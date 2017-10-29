module("battleCore", package.seeall)


RecoverAction = class("RecoverAction", SkillAction)

function RecoverAction:onEnter(skill)
    RecoverAction.super.onEnter(self, skill)
    
    self._attackerEnt = skill:getOwner()
    --阵法还原

    local function callback()
        self:endAction()
    end

    local defaultZhenfa = self._attackerEnt:getDefaultZhenfa()
    self._attackerEnt:changeZhenfa(defaultZhenfa, 200, callback)
end