ChatPanel = class("ChatPanel", BasicPanel)
ChatPanel.NAME = "ChatPanel"

function ChatPanel:ctor(view, panelName)
    ChatPanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function ChatPanel:finalize()
    if self._uiWatch ~= nil then
        self._uiWatch:finalize()
        self._uiWatch = nil
    end
    ChatPanel.super.finalize(self)
end

function ChatPanel:doLayout( )
    local stopBtn = self:getChildByName("stopBg/stopBtn")
    NodeUtils:adaptiveTopY(stopBtn, 200)
end

function ChatPanel:initPanel()
    ChatPanel.super.initPanel(self)
    -- self:setBgType(ModulePanelBgType.BLACKFULL)

    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(WorldChatPanel.NAME, self:getTextWord(302))
    tabControl:addTabPanel(LegionChatPanel.NAME, self:getTextWord(3021))
    tabControl:addTabPanel(ChatPrivatePanel.NAME, self:getTextWord(250029))
    tabControl:setTabSelectByName(WorldChatPanel.NAME)
    self._tabControl = tabControl

    self:setTitle(true,"liaotian",true)

    local stopBtn = self:getChildByName("stopBg/stopBtn")
    stopBtn:addTouchRange(50,50)
    self:addTouchEventListener(stopBtn, self.showOtherPanel)
end

function ChatPanel:showOtherPanel(sender)
    local ShieldChatPanel = self:getPanel(ShieldChatPanel.NAME)
    ShieldChatPanel:show()
end

function ChatPanel:showPanel(panelName, data, otherParam)
    self._tabControl:changeTabSelectByName(panelName)
    local panel = self:getPanel(panelName)
    if otherParam == nil then
        panel:show(data)
    end
end

--更新小红点数量，1世界  2军团  3私聊
function ChatPanel:updateRedCount(type, num)
    self._tabControl:setItemCount(type, num > 0, num)
end

function ChatPanel:hideRedPoint(type)
    self._tabControl:setItemCount(type, false, 0)
end

function ChatPanel:onShowInfo(data)
    local parent = self:getParent()
    if self._uiWatch == nil then
        self._uiWatch = UIWatchPlayerInfo.new(parent,self,true)
    end
    self._uiWatch:setMialShield()
    self._uiWatch:showAllInfo(data)
end

function ChatPanel:registerEvents()
    ChatPanel.super.registerEvents(self)
end

function ChatPanel:hideWatchPanel()
    if self._uiWatch ~= nil then
        self._uiWatch:hide()
    end
end

function ChatPanel:onClosePanelHandler()
    local panel = self:getPanel(EmotionPanel.NAME)
    panel:hide()
    local panels = {LegionChatPanel.NAME, WorldChatPanel.NAME}
    for k,name in pairs(panels) do
        local panel = self:getPanel(name)
        if panel and panel:isVisible() then
            panel:hideMethod()
        end
    end
    self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
end