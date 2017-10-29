--模型对象池，只对战斗中的模型实例进行缓存
--已达到快速战斗，而不用每次都去创建
SpineModelPool = {}

function SpineModelPool:init(gameState)
    self._modelPool = {}
    self._saveTime = 60 * 5 --缓存内存保存的时间 十分钟释放
    self._triggerTime = 60
    
    self._initTimer = false
    
    self._gameState = gameState
    self._spineList = {}
    self._spineResMap = {}  --保存spine的纹理资源

    self._updateCount = 0
end

--将池清空掉
function SpineModelPool:finalize()
    TimerManager:remove(self.autoRelease, self)
    self._initTimer = false
    self:autoRelease(true) --全部清除
end

--将放太久的缓存清除掉
function SpineModelPool:autoRelease(cleanup)

    local isNotFinalizeRes = self._gameState:isNotFinalizeRes(true)
    if isNotFinalizeRes == true and cleanup ~= true then
        self._updateCount = 0
        return  --当前情况，不释放资源
    end
    --应该确保，所有的模块都释放完了，才释放这个

    self._updateCount = self._updateCount + 1  --中间有一个间隔，防止，立马直接释放
    if self._updateCount % 2 ~= 0 and cleanup ~= true then
        return
    end

    self._updateCount = 0

    logger:info("~~~开始检测模型~~")

    local modelPool = {}
    local time = os.time()
    for modelType, modelList in pairs(self._modelPool) do    --模型的入池是延迟2秒的，当刚好未入池时，这边就全部释放了，就会出现问题
        if modelPool[modelType] == nil then
            modelPool[modelType] = {}
        end
        for _, modelNode in pairs(modelList) do
            local pushTime = modelNode.pushTime
            if cleanup == true or time - pushTime  > self._saveTime then
    		    --直接释放
               logger:info("=-----===-SpineModelPool:autoRelease-==---modelType:%d------", modelType)
    		    modelNode:cleanup()
    		    modelNode:release()

                self._spineList[modelType].count = self._spineList[modelType].count - 1 --引用计数减去1
                
    		else  --小于保存内，才会保存起来
                table.insert(modelPool[modelType], modelNode)
    		end
    	end
    end

    --如果modelType对应的缓存都释放干净了，则直接释放掉资源
    local removeModelType = {}
    for modelType, pool in pairs(modelPool) do
        if self._spineList[modelType].count == 0 then  --没有外部引用了
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
--在一定时机上，需要释放掉
--改模型ID超过5分钟都没有引导了，则直接释放掉
function SpineModelPool:preLoad(modelType)
    if self._spineList[modelType] ~= nil then
        return
    end

    -- local json = "model/" .. modelType .. "/skeleton.json"
    -- local atlas = "model/" .. modelType .. "/skeleton.atlas"
    local json,atlas = self:resetModelRes( modelType )

    local function createSkeleton()
        local spine = sp.SkeletonAnimation:create(json, atlas)  
        spine.count = 0  --被创建出来的引用数，当检测为0的时候，则进行释放
        spine:retain()
        self._spineList[modelType] = spine  
    end

    -- 如果有预加载的话，是不能获取到addKey的，应该换种方式获取
    local addKey = TextureManager:addDiffTextureKey(createSkeleton, false)
    self._spineResMap[modelType] = addKey
      
--    print("============SpineModelPool:preLoad==========", modelType)
end

--彻底释放掉模型资源，包括纹理资源
function SpineModelPool:finalizeSpine(modelType)
    logger:info("~~~~~~SpineModelPool:finalizeSpine~~~modelType:%d~~~~~~~", modelType)
    if self._spineList[modelType] == nil then
        logger:error("~~~~~~~~要释放的资源不存在~~~~modelType:%d~~~~~~~", modelType)
        return
    end

    local spine = self._spineList[modelType]
    spine:release()

    self._spineList[modelType] = nil

    local addKey = self._spineResMap[modelType]
    for _, key in pairs(addKey) do
        TextureManager:removeTextureForKey(key)
    end
end

-- 容错处理：6阶+模型不存在时，用5阶的模型替代
function SpineModelPool:resetModelRes( modelType )
    -- body

    local function getFileUrl(modelType)
        -- body
        local json = "model/" .. modelType .. "/skeleton.json"
        local atlas = "model/" .. modelType .. "/skeleton.atlas"
        return json,atlas
    end
    
    local json,atlas = getFileUrl(modelType)
    if (modelType % 100) > 5 then
        local jsonF = cc.FileUtils:getInstance():isFileExist(json)
        local atlasF = cc.FileUtils:getInstance():isFileExist(atlas)

        if jsonF == false or atlasF == false then
            logger:error("模型容错 modelType=%d",modelType)
            modelType = math.floor(modelType / 100) * 100 + 5
            json,atlas = getFileUrl(modelType)
        end
    end

    return json,atlas
end

function SpineModelPool:getSpineModel(modelType)
    if self._spineList[modelType] == nil then
        -- logger:info("获取前，先preLoad")
        self:preLoad(modelType)
    end
    -- logger:info("一个新的模型 modelType=%d",modelType)
    local spine = self._spineList[modelType]
    spine.count = spine.count + 1
    local newSpine = sp.SkeletonAnimation:createWithData(spine)
    return newSpine
end

--isFirst如果是第一次，则将retain起来
function SpineModelPool:push(modelType, modelNode)
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

function SpineModelPool:pop(modelType)
    local modelNode = nil
    if self._modelPool[modelType] ~= nil then
        modelNode = table.remove(self._modelPool[modelType], 1)
    end
    
    return modelNode
end

----------------------------------------------------

SpineModel = class("SpineModel")

function SpineModel:ctor(modelType, parent, isStoke, preLoad)
    self._rootNode = cc.Node:create()
    
    self._eventListers = {}
    self._curAnimation = nil
    
    self._dir = 1
    self._scale = 1
    self._modelType = modelType
    self._isStoke = isStoke or false
    self._preLoad = preLoad or false
    
    parent:addChild(self._rootNode)
    self:createModel(modelType)
    
    self._parent = parent
end

function SpineModel:delayPushPool(modelType, modelNode, rootNode)

    SpineModelPool:push(modelType, modelNode)
    rootNode:removeChild(modelNode, false)  --不要清理，下次缓存还会使用

    logger:info("~~~~~~~~~真正进入释放池~~~~modelType:%d~~~~~~~~~~~~", modelType)
    
    rootNode:removeFromParent()
end

function SpineModel:finalize(isPush)
    if self._modelNode == nil then
        logger:info("释放的模型 不存在")
        return
    end

    logger:info("~~~~~~~~~准备释放~~~~modelType:%d~~~~~~~~~~~~", self._modelType)

    self:unregisterEventHandler()
--    isPush = false --不使用池缓存了
    if isPush ~= false then
        if self._isStoke == true then --战斗的模型，延后入池
            --TODO 如果还没有入池时，直接切换账号，则会出现闪退问题！
            local time = 2000
            if self._preLoad == true then
                time = 300
            end
            TimerManager:addOnce(time, self.delayPushPool, self, self._modelType, self._modelNode, self._rootNode)
        else
            self:delayPushPool(self._modelType, self._modelNode, self._rootNode)
        end
        
    else
        self._rootNode:removeChild(self._modelNode)
        self._parent:removeChild(self._rootNode)
    end
--    self._rootNode:removeChild(self._modelNode)
--    self._parent:removeChild(self._rootNode)
    
--    print("---------finalize-------SpineModel----------", self._modelType)
--    
    self._parent = nil
    self._rootNode = nil
    self._modelNode = nil
    self._bgModelNode = nil
end

function SpineModel:createModel(modelType)
    local json = "model/" .. modelType .. "/skeleton.json"
    local atlas = "model/" .. modelType .. "/skeleton.atlas"
    self._modelType = modelType
    if self._preLoad ~= true then
        -- logger:info("模型 preLoad")
        self._modelNode = SpineModelPool:pop(modelType) --nil --
    end
    
    if self._modelNode == nil then
        logger:info("~~~~~~~~~SpineModel~~~~创建模型~~~~~:%d~~~~~~~~~~~~", modelType)
        -- logger:info("模型 获取")
        self._modelNode = SpineModelPool:getSpineModel(modelType) --sp.SkeletonAnimation:create(json, atlas)
        local anchorPoint = self._modelNode:getAnchorPoint()
--        self._modelNode:setAnchorPoint(cc.p(0.5, 0))
        if self._isStoke == true then
            NodeUtils:renderStoke(self._modelNode, cc.c3b(0,0,0))  --先注释掉描边
        end
    else
        logger:info("~~~~~~~~~SpineModel~~~从缓存拿数据~~~:%d~~~~~~~~~~~~", modelType)
    end
    
    self._modelNode:setOpacity(255)
    self._rootNode:addChild(self._modelNode)
    self:registerEventHandler()
end


function SpineModel:playAnimation(name, isLoop, completeCallback, obj, customEventKey, customCallback)
    if self._modelNode == nil then
        return
    end
    self._curAnimation = name
    isLoop = isLoop or false
    self._modelNode:setAnimation(0, name, isLoop)
    
    if completeCallback ~= nil then  --动作播放完成回调
        self:addEventLister("complete", name, completeCallback, obj)
    end
    
    if customEventKey ~= nil and customCallback ~= nil then
        self:addEventLister(customEventKey, name, customCallback, obj)
    end
end

function SpineModel:setPosition(x, y)
    if self._rootNode == nil then
        return
    end
    self._rootNode:setPosition(x, y)
end

function SpineModel:getPosition()
    if self._rootNode == nil then
        return 0, 0
    end
    return self._rootNode:getPosition()
end

function SpineModel:getPositionX()
    if self._rootNode == nil then
        return 0
    end
    return self._rootNode:getPositionX()
end

function SpineModel:setPositionX(x)
    if self._rootNode == nil then
        return
    end
    return self._rootNode:setPositionX(x)
end

function SpineModel:getPositionY()
    if self._rootNode == nil then
        return 0
    end
    return self._rootNode:getPositionY()
end

function SpineModel:setPositionY(y)
    if self._rootNode == nil then
        return
    end
    return self._rootNode:setPositionY(y)
end

function SpineModel:getContentSize()
    if self._modelNode == nil then
        return
    end
    return self._modelNode:getContentSize()
end

function SpineModel:setAnchorPoint(pos)
    if self._modelNode == nil then
        return
    end
    self._modelNode:setAnchorPoint(pos)
end

----- 1 , -1
function SpineModel:setDirection(dir)
    if self._rootNode == nil then
        return
    end
    self._dir = dir
    self._rootNode:setScaleX(dir * self._scale)
end

function SpineModel:getDirection(dir)
    return self._dir
end

function SpineModel:setLocalZOrder(zOrder)
    if self._rootNode == nil then
        return
    end
    self._rootNode:setLocalZOrder(zOrder)
end

function SpineModel:runAction(action)
    if self._rootNode == nil then
        return
    end
    self._rootNode:runAction(action)
end

function SpineModel:runModelAction(action)
    if self._modelNode == nil then
        return
    end
    self._modelNode:runAction(action)
end

function SpineModel:setOpacity(opacity)
    if self._modelNode == nil then
        return
    end
    self._modelNode:setOpacity(opacity)
end

function SpineModel:setScale(scale)
    self._scale = scale
    self._rootNode:setScaleX(scale * self._dir)
    self._rootNode:setScaleY(scale)
end

function SpineModel:getScaleX()
    return self._rootNode:getScaleX()
end

function SpineModel:getScaleY()
    return self._rootNode:getScaleY()
end

function SpineModel:setVisible(visible)
    self._rootNode:setVisible(visible)
end

function SpineModel:setColor(color)
    self._modelNode:setColor(color)
end

function SpineModel:pause()
    self._modelNode:pause()
end

-------------事件
function SpineModel:registerEventHandler()
    local function callback(event)
        local typeListers = nil
        local listerType = nil
        if event.type == "complete" then
            listerType = "complete"
        elseif event.type == "start" then
            listerType = "start"
        elseif event.type == "end" then
            listerType = "end"
        else
            local frameType = event.eventData.name
            listerType = frameType
        end
        
        typeListers = self._eventListers[listerType]
        if typeListers ~= nil then
            local listers = typeListers[self._curAnimation] or {}
            for _, node in pairs(listers) do
                node["lister"](node["obj"])
            end
        end
    end

    self._modelNode:registerSpineEventHandler(callback)
end

function SpineModel:unregisterEventHandler()
    self._modelNode:unregisterSpineEventHandler()
end

function SpineModel:addEventLister(type, animation, lister, obj)
    local typeListers = self._eventListers[type]

    if typeListers == nil then
        self._eventListers[type] = {}
        typeListers = self._eventListers[type]
    end

    local listers = typeListers[animation]
    if listers == nil then
        typeListers[animation] = {}
    end

    local isInList = false
    for _, node in pairs(typeListers[animation]) do
        if node.lister == lister then
            isInList = true
        end
    end
    if isInList == false then
        table.insert(typeListers[animation],{lister = lister, obj = obj})
    end
end

function SpineModel:removeEventLister(type, animation, lister)
    local typeListers = self._eventListers[type]
    if typeListers == nil then
        return
    end

    local listers = typeListers[animation]
    if listers == nil then
        return
    end

    for key, node in pairs(typeListers[animation]) do
        if node.lister == lister then
            typeListers[animation][key] = nil
        end
    end
end









