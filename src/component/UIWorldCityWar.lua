-- 世界地图上的建筑类
UIWorldCityWar = class("UIWorldCityWar", UIWorldNodeBase)
UIWorldCityWar.__index = UIWorldCityWar

UIWorldCityWar.FONT_SIZE = 16

function UIWorldCityWar:ctor(tileType)
    UIWorldCityWar.super.ctor(self, tileType)
end


function UIWorldCityWar:finalize()
    if self._cityWarEffect ~= nil then
        self._cityWarEffect:finalize()
        self._cityWarEffect = nil
    end
    if self._sp ~= nil then
        self._sp:removeFromParent()
        self._sp = nil
    end

    TimerManager:remove(self.updateRemainTime, self)
    TimerManager:remove(self.updateMap, self)
end

function UIWorldCityWar:onExit()
    TimerManager:remove(self.updateRemainTime, self)
    TimerManager:remove(self.updateMap, self)
end

function UIWorldCityWar:setPosition(pos)
    UIWorldCityWar.super.setPosition(self, pos)

    if self._nameParent ~= nil then
        local dy = GlobalConfig.WorldPlayerTitlePos.y

        -- 名称
        if self._buildTxtBg ~= nil then
            self._buildTxtBg:setPositionX(pos.x - 5)
            self._buildTxtBg:setPositionY(pos.y + dy + 25)
        end
        if self._buildNameTxt ~= nil then
            self._buildNameTxt:setPositionX(pos.x - 5)
            self._buildNameTxt:setPositionY(pos.y + dy + 26)
        end

        -- 同盟信息
        if self._legionIcon ~= nil then
            self._legionIcon:setPositionX(pos.x - 55)
            self._legionIcon:setPositionY(pos.y + dy + 3)
        end
        if self._legionFontBg ~= nil then
            self._legionFontBg:setPositionX(pos.x - 5)
            self._legionFontBg:setPositionY(pos.y + dy)
        end
        if self._legionNameTxt ~= nil then
            self._legionNameTxt:setPositionX(pos.x - 5)
            self._legionNameTxt:setPositionY(pos.y + dy + 1)
        end

        -- 状态图片
        local statePos = cc.p(-5, -140)
        if self._stateImg ~= nil then
            self._stateImg:setPositionX(pos.x)
            self._stateImg:setPositionY(pos.y - 50)
        end

        -- 倒计时
        local timePos = cc.p(0, -22)
        if self._timeBg ~= nil then
            self._timeBg:setPositionX(pos.x + timePos.x) 
            self._timeBg:setPositionY(pos.y + timePos.y) 
        end
        if self._timeTxt ~= nil then
            self._timeTxt:setPositionX(pos.x + timePos.x)
            self._timeTxt:setPositionY(pos.y + timePos.y)
        end


        -- 队伍信息
        local teamImgPos = cc.p(3, 0)
        if self._teamImg ~= nil then
            self._teamImg:setPositionX(pos.x + teamImgPos.x)
            self._teamImg:setPositionY(pos.y + teamImgPos.y)
        end
    end
end

function UIWorldCityWar:renderTile(worldTileInfo, mapPanel)
    UIWorldCityWar.super.renderTile(self, worldTileInfo, mapPanel)

    local townInfo = worldTileInfo.townInfo
    if townInfo == nil then
        return
    end
    self._townInfo = townInfo


    --城配置数据
    local configInfo = ConfigDataManager:getConfigById(ConfigData.TownWarConfig, townInfo.townId)

    self._worldPorxy = self._mapPanel:getProxy(GameProxys.World)

    -- 州城图片，暂时用主城替代
    local cityWarIcon = configInfo.cityIcon

    local url = string.format("images/map/town%d.png", cityWarIcon)
    if self._sprite == nil then
        self._sprite = TextureManager:createSprite(url)
        self:addChild(self._sprite)
    else
        TextureManager:updateSprite(self._sprite, url)
    end

    -- 标题文本和背景设置
    self:addBuildingTxt(worldTileInfo, configInfo)
    logger:info(configInfo.stateName)

    -- 占领盟
    self:addOccupyTxt(worldTileInfo, configInfo)

    -- 状态设置
    self:addTownState(worldTileInfo, configInfo)

    -- 时间和倒计时
    self:addTownRemainTime(worldTileInfo)

    -- 报名队列
    self:addTeamShow(worldTileInfo)

    -- 保护罩特效
    self:addCityWarEffect(worldTileInfo)
end

function UIWorldCityWar:addBuildingTxt(worldTileInfo, configInfo)
    local townInfo = worldTileInfo.townInfo -- 网络数据
    local configInfo = configInfo             -- 配置数据

    local nameParent = self._nameParent or self

    local dy = GlobalConfig.WorldPlayerTitlePos.y
    if self._buildTxtBg == nil then
        local url = "images/map/Bg_resLvBg.png"
        local rect_table = cc.rect(14,8,48,10)
        self._buildTxtBg = TextureManager:createScale9Sprite(url, rect_table)
        self._buildTxtBg:setPosition(-5, dy+ 25)
        nameParent:addChild(self._buildTxtBg, 1)
    end
    
    local name = configInfo.stateName -- 州城名字

    if self._buildNameTxt == nil then
        self._buildNameTxt = ccui.Text:create()
        self._buildNameTxt:setFontName(GlobalConfig.fontName) 
        self._buildNameTxt:setFontSize(UIWorldCityWar.FONT_SIZE)
        self._buildNameTxt:setPosition(-5, dy+ 26)
        nameParent:addChild(self._buildNameTxt, 3)
    end

    self._buildNameTxt:setString(name) -- size

    -- 设置背景大小
    local buildingTextWidth  = self._buildNameTxt:getContentSize().width + 25
    local buildingTextHeight = UIWorldCityWar.FONT_SIZE*1.7
    self._buildTxtBg:setContentSize(buildingTextWidth, buildingTextHeight)

    -- 建筑信息

    -- 建筑状态
    self._stateStatus = townInfo.stateStatus

    -- 归属盟
    local legionName = townInfo.legionName

end

------
-- 设置占领信息
function UIWorldCityWar:addOccupyTxt(worldTileInfo, configInfo)
    local townInfo = worldTileInfo.townInfo -- 网络数据
    local configInfo = configInfo           -- 配置数据

    local dy = GlobalConfig.WorldPlayerTitlePos.y
    local legionName = townInfo.legionName -- 军团名字
    
    local nameParent = self._nameParent or self

    if self._legionIcon == nil then
        local url = "images/map/fontLgion.png"
        self._legionIcon = TextureManager:createImageView(url)
        nameParent:addChild(self._legionIcon, 2)

        self._legionIcon:setPosition(-55, dy + 3)
    end

    if self._legionFontBg == nil then
        local url = "images/map/bgLegionTxt.png"
        self._legionFontBg = TextureManager:createImageView(url)
        nameParent:addChild(self._legionFontBg, 1)
        self._legionFontBg:setPosition(-5, dy)
    end


    if  self._legionNameTxt == nil then
        self._legionNameTxt = ccui.Text:create()
        self._legionNameTxt:setFontName(GlobalConfig.fontName) 
        self._legionNameTxt:setFontSize(UIWorldCityWar.FONT_SIZE)
        nameParent:addChild(self._legionNameTxt, 2)
        self._legionNameTxt:setPosition(-5, dy + 1)
    end


    if legionName == "" then 
        self._legionNameTxt:setString(TextWords:getTextWord(471022)) 
        self._legionNameTxt:setColor(ColorUtils.wordRedColor)
    else
        self._legionNameTxt:setString(legionName) 
        self._legionNameTxt:setColor(ColorUtils.wordBlueColor)
    end

    -- 有人占领，需要把郡城标题隐藏
    if legionName == "" then 
        self._buildTxtBg:setVisible(true)
        self._buildNameTxt:setVisible(true)
    else
        self._buildTxtBg:setVisible(false)
        self._buildNameTxt:setVisible(false)
    end

end





function UIWorldCityWar:onClickEvent()

    local x = self._worldTileInfo.x
    local y = self._worldTileInfo.y
    if self:isCanClick(x, y) then
        self._mapPanel:onWatchCityWarTouch(x , y, self._stateStatus)
        logger:info( string.format("点击盟战地点，坐标：%s,%s", x, y))
    end
end


--玩家基地标题缩放
-- @fontScale   标题缩放参数
function UIWorldCityWar:setBuildTxtScale(scale, fontScale)
    -- 改变的是字体大小，之后背景随着改变
    if self._buildTxtBg ~= nil and self._buildNameTxt ~= nil then
        self._buildNameTxt:setFontSize(UIWorldCityWar.FONT_SIZE * fontScale)

        local nameLen = StringUtils:separate(self._buildNameTxt:getString() or " ")

        local buildingTextWidth = self._buildNameTxt:getContentSize().width + 25
        local buildingTextHeight = UIWorldCityWar.FONT_SIZE * 1.7
        self._buildTxtBg:setContentSize(buildingTextWidth, buildingTextHeight)
    end

    if self._sprite ~= nil then
        self._sprite:setScale(scale)
    end

    -- 状态设置
    if self._stateImg ~= nil then
        self._stateImg:setScale(scale)
    end

    -- 状态设置
    if self._teamImg ~= nil then
        self._teamImg:setScale(scale)
    end

    -- 时间缩放
    --    self._timeBg:setScale(scale)
    --    self._timeTxt:setScale(scale)


end



-- 状态设置
function UIWorldCityWar:addTownState(worldTileInfo, configInfo)
    local townInfo = worldTileInfo.townInfo -- 网络数据
    local configInfo = configInfo             -- 配置数据

    local stateStatus = townInfo.stateStatus -- 状态
--    local stateStatus = 5
    if self:isShowState(stateStatus) then
        local nameParent = self._nameParent or self

        local url = string.format("images/map/townState%d.png", stateStatus)
        if stateStatus == 5 then -- 休战期特殊处理
            url = "images/map/cityState0.png"
        end
        
        if self._stateImg == nil then
            self._stateImg = TextureManager:createImageView(url)

            nameParent:addChild(self._stateImg, 1)
            self._stateImg:setPositionY(self._stateImg:getPositionY() - 50 )
        else
            TextureManager:updateImageView(self._stateImg, url)
        end
        self._stateImg:setVisible(true)
    else
        if self._stateImg ~= nil then
            self._stateImg:setVisible(false)
        end
    end

end

------
-- 倒计时相关组件显示
function UIWorldCityWar:addTownRemainTime(worldTileInfo)
    
    local nameParent = self._nameParent or self

    if self._timeBg == nil then
        local url = "images/map/bgLegionTxt.png"
        self._timeBg = TextureManager:createImageView(url)
        nameParent:addChild(self._timeBg, 1)
        self._timeBg:setPositionY(self._timeBg:getPositionY() - 22 ) -- 78
    end

    if self._timeBg.clockImg == nil then
        local url = "images/newGui2/IconTime.png"
        self._timeBg.clockImg = TextureManager:createImageView(url)
        self._timeBg:addChild(self._timeBg.clockImg, 1)
        self._timeBg.clockImg:setPosition(5,10)
    end

    if self._timeTxt == nil then
        self._timeTxt = ccui.Text:create()
        self._timeTxt:setFontName(GlobalConfig.fontName) 
        self._timeTxt:setFontSize(UIWorldCityWar.FONT_SIZE)
        nameParent:addChild(self._timeTxt, 2)
        self._timeTxt:setPositionY(self._timeTxt:getPositionY() - 21 ) -- 77
    end
    
    -- 默认显示
    self._timeBg:setVisible(true)
    self._timeTxt:setVisible(true)

    local nodeKey = self:getNodeKey(self._worldTileInfo.x, self._worldTileInfo.y)
    self._nodeKey = nodeKey

    -- 时间为0则隐藏
    if worldTileInfo.townInfo.nextStateTime == 0 then
        self._timeBg:setVisible(false)
        self._timeTxt:setVisible(false)
    end

    -- 倒计时
    self:updateRemainTime()
end

function UIWorldCityWar:updateRemainTime()
    local remainTime = self._worldPorxy:getRemainTime(self._nodeKey)
    local timeStr = TimeUtils:getStandardFormatTimeString6(remainTime, true)
    if remainTime > 170*3600 then -- 总开放时间超过170小时，时间显示：即将开启
        timeStr = TextWords:getTextWord(284) -- "即将开启"
    end
    self._timeTxt:setString(timeStr)

    if self._timeBg and self._timeTxt then
        self._timeBg:setVisible(remainTime > 0)
        self._timeTxt:setVisible(remainTime > 0)
    end

    if remainTime > 0 then
        TimerManager:addOnce(1000, self.updateRemainTime, self)
    else
        TimerManager:addOnce(1000, self.updateMap, self)
    end
end

function UIWorldCityWar:updateMap()
    self._mapPanel:dispatchEvent(MapEvent.WORLD_TILE_INFOS_REQ, {x = self._worldTileInfo.x, y = self._worldTileInfo.y})
end

-- 报名队伍
function UIWorldCityWar:addTeamShow(worldTileInfo)

    local townInfo = worldTileInfo.townInfo -- 网络数据
    local stateStatus = townInfo.stateStatus

    local nameParent = self._nameParent or self

--    local stateStatus = 5
    -- 父节点
    if self._teamImg == nil then
        local url = "images/newGui1/none.png"
        self._teamImg = TextureManager:createImageView(url)
        nameParent:addChild(self._teamImg, 1)
    end

    -- 图标
    if self._attackImg == nil then
        local url = "images/map/font_town_attack.png"
        self._attackImg = TextureManager:createImageView(url)
        self._teamImg:addChild(self._attackImg, 1)
        self._attackImg:setPosition(66, 115) -- 61
    end

    if self._defenseImg == nil then
        local url = "images/map/font_town_defense.png"
        self._defenseImg = TextureManager:createImageView(url)
        self._teamImg:addChild(self._defenseImg, 1)
        self._defenseImg:setPosition(66, 90) -- 87
    end
    
    -- 文本
    if self._attackTxt == nil then
        self._attackTxt = ccui.Text:create()
        self._attackTxt:setFontName(GlobalConfig.fontName) 
        self._attackTxt:setFontSize(UIWorldCityWar.FONT_SIZE)
        self._attackTxt:setAnchorPoint( cc.p(0,0.5))
        self._attackImg:addChild(self._attackTxt, 1)
        self._attackTxt:setPosition(25, 12)
    end

    if self._defenseTxt == nil then
        self._defenseTxt = ccui.Text:create()
        self._defenseTxt:setFontName(GlobalConfig.fontName) 
        self._defenseTxt:setFontSize(UIWorldCityWar.FONT_SIZE)
        self._defenseTxt:setAnchorPoint( cc.p(0,0.5))
        self._defenseImg:addChild(self._defenseTxt, 1)
        self._defenseTxt:setPosition(25, 12)
    end

    if stateStatus == 0 then -- 0未开放
        self._attackImg:setVisible(false)
        self._defenseImg:setVisible(false)
    elseif stateStatus == 1 then -- 1可宣战 占领期间
        self._attackImg:setVisible(true)
        self._defenseImg:setVisible(true)
    else
        self._attackImg:setVisible(true)
        self._defenseImg:setVisible(true)
    end




    -- 设置队伍数量
    self._attackTxt:setString(townInfo.attackNum)
    self._defenseTxt:setString(townInfo.defendNum)
end


-- 保护罩特效
function UIWorldCityWar:addCityWarEffect(worldTileInfo)
    local townInfo = worldTileInfo.townInfo -- 网络数据
    -- 0未开放1可宣战时期2宣战（可派兵）期间3开战期间4保护期间5休战期间
    local state = townInfo.stateStatus -- 状态
--    local state = 5
    if self._cityWarEffect ~= nil then
        self._cityWarEffect:finalize()
        self._cityWarEffect = nil
    end

    -- 添加精灵
    if self._sp == nil then
        self._sp = cc.Sprite:create()
        self:addChild(self._sp, 1)
    end
    self._sp:setPosition(0,0)
    self._sp:setScale(1)

    local ccbName = ""
    if state == 2 then
        ccbName = "rgb-mz-zhangu"
    elseif state == 3 then
        ccbName = "rgb-fight-knife"
    elseif state == 4 then
        ccbName = "rgb-mz-zhaozi"
    elseif state == 5 then
        ccbName = "rgb-mz-zhaozi"
    end
    if ccbName == "" then
        if self._cityWarEffect ~= nil then
            self._cityWarEffect:finalize()
            self._cityWarEffect = nil
        end
    else
        self._cityWarEffect = UICCBLayer.new(ccbName, self._sp)
        if state == 2 then
            self._sp:setScale(0.6)
            self._sp:setPosition(-65, -52)
        elseif state == 3 then
            self._sp:setScale(0.7)
        elseif state == 4 then
            self._sp:setScale(0.7)
            self._sp:setPosition(-10, 8)
        elseif state == 5 then
            self._sp:setScale(0.7)
            self._sp:setPosition(-10, 8)
        end
    end
end


function UIWorldCityWar:isShowState(state)
    local showList = {0, 2, 3, 4, 5} -- 0未开放1可宣战时期2宣战（可派兵）期间3开战期间4保护期间5休战期间
    local isShow = false
    for i = 1, #showList do
        if state == showList[i] then
            isShow = true
            break
        end
    end
    return isShow
end

function UIWorldCityWar:getNodeKey(x, y)
    return x.."_"..y
end

function UIWorldCityWar:getOldCityWarTownInfo()
    return self._townInfo
end

function UIWorldCityWar:getOldKey()
    return self:getNodeKey(self._worldTileInfo.x, self._worldTileInfo.y)
end

function UIWorldCityWar:getTownId()
    return self._townInfo.townId
end

function UIWorldCityWar:getTownTimeTxtVisible()
    return self._timeTxt:isVisible()
end

