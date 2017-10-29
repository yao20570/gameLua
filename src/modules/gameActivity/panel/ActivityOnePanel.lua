--
-- Author: zlf
-- Date: 2016年11月30日22:53:16
-- uitype为3和4的界面

ActivityOnePanel = class("ActivityOnePanel", BasicPanel)
ActivityOnePanel.NAME = "ActivityOnePanel"

function ActivityOnePanel:ctor(view, panelName)
    ActivityOnePanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ActivityOnePanel:finalize()
    ActivityOnePanel.super.finalize(self)
end

function ActivityOnePanel:initPanel()
	ActivityOnePanel.super.initPanel(self)

	self._proxy = self:getProxy(GameProxys.Activity)

	--self._listview = self:getChildByName("Panel_bg/rightLv")
    self._scrollView = self:getChildByName("Panel_bg/rightSV")

    self._scrollViewJumpIndex = 1
end

function ActivityOnePanel:registerEvents()
	ActivityOnePanel.super.registerEvents(self)
end

function ActivityOnePanel:doLayout()
	local panel = self:getChildByName("Panel_bg")

	local mainpanel = self:getPanel(GameActivityPanel.NAME)
	if mainpanel ~= nil then
		NodeUtils:adaptivePanelBg(panel, 20, mainpanel:getBestPanel())

	
		-- local topPanel = mainpanel:getTopPanel()
		--NodeUtils:adaptiveListView(self._listview, 20, topPanel)
        -- NodeUtils:adaptiveListView(self._scrollView, 20, topPanel)

    	-- NodeUtils:adaptiveUpPanel(self._scrollView,mainpanel:getMidBg(),10)
		NodeUtils:adaptiveListView(self._scrollView, GlobalConfig.downHeight, mainpanel:getMidBg(),10)
        
        -- self:createScrollViewItemUIForDoLayout(self._scrollView)

	else
		NodeUtils:adaptivePanelBg(panel, 20, GlobalConfig.topHeight)
	end

	self:createScrollViewItemUIForDoLayout(self._scrollView)
end

function ActivityOnePanel:onShowHandler(data)
    -- self._listview.jumpToTop(self._listview)
    self._activityId = data.activityId
    table.sort(data.effectInfos, function(a, b) return a.sort < b.sort end)

    -- self:renderListView(self._listview, data.effectInfos, self, self.renderItemUI)

    -- scrollview的渲染方式
    local fixData = { }
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

function ActivityOnePanel:renderItemUI(item, data, index)
	
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

	local btn = item:getChildByName("getBtn")
	btn:setVisible(data.iscanget ~= 0)
	local key = "1800" .. data.iscanget		
	local text = TextWords:getTextWord(tonumber(key))
	btn:setTitleText(text)
	btn.data = data

	if data.iscanget > 2 then
		NodeUtils:setEnable(btn, false)
	else
		NodeUtils:setEnable(btn, true)
		self:addTouchEventListener(btn, self.btnTouch)
	end
end

function ActivityOnePanel:btnTouch(sender)
	local btnData = sender.data

	-- if self.rankData == nil then
	-- 		logger:error("self.rankData是nil，缺少请求所需数据")
	-- 		return
	-- 	end

	if  btnData.iscanget==2 then
		local function confirmCallback()
			local mainpanel = self:getPanel(GameActivityPanel.NAME)
			mainpanel:commonMethod(self._activityId, btnData.effectId, btnData.sort, false, true)
	    end
		--购买二次确认
        local tipStr = string.format(TextWords:getTextWord(18015), data.disprice[1].num)
        local messageBox = self:showMessageBox( tipStr, confirmCallback)
        messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)

	else
		local mainpanel = self:getPanel(GameActivityPanel.NAME)
		mainpanel:commonMethod(self._activityId, btnData.effectId, btnData.sort, false, false)
	end
end

function ActivityOnePanel:jumpToStart(jumpIndex)
	self._scrollViewJumpIndex = jumpIndex
end