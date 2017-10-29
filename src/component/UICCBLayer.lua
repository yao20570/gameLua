require "CCBReaderLoad"
UICCBLayer = class("UICCBLayer")

----------------------------------------------
-------ccbi资源加载器-------------
-------注意：callback采用owner方式，美术处理--> Target-->Owner
---------- 使用例子
--    local owner = {}
--    owner["complete"] = complete
--    local ccbLayer = UICCBLayer.new("MainScene", self.gameScene, owner)
----------目前更美术约定两个时间帧
----------完成：complete
----------暂停：pause
----------
---@param ccbname ccbi名字
---@param parent  父容器
---@param owner   回调方法表
---@param completeFunc 完成回调方法,如果不为nil，则表示播放一次，辅助字段，默认为nil，
--                   如果为function，则该ccbi资源需要增加一个complete的callback,美术处理(处理方式，详见上面的注意)
--                   最终执行completeFunc回调，且默认会删除掉该实例资源
--@param isPlayOnce 是否播放一次，如果为true，则在complete回调的时候，同时删除掉资源
--@param moduleName 模块名字
---@param pauseFunc 暂停帧回调
function UICCBLayer:ctor(ccbname, parent, owner, completeFunc, isPlayOnce, moduleName, pauseFunc)
    self._callback = completeFunc
    self._callbackPause = pauseFunc
    self._name = ccbname
    self._isPause = false
    local function complete()
        if self._callback ~= nil then
            self._callback()
        end
        
        if isPlayOnce == true then
           self:finalize()
        end
        
    end

    local function pause()
        logger:info("======pause==========")
        if self._callbackPause ~= nil then
            self._callbackPause()
        end
    end

    if type(self._callback) == "function" or isPlayOnce then
        owner = owner or {}
        owner["complete"] = complete
        owner["pause"] = pause
    end

    local function loadCCB()       ------这一块还是有问题，当特效的资源，有一些被引用到，但是这里算出来的资源特效就缺少了！！！
                                   -------会导致各种问题！ ccb资源是共用的
        if ccbname~="rgb-dianji" then
            logger:error("~~加载特效：%s", ccbname)
        end
        local  proxy = cc.CCBProxy:create()
        local  layer  = CCBReaderLoad("ccb/ccbi/" .. ccbname .. ".ccbi", proxy, owner)
        --local  layer = cc.Node:create()

        -- 判断为空
        if parent then
            parent:addChild(layer)
        else
            --print("parent的值为空")
        end
        self._layer = layer
        self._ccbProxy = proxy
        --logger:error("~~~~~~~结束加载特效：%s~~~~~~~~~~~~~~", ccbname)
    end


    local keys = TextureManager:addDiffTextureKey(loadCCB, false)
    TextureManager:addEffectTextureKeys(ccbname, keys, moduleName)

    local function getTextureData()
        local result = require("ccb/ccbi/" .. ccbname)
        return result
    end
    local status, data = pcall(getTextureData)
    if status == true then
        for url, _ in pairs(data) do
            url = cc.FileUtils:getInstance():fullPathForFilename(url)
            TextureManager:addTextureKey2TopModule(url,moduleName)
        end
    else
        logger:error("~~~~~~获取特效资源配置表异常~~~~~~~~~~")
    end

    --
    GlobalConfig.ccbMapInfos[self] = self
end

function UICCBLayer:finalize()

    -- 删除了动画和动画的引用(父节点为空的的失去最后一份引用，就会被删)
    if self._layer ~= nil then
        self._layer:stopAllActions()

        -- 
        self._layer:removeFromParent()
	    self._layer = nil
    end

    GlobalConfig.ccbMapInfos[self] = nil
end

function UICCBLayer:isFinalize()
    
    return self._layer == nil

end 

-- 注意,parentNode为nil时,慎用
function UICCBLayer:changeParent(parentNode)
    local curParent = self._layer:getParent()
    if curParent ~= nil and curParent ~= parentNode then
        self._layer:retain()
        self._layer:removeFromParent(false)
    end

    -- 添加到父节点
    if parentNode == nil then

    else
        if curParent ~= parentNode then
            parentNode:addChild(self._layer)
            self._layer:release()
        end
    end
end

function UICCBLayer:getName()
    return self._name
end

function UICCBLayer:removeFromParent()
    self:finalize()
end

function UICCBLayer:getChildren( )
    return self._layer:getChildren()
end

function UICCBLayer:getContentSize()
    return self._layer:getContentSize()
end

function UICCBLayer:addChild(node)
    return self._layer:addChild(node)
end

function UICCBLayer:getChild(name)
    return self._layer:getChild(name)
end
--[[
    修复:传进来的setPosition({x=1,y=1})不会生效问题
]]
function UICCBLayer:setPosition(x, y)
    self._layer:setPosition(cc.p(x, y))
end

--设置方向 1正 -1反
--TODO如果有缩放，还需要乘以缩放比例
function UICCBLayer:setDir(dir)
    self._layer:setScaleX(dir)
end

--设置x,y翻转
function UICCBLayer:setDirection(dirPos)
    self._layer:setScaleX(dirPos.x)
    self._layer:setScaleY(dirPos.y)
end

function UICCBLayer:stopAllActions()
	self._layer:stopAllActions()
end

function UICCBLayer:getPosition()
    return self._layer:getPosition()
end

function UICCBLayer:getPositionX()
    return self._layer:getPositionX()
end

function UICCBLayer:getPositionY()
    return self._layer:getPositionY()
end

function UICCBLayer:setPositionX(posX)
    self._layer:setPositionX(posX)
end

function UICCBLayer:setPositionY(posY)
    self._layer:setPositionY(posY)
end

-- 锚点修改无效
function UICCBLayer:setAnchorPoint(x, y)
    self._layer:setAnchorPoint(x, y)
end

-- 缩放
function UICCBLayer:setScale(scale)
    self._layer:setScale(scale)
end

function UICCBLayer:setRotation(rotation)
    self._layer:setRotation(rotation)
end

--设置透明度
function UICCBLayer:setOpacity(opacity)
    self:setOpacityChildren(self._layer,opacity) 
end

function UICCBLayer:setOpacityChildren(node,opacity)
    node:setOpacity(opacity)
    local children = node:getChildren()
    for _, child in pairs(children) do
        self:setOpacityChildren(child, opacity)
    end
end

-- get
function UICCBLayer:getLayer()
    return self._layer
end

-- 执行动作
function UICCBLayer:runAction(action)
    self._layer:runAction(action)
end

-- setZOrder
function UICCBLayer:setLocalZOrder(order)
    self._layer:setLocalZOrder(order)
end

--setContentSize(progress.initWidth, h)

function UICCBLayer:setContentSize(width, height)
    self._layer:setContentSize(width, height)
end

function UICCBLayer:setCompleteCallback(callback)
    self._callback = callback
end

-- 可见
function UICCBLayer:setVisible(isShow)
    if self._layer:isVisible() == isShow then
        return
    end

    self._layer:setVisible(isShow)
    if isShow == true then
        self:resume()
    else
        self:pause()
    end
end
function UICCBLayer:isVisible()
    return self._layer:isVisible()
end

function UICCBLayer:pause()
    self._isPause = true
    self:pauseChildren(self._layer)
end

--处理粒子，其他都暂停
function UICCBLayer:pauseNotParticleSystem()
    self:pauseChildren(self._layer, self.isParticleSystem)
end

function UICCBLayer:pauseChildren(node, condition)
    node:pause()
    local children = node:getChildren()
    for _,child in pairs(children) do
        if condition == nil or (not condition(self, child)) then
            self:pauseChildren(child, condition)
        end
    end
end

function UICCBLayer:resume()
    self._isPause = false
    self:resumeChildren(self._layer)
end

function UICCBLayer:resumeChildren(node)
    node:resume()
    local children = node:getChildren()
    for _,child in pairs(children) do
    	self:resumeChildren(child)
    end
end

---
---设置粒子的位置类型
---@param positionType 0 free 1 2 group
function UICCBLayer:setPositionType(positionType)
    self:setPositionTypeChildren(self._layer, positionType)
end

function UICCBLayer:setPositionTypeChildren(node, positionType)

    if self:isParticleSystem(node) then
        local particleSystemQuad = tolua.cast(node, "cc.ParticleSystem")
        particleSystemQuad:setPositionType(positionType)
    end
    local children = node:getChildren()
    for _,child in pairs(children) do
    	self:setPositionTypeChildren(child, positionType)
    end
end

-----设置是否开启，默认是混合模式···
-----当特效为不适用混合模式时，bool设置为false
function UICCBLayer:setBlendAdditive(bool)
    self:setBlendAdditiveChildren(self._layer, bool)
end

function UICCBLayer:setBlendAdditiveChildren(node, bool)
    if self:isParticleSystem(node) then
        local particleSystemQuad = tolua.cast(child, "cc.ParticleSystem")
        if particleSystemQuad ~= nil then
             particleSystemQuad:setBlendAdditive(bool)
        end
    end

    local children = node:getChildren()
    for _,child in pairs(children) do
    	self:setBlendAdditiveChildren(child, bool)
    end
end

function UICCBLayer:setCascadeOpacityEnabledChildren(node, enabled)
--    if self:isParticleSystem(node) then
--        local particleSystemQuad = tolua.cast(node, "cc.ParticleSystem")
--        if particleSystemQuad ~= nil then
--             particleSystemQuad:setCascadeOpacityEnabled(enabled)
--        end
--    end
    node:setCascadeOpacityEnabled(enabled)
    local children = node:getChildren()
    for _,child in pairs(children) do
    	self:setCascadeOpacityEnabledChildren(child, enabled)
    end
end


function UICCBLayer:printDescription(node)
    local description = node:getDescription()
    print("~~printDescription~~", description)
    local children = node:getChildren()
    for _, child in pairs(children) do
        self:printDescription(child)
    end
end

--判断节点是否为粒子
function UICCBLayer:isParticleSystem(node)
    local description = node:getDescription()
    if string.find(description, "ParticleSystem") ~= nil then
        return true
    end
    return false
end

function UICCBLayer:checkTexture()
    self:checkTextureChildren(self._layer)
end

--通过Node检测所使用到的纹理
function UICCBLayer:checkTextureChildren(node)
    local nodeType = self._ccbProxy:getNodeTypeName(node)
    print("~~~~checkTextureChildren~~~~~~", nodeType)
    if nodeType == "cc.Sprite" then
        local sprite = tolua.cast(node, nodeType)
        local texture = sprite:getTexture()
    end

    local children = node:getChildren()
    for _,child in pairs(children) do
        self:checkTextureChildren(child)
    end
end




