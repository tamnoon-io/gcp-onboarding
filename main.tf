locals {
  roles = toset([
    "roles/viewer",
    "roles/browser",
    "roles/iam.securityReviewer",
    "roles/cloudasset.viewer",
    "roles/logging.privateLogViewer",
    "roles/serviceusage.serviceUsageConsumer",
  ])

  use_org_scope = var.organization_id != null

  service_account_id            = "tamnoon-${var.service_account_suffix}"
  workload_identity_pool_id     = "tamnoon-pool-${var.identity_suffix}"
  workload_identity_provider_id = "tamnoon-aws-${var.identity_suffix}"
  trusted_aws_role              = "arn:aws:sts::${var.aws_account_id}:assumed-role/${var.trusted_aws_role_name}"
  project_ids                   = local.use_org_scope || trimspace(var.project_ids) == "" ? [] : toset([for project_id in split(";", var.project_ids) : trimspace(project_id)])
  folder_ids                    = local.use_org_scope || trimspace(var.folder_ids) == "" ? [] : toset([for folder_id in split(";", var.folder_ids) : trimspace(folder_id)])

  project_role_bindings = local.use_org_scope ? {} : {
    for item in flatten([
      for project_id in local.project_ids : [
        for role in local.roles : {
          key  = "project:${project_id}:${role}"
          id   = project_id
          role = role
        }
      ]
    ]) : item.key => item
  }

  folder_role_bindings = local.use_org_scope ? {} : {
    for item in flatten([
      for folder_id in local.folder_ids : [
        for role in local.roles : {
          key  = "folder:${folder_id}:${role}"
          id   = folder_id
          role = role
        }
      ]
    ]) : item.key => item
  }

  organization_role_bindings = local.use_org_scope ? {
    for role in local.roles : role => {
      organization_id = trimspace(var.organization_id)
      role            = role
    }
  } : {}
}

data "google_project" "project" {
  project_id = var.identity_project_id
}

resource "google_service_account" "tamnoon" {
  project      = var.identity_project_id
  account_id   = local.service_account_id
  display_name = local.service_account_id
}

resource "google_iam_workload_identity_pool" "tamnoon" {
  project                   = var.identity_project_id
  workload_identity_pool_id = local.workload_identity_pool_id
  display_name              = "TamnoonWorkloadIdentityPool"
}

resource "google_iam_workload_identity_pool_provider" "aws" {
  project                            = var.identity_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.tamnoon.workload_identity_pool_id
  workload_identity_pool_provider_id = local.workload_identity_provider_id
  display_name                       = local.workload_identity_provider_id
  attribute_condition                = "attribute.aws_role == '${local.trusted_aws_role}'"

  attribute_mapping = {
    "google.subject"     = "assertion.arn"
    "attribute.aws_role" = "assertion.arn.contains('assumed-role') ? assertion.arn.extract('{account_arn}assumed-role/') + 'assumed-role/' + assertion.arn.extract('assumed-role/{role_name}/') : assertion.arn"
  }

  aws {
    account_id = var.aws_account_id
  }
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.tamnoon.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tamnoon.name}/attribute.aws_role/${local.trusted_aws_role}"
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = local.project_role_bindings

  project = each.value.id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.tamnoon.email}"
}

resource "google_folder_iam_member" "service_account_roles" {
  for_each = local.folder_role_bindings

  folder = each.value.id
  role   = each.value.role
  member = "serviceAccount:${google_service_account.tamnoon.email}"
}

resource "google_organization_iam_member" "service_account_roles" {
  for_each = local.organization_role_bindings

  org_id = each.value.organization_id
  role   = each.value.role
  member = "serviceAccount:${google_service_account.tamnoon.email}"
}
