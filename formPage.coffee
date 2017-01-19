toolInfo = []
documentContents = []

selectMenu = null
selectDocumentIndex = 0

# the status variable for the image content
selectImageIndex = 0

# the global variables of libraries
moduleFactory = null
contentEditableManager = null
fileSrcManager = null

isWebKit = navigator.userAgent.toUpperCase().indexOf("APPLEWEBKIT") >= 0 && navigator.userAgent.toUpperCase().indexOf("EDGE") < 0

# %% nested classes goes here %%
class DocumentContent
  type: null
  preview: ""

class TitleContent extends DocumentContent
  type: "title"
  preview: "标题"
  articleType: ""
  header: ""
  coverFile: null

class ParagraphContent extends DocumentContent
  type: "paragraph"
  preview: "段落"
  htmlText: "<span class=\"contentText\"></span>"

  getPureText: ->

  getStrongSection: ->


class ImageContent extends DocumentContent
  type: "image"
  preview: "图片"
  imageBlocks: []
  
class ImageBlock
  inputId: null
# file maybe cached
  imageFile: null
  info: null

class CachedFile
  constructor: (@dataId, @srcKey)->


# %% global function goes here %%
# functions to setup
setup = ->
# setup the libraries
  contentEditableManager = new window.ContentEditableManager(isWebKit)
  contentEditableManager.setup()
  moduleFactory = new window.ModuleFactory()
  fileSrcManager = new window.FileSrcManager(0, moduleFactory)

  # set up the tool info
  toolInfo["align"] = "left"
  refreshAllToolIcons()
  #  set up the document tabs
  titleContent = new TitleContent()
  documentContents.push(titleContent)
  refreshDocumentTabs()

  # setup the tool bar
  $("#btnFile").addClass("btnToolTabOnSelect")
  setToolContainer("file")
  setDocumentContent(0)
  hideToolMenus()

setupEvent = ->

  # setup event for the tool bar
  $(".btnToolTab").on "click", ->
    $(".btnToolTab").removeClass("btnToolTabOnSelect")
    $(this).addClass("btnToolTabOnSelect")
    switch this.id
      when "btnFile" then setToolContainer("file")
      when "btnInsert" then setToolContainer("insert")
      when "btnParagraph" then setToolContainer("paragraph")
      when "btnImage" then setToolContainer("image")

  $(".btnToolBig").on "click", ->
    hideToolMenus()
    switch this.id
      when "btnToolAlign"
        showToolMenu("align", "#toolMenuAlign")
      when "btnToolStrong"
        setBoldText()
#     the btns add file src in input
      when "btnToolAddImage"
        fileSrcManager.addFile("image")
#     the btns insert document content tab
      when "btnToolImage"
        imageContent = new ImageContent()
        documentContents.push(imageContent)
        refreshDocumentTabs()
      when "btnToolParagraph"
        paragraphContent = new ParagraphContent()
        documentContents.push(paragraphContent)
        refreshDocumentTabs()
        
# events for select the document content
  $(".documentTab").on "click", ->
#   get the index of this tab first
    console.log($(this).index())


# the buttons for the all the tool menus
  $(".btnMenuAlign").on "click", (evt)->
    evt.stopPropagation()
    switch this.id
      when "btnMenuAlignCenter" then toolInfo["align"] = "center"
      when "btnMenuAlignLeft" then toolInfo["align"] = "left"
      when "btnMenuAlignRight" then toolInfo["align"] = "right"
    refreshToolIcon("align")
    hideToolMenus()
    selectMenu = null


# !! should enable multiple file input and put them to multiple single inputs !!
# refresh the src contents list when input change
  $(document).on "change", "#fileSrcHolders.fileSrcHolder", ->
#   remove the empty inputs first
    $("#fileSrcHolders.fileSrcHolder").each ->
      if(!(this).val())
        $(this).remove()
#   determine the input type
    switch $(this).attr("fileType")
      when "image"
#       add to the document contents first ( !! need to write a get select document content function !! )
        console.log(1)
#       then calculate and set the selectImageIndex

  $(".toolFileHolder").on "click", (evt)->
    evt.stopPropagation()

  $(".toolFileHolder").change ->
    alert(1)
# show the file in content first
# then upload to the background


# functions for the tool bar
# special tabs for tool bar
setToolContainerTab = (type)->
# hide all the switch tabs first
  $(".btnToolTabSwitch").hide()
# show the tab depend on type
  switch type
    when "paragraph"
      $("#btnParagraph").show()
    when "image"
      $("#btnImage").show()

setToolContainer = (type)->
  $(".toolContainer").hide()
  switch type
    when "file"
      $("#toolListFile").show()
    when "insert"
      $("#toolListInsert").show()
#   the special tool container show depends on select document type
    when "paragraph"
      $("#toolListParagraph").show()
    when "image"
      $("#toolListImage").show()

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

refreshAllToolIcons = ->
# refresh all the types of Tool icons
  refreshToolIcon("align")


# functions for the menu when click on a special tool
showToolMenu = (type, menuId)->
  if(selectMenu == type)
    selectMenu = null
  else
    selectMenu = type
    $(menuId).show()

hideToolMenus = ->
  $(".toolMenu").hide()


# functions for the document contents
setDocumentContent = (documentIndex)->
  $(".documentContentContainer").hide()
# get the document content by the index
  documentContent = documentContents[documentIndex]
  switch documentContent.type
    when "title"
      $("#titleContent").show()
#     the only title content, no need to replace contents
    when "paragraph"
#     replace with the current contents
      $("#textContent")[0].innerHTML = documentContent.htmlText
      $("#textContent").show()
    when "image"
      $("#imageContent").show()
#     replace with the current contents

  # set the tool tab to fit the document content type
  setToolContainerTab(type)

createDocument = (type)->
# create a tab first

getSelectDocument = ()->
  documentContents[selectDocumentIndex]

resetDocumentStatus = ->
  selectImageIndex = 0
  contentEditableManager.reset()

refreshDocumentTabs = ->
# remove all the tabs first
  $("#documentTabList").find(".documentTab").remove()
  # add all the tabs from documentContents
  for documentContent in documentContents
    module = null
    # get the module according to the type
    switch documentContent.type
      when "title" then module = moduleFactory.getModuleById("tmpDocumentTabTitle")
      when "paragraph" then module = moduleFactory.getModuleById("tmpDocumentTabParagraph")
      when "image" then module = moduleFactory.getModuleById("tmpDocumentTabImage")
    $(module).find(".documentTabPreview").text(documentContent.preview)
    # append to the ul ele
    $(module).appendTo($("#documentTabList"))


# functions for edit the inside different types of contents
setBoldText = ->
  contentEditableManager.setBoldText()

setImage = (index)->


# tool functions


# %% main function here %%
$("document").ready ->
  setup()
  setupEvent()













