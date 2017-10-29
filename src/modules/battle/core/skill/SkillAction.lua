module("battleCore", package.seeall)

SkillAction = class("SkillAction")

function SkillAction:ctor()

end

function SkillAction:onEnter(skill)
    self.skill = skill
end

function SkillAction:actionEffect(ent, effectInfo, callback)
    local type = effectInfo[1]
    if type == "effect" then

        -- local effectName = effectInfo[2]
        -- ent:playEffect(effectName, effectInfo[3], effectInfo[4], effectInfo[5])   --创建并播放特效(攻击/受击/)   callback参数其实没有用到

        if effectInfo[5] > 0 then
            self.skill:addTimerOnce(effectInfo[5], self.delayPlayEffect, self, effectInfo[2], effectInfo[3], effectInfo[4], effectInfo[5], ent)
        else
            ent:playEffect(effectInfo[2], effectInfo[3], effectInfo[4], effectInfo[5])   --创建并播放特效(攻击/受击/)   callback参数其实没有用到
        end


    elseif type == "characterColor" then
        ent:characterColor(effectInfo[4], effectInfo[5], effectInfo[6])
    elseif type == "sound" then
        if effectInfo[3] ~= nil and effectInfo[3] > 0 then
            self.skill:addTimerOnce(effectInfo[3], self.delayPlaySound, self, effectInfo[2], effectInfo[3])
        else
            self:playSound(effectInfo[2])
        end

    elseif type == "backgroundColor" then
        local time = (effectInfo[3] - effectInfo[2]) / 100
        ent:backgroundColorAction(effectInfo[4], effectInfo[5], effectInfo[6], effectInfo[7], time)
    elseif type == "formationtab" then
        ent:changeZhenfa(tonumber(effectInfo[2]), effectInfo[3], callback)   --改变阵法
    end
end

-- 延时播放特效
function SkillAction:delayPlayEffect(effectName, dx, dy, delay, parent)
    logger:info("== 00 延时播放特效 name:%s, delay:%s ==",effectName,delay)
    parent:playEffect(effectName, dx, dy, delay)
end

-- 延时播放音效
function SkillAction:delayPlaySound(name)
    -- logger:info("== 00 延时播放音效 name:%s,delay:%s ==",name,delay)
    self:playSound(name)
end

function SkillAction:playSound(name)
    AudioManager:playEffect(name)
end

function SkillAction:endAction()
    -- TimerManager:addOnce(100, self.delayNextAction, self)
    self.skill:addTimerOnce(100, self.delayNextAction, self)
end

function SkillAction:delayNextAction()
    self.skill:nextAction()
end