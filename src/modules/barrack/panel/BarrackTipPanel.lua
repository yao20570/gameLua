BarrackTipPanel = class("BarrackTipPanel", BasicPanel)
BarrackTipPanel.NAME = "BarrackTipPanel"

function BarrackTipPanel:ctor(view, panelName)
    BarrackTipPanel.super.ctor(self, view, panelName, 330)

end

function BarrackTipPanel:finalize()
    BarrackTipPanel.super.finalize(self)
end

function BarrackTipPanel:initPanel()
    BarrackTipPanel.super.initPanel(self)
    
    self:setTitle(true, TextWords:getTextWord(362))
end

--show时候 触发的事件
function BarrackTipPanel:onShowHandler()
    local roleProxy = self:getProxy(GameProxys.Role)
    local viplv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
        
    local conf = ConfigDataManager:getConfigDataBySortId(ConfigData.VipDataConfig) 
    local maxVipLv = conf[#conf].level
    local btnSpeed = self:getChildByName("Panel_1/btnSpeed")
    local btnVIP = self:getChildByName("Panel_1/btnVIP")
    local labVIP = self:getChildByName("Panel_1/Image_2/Label_6_0")
    if viplv >= maxVipLv then
        btnVIP:setVisible(false)
        labVIP:setVisible(false)
        btnSpeed:setPositionX(320)
    else
        btnVIP:setVisible(true)
        labVIP:setVisible(true)
        btnSpeed:setPositionX(480)
    end
end

function BarrackTipPanel:registerEvents()
    local btnVIP = self:getChildByName("Panel_1/btnVIP")
    self:addTouchEventListener(btnVIP, self.onVIPTouch)
    
    local btnSpeed = self:getChildByName("Panel_1/btnSpeed")
    self:addTouchEventListener(btnSpeed, self.onSpeedTouch)
end

function BarrackTipPanel:onVIPTouch(sender)
    ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
    self:hide()
end

function BarrackTipPanel:onSpeedTouch(sender)
    local panel = self:getPanel(BarrackPanel.NAME)
    panel:changeTabSelectByName(RecruitingPanel.NAME)
    panel = self:getPanel(RecruitingPanel.NAME)
    panel:playEffect()
    self:hide()
end