module("battleCore", package.seeall)

--一般的减血飘字
BloodMinusEffect = class("BloodMinusEffect")

function BloodMinusEffect:ctor( ... )

end

function BloodMinusEffect:play(node, delay, callback, dir, actionTime, curCount, fCount, hurtType)
    
    local function complete()
        callback()
    end
    
    node:setScale(0.5)
    local action1 = cc.ScaleTo:create(actionTime / 4, 0.9)
    local action2 = cc.ScaleTo:create(actionTime / 4 * 3, 1)
    
    local action = cc.Sequence:create(action1, action2, cc.CallFunc:create(complete) )
    node:runAction(action)
    
end
