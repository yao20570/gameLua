
VipRebateMainPanel = class("VipRebateMainPanel", BasicPanel)
VipRebateMainPanel.NAME = "VipRebateMainPanel"

function VipRebateMainPanel:ctor(view, panelName)
    VipRebateMainPanel.super.ctor(self, view, panelName)
    
    --self:setUseNewPanelBg(true)

    self.VipGoConfig = ConfigDataManager:getConfigData("VipGoConfig")
    self.FixRewardConfig = ConfigDataManager:getConfigData("FixRewardConfig")
	self.vipRebateProxy = self:getProxy(GameProxys.VipRebate)
	self.listUIIcon = {}
end

function VipRebateMainPanel:finalize()
    VipRebateMainPanel.super.finalize(self)
end

function VipRebateMainPanel:initPanel()
	VipRebateMainPanel.super.initPanel(self)
    --self:setTitle(true,"vipRebate",true)
    --self:setBgType(ModulePanelBgType.ACTIVITY)
    

	-- self._bgImg = self:getChildByName("totalPanel/mainPanel/Image_34")
	--self._bgImg = self:getChildByName("bgImg")
	--TextureManager:updateImageViewFile(self._bgImg,"bg/vipRebate/vipRebateBg.pvr.ccz")
--------------top---------------------------------------
	self._timeLab = self:getChildByName("totalPanel/topPanel/timeLab")
	-- self._describleLab = self:getChildByName("totalPanel/topPanel/describleLab")

	self._tipsBtn = self:getChildByName("totalPanel/topPanel/tipsBtn")

    local label_45 = self:getChildByName("totalPanel/topPanel/Image_41/Image_44/Label_45")
    label_45:setColor(cc.c3b(244,244,244))
    local label_45_0 =self:getChildByName("totalPanel/topPanel/Image_41/Image_44/Label_45_0")
    label_45_0:setColor(cc.c3b(244,244,244))

--------------mid---------------------------------------    
	self._goldTxtLab = self:getChildByName("totalPanel/mainPanel/chargeTypeImg")
	self._goldLab = self:getChildByName("totalPanel/mainPanel/goldLab")
	self._itemsLV = self:getChildByName("totalPanel/mainPanel/itemsLV")
	self._itemPanle = self:getChildByName("totalPanel/mainPanel/itemsLV/itemPanle")

--------------down--------------------------------------    
	self._rechargeBtn = self:getChildByName("downPanel/rechargeBtn")

	self:addTouchEventListener(self._tipsBtn,self.onTipsBtnToch)
	self:addTouchEventListener(self._rechargeBtn,self.onRechargeBtnToch)
	self.proxy = self:getProxy(GameProxys.Activity)

--init	
	
end

function VipRebateMainPanel:doLayout()
	local topPanel = self:getChildByName("totalPanel")
    --local bestTopPanel = self:topAdaptivePanel()
	--NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, bestTopPanel)
    
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveUpPanel(topPanel, tabsPanel, GlobalConfig.topTabsHeight)
	local downPanel = self:getChildByName("downPanel")
    NodeUtils:adaptiveUpPanel(downPanel, topPanel, 70)
end

function VipRebateMainPanel:onShowHandler()
	self.curActivityData = self.proxy.curActivityData
	print("id====",self.curActivityData.activityId)
	self.vipRebateProxy:setCurData(self.curActivityData.activityId)
    
    self:updateThisPanel()
end

function VipRebateMainPanel:updateThisPanel()
	local time = self.vipRebateProxy:getLimitTimeStr(self.curActivityData)
	self._timeLab:setString(time)
    local darlyNum = self.vipRebateProxy:getDarlyNum()
    self._goldLab:setString(darlyNum)
    self:updateDarlyInfo()
end

function VipRebateMainPanel:registerEvents()
	VipRebateMainPanel.super.registerEvents(self)
end

function VipRebateMainPanel:onTipsBtnToch(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	local lines = {}
	for i=1,6 do
		lines[i] = {{content = TextWords:getTextWord(230120 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}
	end
	uiTip:setAllTipLine(lines)
end

function VipRebateMainPanel:updateDarlyInfo()
	local darlyInfos = self.vipRebateProxy:getDarlyList()
	local infos = {}
	for k,v in pairs(darlyInfos) do
		self.VipGoConfig[v.effctid].isGet = v.isGet
		table.insert(infos, self.VipGoConfig[v.effctid])
	end
	--  
	-- for k, v in pairs(self.VipGoConfig) do
	-- 	if v.ID == 101 then
	-- 		table.insert(infos, v)
	-- 	end
	-- end
	self:renderListView(self._itemsLV, infos, self, self.onRenderList)
end

function VipRebateMainPanel:onRenderList(itempanel,info,index)
	local data = self:noDefineNameFuction(info.reward)
	if self.listUIIcon[index] == nil then
		local goodsPanel = itempanel:getChildByName("goodsPanel")
		self.listUIIcon[index] = UIIcon.new(goodsPanel,data, true, self) 
	else
		self.listUIIcon[index]:updateData(data)
	end
	local goodsNameLab = itempanel:getChildByName("goodsNameLab")
	goodsNameLab:setString(data.name)
	goodsNameLab:setColor(ColorUtils:getColorByQuality(data.color))
	local goldNumLab = itempanel:getChildByName("goldNumLab")
	goldNumLab:setString(info.charge)
	local getBtn = itempanel:getChildByName("getBtn")
	local btnNameLab = getBtn:getChildByName("btnNameLab")
	NodeUtils:setEnable(getBtn, false)
	if info.isGet == 1 then
		btnNameLab:setString(TextWords:getTextWord(1112))
	else
		btnNameLab:setString(TextWords:getTextWord(1111))
		local darlyNum = self.vipRebateProxy:getDarlyNum()
		if darlyNum >= info.charge then 
			NodeUtils:setEnable(getBtn, true)
			getBtn.id = info.ID
			self:addTouchEventListener(getBtn,self.reqBtnTouch)
		end
	end
	
end

function VipRebateMainPanel:noDefineNameFuction(reward)
	local jsonData = StringUtils:jsonDecode(reward)
	return ConfigDataManager:getRewardConfigById(jsonData[1])
end

function VipRebateMainPanel:reqBtnTouch(sender)
	self.vipRebateProxy:onTriggerNet230021Req({id = sender.id, activtyid = self.curActivityData.activityId})
end

function VipRebateMainPanel:onRechargeBtnToch(sender)
	ModuleJumpManager:jump( ModuleName.RechargeModule)
end

function VipRebatePanel:onClosePanelHandler()
	self:dispatchEvent(VipRebateEvent.HIDE_SELF_EVENT)
end
