module("battleCore", package.seeall)

BloodRateEffect = class("BloodRateEffect")

function BloodRateEffect:ctor( ... )

end

function BloodRateEffect:finalize()
    self.callback = nil
end

function BloodRateEffect:play(node, delay, callback, dir, actionTime, curCount, fCount, hurtType)
    self.callback = callback
    dir = dir or 1
    self._actionTime = actionTime or 1.2
    node:setVisible(true)
    self:round1(node, delay, dir)
end

function BloodRateEffect:round1(node, delay, dir)
    local x, y = node:getPosition()
    node:setVisible(false)

    local function round2()
        self:round2(node, dir)
    end

    local function visible()
        node:setVisible(true)
    end
    
--    visible()

    local function endAction()
        self:endAction(node)
    end
    
    
    local scaleTo = cc.ScaleTo:create(self._actionTime, 2)
    local action = cc.Sequence:create(cc.DelayTime:create(delay) ,cc.CallFunc:create(visible), scaleTo, cc.CallFunc:create(endAction))

--    local move = cc.MoveTo:create(self._actionTime / 4, cc.p(x, y + 28 * dir)) --+ gameutils:getValueBySign(93, dir)
--    local action = cc.Sequence:create(cc.DelayTime:create(delay) ,cc.CallFunc:create(visible), move, cc.CallFunc:create(round2))

    node:runAction(action)
end

function BloodRateEffect:round2(node, dir)
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

function BloodRateEffect:endAction(node)
    if self.callback ~= nil then
        self.callback()
    end
    self:finalize()
end