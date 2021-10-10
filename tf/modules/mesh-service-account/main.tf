resource "google_service_account" "sa" {
  account_id = "${var.name}-sa"
  display_name = "sa"
}

resource "google_project_iam_member" "role" {
  role = var.role
  member = "serviceAccount:${google_service_account.sa.email}"
}
