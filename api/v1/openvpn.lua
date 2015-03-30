require "lib.stdheaders"
mg.write("Content-Type: application/json\r\n")
mg.write("\r\n")

local json = require "json"
local postdata = require "lib.postdata"

returndata = {}
if postdata.action == 'config' then
    -- Write the config files
elseif postdata.action == 'start' then
    -- Start the OpenVPN service if not
elseif postdata.action == 'stop' then
    -- Stop the OpenVPN service if running
elseif postdata.action == 'status' then
    -- Return the status of the openvpn service
else
    returndata = {error="Invalid Action"}
end

mg.write(json.encode(returndata))
mg.write("\r\n")

