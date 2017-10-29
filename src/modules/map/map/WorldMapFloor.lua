WorldMapFloor = class("WorldMapFloor", function (resConfig)
    return UIMapNodeExtend.extend(cc.Layer:create()) --cc.LayerColor:create(cc.c4b(255, 0, 255, 80))
end)

WorldMapFloor.__index = WorldMapFloor


WorldMapFloor.Layer_Type_Floor = 1          -- 地图背景层
WorldMapFloor.Layer_Type_Safe_Range = 2     -- 地图安全范围层
WorldMapFloor.Layer_Type_Nodes = 3          -- 地图节点层
WorldMapFloor.Layer_Type_March_Line = 4          -- 行军路线层
WorldMapFloor.Layer_Type_March_Actor = 5          -- 行军军队层
WorldMapFloor.Layer_Type_Nodes_Name = 6     -- 地图节点名称层

function WorldMapFloor:ctor(resConfig, mapType)
    -- local format = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565  --不支持透明
    -- local format = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B4444  --支持透明通道
    -- local sprite16PixelFormat = cc.Texture2D:getDefaultAlphaPixelFormat()
    -- cc.Texture2D:setDefaultAlphaPixelFormat(format)
    
    

    self._floor = cc.Layer:create()
    self:addChild(self._floor )
    self:initFloor(resConfig, mapType)

    self._safeRange = cc.Layer:create()
    self:addChild(self._safeRange )    
    
    self._nodes = cc.Layer:create()
    self:addChild(self._nodes )

    self._marchLine = cc.Layer:create()
    self:addChild(self._marchLine )

    self._marchActor = cc.Layer:create()
    self:addChild(self._marchActor )

    self._nodesName = cc.Layer:create()
    self:addChild(self._nodesName )


--    self:setPosition(cc.p(100,100)) 
    self:setMapScale(GlobalConfig.worldMapScale)
end

function WorldMapFloor:initFloor(resConfig, mapType)
    -- 地图
    local url = string.format(resConfig.bg, mapType)
    self._bgImg1 = TextureManager:createSpriteFile(url)
    self._bgImg2 = TextureManager:createSpriteFile(url)
    self._bgImg3 = TextureManager:createSpriteFile(url)
    self._bgImg4 = TextureManager:createSpriteFile(url)
    self._bgImg5 = TextureManager:createSpriteFile(url)
    self._bgImg6 = TextureManager:createSpriteFile(url)
    self._bgImg31 = TextureManager:createSpriteFile(url)
    self._bgImg61 = TextureManager:createSpriteFile(url)
    
    -- 半透明格子
    self._bgAlphaImg1 = TextureManager:createSpriteFile(resConfig.bgAlpha)  
    self._bgAlphaImg2 = TextureManager:createSpriteFile(resConfig.bgAlpha)  
    self._bgAlphaImg3 = TextureManager:createSpriteFile(resConfig.bgAlpha)  
    self._bgAlphaImg4 = TextureManager:createSpriteFile(resConfig.bgAlpha)  
    self._bgAlphaImg5 = TextureManager:createSpriteFile(resConfig.bgAlpha)  
    self._bgAlphaImg6 = TextureManager:createSpriteFile(resConfig.bgAlpha)  
    self._bgAlphaImg31 = TextureManager:createSpriteFile(resConfig.bgAlpha)  
    self._bgAlphaImg61 = TextureManager:createSpriteFile(resConfig.bgAlpha)  

    -- cc.Texture2D:setDefaultAlphaPixelFormat(sprite16PixelFormat)
    
    self._floor:addChild(self._bgImg1)
    self._floor:addChild(self._bgImg2)
    self._floor:addChild(self._bgImg3)
    self._floor:addChild(self._bgImg4)
    self._floor:addChild(self._bgImg5)
    self._floor:addChild(self._bgImg6)
    self._floor:addChild(self._bgImg31)
    self._floor:addChild(self._bgImg61)
    self._bgImg1:setAnchorPoint(cc.p(0,0))
    self._bgImg2:setAnchorPoint(cc.p(0,0))
    self._bgImg3:setAnchorPoint(cc.p(0,0))
    self._bgImg4:setAnchorPoint(cc.p(0,0))
    self._bgImg5:setAnchorPoint(cc.p(0,0))
    self._bgImg6:setAnchorPoint(cc.p(0,0))
    self._bgImg31:setAnchorPoint(cc.p(0,0))
    self._bgImg61:setAnchorPoint(cc.p(0,0))


    self._floor:addChild(self._bgAlphaImg1)
    self._floor:addChild(self._bgAlphaImg2)
    self._floor:addChild(self._bgAlphaImg3)
    self._floor:addChild(self._bgAlphaImg4)
    self._floor:addChild(self._bgAlphaImg5)
    self._floor:addChild(self._bgAlphaImg6)
    self._floor:addChild(self._bgAlphaImg31)
    self._floor:addChild(self._bgAlphaImg61)
    self._bgAlphaImg1:setAnchorPoint(cc.p(0,0))
    self._bgAlphaImg2:setAnchorPoint(cc.p(0,0))
    self._bgAlphaImg3:setAnchorPoint(cc.p(0,0))
    self._bgAlphaImg4:setAnchorPoint(cc.p(0,0))
    self._bgAlphaImg5:setAnchorPoint(cc.p(0,0))
    self._bgAlphaImg6:setAnchorPoint(cc.p(0,0))
    self._bgAlphaImg31:setAnchorPoint(cc.p(0,0))
    self._bgAlphaImg61:setAnchorPoint(cc.p(0,0))
end

function WorldMapFloor:updateMapBg(resConfig, mapType)    
    local url = string.format(resConfig.bg, mapType)
    TextureManager:updateSpriteFile(self._bgImg1, url)
    TextureManager:updateSpriteFile(self._bgImg2, url)
    TextureManager:updateSpriteFile(self._bgImg3, url)
    TextureManager:updateSpriteFile(self._bgImg4, url)
    TextureManager:updateSpriteFile(self._bgImg5, url)
    TextureManager:updateSpriteFile(self._bgImg6, url)
    TextureManager:updateSpriteFile(self._bgImg31, url)
    TextureManager:updateSpriteFile(self._bgImg61, url)
end

function WorldMapFloor:setMapSize(size)
    self:setContentSize(size)
end

function WorldMapFloor:setMapPosition(pos)
    local scale = self._mapScale
    if scale == nil then
        scale = 1
    end

    local mapFloorWidth = MapDef.floorWidth * scale
    local mapFloorHeight = MapDef.floorHeight * scale
    local basePos = cc.p(- pos.x, - pos.y)
    local col = math.floor(basePos.x / mapFloorWidth)
    local row = math.floor(basePos.y / mapFloorHeight)
    local colx = col * mapFloorWidth - MapDef.changeX * GlobalConfig.worldMapScale + 3
    local rowy = row * mapFloorHeight - MapDef.changeY * GlobalConfig.worldMapScale + 8
    local dx = basePos.x - colx
    local dy = basePos.y - rowy
    -- logger:info("地图坐标 dx=%d,dy=%d | colx=%d,rowy=%d | col=%d, row=%d", dx,dy,colx,rowy,col,row)


    self._bgImg1:setPosition(cc.p(colx, rowy))
    self._bgImg2:setPosition(cc.p(colx, rowy + mapFloorHeight))
    self._bgImg3:setPosition(cc.p(colx, rowy + mapFloorHeight * 2))
    self._bgImg31:setPosition(cc.p(colx, rowy + mapFloorHeight * 3))
    self._bgImg4:setPosition(cc.p(colx + mapFloorWidth, rowy))
    self._bgImg5:setPosition(cc.p(colx + mapFloorWidth, rowy + mapFloorHeight))
    self._bgImg6:setPosition(cc.p(colx + mapFloorWidth, rowy + mapFloorHeight * 2))
    self._bgImg61:setPosition(cc.p(colx + mapFloorWidth, rowy + mapFloorHeight * 3))


    -- 格子地图位置
    self._bgAlphaImg1:setPosition(cc.p(colx, rowy))
    self._bgAlphaImg2:setPosition(cc.p(colx, rowy + mapFloorHeight))
    self._bgAlphaImg3:setPosition(cc.p(colx, rowy + mapFloorHeight * 2))
    self._bgAlphaImg31:setPosition(cc.p(colx, rowy + mapFloorHeight * 3))
    self._bgAlphaImg4:setPosition(cc.p(colx + mapFloorWidth, rowy))
    self._bgAlphaImg5:setPosition(cc.p(colx + mapFloorWidth, rowy + mapFloorHeight))
    self._bgAlphaImg6:setPosition(cc.p(colx + mapFloorWidth, rowy + mapFloorHeight * 2))
    self._bgAlphaImg61:setPosition(cc.p(colx + mapFloorWidth, rowy + mapFloorHeight * 3))
end

function WorldMapFloor:setMapScale( scale )
    -- body
    self._mapScale = scale
    self._bgImg1:setScale(scale)
    self._bgImg2:setScale(scale)
    self._bgImg3:setScale(scale)
    self._bgImg31:setScale(scale)
    self._bgImg4:setScale(scale)
    self._bgImg5:setScale(scale)
    self._bgImg6:setScale(scale)
    self._bgImg61:setScale(scale)

    self._bgAlphaImg1:setScale(scale)
    self._bgAlphaImg2:setScale(scale)
    self._bgAlphaImg3:setScale(scale)
    self._bgAlphaImg31:setScale(scale)
    self._bgAlphaImg4:setScale(scale)
    self._bgAlphaImg5:setScale(scale)
    self._bgAlphaImg6:setScale(scale)
    self._bgAlphaImg61:setScale(scale)

end

-- 显示OR隐藏半透明格子地皮
function WorldMapFloor:setAlphaFloorVisible(isShow)
    -- body
    self._bgAlphaImg1:setVisible(isShow)
    self._bgAlphaImg2:setVisible(isShow)
    self._bgAlphaImg3:setVisible(isShow)
    self._bgAlphaImg31:setVisible(isShow)
    self._bgAlphaImg4:setVisible(isShow)
    self._bgAlphaImg5:setVisible(isShow)
    self._bgAlphaImg6:setVisible(isShow)
    self._bgAlphaImg61:setVisible(isShow)
end

function WorldMapFloor:getLayer(layerType)
    if layerType == WorldMapFloor.Layer_Type_Floor then
        return self._floor
    elseif layerType == WorldMapFloor.Layer_Type_Safe_Range then
        return self._safeRange
    elseif layerType == WorldMapFloor.Layer_Type_Nodes then
        return self._nodes
    elseif layerType == WorldMapFloor.Layer_Type_March_Line then
        return self._marchLine
    elseif layerType == WorldMapFloor.Layer_Type_March_Actor then
        return self._marchActor
    elseif layerType == WorldMapFloor.Layer_Type_Nodes_Name then
        return self._nodesName
    end
end

