output "workload_identity_pool_id" {
  description = "Workload identity pool ID."
  value       = google_iam_workload_identity_pool.tamnoon.workload_identity_pool_id
}

output "service_account_id" {
  description = "Service account account_id."
  value       = google_service_account.tamnoon.unique_id
}

output "workload_identity_provider_id" {
  description = "Workload identity pool provider ID."
  value       = google_iam_workload_identity_pool_provider.aws.workload_identity_pool_provider_id
}

output "identity_project_number" {
  description = "Identity project number."
  value       = data.google_project.project.number
}
