-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CommentBoardPanel = class("CommentBoardPanel", BasicPanel)
CommentBoardPanel.NAME = "CommentBoardPanel"

function CommentBoardPanel:ctor(view, panelName)
    CommentBoardPanel.super.ctor(self, view, panelName, 330)

end

function CommentBoardPanel:finalize()
    CommentBoardPanel.super.finalize(self)
end

function CommentBoardPanel:initPanel()
	CommentBoardPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(470001), false)

    self._commentProxy = self:getProxy(GameProxys.Comment)
end

function CommentBoardPanel:registerEvents()
	CommentBoardPanel.super.registerEvents(self)
    self._boardPanel = self:getChildByName("boardPanel")
    self._contentTxt = self._boardPanel:getChildByName("memoTxt")
    self._holdTxt    = self._boardPanel:getChildByName("holdTxt")
    self._clickPanel = self._boardPanel:getChildByName("clickPanel")
    self._editPanel  = self._boardPanel:getChildByName("editPanel") -- 隐藏的
    self._cancleBtn  = self._boardPanel:getChildByName("cancleBtn")
    self._sendBtn    = self._boardPanel:getChildByName("sendBtn")
    self:addTouchEventListener(self._clickPanel, self.onClickPanelHandler)
    self:addTouchEventListener(self._cancleBtn, self.onCancleBtn)
    self:addTouchEventListener(self._sendBtn, self.sendMyComment)
end

function CommentBoardPanel:onShowHandler()
    

    -- 获取目标数据
    self._targetMsg = self:getPanel(CommentPanel.NAME):getTargetMsg()
    
    self._maxSize = ConfigDataManager:getConfigById(ConfigData.CommentSetConfig, 1).wordLimited

    self._contentTxt:setString("") -- 默认空字符串
    -- 加editBox
    if self._commentEditBox == nil then
        local function callback()
            self:setContentToLabel()
        end
        self._commentEditBox = ComponentUtils:addEditeBox(self._editPanel, self._maxSize, "", callback)
    else
        self._commentEditBox:setText("")
    end

    -- 设置占位符
    self._holdTxt:setVisible(true)
    local tipStr = string.format(self:getTextWord(470002), self._maxSize)
    self._holdTxt:setString(tipStr)

end

-- 发送评论
function CommentBoardPanel:sendMyComment()
    local data = {}
    data.typeId  = self._targetMsg.typeId
    data.childId = self._targetMsg.childId
    data.content = StringUtils:trim(self._commentEditBox:getText())
    self._commentProxy:onTriggerNet420001Req(data)

    self:hide()
end

-- 
function CommentBoardPanel:setContentToLabel()
    if self._contentTxt then
        
        local text = self._commentEditBox:getText()
        -- 为空显示占位
        if string.len(text) == 0 then
            self._holdTxt:setVisible(true)
        else
            self._holdTxt:setVisible(false)
        end

        self._contentTxt:setString(text)
	end
end


function CommentBoardPanel:onClickPanelHandler(sender)
	self._commentEditBox:openKeyboard()
end

function CommentBoardPanel:onCancleBtn(sender)
    self:hide()
end