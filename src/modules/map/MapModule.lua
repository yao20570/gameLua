
MapModule = class("MapModule", BasicModule)

-- 行军陆行测试启用
local __________test_____________ = false 

function MapModule:ctor()
    MapModule .super.ctor(self)
    
    self.isFullScreen = false
    self.showActionType = ModuleShowType.Animation
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_2_LAYER

    self.isLayoutNode = false

    self._view = nil
    self._loginData = nil
    self:initRequire()
end

function MapModule:initRequire()
    require("modules.map.event.MapEvent")
    require("modules.map.view.MapView")

end

function MapModule:finalize()
    MapModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function MapModule:initModule()
    MapModule.super.initModule(self)
    self._view = MapView.new(self.parent)
    self._systemProxy = self:getProxy(GameProxys.System)
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
    self:addEventHandler()
end

function MapModule:addEventHandler()
    self._view:addEventListener(MapEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(MapEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:addEventListener(MapEvent.WORLD_TILE_INFOS_REQ, self, self.onGetWorldTileInfosReq)
    self._view:addEventListener(MapEvent.WORLD_TILE_SPY_PRICE_REQ, self, self.onWorldTilePriceReq)
    self._view:addEventListener(MapEvent.WORLD_TILE_MOVE_REQ, self, self.onWorldTileMoveReq)
    self._view:addEventListener(MapEvent.WORLD_NEAR_SEARCH_REQ, self, self.onWorldSearchReq)
    self._view:addEventListener(MapEvent.BUY_ENERGY_REQ, self, self.buyEnergtReq)

    self._view:addEventListener(MapEvent.ATTCK_REBELS_REQ, self, self.onAttackRebels)
    self._view:addEventListener(MapEvent.MARCH_TIME_REQ, self, self.onReqMarchTime)
    
    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80000, self, self.onGetWorldTileInfosResp)
    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80002, self, self.onWorldTilePriceResp)
    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80005, self, self.onWorldTileMoveResp)
    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80012, self, self.onGetMarchTimeResp)
    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80015, self, self.onWorldSearchResp)
--    self:addEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80003, self, self.onUpdateTeamInfoResp)
    self:addProxyEventListener(GameProxys.Soldier, AppEvent.TASK_TEAM_INFO_UPDATE, self, self.onUpdateTeamInfoResp)
    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80016, self, self.onUpdateWorldResp)
    -- self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20013, self, self.buyEnergtResp)
    -- self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20011, self, self.canBuyEnergtResp)
    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80100, self, self.onUpdateAllMarchLineResp)
    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80101, self, self.onUpdateMarchLineResp)
    
    self:addEventListener(AppEvent.M2M_MAIN_EVENT, AppEvent.WATCH_WORLD_TILE, self, self.onWatchWorldTileHandler)
    -- self:addEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, self, self.onEnterScene)

    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_UPDATE_CUR_POS, self, self.onWatchWorldTileHandler)

    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)

    self:addProxyEventListener(GameProxys.BanditDungeon, AppEvent.PROXY_BANDIT_DUNGEON_UPDATE, self, self.onUpdateBanditDungeon)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_BUILDING_MOVE, self, self.onBuildingMove)

    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_NEWGIFT, self, self.onShowExpPanel)

    self:addProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REBELS_GO_TO_TILE, self, self.onGotoTileXY)

    self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_UPDATE, self, self.updateCityWarInfo) -- 点击州城显示
    self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_BATTLE_REPORT, self, self.onOpenTownReportModule) 
    self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_TOWN_RANK, self, self.onOpenTownRankModule) 

    self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_TOWN_TRADE, self, self.onOpenTownTradeModule) 
    
    self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_TOWN_MINE, self, self.onUpdateMyTownPanel) 
	self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_RED_POINT, self, self.updateMyTownRedPoint) 
    self:addProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_MINI_FLAG, self, self.onUpdateMyTownFlag) 

	self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_SKILL, self, self.onSkillInfoUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_INFO, self, self.updateLordCityInfo)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_VOTEINFO, self, self.onVoteInfoUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_UPDATE, self, self.updateCityTiles)
    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_MAP_CLICK, self, self.updateEmperorCityInfo) -- 点击皇城显示
    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_WARON_UPDATE, self, self.onUpdataEmperorWarOnPanel) -- 皇城争夺同步推送状态刷新
    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_UPDATE_WORLD, self, self.onUpdataEmperorWorldNode) -- 皇城事件推送刷新
    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_SHOW_STATE, self, self.showEmperorCityState) -- 显示皇城战状态
    self:addProxyEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE, self, self.onUpdataMapSeason) -- 四季更新
    
end

function MapModule:removeEventHander()
    self._view:removeEventListener(MapEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(MapEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:removeEventListener(MapEvent.WORLD_TILE_INFOS_REQ, self, self.onGetWorldTileInfosReq)
    self._view:removeEventListener(MapEvent.WORLD_TILE_SPY_PRICE_REQ, self, self.onWorldTilePriceReq)
    self._view:removeEventListener(MapEvent.WORLD_TILE_MOVE_REQ, self, self.onWorldTileMoveReq)
    self._view:removeEventListener(MapEvent.WORLD_NEAR_SEARCH_REQ, self, self.onWorldSearchReq)
    self._view:removeEventListener(MapEvent.BUY_ENERGY_REQ, self, self.buyEnergtReq)


    
    self._view:removeEventListener(MapEvent.ATTCK_REBELS_REQ, self, self.onAttackRebels)
    self._view:removeEventListener(MapEvent.MARCH_TIME_REQ, self, self.onReqMarchTime)
    
    self:removeEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80000, self, self.onGetWorldTileInfosResp)
    self:removeEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80002, self, self.onWorldTilePriceResp)
    self:removeEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80005, self, self.onWorldTileMoveResp)
    self:removeEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80012, self, self.onGetMarchTimeResp)
    self:removeEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80015, self, self.onWorldSearchResp)
    -- self:removeEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80003, self, self.onUpdateTeamInfoResp)
    self:removeProxyEventListener(GameProxys.Soldier, AppEvent.TASK_TEAM_INFO_UPDATE, self, self.onUpdateTeamInfoResp)    
    self:removeEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80016, self, self.onUpdateWorldResp)
    -- self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20013, self, self.buyEnergtResp)
    -- self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20011, self, self.canBuyEnergtResp) 
    self:removeEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80100, self, self.onUpdateAllMarchLineResp)   
    self:removeEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80101, self, self.onUpdateMarchLineResp)
    
    self:removeEventListener(AppEvent.M2M_MAIN_EVENT, AppEvent.WATCH_WORLD_TILE, self, self.onWatchWorldTileHandler)
    -- self:removeEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, self, self.onEnterScene)
    
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)

    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_UPDATE_CUR_POS, self, self.onWatchWorldTileHandler)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)

    self:removeProxyEventListener(GameProxys.BanditDungeon, AppEvent.PROXY_BANDIT_DUNGEON_UPDATE, self, self.onUpdateBanditDungeon)
    
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_BUILDING_MOVE, self, self.onBuildingMove)

    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_NEWGIFT, self, self.onShowExpPanel)

    self:removeProxyEventListener(GameProxys.Rebels, AppEvent.PROXY_REBELS_GO_TO_TILE, self, self.onGotoTileXY)
    
    self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_UPDATE, self, self.updateCityWarInfo)
    self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_BATTLE_REPORT, self, self.onOpenTownReportModule) 
    self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_TOWN_RANK, self, self.onOpenTownRankModule) 

    self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_TOWN_TRADE, self, self.onOpenTownTradeModule) 
    self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_TOWN_MINE, self, self.onUpdateMyTownPanel) 
    self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_RED_POINT, self, self.updateMyTownRedPoint) 
    self:removeProxyEventListener(GameProxys.CityWar, AppEvent.PROXY_WARCITY_MINI_FLAG, self, self.onUpdateMyTownFlag) 

    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_SKILL, self, self.onSkillInfoUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_INFO, self, self.updateLordCityInfo)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_VOTEINFO, self, self.onVoteInfoUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_UPDATE, self, self.updateCityTiles)  
     
    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_MAP_CLICK, self, self.updateEmperorCityInfo) -- 点击皇城显示
    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_WARON_UPDATE, self, self.onUpdataEmperorWarOnPanel) -- 皇城争夺同步推送状态刷新
    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_UPDATE_WORLD, self, self.onUpdataEmperorWorldNode) -- 皇城事件推送刷新
    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_SHOW_STATE, self, self.showEmperorCityState) -- 显示皇城战状态
    self:removeProxyEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE, self, self.onUpdataMapSeason) -- 四季更新
end

function MapModule:onOpenModule(extraMsg)
    MapModule.super.onOpenModule(self)
    self._view:initMap()
    AudioManager:playWorldMusic()

    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.RoleInfoModule })

    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.MainSceneModule })
    -- 打开再隐藏
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.LegionSceneModule })
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.LegionModule })

    -- 每次打开世界界面隐藏黄巾贼面板
    self._view:hideBanditPanel()
    -- self:sendServerMessage(AppEvent.NET_M8,AppEvent.NET_M8_C80003, {})
    self:onUpdateTeamInfoResp()
    self:updateRoleInfoHandler()
    self:updateMyTownRedPoint()

    local proxy = self:getProxy(GameProxys.Role)
    local name = proxy:getRoleName() or ""
    if GuideManager:isStartGuide() ~= true and name ~= "" then
        local systemProxy = self:getProxy(GameProxys.System)
        local enterInfo = systemProxy:getCacheInfoByType(ClientCacheType.WORLD_ENTER)
        if enterInfo == nil then
            local sendData = { }
            sendData.enter = 1
            systemProxy:updateProtoGeneratedMessage(ClientCacheType.WORLD_ENTER, sendData)
            -- 过场云动作消失后执行操作
            TimerManager:addOnce(GlobalConfig.moduleJumpAnimationDelay, self.afterAnimationShowHelp, self)
            -- -- 过场云动作消失后执行操作
        end
    end
    -- 防止在mapmodule出现其他不需要出现的toolbarmodule控件
    self:afterAnimationCall()

    -- 告诉服务端进入场景
    self._systemProxy:onTriggerNet30105Req( { type = 0, scene = GlobalConfig.Scene[3] })
    
    -- 请求当前在世界上，所有的简要队伍信息
    if __________test_____________ then        
        local xx = { }
        xx.rs = 0
        xx.teamInfoList = { }
        for i = 1, 50 do
            local x = math.random(1, 50)
            local testData = { }
            testData.startX = 4 + i*4
            testData.startY = 400 + i
            testData.endX = 1
            testData.endY = 2 
            testData.type = 1
            testData.alreadyTime = 0
            testData.totalTime = 600 
            testData.playerId = 8
            testData.legionId = 9
            testData.teamId = i
            table.insert(xx.teamInfoList, testData)
        end
        self:onUpdateAllMarchLineResp(xx)
    else
        -- 请求当前在世界上，所有的简要队伍信息
        self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80100, { })
    end
    
    
    
    -- 进入场景
    local function sceneEventReq()
        local systemProxy = self:getProxy(GameProxys.System)
        systemProxy:onTriggerNet30105Req( { type = 0, scene = GlobalConfig.Scene[4]})
    end
    TimerManager:addOnce(1000, sceneEventReq, self)

    -- 请求一下皇城战相关状态
    self._emperorCityProxy:onTriggerNet550004Req({})
end

function MapModule:afterAnimationCall()
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:sendNotification(AppEvent.PROXY_BAG_OPENMAP)
end

function MapModule:onHideModule()
    MapModule.super.onHideModule(self)
    AudioManager:playSceneMusic()
    if self._view ~= nil then
        self._view:hideOtherPanel()
    end

    self._view:mapPanelUnscheduleUpdate()

    self:sendNotification(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,{moduleName = ModuleName.RoleInfoModule})

    self._systemProxy:onTriggerNet30105Req({type = 1, scene = GlobalConfig.Scene[3]})

    -- 进入场景
    local function sceneEventReq()
        local systemProxy = self:getProxy(GameProxys.System)
        systemProxy:onTriggerNet30105Req( { type = 1, scene = GlobalConfig.Scene[4]})
    end
    TimerManager:addOnce(1000, sceneEventReq, self)
end

---------------------
function MapModule:onGetWorldTileInfosResp(data)
    -- print(".. 不止 80000 的返回处理 .. ")
    if data.rs == 0 then
        --杞寲鏁版嵁
        local x = data.x
        local y = data.y
        -- print(".... 80000 鏁版嵁閲?", x, y, table.size(data.worldTileInfos))
        local time = os.clock()

        local serverWorldTileInfoMap = {}
        for _, worldTileInfo in pairs(data.worldTileInfos) do
            if worldTileInfo == nil then
                -- print("...服务端发的数据 worldTileInfo = nil ...")
            end
            local tileX =  worldTileInfo.x
            local tileY = worldTileInfo.y
            if worldTileInfo.tileType == WorldTileType.Building then
                worldTileInfo.buildingInfo.x = tileX
                worldTileInfo.buildingInfo.y = tileY

            elseif worldTileInfo.tileType == WorldTileType.Resource then
                rawset(worldTileInfo, "isPlayerRes", true)

            end
            serverWorldTileInfoMap[tileX .. "_" .. tileY] = worldTileInfo -- 以 坐_标 当作key值，存储建筑信息
        end

        local worldProxy = self:getProxy(GameProxys.World)
        local cityWarProxy = self:getProxy(GameProxys.CityWar)

        local allWorldTileInfos = {}
        local dt = GlobalConfig.TileDT
        for i=x - dt, x + dt do
            for j=y - dt, y + dt do
                local worldTileInfo = serverWorldTileInfoMap[i .. "_" .. j]
                
                -- 服务端有下发
                if worldTileInfo then
                    if worldTileInfo.tileType == WorldTileType.Resource then  --资源点有行军/采集状态，则要拿一下资源点信息
                        local resInfo = worldProxy:getTileByPos2(i,j)
                        if resInfo == nil then
                            --资源点数据为空，则手动置为空地数据
                            logger:error("... 资源点有行军/采集状态，但资源点数据为空: x=%d, y=%d",i,j)
                            return
                        else
                            -- print("... 拿一下资源点信息", i,j)
                            local tileType = worldProxy:getTileTypeByResType(resInfo.restype)
                            worldTileInfo.tileType = tileType
                            worldTileInfo.resInfo = resInfo
                        end

                    elseif worldTileInfo.tileType == WorldTileType.CityWar and GlobalConfig.isOpenTownFight then -- 州城数据【townInfo】
                        -- 接收到郡城数据存储好时间
                        local nextStateTime = worldTileInfo.townInfo.nextStateTime
                        --if nextStateTime > 0 then 
                            worldProxy:setTownRemainTime(i .. "_" .. j, nextStateTime)
                        --end
                    elseif worldTileInfo.tileType == WorldTileType.EmperorCity then
                        -- 接收到皇城数据存储好时间
                        local nextStateTime = worldTileInfo.cityInfo.nextStateTime
                        worldProxy:pushRemainTime(i .. "_" .. j, nextStateTime)
                        -- 打印滑动界面收到的
                        --self:showEmperorCityLog(worldTileInfo.cityInfo)
                    end
                end

                -- 服务端无下发
                if worldTileInfo == nil then  --服务端不发空地和资源点的数据过来
                    worldTileInfo = {}
                    worldTileInfo.x = i
                    worldTileInfo.y = j
                    
                    local resInfo = worldProxy:getTileByPos2(i,j) -- 没有的话自己获取                   
                    if resInfo == nil then
                        --资源点数据为空，则手动置为空地数据
                        -- print("...--资源点数据为空，则手动置为空地数据 ...",i,j)
                        worldTileInfo.buildingInfo = {}
                        worldTileInfo.tileType = WorldTileType.Empty
                    else
                        local tileType = worldProxy:getTileTypeByResType(resInfo.restype)
                        if tileType == WorldTileType.Resource then
                            worldTileInfo = nil  --这里不用资源点了
                        else
                            worldTileInfo.tileType = tileType
                            worldTileInfo.resInfo = resInfo
                        end
                    end
                end

                if worldTileInfo then
                    table.insert(allWorldTileInfos, worldTileInfo)
                end

            end
        end

        -- print("... 80000 瀹㈡埛绔殑澶勭悊鑰楁椂 寰楀埌鐨勬暟鎹噺...", os.clock() - time, table.size(allWorldTileInfos))
        -- allWorldTileInfos.isResp = true

        worldProxy:setCurTilesServerData(allWorldTileInfos)

        -- 更新服务端格子
        self._view:onGetWorldTileInfosResp(allWorldTileInfos) -- 空地和网络数据
                
        -- 更新本地资源格子（服务端取消了某个资源格子下发，本地没比较，不知道更新了）
        self._view:onUpdateLocalResTile()
    end

    
end

function MapModule:onWorldTilePriceResp(data)
    if data.rs == 0 then
        if data.type == 1 then
          --二级提示框，是否侦查
          local function callback()
                local sendData = {}
                sendData.type = 2
                sendData.x = data.x
                sendData.y = data.y
                sendData.force = data.force or 0
                self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80002, sendData)
          end
            self:showMessageBox(string.format(self:getTextWord(307), data.price),callback)
        elseif data.type == 2 then --跳转到邮箱见面
            
            local _data = {}
            _data.moduleName = ModuleName.MailModule
            _data.extraMsg = {type = "mailInfos",mailId = data.mailId,report = data.report}
            -- 打开邮箱界面，并传递数据，
            self:sendNotification(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,_data)
        end
    end
end

function MapModule:onChatPersonInfoResp(data)
    if data.rs == 0 then 
        if self:isModuleShow(ModuleName.FriendModule) == true
            or self:isModuleShow(ModuleName.RankModule) == true 
            or self:isModuleShow(ModuleName.ChatModule) == true then
        else
            self._view:onWatchPlayerInfo(data)  --查看玩家信息
            
            local worldProxy = self:getProxy(GameProxys.World)
            local buildingInfo = worldProxy:updateCurBuildingServerData(data.info)
            if buildingInfo ~= nil then
                -- 更新服务端格子
                -- print("-- 更新服务端格子")
                self._view:onGetWorldTileInfosResp(buildingInfo)
            end

        end
    end
end

function MapModule:onWorldTileMoveResp(data)
    if data.rs == 0 then
        self._view:gotoTileXY(data.x, data.y)
        -- self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80000, {x = data.x, y = data.y})
        self:onGetWorldTileInfosReq({x = data.x, y = data.y})

        local soldierProxy = self:getProxy(GameProxys.Soldier)
        soldierProxy:clearAllList() --搬家成功清除所有队列
    end
end

function MapModule:onWorldSearchResp(data)
    if data.rs == 0 then
--        for k,v in pairs(data.worldTileInfos) do
--            print(v.x,v.y)
--        end
        self._view:updateTileInfos(data.checkInfos)
    end
end
function MapModule:onUpdateTeamInfoResp()
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local data = soldierProxy:getTaskTeamInfo()
    self._view:updateTeamInfos(data)
end

--无条件刷新格子信息
function MapModule:onUpdateWorldResp(data)
    local x, y = self._view:getReqTilePos()
    -- self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80000, {x = x, y = y})
    -- print("... --无条件刷新格子信息 ...", x, y)
    self:onGetWorldTileInfosReq({x = x, y = y})
end

------------------------------
function MapModule:onGetWorldTileInfosReq(data)
    -- print("... 这里也会请求数据吗 80000 ...",data.x, data.y)
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80000, data)
    
    -- local worldProxy = self:getProxy(GameProxys.World)
    -- local allResTiles = worldProxy:onGetResTileInfos2(data.x, data.y)
    -- print("... allResTiles ",allResTiles)
    -- self._view:onGetWorldTileInfosResp(allResTiles)

end

-- ------------------------------
-- function MapModule:onUpdateResTileInfos(x,y)    
--     local worldProxy = self:getProxy(GameProxys.World)
--     local allResTiles = worldProxy:onGetResTileInfos2(x, y)
--     print("...本地拖动更新 allResTiles ",table.size(allResTiles))
--     self._view:onGetWorldTileInfosResp(allResTiles)

-- end

--刷新行军路线
function MapModule:onUpdateAllMarchLineResp(data)
    self._view:onUpdateAllMarchLineResp(data)

end

--刷新行军路线
function MapModule:onUpdateMarchLineResp(data)
    self._view:onUpdateMarchLineResp(data)

end

function MapModule:onWorldTilePriceReq(data)
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80002, data)
end

function MapModule:onWorldTileMoveReq(data)
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80005, data)
end

function MapModule:onWorldSearchReq(data)
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80015, data)
end

function MapModule:onWatchWorldTileHandler(data)
    self._view:gotoTileXY(data.tileX, data.tileY)
end

function MapModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function MapModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end


function MapModule:buyEnergtReq(data)
    -- self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20013, {})
end

function MapModule:buyEnergtResp(data)
    if data.rs == 0 then
        self.price = data.price
        -- self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20011, {})
    end
end

function MapModule:canBuyEnergtResp(data)
    if data.rs == 1 then
        -- local curPrice = self._roleProxy:getEnergyNeedMoney()
        --print("哈哈哈哈哈")
        local content = string.format(self:getTextWord(507),self.price)
        self:showMessageBox(content,callback)
    end
end

function MapModule:updateRoleInfoHandler()
    self._view:onRoleInfoUpdateResp() 
end

--更新剿匪副本信息
--需要重新刷新一遍，因为坐标有可能修改
function MapModule:onUpdateBanditDungeon(data)
    self._view:onUpdateBanditDungeon(data)
end

--坐标迁移
function MapModule:onBuildingMove(data)
    local miniPanel = self._view:getPanel(MiniMapPanel.NAME)
    miniPanel:setSelfPosition()

    self._view:gotoTileXY(data.x, data.y)

    local mapInfoPanel = self._view:getPanel(MapInfoPanel.NAME)
    mapInfoPanel:updatePos()
end


function MapModule:onAttackRebels(data)
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80001, data)

    local openPanelData = {}
    openPanelData.moduleName = ModuleName.TeamModule
    openPanelData.extraMsg = {}
    openPanelData.extraMsg.panelName = "TeamWorkPanel"
    openPanelData.extraMsg.type = "rebels"   
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, openPanelData)
end

function  MapModule:onReqMarchTime(data)
    --请求行军时间
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80012, {x = data.x ,y = data.y})
end

function MapModule:onGetMarchTimeResp(data)
    if data.rs == 0 then
        --print("onGetRunTimeResp^^^^^^   %d",data.time)
        self._view:onGetMarchTimeResp(data)
    end
end

function MapModule:onShowExpPanel()
    TimerManager:addOnce(2250, function()
        local systemProxy = self:getProxy(GameProxys.System)
        local enterInfo = systemProxy:getCacheInfoByType(ClientCacheType.WORLD_ENTER)
        if enterInfo == nil then
            --存缓存
            local sendData = {}
            sendData.enter = 1
            systemProxy:updateProtoGeneratedMessage(ClientCacheType.WORLD_ENTER, sendData)
            --新手结束后 现在不展示世界玩法了、
            --self._view:showExpPanel()
        end
    end, self) 
end

function MapModule:onGotoTileXY(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.RebelsModule })
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.ActivityCenterModule })
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.ChatModule })
    self._view:gotoTileXY(data.x, data.y)
end

function MapModule:updateCityTiles(data)    
    self._view:updateCityTiles()
end

function MapModule:updateLordCityInfo(data)    
    self._view:updateLordCityInfo()
end

function MapModule:onVoteInfoUpdate(data)    
    self._view:onVoteInfoUpdate()
end

function MapModule:onSkillInfoUpdate(data)    
    self._view:onSkillInfoUpdate()
end
function MapModule:onResetModuleCallback()
    if self._view == nil then
        return
    end

    local itemBuffProxy = self:getProxy(GameProxys.ItemBuff)
    local isProtect = itemBuffProxy:isNeedUpdateProtect()
    self:onProtectUpdate(isProtect and 1 or 0)    
end

function MapModule:onProtectUpdate(protectState)
    local worldProxy = self:getProxy(GameProxys.World)
    local buildingInfo = worldProxy:updateCurBuildingProtectState(protectState)
    if buildingInfo ~= nil then
        -- print("-- 更新格子保護罩~~~~！！！！！")
        self._view:updateProtectTiles(buildingInfo)
    end
end

-- 第一次进入世界图，打开玩法帮助
function MapModule:afterAnimationShowHelp()
    --self._view:showExpPanel() -- 
end

-- 点击刷新返回
function MapModule:updateCityWarInfo(data)
    local cityWarProxy = self:getProxy(GameProxys.CityWar)
    local townStatus = cityWarProxy:getTownInfo().townStatus
    
    local warPanel = self:getPanel(MapCityWarPanel.NAME)
    local warOnPanel = self:getPanel(MapCityWarOnPanel.NAME)

    -- 接收到消息号打开界面
    -- 无界面
    if warPanel:isVisible() == false and warOnPanel:isVisible() == false and townStatus ~= 2 then
        warPanel:show()
        warPanel:updateCityWarInfo()
    elseif warPanel:isVisible() == false and warOnPanel:isVisible() == false and townStatus == 2 then
        warOnPanel:show()
        warOnPanel:updateCityWarInfo()
    elseif warPanel:isVisible() == true and townStatus ~= 2 then -- 有界面只刷新
        warPanel:updateCityWarInfo()
    elseif warOnPanel:isVisible() == true and townStatus == 2 then
        warOnPanel:updateCityWarInfo()
    elseif warPanel:isVisible() == true and townStatus == 2 then -- 界面切换，宣战回调打开warOn
        warPanel:hide()
        local function openWarOnPanel()
            -- 打开warOn界面
            local warOnPanel = self:getPanel(MapCityWarOnPanel.NAME)
            warOnPanel:show()
            warOnPanel:updateCityWarInfo()
        end
        TimerManager:addOnce(500, openWarOnPanel, self)
    end

    -- 刷新地图
    if data.x ~= nil and data.y ~= nil then
        self:onGetWorldTileInfosReq(data)
    end
end

------
-- 550000 回调，显示皇城界面
-- todocity
function MapModule:updateEmperorCityInfo()
    local emperorCityProxy = self:getProxy(GameProxys.EmperorCity)

    local warOnPanel = self:getPanel(MapEmperorWarOnPanel.NAME)
    local warPanel   = self:getPanel(MapEmperorWarPanel.NAME)
    
    -- 根据状态打开响应界面 1未开放, 2休战期, 3准备期, 4争夺期 
    local cityStatus = emperorCityProxy:getCityStatus()
    if cityStatus == 4 then -- 争夺
        if warOnPanel:isVisible() then
            warOnPanel:onUpdataEmperorWarOnPanel()
        else
            warOnPanel:show()
        end
    else
        if warPanel:isVisible() then
            warPanel:onUpdataEmperorWarPanel()
        else
            warPanel:show()
        end
    end
end



-- 470002 回调，打开郡城报告界面
function MapModule:onOpenTownReportModule()
    self:getPanel(MapCityWarPanel.NAME):onOpenTownReportModule()
end

-- 470005 回调，打开郡城排行界面
function MapModule:onOpenTownRankModule()
    self:getPanel(MapInfoPanel.NAME):onOpenTownRankModule()
end

-- 470006 回调，刷新州城信息界面
function MapModule:onUpdateMyTownPanel()
    self:getPanel(MapMyTownPanel.NAME):onUpdateMyTownPanel()
    self:getPanel(MiniMapPanel.NAME):onUpdateMyTownFlag()
end

-- 470007 回调，打开郡城贸易界面
function MapModule:onOpenTownTradeModule()
    self:getPanel(MapCityWarPanel.NAME):onOpenTownTradeModule()
    self:getPanel(MapCityWarOnPanel.NAME):onOpenTownTradeModule()
end

-- 470200 回调，刷新郡城自己的红点
function MapModule:updateMyTownRedPoint()
    self:getPanel(MapInfoPanel.NAME):updateMyTownRedPoint()
    self:getPanel(MapMyTownPanel.NAME):updateMyTownRedPoint()
end

-- 470201 回调，刷新天下大势
function MapModule:onUpdateMyTownFlag()
    self:getPanel(MiniMapPanel.NAME):onUpdateMyTownFlag()
end



-- 551000 回调，推送刷新皇城waronPanel
function MapModule:onUpdataEmperorWarOnPanel()
    local panel = self:getPanel(MapEmperorWarOnPanel.NAME)

    if panel:isVisible() then
        local emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
        if emperorCityProxy:getCityStatus() ~= 4 then -- 状态改变不是争夺期
            panel:hide()

            local function openWarPanelReq()
                -- 打开warPanel界面
                local data = {}
                data.cityId = emperorCityProxy:getCityId()
                emperorCityProxy:onTriggerNet550000Req(data)
            end
            TimerManager:addOnce(200, openWarPanelReq, self)
        else
            panel:onUpdataEmperorWarOnPanel()
        end
    end
end

-- 皇城事件推送刷新
function MapModule:onUpdataEmperorWorldNode(data) 
    self._view:onUpdataEmperorWorldNode(data) 
end

-- 打印滑动界面收到的
function MapModule:showEmperorCityLog(cityInfo)
    
    local integralSpeed = cityInfo.integralSpeed -- 速率
    local cityId = cityInfo.cityId
    -- 皇城配置数据
    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarConfig, cityId)
    local occupyNum     = cityInfo.occupyNum     -- 当前占领值
    local maxNum        = configInfo.occupyNum   -- 最大占领
    logger:info(configInfo.cityName.."80000#当前占领值#############"..occupyNum)
    logger:info(configInfo.cityName.."80000#最大占领###############"..maxNum)
end

-- 皇城事件推送刷新
function MapModule:onUpdataMapSeason() 
    self._view:onUpdataMapSeason() 
end

-- 显示皇城战状态
function MapModule:showEmperorCityState() 
    self:getPanel(MapInfoPanel.NAME):showEmperorCityState()
end



