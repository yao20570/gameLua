ActivityFirstPanel = class("ActivityFirstPanel", BasicPanel)
ActivityFirstPanel.NAME = "ActivityFirstPanel"

function ActivityFirstPanel:ctor(view, panelName)
    ActivityFirstPanel.super.ctor(self, view, panelName)
    self:setUseNewPanelBg(true)
    self.isCheckFunction = false
end

function ActivityFirstPanel:finalize()
    ActivityFirstPanel.super.finalize(self)
end

function ActivityFirstPanel:initPanel()
	ActivityFirstPanel.super.initPanel(self)
	self._sv = self:getChildByName("sv")


end

function ActivityFirstPanel:doLayout()
	-- self:adaptiveList( self._listView )
end

function ActivityFirstPanel:adaptiveList( ListView )
	-- body
	local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(ListView,GlobalConfig.downHeight, tabsPanel)
end

function ActivityFirstPanel:registerEvents()
	ActivityFirstPanel.super.registerEvents(self)
end

function ActivityFirstPanel:onClosePanelHandler()
    self:dispatchEvent(ActivityCenterEvent.HIDE_SELF_EVENT)
end

function ActivityFirstPanel:onShowHandler()

	local parent = self:getParent()
	if parent.infoPanel ~= nil then
		parent.infoPanel:hide()
	end

	local panel = self:getPanel(ActivityCenterPanel.NAME)
	panel:updateRedPoint()

	self:updateInfo()
end

function ActivityFirstPanel:updateInfo(isRemove)
	if self._sv ~= nil then
		local activityProxy = self:getProxy(GameProxys.Activity)
		local data = activityProxy:getLimitActivityInfo()
		self:renderScrollView(self._sv, "panelItem", data, self, self.renderItemPanel, nil, 6)
	end
end

function ActivityFirstPanel:renderItemPanel(item, data, index)

    local Label_name = item:getChildByName("Label_name")
    local Label_desc = item:getChildByName("Label_desc")
    local imgMovBg = item:getChildByName("imgMovBg")
    local endImg = item:getChildByName("endImg")

    Label_name:setString(data.name)

    -- //null
    local number = data.bgIcon
    if number == 24 then
        number = 9999
    end
    local url = string.format("bg/limitActivity/%d.pvr.ccz", number)
    TextureManager:updateImageViewFile(imgMovBg, url)

    -- 小红点
    local redIconImg = item:getChildByName("redIconImg")
    redIconImg:setVisible(false)
    local redPoint = self:getProxy(GameProxys.RedPoint)
    local redNum = redPoint:getRedPointById(data.activityId)
    local numLab = redIconImg:getChildByName("numLab")
    redIconImg:setVisible(redNum ~= 0)
    numLab:setString(redNum)

    local startTime = TimeUtils:setTimestampToString(data.startTime)
    local endTime = TimeUtils:setTimestampToString(data.endTime)
    Label_desc:setString(startTime .. " - " .. endTime)
    item.data = data

    self:addTouchEventListener(item, self.onCallItemTouch)

    -- 活动过期显示优化
    endImg:setVisible(GameConfig.serverTime >= data.endTime)

end

function ActivityFirstPanel:onCallItemTouch(sender)
    -- 跳转函数
	local function onOpenActivityModule()
		local activityData = sender.data
		local activityProxy = self:getProxy(GameProxys.Activity)
		activityProxy:onOpenActivityModule( activityData )
		-- print( "activityId:", sender.data.activityId, "uitype:", sender.data.uitype)

--        -- 关闭限时活动模块
--        local function closeModule()
--            self.view:dispatchEvent(ActivityCenterEvent.HIDE_SELF_EVENT)
--        end

--        TimerManager:addOnce(500, closeModule, self)
	end

	--同盟致富活动特殊判断,玩家是否已经进入同盟
	if sender.data.uitype == ActivityDefine.LIMIT_LEGIONRICH_ID then
		local norNeed = ConfigDataManager:getConfigById(ConfigData.NewFunctionOpenConfig,7).need
    	local roleProxy = self:getProxy(GameProxys.Role)
        local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
        local function okcallbk() -- 前往加同盟
        	local canGo = roleProxy:isFunctionUnLock(7,true)
        	if canGo == true then
        		self:dispatchEvent(MainSceneEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.LegionApplyModule})
        	end
        end
        
		if legionId < 1 then
        	self:showMessageBox(self:getTextWord(394005), okcallbk) 
        else
        	onOpenActivityModule()
        end
    else
    	onOpenActivityModule()
	end

end
