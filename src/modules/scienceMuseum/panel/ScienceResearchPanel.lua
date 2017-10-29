ScienceResearchPanel = class("ScienceResearchPanel", BasicPanel) --太学院研发标签
ScienceResearchPanel.NAME = "ScienceResearchPanel"

function ScienceResearchPanel:ctor(view, panelName)
    ScienceResearchPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function ScienceResearchPanel:finalize()
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:finalize()
    end
    ComponentUtils:removeTaskIcon(self)
    ScienceResearchPanel.super.finalize(self)
end

function ScienceResearchPanel:initPanel()
    ScienceResearchPanel.super.initPanel(self)
    
    self._buildingProxy = self:getProxy(GameProxys.Building)

    local listView = self:getChildByName("listView")
    local item = listView:getItem(0)
    item:setVisible(false)
    self._listView = listView

    -- local tabsPanel = self:getTabsPanel()
    -- NodeUtils:adaptiveListView(listView,GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)
    

    self._configData = ConfigDataManager:getConfigData(ConfigData.MuseumConfig)
    --self:initListView()

end

function ScienceResearchPanel:doLayout()
    self:adaptiveList(self._listView)
end

function ScienceResearchPanel:initListView()
    self:onUpdateBuildingInfo()
end 
--显示界面时调用
function ScienceResearchPanel:onShowHandler()
    local panel = self:getPanel(ScienceMuseumPanel.NAME)
    panel:setBgType(ModulePanelBgType.NONE)

    if self:isModuleRunAction() then
        return
    end

    self._listView:jumpToTop()
    ScienceResearchPanel.super.onShowHandler(self)
    self:onUpdateBuildingInfo()
    
end

function ScienceResearchPanel:onAfterActionHandler()
    self:onShowHandler()
end

function ScienceResearchPanel:adaptiveList(listView)
    -- body 自适应列表
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(listView,GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight - 16)
end

--更新ListView  
function ScienceResearchPanel:onUpdateBuildingInfo(upSuccess)

    if upSuccess and upSuccess == true then
        self._listView:jumpToTop()  --操作成功，将列表置顶显示，解决任务图标不刷新问题
        self:showSysMessage(self:getTextWord(543))
    end
    self._itemPanelMap = {}
    print("self._itemPanelMap 1=====",#self._itemPanelMap)
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo  = buildingProxy:getCurBuildingInfo()
    self._scienceMuseumLv = buildingInfo.level
    -- self._speedRate = buildingInfo.speedRate
    local playerProxy = self:getProxy(GameProxys.Role)
    self._speedRate = playerProxy:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_scirespeedrate)

    print("self._speedRate====",self._speedRate)
    logger:info("更新self._speedRate====%d  level=%d", self._speedRate, self._scienceMuseumLv)

    local productionInfos = buildingInfo.productionInfos --正在升级的科技队列
    
    -- local configData = ConfigDataManager:getConfigData(ConfigData.MuseumConfig)
    local configData = self._configData
    local scienceInfos = {}
    for _,v in pairs(configData) do
        local buildingDetailInfo = buildingProxy:getCurBuildingDetailInfo(v.scienceType)
        local temp = {}
        local scienceLv = 0
        if buildingDetailInfo ~= nil then
            scienceLv = buildingDetailInfo.num
        end 
        temp.configData = v 
        temp.scienceLv = scienceLv
        if productionInfos ~= nil and #productionInfos > 0 then
            for _,value in pairs(productionInfos) do
                if v.scienceType == value.typeid then
                    temp.production = value
                    break
                end 
            end 
        end 
        table.insert(scienceInfos,temp)
    end 
    table.sort( scienceInfos, sortScienceList)
    if #scienceInfos <= 0 then return end
    local taskProxy = self:getProxy(GameProxys.Task)
    self.taskInfo = taskProxy:getMainTaskListByType(1)
    self:renderListView(self._listView, scienceInfos, self, self.renderItemPanel)
    -- ComponentUtils:renderTaskIcon(self, nil, self._listView)  --防止listview局部刷新问题
    
end

function ScienceResearchPanel:renderItemPanel(itemPanel, info ,index)
    self["itemPanel"..(index+1)] = itemPanel
    self["itemPanel"..(info.configData.ID).."taskIcon"] = index

    local taskInfo = self.taskInfo

    -- 移除任务icon
    if self._renderTaskIconIndex == index then
        self._renderTaskIconIndex = nil
        ComponentUtils:removeTaskIcon(self)
    end

    -- 任务数据防nil
    if taskInfo ~= nil then
        if info.configData.ID == taskInfo.conf.finishcond1 then
            if taskInfo.state == 1 or taskInfo.num >= taskInfo.conf.finishcond2 or info.scienceLv == taskInfo.conf.finishcond2 then --已完成
                
            else
                self._renderTaskIconIndex = index
                ComponentUtils:renderTaskIcon(self, nil, self._listView)
            end
        else

        end
    end

    itemPanel:setVisible(true)
    table.insert(self._itemPanelMap,itemPanel)
    local need  = self:getScienceLevelUpNeed(info.configData.scienceType,info.scienceLv)
--    print("name,needtime 1=====",info.configData.name,need.time,self._speedRate)
    local playerProxy = self:getProxy(GameProxys.Role)
    local rate2 = playerProxy:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_technologyResSpeedAdd)
    local function isAddRate2()
        local tb = {1,4,7,10,14}--  /*资源类科技研发速度提升x%*/只有这些类型才加
        for k, v in pairs(tb) do
            if v == info.configData.scienceType then
                return true
            end
        end
        return false
    end
    if isAddRate2() then
        need.time = TimeUtils:getTimeBySpeedRate(need.time, self._speedRate + rate2)
    else
        need.time = TimeUtils:getTimeBySpeedRate(need.time, self._speedRate)
    end
--    print("name,needtime 2=====",info.configData.name,need.time)
    itemPanel.info = info  --绑定信息
    itemPanel.need = need
    local itemChildren = self:getItemChildren(itemPanel)

    --图标
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = info.configData.icon
    iconInfo.num = 0

    local icon = itemPanel.icon
    if icon == nil then
        -- local Image_124 = Image_123:getChildByName("Image_124")
        local conIcon = itemChildren.imageIcon
        icon = UIIcon.new(conIcon,iconInfo,false)
        
        itemPanel.icon = icon
    else
        icon:updateData(iconInfo)
    end

    local tmp = {}
    tmp.info =  itemPanel.info
    tmp.need = itemPanel.need
    local isCanUpGrate = self:isHaveResource(tmp) -- 是否有资源
    NodeUtils:setEnable(itemChildren.btnUpgrate, isCanUpGrate)
    

    itemChildren.btnInfo:setTouchEnabled(false)
    itemPanel.icon:setTouchEnabled(false)

    -- 感叹号坐标
    local size = itemChildren.labelLevel:getContentSize()
    local x = itemChildren.labelLevel:getPositionX()
    -- itemChildren.btnInfo:setPositionX(x + size.width + 20)

    --名字
    itemChildren.labelName:setString(info.configData.name)

    ----按钮
    self:addTouchEventListener(itemPanel, self.onShowInfo)
    self:addTouchEventListener(itemChildren.btnUpgrate,self.onUpgrate)
    self:addTouchEventListener(itemChildren.btnCancel,self.onCancel)
    self:addTouchEventListener(itemChildren.btnAccelerate,self.onAccelerate)
    --设置是否可见
    self:setItemChildrenVisible(itemPanel)
    
end 
--设置item子节点是否可见
function ScienceResearchPanel:setItemChildrenVisible(itemPanel)
    local itemInfo = itemPanel.info 
    local itemNeed = itemPanel.need
    local itemChildren = self:getItemChildren(itemPanel)
    local scienceLv = itemInfo.scienceLv
    
    local visible = true
    if itemInfo.production ~= nil then --正在升级
        local remain = itemInfo.production.remainTime
        local lvStr = string.format("Lv.%d->Lv.%d",scienceLv,scienceLv+1)
        local timeStr = TimeUtils:getStandardFormatTimeString6(remain)

        local order = itemInfo.production.order
        local buildingProxy = self:getProxy(GameProxys.Building)
        local remainTime = buildingProxy:getCurBuildingProLineReTime(order)
        timeStr = TimeUtils:getStandardFormatTimeString6(remainTime)

        local state = itemInfo.production.state
        local process = (itemNeed.time - remain) / itemNeed.time * 100
        itemChildren.btnAccelerate.totalTime = itemNeed.time
        NodeUtils:setEnable(itemChildren.btnAccelerate, true)
        if state == 2 then --等待生产
            lvStr = string.format("Lv.%d",scienceLv)
            timeStr = self:getTextWord(8309)
            process = 0
            NodeUtils:setEnable(itemChildren.btnAccelerate, false)
        end 
        --科技等级
        itemChildren.labelLevel:setString(lvStr)
        -----------------可见---------------
        --升级时间
        itemChildren.labelTime:setVisible(true)
        
        -- itemChildren.labelTime:setString(timeStr)
        itemChildren.labTimeBar:setString(timeStr)
        --进度条
         
        itemChildren.progressBar:setPercent(process)
        -----------------不可见---------------
        --时钟图标
        itemChildren.imageClock:setVisible(false)
        itemChildren.labelTime:setVisible(false)
        --限制提示
        itemChildren.labelLimit:setVisible(false)
        --信息按钮
        itemChildren.btnInfo:setVisible(false)
        --升级按钮
        itemChildren.btnUpgrate:setVisible(false)

    else
        visible = false
        local lvStr = string.format("Lv.%d",scienceLv)
        itemChildren.labelLevel:setString(lvStr)
        -----------------可见---------------
        local limitLv = itemInfo.configData.reqSCenterLv
        local visible1 = true
        local visible2 = false
        local scienceMuseumLv = self._scienceMuseumLv
        if scienceMuseumLv >= limitLv then
            local timeStr = TimeUtils:getStandardFormatTimeString6(itemNeed.time)
            itemChildren.labelTime:setString(timeStr)
        else
            visible1 = false
            visible2 = true
            local limitStr = string.format(self:getTextWord(8310),limitLv)
            itemChildren.labelLimit:setString(limitStr)
        end 
        --时钟图标
        itemChildren.imageClock:setVisible(visible1)
        itemChildren.labelTime:setVisible(visible1)
        --升级时间
        itemChildren.labelTime:setVisible(visible1)  
        --信息按钮
        itemChildren.btnInfo:setVisible(visible1)
        --升级按钮
        itemChildren.btnUpgrate:setVisible(visible1)
        --限制提示
        itemChildren.labelLimit:setVisible(visible2)
        
    end 
    --进度条
    itemChildren.imageProgressBarBg:setVisible(visible)
    itemChildren.progressBar:setVisible(visible)
    --取消按钮
    itemChildren.btnCancel:setVisible(visible)
    --加速按钮
    itemChildren.btnAccelerate:setVisible(visible)
end 
--获取item的子控件
function ScienceResearchPanel:getItemChildren(itemPanel)
    local t = {}
    --获取控件
    t.imageIcon  = itemPanel:getChildByName("Image_icon")    --科技图标
    t.labelName  = itemPanel:getChildByName("Label_name")    --科技名称
    t.labelLevel = itemPanel:getChildByName("Label_level")  --科技等级
    t.labelTime  = itemPanel:getChildByName("Label_time")   --升级时间
    t.labelLimit = itemPanel:getChildByName("Label_limit")  --等级限制
    t.imageClock = itemPanel:getChildByName("Image_clock")  --时钟图标
    t.btnInfo    = itemPanel:getChildByName("Button_info")     --详细信息按钮
    t.btnUpgrate = itemPanel:getChildByName("Button_upgrate")--升级按钮
    t.btnCancel  = itemPanel:getChildByName("Button_cancel") --取消升级按钮
    t.btnAccelerate = itemPanel:getChildByName("Button_accelerate") --加速升级按钮
    t.imageProgressBarBg = itemPanel:getChildByName("Image_progressBarBg")--进度条背景
    t.progressBar = itemPanel:getChildByName("ProgressBar")--进度条控件
    t.labTimeBar = t.progressBar:getChildByName("labTimeBar")--进度条控件

    return t
end
--获取科技升级所需时间和资源
function ScienceResearchPanel:getScienceLevelUpNeed(typeid,level)
    local lvConfig = ConfigDataManager:getConfigData(ConfigData.ScienceLvConfig)
    --遍历科技等级表获取升级需要时间
    local need = {}
    for _,value in pairs(lvConfig) do
        if value.scienceType == typeid then
            if value.level == level then
                need.level = value.level
                need.time = value.time
                need.resource = StringUtils:jsonDecode(value.need)
                need.reqPrestigeLv = value.reqPrestigeLv
--                table.insert(need.resource, 1, {PlayerPowerDefine.POWER_prestigeLevel, value.reqPrestigeLv})
                break
            end 
        end 
    end 
    return need
end 
--打开加速面板
function ScienceResearchPanel:addUIAcceleration()
    local parent = self:getParent()
    local uiAcceleration = UIAcceleration.new(parent, self)
    self._uiAcceleration = uiAcceleration
end
function ScienceResearchPanel:updateUpgratingItem()
    local items = self._itemPanelMap
    local buildingProxy = self:getProxy(GameProxys.Building)
    for _,item in pairs(items)do
        local production = item.info.production
        if production ~= nil and production.state == 1 then
            local con = item.info.configData
            local order = production.order
            local remainTime = buildingProxy:getCurBuildingProLineReTime(order)
            local timeStr = TimeUtils:getStandardFormatTimeString6(remainTime)
            local needTime = item.need.time
            local percent = (needTime - remainTime) / needTime * 100
            local labelTime = item:getChildByName("Label_time")
            local progressBar = item:getChildByName("ProgressBar")
            local labTimeBar = progressBar:getChildByName("labTimeBar")
            labTimeBar:setString(timeStr)
            progressBar:setPercent(percent)
        end 
    end
end 

--选择好加速类型了
function ScienceResearchPanel:onQuickReq(quickType, cost,productionInfo, num)
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local data = {}
    data.order = productionInfo.order
    data.buildingType = buildingInfo.buildingType
    data.index = buildingInfo.index
    data.useType = quickType
    data.useNum = num
    buildingProxy:onTriggerNet280009Req(data)

end
--定时器
function ScienceResearchPanel:update()

    self:updateUpgratingItem()
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:update()
    end
end
-------------------回调函数定义-----------------

--显示升级所需材料信息
function ScienceResearchPanel:onShowInfo(sender)
    -- local item = sender:getParent()
    local item = sender
    local info = item.info
    local need = item.need
    -- local upgrateNeed = item.need.resource
    -- local roleProxy = self:getProxy(GameProxys.Role)

    -- print("================id      need        have=============")
    -- for _,value in ipairs(upgrateNeed) do
    --     local id = value[2]
    --     local num =value[3]
    --     local have = roleProxy:getRolePowerValue(GamePowerConfig.Resource,id) 
    --     print("================"..id.."     "..num.."       "..have.."=============")
    -- end 
    
    local data = {}
    data.info = info
    data.need = need

    self:onShowBuildTip(data)
end

-- 显示tip弹窗
function ScienceResearchPanel:onShowBuildTip(data)
    -- body
    if self._uiBuildingTip == nil then
        self._uiBuildingTip = UIBuildingTip.new(self:getParent(), self, 1)
    end
    self._uiBuildingTip:updateBuilding(data)
end


--升级
function ScienceResearchPanel:onUpgrate(sender)
    local item = sender:getParent()
    local itemInfo = item.info 
    --发送升级请求
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local data = {}
    data.buildingType = buildingInfo.buildingType --建筑类型
    data.index = buildingInfo.index --建筑位置ID
    data.typeid = itemInfo.configData.scienceType --产品类型
    data.num = itemInfo.scienceLv    --产品数量
    -- print("typeid====",data.typeid)
    -- buildingProxy:buildingProductionInfoReq(data) --发送请求
    buildingProxy:onTriggerNet280006Req(data)
end 
 
--取消升级
function ScienceResearchPanel:onCancel(sender)
    local item = sender:getParent()
    local itemInfo = item.info
    local function okCallback()
         --发送取消升级请求
        local buildingProxy = self:getProxy(GameProxys.Building)
        local buildingInfo = buildingProxy:getCurBuildingInfo()
        local data = {}
        data.buildingType = buildingInfo.buildingType --建筑类型
        data.index = buildingInfo.index --建筑位置ID
        data.order = itemInfo.production.order    
        -- buildingProxy:buildingCancelUpgradeReq(data) --发送请求
        buildingProxy:onTriggerNet280008Req(data)
    end
    --弹出确认提示框：返还部分资源
    self:showMessageBox(self:getTextWord(8308),okCallback)
     
end 
--加速升级
function ScienceResearchPanel:onAccelerate(sender)
    local item  = sender:getParent()
    
    if self._uiAcceleration == nil then
        self:addUIAcceleration()
    end
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    
    local productInfo = item.info.production --productInfo实际上应该从服务端获取
    local extroInfo = {}
    extroInfo.configData = item.info.configData
    extroInfo.needTime = item.need.time
    extroInfo.scienceLv = item.info.scienceLv
    self._uiAcceleration:show(buildingInfo,productInfo,extroInfo, sender.totalTime)
end 

--科技馆排序
function sortScienceList(a,b)
    local aPro = a.production 
    local bPro = b.production 
    if aPro ~= nil and bPro == nil then
        return true
    elseif  aPro == nil and bPro ~= nil then
        return false
    elseif  aPro ~= nil and bPro ~= nil then
        return aPro.order < bPro.order
    else
        return a.configData.ID < b.configData.ID 
    end 

end 


function ScienceResearchPanel:onUpdateBuildingInfo_1()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local productionInfos = buildingInfo.productionInfos
    --如果科技的剩余时间不为0则更新正在升级的科技
    if productionInfos and #productionInfos > 0 then 
        for i,v in pairs(productionInfos) do
            print(i,v.typeid,v.remainTime,v.order)
            local productionInfo = v
            local item = self._itemPanelMap[productionInfo.typeid]
            if item then
                local buildingDetailInfo = buildingProxy:getCurBuildingDetailInfo(productionInfo.typeid)
                item.info.level = buildingDetailInfo.num
                
                print("==--如果科技的剩余时间不为0则更新正在升级的科技==")
                self:itemUpgrating(productionInfo)
            end
        end 
        
    else
        if self._upgratingItem and #self._upgratingItem >0 then
            for i,v in pairs(self._upgratingItem) do
                    table.remove(self._upgratingItem,i)
                 
            end
        end
        self:onResetPanel()
    end 
    
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:update()
    end
end


--判断是否够资源
function ScienceResearchPanel:isHaveResource(data)

    local info = data.info
    local need = data.need

    local scienceLv = info.scienceLv
    local scienceType = info.configData.scienceType
    local configData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.ScienceLvConfig, "scienceType", scienceType, "reqPrestigeLv", scienceLv + 1)
    if configData == nil then
        configData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.ScienceLvConfig, "scienceType", scienceType, "reqPrestigeLv", scienceLv)
    end

    -- 图标
    local iconInfo = { }
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = info.configData.icon
    iconInfo.num = 0

    local listInfos = { }

    -- 太学院等级
    local reqSCenterLv = configData.reqSCenterLv
    local listInfo = { }
    listInfo.power = GamePowerConfig.Building
    listInfo.typeid = 8
    listInfo.num = reqSCenterLv
    table.insert(listInfos, listInfo)

    -- 声望等级
    local reqPrestigeLv = need.reqPrestigeLv
    local listInfo = { }
    listInfo.power = GamePowerConfig.Resource
    listInfo.typeid = PlayerPowerDefine.POWER_prestigeLevel
    listInfo.num = reqPrestigeLv
    table.insert(listInfos, listInfo)

    -- 资源需求
    local per = 100
    local technologyProxy = self:getProxy(GameProxys.Technology)
    local roleProxy = self:getProxy(GameProxys.Role)
    local resPer = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_519)
    if resPer >0 and technologyProxy:isResourcesType(scienceType) then        
        per = resPer
    end

    for _, v in pairs(need.resource) do
        local listInfo = { }
        listInfo.power = v[1]
        listInfo.typeid = v[2]
        listInfo.num = v[3] * ( per / 100)
        table.insert(listInfos, listInfo)
    end
    for i = 1, #listInfos do
        local isHave = self:checkIsHaveOneByone(listInfos[i])
        if isHave == false then
            return false
        end
    end
    return true
end

function ScienceResearchPanel:checkIsHaveOneByone(data)
    local power = data.power
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveNum = roleProxy:getRolePowerValue(data.power, data.typeid)
    if power == GamePowerConfig.Building then
        local buildingProxy = self:getProxy(GameProxys.Building)
        local buildingInfo  = buildingProxy:getCurBuildingInfo()
        haveNum = buildingInfo.level
    end
    --算出一个最大可以使用的数量
    if haveNum >= data.num  then --资源够
        return true
    else
        return false
    end
end