###*
  @fileoverview este.demos.app.simple.products.detail.Presenter.
###
goog.provide 'este.demos.app.simple.products.detail.Presenter'

goog.require 'este.app.Presenter'
goog.require 'este.demos.app.simple.products.detail.View'

class este.demos.app.simple.products.detail.Presenter extends este.app.Presenter

  ###*
    @constructor
    @extends {este.app.Presenter}
  ###
  constructor: ->
    super()
    @view = new este.demos.app.simple.products.detail.View

  ###*
    @override
  ###
  load: (params = {}) ->
    window['console']['log'] 'loading product/' + params['id']
    delay = 2000
    if params['id'] == '0'
      delay = 6000
    # async simulation
    result = new goog.result.SimpleResult
    setTimeout ->
      result.setValue params
    , delay
    result

  ###*
    @override
  ###
  show: (result) ->
    @view.params = (`/** @type {Object} */`) result.getValue()
    return