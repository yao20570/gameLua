module("battleCore", package.seeall)

Battle = class("Battle")  --战斗逻辑

function Battle:ctor(battleModule)
    self._battleModule = battleModule
    self._battleView = battleModule:getView()
    self._battlePanel = self._battleView:getPanel(BattlePanel.NAME)
    -- self._enterBattlePanel = self._battleView:getPanel(BattleEnterPanel.NAME)
    self._battleTimerList = {}
end

function Battle:finalize()
    PuppetFactory:getInstance():finalize()
    
    self:stopTimers()
    
    if self._uiParticle ~= nil then
        self._uiParticle:finalize()
    end
    
    self._uiParticle = nil
end

function Battle:stopTimers()
    --需要把所有的定时器清空
    for _, timer in pairs(self._battleTimerList) do
        local func = timer.func
        local obj = timer.obj
        TimerManager:remove(func,obj)
    end

    self._battleTimerList = {}
    
    self._battlePanel:stopAllActions()
    
    local ents = PuppetFactory:getInstance():getEntitys()
    for _, ent in pairs(ents) do
        ent:stopAllActions()
    end
end

local battleCount = 1

function Battle:startBattle(battleData)
    local battleProxy = self._battlePanel:getProxy(GameProxys.Battle)
    local isAaccelerate = battleProxy:isAaccelerate()
    if isAaccelerate == true then
        cc.Director:getInstance():getScheduler():setTimeScale(1.6) --默认2倍速度战斗
    end

    battleCount = battleCount + 1
    
    self._battlePanel:hideSkipBtn()
    self._battlePanel:hideAccelerateBtn()

    self._battleData = battleData
    
    local battle = battleData.battle
    self._rounds = battle.rounds
    self._reward = battle.reward
    
    self:initBattleView(battle)
    

    if self._battleData.rc == 3 or self._battleData.rc == 2 then  --rc=3重播,rc=2战斗播报,直接按播放处理
    else
        if battleData.saveTraffic == 1 then --不看战斗。直接弹出结果面板
            -- local function animationComplete()
            --     self:onEndBattle()
            -- end
            -- local battleProxy = self._battleModule:getProxy(GameProxys.Battle)
            -- battleProxy:setCompleteCallback(animationComplete)

            -- local battleProxy = self._battleModule:getProxy(GameProxys.Battle)
            -- battleProxy:resumeUIAnimation()
            

            self:onEndBattle()

            return
        end
    end
    
    
    
    
    self._puppetNum = #battle.puppets
    self._curPuppetIndex = 1
    self._puppets = battle.puppets
    --TODO 可能要一个一个创建出来
    self:delayCreatePuppet(1)
end

local mapId = 101
function Battle:initBattleView(battle)
    self._battlePanel:setCurBattle(self)
    mapId = battle.bgIcon
    if mapId > 105 or mapId < 101 then
        mapId = 101
    end
    self._battlePanel:onUpdateMap(mapId)
    mapId = mapId + 1
    self._battlePanel:onUpdateRound(0)
   

    local leftHp = 0
    local rightHp = 0
    
    local type = battle.type
    local isBossBattle = type == 7 or type == 11  --boss战斗，直接写死，血量只加成一个
    local addOne = false

    local puppets = battle.puppets
    for _, puppet in pairs(puppets) do
        local index = puppet.attr.index
        if index < 20 then
            leftHp = leftHp + puppet.attr.hp
        else 
            if isBossBattle then
                if addOne == false and index == 25 then  --写死BOSS位置为25
                    rightHp = rightHp + puppet.attr.hp
                    addOne = true
                end
            else
                rightHp = rightHp + puppet.attr.hp
            end
        end
    end
    

    self._battlePanel:setWarBook(battle)

    self._battlePanel:setMaxHpByCamp(leftHp, BattleCamp.Left)
    self._battlePanel:setMaxHpByCamp(rightHp, BattleCamp.Right)

    local battle = self._battleData.battle
    local leftName = battle.leftName
    local rightName = battle.rightName
    self._battlePanel:setNameByCamp(leftName, BattleCamp.Left)
    self._battlePanel:setNameByCamp(rightName, BattleCamp.Right)

    -- 显示先手值
    local firstL = battle.firstL or 0
    local firstR = battle.firstR or 0
    self._battlePanel:setFirstByCamp(firstL, BattleCamp.Left)
    self._battlePanel:setFirstByCamp(firstR, BattleCamp.Right)

    -- 设置双方的头像
    local headIconL = battle.headIconL or 0 
    local headIconR = battle.headIconR or 0 
    
    local playerIdL = battle.headIdL
    local playerIdR = battle.headIdR
    self._battlePanel:setHeadIconByCamp(headIconL, BattleCamp.Left, playerIdL)
    self._battlePanel:setHeadIconByCamp(headIconR, BattleCamp.Right, playerIdR)
--    local tl = StringUtils.fined64ToAtom(playerIdL)
--    local tr = StringUtils.fined64ToAtom(playerIdR)
--    logger:error("=======================================================================>")
--    logger:error("=======================================================================>")
--    logger:error("=======================================================================>")
--    logger:error("====>battle.headIconL:%s, ========>battle.headIconR:%s", headIconL, headIconR)
--    logger:error("====>battle.headIdL:%s%s, ========>battle.headIdR:%s%s", tl.high, tl.low, tr.high, tr.low)

    
    local function animationComplete()
        
        local function callback()
            self:addTimerOnce(30, self.allBirthMove, self)  --门开了，动画开播放
        end

        if self._battleData.saveTraffic ~= 1 then
           local ccb = UICCBLayer.new("rgb-duijue", self._battlePanel:getParent(), nil, nil, true)
           local x, y = NodeUtils:getCenterPosition()
           ccb:setPosition(x + 20, y + 45) --在这里才播放特效
        end
        
        self._battlePanel:showSkipBtn()
        self._battlePanel:showAccelerateBtn()
        --战斗开始动画影响了UI布局，暂时注释掉-----------------------------------
        --self._battlePanel:playAction("ui_ruchang", callback)
        callback()
        --------------------------------------------------
        AudioManager:playEffect("battle_start")
        
        local count = battleCount % 2 + 1
        local soundName = string.format("battle_fb0%d", count)
        soundName = "battle_fb01"
        AudioManager:playMusic(soundName)
    end
--    animationComplete()
    self._animationComplete = animationComplete
        
    -- local battleProxy = self._battleModule:getProxy(GameProxys.Battle)
    -- battleProxy:setCompleteCallback(animationComplete)

    -- local battleProxy = self._battleModule:getProxy(GameProxys.Battle)

    
    local uiParticle = UIParticle.new(self._battlePanel, "huohua")
    local x, y = NodeUtils:getCenterPosition()
    uiParticle:setPosition(x,y)
    self._uiParticle = uiParticle
end

function Battle:createPuppets()
--    for _, puppet in pairs(puppets) do
--        self:createPuppet(puppet)
--    end
    
    self._curPuppetIndex = self._curPuppetIndex + 1
    if self._curPuppetIndex > self._puppetNum then
        -- local battleProxy = self._battleModule:getProxy(GameProxys.Battle)
        -- battleProxy:resumeUIAnimation()
        self._animationComplete() --创建完，才开始跑
    else
        self:addTimerOnce(3, self.delayCreatePuppet, self, self._curPuppetIndex)
    end
end

function Battle:delayCreatePuppet(index)
    local puppet = self._puppets[index]
    local ent = self:createPuppet(puppet) --如果佣兵数量为0，返回nil

    if ent ~= nil then    
        local curMove = 0 --貌似多余的
        local maxMove = 0 --貌似多余的
        
        -- local name = ent:getName()
        -- local camp = ent:getCamp()
        -- self._battlePanel:setNameByCamp(name, camp)
        
        ent:setVisible(false)
    end
    
    self:createPuppets()
end

function Battle:allBirthMove() --开局佣兵移动进场
    local entitys = PuppetFactory:getInstance():getEntitys()
    local maxNum = table.size(entitys)
    local curEndMoveNum = 0
    local function birthMoveComplete()
        curEndMoveNum = curEndMoveNum + 1
        if curEndMoveNum >= maxNum then
            self:addTimerOnce(30, self.playChangeZhenfa, self)
        end
    end
    
    local function delayBirthMove(ent)
        ent:setVisible(true)
        ent:birthMove(birthMoveComplete)
    end

    for _, ent in pairs(entitys) do
        self:addTimerOnce(30,delayBirthMove, ent)
--        ent:playBirthAction()
    end
end

--一下是旧逻辑出场
function Battle:leftBirthMove()

    local lefts = PuppetFactory:getInstance():getEntitysByCamp(BattleCamp.Left)
    local maxNum = #lefts
    local curEndMoveNum = 0
    local function birthMoveComplete()
        curEndMoveNum = curEndMoveNum + 1
        if curEndMoveNum >= maxNum then
--            AudioManager:playEffect("battle", "wav")
--            local lefts = PuppetFactory:getInstance():getEntitysByCamp(BattleCamp.Left)
--            for _, ent in pairs(lefts) do
--                ent:playAnimation(ModelAnimation.Win, true)
--            end
--            TimerManager:addOnce(1000, self.beforeBattle, self)
            self:beforeBattle()
        end
    end
    
    for _, ent in pairs(lefts) do
        ent:setVisible(true)
        ent:birthMove(birthMoveComplete)
        ent:playBirthAction()
    end
    
end


function Battle:beforeBattle()
    local lefts = PuppetFactory:getInstance():getEntitysByCamp(BattleCamp.Left)
    for _, ent in pairs(lefts) do
    	ent:playAnimation(ModelAnimation.Run, true)
    end
    
    local rights = PuppetFactory:getInstance():getEntitysByCamp(BattleCamp.Right)

    local function callback()
        print("=====对面的也要出场咯==========")
        for _, ent in pairs(rights) do
            ent:setVisible(true)
            ent:birthMove()
            ent:playBirthAction()
        end
    end
    
    local function complete()
        for _, ent in pairs(lefts) do
            ent:playAnimation(ModelAnimation.Wait, true)
        end

        self:addTimerOnce(30, self.playChangeZhenfa, self)
    end
    
    self._battlePanel:moveFrontBg(callback, complete)
end

function Battle:playChangeZhenfa()
--    local ents = PuppetFactory:getInstance():getEntitys()
--    for _, ent in pairs(ents) do
--        ent:changeZhenfa(0, 200)
--    end
    
    self:addTimerOnce(300, self.playBirthBuff, self)
end

function Battle:playBirthBuff()  --出场buff

    local function delayPlayBirthBuffEffect(ent)
        ent:playBirthBuffEffect()
    end

    local ents = PuppetFactory:getInstance():getEntitys()
    for _, ent in pairs(ents) do
        self:addTimerOnce(30, delayPlayBirthBuffEffect, ent)
    end
            
    self:addTimerOnce(1000, self.readyBattle, self)
    
end

function Battle:readyBattle()

    local ents = PuppetFactory:getInstance():getEntitys()
    for _, ent in pairs(ents) do
        ent:playAnimation(ModelAnimation.Wait, true)
    end
    
    self:addTimerOnce(300, self.startRoundBattle, self)
end

function Battle:startRoundBattle()
    self._curRoundNum = 1
    
    local round = self._rounds[self._curRoundNum]
    self:startRound(round)
end

--回合开始
function Battle:startRound(round)

    if self._isSkip == true then
        return
    end
    
    self._battlePanel:onUpdateRound(self._curRoundNum)

    local r = Round.new(round, self)
    r:startRound()
    
end

--下一回合
function Battle:nextRound()
    if self._isSkip == true then
        return
    end
    self._curRoundNum = self._curRoundNum + 1
    local round = self._rounds[self._curRoundNum]
    
    if round ~= nil then
        self:startRound(round)
    else
        logger:info("======战斗结束================")
        -- self:onEndBattle()
        self:consiAttackAction()
    end
end

--军师播放死亡动作(重播/回看不执行死亡动作)
-- 根据胜利失败决定哪方军师死亡
function Battle:consiAttackAction()
    local consIndex
    if self._battleData.rc == 0 then  --胜利
        consIndex = ModelConsIndex.Right
    elseif self._battleData.rc == 1 then  --失败
        consIndex = ModelConsIndex.Left
    else
        self:onEndBattle()
        return
    end
        
    local consiEnt = PuppetFactory:getInstance():getEntity(consIndex)
    if consiEnt then
        local function endCall()
            consiEnt:setVisible(false)
            self:onEndBattle()
        end
        consiEnt:playAnimation(ModelAnimation.Die, false, endCall)
    else
        self:onEndBattle()
    end
end

function Battle:onEndBattle()
    if self._battleData.rc == 0 then
        logger:info("======战斗胜利==========")
    else
        logger:info("======战斗失败========== rc:%d",self._battleData.rc)
    end
    
    cc.Director:getInstance():getScheduler():setTimeScale(1) --战斗结束，重置加速

    if self._battleData.rc == 3 or self._battleData.rc == 2 then  --rc=3重播，直接退出。 rc=2 战斗播报，直接退出。
        self._battlePanel:dispatchEvent(BattleEvent.HIDE_SELF_EVENT, {})
    else
        self._battleView:showBattleResultPanel(self._battleData)
    end
    
end

--是否要请求战斗结束
function Battle:isReqBattleEnd()
    return not (self._battleData.rc == 3 or self._battleData.rc == 2)
end

--跳过战斗
function Battle:onSkipBattle()
    self._isSkip = true
    
    self:onEndBattle()
    
--    self:finalize()
end

----------------
function Battle:createPuppet(puppet)

    local attr = puppet.attr
    -- logger:info("创建佣兵attr index=%d、name=%s、num=%d、modelList=%d", attr.index, attr.name, attr.num, attr.modelList)
    
    if attr.num == 0 then
        logger:error("出现数量为0的佣兵数据···attr：index=%d、name=%s、num=%d", attr.index, attr.name, attr.num)
        return nil
    end
    
    local mapPanel = self._battleView:getMapPanel()
    local rootNode = mapPanel:getChildByName("indexPanel" .. attr.index)
    
    rootNode.battlePanel = self._battlePanel
    rootNode.battle = self
    local ent = PuppetFactory:getInstance():create(attr, rootNode)
    
    return ent
end

--统一添加定时器入口，跳过时，统一释放掉定时器，以免出现问题
function Battle:addTimerOnce(delay, func, obj, ...)
    TimerManager:addOnce(delay, func, obj, ...)
    table.insert(self._battleTimerList, {func = func, obj = obj})
end

function Battle:getView()
    return self._view
end

function Battle:getBattleView()
    return self._battleView
end

function Battle:playShark()
    
    if self._startShark == true then
        return
    end
    
    local function endSharkCall()
        self._startShark = false
    end

    self._startShark = true
    local layer = self._battleModule:getCurLayer()
    NodeUtils:shark(layer, nil, endSharkCall)
end

















