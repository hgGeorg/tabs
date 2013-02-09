$ = require 'jquery'
SortableList = require 'sortable-list'
Tab = require 'tabs/src/tab'

module.exports =
class Tabs extends SortableList
  @activate: (rootView) ->
    rootView.eachEditor (editor) =>
      @prependToEditorPane(rootView, editor) if editor.attached

  @prependToEditorPane: (rootView, editor) ->
    if pane = editor.pane()
      pane.prepend(new Tabs(editor))

  @content: ->
    @ul class: "tabs #{@viewClass()}"

  initialize: (@editor) ->
    super

    for editSession, index in @editor.editSessions
      @addTabForEditSession(editSession)

    @setActiveTab(@editor.getActiveEditSessionIndex())
    @editor.on 'editor:active-edit-session-changed', (e, editSession, index) => @setActiveTab(index)
    @editor.on 'editor:edit-session-added', (e, editSession) => @addTabForEditSession(editSession)
    @editor.on 'editor:edit-session-removed', (e, editSession, index) => @removeTabAtIndex(index)

    @on 'click', '.tab', (e) =>
      @editor.setActiveEditSessionIndex($(e.target).closest('.tab').index())
      @editor.focus()

    @on 'click', '.tab .close-icon', (e) =>
      index = $(e.target).closest('.tab').index()
      @editor.destroyEditSessionIndex(index)
      false

  addTabForEditSession: (editSession) ->
    @append(new Tab(editSession, @editor))

  setActiveTab: (index) ->
    @find(".tab.active").removeClass('active')
    @find(".tab:eq(#{index})").addClass('active')

  removeTabAtIndex: (index) ->
    @find(".tab:eq(#{index})").remove()

  onDrop: (event) =>
    super
    sessions = @editor.editSessions
    el = @sortableElement(event)
    previousIndex = event.originalEvent.dataTransfer.getData('index')
    currentIndex  = el.index() - 1

    sessions.splice(currentIndex, 0, sessions.splice(previousIndex, 1)[0])

    @setActiveTab(currentIndex)
    @editor.setActiveEditSessionIndex(currentIndex)
    @editor.focus()
