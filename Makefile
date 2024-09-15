.PHONY: init plan apply apply-with-scan apply-with-medium-low-scan destroy

# Terraform Init
init:
	terraform -chdir=demo-infra init

# Terraform Plan and scan for issues
plan:
	terraform -chdir=demo-infra plan
	python3 scan.py

# Apply without running the scan
apply:
	terraform -chdir=demo-infra apply --auto-approve

# Apply with scan, abort if critical issues are found, continue with warnings for medium/low, but if medium severity issues found, require manual confirmation
apply-with-scan:
	@python3 scan.py
	@CRITICAL_ISSUES=$$(python3 scan.py | grep -i "^HIGH issues found:" | wc -l); \
	if [ $$CRITICAL_ISSUES -gt 0 ]; then \
		echo "High severity issues found, aborting apply."; \
		exit 1; \
	fi
	@MEDIUM_ISSUES=$$(python3 scan.py | grep -i "^MEDIUM issues found:" | wc -l); \
	if [ $$MEDIUM_ISSUES -gt 0 ]; then \
		echo "Medium severity issues found, proceeding with manual confirmation."; \
		terraform -chdir=demo-infra apply; \
	else \
		LOW_ISSUES=$$(python3 scan.py | grep -i "^LOW issues found:" | wc -l); \
		if [ $$LOW_ISSUES -gt 0 ]; then \
			echo "Low severity issues found, proceeding."; \
		fi; \
		terraform -chdir=demo-infra apply --auto-approve; \
	fi

# Terraform Destroy (tears down the infrastructure)
destroy:
	terraform -chdir=demo-infra destroy --auto-approve
