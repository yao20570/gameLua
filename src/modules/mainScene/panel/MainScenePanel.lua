
MainScenePanel = class("MainScenePanel", BasicPanel)
MainScenePanel.NAME = "MainScenePanel"


MainScenePanel.WeatherState = {
    NotInit = 0,--未初始化
    TryCreate = 1,--定时器创建

    ToRaining = 2; --需要下雨
    Raining = 3, --下雨中 
    StoppingRain = 4; --停雨中
    StopRain = 5,--停雨




    ToSunShine = 6;--需要太阳
    SunShinning = 7;--出太阳中
    -- StopSunShinning = 8; -- 关闭太阳ing
    StopSun = 9, --停太阳



    normal = 999, -- 正常状态
}

function MainScenePanel:ctor(view, panelName)
    MainScenePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function MainScenePanel:finalize()

    for key,val in pairs(self._effectContainer) do
        val:finalize()
    end
    self._effectContainer = nil

    MainScenePanel.super.finalize(self)
end

function MainScenePanel:initPanel()
	MainScenePanel.super.initPanel(self)
    self._countDownMap = {}   --正在升级的建筑队列
    self._countDownProductMap = {} --建筑生产队列map
    self._defaultBuildingPanel = self:getChildByName("fieldBuildingPanel")
    self._mainPanel = self:getChildByName("mainPanel")
    -- self._defFieldEffectPanel = self:getChildByName("effectPanel")

    self._defaultBuildingPanel:setVisible(false)
    self._mainPanel:setVisible(false)

    self:setEnabled(false)

    self._sceneWidgetList = {}
    self._sceneBuildingPanelMap = {} --基地建筑面板Map
    self._fieldBuildingPanelMap = {} --野外建筑面板Map
    self._fieldEffectsMap = {}       --资源建筑特效(用于随机播放特效)
    self._lockFlag = false
    self._weatherState = MainScenePanel.WeatherState.NotInit --云雨特效状态值

    local sceneMap = MainSceneMap.new(self)
    self:addChildToView(sceneMap)
    self._sceneMap = sceneMap

    self._effectContainer = {} --存放所有特效,finalize的时候一起释放

	self:initAllBuilding()

	self:initFieldBuilding()


	self:setAllBuildingNameVisible(true)

    local dty = self._sceneMap:getDtSceneY()
    local soldierPanel = self:getChildByName("soldierPanel")
    local y = soldierPanel:getPositionY()
    soldierPanel:setPositionY(y + dty)
    local children = soldierPanel:getChildren()
    for _, panel in pairs(children) do
        panel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
        panel:setTouchEnabled(false)
        panel:setVisible(false)
        local touchPanel = panel:getChildByName("touchPanel")
        if touchPanel ~= nil then
            touchPanel.touchWidget = panel
            touchPanel:setTouchEnabled(false)
            touchPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
        end
    end

    soldierPanel:retain()
    soldierPanel:removeFromParent()
    soldierPanel:release()
    self._sceneMap:addChildToMap(soldierPanel)

    soldierPanel:setLocalZOrder(100)
    self._soldierPanel = soldierPanel

    --self:onUpdateSoldiers()
    -- self:createOrUpdatePatrouille()
    -- self:createOrUpdateWater()
    -- self:createOrUpdateBird()
    -- self:loopRandomFieldEffects()

    self._allSoldierPanelMap = {}
    self._allSoldierChipMap = {}
    self._birdChipMap = {}
    self._birdPanel = {}
    self._waterChipMap = {}
    self._roleProxy = self:getProxy(GameProxys.Role)
    self:onInitChipPanels()

    self._sceneMap:onEffectMove(self.callback, self)
end

function MainScenePanel:playAnimation( ... )
    -- body
    self:playAction("Animation0", nil)
end

function MainScenePanel:callback()
    -- body
    local x,y = self._sceneMap:getPosition()
    local mx,my = self._sceneMap:getMapSize()
    -- self:sendNotification(AppEvent.SCENEMAP_MOVE_UPDATE, {x,y})
    self:dispatchEvent(MainSceneEvent.MOVESCENE_SEND, {x,y,mx,my})
end


function MainScenePanel:enterSceneAction()
    self._sceneMap:runEnterAction(GlobalConfig.centerPos)

end

function MainScenePanel:changeSceneActionIn()
    self._sceneMap._rootNode:setScale(0.3)--
    --self._sceneMap._rootNode:runAction(cc.ScaleTo:create(0.7, GlobalConfig.toScale))
    self._sceneMap:runEnterAction(GlobalConfig.centerPos)
    --self._sceneMap:runEnterAction(nil, 0.5, 1, 0.7)

end

function MainScenePanel:changeSceneActionOut()
    --local function callback()
    --    self.hide()
    --end
    --self._sceneMap:runAction(cc.Sequence:create(cc.ScaleTo:create(0.7, 0.5), cc.CallFunc:create(callback)))
    --self._sceneMap._rootNode:runAction(cc.ScaleTo:create(0.7, 0.3))
    self._sceneMap:runEnterAction(GlobalConfig.centerPos, 1, GlobalConfig.toScale, 0.7)

end

function MainScenePanel:onStopSoldierChip()  --停止主城巡逻动画
    -- logger:error("停止主城巡逻兵动画")
    -- print("停止主城巡逻兵动画")
    for _,v in pairs(self._allSoldierChipMap) do
        v:finalize()
    end
    self._allSoldierChipMap = {}
end

function MainScenePanel:onStopWaterChip()  --停止流水动画
    -- logger:error("停止流水动画")
    -- print("停止流水动画")
    for _,v in pairs(self._waterChipMap) do
        v:finalize()
    end
    self._waterChipMap = {}
end

function MainScenePanel:onStopBridWaterChip()  --停止小鸟动画
    -- logger:error("停止主城小鸟动画")
    -- print("停止主城小鸟动画")
    for _,v in pairs(self._birdChipMap) do
        v:finalize()
    end
    self._birdChipMap = {}
    self._isPlayNowBird = nil

    for _,v in pairs(self._birdPanel) do
        v:removeFromParent()
    end
    self._birdPanel = {}
end

function MainScenePanel:onHideHandler()
    local name = self._roleProxy:getRoleName()
    if name == "" or GameConfig.isNewPlayer == true then
    else
        self:onStopSoldierChip()
        self:onStopWaterChip()
        self:onStopBridWaterChip()
    end
    self._sceneMap:setVisible(false)
end

function MainScenePanel:onShowHandler()
    self._sceneMap:setVisible(true)
    --local name = self._roleProxy:getRoleName()   --新手阶段         
    --if name == "" or GameConfig.isNewPlayer == true then
    --    return
    --end

    -- start-----------------------------------------------------------------------------------
    -- 正在升级的建筑
    local buildingProxy = self:getProxy(GameProxys.Building)
    local upGradeMap = buildingProxy:getBuildingUpGradeList()
    local list = {}
    for _, data in pairs(self._countDownMap) do
        local buildingIndex = data.buildingIndex
        local buildingType = data.buildingType
        local buildingInfo = buildingProxy:getBuildingInfo(buildingType, buildingIndex)
        self:updateBuildingInfo(buildingInfo)
        -- logger:info("打开主城 MainScenePanel:onShowHandler()  正在升级的建筑队列")
    end
    -- stop-----------------------------------------------------------------------------------


    -- -- start-----------------------------------------------------------------------------------
    -- -- 渲染一遍新建造的建筑，
    -- local delList = {}
    -- local newBuildingMap = buildingProxy:getNewBuildingMap()
    -- for _, data in pairs(newBuildingMap) do
    --     local buildingType = data.buildingType
    --     local buildingIndex = data.index
    --     -- logger:info("打开主城 MainScenePanel:onShowHandler()  新创建的建筑  0 buildingType, buildingIndex=%d %d", buildingType, buildingIndex)
    --     local buildingInfo = buildingProxy:getBuildingInfo(buildingType, buildingIndex)
    --     if buildingInfo ~= nil then
    --         self:updateBuildingInfo(buildingInfo)
    --         table.insert(delList, data)
    --     end
    -- end
    -- -- 渲染完，删除该条建筑数据
    -- for _,delData in pairs(delList) do
    --     buildingProxy:updateNewBuildingInfo(delData.buildingType,delData.index,nil)
    -- end
    -- -- stop-----------------------------------------------------------------------------------

    -- start-----------------------------------------------------------------------------------
    -- 渲染一遍隐藏的建筑信息
    local delList = {}
    local newBuildingMap = buildingProxy:getHideUpdateBuildList()
    for _, data in pairs(newBuildingMap) do
        local buildingType = data.buildingType
        local buildingIndex = data.index
        -- logger:info("打开主城 MainScenePanel:onShowHandler()  隐藏的建筑  0 buildingType, buildingIndex=%d %d", buildingType, buildingIndex)
        local buildingInfo = buildingProxy:getBuildingInfo(buildingType, buildingIndex)
        if buildingInfo ~= nil then
            self:updateBuildingInfo(buildingInfo)
            table.insert(delList, data)
        end
    end
    -- 渲染完，删除该条建筑数据
    for _,delData in pairs(delList) do
        buildingProxy:setHideUpdateBuildInfo(delData.buildingType,delData.index,nil)
    end
    -- stop-----------------------------------------------------------------------------------


    --在刷一遍现在正在升级的建筑，比如打开官邸升级的时候，该界面被关闭了
    --可进一步进行优化
    local list = buildingProxy:getBuildingUpGradeList()
    for _, data in pairs(list) do
        local buildingIndex = data.buildingIndex
        local buildingType = data.buildingType
        local buildingInfo = buildingProxy:getBuildingInfo(buildingType, buildingIndex)
        self:updateBuildingInfo(buildingInfo)
        -- logger:info("打开主城 MainScenePanel:onShowHandler()  正在升级的建筑  0")
    end

    local list = self.view:getHideUpdateBuildList() or {}
    for _, data in pairs(list) do
        local buildingIndex = data.buildingIndex
        local buildingType = data.buildingType
        local buildingInfo = buildingProxy:getBuildingInfo(buildingType, buildingIndex)
        self:updateBuildingInfo(buildingInfo)
        -- logger:info("打开主城 MainScenePanel:onShowHandler()  正在升级的建筑  1")
    end
    self.view:clearHideUpdateBuildMap()

    -- 每次打开都刷一下建筑生产数据 add by fzw ---------------------------------star
    for _, data in pairs(self._countDownProductMap) do
        local buildingIndex = data.buildingIndex
        local buildingType = data.buildingType
        local buildingInfo = buildingProxy:getBuildingInfo(buildingType, buildingIndex)
        data.productionInfos = buildingInfo.productionInfos
    end
    -- 每次打开都刷一下建筑生产数据 add by fzw ---------------------------------end


    -- 每次打开都刷新以下的信息显示
    if self._legionNameImg ~= nil and self._legionLevelTxt ~= nil then
        self:updateLegionBuildingInfo()
        -- 军团建筑感叹号
        self:updateMarkTip(ModuleName.LegionSceneModule)
        -- 军械建筑感叹号
        self:updateMarkTip(ModuleName.PartsModule)
        -- 军师建筑感叹号
        self:updateMarkTip(ModuleName.ConsigliereModule)
    end

    self:update()
    self:onUpdateSoldiers()

    self:createOrUpdateLowEffect()
    self:createOrUpdatePatrouille()
    self:createOrUpdateWater()
    self:createOrUpdateTopEffect()
    self:createOrUpdateBird()
    -- self:createOrUpdateFixEffect()--固定在屏幕上的特效
    self:createOrUpdateWeather()--创建天气:雨 阳光

end
-- 建筑更新接口
function MainScenePanel:updateBuildingInfo(buildingInfo)
    if buildingInfo == nil then
        logger:info("buildingInfo is nil !")
        return
    end
    -- logger:info("主城 更新建筑信息 00")
    local buildingType = buildingInfo.buildingType
    local buildingProxy = self:getProxy(GameProxys.Building)
    local isFieldBuilding = buildingProxy:isFieldBuilding(buildingType)
    if isFieldBuilding == true then
        self:updateFieldBuilding(buildingInfo)
    else
        self:updateSceneBuilding(buildingInfo)
    end
end

----------------------------

--------------初始化基地建筑---
function MainScenePanel:initAllBuilding()
    local mainPanel = self._mainPanel

    local children = mainPanel:getChildren()

    local index = 1
    for _, child in pairs(children) do
    	local name = child:getName()
        if string.find(name, "buildingPanel") ~= nil then

            local function initSceneBuilding()
                self:initSceneBuilding(child)
            end
            --30->17  7727 登录游戏时出现卡进度条现象，无法进入游戏 怀疑太晚创建tip精灵,导致的
            TimerManager:addOnce(17 * index, initSceneBuilding, self)

            index = index + 1
--            self:initSceneBuilding(child)
        end
    end

end

function MainScenePanel:initSceneBuilding(buildingPosPanel, touchPanel)
    local posKey = buildingPosPanel:getName()
    local keyname = string.gsub(posKey, "buildingPanel", "")
    local nameAry = StringUtils:splitString(keyname, "_")
    local buildingType = tonumber(nameAry[1])
    local buildingIndex = tonumber(nameAry[2])

    local info = ConfigDataManager:getInfoFindByTwoKey(ConfigData.BuildOpenConfig, "ID", buildingIndex, "type", buildingType)
    if info == nil then
        return
    end

    local buildingPanel = self[posKey]
    if buildingPanel == nil then
        buildingPanel = self:createBuilding(posKey, buildingType, buildingIndex)
    end

    buildingPanel.info = info
    self._sceneBuildingPanelMap[info.ID] = buildingPanel

    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getBuildingInfo(buildingType, buildingIndex)

    if buildingInfo == nil then
        -- logger:error("========buildingType:%d======buildingIndex:%d========", buildingType, buildingIndex)
        return
    end
    self:renderBuildingPanel(buildingPanel, buildingInfo)

end

function MainScenePanel:updateSceneBuilding(buildingInfo)
    local index = buildingInfo.index
    local buildingPanel = self._sceneBuildingPanelMap[index]
    self:renderBuildingPanel(buildingPanel, buildingInfo)
end

function MainScenePanel:renderBuildingPanel(buildingPanel, buildingInfo)
    if buildingPanel == nil then
        return
    end
    local info = buildingPanel.info

    self:renderBuildingCommonInfo(buildingPanel,buildingInfo)

    local buildingBtn = buildingPanel:getChildByName("buildingBtn")
    buildingBtn.info = info

    if buildingBtn.isAddEvent == true then
        
        return
    end
    buildingBtn.isAddEvent = true

    local id = info.ID
    local type = info.type
    local touchPanel = buildingPanel.touchPanel
    touchPanel.info = info
    buildingPanel.info = info

    local function touchCallback(sender, eventType)
        self:onBuildingBtnTouch(sender, eventType)
    end
    buildingPanel.touchCallback = touchCallback
    touchPanel.touchCallback = touchCallback
    touchPanel.buildingPanel = buildingPanel


    if not self:isCanUse(info, info.type) then
        self:addSceneTouchEvent(touchPanel, self.onBuildingBtnTouch)
    end

end

-- 点击建筑的回调
function MainScenePanel:onBuildingBtnTouch(sender)
    local info = sender.info
    local data = {}

    data.buildingType = info.type
    data.buildingIndex = info.ID
    data.moduleName = info.moduleName

    -- 点击生产图标调整到对应的生产界面panel
    local isProductPanel = sender.isProductPanel
    if isProductPanel then
        local panelName = rawget(info,"productPanel")
        if panelName ~= nil and panelName ~= ' ' then
            data.panelName = panelName
        end
    end

    --start 屏蔽军师功能----------------------------------------------
    -- if data.buildingType == 15 then
    --     self:showSysMessage(self:getTextWord(821))
    --     return
    -- end
    --stop 屏蔽军师功能----------------------------------------------

    local buildingProxy = self:getProxy(GameProxys.Building)
    local isOpen = buildingProxy:isBuildingOpen(data.buildingType, data.buildingIndex)

    -- 国家系统功能的屏蔽根据服务端数据，特殊处理
    if isOpen == true and info.moduleName == "CountryModule" then
        if self:getProxy(GameProxys.Country):getIsOpen() == 0 then
            self:showSysMessage(self:getTextWord(821))
            isOpen = false
        end
    end

    -----------------------
    if isOpen == false then
        return
    end

    local roleProxy = self:getProxy(GameProxys.Role)

    --写死，直接打开升级面板
    if data.buildingType == 1 or data.buildingType == 7 then
        buildingProxy:setBuildingPos(data.buildingType, data.buildingIndex)
        local panel = self:getPanel(BuildingUpPanel.NAME)
        panel:show()
    elseif data.buildingType ==  BuildingTypeConfig.LEGIONHALL then
        local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
        local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        -- print("MainScenePanel:onBuildingBtnTouch(sender):legionId===",legionId)
        if legionId < 1 then
            data.moduleName = ModuleName.LegionApplyModule
        else
            self:showSysMessage(self:getTextWord(3024))
        end
        self:dispatchEvent(MainSceneEvent.SHOW_OTHER_EVENT, data)


--暂时屏蔽的功能 start---------------------------------------------------------------------------------------------
    -- elseif data.buildingType == BuildingTypeConfig.MILITARYROOM    --军师府（暂未开启）
    --     or data.buildingType == BuildingTypeConfig.ARMYBASE        --大军基地（暂未开启）
    --     or data.buildingType == BuildingTypeConfig.ARMYRULEROOM    --军制所（暂未开启）
    --     or data.buildingType == BuildingTypeConfig.ARMYTYPEROOM    --军工所（暂未开启）
    --     or data.buildingType == BuildingTypeConfig.EMPERORSTATUE   --皇帝雕像（暂未开启）
    --     then

    --     -- 暂未开启
    --     self:showSysMessage(self:getTextWord(821))
       -- local roleProxy = self:getProxy(GameProxys.Role)
       -- local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
       -- if level < 24 then
       --     self:showSysMessage(self:getTextWord(270009))
       --     return
       -- end
       -- data.moduleName = ModuleName.ConsigliereModule
       -- self:dispatchEvent(MainSceneEvent.SHOW_OTHER_EVENT, data)

    elseif self:isBuildingLocked(data.buildingType) == true then
        -- 暂未开启
        self:showSysMessage(self:getTextWord(821))
--暂时屏蔽的功能 end---------------------------------------------------------------------------------------------

    else
        self:dispatchEvent(MainSceneEvent.SHOW_OTHER_EVENT, data)
    end

end

function MainScenePanel:isBuildingLocked(buildingType)
    -- body
    for _,type in pairs(GlobalConfig.mainSceneBuildLocked) do
        if buildingType == type then
            return true
        end    
    end
    return false
end

--------------------建设空地逻辑-------------------------------
--初始化野外建筑
function MainScenePanel:initFieldBuilding()
    self._buildingPanelMap = {}

    local buildingProxy = self:getProxy(GameProxys.Building)
    local allBuildingInfo = buildingProxy:getAllOutdoorBuilding()

    local index = 1
    for _, buildingInfo in pairs(allBuildingInfo) do
--        self:updateFieldBuilding(buildingInfo)

        local function initSceneBuilding()
            self:updateFieldBuilding(buildingInfo)
        end

        TimerManager:addOnce(30 * index, initSceneBuilding, self)
        index = index + 1
    end
    
end

function MainScenePanel:updateFieldBuilding(buildingInfo)
    local buildingType = buildingInfo.buildingType
    local buildingIndex = buildingInfo.index
    local level = buildingInfo.level


    local buildingPanel = self._fieldBuildingPanelMap[buildingIndex]
    if buildingPanel == nil then
        local index = buildingInfo.index
        buildingPanel = self:createBuilding("buildingPos" .. index, buildingType, buildingIndex)
        self:updateFieldBuildingPos(buildingPanel)
        self._fieldBuildingPanelMap[index] = buildingPanel
        -- logger:info("一个空地将被创建..index=%d type=%d", index, buildingType)
    else
        self:updateBuildingPanel(buildingPanel,buildingType, buildingIndex)
    end

    local buildingBtn = buildingPanel:getChildByName("buildingBtn")

    --buildingType 为0时，表示为空地

    local name = ""

    if level == 0 then
        --print("============updateFieldBuilding===============", buildingType, buildingIndex, debug.traceback())
    end

    if buildingType ~= 0 then
        local info = ConfigDataManager:getInfoFindByTwoKey(ConfigData.BuildResourceConfig, "type", buildingType, "lv",level)
        name = info.name
        buildingBtn.info = info
        buildingBtn.emptyInfo = nil --空地建筑信息
        buildingPanel.info = info
    else
        buildingBtn.info = nil --表示是空地，可以建筑
        buildingPanel.info = nil
        --空地建筑信息
        local emptyInfo = ConfigDataManager:getConfigById(ConfigData.BuildBlankConfig,buildingIndex)
        buildingBtn.emptyInfo = emptyInfo
    end

    buildingBtn:setScale(1)
    buildingBtn.buildingInfo = buildingInfo

    self:renderBuildingCommonInfo(buildingPanel,buildingInfo)


    
    self:setBuildingNameVisible(buildingPanel, false, true) --隐藏资源建筑标题
    
    -- if buildingBtn.isAddEvent == true then
    --     return
    -- end

    buildingBtn.isAddEvent = true
    local touchPanel = buildingPanel.touchPanel
    touchPanel.buildingPanel = buildingPanel
    touchPanel:setVisible(false)
    touchPanel.buildingInfo = buildingInfo
    buildingPanel.buildingInfo = buildingInfo
    buildingPanel.info = buildingBtn.info
    buildingPanel.emptyInfo = buildingBtn.emptyInfo
    local function touchCallback(sender)
        self:onBuildingPanelTouch(sender)
    end
    buildingPanel.touchCallback = touchCallback
    self:addSceneTouchEvent(touchPanel, self.onBuildingPanelTouch)

    self["buildingPos" .. buildingIndex] = buildingPanel  --小助手引导用到
end

function MainScenePanel:onBuildingPanelTouch(sender)
    local info = sender.info
    local emptyInfo = sender.emptyInfo
    local buildingInfo = sender.buildingInfo

    if emptyInfo ~= nil then  --空地，可建筑
        local panel = self:getPanel(BuildingCreatePanel.NAME)
        panel:show(emptyInfo)
    elseif info ~= nil then --升级建筑

        local buildingProxy = self:getProxy(GameProxys.Building)
        buildingProxy:setBuildingPos(buildingInfo.buildingType, buildingInfo.index)

        local panel = self:getPanel(BuildingUpPanel.NAME)
        panel:show()
    end
end

--锤子动作
function MainScenePanel:getCloseAction(hammerNode)
    hammerNode.action = true
    hammerNode:setAnchorPoint(cc.p(0.5, 0.5))
    --local  angle = 15
    --local actionTime = 0.5
    local action1 = cc.RotateTo:create(HammerActionConfig.ACTION_TIME, HammerActionConfig.ACTION_ANGLE, HammerActionConfig.ACTION_ANGLE)
    local action2 = cc.RotateTo:create(HammerActionConfig.ACTION_TIME, -HammerActionConfig.ACTION_ANGLE, -HammerActionConfig.ACTION_ANGLE)
    local action = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
    hammerNode:runAction(action)
end

--渲染建筑通用信息
function MainScenePanel:renderBuildingCommonInfo(buildingPanel, buildingInfo)
    -- logger:info("···渲染建筑通用信息...............type=%d",buildingInfo.buildingType)
    -- 建筑信息
    local infoPanel = buildingPanel:getChildByName("infoPanel")
    -- 建筑标题    
    local namePanel = infoPanel:getChildByName("namePanel")
    -- 建筑升级
    local barPanel = infoPanel:getChildByName("barPanel")
    -- 建筑生产
    local productPanel = infoPanel:getChildByName("productPanel")

    local key = self:getCountDownKey(buildingInfo.buildingType, buildingInfo.index)
    -- 调整标题坐标
    self:updateBuildingInfoPos(namePanel, key, GlobalConfig.keyTitle, nil,1)
    


    local closeImg = infoPanel:getChildByName("closeImg")
    closeImg:setVisible(false)
    closeImg:stopAllActions()
    closeImg.action = false


    local buildingProxy = self:getProxy(GameProxys.Building)
    local time = buildingProxy:getBuildingUpReTime(buildingInfo.buildingType, buildingInfo.index)
    local percent =(buildingInfo.upTime - time) / buildingInfo.upTime * 100
    -- TODO重连时会报错 upTime没有字段
    if percent < 0 then
        percent = 0
    end
    self:createOrUpdateTimeBar(barPanel, percent)
    if time > 0 then
        -- 升级图标动画
        self:addIconAction(barPanel)
        -- logger:info("升级图标动画...")
    end
    if buildingInfo.buildingType == 17 then
        local children = barPanel:getChildren()
        for _, child in pairs(children) do
            child:setVisible(false)
        end
        -- local url = "images/mainScene/help.png"
        -- self:addIconAction(barPanel)
        -- TextureManager:updateImageView(barPanel,url)
    end



    local isShowBuildingNmae = true
    local imgBg = namePanel:getChildByName("imgBg")
    local txtName = namePanel:getChildByName("txtName")



    --local nameImg = namePanel:getChildByName("nameImg")
    --local lvTxt = namePanel:getChildByName("lvTxt")


    if buildingInfo == nil then
        buildingPanel:setVisible(false)
    end
    buildingPanel:setVisible(true)


    local info = buildingPanel.info
    if buildingInfo.buildingType == 0 then
        -- 空地
        -- logger:info("空地....")
        namePanel:setVisible(false)
        barPanel:setVisible(false)
        productPanel:setVisible(false)
        closeImg:setVisible(true)

        if buildingPanel.effect ~= nil then
            buildingPanel.effect:setVisible(false)
            buildingPanel.effect.buildingType = buildingInfo.buildingType
        end

        -- TODO run action
        local newScale = self._sceneMap:getMapNewScale()
        closeImg:setScale(newScale)
        self:getCloseAction(closeImg)
        return
    end

    local buildingType = buildingInfo.buildingType
    local buildingIndex = buildingInfo.index
    local key = self:getCountDownKey(buildingType, buildingIndex)
    local buildingCfgData = buildingProxy:getBuildingConfigInfo(buildingType, buildingInfo.level)

    -- 是否显示建筑标题
    namePanel:setVisible(GlobalConfig.mainSceneInit)
    



    local isSHowName = true
    local buildingName = info.name
    local buildingLevel = buildingInfo.level
    if buildingType == 17 then
--        -- 军团大厅
--        self._legionNameImg = nameImg
--        self._legionLevelTxt = lvTxt
--        -- 军团建筑信息显示
--        local roleProxy = self:getProxy(GameProxys.Role)
--        local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
--        if legionId > 0 then
--            buildingLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_legionLevel)
--            buildingName = roleProxy:getLegionName()
--            -- print("MainScenePanel···buildingLevel = "..buildingLevel..",buildingName = "..buildingName)
--        end

        -- elseif buildingType ~= 0 or buildingType < 3 or buildingType > 6 then  --排除空地、铁、石、木、农田
    elseif buildingType ~= 0 then
        if buildingType >= 3 and buildingType <= 6 then
            --nameImg:setVisible(false)
            -- 铁、石、木、农田 等级坐标调整
            namePanel:setPosition(GlobalConfig.mainSceneResTitlePos)
            imgBg:ignoreContentAdaptWithSize(true)
            imgBg:setScale9Enabled(false)
            local url = "images/mainScene/titleBg2.png"
            TextureManager:updateImageView(imgBg, url)
            --local size = namePanel:getContentSize()
            --lvTxt:setPosition(size.width / 2, size.height / 2)

            isSHowName = false        
        end
    end


    -- local noshowLvList = {11, 12,13,14,15,16,18}  --不显示等级的建筑类型
    if isSHowName == true then
        if table.indexOf(GlobalConfig.hideLevelList, buildingType) >= 0 then
            txtName:setString(buildingName )   
        else
            txtName:setString( buildingLevel .. "  " .. buildingName )   
        end 
        txtName:setScale(1.5)
        local buildingTextWidth  = txtName:getContentSize().width + 25
        local buildingTextHeight = 28
        imgBg:setContentSize(buildingTextWidth, buildingTextHeight)
        imgBg:setScale(1.5)
    else
        txtName:setScale(1.3)
        txtName:setString(buildingLevel )   
    end
    
    

    -- -- start 生产图标显示----------------------------------
    local productionInfos = buildingInfo.productionInfos
    -- 默认隐藏生产控件
    productPanel:setVisible(false)
    if productionInfos == nil or #productionInfos == 0 then
        productPanel:stopAllActions()
        productPanel:setVisible(false)
        productPanel.isAddAction = nil
        self._countDownProductMap[key] = nil

    else
        isShowBuildingNmae = false
        productPanel:setVisible(true)
        productPanel.info = info
        local data = { }
        data.productPanel = productPanel
        data.productionInfos = productionInfos
        data.buildingIndex = buildingIndex
        data.buildingType = buildingType
        data.buildingInfo = buildingInfo
        self._countDownProductMap[key] = data

    end
    -- -- stop -----------------------------------------------

--    if GlobalConfig.mainSceneisShowLevel then
--        txtName:setString(string.format(self:getTextWord(50012), buildingLevel))
--        -- local noshowLvList = {11, 12,13,14,15,16,18}  --不显示等级的建筑类型
--        if table.indexOf(GlobalConfig.hideLevelList, buildingType) >= 0 then
--            txtName:setVisible(false)
--            local y = txtName:getPositionY()
--            imgBg:setPositionY(y)
--        else
--            txtName:setVisible(true)
--        end        
--    else
--        -- 00 全部建筑隐藏等级---------------------------------------
--        txtName:setVisible(false)
--        local y = txtName:getPositionY()
--        imgBg:setPositionY(y)
--        -- 11 全部建筑隐藏等级---------------------------------------        
--    end


    if buildingInfo.levelTime <= 0 then
        barPanel:setVisible(false)   
        self._countDownMap[key] = nil
    else
        barPanel:setVisible(true)        
        isShowBuildingNmae = false
        local buildingCfgData = buildingProxy:getBuildingConfigInfo(buildingType, buildingInfo.level)
        if buildingCfgData ~= nil then
            -- 这里做个容错 没有升级信息，服务端还给建筑升级了
            local playerProxy = self:getProxy(GameProxys.Role)
            local rate = playerProxy:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_buildspeedrate)
            local time = TimeUtils:getTimeBySpeedRate(buildingCfgData.time, rate)
            local data = { }
            data.barPanel = barPanel
            data.buildingPanel = buildingPanel
            data.buildingIndex = buildingIndex
            data.buildingType = buildingType
            data.level = buildingInfo.level
            data.upTime = time

            self._countDownMap[key] = data
        else
            --            print(buildingType, buildingInfo.level)
        end
    end

    -- 渲染装饰
    self:showBeautyPanel(buildingPanel, buildingInfo)

    if buildingType >= 3 and buildingType <= 6 and buildingLevel > 0 then
        -- 渲染资源建筑特效：石/木/铁/田
        -- self:createOrUpdateResBuildEffect(buildingPanel, buildingType, buildingIndex, true)
    else
        -- 渲染功能建筑特效
        self:createOrUpdateBuildEffect(buildingPanel, key, true)
    end

    -- 渲染功能建筑动画
    self:createOrUpdateBuildAction(buildingPanel, buildingType)



    -- -- star -- 未建造半透明-----------------------
    local btn = buildingPanel:getChildByName("buildingBtn")
    btn:setOpacity(255)
    if buildingLevel == 0 and time <= 0 then
        if buildingType == 7 or buildingType == 8 or buildingType == 9
            or buildingType == 10 or buildingType == 11 then
            -- 7仓库， 9兵营， 10校场
            btn:setOpacity(255 * 0.7)

            local buildingProxy = self:getProxy(GameProxys.Building)
            if buildingProxy:isBuildingOpen(buildingType, buildingIndex, true) then
                -- 可建筑，show铁锤
                closeImg:setVisible(true)
                -- TODO run action
                self:getCloseAction(closeImg)
                -- logger:info("可建造，show铁锤")
            end

            -- 隐藏建筑特效
            self:showOrHideBuildEff(buildingPanel, false)
            -- 隐藏建筑标题
            isShowBuildingNmae = false

        end

    end
    -- -- stop 未建造半透明-----------------------------------------------

    -- -- star -- 感叹号显示初始化----------------------------------------------
    -- 加到建筑本身上去
    local moduleName = buildingProxy:getMarkTipsData(buildingInfo.buildingType)
    -- 是否在可标记建筑表里
    local tip = buildingPanel:getChildByName("tip")
    if moduleName and tip == nil then
        tip = cc.Sprite:create()
        buildingPanel:addChild(tip)
        tip:setLocalZOrder(100)
        -- 位置修正
        local buildOpenConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildOpenConfig, "type", buildingInfo.buildingType)
        local posList = StringUtils:jsonDecode(buildOpenConfig.tipsIconXY)
        tip:setPositionX(posList[1])
        tip:setPositionY(posList[2])
        tip:setName("tip")
        local ccblayer = UICCBLayer.new("rgb-gantanhao", tip)
        tip:setVisible(false)
        self:updateMarkTip(moduleName, buildingPanel)
    end
    -- -- stop -- 感叹号显示----------------------------------------------
    -- 皇帝位置额外的文本显示
    if buildingInfo.buildingType == 19 then
        -- 如果为开放，则不执行
        local buildOpenConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildOpenConfig, "type", buildingInfo.buildingType)
        local isOpen = self:getProxy(GameProxys.Country):getIsOpen()
        if buildOpenConfig.openfn ~= 1 and isOpen == 1 then
            self:updateEmperorBuildingTxt(infoPanel)
            -- 
            self:setEmperorBuildingString()
        end
    end

    self:setBuildingNameVisible(buildingPanel, isShowBuildingNmae)
end


-- 添加皇帝雕像的额外文本
function MainScenePanel:updateEmperorBuildingTxt(infoPanel)
-- dynastyName
    if infoPanel.emperorNameTxt == nil then
        -- 背景图
        local emperorNameBg = TextureManager:createImageView("images/mainScene/bg_emperor_name.png")
        infoPanel:addChild(emperorNameBg)
        emperorNameBg:setPosition(15, -60)
        emperorNameBg:setScale(1.3)
        infoPanel.emperorNameBg = emperorNameBg

        -- 文本
        infoPanel.emperorNameTxt = ccui.Text:create()
        infoPanel.emperorNameTxt:setFontName(GlobalConfig.fontName) 
        infoPanel.emperorNameTxt:setFontSize(18)
        infoPanel.emperorNameTxt:setPosition(15, -60)
        infoPanel.emperorNameTxt:setScale(1.3)
        infoPanel:addChild(infoPanel.emperorNameTxt)
        self._emperorNameTxt = infoPanel.emperorNameTxt
    end

    if infoPanel.dynastyNameTxt == nil then
        -- 背景图
        local dynastyNameBg = TextureManager:createImageView("images/mainScene/bg_dynasty_name.png")
        infoPanel:addChild(dynastyNameBg)
        dynastyNameBg:setPosition(15, 110)
        dynastyNameBg:setScale(1.3)
        infoPanel.dynastyNameBg = dynastyNameBg

        -- 文本
        infoPanel.dynastyNameTxt = ccui.Text:create()
        infoPanel.dynastyNameTxt:setFontName(GlobalConfig.fontName) 
        infoPanel.dynastyNameTxt:setFontSize(18)
        infoPanel.dynastyNameTxt:setPosition(15, 112)
        infoPanel.dynastyNameTxt:setScale(1.3)
        infoPanel:addChild(infoPanel.dynastyNameTxt)
        self._dynastyNameTxt = infoPanel.dynastyNameTxt
    end
end

-- 设置字符串
function MainScenePanel:setEmperorBuildingString()
    local buildingPanel = self:getBuildingPanelByModuleName("CountryModule")
    local infoPanel = buildingPanel:getChildByName("infoPanel")

    -- 判空
    if self._dynastyNameTxt == nil or self._emperorNameTxt == nil then
        -- 渲染节点
        self:updateEmperorBuildingTxt(infoPanel)
    end

    -- 节点显示和隐藏
    local isOpen = self:getProxy(GameProxys.Country):getIsOpen()
    infoPanel.emperorNameBg :setVisible(isOpen == 1)
    infoPanel.emperorNameTxt:setVisible(isOpen == 1)
    infoPanel.dynastyNameBg :setVisible(isOpen == 1)
    infoPanel.dynastyNameTxt:setVisible(isOpen == 1)


    local countryProxy = self:getProxy(GameProxys.Country)
    local dynastyName = countryProxy:getDynastyName()
    if dynastyName == "" then
        dynastyName = self:getTextWord(560005) -- "汉"
    end

    local str = string.format(self:getTextWord(560003), dynastyName) -- "%s朝"
    self._dynastyNameTxt:setString(str)

    -- 
    local emperorName = countryProxy:getEmperorName()
    if emperorName == "" then
        emperorName = self:getTextWord(560035) -- "献"
    end
    local emperorStr = string.format(self:getTextWord(560036), dynastyName, emperorName) -- "%s%s帝"
    
    -- 如果没有皇帝的时候显示虚位以待
    if countryProxy:getHadEmperor() == 0 then
        emperorStr = self:getTextWord(560007) -- "虚位以待"
    end
    
    self._emperorNameTxt:setString(emperorStr)
end


------
-- 判断显示状态，建筑感叹号显示管理
-- moduleName, str, 模块名字
-- buildingPanel, node, 建筑panel 
function MainScenePanel:updateMarkTip(moduleName, buildingPanel)
    -- 空则获取
    if buildingPanel == nil then
        buildingPanel = self:getBuildingPanelByModuleName(moduleName)
    end
    -- 如果还为空，则判空停止
    if buildingPanel == nil then
        return
    end 

    local tip = buildingPanel:getChildByName("tip") -- 感叹号特效
    local namePanel = buildingPanel:getChildByName("namePanel")
    if moduleName == ModuleName.ConsigliereModule then -- 模块名字
        local consigliereProxy = self:getProxy(GameProxys.Consigliere)
        local state_15 = consigliereProxy:getFreeState()
        tip:setVisible(state_15)
    elseif moduleName == ModuleName.ArenaModule then
        local arenaProxy = self:getProxy(GameProxys.Arena)
        local state_16 = arenaProxy:havaTimesOrReward()
        tip:setVisible(state_16)
    elseif moduleName == ModuleName.PartsModule then
        local partsProxy = self:getProxy(GameProxys.Parts)
        local state_14 = partsProxy:checkPartsBuildTip()
        tip:setVisible(state_14)
        -- TODO刷新
    elseif moduleName == ModuleName.LegionSceneModule then -- 军团
        local legionProxy = self:getProxy(GameProxys.Legion)
        local state_17 = legionProxy:checkLegionBuildTip()
        tip:setVisible(state_17)
    end
    self:setBuildingNameVisible(buildingPanel, not tip:isVisible())
end

------
-- 根据模块名字获取对应的buildingPanel
-- moduleName, str, 模块名字
-- return : buildingPanel, node, 建筑buildingPanel
function MainScenePanel:getBuildingPanelByModuleName(moduleName)
    local buildingPanel 
    -- 获取buildingPanel
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getBuildConfigByModuleName(moduleName)
    if buildingInfo == nil then
        return nil
    end
    local index = buildingInfo.ID
    local buildingType = buildingInfo.type
    local isFieldBuilding = buildingProxy:isFieldBuilding(buildingType)
    -- 判断是哪种类型的建筑
    if isFieldBuilding == true then
        buildingPanel = self._fieldBuildingPanelMap[index]
    else
        buildingPanel = self._sceneBuildingPanelMap[index]
    end
    return buildingPanel
end



function MainScenePanel:updateNameImg(sprite, buildingType)
    local url = "images/mainScene/title_%d.png"
    url = string.format(url, buildingType)
    TextureManager:updateImageView(sprite, url)
end


-- 渲染装饰
function MainScenePanel:showBeautyPanel(buildingPanel, buildingInfo)
    -- body
    local beautyPanel = buildingPanel:getChildByName("beautyPanel")
    if beautyPanel ~= nil then
        beautyPanel:setVisible(true)
    -- else
    --     beautyPanel:setVisible(false)
    end
end

-- 调整标题OR生产图标OR升级图标的坐标
-- typeP=1 标题 typeP=2 图标
function MainScenePanel:updateBuildingInfoPos(panel, key, subKey, subKey2, typeP)
    -- body
    -- logger:info("....调整图标坐标 key, subKey = %s  %s", key, subKey)

    local posTab = GlobalConfig.buildingInfoPos

    if panel ~= nil and key ~= nil and posTab ~= nil then
        if rawget(posTab, key) then
            if rawget(posTab[key], subKey) then
                local tab = posTab[key][subKey]
                local x = tab[1]
                local y = tab[2]
                if type(x) == type(0) and type(y) == type(0) then
                    panel:setPosition(cc.p(x, y))
                end
            end
            if rawget(posTab[key], subKey2) then
                local s = posTab[key][subKey2]
                if type(s) == type(0) then
                    panel:setScale(s)
                end
            else
                if typeP == 1 then
                    panel:setScale(GlobalConfig.defTitleScale)
                elseif typeP == 2 then
                    panel:setScale(GlobalConfig.defIconScale)
                else
                    panel:setScale(1)
                end

            end

        end
    end

end

function MainScenePanel:updateLegion(data)
    if data ~= nil then 
        self._isShowMessage = data.message
    else 
        self._isShowMessage = 0
    end
    self:updateLegionBuildingInfo()
end
-- 军团建筑信息更新
function MainScenePanel:updateLegionBuildingInfo()

    if self._isShowMessage == 1 then 
        self:showSysMessage(self:getTextWord(280175))
        self._isShowMessage = 0
    elseif self._isShowMessage == 2 then 
        self:showSysMessage(self:getTextWord(280176))
        self._isShowMessage = 0
    end

--    if self._legionLevelTxt == nil then
--        return
--    end
--    -- body
--    -- 军团建筑信息显示
--    local buildingLevel = 1
--    local roleProxy = self:getProxy(GameProxys.Role)
--    local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)

--    if legionId > 0 then
--        -- 已加入军团
--        buildingLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_legionLevel)
--        self._legionLevelTxt:setString(string.format(self:getTextWord(50012), buildingLevel))

--        local y = self._legionLevelTxt:getPositionY()
--        self._legionNameImg:setPositionY(y-14)

--    else
--        -- 未加入军团
--        self._legionLevelTxt:setString("")
--        local y = self._legionLevelTxt:getPositionY()
--        self._legionNameImg:setPositionY(y)
--    end

end

function MainScenePanel:getCountDownKey(buildingType, buildingIndex)
    return buildingType .. "-" .. buildingIndex
end

--倒计时更新
function MainScenePanel:update()

    local buildingProxy = self:getProxy(GameProxys.Building)
--
    local removeKeyList = {}
    local isCanFreeBuild = false
    for key, data in pairs(self._countDownMap) do
        local barPanel = data.barPanel
        local buildingPanel = data.buildingPanel
        local buildingIndex = data.buildingIndex
        local buildingType = data.buildingType

        local time = buildingProxy:getBuildingUpReTime(buildingType, buildingIndex)
        local percent = (data.upTime - time) / data.upTime * 100
        if percent < 0 then
            percent = 0
        end

        -- 倒计时
        self:createOrUpdateTimeBar(barPanel, percent)
        -- 升级图标动画
        self:addIconAction(barPanel)



        -- print("===================MainScenePanel:update===============================", buildingType, buildingIndex, percent)
        if percent >= 100 then
            barPanel:setVisible(false)
            self:setBuildingNameVisible(buildingPanel, false)
            table.insert(removeKeyList, key)
        end
        barPanel.reqData = nil
        barPanel:setTouchEnabled(false)
        barPanel.helpData = nil
        local isShowIconEffect = false
        local url = "images/mainScene/buildIcon.png"
        local freeTime = self._roleProxy:getFreeTime()
        if time <= freeTime then  --升级中，可免费
            isShowIconEffect = true
            url = "images/mainScene/buildFreeIcon.png"
            local freeData = {}
            freeData.useType = 1
            freeData.index = buildingIndex
            freeData.buildingType = buildingType
            barPanel.reqData = freeData
            barPanel:setTouchEnabled(true)
            self:addTouchEventListener(barPanel,self.onBarPanelTouch)

            isCanFreeBuild = true

        else  --升级中，军团帮助
            local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
            if self._roleProxy:hasLegion() and legionHelpProxy:isBuildingHelped(buildingIndex, buildingType) then
                isShowIconEffect = true
                url = "images/mainScene/needHelp.png"
                local helpData = {}
                helpData.buildingType = buildingType
                helpData.index = buildingIndex
                barPanel.helpData = helpData
                barPanel:setTouchEnabled(true)
                self:addTouchEventListener(barPanel,self.onBarPanelTouchHelp)
            end
        end
        local proIcon = barPanel:getChildByName("proIcon")
        TextureManager:updateImageView(proIcon,url)
        proIcon:setTouchEnabled(false)

        local iconEffect = proIcon.iconEffect
        if isShowIconEffect == true then
            if iconEffect == nil then
                iconEffect = self:createUICCBLayer("rpg-jianzhutishi",proIcon) 
                proIcon.iconEffect = iconEffect
                local size = proIcon:getContentSize()
                iconEffect:setPosition(size.width/2,size.height/2)
            end
            iconEffect:setVisible(true)
        elseif iconEffect ~= nil then
            iconEffect:setVisible(false)
        end

    end
    --通知toolbar建筑按钮提示免费加速特效
    buildingProxy:sendNotification(AppEvent.PROXY_BUILDFREE_TOOLBARTIP,isCanFreeBuild)
    -- if self._sceneBuildingPanelMap[14] then
    --     local infoPanel= self._sceneBuildingPanelMap[14]:getChildByName("infoPanel")
    --     local barpanel= infoPanel:getChildByName("barPanel")
    --     local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
    --     barpanel:setVisible(legionHelpProxy:isCanHelp() > 0)
    --     local function helpOthersBuildings()
    --         legionHelpProxy:helpOthersBuildings()
    --     end
    --     self:addTouchEventListener(barpanel,helpOthersBuildings)
    -- end
    -- print("################################################################################")
    for _, key in pairs(removeKeyList) do
        self._countDownMap[key] = nil
    end

    -- -- 建筑生产队列map--------------------------------------------------------
    self:updateProductInfo()

    -- -- 资源建筑随机循环播放--------------------------------------------------------
    self:loopRandomFieldEffects()
end

function MainScenePanel:onBarPanelTouchHelp(sender)
    if sender.helpData then
        local buildingProxy = self:getProxy(GameProxys.Building)
        buildingProxy:onTriggerNet280017Req(sender.helpData.buildingType,sender.helpData.index)   
        self:showSysMessage(self:getTextWord(380000))
    end
end

function MainScenePanel:onBarPanelTouch(sender)
    if sender.reqData then
        local buildingProxy = self:getProxy(GameProxys.Building)
        buildingProxy:onTriggerNet280004Req(sender.reqData)
    end
end

function MainScenePanel:createOrUpdateTimeBar(barPanel, percent)
    -- body
    local timeBar = barPanel.timeBar
    if timeBar == nil then
        local delay = 1.5  --红色进度条滚动时长
        local timeBar = barPanel:getChildByName("timeBar")
        timeBar = ComponentUtils:addProgressbar2(timeBar, "images/mainScene/bar.png", percent, nil)
        barPanel.timeBar = timeBar
    else
        timeBar.setPercent(self, percent)
    end

    -- logger:info("生产进度条 percent=%d",percent)
    -- 生产图标动画
    -- self:addIconAction(barPanel)
end


--倒计时更新
function MainScenePanel:updateProductInfo()
    local buildingProxy = self:getProxy(GameProxys.Building)

    -- 建筑生产队列map--------------------------------------------------------
    for key, data in pairs(self._countDownProductMap) do
        local productPanel = data.productPanel
        local buildingIndex = data.buildingIndex
        local buildingType = data.buildingType
        local productionInfos = data.productionInfos
        local buildingInfo = data.buildingInfo

        -- productPanel:setVisible(false) --默认隐藏生产控件
        if productionInfos == nil or #productionInfos == 0 then
            productPanel:stopAllActions()
            productPanel:setVisible(false)
            productPanel.isAddAction = nil
            self._countDownProductMap[key] = nil
            return
        end

        local productionInfo
        for k,v in pairs(productionInfos) do
            -- print("生产···v.order,v.state", v.order, v.state)
            local time = buildingProxy:getBuildingUpReTime(buildingType, buildingIndex)
            if time > 0 then
                productPanel.isProductPanel = false
                productPanel:setVisible(false) --当前建筑正在升级，优先显示升级，生产不显示
                break
            else
                productPanel.isProductPanel = true
            end

            if v.state == 1 then
                -- 该建筑生产队列不为空
                productionInfo = v
                productPanel:setVisible(true)
                local proIcon = productPanel:getChildByName("proIcon") --生产图标

                local typeid = productionInfo.typeid
                local buildingProxy = self:getProxy(GameProxys.Building)
                local proConfigName = buildingProxy:getBuildingProConfigName(buildingType)
                if proConfigName == nil then
                    logger:error("!!!!!!该建筑竟然有生产数据!!!!:%d!!buildingType:%d!", typeid, buildingType)
                    return
                end
    
                local info = nil
                if proConfigName == ConfigData.ScienceLvConfig then  --太学院    
                    info = ConfigDataManager:getInfoFindByTwoKey(ConfigData.ScienceLvConfig
                        , "scienceType",typeid, "reqPrestigeLv", productionInfo.num+1 ) 
                else
                    info = ConfigDataManager:getConfigById(proConfigName,typeid)
                end


                if info == nil then
                    logger:error("productionInfo > proConfigName > info = nil 生产信息有误！")
                    break
                end

                local iconID = info.ID
                local power = nil
                if buildingType == 8 then --太学院
                    power = GamePowerConfig.Product
                    local conf = ConfigDataManager:getConfigById(ConfigData.MuseumConfig, typeid)
                    iconID = conf.icon
                elseif buildingType == 9 then --兵营
                    power = GamePowerConfig.Product
                elseif buildingType == 10 then --校场
                    power = GamePowerConfig.Product
                elseif buildingType == 11 then --工匠坊
                    power = GamePowerConfig.Product
                    local conf = ConfigDataManager:getConfigById(ConfigData.ItemMadeConfig, info.ID)
                    iconID = conf.icon
                else
                    productPanel:setVisible(false) --其他生产不显示
                    break
                end


                local iconData = {}
                iconData.power = power
                iconData.typeid = iconID
                iconData.num = 1

                local icon = proIcon.icon
                if icon == nil then
                    -- logger:info("···生产图标 ********* new create...........")
                    icon = UIIcon.new(proIcon, iconData, false, nil, true)
                    proIcon.icon = icon

                    -- --TODO 生产图标可以点击，可能会导致个别图标点错建筑
                    icon:setTouchEnabled(false)
                    proIcon:setTouchEnabled(false)
                    productPanel:setTouchEnabled(true)
                    self:addSceneTouchEvent(productPanel, self.onBuildingBtnTouch)
                else
                    icon:updateData(iconData)
                end

                -- 显示进度条
                local percent = self:getProductPercent(buildingInfo, productionInfo, info, buildingProxy, buildingIndex, buildingType)
                self:createOrUpdateTimeBar(productPanel, percent)

                -- 生产图标动画
                self:addIconAction(productPanel)

                break

            end
        end

    end

end

-- 计算生产百分比
function MainScenePanel:getProductPercent(buildingInfo, productionInfo, info, buildingProxy, buildingIndex, buildingType)
    -- body
    local timeneed = nil
    if rawget(info, 'timeneed') then
        timeneed = info.timeneed
        -- print("赋值timeneed=info.timeneed")
    else
        timeneed = info.time
        -- print("赋值timeneed=info.time")
    end

    local speedRate = 1
    if buildingInfo.speedRate ~= nil then
        speedRate = buildingInfo.speedRate
        -- logger:info("主城 计算前 timeneed, speedRate : %d %d", timeneed, speedRate)
        timeneed = TimeUtils:getTimeBySpeedRate(timeneed, speedRate)
    end

    -- print("主城 计算后 timeneed, speedRate", timeneed, speedRate)
    local totalTime = timeneed
    if buildingType ~= 8 then --太学院的productionInfo.num表示当前研发的科技等级
        totalTime = productionInfo.num * timeneed
    end

    -- print("主城 计算后总时间 totalTime, num", totalTime, productionInfo.num)
    local remainTime = buildingProxy:getBuildingProLineReTime(buildingIndex, productionInfo.order)

    local process = (totalTime - remainTime) / totalTime * 100
    -- print("生产时间百分比···process, remainTime", process, remainTime)

    return process
end

function MainScenePanel:addIconAction( panel )
    -- 生产图标动画
    if panel.isAddAction == nil then
        -- print("···生产图标动画 new create...........")
        local iniX,iniY = panel:getPosition()
        local scaleDelay = 0.5                            --时长(游戏设计40帧/秒)
        local action1 = cc.MoveTo:create(scaleDelay,cc.p(iniX, iniY + 5))    --0到5
        local action2 = cc.MoveTo:create(scaleDelay,cc.p(iniX, iniY + 0))    --5到0
        local seq = cc.Sequence:create(action1, action2, nil)
        panel:stopAllActions()
        panel:runAction(cc.RepeatForever:create(seq))
        panel.isAddAction = true --已有动画标记
    end
end

-----------------------------------------------------------
function MainScenePanel:createBuilding(posKey, buildingType, buildingIndex)

    local buildingPanel = self._defaultBuildingPanel:clone()
    local dty = self._sceneMap:getDtSceneY()
    local buildingPos = self._mainPanel:getChildByName(posKey)
    buildingPos:setVisible(false)
    local x, y = buildingPos:getPosition()
    buildingPanel:setPosition(x, y + dty)
    buildingPanel:setName(posKey)

    -- 建筑特效
    local effectPanel = buildingPos:getChildByName("effectPanel")
    if effectPanel ~= nil then

        NodeUtils:switchParent(effectPanel, buildingPanel)
        effectPanel:setLocalZOrder(1)
        effectPanel:setVisible(false)
    end

    -- 建筑装饰
    local beautyPanel = buildingPos:getChildByName("beautyPanel")
    if beautyPanel ~= nil then

        NodeUtils:switchParent(beautyPanel, buildingPanel)
        beautyPanel:setLocalZOrder(2)
        beautyPanel:setVisible(false)
    end

    local infoPanel = buildingPanel:getChildByName("infoPanel")
    if infoPanel ~= nil then
        infoPanel:setLocalZOrder(9)
    end

    local namePanel = infoPanel:getChildByName("namePanel")       --建筑标题
    local barPanel = infoPanel:getChildByName("barPanel")         --建筑升级
    local productPanel = infoPanel:getChildByName("productPanel") --建筑生产
    local key = self:getCountDownKey(buildingType, buildingIndex)

--    -- 调整标题坐标
--    self:updateBuildingInfoPos(namePanel, key, GlobalConfig.keyTitle, nil,1)
    -- 调整升级图标坐标
    self:updateBuildingInfoPos(barPanel, key, GlobalConfig.keyIcon, GlobalConfig.keyIconScale,2)
    -- 调整生产图标坐标
    self:updateBuildingInfoPos(productPanel, key, GlobalConfig.keyIcon, GlobalConfig.keyIconScale,2)

    -- 调试打印    
--    productPanel.key = key
--    productPanel.oldSetScale = productPanel.setScale
--    productPanel.setScale = function(sender, s)
--        logger:info("=====>barPanel.key:%s, oldScale:%s", productPanel.key, productPanel:getScale())
--        sender:oldSetScale(s)
--        logger:info("=====>barPanel.key:%s, newScale:%s", productPanel.key, productPanel:getScale())
--        if productPanel.key == "9-2" then
--            local x = 1
--            local y = 2

--        end
--    end


    self[posKey] = buildingPanel
    buildingPanel.isOffset = false

    local btn = buildingPanel:getChildByName("buildingBtn")

    local touchPanel = buildingPos:getChildByName("touchPanel")
    if touchPanel ~= nil then

        NodeUtils:switchParent(touchPanel, buildingPanel)

        buildingPanel.touchPanel = touchPanel
        touchPanel:setTouchEnabled(false)
        touchPanel:setVisible(false)
        touchPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none) --野外点击区域

        touchPanel.touchWidget = btn
    end

    self._sceneMap:addChildToMap(buildingPanel)

    self:updateBuildingPanel(buildingPanel, buildingType, buildingIndex)

    buildingPanel:setLocalZOrder(2000 - y)

    buildingPanel:setVisible(true)

    buildingPos:removeFromParent()

    return buildingPanel
end

-- 重置野外建筑坐标
function MainScenePanel:updateFieldBuildingPos(buildingPanel)
    -- body
    if buildingPanel.isChgPos == nil then
        buildingPanel.isChgPos = true
        -- local dty = self._sceneMap:getDtSceneY()
        local x,y = buildingPanel:getPosition()
        buildingPanel:setPosition(x-GlobalConfig.centerPos.x, y-GlobalConfig.centerPos.y)
    end
end


function MainScenePanel:onInitChipPanels()  --ps:动画的panel初始化
    for k,v in pairs(GlobalConfig.MainSceneSoldierEff) do
        if self._allSoldierPanelMap["soldierChipPanel"..k] == nil then
            local panel = self._mainPanel:getChildByName(v.pos)
            NodeUtils:switchParent(panel, self._sceneMap, self._sceneMap.addChildToMap)
            panel:setVisible(false)
            panel:setLocalZOrder(3000)
            self._allSoldierPanelMap["soldierChipPanel"..k] = panel
        end
    end

    if self._waterPanel == nil then
        local panel = self._mainPanel:getChildByName("movieChipPos_water")
        NodeUtils:switchParent(panel, self._sceneMap, self._sceneMap.addChildToMap)
        panel:setVisible(false)
        panel:setLocalZOrder(100)
        self._waterPanel = panel
    end

    if self._topEffectPanel == nil then
        local panel = self:getChildByName("topeffect")
        NodeUtils:switchParent(panel, self._sceneMap, self._sceneMap.addChildToMap)
        panel:setVisible(false)
        panel:setLocalZOrder(80000)

        self._topEffectPanel = panel
    end

    if self._lowEffectPanel == nil then
        local panel = self:getChildByName("loweffect")
        NodeUtils:switchParent(panel, self._sceneMap, self._sceneMap.addChildToMap)
        panel:setVisible(false)
        panel:setLocalZOrder(1)

        self._lowEffectPanel = panel
    end
end

-- 主城巡逻兵动画
function MainScenePanel:createOrUpdatePatrouille(flagIndex)
    -- body
    --if flagIndex ~= true then
        local count = 0
        for k,v in pairs(GlobalConfig.MainSceneSoldierEff) do
            -- if self._allSoldierPanelMap["soldierChipPanel"..k] == nil then
            --     local panel = self._mainPanel:getChildByName(v.pos)
            --     panel = panel:clone()
            --     panel:setVisible(true)
            --     panel:setLocalZOrder(3000)
            --     self._sceneMap:addChildToMap(panel)
            --     self._allSoldierPanelMap["soldierChipPanel"..k] = panel
            -- end
            local panelk = self._allSoldierPanelMap["soldierChipPanel"..k]
            

            local function createMovieChip(posPanel, effectName, flag, conf)
                -- body
                posPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
                posPanel:setVisible(true)

                local movieChip = self:createUIMovieClip(effectName)
                movieChip:setAnchorPoint(0,0)
                movieChip:setScale(conf.standScale)

                local pos1 = posPanel:getChildByName("pos1")
                local pos6 = posPanel:getChildByName("pos6")
                pos1:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
                pos6:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)

                local x,y = pos6:getPosition()
                local posTo6 = cc.p(x,y)
                x,y = pos1:getPosition()
                local posTo1 = cc.p(x,y)
                
                local moveDelay = conf.moveDelay          --从头走到尾的时间
                local standDelay = conf.standDelay        --走到尾站立的时间，然后隐藏   
                local moveTo6 = cc.MoveTo:create(moveDelay, posTo6)
                local moveTo1 = cc.MoveTo:create(moveDelay, posTo1)

                local moveTo = nil
                if flag == 0 then
                    movieChip:setParent(pos1)
                    
                    moveTo = cc.Sequence:create( 
                        cc.FadeTo:create(0, 255),
                        moveTo6,
                        cc.DelayTime:create(standDelay),
                        cc.FadeTo:create(0, 0),
                        cc.MoveTo:create(0, posTo1),
                        cc.DelayTime:create(moveDelay+standDelay)
                        )

                else
                    movieChip:setParent(pos1)
                    
                    moveTo = cc.Sequence:create( 
                        cc.FadeTo:create(0, 0),
                        cc.DelayTime:create(moveDelay+standDelay),
                        cc.FadeTo:create(0, 255),
                        moveTo6,
                        cc.DelayTime:create(standDelay),
                        cc.FadeTo:create(0, 0),
                        cc.MoveTo:create(0, posTo1)
                        )

                end

                count = count + 1
                if self._allSoldierChipMap[count] == nil then
                    self._allSoldierChipMap[count] = movieChip
                    -- print("开始显示主城巡逻兵的动画")
                    self._allSoldierChipMap[count]:play(true, nil, nil, moveTo, moveDelay, standDelay)
                end
            end

            for i=1,v.count do
                local walkLeft = panelk:getChildByName("walkLeft" .. i)
                local walkRight = panelk:getChildByName("walkRight" .. i)
            
                if walkLeft ~= nil and walkRight ~= nil then
                    local function call1()
                        createMovieChip(walkRight, v.effectName[1], 0, v)
                     end
                    TimerManager:addOnce(k * 10 + i*10,call1,self)

                    local function call2()
                        createMovieChip(walkLeft, v.effectName[2], 1, v)
                    end
                    TimerManager:addOnce(k * 10 + i*15,call2,self)
                end
            end

            panelk:setVisible(true)
        end
    --end

end


-- 主城流水动画
function MainScenePanel:createOrUpdateWater(flagIndex)
    -- body
    --if self._sceneMap.movieChip_water == nil then
    -- if self._waterPanel == nil then
    --     local panel = self._mainPanel:getChildByName("movieChipPos_water")
    --     panel = panel:clone()
    --     panel:setVisible(true)
    --     panel:setLocalZOrder(100)
    --     self._sceneMap:addChildToMap(panel)
    --     self._waterPanel = panel
    -- end
    --if flagIndex ~= true then
        local count = 0 
        local panel = self._waterPanel
        panel:setVisible(true)

        local function createMovieChip(posPanel, effectName, scale)
            posPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
            posPanel:setVisible(true)

            local movieChip = self:createUIMovieClip(effectName)
            movieChip:setAnchorPoint(0,0)
            movieChip:setScale(scale)
            movieChip:setParent(posPanel)

            count = count + 1

            if self._waterChipMap[count] == nil then 
                self._waterChipMap[count] = movieChip
                -- print("开始主城流水瀑布的动画")
                self._waterChipMap[count]:play(true, nil, nil, nil)
            end
        end


        local waterPanel = panel:getChildByName("rpg-Running_water")
        panel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
        waterPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
        -- 水波纹和小兵
        for k,v in pairs(GlobalConfig.MainSceneEffectPos) do
            local water = waterPanel:getChildByName(v.pos) -- 关键的位置层
            local function call()     
                createMovieChip(water, v.effectName, v.scale)
            end
            TimerManager:addOnce(k *16,call,self)
        end
        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        if GlobalConfig.isTrueWaterPos and 
                (cc.PLATFORM_OS_IPHONE == targetPlatform 
                    or cc.PLATFORM_OS_IPAD == targetPlatform
                    or cc.PLATFORM_OS_WINDOWS == targetPlatform) then
            -- 骨骼特效，瀑布
            for k,v in pairs(GlobalConfig.MainSceneWaterPos) do
                local waterPosPanel = waterPanel:getChildByName(v.pos)
                local function callFunc()
                    self:createEffect(waterPosPanel, v.effectName, v.scale, cc.p(0 , -50))
                end
                -- TimerManager:addOnce(k *16, callFunc, self)
                TimerManager:addOnce(k *80, callFunc, self)
            end
        end
end


function MainScenePanel:createEffectWithConf(posPanel,conf)
    -- local conf = conf

    -- local function createEffect()
        -- self:createEffect(posPanel, conf.effectName, conf.scale, conf.offset, conf.zOrder, conf.effectOffset)
    -- end
    -- if conf.delayCraeteTime then
    --     TimerManager:addOnce(conf.delayCraeteTime, createEffect, self)
    -- else
    --     createEffect()
    -- end

    return self:createEffect(posPanel, conf.effectName, conf.scale, conf.offset, conf.zOrder, conf.effectOffset, conf.completeCallback)
end
--[[ 建议使用 createEffectWithConf 传配置,下面这个函数的参数可能会加到很长
    posPanel:用于定位的panle
    effectName:特效名字
    scale:放到缩小值
    offset:偏移值(会对posPanel进行setPosition)
    zOrder:高度
    effectOffset:特效偏移值(会对特效进行setPosition)
]]
function MainScenePanel:createEffect(posPanel, effectName, scale, offset, zOrder, effectOffset, completeCallback)
    -- local ccbLayer = posPanel.ccbLayer -- 判空
    local ccbLayer = self:getEffect(posPanel)
    if ccbLayer == nil then
        ccbLayer = self:createUICCBLayer(effectName, posPanel, nil, completeCallback) 
        if offset then
            local pos = cc.p(posPanel:getPosition())
            local new_pos = cc.pAdd(pos,offset)
            posPanel:setPosition(new_pos)
        end
        if zOrder then
            ccbLayer:setLocalZOrder(zOrder)
        end
        if effectOffset then
            local pos = cc.p(ccbLayer:getPosition())
            local new_pos = cc.pAdd(pos,effectOffset)
            ccbLayer:setPosition(new_pos)
        end
        self:setEffect(posPanel,ccbLayer)
        table.insert(self._effectContainer,ccbLayer)
        return ccbLayer
    else
        ccbLayer:setVisible(true)
    end
    return ccbLayer
end

--跟MainScenePanel:createEffect 对应着使用
function MainScenePanel:clearEffect(node)
    local ccbLayer = self:getEffect(node)
    if ccbLayer ~= nil then
        ccbLayer:finalize()
        self:setEffect(node,nil)
    end
    return true -- return true 如果模块隐藏的时候,是不会进入到这里到,这时候可以用这个来判断是否进入这个函数
end

function MainScenePanel:getEffect(node)
    if node then
        return node.ccbLayer
    end
end

function MainScenePanel:setEffect(node,effect)
    if node then
        node.ccbLayer = effect
    end
end

--层级比较低的特效 self._lowEffectPanel
function MainScenePanel:createOrUpdateLowEffect(flagIndex)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if GlobalConfig.isTrueWaterPos and 
            (cc.PLATFORM_OS_IPHONE == targetPlatform 
                or cc.PLATFORM_OS_IPAD == targetPlatform
                or cc.PLATFORM_OS_WINDOWS == targetPlatform) then


        local panel = self._lowEffectPanel
        panel:setVisible(true)


        for k,v in pairs(GlobalConfig.MainSceneLowEffect) do
            local effectPosPnl = panel:getChildByName(v.pos)
            effectPosPnl:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
            local function callFunc()
                self:createEffect(effectPosPnl, v.effectName, v.scale, v.offset)
            end
            -- TimerManager:addOnce(k *16, callFunc, self)
            TimerManager:addOnce(k *80, callFunc, self)
        end
    end
end
--层级比较高的特效
function MainScenePanel:createOrUpdateTopEffect(flagIndex)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if GlobalConfig.isTrueWaterPos and 
            (cc.PLATFORM_OS_IPHONE == targetPlatform 
                or cc.PLATFORM_OS_IPAD == targetPlatform
                or cc.PLATFORM_OS_WINDOWS == targetPlatform) then


        local panel = self._topEffectPanel
        panel:setVisible(true)


        for k,v in pairs(GlobalConfig.MainSceneTopEffect) do
            local effectPosPnl = panel:getChildByName(v.pos)
            effectPosPnl:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
            local function callFunc()
                self:createEffect(effectPosPnl, v.effectName, v.scale)
            end
            TimerManager:addOnce(k *80, callFunc, self)
        end
    end
end


--[[

功能:创建固定在屏幕上的特效

]]
function MainScenePanel:createOrUpdateFixEffect()   
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if GlobalConfig.isTrueWaterPos and 
            (cc.PLATFORM_OS_IPHONE == targetPlatform 
                or cc.PLATFORM_OS_IPAD == targetPlatform
                or cc.PLATFORM_OS_WINDOWS == targetPlatform) then

        local layer = self._sceneMap 
        for k,v in pairs(GlobalConfig.MainSceneFixEffect) do
            self:createEffectWithConf(layer,v)
        end
    end
end

--[[

功能:创建雨

]]
function MainScenePanel:createOrUpdateWeather()   
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if GlobalConfig.isTrueWaterPos and 
            (cc.PLATFORM_OS_IPHONE == targetPlatform 
                or cc.PLATFORM_OS_IPAD == targetPlatform
                or cc.PLATFORM_OS_WINDOWS == targetPlatform) then

        --[[
            马上创建,配置里面还可能有延时
            7030 主城下雨天气特效
        ]]
        local RaineffectConf = GlobalConfig.MainSceneRainEffect
        local SunEffectConf = GlobalConfig.MainSceneSunEffect
        local pDirector = cc.Director:getInstance()

        local runWeatherCloneFunc = nil

        local function showRain()
            self._weatherState = MainScenePanel.WeatherState.Raining
            --这里不怕重复创建,里面这个方法里面带保护
            local ccblayer = self:createEffectWithConf(self.rainLayerColor,RaineffectConf)
            self.rainLayerColor._ccblayer = ccblayer

            self.rainLayerColor:setVisible(true)
            ActionUtils:setOpacityTo(self.rainLayerColor,RaineffectConf.fadeInTime,RaineffectConf.opacity)--渐暗
            ccblayer:setVisible(true)
        end

        local tryShowSunClone = nil
        --太阳结束帧
        local function completeSunShine()
            if self.isNeedToStopSunShine then
                logger:info("~~~~~~~~~~~~~~~~~ 阳光已经播放完成 ~~~~~~~~~~~~~~~~~~~~~~~~~")
                self.isNeedToStopSunShine = false
                self.sunLayerColor._ccblayer:setVisible(false)--todo 在不可见的时候 不知道 是否能设置
                runWeatherCloneFunc()
            else
                tryShowSunClone()
            end
        end

        local function showSun()
            self._weatherState = MainScenePanel.WeatherState.SunShinning
            --由于阳光特效需要获取complete帧回调,所以阳光只是播放一次的(如果是无限循环,则获取不到complete回调)
            self:clearEffect(self.sunLayerColor)
            SunEffectConf.completeCallback = completeSunShine
            --这里不怕重复创建,里面这个方法里面带保护
            local ccblayer = self:createEffectWithConf(self.sunLayerColor,SunEffectConf)
            self.sunLayerColor._ccblayer = ccblayer

            ccblayer:setVisible(true)
        end

        local function tryCreateRain()
            if not self:isVisible() then
                logger:error("~~~~~~~ mainScene模块没有显示,待模块显示,再开启下雨")
                self._weatherState = MainScenePanel.WeatherState.ToRaining
                return
            end

            if self._weatherState == MainScenePanel.WeatherState.Raining then
                logger:info("~~~~~已经在下雨了")
                return
            end

            showRain()
        end

        local function trySunShine()
            if not self:isVisible() then
                logger:error("~~~~~~~ mainScene模块没有显示,待模块显示再开启阳光特效 && 停止下雨")
                self._weatherState = MainScenePanel.WeatherState.ToSunShine
                return
            end

            if self._weatherState == MainScenePanel.WeatherState.SunShinning then
                logger:info("~~~~~~~ 阳光已经创建,不需要在创建了")
                return
            end

            showSun()
        end
        tryShowSunClone = trySunShine

        local function stopRainNow()
            logger:info("~~~~~~~~~~~~~~~~~~~~~~~~~~ 立马停雨")
            if self.rainLayerColor and self.rainLayerColor._ccblayer then
                self.rainLayerColor:setVisible(false)
                self.rainLayerColor:setOpacity(0)
                self.rainLayerColor._ccblayer:setVisible(false)
            end
        end

        --停雨
        local function stopRain()
            if not self:isVisible() then
                logger:error("~~~~~~~ mainScene模块没有显示,马上停止下雨")
                self._weatherState = MainScenePanel.WeatherState.StopRain
                return
            end

            if self._weatherState == MainScenePanel.WeatherState.StoppingRain then
                logger:info("~~~~~~~~~~~~~~~~~~~~~~~~ 正在停雨")
                return
            end

            self._weatherState = MainScenePanel.WeatherState.StoppingRain

            if self.rainLayerColor and self.rainLayerColor._ccblayer then
                ActionUtils:setOpacityTo(self.rainLayerColor,RaineffectConf.fadeInTime,0)--渐明
                self.rainLayerColor._ccblayer:setVisible(false)
            end
        end

        --停止太阳
        --这里不需要判断模块是否显示
        local function stopSunShine()
            logger:error("~~~~~~~ mainScene模块无论有没有显示,也要设置停止太阳的状态")
            self.isNeedToStopSunShine = true
            self._weatherState = MainScenePanel.WeatherState.StopSun
        end

        local function runWeather()

            logger:info("~~~~~~~~ 天气开始运行")

            local layer = self._sceneMap 

            if self.rainLayerColor == nil then
                self.rainLayerColor = cc.LayerColor:create(cc.c4b(0,0,0,0))
                self.rainLayerColor:setOpacity(0)
                layer:addChild(self.rainLayerColor,RaineffectConf.zOrder)
            end

            if self.sunLayerColor == nil then
                self.sunLayerColor = cc.Layer:create()--cc.LayerColor:create(cc.c4b(0,0,0,0))
                self.sunLayerColor:setOpacity(0)
                layer:addChild(self.sunLayerColor,RaineffectConf.zOrder)
            end

            self:clearEffect(self.rainLayerColor)
            self:clearEffect(self.sunLayerColor)

            local actions = {
                cc.CallFunc:create(tryCreateRain),--创建下雨特效                *******
                cc.DelayTime:create(RaineffectConf.fadeInTime),--渐变时间
                cc.DelayTime:create(RaineffectConf.rainTime),--下雨下2分钟
                cc.CallFunc:create(stopRain),--停雨                             *******
                cc.DelayTime:create(RaineffectConf.fadeOutTime),--渐变时间
                cc.CallFunc:create(trySunShine),--出太阳                        *******
                cc.DelayTime:create(SunEffectConf.sunTime),--间隔10分钟==出太阳时间
                cc.CallFunc:create(stopSunShine),--停止太阳                     *******
            }

            self.rainLayerColor:stopAllActions()
            --这个会有问题,在pause的时候,他会继续走tryCreateRain函数
            -- self.rainLayerColor:runAction(cc.RepeatForever:create(cc.Sequence:create(unpack(actions))))
            self.rainLayerColor:runAction(cc.Sequence:create(unpack(actions)))

        end
        runWeatherCloneFunc = runWeather

        if self._weatherState == MainScenePanel.WeatherState.NotInit then
            self._weatherState = MainScenePanel.WeatherState.TryCreate
            TimerManager:addOnce(RaineffectConf.delayTime, runWeather, self)
        elseif self._weatherState == MainScenePanel.WeatherState.ToRaining then
            tryCreateRain()
        elseif self._weatherState == MainScenePanel.WeatherState.ToSunShine then
            stopRainNow()
            trySunShine()
        elseif self._weatherState == MainScenePanel.WeatherState.StopRain then
            stopRainNow()
        elseif self._weatherState == MainScenePanel.WeatherState.StopSun then
            runWeather()
        end
    end
end


-- 主城小鸟动画
function MainScenePanel:createOrUpdateBird(flagIndex)    
    --self._birdPanel = {}
    --self._birdChipMap = {}
    --math.randomseed(os.clock())
    --if flagIndex ~= true then
        TimerManager:addOnce(GlobalConfig.birdWaitDelay, self.createBird2, self, 1)
    --end
end

function MainScenePanel:createBird2(index)
        -- body                
    -- logger:info("小小 index = %d", index)
    if self._birdPanel[index] == nil then
        local panel = self._mainPanel:getChildByName("movPos_bird")
        panel = panel:clone()
        panel:setVisible(true)
        panel:setLocalZOrder(3100)
        self._sceneMap:addChildToMap(panel)
        self._birdPanel[index] = panel
        panel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    end
    local panel = self._birdPanel[index]
    
    if self._birdChipMap[index] == nil then
        local movieChip = self:createUIMovieClip(GlobalConfig.birdEffect)
        movieChip:setAnchorPoint(0,0)
        movieChip:setScale(GlobalConfig.birdScale)
        movieChip:setParent(panel)
        movieChip:setLocalZOrder(3100)
        --self._sceneMap.bird = movieChip
        self._birdChipMap[index] = movieChip
    end

    local randomBeginY = math.random(GlobalConfig.birdBeginRandomY[1], GlobalConfig.birdBeginRandomY[2])
    local randomWait = math.random(GlobalConfig.birdBeginRandomWait[1], GlobalConfig.birdBeginRandomWait[2])
    local flyCount1 = math.random(GlobalConfig.birdFlyCount1[1], GlobalConfig.birdFlyCount1[2])
    local flyCount2 = math.random(GlobalConfig.birdFlyCount2[1], GlobalConfig.birdFlyCount2[2])
    local randomEndX = math.random(GlobalConfig.birdEndPosX[1], GlobalConfig.birdEndPosX[2])
    local randomEndY = math.random(GlobalConfig.birdEndPosY[1], GlobalConfig.birdEndPosY[2])
    local randomDelay = math.random(GlobalConfig.birdFlyDelay[1], GlobalConfig.birdFlyDelay[2])

    -- logger:info("randomWait =%d", randomWait)

    panel:setPositionX(-460)
    panel:setPositionY(randomBeginY)
    --self._birdPanel[index].randomBeginY = randomBeginY

    -- AudioManager:playEffect(GlobalConfig.birdAudio) -- 取消每次show都播放叫声


    local function callback()
            -- body
        if self:isModuleVisible() then
            AudioManager:playEffect(GlobalConfig.birdAudio)
        end
    end

    local bezierSum = {GlobalConfig.bezierPos1, cc.p(randomEndX - GlobalConfig.bezierPos2.x, randomEndY - GlobalConfig.bezierPos2.y), cc.p(randomEndX, randomEndY)}
    local bezierTo = cc.BezierTo:create(randomDelay, bezierSum)

    -- local MoveTo = cc.MoveTo:create(0, cc.p(0,0))
    local fadeTo1 = cc.FadeTo:create(0,0)
    local delayTime = cc.DelayTime:create(randomWait/1000)
    local fadeTo2 = cc.FadeTo:create(0,255)
    local cusAction2 = cc.Sequence:create(fadeTo1, delayTime, fadeTo2)

    --if flagIndex ~= true then
    --if self._birdChipMap[index] == nil then
    -- print("开始主城小鸟的动画演示了")
    --self._birdChipMap[index]:stopAllActions()
    if self._isPlayNowBird == nil then
        self._isPlayNowBird = true
        self._birdChipMap[index]:playBird(true, callback, nil, bezierTo, cusAction2, randomWait/1000, flyCount1, flyCount2, GlobalConfig.birdEffect1, GlobalConfig.birdEffect2, cc.p(randomEndX, randomEndY))
    end

    if index < GlobalConfig.birdMaxCount then
        index = index + 1
        TimerManager:addOnce(randomWait, self.createBird2, self, index)
    end
end

function MainScenePanel:createOrUpdateBuildAction(buildingPanel, buildingType)
    -- body
    -- logger:info("createOrUpdateBuildAction... 0 %d",buildingType)
    if buildingType ~= nil then
        local conf = GlobalConfig.buildAction[buildingType]
        if conf ~= nil then
            local movY = rawget(conf, 'movY')
            local movT = rawget(conf, 'movT')
            local rate = rawget(conf, 'rate')
            if movY ~= nil and movT ~= nil then
                if not buildingPanel.buildAction then
                    buildingPanel.buildAction = true

                    local btn = buildingPanel:getChildByName("buildingBtn")
                    local x,y = btn:getPosition()

                    local moveAction1 = cc.MoveTo:create(movT[1], cc.p(x, y + movY[1]))
                    local moveAction2 = cc.MoveTo:create(movT[2], cc.p(x, y + movY[2]))
                    local moveAction = cc.Sequence:create(moveAction1, moveAction2)
                    -- local easeMove = cc.EaseOut:create(moveAction, rate)
                    local easeMove = cc.EaseIn:create(moveAction, rate)
                    local action = cc.RepeatForever:create(easeMove)

                    btn:runAction(action)

                end
            end
        end
    end

end


-- 主城建筑特效
function MainScenePanel:createOrUpdateBuildEffect(buildingPanel, key, isShow)
    -- body
    -- logger:info("主城建筑特效 ....play 000")
    if buildingPanel.effect == nil then
        local name = self._roleProxy:getRoleName()   --新手阶段         
        if name == "" or GameConfig.isNewPlayer == true then
            return
        end

        local effectConf = rawget(GlobalConfig.MainSceneBuildEffectPos, key)
        -- logger:info("主城建筑特效 ....play  %s", key)
        if effectConf then
            -- logger:info("主城建筑特效 ....play 222")
            local effectPanel = buildingPanel:getChildByName("effectPanel")
            effectPanel:setVisible(isShow)

            local function createMovieChip(posPanel, effectName, scale)
                posPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
                posPanel:setVisible(true)

                local movieChip = self:createUIMovieClip(effectName) --这里创建的时候，竟然会串到别的模块去。 持久特效来的，串过去了，就会有问题了
                movieChip:setAnchorPoint(0.5,0.5)
                movieChip:setScale(scale)
                movieChip:setParent(posPanel)

                movieChip:play(true, nil, nil, nil)
                buildingPanel.effect = movieChip
                -- logger:info("主城建筑特效 ....play 666")

            end


            effectPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)

            for k,v in pairs(effectConf) do
                local posPanel = effectPanel:getChildByName(v.pos)        
                createMovieChip(posPanel, v.effectName, v.scale)
            end
        end
    else
        self:showOrHideBuildEff(buildingPanel, isShow)
    end

end

-- 资源建筑特效创建
function MainScenePanel:createOrUpdateResBuildEffect(buildingPanel, buildingType, buildingIndex, isShow)
    -- if buildingPanel.effect == nil then

        local effectConf = GlobalConfig.FieldBuildEffectConf
        if effectConf then
            local effectPanel = buildingPanel:getChildByName("effectPanel")
            if effectPanel ~= nil then
                effectPanel:stopAllActions()

                -- logger:info("主城资源建筑特效 ....play key=%s type=%d", key, buildingType)
                effectPanel:setVisible(isShow)
                effectPanel:setPosition(GlobalConfig.fieldEffPos)
                effectPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
                buildingPanel.effect = effectPanel
                buildingPanel.effect.buildingType = buildingType


                local function createMovieChip(posPanel, effectName, scale)
                    -- print("~````````````")
                    posPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
                    -- posPanel:setVisible(true)

                    local movieChip = self:createUIMovieClip(effectName)
                    movieChip:setAnchorPoint(0.5,0.5)
                    movieChip:setScale(scale)
                    movieChip:setParent(posPanel)

                    local fadeTo1 = cc.FadeTo:create(0, 0)
                    local fadeTo2 = cc.FadeTo:create(0, 255)
                    local endDelay = cc.DelayTime:create(GlobalConfig.fieldEffEndDelay)
                    local seq = cc.Sequence:create(fadeTo1, endDelay, fadeTo2)
                    

                    local function callback()
                        logger:info("资源特效播完 playResEffect callback")
                        self._lockFlag = false
                        movieChip:removeFromParent()
                    end

                    movieChip:playResEffect(false, callback, nil, seq)
                    -- logger:info("主城资源建筑特效 ....play 666")
                end


                local img = effectPanel:getChildByName("img")
                img:stopAllActions()

                self:updateFieldEffectIcon(effectPanel, buildingType)
                self:fieldEffectIconAction(effectPanel)


                local pos = effectPanel:getChildByName("pos")
                pos:stopAllActions()
                pos:removeAllChildren()
                if pos ~= nil then
                    self._effIndex = buildingIndex
                    -- createMovieChip(pos, effectConf.effectName, effectConf.scale)
                end

            end
        end

    -- else
    --     buildingPanel.effect.buildingType = buildingType
    --     self:showOrHideBuildEff(buildingPanel, isShow)
    -- end

end

-- 资源建筑特效的icon
function MainScenePanel:updateFieldEffectIcon(effectPanel, buildingType)
    -- body
    if effectPanel ~= nil then
        local img = effectPanel:getChildByName("img")
        if img ~= nil then
            local url = string.format("images/mainScene/res%d.png", buildingType)
            TextureManager:updateImageView(img, url)
            -- logger:info("资源effect icon url=%s",url)
        end
    end
end

-- 资源建筑特效的icon动画
function MainScenePanel:fieldEffectIconAction(effectPanel)
    -- body
    if effectPanel ~= nil then
        local img = effectPanel:getChildByName("img")
        if img ~= nil then
            -- logger:info("资源建筑特效的icon动画......0")
            img:stopAllActions()
            img:setPositionY(GlobalConfig.fieldEffMov[1])
            img:setScale(GlobalConfig.fieldEffSca[1])
            -- local x,y = img:getPosition()            


            local delay = GlobalConfig.fieldEffDelay
            local delayTime = cc.DelayTime:create(0.04*2)
            local moveTo1 = cc.MoveTo:create(0, cc.p(0, GlobalConfig.fieldEffMov[1]))
            -- local moveTo2 = cc.MoveTo:create(delay, cc.p(0, GlobalConfig.fieldEffMov[2]))
            local scaleTo1 = cc.ScaleTo:create(0, GlobalConfig.fieldEffSca[1])
            local scaleTo2 = cc.ScaleTo:create(delay, GlobalConfig.fieldEffSca[2])
            -- local spawn = cc.Spawn:create(scaleTo2, moveTo2)
            
            local moveAction1 = cc.MoveTo:create(GlobalConfig.fieldEffMovDelay[1], cc.p(0, GlobalConfig.fieldEffMov[2]))
            local moveAction2 = cc.MoveTo:create(GlobalConfig.fieldEffMovDelay[2], cc.p(0, GlobalConfig.fieldEffMov[3]))
            local moveAction = cc.Sequence:create(moveAction1, moveAction2)
            local easeMove = cc.EaseOut:create(moveAction, GlobalConfig.fieldEffMovRate)
            local spawn = cc.Spawn:create(scaleTo2, easeMove)


            local endDelay = cc.DelayTime:create(GlobalConfig.fieldEffEndDelay)
            -- local sequence = cc.Sequence:create(scaleTo1,delayTime, spawn, moveTo1, scaleTo1, endDelay)
            local sequence = cc.Sequence:create(delayTime, spawn, moveTo1, scaleTo1, endDelay)


            local action1 = cc.RotateTo:create(GlobalConfig.fieldEffRotateDelay, GlobalConfig.fieldEffRotateAncle, GlobalConfig.fieldEffRotateAncle)
            local action2 = cc.RotateTo:create(GlobalConfig.fieldEffRotateDelay, -GlobalConfig.fieldEffRotateAncle, -GlobalConfig.fieldEffRotateAncle)
            local action = cc.RepeatForever:create(cc.Sequence:create(action1, action2))

            img:runAction(action)
            -- img:runAction(cc.RepeatForever:create(sequence))
            img:runAction(sequence)

        end
    end
end

-- 放到定时器update()里循环，每播完一次，清除标记
function MainScenePanel:loopRandomFieldEffects()
    -- logger:info("loop random ...... 0")
    if self._lockFlag == false then
        local result = self:updateRandomFieldEffects()
        self._lockFlag = result
    end
end


-- 随机播放某个资源建筑特效
function MainScenePanel:updateRandomFieldEffects()
    -- logger:info("随机播放某个资源建筑特效 .... 1")
    -- math.randomseed(os.clock())

    local index = nil
    local buildingPanel = nil
    local flag = true
    local randomPool = 43
    local tmpMap = {}

    local len = table.size(self._fieldBuildingPanelMap)
    if len == 0 then
        -- logger:error("self._fieldBuildingPanelMap == nil")
        return false
    end

    local tmpK = nil
    for k,v in pairs(self._fieldBuildingPanelMap) do
        if v ~= nil then
            local buildingBtn = v:getChildByName("buildingBtn")
            if buildingBtn ~= nil then
                local buildingInfo = buildingBtn.buildingInfo
                if buildingInfo.buildingType ~= 0 then
                    tmpMap[k] = v
                    tmpK = k
                end
            end
        end        
    end

    local tmpLen = table.size(tmpMap)
    if tmpLen == 0 then
        -- logger:info("tmpMap == nil")
        return false
    elseif tmpLen == 1 then
        -- logger:info(" #tmpMap == 1")
        buildingPanel = tmpMap[tmpK]
    elseif tmpLen > 1 then

        index = math.random(randomPool) --随机一个index（范围应该是最大index内）
        while flag do
            -- logger:info("while... ...1 index=%d", index)            
            if tmpMap[index] then
                -- logger:info("while... ...2")
                buildingPanel = tmpMap[index]
                if self._effIndex ~= index then
                    -- logger:info("随机的index =%d", index)
                    flag = false
                    self._effIndex = index
                else
                    if buildingPanel.effect then  --有的buildingPanel是没有effect特效的
                        buildingPanel.effect:stopAllActions()
                    end
                end

            end

            if flag then
                index = math.random(randomPool) --随机一个index（范围应该是最大index内）
            end
        end

    end




    local buildingInfo = buildingPanel.buildingInfo
    local buildingIndex = buildingInfo.index
    local buildingType = buildingInfo.buildingType

    local buildingBtn = buildingPanel:getChildByName("buildingBtn")
    if buildingBtn then
        buildingType = buildingBtn.buildingType
    end

    if buildingType == 0 or buildingType == 2 then --空地OR铸币所没有资源特效
        return false
    else
        self:createOrUpdateResBuildEffect(buildingPanel, buildingType, buildingIndex, true)
        -- logger:info("return true kkk ... buildingType,buildingIndex = %d %d",buildingType,buildingIndex)
        return true
    end

end


-- 显示OR隐藏建筑特效
function MainScenePanel:showOrHideBuildEff(buildingPanel, isShow)
    -- body
    local effectPanel = buildingPanel:getChildByName("effectPanel")
    if effectPanel ~= nil then
        effectPanel:setVisible(isShow)
    end
end


function MainScenePanel:updateBuildingPanel(buildingPanel, buildingType, buildingIndex)
    -- print("....测试 updateBuildingPanel....")
    local btn = buildingPanel:getChildByName("buildingBtn")
    if btn.buildingType == buildingType then
        return
    end

    local str = "images/mainScene/building_%d.png"
    local isShow = nil
    if buildingType == 0 then
        isShow = false
        if buildingIndex >= 2 and buildingIndex <= 7 then --资源建筑的空地then --资源建筑的空地
            str = "images/mainScene/building_0_%d.png"
        end

    else
        isShow = true
    end

    if buildingPanel.effect ~= nil and (buildingType >=3 and buildingType <= 6) then
        buildingPanel.effect:setVisible(isShow)
        self:updateFieldEffectIcon(buildingPanel.effect, buildingType)  --资源特效icon
    end



    local url = string.format(str, buildingType)
    --print("------------updateBuildingPanel---------", url)

    btn:loadTextureNormal(url, ccui.TextureResType.plistType)
    btn:loadTexturePressed(url, ccui.TextureResType.plistType)
    btn.buildingType = buildingType

    btn:setTouchEnabled(false)
end

function MainScenePanel:setAllBuildingNameVisible(visible)
    for _, buildingPanel in pairs(self._fieldBuildingPanelMap) do
        -- self:setBuildingNameVisible(buildingPanel,false,true,visible) --当前需求不显示资源点标题
    	self:setBuildingNameVisible(buildingPanel,visible,true,visible)
    end

    for _, buildingPanel in pairs(self._sceneBuildingPanelMap) do
        self:setBuildingNameVisible(buildingPanel, true)
    end
    -- 作用：调用隐藏主界面周边按钮层
    self:dispatchEvent(MainSceneEvent.HIDE_MAIN_BTN, visible)
end

function MainScenePanel:setBuildingNameVisible(buildingPanel, visible, isField, visible2)
    -- 隐藏名字，不隐藏升级进度条
    local infoPanel = buildingPanel:getChildByName("infoPanel")
    local namePanel = infoPanel:getChildByName("namePanel")
    local barPanel = infoPanel:getChildByName("barPanel")
    local productPanel = infoPanel:getChildByName("productPanel")
    local tip = buildingPanel:getChildByName("tip")
    local info = buildingPanel.info
    
    namePanel.isShow = false

    if barPanel:isVisible() or productPanel:isVisible() or (tip~=nil and tip:isVisible()) then
        namePanel:setVisible(false)
        return
    end
    
    if isField ~= nil then
        if info ~= nil and rawget(info, 'ID') and rawget(info, 'type') then
            if info.type == 2 then
                namePanel:setVisible(true)  --铸币所
            else
                namePanel:setVisible(visible)  
            end

        end
        return
    end


    if info ~= nil and rawget(info, 'ID') and rawget(info, 'type') then
        local buildingProxy = self:getProxy(GameProxys.Building)
        local buildingInfo = buildingProxy:getBuildingInfo(info.type, info.ID)

        if buildingInfo ~= nil then
            local  isOpen = buildingProxy:isBuildingOpen(info.type, info.ID, true)
            if buildingInfo.level == 0 and isOpen then
                local closeImg = infoPanel:getChildByName("closeImg")
                if closeImg.action == false and not (info.type >= 12 and info.type <= 22) then  --部分建筑未开放，不显示铁锤
                    closeImg:setVisible(true)
                    self:getCloseAction(closeImg)
                    -- logger:info("-- 可建造图标 0---  %d %d", info.type, info.ID)
                end
            end

            if buildingInfo.level == 0 or isOpen == false then
                if not (info.type >= 12 and info.type <= 22) then
                    -- 未建造隐藏标题
                    namePanel:setVisible(false)
                    -- logger:info("-- 可建造、不可建造隐藏标题 0---  %d %d", info.type, info.ID)
                    return
                end
            end
        end
    end

    if info ~= nil and self:isCanUse(info, info.type) then
        namePanel:setVisible(false)
        return
    end
    
    namePanel.isShow = namePanel:isVisible()
    namePanel:setVisible(visible)
    
    -- 如果在屏蔽标题表里，隐藏namePanel
    if table.indexOf(GlobalConfig.hideTitle, rawget(info, 'type')) >= 0 then
        namePanel:setVisible(false)
    end
end

function MainScenePanel:hasBuildingType(table_name, buildingType)
    -- body
    local result = false
   for k,v in pairs(table_name) do
        if v == buildingType then
            result = true
        end
    end 
    return true
end

-- 未启用的建筑暂时屏蔽显示(true=要屏蔽显示)
function MainScenePanel:isCanUse(info, buildingType)
    -- body
    local result = false
    if info ~= nil and buildingType ~= nil then
        local openfn = rawget(info, 'openfn')
        if openfn == 1 then
            result = true
        end
    end
    return result
end


-----------------基地佣兵显示--------------------------

function MainScenePanel:onUpdateSoldiers()
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local soldiers = soldierProxy:getTotalSoldierList()

    for _, soldier in pairs(soldiers) do
        self:renderSoldier(soldierProxy, self._soldierPanel, soldier.typeid)
    end
end

function MainScenePanel:renderSoldier(soldierProxy, soldierPanel, typeid)

    local info = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,typeid)
    if info.show == 2 then
        return
    end

    local parent = soldierPanel:getChildByName("soldier" .. typeid)
    if parent == nil then
        return
    end
    parent:setVisible(true)
    parent:setLocalZOrder(10)

    local soldier = soldierProxy:getSoldier(typeid)
--    if parent.puppet ~= nil then

--        if soldier == nil or soldier.num == 0 then
--            NodeUtils:removeAllChild(parent, "touchPanel")
--            local touchPanel = parent:getChildByName("touchPanel")
--            if touchPanel ~= nil then
--                touchPanel.isEnabled = false
--            end
--            parent.puppet = nil
--        else --更新数量
--            local textBg = parent:getChildByName("textBg")
--            if textBg ~= nil then
--                textBg:removeFromParent()
--            end
--        end
--    end

    if soldier == nil or soldier.num == 0 then
        parent:setVisible(false)
        return
    end


    ----优化参数 佣兵数量+数量背景------------------------------------------
    local minWidth = 23                 --数字背景最小长度
    local textFontSize = 20             --数字字体大小
    local textBgHeight = 26             --数字背景高度
    local textPosY = textBgHeight/2+1   --数字Y坐标居中（其实就是数字背景高度的一半）
    local boundWidth = 4                --左边框与左边第一个数字的距离（同时也是右边框与右边第一个数字的距离）
    local posX = 25                     --整体X坐标(大于0相对佣兵往左偏移，小于0相对佣兵往右偏移)
    local posY = 0                      --整体Y坐标(大于0相对佣兵往下偏移，小于0相对佣兵往上偏移)


    
    if parent.puppet == nil then
        local realModelId = soldierProxy:getModelId(typeid)
        local url = string.format("images/soldierIcon/%d.png", realModelId)
        local defaulturl = "images/soldierIcon/101.png"
        local puppet = TextureManager:createSprite(url, defaulturl) --SpineModel.new(realModelId, parent)
        puppet:setPosition(posX, posY)
        parent:addChild(puppet)
        parent.puppet = puppet    
    end
    local contentSize = parent.puppet:getContentSize()
--    puppet:playAnimation("wait",true)


    ----22 佣兵数量+数量背景------------------------------------------
    local url = "images/common/bg_soldiernumber.png"
    local rect_table = cc.rect(3,3,3,3)
    local textBg = parent:getChildByName("textBg")
    if textBg == nil then
        textBg = TextureManager:createScale9Sprite(url,rect_table)
        textBg:setName("textBg")
        textBg:setLocalZOrder(80)
        textBg:setAnchorPoint(cc.p(0, 0.5))
        textBg:setPosition(0,0-contentSize.height/2)
        parent:addChild(textBg)
    end    

    local numTxt = textBg:getChildByName("numTxt")
    if numTxt == nil then
        numTxt = ccui.Text:create()
        numTxt:setFontName(GlobalConfig.fontName)
        numTxt:setFontSize(textFontSize)
        numTxt:setName("numTxt")
        numTxt:setColor(ColorUtils.riceColor)
        numTxt:setLocalZOrder(100)
        textBg:addChild(numTxt)
    end
    numTxt:setString(soldier.num) 

    local numSize = numTxt:getContentSize() 
    local width = 0
    if numSize.width <= minWidth/2 then
        width = minWidth
    elseif numSize.width <= minWidth then
        width = minWidth + boundWidth*2
    else
        width = numSize.width + boundWidth*2
    end
    numTxt:setPosition(width/2, textPosY)
    textBg:setContentSize(width, textBgHeight)
    
    ----22------------------------------------------------------------

    -- parent.puppet = puppet
    parent.typeid = typeid
    parent.soldier = soldier

    local touchPanel = parent:getChildByName("touchPanel")
    if touchPanel ~= nil then
        touchPanel.isEnabled = true
        touchPanel.typeid = typeid
        self:addSceneTouchEvent(touchPanel, self.onSoldierTouch)
    end

end

function MainScenePanel:onSoldierTouch(sender)
    local typeid = sender.typeid

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local soldier = soldierProxy:getSoldier(typeid)

    if self._uiSoldierInfo == nil then
        local parent = self:getLayer(ModuleLayer.UI_TOP_LAYER)
        self._uiSoldierInfo = UISoldierInfo.new(parent, self)
    end

    self._uiSoldierInfo:updateSoldierInfo(typeid, soldier)
end

-------------
function MainScenePanel:childMove(sender)
    return self._sceneMap:interceptTouchMove(sender)
end

function MainScenePanel:childBegin(sender)
    self._sceneMap:interceptTouchBegin(sender)
end

function MainScenePanel:addSceneTouchEvent(widget, callback)

    if widget.buildingPanel ~= nil then
        local buildingPanel = widget.buildingPanel
        local infoPanel = buildingPanel:getChildByName("infoPanel")
        widget.barPanel = infoPanel:getChildByName("barPanel")        
        widget.namePanel = infoPanel:getChildByName("namePanel")
        widget.productPanel = infoPanel:getChildByName("productPanel")
        widget.closeImg = infoPanel:getChildByName("closeImg")
    end

    self._sceneMap:addSceneTouchEvent(widget, self, callback)

end

function MainScenePanel:moveToBuildingPanel(buildingPanel, callback)
    self._sceneMap:moveToChild(buildingPanel, callback)
end

function MainScenePanel:getOneOfAllLand(num) --获得一个空地下标 --新手引导
    local buildingProxy = self:getProxy(GameProxys.Building)
    local allBuildingInfo = buildingProxy:getAllOutdoorBuilding()
    for _, buildingInfo in pairs(allBuildingInfo) do
        if buildingInfo.buildingType == 0 then
            if num <= 7 and buildingInfo.index <= 7 then
                return buildingInfo.index or num
            elseif num > 7 and buildingInfo.index > 7 then
                return buildingInfo.index or num
            end
        end
    end
    return num
end

function MainScenePanel:getOneOfAllLand2()   --点击引导
    local buildingProxy = self:getProxy(GameProxys.Building)
    local allBuildingInfo = buildingProxy:getAllOutdoorBuilding()
    for _, buildingInfo in pairs(allBuildingInfo) do
        if buildingInfo.buildingType == 0 then
            return buildingInfo.index or 8
        end
    end
    return 8
end

------
-- 播放升级特效
function MainScenePanel:onShowBuildingUpEffect(buildingInfo)
    local index = buildingInfo.index
    local buildingType = buildingInfo.buildingType
    local buildingProxy = self:getProxy(GameProxys.Building)
    local isFieldBuilding = buildingProxy:isFieldBuilding(buildingType)
    local buildingPanel
    local levelUpCCB
    

    -- 判断是哪种类型的建筑
    if isFieldBuilding == true then
        buildingPanel = self._fieldBuildingPanelMap[index]
    else
        buildingPanel = self._sceneBuildingPanelMap[index]
    end
    
    local sp = buildingPanel:getChildByName("sp")
    if sp == nil then
        sp = cc.Sprite:create()
        buildingPanel:addChild(sp)
        sp:setPosition(sp:getPositionX() - 10, sp:getPositionY() - 25)
        sp:setName("sp")
    end
    AudioManager:playEffect("zhuchengshengji")
    levelUpCCB = self:createUICCBLayer("rpg-upgrade", sp, nil, nil, true)
    -- 如果是官邸的话，进行放大展示  index == 1 为官邸
    if isFieldBuilding == false and index == 1 then
        sp:setScale(3)
    end
end