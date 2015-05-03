routes = {
    {"^/v1/test", "Testing..."},
}

function handle_request(env)
  uhttpd.send("Status: 200 OK\r\n")
  uhttpd.send("Content-Type: text/plain\r\n\r\n")
  uhttpd.send("Hello world.\n")
  for k, v in pairs( env ) do
    uhttpd.send(k)
    uhttpd.send("=")
    if type(v) == "string" then
      uhttpd.send(v)
      uhttpd.send("\n")
    else
      uhttpd.send("<object>\n")
    end
  end
  uhttpd.send("\n\n")
  uhttpd.send(env.PATH_INFO)
  uhttpd.send("\n\n")
end
