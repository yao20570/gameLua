module("battleCore", package.seeall)

--预攻击、蓄力阶段
PreAttackAction = class("PreAttackAction", SkillAction)

function PreAttackAction:onEnter(skill)
    PreAttackAction.super.onEnter(self, skill)
    
    local function callback()
        self:endAction()
    end

    self._attackerEnt = skill:getOwner()
    --先变阵
    local skillConfig = skill:getConfig()
    
    
    callback()
    local preattackaction = skillConfig.preattackaction or {}
    self:skillEffect(self._attackerEnt,preattackaction,callback)
    
end

function PreAttackAction:skillEffect(ent, effectInfos, callback)
    for _, effectInfo in pairs(effectInfos) do
        self:actionEffect(ent, effectInfo, callback) --
    end
end
