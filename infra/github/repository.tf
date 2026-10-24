# Preserve the existing settings during adoption. Harden in a separate change.
resource "github_repository" "stdlib" {
  name         = "stdlib"
  description  = ""
  homepage_url = ""
  visibility   = "public"
  topics       = []

  has_issues      = true
  has_discussions = false
  has_projects    = false
  has_wiki        = false
  is_template     = false
  archived        = false

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = false
  allow_update_branch    = true
  allow_forking          = true
  delete_branch_on_merge = true

  # Inactive while merge commits are disabled.
  # Match GitHub defaults to avoid provider drift.
  merge_commit_title          = "MERGE_MESSAGE"
  merge_commit_message        = "PR_TITLE"
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "BLANK"
  web_commit_signoff_required = false

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }

  lifecycle {
    prevent_destroy = true

    # v6.13.0 leaves this deprecated, no-op flag unset on import but defaults
    # it to false in configuration, otherwise causing an unnecessary update.
    ignore_changes = [ignore_vulnerability_alerts_during_read]
  }
}

resource "github_branch_default" "stdlib" {
  repository = github_repository.stdlib.name
  branch     = "main"
}
