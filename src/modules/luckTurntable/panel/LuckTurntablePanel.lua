-- /**
--  * @Author:
--  * @DateTime:    2017-07-12 00:00:00
--  * @Description: 幸运轮盘
--  */
LuckTurntablePanel = class("LuckTurntablePanel", BasicPanel)
LuckTurntablePanel.NAME = "LuckTurntablePanel"

LuckTurntablePanel.RotateState_Start = 1
LuckTurntablePanel.RotateState_Run = 2
LuckTurntablePanel.RotateState_Result = 3
LuckTurntablePanel.RotateState_End = 3

LuckTurntablePanel.Reward_Num = 8

local InitAngle = 360 / LuckTurntablePanel.Reward_Num
local Round = 7
local BasicAngle = 360 * Round - InitAngle / 2
local CCBTime = 4.6 -- 给的特效时间

function LuckTurntablePanel:ctor(view, panelName)
    LuckTurntablePanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function LuckTurntablePanel:finalize()

    LuckTurntablePanel.super.finalize(self)
end

function LuckTurntablePanel:initPanel()
    LuckTurntablePanel.super.initPanel(self)

    self:setBgType(ModulePanelBgType.ACTIVITY)

    self:setTitle(true, "xingyunlunpan", true)

    self._proxy = self:getProxy(GameProxys.LuckTurntable)

    self._topPanel = self:getChildByName("topPanel")
    local imgInfoBg1 = self._topPanel:getChildByName("imgInfoBg1")
    self._txtActivityTime = imgInfoBg1:getChildByName("txtActivityTime")
    self._txtActivityInfo = imgInfoBg1:getChildByName("txtActivityInfo")
    self._txtActivityInfo:setColor(cc.c3b(244,244,244))

    local imgInfoBg2 = self._topPanel:getChildByName("imgInfoBg2")
    self._lab1 = imgInfoBg2:getChildByName("lab1")
    self._txtGold = imgInfoBg2:getChildByName("txtGold")
    self._txtTip = imgInfoBg2:getChildByName("txtTip")


    local panelPlayerInfo = self._topPanel:getChildByName("panelPlayerInfo")
    self._txtRemainTimes = panelPlayerInfo:getChildByName("txtRemainTimes")

    self._btnFree = panelPlayerInfo:getChildByName("btnFree")
    self._btnStart = panelPlayerInfo:getChildByName("btnStart")
    self._btnRecharge = panelPlayerInfo:getChildByName("btnRecharge")
    self._btnTimes = panelPlayerInfo:getChildByName("btnTimes")

    -- 奖励图片容器
    local imgTurntable = self._topPanel:getChildByName("imgTurntable")
    self._imgInner1 = imgTurntable:getChildByName("imgInner1")
    self._imgInner2 = imgTurntable:getChildByName("imgInner2")
    self._imgPointer = imgTurntable:getChildByName("imgPointer")
    local panelCenter = imgTurntable:getChildByName("panelCenter")
    self._rewardIcons = { }
    for i = 1, LuckTurntablePanel.Reward_Num do
        self._rewardIcons[i] = panelCenter:getChildByName("icon" .. i)
    end
end

function LuckTurntablePanel:registerEvents()
    LuckTurntablePanel.super.registerEvents(self)

    self:addTouchEventListener(self._btnFree, self.onStart)
    self:addTouchEventListener(self._btnStart, self.onStart)
    self:addTouchEventListener(self._btnRecharge, self.onRecharge)
    self:addTouchEventListener(self._btnTimes, self.onBtnTimes)
end

function LuckTurntablePanel:doLayout()

end

function LuckTurntablePanel:onShowHandler()
    self._rotateAngle = nil
    self:setStartRotate(false)

    local activityProxy = self:getProxy(GameProxys.Activity)
    self._curActivityData = activityProxy:getCurActivityData()

    self:updateActivityInfoUI()

    -- 奖励icon
    self:renderIcon()
end

function LuckTurntablePanel:onClosePanelHandler()
    if self:isStartRotate() == true then
        self:showSysMessage(TextWords:getTextWord(520001))
    else
        self:hide()
        self._curActivityData = nil
        self.view:dispatchEvent(LuckTurntableEvent.HIDE_SELF_EVENT)
    end
end

function LuckTurntablePanel:setStartRotate(isStart)
    self._isStart = isStart
end

function LuckTurntablePanel:isStartRotate()
    return self._isStart or false
end

function LuckTurntablePanel:updateActivityInfoUI(awardId)
    -- 活动时间
    self._txtActivityTime:setString(self._proxy:getActivityTimeStr())

    -- 活动信息
    self._txtActivityInfo:setString(self._curActivityData.info)

    -- 当前剩余充值
    self._txtGold:setString(self._proxy:getRemainRecharge(self._curActivityData.activityId))

    -- 提示
    local luckTurntableActivityCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.LuckyCoronaConfig, "effectID", self._curActivityData.effectId)
    local strTip = string.format(self:getTextWord(520003), luckTurntableActivityCfg.chargeAmount)
    self._txtTip:setString(strTip)

    NodeUtils:alignNodeL2R(self._lab1, self._txtGold, self._txtTip, 5)

    -- 剩余次数
    self._txtRemainTimes:setString(self._proxy:getRemainTimes(self._curActivityData.activityId))

    -- 显示开始或充值按钮
    local free = self._proxy:getFreeRemainTimes(self._curActivityData.activityId)
    local times = self._proxy:getRemainTimes(self._curActivityData.activityId)

    self._btnRecharge:setVisible(times == 0) -- 次数为0 显示充值
    self._btnFree:setVisible(free > 0) -- 有免费，显示免费
    
    -- 中间都不显示时，显示两边
    if self._btnRecharge:isVisible() == false and self._btnFree:isVisible() == false then
        self._btnStart:setVisible(true)
        self._btnTimes:setVisible(true)
    else
        self._btnStart:setVisible(false)
        self._btnTimes:setVisible(false)
    end


    if awardId ~= nil then
        self:playTurntable(awardId)
    end
end

function LuckTurntablePanel:renderIcon()
    local luckTurntableActivityCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.LuckyCoronaConfig, "effectID", self._curActivityData.effectId)

    self._awardDatas = ConfigDataManager:getInfosFilterByFunc(ConfigData.CurrentRewardConfig, function(data)
        return data.rewardgroup == luckTurntableActivityCfg.rewardID
    end )

    for i = 1, LuckTurntablePanel.Reward_Num do
        local ary = StringUtils:jsonDecode(self._awardDatas[i].item)
        local data = { }
        data.power = ary[1][1]
        data.typeid = ary[1][2]
        data.num = ary[1][3]

        if self._rewardIcons[i].icon == nil then
            self._rewardIcons[i].icon = UIIcon.new(self._rewardIcons[i], data, true, self)
        else
            self._rewardIcons[i].icon:updateData(data)
        end
    end
end

-- 播放轮盘
function LuckTurntablePanel:playTurntable(awardId)
    self._recAwardId = awardId
    self:setStartRotate(true)
    self._index = nil
    for k, v in pairs(self._awardDatas) do
        if v.ID == awardId then
            self._index = k
            break
        end
    end

    if self._index ~= nil then
        self._rotateAngle = BasicAngle + self._index * InitAngle
    end

    self:rotatePointer()
end

function LuckTurntablePanel:playEnd()
    local rewardData = self._proxy:getRewardInfos()

    function callback()
        self._imgPointer:setRotation(0)
        self:setStartRotate(false)
    end

    if self.uiResourceGet == nil then
        self.uiResourceGet = UIGetProp.new(self:getParent(), self, true, callback)
    end
    self.uiResourceGet:show(rewardData, callback)
end

function LuckTurntablePanel:rotatePointer()

    if self._rotateAngle == nil then
        return
    end

    local pointerSize = self._imgPointer:getContentSize()
    local ccbZP = UICCBLayer.new("rpg-xingyunzhuanpan", self._imgPointer, nil, nil, true)
    ccbZP:setPositionX(pointerSize.width / 2)
    ccbZP:setPositionY(pointerSize.height)

    local imgInnerSize = self._imgInner1:getContentSize()
    local ccbGQ = UICCBLayer.new("rpg-xyzp-gq", self._imgInner1, nil, nil, true)
    ccbGQ:setPositionX(imgInnerSize.width / 2)
    ccbGQ:setPositionY(imgInnerSize.height / 2)

    local seq1 = cc.Sequence:create(cc.RotateTo:create(0.3, math.random(2, 5)), cc.RotateTo:create(0.3, math.random( -5,-2)))
    local rep = cc.RepeatForever:create(seq1)
    self._imgInner2:runAction(rep)


    local a1 = cc.EaseSineInOut:create(cc.RotateBy:create(CCBTime, self._rotateAngle))
    local a2 = cc.CallFunc:create( function()
        self._imgInner2:stopAllActions()
        self:createUICCBLayer("rpg-zp-hq", self._rewardIcons[self._index], nil, nil, true)
    end )
    local a3 = cc.DelayTime:create(1)
    local a4 = cc.CallFunc:create( function() self:playEnd() end)
    local seq = cc.Sequence:create(a1, a2, a3, a4)
    self._imgPointer:runAction(seq)
end

function LuckTurntablePanel:onStart(sender)
    if self:isStartRotate() == true then
        -- 轮盘在旋转
        self:showSysMessage(TextWords:getTextWord(520001))
        return
    end

    local data = {}
    data.activityId = self._curActivityData.activityId
    data.type = 1
    self._proxy:onTriggerNet230057Req( data)
end

function LuckTurntablePanel:onBtnTimes(sender)
    
    if self:isStartRotate() == true then
        -- 轮盘在旋转
        self:showSysMessage(TextWords:getTextWord(520001)) -- "正在抽奖中，请稍后！"
        return
    end
    local typeValue = 10
    local free = self._proxy:getFreeRemainTimes(self._curActivityData.activityId)
    local times = self._proxy:getRemainTimes(self._curActivityData.activityId)
    if times < typeValue then
        self:showSysMessage(TextWords:getTextWord(520004)) -- "剩余次数不足"
        return
    end

    local data = {}
    data.activityId = self._curActivityData.activityId
    data.type = typeValue -- 十连抽
    self._proxy:onTriggerNet230057Req( data)
end



function LuckTurntablePanel:onRecharge(sender)
    if self:isStartRotate() == true then
        -- 轮盘在旋转
        self:showSysMessage(TextWords:getTextWord(520001))
        return
    end

    ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
end