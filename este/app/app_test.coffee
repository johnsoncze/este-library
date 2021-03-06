suite 'este.App', ->

  App = este.App

  router = null
  screen = null
  app = null
  window = null
  Presenter0 = null
  Presenter1 = null
  Presenter2 = null
  presenter0 = null
  presenter1 = null
  presenter2 = null

  setup ->
    router = mockRouter()
    screen = mockScreen()
    app = new App router, screen
    window = alert: ->
    app.window = window
    arrangePresenters()
    arrangeRoutes()

  mockRouter = ->
    routes: []
    add: (path, callback) ->
      @routes.push path: path, callback: callback
    start: ->
      @routes[0].callback someParams: true
    pathNavigate: ->
    isHtml5historyEnabled: -> true
    dispose: ->

  mockScreen = ->
    dispose: ->

  arrangePresenters = ->
    Presenter0 = ->
    Presenter1 = ->
    Presenter2 = ->
    presenter0 = mockPresenter Presenter0, true
    presenter1 = mockPresenter Presenter1
    presenter2 = mockPresenter Presenter2

  mockPresenter = (presenterClass, sync) ->
    presenterClass::load = (params) ->
      result = new goog.result.SimpleResult
      if sync
        result.setValue params
      else
        setTimeout ->
          result.setValue params
        , 8
      result
    presenterClass::beforeShow = ->
    presenterClass::beforeHide = ->
    presenterClass::dispose = ->
    new presenterClass

  arrangeRoutes = ->
    app.addRoutes
      '/': presenter0
      '/foo': presenter1
      '/bla/:id': presenter2

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf app, App

  suite 'start', ->
    test 'should throw error if no route is defined', (done) ->
      app = new App router
      try
        app.start()
      catch e
        assert.equal e.message,
          'Assertion failed: At least one route has to be defined.'
        done()

    suite 'with urlEnabled == false', ->
      test 'should call presenter0.load', (done) ->
        app.urlEnabled = false
        presenter0.load = ->
          done()
          goog.result.successfulResult null
        presenter1.load = -> throw Error 'error'
        presenter2.load = -> throw Error 'error'
        app.start()

    suite 'with default urlEnabled', ->
      test 'should start router with navigateImmediately disabled', (done) ->
        router.start = ->
          assert.isFalse router.navigateImmediately
          done()
        app.start()

      test 'should call presenter0.load', (done) ->
        presenter0.load = ->
          done()
          goog.result.successfulResult null
        presenter1.load = -> throw Error 'error'
        presenter2.load = -> throw Error 'error'
        app.start()

  suite 'router', ->
    suite 'start', ->
      test 'should dispatch load event then call load', (done) ->
        loadDispatched = false
        goog.events.listen app, 'load', (e) ->
          jsonA = JSON.stringify e.request
          jsonB = JSON.stringify
            presenter: presenter0
            params: someParams: true
            isNavigation: false
          assert.equal jsonA, jsonB
          loadDispatched = true
        presenter0.load = ->
          assert.isTrue loadDispatched
          done()
          goog.result.successfulResult null
        app.start()

      test 'should dispatch show event then call beforeShow', (done) ->
        showDispatched = false
        goog.events.listen app, 'show', (e) ->
          jsonA = JSON.stringify e.request
          jsonB = JSON.stringify
            presenter: presenter0
            params: someParams: true
            isNavigation: false
          assert.equal jsonA, jsonB
          showDispatched = true
        presenter0.beforeShow = ->
          assert.isTrue showDispatched
          done()
          goog.result.successfulResult null
        app.start()

    suite 'routes', ->
      setup ->
        app.start()

      test 'routes[0] should beforeShow presenter0', (done) ->
        presenter0.beforeShow = -> done()
        router.routes[0].callback()

      test 'routes[1] should beforeShow presenter1', (done) ->
        presenter1.beforeShow = -> done()
        router.routes[1].callback()

      test 'routes[2] should beforeShow presenter2', (done) ->
        presenter2.beforeShow = -> done()
        router.routes[2].callback()

  suite 'show/hide logic', ->
    test 'should dispatch hide event then call presenter1 beforeHide', (done) ->
      app.start()
      hideDispatched = false
      goog.events.listen app, 'hide', (e) ->
        jsonA = JSON.stringify e.request
        jsonB = JSON.stringify
          presenter: presenter0
          params: someParams: true
          isNavigation: false
        assert.equal jsonA, jsonB
        hideDispatched = true
      presenter0.beforeHide = ->
        assert.isTrue hideDispatched
        done()
      router.routes[1].callback()

  suite 'prepare presenter', ->
    suite 'storage', ->
      test 'should be set on presenter, if not defined', ->
        app.storage = {}
        arrangeRoutes()
        assert.equal presenter0.storage, app.storage
        assert.equal presenter1.storage, app.storage
        assert.equal presenter2.storage, app.storage

      test 'should not be set on presenter, if defined', ->
        app.storage = {}
        storage0 = presenter0.storage = {}
        storage1 = presenter1.storage = {}
        storage2 = presenter2.storage = {}
        arrangeRoutes()
        assert.equal presenter0.storage, storage0
        assert.equal presenter1.storage, storage1
        assert.equal presenter2.storage, storage2

    suite 'screen', ->
      test 'should be set on presenter, if not defined', ->
        assert.equal presenter0.screen, app.screen
        assert.equal presenter1.screen, app.screen
        assert.equal presenter2.screen, app.screen

      test 'should not be set on presenter, if defined', ->
        screen0 = presenter0.screen = {}
        screen1 = presenter1.screen = {}
        screen2 = presenter2.screen = {}
        arrangeRoutes()
        assert.equal presenter0.screen, screen0
        assert.equal presenter1.screen, screen1
        assert.equal presenter2.screen, screen2

    suite 'createUrl', ->
      test 'should be set on presenter, if not defined', ->
        calls = ''
        app.createUrl = (presenterClass, params) ->
          calls += presenterClass
          calls += params
        presenter0.createUrl = null
        presenter1.createUrl = null
        presenter2.createUrl = null
        arrangeRoutes()
        presenter0.createUrl 0, 0
        presenter1.createUrl 1, 1
        presenter2.createUrl 2, 2
        assert.equal calls, '001122'

      test 'should not be set on presenter, if defined', ->
        app.createUrl = ->
        createUrl0 = presenter0.createUrl = ->
        createUrl1 = presenter1.createUrl = ->
        createUrl2 = presenter2.createUrl = ->
        arrangeRoutes()
        assert.equal presenter0.createUrl, createUrl0
        assert.equal presenter1.createUrl, createUrl1
        assert.equal presenter2.createUrl, createUrl2

    suite 'redirect', ->
      test 'should be set on presenter, if not defined', ->
        calls = ''
        app.redirect = (presenterClass, params) ->
          calls += presenterClass
          calls += params
        presenter0.redirect = null
        presenter1.redirect = null
        presenter2.redirect = null
        arrangeRoutes()
        presenter0.redirect 0, 0
        presenter1.redirect 1, 1
        presenter2.redirect 2, 2
        assert.equal calls, '001122'

      test 'should not be set on presenter, if defined', ->
        app.redirect = ->
        redirect0 = presenter0.redirect = ->
        redirect1 = presenter1.redirect = ->
        redirect2 = presenter2.redirect = ->
        arrangeRoutes()
        assert.equal presenter0.redirect, redirect0
        assert.equal presenter1.redirect, redirect1
        assert.equal presenter2.redirect, redirect2

  suite 'router.pathNavigate', ->
    test 'should not be called if dispatched by app start', ->
      called = false
      router.pathNavigate = ->
        called = true
      app.start()
      assert.isFalse called

    test 'should be called if route matched and isNavigation == false', ->
      called = false
      router.pathNavigate = ->
        called = true
      app.start()
      assert.isFalse called
      router.routes[0].callback {}, false
      assert.isTrue called

    test 'should not be called if route matched and isNavigation == true', ->
      called = false
      router.pathNavigate = ->
        called = true
      app.start()
      assert.isFalse called
      router.routes[0].callback {}, true
      assert.isFalse called

  suite 'createUrl', ->
    suite 'pushState enabled', ->
      test 'should create URL from presenter and params', ->
        app.start()
        url = app.createUrl Presenter2, 'id': 123
        assert.equal url, '/bla/123'

    suite 'pushState disabled', ->
      test 'should create URL from presenter and params', ->
        router.isHtml5historyEnabled = -> false
        app.start()
        url = app.createUrl Presenter2, 'id': 123
        assert.equal url, '#/bla/123'

  suite 'redirect', ->
    test 'should call presenter with passed params', (done) ->
      app.start()
      params = 'id': 123
      presenter2.load = (p_params) ->
        assert.equal p_params, params
        done()
        goog.result.successfulResult null
      app.redirect Presenter2, params

  suite 'dispose', ->
    test 'should work', ->
      calls = 0
      app.start()
      app.router.dispose = -> calls++
      app.screen.dispose = -> calls++
      presenter0.dispose = -> calls++
      presenter1.dispose = -> calls++
      presenter2.dispose = -> calls++
      app.dispose()
      assert.equal calls, 5

  suite 'last click win', ->
    setup ->
      app.start()

    suite 'presenter1 loaded twice', ->
      test 'should be fired once', (done) ->
        presenter1.beforeShow = -> done()
        router.routes[1].callback()
        setTimeout ->
          router.routes[1].callback()
        , 4

    suite 'presenter1, then presenter2', ->
      test 'should call only presenter2.beforeShow', (done) ->
        presenter1.beforeShow = -> throw Error 'error'
        presenter2.beforeShow = -> done()
        router.routes[1].callback()
        setTimeout ->
          router.routes[2].callback()
        , 4

  suite 'dont repeat same requests', ->
    suite 'presenter1, then presenter2, then presenter1', ->
      test 'should call only presenter1.beforeShow', (done) ->
        presenter1.beforeShow = -> throw Error 'error'
        presenter2.beforeShow = -> done()
        router.routes[1].callback()
        setTimeout ->
          router.routes[2].callback()
        , 2
        setTimeout ->
          router.routes[1].callback()
        , 4

    suite 'presenter1 trying to be loaded twice', ->
      test 'should dispatch only one load event', (done) ->
        app.start()
        loadCount = 0
        goog.events.listen app, 'load', (e) ->
          loadCount++
        goog.events.listen app, 'show', (e) ->
          assert.equal loadCount, 1
          done()
        app.load presenter1
        app.load presenter1

    suite 'presenter1 trying to be loaded twice with different params', ->
      test 'should dispatch two load events', (done) ->
        app.start()
        loadCount = 0
        goog.events.listen app, 'load', (e) ->
          loadCount++
        goog.events.listen app, 'show', (e) ->
          assert.equal loadCount, 2
          done()
        app.load presenter1
        app.load presenter1, a: 1

    suite 'browser BF', ->
      test 'should reset queue cache', (done) ->
        app.start()
        loadCount = 0
        goog.events.listen app, 'load', (e) ->
          loadCount++
        goog.events.listen app, 'show', (e) ->
          assert.equal loadCount, 2
          done()
        app.load presenter1, {}
        app.load presenter2, {}, true

    suite 'onLoad', ->
      test 'should clear queue', (done) ->
        app.start()
        showCount = 0
        goog.events.listen app, 'show', (e) ->
          showCount++
          if showCount == 2
            done()
            return
          app.load presenter1
        app.load presenter1

  suite 'timeout event', ->
    test 'should be dispatched if loading time > timeoutMs', (done) ->
      app.timeoutMs = 4
      app.start()
      goog.events.listen app, 'timeout', (e) ->
        done()
      app.load presenter1

    test 'should display alert', (done) ->
      app.timeoutMs = 4
      app.start()
      app.window.alert = (msg) ->
        assert.equal msg, App.MSG_REQUEST_TIMEOUT
        done()
      app.load presenter1

    test 'should not display alert', (done) ->
      app.showAlertOnError = false
      app.timeoutMs = 4
      app.start()
      alertCalled = false
      app.window.alert = (msg) ->
        alertCalled = true
      goog.events.listen app, 'timeout', (e) ->
        assert.isFalse alertCalled
        done()
      app.load presenter1

  suite 'error event', ->
    test 'should be dispatched if result has non cancelled error', (done) ->
      app.start()
      goog.events.listen app, 'error', (e) ->
        assert.equal e.error, 'foo'
        done()
      presenter0.load = ->
        result = new goog.result.SimpleResult
        setTimeout ->
          result.setError 'foo'
        , 2
        result
      app.load presenter0

    test 'should display alert', (done) ->
      app.start()
      app.window.alert = (msg) ->
        assert.equal msg, App.MSG_REQUEST_ERROR
        done()
      presenter0.load = ->
        result = new goog.result.SimpleResult
        setTimeout ->
          result.setError 'foo'
        , 2
        result
      app.load presenter0

    test 'should not display alert', (done) ->
      app.showAlertOnError = false
      app.start()
      alertCalled = false
      app.window.alert = ->
        alertCalled = true
      goog.events.listen app, 'error', (e) ->
        assert.isFalse alertCalled
        done()
      presenter0.load = ->
        result = new goog.result.SimpleResult
        setTimeout ->
          result.setError 'foo'
        , 2
        result
      app.load presenter0