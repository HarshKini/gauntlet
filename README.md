# 🚀 Harsh Gauntlet — End-to-End DevSecPerf Pipeline

This project is my **innovation starter for AWS + DevOps communities**.  
It builds a Node.js app, runs security + policy scans, load-tests it, calculates a **ShipScore**, and even proposes **auto-remediation** Terraform fixes.  

Designed **100% manually from scratch** (no templates, no forks).  
Built to show how a **non-IT fresher** can design enterprise-grade pipelines like those used in Big 4 companies.

---

## ✨ Features

- **Dockerized app** → Node.js server packaged in `harsh-app`  
- **Dynamic port mapping** → avoids conflicts with already-used ports  
- **Security scanning** → [Trivy](https://aquasecurity.github.io/trivy/) (container vulnerabilities)  
- **IaC scanning** → [Checkov](https://www.checkov.io/) (Terraform IaC checks)  
- **Policy enforcement** → [OPA/Conftest](https://www.openpolicyagent.org/) with Rego v1 rules  
- **Load testing** → [k6](https://k6.io/) (latency & error rate)  
- **ShipScore** → Aggregated metrics:  
  - Security  
  - Policy  
  - Performance  
  - Reliability  
  - Cost  
- **CDR (Continuous Delivery Report)** → YAML reports for every run  
- **Auto-Remediation** → Terraform proposals for failed policies (e.g., S3 block public access)  

---

## 🖥️ How to Run

Clone this repo and execute:

```bash
./scripts/harsh.sh all
# or
make all
```

That’s it — the script runs the **entire gauntlet**:
1. Builds & runs app in Docker  
2. Runs Trivy, Checkov, OPA scans  
3. Executes k6 performance test  
4. Aggregates into a ShipScore  
5. Writes CDR report  
6. Generates Terraform proposal for fixes  
7. Cleans up the container  

---

## 📊 Example Output

### ✅ k6 Load Test
```
http_req_duration
✓ 'p(95)<500' p(95)=19.45ms

http_req_failed
✓ 'rate<0.05' rate=0.00%
```

### 📈 ShipScore
```
- Security: 91.2%
- Policy: 100.0%
- Performance: 96.11%
- Reliability: 100.0%
- Cost: 100.0%

**Final ShipScore: 95.7%**
```

### 🛠️ Auto-Remediation Proposal
```
proposals/2025-08-27T20-43-18_s3_block_public_access.tf
```

---

## 📂 Artifacts Produced

- `artifacts/trivy.json` → summarized vulnerabilities  
- `artifacts/checkov.json` → IaC failed checks count  
- `artifacts/opa.json` → policy denies  
- `artifacts/k6.json` → p95 latency & error rate  
- `artifacts/shipscores/score.json` + `shipscores_summary.md` → numeric + markdown ShipScore  
- `cdrs/*.yaml` → continuous delivery reports  
- `proposals/*.tf` → auto-generated Terraform fixes  

---

## 📸 Recommended Screenshots (for GitHub & LinkedIn)

1. **k6 results block** → shows latency & 0% errors  
2. **ShipScore summary** → highlights **95.7% score**  
3. **Auto-remediation proposal filename** → proof of infra-as-code fix  

---

## 🛠️ Requirements

- Docker (with host-gateway support)  
- Python 3  
- jq  
- Terraform (for infra/ directory)  

---

## 🌍 Why This Matters

This project demonstrates how modern IT pipelines:  
- Integrate **security, policy, performance, and reliability** in one workflow  
- Produce **machine-readable artifacts** for teams  
- Auto-generate **remediation-as-code** proposals  
- Can be built **manually by one person** (even a fresher)  

It is my attempt to show the world that **DevOps + AWS innovation isn’t limited to big companies** — individuals can build & share impactful systems.  

---

## 🤝 Credits

Created by **Harsh Kini** — on a journey to change how AWS + DevOps pipelines are perceived.  
Follow my work:  
- 🌐 [GitHub](https://github.com/HarshKini)  
- 💼 [LinkedIn](https://linkedin.com)  

---

## 🏆 Milestone

Latest run achieved:  
- **p95 latency: 19.45ms**  
- **Error rate: 0.00%**  
- **Final ShipScore: 95.7%**

A complete end-to-end **DevSecPerf pipeline**, done manually.  
