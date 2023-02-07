local colyseus = ngx.shared.colyseus

local current_url = ngx.var.request_uri

-- This variable will send to proxy_pass
ngx.var.final_url = current_url

local matchedProcessId = string.match(current_url, "/([a-zA-Z0-9%-_]+)/[a-zA-Z0-9%-_]+%?")
-- ngx.log(ngx.ERR, "The matched process id is: ", matchedProcessId)

local default_host, flags = colyseus:get("default")
-- ngx.log(ngx.ERR, "The default host is: ", default_host)

local value, flags = colyseus:get(matchedProcessId)

if value ~= nil then

    ngx.var.final_url = value
    ngx.log(ngx.ERR, "Final target: ", ngx.var.final_url)

else

    ngx.var.final_url = default_host
    ngx.log(ngx.ERR, "Use default target: ", ngx.var.final_url)

end

