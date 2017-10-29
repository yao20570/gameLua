
FriendView = class("FriendView", BasicView)

function FriendView:ctor(parent)
    FriendView.super.ctor(self, parent)
end

function FriendView:finalize()
    FriendView.super.finalize(self)
end

function FriendView:registerPanels()
    FriendView.super.registerPanels(self)

    require("modules.friend.panel.FriendPanel")
    self:registerPanel(FriendPanel.NAME, FriendPanel)
    
    require("modules.friend.panel.FriendListPanel")
    self:registerPanel(FriendListPanel.NAME, FriendListPanel)
    
    require("modules.friend.panel.FriendBlessPanel")
    self:registerPanel(FriendBlessPanel.NAME, FriendBlessPanel)
    
    require("modules.friend.panel.CollectionPanel")
    self:registerPanel(CollectionPanel.NAME, CollectionPanel)

    require("modules.friend.panel.CollectionDetailPanel")
    self:registerPanel(CollectionDetailPanel.NAME, CollectionDetailPanel)
end

function FriendView:initView()
    local panel = self:getPanel(FriendPanel.NAME)
    panel:show()
end

function FriendView:onFriendInfoUpdate(data)
    local panel = self:getPanel(FriendListPanel.NAME)
    panel:onFriendInfoUpdate(data)
end

function FriendView:onFriendSearch(friendInfo)
    local panel = self:getPanel(FriendListPanel.NAME)
    panel:onFriendSearch(friendInfo)
end

function FriendView:onBlessUpdate(data)
    local panel = self:getPanel(FriendBlessPanel.NAME)
    panel:onBlessUpdate(data)
end

function FriendView:onWatchPlayerInfo(data)
    local panel = self:getPanel(FriendPanel.NAME)
    panel:onWatchPlayerInfo(data)
end

function FriendView:onShowView(extraMsg, isInit)
    FriendView.super.onShowView(self, extraMsg, isInit)
    if extraMsg ~= nil and extraMsg.panel ~= nil then
        local panel = self:getPanel(FriendPanel.NAME)
        panel:changeTabSelectByName(extraMsg.panel)
    end
end

function FriendView:onCloseView()
    FriendView.super.onCloseView(self)
    local panel = self:getPanel(FriendPanel.NAME)
    panel:resetTab()
end

function FriendView:onUpdateCount()
    local panel = self:getPanel(FriendPanel.NAME)
    panel:onUpdateCount()
end


