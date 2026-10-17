locals {
  # Catppuccin accents from all four flavors: https://catppuccin.com/palette/
  labels = {
    "bug" = {
      color       = "d20f39" # Latte Red
      description = "Something isn't working"
    }
    "documentation" = {
      color       = "8caaee" # Frappé Blue
      description = "Improvements or additions to documentation"
    }
    "duplicate" = {
      color       = "b7bdf8" # Macchiato Lavender
      description = "This issue or pull request already exists"
    }
    "enhancement" = {
      color       = "cba6f7" # Mocha Mauve
      description = "New feature or request"
    }
    "invalid" = {
      color       = "e64553" # Latte Maroon
      description = "This doesn't seem right"
    }
    "wontfix" = {
      color       = "ea999c" # Frappé Maroon
      description = "This will not be worked on"
    }
    "needs-info" = {
      color       = "eed49f" # Macchiato Yellow
      description = "Waiting on the reporter for more information"
    }
    "needs-triage" = {
      color       = "fe640b" # Latte Peach
      description = "Needs maintainer evaluation before implementation"
    }
    "ready-for-agent" = {
      color       = "a6e3a1" # Mocha Green
      description = "Fully specified and ready for autonomous agent implementation"
    }
    "ready-for-human" = {
      color       = "81c8be" # Frappé Teal
      description = "Requires human implementation"
    }
    "wayfinder:map" = {
      color       = "1e66f5" # Latte Blue
      description = "Wayfinding map of decisions, tickets, and open questions"
    }
    "wayfinder:research" = {
      color       = "7dc4e4" # Macchiato Sapphire
      description = "Research ticket linked to a wayfinding map"
    }
    "wayfinder:prototype" = {
      color       = "f5c2e7" # Mocha Pink
      description = "Prototype ticket linked to a wayfinding map"
    }
    "wayfinder:grilling" = {
      color       = "ef9f76" # Frappé Peach
      description = "Design interview ticket linked to a wayfinding map"
    }
    "wayfinder:task" = {
      color       = "a6da95" # Macchiato Green
      description = "Implementation ticket linked to a wayfinding map"
    }
  }
}

# Authoritative: labels omitted here will be deleted on apply. Renaming a label
# deletes the old label and loses its issue/PR associations; review plans closely.
resource "github_issue_labels" "stdlib" {
  repository = github_repository.stdlib.name

  dynamic "label" {
    for_each = local.labels

    content {
      name        = label.key
      color       = label.value.color
      description = label.value.description
    }
  }
}
