
ActivitySecondPanel = class("ActivitySecondPanel", BasicPanel)
ActivitySecondPanel.NAME = "ActivitySecondPanel"

function ActivitySecondPanel:ctor(view, panelName)
    ActivitySecondPanel.super.ctor(self, view, panelName)
    -- ActivityCenterPanel.super.ctor(self, view, panelName,100)
    self:setUseNewPanelBg(true)
	self._isInShowAction = true
	self._isInHideAction = true -- 控制判断

end

function ActivitySecondPanel:finalize()
	-- if self.infoPanel ~= nil then
	-- 	self.infoPanel:finalize()
	-- 	self.infoPanel = nil
	-- end

	local skin = self:getSkin()
    if skin ~= nil then
        skin:setOpacity(0)
    end

    ActivitySecondPanel.super.finalize(self)
end

function ActivitySecondPanel:initPanel()
	ActivitySecondPanel.super.initPanel(self)

	self._redPointProxy = self:getProxy(GameProxys.BattleActivity)
    -- self:updateData(data)
    self._sv = self:getChildByName("sv")
    
   
--    local item = self.listView:getItem(0)
--    self.listView:setItemModel(item)

    self._allModule = {
		[ActivityDefine.SERVER_ACTION_WORLD_BOSS] = ModuleName.WorldBossModule, --世界boss
		[ActivityDefine.SERVER_ACTION_LEGION_WAR] = ModuleName.WarlordsModule,     --军团战
        [ActivityDefine.SERVER_ACTION_PROVINCIAL_EXAM] = ModuleName.ProvincialExamModule, --乡试科举
		[ActivityDefine.SERVER_ACTION_PALACE_EXAM] = ModuleName.PalaceExamModule, --殿试科举
		[ActivityDefine.SERVER_ACTION_LORDCITY_BATTLE] = ModuleName.LordCityModule, --城主争夺战
        [ActivityDefine.SERVER_ACTION_REBELS] = ModuleName.RebelsModule, --消灭叛军
        [ActivityDefine.SERVER_ACTION_EMPEROR_CITY] = ModuleName.EmperorCityModule, --皇城战
	}

end

function ActivitySecondPanel:registerEvents()
	ActivitySecondPanel.super.registerEvents(self)
end

function ActivitySecondPanel:onClosePanelHandler()
    self:dispatchEvent(ActivityCenterEvent.HIDE_SELF_EVENT)
end

function ActivitySecondPanel:onShowHandler()
	self:updateInfo()
end

-----------------------------------------------------------------------------
--下面函数照抄UIBattleActivityPanel
-----------------------------------------------------------------------------

function ActivitySecondPanel:updateInfo()  --刷新listview数据
    local proxy = self:getProxy(GameProxys.BattleActivity)
	local data = proxy:getActivityInfo()

	self:renderScrollView(self._sv, "panelItem", data, self, self.renderItem, nil, 6)
end

function ActivitySecondPanel:renderItem(item, data, index)

    -- 标签背景图
    local url = string.format("bg/limitActivity/%d.pvr.ccz", data.icon)
    local imgMovBg = item:getChildByName("imgMovBg")
    TextureManager:updateImageViewFile(imgMovBg, url)

    -- 活动描述
    local txtDesc = item:getChildByName("txtDesc")
    txtDesc:setString(data.info)

    -- 黑幕遮罩
    local panelMask = item:getChildByName("panelMask")
    panelMask:setVisible(data.state == BattleActivityProxy.ActivityState_Disable)

    -- 活动状态
    local imgState = item:getChildByName("imgState")
    if data.state == BattleActivityProxy.ActivityState_Disable then
        TextureManager:updateImageView(imgState, "images/activityCenter/NotOpen.png")

    elseif data.state == BattleActivityProxy.ActivityState_Open then
        TextureManager:updateImageView(imgState, "images/activityCenter/StateOpen.png")

    elseif data.state == BattleActivityProxy.ActivityState_Close then 
        TextureManager:updateImageView(imgState, "images/activityCenter/StateReady.png")

    end

    -- 活动开启动画
    local isShow = data.state == BattleActivityProxy.ActivityState_Open
    if isShow == true then
        local itemSize = item:getContentSize()
        if item.ccb1 == nil then
            item.ccb1 = self:createUICCBLayer("rgb-xshd-wkq", item)
            item.ccb1:setLocalZOrder(100)
            item.ccb1:setPositionX(itemSize.width / 2)
            item.ccb1:setPositionY(itemSize.height / 2)
        end

        if item.ccb2 == nil then
            item.ccb2 = self:createUICCBLayer("rgb-xshd-jxz", item)
            item.ccb2:setLocalZOrder(101)
            item.ccb2:setPositionX(itemSize.width / 2)
            item.ccb2:setPositionY(itemSize.height / 2)
        end
    end
    if item.ccb1 then
        item.ccb1:setVisible(isShow == true)
    end
    if item.ccb2 then
        item.ccb2:setVisible(isShow == true)
    end

    -- 红点推送
    local redData = self._redPointProxy:getRedPointInfo()
    local redImg = item:getChildByName("redImg")
    redImg:setLocalZOrder(102)
    local numLab = redImg:getChildByName("numLab")
    if redData == nil then
        redImg:setVisible(false)
    else
        local num = redData[data.activityId] or 0
        numLab:setString(num)
        redImg:setVisible(num ~= 0)
    end

    item.data = data
    ComponentUtils:addTouchEventListener(item, self.onBtnTouch, nil, self)
end




function ActivitySecondPanel:onBtnTouch(sender)
	local battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
	local data = sender.data
	local proxy = self:getProxy(GameProxys.Role)
    
    -- 点击弹屏蔽提示
    if data.state == 2 then
        self:showSysMessage(self:getTextWord(370101)) -- "功能暂未开启"
        return
    end 


	if data.activityType == ActivityDefine.SERVER_ACTION_LEGION_WAR then
		local id = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
		if id <= 0 then
			proxy:showSysMessage(TextWords:getTextWord(280139))
			return
		else
			battleActivityProxy:onTriggerNet330000Req({activityId = 2})  --百团大战写死
		end
	end

	local moduleName = self._allModule[data.activityType]
	moduleName = moduleName or ModuleName.WorldBossModule
	
	-- 城主战校验等级解锁状态
	if moduleName == ModuleName.LordCityModule then
		local rolePrxoy = self:getProxy(GameProxys.Role)
		if rolePrxoy:isFunctionUnLock(57,true) == false then
		    return
		end		
	end

	proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName, extraMsg = data})

	battleActivityProxy:setCurActivityID(data.activityId)

end

function ActivitySecondPanel:onOpenwarlords()    
	local systemProxy = self:getProxy(GameProxys.System)
	systemProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.WarlordsModule})
end
