--兵营招兵中
RecruitingPanel = class("RecruitingPanel", BasicPanel)
RecruitingPanel.NAME = "RecruitingPanel"

function RecruitingPanel:ctor(view, panelName)
    RecruitingPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function RecruitingPanel:finalize()
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:finalize()
    end
    
    if self._xszyShou then
        self._xszyShou:finalize()
        self._xszyShou = nil
    end


    if self._xszy then
        self._xszy:finalize()
        self._xszy = nil
    end
    

    RecruitingPanel.super.finalize(self)
end

function RecruitingPanel:initPanel()
    BarrackRecruitPanel.super.initPanel(self)

    local listView = self:getChildByName("listView")
    self._listView = listView
    
    self._itemMap = {}

    self._itemConfig = ConfigDataManager:getItemConfig()
end

function RecruitingPanel:doLayout()
    local upWidget = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView, GlobalConfig.downHeight, upWidget,GlobalConfig.topTabsHeight)
end

function RecruitingPanel:addUIAcceleration()
    local parent = self:getParent()
    local uiAcceleration = UIAcceleration.new(parent, self)

    self._uiAcceleration = uiAcceleration
end


function RecruitingPanel:onUpdateBuildingInfo()
    self:onShowHandler()
    
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:update()
    end
end

--show时候 触发的事件
function RecruitingPanel:onShowHandler()
    local panel = self:getPanel(BarrackPanel.NAME)
    panel:setBgType(ModulePanelBgType.NONE)

    if self._xszy and self._xszyShou then
        self._xszy:setVisible(false)
        self._xszyShou:setVisible(false)
    end

    if self._listView then
        self._listView:jumpToTop()
    end
    local buildingProxy = self:getProxy(GameProxys.Building)
    local curBuildingInfo = buildingProxy:getCurBuildingInfo()
    local productionInfos = curBuildingInfo.productionInfos

    local tempInfos = {}
    for k, v in pairs(productionInfos) do
        table.insert(tempInfos, v)
    end
    table.sort(tempInfos, function(a,b) return a.order < b.order end)
    self:renderProductions(tempInfos)
end

function RecruitingPanel:onResetPanel()
    self._itemMap = {}
end

--渲染生产中。
function RecruitingPanel:renderProductions(productionInfos)

    self._itemMap = {} --缓存有的列表item view关闭时，应该清除掉
    self:renderListView(self._listView, productionInfos, self, self.renderItemPanel)
end


function RecruitingPanel:renderItemPanel(itemPanel, productionInfo, index)
    itemPanel:setVisible(true)
    if index == 0 then
        self._firstItemPanel = itemPanel
    end
    itemPanel:setLocalZOrder(100 - index)
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local labCount = itemPanel:getChildByName("labCount")
    local cancelBtn = itemPanel:getChildByName("cancelBtn")
    local quickBtn = itemPanel:getChildByName("quickBtn")
    local container = itemPanel:getChildByName("container")
    local typeid = productionInfo.typeid

    local buildingProxy = self:getProxy(GameProxys.Building)
    local proConfigName = buildingProxy:getCurBuildingProConfigName()
    local info = ConfigDataManager:getConfigById(proConfigName,typeid)
    
    nameTxt:setString(info.name)
    labCount:setString(TextWords:getTextWord(103) .. productionInfo.num)
    
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local oneData = buildingProxy:getCurBuildingConfigInfo()
    if oneData.type == BuildingTypeConfig.MAKE then --工匠坊
        local tmp = ConfigDataManager:getConfigById(ConfigData.ItemConfig,typeid)
        nameTxt:setColor(ColorUtils:getColorByQuality(tmp.color))
    elseif oneData.type == BuildingTypeConfig.BARRACK then --兵营
        local tmp = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,typeid)
        nameTxt:setColor(ColorUtils:getColorByQuality(tmp.color))
    elseif oneData.type == BuildingTypeConfig.REFORM then --校场
        local tmp = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,typeid)
        nameTxt:setColor(ColorUtils:getColorByQuality(tmp.color))
    end


    local icon = info.ID
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local power = GamePowerConfig.SoldierBarrack
    if buildingInfo.buildingType == BuildingTypeConfig.MAKE then --制作车间(工匠坊) 6666
        power = GamePowerConfig.Other 
        local conf = ConfigDataManager:getConfigById(ConfigData.ItemMadeConfig, info.ID)
        icon = conf.icon
    end

    local data = {}
    data.power = power
    data.typeid = icon
    data.num  = productionInfo.num
    if buildingInfo.buildingType == BuildingTypeConfig.MAKE then
        data.name = info.name
        data.dec  = self._itemConfig[info.ID].info
    end
    if container.y == nil then
        container.y = container:getPositionY()
    end
    container:setScale(1)
    if buildingInfo.buildingType == BuildingTypeConfig.MAKE then
        TextureManager:updateImageView(container, "images/newGui1/none.png")

        local icon = container.icon
        if icon == nil then
            icon = UIIcon.new(container, data, false, self)
            container.icon = icon
        else
            icon:updateData(data)
        end
        local scale = buildingInfo.buildingType == BuildingTypeConfig.MAKE and 1 or 0.7
        icon:setScale(scale)
        local y = buildingInfo.buildingType == BuildingTypeConfig.MAKE and container.y - 15 or container.y
        container:setPositionY(y)

    else
        TextureManager:onUpdateSoldierImg(container,info.ID)
        container:setScale(0.6)
        local y = buildingInfo.buildingType == BuildingTypeConfig.MAKE and container.y - 25 or container.y
        container:setPositionY(y)
    end

    if container.icon ~= nil then
        container.icon:setVisible(buildingInfo.buildingType == BuildingTypeConfig.MAKE)
    end
    

    
    cancelBtn.productionInfo = productionInfo
    quickBtn.productionInfo = productionInfo
    itemPanel.info = info
    itemPanel.productionInfo = productionInfo
    
    local state = productionInfo.state
    if state == 1 then
        cancelBtn:setVisible(true)
        quickBtn:setVisible(true)
        
        NodeUtils:setEnable(quickBtn,true)

        self:addTouchEventListener(quickBtn, self.onQuickBtnTouch)
    else
--        cancelBtn:setVisible(false)
--        quickBtn:setVisible(false)
        
        local infoTxt = itemPanel:getChildByName("infoTxt")
        local timeBar = itemPanel:getChildByName("timeBar")
        local Image_23 = itemPanel:getChildByName("Image_23")
        timeBar:setVisible(false)
        timeBar:setPercent(0)
        Image_23:setVisible(false)
        infoTxt:setString(self:getTextWord(8309))
        
        NodeUtils:setEnable(quickBtn,false)
    end
    
    self._itemMap[index] = itemPanel
    
    self:renderCountDown(itemPanel)
    
    if itemPanel.isAddEvent == true then
        return
    end
    itemPanel.isAddEvent = true
    
    self:addTouchEventListener(cancelBtn, self.onCancelBtnTouch)
    
    
    local index = self._listView:getIndex(itemPanel)
    self["quickBtn" .. (index + 1)] = quickBtn
end

function RecruitingPanel:showSoldierInfo(typeid)
    self.view:showSoldierInfo(typeid)
end

--取消生产升级
function RecruitingPanel:onCancelBtnTouch(sender)
    local function okCallback()
        local productionInfo = sender.productionInfo
        local buildingProxy = self:getProxy(GameProxys.Building)
        local buildingInfo = buildingProxy:getCurBuildingInfo()
        local data = {}
        data.order = productionInfo.order
        data.buildingType = buildingInfo.buildingType
        data.index = buildingInfo.index
        
        -- buildingProxy:buildingCancelUpgradeReq(data)
        buildingProxy:onTriggerNet280008Req(data)
    end
    local messageBox = self:showMessageBox(self:getTextWord(808), okCallback)
end

--打开加速面板
function RecruitingPanel:onQuickBtnTouch(sender, value)
    local productionInfo = sender.productionInfo
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()

    local buildingType = buildingInfo.buildingType
    local info = ConfigDataManager:getInfoFindByOneKey(
        ConfigData.BuildSheetConfig, "type", buildingType)
    local prospeeditem = StringUtils:jsonDecode(info.prospeeditem)
    
    
    if self._xszy and self._xszyShou then
        self._xszy:setVisible(false)
        self._xszyShou:setVisible(false)
    end

    if value == true then --模拟直接提示框
--        prospeeditem = {}
        --直接请求
        --
        local time = buildingProxy:getCurBuildingProLineReTime(productionInfo.order)
        local cost = TimeUtils:getTimeCost(time)
        self:onQuickReq(1, cost, productionInfo)
        return
    end
    
    if #prospeeditem == 0 then  --直接提示框
        
        local time = buildingProxy:getCurBuildingProLineReTime(productionInfo.order)
        local cost = TimeUtils:getTimeCost(time)
        local content = string.format(self:getTextWord(811), cost)
        
        local function onCallback()
            self:onQuickReq(1, cost, productionInfo)
        end
        
        local messageBox = self:showMessageBox(content, onCallback)
        messageBox:setPanel(self)
    else
        if self._uiAcceleration == nil then
            self:addUIAcceleration()
        end
        self._uiAcceleration:show(buildingInfo, productionInfo, nil, sender.totalTime)
    end
   
end

--选择好加速类型了
function RecruitingPanel:onQuickReq(quickType, cost, productionInfo, num)
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local data = {}
    data.order = productionInfo.order
    data.buildingType = buildingInfo.buildingType
    data.index = buildingInfo.index
    data.useType = quickType
    data.useNum = num
    buildingProxy:onTriggerNet280009Req(data) --加速生产
end

function RecruitingPanel:renderCountDown(itemPanel)
    local info = itemPanel.info
    local productionInfo = itemPanel.productionInfo
    
    local infoTxt = itemPanel:getChildByName("infoTxt")
    local timeBar = itemPanel:getChildByName("timeBar")
    local Image_23 = itemPanel:getChildByName("Image_23")
    
    if productionInfo.state == 2 then  --等待生产中
--        infoTxt:setString(TimeUtils:getStandardFormatTimeString6(totalTime))
--        timeBar:setPercent(0)
        
        return
    end
    
    Image_23:setVisible(true)
    timeBar:setVisible(true)
    
    local timeneed = info.timeneed
    
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local speedRate = buildingInfo.speedRate
    timeneed = TimeUtils:getTimeBySpeedRate(timeneed, speedRate)
    
    local totalTime = productionInfo.num * timeneed
    
    local quickBtn = itemPanel:getChildByName("quickBtn")
    quickBtn.totalTime = totalTime
    
    
    
    local buildingProxy = self:getProxy(GameProxys.Building)
    local remainTime = buildingProxy:getCurBuildingProLineReTime(productionInfo.order)
    
    infoTxt:setString(TimeUtils:getStandardFormatTimeString6(remainTime))
    
    local process = (totalTime  - remainTime) / totalTime * 100 
    timeBar:setPercent(process)
    
end

function RecruitingPanel:update()
    for _, itemPanel in pairs(self._itemMap) do
    	self:renderCountDown(itemPanel)
    end
    
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:update()
    end
end

function RecruitingPanel:playEffect()
    if self._xszy == nil then
        if self._firstItemPanel == nil then
            return
        end

        self._xszy = self:createUICCBLayer("rgb-xszy", self._firstItemPanel) 
        self._xszy:setPosition(520, 60)

        self._xszyShou = self:createUICCBLayer("rgb-xszy-shou",self._xszy)
        self._xszyShou:setPosition(self._xszy:getContentSize().width/2,self._xszy:getContentSize().height/2)
        self._xszyShou:setRotation(90)
    else
        self._xszy:setVisible(true)
        self._xszyShou:setVisible(true)
    end
end
