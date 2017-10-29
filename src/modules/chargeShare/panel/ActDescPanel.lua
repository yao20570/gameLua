
ActDescPanel = class("ActDescPanel", BasicPanel)
ActDescPanel.NAME = "ActDescPanel"

function ActDescPanel:ctor(view, panelName)
    ActDescPanel.super.ctor(self, view, panelName)

end

function ActDescPanel:finalize()
    ActDescPanel.super.finalize(self)
end

function ActDescPanel:initPanel()
	ActDescPanel.super.initPanel(self)

    self._listview = self:getChildByName("ListView_2")
    local item = self._listview:getItem(0)
    self._listview:setItemModel(item)

    
    local panelBg = self:getChildByName("topPanel")

    local Label_14 = panelBg:getChildByName("Label_14")
    Label_14:setString(TextWords:getTextWord(249996))

    local lab_desc = panelBg:getChildByName("lab_desc")
    lab_desc:setColor(cc.c3b(244,244,244))
    -- lab_desc:setFontSize(23)
    lab_desc:ignoreContentAdaptWithSize(false)
    lab_desc:setContentSize(cc.size(400, 300))
    

    local payBtn = panelBg:getChildByName("Button_18")
    self:addTouchEventListener(payBtn, function(sender)
        self:dispatchEvent(ChargeShareEvent.SHOW_OTHER_EVENT, ModuleName.RechargeModule)
    end)



    local descBtn = panelBg:getChildByName("tipsBtn")
    self:addTouchEventListener(descBtn, function(sender)
        self.secLvBg:setVisible(true)
    end)

    local panel_tips = self:getChildByName("panel_tips")

    -- --start 二级弹窗 -------------------------------------------------------------------
    if self.secLvBg == nil then
        local extra = {}
        extra["closeBtnType"] = 1
        extra["callBack"] = function() panel_tips:setVisible(false) end
        extra["obj"] = self

        self.secLvBg = UISecLvPanelBg.new(self, self, extra)
        self.secLvBg:setContentHeight(300)
        self.secLvBg:setTitle(TextWords:getTextWord(249999))
        self.secLvBg:setVisible(false)
        self.secLvBg:hideCloseBtn(false)
        self.secLvBg:setLocalZOrder(20)
        -- panel_tips:setLocalZOrder(3)
        self.secLvBg:setBackGroundColorOpacity(120)

        self.tipPanel = panel_tips:clone()
        self.tipPanel:setName("tipPanel")
        local panel = self.secLvBg:getMainPanel()
        panel:addChild(self.tipPanel)


        self.tipPanel:setVisible(true)
        local name = "lab_desc"
        for i=1,3 do
            local label = self.tipPanel:getChildByName(name..i)
            label:setString(TextWords:getTextWord(249999+i))
            label:setColor(ColorUtils.wordYellowColor03)
        end

    end
    -- --end 二级弹窗 --------------------------------------------------------------------
    if self.tipPanel.layoutChild == nil then
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(3000, 3000))
        local winSize = self.tipPanel:getContentSize()
        layout:setPosition(cc.p(winSize.width/2, winSize.height/2))
        layout:setAnchorPoint(0.5, 0.5)
        layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
        self.tipPanel:addChild(layout)
        layout:setTouchEnabled(true)
        self:addTouchEventListener(layout, function()
         self.secLvBg:setVisible(false)
        end)
        self.tipPanel.layoutChild = layout
    end



    local lab_time = panelBg:getChildByName("lab_time")

    local activityProxy = self:getProxy(GameProxys.Activity)
    local data = activityProxy.curActivityData
    -- local t1 = TimeUtils:setTimestampToString(data.startTime)
    -- local t2 = TimeUtils:setTimestampToString(data.endTime)
    -- lab_time:setString(t1.."-"..t2)
    lab_time:setString(TimeUtils.getLimitActFormatTimeString(data.startTime,data.endTime))
    lab_desc:setString(data.info)
    self:readData()

end

function ActDescPanel:doLayout()
    local panelBg = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(panelBg, self._listview, GlobalConfig.downHeight, tabsPanel, 3)
end

function ActDescPanel:readData()
    local ConfigData = ConfigDataManager:getConfigData(ConfigData.LegionShareConfig)
    for k,v in pairs(ConfigData) do
        local id = StringUtils:jsonDecode(v.reward)
        local param
        if type(id[1]) == "number" then
            param = id[1]
        else
            param = tonumber(id[1])
        end
        local r = ConfigDataManager:getRewardConfigById(param)
        v.re = r
    end
    self:renderListView(self._listview, ConfigData, self, self.renderItemPanel)
end

function ActDescPanel:renderItemPanel(item, data)
    local allChild = self:getAllChild(item)
    allChild.pkgDesc:setString(string.format(data.info, self:getNum(data.chargeID)*10))
    allChild.pkgName:setString(data.re.name)
    local panel = self:getPanel(ChargeSharePanel.NAME)
    local color = panel:getColor(data.re.color)
    allChild.pkgName:setColor(color)

    local iconData = {}
    iconData.num = data.re.num
    iconData.power = data.re.power
    iconData.typeid = data.re.typeid
    local uiIcon = allChild.pkgImg.uiIcon
    if not uiIcon then
        uiIcon = UIIcon.new(allChild.pkgImg,iconData,true,self)
        allChild.pkgImg.uiIcon = uiIcon
    else
        uiIcon:updateData(iconData)
    end
    -- uiIcon:setPosition(allChild.pkgImg:getContentSize().width/2, allChild.pkgImg:getContentSize().height/2)

end

function ActDescPanel:getNum(id)
    local ConfigData = ConfigDataManager:getConfigData(ConfigData.ChargeConfig)
    return ConfigData[id].limit
end

function ActDescPanel:registerEvents()
	ActDescPanel.super.registerEvents(self)
end

function ActDescPanel:getAllChild(item)
    local allChild = {}
    allChild.pkgName = item:getChildByName("lab_name")
    allChild.pkgImg = item:getChildByName("img_icon")
    allChild.pkgDesc = item:getChildByName("lab_desc")
    return allChild
end

function ActDescPanel:onShowHandler()
    local panel = self:getPanel(ChargeSharePanel.NAME)
    panel:onShowHandler()
end