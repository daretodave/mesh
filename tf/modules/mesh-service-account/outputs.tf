output "sa-email" {
  description = "The sa role"
  value = google_service_account.sa.email
}
output "sa-account-id" {
  description = "The sa account id"
  value = google_service_account.sa.account_id
}
