-- Search in /www for our packages
package.path = uhttpd.docroot .. "/?.lua;" .. package.path

json = require "lib.json"

-- Stores the routes for the app
routes = {}

-- Register a path in the application
function register_path(path, handler)
    table.insert(routes, {path=path, handler=handler})
end

-- Entry point from uhttpd
function handle_request(env)
    -- Read the data
    datalen, data = uhttpd.recv(2048)

	-- Parse the incoming data
	if env.CONTENT_TYPE == 'application/json' then
		data = json.decode(data)
    end

    -- Try to find a matching route
    for i, r in ipairs(routes) do
        if string.find(env.PATH_INFO, r.path) then
            uhttpd.send("Status: 200 OK\r\n")
            uhttpd.send("Content-Type: application/json\r\n\r\n")
            response = r.handler(env, data)
            uhttpd.send(json.encode(response))
            return nil
        end
    end

    -- Not found in routes table
    uhttpd.send("Status: 404 Not Found\r\n")
    uhttpd.send("Content-Type: application/json\r\n\r\n")
    uhttpd.send('{ "error":"Not Found" }')
end

-- Import various parts of the application
require "app.debug"
require "app.openvpn"

