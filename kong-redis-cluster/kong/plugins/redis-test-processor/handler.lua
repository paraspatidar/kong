local kong = kong
local redis = require "resty.rediscluster"

local RedisTestProcessor = {
  PRIORITY = 1000,
  VERSION = "1.0.1"  -- Bumped version
}

-- per‑worker cache (one instance per unique cluster name)
local instances = {}

local function get_redis_connection(conf)
  local worker_id = ngx.worker.id()
  --check for this host ,if we already have an instance return that
  local key = conf.name 
  local _redis_instance = instances[key]
  if _redis_instance then
    kong.log.err("[Worker ID: ", worker_id, "] CACHE HIT:found instance in instance list by host ", key)
    return _redis_instance
  end

   kong.log.err("[Worker ID: ", worker_id, "] CACHE MISS : no instance found in instance list by host ,thus will initlize it,host:", key)
  --else create a new instance

    local cfg = {
    name                  = conf.name,
    serv_list        = {
        { ip = conf.redis_host, port = conf.redis_port }
    },
    keepalive_timeout     = conf.keepalive_timeout,
    keepalive_cons        = conf.keepalive_cons,
    connect_timeout       = conf.connect_timeout,
    max_redirection       = conf.max_redirection,
    max_connection_attempts = conf.max_connection_attempts,
    refresh_lock_key      = conf.refresh_lock_key,
    dict_name             = conf.dict_name,
    auth                  = conf.redis_password, -- optional
  }
  
  local inst, err = redis:new(cfg)
  if not inst then
    kong.log.err("Redis cluster init failed: ", err)
    return nil, err
  end
  
  kong.log.info("intialize  Redis with details ", cfg.serv_list)
  --add to instances cache
  instances[key] = inst
  kong.log.err("added instance to instance list by host ", key)
  return inst
end

local function is_redirection_exhausted(err)
  return err and err:lower():find("too many redirections")
end

local function is_connection_exhausted(err)
  return err and err:lower():find("failed to connect")
end


function RedisTestProcessor:access(config)
  
  -- Get Authorization header
  local action = kong.request.get_header("action")
  if not action then
      kong.log.info("No action header found")
    return
  end


  local key = kong.request.get_header("key")
  if not key then
      kong.log.info("No key header found")
    return
  end

 

 --now check the value of action if it set to "set" then set the key value in redis and return
  if action == "set" then

      local value = kong.request.get_header("value")
      if not value then
          kong.log.info("No value header found")
        return
      end

      local red, err = get_redis_connection(config)
      if not red then
        kong.log.err("Redis connection error: ", err)
        return
      end
      
      kong.log.info("Setting Redis key ", key, " to value ", value)
      local res, err = red:set(key, value)
      
      
      if err then
        kong.log.err("Redis SET error for key ", key, ": ", err)
        return
      end
      
      kong.log.info("Successfully set Redis key ", key)
      kong.ctx.shared.result = tostring("success")
      return
  else
    kong.log.info("action is not set, so proceeding to read key from redis")
    -- its get then the value from redis based on key
      local red, err = get_redis_connection(config)
      if not red then
        kong.log.err("Redis connection error: ", err)
        return
      end


      local res, err = red:get(key)
      if err then
        kong.log.err("Redis GET error for key ", key, ": ", err)
        return
      end


      -- Return nil if key doesn't exist (not an error)
      if res == ngx.null then
        kong.log.info("Redis key does not exist: ", res)
        return nil
      end

      kong.ctx.shared.result = tostring(res)
      kong.log.info("Value for Redis key ", key, " is: ", res)
      return
      
  end

end

function RedisTestProcessor:header_filter(config)
  if kong.ctx.shared.result then
    kong.response.set_header(config.res_limit_header or "x-res", kong.ctx.shared.result)
  end
end

return RedisTestProcessor