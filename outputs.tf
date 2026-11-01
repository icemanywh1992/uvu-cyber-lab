output "vm_names" { value = { for os, vm in aws_instance.lab : os => vm.tags.Name } }
output "instance_ids" { value = { for os, vm in aws_instance.lab : os => vm.id } }
output "image_ids" {
  description = "AMI IDs used by the lab instances"
  value       = { for os, vm in aws_instance.lab : os => vm.ami }
  sensitive   = true
}