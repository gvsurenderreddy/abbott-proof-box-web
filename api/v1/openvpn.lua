require "lib.stdheaders"
mg.write("Content-Type: application/json\r\n")
mg.write("\r\n")

local json = require "json"
local postdata = require "lib.postdata"

returndata = {}
if postdata.action == 'config' then
    returndata['saved'] = {}
    -- Write the config files
    if postdata.config then
        local config = io.open ('/tmp/openvpn.cfg', 'w')
        config:write(postdata.config)
        config:close()
        table.insert(returndata.saved, 'config')
    end
    if postdata.ca then
        local ca = io.open ('/tmp/ca.crt', 'w')
        ca:write(postdata.ca)
        ca:close()
        table.insert(returndata.saved, 'ca')
    end
    if postdata.username and postdata.password then
        local creds = io.open ('/tmp/vpn.creds', 'w')
        creds:write(postdata.username)
        creds:write("\n")
        creds:write(postdata.password)
        creds:close()
        table.insert(returndata.saved, 'username')
        table.insert(returndata.saved, 'password')
    end

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

