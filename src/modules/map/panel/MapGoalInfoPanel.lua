MapGoalInfoPanel = class("MapGoalInfoPanel", BasicPanel)
MapGoalInfoPanel.NAME = "MapGoalInfoPanel"

MapGoalInfoPanel.RESOURCE_TYPE = 1
MapGoalInfoPanel.COLLECT_TYPE = 2

function MapGoalInfoPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapGoalInfoPanel.super.ctor(self, view, panelName, 500, layer)
end

function MapGoalInfoPanel:finalize()
    if self._uiSharePanel ~= nil then
        self._uiSharePanel:finalize()
        self._uiSharePanel = nil
    end

    MapGoalInfoPanel.super.finalize(self)
end

function MapGoalInfoPanel:initPanel()
    MapGoalInfoPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(320))
    
    self._worldProxy = self:getProxy(GameProxys.World)
    self._roleProxy  = self:getProxy(GameProxys.Role)
    self.lab1 = self:getChildByName("mainPanel/lab1") -- 抵达时间
    self.timeLab = self:getChildByName("mainPanel/timeLab") -- 抵达时间
    self.fightLab = self:getChildByName("mainPanel/fightLab") -- 战力
    self._fightPowerLab = self:getChildByName("mainPanel/fightPowerLab")
    self._richResTxt = self:getChildByName("mainPanel/richResTxt") -- 富矿文本
    self._richTipTxt = self:getChildByName("mainPanel/richTipTxt") -- 富矿提示文本
    self._richTipTxt:setString(TextWords:getTextWord(8788))

    self._richTipBtn = self:getChildByName("mainPanel/richTipBtn") -- 富矿提示按钮


    -- 民忠值显示
    self._richValuePanel = self:getChildByName("mainPanel/richValuePanel")
    self._richBar        = self._richValuePanel:getChildByName("richBar")
    self._levelTitleTxtList= {}
    self._levelTxtList     = {}
    for i = 1, 5 do
        local level = self._richValuePanel:getChildByName("levelTxt0"..i)
        local levelTitle = self._richValuePanel:getChildByName("levelTxt1"..i)
        self._levelTitleTxtList[i] = levelTitle
        self._levelTxtList[i]      = level
    end

    local shareBtn = self:getChildByName("mainPanel/shareBtn")
    self:addTouchEventListener(shareBtn, self.onShareMethod)

    self:setRichConfig() -- 设置配置民忠进度
end

function MapGoalInfoPanel:onShowHandler(data)  
    
    local type = data.type -- 查看1，收藏界面都是2


    if type == MapGoalInfoPanel.RESOURCE_TYPE then
        self._iconScale = data.iconScale or 1  
    elseif type == MapGoalInfoPanel.COLLECT_TYPE then --坑：type == 2 表示收藏/玩家基地
        if data.tileInfo.tileType == WorldTileType.Building then
            self._iconScale = GlobalConfig.worldMapBuildScale --玩家基地
        else
            self._iconScale = data.iconScale or 1
        end
    else
        self._iconScale = data.iconScale or 1
    end



    local selectPanel = self:getChildByName("mainPanel/collectPanel/selectPanel")
    for index=1, 3 do
        local tagPanel = selectPanel:getChildByName("tagPanel" .. index)
        self:setTagPanelState(tagPanel, false)
    end
    
    local shareBtn = self:getChildByName("mainPanel/shareBtn")
    self.fightLab:setVisible(type == MapGoalInfoPanel.RESOURCE_TYPE)
    self._fightPowerLab:setVisible(type == MapGoalInfoPanel.RESOURCE_TYPE)
    shareBtn:setVisible(type == MapGoalInfoPanel.RESOURCE_TYPE)
    self.lab1:setVisible(type == MapGoalInfoPanel.RESOURCE_TYPE)
    self.timeLab:setVisible(type == MapGoalInfoPanel.RESOURCE_TYPE)
    self._richResTxt:setVisible(type == MapGoalInfoPanel.RESOURCE_TYPE)
    --self._richTipTxt:setVisible(type == MapGoalInfoPanel.RESOURCE_TYPE)
    self._richTipBtn:setVisible(type == MapGoalInfoPanel.RESOURCE_TYPE)



    -- 富矿信息显示控制
    self:richShowCtrl(data.tileInfo.tileType)

    if type == MapGoalInfoPanel.RESOURCE_TYPE then  --查看格子的资源信息
        self:renderTileResourceInfo(data.tileInfo)
    else --格子信息收藏
        self:renderCollectInfo(data.tileInfo)
    end
end

function MapGoalInfoPanel:renderTileResourceInfo(tileInfo)
    local collectPanel = self:getChildByName("mainPanel/collectPanel")
    local backBtn = self:getChildByName("mainPanel/backBtn")
    local saveBtn = self:getChildByName("mainPanel/saveBtn")
    local attackBtn = self:getChildByName("mainPanel/attackBtn")
    local spyBtn = self:getChildByName("mainPanel/spyBtn")
    local collectBtn = self:getChildByName("mainPanel/collectBtn")
    local shareBtn = self:getChildByName("mainPanel/shareBtn")
    
    collectPanel:setVisible(false)
    backBtn:setVisible(false)
    saveBtn:setVisible(false)
    
    attackBtn:setVisible(true)
    spyBtn:setVisible(true)
    collectBtn:setVisible(true)
    
    collectBtn.iconScale = self._iconScale
    backBtn.iconScale = self._iconScale
    collectBtn.tileInfo = tileInfo
    backBtn.tileInfo = tileInfo
    saveBtn.tileInfo = tileInfo
    attackBtn.tileInfo = tileInfo
    spyBtn.tileInfo = tileInfo
    shareBtn.tileInfo = tileInfo

    
    local nameTxt = self:getChildByName("mainPanel/nameTxt")
    local posTxt = self:getChildByName("mainPanel/posTxt")
    
    local pointInfo = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, tileInfo.resInfo.resPointId)
    nameTxt:setString(pointInfo.name)
    posTxt:setString(string.format(self:getTextWord(306), tileInfo.x, tileInfo.y))

    local time = tileInfo.time or 0
    time = TimeUtils:getStandardFormatTimeString6(time)
    self.timeLab:setString(time)

    local monsterConfig = ConfigDataManager:getConfigById(ConfigData.MonsterGroupConfig, tileInfo.monsterGroupId)
    self.fightLab:setVisible(monsterConfig ~= nil)
    self._fightPowerLab:setVisible(monsterConfig ~= nil)
    local fitTitile = self:getTextWord(290062)
   
    local rolePower = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_highestCapacity)  -- 当前战力
    if monsterConfig ~= nil then
        local force = StringUtils:formatNumberByK(monsterConfig.force)
        self.fightLab:setString( fitTitile)

        if rolePower > monsterConfig.force then
            self._fightPowerLab:setColor(ColorUtils.wordGreenColor)
        else
            self._fightPowerLab:setColor(ColorUtils.wordRedColor)
        end
        self._fightPowerLab:setString(force)
    else
        -- 服务端没有数据，客户端读表
        local force = StringUtils:formatNumberByK(pointInfo.fitCombat)
        self.fightLab:setString(fitTitile)
        self.fightLab:setVisible(true)

        if rolePower > pointInfo.fitCombat then
            self._fightPowerLab:setColor(ColorUtils.wordGreenColor)
        else
            self._fightPowerLab:setColor(ColorUtils.wordRedColor)
        end
        self._fightPowerLab:setString(force)
        self._fightPowerLab:setVisible(true)
    end
    
    local iconContainer = self:getChildByName("mainPanel/iconContainer")
    local url = ComponentUtils:getWorldBuildingUrl(pointInfo.icon,true)
    TextureManager:updateImageView(iconContainer,url)
    
    iconContainer:setScale(self._iconScale)
    iconContainer.iconScale = self._iconScale

    -- 调整坐标位置
    NodeUtils:alignNodeL2R(nameTxt, posTxt, 5)

    -- 富矿显示信息 自己组的和网络下发的
    local loyaltyCount = tileInfo.loyaltyCount 
    if loyaltyCount == nil or loyaltyCount == 0 then
        loyaltyCount = 0
    end

    if self._richResTxt:isVisible() and loyaltyCount ~= nil then
        local loyaltyInfo = self._worldProxy:getLoyaltyConfigInfo(loyaltyCount)
        if loyaltyInfo ~= nil then
            local colorType =  loyaltyInfo.type
            local collectAdd = loyaltyInfo.collectAdd + 100
            local titleStr = self:getTextWord(8700 + colorType)
            local perCentStr =  collectAdd .."%"-- .."  数值"..loyaltyCount
            self._richResTxt:setString(titleStr ..perCentStr)
            self._richResTxt:setColor( ColorUtils:getColorByQuality(colorType))
            nameTxt:setColor( ColorUtils:getColorByQuality(colorType))
            
            self:setRichBar(loyaltyCount, colorType)
        end
    end

end

function MapGoalInfoPanel:renderCollectInfo(tileInfo)
    local collectPanel = self:getChildByName("mainPanel/collectPanel")
    local backBtn = self:getChildByName("mainPanel/backBtn")
    local saveBtn = self:getChildByName("mainPanel/saveBtn")
    local attackBtn = self:getChildByName("mainPanel/attackBtn")
    local spyBtn = self:getChildByName("mainPanel/spyBtn")
    local collectBtn = self:getChildByName("mainPanel/collectBtn")

    collectPanel:setVisible(true)
    backBtn:setVisible(true)
    saveBtn:setVisible(true)

    attackBtn:setVisible(false)
    spyBtn:setVisible(false)
    collectBtn:setVisible(false)
    local nameTxt = self:getChildByName("mainPanel/nameTxt")
    local iconContainer = self:getChildByName("mainPanel/iconContainer")
    local tileType = tileInfo.tileType
    if tileType == WorldTileType.Building then  --建筑
        backBtn:setVisible(false)
        nameTxt:setString(tileInfo.buildingInfo.name)
        local url = ComponentUtils:getWorldBuildingUrl(tileInfo.buildingInfo.buildIcon)
        TextureManager:updateImageView(iconContainer,url)
        iconContainer:setScale(self._iconScale)
    else  --资源点
        backBtn:setVisible(true)
        local pointInfo = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, tileInfo.resInfo.resPointId)
        nameTxt:setString(pointInfo.name)
        local url = ComponentUtils:getWorldBuildingUrl(pointInfo.icon,true)
        TextureManager:updateImageView(iconContainer,url)
--        local buildType = PlayerPowerDefine:getResCollectionIcon(pointInfo.restype)
--        local url = string.format("images/buildingIcon/building_%d.png", buildType)
        TextureManager:updateImageView(iconContainer,url)
    end
    
    collectBtn.iconScale = self._iconScale
    backBtn.iconScale = self._iconScale
    -- 数据存储
    collectBtn.tileInfo = tileInfo
    backBtn.tileInfo = tileInfo
    saveBtn.tileInfo = tileInfo
    attackBtn.tileInfo = tileInfo
    spyBtn.tileInfo = tileInfo
    
    local posTxt = self:getChildByName("mainPanel/posTxt")

    posTxt:setString(string.format(self:getTextWord(306), tileInfo.x, tileInfo.y))

    -- 调整坐标位置
    NodeUtils:alignNodeL2R(nameTxt, posTxt, 5)
end


-----------------------------------------
function MapGoalInfoPanel:registerEvents()
    -- local closeBtn = self:getChildByName("mainPanel/closeBtn")
    -- self:addTouchEventListener(closeBtn, self.onCloseBtnTouch)
    
    local collectBtn = self:getChildByName("mainPanel/collectBtn")
    self:addTouchEventListener(collectBtn, self.onCollectBtnTouch)
    local backBtn = self:getChildByName("mainPanel/backBtn")
    self:addTouchEventListener(backBtn, self.onBackBtnTouch)
    local saveBtn = self:getChildByName("mainPanel/saveBtn")
    self:addTouchEventListener(saveBtn, self.onSaveBtnTouch)
    local attackBtn = self:getChildByName("mainPanel/attackBtn")
    self:addTouchEventListener(attackBtn, self.onAttackBtnTouch)
    local spyBtn = self:getChildByName("mainPanel/spyBtn")
    self:addTouchEventListener(spyBtn, self.onSpyBtnTouch)
    
    self:addTouchEventListener(self._richTipBtn, self.onRichTipBtn) -- 富矿文本

    local selectPanel = self:getChildByName("mainPanel/collectPanel/selectPanel")
    for index=1, 3 do
        local tagPanel = selectPanel:getChildByName("tagPanel" .. index)
        self:addTouchEventListener(tagPanel, self.onChangeTagPanelTouch)
    end
end

function MapGoalInfoPanel:onChangeTagPanelTouch(sender)
    local curState = sender.curState
    self:setTagPanelState(sender, not curState)
    if self._uiSharePanel ~= nil then
        if self._uiSharePanel:isVisible() == true then
            self._uiSharePanel:hidePanel()
        end
    end
end

---------------------------------
--state true选中 false未选中
function MapGoalInfoPanel:setTagPanelState(tagPanel, state)
    local tickBg = tagPanel:getChildByName("tickBgImg")
    if tickBg == nil then
        print("tickBg == nil ")
        return
    end
    local mask = tickBg:getChildByName("mask")
    local tickImg = tickBg:getChildByName("tickImg")
    local selectedImg = tickBg:getChildByName("selectedImg")
    if mask then
        tickImg:setVisible(state)
        selectedImg:setVisible(state)
        mask:setVisible(not state)
    end
    tagPanel.curState = state
end

function MapGoalInfoPanel:onCloseBtnTouch(sender)
    self:hide()
end

function MapGoalInfoPanel:onCollectBtnTouch(sender)
    local tileInfo = sender.tileInfo
    local iconScale = sender.iconScale
    local data = {}
    data.type = MapGoalInfoPanel.COLLECT_TYPE
    data.tileInfo = tileInfo
    data.iconScale = iconScale
    self:onShowHandler(data)
    if self._uiSharePanel ~= nil then
        if self._uiSharePanel:isVisible() == true then
            self._uiSharePanel:hidePanel()
        end
    end
end

function MapGoalInfoPanel:onBackBtnTouch(sender)
    local tileInfo = sender.tileInfo
    local iconScale = sender.iconScale
    local data = {}
    data.type = MapGoalInfoPanel.RESOURCE_TYPE
    data.tileInfo = tileInfo
    data.iconScale = iconScale
    self:onShowHandler(data)
    if self._uiSharePanel ~= nil then
        if self._uiSharePanel:isVisible() == true then
            self._uiSharePanel:hidePanel()
        end
    end
end

--攻击
function MapGoalInfoPanel:onAttackBtnTouch(sender)
    local tileInfo = sender.tileInfo

    local curProcessrLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_ResLevel) -- 攻打等级进度
    
    if tileInfo.resInfo.level > curProcessrLevel + 1 then
        self:showSysMessage( string.format(self:getTextWord(8711), tileInfo.resInfo.level - 1))
        return 
    end

    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:onAttckResourceTouch(tileInfo)
    
    self:hide()
    if self._uiSharePanel ~= nil then
        if self._uiSharePanel:isVisible() == true then
            self._uiSharePanel:hidePanel()
        end
    end
end

--侦查
function MapGoalInfoPanel:onSpyBtnTouch(sender)
    local tileInfo = sender.tileInfo
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:onSpyPriceTouch(tileInfo)
    
    self:hide()
    if self._uiSharePanel ~= nil then
        if self._uiSharePanel:isVisible() == true then
            self._uiSharePanel:hidePanel()
        end
    end
end

--收藏保存btn.data = userdata
function MapGoalInfoPanel:onSaveBtnTouch(sender)
    local tileInfo = sender.tileInfo
    local tileType = tileInfo.tileType

    local info = {}
    info.tags = {}
    local selectPanel = self:getChildByName("mainPanel/collectPanel/selectPanel")
    for index=1, 3 do
        local tagPanel = selectPanel:getChildByName("tagPanel" .. index)
        if tagPanel.curState == true then
            table.insert(info.tags, index)
        end
    end
    if tileType == WorldTileType.Building then
        local playerInfo = tileInfo.playerInfo
        local buildingInfo = tileInfo.buildingInfo
        info.name = buildingInfo.name
        info.tileX = buildingInfo.x
        info.tileY = buildingInfo.y
        info.level = buildingInfo.level
        info.isPerson = 0   --表示玩家
        info.iconId = playerInfo.iconId       --玩家头像
        info.pendantId = playerInfo.pendantId  --玩家挂件 140001要改
        info.power = playerInfo.capacity
        info.legionName = playerInfo.legion
        info.playerId = playerInfo.playerId
    else
        local pointInfo = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, tileInfo.resInfo.resPointId)
        local buildType = PlayerPowerDefine:getResCollectionIcon(pointInfo.restype)
        info.buildingType = buildType --资源类型
        info.name = pointInfo.name
        info.iconId = 1
        info.tileX = tileInfo.x
        info.tileY = tileInfo.y
        info.level = tileInfo.resInfo.level
        info.isPerson = 1  --表示资源
    end
    
    local friendProxy = self:getProxy(GameProxys.Friend)
    friendProxy:updateWorldCollectionInfo(info, true) -- 修改collectMap并更新缓存列表
    
    self:hide()
    if self._uiSharePanel ~= nil then
        if self._uiSharePanel:isVisible() == true then
            self._uiSharePanel:hidePanel()
        end
    end
end

function MapGoalInfoPanel:onShareMethod(sender)
    local resInfo = sender.tileInfo

    if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new(sender, self)
    end
    
    local data = {}
    data.type = ChatShareType.RESOURCE_TYPE
    data.postinfo = {x = resInfo.x, y = resInfo.y}
    self._uiSharePanel:showPanel(sender, data)
end

function MapGoalInfoPanel:onRichTipBtn(sender)

	local content1 = self:getTextWord(8706)
	local content2 = self:getTextWord(8707)
	local content3 = self:getTextWord(8708)
	local content4 = self:getTextWord(8709)
	local content5 = self:getTextWord(8710)

	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local line1 = {{content = content1, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line2 = {{content = content2, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line3 = {{content = content3, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line4 = {{content = content4, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line5 = {{content = content5, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}

    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)
    table.insert(lines, line3)	    
    table.insert(lines, line4)	    
    table.insert(lines, line5)	    
    uiTip:setAllTipLine(lines)
end

function MapGoalInfoPanel:setRichBar(loyaltyCount, colorType)
    local richValueTxt = self._richBar:getChildByName("richValueTxt")

    local changePercent = self:changePercent(loyaltyCount, colorType)
    local modulus = changePercent/100

    self._richBar:setPercent(changePercent)
    richValueTxt:setString( StringUtils:formatNumberByK3(loyaltyCount))

    -- 改变锚点
    if colorType < 2 then
        richValueTxt:setAnchorPoint(0, 0.5)
    else
        richValueTxt:setAnchorPoint(1, 0.5)
    end
    richValueTxt:setPositionX(self._richBar:getContentSize().width *modulus)
end

function MapGoalInfoPanel:setRichConfig()
    self._levelMinValueTable = {}
    self._levelMaxValueTable = {}

    local configData = ConfigDataManager:getConfigData(ConfigData.WorldHeavyResConfig)

    for i = 1, #configData do
        local configInfo = configData[i]
        local value = StringUtils:jsonDecode(configInfo.loyaltyNeed)[1]
        self._levelTitleTxtList[i]:setString( "("..StringUtils:formatNumberByK(value) ..")")
        self._levelTitleTxtList[i]:setColor( ColorUtils:getColorByQuality(configInfo.type))
        self._levelTxtList[i]:setColor( ColorUtils:getColorByQuality(configInfo.type))
        if i == #configData then
            self._maxRichValue = value
        end

        -- 索引表
        self._levelMinValueTable[i] = StringUtils:jsonDecode(configInfo.loyaltyNeed)[1] 
        self._levelMaxValueTable[i] = StringUtils:jsonDecode(configInfo.loyaltyNeed)[2] 
    end

end


function MapGoalInfoPanel:changePercent(loyaltyCount, colorType)
    local truePercent = 0 
    local levelDiffPercent = 100/#self._levelMaxValueTable -- 以20为一个区间

    local diffCount = self._levelMaxValueTable[colorType] - self._levelMinValueTable[colorType]
    local curLevelCount = loyaltyCount - self._levelMinValueTable[colorType]
    local inLevelModulus = curLevelCount/diffCount -- 在该等级里的系数

    local levelShowPercent =  levelDiffPercent* inLevelModulus
    
    truePercent = ( colorType - 1) *levelDiffPercent + levelShowPercent
    return truePercent
end

------
-- 下层富矿元素显示控制
function MapGoalInfoPanel:richShowCtrl(tileType)
    self._richValuePanel:setVisible(true)
    self._richTipTxt:setVisible(true)
    -- 如果是建筑收藏，隐藏富矿层
    if tileType ==  WorldTileType.Building then
        self._richValuePanel:setVisible(false)
        self._richTipTxt:setVisible(false)
    end
end
