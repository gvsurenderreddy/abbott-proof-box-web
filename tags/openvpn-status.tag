<openvpn-status>
  <p>
    Status: { status }<br />
    Download: { down } Mb<br />
    Upload: { up } Mb<br />
  </p>
  <script>
    self.status = 'Unknown'

    load() {
      var request = new XMLHttpRequest, self = this

      request.open('GET', '/api/v1/openvpn/status', true)
      request.onload = function() {
        if (this.status >= 200 && this.status < 400) {
          var rjson = JSON.parse(request.responseText)
          self.status = rjson.status.charAt(0).toUpperCase() + rjson.status.slice(1);
          self.up = Math.round(rjson.stats['TCP/UDP write bytes'] / 1024 / 1024)
          self.down = Math.round(rjson.stats['TCP/UDP read bytes'] / 1024 / 1024)
          self.update()
        }
      }
      request.send()
    }

    this.load()
    this.on('mount', function() {
      setInterval(this.load, this.opts.interval)
    })

  </script>
</openvpn-status>
