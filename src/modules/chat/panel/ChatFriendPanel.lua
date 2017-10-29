ChatFriendPanel = class("ChatFriendPanel", BasicPanel)
ChatFriendPanel.NAME = "ChatFriendPanel"

function ChatFriendPanel:ctor(view, panelName)
    ChatFriendPanel.super.ctor(self, view, panelName, 650)

    self:setUseNewPanelBg(true)
end

function ChatFriendPanel:finalize()
    ChatFriendPanel.super.finalize(self)
end

function ChatFriendPanel:initPanel()
	ChatFriendPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(1101))
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)
end

function ChatFriendPanel:renderItemPanel(item, data, index)
    -- local bgItem = item:getChildByName("Image_26")
    local clearBtn = item:getChildByName("clearBtn")
    local nameTxt = item:getChildByName("nameTxt")
    local actor = item:getChildByName("icon")
    clearBtn.data = data
    local txt = "Lv." .. data.level .. " " .. data.name
    nameTxt:setString(txt)
    self:addTouchEventListener(clearBtn, self.chooseBtnTouch)


    TextureManager:updateImageView(actor, "images/newGui1/none.png")

    local headInfo = { }
    headInfo.icon = data.iconId
    headInfo.pendant = data.pendantId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = false
    headInfo.playerId = rawget(data, "playerId")

    local head = actor.head
    if head == nil then
        head = UIHeadImg.new(actor, headInfo, self)
        actor.head = head
    else
        head:updateData(headInfo)
    end

end

function ChatFriendPanel:registerEvents()
    self._listView = self:getChildByName("Panel_16/ListView")
end
--开始就会掉用
function ChatFriendPanel:onShowHandler()
    local friendProxy = self:getProxy(GameProxys.Friend)
    local friendInfos = friendProxy:getFriendInfos()
    self:renderListView(self._listView, friendInfos, self, self.renderItemPanel)
end

function ChatFriendPanel:btnClickEvents(sender)
    self:hide()
end

function ChatFriendPanel:onClosePanelHandler()
    self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
end

function ChatFriendPanel:chooseBtnTouch(sender)
    local data = sender.data
    local panel = self:getPanel(ChatPrivatePanel.NAME)
    panel:show(data)
    self:hide()
end