--
-- Author: zlf
-- Date: 2016年11月30日22:05:13
-- 建国基金界面

ActivityFourPanel = class("ActivityFourPanel", BasicPanel)
ActivityFourPanel.NAME = "ActivityFourPanel"

function ActivityFourPanel:ctor(view, panelName)
    ActivityFourPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ActivityFourPanel:finalize()
    
	-- local bgImg = self:getChildByName("Panel_bg/Infoimg")
	-- if bgImg.effect ~= nil then
	-- 	bgImg.effect:finalize()
	-- 	bgImg.effect = nil
	-- end

    ActivityFourPanel.super.finalize(self)
end

function ActivityFourPanel:initPanel()
	ActivityFourPanel.super.initPanel(self)

	self._proxy = self:getProxy(GameProxys.Activity)

	--self._listview = self:getChildByName("Panel_bg/listView")
    self._scrollView = self:getChildByName("Panel_bg/scrollView")

    self._scrollViewJumpIndex = 1
end

function ActivityFourPanel:registerEvents()
	ActivityFourPanel.super.registerEvents(self)
end

function ActivityFourPanel:doLayout()
	local panel = self:getChildByName("Panel_bg")

	local mainpanel = self:getPanel(GameActivityPanel.NAME)
	if mainpanel ~= nil then
		-- NodeUtils:adaptivePanelBg(panel, 20, mainpanel:getTopListView())
  --   	NodeUtils:adaptiveTopPanelAndListView(panel, nil, nil, mainpanel:getTopListView(), 10)
    	NodeUtils:adaptiveUpPanel(panel,mainpanel:getTopListView(),10)
	else
		NodeUtils:adaptivePanelBg(panel, 20, self:topAdaptivePanel():getPositionY()-85)
	end

	-- NodeUtils:adaptiveTopPanelAndListView(self._scrollView,nil, GlobalConfig.downHeight,  mainpanel:getTopPanel(), 10)
	-- NodeUtils:adaptiveUpPanel(self._scrollView,mainpanel:getMidBg(),10)
	-- NodeUtils:adaptiveListView(self._scrollView, GlobalConfig.downHeight, mainpanel:getTopPanel(),10)
	NodeUtils:adaptiveListView(self._scrollView, GlobalConfig.downHeight, mainpanel:getMidBg(),10)
	self:createScrollViewItemUIForDoLayout(self._scrollView)

end

function ActivityFourPanel:updateView(data)
	self._activityId = data.activityId
	self.rankData = {effectId = -1, sort = -1}

	local bgImg = self:getChildByName("Panel_bg/Infoimg")
	if bgImg.bgIcon ~= data.bgIcon then
		bgImg.bgIcon = data.bgIcon
        -- local url = "bg/activity/artIcon"..data.artIcon .. TextureManager.bg_type
        local url = "bg/activity/artIcon"..data.titleIcon .. ".png"
		TextureManager:updateImageViewFile(bgImg, url)
		--建国基金特效
		-- if bgImg.effect == nil then
		-- 	bgImg.effect = self:createUICCBLayer("rgb-hd-xian", bgImg)
		-- 	local bgSize = bgImg:getContentSize()
		-- 	bgImg.effect:setPosition(bgSize.width*0.2, -10)
		-- end
	end

	local bgImg2 = self:getChildByName("Panel_bg")

	for i=1,2 do
		local v = data.buttons[i]
		local btn = bgImg2:getChildByName("btn"..i)
		btn.index = i
		btn:setVisible(v ~= nil)
		if v ~= nil then
			btn.data = v
			btn:setTitleText(v.name)
			self:addTouchEventListener(btn, self.btnTouch)
	        if i == 2 then  --vip等级
	        	local proxy = self:getProxy(GameProxys.Role)
	        	local vipLeval = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
	        	NodeUtils:setEnable(btn, vipLeval >= 2)
	        end
		end
	end

	table.sort(data.effectInfos,function (a,b) return a.sort < b.sort end )

	--self:renderListView(self._listview, data.effectInfos, self, self.renderItemUI)

    local fixData = {}
    for k, v in pairs(data.effectInfos) do
        if v.iscanget ~= 4 then
            table.insert(fixData, v)
        end
    end

    table.sort(fixData, function(a, b) 
        if a.iscanget ~= b.iscanget then
            if a.iscanget == 1 then
                return true
            elseif b.iscanget == 1 then
                return false
            end                
        end
        
        return a.sort < b.sort
    end)

    self:renderScrollView(self._scrollView, "itemPanel", fixData, self, self.renderItemUI, self._scrollViewJumpIndex) 
end

function ActivityFourPanel:renderItemUI(item, data, index)
	local title = item:getChildByName("title")
	title:setString(data.conditionName)
	local info = item:getChildByName("info")
	info:setString(data.info)
	for k,v in pairs(data.rewards) do
		local iconNode = item:getChildByName("item"..k)
		if iconNode ~= nil then
			iconNode:setVisible(true)
			if iconNode.uiIcon == nil then
				iconNode.uiIcon = UIIcon.new(iconNode, v, true, self, nil, true)
			else
				iconNode.uiIcon:updateData(v)
			end
		end
	end

	for i=#data.rewards + 1, 3 do
		local iconNode = item:getChildByName("item"..i)
		iconNode:setVisible(false)
	end

	local getBtn = item:getChildByName("getBtn")
	getBtn.data = data

	local key = "1800" .. data.iscanget		
	local text = TextWords:getTextWord(tonumber(key))
	getBtn:setTitleText(text)

	if data.iscanget > 2 then
		NodeUtils:setEnable(getBtn, false)
	else
		NodeUtils:setEnable(getBtn, true)
		self:addTouchEventListener(getBtn, self.getReward)
	end
end

--除了建国基金写死两个-1  其他都去proxy拿effectid  和  sort
--type：1  跳转模块
--type：2  可领取状态
function ActivityFourPanel:btnTouch(sender)
	local buttons = sender.data
	if buttons.type == 1 then
		local mainpanel = self:getPanel(GameActivityPanel.NAME)
		mainpanel:commonJumpMethod(buttons)
	elseif buttons.type == 2 then
		if self.rankData == nil then
			logger:error("self.rankData是nil，缺少请求所需数据")
			return
		end
		local function confirmCallback()
			local sendData = {}
			sendData.activityId = self._activityId
			sendData.effectId = self.rankData.effectId
			sendData.sort = self.rankData.sort
			self._proxy:onTriggerNet230001Req(sendData, sender.index, true, false)
	    end
		--购买二次确认
		local priceNum = 500--建国基金价格在UI里面被写死了
        local tipStr = string.format(TextWords:getTextWord(18015), priceNum)
        local messageBox = self:showMessageBox( tipStr, confirmCallback)
        messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	end
end

function ActivityFourPanel:getReward(sender)
	local data = sender.data
	local mainpanel = self:getPanel(GameActivityPanel.NAME)
	mainpanel:commonMethod(self._activityId, data.effectId, data.sort, false, false)
end

function ActivityFourPanel:jumpToStart(jumpIndex)
	self._scrollViewJumpIndex = jumpIndex
end