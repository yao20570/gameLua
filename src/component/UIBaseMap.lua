UIBaseMap = class("UIBaseMap", function ()
    return UIMapNodeExtend.extend(cc.Layer:create()) --cc.LayerColor:create(cc.c4b(200, 200, 255, 0))
end)
UIBaseMap.__index = UIBaseMap

function UIBaseMap:ctor()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    self:setContentSize(visibleSize)
    
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    self.ignoreMove = 10 * visibleSize.width / 640
end

function UIBaseMap:onExit()
    print("UIBaseMap:onExit(UIBaseMap:onExit(")
end

function UIBaseMap:onTouchBegan(touch, event)
--    logger:info("BaseMap onTouchBegan")
    GameConfig.lastTouchTime = -1
    self._isSceneRunAction = false
    self._scene:stopAllActions() --先停止动画
    self._isSysWorldData = nil
    self.curMove_x = touch:getLocation().x
    self.curMove_y = touch:getLocation().y
    self.beginMove_x = self.curMove_x
    self.beginMove_y = self.curMove_y
    self.isTouchMoved = false
    self.isBenganMove = true

    local pos = touch:getLocation()
    self._touchBeginTime = os.clock()
    self._touchBeginPos = pos

    return true
end

function UIBaseMap:onTouchEnd(touch, event)
--    logger:info("BaseMap onTouchEnd")
    -- 如果移动量过小，那么触发建筑点击
    GameConfig.lastTouchTime = os.time()
    if self._isSysWorldData == false then
        self:onSysWorldData()
    end

    local dis = math.sqrt( math.pow((touch:getLocation().x-self.beginMove_x), 2)+math.pow((touch:getLocation().y-self.beginMove_y), 2) )
    if (not self.isTouchMoved) or (dis < self.ignoreMove)
    then
        self:onSysWorldData()  --解决快速拖动后，点击，之后数据不刷新问题
        self:onSelectBuildingEvent(touch)
        -- print("~~~~~~~onTouchEnd~~~little~~~~~~~~~~")
    else
        -- 取消滑动效果
        --[[
        --滑动一点点
        local pos = touch:getLocation()
        local time = os.clock()
        local dt = time - self._touchBeginTime
        if dt < 1.2 then  --加速滑动
            local distance = cc.pGetDistance(pos, self._touchBeginPos)
            local speed = distance / dt --cc.p(pos.x - self._touchBeginPos.x, pos.y - self._touchBeginPos.y)
            local dir = cc.pNormalize(cc.pSub(pos, self._touchBeginPos))
            local a = -4000
    
            self:autoScroll(speed, dir, a)
        else
            self:onSysWorldData()  --解决快速拖动后，按住再进行拖动，之后数据不刷新问题
        end
        --]]

        self:onSysWorldData()
    end
end


function UIBaseMap:onSelectBuildingEvent(touch)
    logger:info("onSelectBuildingEvent")
end

function UIBaseMap:onTouchMoved(touch, event)
    local delta = touch:getDelta()
    
--    print("BaseMap onTouchMoved", delta.x, delta.y)
    
    self:onSceneMove(delta)
    
    self.isTouchMoved = true
end

function UIBaseMap:onSceneMove(delta)
    local posX,posY = self._scene:getPosition()
    self:setScenePosition(cc.p(posX + delta.x, posY + delta.y))
end

function UIBaseMap:setScenePosition(pos)
    local new_pos = cc.p(math.min(0,pos.x), pos.y)
    self._scene:setPosition(new_pos)
end

function UIBaseMap:autoScroll(speed, dir, a)

    self._scene:stopAllActions()

    local sx = (0 - math.pow(dir.x * speed, 2)) / 2 / a
    local sy = (0 - math.pow(dir.y * speed, 2)) / 2 / a

    local maxLen = 500

    --这里需要按方向算出最大的sx sy
    if sx * sx + sy * sy > maxLen * maxLen then
        local rad = math.atan(sy / sx)
        sx = maxLen * math.cos(rad)
        sy = maxLen * math.sin(rad)
    end

    -- print("~~~~~~~sx~~~~~~~~~~sy~~~~~~~~", sx, sy)

    local dx = sx * dir.x
    local dy = sy * dir.y
    local posx, posy = self._scene:getPosition()
    posx, posy = self:adjustPosition(posx, posy , dx , dy )

    local function updateScenePosition()
        local posX,posY = self._scene:getPosition()
        self:setScenePosition(cc.p(posX, posY))
    end

    local function runEnd()
        self:renderTopPos()
        self._isSceneRunAction = false
        self:refreshMap()
    end

    self._isSysWorldData = false

    local function sysWorldData()
        self:refreshCurrentTileCoor()
        self:onSysWorldData()
        self._isSysWorldData = true
    end

    local moveTo = cc.MoveTo:create(0.8, cc.p(posx, posy))
    local move_ease_out = cc.EaseOut:create(moveTo,2)
    local action = cc.Sequence:create(move_ease_out, cc.CallFunc:create(runEnd))
    local sysAction = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(sysWorldData))
    local updatePosAction = cc.Sequence:create(
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition),
        cc.DelayTime:create(0.05), cc.CallFunc:create(updateScenePosition))
    local spaw = cc.Spawn:create(action, sysAction, updatePosAction) --
    
    self._scene:runAction(spaw)
    self._isSceneRunAction = true
end

function UIBaseMap:refreshCurrentTileCoor()
end

function UIBaseMap:renderTopPos()
end

function UIBaseMap:onSysWorldData()
end

function UIBaseMap:refreshMap()
end

function UIBaseMap:isSceneRunAction()
    return self._isSceneRunAction
end

--function UIBaseMap:addChild(child)
--    self._scene:addChild(child, 0, 999)
--end

function UIBaseMap:touchOneByOne()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)

    local function onTouchBegan(touch, event)
        return self:onTouchBegan(touch, event)
    end
    local function onTouchMoved(touch, event)
        GameConfig.lastTouchTime = -1
        self:onTouchMoved(touch, event)
    end
    local function onTouchEnded(touch, event)
        self:onTouchEnd(touch, event)
    end

    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
--    eventDispatcher:addEventListenerWithFixedPriority(listener, -100)
end

function UIBaseMap:onEnter()
    self:touchOneByOne()
end

