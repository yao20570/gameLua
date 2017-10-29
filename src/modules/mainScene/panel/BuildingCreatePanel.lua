BuildingCreatePanel = class("BuildingCreatePanel", BasicPanel)
BuildingCreatePanel.NAME = "BuildingCreatePanel"

function BuildingCreatePanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_3_LAYER)
    BuildingCreatePanel.super.ctor(self, view, panelName, true, layer)
    
    self:setUseNewPanelBg(true)
end

function BuildingCreatePanel:finalize()
    if self._uiBuildingTip ~= nil then
        self._uiBuildingTip:finalize()
    end
    ComponentUtils:removeTaskIcon(self)
    BuildingCreatePanel.super.finalize(self)
end

function BuildingCreatePanel:initPanel()
    BuildingCreatePanel.super.initPanel(self)
    
    self:setTitle(true,"jianzao",true)
    self:setBgType(ModulePanelBgType.NONE)
    self._buildingListView = self:getChildByName("buildingListView")
    self._topPanel = self:getChildByName("topPanel")    
    
end

function BuildingCreatePanel:doLayout()
    NodeUtils:adaptiveUpPanel(self._topPanel,nil,GlobalConfig.tabsHeight-50)
    NodeUtils:adaptiveListView(self._buildingListView,GlobalConfig.downHeight, self._topPanel)
end

function BuildingCreatePanel:onHideHandler()
--    self:setParentZOrder(ModuleLayer.UI_Z_ORDER_0)

    self.view:hideFullScreenPanel()
end

function BuildingCreatePanel:onShowHandler(info)

    self.view:showFullScreenPanel()
--    self:setParentZOrder(ModuleLayer.UI_Z_ORDER_2)
    self._curBuildingIndex = info.ID
    local canbuildList = StringUtils:jsonDecode(info.canbulid)
    
    print("== 建造 BuildingIndex==",self._curBuildingIndex)

    local list = {}
    for _, id in pairs(canbuildList) do
        table.insert(list, {id = id})
    end

    self:renderListView(self._buildingListView,list, self, self.renderItemPanel)
    self:updateTopPanel()
    
    if self._curBuildingIndex < 8 or table.size(list) == 1 then  --铸币所,农田：不显示任务图标
        ComponentUtils:removeTaskIcon(self)
    else
        ComponentUtils:renderTaskIcon(self, nil, self._buildingListView)
    end


end

function BuildingCreatePanel:renderItemPanel(itemPanel, data, index)
    itemPanel:setVisible(true)
    self["itemPanel"..(index + 1)] = itemPanel
    self["itemPanel"..(index + 1).."taskIcon"] = index
    local buildingType = data.id
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingConfig = buildingProxy:getBuildingConfigInfo(buildingType, 0)
    
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local timeTxt = itemPanel:getChildByName("timeTxt")
    local infoBtn = itemPanel:getChildByName("infoBtn")
    local createBtn = itemPanel:getChildByName("createBtn")
    local buildingImg = itemPanel:getChildByName("buildingImg")
    
    local url = string.format("images/mainScene/building_%d.png", buildingType)
    TextureManager:updateImageView(buildingImg,url)
    buildingImg:setScale(0.6)
    
    nameTxt:setString(buildingConfig.name)
    
    local size = nameTxt:getContentSize()
    local x = nameTxt:getPositionX()
    infoBtn:setPositionX(x + size.width + 20)
    infoBtn:setTouchEnabled(false)
    buildingImg:setEnabled(false)

    
    local timeStr = TimeUtils:getStandardFormatTimeString6(buildingConfig.time)
    timeTxt:setString(timeStr)
    
    -- infoBtn.info = buildingConfig
    buildingConfig.buildingType = buildingType
    createBtn.info = buildingConfig
    itemPanel.info = buildingConfig
    
    if createBtn.isAddEvent == true then
        return
    end
    createBtn.isAddEvent = true
    
    self:addTouchEventListener(createBtn, self.onCreateBtnTouch)
    self:addTouchEventListener(itemPanel, self.onInfoBtnTouch)
    
    local index = self._buildingListView:getIndex(itemPanel)
    self["createBtn" .. (index + 1)] = createBtn
end

function BuildingCreatePanel:onCreateBtnTouch(sender)
    local info = sender.info
    
    local buildingProxy = self:getProxy(GameProxys.Building)

    local data = {}
    data.index = self._curBuildingIndex
    data.buildingType = info.type
    data.type = 1 --TODO

    buildingProxy:onTriggerNet280001Req(data)
    -- buildingProxy:buildingUpgradeReq(data)
    
    self:onClosePanelHandler()
end

function BuildingCreatePanel:onInfoBtnTouch(sender)
    local info = sender.info
    
    if self._uiBuildingTip == nil then
        self._uiBuildingTip = UIBuildingTip.new(self:getParent(), self)
    end
    
    self._uiBuildingTip:updateBuilding(info)
end

function BuildingCreatePanel:onClosePanelHandler()
    --这个面板比较特殊，属于通用面板，只有在建设铁矿、木材和石料3个才会出现任务icon
    --当建铸币所的时候铁矿那些item已经属于无效的obj，在render时候删除就会报错
    --所以这个面板在关闭就要删掉任务icon，免得出现self.taskIcon~=nil  但是他的父节点却属于无效obj
    ComponentUtils:removeTaskIcon(self)
    BuildingCreatePanel.super.onClosePanelHandler(self)
    self:hide()

    if self._closeCallback ~= nil then
        self._closeCallback()
        self._closeCallback = nil
    end
end

-- 显示已建造的资源建筑数量
function BuildingCreatePanel:updateTopPanel()
    local types = {
        4,      --铁
        5,      --石
        3       --木
    }

    local buildingProxy = self:getProxy(GameProxys.Building)
    local topPanel = self._topPanel
    for i=1,3 do
        local number = buildingProxy:getOneTypeBuildingInfo(types[i])
        if number == nil then
            number = 0
        else
            number = table.size(number)
        end
        local labelTxt = topPanel:getChildByName("label"..i)
        local numberTxt = topPanel:getChildByName("number"..i)
        labelTxt:setString(self:getTextWord(8600 + types[i]))
        numberTxt:setString(number)
        local size = labelTxt:getContentSize()
        numberTxt:setPositionX(labelTxt:getPositionX() + size.width + 10)
    end
end

-- 回调函数
function BuildingCreatePanel:setCloseCallBack(closeFun)
    if closeFun ~= nil then
        self._closeCallback = closeFun
    end
end




