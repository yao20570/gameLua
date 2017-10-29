MapDef = { }

MapDef.floorWidth = 1200
MapDef.floorHeight = 600

MapDef.tileWidth = MapDef.floorWidth / 4 * GlobalConfig.worldMapScale -- 从MapDef.floorWidth 转
MapDef.tileHeight = MapDef.floorHeight / 4 * GlobalConfig.worldMapScale

MapDef.tileSize = cc.size(MapDef.tileWidth, MapDef.tileHeight) -- 主要参数

MapDef.tileViewMax = 3
MapDef.tileMaxSize = 602 


MapDef.mapSize = cc.size(MapDef.tileWidth * MapDef.tileMaxSize, MapDef.tileHeight * MapDef.tileMaxSize)

MapDef.mapOrigin = cc.p(MapDef.mapSize.width / 2, MapDef.tileHeight)
MapDef.mapTopPoint = cc.p(MapDef.mapSize.width / 2, MapDef.mapSize.height - MapDef.tileHeight)
MapDef.mapLeftPoint = cc.p(MapDef.tileWidth, MapDef.mapSize.height / 2)
MapDef.mapRightPoint = cc.p(MapDef.mapSize.width - MapDef.tileWidth, MapDef.mapSize.height / 2)

MapDef.keyParam = 10000

-- 5 tile(240,120) origin(72240,120+120/2)
-- 4 tile(300,150) origin(90300,150+150/2)
-- 格子(0,0)的坐标：相对于一个底图(1200*600)的偏移坐标是(300,225)

MapDef.changeX = 150             -- 地图偏移坐标X (x不能小于0)
MapDef.changeY = 160             -- 地图偏移坐标Y
MapDef.changeTileX = 000         -- 格子偏移坐标X
MapDef.changeTileY = 000         -- 格子偏移坐标Y


MapDef.minTileX = 0
MapDef.maxTileX = 599

MapDef.minTileY = 0
MapDef.maxTileY = 599

function MapDef.worldTileToScreenXY(tileX, tileY)
    local x = MapDef.mapOrigin.x +(tileX - tileY) * MapDef.tileWidth / 2 + MapDef.changeTileX * GlobalConfig.worldMapScale
    local y = MapDef.mapOrigin.y +(tileX + tileY + 1) * MapDef.tileHeight / 2 + MapDef.changeTileY * GlobalConfig.worldMapScale
    
    return x, y
end

function MapDef.worldTileToScreen(tileX, tileY)
    local x, y = MapDef.worldTileToScreenXY(tileX, tileY)
    local screenPos = cc.p(x, y)
    return screenPos
end

function MapDef.screenToWorldTile(screenPos)
    local x = screenPos.x
    local y = screenPos.y
    local tileX = math.ceil(0.5 *(2 *(x - MapDef.mapOrigin.x) / MapDef.tileWidth + 2 *(y - MapDef.mapOrigin.y) / MapDef.tileHeight - 2))
    local tileY = math.ceil(0.5 *(2 *(y - MapDef.mapOrigin.y) / MapDef.tileHeight - 2 *(x - MapDef.mapOrigin.x) / MapDef.tileWidth) -1)

    -- 蛋疼的,竟然会返回-0, 用它们拼接城key会出错
    if tileX == -0 then
        tileX = 0
    end

    if tileY == -0 then
        tileY = 0
    end

    return tileX, tileY
end

function MapDef.getKeyByTilePos(tileX, tileY)
    return tileX * MapDef.keyParam + tileY
end

function MapDef.getTilePosByKey( key )
    local tileX = math.floor(key / MapDef.keyParam)
    local tileY = key % MapDef.keyParam
    return tileY ,tileY
end

MapRes = { }

MapRes.worldMapRes = {
    bgDefauleType = 1,
    bg = "bg/map/map_bg%s" .. TextureManager.bg_type,
    bgAlpha = "bg/map/map-alpha" .. TextureManager.bg_type
}

MapConfig = { }



