MapCityWarOnPanel = class("MapCityWarOnPanel", BasicPanel)
MapCityWarOnPanel.NAME = "MapCityWarOnPanel"
MapCityWarOnPanel.TOWN_SCALE = 0.8
function MapCityWarOnPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapCityWarOnPanel.super.ctor(self, view, panelName, 700, layer)
end

function MapCityWarOnPanel:finalize()
    MapCityWarOnPanel.super.finalize(self)


end

function MapCityWarOnPanel:initPanel()
    MapCityWarOnPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(471001)) -- "郡城信息"


    self._cityWarProxy = self:getProxy(GameProxys.CityWar)

    self._roleProxy    = self:getProxy(GameProxys.Role)

    self._soliderProxy = self:getProxy(GameProxys.Soldier)
end

function MapCityWarOnPanel:registerEvents()
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
    self:addTouchEventListener(self._helpBtn, self.onHelpBtn)

    self:addTouchEventListener(self._reportBtn, self.onReportBtn)

    self._warOnBtn      = self._panel04:getChildByName("warOnBtn")
    self._attackBtn     = self._panel04:getChildByName("attackBtn")
    self:addTouchEventListener(self._warOnBtn, self.onWarOnBtn)
    self:addTouchEventListener(self._attackBtn, self.onAttackBtn)

    self._defenseBtn    = self._panel04:getChildByName("defenseBtn") -- 防守
    self._tradeBtn      = self._panel04:getChildByName("tradeBtn")   -- 贸易

    self:addTouchEventListener(self._defenseBtn, self.onDefenseBtn) -- 防守
    self:addTouchEventListener(self._tradeBtn, self.onTradeBtn)     -- 贸易


    self._txtList01 = {}
    self._txtList02 = {}
    for i = 1, 3 do
        self._txtList01[i] = self._panel03:getChildByName("titleTxt0"..i)
        self._txtList02[i] = self._panel03:getChildByName("memoTxt0"..i)
    end

    self._legionNameTxtList = {}
    for i = 1, 3 do
        self._legionNameTxtList[i] = self._panel02:getChildByName("legionNameTxt0"..i)
    end
    
    -- 感叹号提醒
    self._attentionImg = self._panel02:getChildByName("attentionImg")
    
end

function MapCityWarOnPanel:onShowHandler(data)
    self._panel01:setVisible(false)
    self._panel02:setVisible(false)
    self._panel03:setVisible(false)
    self._panel04:setVisible(false)
end


-- 更新
function MapCityWarOnPanel:updateCityWarInfo()
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


    self._nameTxt:setString(townName)

    self._posTxt:setString( string.format("(%s, %s)",posX , posY) )

    self._timeTxt :setString( TimeUtils:getStandardFormatTimeString8(marchTime))

    self._legionNameTxt:setString(legionName == "" and self:getTextWord(471022) or legionName)
    if legionName == "" then
        self._legionNameTxt:setColor(ColorUtils.wordBadColor)
    else
        self._legionNameTxt:setColor(ColorUtils.wordYellowColor01)
    end

    -- 郡城图标
    local cityWarIcon = configInfo.cityIcon 
    local imgUrl = string.format("images/map/town%d.png", cityWarIcon)
    TextureManager:updateImageView(self._townImg, imgUrl)
    self._townImg:setScale(MapCityWarOnPanel.TOWN_SCALE )

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

    -- 设置感叹号提醒
    self:setAttention()

    -- 设置宣战盟
    self:setWarOnLegion()

    -- 设置队伍信息
    self:setTeamInfo()

    -- 设置队伍出战buff
    self:setFightBuff()
end


-- 点击战报按钮
function MapCityWarOnPanel:onReportBtn(sender)
    local data = {}
    data.townId = self._townId
    self._cityWarProxy:onTriggerNet470002Req(data)

    
end

function MapCityWarOnPanel:onOpenTownReportModule()
    -- 打开战报模块
    local data = {}
    data.moduleName = ModuleName.TownReportModule
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
    self:hide()
end

-- 设置感叹号提醒
function MapCityWarOnPanel:setAttention()
    local id = self._cityWarProxy:getDebuffId()

    if id and id ~= 0 then
        self._attentionImg:setVisible(true)
        local attentionTxt = self._attentionImg:getChildByName("attentionTxt")
        local configInfo = ConfigDataManager:getConfigById(ConfigData.TownWarDebuffConfig, id)
        if configInfo ~= nil then
            local attentionStr = configInfo.info
            attentionTxt:setString(attentionStr)
        else
            attentionTxt:setString("")
        end
        
    else
        self._attentionImg:setVisible(false)
    end
end

------
-- 设置宣战盟
function MapCityWarOnPanel:setWarOnLegion()
    -- 宣战军团信息 非归属盟的弹窗
    local townLegionList = self._cityWarProxy:getTownLegionList()

    -- 上限3个的同盟报名
    for i = 1, #self._legionNameTxtList do
        if townLegionList[i] ~= nil then
            self._legionNameTxtList[i]:setString(townLegionList[i].legionName)
            self._legionNameTxtList[i]:setColor(ColorUtils.wordYellowColor03) 
        else
            self._legionNameTxtList[i]:setString(self:getTextWord(360010)) -- "暂无"
            self._legionNameTxtList[i]:setColor(ColorUtils.wordGrayColor) 
        end
    end
end

------
-- 设置显示
function MapCityWarOnPanel:setBtnShow(townStatus)
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
function MapCityWarOnPanel:onWarOnBtn()
    local data = {}
    data.townId = self._townId
    self._cityWarProxy:onTriggerNet470100Req(data)
end

------
-- 点击防守
function MapCityWarOnPanel:onDefenseBtn()
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
function MapCityWarOnPanel:onTradeBtn()
    local data = {}
    data.townId = self._townId
    self._cityWarProxy:onTriggerNet470007Req(data)
end

function MapCityWarOnPanel:onOpenTownTradeModule()
    -- 打开战报模块
    local data = {}
    data.moduleName = ModuleName.TownTradeModule
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
    self:hide()
end



------
-- 点击进攻
function MapCityWarOnPanel:onAttackBtn()
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

------
-- 设置队伍信息
function MapCityWarOnPanel:setTeamInfo()
    self._teamInfo = self._cityWarProxy:getTeamInfo()
    
    local teamType      = self._teamInfo.type -- 1攻击方  2防守方
    local totalCapacity = self._teamInfo.totalCapacity -- 总战力
    local totalTeamNum  = self._teamInfo.totalTeamNum -- 总队伍数量
    local selfTeamNum   = self._teamInfo.selfTeamNum --我的队伍数



    if teamType == 1 then
        self._txtList01[2]:setString(self:getTextWord(471017))-- "攻方队伍："
        self._txtList01[3]:setString(self:getTextWord(471018))-- "攻方战力："
    else
        self._txtList01[2]:setString(self:getTextWord(471019))-- "守方队伍："
        self._txtList01[3]:setString(self:getTextWord(471020))-- "守方战力："
    end

    self._txtList02[1]:setString(selfTeamNum)
    self._txtList02[2]:setString(totalTeamNum)
    self._txtList02[3]:setString( StringUtils:formatNumberByK3( totalCapacity) )

    -- 设置部队最低出战战力
    local minCapacity = self._cityWarProxy:getMinAttackCapacity()
    local minCapacityTxt = self._panel03:getChildByName("minCapacityTxt")
    local lastTxt = self._panel03:getChildByName("lastTxt")
    minCapacityTxt:setString( StringUtils:formatNumberByK3(minCapacity))
    NodeUtils:fixTwoNodePos(minCapacityTxt, lastTxt)
end

-- 设置队伍出战buff
function MapCityWarOnPanel:setFightBuff()
    logger:info("显示我方队伍buff")
    local fightBuffListConfig = {}
    -- 判断攻守方
    if self._defenseBtn:isVisible() then
        -- 守
        fightBuffListConfig = StringUtils:jsonDecode(self._configInfo.defFightBuff)
    else
        -- 攻
        fightBuffListConfig = StringUtils:jsonDecode(self._configInfo.actFightBuff)
    end
    local fightBuff = self._cityWarProxy:getFightBuffIdList()
    local buffStringList = self._cityWarProxy:getFightBuffStringList2(fightBuffListConfig)

    -- 设置
    for i = 1, 2 do
        local teamBuffTxt = self._panel03:getChildByName("teamBuff0"..i)
        local teamBuffEffTxt = self._panel03:getChildByName("teamBuffEffTxt0"..i)
        
        teamBuffTxt:setString(buffStringList[i].str)
        
        local isVisible = self:isEffTxtVisible(buffStringList[i].fightBuffId, fightBuff)
        teamBuffEffTxt:setVisible(isVisible)

        NodeUtils:fixTwoNodePos(teamBuffTxt, teamBuffEffTxt)
    end
end

-- 是否显示已生效
function MapCityWarOnPanel:isEffTxtVisible(fightBuffId, fightBuff)
    local state = false
    for i, value in pairs(fightBuff) do
        if fightBuffId == value then
            state = true
            break
        end
    end
    return state 
end


function MapCityWarOnPanel:update()
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
function MapCityWarOnPanel:isInWarOnLegion()
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
function MapCityWarOnPanel:onHideHandler()
    if self._townId ~= nil then
        self._cityWarProxy:pushRemainTime(self._cityWarProxy:getKey(self._townId), 0)
    end
end


-- 点击帮助按钮
function MapCityWarOnPanel:onHelpBtn()
    SDKManager:showWebHtmlView("html/help_townWar.html")
    logger:info("打开盟战玩法帮助")
end
