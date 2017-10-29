
VipGrandTotalPanel = class("VipGrandTotalPanel", BasicPanel)
VipGrandTotalPanel.NAME = "VipGrandTotalPanel"

function VipGrandTotalPanel:ctor(view, panelName)
    VipGrandTotalPanel.super.ctor(self, view, panelName)
    
    --self:setUseNewPanelBg(true)

    self.VipGoConfig = ConfigDataManager:getConfigData("VipGoConfig")
    self.FixRewardConfig = ConfigDataManager:getConfigData("FixRewardConfig")
	self.vipRebateProxy = self:getProxy(GameProxys.VipRebate)
	self.listUIIcon = {}
end

function VipGrandTotalPanel:finalize()
    VipGrandTotalPanel.super.finalize(self)
end

function VipGrandTotalPanel:initPanel()
	VipGrandTotalPanel.super.initPanel(self)
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
	self._itemTotalPanle = self:getChildByName("totalPanel/mainPanel/itemPanle")

--------------down--------------------------------------    
	self._rechargeBtn = self:getChildByName("downPanel/rechargeBtn")

	self:addTouchEventListener(self._tipsBtn,self.onTipsBtnToch)
	self:addTouchEventListener(self._rechargeBtn,self.onRechargeBtnToch)
	self.proxy = self:getProxy(GameProxys.Activity)

--init	
	
end

function VipGrandTotalPanel:doLayout()
	local topPanel = self:getChildByName("totalPanel")
    --local bestTopPanel = self:topAdaptivePanel()
	--NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, bestTopPanel)
    
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveUpPanel(topPanel, tabsPanel, GlobalConfig.topTabsHeight)
	local downPanel = self:getChildByName("downPanel")
    NodeUtils:adaptiveUpPanel(downPanel, topPanel, 70)
end

function VipGrandTotalPanel:onShowHandler()
	self.curActivityData = self.proxy.curActivityData
	print("id====",self.curActivityData.activityId)
	self.vipRebateProxy:setCurData(self.curActivityData.activityId)
	self:initTotalInfo()
    
    self:updateThisPanel()
end

function VipGrandTotalPanel:updateThisPanel()
    local totalNum = self.vipRebateProxy:getTotalNum()
    self._goldLab:setString(totalNum)
    self:updateTotalInfo()
end

function VipGrandTotalPanel:initTotalInfo()
	local time = self.vipRebateProxy:getLimitTimeStr(self.curActivityData)
	self._timeLab:setString(time)
	-- local describle = self.vipRebateProxy:getDescrible()
	-- self._describleLab:setString(describle)  
	local item = {}
    for _, v in pairs(self.VipGoConfig) do
    	if v.type == 102 then
    		item = v
    		self.totalId = v.ID 
    	end
    end
    local goldNumLab = self._itemTotalPanle:getChildByName("goldNumLab")
    goldNumLab:setString(item.charge)
    local jsonData = StringUtils:jsonDecode(item.reward)
    for k, v in pairs(jsonData) do
    	local txt = self._itemTotalPanle:getChildByName("goodsName"..k.."Lab")
    	local tempData = ConfigDataManager:getRewardConfigById(v)
    	local colorType = tempData.color
    	txt:setColor(ColorUtils:getColorByQuality(colorType))
    	txt:setString(tempData.name)

    	local goodsPanel = self._itemTotalPanle:getChildByName("goodsPanel"..k)
    	if goodsPanel.uiIcon == nil then
    		goodsPanel.uiIcon = UIIcon.new(goodsPanel,tempData, true, self) 
    	else
    		goodsPanel.uiIcon:updateData(tempData)
    	end
    end
end


function VipGrandTotalPanel:registerEvents()
	VipGrandTotalPanel.super.registerEvents(self)
end

function VipGrandTotalPanel:onTipsBtnToch(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	local lines = {}
	for i=1,6 do
		lines[i] = {{content = TextWords:getTextWord(230120 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}
	end
	uiTip:setAllTipLine(lines)
end

function VipGrandTotalPanel:onRenderList(itempanel,info,index)
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

function VipGrandTotalPanel:noDefineNameFuction(reward)
	local jsonData = StringUtils:jsonDecode(reward)
	return ConfigDataManager:getRewardConfigById(jsonData[1])
end

function VipGrandTotalPanel:updateTotalInfo()
	local isGet = self.vipRebateProxy:isAllnumGet()
	local btn = self:getChildByName("totalPanel/mainPanel/itemPanle/getBtn")
	local btnTxt = self:getChildByName("totalPanel/mainPanel/itemPanle/getBtn/btnNameLab")
	NodeUtils:setEnable(btn, false)
	if isGet == 1 then
		btnTxt:setString(TextWords:getTextWord(1112))
	else
		btnTxt:setString(TextWords:getTextWord(1111))
		local totalNum = self.vipRebateProxy:getTotalNum()
		if totalNum >= self.VipGoConfig[self.totalId].charge then
			NodeUtils:setEnable(btn, true)
			btn.id = self.totalId
			self:addTouchEventListener(btn,self.reqBtnTouch)
		end
	end	
	
end

function VipGrandTotalPanel:reqBtnTouch(sender)
	self.vipRebateProxy:onTriggerNet230021Req({id = sender.id, activtyid = self.curActivityData.activityId})
end

function VipGrandTotalPanel:onRechargeBtnToch(sender)
	ModuleJumpManager:jump( ModuleName.RechargeModule)
end

function VipGrandTotalPanel:onClosePanelHandler()
	self:dispatchEvent(VipRebateEvent.HIDE_SELF_EVENT)
end