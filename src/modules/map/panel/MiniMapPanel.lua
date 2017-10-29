
MiniMapPanel = class("MiniMapPanel", BasicPanel)
MiniMapPanel.NAME = "MiniMapPanel"

MiniMapPanel.CITY_HIDE = 1
MiniMapPanel.CITY_SHOW = 0

function MiniMapPanel:ctor(view, panelName)

    local layer = view:getLayer(ModuleLayer.UI_POP_LAYER)
    --    MiniMapPanel.super.ctor(self, view, panelName, true, layer)

    MapInfoPanel.super.ctor(self, view, panelName, false, layer)
end

function MiniMapPanel:finalize()
    MiniMapPanel.super.finalize(self)
end

function MiniMapPanel:initPanel()
    MiniMapPanel.super.initPanel(self)
    self:setLocalZOrder(100)

    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
    self._roleProxy = self:getProxy(GameProxys.Role)
    -- 滚动
    self._svMinMap = self:getChildByName("svMinMap")

    -- 加载地图图片和设置地图位置
    self._imgMap = self._svMinMap:getChildByName("imgMap")
    TextureManager:updateImageViewFile(self._imgMap, "bg/map/minMap.jpg")
    local mapSize = self._imgMap:getContentSize()
    self._imgMap:setPosition(mapSize.width / 2, mapSize.height / 2)
    local svSize = self._svMinMap:getContentSize()
    self._svMinMap:setInnerContainerSize(mapSize)
    self._svInner = self._svMinMap:getInnerContainer()
    self._svInner:setPosition((svSize.width - mapSize.width) / 2,(svSize.height - mapSize.height) / 2)


    self._panelTop = self:getChildByName("panelTop")
    self._btnClose = self._panelTop:getChildByName("btnClose")

    self._panelBottom = self:getChildByName("panelBottom")
    self._txtPos = self._panelBottom:getChildByName("txtPos")
    self._btnEnter = self._panelBottom:getChildByName("btnEnter")

    
    self._lab1 = self._panelBottom:getChildByName("lab1")
    self._img1 = self._panelBottom:getChildByName("img1")
    self._img2 = self._panelBottom:getChildByName("img2")
    self._img3 = self._panelBottom:getChildByName("img3")
    self._img4 = self._panelBottom:getChildByName("img4")
    self._img5 = self._panelBottom:getChildByName("img5")
    self._img3:setVisible(false)
    NodeUtils:alignNodeL2R(self._lab1, self._img5, self._img4, --[[self._img3,]] self._img2, self._img1, 7)


    -- 初始化地图容器和城池，标识物等
    self:initMapObj()
end

function MiniMapPanel:doLayout()
    -- local topAdaptivePanel = self:topAdaptivePanel()
    NodeUtils:adaptiveListView(self._svMinMap, self._panelBottom, self._panelTop, 0, -30)

    local mapInfoPanel = self:getPanel(MapPanel.NAME)
    local curMapTilePosX, curMapTilePosY = mapInfoPanel:getCurTilePos()
    self:setCurMiniMapPos(curMapTilePosX, curMapTilePosY)
    self:setCurMiniMapPosToCenter(curMapTilePosX, curMapTilePosY)
end

function MiniMapPanel:registerEvents()
    MiniMapPanel.super.registerEvents(self)

    --    local bgImg = self:getChildByName("mainPanel/bgImg")
    --    self:addTouchEventListener(bgImg, self.onClickMiniPanel)
    --    self._bgImg = bgImg

    --    local mainPanel = self:getPanelRoot()
    --    self:addTouchEventListener(mainPanel, self.onCloseMiniPanel)

    self:addTouchEventListener(self._panelContainer, self.onClickMiniPanel)
    self:addTouchEventListener(self._btnEnter, self.onGoToMap)
    self:addTouchEventListener(self._btnClose, self.onCloseMiniPanel)

end

function MiniMapPanel:onShowHandler()
    -- 发送消息号获得最新的自己盟城数据
    self._cityWarProxy:onTriggerNet470201Req({})

    -- 显示重置
    self:showReset()

    -- 设置当前的范围
    local mapInfoPanel = self:getPanel(MapPanel.NAME)
    local curMapTilePosX, curMapTilePosY = mapInfoPanel:getCurTilePos()
    self:setCurMiniMapPos(curMapTilePosX, curMapTilePosY)
    self:setCurMiniMapPosToCenter(curMapTilePosX, curMapTilePosY)

    -- 设置自己的位置
    self:setSelfPosition()

    -- 设置同盟会长的位置
    self:setLeaderPosition()

    --    local worldProxy = self:getProxy(GameProxys.World)
    --    local mtx, mty = worldProxy:getLastMoveTile()
    --    if mtx >= 0 then
    --        self:onMapMove(mtx, mty)
    --    else
    --        local roleProxy = self:getProxy(GameProxys.Role)
    --        local wtx, wty = roleProxy:getWorldTilePos()
    --        self:onMapMove(wtx, wty)
    --    end
end

-- 初始化地图容器和城池，标识物等
function MiniMapPanel:initMapObj()
    -- 容器
    self._panelContainer = self._imgMap:getChildByName("panelContainer")
    local containerSize = self._panelContainer:getContentSize()
    self._miniMapWidth = containerSize.width
    self._miniMapHeight = containerSize.height
    self._mapOriginX = self._miniMapWidth / 2
    self._mapOriginY = 0

    -- 当前在世界的位置
    self._imgCurMapPos = self._panelContainer:getChildByName("imgCurMapPos")
    self._imgCurMapPos:setLocalZOrder(100000001)

    -- 自己位置
    self._imgSelfPos = self._panelContainer:getChildByName("imgSelfPos")
    self._imgSelfPos:setLocalZOrder(100000002)

    -- 当前位置
    self._imgCurPos = self._panelContainer:getChildByName("imgCurPos")
    self._imgCurPos:setLocalZOrder(1000000003)

    
    

    -- 加载城池
    self._cityList = { }
    local cityPosList = ConfigDataManager:getConfigData(ConfigData.MiniMapShowConfig)
    for k, v in pairs(cityPosList) do
        if v.hide == MiniMapPanel.CITY_SHOW then
            local imgCity = ccui.ImageView:create()
            TextureManager:updateImageView(imgCity, "images/miniMapIcon/btnCityNormal" .. v.icon .. ".png")
            local posX, posY = self:getMiniPosition(v.dataX, v.dataY)
            imgCity:setPosition(posX, posY)
            imgCity.cityData = v
            imgCity:setLocalZOrder(self:getCityZOrder(v.dataX, v.dataY))

            self._panelContainer:addChild(imgCity)
            self:addTouchEventListener(imgCity, self.onClickCity)

            local cityKey = self:getCityKey(v.cityType, v.cityId)
            self._cityList[cityKey] = imgCity

            -- 测试添加范围
            --self:setCityRange(imgCity, true)
            -- 测试添加旗子
            --self:setCityFlag(imgCity, false, true)

            if v.nameIcon > 0 then
                local imgName = ccui.ImageView:create()
                TextureManager:updateImageView(imgName, "images/miniMapIcon/spCityName" .. v.nameIcon .. ".png")
                local imgCityH = imgCity:getContentSize().height
                local imgNameH = imgName:getContentSize().width
                imgName:setPosition(posX, posY - imgCityH / 2 - imgNameH / 2 + 10)
                imgCity:setLocalZOrder(1)
                self._panelContainer:addChild(imgName)
            end
        end
    end

end

-- 城的ZOrder
function MiniMapPanel:getCityZOrder(tx, ty)
    return tx * 10000 + ty
end

-- 城的key
function MiniMapPanel:getCityKey(cityType, cityId)
    return cityType * 10000 + cityId
end

-- 获取城池
function MiniMapPanel:getImgCity(cityType, cityId)
    local cityKey = self:getCityKey(cityType, cityId)
    return self._cityList[cityKey]
end

-- 设置占领范围
function MiniMapPanel:setCityRange(imgCity, isShow)
    if imgCity then
        if imgCity.imgRange then
            imgCity.imgRange:setVisible(isShow)
        else
            if isShow then
                local imgRange = ccui.ImageView:create()
                TextureManager:updateImageView(imgRange, "images/miniMapIcon/SpFrameCity.png")
                imgRange:setPosition(imgCity:getContentSize().width / 2, imgCity:getContentSize().height/2)
                imgCity:addChild(imgRange)
            end
        end
    end
end

-- 设置城占领flag
function MiniMapPanel:setCityFlag(imgCity, isEnemy, isShow)
    if imgCity then
        local imgFlag = imgCity.imgFlag
        if imgFlag then
            imgFlag:setVisible(isShow)
            if isEnemy then
                TextureManager:updateImageView(imgFlag, "images/miniMapIcon/spFlagEnemy.png")
            else
                TextureManager:updateImageView(imgFlag, "images/miniMapIcon/spFlagLegion.png")
            end
        else
            if isShow then
                imgFlag = ccui.ImageView:create()
                if isEnemy then
                    TextureManager:updateImageView(imgFlag, "images/miniMapIcon/spFlagEnemy.png")
                else
                    TextureManager:updateImageView(imgFlag, "images/miniMapIcon/spFlagLegion.png")
                end
                imgFlag:setAnchorPoint(0.5, 0)
                imgFlag:setPosition(imgCity:getContentSize().width / 2, imgCity:getContentSize().height)
                imgCity:addChild(imgFlag)
                imgFlag:setVisible(isShow)
                imgCity.imgFlag = imgFlag
            end
        end
    end
end


function MiniMapPanel:showReset()
    self._imgCurPos:setVisible(false)

    self:setSelctCity(nil)

    local mapSize = self._imgMap:getContentSize()
    local svSize = self._svMinMap:getContentSize()
    self._svInner:setPosition((svSize.width - mapSize.width) / 2,(svSize.height - mapSize.height) / 2)

end

function MiniMapPanel:setSelfPosition()
    local roleProxy = self:getProxy(GameProxys.Role)
    local wtx, wty = roleProxy:getWorldTilePos()
    local x, y = self:getMiniPosition(wtx, wty)
    self._imgSelfPos:setPosition(x, y)
end

function MiniMapPanel:setSelctCity(imgCity)
    if self._selectCity ~= nil then
        local oldCityData = self._selectCity.cityData
        TextureManager:updateImageView(self._selectCity, "images/miniMapIcon/btnCityNormal" .. oldCityData.icon .. ".png")
    end

    self._selectCity = imgCity
    if self._selectCity ~= nil then
        local newCityData = self._selectCity.cityData
        TextureManager:updateImageView(self._selectCity, "images/miniMapIcon/btnCityDown" .. newCityData.icon .. ".png")
    end
end

function MiniMapPanel:setLeaderPosition()

    --    self._leaderPosImg:setVisible(false)

end

function MiniMapPanel:setGoPos(tileX, tileY)
    self._goPosX = tileX
    self._goPosY = tileY

    self:updatePosFlas()
end


function MiniMapPanel:updatePosFlas()
    self._txtPos:setString(self._goPosX .. "," .. self._goPosY)

    local miniPosX, miniPosY = self:getMiniPosition(self._goPosX, self._goPosY)
    self._imgCurPos:setPosition(miniPosX, miniPosY)
    self._imgCurPos:setVisible(true)
end

function MiniMapPanel:setCurMiniMapPos(tileX, tileY)
    local mapPosX, mapPosY = self:getMiniPosition(tileX, tileY)
    self._imgCurMapPos:setPosition(mapPosX, mapPosY)
end

function MiniMapPanel:setCurMiniMapPosToCenter(tileX, tileY)
    local mapPosX, mapPosY = self:getMiniPosition(tileX, tileY)
    
    
    local svSize = self._svMinMap:getContentSize()
    local inner = self._svMinMap:getInnerContainer()
    local innerSize = inner:getContentSize()
    local mapSize = self._panelContainer:getContentSize()

    local offsetX = (innerSize.width - mapSize.width) / 2
    local offsetY = (innerSize.height - mapSize.height) / 2

    local innerPosX = svSize.width / 2 - mapPosX - offsetX
    innerPosX = math.max(innerPosX, svSize.width - mapSize.width)
    innerPosX = math.min(innerPosX, 0)

    
    local innerPosY = svSize.height / 2 - mapPosY - offsetY
    innerPosY = math.max(innerPosY, svSize.height - mapSize.height)
    innerPosY = math.min(innerPosY, 0)

    inner:setPositionX(innerPosX)
    inner:setPositionY(innerPosY) 
end

function MiniMapPanel:onMapMove(tileX, tileY)

    local x, y = self:getMiniPosition(tileX, tileY)
    -- print("~~~~~MiniMapPanel:onMapMove(tileX, tileY)~~~~~~~~", x, y)
    --    self._curPosImg:setPosition(x, y)

end

function MiniMapPanel:getMiniPosition(tileX, tileY)
    tileX = tileX - 100
    tileY = tileY - 100
    local tileWidth = self._miniMapWidth / 400
    local tileHeight = self._miniMapHeight / 400
    local mapOriginX = 0
    local mapOriginY = 0
    local x = self._mapOriginX +(tileX - tileY) * tileWidth / 2
    local y = self._mapOriginY +(tileX + tileY + 1) * tileHeight / 2

    -- 先写死一个区域
    if y <= 0 then
        y = 0
    end
    if y >= self._miniMapHeight then
        y = self._miniMapHeight
    end
    if x <= 0 then
        x = 0
    end
    if x >= self._miniMapWidth then
        x = self._miniMapWidth
    end

    local tx, ty = self:getTileByMiniPosition(x, y)
    --    print("=======================================>", tileX, tileY, tx, ty , x, y)
    --    print("=======================================>", tileX, tileY, tx, ty , x, y)
    --    print("=======================================>", tileX, tileY, tx, ty , x, y)
    --    print("=======================================>", tileX, tileY, tx, ty , x, y)

    return x, y
end

function MiniMapPanel:getTileByMiniPosition(x, y)
    local tileWidth = self._miniMapWidth / 400
    local tileHeight = self._miniMapHeight / 400
    local tx =(x - self._mapOriginX) / tileWidth +(y - self._mapOriginY) / tileHeight - 0.5
    local ty = tx - 2 *(x - self._mapOriginX) / tileWidth

    tx = tx < 0 and 0 or tx
    ty = ty < 0 and 0 or ty

    tx = tx > (400 - 1) and (400 - 1) or tx
    ty = ty > (400 - 1) and (400 - 1) or ty

    return math.ceil(tx) + 100, math.ceil(ty) + 100
end

function MiniMapPanel:onClickCity(sender)
    local cityData = sender.cityData

    self:setSelctCity(sender)

    self:setGoPos(cityData.dataX, cityData.dataY)
end

function MiniMapPanel:onClickMiniPanel(sender)
    local pos = sender:getTouchEndPosition()
    local _pos = self._panelContainer:convertToNodeSpace(pos)
    local tx, ty = self:getTileByMiniPosition(_pos.x, _pos.y)
    

    self:setSelctCity(nil)

    self:setGoPos( tx, ty)

end

function MiniMapPanel:onCloseMiniPanel(sender)
    self:hide()
end

function MiniMapPanel:onGoToMap(sender)
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:gotoTileXY(self._goPosX, self._goPosY)

    self:hide()
end

-- 显示自己的郡城旗子
function MiniMapPanel:onUpdateMyTownFlag()
    local cityPosList = ConfigDataManager:getConfigData(ConfigData.MiniMapShowConfig)
    
    -- 初始化旗子
    for i , configInfo in pairs(cityPosList) do
        local imgCity = self:getImgCity(configInfo.cityType, configInfo.cityId)
        self:setCityFlag(imgCity, false, false)
    end

    local myLegionName = self._roleProxy:getLegionName() 
    local townInfoList = self._cityWarProxy:getTownStateList()
    for i , info in pairs(townInfoList) do
        local townId = info.typeId 
        local state  = info.state -- 1 己方，2非己方 未占领的不发

        local configInfo = cityPosList[townId]
        local imgCity = self:getImgCity(configInfo.cityType, configInfo.cityId)
        if state == 1 then
            self:setCityFlag(imgCity, false, true)
        elseif state == 2 then
            self:setCityFlag(imgCity, true, true)
        end
    end
end