# terraform/outputs.tf

output "kubeconfig_command" {
  description = "The command to run to configure kubectl for the EKS cluster."
  # The cluster name is exposed via the 'cluster_id' attribute in this module version.
  # The region can be taken directly from the AWS provider configuration.
  value       = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${module.eks.cluster_id}"
}

# We need to explicitly ask Terraform for the current region
data "aws_region" "current" {}