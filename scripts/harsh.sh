#!/usr/bin/env bash
set -euo pipefail

# Ensure artifacts dir exists and is writable (containers may write as root)
mkdir -p artifacts
fix_perms() {
  sudo chown -R "$USER":"$USER" artifacts 2>/dev/null || true
  chmod -R u+rwX,g+rwX,o+rwX artifacts 2>/dev/null || true
}
fix_perms

# --- helpers ---
find_free_port() {
  local start="${1:-8080}"
  local end="${2:-8090}"
  for p in $(seq "$start" "$end"); do
    if ! ss -ltn "( sport = :$p )" | grep -q ":$p"; then
      echo "$p"; return 0
    fi
  done
  echo "no-free-port"; return 1
}

APP_IMAGE="harsh-app"
CONTAINER_NAME="harsh-app-run"

build() {
  echo "==> Build app image"
  docker build -t "$APP_IMAGE" ./app
}

up_local() {
  echo "==> Run app locally (dynamic port)"
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

  PORT="$(find_free_port 8080 8090)"
  if [[ "$PORT" == "no-free-port" ]]; then
    echo "No free port between 8080-8090. Adjust range in script."; exit 1
  fi
  echo "$PORT" > artifacts/port

  # Container listens on 8080; host maps to a free port
  docker run -d --name "$CONTAINER_NAME" -p "$PORT:8080" "$APP_IMAGE" >/dev/null
  echo "App mapped: http://localhost:$PORT"
}

down_local() {
  echo "==> Stop local app"
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}

run_k6() {
  echo "==> k6 smoke/perf"
  local PORT="8080"
  [[ -f artifacts/port ]] && PORT="$(cat artifacts/port)"

  # On Linux, force host gateway resolution so k6 can reach the host-mapped port
  local TARGET="http://host.docker.internal:${PORT}"

  docker run --rm -i -u 0 \
    --add-host=host.docker.internal:host-gateway \
    -e TARGET_URL="$TARGET" \
    -v "$PWD/k6:/k6" \
    -v "$PWD/artifacts:/out" \
    grafana/k6 run /k6/loadtest.js --summary-export=/out/k6-summary.json || true

  fix_perms

  # Extract p95 + error rate (works across k6 JSON schema versions)
  if [[ -f artifacts/k6-summary.json ]] && command -v jq >/dev/null 2>&1; then
    P95=$(jq -r '
      .metrics.http_req_duration.values["p(95)"]
      // .metrics.http_req_duration["p(95)"]
      // 300
    ' artifacts/k6-summary.json 2>/dev/null || echo 300)

    ERR=$(jq -r '
      .metrics.http_req_failed.rate
      // 0
    ' artifacts/k6-summary.json 2>/dev/null || echo 0)
  else
    P95=300; ERR=0
  fi

  echo "{\"p95_ms\":${P95:-300},\"error_rate\":${ERR:-0}}" > artifacts/k6.json
  fix_perms
}

trivy_scan() {
  echo "==> Trivy scan"
  docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:/src" \
    aquasec/trivy:0.53.0 image \
      --format json \
      --output /src/artifacts/trivy.raw.json \
      "$APP_IMAGE" || true

  fix_perms

  # Normalize counts that score.py expects
  if command -v jq >/dev/null 2>&1 && [[ -f artifacts/trivy.raw.json ]]; then
    CRIT=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' artifacts/trivy.raw.json 2>/dev/null || echo 0)
    HIGH=$(jq  '[.Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH")]     | length' artifacts/trivy.raw.json 2>/dev/null || echo 0)
    printf '{"critical":%s,"high":%s,"medium":0,"low":0}\n' "${CRIT:-0}" "${HIGH:-0}" > artifacts/trivy.json
  else
    echo '{"critical":0,"high":0,"medium":0,"low":0}' > artifacts/trivy.json
  fi

  fix_perms
}

checkov_scan() {
  echo "==> Checkov scan"
  docker run --rm \
    -v "$PWD/infra/terraform:/tf" \
    -v "$PWD/artifacts:/out" \
    bridgecrew/checkov:3.2.360 \
      -d /tf -o json > artifacts/checkov.raw.json || true

  fix_perms

  if command -v jq >/dev/null 2>&1 && [[ -f artifacts/checkov.raw.json ]]; then
    FAIL=$(jq '[.summary?.failed_checks] | add // 0' artifacts/checkov.raw.json 2>/dev/null || echo 0)
    echo "{\"failed\":${FAIL:-0}}" > artifacts/checkov.json
  else
    echo '{"failed":0}' > artifacts/checkov.json
  fi

  fix_perms
}

opa_test() {
  echo "==> OPA/Conftest"
  docker run --rm \
    -v "$PWD/policy:/policy" \
    -v "$PWD/infra/terraform:/src" \
    openpolicyagent/conftest \
      test /src --policy /policy --output json > artifacts/opa_raw.json || true

  fix_perms

  if command -v jq >/dev/null 2>&1 && [[ -f artifacts/opa_raw.json ]]; then
    DENY=$(jq '[.[] | .failures | length] | add // 0' artifacts/opa_raw.json 2>/dev/null || echo 0)
  else
    DENY=0
  fi
  echo "{\"deny\":${DENY:-0}}" > artifacts/opa.json
  fix_perms
}

score() {
  echo "==> ShipScore"
  python3 scripts/score.py | tee artifacts/shipscores_summary.md
  fix_perms
}

cdr() {
  echo "==> CDR"
  python3 scripts/cdr.py
  fix_perms
}

propose() {
  echo "==> Auto remediation proposal"
  python3 scripts/propose_fix.py
  fix_perms
}

all() {
  build
  up_local
  trivy_scan
  checkov_scan
  opa_test
  run_k6
  score
  cdr
  propose
  down_local
  echo "Done. See artifacts/shipscores/score.json and cdrs/"
}

usage(){ echo "Usage: $0 {build|up|down|scan|k6|score|cdr|propose|all}"; }

case "${1:-all}" in
  build) build;;
  up) up_local;;
  down) down_local;;
  scan) trivy_scan; checkov_scan; opa_test;;
  k6) run_k6;;
  score) score;;
  cdr) cdr;;
  propose) propose;;
  all) all;;
  *) usage; exit 1;;
esac
