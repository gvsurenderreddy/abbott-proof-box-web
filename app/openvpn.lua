local openvpn = {}

function openvpn.status(env, data)
    return nil
end

register_path("^/v1/openvpn/?$", openvpn.status)

return openvpn

