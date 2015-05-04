local openvpn = {}

function openvpn.status(env, data)
    local result = {}

    local exit = os.execute('killall -0 openvpn')
    if exit == 0 then
        result.status = "running"
    else
        result.status = "stopped"
    end

    return result
end

function openvpn.config(env, data)
    return nil
end

register_path("^/v1/openvpn/?$", openvpn.status)
register_path("^/v1/openvpn/status/?$", openvpn.status)
register_path("^/v1/openvpn/config/?$", openvpn.config)

return openvpn

