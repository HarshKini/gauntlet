# Harsh Gauntlet — DevOps/AWS Innovation Starter

A one-command mini Gauntlet that builds a Node app in Docker, runs it on a dynamic port, scans it (Trivy, Checkov), enforces policy (OPA/Conftest), load-tests it (k6), computes a ShipScore, emits a CDR, and proposes an auto-remediation Terraform change.

## Run
```bash
./scripts/harsh.sh all
# or: make all

