
ProvExamRewardPanel = class("ProvExamRewardPanel", BasicPanel)
ProvExamRewardPanel.NAME = "ProvExamRewardPanel"

function ProvExamRewardPanel:ctor(view, panelName)
    ProvExamRewardPanel.super.ctor(self, view, panelName)

end

function ProvExamRewardPanel:finalize()
    ProvExamRewardPanel.super.finalize(self)
end

function ProvExamRewardPanel:initPanel()
	ProvExamRewardPanel.super.initPanel(self)
    self.proxy = self:getProxy(GameProxys.ExamActivity)
    self._listView = self:getChildByName("ListView")
    
    self.hasGotBtn = self:getChildByName("bottonPanel/hasGotBtn")
    self:addTouchEventListener(self.hasGotBtn , self.onHasGotBtnHandler)    
    self.getBtn = self:getChildByName("bottonPanel/getBtn")
    self:addTouchEventListener(self.getBtn, self.onGetBtnHandler)  
    self.tipImg = self:getChildByName("bottonPanel/getBtn/tipImg")  

end

function ProvExamRewardPanel:doLayout()
    local downPanel = self:getChildByName("bottonPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView, downPanel, tabsPanel,GlobalConfig.topTabsHeight)
end

function ProvExamRewardPanel:registerEvents()
	ProvExamRewardPanel.super.registerEvents(self)
end
function ProvExamRewardPanel:onShowHandler()
    ProvExamRewardPanel.super.onShowHandler(self)
    self:updateListView()
end 

function ProvExamRewardPanel:updateListView()
    local provEaxmAllRewardArray = self.proxy:getProvEaxmAllRewardArray()
    self:renderListView(self._listView, provEaxmAllRewardArray, self, self.renderItemPanel)

    --领奖
    local hasReward,state = self.proxy:getProvExamHasRewardAndState()--0不可领，1，可领，2已领取
    self.tipImg:setVisible(hasReward == 1)
    self.getBtn:setVisible(hasReward ~= 2)
    --增加领取小红点判断，当乡试状态为0答题中时，屏蔽小红点
    if state == 2 then
        self.tipImg:setVisible(false)
    end
    --积分
    local integral = self.proxy:getCurIntegral()
    local lastSroceLab = self:getChildByName("bottonPanel/lastSroceLab")
    lastSroceLab:setString(integral)
end
function ProvExamRewardPanel:renderItemPanel(itemPanel, info, index)
    local nameLab = itemPanel:getChildByName("index_label")
    local itemArr  = {}
    local itemImg1 = itemPanel:getChildByName("itemImg1")
    table.insert(itemArr,itemImg1)
    local itemImg2 = itemPanel:getChildByName("itemImg2")
    table.insert(itemArr,itemImg2)
    local itemImg3 = itemPanel:getChildByName("itemImg3")
    table.insert(itemArr,itemImg3)
    
    if info.integral1 == info.integral2 then
        nameLab:setString(string.format("%d%s",info.integral1,self:getTextWord(360022)))
    else
        nameLab:setString(string.format("%d%s%d%s",info.integral1,self:getTextWord(360017),info.integral2,self:getTextWord(360023)))
    end

    local rewardArr = StringUtils:jsonDecode(info.reward)
    for i,v in ipairs(itemArr) do
        v:setVisible(false)
    end
    local materialDataTable = rewardArr
    local roleProxy = self:getProxy(GameProxys.Role)
    for i=1,#rewardArr do
        local haveNum =  roleProxy:getRolePowerValue(materialDataTable[i][1], materialDataTable[i][2])
        --self:renderChild(itemArr[i], haveNum, materialDataTable[i][3])
        local iconData = {}
        iconData.typeid = materialDataTable[i][2]
        iconData.num = materialDataTable[i][3]
        iconData.power = materialDataTable[i][1]
        if itemArr[i].uiIcon == nil then
            itemArr[i].uiIcon = UIIcon.new(itemArr[i], iconData, true, self, nil, true)
        else
            itemArr[i].uiIcon:updateData(iconData)
        end
        itemArr[i]:setVisible(true)
    end

end

function ProvExamRewardPanel:onHasGotBtnHandler(sender)
    self:showSysMessage(self:getTextWord(360008))
end

function ProvExamRewardPanel:onGetBtnHandler()
    self.proxy:onTriggerNet370004Req()
end
