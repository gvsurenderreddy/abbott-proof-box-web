require "uci"

local openvpn = {}

openvpn.config_options = {
    "enabled", "client", "dev", "proto", "remote", "resolv_retry", "nobind",
    "persist_key", "persist_tun", "ca", "cert", "key", "comp_lzo", "verb",
    "tun_mtu", "tun_mtu_extra", "mssfix", "ping_restart", "route_delay",
    "auth_user_pass"
}

openvpn.client_name = "api_client"

function openvpn.get_config()
    local config = {}
    local u = uci.cursor()
    for i, c in ipairs(openvpn.config_options) do
        config[c] = u:get("openvpn", openvpn.client_name, c)
    end

    return config
end

function openvpn.set_config(data)
    -- Create a cursor of the config
    local u = uci.cursor()

    -- Custom process auth data
    if data['auth_user_pass'] == 'included' then
        local user = data['auth_username']
        local pass = data['auth_password']

        -- Make auth file
        local af = io.open("/etc/openvpn/auth.txt", "w")
        af:write(user)
        af:write("\n")
        af:write(pass)
        af:write("\n")
        af:close()

        -- Point to the auth
        data['auth_user_pass'] = {"/etc/openvpn/auth.txt",}

        -- Delete processed options
        data['auth_username'] = nil
        data['auth_password'] = nil
    end

    -- Process an included CA certificate
    if data['ca'] then
        -- Write the CA out to a file
        local caf = io.open("/etc/openvpn/ca.crt", "w")
        caf:write(data['ca'])
        caf:close()

        -- Point to where we wrote it
        data['ca'] = "/etc/openvpn/ca.crt"
    end

    -- Clear existing settings
    u:delete("openvpn", openvpn.client_name)
    u:set("openvpn", openvpn.client_name, "openvpn")

    -- Setup management interface
    u:set("openvpn", openvpn.client_name, 'status', '/tmp/openvpn-' .. openvpn.client_name .. '.txt')
    u:set("openvpn", openvpn.client_name, 'status-version', '3')

    -- Set the config options we allow
    for i, c in ipairs(openvpn.config_options) do
        if data[c] then
            u:set("openvpn", openvpn.client_name, c, data[c])
        end
    end
    u:commit("openvpn")

    -- Return the latest config
    return openvpn.get_config()
end

function openvpn.status(env, data)
    if env.REQUEST_METHOD == 'GET' then
        return openvpn.get_service_status()

    elseif env.REQUEST_METHOD == 'POST'
       and env.CONTENT_TYPE == 'application/json'
       and data.status == 'start' then
        openvpn.start_service()

    elseif env.REQUEST_METHOD == 'POST'
       and env.CONTENT_TYPE == 'application/json'
       and data.status == 'stop' then
        openvpn.stop_service()

    else
        return {error='Bad Request'}

    end

    return openvpn.get_service_status()
end

function openvpn.start_service()
    local exit = os.execute('/etc/init.d/openvpn start')
end

function openvpn.stop_service()
    local exit = os.execute('/etc/init.d/openvpn stop')
end

function openvpn.get_service_status()
    local fn = '/tmp/openvpn-' .. openvpn.client_name .. '.txt'
    local result = {}

    local exit = os.execute('killall -0 openvpn &>/dev/null')
    if exit == 0 then
        result.status = "running"
        local f = io.open(fn, 'r')

        if f ~= nil then
            result['stats'] = {}
            for line in f:lines() do
                if line ~= 'OpenVPN STATISTICS' and line ~= 'END' then
                    key, val = line:match('([^,]*),(.*)')
                    result['stats'][key] = val
                end
            end
        end
    else
        result.status = "stopped"
    end

    return result
end

function openvpn.config(env, data)
    if env.REQUEST_METHOD == "GET" then
        return openvpn.get_config()
    elseif env.REQUEST_METHOD == "POST" and env.CONTENT_TYPE == 'application/json' then
        return openvpn.set_config(data)
    else
        return {error="Bad Request"}
    end
end

register_path("^/v1/openvpn/?$", openvpn.status)
register_path("^/v1/openvpn/status/?$", openvpn.status)
register_path("^/v1/openvpn/config/?$", openvpn.config)

return openvpn

