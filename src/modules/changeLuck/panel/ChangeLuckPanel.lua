-- /**
--  * @Author:      wzy
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 招财转运
--  */
ChangeLuckPanel = class("ChangeLuckPanel", BasicPanel)
ChangeLuckPanel.NAME = "ChangeLuckPanel"

ChangeLuckPanel.Show_Type1 = 1
ChangeLuckPanel.Show_Type2 = 2

local RotateRound = 5


local NormalSpeed = 0.07
local AddSpeed = 0.02   -- 每次增加或减少时间
local MaxAddSpeedTimes = 8 -- 缓动次数

function ChangeLuckPanel:ctor(view, panelName)
    ChangeLuckPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function ChangeLuckPanel:finalize()
    if self._ccbgq ~= nil then
        self._ccbgq:finalize()
        self._ccbgq = nil
    end

    ChangeLuckPanel.super.finalize(self)
end

function ChangeLuckPanel:initPanel()
    ChangeLuckPanel.super.initPanel(self)

    self:setBgType(ModulePanelBgType.ACTIVITY)

    self:setTitle(true, "ZhaoCaiZhuanYun", true)

    self._proxy = self:getProxy(GameProxys.ChangeLuck)

    self._iconPosMap = { }
    self._iconPosMap[8] = {
        { 173, 397 },
        { 319, 452 },
        { 468, 398 },
        { 523, 251 },
        { 467, 100 },
        { 320, 46 },
        { 173, 102 },
        { 118, 251 },
    }

    self._iconPosMap[12] = {
        { 213, 455 },
        { 320, 489 },
        { 425, 455 },
        { 517, 361 },
        { 583, 245 },
        { 517, 131 },
        { 425, 38 },
        { 320, 3 },
        { 213, 38 },
        { 121, 132 },
        { 54, 245 },
        { 121, 361 },
    }

    local mainPanel = self:getChildByName("mainPanel")
    local imgInfoBg1 = mainPanel:getChildByName("imgInfoBg1")

    self._txtActivityTime = imgInfoBg1:getChildByName("txtActivityTime")
    self._txtActivityInfo = imgInfoBg1:getChildByName("txtActivityInfo")
    self._txtActivityInfo:setColor(cc.c3b(244,244,244))

    local panelBtn = mainPanel:getChildByName("panelBtn")
    self._btnRecharge1 = panelBtn:getChildByName("btnRecharge1")
    self._btnRecharge1.showType = ChangeLuckPanel.Show_Type1
    self._btnRecharge1.urlDown = "images/changeLuck/BtnYellowDown.png"
    self._btnRecharge1.urlNormal = "images/changeLuck/BtnYellowNormal.png"

    self._btnRecharge2 = panelBtn:getChildByName("btnRecharge2")
    self._btnRecharge2.showType = ChangeLuckPanel.Show_Type2
    self._btnRecharge2.urlDown = "images/changeLuck/BtnRedDown.png"
    self._btnRecharge2.urlNormal = "images/changeLuck/BtnRedNormal.png"

    self._imgRed1 = self._btnRecharge1:getChildByName("imgRed")
    self._imgRed2 = self._btnRecharge2:getChildByName("imgRed")
    self._txtRed1 = self._imgRed1:getChildByName("txtRed")
    self._txtRed2 = self._imgRed2:getChildByName("txtRed")


    local panelIcon = mainPanel:getChildByName("panelIcon")
    local imgDot = panelIcon:getChildByName("imgDot")

    self._imgBgCenter = imgDot:getChildByName("imgBgCenter")

    self._btnFree = imgDot:getChildByName("btnFree")
    self._btnStart = imgDot:getChildByName("btnStart")
    self._btnRecharge = imgDot:getChildByName("btnRecharge")

    self._txtRemainTimes = imgDot:getChildByName("txtRemainTimes")

    self._iconBgMap = { }
    for i = 1, 12 do
        self._iconBgMap[i] = panelIcon:getChildByName("iconBg" .. i)
    end

end

function ChangeLuckPanel:registerEvents()
    ChangeLuckPanel.super.registerEvents(self)

    self:addTouchEventListener(self._btnRecharge1, self.onChangeType, self.onTouchBegan)
    self._btnRecharge1.cancelCallback = function() 
        self:onTouchCancel(self._btnRecharge1) 
    end

    self:addTouchEventListener(self._btnRecharge2, self.onChangeType, self.onTouchBegan)
    self._btnRecharge2.cancelCallback = function() 
        self:onTouchCancel(self._btnRecharge2) 
    end

    self:addTouchEventListener(self._btnRecharge, self.onRecharge)
    self:addTouchEventListener(self._btnStart, self.onStart)
    self:addTouchEventListener(self._btnFree, self.onStart)
end

function ChangeLuckPanel:onShowHandler()

    local activityProxy = self:getProxy(GameProxys.Activity)

    -- 当前活动数据
    self._curActivityData = activityProxy:getCurActivityData()

    -- 当前活动的配置表
    self._curActivityCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.FortuneConfig, "effectID", self._curActivityData.effectId)

    -- 打开默认显示类型8
    self:setShowType(ChangeLuckPanel.Show_Type1)

    -- 更新面板
    self:updateUI()

end

function ChangeLuckPanel:onClosePanelHandler()
    if self:isStartRotate() == true then
        self:showSysMessage(TextWords:getTextWord(530001))
    else
        self:hide()
        self._curActivityData = nil
        self._curActivityCfg = nil
        self.view:dispatchEvent(ChangeLuckEvent.HIDE_SELF_EVENT)
    end
end

function ChangeLuckPanel:setStartRotate(isStart)
    self._isStart = isStart

    if isStart then

    end

    for k, v in pairs(self._iconBgMap) do
        local icon = v.icon
        if icon then
            icon:setTouchEnabled(isStart == false)
        end
    end
end

function ChangeLuckPanel:isStartRotate()
    return self._isStart or false
end

function ChangeLuckPanel:updateUI(awardId)
    local curActivityId = self._curActivityData.activityId
    
    -- 红点
    local times1, times2 = self._proxy:getTimes(curActivityId)    
    self._imgRed1:setVisible(times1 > 0)
    self._imgRed2:setVisible(times2 > 0)
    self._txtRed1:setString(times1)
    self._txtRed2:setString(times2)

    -- 活动时间
    self._txtActivityTime:setString(self._proxy:getActivityTimeStr())

    -- 活动信息
    self._txtActivityInfo:setString(self._curActivityData.info)


    -- 按钮文本
    local chargeCfg = ConfigDataManager:getConfigById(ConfigData.ChargeConfig, self._curActivityCfg.chargeAmount1)
    local strRecharge1 = string.format(self:getTextWord(530000), chargeCfg.limit * 10)
    self._btnRecharge1:setTitleText(strRecharge1)

    local chargeCfg2 = ConfigDataManager:getConfigById(ConfigData.ChargeConfig, self._curActivityCfg.chargeAmount2)
    local strRecharge2 = string.format(self:getTextWord(530000), chargeCfg2.limit * 10)
    self._btnRecharge2:setTitleText(strRecharge2)

    self:setShowType(self:getShowType())

    if awardId ~= nil then
        self:playAction(awardId)
    end
end

function ChangeLuckPanel:getShowType()
    return self._curShowType or ChangeLuckPanel.Show_Type1
end


function ChangeLuckPanel:setShowType(showType)

    self._curShowType = showType
    
    local curActivityId = self._curActivityData.activityId
    local times1, times2 = self._proxy:getTimes(curActivityId)   
    local free1, free2 = self._proxy:getFreeRemainTimes(curActivityId)   

     -- 开始和重置按钮显示
    local times = 0
    local free = 0
    if showType == ChangeLuckPanel.Show_Type1 then
        times = times1
        free = free1
    else
        times = times2
        free = free2
    end

    self._btnFree:setVisible(free > 0)
    self._btnStart:setVisible(free == 0 and times > 0)
    self._btnRecharge:setVisible(times == 0)

    -- 获取对应的iocn配置
    local awardDatas = nil
    if showType == ChangeLuckPanel.Show_Type1 then
        awardDatas = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CurrentRewardConfig, "rewardgroup", self._curActivityCfg.rewardID1)
        
        local scaleTo = cc.ScaleTo:create(0.1, 1)
        self._btnRecharge1:stopAllActions()
        self._btnRecharge1:runAction(scaleTo)
        self._btnRecharge1:loadTextureNormal(self._btnRecharge1.urlDown, 1)
        
        local scaleTo = cc.ScaleTo:create(0.1, 0.8)
        self._btnRecharge2:stopAllActions()
        self._btnRecharge2:runAction(scaleTo)
        self._btnRecharge2:loadTextureNormal(self._btnRecharge2.urlNormal, 1)

        self._txtRemainTimes:setString(times1)
    else
        awardDatas = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CurrentRewardConfig, "rewardgroup", self._curActivityCfg.rewardID2)

        local scaleTo = cc.ScaleTo:create(0.1, 0.8)
        self._btnRecharge1:stopAllActions()
        self._btnRecharge1:runAction(scaleTo)
        self._btnRecharge1:loadTextureNormal(self._btnRecharge1.urlNormal, 1)
        
        local scaleTo = cc.ScaleTo:create(0.1, 1)
        self._btnRecharge2:stopAllActions()
        self._btnRecharge2:runAction(scaleTo)
        self._btnRecharge2:loadTextureNormal(self._btnRecharge2.urlDown, 1)

        self._txtRemainTimes:setString(times2)
    end

    -- 获取对应的位置表
    local posMap = self._iconPosMap[#awardDatas]

    -- 遍历设置icon
    for k, v in pairs(self._iconBgMap) do
        local iconBg = v
        local pos = posMap[k]
        if pos ~= nil and awardDatas[k] ~= nil then
            iconBg:setVisible(true)
            iconBg:setPositionX(pos[1])
            iconBg:setPositionY(pos[2])

            local ary = StringUtils:jsonDecode(awardDatas[k].item)
            local data = { }
            data.power = ary[1][1]
            data.typeid = ary[1][2]
            data.num = ary[1][3]

            if iconBg.icon == nil then
                iconBg.icon = UIIcon.new(v, data, true, self, false, true)
            else
                iconBg.icon:updateData(data)
            end
            iconBg.awardCfg = awardDatas[k]
        else
            iconBg:setVisible(false)
            iconBg.awardCfg = nil
        end
    end

end

function ChangeLuckPanel:playAction(awardId)
    self._recAwardId = awardId
    self:setStartRotate(true)

    if self._ccbgq == nil then
        local imgBgCenterSize = self._imgBgCenter:getContentSize()
        self._ccbgq = self:createUICCBLayer("rpg-zp-gq", self._imgBgCenter)
        self._ccbgq:setPositionX(imgBgCenterSize.width / 2)
        self._ccbgq:setPositionY(imgBgCenterSize.height / 2)
    end
    self._ccbgq:setVisible(true)


    if self:getShowType() == ChangeLuckPanel.Show_Type1 then
        awardDatas = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CurrentRewardConfig, "rewardgroup", self._curActivityCfg.rewardID1)
    else
        awardDatas = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CurrentRewardConfig, "rewardgroup", self._curActivityCfg.rewardID2)
    end
    local num = #awardDatas
    self._curIndex = 0
    self._maxIndex = num * RotateRound + self:getAwardIndex(awardId) - 1


    local function callback()

        local index = self._curIndex % num + 1

        if self._curIndex < self._maxIndex then
            local dt = NormalSpeed
            if self._curIndex < MaxAddSpeedTimes then
                -- 开始缓动
                dt =(MaxAddSpeedTimes - self._curIndex) * AddSpeed + NormalSpeed
            elseif self._maxIndex - self._curIndex < MaxAddSpeedTimes then
                -- 结束缓动
                dt =(MaxAddSpeedTimes -(self._maxIndex - self._curIndex)) * AddSpeed + NormalSpeed
            end


            local a1 = cc.DelayTime:create(dt)
            local f1 = cc.CallFunc:create(callback)
            local seq = cc.Sequence:create(a1, f1)
            self._iconBgMap[index]:runAction(seq)
            local bgSize = self._iconBgMap[index]:getContentSize()
            local ccb = self:createUICCBLayer("rpg-zp-zd", self._iconBgMap[index], nil, nil, true)
            ccb:setPositionX(bgSize.width / 2)
            ccb:setPositionY(bgSize.height / 2)
            self._curIndex = self._curIndex + 1
        else

            local function openGetProp()
                if self.uiResourceGet == nil then
                    self.uiResourceGet = UIGetProp.new(self:getParent(), self, true)
                end

                local rewardData = { }
                local awardCfg = self._iconBgMap[index].awardCfg
                local ary = StringUtils:jsonDecode(awardCfg.item)
                local data = { }
                data.power = ary[1][1]
                data.typeid = ary[1][2]
                data.num = ary[1][3]
                table.insert(rewardData, data)

                self.uiResourceGet:show(rewardData)

                self:setStartRotate(false)
            end


            local function playEndCCB()
                local bgSize = self._iconBgMap[index]:getContentSize()
                local ccb = self:createUICCBLayer("rpg-zp-hq", self._iconBgMap[index], nil, nil, true)
                ccb:setPositionX(bgSize.width / 2)
                ccb:setPositionY(bgSize.height / 2)
                self._ccbgq:setVisible(false)
            end


            local bgSize = self._iconBgMap[index]:getContentSize()
            local ccb = self:createUICCBLayer("rpg-zp-zd", self._iconBgMap[index], nil, nil, true)
            ccb:setPositionX(bgSize.width / 2)
            ccb:setPositionY(bgSize.height / 2)


            local a1 = cc.DelayTime:create(0.2)
            local f1 = cc.CallFunc:create(playEndCCB)
            local a2 = cc.DelayTime:create(2)
            local f2 = cc.CallFunc:create(openGetProp)
            local seq = cc.Sequence:create(a1, f1, a2, f2)
            self._iconBgMap[index]:runAction(seq)
        end
    end

    callback()
end

function ChangeLuckPanel:getAwardIndex(awardId)
    for k, v in pairs(self._iconBgMap) do
        logger:info("===============>awardId:%s, v.data.ID:%s", awardId, v.awardCfg.ID)
        if v.awardCfg and v.awardCfg.ID == awardId then

            return k
        end
    end

    logger:error("awardId is not exist")
    return 1
end


function ChangeLuckPanel:onChangeType(sender)
    if self:isStartRotate() == true then
        -- 轮盘在旋转
        self:showSysMessage(TextWords:getTextWord(520001))
        return
    end

    local showType = sender.showType

    self:onTouchCancel(sender)

    self:setShowType(showType)

--    local scaleTo = cc.ScaleTo:create(0.1, 1)
--    sender:stopAllActions()
--    sender:runAction(scaleTo)

end

function ChangeLuckPanel:onTouchBegan(sender)
--    local scaleTo = cc.ScaleTo:create(0.1, 1)
--    sender:stopAllActions()
--    sender:runAction(scaleTo)
end

function ChangeLuckPanel:onTouchCancel(sender)
--    local scaleTo = cc.ScaleTo:create(0.1, 0.7)
--    sender:stopAllActions()
--    sender:runAction(scaleTo)
end

function ChangeLuckPanel:onStart(sender)
    if self:isStartRotate() == true then
        -- 轮盘在旋转
        self:showSysMessage(TextWords:getTextWord(520001))
        return
    end

    local reqData = { }
    reqData.activityId = self._curActivityData.activityId
    reqData.type = self:getShowType()

    self._proxy:onTriggerNet230059Req(reqData)
end

function ChangeLuckPanel:onRecharge(sender)
    if self:isStartRotate() == true then
        -- 轮盘在旋转
        self:showSysMessage(TextWords:getTextWord(520001))
        return
    end

    ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
end