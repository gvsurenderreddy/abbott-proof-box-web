require "lib.stdheaders"
mg.write("Content-Type: application/json\r\n")
mg.write("\r\n")

local json = require "json"
mg.write(json.encode({name="ping", value="pong"}))
