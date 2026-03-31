variable "identity_project_id" {
  description = "Host project where the service account, workload identity pool, and provider are created."
  type        = string

  validation {
    condition     = trimspace(var.identity_project_id) != ""
    error_message = "identity_project_id must not be empty."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.identity_project_id))
    error_message = "identity_project_id must only contain digits lowercase letters and hyphens, start with a lowercase letter, end with a lowercase letter or digits and be 6-30 characters long"
  }
}

variable "service_account_suffix" {
  description = "Suffix appended to tamnoon- for the service account account_id."
  type        = string

  validation {
    condition     = trimspace(var.service_account_suffix) != ""
    error_message = "service_account_suffix must not be empty."
  }

  validation {
    condition     = startswith(var.service_account_suffix, "-") == false
    error_message = "service_account_suffix must not start with -."
  }

  validation {
    condition     = endswith(var.service_account_suffix, "-") == false
    error_message = "service_account_suffix must not end with -."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service_account_suffix))
    error_message = "service_account_suffix must contain only lowercase letters, digits, and hyphens."
  }

  validation {
    condition     = length("tamnoon-${var.service_account_suffix}") <= 30
    error_message = "service_account_suffix is too long; tamnoon-<suffix> must be 30 characters or fewer."
  }
}

variable "identity_suffix" {
  description = "Suffix used to derive the workload identity pool and provider IDs."
  type        = string

  validation {
    condition     = trimspace(var.identity_suffix) != ""
    error_message = "identity_suffix must not be empty."
  }

  validation {
    condition     = startswith(var.identity_suffix, "-") == false
    error_message = "identity_suffix must not start with -."
  }

  validation {
    condition     = endswith(var.identity_suffix, "-") == false
    error_message = "identity_suffix must not end with -."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.identity_suffix))
    error_message = "identity_suffix must contain only lowercase letters, digits, and hyphens."
  }

  validation {
    condition     = length("tamnoon-pool-${var.identity_suffix}") <= 32 && length("tamnoon-aws-${var.identity_suffix}") <= 32
    error_message = "identity_suffix is too long; the derived pool and provider IDs must be 32 characters or fewer."
  }
}

variable "aws_account_id" {
  description = "AWS account ID trusted by the workload identity pool provider."
  type        = string

  validation {
    condition     = length(var.aws_account_id) == 12
    error_message = "aws_account_id length is always 12 characters"
  }

  validation {
    condition     = can(regex("^[0-9]+$", var.aws_account_id))
    error_message = "aws_account_id must only contain digits"
  }
}

variable "trusted_aws_role_name" {
  description = "Trusted AWS role name"
  type        = string

  validation {
    condition     = trimspace(var.trusted_aws_role_name) != ""
    error_message = "trusted_aws_role_name must not be empty."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@-]+$", var.trusted_aws_role_name))
    error_message = "trusted_aws_role_name must only contain letters, digits, plus signs, equal signs, commas, dots, at signs and hyphens"
  }
}

variable "project_ids" {
  description = "Semicolon-delimited string of project IDs that receive the requested roles when organization_id is not set."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.project_ids) == "" || alltrue([for project_id in split(";", var.project_ids) : trimspace(project_id) != ""])
    error_message = "project_ids must not contain empty items."
  }

  validation {
    condition = trimspace(var.project_ids) == "" || alltrue([
      for project_id in split(";", var.project_ids) : can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", trimspace(project_id)))
    ])
    error_message = "Each project ID must only contain lowercase letters, digits, and hyphens, start with a lowercase letter, end with a lowercase letter or digit, and be 6-30 characters long."
  }
}

variable "folder_ids" {
  description = "Semicolon-delimited string of folder IDs that receive the requested roles when organization_id is not set."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.folder_ids) == "" || alltrue([for folder_id in split(";", var.folder_ids) : trimspace(folder_id) != ""])
    error_message = "folder_ids must not contain empty items."
  }

  validation {
    condition = trimspace(var.folder_ids) == "" || alltrue([
      for folder_id in split(";", var.folder_ids) : can(regex("^[0-9]+$", trimspace(folder_id)))
    ])
    error_message = "Each folder ID must contain only digits."
  }
}

variable "organization_id" {
  description = "Optional organization ID. When set, organization-level grants are created and project_ids/folder_ids are ignored."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.organization_id == null || can(regex("^[0-9]+$", var.organization_id))
    error_message = "organization_id must only contain digits."
  }
}
