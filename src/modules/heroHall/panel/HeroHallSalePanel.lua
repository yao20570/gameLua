--
-- Author: zlf
-- Date: 2016年12月13日16:41:36
-- 英雄分解预览

HeroHallSalePanel = class("HeroHallSalePanel", BasicPanel)
HeroHallSalePanel.NAME = "HeroHallSalePanel"

function HeroHallSalePanel:ctor(view, panelName)
    HeroHallSalePanel.super.ctor(self, view, panelName, 330)
    
    self:setUseNewPanelBg(true)
end

function HeroHallSalePanel:finalize()
    HeroHallSalePanel.super.finalize(self)
end

function HeroHallSalePanel:initPanel()
	HeroHallSalePanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(290067))
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)
    self._iconImg = self:getChildByName("Panel_1/itemPanel/item/iconImg")
    self._numLab = self:getChildByName("Panel_1/itemPanel/item/numLab")
    self._nameLab = self:getChildByName("Panel_1/itemPanel/item/nameLab")
    self._saleBtn = self:getChildByName("Panel_1/sureBtn")
    local cancelBtn = self:getChildByName("Panel_1/cancelBtn")
    self:addTouchEventListener(cancelBtn, self.hide)
end

function HeroHallSalePanel:onShowHandler(data)

	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig,data.heroId)
	local stageJson = StringUtils:jsonDecode(config.decompose)
	local stageDate = ConfigDataManager:getRewardConfigByJson(config.decompose)

	self:renderItem(stageJson,stageDate)

	local sendData = {}
	sendData.id = data.heroDbId
	self._saleBtn.data = sendData
  	self:addTouchEventListener(self._saleBtn,self.saleEvent)
end

function HeroHallSalePanel:renderItem(stageJson,stageDate)
	self._nameLab:setString(stageDate.name)
    self._numLab:setString(stageDate.num)
    local data = {}
    data.power = stageJson[1][1]
    data.typeid = stageJson[1][2]
    local icon = self._iconImg.icon
    if icon == nil then
        icon = UIIcon.new(self._iconImg, data, true, self)
        self._iconImg.icon = icon
    else
        icon:updateData(data)
    end
end

function HeroHallSalePanel:saleEvent(sender)
	local heroProxy = self:getProxy(GameProxys.Hero)
	local data = sender.data
	heroProxy:onTriggerNet300103Req(data)
	self:hide()
end