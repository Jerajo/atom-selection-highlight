MarkerView = require './marker-view'
{EditorView, View} = require 'atom'

module.exports =
class HighlightedAreaView extends View
  @content: ->
    @div class: 'highlight-selected'

  initialize: (editorView) ->
    @views = []
    @editorView = editorView

  attach: =>
    @editorView.underlayer.append(this)
    @editorView.on "dblclick", @handleDblClick
    @editorView.on "click", @removeMarkers

  getEditorView: ->
    activeView = atom.workspaceView.getActiveView()
    if activeView instanceof EditorView then activeView else null

  getActiveEditor: ->
    atom.workspace.getActiveEditor()

  handleDblClick: =>
    text = @getActiveEditor()?.getSelectedText()
    return if text.length == 0
    editor = @getActiveEditor()

    range =  [[0, 0], editor.getEofBufferPosition()]

    @results = []
    editor.scanInBufferRange new RegExp(text, 'g'), range,
      (result) =>
        if prefix = result.match[1]
          result.range = result.range.translate([0, prefix.length], [0, 0])
        @results.push result

    for result in @results
      view = new MarkerView(result.range, this, @getEditorView())
      @views.push view

    for view in @views
      @append(view.element)

  removeMarkers: =>
    return unless @views?
    return if @views.length == 0
    for view in @views
      view.element.remove()
    @views = []