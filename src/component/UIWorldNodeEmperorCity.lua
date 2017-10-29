-- 世界地图上的建筑类：皇城建筑
UIWorldNodeEmperorCity = class("UIWorldNodeEmperorCity", UIWorldNodeBase)
UIWorldNodeEmperorCity.__index = UIWorldNodeEmperorCity

UIWorldNodeEmperorCity.FONT_SIZE = 16


function UIWorldNodeEmperorCity:ctor(tileType)
    UIWorldNodeEmperorCity.super.ctor(self, tileType)

end

function UIWorldNodeEmperorCity:finalize()

end

function UIWorldNodeEmperorCity:setPosition(pos)
    UIWorldNodeEmperorCity.super.setPosition(self, pos)

    if self._nameParent ~= nil then
        local dy = GlobalConfig.WorldPlayerTitlePos.y

        local topFixY = 40
        local bottomFixY = 0
        if self._configInfo then
            if self._cityType == 1 then
                topFixY = 37
                bottomFixY = -61
            elseif self._cityType == 2 then
                topFixY = 85
                bottomFixY = -82
            elseif self._cityType == 3 then
                topFixY = 120
                bottomFixY = -115
            end
        end

        -- 名称
        if self._buildTxtBg ~= nil then
            self._buildTxtBg:setPositionX(pos.x - 5)
            self._buildTxtBg:setPositionY(pos.y + dy + 25 + topFixY)
        end
        if self._buildNameTxt ~= nil then
            self._buildNameTxt:setPositionX(pos.x - 5)
            self._buildNameTxt:setPositionY(pos.y + dy + 26+ topFixY)
        end

        -- 同盟信息
        if self._legionIcon ~= nil then
            self._legionIcon:setPositionX(pos.x - 55)
            self._legionIcon:setPositionY(pos.y + dy + 3+ topFixY)
        end
        if self._legionFontBg ~= nil then
            self._legionFontBg:setPositionX(pos.x - 5)
            self._legionFontBg:setPositionY(pos.y + dy+ topFixY)
        end
        if self._legionNameTxt ~= nil then
            self._legionNameTxt:setPositionX(pos.x - 5)
            self._legionNameTxt:setPositionY(pos.y + dy + 1+ topFixY)
        end

        -- 进度条
        if self._loadBarBg ~= nil then
            self._loadBarBg:setPositionX(pos.x - 5)
            self._loadBarBg:setPositionY(pos.y + dy - 20 + topFixY)
        end

        -------------------------------------------------------

        if self._sp ~= nil and self._cityinfo then
            self:setCcbSpScalePos(self._sp, cc.p(pos.x, pos.y - 50 + bottomFixY)) -- 用状态图片位置
        end
    end
end


function UIWorldNodeEmperorCity:renderTile(worldTileInfo, mapPanel)
    UIWorldNodeEmperorCity.super.renderTile(self, worldTileInfo, mapPanel)
    
    --todocity
    self._worldTileInfo = worldTileInfo
    local cityInfo = worldTileInfo.cityInfo
    self._cityinfo = cityInfo

    if cityInfo == nil then
        return
    end
    --
    local cityId = cityInfo.cityId
    -- 皇城配置数据
    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarConfig, cityId)
    self._configInfo = configInfo
    self._cityType = self._configInfo.type
    self._cityId   = self._configInfo.cityId

    -- 图片主节点
    local cityIcon = configInfo.cityIcon
    local url = string.format("bg/map/iconCity%d.png", configInfo.cityIcon)
    if self._sprite == nil then
        self._sprite = TextureManager:createImageViewFile(url)
        self:addChild(self._sprite )
        self._sprite:setPosition(5, 15)
        if self._cityType ~= 1 then
            self._mapPanel:addWorldWidgetTouchCancleList(self._sprite, self, self.onClickEventCancle)
        end
    else
        TextureManager:updateImageViewFile(self._sprite, url)
    end

    -- 添加touch层( img_head,  )
    if self._touchImg == nil then
--        local url = "images/newGui1/IconPinZhi6.png"
--        local rect_table = cc.rect(3,3,3,3)
        local url = "images/newGui1/none.png"
        local rect_table = cc.rect(1,1,1,1)
        self._touchImg = TextureManager:createScale9ImageView(url, rect_table)
        self:addChild(self._touchImg, 1)
        self._mapPanel:addWorldWidgetTouchList(self._touchImg, self, self.onClickEvent)
        
        local spSize = self._sprite:getContentSize()
        self:setSizeAndPos(spSize, self._touchImg, self._cityType)
    else
        local spSize = self._sprite:getContentSize()
        self:setSizeAndPos(spSize, self._touchImg, self._cityType)
    end

    self._nodeKey = self._worldTileInfo.x.."_"..self._worldTileInfo.y
    
    -- 标题文本和背景设置
    self:addBuildingTxt(worldTileInfo, configInfo)

    -- 占领盟
    self:addOccupyTxt(worldTileInfo, configInfo)

    -- 进度条显示（进度表和百分比文本）
    self:addProBarShow(worldTileInfo, configInfo)

    -- 特效显示
    self:addEmperorCityEffect(worldTileInfo, configInfo)

    -- 显示状态问题
    self:setNodeVisible(worldTileInfo)
end



function UIWorldNodeEmperorCity:addBuildingTxt(worldTileInfo, configInfo)
    local nameParent = self._nameParent 

    local dy = GlobalConfig.WorldPlayerTitlePos.y

    if self._buildNameTxt == nil then
        self._buildNameTxt = ccui.Text:create()
        self._buildNameTxt:setFontName(GlobalConfig.fontName) 
        self._buildNameTxt:setFontSize(UIWorldNodeEmperorCity.FONT_SIZE)
        nameParent:addChild(self._buildNameTxt, 3)
    end

    if self._buildTxtBg == nil then
        local url = "images/map/Bg_resLvBg.png"
        local rect_table = cc.rect(14,8,48,10)
        self._buildTxtBg = TextureManager:createScale9Sprite(url, rect_table)
        nameParent:addChild(self._buildTxtBg, 1)
    end

    -- 设置背景大小和名字
    local name = configInfo.cityName 
    self._buildNameTxt:setString(name)
    local buildingTextWidth  = self._buildNameTxt:getContentSize().width + 25
    local buildingTextHeight = UIWorldNodeEmperorCity.FONT_SIZE*1.7
    self._buildTxtBg:setContentSize(buildingTextWidth, buildingTextHeight)
end



function UIWorldNodeEmperorCity:onClickEvent()
    -- todo
    -- 根据有没有在活动状态里面 ， 飘字：即将开启，敬请期待
    if self._mapPanel:isEmperorCityUnLock() == false then
        self._mapPanel:showSysMessage(TextWords:getTextWord(821))
        return 
    end

    local x = self._worldTileInfo.x
    local y = self._worldTileInfo.y
    if self:isCanClick(x, y) then
        self._mapPanel:onEmperorCityTouch(x , y)
    end
end


function UIWorldNodeEmperorCity:onClickEventCancle()
    logger:info("点击到了图片")
end



--玩家基地标题缩放
-- @fontScale   标题缩放参数
function UIWorldNodeEmperorCity:setBuildTxtScale(scale, fontScale)
    -- 改变的是字体大小，之后背景随着改变
    if self._buildTxtBg ~= nil and self._buildNameTxt ~= nil then
        self._buildNameTxt:setFontSize( UIWorldNodeEmperorCity.FONT_SIZE * fontScale)
        
        local nameLen = StringUtils:separate(self._buildNameTxt:getString() or " ")
        
        local buildingTextWidth  = self._buildNameTxt:getContentSize().width + 25
        local buildingTextHeight = UIWorldNodeEmperorCity.FONT_SIZE*1.7
        self._buildTxtBg:setContentSize(buildingTextWidth, buildingTextHeight)
    end

    -- 主城精灵缩放
    if self._sprite ~= nil then
        self._sprite:setScale(0.8) -- 7653#皇城战建筑缩小
    end
end

-- 获取特效名字
function UIWorldNodeEmperorCity:getCcbName(cityStatus)
    local ccbName = "" 
    if cityStatus == 1 or cityStatus == 2 then 
        ccbName = "rgb-mz-zhaozi"
    end
    return ccbName
end

------
-- 设置占领信息
function UIWorldNodeEmperorCity:addOccupyTxt(worldTileInfo, configInfo)
    local cityInfo = worldTileInfo.cityInfo -- 网络数据
    local configInfo = configInfo           -- 配置数据
    local dy = GlobalConfig.WorldPlayerTitlePos.y
    local legionName = cityInfo.legionName -- 军团名字

    local nameParent = self._nameParent or self

    if self._legionIcon == nil then
        local url = "images/map/fontLgion.png"
        self._legionIcon = TextureManager:createImageView(url)
        nameParent:addChild(self._legionIcon, 2)
    end

    if self._legionFontBg == nil then
        local url = "images/map/bgLegionTxt.png"
        self._legionFontBg = TextureManager:createImageView(url)
        nameParent:addChild(self._legionFontBg, 1)
    end

    if  self._legionNameTxt == nil then
        self._legionNameTxt = ccui.Text:create()
        self._legionNameTxt:setFontName(GlobalConfig.fontName) 
        self._legionNameTxt:setFontSize(UIWorldNodeEmperorCity.FONT_SIZE)
        nameParent:addChild(self._legionNameTxt, 2)
    end

    if legionName == "" then 
        self._legionNameTxt:setString(TextWords:getTextWord(471022)) 
        self._legionNameTxt:setColor(ColorUtils.wordRedColor)
    else
        self._legionNameTxt:setString(legionName) 
        self._legionNameTxt:setColor(ColorUtils.wordBlueColor)
    end
    -- 有人占领，需要把标题隐藏
    if legionName == "" then 
        self._buildTxtBg:setVisible(true)
        self._buildNameTxt:setVisible(true)
    else
        self._buildTxtBg:setVisible(false)
        self._buildNameTxt:setVisible(false)
    end
end



-- 进度条显示（进度表和百分比文本）todocity
function UIWorldNodeEmperorCity:addProBarShow(worldTileInfo, configInfo)
    local cityInfo = worldTileInfo.cityInfo -- 网络数据
    local configInfo = configInfo           -- 配置数据

    local integralSpeed = cityInfo.integralSpeed -- 速率
    local occupyNum     = cityInfo.occupyNum     -- 当前占领值
    local maxNum        = configInfo.occupyNum   -- 最大占领

--    logger:info(configInfo.cityName.."##当前占领值#############"..occupyNum)
--    logger:info(configInfo.cityName.."##最大占领###############"..maxNum)

    -- 设置数值
    local percent = math.floor(occupyNum/maxNum *100)

    -- 进度条背景
    if self._loadBarBg == nil then
        local url = "images/map/icon_emperor_barBg.png"
        self._loadBarBg = TextureManager:createImageView(url)
        self._nameParent:addChild(self._loadBarBg) -- 作为父节点
    end
    -- 进度条
    if self._loadBar == nil then
        local url = self:getLoadBarUrl(integralSpeed)
        self._loadBar = self:addLoadProgress(self._loadBarBg, url)
    end
    
    -- 进度条文本
    if self._loadBarTxt == nil then
        self._loadBarTxt = ccui.Text:create()
        self._loadBarTxt:setFontName(GlobalConfig.fontName) 
        self._loadBarTxt:setFontSize(UIWorldNodeEmperorCity.FONT_SIZE - 3) -- 14号字体
        self._loadBarBg:addChild(self._loadBarTxt, 2)
        self._loadBarTxt:setPosition(self._loadBarBg:getContentSize().width/2, self._loadBarBg:getContentSize().height/2 + 1)
    end

    -- 设置数值
    self._loadBar:setPercentage(percent)
    self._loadBarTxt:setString(percent.. "%")
    
end


-----
-- 计时更新updateEmperorCityWithTime
function UIWorldNodeEmperorCity:updateEmperorCityWithTime()
    -- 时间刷新
    self:updateRemainTime()

    -- 进度条刷新
    self:updateLoadingBar(self._worldTileInfo, self._configInfo)

end

-- 时间刷新
function UIWorldNodeEmperorCity:updateRemainTime()
    local remainTime = self._mapPanel:getProxy(GameProxys.World):getRemainTime(self._nodeKey)

    if remainTime == 0 then
        self:updateMap()
    end
end



-- 进度条刷新
function UIWorldNodeEmperorCity:updateLoadingBar(worldTileInfo, configInfo)
    -- 没队伍时，速度值为0
    local cityInfo = worldTileInfo.cityInfo
    local cityStatus = cityInfo.cityStatus
    -- 争夺期
    if cityStatus ~= 4 then
        return
    end
    local cityId        = cityInfo.cityId        -- 城id
    local integralSpeed = cityInfo.integralSpeed -- 速率
    local maxNum        = configInfo.occupyNum   -- 最大占领
    
    local curNum = cityInfo.occupyNum
    -- logger:info(configInfo.cityName.."当前的数值："..cityInfo.occupyNum)

    local curNum = cityInfo.occupyNum

    -- 进度条刷新
    self:updateSpriteLoadBar(integralSpeed)

    if integralSpeed ~= 0 then 
        -- 民忠满了，速度为+
        if curNum >= maxNum and integralSpeed > 0 then
            return 
        end

        curNum = curNum + integralSpeed
        -- 临界值判断
        if curNum > maxNum then
            curNum = maxNum
        elseif curNum < 0 then
            curNum = 0
        end

        cityInfo.occupyNum = curNum -- 赋值
        self._worldTileInfo.cityInfo = cityInfo -- 重新赋值

        if curNum == 0 or curNum == maxNum then
            self:updateMap()
        end
        self:addProBarShow(worldTileInfo, configInfo)
    end
end

-- 进度条刷新
function UIWorldNodeEmperorCity:updateSpriteLoadBar(integralSpeed)
    if self._loadBar.spState == nil then
        self._loadBar.spState = integralSpeed >= 0 and 1 or 0
    end
    local curSpState = integralSpeed >= 0 and 1 or 0
    if self._loadBar.spState ~= curSpState then
        TextureManager:updateSprite(self._loadBar:getSprite(), self:getLoadBarUrl(integralSpeed))
        self._loadBar:setPercentage(self._loadBar:getPercentage() + 1)
        self._loadBar:setPercentage(self._loadBar:getPercentage() - 1)
    end
    self._loadBar.spState = curSpState
end


-- 获取进度条资源路径
function UIWorldNodeEmperorCity:getLoadBarUrl(integralSpeed)
    if integralSpeed > 0 then
        url = "images/map/icon_emperor_increase.png"
    elseif integralSpeed == 0 then
        url = "images/map/icon_emperor_increase.png"
    elseif integralSpeed < 0 then
        url = "images/map/icon_emperor_reduce.png"
    end
    return url
end

-- 获取进度条资源路径
function UIWorldNodeEmperorCity:addLoadProgress(parent, url)
    local sprite = TextureManager:createSprite(url)
    local actionProgressBar = cc.ProgressTimer:create(sprite)
    actionProgressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    actionProgressBar:setMidpoint(cc.p(0,0))
    actionProgressBar:setBarChangeRate(cc.p(1, 0))
    actionProgressBar:setPercentage(0)
    actionProgressBar:setLocalZOrder(2)
    parent:addChild(actionProgressBar)
    actionProgressBar:setPosition(parent:getContentSize().width/2, parent:getContentSize().height/2)
    return actionProgressBar
end

-- 请求地图区域信息
function UIWorldNodeEmperorCity:updateMap()
    self._mapPanel:dispatchEvent(MapEvent.WORLD_TILE_INFOS_REQ, {x = self._worldTileInfo.x, y = self._worldTileInfo.y})
end

-- 特效显示todocity
function UIWorldNodeEmperorCity:addEmperorCityEffect(worldTileInfo, configInfo)
    local cityInfo = worldTileInfo.cityInfo
    local cityStatus = cityInfo.cityStatus 
    local cityType = configInfo.type

    -- 添加精灵
    if self._sp == nil then
        self._sp = cc.Sprite:create()
        self._nameParent:addChild(self._sp, 2)
    end

    if self._cityWarEffect ~= nil then
        self._cityWarEffect:finalize()
        self._cityWarEffect = nil
    end

    local ccbName = self:getCcbName(cityStatus)
    if ccbName == "" then
        if self._cityWarEffect ~= nil then
            self._cityWarEffect:finalize()
            self._cityWarEffect = nil
        end
    else  
        self._cityWarEffect = UICCBLayer.new(ccbName, self._sp)
        
    end
end

-- 设置特效位置和缩放
function UIWorldNodeEmperorCity:setCcbSpScalePos(sp, pos)
    local cityType = self._configInfo.type
    local cityStatus = self._cityinfo.cityStatus 
    
    if cityStatus == 1 or cityStatus == 2 then -- 保护罩特效
        if cityType == 1 then
            self._sp:setScale(0.8)
            self._sp:setPosition(pos.x, pos.y + 145)
        elseif cityType == 2 then
            self._sp:setScale(1.3)
            self._sp:setPosition(pos.x, pos.y + 170)
        elseif cityType == 3 then
            self._sp:setScale(1.8)
            self._sp:setPosition(pos.x - 5, pos.y + 200)
        end
    end
    
end



function UIWorldNodeEmperorCity:setSizeAndPos(spSize, touchImg, cityType)
    if cityType == 1 then
        self._touchImg:setContentSize(cc.size(spSize.width*0.35, spSize.height*0.5))
        self._touchImg:setPositionY(20)
    elseif cityType == 2 then
        self._touchImg:setContentSize(cc.size(spSize.width*0.55, spSize.height*0.65))

    elseif cityType == 3 then
        self._touchImg:setContentSize(cc.size(spSize.width*0.55, spSize.height*0.6))
    end
end


-- 显示状态问题，根据策划需求表格设置
-- 1-未开放, 2-休战期(归属期), 3准备期(保护), 4-争夺期 
function UIWorldNodeEmperorCity:setNodeVisible(worldTileInfo)
    local cityInfo = worldTileInfo.cityInfo -- 网络数据
    local cityStatus = cityInfo.cityStatus
    ------------ 对应位置 (ccb, buildName, legionName, proBar)
    if cityStatus == 1 then
        self:setNodesIsVisible(true, true, false, false)
    elseif cityStatus == 2 then
        self:setNodesIsVisible(true, true, true, false)
    elseif cityStatus == 3 then
        self:setNodesIsVisible(false, true, true, false)
    elseif cityStatus == 4 then
        self:setNodesIsVisible(false, true, true, true)
    end
end


function UIWorldNodeEmperorCity:setNodesIsVisible(ccb, buildName, legionName, proBar)
    self._sp:setVisible(ccb)
    
    self._buildTxtBg:setVisible(buildName)
    self._buildNameTxt:setVisible(buildName)

    self._legionIcon:setVisible(legionName)
    self._legionFontBg:setVisible(legionName)
    self._legionNameTxt:setVisible(legionName)

    self._loadBarBg:setVisible(proBar)
    self._loadBar:setVisible(proBar)
    self._loadBarTxt:setVisible(proBar)
end

function UIWorldNodeEmperorCity:getOldEmperorCityInfo()
    return self._cityinfo
end


