-- ngx.log(ngx.ERR, "Starting init.lua")

-- Init shared dict
local colyseus = ngx.shared.colyseus

local function loadNodeToSharedDict()
    local redis_host
    if not os.getenv("REDIS_HOST") then
        redis_host = "172.31.0.9"
    else
        redis_host = os.getenv("REDIS_HOST")
    end

    if not os.getenv("REDIS_PORT") then
        redis_port = 6379
    else
        redis_port = os.getenv("REDIS_PORT")
    end

    -- ngx.log(ngx.ERR, "Redis Host is ", redis_host)

    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeouts(1000, 1000, 1000) -- 1 sec
    
    local ok, err = red:connect( redis_host, redis_port)

    if not ok then
        ngx.log(ngx.ERR, "Redis in init.lua failed to connect: ", err)
        -- ngx.say("Unable to connect to redis!")
        return
    end

    -- ngx.log(ngx.ERR, "Redis connect successfully host:", redis_host, " port:", redis_port)

    local NODES_SET = "colyseus:nodes"
    local nodes, err = red:smembers(NODES_SET)
    if err ~= nil then
        -- reply no nodes using ngx.say
        ngx.log(ngx.ERR,"Discovery getNodeList: no nodes", err)
        ngx.exit(ngx.OK)
        return
    else
        -- ngx.log(ngx.ERR,"Discovery getNodeList, number of nodes: " .. #nodes)
        for _, data in ipairs(nodes) do
            -- ngx.log(ngx.ERR,"for ipairs",data)
            local processId, targetHost = data:match("([^/]+)/(.+)")

            local default_host, flags = colyseus:get("default")
            if default_host == nil then
                ngx.log(ngx.ERR,"Set default host to default_host")
                colyseus:set("default", targetHost)
            end

            -- ngx.log(ngx.ERR, "  processId: " .. processId .. ", targetHost: " .. targetHost)

            local ok, err = colyseus:safe_add(processId, targetHost)
            -- ngx.log(ngx.ERR, "safe_add host ok=", ok, " err=", err)
        end
    end -- end if err ~= nil

    local keys = colyseus:get_keys()

    for i, key in ipairs(keys) do
        if key ~= "default" then
            -- ngx.log(ngx.ERR, "KEYS key=", key, " i=", i)

            local value, flags = colyseus:get(key)
            --ngx.say(key .. ": " .. value)

            local host, port = string.match(value, "([^:]+):(%d+)")
            local sock = ngx.socket.tcp()
            local success, err = sock:connect(host, port)
            if not success then

                local redis_set_member_to_delete = key .. "/" .. value
                local res, err = red:srem( NODES_SET , redis_set_member_to_delete )
                if not res then
                    ngx.log(ngx.ERR, "Failed to remove value from set: ", err)
                    return
                end
                colyseus:delete(key)

                -- Also delete from default host
                local default_host, flags = colyseus:get("default")
                if default_host == value then
                    colyseus:delete("default")
                end

                ngx.log(ngx.ERR, "Delete unable to connect target host=", host, " port=", port, " redis_set_member_to_delete=", redis_set_member_to_delete)
                --ngx.say("Port " .. port .. " is closed for host " .. host)

            else

              --ngx.say("Port " .. port .. " is open for host " .. host)
              sock:close()
            end

        end
    end

end -- end loadNodeToSharedDict

loadNodeToSharedDict()
