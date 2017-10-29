MapCityWarPanel = class("MapCityWarPanel", BasicPanel)
MapCityWarPanel.NAME = "MapCityWarPanel"
MapCityWarPanel.TOWN_SCALE = 0.8
function MapCityWarPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapCityWarPanel.super.ctor(self, view, panelName, 700, layer)
end

function MapCityWarPanel:finalize()
    MapCityWarPanel.super.finalize(self)


end

function MapCityWarPanel:initPanel()
    MapCityWarPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(471001))


    self._cityWarProxy = self:getProxy(GameProxys.CityWar)

    self._roleProxy    = self:getProxy(GameProxys.Role)

    self._soliderProxy = self:getProxy(GameProxys.Soldier)
end

function MapCityWarPanel:registerEvents()
    self._mainPanel = self:getChildByName("mainPanel")
    self._panel01   = self._mainPanel:getChildByName("panel01")
    self._panel02   = self._mainPanel:getChildByName("panel02")
    self._panel03   = self._mainPanel:getChildByName("panel03")
    self._panel04   = self._mainPanel:getChildByName("panel04")

    self._nameTxt       = self._panel01:getChildByName("nameTxt")      
    self._posTxt        = self._panel01:getChildByName("posTxt")       
    self._legionNameTxt = self._panel01:getChildByName("legionNameTxt")
    self._stateTxt      = self._panel01:getChildByName("stateTxt")     
    self._timeTxt       = self._panel01:getChildByName("timeTxt")      
    self._reportBtn     = self._panel01:getChildByName("reportBtn")    
    self._townImg       = self._panel01:getChildByName("townImg")
    
    self._helpBtn       = self._panel01:getChildByName("helpBtn") -- 帮助按钮

    self:addTouchEventListener(self._reportBtn, self.onReportBtn)

    self:addTouchEventListener(self._helpBtn, self.onHelpBtn)

    self._warOnBtn      = self._panel04:getChildByName("warOnBtn")
    self._attackBtn     = self._panel04:getChildByName("attackBtn")
    self:addTouchEventListener(self._warOnBtn, self.onWarOnBtn)
    self:addTouchEventListener(self._attackBtn, self.onAttackBtn)

    self._defenseBtn    = self._panel04:getChildByName("defenseBtn") -- 防守
    self._tradeBtn      = self._panel04:getChildByName("tradeBtn")   -- 贸易

    self:addTouchEventListener(self._defenseBtn, self.onDefenseBtn)
    self:addTouchEventListener(self._tradeBtn, self.onTradeBtn)

    self._buffListView = self._panel02:getChildByName("buffListView")
    self._conditionTxt = self._panel02:getChildByName("conditionTxt")

    self._txtList02 = {}
    for i = 1, 3 do
        self._txtList02[i] = self._panel03:getChildByName("memoTxt0"..i)
    end
end

function MapCityWarPanel:onShowHandler(data)
    self._panel01:setVisible(false)
    self._panel02:setVisible(false)
    self._panel03:setVisible(false)
    self._panel04:setVisible(false)
end


-- 更新
function MapCityWarPanel:updateCityWarInfo()
    self._panel01:setVisible(true)
    self._panel02:setVisible(true)
    self._panel03:setVisible(true)
    self._panel04:setVisible(true)

    logger:info("接收信息并更新")
    self._townId = self._cityWarProxy:getTownId()
    local configInfo = ConfigDataManager:getConfigById(ConfigData.TownWarConfig, self._townId)
    self._configInfo = configInfo

    -- 名字
    local townName = configInfo.stateName
    self._townName = townName

    -- 盟城信息
    local townInfo = self._cityWarProxy:getTownInfo()
    

    -- 军团名字
    local legionName = townInfo.legionName
    self._legionName = legionName

    -- 州王名字
    local townKingName = townInfo.townKingName

    -- 坐标
    local posX = townInfo.x
    local posY = townInfo.y

    -- 状态
    local townStatus = townInfo.townStatus -- 0未开放1可宣战时期2宣战（可派兵）期间3开战期间4保护期间5休战期间
    self._townStatus = townStatus

    -- 下一个状态的剩余时间
    local nextStateTime = self._cityWarProxy:getNextStateTime()
    if nextStateTime < 0 then
        nextStateTime = 0
    end

    -- 行军时间
    local marchTime = self._cityWarProxy:getMarchTime()

    -- 洲城增益Buff 归属盟弹窗
    local buffIdList = self._cityWarProxy:getBuffIdList()


    self._nameTxt:setString(townName)

    self._posTxt:setString( string.format("(%s, %s)",posX , posY) )

    self._timeTxt :setString( TimeUtils:getStandardFormatTimeString8(marchTime))

    self._legionNameTxt:setString(legionName == "" and self:getTextWord(471022) or legionName)
    if legionName == "" then
        self._legionNameTxt:setColor(ColorUtils.wordBadColor)
    else
        self._legionNameTxt:setColor(ColorUtils.wordYellowColor01)
    end


    local cityWarIcon = configInfo.cityIcon 
    local imgUrl = string.format("images/map/town%d.png", cityWarIcon)
    TextureManager:updateImageView(self._townImg, imgUrl)
    self._townImg:setScale(MapCityWarPanel.TOWN_SCALE )

    local timeStr = TimeUtils:getStandardFormatTimeString6(nextStateTime, true)
    if nextStateTime ~= 0 then
        if nextStateTime > 170*3600 then -- 总开放时间超过170小时，时间显示：即将开启
            timeStr = self:getTextWord(284) -- "即将开启"
        end

        timeStr = string.format("(%s)", timeStr)
    elseif nextStateTime == 0 then
        timeStr = ""
    end

    self._stateTxt:setString( self:getTextWord(471002 + self._townStatus) .. timeStr)

    NodeUtils:fixTwoNodePos(self._nameTxt, self._posTxt, 3)

    
    -- 设置按钮显示
    self:setBtnShow(townStatus, legionName)

    -- 设置buff
    self:setTownBuff()
    
    -- 宣战条件
    self:setConditionTxt()

    -- 设置宣战最低战力
    self:setMinWarOnCapacity()

    -- 郡城奖励
    self:setReward()
end


-- 点击战报按钮
function MapCityWarPanel:onReportBtn(sender)
    local data = {}
    data.townId = self._townId
    self._cityWarProxy:onTriggerNet470002Req(data)
end

function MapCityWarPanel:onOpenTownReportModule()
    -- 打开战报模块
    local data = {}
    data.moduleName = ModuleName.TownReportModule
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
    self:hide()
end



------
-- 设置buff显示 
function MapCityWarPanel:setTownBuff()
    self._buffIdList = self._cityWarProxy:getBuffIdList()
    local townWarBuffConfig = ConfigDataManager:getConfigData(ConfigData.TownWarBuffConfig)
    local buffIdList = {}
    for i = 1 , #self._buffIdList  do
        local buffGroundId = self._buffIdList[i]
        
        for ID = 1, #townWarBuffConfig do
            if townWarBuffConfig[ID].buffGroundId == buffGroundId then
                table.insert(buffIdList, ID)
            end
        end
    end

    for i = 1, #buffIdList do
        local ID = buffIdList[i]
        local info = {}
        info.infoStr = self:getBuffInfoStr(ID)
        buffIdList[i] = info
    end

    self:renderListView(self._buffListView, buffIdList, self, self.renderItemTxt)
end

function MapCityWarPanel:renderItemTxt(itemTxt, data, index)
    itemTxt:setString(data.infoStr)
end

-- 获取buffId。buffInfo
function MapCityWarPanel:getBuffInfoStr(id)
    local configInfo = ConfigDataManager:getConfigById(ConfigData.TownWarBuffConfig, id)
    return configInfo.buffInfo
end


-- 宣战条件设置
function MapCityWarPanel:setConditionTxt()
    local legionLevel = self._configInfo.legionLevel
    local playerLevel = self._configInfo.playerLevel
    local str = string.format(self:getTextWord(471035), legionLevel, playerLevel)
    self._conditionTxt:setString(str)

    -- 设置部队最低出战战力
    local minCapacity = self._cityWarProxy:getMinAttackCapacity()
    local minCapacityTxt = self._panel02:getChildByName("minCapacityTxt")
    local lastTxt = self._panel02:getChildByName("lastTxt")
    minCapacityTxt:setString( StringUtils:formatNumberByK3(minCapacity))
    NodeUtils:fixTwoNodePos(minCapacityTxt, lastTxt)
end


-- 设置宣战最低战力
function MapCityWarPanel:setMinWarOnCapacity()
    local minWarOnCapacity = self._cityWarProxy:getMinWarOnCapacity()

    local warOnCapacityTxt = self._panel02:getChildByName("warOnCapacityTxt")
    local cityWarAddTxt = self._panel02:getChildByName("cityWarAddTxt")
    local secondLineImg = self._panel02:getChildByName("secondLineImg")
    local buffListView  = self._panel02:getChildByName("buffListView")
    if minWarOnCapacity ~= 0 then
        local valueTxt = warOnCapacityTxt:getChildByName("valueTxt")
        valueTxt:setString( StringUtils:formatNumberByK(minWarOnCapacity))
        warOnCapacityTxt:setVisible(true)
        warOnCapacityTxt:setString(self:getTextWord(471038)) -- "宣战者国力需到达"
        valueTxt:setColor(ColorUtils.wordGreenColor)
    else
        warOnCapacityTxt:setVisible(false)
    end

    if minWarOnCapacity ~= 0 then
        secondLineImg:setPositionY(131)
        cityWarAddTxt:setPositionY(104)
        buffListView :setPositionY(-26)
    else
        secondLineImg:setPositionY(151)
        cityWarAddTxt:setPositionY(124)
        buffListView :setPositionY(-6 )
    end

end




-- 郡城奖励
function MapCityWarPanel:setReward()
    

    self._txtList02[2]:setString(self:getTextWord(471033))
    self._txtList02[3]:setString(self:getTextWord(471034))


    local str = self:getTextWord(471036)
    local rewardGroupId = self._configInfo.pointRewardGroupID
    local pointRewar = self:getPointReward(rewardGroupId)
    if pointRewar then
        local pointRewarList = StringUtils:jsonDecode(pointRewar)
        for i = 1, #pointRewarList do
            local pointRewarInfo = pointRewarList[i]
            local power = pointRewarInfo[1]
            local typeId = pointRewarInfo[2]
            local num = pointRewarInfo[3]

            local configInfo = ConfigDataManager:getConfigByPowerAndID(power, typeId)
            local addStr = ""
            if i == #pointRewarList then
                addStr = configInfo.name.."x"..num
            else
                addStr = configInfo.name.."x"..num..","
            end
            str = str ..addStr
        end
    end
    self._txtList02[1]:setString(str)
end


------
-- 设置按钮显示
function MapCityWarPanel:setBtnShow(townStatus)
--    1可宣战时期
--    2宣战（可派兵）期间
--    3开战期间
--    4保护期间
--    5休战期间

    -- 进攻按钮(可派兵、已宣战，才显示)
    if self:isInWarOnLegion() and townStatus == 2 then
        self._attackBtn:setVisible(true)
    else
        self._attackBtn:setVisible(false)
    end
    

    -- 宣战按钮 
    if townStatus == 1 or townStatus == 4 or townStatus == 5 then
        self._warOnBtn:setVisible(true)
    else
        self._warOnBtn:setVisible(false)
    end

    -- 在派兵期，但是没宣战，显示宣战按钮
    if townStatus == 2 and self:isInWarOnLegion() == false then
        self._warOnBtn:setVisible(true)
    end

    -- i.郡城保护期4或休战期5，宣战按钮置灰不能点击
    if self._warOnBtn:isVisible() then
        if townStatus == 4 or townStatus == 5 then
            NodeUtils:setEnable(self._warOnBtn, false)
        else
            NodeUtils:setEnable(self._warOnBtn, true)
        end
    end


    -- 是否归属
    self._defenseBtn:setVisible(false)
    self._tradeBtn:setVisible(false)
    if self._legionName ~= "" then
        local myLegionName = self._roleProxy:getLegionName()
        if self._legionName == myLegionName then
            self._defenseBtn:setVisible(true)
            self._tradeBtn:setVisible(true)

            if self._warOnBtn:isVisible() then
                self._warOnBtn:setVisible(false)
            end

            if self._attackBtn:isVisible() then
                self._attackBtn:setVisible(false)
            end
        end
    end

    -- 根据配表显示贸易按钮
    if self._tradeBtn:isVisible() then
        local tradeOpen = self._configInfo.tradeOpen
        if tradeOpen == 0 then
            self._tradeBtn:setVisible(false)
        end
    end

    -- 调整位置
    if self._tradeBtn:isVisible() == false and self._defenseBtn:isVisible() == true then
        -- 贸易隐藏，防守显示
        self._defenseBtn:setPosition(271, 26)
    elseif self._tradeBtn:isVisible() == true and self._defenseBtn:isVisible() == true then
        -- 贸易显示，防守显示
        self._defenseBtn:setPosition(133, 26)
    end

end

------
--  点击宣战
function MapCityWarPanel:onWarOnBtn()
    local data = {}
    data.townId = self._townId
    self._cityWarProxy:onTriggerNet470100Req(data)
end

------
-- 点击防守
function MapCityWarPanel:onDefenseBtn()
--    if self._townStatus ~= 2 then
--        self:showSysMessage(self:getTextWord(471026))
--        return
--    end

    -- 盟城信息
    local townInfo = self._cityWarProxy:getTownInfo()
    
    -- 坐标
    local posX = townInfo.x
    local posY = townInfo.y

    -- 军团名字
    local legionName = townInfo.legionName

    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:onAttackCityWar(posX, posY, self._townName, legionName)
    self:hide()
end

------
-- 点击贸易
function MapCityWarPanel:onTradeBtn()
    local data = {}
    data.townId = self._townId
    self._cityWarProxy:onTriggerNet470007Req(data)
end

function MapCityWarPanel:onOpenTownTradeModule()
    -- 打开战报模块
    local data = {}
    data.moduleName = ModuleName.TownTradeModule
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
    self:hide()
end



------
-- 点击进攻
function MapCityWarPanel:onAttackBtn()
    -- 盟城信息
    local townInfo = self._cityWarProxy:getTownInfo()
    -- 坐标
    local posX = townInfo.x
    local posY = townInfo.y
    -- 军团名字
    local legionName = townInfo.legionName

    local configInfo = self._cityWarProxy:getConfigByMapKey(posX.."_"..posY)
    local limitLevel = configInfo.playerLevel
    local myLevel    = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if myLevel < limitLevel then
        self:showSysMessage( string.format(self:getTextWord(471030), limitLevel))
        return
    end

    -- 时间限制
    local remainTime = self._cityWarProxy:getRemainTime(self._cityWarProxy:getKey(self._townId)) -- 状态倒计时
    local marchTime = self._cityWarProxy:getMarchTime() -- 军工时间
    if remainTime < marchTime then
        self:showSysMessage( string.format(self:getTextWord(471031), limitLevel))
        return
    end

    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:onAttackCityWar(posX, posY, self._townName, legionName)

    self:hide()
end



function MapCityWarPanel:update()
    if self._townStatus ~= nil then
        local remainTime = self._cityWarProxy:getRemainTime(self._cityWarProxy:getKey(self._townId))
        local timeStr = TimeUtils:getStandardFormatTimeString6(remainTime, true)
        if remainTime ~= 0 then
            if remainTime > 170*3600 then -- 总开放时间超过170小时，时间显示：即将开启
                timeStr = self:getTextWord(284) -- "即将开启"
            end
            timeStr = string.format("(%s)", timeStr)
        elseif remainTime == 0 then
            timeStr = ""
        end
        self._stateTxt:setString( self:getTextWord(471002 + self._townStatus) .. timeStr)
    end
end



-- 我的同盟是否在宣战同盟里
function MapCityWarPanel:isInWarOnLegion()
    local state = false
    local myLegionName = self._roleProxy:getLegionName()
    local townLegionList = self._cityWarProxy:getTownLegionList()
    for i, info in pairs(townLegionList) do
        if info.legionName == myLegionName then
            state = true
            break
        end
    end
    return state
end

-- 关闭界面的时候，顺便清掉相应的计时器 
-- updateCityWarInfo也会调用hide()从而触发
function MapCityWarPanel:onHideHandler()
    local curStatus = self._cityWarProxy:getTownInfo().townStatus

    -- 清除
    if curStatus ~= 2 then
        if self._townId ~= nil then
            self._cityWarProxy:pushRemainTime(self._cityWarProxy:getKey(self._townId), 0)
        end
    end
end


-- 获取奖励id
function MapCityWarPanel:getPointReward(rewardGroupId) 
    local pointReward = nil 
    local level = self._roleProxy:getLegionLevel()
    
    local config = ConfigDataManager:getConfigData(ConfigData.TownWarPointRewardConfig)
    
    for i, configInfo in pairs(config) do
        local legionLvList = StringUtils:jsonDecode(configInfo.legionLv)
        local rewardGroup = configInfo.rewardGroup
        if rewardGroup == rewardGroupId and (level >= legionLvList[1] and level <= legionLvList[2]) then
            pointReward = configInfo.pointReward
            break
        end
    end
    return pointReward
end


-- 点击帮助按钮
function MapCityWarPanel:onHelpBtn()
    SDKManager:showWebHtmlView("html/help_townWar.html")
    logger:info("打开盟战玩法帮助")
end