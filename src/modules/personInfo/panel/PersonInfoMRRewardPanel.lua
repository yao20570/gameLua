 --个人信息技能界面
--FZW 
--2015/11/25
PersonInfoMRRewardPanel = class("PersonInfoMRRewardPanel", BasicPanel)  
PersonInfoMRRewardPanel.NAME = "PersonInfoMRRewardPanel"

function PersonInfoMRRewardPanel:ctor(view, panelName)
    PersonInfoMRRewardPanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function PersonInfoMRRewardPanel:finalize()
    PersonInfoMRRewardPanel.super.finalize(self)
end

function PersonInfoMRRewardPanel:onHideHandler()
    self.view:onShowAllPanel()
end

function PersonInfoMRRewardPanel:initPanel()
    PersonInfoMRRewardPanel.super.initPanel(self)
    -- self:setBgType(ModulePanelBgType.BLACKFULL)
    self:setTitle(true,"fengshang",true)
    
    self._conf = ConfigDataManager:getConfigDataBySortId(ConfigData.PrestigeGiveConfig)
    self._rewardFlag = nil --0:可封赏 1：已封赏

    self._listview = self:getChildByName("ListView_1")

end

function PersonInfoMRRewardPanel:doLayout()
    -- local topAdaptivePanel = self:topAdaptivePanel()
    -- NodeUtils:adaptivePanelBg(self._uiPanelBg._bgImg5, GlobalConfig.downHeight, topAdaptivePanel)

    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, tabsPanel)
    
    local ListView_1 = self:getChildByName("ListView_1")
    NodeUtils:adaptiveListView(ListView_1, GlobalConfig.downHeight, topPanel, 3)
end

-- 每次panel:show都会执行onShowHandler
function PersonInfoMRRewardPanel:onShowHandler(info)

    local topPanel = self:getChildByName("topPanel")
    local tipTxt = topPanel:getChildByName("tipTxt")
    tipTxt:setString(self:getTextWord(516))


    self.view:onHiteAllPanel()

    -- 判定声望是否满级
    local roleProxy = self:getProxy(GameProxys.Role)
    local prestigeLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_prestigeLevel) or 0--声望等级
    if prestigeLevel >= 80 then
        _isMaxLv = true
    else
        _isMaxLv = false
    end        

    -- 从代理获取封赏状态
    self._index = 2 
    local prestigeState = roleProxy:getPrestigeState()
    self._rewardFlag = prestigeState

    self:renderListView(self._listview, self._conf, self, self.onRenderListViewInfo)

end

function PersonInfoMRRewardPanel:onRenderListViewInfo(itempanel,info)
    itempanel:setVisible(true)

    local itemBtn = itempanel:getChildByName("itemBtn")
    local Label_name = itemBtn:getChildByName("Label_name")
    local Label_detail122 = itemBtn:getChildByName("Label_detail122")
    local labPay = itemBtn:getChildByName("labPay")
    local rewardBtn = itemBtn:getChildByName("rewardBtn")
    -- local Button_132 = itemBtn:getChildByName("Button_132")

    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = info.icon
    iconInfo.num = 0

    local icon = itempanel.icon
    if icon == nil then
        local iconImg = itemBtn:getChildByName("iconImg")
        icon = UIIcon.new(iconImg,iconInfo,false)
        
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end

    
    Label_name:setString(info.name)
    local price = StringUtils:jsonDecode(info.price)
    local string = string.format(self:getTextWord(523))
    local pay = price[2]
    if price[1] == 201 then
        pay = pay..self:getTextWord(524)
    elseif price[1] == 206 then
        pay = pay..self:getTextWord(525)
    end
    Label_detail122:setString(string)
    labPay:setString(pay)
    NodeUtils:alignNodeL2R(Label_detail122,labPay)

    if self._rewardFlag == 0 then 
        --未封赏
        -- Button_132:setVisible(false)
        -- rewardBtn:setVisible(true)
        rewardBtn:setTitleText(self:getTextWord(510))
        -- rewardBtn:setTouchEnabled(true)
        rewardBtn.ID = info.ID
        rewardBtn.price = price
        self:addTouchEventListener(rewardBtn,self.onTouchItemBtn)
    else
        --已封赏
        -- rewardBtn:setVisible(false)
        -- rewardBtn:setTouchEnabled(false)
        -- Button_132:setVisible(true)
        -- Button_132:setTitleText(self:getTextWord(518))
        rewardBtn:setTitleText(self:getTextWord(518))
        NodeUtils:setEnable(rewardBtn,false)
    end
    -- table.insert(self._btnList,rewardBtn)
    -- table.insert(self._btnList2,Button_132)
end

function PersonInfoMRRewardPanel:onTouchItemBtn(sender)
    -- body
    if _isMaxLv == true then
        self:showSysMessage(self:getTextWord(552)) --声望满级提示
    else
        if sender.price[1] == 206 then
            self:MessageBox(sender)
        else
            local data = {}
            data.type = sender.ID
            data.index = self._index
            self.view:onSendItemBtn(data)
        end
    end

end

--  对话框
function PersonInfoMRRewardPanel:MessageBox(sender)
    -- body
    local function okCallBack()
        local function callFunc()
            local data = {}
            data.type = sender.ID
            data.index = self._index
            self.view:onSendItemBtn(data)
        end
        sender.callFunc = callFunc
        sender.money = sender.price[2]
        self:isShowRechargeUI(sender)

    end


    local content = string.format(self:getTextWord(560),sender.price[2])
    self:showMessageBox(content,okCallBack)
end

-- 是否弹窗元宝不足
function PersonInfoMRRewardPanel:isShowRechargeUI(sender)
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

function PersonInfoMRRewardPanel:onMRRewardListInfo(data)
	-- body
    for index=0,3 do
        item = self._listview:getItem(index)
        if item == nil then
            self._listview:pushBackDefaultItem()
            item = self._listview:getItem(index)
        end
        self:registerItemEvents(item,data,index)
        index = index + 1
    end

end

function PersonInfoMRRewardPanel:onMRRewardResp(data)
    self._rewardFlag = 1
    self:onShowHandler()
    -- for k,v in pairs(self._btnList) do
    --     -- v:setVisible(false)
    -- end
    -- for k,v in pairs(self._btnList2) do
    --     v:setVisible(true)
    -- end
end


function PersonInfoMRRewardPanel:onClosePanelHandler()
    self:hide()    
end

function PersonInfoMRRewardPanel:onShowMRRewardResp(data)
    -- body
    self._rewardFlag = data
end