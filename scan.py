import os
import re

# Define specific misconfigurations to look for
misconfigurations = {
    "high": [
        # Full admin access in IAM roles (trigger alert if found)
        {
            "pattern": r'\{\s*Action\s*=\s*"\*"\s*,\s*Effect\s*=\s*"Allow"\s*,\s*Resource\s*=\s*"\*"\s*\}',
            "issue": "IAM Role with Full Administrator Access",
            "resource_check": r'resource\s+"aws_iam_role"'
        },
        # Unencrypted RDS instance (trigger alert if found)
        {
            "pattern": r'resource\s+"aws_db_instance"[\s\S]*storage_encrypted\s*=\s*false',
            "issue": "RDS instance without encryption",
            "resource_check": r'resource\s+"aws_db_instance"'
        },
        # S3 bucket without server-side encryption (alert if resource is absent)
        {
            "pattern": r'resource\s+"aws_s3_bucket_server_side_encryption_configuration"[\s\S]*?sse_algorithm\s*=\s*"aws:kms"',
            "issue": "S3 bucket without server-side encryption",
            "resource_check": r'resource\s+"aws_s3_bucket"'
        }
    ],
    "medium": [
        # EC2 instance with unencrypted EBS volume (alert if found)
        {
            "pattern": r'root_block_device\s*{[\s\S]*?encrypted\s*=\s*false',
            "issue": "EBS volume unencrypted",
            "resource_check": r'resource\s+"aws_instance"'
        },
        # Security group allowing ingress from 0.0.0.0/0 on port 22 (alert if found)
        {
            "pattern": r"ingress\s*{[^}]*?from_port\s*=\s*22[^}]*?cidr_blocks\s*=\s*\[\"0.0.0.0/0\"\]",
            "issue": "Security group allows SSH from 0.0.0.0/0",
            "resource_check": r'resource\s+"aws_security_group"'
        }
    ],
    "low": [
        # Missing S3 bucket logging configuration (alert if resource is absent)
        {
            "pattern": r'resource\s+"aws_s3_bucket_logging"[\s\S]*?target_bucket\s*=\s*aws_s3_bucket\.log_bucket\.id[\s\S]*?target_prefix\s*=\s*"logs/"',
            "issue": "Missing S3 bucket logging configuration",
            "resource_check": r'resource\s+"aws_s3_bucket"'
        }
    ]
}

# Function to remove comments from the file content


def remove_comments(content):
    # Remove single-line comments that start with # or //
    content = re.sub(r'#.*', '', content)
    content = re.sub(r'//.*', '', content)

    # Remove block comments /* ... */
    content = re.sub(r'/\*[\s\S]*?\*/', '', content)

    return content

# Function to scan a file for specific misconfigurations


def scan_file(file_content, filepath, found_issues):
    # Remove comments before scanning
    file_content_no_comments = remove_comments(file_content)

    # Print file header for terminal output
    print(f"\n{'=' * 60}\n")
    print(f"Scanning file: {filepath}")
    print(f"{'-' * 60}")

    for severity, rules in misconfigurations.items():
        for rule in rules:
            # Check if the file contains the relevant resource block
            resource_match = re.search(
                rule["resource_check"], file_content_no_comments, re.DOTALL)

            if resource_match:
                print(f"Found relevant resource block for {
                      rule['issue']} in {filepath}.")
                # Print the matched resource block
                print(f"Resource match content:\n{resource_match.group(0)}")

                # Test if the pattern is found (related to the resource type)
                match = re.search(
                    rule["pattern"], file_content_no_comments, re.DOTALL)

                log_entry = f"Checking pattern: {rule['issue']}...\n"

                if rule["issue"] in ["S3 bucket without server-side encryption", "Missing S3 bucket logging configuration"]:
                    # For absence checks, flag if the pattern is NOT found
                    if not match:
                        log_entry += f"Pattern '{rule['issue']}' NOT found!\n"
                        print(log_entry.strip())
                        if rule['issue'] not in found_issues[severity]:
                            found_issues[severity].append(rule['issue'])
                    else:
                        log_entry += f"Pattern '{rule['issue']}' found.\n"
                        print(f"Pattern match for {rule['issue']}:\n{
                              match.group(0)}")  # Print the matched pattern
                else:
                    # For presence checks, flag if the pattern IS found (i.e., full admin access, unencrypted EBS, etc.)
                    if match:
                        log_entry += f"Pattern '{rule['issue']}' found.\n"
                        print(f"Pattern match for {rule['issue']}:\n{
                              match.group(0)}")  # Print the matched pattern
                        if rule['issue'] not in found_issues[severity]:
                            found_issues[severity].append(rule['issue'])
                    else:
                        log_entry += f"Pattern '{rule['issue']}' NOT found!\n"
                        print(log_entry.strip())

                # Print to terminal
                print(log_entry.strip())
            else:
                print(f"Skipping pattern '{
                      rule['issue']}' - resource type not found.")

    return found_issues

# Function to scan all Terraform files in a directory


def scan_terraform(directory):
    all_results = {"high": [], "medium": [], "low": []}

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".tf"):
                filepath = os.path.join(root, file)
                with open(filepath, "r") as f:
                    file_content = f.read()
                    all_results = scan_file(
                        file_content, filepath, all_results)

    return all_results


# Main entry
if __name__ == "__main__":
    results = scan_terraform("./demo-infra")

    # Print final summary in the terminal
    for severity, issues in results.items():
        if issues:
            print(f"\n{severity.upper()} issues found:")
            for issue in issues:
                print(f" - {issue}")
        else:
            print(f"\nNo {severity.upper()} issues found.")
