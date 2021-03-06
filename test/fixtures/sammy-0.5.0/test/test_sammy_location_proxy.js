(function($) {
  with(QUnit) {
    
    context('Sammy', 'HashLocationProxy', {
      before: function() {
        this.app = new Sammy.Application;
        this.proxy = new Sammy.HashLocationProxy(this.app);
        this.has_native = (typeof window.onhashchange != 'undefined');
      }
    })
    .should('store a pointer to the app', function() {
      equal(this.proxy.app, this.app)
    })
    .should('set is_native true if onhashchange exists in window', function() {
      if (this.has_native) {
        var proxy = new Sammy.HashLocationProxy(this.app)
        ok(proxy.is_native)
      } else {
        ok(true, 'No native hash change support.')
      }
    })
    .should('set is_native to false if onhashchange does not exist in window', function() {
      if (!this.has_native) {
        var proxy = new Sammy.HashLocationProxy(this.app)
        ok(!proxy.is_native)
      } else {
        ok(true, 'Native hash change support.')
      }
    })
    .should('create poller on hash change', function() {
      if (!this.has_native) {
        ok(Sammy.HashLocationProxy._interval);
        isType(Sammy.HashLocationProxy._interval, 'Number');
      } else {
        ok(true, 'Native hash change support.')
      }
    })
    .should('only create a single poller', function() {
      if (!this.has_native) {
        var interval = Sammy.HashLocationProxy._interval;
        var proxy = new Sammy.HashLocationProxy(this.app)
        equal(Sammy.HashLocationProxy._interval, interval);
      } else {
        ok(true, 'Native hash change support.')
      }
    });

    
    context('Sammy', 'DataLocationProxy', {
      before: function() {
        this.app = new Sammy.Application(function() {
          this.location_proxy = new Sammy.DataLocationProxy(this);
        });
      }
    })
    .should('store a pointer to the app', function() {
      equal(this.app.location_proxy.app, this.app);
    })
    .should('be able to configure data name', function() {
      var proxy = new Sammy.DataLocationProxy(this.app, 'othername');
      proxy.setLocation('newlocation');
      equal($('body').data('othername'), 'newlocation');
    })
    .should('trigger app event when data changes', function() {
      $('body').data(this.app.location_proxy.data_name, '');
      var triggered = false, app = this.app;
      app.bind('location-changed', function() {
        triggered = true;
      });
      ok(!triggered);
      app.run('#/');
      $('body').data(this.app.location_proxy.data_name, '#/newhash');
      soon(function() {
        ok(triggered);
        equal(this.app.getLocation(), '#/newhash');
        app.unload();
      }, this, 2, 3);
    })
    .should('return the current location from data', function() {
      $('body').data(this.app.location_proxy.data_name, '#/zuh')
      equal(this.app.location_proxy.getLocation(), '#/zuh');
    })
    .should('set the current location in data', function() {
      $('body').data(this.app.location_proxy.data_name, '#/zuh')
      equal(this.app.location_proxy.getLocation(), '#/zuh');
      this.app.location_proxy.setLocation('#/boosh');
      equal('#/boosh', this.app.location_proxy.getLocation());
    });

  }
})(jQuery);