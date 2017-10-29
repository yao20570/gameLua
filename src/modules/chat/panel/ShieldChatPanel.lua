ShieldChatPanel = class("ShieldChatPanel", BasicPanel)
ShieldChatPanel.NAME = "ShieldChatPanel"

function ShieldChatPanel:ctor(view, panelName)
    ShieldChatPanel.super.ctor(self, view, panelName, 700)
    --self:registerEvents()

    self:setUseNewPanelBg(true)
end

function ShieldChatPanel:finalize()
    ShieldChatPanel.super.finalize(self)
end

function ShieldChatPanel:initPanel()
	ShieldChatPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(913))
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)
end
function ShieldChatPanel:onShieldChatInfoResp(data)  --显示屏蔽信息的数据
    -- self._listView = self:getChildByName("Panel_16/ListView")
    local List = data.infos
    -- self.shieldNumTxt:setString(#List.."/30")
    self.shieldNumTxt:setString(#List)
    self.shieldMaxNumTxt:setString("/30")
    NodeUtils:alignNodeL2R(self.shieldNumTxt,self.shieldMaxNumTxt)
    -- if #List > 0 then
    --      self.sheileOnePanel:setVisible(true)
    -- end
    self:renderListView(self._listView, List, self, self.renderItemPanel,nil,nil,GlobalConfig.listViewRowSpace)
end
function ShieldChatPanel:renderItemPanel(item,data,index)
    if item then
        item:setVisible(true)
    end
    -- local bgItem = item:getChildByName("Image_26")
    local clearBtn = item:getChildByName("clearBtn")
    local nameTxt = item:getChildByName("nameTxt")
    local actor = item:getChildByName("icon")
    --actor:setVisible(false)
    clearBtn.playerId = data.playerId
    nameTxt:setString(data.name)
    self:addTouchEventListener( clearBtn,self.btnClickEvents)

    local headInfo = {}
    headInfo.icon = data.iconId
    headInfo.pendant = data.iconId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = nil
    headInfo.isCreatPendant = false
    headInfo.playerId = rawget(data, "playerId")
    local head = actor.head
    if head == nil then
        head = UIHeadImg.new(actor,headInfo,self)
        actor.head = head
    else
        head:updateData(headInfo)
    end     
    --head:setHeadScale(0.8)
    --head:setHeadSquare(headInfo.icon)
end

function ShieldChatPanel:registerEvents()
    self.sheileOnePanel =  self:getChildByName("Panel_16/ListView/Panel_20")
    self._listView = self:getChildByName("Panel_16/ListView")
    self.shieldNumTxt = self:getChildByName("Panel_16/labCurNum")
    self.shieldMaxNumTxt = self:getChildByName("Panel_16/labMaxNum")

end
--开始就会掉用
function ShieldChatPanel:onShowHandler(chat)
    local num = 1
    self:dispatchEvent(ChatEvent.SEND_CHATSHIELD_INFO_REQ, num)   ---先请求频闭列表
end
function ShieldChatPanel:btnClickEvents(sender)
    if sender == self.closeBtn then --关闭本页面
        self:hide()
    else
        local chatProxy = self:getProxy(GameProxys.Chat)
        chatProxy:onTriggerNet140007Req({type = 1, playerId = sender.playerId})
    end
end
function ShieldChatPanel:onClosePanelHandler()
    self:dispatchEvent(ChatEvent.HIDE_SELF_EVENT)
end




