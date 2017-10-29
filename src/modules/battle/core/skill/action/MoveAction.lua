module("battleCore", package.seeall)

MoveAction = class("MoveAction", SkillAction)

function MoveAction:onEnter(skill)
    MoveAction.super.onEnter(self, skill)
    
    self._attackerEnt = skill:getOwner()
    -- self._dir = self._attackerEnt:getDirection()
    self._dir = self._attackerEnt:getDirFromExchangeCamp()  --根据阵营转为朝向
    
    local targets = skill:getTargets()
    local target = targets[1]
    
    local targetEnt = PuppetFactory:getInstance():getEntity(target.index)
    --朝这方向移动
    local x, y = targetEnt:getPosition()
    
    local function moveEnd()
        self:endAction()
    end
    
    self._attackerEnt:moveTo(cc.p(x + self._dir * 100, y), 400, moveEnd)
    
end


function MoveAction:moveEnd()
    self:endAction()
    
end