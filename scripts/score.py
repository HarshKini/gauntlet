#!/usr/bin/env python3
import json, math
from pathlib import Path, PurePath
def read_json(p, default): 
    try: return json.load(open(p))
    except Exception: return default
def clamp01(x): return max(0.0, min(1.0, x))
def main():
    trivy = read_json("artifacts/trivy.json", {"critical":0,"high":0,"medium":0,"low":0})
    checkov = read_json("artifacts/checkov.json", {"failed":0})
    opa = read_json("artifacts/opa.json", {"deny":0})
    k6 = read_json("artifacts/k6.json", {"p95_ms":300,"error_rate":0.0})
    cost = read_json("artifacts/cost.json", {"signal":0.0})

    sec_worst = trivy["critical"]*1.0 + trivy["high"]*0.5 + checkov["failed"]*0.2
    sec_score = 1.0 if sec_worst==0 else 1.0 - min(1.0, (math.log10(1+sec_worst)/2.0))
    pol_score = 1.0 if opa["deny"]==0 else clamp01(1.0 - opa["deny"]*0.1)
    perf_score = clamp01((500 - k6["p95_ms"])/500)
    rel_score  = clamp01(1.0 - k6["error_rate"]*10)
    cost_score = clamp01(1.0 - clamp01(cost["signal"]))

    final = (sec_score*.40 + pol_score*.20 + perf_score*.20 + rel_score*.10 + cost_score*.10)*100.0
    result = {
      "scores": {
        "security": round(sec_score*100,2), "policy": round(pol_score*100,2),
        "performance": round(perf_score*100,2), "reliability": round(rel_score*100,2),
        "cost": round(cost_score*100,2)
      },
      "final": round(final,2)
    }
    Path("artifacts/shipscores").mkdir(parents=True, exist_ok=True)
    json.dump(result, open("artifacts/shipscores/score.json","w"), indent=2)
    print(f"""### ShipScore
- Security: {result['scores']['security']}%
- Policy: {result['scores']['policy']}%
- Performance: {result['scores']['performance']}%
- Reliability: {result['scores']['reliability']}%
- Cost: {result['scores']['cost']}%

**Final ShipScore: {result['final']}%**
""")
if __name__ == "__main__": main()
