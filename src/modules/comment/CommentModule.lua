-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CommentModule = class("CommentModule", BasicModule)

function CommentModule:ctor()
    CommentModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function CommentModule:initRequire()
    require("modules.comment.event.CommentEvent")
    require("modules.comment.view.CommentView")
end

function CommentModule:finalize()
    CommentModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function CommentModule:initModule()
    CommentModule.super.initModule(self)
    self._view = CommentView.new(self.parent)

    self:addEventHandler()
end

function CommentModule:addEventHandler()
    self._view:addEventListener(CommentEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(CommentEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Comment, AppEvent.PROXY_COMMENT_ON_SHOW, self, self.updateCommentPanel)
    self:addProxyEventListener(GameProxys.Comment, AppEvent.PROXY_COMMENT_DID_COMMENT, self, self.updateCommentPanel)
    self:addProxyEventListener(GameProxys.Comment, AppEvent.PROXY_COMMENT_DID_LIKE, self, self.updateLikeNum)
end

function CommentModule:removeEventHander()
    self._view:removeEventListener(CommentEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(CommentEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Comment, AppEvent.PROXY_COMMENT_ON_SHOW, self, self.updateCommentPanel)
    self:removeProxyEventListener(GameProxys.Comment, AppEvent.PROXY_COMMENT_DID_COMMENT, self, self.updateCommentPanel)
    self:removeProxyEventListener(GameProxys.Comment, AppEvent.PROXY_COMMENT_DID_LIKE, self, self.updateLikeNum)
end

function CommentModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function CommentModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


function CommentModule:onOpenModule(extraMsg)
    CommentModule.super.onOpenModule(self, extraMsg)
    -- 发送最新的信息

end

--  回调刷新列表
function CommentModule:updateCommentPanel(data)
    local commentPanel = self:getPanel(CommentPanel.NAME)
    commentPanel:updateCommentPanel()
end

-- 点赞
function CommentModule:updateLikeNum()
    local commentPanel = self:getPanel(CommentPanel.NAME)
    commentPanel:updateLikeNum()
end