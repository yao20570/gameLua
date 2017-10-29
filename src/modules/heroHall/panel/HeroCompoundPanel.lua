HeroCompoundPanel = class("HeroCompoundPanel",BasicPanel)
HeroCompoundPanel.NAME = "HeroCompoundPanel"

HeroCompoundPanel.INSTEAD_HERO_PEICE_ID = 28 -- 升星魂的typeId
local btnComNonePath = "images/newGui1/BtnMiniGreed1.png"
local btnComDownPath = "images/newGui1/BtnMiniGreed2.png"
local btnGoNonePath = "images/newGui1/BtnMiniRed1.png"
local btnGoDownPath = "images/newGui1/BtnMiniRed2.png"

function HeroCompoundPanel:ctor(view, panelName)
    HeroCompoundPanel.super.ctor(self, view, panelName, 320)
    
    self:setUseNewPanelBg(true)
end

function HeroCompoundPanel:finalize()
    HeroCompoundPanel.super.finalize(self)
end

function HeroCompoundPanel:onShowHandler(data)
    self:updatePanel(data)
end
--界面更新
function HeroCompoundPanel:updatePanel(data)
    local mainPanel = self:getChildByName("mainPanel")
    local goodsPanel = mainPanel:getChildByName("Panel_goods")
    local contain = goodsPanel:getChildByName("icon")
    local num = goodsPanel:getChildByName("num")
    local desc =goodsPanel:getChildByName("desc")
    local btn = mainPanel:getChildByName("btn")

    num:setString(data.owner)
    desc:setString(data.desc)

    if data.owner < data.num then
        btn:loadTextures(btnComNonePath,btnComDownPath, "", 1)
        btn:setTitleText(self:getTextWord(290014))
    else
        btn:loadTextures(btnGoNonePath,btnGoDownPath, "", 1)
        btn:setTitleText(self:getTextWord(290013))
    end
    btn.data = data
    self:addTouchEventListener(btn,self.onBtnClicked)
    -- 如果是升星魂不显示按钮
    if data.ID == HeroCompoundPanel.INSTEAD_HERO_PEICE_ID then
        btn:setVisible(false)
    else
        btn:setVisible(true)
    end

    local icon = contain.icon
    local iconData = {}
    iconData.customNumStr = self:getTextWord(290015)
    iconData.typeid = data.ID
    iconData.power = GamePowerConfig.HeroFragment
    if icon == nil then
        icon = UIIcon.new(contain, iconData, true, self)
        contain.icon = icon
    else
        icon:updateData(iconData)
    end

end

function HeroCompoundPanel:initPanel()
    HeroCompoundPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(290012))
    self:setLocalZOrder (PanelLayer.UI_Z_ORDER_1)
end



function HeroCompoundPanel:onBtnClicked(sender)
    local data = sender.data
    --前往获碎片
    if data.owner < data.num then
        local roleProxy = self:getProxy(GameProxys.Role)
        local isOpen = roleProxy:isFunctionUnLock(6)
        if isOpen then
            local dungeonProxy = self:getProxy(GameProxys.Dungeon)
            -- dungeonProxy:sendNotification(AppEvent.PROXY_COLSE_EVENT)
            dungeonProxy:onExterInstanceSender(1)
            self:onClosePanelHandler()
            self:dispatchEvent(HeroHallEvent.HIDE_SELF_EVENT, {})
        end
    else
        --合成碎片
        local heroProxy = self:getProxy(GameProxys.Hero)
        -- 合成前先判断有没有该武将
        if heroProxy:getHeroNumById(data.compound) > 0 then
            self:showSysMessage(self:getTextWord(290077))
            return
        end
        
        heroProxy:onTriggerNet300100Req(data.ID)
        self:onClosePanelHandler()
    end
    
end

function HeroCompoundPanel:onClosePanelHandler()
    HeroCompoundPanel.super.onClosePanelHandler(self)
    self:hide()
end