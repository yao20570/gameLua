BattleBossResultPanel = class("BattleBossResultPanel", BasicPanel)
BattleBossResultPanel.NAME = "BattleBossResultPanel"

function BattleBossResultPanel:ctor(view, panelName)
    BattleBossResultPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function BattleBossResultPanel:finalize()
    -- self._spineModel:finalize()
    if self._ccbGuang ~= nil then
        self._ccbGuang:finalize()
        self._ccbGuang = nil
    end
    BattleBossResultPanel.super.finalize(self)
end

function BattleBossResultPanel:initPanel()
    BattleBossResultPanel.super.initPanel(self)
    
    self._mainPanel = self:getChildByName("panelNode/mainPanel")
    self._ccbGuang = nil
    self._ccbTitle = nil
end

function BattleBossResultPanel:onReplayReq(sender)
    if sender.id == nil then
        return
    end
    local battleProxy = self:getProxy(GameProxys.Battle)
    local battleData = battleProxy:getBattleDataById(sender.id)
    if battleData ~= nil then
        local data2 = {}
        battleProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.BattleModule})
        battleProxy:onTriggerNet50000Resp(battleData)
    end
    
    -- local battleId = StringUtils:int32ToFixed64(sender.id)
    -- mailProxy:onTriggerNet160005Req({battleId = battleId})
end

----------------------------------------------------------------------
function BattleBossResultPanel:onUpdateBattleResult(data)
    local replayBtn = self:getChildByName("panelNode/mainPanel/replayBtn")
    replayBtn.id = data.battle.id
    self:addTouchEventListener(replayBtn, self.onReplayReq)

    local roleProxy = self:getProxy(GameProxys.Role)  
    if data.saveTraffic == 1 then --不看战斗, 隐藏重播按钮
        replayBtn:setVisible(false)
    else
        replayBtn:setVisible(true)
    end

    self:updateView(data)
       
end

function BattleBossResultPanel:updateView(data)
    self._mainPanel = self:getChildByName("panelNode/mainPanel")
    --入场动画
    self:enterAnimation()
    --播放特效
    --self:playEffects()

    local curBtType = data.battle.type
    local MyDamage = data.damage
    --伤害
    local labDamageNum = self:getChildByName("panelNode/mainPanel/labHurtNum")
    labDamageNum:setString(MyDamage)
    local labDamage = self:getChildByName("panelNode/mainPanel/labHurt")
    --重置伤害位置
    local diff = (640 - labDamageNum:getContentSize().width - labDamage:getContentSize().width) * 0.5
    labDamage:setPositionX(diff - 320)
    labDamageNum:setPositionX(320 - diff)

    -- 世界boss战斗中的数值显示
    if curBtType == GameConfig.battleType.world_boss then
        local rewardInfo = data.battle.reward.rewardInfo
        for i=1,4 do
            local rewardItem = self:getChildByName("panelNode/mainPanel/rewardPanel/item"..i)
            rewardItem:setVisible(true)
            if rewardInfo[i] ~= nil then
                local icon = rewardItem.icon
                if icon == nil then
                    icon = UIIcon.new(rewardItem, rewardInfo[i], true, self, _, _, _, _, BattleBossResultPanel.PANEL_ACTION_TIME)
                    rewardItem.icon = icon
                else
                    icon:updateData(rewardInfo[i])
                end
                icon:setIconCenter()
                icon:setShowName(true)
            end
           
        end
    end

    
end

function BattleBossResultPanel:registerEvents()
    local exitBtn = self:getChildByName("panelNode/mainPanel/exitBtn")
    self:addTouchEventListener(exitBtn, self.onExitBattleTouch)
end

function BattleBossResultPanel:onExitBattleTouch(sender, callArg)
    if callArg == nil then
        TimerManager:addOnce(40, self.delayHideSelf, self)
    else
        self:dispatchEvent(BattleEvent.HIDE_SELF_EVENT, {})
    end
end

function BattleBossResultPanel:delayHideSelf()
    self:dispatchEvent(BattleEvent.HIDE_SELF_EVENT, {})
end

function BattleBossResultPanel:playEffects()
    local size = self._mainPanel:getContentSize()
    if self._ccbGuang == nil then
        self._ccbGuang = UICCBLayer.new("rgb-tfzj-guang", self._mainPanel)
        self._ccbGuang:getLayer():setLocalZOrder(-1)
        self._ccbGuang:setPosition(size.width/2, size.height/2 + 12)
    end
    if self._ccbTitle ~= nil then
        self._ccbTitle:removeFromParent()
    end


    self._ccbTitle = UICCBLayer.new("rgb-tfzj-zi", self._mainPanel)
    self._ccbTitle:getLayer():setLocalZOrder(100)
    self._ccbTitle:setPosition(size.width/2, size.height/2 + 190)
end

function BattleBossResultPanel:enterAnimation()
    self._mainPanel:setScale(0.4)
    local replayBtn = self:getChildByName("panelNode/mainPanel/replayBtn")
    local exitBtn = self:getChildByName("panelNode/mainPanel/exitBtn")
    replayBtn:setOpacity(0)
    exitBtn:setOpacity(0)

    local function callback()
        replayBtn:runAction(cc.FadeTo:create(0.5, 255))
        exitBtn:runAction(cc.FadeTo:create(0.5, 255))
        
        --播放特效
        self:playEffects()
    end
    local action = cc.Sequence:create(cc.ScaleTo:create(0.15, 1.2), cc.ScaleTo:create(0.1, 1), cc.CallFunc:create(callback))
    self._mainPanel:runAction(action)
end