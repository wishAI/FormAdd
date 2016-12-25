toolInfo = []
documentList = []

currentMenu = null
currentDocumentId = 0

# the global value about selections
previousSelectionEle = null
previousSelectionEleStart = null
previousEndEleOfSelectionSection = null
caretAfterBoldFlag = false
caretAfterBoldNum = 0

isWebKit = navigator.userAgent.toUpperCase().indexOf("APPLEWEBKIT") >= 0 && navigator.userAgent.toUpperCase().indexOf("EDGE") < 0

class DocumentInfo
  preview: ""

class TextDocumentInfo extends DocumentInfo
  text: ""

class DocumentEditInfo
  caretPos: 0

class SelectionSection
  startSpan: 0
  endSpan: 0
  startCaretPos: null
  endCaretPos: null

$("document").ready ->
# set up the tool info
  toolInfo["align"] = "left"
  refreshAllIcons()

  # event for better selection of text editor

  # customize the selection event
  ###  setInterval(->
      console.log(getSelectionSection())
      console.log(getSelectionSection().startSpan.tagName + "   " + getSelectionSection().endSpan.tagName)
    , 500)###
  if (window.PointerEvent)
    alert(1)

  setInterval(->
    sel = window.getSelection()
    currentSelectionEle = null
    currentSelectionEleStart = null
    if(sel && sel.rangeCount > 0)
      currentSelectionEle = window.getSelection().getRangeAt(0).startContainer.parentNode
    if(sel && sel.rangeCount > 0)
      currentSelectionEleStart = window.getSelection().getRangeAt(0).startOffset

    # the selection event
    if(currentSelectionEle != previousSelectionEle || currentSelectionEleStart != previousSelectionEleStart)
      event = $.Event("selection")
      event.selectionStartIndex = currentSelectionEleStart
      $(currentSelectionEle).trigger(event)
    # the unselection event
    if(currentSelectionEle != previousSelectionEle)
      $(previousSelectionEle).trigger("unselection")

    previousSelectionEle = currentSelectionEle
    previousSelectionEleStart = currentSelectionEleStart
  , 20)

  $("#textContent").on "paste", (evt)->
    evt.preventDefault()
    text = ""
    if(evt.clipboardData)
      content = (evt.originalEvent || evt).clipboardData.getData("text/plain")
    else if(window.clipboardData)
      content = window.clipboardData.getData("Text")
    else if(evt.originalEvent.clipboardData)
      content = $("<div></div>").text(evt.originalEvent.clipboardData.getData("text"))
    document.execCommand("insertText", false, $(content).html())

  $("#textContent").on "DOMNodeInserted", (evt)->
    target = evt.target
    if(target.innerHTML == "")
      $(target).removeClass("contentTextBold")
    $(".contentText b").remove()
    $(".contentText strong").remove()
    if(!this.firstChild.tagName)
      outText = $(this.firstChild).text()
      $(this.firstChild).remove()
      if($(".contentText").length > 0)
        $($(".contentText")[0]).text(outText)
      else
        $("#textContent").append(createContentTextEle(outText, false))
      # set the caret to the end of the text
      range = document.createRange()
      sel = window.getSelection()
      range.setStart($(".contentText")[0], 1)
      range.collapse(true)
      sel.removeAllRanges()
      sel.addRange(range)

  $(document).on "selection", ".contentTextBold", (evt)->
# set the caret to next element if start index equals to length
    if($(this).text().length == evt.selectionStartIndex && window.getSelection().toString().length == 0)
      if(isWebKit)
        caretAfterBoldFlag = true
        caretAfterBoldNum = $(this).text().length
      else
        nextEle = null
        if($(this).next().length)
          nextEle = $(this).next()[0]
        else
          nextEle = document.createElement("span")
          $(nextEle).addClass("contentText")
          $(nextEle).insertAfter($(this))
        nextEle.focus()
        range = document.createRange()
        selection = window.getSelection()
        if(nextEle.innerHTML == "")
          range.setStart(nextEle, 0)
        else
          range.setStart(nextEle.firstChild, 0)
        range.collapse(true)
        selection.removeAllRanges()
        selection.addRange(range)
    else if(isWebKit)
      caretAfterBoldFlag = false

  $(document).on "unselection", ".contentTextBold", ->
    if(isWebKit)
      caretAfterBoldFlag = false

  $(document).on "DOMSubtreeModified", ".contentTextBold", (evt)->
    if(isWebKit)
      evt.stopPropagation()
      if(caretAfterBoldFlag)
        oldText = $(this).text().substring(0, caretAfterBoldNum)
        newText = $(this).text().substring(caretAfterBoldNum, $(this).text().length)
        nextEle = null
        if($(this).next().length)
          nextEle = $(this).next()[0]
        else
          nextEle = document.createElement("span")
          $(nextEle).addClass("contentText")
          $(nextEle).insertAfter($(this))
        $(nextEle).text(newText + $(nextEle).text())
        # set the caret to next element
        nextEle.focus()
        range = document.createRange()
        selection = window.getSelection()
        range.setStart(nextEle.firstChild, $(this).text().length - caretAfterBoldNum)
        range.collapse(true)
        selection.removeAllRanges()
        selection.addRange(range)
        # create new element instead of adding text to prevent loop trigger
        # $(this).text(oldText)
        newEle = document.createElement("span")
        newEle.innerHTML = oldText
        $(newEle).addClass("contentText")
        $(newEle).addClass("contentTextBold")
        $(newEle).insertAfter($(this))
        $(this).remove()

  $(document).on "DOMSubtreeModified", "#textContent div", ->
    if(this.childNodes.length == 0)
      $(this).remove()

  # setup the tool bar

  $("#btnFile").addClass("btnToolTabOnSelect")
  setToolContainer("file")
  setDocumentContent("text", null)
  hideToolMenus()


  # event for the tool bar

  $(".btnToolTab").on "click", ->
    $(".btnToolTab").removeClass("btnToolTabOnSelect")
    $(this).addClass("btnToolTabOnSelect")
    switch this.id
      when "btnFile" then setToolContainer("file")
      when "btnStart" then setToolContainer("start")
      when "btnInsert" then setToolContainer("insert")

  $(".btnToolBig").on "click", ->
    hideToolMenus()
    switch this.id
      when "btnToolAlign"
        showToolMenu("align", "#toolMenuAlign")
      when "btnToolPicture"
        $("#btnToolPictureHolder").click()

  $("#btnToolStrong").on "click", ->
    setBoldText()

  $(".btnMenuAlign").on "click", (evt)->
    evt.stopPropagation()
    switch this.id
      when "btnMenuAlignCenter" then toolInfo["align"] = "center"
      when "btnMenuAlignLeft" then toolInfo["align"] = "left"
      when "btnMenuAlignRight" then toolInfo["align"] = "right"
    refreshToolIcon("align")
    hideToolMenus()
    currentMenu = null

  $(".toolFileHolder").on "click", (evt)->
    evt.stopPropagation()

  $(".toolFileHolder").change ->
    alert(1)
# show the file in content first
# then upload to the background


# all the global function goes here
# function of selection


getSelectionSection = ->
# get the caret pos of all the text
  sel = window.getSelection()
  this.allCaretEndPos = $("#textContent").caret("pos")
  this.allCaretStartPos = allCaretEndPos - window.getSelection().toString().length
  # get the start and end element and calculate the start and end pos of caret inside the ele
  this.startSpan = null
  this.endSpan = null
  this.startCaretPos = 0
  this.endCaretPos = 0
  this.charCount = 0
  $(".contentText").each ->
    textLength = $(this).text().length
    self.charCount += textLength
    if(startSpan == null && self.charCount >= self.allCaretStartPos)
      self.startCaretPos = textLength - (self.charCount - self.allCaretStartPos)
      self.startSpan = this
    if(self.charCount >= self.allCaretEndPos)
      self.endCaretPos = textLength - (self.charCount - self.allCaretEndPos)
      self.endSpan = this
      return false
  # build the new selection object and return it
  selectionSection = new SelectionSection()
  selectionSection.startSpan = this.startSpan
  selectionSection.endSpan = this.endSpan
  selectionSection.startCaretPos = this.startCaretPos
  selectionSection.endCaretPos = this.endCaretPos
  selectionSection


# function of tool bars

setToolContainer = (type)->
  $(".toolContainer").hide()
  switch type
    when "file"
      $("#toolListFile").show()
    when "start"
      $("#toolListStart").show()
    when "insert"
      $("#toolListInsert").show()

setDocumentContent = (type, documentId)->
  $(".documentContentContainer").hide()
  switch type
    when "title"
      $("#titleContent").show()
    when "text"
      $("#textContent").show()
    when "picture"
      $("#pictureContent").show()

showToolMenu = (type, menuId)->
  if(currentMenu == type)
    currentMenu = null
  else
    currentMenu = type
    $(menuId).show()

hideToolMenus = ->
  $(".toolMenu").hide()

createDocument = (type)->
# create a tab first

refreshToolIcon = (type)->
  switch type
    when "align"
      $(".toolAlignIcon").hide()
      switch toolInfo["align"]
        when "center"
          $("#toolAlignIconCenter").show()
        when "left"
          $("#toolAlignIconLeft").show()
        when "right"
          $("#toolAlignIconRight").show()

refreshAllIcons = ->
  refreshToolIcon("align")

setBoldText = ->
# get the selectionSection object first
  selectionSection = getSelectionSection()
  if(selectionSection.startSpan == selectionSection.endSpan)
    # single span
    spanToBold = selectionSection.startSpan
    textBefore = $(spanToBold).text().substring(0, selectionSection.startCaretPos)
    textAfter = $(spanToBold).text().substring(selectionSection.endCaretPos, $(spanToBold).text().length)
    textToBold = $(spanToBold).text().substring(selectionSection.startCaretPos, selectionSection.endCaretPos)
    if(!$(spanToBold).hasClass("contentTextBold"))
      # bold the text
      $(spanToBold).text(textToBold)
      $(spanToBold).addClass("contentTextBold")
      if(textBefore.length > 0)
        $(createContentTextEle(textBefore, false)).insertBefore($(spanToBold))
      if(textAfter.length > 0)
        $(createContentTextEle(textAfter, false)).insertAfter($(spanToBold))
    else
      # unbold the text
      $(spanToBold).text(textToBold)
      $(spanToBold).removeClass("contentTextBold")
      if(textBefore.length > 0)
        $(createContentTextEle(textBefore, true)).insertBefore($(spanToBold))
      if(textAfter.length > 0)
        $(createContentTextEle(textAfter, true)).insertAfter($(spanToBold))
  else
    # determine whether to bold or unbold
    boldFlag = true
    # bold the start and end ele first, then process all the middle part


createContentTextEle = (text, isBold)->
  ele = document.createElement("span")
  $(ele).text(text)
  $(ele).addClass("contentText")
  if(isBold)
    $(ele).addClass("contentTextBold")
  ele

