-- 日常福利
LegionWelfareDailyPanel = class("LegionWelfareDailyPanel", BasicPanel)
LegionWelfareDailyPanel.NAME = "LegionWelfareDailyPanel"

function LegionWelfareDailyPanel:ctor(view, panelName)
    LegionWelfareDailyPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionWelfareDailyPanel:finalize()
    LegionWelfareDailyPanel.super.finalize(self)
end

function LegionWelfareDailyPanel:initPanel()
	LegionWelfareDailyPanel.super.initPanel(self)

    local topPanel = self:getChildByName("topPanel")
	local mainList = self:getChildByName("mainList")
    self._topPanel = topPanel
    self._mainList = mainList

    topPanel:setVisible(false)
    mainList:setVisible(false)
end

function LegionWelfareDailyPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, self._mainList, GlobalConfig.downHeight, tabsPanel)
end

function LegionWelfareDailyPanel:registerEvents()
    LegionWelfareDailyPanel.super.registerEvents(self)
    
    self._upgrateBtn = self:getChildByName("topPanel/Button_upgrate")
    self._upgrateBtn:setVisible(false)
    self:addTouchEventListener(self._upgrateBtn,self.onUpgrateBtnTouch)
end

--显示界面时调用
function LegionWelfareDailyPanel:onShowHandler(data)
    if self:isModuleRunAction() then
        return
    end

    --请求刷新TopPanel的数据
    self.view._parent.module:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220012, {})

    self._topPanel:setVisible(true)
    self._mainList:setVisible(true)
    
    LegionWelfareDailyPanel.super.onShowHandler(self)
    self:onUpdateUpgrateBtn(data)

    if self._data == nil and self.view.panelInfo ~= nil then
        self:updateData(self.view.panelInfo)
    end
end

function LegionWelfareDailyPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionWelfareDailyPanel:getRoleJobInLegion()
    local legionProxy = self:getProxy(GameProxys.Legion)
    local info = legionProxy:getMineInfo()
    local job = info.mineJob
    local isLeader = false
    if job == 7 then
        isLeader = true
    end 
    return isLeader
end 

--更新数据
function LegionWelfareDailyPanel:updateData(data)
    print("..............................--更新数据 00000000000000")
    self._data = data
    self:updateTopPanel(data)
end 

--领取福利成功
function LegionWelfareDailyPanel:onWelfareGetResp(iscangetWelf)
    --领取按钮
    local getTag = iscangetWelf
    if getTag == 1 then --已领取 变灰
        NodeUtils:setEnable(self._rewardBtn, false)
        self._rewardBtn:setTitleText(self:getTextWord(3417))
    else
        NodeUtils:setEnable(self._rewardBtn, true)
        self._rewardBtn:setTitleText(self:getTextWord(3416))
    end 

end 

function LegionWelfareDailyPanel:updateTopPanel(data)
    if self._isLabelInit ~= true then
        self._labelName   = self:getChildByName("topPanel/Label_1")
        self._labelLv     = self:getChildByName("topPanel/Label_num_1")
        self._labelNeed   = self:getChildByName("topPanel/Label_num_2")
        self._labelAllPro = self:getChildByName("topPanel/Label_num_3")
        self._labelDevote = self:getChildByName("topPanel/Label_num_4")
        self._isLabelInit = true
    end

    local level = data.welfarelv
    local need = data.buildNeed
    local pro = data.allBuild
    local devote = data.myContribute
    -- local getId = data.canGetId
    self._haveNum = devote
    self._getId = data.canGetId


    self._labelLv:setString("Lv." .. level)
    self._labelNeed:setString(need)
    self._labelAllPro:setString(pro)
    self._labelDevote:setString(devote)

    -- NodeUtils:alignNodeL2R(self._labelName,self._labelLv)
    local color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Green)
    if need > pro then
        color =ColorUtils:color16ToC3b(ColorUtils.commonColor.Red)
    end 
    self._labelNeed:setColor(color)


    self:onUpdateUpgrateBtn(data)    
    self:updateMainList(level,devote)


    -- 满级显示
    if level >= GlobalConfig.LegionWelfareMaxLV then
        self._labelNeed:setString(self:getTextWord(3027))
        self._labelNeed:setColor(ColorUtils.wordColorLight03)
    else
        self._labelNeed:setString(need)
    end
end

--更新升级按钮
function LegionWelfareDailyPanel:onUpdateUpgrateBtn(data)
    logger:info("= --更新升级按钮 =")    
    local legionProxy = self:getProxy(GameProxys.Legion)
    local mineJob = legionProxy:getMineJob()    --自己的职位

    local isLeader = legionProxy:getShowStateByJob(mineJob, "buildLevel")

    if isLeader ~= true then
        self._upgrateBtn:setVisible(false)
        return
    end

    if isLeader == true then
        if data ~= nil then

            -- 满级显示
            local level = data.welfarelv
            if level >= GlobalConfig.LegionWelfareMaxLV then
                if isLeader == true then
                    self._upgrateBtn:setVisible(false)
                    -- NodeUtils:setEnable(self._upgrateBtn, false)
                    return
                end
            end

            --建设度不足以升级
            self._upgrateBtn:setVisible(true)
            if data.buildNeed > data.allBuild then
                NodeUtils:setEnable(self._upgrateBtn, false)
            else
                NodeUtils:setEnable(self._upgrateBtn, true)
            end

        end
    end


end

function LegionWelfareDailyPanel:updateMainList(level,devote)
    local legionProxy = self:getProxy(GameProxys.Legion)
    self.welfareInsfos = legionProxy:getWelfareInfo()

    local reward = self:getConfData(level)
    if reward ~= nil then
        self:renderListView(self._mainList, reward, self, self.renderItemPanel)
    end
end

-- 渲染列表
function LegionWelfareDailyPanel:renderItemPanel(itemPanel,info,index)
    if itemPanel == nil or info == nil then
        print("itemPanel == nil or info == nil!!!")
        return  
    end

-- TextWords[3044] = "福利所"
-- TextWords[3045] = "%d~%d"
-- TextWords[3046] = "级奖励"
    local titleTxt1 = itemPanel:getChildByName("titleTxt1")
    local titleTxt2 = itemPanel:getChildByName("titleTxt2")
    local titleTxt3 = itemPanel:getChildByName("titleTxt3")
    -- local str = string.format(self:getTextWord(3029),info.welfarelvmin,info.welfarelvmax)
    titleTxt1:setString(TextWords[3044])
    titleTxt2:setString(string.format(TextWords[3045],info.welfarelvmin,info.welfarelvmax))
    titleTxt3:setString(TextWords[3046])
    NodeUtils:alignNodeL2R(titleTxt1,titleTxt2,titleTxt3)
    NodeUtils:centerNodesGlobal(titleTxt1:getParent(),{titleTxt1,titleTxt2,titleTxt3})

    -- 领取按钮
    local devoteTxt0 = itemPanel:getChildByName("devoteTxt0")
    local devoteTxt = itemPanel:getChildByName("devoteTxt")
    local rewardBtn = itemPanel:getChildByName("rewardBtn")
    
    local isShow = false
    if index == 0 then
        isShow = true

        local needDevote = info.contrineed
        local color = ColorUtils.wordGreenColor
        if needDevote > self._haveNum then
            color = ColorUtils.wordRedColor
        end
        devoteTxt:setColor(color)
        devoteTxt:setString(needDevote)

        self._rewardBtn = rewardBtn
        self._rewardBtn.getId = self._getId
        self:addTouchEventListener(self._rewardBtn,self.onRewardBtnTouch)        

        local iscangetWelf = rawget(self.welfareInsfos,"iscangetWelf")
        if iscangetWelf then
            if iscangetWelf == 0 then
                NodeUtils:setEnable(rewardBtn, true)
                rewardBtn:setVisible(true)
                rewardBtn:setTitleText(self:getTextWord(3416))
            else
                NodeUtils:setEnable(rewardBtn, false)
                rewardBtn:setVisible(true)
                rewardBtn:setTitleText(self:getTextWord(3417))
            end
        end

    end
    rewardBtn:setVisible(isShow)
    devoteTxt0:setVisible(isShow)
    devoteTxt:setVisible(isShow)

    NodeUtils:centerNodesGlobal(rewardBtn,{devoteTxt0,devoteTxt})

    local itemList = itemPanel:getChildByName("itemList")
    self:renderListView(itemList, info.rewardList, self, self.renderRewardIcons)
end

-- 渲染道具
function LegionWelfareDailyPanel:renderRewardIcons(itemPanel,info)
    local iconImg = itemPanel:getChildByName("iconImg")
    local data = ConfigDataManager:getRewardConfigById(info[1])
    local icon = iconImg.icon
    if icon == nil then
        icon = UIIcon.new(iconImg,data,true,self)
        iconImg.icon = icon
    else
        icon:updateData(data)
    end 
    icon:setShowName(true)
    -- local txt = itemPanel:getChildByName("txt")
    -- txt:setString(icon:getName())
end

-- function LegionWelfareDailyPanel:updateList(level,devote)
--     self:updateMainList(level,devote)
-- end


--获取配置表数据
function LegionWelfareDailyPanel:getConfData(level)
    local configData = ConfigDataManager:getConfigDataBySortId(ConfigData.WelfareRewardConfig)
    
    local allReward = {}
    local tmpReward = {}
    local minLv,maxLv,curID = nil,nil,nil

    for k,v in pairs(configData) do
        minLv = v.welfarelvmin
        maxLv = v.welfarelvmax
        
        -- 解析json
        v.rewardList = {}
        local reward = StringUtils:jsonDecode(v.reward)
        for index,item in pairs(reward) do
            table.insert(v.rewardList,{item})
        end

        if level >= minLv and level <= maxLv then
            curID = v.ID
            table.insert(allReward,v)  --当前奖励
        else
            table.insert(tmpReward,v)
        end
    end

    if table.size(allReward) == 0 then
        logger:error("legionWelfare reward is nil !!!")
        return allReward
    else
        local info = configData[curID+1]
        if info ~= nil then
            table.insert(allReward,info)  --下一级奖励
            
            local isLeader = self:getRoleJobInLegion()
            if isLeader == true then
                table.sort( tmpReward, function(a, b) return a.ID > b.ID end )
                for _,v in pairs(tmpReward) do
                    if v.ID ~= info.ID then
                        table.insert(allReward,v)
                    end
                end
            end    
        else
            print("nextReward is nil ! ")
        end
    end
    
    return allReward
end

-----------------------回调函数定义----------------------------

--领取
function LegionWelfareDailyPanel:onRewardBtnTouch(sender)
    print("LegionWelfareDailyPanel:onRewardBtnTouch(sender)",sender.getId)
    local data = {}
    data.type = 3
    data.canGetId = sender.getId
    self.view:dispatchEvent(LegionWelfareEvent.GET_WELFARE_REQ,data)
end

--等级提升
function LegionWelfareDailyPanel:onUpgrateBtnTouch(sender)
    print("LegionWelfareDailyPanel:onUpgrateBtnTouch(sender)")
    local function okCallback()
        self.view:dispatchEvent(LegionWelfareEvent.WELFARE_UP_REQ,nil)
    end
    --弹出确认提示框
    local tempStr = self:getTextWord(3404)
    self:showMessageBox(tempStr,okCallback)
end 
