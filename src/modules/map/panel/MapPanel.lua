
MapPanel = class("MapPanel", BasicPanel)
MapPanel.NAME = "MapPanel"

function MapPanel:ctor(view, panelName)
    MapPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function MapPanel:finalize()
    self._worldMap:finalize()
    MapPanel.super.finalize(self)
end

function MapPanel:initPanel()
	MapPanel.super.initPanel(self)
	
    self:setTouchEnabled(false)
	self:initReqMap()
	
	self:createWorldMap()

    self:createWorldMapSky()
end

function MapPanel:initReqMap()
    require("modules.map.map.MapDef")
    require("modules.map.map.WorldMap")
    require("modules.map.map.WorldMapFloor")
    require("modules.map.map.WorldMapSky")
end

function MapPanel:createWorldMap()
    local map = WorldMap.new(self)
    
    self:addChild(map)
    
    self._worldMap = map
end

function MapPanel:createWorldMapSky()
    local mapSky = WorldMapSky.new(self)
    
    self:addChild(mapSky)
    
    self._worldMapSky = mapSky
end


-- 接收服务端坐标点建筑数据后率刷新80000
function MapPanel:onGetWorldTileInfosResp(worldTileInfos)

    self._worldMap:loadAdornment(worldTileInfos)
    self._worldMap:loadSafeRangeNode(worldTileInfos)

end

function MapPanel:updateProtectTiles(data)
    self._worldMap:updateProtectTiles(data)
end

function MapPanel:updateCityTiles()
    self._worldMap:updateCityTiles()
end

-- 本地刷新，和80000一个接口
function MapPanel:onUpdateLocalResTile()

    self._worldMap:onUpdateResTile(true)
    
end

function MapPanel:onWatchPlayerInfo(data) --TODO BUG 2379
    -- if self._watchPlayInfoPanel == nil then
    --     local topLayer = self:getLayer(ModuleLayer.UI_2_LAYER)
    --     self._watchPlayInfoPanel = UIWatchPlayerInfo.new(topLayer, self, false, nil, true)
    -- end
    -- -- self._watchPlayInfoPanel:setMialShield(true)
    -- data.tileInfo = self._curWatchWorldTileInfo
    -- self._watchPlayInfoPanel:showAllInfo(data)


    -- 城主战技能需求
    data.tileInfo = self._curWatchWorldTileInfo
    local panel = self:getPanel(MapPlayerInfoPanel.NAME)
    panel:show()
    panel:onWatchPlayerInfo(data)
end

-- 查看玩家
function MapPanel:onWatchPlayerInfoTouch(worldTileInfo)
    self._curWatchWorldTileInfo = worldTileInfo
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:watchPlayerInfoReq({playerId = worldTileInfo.buildingInfo.playerId})
end

-- 查看资源点信息
function MapPanel:onWatchResourceTouch(tileInfo)
    
    local rolePrxoy = self:getProxy(GameProxys.Role)
    local beginX, beginY = rolePrxoy:getWorldTilePos()
    tileInfo.time = rolePrxoy:calcNeedTime(RoleProxy.MarchingType_World, beginX, beginY, tileInfo.x, tileInfo.y)
    local scale = self:getIconScale(tileInfo)
    local mapGoalInfoPanel = self:getPanel(MapGoalInfoPanel.NAME)
    mapGoalInfoPanel:show({type = MapGoalInfoPanel.RESOURCE_TYPE, tileInfo = tileInfo, iconScale = scale})
end


--主城点击
function MapPanel:onCityTileTouch(worldTileInfo)
    local cityId = worldTileInfo.cityId
    if cityId == nil then
        logger:error("-- 点击城池 cityId = nil ")
        return
    end

    local rolePrxoy = self:getProxy(GameProxys.Role)
    if rolePrxoy:isFunctionUnLock(57,true) == false then
        return
    end

    local lordCityProxy = self:getProxy(GameProxys.LordCity)
    lordCityProxy:setSelectCityId(cityId)

    local data = { cityId = cityId }
    -- 主界面 则弹城池列表信息
    lordCityProxy:onTriggerNet360010Req(data)
    -- 主界面 则弹城池详细信息
    lordCityProxy:onTriggerNet360011Req(data)
    -- 玩家信息
    lordCityProxy:onTriggerNet360042Req(data)

    local mapLordCityPanel = self:getPanel(MapLordCityPanel.NAME)
    mapLordCityPanel:show()

end


--叛军战斗点击
function MapPanel:onRebelsTouch(rebelsInfo)

    -- 讨伐令不足
    local rolePrxoy = self:getProxy(GameProxys.Role)
    if rolePrxoy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) <= 0 then
        rolePrxoy:getBuyCrusadeEnergyBox(self)
        return
    end

    local mapRebelsPanel = self:getPanel(MapRebelsPanel.NAME)
    mapRebelsPanel:show( rebelsInfo )

end

--剿匪副本战斗点击
function MapPanel:onBanditDungeonBattleTouch(banditDungeon)
    -- local banditPanel = self:getPanel(BanditPanel.NAME)
    -- banditPanel:show(banditDungeon)
    -- local banditPanel = self:getPanel(BanditCityInfoPanel.NAME)
    -- banditPanel:show(banditDungeon)

    local isShow,data = self:isShowCityUI(banditDungeon)
    if isShow == true then
        local banditPanel = self:getPanel(BanditCityInfoPanel.NAME)
        banditPanel:show(data)
    else
        local teamDetail = self:getProxy(GameProxys.TeamDetail)
        teamDetail:setEnterTeamDetailType(1)
        local banditPanel = self:getPanel(BanditPanel.NAME)
        banditPanel:show(data)
    end

end

-- 点击州城
function MapPanel:onWatchCityWarTouch(posX, posY, stateStatus)
    local data = {}
    data.x = posX
    data.y = posY

    -- DID：lg加一个刷新地图操作
    self:dispatchEvent(MapEvent.WORLD_TILE_INFOS_REQ, data)


    local cityWarProxy = self:getProxy(GameProxys.CityWar)
    cityWarProxy:onTriggerNet470000Req(data)
end

-- 点击皇城
function MapPanel:onEmperorCityTouch(posX, posY)
    
    logger:info( string.format("点击皇城点，坐标：%s,%s", posX, posY))
    local emperorCityProxy = self:getProxy(GameProxys.EmperorCity)

    local data = {}
    data.cityId = emperorCityProxy:getConfigByMapKey(posX.."_"..posY).ID
    emperorCityProxy:onTriggerNet550000Req(data)
    -- todocity
--    local warOnPanel = self:getPanel(MapEmperorWarOnPanel.NAME)
--    local warPanel   = self:getPanel(MapEmperorWarPanel.NAME)

--    warPanel:show()
end




function MapPanel:isShowCityUI(data)
    -- self._dungeonProxy = self:getProxy(GameProxys.Dungeon)
    -- local type ,dunId = self._dungeonProxy:getCurrType()
    -- local cityId = self._dungeonProxy:getCurrCityType()
    -- print("isShowCityUI: type,cityId,dunId = ",type,cityId,dunId)

    local eventId = data.eventId
    local panditMonster = ConfigDataManager:getConfigById(ConfigData.PanditMonsterConfig, eventId)
    panditMonster.chapter = 1
    data._info = panditMonster


    local isShowCityUI = true    
    if panditMonster.showwinds == 0 then
        isShowCityUI = false
    end
    return isShowCityUI,data
end

-- 查看资源点界面icon缩放大小
function MapPanel:getIconScale(tileInfo)
    -- body
    local scale = 1
    if tileInfo.tileType == WorldTileType.Resource then
        local level = tileInfo.resInfo.level
        for k,info in pairs(GlobalConfig.worldMapResScaleConf) do
            if level >= info[1] and level <= info[2] then
                -- logger:info("资源点 设缩放拉拉 scale=%d tileType=%d resLv=%d",info[3],tileInfo.tileType,tileInfo.resLv)
                scale = info[3]
                return scale
            end
        end        
    end
    return scale

end

--点击空地，进行迁移逻辑
function MapPanel:onEmptyTileTouch(tileInfo)
    local x = tileInfo.x
    local y = tileInfo.y
    
    local function callback()
        self:dispatchEvent(MapEvent.WORLD_TILE_MOVE_REQ, {x = x, y = y})
    end
    
    local itemProxy = self:getProxy(GameProxys.Item)
    local itemType = 3311
    local num = itemProxy:getItemNumByType(itemType)
    local content = ""
    if num > 0 then
        local info = ConfigDataManager:getConfigById(ConfigData.ItemConfig, itemType)
        content = string.format(self:getTextWord(310), info.name, x, y)
    else
        content = string.format(self:getTextWord(309), x, y)
    end
    self:showMessageBox(content, callback) 
end

--建筑收藏
function MapPanel:onPlayerCollectTouch(tileInfo)
    local mapGoalInfoPanel = self:getPanel(MapGoalInfoPanel.NAME)
    mapGoalInfoPanel:show({type = MapGoalInfoPanel.COLLECT_TYPE, tileInfo = tileInfo})
end

--执行攻击
function MapPanel:onAttackPlayerTouch(tileInfo)
    local lordCityProxy = self:getProxy(GameProxys.LordCity)
    local isHaveSkillBuff = lordCityProxy:isHaveCitySkillBuff()
    if isHaveSkillBuff == true then
        self:showSysMessage(self:getTextWord(291010))
        return
    end

    
    --强制进攻
    local function gotoTeamModule(force)
        local force = force or 0
        local rolePrxoy = self:getProxy(GameProxys.Role)
        if rolePrxoy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) <= 0 then  --讨伐令
            rolePrxoy:getBuyCrusadeEnergyBox(self)
            return
        end
        local data = {}
        data.moduleName = ModuleName.TeamModule
        data.extraMsg = {}
        data.extraMsg.type = "world"
        data.extraMsg.tileX = tileInfo.x
        data.extraMsg.tileY = tileInfo.y
        data.extraMsg.force = force
        -- data.extraMsg.otherCityStr = string.format("%s(%d,%d)",tileInfo.buildingInfo.name, tileInfo.x, tileInfo.y)
        data.extraMsg.otherCityStr = tileInfo.buildingInfo.name
        
        local isHaveNotfight = rolePrxoy:getRoleAttrValue(PlayerPowerDefine.POWER_notFightState)
        if isHaveNotfight > 0 then
            local function useItem()
                self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
            end
            local function showBox()
                self:showMessageBox(self:getTextWord(4019),useItem)
            end
            TimerManager:addOnce(30, showBox, self)
        else
            self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
        end
    end

    if tileInfo.buildingInfo.protect > 0 then
        --判断强攻令是否存在
        local itemProxy = self:getProxy(GameProxys.Item)
        local info = ConfigDataManager:getInfoFindByOneKey("WorldHandleCostConfig", "type", 1)
        local arr = StringUtils:jsonDecode(info.forceCost)
        local forceAttTypeId = arr[1][2]
        local itemNum = itemProxy:getItemNumByType(forceAttTypeId)
        local function okcallbk()
            gotoTeamModule(1)
        end
        if itemNum > 0 then
            local messageBox = self:showMessageBox(self:getTextWord(4037),okcallbk)
        else
            self:showSysMessage(self:getTextWord(4018))
        end
    else
        gotoTeamModule()
    end

    


    
end
--执行驻军
function MapPanel:onGoStationTouch(tileInfo)
    local data = {}
    data.moduleName = ModuleName.StationModule
    data.extraMsg = {}
    data.extraMsg.tileX = tileInfo.x
    data.extraMsg.tileY = tileInfo.y
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
end
--攻击资源
function MapPanel:onAttckResourceTouch(tileInfo)
    local rolePrxoy = self:getProxy(GameProxys.Role)
    if rolePrxoy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) <= 0 then  --讨伐令
        rolePrxoy:getBuyCrusadeEnergyBox(self)
        return
    end

    --   城主战新增安全区Buff,无法被攻击的矿点会出现一个保护罩（前端需要显示）
    if rawget(tileInfo,"resProtect") == 1 then
        self:showSysMessage(self:getTextWord(291000))
        return
    end


    local lordCityProxy = self:getProxy(GameProxys.LordCity)
    local isHaveSkillBuff = lordCityProxy:isHaveCitySkillBuff()
    if isHaveSkillBuff == true then
        self:showSysMessage(self:getTextWord(291010))
        return
    end


    local worldProxy = self:getProxy(GameProxys.World)
    local info = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, tileInfo.resInfo.resPointId)
    local data = {}
    data.moduleName = ModuleName.TeamModule
    data.extraMsg = {}
    data.extraMsg.type = "world"
    data.extraMsg.isPlayerRes = rawget(tileInfo, "isPlayerRes")    
    data.extraMsg.tileX = tileInfo.x
    data.extraMsg.tileY = tileInfo.y
    data.extraMsg.legionName = tileInfo.legionName -- 传入同盟名
    data.extraMsg.subBattleType = worldProxy:getSubBattleType(info.level)
    -- data.extraMsg.otherCityStr = string.format("%s(%d,%d)",info.name, tileInfo.x, tileInfo.y)
    data.extraMsg.otherCityStr = info.name
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
end

--侦查加个查询
function MapPanel:onSpyPriceTouch(tileInfo)
    -- print("onSpyPriceTouch")
    local function dispatchSpy(force)
        local force = force or 0
        local data = {}
        data.x = tileInfo.x
        data.y = tileInfo.y
        data.force = force
        data.type = 1
        self:dispatchEvent(MapEvent.WORLD_TILE_SPY_PRICE_REQ, data)
    end

    --   城主战新增安全区Buff,无法被攻击的矿点会出现一个保护罩（前端需要显示）
    if rawget(tileInfo,"resProtect") == 1 then
        self:showSysMessage(self:getTextWord(291000))
        return
    end

    if tileInfo.buildingInfo ~= nil and tileInfo.buildingInfo.protect ~= nil and tileInfo.buildingInfo.protect > 0 then
        --判断强侦令是否存在
        local itemProxy = self:getProxy(GameProxys.Item)
        local info = ConfigDataManager:getInfoFindByOneKey("WorldHandleCostConfig", "type", 2)
        local arr = StringUtils:jsonDecode(info.forceCost)
        local forceSprTypeId = arr[1][2]
        local itemNum = itemProxy:getItemNumByType(forceSprTypeId)
        local function okcallbk()
            dispatchSpy(1)
        end
        if itemNum > 0 then
            local messageBox = self:showMessageBox(self:getTextWord(4038),okcallbk)
        else
            self:showSysMessage(self:getTextWord(4018))
        end
    else
        dispatchSpy()
    end


end

-- 进攻州城
function MapPanel:onAttackCityWar(x, y, name, legionName)
    local data = {}
    data.moduleName = ModuleName.TeamModule
    data.extraMsg = {}
    data.extraMsg.type = "attackTown"
    data.extraMsg.tileX = x
    data.extraMsg.tileY = y
    data.extraMsg.otherCityStr = name
    data.extraMsg.legionName = legionName

    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
end

-- 进攻皇城建筑
function MapPanel:onAttackEmperorCity(x, y, name, legionName)
    local data = {}
    data.moduleName = ModuleName.TeamModule
    data.extraMsg = {}
    data.extraMsg.type = "attackEmperorCity" -- 和损伤兵有关的参数 
    data.extraMsg.tileX = x
    data.extraMsg.tileY = y
    data.extraMsg.otherCityStr = name
    data.extraMsg.legionName = legionName

    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
end

-- 推送刷新地图节点Emperor
function MapPanel:onUpdataEmperorWorldNode(data)
    self._worldMap:onUpdataEmperorWorldNode(data)
end

-- 判断皇城战活动是否开启
function MapPanel:isEmperorCityUnLock()
    local proxy = self:getProxy(GameProxys.BattleActivity)
    local data = proxy:getActivityInfo()
    for k,v in pairs(data) do
        if v.activityType == ActivityDefine.SERVER_ACTION_EMPEROR_CITY then
            if v.state ~= 2 then
                return true
            end
        end
    end
    return false
end



function MapPanel:gotoTileXY(tileX, tileY)
    self._worldMap:gotoTileXY(tileX, tileY)
end

function MapPanel:initMap()
    self._worldMap:initMap()
end

function MapPanel:refreshMap()
     self._worldMap:refreshMap()
end

function MapPanel:getReqTilePos()
    return self._worldMap:getReqTilePos()
end

function MapPanel:getCurTilePos()
    return self._worldMap:getCurTilePos()
end

function MapPanel:updateTaskInfos(list)
    self._worldMap:updateTaskInfos(list)
end

-- 是否弹窗元宝不足
function MapPanel:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end

    else
        sender.callFunc()
    end

end

function MapPanel:update()
    self._worldMap:updateCityRemainTime()

    -- 更新皇城/军营倒计时
    self._worldMap:updateEmperorCityWithTime()
end

function MapPanel:onUpdateAllMarchLineResp(data)
    self._worldMap:onUpdateAllMarchLineResp(data)
end

function MapPanel:onUpdateMarchLineResp(data)
    self._worldMap:onUpdateMarchLineResp(data)
end

function MapPanel:unscheduleUpdate()
    self._worldMap:unscheduleUpdate()
end

function MapPanel:addWorldWidgetTouchList(widget, obj, callback)
    self._worldMap:addWorldWidgetTouchList(widget, obj, callback)
end

function MapPanel:addWorldWidgetTouchCancleList(widget, obj, callback)
    self._worldMap:addWorldWidgetTouchCancleList(widget, obj, callback)
end

function MapPanel:onUpdataMapSeason()
    self._worldMap:onUpdataMapSeason()
    self._worldMapSky:onUpdataMapSeason()
end