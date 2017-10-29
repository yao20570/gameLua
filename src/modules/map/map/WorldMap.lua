WorldMap = class("WorldMap", UIBaseMap)
WorldMap.__index = WorldMap

WorldMap.AppearActionTag = 100

WorldMap.MarchLineOprate_Add = 1
WorldMap.MarchLineOprate_Del = 2

local MaxMarchUICount = 50 -- 最大行军路线

function WorldMap:ctor(mapPanel)
    WorldMap.super.ctor(self)

    self._mapPanel = mapPanel
    self._oldWorldTileInfoMap = {}
    self._worldTileNodeMap = {}

    self._worldSafeNodeMap = {}
    self._touchWidgetList = {}
    self._touchCancleWidgetList = {}

    local size = self:getContentSize()
    self.halfWidth = size.width*0.5
    self.halfHeight = size.height*0.5

    self.visibleHeight = size.height
    self.mostTopY = self.visibleHeight - MapDef.mapSize.height
    self.mostRightX = size.width - MapDef.mapSize.width

    self:initTilePos()

    self._soldierProxy = mapPanel:getProxy(GameProxys.Soldier)
    self._cityWarProxy = mapPanel:getProxy(GameProxys.CityWar)
    self._emperorCityProxy = mapPanel:getProxy(GameProxys.EmperorCity)

    local mapInfoPanel = mapPanel:getPanel(MapInfoPanel.NAME)
    self._posTxt = mapInfoPanel:getChildByName("mainPanel/posBg/posTxt")
    
    self._worldLineActorMap = {}  --行军动画表
    self._worldLineMap = {}  --行军路线表

    self._myLegionPosMap = {} --我的军团的据点Map
    
    self._actionTypeNameMap = {} -- 行为对应的图片
    self._actionTypeNameMap[1] = {imgName = "bg_Selected"  , ccbName="rgb-shijie-jingong" ,  isImg = false }
    self._actionTypeNameMap[3] = {imgName = "bg_collection", ccbName="" ,                    isImg = true }
    self._actionTypeNameMap[4] = {imgName = "bg_gotogar"   , ccbName="rgb-shijian-qianwan",  isImg = false }
    self._actionTypeNameMap[5] = {imgName = "bg_Garrison"  , ccbName="rgb-shijie-zhufang" ,  isImg = false }


    -- 行军路线UI数组
    self._MarchLineUIList = {}

    -- 延迟删除的行军路线()
    self._delayRemoveMarchLineData = {}

    -- 皇城配置表 
    self._emperorCityConfigData = ConfigDataManager:getConfigData(ConfigData.EmperorWarConfig)
end

function WorldMap:finalize()
    for _,v in pairs(self._worldLineActorMap) do
        v:finalize()
    end
    self._worldLineActorMap = nil

    for k, v in pairs(self._worldLineMap) do
        v:finalize()
    end
    self._worldLineMap = nil

    self._MarchLineUIList = nil
end

function WorldMap:onEnter()
    WorldMap.super.onEnter(self)

    if not self._scene then
        local mapType = self:getMapBgType()
        self._scene = WorldMapFloor.new(MapRes.worldMapRes, mapType)
        self._scene:setMapSize( MapDef.mapSize )
        self._scene:setAlphaFloorVisible(false)

        
        self:addChild(self._scene)
    end

    self:setTileXY(self.reqTileX, self.reqTileY)
end

function WorldMap:getReqTilePos()
    return self.reqTileX, self.reqTileY
end

function WorldMap:getCurTilePos()
    return self.currTileX, self.currTileY
end

function WorldMap:onTouchBegan(touch, event)
    if self._mapPanel:isModuleVisible() ~= true then
        return false
    end
    -- return WorldMap.super.onTouchBegan(self, touch, event)
    
    local began = WorldMap.super.onTouchBegan(self, touch, event)
    if began then
        self._scene:setAlphaFloorVisible(true) 
    else
        self._scene:setAlphaFloorVisible(false) 
    end
    return began
end

function WorldMap:onTouchMoved(touch, event)
    WorldMap.super.onTouchMoved(self, touch, event)
    self._scene:setAlphaFloorVisible(true)
end

function WorldMap:initTilePos()
    local roleProxy = self._mapPanel:getProxy(GameProxys.Role)
    local worldProxy = self._mapPanel:getProxy(GameProxys.World)
    local x, y = worldProxy:getLastMoveTile()
    if x < 0 then
        x, y = roleProxy:getWorldTilePos()
    end
    if x < 0 then
        self.reqTileX = 0
        self.reqTileY = 0
        self.currTileX = self.reqTileX
        self.currTileY = self.reqTileY
    else
        self.reqTileX = x
        self.reqTileY = y
        self.currTileX = self.reqTileX
        self.currTileY = self.reqTileY
    end

end

function WorldMap:initMap()

    self:setScale(0.5)
    self:runAction(cc.ScaleTo:create(0.7, 1))

    self:requestBuildingData()

    -- 这里做优化，坐标没有刷新，就不重新计算矿点
    local roleProxy = self._mapPanel:getProxy(GameProxys.Role)
    local worldProxy = self._mapPanel:getProxy(GameProxys.World)
    local moveX, moveY = worldProxy:getLastMoveTile()
    local lastX,lastY = worldProxy:getLastInitTile()
    if lastX > 0 then
        if lastX == self.reqTileX and lastY == self.reqTileY then
            self:refreshMap()
            return
        else
            worldProxy:setLastInitTile(self.reqTileX, self.reqTileY)
        end
    elseif moveX > 0 then
        if moveX == lastX and moveY == lastY then
            self:refreshMap()
            return
        else
            worldProxy:setLastInitTile(moveX, moveY)
        end
    else
        worldProxy:setLastInitTile(self.reqTileX, self.reqTileY)
    end

    self:onUpdateResTileInfos(self.reqTileX, self.reqTileY)
end

--直接跳转到某个坐标
function WorldMap:gotoTileXY(tileX, tileY)
    if tileX == nil or tileY == nil then
        return
    end
    if tileX >= 600 then
        tileX = 599
    end
    
    if tileY >= 600 then
        tileY = 599
    end

    local dx = math.abs(self.currTileX - tileX)
    local dy = math.abs(self.currTileY - tileY)
    
    self:setTileXY(tileX, tileY)
    self:refreshCurrentTileCoor()
    
    self:renderTopPos()
    self:onUpdateResTile()    

    if dx > GlobalConfig.TileMoveX or dy > GlobalConfig.TileMoveY then
        self.reqTileX = self.currTileX
        self.reqTileY = self.currTileY
        self:requestBuildingData()
    end
    
end

function WorldMap:setTileXY(tileX, tileY)
    local pos = MapDef.worldTileToScreen(tileX, tileY)
    local x = -pos.x + self.halfWidth
    local y = -pos.y + self.halfHeight
    self:setScenePosition(cc.p(x, y))
end

function WorldMap:refreshCurrentTileCoor()
    local x,y = self._scene:getPosition()
    local pos = cc.p(self.halfWidth-x, self.halfHeight - y)
    self.currTileX, self.currTileY = MapDef.screenToWorldTile(pos)
    
    local mapInfoPanel = self._mapPanel:getPanel(MapInfoPanel.NAME)
    mapInfoPanel:setWayDir(pos.x, pos.y)

    --logger:info("tile:%d, %d, %f, %f", self.currTileX, self.currTileY, x, y)
--    local miniMapPanel = self._mapPanel:getPanel(MiniMapPanel.NAME)
--    miniMapPanel:setCurMapPos(self.currTileX, self.currTileY)

    
end


function WorldMap:onSceneMove(delta)
    local posX,posY = self._scene:getPosition()
    local newX,newY = self:adjustPosition(posX,posY,delta.x,delta.y)

    self:setScenePosition(cc.p(newX, newY))
    self:refreshCurrentTileCoor()

    --TODO 显示悬浮坐标
    self:renderTopPos()

    -- logger:info("self.halfWidth =%d , self.halfHeight=%d",self.halfWidth,self.halfHeight)
    self:onUpdateResTile()
end

-- 设置地图四季
function WorldMap:onUpdataMapSeason()
    -- 地图背景
    self:onUpdataMapBgBySeason()

    -- 重新刷新空地
    self:onUpdataMapEmptyNodeBySeason()

    
end


function WorldMap:getMapBgType()
    local mapType = MapRes.worldMapRes.bgDefauleType

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == targetPlatform
        or cc.PLATFORM_OS_IPAD == targetPlatform
        or cc.PLATFORM_OS_WINDOWS == targetPlatform then

        -- ios,win等需要显示4季，android不需要
        local seasonProxy = self._mapPanel:getProxy(GameProxys.Seasons)
        seasonIndex = seasonProxy:getCurSeason()

        local mapBgCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.MapBg, "season", seasonIndex)
        mapType = mapBgCfg.mapBg
    end

    return mapType
end

function WorldMap:onUpdataMapBgBySeason()
    local mapType = self:getMapBgType()
    self._scene:updateMapBg(MapRes.worldMapRes, mapType)

end

function WorldMap:onUpdataMapEmptyNodeBySeason()
    for k, v in pairs(self._worldTileNodeMap) do
        local worldNodeEmpty = v
        if worldNodeEmpty:getType() == WorldTileType.Empty then
            worldNodeEmpty:renderTile(worldNodeEmpty:getWorldTileInfo(), self._mapPanel, true)
        end
    end
end



-- 移动地图后刷新资源点，本地刷新
function WorldMap:onUpdateResTile(isFoce)
    local isUpdate = false

    if isFoce == true then
        isUpdate = true
    else
        local dx = math.abs(self.currTileX - (self._frontTileX or 0))
        local dy = math.abs(self.currTileY - (self._frontTileY or 0))
        if dx >= GlobalConfig.TileMoveX or dy >= GlobalConfig.TileMoveY then
            --logger:info(string.format( "================================>x = %d, y = %d", dx, dy))
            isUpdate = true
        end
    end

    if isUpdate == true then
        
        logger:info("... -- 移动地图后刷新资源点 ...")
        self._frontTileX = self.currTileX
        self._frontTileY = self.currTileY
        self:onUpdateResTileInfos(self.currTileX, self.currTileY)
    end
end

-- 渲染新的资源点出来(本地移动刷走这里)
function WorldMap:onUpdateResTileInfos(x,y)
    local worldProxy = self._mapPanel:getProxy(GameProxys.World)
    local allResTiles, safeNodeDatas = worldProxy:onGetResTileInfos2(x, y)
    -- print("... allResTiles ",allResTiles)
    self._mapPanel:onGetWorldTileInfosResp(allResTiles) -- 相关数据(新的资源点)

end


function WorldMap:onTouchEnd(touch, event)
    WorldMap.super.onTouchEnd(self, touch, event)
    -- local dx = math.abs(self.currTileX - self.reqTileX)
    -- local dy = math.abs(self.currTileY - self.reqTileY)

    -- if dx >= 2 or dy >= 2 then
    --     self.reqTileX = self.currTileX
    --     self.reqTileY = self.currTileY
    --     --self:requestBuildingData()
    --     TimerManager:remove(self.requestBuildingData, self)  --ps:. 世界拖动时，手指放开后0.5秒后，才会开始向服务器请求数据
    --     TimerManager:addOnce(100,self.requestBuildingData,self)
    -- end
    self._scene:setAlphaFloorVisible(false)
end

--同步世界数据
function WorldMap:onSysWorldData()
    local dx = math.abs(self.currTileX - self.reqTileX)
    local dy = math.abs(self.currTileY - self.reqTileY)

    if dx >= GlobalConfig.TileMoveX or dy >= GlobalConfig.TileMoveY then
        self.reqTileX = self.currTileX
        self.reqTileY = self.currTileY
        self:requestBuildingData()
        -- self:onUpdateResTile() 没用了,dx,dy 等于 0 了
        -- TimerManager:remove(self.requestBuildingData, self)  --ps:. 世界拖动时，手指放开后0.5秒后，才会开始向服务器请求数据
        -- TimerManager:addOnce(100,self.requestBuildingData,self)
    end
end

--渲染小地图
function WorldMap:renderMiniMap()
--    local panel = self._mapPanel:getPanel(MiniMapPanel.NAME)
--    panel:onMapMove(self.currTileX, self.currTileY)
end

function WorldMap:renderTopPos()

    local curTime = ClockUtils:getOsClock()
    -- logger:error("===================================>MiniMap curTime: " .. curTime ..  ", curRenderTime: " .. (self._curRenderTime or 0))
    if self._curRenderTime ~= nil and curTime - self._curRenderTime <  0.1 and curTime - self._curRenderTime >  0 then
        return
    end
    self._curRenderTime = curTime
    
    local topStr = math.abs(self.currTileX) .. "," .. (math.abs(self.currTileY))
    self._posTxt:setString(topStr)

    local worldProxy = self._mapPanel:getProxy(GameProxys.World)
    worldProxy:setLastMoveTile(self.currTileX, self.currTileY)

    self:renderMiniMap()
    
    local parent = self._posTxt:getParent() 
    parent:setVisible(true)
    
    parent:stopAllActions()
    parent:setOpacity(255)
    --两秒后消失
--    if self._isPosVisible ~= true then
        local function callback()
            parent:setVisible(false)
            self._isPosVisible = nil
        end
        
        local action = cc.FadeTo:create(2, 0)
        parent:runAction(cc.Sequence:create(action, cc.CallFunc:create(callback)))
--    end
--    
--    self._isPosVisible = true
    
end

function WorldMap:setScenePosition(pos)
    local y = math.max(math.min(pos.y, 0), self.mostTopY)
    local x = math.max(math.min(0,pos.x), self.mostRightX)
    -- logger:info("坐标mostRightX, mostTopY, x, y = %d %d %d %d", self.mostRightX, self.mostTopY, x, y)
    local new_pos = cc.p(x, y)
    self._scene:setPosition(new_pos)
    self._scene:setMapPosition(new_pos)
end

function WorldMap:requestBuildingData()
    logger:info("========请求建筑信息=x:%d=====y:%d================", self.reqTileX, self.reqTileY)
    self._mapPanel:dispatchEvent(MapEvent.WORLD_TILE_INFOS_REQ, {x = self.reqTileX, y = self.reqTileY})

end

function WorldMap:adjustPosition(x, y, dx, dy)
    local newX = x + dx
    local newY = y + dy

    if self:isInnerArea(newX, newY) == false then
        newX = x
        newY = y
        
        if self._showEnd == false then
        else
            self._mapPanel:showSysMessage(TextWords:getTextWord(315))
            self._showEnd = false
            TimerManager:addOnce(1000, self.showEndMsg, self)
        end
    end

    return newX,newY
end

function WorldMap:showEndMsg()
    self._showEnd = true
end

function WorldMap:isInnerArea(mapx,mapy)
    local mid = cc.p(self.halfWidth-mapx, self.halfHeight - mapy)
    local x = mid.x
    local y = mid.y
    local p0 = MapDef.mapOrigin
    local pl = MapDef.mapLeftPoint
    local pr = MapDef.mapRightPoint
    local pt = MapDef.mapTopPoint

    local k1 = (y-p0.y)/(pl.y-p0.y) - (x-p0.x)/(pl.x-p0.x)
    local k2 = (y-p0.y)/(pr.y-p0.y) - (x-p0.x)/(pr.x-p0.x)

    local k3 = (y-pl.y)/(pt.y-pl.y) - (x-pl.x)/(pt.x-pl.x)
    local k4 = (y-pr.y)/(pt.y-pr.y) - (x-pr.x)/(pt.x-pr.x)
    if k1 > 0 and k2 > 0 and k3 < 0 and k4 < 0 then
        return true
    else
        return false
    end
end

function WorldMap:updateTaskInfos(list)
    local newKeyMap = {}
    for _, taskTeamInfo in pairs(list) do
        local type = taskTeamInfo.type
        local startPos = nil
        local targetPos = nil
        if type == 1 or type == 2 then --进攻 返回方向 
            startPos = cc.p(taskTeamInfo.startx, taskTeamInfo.starty)
            targetPos = cc.p(taskTeamInfo.x, taskTeamInfo.y)
        elseif type == 3 or type == 5 then
            startPos = cc.p(taskTeamInfo.x, taskTeamInfo.y)
            targetPos =  cc.p(taskTeamInfo.x, taskTeamInfo.y)
        elseif type == 4 then
            startPos = cc.p(taskTeamInfo.startx, taskTeamInfo.starty)
            targetPos = cc.p(taskTeamInfo.x, taskTeamInfo.y)
        end
        if startPos ~= nil then
            local lineKey = startPos.x .. "-" .. startPos.y .. "-" .. targetPos.x .. "-" .. targetPos.y
            local actorKey = taskTeamInfo.id .. lineKey
            if self._worldLineActorMap[actorKey] == nil then
                local pos1 = MapDef.worldTileToScreen(startPos.x, startPos.y)
                local pos2 = MapDef.worldTileToScreen(targetPos.x, targetPos.y)
                local key = targetPos.x .. "_" .. targetPos.y

                -- 行军军队和目标特效
                local uiLineActor = self:drawDottedLineActor(pos1, pos2, key, type, lineKey)
                if uiLineActor ~= nil then
                    local alreadyTime = taskTeamInfo.totalTime - self._soldierProxy:getRemainTime("teamTask"..taskTeamInfo.id)                    
                    local data = {}
                    data.alreadyTime = alreadyTime
                    data.totalTime = taskTeamInfo.totalTime
                    uiLineActor:setMoveData(data)
                    self._worldLineActorMap[actorKey] = uiLineActor

                    taskTeamInfo.updateTime = now
                end
            end
            newKeyMap[actorKey] = true
        end
    end
    
    local removeKeyList = {}
    for key, _ in pairs(self._worldLineActorMap) do
    	if newKeyMap[key] == nil then
            table.insert(removeKeyList, key)
    	end
    end

    for _, key in pairs(removeKeyList) do
        local uiLineActor = self._worldLineActorMap[key]        
        -- 移除行军军队
        if uiLineActor ~= nil then
            uiLineActor:finalize()
        end
        self._worldLineActorMap[key] = nil
    end

end

function WorldMap:drawDottedLineActor(pos1, pos2, key, type, lineKey)
    local tileInfo = self._oldWorldTileInfoMap[key]
    
    -- 判断是否是州城
    local townConfig = self._cityWarProxy:getConfigByMapKey(key)

    -- 判断是否是皇城 
    local emperorCityConfig = self._emperorCityProxy:getConfigByMapKey(key)
    
    local action = self._actionTypeNameMap[type]
    local targetNode = cc.Node:create()
    
    local nodesLayer = self._scene:getLayer(WorldMapFloor.Layer_Type_Nodes)
    nodesLayer:addChild(targetNode)
    if action ~= nil and townConfig == nil and emperorCityConfig == nil then
    --if action ~= nil then
        local url = ""
        if action.isImg == true then        
            url = string.format("images/map/%s.png", action.imgName)
            local img = TextureManager:createImageView(url)
            targetNode:addChild(img)
            targetNode.isCCB = false
        else            
            local ccb = self._mapPanel:createUICCBLayer(action.ccbName, targetNode) 
            targetNode.ccb = ccb
        end
    end
    
    targetNode:setLocalZOrder(100000000)
    self:setTargetNodeScale(tileInfo, targetNode)

    local dottedLineActor = UIDottedLineActor.new(pos1, pos2, targetNode)
    return dottedLineActor, nil

    
end

function WorldMap:getTargetNodeScale(tileInfo)
    local scale = 1
    if tileInfo ~= nil then
        if tileInfo.tileType == WorldTileType.Resource then
            local resInfo = tileInfo.resInfo
            local resType = resInfo.resType
            local pointInfo = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, tileInfo.resInfo.resPointId)

            scale = pointInfo.size / 100
        end
    end
    return scale
end

function WorldMap:setTargetNodeScale(tileInfo, targetNode)
    local scale = self:getTargetNodeScale(tileInfo)
    -- targetNode:setBuildTxtScale(scale)
end
-- 固定的缩放操作
function WorldMap:setBuildingScale(tileBuilding,tileInfo)
    if tileBuilding ~= nil and tileInfo ~= nil then
        local banditDungeon = tileBuilding:getBanditDungeonInfo()
        if tileInfo.tileType == WorldTileType.Resource and banditDungeon == nil then
            local resInfo = tileInfo.resInfo
            local level = resInfo.level
            for k,info in pairs(GlobalConfig.worldMapResScaleConf) do--根据资源储量设置大小
                if level >= info[1] and level <= info[2] then
                    tileBuilding:setScales(info[3])
                    -- tileBuilding:setResTxtScale(1/info[3])
                    -- tileBuilding:setEffectScale(1/info[3])
                    
                    -- logger:info("资源点 设缩放 scale=%d tileType=%d level=%d",info[3],tileInfo.tileType,level)
                    return
                end
            end
        end
        -- 默认缩放大小
        -- tileBuilding:setScale(GlobalConfig.worldMapBuildScale)
        -- tileBuilding:setScale(1)
        tileBuilding:setBuildTxtScale(GlobalConfig.worldMapBuildScale, GlobalConfig.worldMapFontScale)
    end
end

--直接刷新地图
function WorldMap:refreshMap()
    -- logger:error("... --直接刷新地图 refreshMap ...")
    if self._lastWorldTileInfos ~= nil then
        self:loadAdornment(self._lastWorldTileInfos)
        self:loadSafeRangeNode()
        -- self:onUpdateResTile()
        -- logger:info("... --直接刷新地图 refreshMap ...",table.size(self._lastWorldTileInfos))
        -- self:onUpdateResTileInfos(self.reqTileX, self.reqTileY)
    end
    -- if self._lastRespWorldTileInfos ~= nil then
    --     self:loadAdornment(self._lastRespWorldTileInfos)
    -- end
end


function WorldMap:getSafeRangeNodeFromPool()
    local safeRangeNode = nil

    -- 对象池有则取对象池的
    if self._safeRangeNodePool ~= nil then
        safeRangeNode = self._safeRangeNodePool:pop()
        if safeRangeNode~= nil then
            safeRangeNode:setVisible(true)

            return safeRangeNode
        end
    end

    safeRangeNode = UIWorldFloorSafe.new()

    local safeRangeLayer = self._scene:getLayer(WorldMapFloor.Layer_Type_Safe_Range)
    safeRangeLayer:addChild(safeRangeNode)
    return safeRangeNode
end

function WorldMap:removeSafeRangeNodeToPool(safeRangeNode)
    
    if self._safeRangeNodePool == nil then
        self._safeRangeNodePool = Stack.new()
    end

    self._safeRangeNodePool:push(safeRangeNode)
    safeRangeNode:setVisible(false)
    safeRangeNode:setPosition(cc.p(-10000, -10000))
end

function WorldMap:loadSafeRangeNode()
    local offset = 5

    local minX = self.currTileX - offset
    minX = math.max(minX, 0)
    minX = math.min(minX, 599)

    local maxX = self.currTileX + offset
    maxX = math.max(maxX, 0)
    maxX = math.min(maxX, 599)

    local minY = self.currTileY - offset
    minY = math.max(minY, 0)
    minY = math.min(minY, 599)

    local maxY = self.currTileY + offset
    maxY = math.max(maxY, 0)
    maxY = math.min(maxY, 599)

    for key, safeNode in pairs(self._worldSafeNodeMap) do
        local x, y = MapDef.getTilePosByKey(key)
        if math.abs(x - self.currTileX) > offset or math.abs(y - self.currTileY) > offset then
            self:removeSafeRangeNodeToPool(safeNode)
            self._worldSafeNodeMap[key] = nil
        end
    end


    -- 安全区域
    local worldProxy = self._mapPanel:getProxy(GameProxys.World)
    for x = minX, maxX do
        for y = minY, maxY do
            local safeNodeType = worldProxy:getSafeNodeType(x, y)
            if safeNodeType ~= nil then
                local key = MapDef.getKeyByTilePos(x, y)
                local pos = MapDef.worldTileToScreen(x, y)
                if self._worldSafeNodeMap[key] == nil then
                    local safeNode = self:getSafeRangeNodeFromPool()
                    safeNode:renderTile(x, y, safeNodeType)
                    safeNode:setPosition(pos)
                    self._worldSafeNodeMap[key] = safeNode
                end
            end
        end
    end

end

function WorldMap:loadAdornment(worldTileInfos)
    -- 本地数据
    
    
    --这里的数据不只是单纯的替换  
    --self._lastWorldTileInfos = worldTileInfos
    --]]
    --替换逻辑 change  by  jy
    ---[[
    if not self._lastWorldTileInfos then
        self._lastWorldTileInfos = {}
    end
    for _,worldTileInfo in pairs(worldTileInfos) do
        local x = worldTileInfo.x
        local y = worldTileInfo.y
        local key = x .. "_" .. y
        self._lastWorldTileInfos[key] = worldTileInfo
    end
    --]]


    -- logger:error("!!!!!WorldMap:loadAdornment!!!!before!!:%s,%d", tostring(self:isSceneRunAction()), #worldTileInfos)

    if self:isSceneRunAction() then
        -- 还在移动，不渲染，移动完毕后。再刷新
        return
    end


    local worldProxy = self._mapPanel:getProxy(GameProxys.World)
    local banditProxy = self._mapPanel:getProxy(GameProxys.BanditDungeon)
    
    for _, worldTileInfo in pairs(self._lastWorldTileInfos) do
        local x = worldTileInfo.x
        local y = worldTileInfo.y
        local key = x .. "_" .. y

        local oldTileInfo = self._oldWorldTileInfoMap[key]

        -- 州城临时打印
--        if x == 111 and y == 222 then
--            logger:info("州城(199, 199)")
--            logger:info("州城(199, 199)")
--        end

        local isSameTile = self:isSameTile(worldTileInfo, oldTileInfo) -- 判断是否相同

        --先做一下容错处理，一下情况就不处理了
        if oldTileInfo ~= nil and worldTileInfo ~= nil then            
            if (worldTileInfo.tileType == WorldTileType.Resource and oldTileInfo.tileType == WorldTileType.Building ) then
                -- 1，老的是建筑了，新的是资源（前后版本配置表修改导致的）
                isSameTile = true
            end

            if oldTileInfo.tileType == WorldTileType.City  then                
                -- 2，老的是主城
                worldTileInfos[_] = nil
                isSameTile = true
            end
        end

        -- 有黄巾贼
        local tileNode = self._worldTileNodeMap[key]
        local isUpdateBandit = self:isUpdateBandit(tileNode, x, y)

        if isSameTile == false or isUpdateBandit then
            if worldTileInfo ~= nil then
                self:addWorldBuilding(worldTileInfo) -- 添加世界点
            end
        end
    end
    -- 世界尽头的边界建筑
    self:addBorderBuilding(worldTileInfos)

    for _, worldTileInfo in pairs(worldTileInfos) do
        local x = worldTileInfo.x
        local y = worldTileInfo.y
        self._oldWorldTileInfoMap[x .. "_" .. y] = worldTileInfo
    end

    local rd = 5
    for key, worldTileInfo in pairs(self._oldWorldTileInfoMap) do
        if math.abs(worldTileInfo.x - self.currTileX) > rd or math.abs(worldTileInfo.y - self.currTileY) > rd then
            self._oldWorldTileInfoMap[key] = nil
            self._lastWorldTileInfos[key] = nil
        end
    end
    
    for key, v in pairs(self._worldTileNodeMap) do
        if math.abs(v._worldTileInfo.x - self.currTileX) > rd or math.abs(v._worldTileInfo.y - self.currTileY) > rd then
            local tileNode = self._worldTileNodeMap[key]
            if tileNode ~= nil then
                self:removeWorldNodeToPool(tileNode)
                self._worldTileNodeMap[key] = nil
            end
        end
    end


    --self._isFirstLoad = false
end


function WorldMap:updateProtectTiles(worldTileInfos)
    -- logger:error("!!!!!---WorldMap:updateProtectTiles---")
    for _, worldTileInfo in pairs(worldTileInfos) do
        local x = worldTileInfo.x
        local y = worldTileInfo.y
        local key = x .. "_" .. y

        local tileNode = self._worldTileNodeMap[key]
        if tileNode ~= nil then
            -- print("... 先删除旧的格子==========",key)       
            self:removeWorldNodeToPool(tileNode)
            self._worldTileNodeMap[key] = nil
        end
        
        local tileType = worldTileInfo.tileType
        if tileType ~= WorldTileType.Building then
            return
        end

        local pos = MapDef.worldTileToScreen(x, y)
        local zorder = 1000 * (1000 - y) + x
        local worldBuilding = self:getWorldNodeFromPool(tileType)
        worldBuilding:renderTile(worldTileInfo, self._mapPanel)
        worldBuilding:setPosition(pos)
        worldBuilding:setLocalZOrder(zorder)
        self:setBuildingScale(worldBuilding, worldTileInfo)
        self._worldTileNodeMap[key] = worldBuilding

    end
end
-- 点击城主建筑回调刷新
function WorldMap:updateCityTiles()
    for _, worldTileInfo in pairs(self._oldWorldTileInfoMap) do
        local x = worldTileInfo.x
        local y = worldTileInfo.y
        local key = x .. "_" .. y

        local lordCityProxy = self._mapPanel:getProxy(GameProxys.LordCity)
        local isPlacePos = lordCityProxy:isLordCityPlacePos(x, y)
        if isPlacePos then
            local tileNode = self._worldTileNodeMap[key]
            if tileNode then
                tileNode:renderTile(worldTileInfo, self._mapPanel) -- 重新渲染
            end
        end

    end
end

function WorldMap:updateCityRemainTime()
    for _, worldTileInfo in pairs(self._oldWorldTileInfoMap) do
        local x = worldTileInfo.x
        local y = worldTileInfo.y
        local key = x .. "_" .. y

        local lordCityProxy = self._mapPanel:getProxy(GameProxys.LordCity)
        local isPlacePos = lordCityProxy:isLordCityPlacePos(x, y)
        if isPlacePos and worldTileInfo.cityId then
            local state,_ = lordCityProxy:getCityStateAndTime(worldTileInfo.cityId)
            if state == 2 or state == 3 then  --准备中、争夺中，并且可看见
                local tileNode = self._worldTileNodeMap[key]
                if tileNode then
                    tileNode:renderTile(worldTileInfo, self._mapPanel)
                end
            end
        end
    end
end

-- 推送刷新地图节点Emperor
function WorldMap:onUpdataEmperorWorldNode(data)
    local key = data.x .."_"..data.y
    local tileNode = self._worldTileNodeMap[key]
    if tileNode then
        if tileNode:getType() == WorldTileType.EmperorCity then
            -- 刷新地图
            self._mapPanel:dispatchEvent(MapEvent.WORLD_TILE_INFOS_REQ, data)
        end
    end
end

-- 更新皇城/军营倒计时
function WorldMap:updateEmperorCityWithTime()
    for i, info in pairs(self._emperorCityConfigData) do
        local key = info.dataX.."_"..info.dataY 
        local tileNode = self._worldTileNodeMap[key]
        if tileNode and tileNode:getType() == WorldTileType.EmperorCity then
            tileNode:updateEmperorCityWithTime()
        end
    end
end

-- 渲染世界的尽头
function WorldMap:addBorderBuilding(worldTileInfos)

    -- 渲染用的世界尽头的节点
    if self._oldWorldNodeNoneRender == nil then
        self._oldWorldNodeNoneRender = {}
    end

    -- 世界尽头节点的对象池
    if self._oldWorldNodeNonePool == nil then
        self._oldWorldNodeNonePool = List.new()
    end

    -- 将渲染的全放回对象池
    for k, v in pairs(self._oldWorldNodeNoneRender) do        
        v:setVisible(false);
        self._oldWorldNodeNonePool:pushBack(v)
    end
    self._oldWorldNodeNoneRender = {}



    local addValue = GlobalConfig.TileDT+1
    -- if self.reqTileX < addValue+1 or self.reqTileX > 599-addValue or self.reqTileY < addValue+1 or self.reqTileY > 599-addValue  then
    --     addValue = addValue+1
    -- end

    -- local bx = self.reqTileX - addValue
    -- local by = self.reqTileY - addValue
    -- local ex = self.reqTileX + addValue
    -- local ey = self.reqTileY + addValue

    local bx = self.currTileX - addValue
    local by = self.currTileY - addValue
    local ex = self.currTileX + addValue
    local ey = self.currTileY + addValue

    
    for x=bx, ex do
        for y=by, ey do
            if x < 0 or x > 599 or y < 0 or y > 599 then

                for _,v in pairs(worldTileInfos) do
                    if v.x == x and v.y == y then
                        -- print("... 重复的世界尽头坐标 跳过 ...",x,y)
                        break
                    end 
                end

                -- print("... WorldMap 世界尽头的边界 ...",x,y)
                local sprite = self._oldWorldNodeNonePool:popFront()
                if sprite == nil then
                    local resId = 99
                    local url = string.format("images/map/empty%d.png", resId)
                    sprite = TextureManager:createSprite(url)

                    local nodesLayer = self._scene:getLayer(WorldMapFloor.Layer_Type_Nodes)
                    nodesLayer:addChild(sprite)   
                end
                table.insert(self._oldWorldNodeNoneRender, sprite)
                local pos = MapDef.worldTileToScreen(x,y)
                sprite:setPosition(pos)
                sprite:setVisible(true)
                sprite:setLocalZOrder(999 + 2000 - (x + y))
            end
        end
    end

end

-- 从ObjectPool获取tileNode
function WorldMap:getWorldNodeFromPool(tileType)
    local tileNode = nil

    -- 对象池有则取对象池的
    if self._worldNodePool ~= nil and self._worldNodePool[tileType] ~= nil then
        tileNode = self._worldNodePool[tileType]:pop()
        if tileNode~= nil then
            tileNode:setVisible(true)
            -- tolua.cast(tileNode,UIWorldNodeBuilding)
            return tileNode
        end
    end

    -- 对象池没有则new
    if tileType == WorldTileType.Building then
        tileNode = UIWorldNodeBuilding.new(WorldTileType.Building)

    elseif tileType == WorldTileType.Resource then
        tileNode = UIWorldNodeResource.new(WorldTileType.Resource)

    elseif tileType == WorldTileType.Rebels then
        tileNode = UIWorldNodeRebels.new(WorldTileType.Rebels)

    elseif tileType == WorldTileType.BanditDungeon then
        tileNode = UIWorldNodeBanditDungeon.new(WorldTileType.BanditDungeon)
    elseif tileType == WorldTileType.CityWar and GlobalConfig.isOpenTownFight then
        tileNode = UIWorldCityWar.new(WorldTileType.CityWar)	
    elseif tileType == WorldTileType.City then
        tileNode = UIWorldNodeCity.new(WorldTileType.City)    
    elseif tileType == WorldTileType.EmperorCity then -- 皇城
        tileNode = UIWorldNodeEmperorCity.new(WorldTileType.EmperorCity)	
    else
        tileNode = UIWorldNodeEmpty.new(WorldTileType.Empty)
        -- parent:addChild(tileNode,-99)
        -- return
    end

    local nodesLayer = self._scene:getLayer(WorldMapFloor.Layer_Type_Nodes)
    nodesLayer:addChild(tileNode)

    local nameLayer = self._scene:getLayer(WorldMapFloor.Layer_Type_Nodes_Name)
    tileNode:setNameParent(nameLayer)

    return tileNode
end

-- 移除tileNode放回ObjectPool
function WorldMap:removeWorldNodeToPool(worldNode)
    local nodeType = worldNode:getType()

    if self._worldNodePool == nil then
        self._worldNodePool = {}
    end

    if self._worldNodePool[nodeType] == nil then
        self._worldNodePool[nodeType] = Stack.new()
    end

    self._worldNodePool[nodeType]:push(worldNode)
    worldNode:setVisible(false)
    worldNode:setPosition(cc.p(-10000, -10000))
end

function WorldMap:addWorldBuilding(worldTileInfo)

    local tileType = worldTileInfo.tileType  -- 除了资源，默认是空地3， 其他后续赋值
    local x, y = worldTileInfo.x, worldTileInfo.y
    local key = x .. "_" .. y

    

    
    local pos = MapDef.worldTileToScreen(x, y)
    local zorder = 1000 * (1000 - y) + x

    
    local banditDungeonProxy = self._mapPanel:getProxy(GameProxys.BanditDungeon)
    local banditDungeon = banditDungeonProxy:getBanditDungeon(x, y)
    if banditDungeon ~= nil then
        tileType = WorldTileType.BanditDungeon
    end


    local tileNode = self._worldTileNodeMap[key]
    if tileNode ~= nil then
        if tileNode:getType() == tileType and tileNode:getType() ~= WorldTileType.CityWar then -- todo:先做最小影响的修改，后续待优化
            --同一类型则刷新
            tileNode:renderTile(worldTileInfo, self._mapPanel, banditDungeon)
            tileNode:setPosition(pos)
            return
        else
            --print("... 先删除旧的格子==========",key, "新格子类型:", worldTileInfo.tileType)
            self:removeWorldNodeToPool(tileNode)
            self._worldTileNodeMap[key] = nil
        end
    end

    local worldNode = self:getWorldNodeFromPool(tileType) -- 强行获取相同类型的节点做添加
    worldNode:renderTile(worldTileInfo, self._mapPanel, banditDungeon)
    worldNode:setPosition(pos)
    if tileType == WorldTileType.Empty then
        worldNode:setLocalZOrder(0)
    else
        worldNode:setLocalZOrder(zorder)
    end

    self:setBuildingScale(worldNode, worldTileInfo)
    self._worldTileNodeMap[key] = worldNode -- 加入节点key
    
    for key, uiLineActor in pairs(self._worldLineActorMap) do
        local tx, ty = uiLineActor:getTargetPosition()
        if tx == pos.x and ty == pos.y then
            local targetNode = uiLineActor:getTargetNode()
            if targetNode then
                self:setTargetNodeScale(worldTileInfo, targetNode)
                self:runAppearAction(targetNode, 0.5)
            end
        end
    end

    self:runAppearAction(worldNode, 0.5)
end
-- 动作，会造成闪烁刷新
function WorldMap:runAppearAction(worldNode, dt)
    local action = cc.FadeTo:create(dt, 255)
    action:setTag(WorldMap.AppearActionTag)
    worldNode:setCascadeOpacityEnabled(true)
    worldNode:setOpacity(0)
    worldNode:stopActionByTag(WorldMap.AppearActionTag)
    worldNode:runAction(action)
end

--判断是否为一样的建筑
function WorldMap:isSameTile(tileInfo1, tileInfo2)
    if tileInfo1 == nil or tileInfo2 == nil then
        return false
    end
    
    local key = tileInfo1.x .. "_" .. tileInfo1.y
    
    local roleProxy = self._mapPanel:getProxy(GameProxys.Role)
    local myLegionName = roleProxy:getLegionName()
    
    if myLegionName ~= tileInfo1.legionName then --不是我军团的，判断之前是不是在我军团的格子里面
        if self._myLegionPosMap[key] ~= nil then --之前在的军团我看过这个据点。我要与他扯开关系
            self._myLegionPosMap[key] = nil
            return false
        end
    end
    
    if (myLegionName == tileInfo1.legionName and myLegionName ~= "") and  --没军团 且Building-- or myLegionName == ""
      tileInfo1.tileType == WorldTileType.Building then
        if self._myLegionPosMap[key] == nil then --之前不是我军团的，要刷新
            self._myLegionPosMap[key] = true
            return false
        end
    end
    -- todocity
    -- 州城刷新判断
    if GlobalConfig.isOpenTownFight then
        if tileInfo1.tileType == WorldTileType.CityWar then
            -- 州城状态、队伍数量不一致则刷新
            local townInfo = tileInfo1.townInfo
            local oldTownInfo = nil 
            if self._worldTileNodeMap[key]:getType() == WorldTileType.CityWar then
                oldTownInfo = self._worldTileNodeMap[key]:getOldCityWarTownInfo() -- 旧节点
            end
            local oldAttackNum   = oldTownInfo == nil and 0 or oldTownInfo.attackNum
            local oldDefendNum   = oldTownInfo == nil and 0 or oldTownInfo.defendNum
            local oldStateStatus = oldTownInfo == nil and 0 or oldTownInfo.stateStatus

            local attackNum   = townInfo.attackNum
            local defendNum   = townInfo.defendNum
            local stateStatus = townInfo.stateStatus
            -- id是否相同
            local townId = oldTownInfo == nil and 0 or oldTownInfo.townId
            local curId = self._cityWarProxy:getConfigByMapKey(key).ID

            -- 时间控件刷新
            local isShow = true
            if oldTownInfo == nil then
                isShow = false
            else
                local isVisible = self._worldTileNodeMap[key]:getTownTimeTxtVisible()
                if townInfo.nextStateTime ~= 0 and isVisible == false then
                    isShow = false
                end
            end
            
            return oldAttackNum == attackNum and oldDefendNum == defendNum and oldStateStatus == stateStatus and townId == curId and isShow
        elseif tileInfo2.tileType == WorldTileType.CityWar then
            if tileInfo1.tileType == WorldTileType.Empty then -- 第二次刷直接过滤
                return true
            end
        end
    end

    -- 判断是否刷新皇城
    if tileInfo1.tileType == WorldTileType.EmperorCity then
        local cityInfo = tileInfo1.cityInfo
        local oldCityInfo = nil 
        if self._worldTileNodeMap[key]:getType() == WorldTileType.EmperorCity then
            oldCityInfo = self._worldTileNodeMap[key]:getOldEmperorCityInfo() 
        end
        local oldLeigonName = oldCityInfo ~= nil and oldCityInfo.legionName or ""
        local oldCityStatus = oldCityInfo ~= nil and oldCityInfo.cityStatus or 0
        local curLeigonName = cityInfo.legionName
        local curCityStatus = cityInfo.cityStatus

        -- id是否相同
        local cityId = oldCityInfo ~= nil and oldCityInfo.cityId or 0
        local curId = cityInfo.cityId

        -- 速度是否相同
        local oldSpeed = oldCityInfo ~= nil and oldCityInfo.integralSpeed or 0
        local curSpeed = cityInfo.integralSpeed

        return oldLeigonName == curLeigonName and oldCityStatus == curCityStatus and cityId == curId and oldSpeed == curSpeed
    elseif tileInfo2.tileType == WorldTileType.EmperorCity then
        if tileInfo1.tileType == WorldTileType.Empty then -- 第二次刷直接过滤
            return true
        end
    end

    --叛军是否更新
    local rebelInfo1 = tileInfo1.rebelInfo
    local rebelInfo2 = tileInfo2.rebelInfo    
    if rebelInfo1 == rebelInfo2 then
        -- 只有都为nil才相等
    elseif rebelInfo1 == nil or rebelInfo2 == nil then
        return false
    elseif rebelInfo1.nowHp ~= rebelInfo2.nowHp then
        return false
    end

    -- 民忠值前后不一致重新刷新
    local count01 = tileInfo1.loyaltyCount
    local count02 = tileInfo2.loyaltyCount
    if count01 ~= count02 then
        return false
    end

    
    local flag = true
    local keyList = {"tileType", "legionName"}
    for _, key in pairs(keyList) do
    	if tileInfo1[key] ~= tileInfo2[key] then
    	    flag = false
    	    break
    	end
    end

    local keyList = {"playerId", "name", "level", "buildIcon", "protect", "icon",
        "degree", "degreemax", "pendant", "banMove","skills"}
    if flag == true then
        local buildingInfo1 = rawget(tileInfo1, "buildingInfo")
        local buildingInfo2 = rawget(tileInfo2, "buildingInfo")
        if buildingInfo1 and buildingInfo2 then
            for _, key in pairs(keyList) do
                if buildingInfo1[key] ~= buildingInfo2[key] then
                    flag = false
                    break
                end
            end
        end
    end    

    local keyList = {"resType", "resId", "resLv", "resPointId"}
    if flag == true then
        local resInfo1 = rawget(tileInfo1,"resInfo")
        local resInfo2 = rawget(tileInfo2,"resInfo")
        if resInfo1 and resInfo2 then
            for _, key in pairs(keyList) do
                if resInfo1[key] ~= resInfo2[key] then
                    flag = false
                    break
                end
            end
        end
    end

    return flag
end

--判断这个格子是否剿匪副本更新
function WorldMap:isUpdateBandit(worldTileNode, x, y)

    if worldTileNode == nil then
        -- logger:error("!!!!!WorldMap:isUpdateBandit!!!!worldTileNode!!!null!!")
        return false
    end

    local oldBanditDungeon = worldTileNode:getBanditDungeonInfo()

    local banditDungeonProxy = self._mapPanel:getProxy(GameProxys.BanditDungeon)
    local newBanditDungeon = banditDungeonProxy:getBanditDungeon(x, y)
    if (oldBanditDungeon == nil and newBanditDungeon ~= nil) or 
            (oldBanditDungeon ~= nil and newBanditDungeon == nil) then
            -- logger:error("... 格子更新剿匪 :%d,%d",x,y)
        return true
    end

    if oldBanditDungeon ~= nil and newBanditDungeon ~= nil then
        local isBug = worldTileNode:getBg():isVisible() and newBanditDungeon.remainRestTime > 0
        -- logger:error("... 格子是否更新剿匪 是不是bug:%d,%d,%d,%d,%s", x, y, oldBanditDungeon.eventId, newBanditDungeon.eventId, tostring(isBug))
        return oldBanditDungeon.eventId ~= newBanditDungeon.eventId or isBug
    end

    return false

end


function WorldMap:onSelectBuildingEvent(touch)
    local pos = touch:getLocation()

    local isHitTouchWidget = self:isHitTouchWidget(pos, self._touchWidgetList) -- 点到自定义，直接中断
    if isHitTouchWidget then
        return 
    end

    local isHitTouchCancleWidget = self:isHitTouchWidget(pos, self._touchCancleWidgetList)
    if isHitTouchCancleWidget then
        return 
    end

    local screenPos = self._scene:convertToNodeSpace(pos)
    local tileX, tileY = MapDef.screenToWorldTile(screenPos) -- 
    local worldTileNode = self._worldTileNodeMap[tileX .. "_" .. tileY]
    -- self._mapPanel:showSysMessage(tileX.."---"..tileY)
    if worldTileNode then
        worldTileNode:onClickEvent()
    end
end

----------------------------------------------行军路线------------------------------------------------------



function WorldMap:onUpdateAllMarchLineResp(data)
    if data.rs ~= 0 then
        return
    end

    self:resetWorldMap(data)
end

function WorldMap:onUpdateMarchLineResp(data)
    if data.type == WorldMap.MarchLineOprate_Add then
        local goData = self:getDelayRemoveMarchLineData(data.teamInfo.teamId)
        if goData ~= nil then
            rawset(data.teamInfo, "goData", goData)
        end
        self:addMarchLineUI(data.teamInfo)

    elseif data.type == WorldMap.MarchLineOprate_Del then
        local index = self:getIndexByTeamId(data.teamInfo.teamId)
        self:delMarchLineUI(index)

    end
end

-- 停止行军路线的更新(地图模块关闭时)
function WorldMap:unscheduleUpdate()
    for k, v in pairs(self._MarchLineUIList) do
        v:setVisible(false)
    end

    TimerManager:remove(self.delayAddMarchLineUI, self)
end


-- 重置行军路线
function WorldMap:resetWorldMap(data)
    self._tempTeamInfoMap = { }
    for k, v in pairs(data.teamInfoList) do
        self._tempTeamInfoMap[v.teamId] = v        
    end

    for k, v in pairs(self._MarchLineUIList) do
        local marchData = v:getMarchData()
        if self._tempTeamInfoMap[marchData.teamId] == nil then
            local index = self:getIndexByTeamId(marchData.teamId)
            self:delMarchLineUI(index)
        end
    end

    self:delayAddMarchLineUI()
end

-- 延迟加载行军路线
function WorldMap:delayAddMarchLineUI()
    
    local taskTeamShortInfo = nil
    for k, v in pairs(self._tempTeamInfoMap) do
        self._tempTeamInfoMap[k] = nil
        taskTeamShortInfo = v
        break
    end

    if taskTeamShortInfo ~= nil then
        self:addMarchLineUI(taskTeamShortInfo)
        TimerManager:addOnce(0.01, self.delayAddMarchLineUI, self)
    end
end

-- 添加行军路线
function WorldMap:addMarchLineUI(taskTeamShortInfo)
    local uiMarchLine = self:getMarchLineUIByTeamId(taskTeamShortInfo.teamId)
    if uiMarchLine == nil then           
        if #self._MarchLineUIList >= MaxMarchUICount then             
            self:delMaxMarchLineUI()
        end  
        
        uiMarchLine = self:getMarchLineUIFromPool()
        table.insert(self._MarchLineUIList, uiMarchLine)    

    end

    uiMarchLine:updateUI(taskTeamShortInfo)

    --     
    if taskTeamShortInfo.type == SoldierProxy.March_Atk then
        local roleProxy = self._mapPanel:getProxy(GameProxys.Role)
        local playerId = roleProxy:getPlayerId()
        if taskTeamShortInfo.playerId == playerId then
            local temp = StringUtils:fined64ToAtom(taskTeamShortInfo.teamId)
            logger:info("add delayRemoveMarchLineData === > teamId low:%s, high:%s", temp.low, temp.high)
            self._delayRemoveMarchLineData[taskTeamShortInfo.teamId] =  taskTeamShortInfo
        end
    end
end

function WorldMap:delMaxMarchLineUI()

    local roleProxy = self._mapPanel:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()
    local legionId = roleProxy:getLegionId()
   -- local x, y = roleProxy:getWorldTilePos()
    -- 先删除其它玩家的
    for k, v in pairs(self._MarchLineUIList) do
        local marchData = v:getMarchData()
        if marchData.legionId ~= legionId then
            self:delMarchLineUI(k)
            return
        end
    end

    -- 没有其它玩家的，就删同盟的
    for k, v in pairs(self._MarchLineUIList) do
        local marchData = v:getMarchData()
        if marchData.playerId ~= playerId then
            self:delMarchLineUI(k)
            return
        end
    end
end

-- 通过itemId获取对应的行军路线index
function WorldMap:getMarchLineUIByTeamId(teamId)
    local index = self:getIndexByTeamId(teamId)
    return self._MarchLineUIList[index]
end

-- 通过itemId获取对应的行军路线index
function WorldMap:getIndexByTeamId(teamId)
    for k, v in pairs(self._MarchLineUIList) do
        local marchData = v:getMarchData()
        if marchData.teamId == teamId then
            return k
        end
    end
    return nil
end

-- 删除行军路线
function WorldMap:delMarchLineUI( index )
    local marchLine = self._MarchLineUIList[index]
    if marchLine ~= nil then        
        self:removeMarchLineUIToPool(marchLine)

        table.remove(self._MarchLineUIList, index)

        -- 数据延后删除，让进攻返回类型的行军路线回溯,获取返回始点
        local marchData = marchLine:getMarchData()
        if self:getDelayRemoveMarchLineData(marchData.teamId) ~= nil then
            TimerManager:addOnce(2000, function()
                local temp = StringUtils:fined64ToAtom(marchData.teamId)
                logger:info("del delayRemoveMarchLineData === > teamId low:%s, high:%s", temp.low, temp.high)
                self._delayRemoveMarchLineData[marchData.teamId] = nil
            end, self)
        end
    end
end

-- 通过teamId查询延迟删除的数据
function WorldMap:getDelayRemoveMarchLineData(teamId)
    local temp = StringUtils:fined64ToAtom(teamId)
    logger:info("del delayRemoveMarchLineData === > teamId low:%s, high:%s", temp.low, temp.high)
    return self._delayRemoveMarchLineData[teamId]
end

function WorldMap:getMarchLineUIFromPool()
    local marchLineUI = nil

    -- 对象池有则取对象池的
    if self._marchLineUIPool ~= nil then
        marchLineUI = self._marchLineUIPool:pop()
        if marchLineUI~= nil then
            marchLineUI:setVisible(true)

            return marchLineUI
        end
    end

    marchLineUI = UIMarchLine.new(self, self._mapPanel, self._scene)

    return marchLineUI
end

function WorldMap:removeMarchLineUIToPool(marchLineUI)

    if self._marchLineUIPool == nil then
        self._marchLineUIPool = Stack.new()
    end

    self._marchLineUIPool:push(marchLineUI)
    marchLineUI:setVisible(false)
end

-- 添加点击事件控件回调表
function WorldMap:addWorldWidgetTouchList(widget, obj, callback)
    table.insert(self._touchWidgetList, {widget = widget, obj = obj, callback = callback})
end

-- 添加点击事件控件回调表
function WorldMap:addWorldWidgetTouchCancleList(widget, obj, callback)
    table.insert(self._touchCancleWidgetList, {widget = widget, obj = obj, callback = callback})
end

function WorldMap:isHitTouchWidget(pos, list)
    local touchWidgetList = {}
    if #list == 0 then
        return false
    end

    for _, data in pairs(list) do
        if data.widget:hitTest(pos) == true then
            table.insert(touchWidgetList, data)
        end
    end

    if #touchWidgetList > 0 then
        local data = touchWidgetList[1]
        data.callback(data.obj) -- 执行， 如果return true ，不响应地板点击
        logger:info("长度打印，WorldWidgetTouchList："..#list)
        return true
    end
    return false
end