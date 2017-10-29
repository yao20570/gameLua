-- 世界地图上的建筑类
UIWorldNodeCity = class("UIWorldNodeCity", UIWorldNodeBase)
UIWorldNodeCity.__index = UIWorldNodeCity

function UIWorldNodeCity:ctor(tileType)
    UIWorldNodeCity.super.ctor(self, tileType)
end

function UIWorldNodeCity:finalize()
    self._lordCityProxy = nil
    self._cityId = nil
end

function UIWorldNodeCity:setPosition(pos)
    UIWorldNodeCity.super.setPosition(self, pos)

    if self._nameParent ~= nil then
        -- 名称
        local namePos = cc.p(-5, 160)
        if self._cityTxtBg ~= nil then
            self._cityTxtBg:setPositionX(pos.x + namePos.x)
            self._cityTxtBg:setPositionY(pos.y + namePos.y)
        end
        if self._cityNameTxt ~= nil then
            self._cityNameTxt:setPositionX(pos.x + namePos.x)
            self._cityNameTxt:setPositionY(pos.y + namePos.y)
        end

        -- 同盟信息
        local legionPos = cc.p(-5, 136)
        if self._legionIcon ~= nil then
            self._legionIcon:setPositionX(pos.x + legionPos.x - 50)
            self._legionIcon:setPositionY(pos.y + legionPos.y)
        end
        if self._legionFontBg ~= nil then
            self._legionFontBg:setPositionX(pos.x + legionPos.x)
            self._legionFontBg:setPositionY(pos.y + legionPos.y)
        end
        if self._legionNameTxt ~= nil then
            self._legionNameTxt:setPositionX(pos.x + legionPos.x)
            self._legionNameTxt:setPositionY(pos.y + legionPos.y)
        end

        -- 状态图片
        local statePos = cc.p(-5, -140)
        if self._cityStateImg ~= nil then
            self._cityStateImg:setPositionX(pos.x + statePos.x)
            self._cityStateImg:setPositionY(pos.y + statePos.y)
        end

        -- 倒计时
        local timePos = cc.p(-5, -172)
        if self._remainTimeIcon ~= nil then
            self._remainTimeIcon:setPositionX(pos.x + timePos.x - 50)
            self._remainTimeIcon:setPositionY(pos.y + timePos.y)
        end
        -- 倒计时框
        if self._remainTimeBg ~= nil then
            self._remainTimeBg:setPositionX(pos.x + timePos.x)
            self._remainTimeBg:setPositionY(pos.y + timePos.y)
        end
        -- 倒计时
        if self._remainTimeTxt ~= nil then
            self._remainTimeTxt:setPositionX(pos.x + timePos.x)
            self._remainTimeTxt:setPositionY(pos.y + timePos.y)
        end
    end
end

function UIWorldNodeCity:renderTile(worldTileInfo, mapPanel)
    UIWorldNodeCity.super.renderTile(self, worldTileInfo, mapPanel)

    self._lordCityProxy = mapPanel:getProxy(GameProxys.LordCity)
    self._cityId = worldTileInfo.cityId

    local n = worldTileInfo.x
    local m = worldTileInfo.y

    local isPlacePos = self._lordCityProxy:isLordCityPlacePos(n, m)
    self._isPlacePos = isPlacePos
    
    local isVisible = isPlacePos
    if isPlacePos == true then -- 有城池
        local configInfo = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig, self._cityId)
        
        -- 城池图片
        local url = string.format("bg/map/iconCity%d.png", configInfo.icon)
        if self._cityImg == nil then
            --self._cityImg = TextureManager:createSprite(url)
            self._cityImg = TextureManager:createImageViewFile(url)
            self:addChild(self._cityImg)
        else
            --TextureManager:updateSprite(self._cityImg, url)
            TextureManager:updateImageViewFile(self._cityImg, url)
        end

        local pos = cc.p(-5, 160)

        local nameParent = self._nameParent or self
        --城池名字框
        if self._cityTxtBg == nil then
            local url = "images/map/Bg_resLvBg.png"
            local rect_table = cc.rect(14,8,48,10)
            self._cityTxtBg = TextureManager:createScale9Sprite(url, rect_table)
            self._cityTxtBg:setPosition(pos)
            nameParent:addChild(self._cityTxtBg, 10)
        end
        
        --城池名字
        local name = configInfo.name 
        if self._cityNameTxt == nil then
            self._cityNameTxt = ccui.Text:create()
            self._cityNameTxt:setFontName(GlobalConfig.fontName) 
            self._cityNameTxt:setFontSize(UIWorldCityWar.FONT_SIZE)
            self._cityNameTxt:setPosition(pos)
            nameParent:addChild(self._cityNameTxt, 20)
        end
        self._cityNameTxt:setString(name)
    end

    if self._cityImg ~= nil then
        self._cityImg:setVisible(isVisible)
    end
    if self._cityTxtBg ~= nil then
        self._cityTxtBg:setVisible(isVisible)
    end
    if self._cityNameTxt ~= nil then
        self._cityNameTxt:setVisible(isVisible)
    end

    self:showLegionInfo()

end

-- 显示占领同盟信息
function UIWorldNodeCity:showLegionInfo()
    local isVisible = false

    local state = 0
    local remainTime = 0
    local hostLegion = ""

    if self._isPlacePos then
        local cityHostMap = self._lordCityProxy:getCityHostMap()
        local cityHost
        if cityHostMap then
            cityHost = cityHostMap[self._cityId]
            if cityHost then
                isVisible = true
                
                hostLegion = cityHost.hostLegion
                self:addLegionInfo(cityHost)

                state,remainTime = self._lordCityProxy:getCityStateAndTime(self._cityId)
                self:addStateInfo(state)
                if state ~= 0 then
                    self:addRemainTime(remainTime)
                end
            else
                self:runCityReq()
            end
        else
            self:runCityReq()
        end
    end

    if self._cityStateImg ~= nil then
        self._cityStateImg:setVisible(isVisible)
    end

    local isVisible2 = isVisible
    if hostLegion == "" then
        isVisible2 = false        
    end
    if self._legionIcon ~= nil then
        self._legionIcon:setVisible(isVisible2)
    end
    if self._legionFontBg ~= nil then
        self._legionFontBg:setVisible(isVisible2)
    end
    if self._legionNameTxt ~= nil then
        self._legionNameTxt:setVisible(isVisible2)
    end


    if state == 0 then --休战中不显示倒计时
        isVisible = false
    end
    if self._remainTimeIcon ~= nil then
        self._remainTimeIcon:setVisible(isVisible)
    end
    if self._remainTimeBg ~= nil then
        self._remainTimeBg:setVisible(isVisible)
    end
    if self._remainTimeTxt ~= nil then
        self._remainTimeTxt:setVisible(isVisible)
    end


end

function UIWorldNodeCity:runCityReq()
    local rolePrxoy = self._mapPanel:getProxy(GameProxys.Role)
    if rolePrxoy:isFunctionUnLock(57,false) == false then
        return
    end
    
    if self._isPlacePos and self._cityId then
        self._lordCityProxy:onTriggerNet360011Req({cityId = self._cityId})  --还没有城主战数据，就请求一下城池数据
    end
end

function UIWorldNodeCity:addLegionInfo(cityHost)
    local legionName = cityHost.hostLegion
    local pos = cc.p(-5, 136)

    local nameParent = self._nameParent or self
    -- 同盟图标
    if self._legionIcon == nil then
        local url = "images/map/fontLgion.png"
        self._legionIcon = TextureManager:createImageView(url)
        nameParent:addChild(self._legionIcon, 20)

        self._legionIcon:setPosition(pos.x - 50, pos.y)
    end
    -- 同盟名字框
    if self._legionFontBg == nil then
        local url = "images/map/bgLegionTxt.png"
        self._legionFontBg = TextureManager:createImageView(url)
        nameParent:addChild(self._legionFontBg, 10)
        self._legionFontBg:setPosition(pos)
    end
    -- 同盟名字
    if  self._legionNameTxt == nil then
        self._legionNameTxt = ccui.Text:create()
        self._legionNameTxt:setFontName(GlobalConfig.fontName) 
        self._legionNameTxt:setFontSize(UIWorldCityWar.FONT_SIZE)
        nameParent:addChild(self._legionNameTxt, 20)
        self._legionNameTxt:setPosition(pos)
    end

    self._legionNameTxt:setString(legionName)
    self._legionNameTxt:setColor(ColorUtils.wordBlueColor)
end

function UIWorldNodeCity:addStateInfo(state)
    local pos = cc.p(-5, -140)

    local nameParent = self._nameParent or self
    -- 状态图片
    local url = "images/map/cityState" .. state .. ".png"
    if self._cityStateImg == nil then
        self._cityStateImg = TextureManager:createImageView(url)
        nameParent:addChild(self._cityStateImg, 10)
        self._cityStateImg:setPosition(pos)
    else
        TextureManager:updateImageView(self._cityStateImg,url)
    end

end

function UIWorldNodeCity:addRemainTime(remainTime)
    local pos = cc.p(-5, -172)

    local nameParent = self._nameParent or self
    -- 倒计时图标
    if self._remainTimeIcon == nil then
        local url = "images/newGui2/IconTime.png"
        self._remainTimeIcon = TextureManager:createImageView(url)
        nameParent:addChild(self._remainTimeIcon, 20)

        self._remainTimeIcon:setPosition(pos.x - 50, pos.y)
    end
    -- 倒计时框
    if self._remainTimeBg == nil then
        local url = "images/map/bgLegionTxt.png"
        self._remainTimeBg = TextureManager:createImageView(url)
        nameParent:addChild(self._remainTimeBg, 10)
        self._remainTimeBg:setPosition(pos)
    end
    -- 倒计时
    if  self._remainTimeTxt == nil then
        self._remainTimeTxt = ccui.Text:create()
        self._remainTimeTxt:setFontName(GlobalConfig.fontName) 
        self._remainTimeTxt:setFontSize(UIWorldCityWar.FONT_SIZE)
        nameParent:addChild(self._remainTimeTxt, 20)
        self._remainTimeTxt:setPosition(pos)
    end

    remainTime = TimeUtils:getStandardFormatTimeString(remainTime)
    self._remainTimeTxt:setString(remainTime)

end

function UIWorldNodeCity:onClickEvent()
    local x = self._worldTileInfo.x
    local y = self._worldTileInfo.y
    if self:isCanClick(x, y) then
        self._mapPanel:onCityTileTouch(self._worldTileInfo)
    end
end

