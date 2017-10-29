--------created by zhangfan in 2016-08-09
--------战斗活动的入口通用面板
UIBattleActivityPanel = class("UIBattleActivityPanel", BasicComponent) 

function UIBattleActivityPanel:ctor(parent, data, tabsPanel, redPoint)
	UIBattleActivityPanel.super.ctor(self)
	self._redPoint = redPoint
	tabsPanel = tabsPanel or GlobalConfig.tabsMaxHeight
    self.tabsPanel = tabsPanel
    local function initPanel(skin)
    	self._uiSkin = skin
    	self:initPanel(data)
    end

    local function doLayout(skin)
    	self._uiSkin = skin
    	self:doLayout()
    end

    self._parent = parent
    local uiSkin = UISkin.new("UIBattleActivityPanel", initPanel, doLayout)
    uiSkin:setParent(parent)
    self._uiSkin = uiSkin
    
end

function UIBattleActivityPanel:initPanel(data)
	self._redPointProxy = self._parent:getProxy(GameProxys.BattleActivity)
    self:updateData(data)
    self.listView = self._uiSkin:getChildByName("ListView")
    
   
    local item = self.listView:getItem(0)
    self.listView:setItemModel(item)

    self._allModule = {
		[ActivityDefine.SERVER_ACTION_WORLD_BOSS] = ModuleName.WorldBossModule, --世界boss
		[ActivityDefine.SERVER_ACTION_LEGION_WAR] = ModuleName.WarlordsModule,     --军团战
        [ActivityDefine.SERVER_ACTION_PROVINCIAL_EXAM] = ModuleName.ProvincialExamModule, --乡试科举
		[ActivityDefine.SERVER_ACTION_PALACE_EXAM] = ModuleName.PalaceExamModule, --殿试科举
		[ActivityDefine.SERVER_ACTION_LORDCITY_BATTLE] = ModuleName.LordCityModule, --城主争夺战
        [ActivityDefine.SERVER_ACTION_REBELS] = ModuleName.RebelsModule, --消灭叛军
        [ActivityDefine.SERVER_ACTION_EMPEROR_CITY] = ModuleName.EmperorCityModule, --消灭叛军
	}

	self._systemProxy = self._parent:getProxy(GameProxys.System)
	
	self:registerProxyEvents()
end

function UIBattleActivityPanel:doLayout()
	 NodeUtils:adaptiveListView(self.listView, GlobalConfig.downHeight, self.tabsPanel)
end

function UIBattleActivityPanel:registerProxyEvents()
	self._systemProxy:addEventListener(AppEvent.PROXY_OPENWARLORDS, self, self.onOpenwarlords)
end
function UIBattleActivityPanel:removeProxyEvents()
	self._systemProxy:removeEventListener(AppEvent.PROXY_OPENWARLORDS, self, self.onOpenwarlords)
end

function UIBattleActivityPanel:finalize()
	
	self:removeProxyEvents()
	self._uiSkin:finalize()
	UIBattleActivityPanel.super.finalize(self)
end

function UIBattleActivityPanel:updateData(data)  --刷新listview数据
	self._uiSkin:setVisible(true)
	local listView = self._uiSkin:getChildByName("ListView")

	self:renderListView(listView, data, self, self.renderItem)
end

function UIBattleActivityPanel:renderItem(item, data, index)
	local img = item:getChildByName("Image_icon")--活动图标
	local iconImg = img:getChildByName("icon")--活动图标
	local Label_name = item:getChildByName("Label_name")--活动名字
	local Label_desc = item:getChildByName("Label_desc")--开启时间
	local tipsBtn = item:getChildByName("Button_buy") -- 暂时无用，
    tipsBtn:setVisible(false)
	local Label_open = item:getChildByName("Label_open")--活动状态提示

	local redData = self._redPointProxy:getRedPointInfo()
	local redImg = item:getChildByName("redImg")
	local numLab = redImg:getChildByName("numLab")
	if not self._redPoint then
		redImg:setVisible(false)
	else
		local num = redData[data.activityId] or 0
		numLab:setString(num)
		redImg:setVisible(num ~= 0)
	end



	Label_name:setString(data.name)
	local state = data.state == 0 and TextWords:getTextWord(280137) or TextWords:getTextWord(280138)
    -- 设置颜色
    if data.state == 0 then
        Label_open:setColor(ColorUtils.commonColor.c3bRed)--cc.c3b(255, 18, 18))
    else
        Label_open:setColor(ColorUtils.commonColor.c3bGreen)--cc.c3b(37, 239, 60))
    end

	Label_open:setString(state)
	Label_desc:setString(data.info)
    -- 活动图标设置
    local url = "bg/activity/"..data.icon .. TextureManager.bg_type
    TextureManager:updateImageViewFile(iconImg, url)

	tipsBtn.data = data
	item.data = data
	--ComponentUtils:addTouchEventListener(tipsBtn, self.onBtnTouch, nil, self)
	ComponentUtils:addTouchEventListener(item, self.onBtnTouch, nil, self)

	-- 名字和开启状态左对齐
	local size = Label_name:getContentSize()
	Label_open:setPositionX(Label_name:getPositionX() + size.width + 20)

end

function UIBattleActivityPanel:registerEvents()
end

function UIBattleActivityPanel:onBtnTouch(sender)
	local battleActivityProxy = self._parent:getProxy(GameProxys.BattleActivity)
	local data = sender.data
	local proxy = self._parent:getProxy(GameProxys.Role)

	if data.activityType == ActivityDefine.SERVER_ACTION_LEGION_WAR then
		local id = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
		if id <= 0 then
			proxy:showSysMessage(TextWords:getTextWord(280139))
			return
		else
			battleActivityProxy:onTriggerNet330000Req({activityId = 2})  --百团大战写死
			return
		end
	end
	local moduleName = self._allModule[data.activityType]
	moduleName = moduleName or ModuleName.WorldBossModule
	proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName, extraMsg = data})
	
	battleActivityProxy:setCurActivityID(data.activityId)
end

function UIBattleActivityPanel:hide()
	self._uiSkin:setVisible(false)
end

function UIBattleActivityPanel:onOpenwarlords()
	self._systemProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.WarlordsModule})
end