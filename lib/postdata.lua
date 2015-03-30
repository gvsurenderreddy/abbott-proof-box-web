local json = require "json"

local stringtab = {}

repeat
    local add_data = mg.read()
    stringtab[#stringtab+1] = add_data
until (add_data == nil);
local post_string = table.concat(stringtab)

return json.decode(post_string)

