module("battleCore", package.seeall)

Round = class("Round")  --回合

function Round:ctor(round, battle)
    self._round = round
    self._battle = battle
    self._attacker = PuppetFactory:getInstance():getEntity(round.index)
end

function Round:startRound()
    self:playRoleBuffs(self._round.startRoleBuffs)
    self:useSkill(self._round.skillId)
end

function Round:useSkill(skillId)
    logger:info("=--index:%d-----useSkill(%d)----------", self._round.index, skillId)
    local function skillEndCallback()
        self:endRound()
    end
    
    if skillId == 0 then  --该回合没有释放技能
        skillEndCallback()
        return
    end
    
    local reliefModelType = self._attacker:getReliefModelType()
    if reliefModelType ~= nil then
        skillId = reliefModelType --现在的默认技能ID是跟模型一样的，当不一样时，就需要修改！！
    end
    local config = ConfigDataManager:getConfigById(ConfigData.FightShowConfig, skillId)
    local skill = Skill.new(self._battle)
    skill:init(self._attacker, self._round.targets, config, self, skillEndCallback)
    skill:use()
end


function Round:endRound()
    self:playRoleBuffs(self._round.endRoleBuffs)
    self:nextRound()
end

function Round:playHitRoleBuffs()
    self:playRoleBuffs(self._round.hitRoleBuffs)
end

function Round:playRoleBuffs(roleBuffs)
    print("~~~~~~~~roleBuffs~~~~~~~", #roleBuffs)
    print("~~~~~~~~roleBuffs~~~~~~~", #roleBuffs)

    --测试数据
--    roleBuffs ={
--        {
--            index = 21,
--	        buffs = {
--	            {
--                    id = 1403,
--	                lastRound = 2,
--	                iconId = 3
--                }
--            },
--	        attrMaps = {
--                {
--                    key = 1,
--	                value = 99999,
--	                delta = 30,
--	                num = 666666,
--                }
--            }
--        },
--        {
--            index = 23,
--	        buffs = {
--	            {
--                    id = 1403,
--	                lastRound = 2,
--	                iconId = 3
--                }
--            },
--	        attrMaps = {
--                {
--                    key = 1,
--	                value = 99999,
--	                delta = 30,
--	                num = 666666,
--                }
--            }
--        }

--    }



    -- buff效果动画
    for k, v in pairs(roleBuffs) do
        self:playRoleBuff(v)
    end

end

function Round:playRoleBuff(roleBuff)
    local puppet = PuppetFactory:getInstance():getEntity(roleBuff.index)
    if puppet then

        puppet:updateBuffCCBList(roleBuff.buffs)

        -- 属性变化效果
        for _, attrMap in pairs(roleBuff.attrMaps) do
            local key = attrMap.key
            local value = attrMap.value
            local delta = attrMap.delta

            -- buff的血量变化
            if key == 2 then
                local hurtType = HurtType.NormalHurt
                if delta > 0 then
                    hurtType = HurtType.AddHpHurt
                end
                delta = - delta

                local bloods = { }
                local blood = { state = hurtType, delta = delta }
                table.insert(bloods, blood)
                puppet:beHurt(bloods, attrMap.num, nil, 6, { 25, 30, 35, 40, 45, 50 }, 2, 1.5)
            else
                -- TODO:其它属性变化特效
            end
        end
    end
end

function Round:nextRound()
    -- TimerManager:addOnce(100, self.delayRound,self)
    self._battle:addTimerOnce(100, self.delayRound,self)
end

function Round:delayRound()
    self._battle:nextRound()
end













