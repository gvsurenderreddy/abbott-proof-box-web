-- This endpoint processed the JSON it receives and echoes it back to the client

-- Headers
require "lib.stdheaders"
mg.write("Content-Type: text/plain\r\n")
mg.write("\r\n")

-- Modules
local json = require "json"
local postdata = require "lib.postdata"

-- Output data
mg.write(json.encode(postdata))
mg.write("\n")


