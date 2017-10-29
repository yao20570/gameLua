--个人信息建造界面
--FZW 
--2015/11/20
PersonInfoBuildPanel = class("PersonInfoBuildPanel", BasicPanel)  
PersonInfoBuildPanel.NAME = "PersonInfoBuildPanel"

function PersonInfoBuildPanel:ctor(view, panelName)
    PersonInfoBuildPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function PersonInfoBuildPanel:finalize()
    if self._uiAcceleration ~= nil then
        self._uiAcceleration:finalize()
    end
    if self._uiBuildingTip ~= nil then
        self._uiBuildingTip:finalize()
    end
    PersonInfoBuildPanel.super.finalize(self)
    -- self._listview = {}
    -- self._tabData = {}
end

function PersonInfoBuildPanel:initPanel()
    PersonInfoBuildPanel.super.initPanel(self)
    -- self:showSysMessage("initPanel")
    self._listview = {}
    self._tabData = {}
    self._tabDataNew = {}
    self._cmdBuildingLV = 0     -- 官邸等级
    self._autoPanelFlag = true  --true:显示 false：隐藏
    self._money = GlobalConfig.autoBuildPrice           --自动升级道具价格
    self._buildProxy = self:getProxy(GameProxys.Building)

    self._buildSheetConf = ConfigData.BuildSheetConfig
    self._buildResConf = ConfigData.BuildResourceConfig
    self._buildFuncConf = ConfigData.BuildFunctionConfig

    self._topPanel = self:getChildByName("topPanel")
    self._topInfoTxt = self._topPanel:getChildByName("infoTxt")
    self._imgVip = self._topPanel:getChildByName("imgVip")
    self._artVip = self._topPanel:getChildByName("artVip")


--    self._LISTVIEW = self:getChildByName("ListView_1")
--    local item = self._LISTVIEW:getItem(0)
--    item:setVisible(false)

    self._svBuilding = self:getChildByName("svBuilding")
    self._svBuilding:setVisible(false)
    
    self:initConfig()
    self:initAutoBuildPanel(self._autoPanelFlag)
end

function PersonInfoBuildPanel:doLayout()
    self:adaptive()
end

function PersonInfoBuildPanel:adaptive()
    local downWidget = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    --NodeUtils:adaptiveTopPanelAndListView(self._topPanel, self._LISTVIEW, downWidget, upWidget, 6)
    NodeUtils:adaptiveTopPanelAndListView(downWidget, nil, nil, tabsPanel)
    
    NodeUtils:adaptiveTopPanelAndListView(self._topPanel, nil, nil, downWidget)


    NodeUtils:adaptiveListView(self._svBuilding, GlobalConfig.downHeight, self._topPanel, 3)
    self:createScrollViewItemUIForDoLayout(self._svBuilding)
end

function PersonInfoBuildPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    PersonInfoBuildPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function PersonInfoBuildPanel:initConfig()
    -- body
    self._BuildSheetConf = ConfigDataManager:getConfigData(self._buildSheetConf)
    self._BuildOpenConf = ConfigDataManager:getConfigData(ConfigData.BuildOpenConfig)
    
    local Conf = ConfigDataManager:getConfigData(self._buildResConf)
    self._BuildResourceConf = {}
    for k,v in pairs(Conf) do
        local inx = v.type..v.lv
        self._BuildResourceConf[inx] = v
    end

    Conf = ConfigDataManager:getConfigData(self._buildFuncConf)
    self._BuildFunctionConf = {}
    for k,v in pairs(Conf) do
        local inx = v.type..v.lv
        self._BuildFunctionConf[inx] = v
    end

end

function PersonInfoBuildPanel:onShowHandler(info)
    -- body
    -- self:adaptive()
--    if #self._listview > 0 or #self._tabData > 0 then
--        local tabData,tabDataNew = self:getBuildingData()
--        print("#tabData="..#tabData..",#self._tabData="..#self._tabData)
--        if #tabData == #self._tabData then
--            self._LISTVIEW:jumpToTop()
--
--
--            --更新自动升级建筑开关(由于购买建筑位触发自动升级)

--            self:update()
--            return
--        end
--    end

    if self:isModuleRunAction() then
        return
    end
            local buildingProxy = self:getProxy(GameProxys.Building)
            local type = buildingProxy:getAutoBuildState()
--            if type == 1 then
--                -- print("更新自动升级建筑开关 swithc = "..type)
--                self._type = type
--                self:updateSwitch(type)
--            end
            
    self:updateAutoBuildPanel(type)
    -- 每次打开界面刷新
    self:onReflashAll()
    self:onTopPanelUpdate()
end

function PersonInfoBuildPanel:onTopPanelUpdate()
    local roleProxy = self:getProxy(GameProxys.Role)
    local vipLV = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    local maxNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildsize) or 0

    local buildingProxy = self:getProxy(GameProxys.Building)
    local curNum, _, _ = buildingProxy:buildingLvNum()

    self._artVip:setString(vipLV)

    local infoStr = { 
                        { 
                            -- { "VIP" .. vipLV, 20, "#FFEE00" }, 
                            { self:getTextWord(50200), 18, ColorUtils.commonColor.FuBiaoTi }, 
                            { curNum, 18, ColorUtils.commonColor.Green }, 
                            { "/" .. maxNum, 18, ColorUtils.commonColor.White } 
                        }, 
                    }

    local richLabel = self._topInfoTxt.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        self._topInfoTxt:addChild(richLabel)
        self._topInfoTxt.richLabel = richLabel
    end
    richLabel:setString(infoStr)

    -- local size = richLabel:getContentSize()
    -- richLabel:setPositionX(0 - size.width / 2)
    NodeUtils:alignNodeL2R(self._imgVip,self._artVip)
    local x = self._artVip:getPositionX()
    local an_x = self._artVip:getAnchorPoint().x
    local size = self._artVip:getContentSize()
    self._topInfoTxt:setPositionX( x + (1-an_x) * size.width )

end

function PersonInfoBuildPanel:onAfterActionHandler()
    self:onShowHandler()
end

-- function PersonInfoBuildPanel:onUpdateBuildingInfo()
--     local tabData,tabDataNew = self:getBuildingData()
--     self._tabData = tabData
--     self._tabDataNew = tabDataNew
    
--     for _, info in pairs(tabData) do
--         local inx = info.index..info.buildingType
--         local itempanel = self._listview[inx]
--         if itempanel ~= nil then
--         self:onRenderItem(itempanel,info)
--         end
--     end
-- end

function PersonInfoBuildPanel:onReflashAll()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local tabData = buildingProxy:getPersonBuildingDetailInfos()

    self._tabData = tabData
    -- 复制
    self._copyTabData = {}
    table.merge(self._copyTabData, self._tabData)
        
    -- 空地数据
    local blankData = buildingProxy:getBlankInfo()
    table.addAll(tabData, blankData)

    --self:renderListView(self._LISTVIEW, tabData, self, self.onRenderListViewInfo)
    self:renderScrollView(self._svBuilding, "panelItem", tabData, 
                        self, self.onRenderListViewInfo, nil, GlobalConfig.listViewRowSpace)
    self._svBuilding:setVisible(true)
end

function PersonInfoBuildPanel:onRenderListViewInfo(itempanel,info,index)
    -- body

    if index <= #self._copyTabData then
 	    self:onRenderItem(itempanel,info,index)

        self._listview[itempanel] = itempanel   
    else
        -- 空地
        self:onRenderBlankItem(itempanel, info, index) 
    end

end

function PersonInfoBuildPanel:onRenderItem(itempanel, info, index)
    -- body
    itempanel:setVisible(true)
    itempanel.info = info

    local itemBtn = itempanel:getChildByName("itemBtn")
    local Label_name = itemBtn:getChildByName("Label_name")
    local labLv = itemBtn:getChildByName("labLv")
    local tipBtn = itemBtn:getChildByName("tipBtn")
    local upBtn = itemBtn:getChildByName("upBtn")
    local labDes = itemBtn:getChildByName("labDes")
    
    local Panel_22 = itemBtn:getChildByName("Panel_22")
    local Label_detail122 = Panel_22:getChildByName("Label_detail122")
    local Image_24 = Panel_22:getChildByName("Image_24")
    local ProgressBar_23 = Image_24:getChildByName("ProgressBar_23")
    local Button_25 = Panel_22:getChildByName("Button_25")
    local Button_26 = Panel_22:getChildByName("Button_26")
    local iconImg = itemBtn:getChildByName("iconImg")
    local imgClock = Panel_22:getChildByName("imgClock") --时钟图标

    local iconInfo = { }
    iconInfo.power = GamePowerConfig.Building
    iconInfo.typeid = info.buildingType -- PlayerPowerDefine.POWER_commandLevel
    iconInfo.num = 0

    -- print("···建筑类型buildingType="..info.buildingType)

    local icon = itempanel.icon
    if icon == nil then
        local iconImg = itemBtn:getChildByName("iconImg")
        icon = UIIcon.new(iconImg, iconInfo, false)

        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end


    local conf = { }
    if info.buildingType < 8 then
        -- 资源建筑
        -- conf = ConfigDataManager:getInfoFindByTwoKey(self._buildResConf,"type",info.buildingType,"lv",info.level)
        local inx = info.buildingType .. info.level
        conf = self._BuildResourceConf[inx]
    else
        -- 功能建筑
        -- conf = ConfigDataManager:getInfoFindByTwoKey(self._buildFuncConf,"type",info.buildingType,"lv",info.level)
        local inx = info.buildingType .. info.level
        conf = self._BuildFunctionConf[inx]
    end
    local levelStr = string.format(self:getTextWord(529), info.level)

    Label_name:setString(conf.name)
    labLv:setString(levelStr)

    local playerProxy = self:getProxy(GameProxys.Role)
    local rate = playerProxy:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_buildspeedrate)
    local time2 = TimeUtils:getTimeBySpeedRate(conf.time, rate)
    -- print("time2 = "..time2)
    -- print("rate = "..rate)

    Label_name:setColor(ColorUtils.wordWhiteColor)          --name lv 颜色
    Label_detail122:setColor(ColorUtils.wordWhiteColor)     --remainTime 颜色

    upBtn:setVisible(true)
    tipBtn:setVisible(true)
    -- self:adaptiveTipBtnPosX(Label_name, tipBtn)
    NodeUtils:alignNodeL2R(Label_name,labLv, tipBtn)

    -- tip按钮
    local buildingType = info.buildingType
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingConfig = buildingProxy:getBuildingConfigInfo(buildingType, info.level)
    buildingConfig.buildingType = buildingType
    itemBtn.info = buildingConfig
    itemBtn.info.buildingInfo = info

    self:addTouchEventListener(itemBtn, self.onTipBtn)

    local remainTime = self:getCurBuildingUpgrateReTime( info )
    local time = 0
    if remainTime <= 0 then
        -- 未升级
        time = time2

        Image_24:setVisible(false)
        ProgressBar_23:setVisible(false)
        Button_25:setVisible(false)
        Button_26:setVisible(false)
        imgClock:setVisible(true)
        
        -- 升级按钮
        local isCan = self:isCanUp(buildingConfig,info.index)
        itempanel.isCan = isCan
        if isCan == 0 then
            local data = { }
            data.inx = 0
            data.index = info.index
            data.type = 1 --1普通升级 2金币升级
            data.buildingType = info.buildingType
            data.selectFlag = data.index .. data.buildingType
            upBtn.info = data
            upBtn:setTitleText(self:getTextWord(594)) -- [[升级]]
            self:addTouchEventListener(upBtn, self.onUpBtn)
            NodeUtils:setEnable(upBtn, true)

        elseif isCan == 1 then
            -- 官邸等级不足以升级建筑
            local data = { }
            data.inx = 0
            data.index = info.index
            data.type = 3 --1普通升级 2金币升级 3官邸升级
            data.buildingType = info.buildingType
            data.selectFlag = data.index .. data.buildingType
            upBtn.info = data
            upBtn:setTitleText(self:getTextWord(594)) -- [[升级]]
            self:addTouchEventListener(upBtn, self.onUpBtn)
            NodeUtils:setEnable(upBtn, false) -- 等级不足变灰

        else
            -- 资源不足以升级建筑
            upBtn:setTitleText(self:getTextWord(594)) -- [[升级]]
            NodeUtils:setEnable(upBtn,false) --不可升级，变灰
            self:addTouchEventListener(upBtn, function()
                local str = self:getNeedStr(buildingConfig)
                self:showSysMessage(str)
            end )
        end

    else
        -- 升级中
        time = remainTime

        imgClock:setVisible(false)
        -- tipBtn:setVisible(false)
        upBtn:setVisible(false)
        Image_24:setVisible(true)
        ProgressBar_23:setVisible(true)
        Button_25:setVisible(true)
        Button_26:setVisible(true)
        local per =(time2 - time) / time2 * 100
        if per < 0 then
            per = 0
        end
        ProgressBar_23:setPercent(per)

        local data = { }

        data.inx = 1
        data.buildingType = info.buildingType
        data.index = info.index
    	data.order = nil -- -1表示建筑
        data.selectFlag = data.index..data.buildingType
        Button_25.info = data

        info.inx = 2
        info.order = nil -- -1
    	Button_26.info = info

        self:addTouchEventListener(Button_25, self.onCancelBtn)
        self:addTouchEventListener(Button_26, self.onAccelerateBtn)
        Button_26.totalTime = time2

        self:onRenderItemTime(itempanel)
    end
    tipBtn:setTouchEnabled(false)
	time = TimeUtils:getStandardFormatTimeString6(time) --TODO
    Label_detail122:setFontSize(14)
    Label_detail122:setString(time)
    labDes:setString("")

end

-- 空地item
function PersonInfoBuildPanel:onRenderBlankItem(itempanel, info, index)

    itempanel.info = info

    local itemBtn = itempanel:getChildByName("itemBtn")
    local Label_name = itemBtn:getChildByName("Label_name")
    local labLv = itemBtn:getChildByName("labLv")
    local upBtn = itemBtn:getChildByName("upBtn")
    local tipBtn = itemBtn:getChildByName("tipBtn")
    local labDes = itemBtn:getChildByName("labDes")

    local Panel_22 = itemBtn:getChildByName("Panel_22")
    local Label_detail122 = Panel_22:getChildByName("Label_detail122") -- 计时
    local Image_24 = Panel_22:getChildByName("Image_24") -- 进度条
    local Button_25 = Panel_22:getChildByName("Button_25") -- x 取消按钮
    local Button_26 = Panel_22:getChildByName("Button_26") --
    local imgClock = Panel_22:getChildByName("imgClock") --时钟图标
    Button_26:setVisible(false)
    local iconImg = itemBtn:getChildByName("iconImg") -- 图标

    
    local emptyInfo = ConfigDataManager:getConfigById(ConfigData.BuildBlankConfig, info.index) 
    local blankName = self:getBlankName(emptyInfo.canbulid)      
    Label_name:setString(blankName)
    labLv:setString(" Lv.1")                                     --// by null
    NodeUtils:alignNodeL2R(Label_name,labLv, tipBtn,5)

    upBtn:setVisible(true)
    upBtn:setTitleText(self:getTextWord(595)) -- [[建造]]
    tipBtn:setVisible(false)

    Image_24:setVisible(false)
    Button_25:setVisible(false)
    labDes:setString(self:getTextWord(50201)) -- [[点击可建造资源建筑]]
    --labDes:setFontSize(18)
    Label_detail122:setString("")
    imgClock:setVisible(false)

    -- 默认图标
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Building
    iconInfo.typeid = info.buildingType -- PlayerPowerDefine.POWER_commandLevel
    iconInfo.num = 0
    local icon = itempanel.icon
    if icon == nil then
        local iconImg = itemBtn:getChildByName("iconImg")
        icon = UIIcon.new(iconImg, iconInfo, false)
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end

    -- 响应事件
    upBtn.info = info
    NodeUtils:setEnable(upBtn, true)
    self:addTouchEventListener(upBtn, self.onBlankBuild)

    itemBtn.info = nil

    --logger:error(emptyInfo.canbulid)
end

function PersonInfoBuildPanel:onBlankBuild(sender)
    local blankData = sender.info
    
    
    local emptyInfo = ConfigDataManager:getConfigById(
    ConfigData.BuildBlankConfig, blankData.index)

    local function upClose() -- 重新打开本模块
        ModuleJumpManager:jump(ModuleName.PersonInfoModule, PersonInfoBuildPanel.NAME)
    end

    local panel = self:getModulePanel(ModuleName.MainSceneModule, BuildingCreatePanel.NAME)
    panel:show(emptyInfo)  --通过回调的方式处理这些Panel关系
    panel:setCloseCallBack(upClose)
    --self._buildProxy:sendShowCreatePanel(emptyInfo)

    self:dispatchEvent(PersonInfoEvent.HIDE_SELF_EVENT, {})
    self:dispatchEvent(PersonInfoEvent.HIDE_OTHER_EVENT, {moduleName = ModuleName.FightingCapModule})
end

function PersonInfoBuildPanel:adaptiveTipBtnPosX(nameLabel,tipBtn)
    -- body

    if nameLabel ~= nil and tipBtn ~= nil then
        -- tipBtn坐标偏移
        -- logger:info("-- tipBtn坐标偏移 00")
        local size = nameLabel:getContentSize()
        local x = nameLabel:getPositionX() + size.width + 20
        tipBtn:setPositionX(x)
    end
end

function PersonInfoBuildPanel:renderOneItem(itempanel, info)
    -- body
    logger:info("资源触发刷新 ··· renderOneItem(itempanel, info)")

    local itemBtn = itempanel:getChildByName("itemBtn")
    local Label_name = itemBtn:getChildByName("Label_name")
    local upBtn = itemBtn:getChildByName("upBtn")
    local Panel_22 = itemBtn:getChildByName("Panel_22")
    local Label_detail122 = Panel_22:getChildByName("Label_detail122")

    
    if itempanel.isCan == 0 then
        -- 资源充足可以升级建筑
        local data = {}
        data.inx = 0
        data.index = info.index
        data.type = 1 --1普通升级 2金币升级
        data.buildingType = info.buildingType
        data.selectFlag = data.index..data.buildingType
        upBtn.info = data
        self:addTouchEventListener(upBtn,self.onUpBtn)
        NodeUtils:setEnable(upBtn,true)
        upBtn:setVisible(true)
        Label_name:setColor(ColorUtils.wordWhiteColor)          --name lv 颜色
        Label_detail122:setColor(ColorUtils.wordWhiteColor)     --remainTime 颜色

    elseif itempanel.isCan == 2 then
        -- 资源不足以升级建筑
        NodeUtils:setEnable(upBtn,false) --不可升级，变灰
        self:addTouchEventListener(upBtn, function()
            local str = self:getNeedStr(buildingConfig)
            self:showSysMessage(str)
        end)
        -- upBtn:setVisible(false)
        -- Label_name:setColor(ColorUtils.wordRedColor)
        -- Label_detail122:setColor(ColorUtils.wordRedColor)
    end
end




-- 刷新显示建筑升级倒计时
function PersonInfoBuildPanel:onRenderItemTime(itempanel)
    local info = itempanel.info
    local time = info.levelTime 

    if time == nil then
        return
    end
    -- body
    -- itempanel:setVisible(true)
    -- 升级中
    local normalUrl = "images/newGui1/BtnMiniYellow1.png"
    local pressedUrl = "images/newGui1/BtnMiniYellow2.png"


    local buildingType = info.buildingType
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingConfig = buildingProxy:getBuildingConfigInfo(buildingType, info.level)
    local itemBtn = itempanel:getChildByName("itemBtn")
    local labDes = itemBtn:getChildByName("labDes")
    itemBtn.info = buildingConfig
    itemBtn.info.buildingInfo = info

    local Panel_22 = itemBtn:getChildByName("Panel_22")
    -- "加速"
    local str = TextWords:getTextWord(8403)
    local roleProxy = self:getProxy(GameProxys.Role)
    local freeTime = roleProxy:getFreeTime()
    if time <= freeTime then 
        -- 免费
        str = TextWords:getTextWord(8404)
        normalUrl = "images/newGui1/BtnMiniGreed1.png"
        pressedUrl = "images/newGui1/BtnMiniGreed2.png"
        
    else
        local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)        
        if roleProxy:hasLegion() and legionHelpProxy:isBuildingHelped(info.index, info.buildingType) then
            --"求助"
            str = TextWords:getTextWord(8405)
            normalUrl = "images/newGui1/BtnMiniYellow1.png"
            pressedUrl = "images/newGui1/BtnMiniYellow2.png"

        end
    end
    local Button_26 = Panel_22:getChildByName("Button_26")
    Button_26:setTitleText(str)

    TextureManager:updateButtonNormal(Button_26, normalUrl)
    TextureManager:updateButtonPressed(Button_26, pressedUrl)

    local Label_detail122 = Panel_22:getChildByName("Label_detail122")
    local Image_24 = Panel_22:getChildByName("Image_24")
    local ProgressBar_23 = Image_24:getChildByName("ProgressBar_23")

    local conf = {}
    if info.buildingType < 8 then
        -- 资源建筑
        local inx = info.buildingType..info.level
        conf = self._BuildResourceConf[inx]
    else
        -- 功能建筑
        local inx = info.buildingType..info.level
        conf = self._BuildFunctionConf[inx]
    end

    local playerProxy = self:getProxy(GameProxys.Role)
    local rate = playerProxy:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_buildspeedrate)
    local time2 = TimeUtils:getTimeBySpeedRate(conf.time,rate)
    local per = (time2 - time) / time2 * 100
    if per < 0 then
        per = 0
    end
    ProgressBar_23:setPercent(per)
    ProgressBar_23:setVisible(true)

    time = TimeUtils:getStandardFormatTimeString6(time)
    Label_detail122:setFontSize(14)
    Label_detail122:setString(time)
    labDes:setString("")
end

function PersonInfoBuildPanel:isCanUp(info,index)
    -- body
    local isCan = 0  --可以升级
    local need = StringUtils:jsonDecode(info.need)
    local commandlv = StringUtils:jsonDecode(info.commandlv)

    local buildingProxy = self:getProxy(GameProxys.Building)
    for k,v in pairs(commandlv) do
        local level = buildingProxy:getBuildingMaxLvByType(v[1])
        if level < v[2] then
            return 1 --建筑等级不足以升级建筑
        end
    end

    -- local cmdBuildingLV = buildingProxy:getCommandLv()
    -- if info.commandlv > cmdBuildingLV then
        -- isCan = 1 --官邸等级不足以升级建筑
    -- else
        for _,v in pairs(need) do
            local roleProxy = self:getProxy(GameProxys.Role)
            local haveNum = roleProxy:getRolePowerValue(GamePowerConfig.Resource, v[1])
            if v[2] > haveNum then
                isCan = 2 --资源不足以升级建筑
                break
            end
        end
    -- end
    
    return isCan
end

function PersonInfoBuildPanel:getNeedStr(info)
    if info == nil then
        return "资源不足"
    end
    if rawget(info, "need") == nil then
        return "资源不足"
    end
    local need = StringUtils:jsonDecode(info.need)
    local str = "不足"
    local needStr = ""
    for _,v in pairs(need) do
        local roleProxy = self:getProxy(GameProxys.Role)
        local haveNum = roleProxy:getRolePowerValue(GamePowerConfig.Resource, v[1]) or 100
        local resConfig = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, v[1])
        if resConfig == nil then
            logger:error("读表失败，id是：%d",v[1])
        end
        if v[2] > haveNum then
            if resConfig ~= nil then
                needStr = needStr .. resConfig.name .. ","
            end
        end
    end
    needStr = string.reverse(needStr)
    needStr = string.gsub(needStr, ",", "", 1)
    needStr = string.reverse(needStr)
    print(needStr..str)
    return needStr..str
end

-- 自动建造升级界面
function PersonInfoBuildPanel:initAutoBuildPanel(flag,data)
	-- body
	local downPanel = self:getChildByName("downPanel")
    -- local Image_82 = downPanel:getChildByName("Image_82")
    local Label_101 = downPanel:getChildByName("Label_101")
    local Label_102 = downPanel:getChildByName("Label_102")
    local priceLabel = downPanel:getChildByName("priceLabel") --购买费用
    local Label_104 = downPanel:getChildByName("Label_104")
    local buyBtn = downPanel:getChildByName("buyBtn") --购买按钮
    local pnlKaiGuan = downPanel:getChildByName("pnlKaiGuan")
    self._Label_105L = downPanel:getChildByName("Label_105_L")   --(当前拥有:
    self._Label_105 = downPanel:getChildByName("Label_105")   --xxx
    self._Label_105R = downPanel:getChildByName("Label_105_R")   --)
    self._leftBtn = pnlKaiGuan:getChildByName("leftBtn")
    self._rightBtn = pnlKaiGuan:getChildByName("rightBtn")
    self._imgKai = pnlKaiGuan:getChildByName("imgKai") --开
    self._imgGuan = pnlKaiGuan:getChildByName("imgGuan") --关
    self._timeTxt2 = downPanel:getChildByName("timeTxt_2")  --txt (剩余时间：
    self._tip = downPanel:getChildByName("tip")              --(已关闭)
    self._timeTxt = downPanel:getChildByName("timeTxt")      --剩余时间数字 0m0s)


	local time = GlobalConfig.autoBuildTime
    local price = self._money
    Label_101:setString(self:getTextWord(5053))
    Label_102:setString(string.format(self:getTextWord(521),time))
    priceLabel:setString(price)
    Label_104:setString(self:getTextWord(522))
	buyBtn:setTitleText(self:getTextWord(519))

    -- icon
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = 10207
    iconInfo.num = 0

    local icon = self.icon
    if icon == nil then
        local iconImg = downPanel:getChildByName("iconImg")
        icon = UIIcon.new(iconImg,iconInfo,false)
        
        self.icon = icon
    else
        icon:updateData(iconInfo)
    end


    self:onUpdateAutoUpgrateGold()

    self.buyBtn = buyBtn
	self._autoPanel = downPanel
	self:addTouchEventListener(buyBtn,self.onBuyBtn)

    
    -- 初始化开关状态
    local roleProxy = self:getProxy(GameProxys.Role)
    local type = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_auto_build_type)
    self._type = type

    if type ~= nil then
        self._timeTxt:setVisible(true)
        self._timeTxt2:setVisible(true)
        self:updateAutoBuildPanel(type)
    else
        self._timeTxt:setVisible(false)
        self._timeTxt2:setVisible(false)
--        TimerManager:remove(self.onUpgrateTimeHandle, self)
    end

end

-- 刷新自动建造升级界面
function PersonInfoBuildPanel:updateAutoBuildPanel(type)
    -- body
    self:onUpgrateTimeHandle()
    self:updateSwitch(type)

end

-- 刷新当前拥有的元宝
function PersonInfoBuildPanel:onUpdateAutoUpgrateGold()
    -- body
    -- 当前拥有元宝
    local roleProxy = self:getProxy(GameProxys.Role)
    local gold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
    -- self._Label_105:setString(string.format(self:getTextWord(535),gold))

    local color = nil
    if gold >= self._money then
        color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Green)--ColorUtils.wordColorDark03
    else
        color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Red)--ColorUtils.wordColorDark04
    end
    self._Label_105:setColor(color)

    self._Label_105L:setString(self:getTextWord(558))
    self._Label_105:setString(StringUtils:formatNumberByK(gold))
    self._Label_105R:setString(self:getTextWord(559))

    local posx = self._Label_105L:getPositionX()
    local sizeL = self._Label_105L:getContentSize()
    local size = self._Label_105:getContentSize()
    local x1 = posx + sizeL.width
    local x2 = x1 + size.width + 2
    self._Label_105:setPositionX(x1)
    self._Label_105R:setPositionX(x2)

    -- print("onUpdateAutoUpgrateGold current gold = "..gold)

end

-- 刷新自动建造升级开关
function PersonInfoBuildPanel:updateSwitch(type)
    -- body
    if type == 1 then
        -- 已开启
        self._rightBtn:setVisible(true)
        self._leftBtn:setVisible(false)
        self._imgGuan:setVisible(false)
        self._imgKai:setVisible(true)
        self._rightBtn.type = type
        self._tip:setString(self:getTextWord(556))
        -- self._tip:setColor(ColorUtils.wordColorDark03)
--        TimerManager:add(1000, self.onUpgrateTimeHandle, self) 
        self._upgrateTime = true
        self:addTouchEventListener(self._rightBtn,self.onSwithBtn)
    elseif type == 0 then
        -- 已关闭
        self._rightBtn:setVisible(false)
        self._leftBtn:setVisible(true)
        self._imgGuan:setVisible(true)
        self._imgKai:setVisible(false)
        self._leftBtn.type = type
        self._tip:setString(self:getTextWord(557))
        -- self._tip:setColor(ColorUtils.wordColorDark04)
        self._upgrateTime = false
--        TimerManager:remove(self.onUpgrateTimeHandle, self)
        self:addTouchEventListener(self._leftBtn,self.onSwithBtn)
    end
end

-- 自动升级倒计时
function PersonInfoBuildPanel:onUpgrateTimeHandle()
    -- body

    -- 剩余时间
    local buildingProxy = self:getProxy(GameProxys.Building)
    local time = buildingProxy:getAutoBuildReTime()
--   print("自动升级剩余时间···time",time)
    self._timeTxt2:setVisible(true)
    self._timeTxt:setString(TimeUtils:getStandardFormatTimeString8(time)..")")
    NodeUtils:alignNodeL2R(self._timeTxt2,self._timeTxt)
--    print("building auto upgrate time = "..time)

    
    if time == 0 then
        self._timeTxt:setVisible(false)
        self._timeTxt2:setVisible(false)
        self:updateSwitch(0) --到期了
    else
        self._timeTxt:setVisible(true)
        self._timeTxt2:setVisible(true)
    end


end


function PersonInfoBuildPanel:onShowAutoBuildPanel(sender)
	-- body
	self._showBtn:setTouchEnabled(false)
	self._hideBtn:setTouchEnabled(true)
	self._autoPanel:setVisible(true)
	self._autoPanelFlag = true
end

function PersonInfoBuildPanel:onHideAutoBuildPanel(sender)
	-- body
	self._showBtn:setTouchEnabled(true)
	self._hideBtn:setTouchEnabled(false)
	self._autoPanel:setVisible(false)
	self._autoPanelFlag = false
end

function PersonInfoBuildPanel:onTipBtn(sender)
	-- body
	-- self:showSysMessage("onTipBtn")
    if sender.info == nil then        
        --logger:info("=========================》空地，没有tip")
        return
    end

    self:onShowBuildTip(sender)
end

-- 显示建筑tip
function PersonInfoBuildPanel:onShowBuildTip(sender)
    -- body
    local info = sender.info
    
    if self._uiBuildingTip == nil then
        self._uiBuildingTip = UIBuildingTip.new(self:getParent(), self)
    end
    
    self._uiBuildingTip:updateBuilding(info)


end

function PersonInfoBuildPanel:onUpBtn(sender)
	-- body
	local buildingProxy = self:getProxy(GameProxys.Building) 
    local info = sender.info

    if info.type == 3 then
        local buildingType = info.buildingType
        local index = info.index
        
        local moduleName = "MainSceneModule"
        local panelName = BuildingUpPanel.NAME
        
        local isFieldBuilding = buildingProxy:isFieldBuilding(buildingType)
        if isFieldBuilding == true or buildingType == 1 then
            buildingProxy:setBuildingPos(buildingType, index)
        elseif buildingType ~= 1 then
            local config = ConfigDataManager:getInfoFindByTwoKey(
                ConfigData.BuildOpenConfig,"ID",index,"type",buildingType)
            moduleName = config.moduleName .. buildingType .. "_" .. index

            if buildingType == BuildingTypeConfig.WAREHOUSE then --仓库
                moduleName = "MainSceneModule"
                buildingProxy:setBuildingPos(buildingType, index)
            elseif buildingType == BuildingTypeConfig.SCIENCE then
                panelName = "ScienceBuildPanel"
            elseif buildingType == BuildingTypeConfig.BARRACK or 
                buildingType == BuildingTypeConfig.REFORM  or buildingType == BuildingTypeConfig.MAKE then
                panelName = "BarrackBuildPanel"
            end
        end
        
        ModuleJumpManager:jump(moduleName, panelName)
        -- logger:info("moduleName:"..moduleName..",panelName:"..panelName)

    else
        -- 请求升级建筑
        local num, buildingType, index = buildingProxy:buildingLvNum()  --num=已使用建造位
        local roleProxy = self:getProxy(GameProxys.Role)
        local allbuildsize = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildsize)  --allbuildsize=总建造位
        if allbuildsize == num then
            self:dispatchEvent(PersonInfoEvent.Build_Upgrate_Buy_Vip_Req)
            -- self:showSysMessage(self:getTextWord(554)) --没有建造空位时飘字
            return
        end

        self._selectFlag = info.selectFlag
        self.view:onSendBuild(info)
    end
end

function PersonInfoBuildPanel:cancelMessageBox(info)
	-- body
	local function okCallBack()
        self._selectFlag = info.selectFlag
		self.view:onSendBuild(info)
	end
	local function cancelCallBack()
	end
	self:showMessageBox(self:getTextWord(808),okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))
end

function PersonInfoBuildPanel:onCancelBtn(sender)
	-- body
	self:cancelMessageBox(sender.info)
end

function PersonInfoBuildPanel:createUIAcceleration()
	-- body
    local parent = self:getParent()
    local uiAcceleration = UIAcceleration.new(parent, self,true)

    self._uiAcceleration = uiAcceleration

end

function PersonInfoBuildPanel:onQuickReq(quickType, cost, info, num)
    self._cost = cost
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local data = {}
    -- data.order = -1
    data.buildingType = buildingInfo.buildingType
    data.index = buildingInfo.index
    data.useType = quickType
    data.useNum = num
    buildingProxy:onTriggerNet280004Req(data)
    -- buildingProxy:buildingQuickReq(data)
    
end


function PersonInfoBuildPanel:onAccelerateBtn(sender)
	-- body
	local buildingInfo = sender.info
	local productionInfo = nil	

    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:setBuildingPos(buildingInfo.buildingType, buildingInfo.index)
    local remainTime = buildingProxy:getBuildingUpReTime(buildingInfo.buildingType, buildingInfo.index)
    local roleProxy = self:getProxy(GameProxys.Role)
    local freeTime = roleProxy:getFreeTime()
    if remainTime <= freeTime then
        local data = {}
        data.index = buildingInfo.index
        data.useType = 1
        data.buildingType = buildingInfo.buildingType
        buildingProxy:onTriggerNet280004Req(data)
        return
    else
        local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
        if roleProxy:hasLegion() and legionHelpProxy:isBuildingHelped(buildingInfo.index, buildingInfo.buildingType) then
            local buildingProxy = self:getProxy(GameProxys.Building)
            buildingProxy:onTriggerNet280017Req(buildingInfo.buildingType, buildingInfo.index)
            legionHelpProxy:showHelp()
            return
        end
    end
    if self._uiAcceleration == nil then
        self:createUIAcceleration()
    end
    self._uiAcceleration:show(buildingInfo, productionInfo, nil, sender.totalTime)
end

-- 购买自动升级
function PersonInfoBuildPanel:onBuyBtn(sender)
    -- body
    local function okCallBack()
        local function callFunc()
            -- 请求购买自动升级建筑
            local buildingProxy = self:getProxy(GameProxys.Building)
            buildingProxy:onTriggerNet280012Req({})
        end
        sender.callFunc = callFunc
        sender.money = self._money
        self:isShowRechargeUI(sender)

    end

    local money = self._money
    local str = string.format(self:getTextWord(545), money)
    self:showMessageBox(str,okCallBack)
end

-- 是否弹窗元宝不足
function PersonInfoBuildPanel:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end

    else
        sender.callFunc()
    end

end


-- 自动升级建筑开关
function PersonInfoBuildPanel:onSwithBtn(sender)
	-- body
    -- 请求购买自动升级建筑
    local type = sender.type
    if type == 1 then
        type = 0
    elseif type == 0 then
        type = 1
    else
--        return
    end
    local buildingProxy = self:getProxy(GameProxys.Building)
    --TODO判断，购买自动升级
    local reTime = buildingProxy:getAutoBuildReTime()
    if reTime == 0 then  --没有剩余时间，表示需要购买
        self:onBuyBtn(sender)
        return
    end
    
    --开关请求
    
    buildingProxy:onTriggerNet280013Req({type = type}) --1开启，0关闭

end


-- 升级建筑
-- function PersonInfoBuildPanel:onBuildUpgrateResp(data)
	-- body

    -- local info = data.buildingInfo
    -- for k,v in pairs(self._listview) do
    --     local itemData = v.info
    --     if info.index == itemData.index and info.buildingType == itemData.buildingType then
    --         self:showSysMessage("upgrate 0")
    --         self:onRenderItem(v,info,k)
    --     end
    -- end
        
-- end

-- 建筑更新
function PersonInfoBuildPanel:buildingUpdateResp(data)
    -- body
    
    -- local info = data
    -- if info.buildingType < 1 or info.buildingType > 11  or info.level < 1 then
    --     -- logger:info("建筑更新 return A")
    --     return
    -- end 

    -- local inx = info.index..info.buildingType
    -- local itempanel = self._listview[inx]
    -- if itempanel ~= nil then
    --     local v = itempanel.info

    --     -- _selectFlag是解决取消升级时和计时器冲突导致界面未刷新的标记
    --     if self._selectFlag == nil or self._selectFlag ~= inx then
    --         if v.index == info.index and v.buildingType == info.buildingType and v.level == info.level and v.levelTime == info.levelTime then
    --             -- logger:info("建筑更新 return B")
    --             return
    --         end
    --     elseif self._selectFlag == inx then
    --         self._selectFlag = nil
    --     end
    -- end


    self:onReflashAll()
    logger:info("建筑更新 0000")
end


function PersonInfoBuildPanel:onUpdateBuildInfo()
    -- body
    logger:info("个人信息改变or资源改变，导致建筑更新 0000")
    self:onUpdateAutoUpgrateGold()
    self:onTopPanelUpdate()

    self:onReflashAll()

--    -- 判定是否刷新
--    for k,itempanel in pairs(self._listview) do
--        local info = itempanel.info
--        local remainTime = self:getCurBuildingUpgrateReTime(info)
--        if remainTime <= 0 then
--            -- 没有在升级的item，才判定刷新
--            local buildingProxy = self:getProxy(GameProxys.Building)
--            local buildingConfig = buildingProxy:getBuildingConfigInfo(info.buildingType, info.level)
--            local isCan = self:isCanUp(buildingConfig)

--            -- logger:info("资源触发刷新··· itempanel.isCan=%d isCan=%d", itempanel.isCan, isCan)
--            if itempanel.isCan ~= isCan then
--                -- 资源改变需要刷新按钮状态
--                itempanel.isCan = isCan
--                self:renderOneItem(itempanel, info)
--            end
--        end
--    end        

end


-- 取消升级建筑
function PersonInfoBuildPanel:onBuildUpgrateCancelResp(data)
    -- body
    
    -- local info = data.buildingInfo

    -- for k,v in pairs(self._listview) do
    --     local itemData = v.info
    --     if info.index == itemData.index and info.buildingType == itemData.buildingType then
    --         info.levelTime = self:getCurBuildingUpgrateReTime(info)
       --      -- self:showSysMessage("cancel 0")
    --         self:onRenderItem(v,info,k)
    --     end
    -- end

    
    -- local index = info.index
    -- info.levelTime = self:getCurBuildingUpgrateReTime(info)
    -- self:onRenderItem(self._listview[index],info,index)

end

-- 加速升级建筑飘字
function PersonInfoBuildPanel:onBuildUpgrateAccelerateResp(data)
	-- body
    local info = data.buildingInfo
    local conf = {}
    if info.buildingType < 8 then
        -- 资源建筑
        conf = ConfigDataManager:getInfoFindByTwoKey(self._buildResConf,"type",info.buildingType,"lv",info.level)
    else
        -- 功能建筑
        conf = ConfigDataManager:getInfoFindByTwoKey(self._buildFuncConf,"type",info.buildingType,"lv",info.level)
    end

    local money = self._cost or 0
    self:showSysMessage(string.format(self:getTextWord(544), conf.name, money))

end

function PersonInfoBuildPanel:onSendBuild(data)
	-- body
	self.view:onSendBuild(data)
end

--获取当前建筑升级的剩余时间
function PersonInfoBuildPanel:getCurBuildingUpgrateReTime(data)
    local buildingProxy = self:getProxy(GameProxys.Building)
    local time = buildingProxy:getBuildingUpReTime(data.buildingType, data.index)
    return time
end

function PersonInfoBuildPanel:getRenderLevelTime(data)

    for k, panelItem in pairs(self._listview) do
        local info = panelItem.info
        info.levelTime = self:getCurBuildingUpgrateReTime(info)
        if info.levelTime > 0 then
            self:onRenderItemTime(panelItem)
        end
    end
end

function PersonInfoBuildPanel:update()
	-- body
	if self._listview == nil or self._tabData == nil then
		return
	else
		self:getRenderLevelTime()

        -- 加速升级界面
        self:updateCallBack()
		
        -- 自动升级建筑
        -- self:onUpgrateTimeHandle()
        if self._upgrateTime == true then
            self:onUpgrateTimeHandle()
        end
	end
end

function PersonInfoBuildPanel:updateCallBack()
	-- body
	if self._uiAcceleration ~= nil then
		self._uiAcceleration:update()
	end
end


-- 自动升级建筑通知
function PersonInfoBuildPanel:onAutoUpgrateUpdate(data)
    -- body
    if data == 3 then
        --未购买，弹出购买自动升级对话框
       -- self:onBuyBtn(self.buyBtn) 
       return
    end


    local buildingProxy = self:getProxy(GameProxys.Building)
    local type = buildingProxy:getAutoBuildState()
    self._type = type
--    print("building auto upgrate swithc = "..type)

    if data == 1 then
        -- 来自购买自动升级的协议返回通知
        self:updateAutoBuildPanel(type)
    elseif data == 2 then
        --来自自动升级建筑开关的协议返回通知
        self:updateSwitch(type)
    end


end

function PersonInfoBuildPanel:getBlankName(canBuild)
    local name = ""
    if canBuild == "[2]" then
        name = self:getTextWord(8609) -- [[铸币空地]]
    elseif canBuild == "[6]" then
        name = self:getTextWord(8608) -- [[农田空地]]
    end
    if name == "" then
        name = self:getTextWord(820) -- [[空地]]
    end
    return name
end 

