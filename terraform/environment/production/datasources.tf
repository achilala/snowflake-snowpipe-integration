variable "datasources" {
  description = "Map of database objects necessary for integration."
  type        = map(any)
  default = {
    raw = {
      name    = "RAW"
      comment = "This database stores raw data."
      schemas = {
        gitlab = {
          name    = "GITLAB"
          comment = "This schema stores raw GITLAB data."
          tables = {
            merge_requests = {
              name    = "MERGE_REQUESTS"
              comment = "This table stores raw MERGE_REQUESTS data."
            },
            users = {
              name    = "USERS"
              comment = "This table stores raw USERS data."
            }
          }
        },
        predictit = {
          name    = "PREDICTIT"
          comment = "This schema stores raw PREDICTIT data."
          tables = {
            markets = {
              name    = "MARKETS"
              comment = "This table stores raw MARKETS data."
            }
          }
        }
      }
    }
  }
}
