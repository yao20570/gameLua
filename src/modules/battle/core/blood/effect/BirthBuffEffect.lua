module("battleCore", package.seeall)

--出生Buff特效
BirthBuffEffect = class("BirthBuffEffect")

function BirthBuffEffect:ctor( ... )

end

function BirthBuffEffect:finalize()
    self.callback = nil
end

function BirthBuffEffect:play(node, delay, callback, dir, actionTime)
    self.callback = callback

    dir = dir or 1
    self._actionTime = actionTime or 1.2
    node:setVisible(true)
    self:round1(node, delay, dir)
end

function BirthBuffEffect:round1(node, delay, dir)
    local x, y = node:getPosition()
    node:setVisible(false)

    local function round2()
        self:round2(node, dir)
    end

    local function visible()
        node:setVisible(true)
    end

    node:setScale(0.1)
    local move = cc.MoveTo:create(self._actionTime / 4, cc.p(x, y + 28 * dir)) --+ gameutils:getValueBySign(93, dir)
    local scaleAction = cc.ScaleTo:create(self._actionTime / 4, 1)
    local spawn = cc.Spawn:create(move, scaleAction)
    local action = cc.Sequence:create(cc.DelayTime:create(delay) ,
        cc.CallFunc:create(visible), spawn, cc.CallFunc:create(round2))

    node:runAction(action)
end

function BirthBuffEffect:round2(node, dir)
    local x, y = node:getPosition()

    local function endAction()
        self:endAction(node)
    end

    local move = cc.MoveTo:create(self._actionTime / 4 * 3, cc.p(x  , y + 75* dir)) --+ gameutils:getValueBySign(79, dir)
    local fadeTo = cc.FadeTo:create(self._actionTime / 4 * 3, 0)
    local spawn = cc.Spawn:create(move, fadeTo)
    local action = cc.Sequence:create(spawn, cc.CallFunc:create(endAction))

    node:runAction(action)
end

function BirthBuffEffect:endAction(node)
    if self.callback ~= nil then
        self.callback()
    end
    self:finalize()
end