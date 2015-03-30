require "lib.stdheaders"
mg.write("Content-Type: text/plain\r\n")
mg.write("\r\n")

local json = require "json"
local file = io.open("/tmp/test.log", "a")
local postdata = require "lib.postdata"

file:write(json.encode(postdata))
file:write("\n")
file:close()

mg.write('Written!')


