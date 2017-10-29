
FriendPanel = class("FriendPanel", BasicPanel)
FriendPanel.NAME = "FriendPanel"

function FriendPanel:ctor(view, panelName)
    FriendPanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function FriendPanel:finalize()
    if self._watchPlayInfoPanel ~= nil then
        self._watchPlayInfoPanel:finalize()
    end
    self._watchPlayInfoPanel = nil
    FriendPanel.super.finalize(self)
end

function FriendPanel:initPanel()
	FriendPanel.super.initPanel(self)
	
	self:addTabControl()
end

function FriendPanel:addTabControl()
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(FriendListPanel.NAME, self:getTextWord(1101))
    tabControl:addTabPanel(FriendBlessPanel.NAME, self:getTextWord(1102))
    tabControl:addTabPanel(CollectionPanel.NAME, self:getTextWord(1103))
    
    tabControl:setTabSelectByName(FriendListPanel.NAME)

    self._tabControl = tabControl

    -- self:setTitle(true, self:getTextWord(1100))
    self:setTitle(true,"friend",true)
    self:setBgType(ModulePanelBgType.NONE)
end

function FriendPanel:onWatchPlayerInfo(data)
    if self._watchPlayInfoPanel == nil then
        self._watchPlayInfoPanel = UIWatchPlayerInfo.new(self:getParent(), self, false, false)
    end
    -- self._watchPlayInfoPanel:setMialShield(true)
    self._watchPlayInfoPanel:showAllInfo(data)
end

function FriendPanel:onClosePanelHandler()
    self:dispatchEvent(FriendEvent.HIDE_SELF_EVENT)
end

function FriendPanel:resetTab()
    
    if self._tabControl:getCurPanelName() == FriendListPanel.NAME then
        local panel = self:getPanel(FriendListPanel.NAME)
        panel:resetPanel()
    end
end

-- 更新小红点显示
function FriendPanel:onUpdateCount()
    local friendProxy = self:getProxy(GameProxys.Friend)
    local redCount = friendProxy:getBlessRedPointCount()
    if redCount > 0 then
        self._tabControl:setItemCount(2, true, redCount)
    else
        self._tabControl:setItemCount(2, false, 0)
    end 
end