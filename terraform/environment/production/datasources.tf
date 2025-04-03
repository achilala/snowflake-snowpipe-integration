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
    },
    analytics = {
      name    = "ANALYTICS"
      comment = "This database stores transformed data for analytics."
      schemas = {
        staging = {
          name    = "STAGING"
          comment = "This schema stores flattened raw data."
          tables = {}
        },
        mart = {
          name    = "MART"
          comment = "This schema stores transformed and analytics-ready data."
          tables = {}
        }
      }
    }
  }
}
