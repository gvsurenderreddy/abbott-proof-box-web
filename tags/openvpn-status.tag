<openvpn-status>
  <p>Status: { status }</p>
  <script>
    self.status = 'Unknown'

    load() {
      var request = new XMLHttpRequest, self = this

      request.open('GET', '/api/v1/openvpn/status', true)
      request.onload = function() {
        if (this.status >= 200 && this.status < 400) {
          var gotstatus = JSON.parse(request.responseText).status
          self.status = gotstatus.charAt(0).toUpperCase() + gotstatus.slice(1);
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
