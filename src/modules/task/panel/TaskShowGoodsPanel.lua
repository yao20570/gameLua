-- 战功奖励宝箱弹窗
TaskShowGoodsPanel = class("TaskShowGoodsPanel")


TaskShowGoodsPanel.BTN_YELLOW_NORMAL = "images/newGui1/BtnMiniYellow1.png"
TaskShowGoodsPanel.BTN_YELLOW_PRESSE = "images/newGui1/BtnMiniYellow2.png"
TaskShowGoodsPanel.BTN_GREEN_NORMAL = "images/newGui1/BtnMiniGreed1.png"
TaskShowGoodsPanel.BTN_GREEN_PRESSE = "images/newGui1/BtnMiniGreed2.png"

function TaskShowGoodsPanel:ctor(parent, panel)
    local uiSkin = UISkin.new("TaskShowGoodsPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(640, 960))
    layout:setAnchorPoint(cc.p(0.5,0.5))
    local winSize = cc.Director:getInstance():getWinSize()
    layout:setPosition(winSize.width/2, winSize.height/2)
    parent:addChild(layout)
    local secLvBg = UISecLvPanelBg.new(layout, self)
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setContentHeight(320)
    uiSkin:setParent(parent)
    self._parent = layout
    self._uiSkin = uiSkin
    self._panel = panel
    self.secLvBg = secLvBg
    self:initUi()
    self:initEvent()
    -- self.secLvBg:hideCloseBtn(false)
    
end

function TaskShowGoodsPanel:initUi()
    self.secLvBg:setTitle("战功奖励宝箱")
    self.ListView_1 = self:getChildByName("mainPanel/ListView_1")
    self.bgImg = self:getChildByName("mainPanel/bgImg")
    self.sureBtn = self:getChildByName("mainPanel/sureBtn")
    self.mainPanel = self:getChildByName("mainPanel")
end

function TaskShowGoodsPanel:initEvent()
    local closebtn = self.secLvBg:getCloseBtn()
    closebtn:setVisible(false)
    ComponentUtils:addTouchEventListener(self.sureBtn, self.onSureBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(self.mainPanel, self.hide, nil, self)
end

function TaskShowGoodsPanel:onSureBtnTouch(sender)
    logger:info("sender.ID %d",sender.ID)
    self._taskProxy:onTriggerNet190004Req(sender.ID)
    if type(self.callfunc) == "function" then
        self.callfunc()
    end
    self:hide()   
end

function TaskShowGoodsPanel:hide()
    self._uiSkin:setVisible(false)
    self._parent:setVisible(false)
end

function TaskShowGoodsPanel:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function TaskShowGoodsPanel:updateInfos(info,taskProxy,callfunc)
    self.callfunc = callfunc
    self._taskProxy = taskProxy
    self._uiSkin:setVisible(true)
    self._parent:setVisible(true)   
    self:updateGoods(info)

    local currentActive = taskProxy:getExploitValue()
    self.sureBtn:setTitleText("领  取")
    NodeUtils:setEnable(self.sureBtn, false)  
    TextureManager:updateButtonNormal(self.sureBtn, TaskShowGoodsPanel.BTN_GREEN_NORMAL)
    TextureManager:updateButtonPressed(self.sureBtn, TaskShowGoodsPanel.BTN_GREEN_PRESSE)
    if info.activeneed <= currentActive then
        NodeUtils:setEnable(self.sureBtn, true)   
        TextureManager:updateButtonNormal(self.sureBtn, TaskShowGoodsPanel.BTN_YELLOW_NORMAL)
        TextureManager:updateButtonPressed(self.sureBtn, TaskShowGoodsPanel.BTN_YELLOW_PRESSE)
        self.sureBtn.ID = info.ID
        if info.isAlreadyReward == true then
            NodeUtils:setEnable(self.sureBtn, false)  
			TextureManager:updateButtonNormal(self.sureBtn, TaskShowGoodsPanel.BTN_GREEN_NORMAL)
			TextureManager:updateButtonPressed(self.sureBtn, TaskShowGoodsPanel.BTN_GREEN_PRESSE)
            self.sureBtn:setTitleText("已领取")            
        end
    end
end

function TaskShowGoodsPanel:updateGoods(info,taskProxy)
    local data = RewardManager:jsonRewardGroupToArray(info.fixreward)

    --2016年11月7日16:24:24
    --加多个restype字段奖励
    if info.restype ~= 0 then
        local buildProxy = self._panel:getProxy(GameProxys.Building)
        local buildingInfo = buildProxy:getBuildingInfo(info.buildType, 1)
        local config = ConfigDataManager:getConfigById(ConfigData.ActiveResConfig, buildingInfo.level)
        table.insert(data, {num = config.activelv, power = 407, typeid = info.restype})
    end

    local roleproxy = self._panel:getProxy(GameProxys.Role)
    local expAdd = roleproxy:getRoleAttrValue(PlayerPowerDefine.POWER_exploitsAdd) or 0
    local percent = 1+expAdd/100
    -- logger:info("战功经验加成==", percent, expAdd)
    if info.expreward == 1 then
        local expNum = 0
        local expInfo = ConfigDataManager:getConfigById(ConfigData.ActiveExpConfig, info.lv)
        expNum = expInfo.activelv*percent
        if self._panel:getProxy(GameProxys.RealName):isShowDebuff() then
            local debuff = self._panel:getProxy(GameProxys.RealName):getDebuff()
            expNum = math.floor( expNum *(1- debuff) )
            logger:error("任务奖励未实名惩罚生效")
        end

        table.insert(data,{num = expNum,power = 407,typeid = 101})
        
    end
    ComponentUtils:renderAllGoods(self.ListView_1,self.bgImg, self.secLvBg, self.sureBtn,data, self._panel)
    --self.sureBtn:setPositionY(self.sureBtn:getPositionY() - 10)
end

