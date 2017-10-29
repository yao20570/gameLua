module("battleCore", package.seeall)

ReadyAction = class("ReadyAction", SkillAction)

function ReadyAction:onEnter(skill)
    ReadyAction.super.onEnter(self, skill)
    
    self._attackerEnt = skill:getOwner()
    --先变阵
    local skillConfig = skill:getConfig()
    
    local function callback()
        self:endAction()
    end
    
    local readyaction = skillConfig.readyaction
    self:skillEffect(self._attackerEnt,readyaction,callback)
end

function ReadyAction:skillEffect(ent, effectInfos, callback)
    for _, effectInfo in pairs(effectInfos) do
        self:actionEffect(ent, effectInfo, callback) --
    end
end

