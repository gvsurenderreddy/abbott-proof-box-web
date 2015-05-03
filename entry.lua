-- Search in /www for out packages
package.path = uhttpd.docroot .. "/?.lua;" .. package.path

json = require "lib.json"

function debug_data(env)
    env.datalen, env.data = uhttpd.recv(2048)
    return env
end

routes = {
    {path="^/v1/debug", handler=debug_data},
}

function handle_request(env)
    -- Try to find a matching route
    for i, r in ipairs(routes) do
        if string.match(env.PATH_INFO, r.path) then
            uhttpd.send("Status: 200 OK\r\n")
            uhttpd.send("Content-Type: application/json\r\n\r\n")
            uhttpd.send(json.encode(r.handler(env)))
            return nil
        end
    end

    -- Not found in routes table
    uhttpd.send("Status: 404 Not Found\r\n")
    uhttpd.send("Content-Type: application/json\r\n\r\n")
    uhttpd.send('{ "error":"Not Found" }')
end
