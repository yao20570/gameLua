module("battleCore", package.seeall)

MoveBackAction = class("MoveBackAction", SkillAction)

function MoveBackAction:onEnter(skill)
    MoveBackAction.super.onEnter(self, skill)
    
    self._attackerEnt = skill:getOwner()
    local pos = self._attackerEnt:getSpawPos()

    local function moveEnd()
        self:endAction()
    end

    self._attackerEnt:moveTo(pos, 400, moveEnd)
end

function MoveBackAction:moveEnd()
    self:endAction()
end