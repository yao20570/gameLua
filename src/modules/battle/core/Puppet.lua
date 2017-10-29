module("battleCore", package.seeall)

Puppet = class("Puppet")  --佣兵

function Puppet:ctor(attr, rootNode)
    self._battlePanel = rootNode.battlePanel
    self._battle = rootNode.battle
    self._infoPanel = rootNode:getChildByName("infoPanel")
    
    rootNode:setVisible(true)
    rootNode.puppet = self
    
    local index = attr.index
    local modelType = attr.modelList


    if index == ModelConsIndex.Left or index == ModelConsIndex.Right then
        modelType = 1001  --军师出战，军师模型暂缺，写死用1001模型
    else
        -- 扣血飘字用bloodpanel独立显示，解决被特效层级遮挡问题
        local mapPanel = self._battlePanel:getChildByName("mapPanel")
        self._bloodPanel = mapPanel:getChildByName("bloodPanel"..index)
        if self._bloodPanel then
            self._bloodPanel:setVisible(true)
        end
    end
    
    --modelType 需要判断这个包里面有没有资源，如果没有，直接转换成低阶兵逻辑，从根源处理
    local json = "model/" .. modelType .. "/skeleton.json"
    local jsonF = cc.FileUtils:getInstance():isFileExist(json)
    if jsonF ~= true then  --文件不存在了，直接转换成低阶兵
        modelType = math.floor(modelType / 100) * 100 + 5 
        self._reliefModelType = modelType
    end

    self._index = index          --坑位
    self._heroId = attr.heroId   --武将id/军师id
    self._consiStar = attr.star  --军师星级
    
    if index < 20 then
        self.camp = BattleCamp.Left
    else 
        self.camp = BattleCamp.Right
    end

    attr.camp = self.camp
    
    self._rootNode = rootNode
    
    local x, y = self._rootNode:getPosition()
    self._spawPos = cc.p(x,y)
    
    self._defaultScale = 1 --attr.scale or 1
    self._curZhenfa = self._defaultZhenfa
    local info = ConfigDataManager:getInfoFindByOneKey(ConfigData.ModelGroConfig, "modelID", modelType)
    self._defaultModelNum = info.num
    self._defaultDir = self:getDefaultDir(index,info.dir)
    self._curDir = self._defaultDir
    self._defaultZhenfa = info.formationID
    
    self._curHp = attr.hp
    self._maxHp = attr.hp
    self._modelType = modelType
    self._name = attr.name
    self._birthBuffs = attr.buffs

    local hpTxt = self._infoPanel:getChildByName("hpTxt")
    hpTxt:setVisible(true) --初始化显示hp
    
    if self._infoPanel ~= nil then
        self._infoPanel:setVisible(true)
        self:setHpTxt(self._curHp, attr.num)
        self:setModelName()
    end
    
    
    self._liveModelNum = self._defaultModelNum
    
    self._deathMap = {}  --把死亡的阵眼丢进这个Map来
    
    self:createAllModel(modelType)

    self._ccbMap = {}
end

--获取替身模型，如果不为nil的话，需要在技能回合时，强转一下技能ID
function Puppet:getReliefModelType()
    return self._reliefModelType
end


function Puppet:finalize()
    self._rootNode.puppet = nil
    self._rootNode:stopAllActions()
    for _, model in pairs(self._modelMap) do
        model:finalize()
    end

    for k, v in pairs(self._ccbMap) do
        v:finalize()
    end
    self._ccbMap = {}

    self._rootNode = nil
    self._infoPanel = nil
    self._bloodPanel = nil
    self._battlePanel = nil
end

function Puppet:stopAllActions()
    self._rootNode:stopAllActions()
end

function Puppet:getDefaultZhenfa()
    return self._defaultZhenfa
end

function Puppet:createAllModel(id)
    
    local modelMap = {}
    
    for eye=1, self._defaultModelNum do
        local info = self:getZhenfaInfo(self._defaultZhenfa, eye) 
            
        local x = self:xAxis( info.x )
        local y = info.y
        local model = self:createModel(id)
        model:setPosition(x, y)
        modelMap[info.eye] = model

        model:setLocalZOrder(100 - y)
        local scale = self:getScaleByY(y)
        model:setScale(scale)
        -- logger:info("puppet 初始 缩放 scale=%.2f",scale)     
        
        --播放出生特效   
    end
    
    self._modelMap = modelMap
    
end

function Puppet:playBirthAction()
    for _, model in pairs(self._modelMap) do
    	model:setOpacity(0)
    end
    local action = cc.FadeTo:create(1, 255)
    self:runModelAction(action)
end

--主要是右边的出场移动
function Puppet:birthMove(complete)
    -- local dir = self._defaultDir
    local dir = self:getDirFromExchangeCamp()  --根据阵营转为朝向
    local srcPos = self._rootNode.srcPos
    self._rootNode:setPosition(srcPos.x + 300 * dir, srcPos.y)
    local moveAction = cc.MoveTo:create(1, cc.p(srcPos.x, srcPos.y))
    
    local function callback()
        self:playAnimation(ModelAnimation.Wait, true)
        if complete ~= nil then
            local x, y = self._rootNode:getPosition()
--            logger:info("~~~~~uppet:birthMove~~index:%d~~~srcPos.x:%f, srcPos.y:%f~~~~x:%f,y:%f~",
--                self._index, srcPos.x, srcPos.y, x, y)
            complete()
        end
    end
    self:playAnimation(ModelAnimation.Run, true)
    local action = cc.Sequence:create(moveAction, cc.CallFunc:create(callback))
    self._rootNode:runAction(action)
end

--播放出生Buff特效
--返回是否有播放
function Puppet:playBirthBuffEffect()

    local index = 0
    local isPlay = false
    for _, buff in pairs(self._birthBuffs) do
    	local buffId = buff.id
        local info = ConfigDataManager:getConfigById(ConfigData.BuffConfig,buffId)
        if info ~= nil and info.showID > 0 then
            --添加特效
            local function playBuffEffect(self, showID)
                self:playBuffEffect(showID)
            end
            
            if index == 0 then
                self:playBuffEffect(info.showID)
            else
                self:addTimerOnce(1000, playBuffEffect, self, info.showID)
            end
            index = index + 1
--            
            isPlay = true
        end
    end
    
    if isPlay == true then
--        AudioManager:playEffect("battle_chuchang", "wav")
        self:playAnimation(ModelAnimation.Win, true)
    end
end

function Puppet:playBuffEffect(id)
    local sprite = TextureManager:createSprite("images/buffIcon/" .. id .. ".png")
    sprite:setPosition(50,50)
    self:addChild(sprite)
    sprite:setLocalZOrder(100)
    
    local function callback()
        sprite:removeFromParent()
    end    
    local delay = math.random(0, 500)
    BirthBuffEffect:play(sprite, delay / 1000, callback )
end


function Puppet:updateBuffCCBList(buffList)
    for k, v in pairs(buffList) do
        if v.lastRound > 0 then
            self:addBuffCCB(v.id)
        else
            self:delBuffCCB(v.id)
        end
    end
end

-- 添加buff特效
function Puppet:addBuffCCB(buffId)
    local buffCfgData = ConfigDataManager:getConfigById(ConfigData.BuffConfig, buffId)
    if buffCfgData == nil or buffCfgData.ccb == " " then
        return
    end
    if self._ccbMap[buffCfgData.ccb] == nil then
        local pos = StringUtils:jsonDecode(buffCfgData.warDeviation)

        local ArmyCfgData = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig, self._modelType)
        local x = 0
        local y = 0
        if ArmyCfgData ~= nil then
            local scale = StringUtils:jsonDecode(ArmyCfgData.multiple)

            x = scale[1] / 10000 *(pos[1] or 0)
            y = scale[2] / 10000 *(pos[2] or 0)
        end
        

        if self.camp == BattleCamp.Right then
            x = - x
        end

        x = x + self._rootNode:getContentSize().width / 2

        local ccb = UICCBLayer.new(buffCfgData.ccb, self._rootNode)
        ccb:setPosition(x, y)
        ccb:setLocalZOrder(100)
        self._ccbMap[buffCfgData.ccb] = ccb
    end
end

-- 移除buff特效
function Puppet:delBuffCCB(buffId)   
    local buffCfgData = ConfigDataManager:getConfigById(ConfigData.BuffConfig,buffId)
    if buffCfgData == nil or buffCfgData.ccb == " " then
        return
    end
    if self._ccbMap[buffCfgData.ccb] == nil then
        return
    end
    self._ccbMap[buffCfgData.ccb]:finalize()
    self._ccbMap[buffCfgData.ccb] = nil
end


function Puppet:createModel(id)  --创建佣兵模型/军师模型
    local model = SpineModel.new(id, self._rootNode, true)
    model:playAnimation(ModelAnimation.Wait, true)
    model:setDirection(self._defaultDir)
    
    return model
end

function Puppet:getDefaultDir(index,configDir)
    -- 模型出生朝向
    local dir = ModelDirection.Left
    if self.camp == BattleCamp.Left then
        dir = ModelDirection.Right
    end

    if configDir then
        dir = dir * configDir --
    end

    return dir
end

function Puppet:playAnimation(animation, isLoop, completeCallback, customEventKey, ccustomCallback)
    
    local curEndNum = 0
    local maxEndNum = 0
    local function endCallback(model)
        curEndNum = curEndNum + 1
        if curEndNum >= maxEndNum then
            if completeCallback ~= nil then
                completeCallback()
            end
            --需要把回调的注册删除掉
        end
        model:removeEventLister("complete", animation, endCallback)
    end
    
    local cusCurEndNum = 0
    local function customCallback(model)
        cusCurEndNum = cusCurEndNum + 1
        if cusCurEndNum >= maxEndNum then
            if ccustomCallback ~= nil then
                ccustomCallback()
            end
            --需要把回调的注册删除掉
        end
        model:removeEventLister(customEventKey, animation, customCallback)
    end
    
    for _, model in pairs(self._modelMap) do
        local function delayPlayAnimation(self,model, animation, isLoop)
            if isLoop ~= false then --循环播放的不回调
                endCallback = nil
            end
            model:playAnimation(animation, isLoop, endCallback, model, customEventKey, customCallback)
        end
        --待机的 直接切换  不然在切换过程中又进行再切换 则会出现问题
        --TODO 这里有可能会引发BUG！！！ --animation == ModelAnimation.Wait or
        if model.isDeath ~= true and (true or animation == ModelAnimation.Run
            or animation == ModelAnimation.Wait or animation == ModelAnimation.Attack) then  
            maxEndNum = maxEndNum + 1
            model:playAnimation(animation, isLoop, endCallback, model, customEventKey, customCallback)
        elseif model.isDeath ~= true then
            maxEndNum = maxEndNum + 1
            local time = math.ceil(1000 / GameConfig.frameRate) * math.random(2, 16)
            self:addTimerOnce(time, delayPlayAnimation, self,model, animation, isLoop)
        end
    end
end

function Puppet:setDirection(dir)
    if self._curDir == dir then
        return
    end
    self._curDir = dir
    for _, model in pairs(self._modelMap) do
        model:setDirection(dir)
    end
end

function Puppet:getDirection()
    return self._curDir
end

function Puppet:setPosition(x, y)
    self._rootNode:setPosition(x,y)
end

function Puppet:getPosition()
    return self._rootNode:getPosition()
end

function Puppet:getCenterPosition()
    local x, y = self:getPosition()
    return x + 50, y + 80
end

function Puppet:setScale(scale)
    for _, model in pairs(self._modelMap) do
        model:setScale(scale)
        -- logger:info("puppet 缩放 scale=%.2f",scale)
    end
end

function Puppet:setVisible(visible)
    self._rootNode:setVisible(visible)
end

--受击效果
function Puppet:beHurt(bloods, num, callback, fCount, fsecond, delayDeath, delayHurt)
    
    self._isBeHurt = true --状态判断
    
    --算出要死的阵眼
    for _, blood in pairs(bloods) do
        self:cutHp(blood.delta, num, blood.state, fCount, fsecond)
    end

    --------------处理死亡的逻辑----------------
    if callback == nil then
        self._isBeHurt = false
        if self._liveModelNum == 0 then
            self:hideInfoPanel()
        end
        return
    end
    
    local rate = self._curHp / self._maxHp 
    
    local newDeathEyeList = {}
    for eye=1, self._defaultModelNum do
    	if (eye - 1) / self._defaultModelNum >= rate then
    	    --eye死亡
    	    if self._deathMap[eye] == nil then
                table.insert(newDeathEyeList, eye)
                self._deathMap[eye] = true
    	    end
    	end
    end
    
    local function endCall()
--        logger:info("=========endCall===============")
        self._isBeHurt = false
        self:playAnimation(ModelAnimation.Wait, true)
        if self._curHp <= 0 then
        else
            self._infoPanel:setVisible(true)  --TODO 这里有可能都死光了，不用再显示出来
        end
        
        if callback ~= nil then
            callback()
        end
    end
    
    local function beDeathCallback()
        if self._liveModelNum == 0 then --全死光了
            if callback ~= nil then --死光的时候是没有behurt回调的
                logger:info("=========beDeathCallback===============" .. self._index)
                callback()
            end
        
        self:hideInfoPanel() --
        end
    end
    
    local function delayDeathEye()
        --死亡的，直接播放
        for _, eye in pairs(newDeathEyeList) do
            self:beDeath(eye, beDeathCallback) 
        end
    end
    
    if self._curHp > 0 then
        delayDeathEye()  --还活着，该死的还是直接死
    else
        delayDeath = delayDeath or 0.2
        self:addTimerOnce(delayDeath * 1000, delayDeathEye, self)
    end

    ---------------------------------------
    
    --TODO 受击时，处理其血量，并且处理相关死亡逻辑
    --会同时做一些击退逻辑
    
    local function behurtcallback()
        print("------------behurtcallback--------------")
    end
    
    local function delayhurt()
        self:playAnimation(ModelAnimation.Hurt, false, endCall)
        self:characterColor(255, 0, 0)
    end
    
    if self._liveModelNum == 0 then
    
    elseif self._curHp > 0 then --没死光，受击效果
        self._infoPanel:setVisible(false)
        delayHurt = delayHurt or 0.3
        self:addTimerOnce(delayHurt * 1000, delayhurt, self)
    end
    
end

--某个阵眼死掉了
--通过计算整体的血量比,来决定死亡数
function Puppet:beDeath(eye, callback)
    local model = self:getModel(eye)
    
    local function endCall()
        self._liveModelNum = self._liveModelNum - 1
        model:setVisible(false)
        callback()
    end
    
    model:playAnimation(ModelAnimation.Die, false, endCall)
    
    model.isDeath = true -- 标记已经死了
end

function Puppet:characterColor(r, g, b)
    local action1 = cc.TintTo:create(0.2,r, g, b)
    local action2 = cc.TintTo:create(0.2, 255,255,255)
    local action = cc.Sequence:create(action1, action2)
    
    self:runModelAction(action)
end

function Puppet:backgroundColorAction(r, g, b, a, time)
    time = time or 1
    local action1 = cc.TintTo:create(time,r, g, b)
    local atioin1_1 = cc.FadeTo:create(time, a)
    
    local action2 = cc.TintTo:create(time, 255,255,255)
    local action2_2 = cc.FadeTo:create(time, 255)
    
    
    local action = cc.Sequence:create(cc.Spawn:create(action1, atioin1_1), cc.Spawn:create(action2, action2_2))

    local panelRoot = self._battlePanel:getPanelRoot()
    panelRoot:runAction(action)
end

--血量变化
function Puppet:cutHp(delta, num, hurtType, fCount, frameList)
    local curHp = self._curHp - delta
    
    if curHp < 0 then
        curHp = 0
        delta = self._curHp
    end
    local campHpDelta = delta

    if curHp >= self._maxHp then  --加到满血
        curHp = self._maxHp
        campHpDelta = self._curHp - self._maxHp
    end
    
    if hurtType == HurtType.CritHurt then
        self._battle:playShark()
    end
    
    self._curHp = curHp
    
    self:setHpTxt(self._curHp, num)

    -- logger:info("!!!!!!Puppet:cutHp!!!!!!!!campHpDelta:%d!!!!index:%d!!!!curHp:%d!!!!delta:%d!!!!%s", 
    --     campHpDelta, self._index, curHp, delta, debug.traceback())
    
    self._battlePanel:cutHpByCamp(campHpDelta, self:getCamp())
    
    fCount = fCount or 1  --飘血的次数
--    fsecond = fsecond or 1.2  --持续秒数
    
    local lastFrame = 0
    local curCount = 0
    local function effectCallback()
        if curCount <= fCount then
            
            local curDelta = math.floor(delta / fCount * curCount)
            if curCount == fCount then
                curDelta = delta
            end
            
            curCount = curCount + 1
            local fsecond = GameConfig.frequency * 30
            if frameList[curCount] ~= nil then
                 fsecond = GameConfig.frequency * (frameList[curCount] - lastFrame)
                lastFrame = frameList[curCount]
            end

            -- print("持续秒数···fsecond, fCount, curCount", fsecond, fCount, curCount)

            self:playBloodEffect(curDelta, hurtType, fsecond, curCount, fCount)
            
            self:addTimerOnce(fsecond * 1000, effectCallback, self)
        else
            
        end
    end
    
    --TODO 这里做单独的飘血逻辑frequency
    curCount = curCount + 1
    local fsecond = GameConfig.frequency * frameList[curCount]
    lastFrame = frameList[curCount]
    self:addTimerOnce( fsecond * 1000, effectCallback, self)
end

--渲染当前 血量 人数
function Puppet:setHpTxt(hp, num)
    local hpTxt = self._infoPanel:getChildByName("hpTxt")
    hpTxt:setString(num)
    
    local hpBar = self._infoPanel:getChildByName("hpBar")
    local percent = hp / self._maxHp * 100
    hpBar:setPercent(percent)
    hpBar:setVisible(false)
end

function Puppet:setModelName()
    local nameTxt = self._infoPanel:getChildByName("nameTxt")
    local info = ConfigDataManager:getConfigById(
        ConfigData.ModelGroConfig, self._modelType)
    nameTxt:setString(info.modelName)
    -- nameTxt:setString(info.modelName..self._modelType)  --测试

    --同时设置武将
    local heroId = self._heroId
    local heroImg = self._infoPanel:getChildByName("heroImg")

    -- print("--同时设置武将名字 heroId,index",heroId,self._index)

    if heroId > 0 then
        heroImg:setVisible(true)

        local initVisible = false
        local power = GamePowerConfig.Hero
        if self._index == ModelConsIndex.Left or self._index == ModelConsIndex.Right then
            power = GamePowerConfig.Counsellor  --军师名字
            initVisible = true
        end

        local info = ConfigDataManager:getConfigByPowerAndID(power, heroId)
        local color = ColorUtils:getColorByQuality(info.color) 
        nameTxt:setColor(color)
        nameTxt:setString(info.name)

        if initVisible == true then
            self:setConsiNameVisible(initVisible) --初始化，默认显示军师名字
        else
            TextureManager:updateImageView(heroImg, info.url)
            heroImg:setScale(0.3)
            self:setHeroNameVisible(initVisible) --初始化，默认不显示英雄名字
        end

    else
        heroImg:setVisible(false)
        nameTxt:setVisible(false)

        nameTxt:setColor(ColorUtils.wordWhiteColor)
        nameTxt:setString(TextWords:getTextWord(127))
    end
end

--设置军师名字的显示
function Puppet:setConsiNameVisible(visible)
    local bgImg = self._infoPanel:getChildByName("bgImg")
    local nameTxt = self._infoPanel:getChildByName("nameTxt")
    local heroImg = self._infoPanel:getChildByName("heroImg")
    local starNum = self._infoPanel:getChildByName("starNum")
    local hpTxt = self._infoPanel:getChildByName("hpTxt")
    hpTxt:setVisible(not visible)
    nameTxt:setVisible(visible)

    local star = self._consiStar  --军师的星级，为0时不显示星级
    if star == nil or star > 5 then  --star > 5 暂时先按0处理
        star = 0
    end
    
    local x = bgImg:getPositionX()
    if star == 0 then  --没星时名字居中
        heroImg:setVisible(false)
        starNum:setVisible(false)
        bgImg:setScaleX(1)
        local size = bgImg:getContentSize()
        local scalex = bgImg:getScaleX()
        nameTxt:setPositionX(x + size.width*scalex/2 + 5)
        nameTxt:setAnchorPoint(0.5,0.5)
    else  --有星时名字跟随星级
        local url = string.format("images/newGui1/adviser_num_%d.png",star)
        -- TextureManager:updateImageView(starNum,url)
        starNum:setString(star)
        starNum:setLocalZOrder(25)
        TextureManager:updateImageView(heroImg,"images/newGui1/IconStarMini.png")
        heroImg:setScale(1)
        heroImg:setLocalZOrder(20)
        bgImg:setScaleX(1.5)

        local size1 = heroImg:getContentSize()
        local size2 = starNum:getContentSize()

        local par=nameTxt:getParent():getParent()
        print("------------------------------par------------------"..par:getPositionX())
        if par:getPositionX()>320 then
        nameTxt:setPositionX(x + size1.width + size2.width-10)
        else
        nameTxt:setPositionX(x + size1.width + size2.width+10)
        end
        nameTxt:setAnchorPoint(0,0.5)
        heroImg:setVisible(true)
        starNum:setVisible(true)
    end

end

--设置英雄名字的可见性
function Puppet:setHeroNameVisible(visible)
    local nameTxt = self._infoPanel:getChildByName("nameTxt")
    nameTxt:setVisible(visible)

    local hpTxt = self._infoPanel:getChildByName("hpTxt")
    hpTxt:setVisible(not visible)
end

function Puppet:getModelType()
    return self._modelType
end

function Puppet:getModelName()
    return self._modelName
end

function Puppet:getName()
    return self._name
end

function Puppet:getCamp()
    return self.camp
end

-- 根据阵营转为朝向,左边阵营朝右，右边阵营朝左
function Puppet:getDirFromExchangeCamp()
    local dir = ModelDirection.Left
    if self.camp == BattleCamp.Left then
        dir = ModelDirection.Right
    end
    return dir
end

function Puppet:hideInfoPanel()
    if self._rootNode == nil then
        logger:info("~~~~~~~~~~Puppet:hideInfoPanel~~~~~~~index:%d~~~~~~~~~~~~~", self._index)
    end
    self._infoPanel:setVisible(false)
    self._rootNode:setVisible(false)
end

function Puppet:playBloodEffect(delta, hurtType, actionTime, curCount, fCount)
    
    -- hurtType = HurtType.RefrainHurt  --TODO 测试代码 克制
    -- hurtType = HurtType.CritHurt  --TODO 测试代码 暴击

    local value = math.abs(delta)
    local boolItem = self["_boolItem" .. hurtType]
    if boolItem == nil then
        boolItem = NumFactory:getInstance():getNumByType(hurtType, value)
        boolItem:setPosition(50, 50)
        boolItem:setLocalZOrder(4000)
        
        if self._bloodPanel then
            self._bloodPanel:addChild(boolItem)
        else
            self._rootNode:addChild(boolItem)  --容错
        end

        
        self["_boolItem" .. hurtType] = boolItem
    end
    
    if hurtType == HurtType.RefrainHurt or hurtType == HurtType.CritHurt then
        --暴击、克制的数值
        local number = boolItem:getChildByTag(hurtType)
        number:setString(value)
    else
        boolItem:setString(value)
    end
    
    boolItem:stopAllActions()
    boolItem:setVisible(true)
    
    local function callback()
        boolItem:setVisible(false)
    end
    
    local args = {}
    args["x"] = 50
    args["y"] = 50
    args["value"] = delta
    args["hurtType"] = hurtType
    args["actionTime"] = actionTime --持续时间
    args["parent"] = self._rootNode
    args["callback"] = callback
    args["effectNode"] = boolItem
    args["curCount"] = curCount
    args["fCount"] = fCount
    
    BloodEffect:play(args)
end

--外部整体移动
--speed单位， 像素/s
function Puppet:moveTo(pos, speed, callback) 
    
    local tx, ty = pos.x, pos.y
    local sx, sy = self._rootNode:getPosition()
    
    local dx = tx - sx
    if dx ~= 0 then
        local dir = self:getDirByDx(dx)
        self:setDirection(dir)
    end
    
    local ady = math.abs(ty - sy)
    local adx = math.abs(dx)
    local s = math.sqrt( ady * ady + adx * adx)
    
    local time = s / speed
    
    local function moveEnd()
        self:playAnimation(ModelAnimation.Wait,true)
        self:setDirection(self._defaultDir)
        if callback ~= nil then
            callback()
        end
    end

    local move = cc.MoveTo:create(time, pos) 
    local action = cc.Sequence:create(move, cc.CallFunc:create(moveEnd))
    
    self._rootNode:runAction(action)
    
    self:playAnimation(ModelAnimation.Run,true)
end

function Puppet:getSpawPos()
    return self._spawPos
end

--阵法改变。内部模型改变 time变阵时间，单位毫秒
function Puppet:changeZhenfa(zhenfaId, time, callback)
    
    if self._curZhenfa == zhenfaId then
        if callback ~= nil then
            callback()
        end
        return
    end
    self._curZhenfa = zhenfaId
    
    local num = 0
    local function completeCall(target)
        self:chageModelLocalZOrder(target.eye)
        num = num + 1
        if num == self._defaultModelNum then
            if callback ~= nil then
                callback()
            end
        end
    end
    
    logger:info("=----changeZhenfa--zhenfaId:%d----modelType:%d--------", zhenfaId, self._modelType)
    
    for eye=1, self._defaultModelNum do
        local info = self:getZhenfaInfo(zhenfaId, eye)
        if info == nil then
            info = self:getZhenfaInfo(self._defaultZhenfa, eye)
        end
            
        local x = self:xAxis( info.x )
        local y = info.y
        
        local model = self:getModel(eye)
        
        local moveTo = cc.MoveTo:create(time / 1000,cc.p(x,y))
        
        local dir = model:getDirection()
        local scale = self:getScaleByY(y)
        local scaleTo = cc.ScaleTo:create(time / 1000, dir * scale , scale)
        
        local spawn = cc.Spawn:create(moveTo, scaleTo)
        
        local action = cc.Sequence:create(spawn, cc.CallFunc:create(completeCall))
        
        model:runAction(action)
        model._rootNode.eye = eye --直接赋值 缓存了。。
    end
    
end

function Puppet:getZhenfaInfo(zhenfa, eye)
    local info = ConfigDataManager:getInfoFindByThreeKey(ConfigData.ZhenfaConfig,
        "type", zhenfa, "eye", eye, "camp", self.camp)
    return info
end

function Puppet:xAxis(x)
    if self.camp == BattleCamp.Left then
--        x = 100 + x
    end
    
    return x
end

--通过Y值 获取对应的scale比例
--0->1  100->0.6
function Puppet:getScaleByY(y)
    return 1
--    return self._defaultScale - y * 0.0025
end

function Puppet:chageModelLocalZOrder(eye)
    local model = self:getModel(eye)
    local _, y = model:getPosition()
    model:setLocalZOrder(100 - y)
end

function Puppet:chageModelScale(eye)
    local model = self:getModel(eye)
    local _, y = model:getPosition()
    local scale = self:getScaleByY(y)
    model:setScale(scale) 
end

function Puppet:getModel(eye)
    return self._modelMap[eye]
end

function Puppet:runModelAction(action)
    for _, model in pairs(self._modelMap) do
        local ac = action:clone()
        model:runModelAction(ac)
    end
end

function Puppet:getDirByDx(dx)
    local dir = ModelDirection.Right
    if dx < 0 then
        dir = ModelDirection.Left
    end
    return dir
end

function Puppet:getMapPanel()
    if self._rootNode == nil then
        return
    end
    return self._rootNode:getParent()
end

function Puppet:addChild(child)
    if self._rootNode == nil then
        return
    end
    self._rootNode:addChild(child)
end

function Puppet:addTimerOnce(delay, func, obj, ...)
    self._battle:addTimerOnce(delay, func, obj, ...)
end

function Puppet:playEffect(effectName, dx, dy, delay)
    if self._rootNode == nil then
        return
    end
    local function createEffect( )
        local spineEffect = SpineEffect.new(effectName, self._rootNode)
        spineEffect:setPosition(dx * self._curDir + 50, dy  + 50)  --50写死。居中处理。 * self._curDir
        spineEffect:setLocalZorder(1000)
        spineEffect:setDirection(self._curDir)
        logger:info("低阶特效 Puppet effectName,dx,dy,delay,dir=%s,%d,%d,%d,%d",effectName,dx,dy,delay,self._curDir)
    end

    if delay > 0 then
        -- TimerManager:addOnce(delay, self.delayNextAction, self)
        self:addTimerOnce(delay, self.delayNextAction, self)
    else
        createEffect()
    end

end

