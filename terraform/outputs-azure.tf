# terraform/outputs-azure.tf

output "aks_kubeconfig_command" {
  description = "The command to run to configure kubectl for the AKS cluster."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks_cluster.name} --overwrite-existing"
}