module("battleCore", package.seeall)

EffectFactory = class("EffectFactory")

local instance = nil

function EffectFactory:ctor()

end

function EffectFactory:getInstance()
    if instance == nil then
        instance = EffectFactory.new()
    end

    return instance
end

function EffectFactory:finalize()
    instance = nil
end

function EffectFactory:getEffectByType(effectType)
    local effect = nil
    local effectType = effectType or "BloodMinusEffect"
    if effectType == "BloodMinusEffect" then
        effect = BloodMinusEffect
    elseif effectType == "BloodRateEffect" then
        effect = BloodRateEffect
    elseif effectType == "BloodCritEffect" then
        effect = BloodCritEffect
    elseif effectType == "BloodRefrainEffect" then
        effect = BloodRefrainEffect
    end
    

    return effect
end