# Uncomment when ready to deploy; start minimal to avoid costs.

# Example Budget guardrail
# resource "aws_budgets_budget" "monthly" {
#   name         = "${var.project_name}-budget"
#   budget_type  = "COST"
#   limit_unit   = "USD"
#   limit_amount = var.monthly_budget_usd
#   time_unit    = "MONTHLY"
# }

# Example (future) ECR
# resource "aws_ecr_repository" "app" {
#   name = "${var.project_name}-app"
#   image_scanning_configuration { scan_on_push = true }
#   force_delete = true
# }
