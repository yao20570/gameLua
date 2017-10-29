--兵营招兵
BarrackRecruitPanel = class("BarrackRecruitPanel", BasicPanel)
BarrackRecruitPanel.NAME = "BarrackRecruitPanel"

--UI配置参数
--self._rootSize = cc.size(760, 420)   与Module_Size对应
 
--self._moveCenterX = 321   与Module_Center对应
--self._moveCenterY = 102

--local x = self._moveCenterX + disX * math.sin(i * self._unitAngle + self:getAngle())
--local y = self._moveCenterY - disY * math.cos(i * self._unitAngle + self:getAngle())
--
--self._soldierArr[i]:setPosition(x, y);
--
--self._soldierArr[i]:setOpacity(192 + 63 * math.cos(i * self._unitAngle + self:getAngle()));
--self._soldierArr[i]:setScale(0.75 + 0.25 * math.cos(i * self._unitAngle + self:getAngle()));

--模型转动的区域大小（第一个值为width，第二个值为height）
--BarrackRecruitPanel.Module_Size = {760, 420}--（状态：不可修改）
--
----模型转动的圆心（第一个值为X，第二个值为Y）Y值控制模型士兵模型上下高度位置，X值不建议修改作用和Y值同理
--BarrackRecruitPanel.Module_Center = {321, 102}--（状态：可修改）---------------------------------------------------------------------
--
----模型透明基值（最后面士兵模型最终透明度，范围：0 - 255，0：透明， 255：不透明）
--BarrackRecruitPanel.Opacity_Basic = 192--（状态：可修改）---------------------------------------------------------------------
----模型透明因子（状态：不可修改）
--BarrackRecruitPanel.Opacity_Factor = 255 - BarrackRecruitPanel.Opacity_Basic--(高级版：这个暂时不开启，与转动的时候，透明度变化率相关)
--
----缩放基值 + 缩放因子 = 1（理想状态两个值相加要等于1，超过会拉伸原来模型大小，反之亦然）
----模型缩放基值（最后面士兵模型最终缩放比例，范围：可放大，所以暂时不做限制）
--BarrackRecruitPanel.Scale_Basic = 0.75--（状态：可修改）---------------------------------------------------------------------
----模型缩放因子
--BarrackRecruitPanel.Scale_Factor = 0.25--（状态：可修改）---------------------------------------------------------------------
----模型偏移角度
--BarrackRecruitPanel.Offset_Angel = 0.2--（状态：可修改）---------------------------------------------------------------------
----模型适配偏移（距离上面的距离）
--BarrackRecruitPanel.Offset_Aaptive = 100--（状态：可修改）---------------------------------------------------------------------



BarrackRecruitPanel.Type_Dao = 1
BarrackRecruitPanel.Type_Qi = 2
BarrackRecruitPanel.Type_Qiang = 3
BarrackRecruitPanel.Type_Gong = 4

function BarrackRecruitPanel:ctor(view, panelName)
    BarrackRecruitPanel.super.ctor(self, view, panelName)
    
    --print("111111111111111111111111111111111111111111111111111111111111111111111111")
    self:setUseNewPanelBg(true)
end

function BarrackRecruitPanel:finalize()
    ComponentUtils:removeTaskIcon(self)

    BarrackRecruitPanel.super.finalize(self)
end

function BarrackRecruitPanel:initPanel()
    BarrackRecruitPanel.super.initPanel(self)

    --for i=1,2 do
    --    local listView = self:getChildByName("listView"..i)
    --    local item = listView:getItem(0)
    --    listView:setItemModel(item)
    --    item:setVisible(false)
    --    self["listView"..i] = listView
    --end
    --self._tmpListView = self.listView2
    --常量
    self.MAX_COUNT_MOVE_OBJ = 4 --最大移动对象数量
    self.MAX_SOLDIER_LEVEL = 6 --兵种最大等级
    self.SOLDIIER_PATH = {"dao_", "qi_", "qiang_", "gong_"}
    self.MAX_PRODUCT_NUM = 100 --最大生产数量
    self.SOLDIIER_LEVEL = {"一阶", "二阶", "三阶", "四阶", "五阶", "黄阶", "玄阶", "地阶", "天阶"}

    self._lastData = {}--保存上次操作数据

    -- 触摸相关
    self._startMove = nil                       
    self._startPos = nil                       --触摸开始的位置

    --组件节点相关
    self._soldierArr = {}                       ---转盘上四个移动对象的数组
    self._soldierModelArr = {}                  ---转盘上四个士兵模型的数组
    self._moveObjPosArr = {}                    -----转盘上四个移动对象初始坐标数组
    self._moveObjCurrentPosArr = {}             -----转盘上四个移动对象当前坐标数组
    self._currentSelectedIndex = 1              --转盘当前选中下标默认初始化为1
    self._needTxtMap = {}                       --需求资源显示Label
    self._needTxtImageMap = {}                  --需求资源显示Label 对应的icon
    self._soldierLockArr = {}                   ---转盘上四个移动对象锁Icon的数组
    
    self._selectedLevelIconArr = {}             ----选中士兵品级图标数组
    self._selectedLevelLockArr = {}             ----选中士兵品级图标锁Icon数组
    self._taskMarkArr = {}                      ----任务标签Icon数组
    self._levelBtnArr = {}                      ----士兵品级按钮数组
    self._soldierData = {}                      ----士兵数据

    self._curSelectCount = 1                    ----当前选择的生产数量
    self._minNum = 2000000000
    self._uiMoveBtn = nil
    self._resInfos = {}                         --当前选中兵种资源消耗数据
    self._tipsTxtInfos = {}                     --8216 用绿色字 空格隔开 只显示缺少的道具 
    -------------------------------------------------------------------------------------------------------------
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType
    

    self._labTips = self:getChildByName("ConscriptionPanel/labTips")--提示文字
    
    self._btnRecruit = self:getChildByName("ConscriptionPanel/btnRecruit")--招募按钮

    self.listView1 = self:getChildByName("listView1")
    local item = self.listView1:getItem(0)
    self.listView1:setItemModel(item)
    item:setVisible(false)
    self._conscriptionPanel = self:getChildByName("ConscriptionPanel")
    self._TouchPanel = self._conscriptionPanel:getChildByName("TouchPanel")
    self._btnSkillInfo = self._conscriptionPanel:getChildByName("btnSkillInfo")
    self._btnAuar = self._conscriptionPanel:getChildByName("btnAuar")
    self._btnRestrain = self._conscriptionPanel:getChildByName("btnRestrain")
    self:addTouchEventListener(self._btnSkillInfo, self.onShowSoldierTip)
    self:addTouchEventListener(self._btnAuar, self.onShowSoldierTip)
    self:addTouchEventListener(self._btnRestrain, self.onShowSoldierTip)


    self._soldierInfoPanel = self:getChildByName("SoldierInfoPanel")
--    NodeUtils:adaptive(listView)
    for i = 1,self.MAX_COUNT_MOVE_OBJ do
        self._soldierArr[i] = self._TouchPanel:getChildByName("imgMove_" .. i)
        if buildingType == BuildingTypeConfig.REFORM then--校场没有一阶
            self._soldierArr[i].tag = 2
        elseif buildingType == BuildingTypeConfig.BARRACK then
            self._soldierArr[i].tag = 1
        end
        self._soldierModelArr[i] = self._soldierArr[i]:getChildByName("imgPeople")
        self._soldierModelArr[i].tag = i
        TextureManager:updateImageViewFile(self._soldierModelArr[i], "bg/barrack/" .. self.SOLDIIER_PATH[i] .. "1.png")
        self._moveObjPosArr[i] = cc.p(self._soldierArr[i]:getPosition())
        self._moveObjCurrentPosArr[i] = cc.p(self._soldierArr[i]:getPosition())
        self._soldierLockArr[i] = self._soldierArr[i]:getChildByName("imgLock")
    end

    self._guideQi = self._soldierModelArr[2]
    self:addTouchEventListener(self._guideQi, self.guideSelect)

--    self._guideDao = self._soldierModelArr[1]
--    self:addTouchEventListener(self._guideDao, self.guideSelect)

    
    self._soldierArr[1]:setLocalZOrder(10)

    for i = 1,self.MAX_SOLDIER_LEVEL do
        self._taskMarkArr[i] = self._conscriptionPanel:getChildByName("imgTaskMark_" .. i)--任务标签
        self._selectedLevelIconArr[i] = self._conscriptionPanel:getChildByName("imgLevel_" .. i)
        self._selectedLevelIconArr[i]:setVisible(false)
        self._levelBtnArr[i] = self._conscriptionPanel:getChildByName("btn_" .. i)
        self:addTouchEventListener(self._levelBtnArr[i], self.selectedSoldierLevel)
        self._levelBtnArr[i].tag = i
        self._levelBtnArr[i].sort = i
        --Icon上的锁     
        self._selectedLevelLockArr[i] = self._conscriptionPanel:getChildByName("imgLock_" .. i)
    end
    self._selectedLevelIconArr[1]:setVisible(true)
    ---------------------------------------------------------------------------
    -- NodeUtils:setEnable(self._levelBtnArr[6], false)--黄级士兵暂时没开放
    ---------------------------------------------------------------------------

    --资源需求
    for i = 1,7 do
        self._needTxtMap[i] = self._soldierInfoPanel:getChildByName("labResTxt_" .. i)
        self._needTxtImageMap[i] = self._soldierInfoPanel:getChildByName("imgRes_" .. i)
    end
    
    local btnShowSoldierInfo = self._soldierInfoPanel:getChildByName("btnHelp")
    self:addTouchEventListener(btnShowSoldierInfo, self.showSoldierInfo)

    --//null 添加一个评论按钮
    local btnCommon = self:getChildByName("ConscriptionPanel/TouchPanel/btnCommon")
    print(btnCommon)
    self:addTouchEventListener(btnCommon,self.showCommon)
     --GlobalConfig.topTabsHeight
    
    -- self._listView = listView
    
    if buildingType == BuildingTypeConfig.REFORM then--校场没有一阶
        self._levelBtnArr[1]:setVisible(false)
        self._selectedLevelIconArr[1]:setVisible(false)
        self._levelBtnArr[6]:setVisible(false)
        self._selectedLevelIconArr[6]:setVisible(false)
    end

    -- self:initAllArmProduct()
    self:initTouchEvent()
    
end



function BarrackRecruitPanel:guideSelect(sender, value)
    self._currentSelectedIndex = sender.tag
    --self._guideNum = value
    self:setAngle(- self._unitAngle * self._currentSelectedIndex)
    self:updatePosition()
    self:setSelectedSoldierLevelIcon()

    sender:setTouchEnabled(false)
end

function BarrackRecruitPanel:doLayout()
    local upWidget = self:getTabsPanel()
    --for i=1,2 do
    --    local listView = self:getChildByName("listView"..i)self._conscriptionPanel
    --    NodeUtils:adaptiveListView(listView, GlobalConfig.downHeight, upWidget, 0)
    --end
    NodeUtils:adaptiveListView(self:getChildByName("listView1"), GlobalConfig.downHeight, upWidget, 0)
    --NodeUtils:adaptiveListView(self._soldierInfoPanel, self._conscriptionPanel, upWidget, GlobalConfig.topTabsHeight)
    NodeUtils:adaptiveUpPanel(self._soldierInfoPanel, upWidget, GlobalConfig.topTabsHeight - 8)
    NodeUtils:adaptiveUpPanel(self._conscriptionPanel, self._soldierInfoPanel, 0 - GlobalConfig.Offset_Aaptive+10)
    --NodeUtils:adaptiveDownPanel(self._soldierInfoPanel, GlobalConfig.downHeight, 0)
end

function BarrackRecruitPanel:initAllArmProduct()
    self._itemConfig = ConfigDataManager:getItemConfig()
    self._itemPanelMap = {}

    local buildingProxy = self:getProxy(GameProxys.Building)
    local proConfigName = buildingProxy:getCurBuildingProConfigName()
    if proConfigName == nil then
        logger:error("== proConfigName, buildingType >> %s %d | %s",proConfigName, self._curBuildingType,debug.traceback())
        return
    end

    local allInfos = ConfigDataManager:getConfigDataBySortKey(proConfigName, "sort")
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    self._curBuildingType = buildingInfo.buildingType
    self.listView1:setVisible(self._curBuildingType == BuildingTypeConfig.MAKE)
    --self.listView2:setVisible(self._curBuildingType ~= BuildingTypeConfig.MAKE)
    self._conscriptionPanel:setVisible(self._curBuildingType ~= BuildingTypeConfig.MAKE)
    
    

    if self._curBuildingType == BuildingTypeConfig.MAKE then  --工匠坊
        self:renderListView(self.listView1, allInfos, self, self.renderItemPanel)
        self._soldierInfoPanel:setVisible(false)
    else
        self._soldierData = self:getBarrackInfo(buildingProxy)  --兵营OR校场
        --self:renderListView(self.listView2, data, self, self.renderItem)
        self._soldierInfoPanel:setVisible(true)
        self:initViewData()
    end
end

function BarrackRecruitPanel:getBarrackInfo(proxy)
    local proConfigName = proxy:getCurBuildingProConfigName()
    if proConfigName == nil then
        logger:error("== proConfigName, buildingType >> %s %d | %s",proConfigName, self._curBuildingType,debug.traceback())
        return
    end

    local allInfos = ConfigDataManager:getConfigDataBySortKey(proConfigName, "sort")
    local data = {}
    --local index = 1
    --for i=1, #allInfos, 2 do
    --    data[index] = {}
    --    table.insert(data[index], allInfos[i])
    --    table.insert(data[index], allInfos[i + 1])
    --    index = index + 1
    --end
    

    ---------------------------------------------------------------
    local soldierType = 1

    for i=1, #allInfos do
        soldierType = math.modf(allInfos[i].ID / 100)
        if data[soldierType] == nil then
            data[soldierType] = {}
        end
        table.insert(data[soldierType], allInfos[i])
    end

    -------------------------------------------------------------

    return data
end

function BarrackRecruitPanel:onUpdateBuildingInfo()
    self:onShowHandler()
end

--show时候 触发的事件
function BarrackRecruitPanel:onShowHandler()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    --TODO 有数据的更新再渲染
    if buildingInfo == nil then
        return
    end
    self._labTips:stopAllActions()
    self._labTips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5),cc.FadeIn:create(0.5))))

    local buildingType = buildingInfo.buildingType

    if buildingType ~= self._curBuildingType then --打开不同的建筑了，先把面板都隐藏掉
        self.listView1:setVisible(false)
        self._conscriptionPanel:setVisible(false)
        self._soldierInfoPanel:setVisible(false)
    end

    self.listView1:setVisible(buildingType == BuildingTypeConfig.MAKE)


    if self:isModuleRunAction() then
        return
    end
    
    --if self._listView then
    --    self._listView:jumpToTop()
    --end
    
    --local ids = buildingProxy:getCanProductIdList(BuildingTypeConfig.BARRACK)
    
    
    --self._oldBuildingDetailInfos = nil
    self:initAllArmProduct()
    
    if buildingType == BuildingTypeConfig.MAKE then
        return
    end


    local taskProxy = self:getProxy(GameProxys.Task)
    self.taskInfo = taskProxy:getMainTaskListByType(1)
    
    self._guideQi:setTouchEnabled(guideValue == BarrackRecruitPanel.Type_Qi)
    --self._guideDao:setTouchEnabled(guideValue == BarrackRecruitPanel.Type_Dao)

    self._guideNum = self:getGuideValue()
    self:setGuideValue(nil)    
    
    --恢复上次突出的样子
    local tmp = self._lastData[buildingType]
    local soldierType = 1
    local soldierLevel= 1
    if tmp then
        soldierType = tmp.type
        soldierLevel= tmp.lvl
    else--保存的数据为空的时候说明是第一次就进入该界面(校场默认品级修正为2，没有1、6级)
        if buildingType == BuildingTypeConfig.REFORM then
            soldierLevel= 2
        end
    end
    -- 选兵
    self:selectedSoldier(soldierType)
    -- 选阶
    local data = {}
    data.tag = soldierLevel
    self:selectedSoldierLevel(data)
    -- 任务跳转操作
    if self.taskInfo then
        if self.taskInfo.conf.reaches == BarrackRecruitPanel.NAME and taskProxy:getBarrackRecruitGuide() ~= nil then
            local markControl = StringUtils:jsonDecode(self.taskInfo.conf.markControl) 
            
            local soldierType = markControl[1]
            local soldierLevel= markControl[2]
            -- 选兵
            self:selectedSoldier(soldierType)
            -- 选阶
            local data = {}
            data.tag = soldierLevel
            self:selectedSoldierLevel(data)
        end
    end
    taskProxy:setBarrackRecruitGuide(nil)
end

function BarrackRecruitPanel:onHideHandler()
    self._guideNum = nil
end

function BarrackRecruitPanel:onAfterActionHandler()
    self:onShowHandler()
end

--function BarrackRecruitPanel:renderItem(itemPanel, info, index)
--    for i=1,2 do
--        local panel = itemPanel:getChildByName("Panel"..i)
--        panel:setVisible(info[i] ~= nil)
--        if info[i] ~= nil then
--            self:drawItem(info[i], panel)
--            self["itemPanel" .. (index*2+i)] = panel
--            self["itemPanel" .. (index*2+i) .. "taskIcon"] = index
--            self["itemPanel" .. (index*2+i) .. "index"] = i
--            -- if self.taskInfo ~= nil and self.taskInfo.conf ~= nil then
--            --     local config = self.taskInfo.conf
--            --     if config.reaches == self.NAME and self.taskIcon == nil then
--                    -- print("itemPanel" .. (index*2+i) .. "index", i, info[i].name, info[i].ID)
--            --         ComponentUtils:renderTaskIcon(self, nil, self.listView2, self._curBuildingType)
--            --     end
--            -- end
--        end
--    end
--end
--
--function BarrackRecruitPanel:drawItem(info, item)
--    local name = item:getChildByName("nameLab")
--    local numlab = item:getChildByName("numLab")
--    local iconImg = item:getChildByName("iconImg")
--    local numBg = item:getChildByName("Image_40")
--    local colorImg = item:getChildByName("colorImg")
--
--
--    local buildingProxy = self:getProxy(GameProxys.Building)
--    local buildingInfo = buildingProxy:getCurBuildingInfo()
--    local buildingType = buildingInfo.buildingType
--    
--    local flag, dec =  buildingProxy:getProductConditionResult(buildingType,buildingInfo.index, info)
--    local nameTxt = flag and info.name or dec
--    numlab:setVisible(flag)
--    numBg:setVisible(flag)
--
--    local tmp = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,info.ID)
--    local color = flag and ColorUtils:getColorByQuality(tmp.color) or cc.c3b(255, 0, 0)
--    name:setString(nameTxt)
--    name:setColor(color)
--
--    numlab:setColor(color)
--    local num = 0
--    local roleProxy = self:getProxy(GameProxys.Role)
--    if buildingType == BuildingTypeConfig.REFORM then 
--        local tankneed = StringUtils:jsonDecode(info.tankneed)
--        local id = tankneed[1][1]
--        num = roleProxy:getRolePowerValue(GamePowerConfig.Soldier, id)
--    else
--        num = roleProxy:getRolePowerValue(GamePowerConfig.Soldier, info.ID)
--    end
--    numlab:setString(num)
--
--    local url = string.format("images/barrack/%d.png", tmp.gradation)
--    TextureManager:updateImageView(colorImg, url)
--
--    -- local data = {}
--    -- data.power = GamePowerConfig.SoldierBarrack
--    -- data.typeid = info.ID
--    -- data.num = 1
--    TextureManager:onUpdateSoldierImg(iconImg,info.ID)
--    iconImg:setScale(0.8)
--
--    -- local icon = iconImg.icon
--    -- if icon == nil then
--    --     icon = UIIcon.new(iconImg, data, false, self)
--    --     iconImg.icon = icon
--    -- else
--    --     icon:updateData(data)
--    -- end
--    info.buildingType = buildingType
--
--
--    info.isConditionResult = flag
--    item.info = info 
--
--    self:addTouchEventListener(item, self.onAddArmUseTouch)
--
--end

function BarrackRecruitPanel:renderItemPanel(itemPanel, info)

    if itemPanel == nil then
        return
    end

    self._itemPanelMap[info.ID] = itemPanel
    
    itemPanel:setVisible(true)
    local useBtn = itemPanel:getChildByName("useBtn")
    local numTxt = itemPanel:getChildByName("numTxt")
    local numTxt_0 = itemPanel:getChildByName("numTxt_0")
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local infoTxt = itemPanel:getChildByName("infoTxt")
    local clockImg = itemPanel:getChildByName("clockImg")
    local container = itemPanel:getChildByName("container")
    local lockedTxt = itemPanel:getChildByName("lockedTxt")
    local tipImg = itemPanel:getChildByName("tipImg")
    
    nameTxt:setString(info.name)
    lockedTxt:setVisible(false)

    -- 感叹号坐标
    local size = nameTxt:getContentSize()
    local x = nameTxt:getPositionX()
    tipImg:setPositionX(x + size.width + 20)

    local TankPlantLv = info.TankPlantLv
    local commanderLv = info.commanderLv
    local timeneed = info.timeneed
    
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType
    
    local flag, dec =  buildingProxy:getProductConditionResult(
        buildingType,buildingInfo.index, info)
    if flag == true then
        clockImg:setVisible(true)
        infoTxt:setColor(ColorUtils.wordYellowColor03)
        --需要通过加速百分比，算出实际的所需时间
        -- local speedRate = buildingInfo.speedRate
        -- timeneed = TimeUtils:getTimeBySpeedRate(timeneed, speedRate)
        local speedRate, timeneed = buildingProxy:getProductionSpeedRate(buildingType, buildingInfo.index, nil)
        
        local timeStr = TimeUtils:getStandardFormatTimeString6(timeneed)
        infoTxt:setString(timeStr)
        useBtn:setVisible(true)
    else
        -- 使用条件不足
        clockImg:setVisible(false)
        useBtn:setVisible(false)
        lockedTxt:setVisible(true)
        -- infoTxt:setColor(ColorUtils.wordRedColor)
        lockedTxt:setString(dec)
        infoTxt:setString("")
    end
    
    local buildingDetailInfo = buildingProxy:getCurBuildingDetailInfo(info.ID)
    local num = 0
--    if buildingDetailInfo ~= nil then
--        num = buildingDetailInfo.num
--    end
    local roleProxy = self:getProxy(GameProxys.Role)
    --拿背包的数量
    if buildingType == BuildingTypeConfig.MAKE then
        num = roleProxy:getRolePowerValue(GamePowerConfig.Item, info.ID)
        local tmp = ConfigDataManager:getConfigById(ConfigData.ItemConfig,info.ID)
        nameTxt:setColor(ColorUtils:getColorByQuality(tmp.color))
    elseif buildingType == BuildingTypeConfig.BARRACK then --兵营
        num = roleProxy:getRolePowerValue(GamePowerConfig.Soldier, info.ID)
        local tmp = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,info.ID)
        nameTxt:setColor(ColorUtils:getColorByQuality(tmp.color))
    elseif buildingType == BuildingTypeConfig.REFORM then   --校场
        local tankneed = StringUtils:jsonDecode(info.tankneed)
        local id = tankneed[1][1]
        num = roleProxy:getRolePowerValue(GamePowerConfig.Soldier, id)
        local tmp = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,info.ID)
        nameTxt:setColor(ColorUtils:getColorByQuality(tmp.color))
    end
    
    local strKey = 824
    if buildingType == BuildingTypeConfig.REFORM then --改造车间
        strKey = 825
    end
    
    -- local numStr = string.format(self:getTextWord(strKey), num)
    -- numTxt:setString(numStr)
    numTxt:setString(num)
    numTxt_0:setString(self:getTextWord(strKey))

    
    useBtn:setTitleText(self:getTextWord(8004))
    
    local iconID = info.ID

    local power = GamePowerConfig.SoldierBarrack
    if buildingType == BuildingTypeConfig.MAKE then --制作车间（工匠坊）
        -- power = GamePowerConfig.Item
        -- print("工匠坊···info.ID="..info.ID)
        power = GamePowerConfig.Other
        local conf = ConfigDataManager:getConfigById(ConfigData.ItemMadeConfig, info.ID)
        iconID = conf.icon
        useBtn:setTitleText(self:getTextWord(8005))
    end

    local data = {}
    data.power = power
    data.typeid = iconID
    data.num = 1
    if buildingType == BuildingTypeConfig.MAKE then
        data.name = info.name
        data.dec  = self._itemConfig[info.ID].info
    end

    local icon = container.icon
    if icon == nil then
        icon = UIIcon.new(container, data, false, self)
        container.icon = icon
    else
        icon:updateData(data)
    end
    
    info.isConditionResult = flag
    info.buildingType = buildingType
    itemPanel.info = info
    useBtn.info = info
    
    if itemPanel.isAddEvent == true then
        return
    end
    itemPanel.isAddEvent = true
    
    self:addTouchEventListener(useBtn, self.onAddArmUseTouch)
    self:addTouchEventListener(itemPanel, self.onAddArmUseTouch)
    
    local index = self.listView1:getIndex(itemPanel)
    -- self["itemPanel" .. (index + 1)] = itemPanel -- useBtn
end

function BarrackRecruitPanel:onAddArmUseTouch(sender, value)
    local info = sender.info
    
    if info.isConditionResult ~= true then  --未解锁？？
        --print("未解锁？？.......................................ID",info.ID,info.buildingType)
        if info.buildingType ~= BuildingTypeConfig.MAKE then
            --print("未解锁？？.....................................buildingType",info.buildingType)
            self:showSoldierInfo() 
        end
        return
    end
    
    local data = {}
    data.info = info
    if value then
        data.minValue = value
    end
    local panel = self:getPanel(BarrackProductPanel.NAME)
    panel:show(data)
    
end

-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------新版代码---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------轮盘操作start-----------------------------------------

function BarrackRecruitPanel:disToAngle(dis)
    local width = self._rootSize.width / 2
    local angle = dis / width * self._unitAngle
    --print("angle===============>", angle)
    return angle
end

function BarrackRecruitPanel:setAngle(angle)
    self._angle = angle or 0
    --print("self._angle===========>",self._angle)
end


function BarrackRecruitPanel:getAngle()
    return self._angle or 0
end


function BarrackRecruitPanel:setRunToAngle(angle)
    self._runToAngle = angle or 0
    --print("self._angle===========>",self._angle)
end

function BarrackRecruitPanel:getRunToAngle()
    return self._runToAngle or 0
end

function BarrackRecruitPanel:updatePosition()
    local disY = self._rootSize.height / 8;
    local disX = self._rootSize.width / 3;
    for i = 1, self.MAX_COUNT_MOVE_OBJ do
        local x = self._moveCenterX + disX * math.sin(i * self._unitAngle + self:getAngle() + GlobalConfig.Offset_Angel)
        local y = self._moveCenterY - disY * math.cos(i * self._unitAngle + self:getAngle() + GlobalConfig.Offset_Angel)

        self._soldierArr[i]:setPosition(x, y);
        self._soldierArr[i]:setLocalZOrder(- math.ceil(y));

        self._soldierArr[i]:setOpacity(GlobalConfig.Opacity_Basic + GlobalConfig.Opacity_Factor * math.cos(i * self._unitAngle + self:getAngle()));
        self._soldierArr[i]:setScale(GlobalConfig.Scale_Basic + GlobalConfig.Scale_Factor * math.cos(i * self._unitAngle + self:getAngle()));
        --print("==================>", i, math.ceil(x), math.ceil(y), 192 + 63 * math.cos(i * self._unitAngle + self:getAngle()), 0.75 + 0.25 * math.cos(i * self._unitAngle + self:getAngle()))
    end
end


function BarrackRecruitPanel:initTouchEvent()

    self._PI = 3.1415926535898
    self._unitAngle = 2 * self._PI / self.MAX_COUNT_MOVE_OBJ
    self._rootSize = cc.size(GlobalConfig.Module_Size[1], GlobalConfig.Module_Size[2])    
    self._moveCenterX = GlobalConfig.Module_Center[1]
    self._moveCenterY = GlobalConfig.Module_Center[2]
    self:setAngle( self._unitAngle * 3)
    self:updatePosition()

    local function onTouchPanelHandler(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self._startMove = os.clock()
            self._startPos = sender:getTouchBeganPosition()

        elseif eventType == ccui.TouchEventType.moved then
--            if self._startMove ==nil or math.abs( os.clock() - self._startMove) < 0.03 then
--                return
--            end
--            self._startMove = os.clock()
            self:handlerMoveTouch(sender)
             local btnCommon = self:getChildByName("ConscriptionPanel/TouchPanel/btnCommon")
             btnCommon:setVisible(false)

        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            self._endMove = os.clock()
            self._endPos = sender:getTouchEndPosition()
            self._oldPosition = nil
            self:handlerEndTouch(sender)        
        end
    end
    self._TouchPanel:setTouchEnabled(true)
    self._TouchPanel:addTouchEventListener(onTouchPanelHandler)
    self:addTouchEventListener(self._btnRecruit, self.onSureTouch)
end


--监听手指滑动的过程
--四个移动组件通过偏移值计算并设置往下一个点的向量方向计算偏移位置(跟随移动)
function BarrackRecruitPanel:handlerMoveTouch(sender)
    local endPos = sender:getTouchMovePosition()
    if self._oldPosition ~= nil then
        --print("pos==>",endPos.x , self._oldPosition.x)
        local angle = self:disToAngle(endPos.x - self._oldPosition.x)
        self:setAngle(self:getAngle() + angle)
        self:updatePosition();
    end
    self._oldPosition = endPos
end

--监听手指离开时偏移值（四个移动组件复位）
function BarrackRecruitPanel:handlerEndTouch(pos)
    if math.abs( self._startMove - self._endMove) < 0.3 then
        if (self._endPos.x - self._startPos.x) <= -10  then
            self._currentSelectedIndex = self._currentSelectedIndex + 1       
        elseif (self._endPos.x - self._startPos.x) >= 10  then
            self._currentSelectedIndex = self._currentSelectedIndex - 1
        else            
            if self._endPos.x < 200 then 
                self._currentSelectedIndex = self._currentSelectedIndex - 1
            elseif self._endPos.x > 440 then
                self._currentSelectedIndex = self._currentSelectedIndex + 1
            else
                -- 不变
            end
        end
        
        self._currentSelectedIndex = self._currentSelectedIndex % self.MAX_COUNT_MOVE_OBJ       
        if self._currentSelectedIndex == 0 then
            self._currentSelectedIndex = 4
        end    
    else
        local angle = self:getAngle()
        if angle < 0 then
            self._currentSelectedIndex = math.floor((angle - self._unitAngle * 0.5) / -self._unitAngle) % self.MAX_COUNT_MOVE_OBJ
            if self._currentSelectedIndex <= 0 then
                self._currentSelectedIndex = self.MAX_COUNT_MOVE_OBJ - self._currentSelectedIndex
            end
        end
    end

    self:selectedSoldier(self._currentSelectedIndex) 
end

function BarrackRecruitPanel:selectedSoldier(index)
    self._currentSelectedIndex = index
    self:setAngle(- self._unitAngle * self._currentSelectedIndex)
    self:updatePosition()
    self:setSelectedSoldierLevelIcon()
    self:saveData()
    self:alignResourceIcon()
end

function BarrackRecruitPanel:updateToAngle(dt)
    local updateOffset = self._unitAngle / 30
    local isFinish = false
    if self:getAngle() > self:getRunToAngle() then
        self:setAngle(self:getAngle() - updateOffset)        
        isFinish = self:getAngle() < self:getRunToAngle()
    else
        self:setAngle(self:getAngle() + updateOffset)
        isFinish = self:getAngle() > self:getRunToAngle()
    end

    self:updatePosition()

    if isFinish == true then
        print("==============>isFinish")
        self:setAngle(self:getRunToAngle() % (2 * self._PI))
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._idSchedule)

        self:setSelectedSoldierLevelIcon()
        
        
    end
end



-----------------------------------轮盘操作end-----------------------------------------

--选择兵种的品级
function BarrackRecruitPanel:selectedSoldierLevel(sender)
    for i = 1,6 do
        if sender.tag == i then--选中品级显示对应高亮图标
            self._selectedLevelIconArr[i]:setVisible(true)
            self:changeModel(i)
        else
            self._selectedLevelIconArr[i]:setVisible(false)
        end
        
    end
    self:saveData()

    self:setBtnTipImg(sender.tag)

    self:alignResourceIcon()
end

--对齐资源图片和lable todo 纵向对齐
function BarrackRecruitPanel:alignResourceIcon()

    --对齐资源icon
        --资源需求
    local imgNodes = {}
    local txtNodes = {}
    local number = 0
    for i = 1,7 do
        if self._needTxtImageMap[i]:isVisible() then
            number = number + 1
            table.insert(imgNodes,self._needTxtImageMap[i])
            table.insert(txtNodes,self._needTxtMap[i])
        end
    end

    imgNodes[1]:setPositionY(3)
    txtNodes[1]:setPositionY(3)

    NodeUtils:alignNodeU2DForAbsLength(imgNodes,32)
    NodeUtils:alignNodeU2DForAbsLength(txtNodes,32)
end


--显示选中兵种的对应品级图标
function BarrackRecruitPanel:setSelectedSoldierLevelIcon()
    for i = 1,6 do
        if self._soldierArr[self._currentSelectedIndex].tag == i then--选中品级显示对应高亮图标
            self._selectedLevelIconArr[i]:setVisible(true)

            self:setBtnTipImg(i)
        else
            self._selectedLevelIconArr[i]:setVisible(false)
        end
        
    end
    self:refleshView()
   
end

--更改当前选中兵种品级模型
function BarrackRecruitPanel:changeModel(level)
    self._soldierArr[self._currentSelectedIndex].tag = level
    --写死8级兵
    if level == 6 then
        level = 8
    end
    TextureManager:updateImageViewFile(self._soldierModelArr[self._currentSelectedIndex], "bg/barrack/" .. self.SOLDIIER_PATH[self._currentSelectedIndex] .. level .. ".png")
    self:refleshView()

end

function BarrackRecruitPanel:addMoveBtn()
    if self._uiMoveBtn == nil then
        local moveBtnContainer = self._conscriptionPanel:getChildByName("moveBtnContainer")
        local args = {}
        args["moveCallobj"] = self
        args["moveCallback"] = self.onMoveBtnCallback
        args["count"] = 1
        self._uiMoveBtn = UIMoveBtn.new(moveBtnContainer, args)
    end
    
--    self._uiMoveBtn:setEnterCount(100)
end

function BarrackRecruitPanel:onMoveBtnCallback(count)
    self:setAllMinNumCount(count)
end

function BarrackRecruitPanel:setAllMinNumCount(count)
    if self._needTxtMap == nil then
        return
    end
--    
    if count == 0 or self._minNum == 0 then  --默认1 这时确定按钮 置灰
        NodeUtils:setEnable(self._btnRecruit, false)
        count = 1
    else
--        NodeUtils:setEnable(self._btnRecruit, true)
    end
--    
    self._curSelectCount = count
--    
    for key, needTxt in pairs(self._needTxtMap) do
        if needTxt.info then
    	    local info = needTxt.info
            if info.num > 0 then
                local str = StringUtils:formatNumberByK(count * info.num, needTxt.typeid)
                needTxt:setString(str)
                needTxt:setVisible(true)
                self._needTxtImageMap[key]:setVisible(true)
                if info.isEnought then
                    needTxt:setColor(ColorUtils.commonColor.c3bGreen)
                else
                    needTxt:setColor(ColorUtils.commonColor.c3bRed)
                end
                if info.power == GamePowerConfig.Item then
                    local url = string.format("images/barrack/item_%s.png",info.typeid)
                    TextureManager:updateImageView(self._needTxtImageMap[key],url)
                elseif info.power == GamePowerConfig.Soldier then
                    local url = string.format("images/barrack/Icon_%d_%d.png",self:getTypeByID(info.typeid),self._soldierArr[self._currentSelectedIndex].tag - 1)
                    TextureManager:updateImageView(self._needTxtImageMap[key],url)
                elseif info.power == GamePowerConfig.Resource then
                    local url = string.format("images/newGui1/IconRes%d.png",PlayerPowerDefine:getResSmallIcon(info.typeid))
                    TextureManager:updateImageView(self._needTxtImageMap[key],url)
                end
            else
                needTxt:setVisible(false)
                self._needTxtImageMap[key]:setVisible(false)
            end
        else
            needTxt:setString(0)
        end
    end
    

    --需要通过加速百分比，算出实际的所需时间
    local data = self:getCurrentSoldierData()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    -- local speedRate = buildingInfo.speedRate
    local speedRate, timeneed = buildingProxy:getProductionSpeedRate(buildingInfo.buildingType, buildingInfo.index, nil)
    local timeneed = TimeUtils:getTimeBySpeedRate(data.timeneed, speedRate)
    timeneed = timeneed * count

    local timeTxt = self:getChildByName("ConscriptionPanel/labTimeTxt")
    local timeStr = TimeUtils:getStandardFormatTimeString6(timeneed)
    timeTxt:setString(timeStr)
    
    local numTxt = self:getChildByName("ConscriptionPanel/labNumTxt")
    numTxt:setString(count)

    --8208 暂时注释
    -- local buildingProxy = self:getProxy(GameProxys.Building)
    -- local buildingInfo = buildingProxy:getCurBuildingInfo()
    -- local buildingType = buildingInfo.buildingType
    -- if buildingType == BuildingTypeConfig.REFORM then--校场
    --      self._needTxtMap[1]:setString(count)
    --      self._needTxtMap[1]:setVisible(true)
    --      self._needTxtImageMap[1]:setVisible(true)
    -- end

    self._curSelectNum = count
end

--初始化界面数据
function BarrackRecruitPanel:initViewData()
    --self._soldierData    
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType
    -----
    --NodeUtils:adaptive(listView)
    for i = 1,self.MAX_COUNT_MOVE_OBJ do
        if buildingType == BuildingTypeConfig.REFORM then--校场没有一阶
            self._soldierArr[i].tag = 2
            TextureManager:updateImageViewFile(self._soldierModelArr[i], "bg/barrack/" .. self.SOLDIIER_PATH[i] .. "2.png")
            self._levelBtnArr[1]:setVisible(false)
            self._levelBtnArr[6]:setVisible(false)
        elseif buildingType == BuildingTypeConfig.BARRACK then
            self._soldierArr[i].tag = 1
            TextureManager:updateImageViewFile(self._soldierModelArr[i], "bg/barrack/" .. self.SOLDIIER_PATH[i] .. "1.png")
            self._levelBtnArr[1]:setVisible(true)
            self._levelBtnArr[6]:setVisible(true)
        end
--        self._soldierArr[i]:setPosition(self._moveObjPosArr[i])
--        self._moveObjCurrentPosArr[i] = cc.p(self._soldierArr[i]:getPosition())
--        self._soldierArr[i]:setScale(0.6)
--        self._soldierArr[i]:setOpacity(200)
    end

--    self._soldierArr[1]:setLocalZOrder(10)
--    self._soldierArr[1]:setScale(1)
--    self._soldierArr[1]:setOpacity(255)

    self:setAngle( - self._unitAngle)
    self:updatePosition()

    for i = 1,6 do
        self._selectedLevelIconArr[i]:setVisible(false)
        self._levelBtnArr[i].tag = i
    end
    if buildingType == BuildingTypeConfig.REFORM then--校场没有一阶
        self._selectedLevelIconArr[2]:setVisible(true)
        
        self._soldierInfoPanel:getChildByName("labCount"):setVisible(false)
        self._soldierInfoPanel:getChildByName("labCountTxt"):setVisible(false)
    elseif buildingType == BuildingTypeConfig.BARRACK then
        self._selectedLevelIconArr[1]:setVisible(true)
        
        self._soldierInfoPanel:getChildByName("labCount"):setVisible(true)
        self._soldierInfoPanel:getChildByName("labCountTxt"):setVisible(true)
    end
    --self._currentSelectedIndex = 1 
---------------------------------------------------
    --self:setResLabelData()
    self:addMoveBtn()
    ------------------------------------------------------
    --初始士兵数据
    self:refleshView()
    -------------

    ----------------------------------------------------------------------------
    --设置
    --
end

function BarrackRecruitPanel:refleshMoveBtn()

    if self._guideNum ~= nil then
        self._minNum = self._guideNum
    else
        local roleProxy = self:getProxy(GameProxys.Role)
        local tmpNum = 20000000
        for _, data in pairs(self._resInfos) do
            local haveNum = roleProxy:getRolePowerValue(data.power, data.typeid)
            local minNum = math.floor(haveNum / data.num)
            if minNum < tmpNum then
                tmpNum = minNum
            end
        end
        self._minNum = tmpNum

        if self._minNum > self.MAX_PRODUCT_NUM then
            self._minNum = self.MAX_PRODUCT_NUM
        end
    end


    self._uiMoveBtn:setEnterCount(self._minNum, false)
end

function BarrackRecruitPanel:getCurrentSoldierData()
    return self:getSoldierDataByIndex(self._currentSelectedIndex)
end

function BarrackRecruitPanel:getSoldierDataByIndex(index)
    local lvl = self._soldierArr[index].tag
    
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType
    
    if buildingType == BuildingTypeConfig.REFORM then--校场没有一阶(所取的数据全部取前一个)
        lvl = lvl - 1
    end

    return self._soldierData[index][lvl]
end

function BarrackRecruitPanel:refleshView()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType


    local roleProxy = self:getProxy(GameProxys.Role)
    local info = self:getCurrentSoldierData()
    local labName = self._soldierInfoPanel:getChildByName("labNameTxt")--名字
    labName:setString(info.name)
    local labNum = self._soldierInfoPanel:getChildByName("labCountTxt")--拥有数量
    local num = roleProxy:getRolePowerValue(GamePowerConfig.Soldier, info.ID)
    labNum:setString(num)
    local imgLevel = self._soldierInfoPanel:getChildByName("imgLevel")--品级

    local tag = self._soldierArr[self._currentSelectedIndex].tag
    --地阶 8级 写死
    if self._soldierArr[self._currentSelectedIndex].tag == 6 then
        TextureManager:updateImageView(imgLevel, "images/newGui2/Icon_level" .. 8 .. ".png")
    else
        TextureManager:updateImageView(imgLevel, "images/newGui2/Icon_level" .. tag .. ".png")
    end
    --labLevel:setString(self.SOLDIIER_LEVEL[self._soldierArr[self._currentSelectedIndex].tag]) 
    --士兵TypeIcon
    local imgType = self._soldierInfoPanel:getChildByName("imgType")--士兵TypeIcon
    TextureManager:updateImageView(imgType, "images/barrack/IconBingYing" .. self:getTypeByID(info.ID) .. ".png")

    local imgNum = nil
    local data = nil
    for i = 2,6 do
        imgNum = self._conscriptionPanel:getChildByName("bg_" .. i)--拥有数量
        if buildingType == BuildingTypeConfig.REFORM then--校场没有一阶
            data = self._soldierData[self._currentSelectedIndex][i - 1]
            imgNum:setVisible(true)
            imgNum:getChildByName("labNumTxt"):setString(roleProxy:getRolePowerValue(GamePowerConfig.Soldier, self:getLastCorpsByID(data.ID)))
            self._btnRecruit:setTitleText(TextWords:getTextWord(8102))
        elseif buildingType == BuildingTypeConfig.BARRACK then
            imgNum:setVisible(false)
            self._btnRecruit:setTitleText(TextWords:getTextWord(802))
        end
    end
    
    --8028 临时注释
    -- if buildingType == BuildingTypeConfig.REFORM then--校场没有一阶
    --     TextureManager:updateImageView(self._needTxtImageMap[1], "images/barrack/Icon_" .. self:getTypeByID(info.ID) .. "_" .. self._soldierArr[self._currentSelectedIndex].tag - 1 .. ".png")
    -- elseif buildingType == BuildingTypeConfig.BARRACK then
    --     TextureManager:updateImageView(self._needTxtImageMap[1], "images/newGui1/IconRes1.png")
    -- end

    ---------------------------士兵属性
    local conf = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,info.ID)
    local labHP = self._conscriptionPanel:getChildByName("labHPTxt")--HP
    local labATK = self._conscriptionPanel:getChildByName("labATKTxt")--ATK
    local labWeight = self._conscriptionPanel:getChildByName("labWeightTxt")--负重
    labHP:setString(conf.hpmax)
    labATK:setString(conf.atk)
    labWeight:setString(conf.load)
    
    NodeUtils:setEnable(self._btnRecruit, true)--默认为可点击

    self:setResLabelData()
    self:refleshMoveBtn()
    self:setAllMinNumCount(self._curSelectCount)
    --num = 
    --是否开放
    self:setLockStatus()
    
    self:setTaskMark()

    local btnCommon = self:getChildByName("ConscriptionPanel/TouchPanel/btnCommon")
    btnCommon:setVisible(true)
    
end

function BarrackRecruitPanel:setLockStatus()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType
    
    local flag = false
    local dec = ""
    
    for i = 1,6 do
        self._selectedLevelLockArr[i]:setVisible(true)
        self._levelBtnArr[i]:setVisible(true)
    end

    
    if buildingType == BuildingTypeConfig.REFORM then--校场不显示一阶和地阶
        for i = 1,6 do
            if i == 1 then
                self._levelBtnArr[i]:setVisible(false)
                NodeUtils:setEnable(self._levelBtnArr[i], false)
                self._selectedLevelLockArr[i]:setVisible(false)
            else
                flag, dec =  buildingProxy:getProductConditionResult(buildingType,buildingInfo.index, self._soldierData[self._currentSelectedIndex][i - 1])
                if flag then--已经解锁(隐藏锁图标)
                    self._selectedLevelLockArr[i]:setVisible(false)
                end  
            end
        end
    elseif buildingType == BuildingTypeConfig.BARRACK then
        for i = 1,6 do
            if i == 1 then
                self._levelBtnArr[i]:setVisible(true)
                NodeUtils:setEnable(self._levelBtnArr[i], true)
            end
            flag, dec =  buildingProxy:getProductConditionResult(buildingType,buildingInfo.index, self._soldierData[self._currentSelectedIndex][i])
            if flag then--已经解锁(隐藏锁图标)
                self._selectedLevelLockArr[i]:setVisible(false)
            end  
        end
    end

    ---------------拖动对象上是否解锁
    for i = 1,self.MAX_COUNT_MOVE_OBJ do        
        self._soldierLockArr[i]:setVisible(false)
        self._soldierArr[i]:getChildByName("labTips"):setVisible(false)
        self._soldierArr[i]:getChildByName("imgLockBg"):setVisible(false)
        self._soldierArr[i]:getChildByName("imgZhanLi"):setVisible(false)
        self._soldierArr[i]:getChildByName("artZhanLi"):setVisible(false)
        NodeUtils:setGray( self._soldierModelArr[i], true)
    end

    -- 设置战力
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local totalFight, weight, exterLen = soldierProxy:getFightAndWeightByItem({typeid = self:getCurrentSoldierData().ID})    
    self._soldierArr[self._currentSelectedIndex]:getChildByName("imgZhanLi"):setVisible(true)
    self._soldierArr[self._currentSelectedIndex]:getChildByName("artZhanLi"):setVisible(true)

    -- 战力四舍五入取整(艺术字没小数点)
    totalFight = math.floor(totalFight + 0.5)
    self._soldierArr[self._currentSelectedIndex]:getChildByName("artZhanLi"):setString(totalFight) 

    --当前选中的兵种
    local flag, dec =  buildingProxy:getProductConditionResult(buildingType,buildingInfo.index, self:getCurrentSoldierData())
    if flag then--已经解锁(隐藏锁图标)
        self._soldierLockArr[self._currentSelectedIndex]:setVisible(false)
        NodeUtils:setEnable(self._btnRecruit, true)
        NodeUtils:setGray( self._soldierModelArr[self._currentSelectedIndex], false)
    else
        self._soldierLockArr[self._currentSelectedIndex]:setVisible(true)
        self._soldierArr[self._currentSelectedIndex]:getChildByName("labTips"):setVisible(true)
        self._soldierArr[self._currentSelectedIndex]:getChildByName("labTips"):setString(dec)
        self._soldierArr[self._currentSelectedIndex]:getChildByName("imgLockBg"):setVisible(true)         
        NodeUtils:setEnable(self._btnRecruit, false)
    end

    if self._minNum == 0 then--资源不够生产一个兵
        NodeUtils:setEnable(self._btnRecruit, false)
    end
            --self._soldierArr[i]:getChildByName("labTips"):setString(dec)
            
end

function BarrackRecruitPanel:setResLabelData()
    local info = self:getCurrentSoldierData()
    local need = StringUtils:jsonDecode(info.need)
    local itemneed = StringUtils:jsonDecode(info.itemneed)
    local tankneed = StringUtils:jsonDecode(info.tankneed or "[]")
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType
    local roleProxy = self:getProxy(GameProxys.Role)
    
    self._resInfos = {}
    self._tipsTxtInfos = {}
    for _, v in pairs(need) do
        local info = {}
        info.power = GamePowerConfig.Resource
        info.typeid = v[1]
        info.num = v[2]
        table.insert(self._resInfos, info)
    end
    for _, v in pairs(itemneed) do
        local info = {}
        info.power = v[1] --v[1]=GamePowerConfig.Item=401
        info.typeid = v[2]
        info.num = v[3]      
        table.insert(self._resInfos, info)
    end
    
    for _, v in pairs(tankneed) do
        local info = {}
        info.power = GamePowerConfig.Soldier
        info.typeid = v[1]
        info.num = v[2]
        table.insert(self._resInfos, info)
    end
    
    
    --local function getDataByType(resType)
    --    for _,data in pairs(self._resInfos) do
    --        if (resType + 200) == data.typeid then
    --            return data
    --        end
    --    end
    --    return nil
    --end

    --找是否需要银两
    local function isFindTael()
        for key,val in pairs(self._resInfos) do
            if val.typeid == PlayerPowerDefine.POWER_tael then
                return true
            end
        end
        return false
    end


    table.sort(self._resInfos,function(a,b)
        return a.typeid < b.typeid
    end)

    --把兵种置前 校场
    local soldierKey = nil
    for key,val in pairs(self._resInfos) do
        if val.power == GamePowerConfig.Soldier then
            soldierKey = key
            break
        end
    end
    if soldierKey then
        local soldier = table.remove(self._resInfos,soldierKey)
        table.insert(self._resInfos,1,soldier)
    end

    for i = 1,7 do
        --local info = getDataByType(i)
        local info = self._resInfos[i]
        if info then
            local have = roleProxy:getRolePowerValue(info.power,info.typeid)
            if have >= info.num then
                info.isEnought = true
            else
                info.isEnought = false
            end
            if info.power == GamePowerConfig.Item and not info.isEnought then
                local itemConf = ConfigDataManager:getConfigByPowerAndID(info.power, info.typeid)
                table.insert(self._tipsTxtInfos,string.format(TextWords:getTextWord(894),itemConf.name))
            end

            self._needTxtMap[i].info = info
        else
            self._needTxtMap[i].info = {
                power = -1,
                typeid = -1,
                num = 0
            }
        end
    end
    self._labTips:setString(table.concat(self._tipsTxtInfos," "))
end

function BarrackRecruitPanel:onSureTouch(sender)
    AudioManager:playEffect("yx01")
    --开始生产兵
    local info = self:getCurrentSoldierData()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local curBuildingInfo = buildingProxy:getCurBuildingInfo()
    
    local data = {}
    data.buildingType = curBuildingInfo.buildingType
    data.index = curBuildingInfo.index
    data.typeid = info.ID
    data.num = self._curSelectNum
    
    -- self:dispatchEvent(BarrackEvent.PRODUCTION_REQ, data)
    
    -- self:hide()
    -- local panel = self:getPanel(BarrackPanel.NAME)
    -- panel:changeTabSelectByName(RecruitingPanel.NAME)


    --建筑生产
    local isBuildingCanProduction = buildingProxy:isBuildingCanProduction(data.buildingType, data.index)
    if isBuildingCanProduction == 0 then
        data.isBuildingCanProduction = isBuildingCanProduction
        self:dispatchEvent(BarrackEvent.PRODUCTION_REQ, data)
        
        -- self:hide()
        -- local panel = self:getPanel(BarrackPanel.NAME)
        -- panel:changeTabSelectByName(RecruitingPanel.NAME)
    else
        local msg
        if data.buildingType == BuildingTypeConfig.BARRACK  then --兵营
            msg = nil--TextWords:getTextWord(357)

            local panel = self:getPanel(BarrackTipPanel.NAME)
            panel:show()
        else--校场
            msg = TextWords:getTextWord(358)
        end
        if msg ~= nil then
            self:showSysMessage(msg)
        end
        --TODO 弹错误码 生产队列上限
        -- buildingProxy:errorCodeHandler(AppEvent.NET_M28_C280006, isBuildingCanProduction)

    end

end

function BarrackRecruitPanel:showSoldierInfo(sender)  --显示佣兵属性
    local info = self:getCurrentSoldierData()
    self.view:showSoldierInfo(info.ID)
end

function BarrackRecruitPanel:showCommon(sender)
    local info = self:getCurrentSoldierData()                                                               --获得当前佣兵的数据
    local commentProxy = self:getProxy(GameProxys.Comment)
    print("兵种 的 typeid ".. info.ID)
    commentProxy:toCommentModule(1,info.ID,info.name)
    
end

--刀兵101 骑兵201 枪兵301 弓兵401转换成本地ID1 2 3 4
function BarrackRecruitPanel:getTypeByID(id)
    local soldierType = math.modf(id / 100)
    return soldierType
end

--当前兵种Id减去1可以得到前一j阶兵ID（步兵101 朴刀兵102）
function BarrackRecruitPanel:getLastCorpsByID(currentId)
    if currentId%100 == 8 then
        return currentId - 3    --8级兵用5级兵升
    else
        return currentId - 1
    end
end

--推出前保存上一次的数据
function BarrackRecruitPanel:saveData()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType

    local data = {}
    data.type = self._currentSelectedIndex
    data.lvl = self._soldierArr[self._currentSelectedIndex].tag
    self._lastData[buildingType] = data

    self:setTaskMark()
end


function BarrackRecruitPanel:setTaskMark()
    for i = 1, self.MAX_SOLDIER_LEVEL do
        self._taskMarkArr[i]:setVisible(false)
    end

    if self.taskInfo then
        local buildingProxy = self:getProxy(GameProxys.Building)
        local buildingInfo = buildingProxy:getCurBuildingInfo()
        local buildingType = buildingInfo.buildingType
        
        if self.taskInfo.conf.buildingType == buildingType and self.taskInfo.conf.markControl ~= nil then -- 判空，不是所有任务都有markControl字段
            local markControl = StringUtils:jsonDecode(self.taskInfo.conf.markControl) --
            
            local soldierType = markControl[1]
            local soldierLevel= markControl[2]
            if self._currentSelectedIndex == soldierType then
                self._taskMarkArr[soldierLevel]:setVisible(true)
            end
        end
    end
end


function BarrackRecruitPanel:onShowSoldierTip(sender)
    local curSoldierData = self:getCurrentSoldierData()
    local barrackSoldierTipPanel = self:getPanel(BarrackSoldierTipPanel.NAME)
    barrackSoldierTipPanel:show(curSoldierData.ID)
end

function BarrackRecruitPanel:setBtnTipImg(soldierLevel)
    
    local urlNormal = "images/barrack/btnSkillinfoNormal" .. soldierLevel .. ".png"
    local urlDown = "images/barrack/btnSkillinfoDown" .. soldierLevel .. ".png"
    self._btnSkillInfo:loadTextures(urlNormal, urlDown, "", 1)

    urlNormal = "images/barrack/btnAuarNormal" .. soldierLevel .. ".png"
    urlDown = "images/barrack/btnAuarDown" .. soldierLevel .. ".png"
    self._btnAuar:loadTextures(urlNormal, urlDown, "", 1)
    
    urlNormal = "images/barrack/btnRestrainNormal" .. soldierLevel .. ".png"
    urlDown = "images/barrack/btnRestrainDown" .. soldierLevel .. ".png"
    self._btnRestrain:loadTextures(urlNormal, urlDown, "", 1)

end