

ActivitySixPanel = class("ActivitySixPanel", BasicPanel)
ActivitySixPanel.NAME = "ActivitySixPanel"

function ActivitySixPanel:ctor(view, panelName)
    ActivitySixPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ActivitySixPanel:finalize()
    ActivitySixPanel.super.finalize(self)
end

function ActivitySixPanel:initPanel()
	ActivitySixPanel.super.initPanel(self)

	self._proxy = self:getProxy(GameProxys.Activity)

	--self._listview = self:getChildByName("Panel_bg/rightLv3")

    self._scrollView = self:getChildByName("Panel_bg/rightSV3")

    self._scrollViewJumpIndex = 1
end

function ActivitySixPanel:registerEvents()
	ActivitySixPanel.super.registerEvents(self)
end

function ActivitySixPanel:doLayout()
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

function ActivitySixPanel:onShowHandler(data)
	-- self._listview:jumpToTop()
	self._activityId = data.activityId
	self._MainPanel = self:getPanel(GameActivityPanel.NAME)
	table.sort(data.effectInfos,function (a,b) return a.sort < b.sort end )
	--self:renderListView(self._listview, data.effectInfos, self, self.renderMethod)


    -- self:renderScrollView(self._scrollView, "itemPanel3", data.effectInfos, self, self.renderMethod, self._scrollViewJumpIndex)
    self:renderScrollView(self._scrollView, "itemPanel3", data.effectInfos, self, self.renderMethod, nil)

end

function ActivitySixPanel:renderMethod(item, data)
    logger:info("sort "..data.sort)
	local buyBtn = item:getChildByName("Button_47")
	local count = item:getChildByName("count")

	buyBtn.data = data
    self:addTouchEventListener(buyBtn, self.btnTouch)
    logger:info("limit "..data.limit.." totalLimit.. "..data.totalLimit)
    count:setString(string.format(TextWords:getTextWord(1333),data.limit,data.totalLimit))                          --TextWords 1333
    NodeUtils:setEnable(buyBtn, true)
    if data.limit == data.totalLimit then
        NodeUtils:setEnable(buyBtn, false)
    end

    local left = item:getChildByName("left")
    local right = item:getChildByName("right")

    local disprice = data.disprice[1]

    local dispriceData = {}
    dispriceData.power =disprice.power
    dispriceData.typeid = disprice.typeId
    dispriceData.num = disprice.num
        
    --logger:info("显示当前 兑换道具的数量 "..dispriceData.num.."  power "..dispriceData.power.."  typeid "..dispriceData.typeid)
    if left._disprice == nil then
        
       left._disprice =UIIcon.new(left,dispriceData,true,self,nil,true)
    else
        left._disprice:updateData(dispriceData)
    end

	local rewards =data.rewards[1]
    if right._rewardIcon == nil then
        right._rewardIcon =  UIIcon.new(right, rewards, true, self, nil, true)
    else
        right._rewardIcon:updateData(rewards)
    end


end

function ActivitySixPanel:btnTouch(sender)
	local data = sender.data
	if rawget(data,"jumpbutton") ~= nil and rawget(data,"jumpbutton") ~= "" then  --跳转模块
		local jumpData = {}
		self._MainPanel:commonJumpMethod({jump = data.jumpbutton, jumpPanel = data.jumpmodule})
	elseif data.iscanget == 1 or data.iscanget == 2 then
		--local function confirmCallback()
			self._MainPanel:commonMethod(self._activityId, data.effectId, data.sort, false, true)
	    --end
		----购买二次确认
  --      local tipStr = string.format(TextWords:getTextWord(18015), data.disprice[1].num)
  --      local messageBox = self:showMessageBox( tipStr, confirmCallback)
  --      messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	end
end

function ActivitySixPanel:jumpToStart(jumpIndex)
	self._scrollViewJumpIndex = jumpIndex
end