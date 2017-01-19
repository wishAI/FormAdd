class window.ModuleFactory

  constructor: ->

  getModuleById: (id)->
    ele = $(document.getElementById(id)).clone()[0]
    $(ele).removeAttr("id")
    ele
