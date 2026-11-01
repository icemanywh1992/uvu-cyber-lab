# UVU IT 3200 Cyber Lab — Terraform AWS EC2

This Terraform project defines **exactly three EC2 virtual machines** in AWS: Ubuntu 24.04 LTS, Windows Server 2022, and Kali Linux. No cybersecurity software is installed. All VMs use the naming convention `<os>-uvu-<course_id>-<student_id>`.

## Images

| VM | Publisher / image | Terraform selection |
|---|---|---|
| Ubuntu | Canonical Ubuntu Server 24.04 LTS (Noble), amd64, gp3 | AWS public SSM parameter `/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id` |
| Windows | Amazon Windows Server 2022 English Full Base | AWS public SSM parameter `/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base` |
| Kali | Kali Linux x86_64 AWS-compatible image | `var.kali_ami_id`, provided by deployer after verifying the publisher and AMI in the target region |

The Ubuntu and Windows parameter values resolve to region-specific AMI IDs at deployment time and may change as publishers release updates. Inspect `terraform output image_ids` to record the exact deployed IDs. Kali image IDs are also region-specific. For Kali, find a suitable Kali Linux AMI in EC2 > AMIs or AWS Marketplace, verify the publisher, architecture, virtualization and root device, and supply its ID. An AWS Marketplace subscription and any applicable product charges may be required **before** `terraform apply`. Alternatively, create an authorized, cloud-compatible Kali AMI in the region and supply that ID. Do not use an arbitrary image just because its name includes Kali. Confirm availability and terms for your AWS account.

## Prerequisites

- Terraform >= 1.5 and AWS credentials with EC2, VPC describe, and SSM parameter read permissions.
- AWS account with EC2 quotas, billing enabled, and permission to launch the chosen images and instance types.
- A **default VPC with at least one default subnet** in the selected region. This project reuses it; it does not create a new VPC.
- An approved Kali AMI ID for the region (and Marketplace subscription if needed).
- AWS CLI is optional but useful for checking identity and image metadata.

## Deployment

1. Clone the repository and enter its directory.
2. Configure AWS credentials **outside** the repository, for example with `aws sso login --profile uvu-lab` and `AWS_PROFILE=uvu-lab` (PowerShell: `$env:AWS_PROFILE = "uvu-lab"`).
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace `student_id`, `aws_region`, and `kali_ami_id` with actual values. The example Kali ID is a **placeholder**, not a verified image.
4. Run:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
terraform output vm_names
terraform output image_ids
```

5. Verify in the AWS EC2 console that exactly three instances exist with the required names and images. Record screenshots for the assignment. Confirm the Kali image metadata explicitly identifies Kali Linux.
6. To avoid ongoing charges, run `terraform destroy` after finishing, and verify resources are gone.

## Configuration

- `aws_region`: AWS region; default `us-west-2`.
- `course_id`: course code; default `it3200`.
- `student_id`: your lowercase name/identifier; default `yourname`.
- `kali_ami_id`: **required**, verified Kali AMI in chosen region.
- `linux_instance_type`: Ubuntu and Kali instance type; default `t3.medium`.
- `windows_instance_type`: Windows instance type; default `t3.large`.

## Security, limitations, and cost

The VMs have encrypted gp3 root volumes, **no public IPs**, and a security group with **no inbound rules**. Outbound traffic is allowed at the security group level, but private instances in a default subnet will generally **not have internet access** without a NAT or appropriate VPC endpoints. No SSH, RDP, or SSM access is configured. The assignment is infrastructure provisioning only, not remote login. If access is required later, configure an approved private access method rather than opening SSH/RDP to the internet.

All three instances incur EC2 and EBS charges while running. Windows licensing is typically reflected in its instance pricing; Marketplace Kali images may have separate software charges. Check the current AWS pricing and any Marketplace terms before applying. The selected instance types and images must be compatible in your region. The AWS account must have capacity and quotas. A Marketplace image may have root volume size or product-specific requirements that require adjustments.

Do not commit AWS keys, credentials, private keys, `.tfvars` files, Terraform plans or state files. Terraform state can contain sensitive data; use a protected backend for collaborative deployments. This project deliberately does not create a remote state backend.

## Repository structure

- `main.tf`: provider, OS image lookups, security group and exactly three instances via `for_each`.
- `variables.tf`: input variables and validation.
- `outputs.tf`: instance names, IDs and AMI IDs.
- `terraform.tfvars.example`: safe sample configuration; the Kali AMI is a placeholder.
- `.gitignore`: excludes credentials and state artifacts.

## References

- Ubuntu AMI discovery: https://ubuntu.com/aws/docs/aws-how-to/instances/find-ubuntu-images/
- AWS Windows AMI parameters: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami-parameter-store.html
- AWS Marketplace subscriptions: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-paid-amis-purchasing-paid-ami.html
