#!/usr/bin/env python3
import json, time, os
from pathlib import Path
opa = {}
try: opa = json.load(open("artifacts/opa.json"))
except: opa = {"deny":0}
ts = time.strftime("%Y-%m-%dT%H-%M-%S")
Path("proposals").mkdir(exist_ok=True)
body = """# Auto-proposal: enforce S3 block public access
# Review & edit before apply.
resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
"""
out = f"proposals/{ts}_s3_block_public_access.tf"
open(out,"w").write(body)
print(out)
