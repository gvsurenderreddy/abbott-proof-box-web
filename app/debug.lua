local debug = {}

function debug.data(env, data)
    env.data = data
    return env
end

register_path("^/v1/debug/?$", debug.data)

return debug

