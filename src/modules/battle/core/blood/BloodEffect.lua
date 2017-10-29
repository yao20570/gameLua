module("battleCore", package.seeall)

BloodEffect = {}

function BloodEffect:play(args)
    local x = args["x"]
    local y = args["y"] 
    local value = args["value"]
    local hurtType = args["hurtType"]
    local parent = args["parent"] 
    local actionTime = args["actionTime"]
    local effectType = HurtEffectType[hurtType]
    local callback = args["callback"]
    local effectNode = args["effectNode"]
    local curCount = args["curCount"]
    local fCount = args["fCount"]
    local item = effectNode
--    local item = NumFactory:getInstance():getNumByType(hurtType, value)
    if item == nil then
        logger:error("-----blood-effect---item---------nil--------")
        return
    end
    
--    item:setVisible(true)
--    parent:addChild(item)
--    item:setPosition(cc.p(x, y))
--    item:setLocalZOrder(1000)
    
    local effect = EffectFactory:getInstance():getEffectByType(effectType)

    local function release()
--        if item:getParent() ~= nil then
--            parent:removeChild(item)
--        end         
--        item = nil
        callback()
    end

    -- tip：第一次扣血飘字时 curCount = 2
    local delay = 50
    effect:play(item, delay / 1000,  release, nil, actionTime, curCount, fCount, hurtType)
end
