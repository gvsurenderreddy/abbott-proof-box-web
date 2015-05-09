require "uci"

local lan = {}

lan.network_config_options = {
    "ipaddr", "netmask"
}

lan.dhcp_config_options = {
    "start", "limit", "leasetime"
}

function lan.status(env, data)
    return {status="online"}
end

function lan.config(env, data)
    if env.REQUEST_METHOD == "GET" then
        return lan.get_config()
    elseif env.REQUEST_METHOD == "PUT" and env.CONTENT_TYPE == 'application/json' then
        local config = lan.set_config(data)
        lan.restart()
        return config
    end
end

function lan.set_config(config)
    local u = uci.cursor()
    for i, c in ipairs(lan.network_config_options) do
        if config[c] then
            u:set("network", "lan", c, config[c])
        end
    end
    for i, c in ipairs(lan.dhcp_config_options) do
        if config[c] then
            u:set("dhcp", "lan", c, config[c])
        end
    end
    u:commit("openvpn")

    return lan.get_config()
end

function lan.get_config()
    local config = {}
    local u = uci.cursor()
    for i, c in ipairs(lan.network_config_options) do
        config[c] = u:get("network", "lan", c)
    end
    for i, c in ipairs(lan.dhcp_config_options) do
        config[c] = u:get("dhcp", "lan", c)
    end

    return config
end

function lan.restart()
    os.execute('/etc/init.d/network restart')
    os.execute('/etc/init.d/dnsmasq restart')
end

register_path("^/v1/lan/?$", lan.status)
register_path("^/v1/lan/status/?$", lan.status)
register_path("^/v1/lan/config/?$", lan.config)

return lan

