return {
  name = "redis-test-processor",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            dict_name = {
              type = "string",
              default = "redis_cluster_slot_locks",
              required = true
            }
          },
          {
            refresh_lock_key = {
              type = "string",
              default = "refresh_lock",
              required = true
            }
          },
          {
            name = {
              type = "string",
              default = "redisCluster",
              required = true
            }
          },
          {
            redis_host = {
              type = "string",
              default = "redis-1",
              required = true
            }
          },
          {
            redis_port = {
              type = "integer",
              default = 6379,
              required = true
            }
          },
          {
            keepalive_timeout = {
              type = "integer",
              default = 60000,
              required = true,
              gt = 0
            }
          },
            {
            keepalive_cons = {
              type = "integer",
              default = 1000,
              required = true,
              gt = 0
            }
          },
          {
            connect_timeout = {
              type = "integer",
              default = 1000,
              required = true,
              gt = 0
            }
          },
          {
            lock_timeout = {
              type = "integer",
              default = 5,
              required = true,
              gt = 0
            }
          },
          {
            max_redirection = {
              type = "integer",
              default = 5,
              required = true,
              gt = 0
            }
          },
          {
            max_connection_attempts = {
              type = "integer",
              default = 1,
              required = true,
              gt = 0
            }
          },
          {
            redis_password = {
              type = "string",
              required = false,
              encrypted = true
            }
          }
        }
      }
    }
  }
}