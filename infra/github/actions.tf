resource "github_actions_repository_permissions" "stdlib" {
  repository = github_repository.stdlib.name
  enabled    = false
}

resource "github_workflow_repository_permissions" "stdlib" {
  repository                       = github_repository.stdlib.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}
