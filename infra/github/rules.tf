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

    # Enable only after a real PR verifies the instance's status context.
    dynamic "required_status_checks" {
      for_each = var.woodpecker_pr_status_context == null ? [] : [var.woodpecker_pr_status_context]

      content {
        required_check {
          context = required_status_checks.value
        }
      }
    }
  }
}
