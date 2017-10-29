--
-- Author: zlf
-- Date: 2016年12月6日17:51:16
-- 排行榜的界面

ActivityThreePanel = class("ActivityThreePanel", BasicPanel)
ActivityThreePanel.NAME = "ActivityThreePanel"

function ActivityThreePanel:ctor(view, panelName)
    ActivityThreePanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ActivityThreePanel:finalize()
   
	local downPanel = self:getChildByName("downPanel")
	local btnNames = {"leftBtn", "rightBtn"}
	for k,btnName in pairs(btnNames) do
		local btn = downPanel:getChildByName(btnName)
		if btn.effect ~= nil then
			btn.effect:finalize()
			btn.effect = nil
		end
	end

    ActivityThreePanel.super.finalize(self)
end

function ActivityThreePanel:initPanel()
	ActivityThreePanel.super.initPanel(self)

	self._proxy = self:getProxy(GameProxys.Activity)

	--self._listview = self:getChildByName("Panel_bg/rightLv")
    self._scrollView = self:getChildByName("Panel_bg/rightSV")

    self._scrollViewJumpIndex = 1
end

function ActivityThreePanel:registerEvents()
	ActivityThreePanel.super.registerEvents(self)
end

function ActivityThreePanel:doLayout()
	local panel = self:getChildByName("Panel_bg")

	local mainpanel = self:getPanel(GameActivityPanel.NAME)
	if mainpanel ~= nil then
		-- NodeUtils:adaptivePanelBg(panel, 20, mainpanel:getBestPanel())
		local topPanel = mainpanel:getTopPanel()
		local downPanel = self:getChildByName("downPanel")
		--NodeUtils:adaptiveListView(self._listview, downPanel, topPanel)
        -- NodeUtils:adaptiveListView(self._scrollView, downPanel, topPanel)
        
		NodeUtils:adaptiveListView(self._scrollView, downPanel, mainpanel:getMidBg(),10)
		NodeUtils:adaptiveListView(downPanel, GlobalConfig.downHeight, self._scrollView,10)
	else
		NodeUtils:adaptivePanelBg(panel, 20, GlobalConfig.topHeight)
	end
    self:createScrollViewItemUIForDoLayout(self._scrollView)
end

function ActivityThreePanel:onShowHandler(data)

	self.rankData = nil
	-- if data.buttons[1].type == 2 then
	--获取请求的数据
	self.rankData = self._proxy:getRankReqData(data.activityId)
	-- end

	-- self._listview:jumpToTop()
	table.sort(data.effectInfos,function (a,b) return a.sort < b.sort end )


	--self:renderListView(self._listview, data.effectInfos, self, self.renderMethod)

    local fixData = { }
    for k, v in pairs(data.effectInfos) do
        if v.iscanget ~= 4 then
            table.insert(fixData, v)
        end
    end
    self:renderScrollView(self._scrollView, "itemPanel4", fixData, self, self.renderMethod, self._scrollViewJumpIndex)

	self:updateDownPanel(data)
end

function ActivityThreePanel:renderMethod(item, data)
	local title = item:getChildByName("title")
	title:setString(data.conditionName)
	for i=1,3 do
		local info = data.rewards[i]
		local iconNode = item:getChildByName("item"..i)
		iconNode:setVisible(info ~= nil)
		if info ~= nil then
			if iconNode.uiIcon == nil then
				iconNode.uiIcon = UIIcon.new(iconNode, info, true, self, nil, true)
			else
				iconNode.uiIcon:updateData(info)
			end
		end
	end
end

function ActivityThreePanel:updateDownPanel(data)
	local buttons = data.buttons
	local downPanel = self:getChildByName("downPanel")
	downPanel:setVisible(type(buttons) == "table" and #buttons > 0)
	if type(buttons) ~= "table" or #buttons < 1 then
		return
	end		
	local btnNames = {"leftBtn", "rightBtn"}
	for i=1, 2 do
		local btnInfo = buttons[i]
		local btn = downPanel:getChildByName(btnNames[i])
		if btn.effect == nil then
			local effectName = btnNames[i] == "leftBtn" and 
												"rgb-daanniu-lv" or "rgb-daanniu-huang"
			btn.effect = self:createUICCBLayer(effectName, btn)
			local btnSize = btn:getContentSize()
			btn.effect:setPosition(btnSize.width*0.5, btnSize.height*0.5)
		end

		NodeUtils:setEnable(btn, true)
		btn:setVisible(btnInfo ~= nil)
		if btnInfo ~= nil then
			btn:setTitleText(btnInfo.name)
			btn.data = data
			btn.index = i
			if btn.effect then
				btn.effect:setVisible(btnInfo.type <= 2)
			end
			if btnInfo.type > 2 then
				NodeUtils:setEnable(btn, false)
			else
				self:addTouchEventListener(btn, self.btnTouch)
			end
		end
	end

	-- 当前排名显示
	local Panel_rank = downPanel:getChildByName("Panel_rank")
	Panel_rank:setVisible(true)
	local Label_left = Panel_rank:getChildByName("Label_left")
	local Label_right = Panel_rank:getChildByName("Label_right")
	Label_left:setString(self:getTextWord(18006))
	if data.already == 0 or data.already == nil then
		-- 未上榜
		Label_right:setString(self:getTextWord(1912))
		Label_right:setColor(ColorUtils.wordColorDark04)					
	elseif data.already > 0 then
		-- 当前排名
		Label_right:setString(data.already)
		Label_right:setColor(ColorUtils.wordColorDark03)
	elseif data.already < 0 then
		-- 活动排名
		Label_left:setString(self:getTextWord(18007))
		Label_right:setString(math.abs(data.already))
		Label_right:setColor(ColorUtils.wordColorDark03)
	end



end

function ActivityThreePanel:btnTouch(sender)
	local mainpanel = self:getPanel(GameActivityPanel.NAME)
	local buttons = sender.data.buttons[sender.index]
	if sender.index == 1 then  --跳轉
		mainpanel:commonJumpMethod(buttons)
	elseif sender.index == 2 then  --領取
		if self.rankData == nil then
			logger:error("self.rankData是nil，缺少请求所需数据")
			return
		end
		mainpanel:commonMethodThree(sender.data.activityId, self.rankData.effectId, self.rankData.sort, sender.index, true, false)
	end
end

function ActivityThreePanel:jumpToStart(jumpIndex)
	self._scrollViewJumpIndex = jumpIndex
end