variable "integration" {
  description = "Map of database names for configuration."
  type        = map(any)

  default = {
    gitlab = {
      users = {
        name    = "USERS"
        comment = "This table stores raw USERS data."
      },
      branches = {
        name    = "BRANCHES"
        comment = "This table stores raw BRANCHES data."
      },
      commits = {
        name    = "COMMITS"
        comment = "This table stores raw COMMITS data."
      },
      projects = {
        name    = "PROJECTS"
        comment = "This table stores raw PROJECTS data."
      },
    }
    jira = {
      users = {
        name    = "USERS"
        comment = "This table stores raw USERS data."
      },
      branches = {
        name    = "BRANCHES"
        comment = "This table stores raw BRANCHES data."
      },
    }
  }
}
