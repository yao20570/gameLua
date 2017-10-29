WorldProxy = class("WorldProxy", BasicProxy)

WorldProxy.City_Type_1 = 1
WorldProxy.City_Type_2 = 2 -- 城旁边的安全区
WorldProxy.City_Type_3 = 3


function WorldProxy:ctor()
    WorldProxy.super.ctor(self)
    self.proxyName = GameProxys.World

    self:initData()
end

function WorldProxy:resetAttr()
    self:initData()
end

function WorldProxy:initData()
	self._lastMoveTileX = -1
    self._lastMoveTileY = -1
    self._lastInitTileX = -1
    self._lastInitTileY = -1

    self._realTileList = {}

    self:createAllTiles()
        
    -- 当前的服务端下发的格子数据(为效率只记录资源的)
    self._curTilesServerData = {}
    
    -- 当前的服务端下发的格子数据(记录玩家建筑)
    self._curBuildingServerData = {}

    -- 当前的服务端下发的格子数据(记录盟城)
    self._curTownServerData = {}

    self._resLvSubTypeMap = {}

    self._safeRangeMap = {}
    
    self._seasonBlank = {}
end

function WorldProxy:getSeasonBlankResList(seasonID)
    if self._seasonBlank[seasonID] == nil then
        self._seasonBlank[seasonID] = ConfigDataManager:getInfosFilterByOneKey(ConfigData.Blank, "season", seasonID)
    end    
    return self._seasonBlank[seasonID]
end

-- 安全区表格数据添加
function WorldProxy:addSafeRange(cityType, cityId, x, y, w, h)
    local key = cityType * 10000 + cityId
    self._safeRangeMap[key] = { tileMinX = x, tileMinY = y, tileMaxX = x + w, tileMaxY = y + h }
end

function WorldProxy:getSafeRange(cityType, cityId)
    local key = cityType * 10000 + cityId
    return self._safeRangeMap[key]
end

function WorldProxy:getSafeNodeType(x, y)
    for k, v in pairs(self._safeRangeMap) do
        if v.tileMinY == y and v.tileMinX == x then
            return 1
        end
        if v.tileMinY == y and v.tileMinX < x and x < v.tileMaxX then
            return 2
        end
        if v.tileMinY == y and v.tileMaxX == x then
            return 3
        end

        if v.tileMinY < y and y < v.tileMaxY and v.tileMinX == x then
            return 4
        end
        if v.tileMinY < y and y < v.tileMaxY and v.tileMinX < x and x < v.tileMaxX then
            return 5
        end
        if v.tileMinY < y and y < v.tileMaxY and v.tileMaxX == x then
            return 6
        end

        if v.tileMaxY == y and v.tileMinX == x then
            return 7
        end
        if v.tileMaxY == y and v.tileMinX < x and x < v.tileMaxX then
            return 8
        end
        if v.tileMaxY == y and v.tileMaxX == x then
            return 9
        end
    end

    return nil
end

function WorldProxy:setCurTilesServerData(tilesServerData)
    self._curTilesServerData = {}
    self._curBuildingServerData = {}
    self._curTownServerData = {}
    for k, v in pairs(tilesServerData) do
        if v.tileType == WorldTileType.Resource then
            -- 为效率只记录资源的
            table.insert(self._curTilesServerData, v)
        end
        if v.tileType == WorldTileType.Building then
            table.insert(self._curBuildingServerData, v)
        end
        if v.tileType == WorldTileType.CityWar then
            table.insert(self._curTownServerData, v)
        end
    end
end

function WorldProxy:isInCurTilesServerData(tileData)
    for k, v in pairs(self._curTilesServerData) do
        if v.tileType == tileData.tileType and v.x == tileData.x and v.y == tileData.y then
            return true
        end
    end
    return false
end

-- 经过跟策划协商确定当点击该建筑请求140001查看该建筑信息时客户端根据其繁荣度 重新刷新玩家建筑的繁荣状态
function WorldProxy:updateCurBuildingServerData(tileData)
    for k, v in pairs(self._curBuildingServerData) do
        if v.x == tileData.x and v.y == tileData.y then
        	if v.buildingInfo then
        		-- print("==繁荣old,new==", v.buildingInfo.degree , tileData.boom , v.buildingInfo.degreemax , tileData.boomUpLimit)
        		if v.buildingInfo.degree ~= tileData.boom or v.buildingInfo.degreemax ~= tileData.boomUpLimit then
					local info = clone(v)
					info.buildingInfo.degree = tileData.boom
	        		info.buildingInfo.degreemax = tileData.boomUpLimit
					info.buildingInfo.buildIcon = tileData.cityIcon
		            return {info}
        		end
        	end
        end
    end
    return nil
end

-- 打开世界地图并使用了保護罩道具，並且當前屏幕可見玩家自己的基地，则更新保护罩显示
function WorldProxy:updateCurBuildingProtectState(protectState)
    local roleProxy = self:getProxy(GameProxys.Role)
    local mX, mY = roleProxy:getWorldTilePos()
    local topX, topY = self:getLastMoveTile()
    if topX == -1 and topY == -1 then
        topX, topY = self:getLastInitTile()
    end

    local isInScreen = self:isCurPointInScreen(mX, mY, topX, topY, GlobalConfig.TileDT)
    if isInScreen ~= true then
        -- logger:info("--玩家自己的基地不再當前屏幕範圍，則不刷新")        
        return nil
    end

    for k, v in pairs(self._curBuildingServerData) do
        if v.x == mX and v.y == mY then
            if v.buildingInfo and v.buildingInfo.protect ~= protectState then
                -- logger:info("==更新保护罩显示！！！！！！！！！！！！==%d",protectState)
                v.buildingInfo.protect = protectState
                return { v }
            end
        end
    end
    -- logger:info("==不需要刷新保护罩显示==")
    return nil
end

function WorldProxy:isCurPointInScreen(playerX, playerY, topX, topY, dt)
    dt = dt or GlobalConfig.TileDT
    if topX - dt <= playerX and
    	topX + dt >= playerX and 
    	topY - dt <= playerY and 
    	topY + dt >= playerY then
    	return true
    else
    	return false
    end
end

function WorldProxy:setLastMoveTile(tileX, tileY)
    self._lastMoveTileX = tileX
    self._lastMoveTileY = tileY
end

function WorldProxy:getLastMoveTile()
    return self._lastMoveTileX, self._lastMoveTileY
end

function WorldProxy:setLastInitTile(tileX, tileY)
    self._lastInitTileX = tileX
    self._lastInitTileY = tileY
end

function WorldProxy:getLastInitTile()
    return self._lastInitTileX, self._lastInitTileY
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--地图资源点生成机制
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 种子 表
function WorldProxy:getRandomConfig(seedID)
	local config = ConfigDataManager:getConfigById("ParamBankConfig", seedID)
	return config
end

-- 地图库 表 TODO：删除无用
function WorldProxy:getTileConfig(ID)
	local config = ConfigDataManager:getConfigById("MapBankConfig", ID)
	return config
end

-- 将资源类型和等级转换成字段：resPointId
function WorldProxy:getResPointId(type,level)
	local ID = type * 1000 + level
	return ID
end

-- 读取资源点数据
function WorldProxy:getTile(randomList, x, y)
	local group = self:getGroupByPos(x,y)
	local index = self:getIndexByPos(x,y)
	local randnum = randomList[index]

	if randnum == nil then
		logger:error("... randnum is nil (index=%d)",index)
		return nil
	end

	local ID = group * 10000 + randnum  --转换成ID
	local realTile = self:getTileConfig(ID)
	if realTile then
		realTile.x = x
		realTile.y = y
		realTile.resPointId = self:getResPointId(realTile.restype,realTile.level)
		return realTile
	else
		logger:error("... 格子 realTile is nil (ID=%d,index=%d)",ID,index)
		return nil
	end
end


-- 线性同余法生成随机数
-- seed:[num]种子
-- b:[num]参数B
-- c:[num]参数C
-- m:[num]参数M
-- n:[num]生成的随机数个数
function WorldProxy:getRandomList(seed, b, c, m, n)
	local randomList = {}
	local index = 1
	local a0 = seed
	local an = a0

	while (index <= n) do
		local random = (b * an + c) % m
		table.insert(randomList,random)
		an = random
		index = index + 1
	end

	return randomList
end

-- 将坐标转换成随机数的索引
function WorldProxy:getIndexByPos(x,y)
	local index = x * 600 + y + 1
	return index
end

-- 将坐标转换成一个key
function WorldProxy:getKeyByPos(x,y)
	local key = x.."_"..y
	return key
end

-- 根据资源类型返回格子类型
function WorldProxy:getTileTypeByResType(restype)
	local tileType
	if restype >= 1 and restype <= 5 then
		tileType = WorldTileType.Resource  --资源点
	else
		tileType = WorldTileType.Empty  --空地
	end
	return tileType
end

-- 根据当前坐标获取对应的组号
--TODO 要让策划新建配表
function WorldProxy:getGroupByPos(curX, curY)
	if self._groupAreaList == nil then
		self._groupAreaList = ConfigDataManager:getConfigData("MapPosGroundConfig")
	end

	local group = 11  --生成组默认是11
	for _,config in pairs(self._groupAreaList) do
		if curX >= config.xorigin and curX <= config.xend and curY >= config.yorigin and curY <= config.yend then
			return config.groundNum
		end
	end

	return group
end

--[[
	生成逻辑：
	1.根据当前服的种子id，匹配种子，并生成随机数
	2.根据生成的随机数和当前位置坐标，过滤资源点
	3.每次登陆客户端都重新生成
]]
function WorldProxy:createRandomData(seedID)
	if seedID == nil or seedID < 0 then
		logger:error("... World seed type id is nil. ")  --种子id有误
		return
	end
	
	if self._seedID == nil or self._seedID ~= seedID then
		self._seedID = seedID
	elseif table.size(self._realTileList) > 0 or self._seedID == seedID then  --避免重复创建
		logger:info("... Tile list already been created. (done)")
		return
	end

	local randomConfig = self:getRandomConfig(seedID)
	if randomConfig == nil then
		logger:error("... RandomConfig is nil (seedID=%d)",seedID)  --种子id匹配不到种子
		return
	end


	local row,col = 600,600  --行，列
	local tileCount = col*row  --随机数个数
	local randomList = self:getRandomList(randomConfig.seed, randomConfig.parameterB, randomConfig.parameterC, randomConfig.parameterM, tileCount)
	
	local beginTime = os.clock()
	logger:info(string.format("0000---not-error--LUA VM MEMORY USED : %0.2f KB", collectgarbage("count")))

	local tmpList = {}
	for i=1,row do
		for j=1,col do
			local tmpX = i - 1
			local tmpY = j - 1
			local realTile = self:getTile(randomList, tmpX, tmpY)
			if realTile then				
				--TODO 用KEY做下标，表格插入数据速度比较慢,原因是重复哈希耗时导致
				local key = self:getKeyByPos(tmpX,tmpY)
				self._realTileList[key] = realTile
			else
				logger:error("... 生成错误资源点 tile : x=%d,y=%d",tmpX,tmpY)
			end

		end
	end

	logger:error("... 世界地图生成耗时(s) : %2.5f",os.clock() - beginTime)  --TODO PC生成耗时3~4秒 ！手机上耗时翻倍！
	logger:info(string.format("1111---not-error--LUA VM MEMORY USED : %0.2f KB", collectgarbage("count")))
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 对外接口
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 通过坐标获取tile数据
function WorldProxy:getTileByPos(x,y)
	if x == nil or y == nil then
		logger:info("can't get the tile by (%d,%d).",x,y)
		return nil
	end

	local key = self:getKeyByPos(x,y)
	return self._realTileList[key]
end

---------------------
-- 拖动地图的时候本地手动刷新资源点显示
-- 其他格子类型等协议回来再刷新
function WorldProxy:onGetResTileInfos(x,y)
	local time = os.clock()

    local allResTiles = {}
    local dt = GlobalConfig.TileDT
    for i=x - dt, x + dt do
        for j=y - dt, y + dt do
        	if i < 0 or j < 0 or i > 599 or j > 599 then
        		break
        	end
			local resInfo = self:getTileByPos(i,j)
            local tileType = self:getTileTypeByResType(resInfo.restype)
            if tileType == WorldTileType.Resource then  --只匹配资源点，空地不要了
    	        local worldTileInfo = {}
	            worldTileInfo.x = i
	            worldTileInfo.y = j
	            worldTileInfo.buildingInfo = {}
	            worldTileInfo.tileType = tileType
	            worldTileInfo.resInfo = resInfo
	            table.insert(allResTiles, worldTileInfo)
            end
        end
    end

    -- print("... 取一个区域的耗时 time",os.clock() - time)
    return allResTiles
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 下面是2.0方案测试
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 通过坐标获取tile数据 资源
function WorldProxy:getTileByPos2(x,y)
	if x == nil or y == nil then
		logger:info("can't get the tile by (%d,%d).",x,y)
		return nil
	end
	local tile = self:getTile2(x,y)
	return tile
end

---------------------
-- 拖动地图的时候本地手动刷新资源点显示
-- 其他格子类型等协议回来再刷新
-- isNeedEmpty：true要空地，false不要空地
function WorldProxy:onGetResTileInfos2(x, y, isNeedEmpty)
    local time = os.clock()

    local sageNodeDatas = {}
    local allResTiles = { }
    local dt = GlobalConfig.TileDT
    for i = x - dt, x + dt do
        for j = y - dt, y + dt do           

            local worldTileInfo = { }
            worldTileInfo.x = i
            worldTileInfo.y = j

            local lordCityId = nil
            local resInfo = nil
            
            local isLock = self:isLockPos(i, j)

            if i < 0 or j < 0 or i > 599 or j > 599 or isLock then
                -- resInfo = {ID = 0, group = 11, level = 0, randnum = 0, restype = 0}
                -- 世界的尽头
                resInfo = nil
                
                if isLock then
                    lordCityId = self:getLordCityIdByPos(i, j)
                end
            else
                -- 获取数据
                resInfo = self:getTileByPos2(i, j) -- 获取资源数据
                lordCityId = self:getLordCityIdByPos(i, j) -- 同时设置 self._buffRangeMap数据
            end
            -- print("锁定区 ",isLock,i,j,lordCityId)


            if resInfo == nil and lordCityId == nil then
                -- print("...--资源点数据为空，世界尽头，置为空地 ...",i,j)
                worldTileInfo.buildingInfo = { }
                worldTileInfo.tileType = WorldTileType.Empty

            elseif lordCityId then

                -- 安全区       
                if self:getSafeRange(WorldProxy.City_Type_2, lordCityId) == nil then
                   
                    local minTileX = 0
                    local maxTileX = 0
                    local minTileY = 0
                    local maxTileY = 0
                    for k,v in pairs(self._buffRangeMap) do
                        if v.ID == lordCityId then
                            minTileX = v.tileMinX
                            maxTileX = v.tileMaxX
                            minTileY = v.tileMinY
                            maxTileY = v.tileMaxY
                        end
                    end
                    self:addSafeRange(WorldProxy.City_Type_2, lordCityId, minTileX, minTileY, maxTileX - minTileX, maxTileY - minTileY)
                end

                -- 主城
                local cityId = self:getLordCityId(i, j)
                if cityId and lordCityId == cityId then
                    -- logger:info(" 1 先城池 ~~~~~~***!*!**!*!*!")
                    worldTileInfo.tileType = WorldTileType.City
                    worldTileInfo.cityId = cityId
                else
                    if resInfo then
                        worldTileInfo = self:resTileFunc(resInfo,i,j)
                    else
                        worldTileInfo.buildingInfo = { }
                        worldTileInfo.tileType = WorldTileType.Empty
                    end
                end

            else
                -- logger:info(" 2 再资源 ~~~~~~***!*!**!*!*!")
                -- -- 再资源
                -- local tileType = self:getTileTypeByResType(resInfo.restype)
                -- if tileType == WorldTileType.Empty then
                --     if isNeedEmpty or banditProxy:getBanditDungeon(i, j) ~= nil then
                --         -- 不需要空地的时候再判断空地上面有没有黄巾贼     
                --         worldTileInfo.tileType = tileType
                --         worldTileInfo.resInfo = resInfo             
                --     else
                --         -- 这里不要空地，空地等80000返回再渲染
                --         worldTileInfo = nil
                --     end
                -- else
                --     worldTileInfo.tileType = tileType
                --     worldTileInfo.resInfo = resInfo

                --     if self:isInCurTilesServerData(worldTileInfo) == true then
                --         worldTileInfo = nil
                --     end
                -- end

                worldTileInfo = self:resTileFunc(resInfo,i,j)
            end

            if worldTileInfo then
--                if worldTileInfo.tileType == nil then

--                    print("XXXXXXXXXXXXXXXXXXXXX")
--                    print("XXXXXXXXXXXXXXXXXXXXX")
--                end

                table.insert(allResTiles, worldTileInfo)
            end
            
        end
    end

    -- print("...取一个区域的耗时,数据量", os.clock() - time, table.size(allResTiles))
    return allResTiles, sageNodeDatas
end


function WorldProxy:resTileFunc(resInfo, m, n)
    -- logger:info(" 2 再资源 ~~~~~~***!*!**!*!*!")
    -- 资源格子数据
    local worldTileInfo = { }
    worldTileInfo.x = m
    worldTileInfo.y = n

    
    local banditProxy = self:getProxy(GameProxys.BanditDungeon)
    local tileType = self:getTileTypeByResType(resInfo.restype)
    if tileType == WorldTileType.Empty then
        if isNeedEmpty or banditProxy:getBanditDungeon(m, n) ~= nil then
            -- 不需要空地的时候再判断空地上面有没有黄巾贼
            worldTileInfo.tileType = tileType
            worldTileInfo.resInfo = resInfo
        else
            -- 这里不要空地，空地等80000返回再渲染
            worldTileInfo = nil
        end
    else
        worldTileInfo.tileType = tileType
        worldTileInfo.resInfo = resInfo

        if self:isInCurTilesServerData(worldTileInfo) == true then
            worldTileInfo = nil
        end
    end
    return worldTileInfo
end

-- 计算出每个安全区域的范围，传入当前坐标，返回安全区cityid
function WorldProxy:getLordCityIdByPos(x,y)

    if self._buffRangeMap == nil then
        self._buffRangeMap = {}
        local config = ConfigDataManager:getConfigData(ConfigData.CityRewardConfig)
        for key,cityRewardCfgData in pairs(config) do
            local ary = StringUtils:jsonDecode(cityRewardCfgData.buffRange)
            local minTileX = MapDef.maxTileX
            local maxTileX = MapDef.minTileX
            local minTileY = MapDef.maxTileY
            local maxTileY = MapDef.minTileY
            for k, v in pairs(ary) do
                local mapTileCfgData = ConfigDataManager:getInfoFindByOneKey(ConfigData.MapGenerateConfig, "sort", v)
                if mapTileCfgData.xorigin < minTileX then
                    minTileX = mapTileCfgData.xorigin
                end

                if maxTileX < mapTileCfgData.xend then
                    maxTileX = mapTileCfgData.xend
                end

                if mapTileCfgData.yorigin < minTileY then
                    minTileY = mapTileCfgData.yorigin
                end

                if maxTileY < mapTileCfgData.yend then
                    maxTileY = mapTileCfgData.yend
                end
            end
            self._buffRangeMap[key] = {ID = cityRewardCfgData.ID, tileMinX = minTileX, tileMinY = minTileY, tileMaxX = maxTileX, tileMaxY = maxTileY }
        end
    end

    local lordCityId = nil
    for k,v in pairs(self._buffRangeMap) do
        -- print(" 范围 ",v.tileMinX,v.tileMinY,v.tileMaxX,v.tileMaxY)
        if v.tileMinX <= x 
            and v.tileMaxX >= x 
            and v.tileMinY <= y 
            and v.tileMaxY >= y then
            lordCityId = v.ID
        end
    end

    return lordCityId

end

function WorldProxy:getLordCityId(x, y)    
    local lordCityProxy = self:getProxy(GameProxys.LordCity)
    local mapBattleCfgData = lordCityProxy:getCityBattleCfgDataByTouchPos(x, y)    
    return mapBattleCfgData and mapBattleCfgData.ID or nil
end


function WorldProxy:getTileInfoByPos2(x, y)
    local worldTileInfo = {}
    worldTileInfo.x = x
    worldTileInfo.y = y

	local resInfo
	if x < 0 or y < 0 or x > 599 or y > 599 then
		resInfo = nil  --世界的尽头
	else
		resInfo = self:getTileByPos2(x, y)
	end

    if resInfo == nil then
        worldTileInfo.buildingInfo = {}
        worldTileInfo.tileType = WorldTileType.Empty
    else
        local tileType = self:getTileTypeByResType(resInfo.restype)
        worldTileInfo.tileType = tileType
        worldTileInfo.resInfo = resInfo                	
    end
	
	return worldTileInfo
end

-- 其实就是随机数
function WorldProxy:getIndexByPos2(x,y)
	local index = x % 50 * 50 + y % 50 + 0
	return index
end
-- 获取本地资源点数据
function WorldProxy:getTile2(x,y)
	-- 这里做个容错
	if self._config == nil then
		self:createAllTiles()		
	end

	local group = self:getGroupByPos(x,y)
	local index = self:getIndexByPos2(x,y)
	local key = group.."_"..index

	local realTile = self._config[key]
	if realTile then
		realTile.x = x
		realTile.y = y
		realTile.resPointId = self:getResPointId(realTile.restype,realTile.level)
		return realTile
	else
		logger:error("... 格子 realTile is nil (ID=%d,index=%d)",group,index)
		return nil
	end
end

-- 生成索引表
function WorldProxy:createAllTiles()
	if self._config then
		return  --避免重复执行
	end
	
	local beginTime2 = os.clock()
	self._config = {}
	local config = ConfigDataManager:getConfigData("MapSampleConfig")
	for k,v in pairs(config) do
		local key = v.group.."_"..v.randnum
		self._config[key] = v
	end

	beginTime2 = os.clock() - beginTime2
	print("... 表转换key下标耗时 ...",beginTime2)  --0.3S
	-- print("... 先不生成360000个数据，每次根据坐标来取 ...")

end

function WorldProxy:isLockPos(x, y)
	local config = ConfigDataManager:getConfigData(ConfigData.MapLockConfig)
	for k,v in pairs(config) do
		if x >= v.xorigin and x <= v.xend and y >= v.yorigin and y <= v.yend then
			return true
		end
	end
	return false
end

------
-- 根据民忠值获取配置信息
-- @loyaltyCount    民忠值
function WorldProxy:getLoyaltyConfigInfo(loyaltyCount)
    local heavyResConfig = ConfigDataManager:getConfigData(ConfigData.WorldHeavyResConfig)
    local loyaltyInfo = nil 
    for i, info in pairs(heavyResConfig) do
        local needRange = StringUtils:jsonDecode(info.loyaltyNeed)
        if needRange[1] <= loyaltyCount and needRange[2] >= loyaltyCount then
            loyaltyInfo = info
            break
        end
    end
    return loyaltyInfo
end

------
-- 根据民忠值获取颜色
function WorldProxy:getColorByLoyalty(loyaltyCount)
    local color = 1
    if loyaltyCount == 0 then
        return color -- 
    end  

    local loyaltyInfo = self:getLoyaltyConfigInfo(loyaltyCount)
    if loyaltyInfo == nil then
        color = 1
    else
        color = loyaltyInfo.type
    end
    return color
end

function WorldProxy:getColorValueByLoyalty(loyaltyCount)
    return ColorUtils:getColorByQuality(self:getColorByLoyalty(loyaltyCount)) 
end

function WorldProxy:getPlusValueByLoyalty(loyaltyCount)
    local plusValue = 1
    if loyaltyCount == 0 then
        return plusValue -- 
    end

    local loyaltyInfo = self:getLoyaltyConfigInfo(loyaltyCount)
    if loyaltyInfo == nil then
        plusValue = 1
    else
        plusValue = (loyaltyInfo.collectAdd + 100)/100
    end
    return plusValue 
end



-- 矿点采集速率的vip加成
function WorldProxy:getVipSpeedUpCollectRes()
    local speedUp = 0
    local roleProxy = self:getProxy(GameProxys.Role)
    local vipLevel = roleProxy:getRoleAttrValue( PlayerPowerDefine.POWER_vipLevel)
    local vipConfigInfo = ConfigDataManager:getConfigById(ConfigData.VipDataConfig, vipLevel + 1)
    
    local jsonInfo = StringUtils:jsonDecode(vipConfigInfo.speedUpCollectRes)
    if #jsonInfo == 0 then
        return speedUp
    end
    
    if #jsonInfo == 2 then
        speedUp = jsonInfo[2]/100 -- 加成数率
    end
    return speedUp
end



-- 不同等级区间的矿点拥有不同的战损比例：用资源点等级获取到子战斗类型，再去读战损表的战损
function WorldProxy:getSubBattleType( resLv )
    local subType = self._resLvSubTypeMap[resLv]
    if subType == nil then
        local allData = ConfigDataManager:getConfigData(ConfigData.FightBranchConfig)
        for _, config in pairs(allData) do
            local levelInterval = StringUtils:jsonDecode(config.levelInterval)
            if levelInterval[1] <= resLv  and resLv <= levelInterval[2] then
                subType = config.subType
                break
            end
        end
        self._resLvSubTypeMap[resLv] = subType
    end
    return subType or 0
end

-- 郡城倒计时
function WorldProxy:setTownRemainTime(key, remainTime)
    self:pushRemainTime(key, remainTime)
end




-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------