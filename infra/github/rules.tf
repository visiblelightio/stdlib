resource "github_repository_ruleset" "main" {
  name        = "main-requires-pr"
  repository  = github_repository.stdlib.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  # No bypass actors: administrators must use pull requests too.
  rules {
    pull_request {
      allowed_merge_methods             = ["squash"]
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = false
      # Require a PR without requiring another reviewer for solo development.
      required_approving_review_count = 0
    }

    # Require every observed PR workflow status, without adding bypass actors.
    dynamic "required_status_checks" {
      for_each = length(var.woodpecker_pr_status_contexts) == 0 ? [] : [var.woodpecker_pr_status_contexts]

      content {
        dynamic "required_check" {
          for_each = required_status_checks.value

          content {
            context = required_check.value
          }
        }
      }
    }
  }
}
