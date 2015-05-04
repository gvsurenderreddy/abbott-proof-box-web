function debug_data(env, data)
    env.data = data
    return env
end

register_path("^/v1/debug/?$", debug_data)

