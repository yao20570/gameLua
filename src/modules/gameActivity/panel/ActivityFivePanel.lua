--
-- Author: zlf
-- Date: 2016年12月6日17:51:16
-- 限购界面

ActivityFivePanel = class("ActivityFivePanel", BasicPanel)
ActivityFivePanel.NAME = "ActivityFivePanel"

function ActivityFivePanel:ctor(view, panelName)
    ActivityFivePanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ActivityFivePanel:finalize()
    ActivityFivePanel.super.finalize(self)
end

function ActivityFivePanel:initPanel()
	ActivityFivePanel.super.initPanel(self)

	self._proxy = self:getProxy(GameProxys.Activity)

	--self._listview = self:getChildByName("Panel_bg/rightLv3")

    self._scrollView = self:getChildByName("Panel_bg/rightSV3")

    self._scrollViewJumpIndex = 1
end

function ActivityFivePanel:registerEvents()
	ActivityFivePanel.super.registerEvents(self)
end

function ActivityFivePanel:doLayout()
	local panel = self:getChildByName("Panel_bg")

	local mainpanel = self:getPanel(GameActivityPanel.NAME)
	if mainpanel ~= nil then
		-- NodeUtils:adaptivePanelBg(panel, 20, mainpanel:getBestPanel())
		-- NodeUtils:adaptivePanelBg(panel, 10, mainpanel:getTopListView())
    	NodeUtils:adaptiveUpPanel(panel,mainpanel:getTopListView(),10)

		-- local topPanel = mainpanel:getTopPanel()
		-- NodeUtils:adaptiveListView(self._scrollView, 20, topPanel)

		NodeUtils:adaptiveListView(self._scrollView, GlobalConfig.downHeight, mainpanel:getMidBg(),10)
	else
		NodeUtils:adaptivePanelBg(panel, 20, GlobalConfig.topHeight)
	end

	self:createScrollViewItemUIForDoLayout(self._scrollView)
end

function ActivityFivePanel:onShowHandler(data)
	-- self._listview:jumpToTop()
	self._activityId = data.activityId
	self._MainPanel = self:getPanel(GameActivityPanel.NAME)
	table.sort(data.effectInfos,function (a,b) return a.sort < b.sort end )
	--self:renderListView(self._listview, data.effectInfos, self, self.renderMethod)


    -- self:renderScrollView(self._scrollView, "itemPanel3", data.effectInfos, self, self.renderMethod, self._scrollViewJumpIndex)
    self:renderScrollView(self._scrollView, "itemPanel3", data.effectInfos, self, self.renderMethod, nil)

end

function ActivityFivePanel:renderMethod(item, data)
	local title = item:getChildByName("title")
	local buyBtn = item:getChildByName("buyBtn")
	local count = item:getChildByName("count")

	if buyBtn.oldPos == nil then
		buyBtn.oldPos = cc.p(buyBtn:getPosition())
	end

	title:setString(data.conditionName)

	if type(data.originalprice) == "table" and #data.originalprice ~= 0 then
		count:setVisible(true)
		NodeUtils:centerNodes(buyBtn, {count})
		buyBtn:setPosition(buyBtn.oldPos)
	else
		count:setVisible(false)
		buyBtn:setPositionY(60)
	end

	buyBtn:setTitleText(TextWords:getTextWord(18005))
	if rawget(data,"jumpbutton") ~= nil and rawget(data,"jumpbutton") ~= "" then  --跳转模块
		buyBtn:setTitleText(TextWords:getTextWord(18002))
	end

	buyBtn.data = data
	self:addTouchEventListener(buyBtn, self.btnTouch)
	NodeUtils:setEnable(buyBtn, true)

	for i=1,3 do
		local nameLab = item:getChildByName("nameLab"..i)
		nameLab:setVisible(false)
	end
	local infoPanel = item:getChildByName("Panel_178")
	infoPanel:setVisible(type(data.originalprice) == "table" and #data.originalprice ~= 0)
	if #data.originalprice ~= 0 then
		local oriPrice = infoPanel:getChildByName("oriPrice")
		local endPrice = infoPanel:getChildByName("endPrice")
		local oriImg = infoPanel:getChildByName("oriImg")
		local disImg = infoPanel:getChildByName("disImg")
		oriPrice:setString(data.originalprice[1].num)
		endPrice:setString(data.disprice[1].num)
		count:setString("可购买"..data.limit.."/"..data.totalLimit.."次数")

		if data.limit == data.totalLimit then
			NodeUtils:setEnable(buyBtn, false)  --购买次数不足
		end

		local redLine = infoPanel:getChildByName("lineImg")
		local labelSize = oriPrice:getContentSize()
		local lineSize = redLine:getContentSize()
		redLine:setScaleX(1)
		redLine:setScaleX((labelSize.width + 10) / lineSize.width)

		if data.originalprice[1].power == 407 and data.originalprice[1].typeId == 206 then
			local url = "images/newGui1/IconRes6.png"
			if oriImg.url ~= url then
				oriImg.url = url
				TextureManager:updateImageView(oriImg, url)
				TextureManager:updateImageView(disImg, url)
			end
		else
			local config = ConfigDataManager:getConfigByPowerAndID(data.originalprice[1].power,data.originalprice[1].typeId)
			if oriImg.url ~= config.url then
				oriImg.url = config.url
				TextureManager:updateImageView(oriImg, config.url)
				TextureManager:updateImageView(disImg, config.url)
			end
		end

	end

	local function updateIcon(iconInfo)
		for i=1,3 do
			local info = iconInfo[i]
			local iconNode = item:getChildByName("item"..i)
			if iconNode ~= nil then
				iconNode:setVisible(info ~= nil)
			end
			if info ~= nil and iconNode ~= nil then
				if iconNode.uiIcon == nil then
					iconNode.uiIcon = UIIcon.new(iconNode, info, true, self, nil, true)
				else
					iconNode.uiIcon:updateData(info)
				end
			end
		end
	end

	if data.rewards == nil or #data.rewards == 0 then
		
		local tabData = data.icon
		tabData = StringUtils:splitString(tabData,";") --@换行标记
		for k,v in pairs(tabData) do
			v = self._MainPanel:StringRemove(v,"'") 				--删除单引号
			v = StringUtils:splitString(v,",") 		--分号；同一行拼接
			
			local nameLab = item:getChildByName("nameLab"..k)
			if nameLab ~= nil then
				nameLab:setVisible(true)
				nameLab:setString(v[2])
			end
			local iconData = {}
			iconData.power = GamePowerConfig.Other
			iconData.typeid = tonumber(v[1])
			iconData.num = 0
			tabData[k] = iconData
		end
		updateIcon(tabData)
		return
	end
	updateIcon(data.rewards)
end

function ActivityFivePanel:btnTouch(sender)
	local data = sender.data
	if rawget(data,"jumpbutton") ~= nil and rawget(data,"jumpbutton") ~= "" then  --跳转模块
		local jumpData = {}
		self._MainPanel:commonJumpMethod({jump = data.jumpbutton, jumpPanel = data.jumpmodule})
	elseif data.iscanget == 1 or data.iscanget == 2 then
		local function confirmCallback()
			self._MainPanel:commonMethod(self._activityId, data.effectId, data.sort, false, true)
	    end
		--购买二次确认
        local tipStr = string.format(TextWords:getTextWord(18015), data.disprice[1].num)
        local messageBox = self:showMessageBox( tipStr, confirmCallback)
        messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	end
end

function ActivityFivePanel:jumpToStart(jumpIndex)
	self._scrollViewJumpIndex = jumpIndex
end