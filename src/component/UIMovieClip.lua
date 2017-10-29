UIMovieClip = class("UIUIMovieClip")

function UIMovieClip:ctor(name, delay)

    self._name = name
    self._delay = delay or 0.04
    self._rootNode = cc.Sprite:create()

    self._moduleName = nil --这个特效是由哪个模块产生的
end

function UIMovieClip:finalize()
    self._rootNode:stopAllActions()
    self._parent:removeChild(self._rootNode)

    self._rootNode = nil
end

function UIMovieClip:removeFromParent()
    self:finalize()
end

function UIMovieClip:setModuleName(moduleName)
    self._moduleName = moduleName
end

function UIMovieClip:playActionName(name, loop, callback, delay)
    self._name = name
    self:play(loop, callback, delay)
end

function UIMovieClip:play(loop, callback, delay, customAction, moveDelay, standDelay)
    local function realPlay()
       self:realPlay(loop, callback, delay, customAction, moveDelay, standDelay) 
    end
    local keys = TextureManager:addDiffTextureKey(realPlay, false)
    TextureManager:addEffectTextureKeys(self._name, keys, self._moduleName)
end

function UIMovieClip:realPlay(loop, callback, delay, customAction, moveDelay, standDelay)
    self._rootNode:stopAllActions()
    delay = delay or self._delay

    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames("effect/frame/" .. self._name .. ".plist")

    local animFrames = {}
    local index = 1
    for j = 1, 90 do  --预留最大20帧
        local url = string.format(self._name .. "/%04d", j - 1)
        local spriteFrame = cache:getSpriteFrame(url)

        if spriteFrame ~= nil then
            animFrames[index] = spriteFrame
            index = index + 1
        end
    end

    local action = nil
    local animation = cc.Animation:createWithSpriteFrames(animFrames, delay)
    if loop == true then
        action = cc.RepeatForever:create(cc.Animate:create(animation))
    else
        if callback ~= nil then
            action = cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(callback))
        else
            action = cc.Animate:create(animation)
        end

    end

    -- 巡逻兵动画
    if customAction ~= nil then
        -- logger:info("customAction ~= nil 移动动画..")
        local animate = cc.Animate:create(animation)

        -- 同时2个执行动画，时间短的执行完要等待时间长点执行完，才会开始下一次循环
        -- 所以将序列帧动画弄成序列动画
        -- 确保：action总时长>=customAction
        -- 一个animate时长=index*delay（8*0.04=0.32）
        action = cc.Repeat:create(animate, (moveDelay+standDelay) / delay / (index-1) * 2 + 0)
        action = cc.Spawn:create(action,customAction)  
        action = cc.RepeatForever:create(action)
    end

    self._rootNode:runAction(action)
end

-- 主城小鸟特效
function UIMovieClip:playBird(loop, callback, delay, customAction1, customAction2, randomWait, randomCount1, randomCount2, effectName1, effectName2, endPos)
    self._rootNode:stopAllActions()
    delay = delay or self._delay

    local animFrames1 = self:addFrames(effectName1)
    local animation1 = cc.Animation:createWithSpriteFrames(animFrames1, delay)
    local action1 = cc.Animate:create(animation1)

    local animFrames2 = self:addFrames(effectName2)
    local animation2 = cc.Animation:createWithSpriteFrames(animFrames2, delay)
    local action2 = cc.Animate:create(animation2)

    action1 = cc.Repeat:create(action1, randomCount1)
    action2 = cc.Repeat:create(action2, randomCount2)

    local action = nil
    local a,b = math.modf(randomWait/2)
    if b == 0 then
        -- logger:info("顺序-----A- 1,2")
        action = cc.Sequence:create(action1, action2)
    else
        -- logger:info("顺序-----B- 2,1")
        action = cc.Sequence:create(action2, action1)
    end

    local perX = endPos.x/10
    local perY = endPos.y/10

    
    if customAction1 ~= nil then
                    
        self._rootNode:runAction(cc.RepeatForever:create(action))

        local function call()
            -- body
            if callback ~= nil then
                callback()
            end

            -- action = customAction1
            -- action = cc.Sequence:create(action, cc.DelayTime:create(randomWait), cc.CallFunc:create(call))
            action = cc.Sequence:create(customAction1, customAction2, cc.CallFunc:create(call))
            self._rootNode:setPosition(cc.p(0, 0))
            self._rootNode:runAction(action)
        end

        action = customAction1
        -- action = cc.Sequence:create(action, cc.DelayTime:create(randomWait), cc.CallFunc:create(call))
        action = cc.Sequence:create(action, customAction2, cc.CallFunc:create(call))

    
    elseif loop == true then
        action = cc.RepeatForever:create(action)
    end

    self._rootNode:runAction(action)
end

-- 主城资源建筑特效
function UIMovieClip:playResEffect(loop, callback, delay, customAction, moveDelay, standDelay)
    self._rootNode:stopAllActions()
    delay = delay or self._delay

    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames("effect/frame/" .. self._name .. ".plist")

    local animFrames = {}
    local index = 1
    for j = 1, 90 do  --预留最大90帧
        local url = string.format(self._name .. "/%04d", j - 1)
        local spriteFrame = cache:getSpriteFrame(url)

        if spriteFrame ~= nil then
            animFrames[index] = spriteFrame
            index = index + 1
        end
    end

    local action = nil
    local animation = cc.Animation:createWithSpriteFrames(animFrames, delay)
    if loop == true then
        action = cc.RepeatForever:create(cc.Animate:create(animation))
    else
        action = cc.Animate:create(animation)
    end

    if customAction ~= nil then
        if callback ~= nil then
            action = cc.Sequence:create(action, customAction, cc.CallFunc:create(callback))
        else
            action = cc.Sequence:create(action, customAction)
        end
    end

    self._rootNode:runAction(action)
end

function UIMovieClip:addFrames( name )
    -- body
    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames("effect/frame/" .. name .. ".plist")

    local animFrames = {}
    local index = 1
    for j = 1, 90 do  --预留最大20帧
        local url = string.format(name .. "/%04d", j - 1)
        local spriteFrame = cache:getSpriteFrame(url)

        if spriteFrame ~= nil then
            animFrames[index] = spriteFrame
            index = index + 1
        end
    end

    return animFrames
end

function UIMovieClip:setParent(parent)
    self._parent = parent
    self._parent:addChild(self._rootNode)
end

------
-- 设置名字
function UIMovieClip:setName(name)
    self._rootNode:setName(name)
end


function UIMovieClip:setPosition(x, y)
    self._rootNode:setPosition(x, y)
end

function UIMovieClip:getPositionX()
    return self._rootNode:getPositionX()
end

function UIMovieClip:getPositionY()
    return self._rootNode:getPositionX()
end

function UIMovieClip:setVisible(visible)
    self._rootNode:setVisible(visible)
end

function UIMovieClip:setAnchorPoint(x, y)
    self._rootNode:setAnchorPoint(cc.p(x,y))
end

function UIMovieClip:setLocalZOrder(zOrder)
    self._rootNode:setLocalZOrder(zOrder)
end

function UIMovieClip:setScale(scale)
    self._rootNode:setScale(scale)
end

function UIMovieClip:setDir(dirPos)
    self._rootNode:setScaleX(dirPos.x)
    self._rootNode:setScaleY(dirPos.y)
end

function UIMovieClip:stopAllActions()
    self._rootNode:stopAllActions()
end

function UIMovieClip:setNodeAnchorPoint(x, y)
    self._rootNode:setAnchorPoint(cc.p(x,y))
end

function UIMovieClip:runCustomAction(action)
    -- body
    self._rootNode:runAction(action)
end

function UIMovieClip:setRotation(action)
    -- body
    self._rootNode:setRotation(action)
end

function UIMovieClip:setSkewX(action)
    -- body
    self._rootNode:setSkewX(action)
end

function UIMovieClip:setSkewY(action)
    -- body
    self._rootNode:setSkewY(action)
end

