-- 日常任务
DailyTaskPanel = class("DailyTaskPanel", BasicPanel)
DailyTaskPanel.NAME = "DailyTaskPanel"

function DailyTaskPanel:ctor(view, panelName)
    DailyTaskPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function DailyTaskPanel:finalize()
    DailyTaskPanel.super.finalize(self)
end

function DailyTaskPanel:initPanel()
	DailyTaskPanel.super.initPanel(self)
    -- self._listview = {}
    self._conf = self:initConfigData(ConfigData.DayMissionConfig)
    self._taskProxy = self:getProxy(GameProxys.Task)

    local listview = self:getChildByName("ListView_1")
    NodeUtils:adaptive(listview)
    self._listview = listview
    

    local down_Panel = self:getChildByName("down_Panel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(listview,down_Panel,tabsPanel,GlobalConfig.topTabsHeight)
end

function DailyTaskPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("down_Panel")
    DailyTaskPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function DailyTaskPanel:initConfigData(configTab)
    -- body
    local conf = ConfigDataManager:getConfigDataBySortId(configTab)
    local info = {}

    for k,v in pairs(conf) do
        info[v.ID] = v
    end
    return info
end

--status=false:已完成次数<5,弹框是否快速完成  status=true:已完成5次，弹框是否重置次数
function DailyTaskPanel:getTaskStatus(dailyNumber, tabData)
    -- body
    local status = false

    if dailyNumber >= 5 then
        local s = true
        for k,v in pairs(tabData) do
            if v.accept ~= 0 or v.state ~= 0 then
                s = false
                break
            end
        end
        status = s
    end

    return status
end

function DailyTaskPanel:onShowHandler()
    -- body
    -- if self._listview ~= nil then
    --     self._listview = {}
    -- end
    -- self._listview = {}
    self._listview:jumpToTop()

    local tabData,dailyNumber,dailyStatus = self:getTaskData()
    self._tabData = tabData
    self._dailyNumber = dailyNumber
    self._dailyStatus = dailyStatus

    self._goBtnStatus = self:getTaskStatus(dailyNumber, tabData)
    self:onButtomPanel(tabData, dailyNumber, dailyStatus)

    local listview = self:getChildByName("ListView_1")
    -- local data = ConfigDataManager:getConfigDataBySortId("DayMissionConfig")
    self:renderListView(listview, tabData, self, self.onRenderListViewInfo)
end

function DailyTaskPanel:onButtomPanel(tabData, dailyNumber, dailyStatus)
    -- body
    local down_Panel = self:getChildByName("down_Panel")
    local countTxt = down_Panel:getChildByName("countTxt")
    local tipTxt = down_Panel:getChildByName("tipTxt")
    local chgBtn = down_Panel:getChildByName("chgBtn")
    local resetBtn = down_Panel:getChildByName("resetBtn")
    local Image_26 = down_Panel:getChildByName("Image_26")
    local Label_27 = Image_26:getChildByName("Label_27")

    local num = nil
    if dailyNumber >= 5 then
        num = 5
    else
        num = dailyNumber
    end
    
    countTxt:setString(string.format(self:getTextWord(1316),num))
    tipTxt:setString(self:getTextWord(1317))

    chgBtn:setTitleText(self:getTextWord(1309))
        
    for k,v in pairs(tabData) do
        v.dailyNumber = dailyNumber
        if v.accept == 1 then
            chgBtn.info = v
            resetBtn.info = v
            break
        end
        resetBtn.info = v
    end

    if dailyNumber < 5 then
        local price = GlobalConfig.dailyTaskRefreshPrice
        Label_27:setString(tostring(price))
        resetBtn:setTitleText(self:getTextWord(1310))
        -- NodeUtils:setEnable(resetBtn,true)
        -- self:addTouchEventListener(resetBtn,self.onResetBtn)
    else
        local price = GlobalConfig.dailyTaskResetPrice
        Label_27:setString(tostring(price))
        resetBtn:setTitleText(self:getTextWord(1320))
    end


    if dailyStatus == 2 then
        NodeUtils:setEnable(resetBtn, false)
        NodeUtils:setEnable(chgBtn, false)
    elseif dailyStatus == 1 then
        NodeUtils:setEnable(resetBtn, false)
        NodeUtils:setEnable(chgBtn, true)
        self:addTouchEventListener(chgBtn,self.onGiveUpBtn)
    else 
        NodeUtils:setEnable(chgBtn, false)
        NodeUtils:setEnable(resetBtn, true)
        self:addTouchEventListener(resetBtn,self.onResetBtn)
    end

end


function DailyTaskPanel:onRenderListViewInfo(itempanel,info,index)
    -- body
 	self:onRenderItem(itempanel,info,index)
    -- table.insert( self._listview, itempanel )
end

function DailyTaskPanel:onRenderItem(itempanel,info,index)
	-- body
	itempanel:setVisible(true)

    local conf = self._conf[info.typeId]

    -- local itempanel = itempanel:getChildByName("itempanel")
    local name = itempanel:getChildByName("name")
    local tipBtn = itempanel:getChildByName("tipBtn")
    local goBtn = itempanel:getChildByName("goBtn")
    local rewardBtn = itempanel:getChildByName("rewardBtn")
    local priceImg = itempanel:getChildByName("priceImg")
    local price = priceImg:getChildByName("price")
    local Panel_star = itempanel:getChildByName("Panel_star")
    local progress = itempanel:getChildByName("progress")
    local curProgress = itempanel:getChildByName("curProgress") --当前进度
    local maxProgress = itempanel:getChildByName("maxProgress") --总进度

    -- local icon = itempanel:getChildByName("icon")

    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = conf.icon
    iconInfo.num = 0
    -- local icon = UIIcon.new(icon,iconInfo,false)	
    local icon = itempanel.icon
    if icon == nil then
        local iconImg = itempanel:getChildByName("icon")
        icon = UIIcon.new(iconImg,iconInfo,false)        
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end
    icon:setTouchEnabled(false)


    for i=1,5,1 do
        local star = Panel_star:getChildByName("star"..i)
        star:setVisible(false)
    end
    local max = info.star
    for i=1,max,1 do
        local star = Panel_star:getChildByName("star"..i)
        star:setVisible(true)
    end


    progress:setVisible(false)
    curProgress:setVisible(false)
    maxProgress:setVisible(false)

    name:setString(conf.name)
    -- name:setColor(ColorUtils.wordOrangeColor)

    local size = name:getContentSize()
    local x = name:getPositionX()
    tipBtn:setPositionX(x + size.width + 20)
    
    rewardBtn:setVisible(false)
    
    goBtn.info = info
    if info.accept == 0 then --未接受
        priceImg:setVisible(false)
        if self._dailyStatus == 1 or self._dailyStatus == 2 then
            -- tipBtn:setVisible(false)
            goBtn:setVisible(false)
        else
            goBtn:setVisible(true)
            -- tipBtn:setVisible(true)
            goBtn:setTitleText(self:getTextWord(1308))
            self:addTouchEventListener(goBtn,self.onGoBtn)
        end
        elseif info.accept == 1 then --已接受
            if info.state == 1 then
                -- 可领奖
                priceImg:setVisible(false)
                -- tipBtn:setVisible(false)
                goBtn:setVisible(false)
                rewardBtn:setVisible(true)
                rewardBtn.info = info
                rewardBtn:setTitleText(self:getTextWord(1318))
                self:addTouchEventListener(rewardBtn,self.onRewardBtn)

            else
                -- 未完成
                local curNum = info.num
                local maxNum = conf.finishcond2
                local color = nil
                if curNum >= maxNum then
                    curNum = maxNum
                    color = ColorUtils.wordColorDark03
                else
                    color = ColorUtils.wordColorDark04
                end
                curProgress:setColor(color)

                curProgress:setString(info.num)
                maxProgress:setString("/"..conf.finishcond2)
                progress:setVisible(true)
                curProgress:setVisible(true)
                maxProgress:setVisible(true)
                local progressX = progress:getPositionX()
                local size = progress:getContentSize()
                local curSize = curProgress:getContentSize()
                local curX = progressX + size.width
                local maxX = curX + curSize.width
                curProgress:setPositionX(curX) 
                maxProgress:setPositionX(maxX)


                -- tipBtn:setVisible(true)
                rewardBtn:setVisible(false)
                goBtn:setTitleText(self:getTextWord(1312))
                local priceStr = 5
                price:setString(priceStr)
                priceImg:setVisible(true)
                self:addTouchEventListener(goBtn,self.onGoBtn)
            end
        end

    -- tipBtn.info = info
    -- tipBtn.conf = conf
    -- self:addTouchEventListener(tipBtn,self.onTipBtn)

    itempanel.info = info
    itempanel.conf = conf
    self:addTouchEventListener(itempanel,self.onTipBtn)

end
---------------------------------------------------------------------
--button touch event
function DailyTaskPanel:onRewardBtn(sender)
    local info = sender.info
    local sendData = {}
    sendData.tableType = 2
    sendData.typeId = info.typeId
    self._taskProxy:onTriggerNet190001Req(sendData)
end

function DailyTaskPanel:onGiveUpBtn(sender)
    -- body

    local info = sender.info
    local sendData = {}
    sendData.type = 2
    sendData.typeId = info.typeId

    self._taskProxy:onTriggerNet190002Req(sendData)
end

function DailyTaskPanel:onResetBtn(sender)
    -- body
    local info = sender.info
    local sendData = {}
    local price = nil
    local textID = nil
    if info.dailyNumber < 5 then
        sendData.type = 4
        sendData.typeId = info.typeId
        price = 5
        textID = 1321
        self:onMessageBox(sendData,price,textID,sender) --刷新任务
    else
        sendData.type = 3
        sendData.typeId = info.typeId
        price = 25
        textID = 1322
        self:onMessageBox(sendData,price,textID,sender) --重置任务次数
    end

end

-- 通用弹框
-- 重置任务次数弹框
-- 快速完成弹框
function DailyTaskPanel:onMessageBox(sendData,price,textID,sender)
    -- body
    local function okCallBack()

        local function callFunc()
            -- 请求购买自动升级建筑
            self._taskProxy:onTriggerNet190002Req(sendData)
        end
        sender.callFunc = callFunc
        sender.money = price
        self:isShowRechargeUI(sender)
    end


    local content = string.format(self:getTextWord(textID),price)
    self:showMessageBox(content,okCallBack)
end

-- 是否弹窗元宝不足
function DailyTaskPanel:isShowRechargeUI(sender)
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


function DailyTaskPanel:onGoBtn(sender)
    -- body
    if self._goBtnStatus == true then
        self:onResetBtn(sender)
        return
    end
    
    local info = sender.info
    local accept = info.accept
    local sendData = {}
    sendData.typeId = info.typeId

    if accept == 0 then
        sendData.type = 1
        -- self.view:onTaskDailyReq(sendData)
        self._taskProxy:onTriggerNet190002Req(sendData)
        elseif accept == 1 then
            sendData.type = 5
            local price = 5
            local textID = 1331
            self:onMessageBox(sendData,price,textID,sender)
    end

end

function DailyTaskPanel:onTipBtn(sender)
    -- body
    local info = sender.info
    info.conf = sender.conf
    info.TASKTYPE = 1
    self.view:openTipView(info)    
end

function DailyTaskPanel:getTaskData()
	-- body
	local tabData = {}
    -- local taskProxy = self:getProxy(GameProxys.Task)
    tabData = self._taskProxy:getDailyTaskList() --真实数据
    local dailyNumber = self._taskProxy:getDailyFinishNumber() or 0
    local dailyStatus = self._taskProxy:getDailyStatus() or 0
	return tabData,dailyNumber,dailyStatus
end

function DailyTaskPanel:onUpdateTaskInfoResp(data)
    -- body
end
