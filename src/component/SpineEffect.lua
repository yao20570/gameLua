
SpineEffectPool = {}

function SpineEffectPool:init(gameState)
    self._modelPool = {}
    self._saveTime = 60 * 5 --缓存内存保存的时间 五分钟
    self._triggerTime = 60

    self._initTimer = false

    self._gameState = gameState
    
    self._spineList = {}
    self._spineResMap = {}  --保存spine的纹理资源

    self._updateCount = 0
end

--将池清空掉
function SpineEffectPool:finalize()
    TimerManager:remove(self.autoRelease, self)
    self._initTimer = false
    self:autoRelease(true) --全部清除
end

--将放太久的缓存清除掉
function SpineEffectPool:autoRelease(cleanup)

    local isNotFinalizeRes = self._gameState:isNotFinalizeRes(true)
    if isNotFinalizeRes == true and cleanup ~= true then
        self._updateCount = 0
        return  --当前情况，不释放资源
    end

    self._updateCount = self._updateCount + 1  --中间有一个间隔，防止，立马直接释放
    if self._updateCount % 2 ~= 0 and cleanup ~= true then
        return
    end
    self._updateCount = 0

    logger:info("~~~~~~开始检测特效模型释放~~~~~~~~~")
    local modelPool = {}
    local time = os.time()
    for modelType, modelList in pairs(self._modelPool) do
        if modelPool[modelType] == nil then
            modelPool[modelType] = {}
        end
        for _, modelNode in pairs(modelList) do
            local pushTime = modelNode.pushTime
            if cleanup == true or time - pushTime  > self._saveTime then
                --直接释放
                logger:info("=-----===-SpineModelPool:autoRelease-==-:%s--------", modelType)
                modelNode:cleanup()
                modelNode:release()
                self._spineList[modelType].count = self._spineList[modelType].count - 1 --引用计数减去1
            else  --小于保存内，才会保存起来
                table.insert(modelPool[modelType], modelNode)
            end
        end
    end

    local removeModelType = {}
    for modelType, pool in pairs(modelPool) do
        if self._spineList[modelType].count == 0 then
            table.insert(removeModelType, modelType)
        end
    end

    for _,modelType in pairs(removeModelType) do
        self:finalizeSpine(modelType)
        modelPool[modelType] = nil
    end

    self._modelPool = nil
    self._modelPool = modelPool
end

--预先加载
function SpineEffectPool:preLoad(name)
    if self._spineList[name] ~= nil then
        return
    end
    local json = "effect/spine/" .. name .. "/skeleton.json"
    local atlas = "effect/spine/" .. name .. "/skeleton.atlas"
    
    local function createSkeleton()
        local spine = sp.SkeletonAnimation:create(json, atlas)
        spine.count = 0  --被创建出来的引用数，当检测为0的时候，则进行释放
        spine:retain()
        self._spineList[name] = spine
    end

    -- 如果有预加载的话，是不能获取到addKey的，应该换种方式获取
    local addKey = TextureManager:addDiffTextureKey(createSkeleton, false)
    self._spineResMap[name] = addKey

end

--彻底释放掉模型资源，包括纹理资源
function SpineEffectPool:finalizeSpine(name)
    if self._spineList[name] == nil then
        logger:error("~~~~~~~~要释放的资源不存在~~~~name:%s~~~~~~~", name)
        return
    end

    local spine = self._spineList[name]
    spine:release()

    self._spineList[name] = nil

    local addKey = self._spineResMap[name]
    for _, key in pairs(addKey) do
        TextureManager:removeTextureForKey(key)
    end
end

function SpineEffectPool:getSpineEffect(name)
    if self._spineList[name] == nil then
        self:preLoad(name)
    end

    logger:info("SpineEffect getSpineEffect  name=%s ",name)
    local spine = self._spineList[name]
    spine.count = spine.count + 1
    local newSpine = sp.SkeletonAnimation:createWithData(spine)

    return newSpine
end

--isFirst如果是第一次，则将retain起来
function SpineEffectPool:push(modelType, modelNode)
    if self._initTimer == false then
        TimerManager:add(self._triggerTime * 1000, self.autoRelease, self)
        self._initTimer = true
    end
    if modelNode.isInPool == nil then
        modelNode:retain()
        modelNode.isInPool = true
    end

    modelNode.pushTime = os.time()

    if self._modelPool[modelType] == nil then
        self._modelPool[modelType] = {}
    end

    table.insert(self._modelPool[modelType], modelNode)
end

function SpineEffectPool:pop(modelType)
    local modelNode = nil
    if self._modelPool[modelType] ~= nil then
        modelNode = table.remove(self._modelPool[modelType], 1)
    end

    return modelNode
end

-------------------------------------------------------------


SpineEffect = class("SpineEffect")

--特效一次性，播放完后，直接释放
function SpineEffect:ctor(name, parent, isLoop, preLoad)
    self._rootNode = cc.Node:create()
    
    self._scale = 1
    
    self._isLoop = isLoop or false
    self._preLoad = preLoad or false
    
    parent:addChild(self._rootNode)
    self:createEffect(name)

    self._parent = parent
    self._name = name
end

function SpineEffect:delayPushPool(modelType, modelNode, rootNode)
    SpineEffectPool:push(modelType, modelNode)
    rootNode:removeChild(modelNode, false)  --不要清理，下次缓存还会使用

    rootNode:removeFromParent()
end

function SpineEffect:finalize()
--    print("=============finalize=============", self._name)
--    self._rootNode:removeChild(self._effectNode)
--    self._parent:removeChild(self._rootNode)
    self:unregisterEventHandler()
    TimerManager:addOnce(100, self.delayPushPool, self, self._modelType, self._effectNode, self._rootNode)

    self._parent = nil
    self._rootNode = nil
    self._effectNode = nil
end

function SpineEffect:createEffect(name)
    local json = "effect/spine/" .. name .. "/skeleton.json"
    local atlas = "effect/spine/" .. name .. "/skeleton.atlas"
    
    self._modelType = name
    
    if self._preLoad ~= true then
        self._effectNode = SpineEffectPool:pop(name) --nil --
    end
    
    if self._effectNode == nil then
        -- logger:error("~~~~~~~~~SpineEffect~~~~创建模型特效~~~~~:%s~~~~~~~~~~~~", name)
        self._effectNode = SpineEffectPool:getSpineEffect(name) --sp.SkeletonAnimation:create(json, atlas)
    end
    
    self._rootNode:addChild(self._effectNode)
    self:registerSpineEventHandler()
    self._effectNode:setAnimation(0, "animation", self._isLoop)
    
    self._effectNode:resume()
end

function SpineEffect:registerSpineEventHandler()
    local function callback(event)
        if event.type == "complete" then
            self:unregisterEventHandler()
            TimerManager:addOnce(30,self.finalize,self)
        end
    end
    self._effectNode:registerSpineEventHandler(callback)
end

function SpineEffect:unregisterEventHandler()
    self._effectNode:unregisterSpineEventHandler()
end

function SpineEffect:setPosition(x, y)
    self._rootNode:setPosition(x, y)
end

function SpineEffect:setLocalZorder(zOrder)
    self._rootNode:setLocalZOrder(zOrder)
end

----- 1 , -1
function SpineEffect:setDirection(dir)
    self._dir = dir
    self._rootNode:setScaleX(dir * self._scale)
end

function SpineEffect:setRotation(r)
    self._effectNode:setRotation(r)
end


