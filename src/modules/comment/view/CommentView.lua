
CommentView = class("CommentView", BasicView)

function CommentView:ctor(parent)
    CommentView.super.ctor(self, parent)
end

function CommentView:finalize()
    CommentView.super.finalize(self)
end

function CommentView:registerPanels()
    CommentView.super.registerPanels(self)

    require("modules.comment.panel.CommentPanel")
    self:registerPanel(CommentPanel.NAME, CommentPanel)

    require("modules.comment.panel.CommentBoardPanel")
    self:registerPanel(CommentBoardPanel.NAME, CommentBoardPanel)
end

function CommentView:initView()

end

function CommentView:onShowView(msg, isInit, isAutoUpdate)
    GameActivityView.super.onShowView(self, msg, isInit, false)
    local panel = self:getPanel(CommentPanel.NAME)
    panel:show(msg)
end

function CommentView:hideModuleHandler()
    self:dispatchEvent(CommentEvent.HIDE_SELF_EVENT, {})
end