class window.FileSrcManager

  constructor: (@inputIdCount, @moduleFactory)->

# move the src in input to img ele
  setFileSrcToImg: (inputId, img)->

# add an input ele to hold the file
# if user cancel upload the file, need to remove the input ?? can be done when refresh the resource ??
# ?? how to get the status in the main function ??
  addFile: (type)->
    input = @moduleFactory.getModuleById("tmpFileSrcHolder")
    $(input).attr("inputId", @inputIdCount)
    $(input).attr("fileType", type)
    @inputIdCount++
    $(input).appendTo($("#fileSrcHolders"))
    $(input).trigger("click")

