module("battleCore", package.seeall)

AttackAction = class("AttackAction", SkillAction)

-- attackerEnt  进攻方佣兵
-- targetEnt    防守方佣兵

function AttackAction:onEnter(skill)
    AttackAction.super.onEnter(self, skill)
    
    self._attackerEnt = skill:getOwner()
    self._battle = skill:getBattle()
    self._attackerType = self._attackerEnt:getModelType()  --攻击方的佣兵类型
    
    local skillConfig = skill:getConfig()
    self._bulletInfo = skillConfig.bullet           --子弹表现
    self._attackaction = skillConfig.attackaction or {}   --攻击表现
    self._hurtaction = skillConfig.hurtaction or {}       --受击表现
    self._atkaction = skillConfig.atkaction or {}   --攻击战斗特效表现
    self._animationSound = skillConfig.animationSound or {}   --攻击动作音效

    self._hurtEffectCount = 0  --高阶受击特效计数

    
    local curNum = 0
    local maxNum = 2
    local function actionCallback()
        curNum = curNum + 1
        
        if curNum == maxNum then
            self:endAction()
        end
    end
    
    local function attackEnd() 
        actionCallback()
        --有些模型会死亡，不能直接全部播放特效了。
        self._attackerEnt:playAnimation(ModelAnimation.Wait, true)
    end
    
    local targets = skill:getTargets()
    self._targets = targets
    self._startHit = false
    local function hitCallback()
        print("===========hitCallback==============")
        skill:getRound():playHitRoleBuffs()
        self:delayLanuchButtle(self._attackerEnt,targets,actionCallback)
    end
    
    -- 攻击动作
    self._attackerEnt:playAnimation(ModelAnimation.Attack,false, attackEnd, "hit", hitCallback)

    -- 攻击音效
    self:playAnimationSound(self._attackerEnt, ModelAnimation.Attack, self._animationSound)

    
    self:consiAttackAction(self._attackerEnt)

    
    --TODO 这里需要打击帧 进行发射
    self.skill:addTimerOnce(1000, self.delayLanuchButtle, self ,self._attackerEnt,targets,actionCallback)

end

-- 根据佣兵类型和模型动作，播放音效
function AttackAction:playAnimationSound(ent, animationName, skillConfig)
    if ent == nil or animationName == nil or skillConfig == nil then
        return
    end

    for k,soundInfo in pairs(skillConfig) do
        if soundInfo[1] == animationName then
            -- print("== -- 根据佣兵类型和模型动作，播放音效 ==")
            self:actionEffect(ent, {soundInfo[2],soundInfo[3],soundInfo[4]})
            return
        end
    end

end


--军师播放攻击动作
-- 根据当前佣兵所在阵营判定播放
function AttackAction:consiAttackAction(curEnt)
    -- local dir = curEnt:getDirection()
    local dir = curEnt:getDirFromExchangeCamp()
    local consIndex
    if dir == ModelDirection.Right then --左边军师
        consIndex = ModelConsIndex.Left
    elseif dir == ModelDirection.Left then --右边军师
        consIndex = ModelConsIndex.Right
    end
    local consiEnt = PuppetFactory:getInstance():getEntity(consIndex)
    if consiEnt then
        local function attackCallBack()
            consiEnt:playAnimation(ModelAnimation.Wait, true)
        end
        consiEnt:playAnimation(ModelAnimation.Attack,false, attackCallBack)
    end
end

function AttackAction:attackEffect(ent, effectInfos, playSound)
    for _, effectInfo in pairs(effectInfos) do
        if effectInfo[1] == "sound" and playSound == true then
            self:actionEffect(ent, effectInfo) --callback
        elseif effectInfo[1] ~= "sound" then
            self:actionEffect(ent, effectInfo) --callback
        end
    end
end

function AttackAction:delayLanuchButtle(attackerEnt, targets, actionCallback)
    if self._startHit == true then  --兼容
        return
    end
    self._startHit = true
    self:lanuchButtle(attackerEnt,targets,actionCallback)
    
    self:attackEffect(attackerEnt, self._attackaction, true)

    self:launchAtkAction(attackerEnt, self._atkaction, targets, true)  --新增战斗特效
end

--发射子弹
function AttackAction:lanuchButtle(attackerEnt, targets, actionCallback)
    self._hurtEffectCount = 0
    local curNum = 0
    local maxNum = #targets
    local function hurtCallback()
        curNum = curNum + 1
        if curNum == maxNum then  --整个攻击，受击结束
            actionCallback()
        end
    end
    
    local isPlaySound = true
    --攻击飘血频率 由子弹配置决定
    local function lanuchCallback(target)
        self:beHurt(target, hurtCallback, self._bulletInfo[5], 
            self._bulletInfo[6], self._bulletInfo[7],self._bulletInfo[8], isPlaySound)
         --子弹运行到，受击播放
         isPlaySound = false
    end

    self._dir = attackerEnt:getDirection()
    
    local mapPanel = attackerEnt:getMapPanel()
    
    for _, target in pairs(targets) do
        local targetEnt = PuppetFactory:getInstance():getEntity(target.index)
        if targetEnt ~= nil then
            logger:info("发射子弹index=%d",target.index)

            local attr = {}
            attr.startPos = cc.p(attackerEnt:getCenterPosition())
            attr.endPos = cc.p(targetEnt:getCenterPosition())
            attr.callback = lanuchCallback
            attr.parent = mapPanel
            attr.target = target
            attr.atkDir = attackerEnt:getDirection()
            attr.info = self._bulletInfo
            Bullet.new(attr)
        end
    end
end


-- -- 受击表现
-- function AttackAction:beHurt(target, callback, fCount, fsecond, delayDeath,delayHurt, isPlaySound)
--     local ent = PuppetFactory:getInstance():getEntity(target.index)
--     if ent == nil then --战斗已经结束了。不要回调了
--         return
--     end

--     -- 受击动作+扣血
--     ent:beHurt(target.bloods, target.num, callback, fCount, fsecond, delayDeath,delayHurt)
    
--     -- 受击特效
--     self:attackEffect(ent, self._hurtaction, isPlaySound)
-- end


-- 受击表现
function AttackAction:beHurt(target, callback, fCount, fsecond, delayDeath,delayHurt, isPlaySound)
    local ent = PuppetFactory:getInstance():getEntity(target.index)
    if ent == nil then --战斗已经结束了。不要回调了
        return
    end

    -- 受击动作+扣血
    ent:beHurt(target.bloods, target.num, callback, fCount, fsecond, delayDeath,delayHurt)
    
    
    -- local isPlayEffect = false
    -- local size = table.size(self._targets)
    -- local attackerType = self._attackerType  % 100
    -- local index = target.index % 10
    -- logger:info("受击特效判定 size,attackerType,index =%d %d %d",size,attackerType,index) --3.109.24=3.9.4

    -- 暂时屏蔽高阶受击处理
    -- if attackerType > 5 and size > 0 then
    --     --高阶兵才处理
    --     local data = {}
    --     local parent = nil
    --     local camp = 1  --1=left 2=right
    --     local dir = ModelDirection.Left
    --     if target.index < 20 then
    --         camp = 1
    --         dir = ModelDirection.Right
    --     else
    --         camp = 2
    --         dir = ModelDirection.Left
    --     end

    --     if index >=1 and index <= 3 then  --前排
    --         isPlayEffect = true
    --     elseif index >=4 and index <= 6 then  --后排
    --         isPlayEffect = true
    --     end

    --     if isPlayEffect then
    --         if self._hurtEffectCount == 0 then  --只在指定位置播放一次受击特效
    --             self._hurtEffectCount = self._hurtEffectCount + 1
    --             data.dir = dir
    --             data.camp = camp
    --             data.index = index

    --             -- 高阶受击表现
    --             self:attackEffect2(ent, self._hurtaction, isPlaySound,data)
    --         end
    --         return            
    --     end
    -- end

    -- 低阶受击表现
    self:attackEffect(ent, self._hurtaction, isPlaySound)
end

-- 判断是否高阶
function AttackAction:targetAtkAction(target)
    -- body

    local isPlayEffect = false
    local data = {}
    local parent = nil
    local camp = 1  --1=left 2=right
    local dir = ModelDirection.Left

    local size = table.size(self._targets)
    local attackerType = self._attackerType  % 100
    local index = target.index % 10
    logger:info("判定 size,attackerType,index =%d %d %d",size,attackerType,index) --3.109.24=3.9.4


    if self._attackerType > 500 then
        attackerType = 6   --boss模型当高阶兵处理
    end


    -- 暂时屏蔽高阶受击处理
    if attackerType > 5 and size > 0 then
        --高阶兵才处理
        if target.index < 20 then
            camp = 1
            dir = ModelDirection.Right
        else
            camp = 2
            dir = ModelDirection.Left
        end

        if index >=1 and index <= 3 then  --前排
            isPlayEffect = true
        elseif index >=4 and index <= 6 then  --后排
            isPlayEffect = true
        end
    end

    data.dir = dir
    data.camp = camp
    data.index = index

    return isPlayEffect,data
end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- 高阶受击表现
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
function AttackAction:attackEffect2(ent, effectInfos, playSound,parent)
    for _, effectInfo in pairs(effectInfos) do
        if effectInfo[1] == "sound" and playSound == true then
            self:actionEffect2(ent, effectInfo,nil,parent) --callback
        elseif effectInfo[1] ~= "sound" then
            self:actionEffect2(ent, effectInfo,nil,parent) --callback
        end
    end
end

function AttackAction:actionEffect2(ent, effectInfo, callback,data)
    local type = effectInfo[1]
    if type == "effect" then
        local effectName = effectInfo[2]
        local rootNode = self:dealEffectData(effectName,data)
        if rootNode ~= nil then
            self:playEffect2(effectName, effectInfo[3], effectInfo[4],rootNode)   --创建高阶受击特效
        else
            ent:playEffect(effectName, effectInfo[3], effectInfo[4])   --创建低阶受击特效
        end
    elseif type == "characterColor" then
        ent:characterColor(effectInfo[4], effectInfo[5], effectInfo[6])
    elseif type == "sound" then
        self:playSound(effectInfo[2])
    elseif type == "backgroundColor" then
        local time = (effectInfo[3] - effectInfo[2]) / 100
        ent:backgroundColorAction(effectInfo[4], effectInfo[5], effectInfo[6], effectInfo[7], time)
    elseif type == "formationtab" then
        ent:changeZhenfa(tonumber(effectInfo[2]), effectInfo[3], callback)   --改变阵法
    end
end

-- 创建高阶受击特效
function AttackAction:playEffect2(effectName, dx, dy,parent)
    local spineEffect = SpineEffect.new(effectName, parent)
    spineEffect:setPosition(dx * 1 + 50, dy  + 50)  --50写死。居中处理。 * self._curDir
    spineEffect:setLocalZorder(1000)

    spineEffect:setDirection(parent.dir)

    logger:info("高阶特效 effectName,dx,dy,dir=%s,%d,%d,%d",effectName,dx,dy,parent.dir)
end

-- 判定高阶受击特效的播放坑位
function AttackAction:dealEffectData(effectName,data)
    -- body
    local parent = nil
    local conf = self:getSkillConfByName(effectName)
    if conf ~= nil then
        local index = data.index
        for _,indexMap in pairs(conf.indexMaps) do
            if index >= indexMap[2]and index <= indexMap[3] then
                local battleView = self._battle:getBattleView()
                local mapPanel = battleView:getMapPanel()
                parent = mapPanel:getChildByName("indexPanel" .. indexMap[1] .. data.camp)
                parent:setVisible(true)
                parent.dir = data.dir
                parent:setLocalZorder(1000)
                return parent
            end
        end
    end

    return parent
end


-- 根据特效名字获取受击特效配表信息
function AttackAction:getSkillConfByName(effectName)
    -- body

    -- 高阶兵种受击特效
    -- {'A',1,3} : 'A'=播放位置，1=坑位1，3=坑位3 ..(即前排还有敌人(受击坑位含有1~3之一)，则在A位置播放特效effect="bu06_hit")
    -- {'B',4,6} : 'B'=播放位置，1=坑位1，3=坑位3 ..(即后排还有敌人(受击坑位含有4~6之一)，则在B位置播放特效effect="bu06_hit")
    -- defaultDir=1 : 特效资源的方向朝向

    -- local skillConf = {}
    -- skillConf[1] = {ID = 1, effect="bu06_hit", defaultDir=1, indexMaps={{'A',1,3},{'B',4,6}}}  
    -- skillConf[2] = {ID = 2, effect="gong06_hit", defaultDir=1, indexMaps={{'C',1,6}}}  
    -- skillConf[3] = {ID = 3, effect="qiang06_hit", defaultDir=1, indexMaps={{'D',1,1},{'D',4,4},{'E',2,2},{'E',5,5},{'F',3,3},{'F',6,6}}}  
    -- skillConf[4] = {ID = 4, effect="qi01_atk", defaultDir=1, indexMaps={{'A',1,3},{'B',4,6}}}
    local skillConf = HurtSkillConf

    for _,v in pairs(skillConf) do
        if v.effect == effectName then
            return v
        end
    end
    return nil
end

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- 高阶攻击特效
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
function AttackAction:launchAtkAction(attackerEnt, effectInfos, targets, playSound)
    -- body
    local size = table.size(targets)
    if size > 0 then
        local target = targets[1]
        local isPlayEffect, data= self:targetAtkAction(target)
        if isPlayEffect == true and data ~= nil then
            logger:info("准备要播高阶的攻击特效啦..... 000")
            self:attackEffect3(attackerEnt, effectInfos, playSound,data)  --高阶攻击特效
        end
    end

end

function AttackAction:attackEffect3(ent, effectInfos, playSound,parent)
    for _, effectInfo in pairs(effectInfos) do
        if effectInfo[1] == "sound" and playSound == true then
            self:actionEffect3(ent, effectInfo,nil,parent) --callback
        elseif effectInfo[1] ~= "sound" then
            self:actionEffect3(ent, effectInfo,nil,parent) --callback
        end
    end
end

function AttackAction:actionEffect3(ent, effectInfo, callback,data)
    local type = effectInfo[1]
    if type == "effect" then
        logger:info("准备要播高阶的攻击特效啦..... A1")
        local effectName = effectInfo[2]
        local rootNode = self:dealEffectData3(effectInfo[6],data)
        if rootNode ~= nil then
            logger:info("准备要播高阶的攻击特效啦..... A2")

            if effectInfo[5] > 0 then
                logger:info("== 延时 播高阶的攻击特效..... A2")
                self.skill:addTimerOnce(effectInfo[5], self.playEffect3, self, effectName, effectInfo[3], effectInfo[4],rootNode)
            else
                logger:info("播高阶的攻击特效..... A2")
                self:playEffect3(effectName, effectInfo[3], effectInfo[4],rootNode)   --创建高阶攻击特效
            end
            
        end
    elseif type == "characterColor" then
        ent:characterColor(effectInfo[4], effectInfo[5], effectInfo[6])
    elseif type == "sound" then
        -- self:playSound(effectInfo[2])
        self:actionEffect(ent, effectInfo, nil)

    elseif type == "backgroundColor" then
        local time = (effectInfo[3] - effectInfo[2]) / 100
        ent:backgroundColorAction(effectInfo[4], effectInfo[5], effectInfo[6], effectInfo[7], time)
    elseif type == "formationtab" then
        ent:changeZhenfa(tonumber(effectInfo[2]), effectInfo[3], callback)   --改变阵法
    end
end

-- 创建高阶攻击特效
function AttackAction:playEffect3(effectName, dx, dy,parent)
    local spineEffect = SpineEffect.new(effectName, parent)
    spineEffect:setPosition(dx * 1 + 50, dy  + 50)  --50写死。居中处理。 * self._curDir
    spineEffect:setLocalZorder(1000)
    spineEffect:setDirection(parent.dir)

    logger:info(" ok 高阶攻击特效 effectName,dx,dy,dir=%s,%d,%d,%d",effectName,dx,dy,parent.dir)
end

-- 判定高阶攻击特效的播放坑位
function AttackAction:dealEffectData3(showType,data)
    -- body
    local parent = nil
    local conf = self:getSkillConfByName3(showType)
    if conf ~= nil then
        local index = data.index
        for _,indexMap in pairs(conf.indexMaps) do
            if index >= indexMap[2]and index <= indexMap[3] then
                logger:info("判定高阶特效的播放坑位 ..... B")
                local battleView = self._battle:getBattleView()
                local mapPanel = battleView:getMapPanel()
                parent = mapPanel:getChildByName("indexPanel" .. indexMap[1] .. data.camp)
                parent:setVisible(true)
                parent.dir = data.dir
                parent:setLocalZOrder(1000)
                return parent
            end
        end
    end

    return parent
end

-- FightShowConfig effectInfo[6] 表示坑位

-- 根据特效名字获取攻击特效配表信息
function AttackAction:getSkillConfByName3(showType)
    -- body

    -- 高阶兵种特效
    -- {'A',1,3} : 'A'=播放位置，1=坑位1，3=坑位3 ..(即前排还有敌人(受击坑位含有1~3之一)，则在A位置播放特效effect="bu06_hit")
    -- {'B',4,6} : 'B'=播放位置，1=坑位1，3=坑位3 ..(即后排还有敌人(受击坑位含有4~6之一)，则在B位置播放特效effect="bu06_hit")

    local skillConf = HurtSkillConf
    for _,v in pairs(skillConf) do
        if v.showType == showType then
            return v
        end
    end
    return nil
end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


