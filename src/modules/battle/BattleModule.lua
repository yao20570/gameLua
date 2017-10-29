
BattleModule = class("BattleModule", BasicModule)

function BattleModule:ctor()
    BattleModule .super.ctor(self)
    
    self.showActionType = ModuleShowType.Animation
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil
    
    self.isFullScreen = true
    
    self.hideRemoveEvent = false
    
    self:initRequire()
end

function BattleModule:initRequire()
    require("modules.battle.event.BattleEvent")
    require("modules.battle.view.BattleView")
    
    --Battle
    require("modules.battle.core.const.BattleConst")
    require("modules.battle.core.Battle")
    require("modules.battle.core.Puppet")
    require("modules.battle.core.Bullet")
    require("modules.battle.core.PuppetFactory")
    
    require("modules.battle.core.Round")
    require("modules.battle.core.skill.SkillAction")
    require("modules.battle.core.skill.Skill")
    require("modules.battle.core.skill.action.MoveAction")
    require("modules.battle.core.skill.action.AttackAction")
    require("modules.battle.core.skill.action.MoveBackAction")
    require("modules.battle.core.skill.action.ReadyAction")
    require("modules.battle.core.skill.action.RecoverAction")
    require("modules.battle.core.skill.action.PreAttackAction")
    -- require("modules.battle.core.skill.action.BattleAction")
    
    require("modules.battle.core.blood.factories.NumFactory")
    require("modules.battle.core.blood.factories.EffectFactory")
    require("modules.battle.core.blood.effect.BloodMinusEffect")
    require("modules.battle.core.blood.effect.BloodRateEffect")
    require("modules.battle.core.blood.effect.BirthBuffEffect")
    require("modules.battle.core.blood.effect.BloodCritEffect")
    require("modules.battle.core.blood.effect.BloodRefrainEffect")
    require("modules.battle.core.blood.BloodEffect")
    
end

function BattleModule:finalize()
    BattleModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function BattleModule:initModule()
    BattleModule.super.initModule(self)
    self._view = BattleView.new(self.parent)

    self:addEventHandler()
    
    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_TOP)
end

function BattleModule:addEventHandler()
    self._view:addEventListener(BattleEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(BattleEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Battle, AppEvent.PROXY_BATTLE_END, self, self.onBattleEnd)
end

function BattleModule:removeEventHander()
    self._view:removeEventListener(BattleEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(BattleEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Battle, AppEvent.PROXY_BATTLE_END, self, self.onBattleEnd)
end

----------------------
function BattleModule:onOpenModule(extraMsg)
    extraMsg = extraMsg or {}
    local battleData = extraMsg.battleData
    self:onGetBattleResp(battleData)
    
    self:hideAllLayerExcept(self.uiLayerName,GameLayer.topLayer)
end

function BattleModule:onHideModule()
    if self._battle == nil then
        return
    end
    self:resetLayers()
    
    local isReqBattleEnd = false
    if self._battle ~= nil then
        isReqBattleEnd = self._battle:isReqBattleEnd()
        self._battle:finalize()
    end
    self._battle = nil
    
    if self:isModuleShow(ModuleName.DungeonModule) then --先这样写了
        AudioManager:playDungeonMusic()
    else
        AudioManager:playSceneMusic()
    end
    
    --TODO 请求战斗结束 可能会提前请求
    if isReqBattleEnd == true then
        local battleProxy = self:getProxy(GameProxys.Battle)
        local battleId = battleProxy:getCurBattleId()
        local battleType = battleProxy:getCurBattleType()
        -- 2016年8月17日14:11:27修改  战斗类型为世界boss的时候不需要请求战斗结束
        -- if battleType ~= GameConfig.battleType.world_boss then
            battleProxy:onTriggerNet50001Req({id = battleId})
        -- end
    end
end

---------------------------------------
function BattleModule:onGetBattleResp(data)
    
    self._battle = battleCore.Battle.new(self)
    self._battle:startBattle(data)
end

function BattleModule:onBattleEnd(data)
    self._view:onBattleEndOpenFun()
end

-------------------------------

function BattleModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function BattleModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end




