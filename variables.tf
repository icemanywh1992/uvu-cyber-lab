variable "aws_region" {
  type    = string
  default = "us-west-2"
}
variable "course_id" {
  type    = string
  default = "it3200"
}
variable "student_id" {
  type    = string
  default = "yourname"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.student_id))
    error_message = "Use lowercase letters, digits and hyphens only."
  }
}
variable "kali_ami_id" {
  type        = string
  description = "Verified Kali Linux x86_64 EC2 AMI ID for the selected region. Marketplace subscription or a custom AMI may be required."
  validation {
    condition     = can(regex("^ami-[0-9a-f]{8}([0-9a-f]{9})?$", var.kali_ami_id))
    error_message = "Supply a valid AWS AMI ID."
  }
}
variable "linux_instance_type" {
  type    = string
  default = "t3.medium"
}
variable "windows_instance_type" {
  type    = string
  default = "t3.large"
}
