-- 日常活跃
ActiveTaskPanel = class("ActiveTaskPanel", BasicPanel)
ActiveTaskPanel.NAME = "ActiveTaskPanel"

function ActiveTaskPanel:ctor(view, panelName)
    ActiveTaskPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function ActiveTaskPanel:finalize()
    ActiveTaskPanel.super.finalize(self)
end

function ActiveTaskPanel:initPanel()
	ActiveTaskPanel.super.initPanel(self)
	-- self._listview = {}
    self._conf = self:initConfigData(ConfigData.DayActiveConfig)

    local listview = self:getChildByName("ListView_1")
--    NodeUtils:adaptive(listview)
    self._listview = listview

    local Panel_28 = self:getChildByName("Panel_28")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(Panel_28,listview,GlobalConfig.downHeight,tabsPanel)

end

function ActiveTaskPanel:initConfigData(configTab)
    -- body
    local conf = ConfigDataManager:getConfigDataBySortId(configTab)
    local info = {}

    for k,v in pairs(conf) do
        info[v.ID] = v
    end
    return info
end

function ActiveTaskPanel:onShowHandler()
    -- body
    -- if self._listview ~= nil then
    -- 	self._listview = {}
    -- end

    self._listview:jumpToTop()

    -- self._listview = {}
    local tabData,activeID,activeMaxID = self:getTaskData()
    self._activeMaxID = activeMaxID
    self._tabData = tabData

    self:onTopPanel(data,activeID)

    local listview = self:getChildByName("ListView_1")
    self:renderListView(listview, tabData, self, self.onRenderListViewInfo)

    self.view:onUpdateCount()
end

function ActiveTaskPanel:onTopPanel(data,activeID)
    -- body
    local Panel_28 = self:getChildByName("Panel_28")
    local Image_29 = Panel_28:getChildByName("Image_29")
    local Label_33 = Image_29:getChildByName("Label_33")
    local tipBtn = Image_29:getChildByName("tipBtn")
    local rewardBtn = Image_29:getChildByName("rewardBtn")
    
    local Image_31 = Image_29:getChildByName("Image_31")
    local ProgressBar_32 = Image_31:getChildByName("ProgressBar_32")
    local proTxt = ProgressBar_32:getChildByName("proTxt")
    local proTxt_0 = ProgressBar_32:getChildByName("proTxt_0")
    local proTxt_1 = ProgressBar_32:getChildByName("proTxt_1")
    local proTxt_2 = ProgressBar_32:getChildByName("proTxt_2")

    Label_33:setString(self:getTextWord(1314))


    local conf = ConfigDataManager:getConfigById("ActiveRewardConfig",activeID)
    local roleProxy = self:getProxy(GameProxys.Role)
    local cur = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_active)
    local max = conf.activeneed

    local per = 100
    local color = nil
    if cur >= max then
        per = 100
        color = ColorUtils.wordColorDark03
    else
        per = cur / max * 100
        color = ColorUtils.wordColorDark04
    end
    ProgressBar_32:setPercent(per)
    proTxt_1:setColor(color)


    proTxt_1:setString(cur)
    proTxt_2:setString(string.format(self:getTextWord(1334), max))

    -- 文本对齐
    local proTxtX = proTxt:getPositionX()
    local size0 = proTxt_0:getContentSize()
    local size1 = proTxt_1:getContentSize()
    local size2 = proTxt_2:getContentSize()
    local allLen = size0.width + size1.width + size2.width
    local x0 = proTxtX - allLen/2
    local x1 = x0 + size0.width
    local x2 = x1 + size1.width

    proTxt_0:setPositionX(x0)
    proTxt_1:setPositionX(x1)
    proTxt_2:setPositionX(x2)
    proTxt:setVisible(false)

    -- print("self._activeMaxID, activeID >>> ", self._activeMaxID, activeID)

    if per >= 100 then
        -- if self._activeMaxID == activeID then
        if self._activeMaxID == 5 then
            -- 已领取最大活跃奖励
            NodeUtils:setEnable(rewardBtn,false)
            rewardBtn:setTitleText(self:getTextWord(1335)) -- 达成 已领取
            -- self:addTouchEventListener(rewardBtn,self.onTopRewardBtn)
            -- rewardBtn:setBright(false)
            NodeUtils:setEnable(rewardBtn, false)
        else
            NodeUtils:setEnable(rewardBtn,true)
            rewardBtn:setTitleText(self:getTextWord(1323)) -- 达成 可领取
            self:addTouchEventListener(rewardBtn,self.onTopRewardBtn)
            -- rewardBtn:setBright(true)
            NodeUtils:setEnable(rewardBtn, true)
        end
    else
        NodeUtils:setEnable(rewardBtn,false)
        rewardBtn:setTitleText(self:getTextWord(1311)) -- 未达成 变灰
        -- rewardBtn:setBright(false)
        NodeUtils:setEnable(rewardBtn, false)
    end

    self:addTouchEventListener(tipBtn,self.onTopTipBtn)

end


function ActiveTaskPanel:onRenderListViewInfo(itempanel,info,index)
    -- body
 	self:onRenderItem(itempanel,info,index)
    -- table.insert( self._listview, itempanel )
end

function ActiveTaskPanel:onRenderItem(itempanel,info,index)
	-- body
	itempanel:setVisible(true)

    local conf = self._conf[info.typeId]

    local Image_4 = itempanel:getChildByName("Image_4")
    local name = Image_4:getChildByName("name")
    local reward = Image_4:getChildByName("reward")
    local process = Image_4:getChildByName("process")
    local processR = Image_4:getChildByName("processR")
    local goBtn = Image_4:getChildByName("goBtn")
    local openLevel = Image_4:getChildByName("openLevel")
    -- local icon = Image_4:getChildByName("icon")

    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = conf.icon
    iconInfo.num = 0
    -- local icon = UIIcon.new(icon,iconInfo,false)	
    local icon = itempanel.icon
    if icon == nil then
        local iconImg = Image_4:getChildByName("icon")
        icon = UIIcon.new(iconImg,iconInfo,false)        
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end
    icon:setTouchEnabled(false)
    

    name:setString(conf.name)
    -- name:setColor(ColorUtils.wordOrangeColor)

    local rewardID = StringUtils:jsonDecode(conf.reward)
    local rewardData = ConfigDataManager:getRewardConfigById(rewardID[1])
    -- reward:setString(string.format(self:getTextWord(1332), rewardData.num))
    reward:setString("+"..rewardData.num)

    local number = tonumber(info.num)
    local maxNum = conf.finishcond2
    local color = nil
    if number >= maxNum then
        number = maxNum
        color = ColorUtils.wordColorDark03
    else
        color = ColorUtils.wordColorDark04
    end
    process:setColor(color)


    process:setString(number)
    processR:setString("/"..maxNum)

    local posx = process:getPositionX()
    local size = process:getContentSize()
    local x = posx + size.width
    processR:setPositionX(x)


    if info.isOpen == false then
        goBtn:setVisible(false)
        openLevel:setVisible(true)
        openLevel:setColor(ColorUtils.wordColorLight04)
        openLevel:setString(string.format(self:getTextWord(1319),conf.opencond))
    elseif info.isOpen == true then
        goBtn:setVisible(true)
        openLevel:setVisible(false)
    end

    goBtn.info = info
    if info.state == 1 or info.state == 2 then
        -- 已达成
        local url = "images/newGui1/BtnMiniRed1.png"
        TextureManager:updateButtonNormal(goBtn,url)
        -- NodeUtils:setEnable(goBtn, false)
        goBtn:setEnabled(false)
        goBtn:setTitleText(self:getTextWord(1323))
    else
        local url = "images/newGui1/BtnMiniGreed1.png"
        TextureManager:updateButtonNormal(goBtn,url)
        NodeUtils:setEnable(goBtn, true)
        goBtn:setTitleText(self:getTextWord(1307))
        info.jumpmodule = conf.jumpmodule
        info.reaches = conf.reaches
        info.ID = conf.ID
        goBtn.info = info
        self:addTouchEventListener(goBtn,self.onGoBtn)
    end
    
    -- tipBtn.info = info
    -- self:addTouchEventListener(tipBtn,self.onTipBtn)

end
---------------------------------------------------------------------
--button touch event
function ActiveTaskPanel:onTopTipBtn(sender)
    -- body
    -- self:showSysMessage("Top Tip button")
    self.view:openTipPreView()
    -- local panel = self:getPanel(TaskRewardPreviewPanel.NAME)
    -- panel:show()
end

function ActiveTaskPanel:onTopRewardBtn(sender)
    -- body
    local taskProxy = self:getProxy(GameProxys.Task)
    taskProxy:onTriggerNet190003Req({})
end

function ActiveTaskPanel:onGoBtn(sender)
    -- body

    local info = sender.info
    if info.jumpmodule == ' ' then
        self:showSysMessage(self:getTextWord(1336))
        return
    end

    local moduleName = info.jumpmodule
    local panelName = info.reaches
    -- print("前往按钮:...".."moduleName="..moduleName..",panelName="..panelName..",info.ID="..info.ID)


    if info.ID >= 209 and info.ID <= 213 then
        local roleProxy = self:getProxy(GameProxys.Role)
        local legionID = roleProxy:hasLegion()
        if legionID == false then
            -- 未加入军团,跳转去军团申请列表模块
            ModuleJumpManager:jump("LegionApplyModule", "LegionListPanel")
            self:showSysMessage(self:getTextWord(4025))
            self:dispatchEvent(TaskEvent.HIDE_SELF_EVENT, {})
            return
        end
    end

    ModuleJumpManager:jump(moduleName, panelName)
    self:dispatchEvent(TaskEvent.HIDE_SELF_EVENT, {})
end

function ActiveTaskPanel:getTaskData()
    -- body
    local tabData = {}
    local taskProxy = self:getProxy(GameProxys.Task)
    tabData = taskProxy:getActiveTaskList() --真实数据    
    local activeID = taskProxy:getActiveID() or 1 --真实数据    
    local activeMaxID = taskProxy:getActiveMaxID() or 0 --真实数据    
    return tabData, activeID, activeMaxID
end

function ActiveTaskPanel:onUpdateTaskInfoResp(data)
    -- body
end
