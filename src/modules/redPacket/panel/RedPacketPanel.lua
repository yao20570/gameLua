--
-- Author: zlf
-- Date: 2016年5月23日14:02:23
-- 红包大派送界面
RedPacketPanel = class("RedPacketPanel", BasicPanel)
RedPacketPanel.NAME = "RedPacketPanel"

function RedPacketPanel:ctor(view, panelName)
    RedPacketPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)

end

function RedPacketPanel:finalize()
    RedPacketPanel.super.finalize(self)
end

function RedPacketPanel:initPanel()
	RedPacketPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Activity)
	self:setTitle(true,"redbag", true)

	self:setBgType(ModulePanelBgType.ACTIVITY)

	local topPanel = self:getChildByName("topPanel")

	-- NodeUtils:adaptiveListView(topPanel, self:getChildByName("bottomPanel"), 900)
	self.alt_num = self:getChildByName("topPanel/alt_num")
	local btn_tips = self:getChildByName("topPanel/btn_tips")
	self:addTouchEventListener(btn_tips, self.showTips)


	-- self.lab_txt = self:getChildByName("topPanel/lab_txt")
	self.lab_time = self:getChildByName("topPanel/lab_time")
	local lab_title = self:getChildByName("topPanel/lab_title")

	lab_title:setString(TextWords:getTextWord(249996))

	for i=1,2 do
		local label = self:getChildByName("topPanel/lab"..i)
		label:setString(TextWords:getTextWord(250022+i))
	end

	self.pay_btn = self:getChildByName("bottomPanel/btn_pay")
	self:addTouchEventListener(self.pay_btn, self.payRedPkg)

	local Img1 = self:getChildByName("topPanel/Image_12_0")
	local Img2 = self:getChildByName("bottomPanel/Image_12")
	local Img3 = self:getChildByName("topPanel/Image_12_1")
    TextureManager:updateImageView(Img1, "images/newGui1/IconRes6.png")
	TextureManager:updateImageView(Img2, "images/newGui1/IconRes6.png")
    TextureManager:updateImageView(Img3, "images/redPacket/money.png")


	-- self:adjustBootomBg(self:getChildByName("bottomPanel"), topPanel)

end

function RedPacketPanel:doLayout()
	local topPanel = self:getChildByName("topPanel")

	local bestTopPanel = self:topAdaptivePanel()
	NodeUtils:adaptiveUpPanel(topPanel, bestTopPanel, GlobalConfig.topAdaptive)
end

function RedPacketPanel:registerEvents()
	RedPacketPanel.super.registerEvents(self)
end

function RedPacketPanel:onShowHandler()
	--self:playAction("open")
	local data = self.proxy.curActivityData
	self:initView(data)
end

function RedPacketPanel:getExcelData(id)
	local config = ConfigDataManager:getConfigData(ConfigData.RedBagConfig)
	return config[id]
end

function RedPacketPanel:onClosePanelHandler()
    self.view:dispatchEvent(RedPacketEvent.HIDE_SELF_EVENT)
end

function RedPacketPanel:showTips(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	local text = {{{content = TextWords:getTextWord(250015), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}}
    uiTip:setAllTipLine(text)
end

function RedPacketPanel:initView(data)
	-- local startTime = TimeUtils:setTimestampToString(data.startTime)
 --    local endTime = TimeUtils:setTimestampToString(data.endTime)
    self.lab_time:setString(TimeUtils.getLimitActFormatTimeString(data.startTime,data.endTime))
    local updateInfo = self:getExcelData(data.effectId)
    local lab_have = self:getChildByName("topPanel/lab_have")
    local lab_use = self:getChildByName("topPanel/lab_use")
    local lab_price = self:getChildByName("bottomPanel/Label_6_2")
    local priceInfo = self.proxy:getPkgInfoByEffectId(data.activityId)
    if priceInfo then
    	lab_use:setString(priceInfo.num)
    	self.pay_btn.hasCoin = priceInfo.num
    	local needCoin = updateInfo.price - self.pay_btn.hasCoin
    	if needCoin * 100 < updateInfo.price*(100-updateInfo.discount) then
    		needCoin = updateInfo.price*(100-updateInfo.discount) / 100
    		needCoin = StringUtils:getPreciseDecimal(needCoin, 0)
    	end
    	lab_price:setString(needCoin)
    end


    self.pay_btn.payId = data.activityId
    self.alt_num:setString((100 - updateInfo.discount)/10)
    lab_have:setString(updateInfo.price)
    self.pay_btn.price = updateInfo.price--*config.discount*0.01
    self.pay_btn.percent = updateInfo.discount
    local rewardData = updateInfo.showreward
    self:updateRewardIcon(rewardData)
end

function RedPacketPanel:showPkgInfoView(data)
	if self._uiRedPacket == nil then
        local parent = self.view:getLayer(ModuleLayer.UI_TOP_LAYER)
        self._uiRedPacket = UIRetPacket.new(parent, self)
    end
    local info = data.rbrInfo
    local num = data.getMoney
    self._uiRedPacket:show(info, data.name, num)
end

function RedPacketPanel:updateRewardIcon(data)
	for i=1,4 do
		local icon = self:getChildByName("topPanel/img_icon"..i)
		if data[i] then
			local iconData = {}
    		iconData.num = data[i][3]
    		iconData.power = data[i][1]
    		iconData.typeid = data[i][2]
    		local uiIcon = icon.uiIcon
    		if not uiIcon then
        		uiIcon = UIIcon.new(icon, iconData, true, self, nil, true)
        		icon.uiIcon = uiIcon
    		else
        		uiIcon:updateData(iconData)
    		end
    		uiIcon:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
		end
		icon:setVisible(data[i]~=nil)
	end
end

function RedPacketPanel:payRedPkg(sender)
	if (not sender.payId) or (not sender.hasCoin) then 
		print("缺少请求所需数据")
		return 
	end
	local text = TextWords:getTextWord(250021)
	local roleProxy = self:getProxy(GameProxys.Role)
	local payText = TextWords:getTextWord(230115)
    local coin = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
	local function call()
		local parent = self:getParent()
        local panel = parent.payPanel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.payPanel = panel
        else
            panel:show()
        end
	end

	local function showPayTips(pkgPrice)
		local messageBox = self:showMessageBox(string.format(payText, pkgPrice), function()
			self.proxy:onTriggerNet230016Req({id = sender.payId})
		end)
        messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	end

	if sender.hasCoin*100 >= sender.price * sender.percent then
		local percent = 100 - sender.percent
		local needCoin = sender.price * percent
		needCoin = needCoin / 100
		needCoin = StringUtils:getPreciseDecimal(needCoin, 0)
		logger:error("红包的价格===%d",needCoin)
		if coin < needCoin then
			self:showMessageBox(string.format(text, sender.price, coin, needCoin - coin), call)
		else
			showPayTips(needCoin)
			-- self.proxy:onTriggerNet230016Req({id = sender.payId})
		end
	else
		local needCoin = sender.price - sender.hasCoin
		if coin < needCoin then
			self:showMessageBox(string.format(text, sender.price, coin, needCoin - coin), call)
		else
			-- self.proxy:onTriggerNet230016Req({id = sender.payId})
			showPayTips(needCoin)
		end
	end
end