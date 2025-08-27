#!/usr/bin/env python3
import json, time, os
from pathlib import Path
def read(p, d): 
    try: return json.load(open(p))
    except: return d
ts = time.strftime("%Y-%m-%dT%H-%M-%S")
trivy  = read("artifacts/trivy.json", {"critical":0,"high":0,"medium":0,"low":0})
checkov= read("artifacts/checkov.json", {"failed":0})
opa    = read("artifacts/opa.json", {"deny":0})
k6     = read("artifacts/k6.json", {"p95_ms":300,"error_rate":0.0})
score  = read("artifacts/shipscores/score.json", {"final":0,"scores":{}})
Path("cdrs").mkdir(exist_ok=True)
y = []
y.append(f"id: cdr-{ts}")
y.append("actor: harsh")
y.append("summary:")
y.append(f"  shipscore: {score.get('final',0)}")
y.append("inputs:")
y.append(f"  trivy: {trivy}")
y.append(f"  checkov: {checkov}")
y.append(f"  opa: {opa}")
y.append(f"  k6: {k6}")
recs = []
if trivy.get("critical",0)>0: recs.append("Remove critical image vulns or pin a safer base image.")
if checkov.get("failed",0)>0: recs.append("Fix failing IaC checks (encryption, least-privilege, no-public).")
if opa.get("deny",0)>0: recs.append("Satisfy policy gates (e.g., no public S3).")
if k6.get("p95_ms",0)>500: recs.append("Optimize latency: enable gzip/cache, reduce N+1 calls.")
if not recs: recs.append("All gates clean. Ready to ship.")
y.append("recommendations:")
for r in recs: y.append(f"  - \"{r}\"")
open(f"cdrs/{ts}.yaml","w").write("\n".join(y)+"\n")
print(f"cdrs/{ts}.yaml")
