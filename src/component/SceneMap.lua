SceneMap = class("SceneMap", function ()
    return UIMapNodeExtend.extend(cc.Layer:create())
end)

function SceneMap:ctor(panel)
    self._panel = panel
    self._rootNode = cc.Layer:create()
    self:addChild(self._rootNode)

    -- self._rootAnchorX = 0
    -- self._rootAnchorY = 0
    self._chgPos = cc.p(0, 0)       --默认初始坐标位置
    self._isChgPos = false           --是否已经调整过子节点坐标

    self._minX = 0
    self._minY = 0
    self._maxX = 0
    self._maxY = 0

    self._mapWidth = 0
    self._mapHeight = 0
    self._bottom = 0
    self._multBeganPoints = {}
    self.ignoreMove = 10
    self._scale = 1             --当前缩放值
    self._maxScale = 1        --最大缩放值
    self._scaleDt = 0.01        --
    self._bgType = TextureManager.bg_type

    self._dtSceneY = 60         --起始高度

    self._sceneWidgetList = {}

    self.url = "bg/scene/1_%02d"  .. TextureManager.bg_type
    self.maxCol = 5             --地图图块列数
end

-- 背景渲染顺序
-- 从下往上+从左往右：第一行渲染图片6~10，第二行渲染图片1~5
-- 屏幕初始显示位置为第一个渲染图片的位置

-----------------------
function SceneMap:addSceneTouchEvent(widget, obj, callback)
    if widget.isAddSceneEvent == true then
        return
    end
    widget.isAddSceneEvent = true
    widget:setTouchEnabled(false)
    widget.touchCallback = callback
    table.insert(self._sceneWidgetList, {widget = widget, obj = obj, callback = callback})
end

function SceneMap:hitTest(touch)

    local now = os.clock()

    if self._lastHitTest ~= nil and math.abs(math.abs(now) - math.abs(self._lastHitTest)) < 0.3 then  --小于300毫秒，不处理
        self._lastHitTest = now
        return
    end

    self._lastHitTest = now

    local pos = touch:getLocation()
    local touchWidgetList = {}  --触摸到的widget列表，有可能多个叠在一起，以localZorder最大为主
    for _, data in pairs(self._sceneWidgetList) do
        if data.widget.isEnabled ~= false and data.widget:hitTest(pos) == true then
            table.insert(touchWidgetList, data)
        end
    end

    local function cmp(a, b)
        return a.widget:getLocalZOrder() > b.widget:getLocalZOrder()
    end
    if #touchWidgetList > 0 then
        table.sort(touchWidgetList, cmp)
        local data = touchWidgetList[1]

        local bgFlickerAction = cc.TintTo:create(0.1, GlobalConfig.hitBuildColor[1],GlobalConfig.hitBuildColor[2],GlobalConfig.hitBuildColor[3])
        local bgFlickerAction2 = cc.TintTo:create(0.1, 255,255,255)
        local action = cc.Sequence:create(bgFlickerAction, bgFlickerAction2)
        local effectWidget = data.widget.touchWidget
        if effectWidget == nil then
            effectWidget = data.widget
        end
        effectWidget:runAction(action)
        TimerManager:addOnce(0.22 * 1000, data.callback, data.obj, effectWidget)
    end
end

---------------------------
function SceneMap:onEnter()
    self:initMap()
    self:registerEvent()
end

function SceneMap:onExit()
end

function SceneMap:registerEvent()
    self:touchOneByOne()
    self:touchAllAtOnce()
end

function SceneMap:touchAllAtOnce()  --多点触摸 --应该是缩放场景
    local listener = cc.EventListenerTouchAllAtOnce:create()
    local function onTouchesBegan(touches, event)
        local isCanTouch = self._panel:isModuleVisible() --触摸用visible判断
        if isCanTouch ~= true then
            return
        end
        self._isTouchBegan = true
        self._multTouchScale = false
        for i = 1,#touches do
            local point = touches[i]:getLocation()
            self._multBeganPoints[touches[i]:getId()] = point
            if 0 == touches[i]:getId() then
                self._firstTouchId = touches[i]:getId()
            elseif 1 == touches[i]:getId() then
                if self._firstTouchId == nil then
                    return
                end
                self._secondTouchId = touches[i]:getId()
                if self._secondTouchId == nil then
                    return
                end
                local firstPoint = self._multBeganPoints[self._firstTouchId]
                local secondPoint = self._multBeganPoints[self._secondTouchId]
                self._baseDistance = math.sqrt((firstPoint.x - secondPoint.x) * (firstPoint.x - secondPoint.x) + (firstPoint.y - secondPoint.y) * (firstPoint.y - secondPoint.y))
            elseif table.getn(touches) > 2 then
                if self._firstTouchId == nil then
                    return
                end
                if self._secondTouchId == nil then
                    return
                end
                local firstPoint = self._multBeganPoints[self._firstTouchId]
                local secondPoint = self._multBeganPoints[self._secondTouchId]
                local firstLong = math.abs(secondPoint.x - firstPoint.x)
                    + math.abs(secondPoint.y - firstPoint.y)
                local nextLong  = math.abs(point.x - firstPoint.x)
                    + math.abs(point.y - firstPoint.y)
                if nextLong > firstLong then
                    if self._firstTouchId == nil then
                        return
                    end
                    self._secondTouchId = touches[i]:getId()
                    if self._secondTouchId == nil then
                        return
                    end
                    local firstPoint = self._multBeganPoints[self._firstTouchId]
                    local secondPoint = self._multBeganPoints[self._secondTouchId]
                    math.sqrt((firstPoint.x - secondPoint.x) * (firstPoint.x - secondPoint.x) + (firstPoint.y - secondPoint.y) * (firstPoint.y - secondPoint.y))
                end
            end
        end
    end
    local function onTouchesMoved(touches, event)
        local isCanTouch = self._panel:isModuleVisible() --触摸用visible判断
        if isCanTouch ~= true then
            return
        end
        if 1 < #touches then
            if self._firstTouchId == nil then
                return
            end
            if self._secondTouchId == nil then
                return
            end
            self._isMultTouch = true
            local firstPoint = touches[self._firstTouchId + 1]:getLocation()
            local secondPoint = touches[self._secondTouchId + 1]:getLocation()
            if firstPoint and secondPoint then
                local curDistance = math.sqrt((firstPoint.x - secondPoint.x) * (firstPoint.x - secondPoint.x) + (firstPoint.y - secondPoint.y) * (firstPoint.y - secondPoint.y))
                local dscale = curDistance / self._baseDistance
                --                local dtScale = (curDistance - self._baseDistance) / 100
                local dtScale = 0
                local scale = self._scale
                --                scale = self._scale + dtScale
                if dscale > 1 then
                    dtScale = self._scaleDt
                elseif dscale < 1 then
                    dtScale = -self._scaleDt
                end
                if math.abs(curDistance - self._baseDistance) < 1 then
                    dtScale = 0
                end
                scale = self._scale + dtScale
                --                local scale  = dscale * self._scale
                self._baseDistance = curDistance
                --                local time = os.clock()
                --                if self._lastTime == nil or time - self._lastTime  > 0.01 then
                self._multTouchScale = true
                if self._firstCenterPos == nil then
                    self._firstCenterPos = cc.pMidpoint(firstPoint,secondPoint)
                end
                self:setScale(scale, self._firstCenterPos)
                --                    self._lastTime = time
                --                end
            end
        end
    end
    local function onTouchesEnded(touches, event)
        local isCanTouch = self._panel:isModuleVisible() --触摸用visible判断
        if isCanTouch ~= true then
            return
        end
        self._multTouchScale = false
        self._firstCenterPos = nil
        if not self._isTouchBegan then
            return
        end
        if 1 < #touches then
            for i = 1,#touches do
                self._multBeganPoints[touches[i]:getId()] = nil
            end
            self._multBeganPoints = {}
            self._baseDistance = 0
            self._isMultTouch = false
            self._isTouchBegan = false
        end
    end

    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED)
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

-------------滑动的加速处理------------
function SceneMap:sceneTouchBegin(pos)
    self._touchBeginTime = os.clock()
    self._touchBeginPos = pos
end

function SceneMap:sceneTouchMove(pos)
    --    self._touchBeginTime = os.clock()
    --    self._touchBeginPos = pos
    self._rootNode:stopAllActions()
end

function SceneMap:sceneTouchEnd(pos)
    local time = os.clock()
    local dt = time - self._touchBeginTime
    if dt < 1.2 then  --加速滑动
        local distance = cc.pGetDistance(pos, self._touchBeginPos)
        local speed = distance / dt --cc.p(pos.x - self._touchBeginPos.x, pos.y - self._touchBeginPos.y)
        local dir = cc.pNormalize(cc.pSub(pos, self._touchBeginPos))
        local a = -4000

        self:autoScroll(speed, dir, a)

    end
end

function SceneMap:autoScroll(speed, dir, a)

    self._rootNode:stopAllActions()

    local sx = (0 - math.pow(dir.x * speed, 2)) / 2 / a
    local sy = (0 - math.pow(dir.y * speed, 2)) / 2 / a

    local posx, posy = self:getPosition()
    posx, posy = self:adjustPosition(posx + sx * dir.x, posy + sy * dir.y )
    local moveTo = cc.MoveTo:create(0.8, cc.p(posx, posy))
    local move_ease_out = cc.EaseOut:create(moveTo,2)
    self._rootNode:runAction(move_ease_out)
end

---
--子控件的移动
function SceneMap:interceptTouchBegin(sender)
    local beginPosition = sender:getTouchBeganPosition()

    self._beginPosition = beginPosition
    self._lastMovePosition = beginPosition

    self:sceneTouchBegin(beginPosition)
end

function SceneMap:interceptTouchMove(sender)
    local movePosition = sender:getTouchMovePosition()
    sender.getDelta = function()
        return cc.p(movePosition.x - self._lastMovePosition.x,
            movePosition.y - self._lastMovePosition.y)
    end

    sender.getLocation = function()
        return movePosition
    end

    if math.sqrt((self._beginPosition.x - movePosition.x) * (self._beginPosition.x - movePosition.x) +
        (self._beginPosition.y - movePosition.y) * (self._beginPosition.y - movePosition.y)) < 5 then
        return false
    end

    self:sceneTouchBegin(movePosition)
    self:onTouchMoved(sender)

    self._lastMovePosition = movePosition

    return true
end

function SceneMap:interceptTouchEnd(sender)
end

local isScale = false
function SceneMap:onTouchBegan(touch, event)
    --    if isScale == false then
    --        self:setScale(2)
    --        isScale = true
    --    end
    local isCanTouch = self._panel:isModuleVisible() --触摸用visible判断
    if isCanTouch ~= true then
        return
    end
    GameConfig.lastTouchTime = -1 --began不触摸事件
    self._isMoving = false
    self.curMove_x = touch:getLocation().x
    self.curMove_y = touch:getLocation().y
    self.beginMove_x = self.curMove_x
    self.beginMove_y = self.curMove_y

    local pos = touch:getLocation()
    self:sceneTouchBegin(pos)
    self._panel:setAllBuildingNameVisible(GlobalConfig.mainSceneTouchBegan)
    return isCanTouch
end

function SceneMap:onTouchMoved(touch, event)
    if self._multTouchScale == true then
        return
    end
    self._isMoving = true
    local pos = touch:getLocation()
    self:sceneTouchMove(pos)
    local delta = touch:getDelta()
    self._curDelta = delta

    --    local scale = 1
    --    if delta.x > 0 then
    --        scale = self._scale + self._scaleDt
    --    elseif delta.y < 1 then
    --        scale = self._scale - self._scaleDt
    --    end
    --    self:setScale(scale, cc.p(320, 320))
    GameConfig.lastTouchTime = -1  --场景在移动，也不释放
    self:onSceneMove(delta)


    -- logger:info("我是移动 Move .... 0000")
    if self._rootNode.onEffectMove ~= nil and self._rootNode.obj ~= nil then
        -- logger:info("我是移动 Move .... 222")
        self._rootNode.onEffectMove(self._rootNode.obj)
    
        -- local x,y = self._rootNode:getPosition()
        -- self._rootNode.obj:sendNotification(AppEvent.SCENEMAP_MOVE_UPDATE, {x,y})
    end



end

function SceneMap:onEffectMove(callback, obj)
    -- body
    -- logger:info("我是移动 Move .... 444")
    if callback ~= nil and obj ~= nil then
        -- logger:info("我是移动 Move .... 555")
        self._rootNode.onEffectMove = callback
        self._rootNode.obj = obj
    end
end

function SceneMap:onTouchEnd(touch, event)
    GameConfig.lastTouchTime = os.time()
    self._panel:setAllBuildingNameVisible(GlobalConfig.mainSceneTouchEnd)
    if self._multTouchScale == true then
        -- print(" self._multTouchScale == true  --还在xxx，不处理点击事件")
        return
    end

   -- if self._initRunAction == true then --还在跑动画，不处理点击事件
   --     print(" self._initRunAction == true  --还在跑动画，不处理点击事件")
   --     return
   -- end

    if self._panel:isMask() then
        return  
    end

    local pos = touch:getLocation()
    self:sceneTouchEnd(pos)

    local dis = math.sqrt( math.pow((touch:getLocation().x-self.beginMove_x), 2)+math.pow((touch:getLocation().y-self.beginMove_y), 2) )
    local flag = (not self._isMoving) or (dis < self.ignoreMove)
    if flag then
        self:hitTest(touch)
    end

end

function SceneMap:touchOneByOne() --单点触摸
    local listener = cc.EventListenerTouchOneByOne:create()
    --    listener:setSwallowTouches(true)

    local function onTouchBegan(touch, event)
        return self:onTouchBegan(touch, event)
    end
    local function onTouchMoved(touch, event)
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
end

function SceneMap:initMap()
    local winSize = self:getContentSize()

    -- local tmpX = 275
    -- local tmpY = 490

    local col = self.maxCol
    local width = 0
    local height = 0
    local lastSize = cc.size(0,0)
    local lastx, lasty = 0, self._dtSceneY
    for y=2, 1, -1 do  --暂时支持两行
        lastx = 0
        local dy = lasty + lastSize.height / 2
        lastSize = cc.size(0,0)
        for x=1, col do
            local url = string.format(self.url,(x + (y - 1) * col))
            
            -- local sprite = TextureManager:createSpriteFile(url)
            local sprite
            if self._bgType == TextureManager.file_type then
                sprite = TextureManager:createImageViewFile(url)
                -- lastx = lastx + 120
                -- lasty = lasty + 60
            else
                sprite = TextureManager:createSpriteFile(url)
            end

            self._rootNode:addChild(sprite)
            local size = sprite:getContentSize()


            lastx = lastx + lastSize.width / 2 + size.width / 2
            lasty = dy + size.height / 2
            --print("背景...............lastx,lasty",lastx,lasty)
            -- sprite:setPosition(lastx-tmpX,lasty-tmpY)
            sprite:setPosition(lastx,lasty)

            if y == 1 then
                self._mapWidth = self._mapWidth + size.width
            end

            if x == 1 then
                self._mapHeight = self._mapHeight + size.height
            end

            lastSize = size
        end
    end

    --加入主城左侧的图片,用于挡住瀑布特效
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == targetPlatform or 
        cc.PLATFORM_OS_IPAD == targetPlatform or 
        cc.PLATFORM_OS_WINDOWS == targetPlatform then
        local url = "bg/scene/MainBuildingLeft" .. TextureManager.file_type
        local sprite = TextureManager:createImageViewFile(url)
        self._rootNode:addChild(sprite)
        sprite:setLocalZOrder(50)
        sprite:setPosition(350+28,1500-35)
    end

    if self._curScene == ModuleName.LegionSceneModule then
        self._minScale = 1   --军团场景默认1倍
    else
        local vSize = self:getViewSize()
        self._minScale = vSize.height / self._mapHeight --最小缩放值
    end

    self._mapSize = cc.size(self._mapWidth, self._mapHeight)
    self:resetLimitHeight()
    print("ghhhhgffdddgggghh", self._scale)
end

function SceneMap:onSceneMove(delta)
    local posX,posY = self:getPosition()
    self:setPosition(posX + delta.x, posY + delta.y)
end

-- function SceneMap:resetLimitHeight()
--     local vSize = self:getViewSize()
--     local sSize = self._mapSize

--     local visSize = cc.Director:getInstance():getVisibleSize()

--     self._maxX = visSize.width * (self._scale - 1) / 2
--     self._maxY = vSize.height * (self._scale - 1) / 2
--     self._minX = vSize.width - sSize.width * self._scale + vSize.width * (self._scale - 1) / 2
--     self._minY = vSize.height - sSize.height * self._scale + vSize.height * (self._scale - 1) / 2

--     -- logger:info("resetLimitHeight self._maxX,self._maxY,self._minX,self._minY - %d,%d,%d,%d,", self._maxX,self._maxY,self._minX,self._minY)
-- end

function SceneMap:resetLimitHeight()
    local vSize = self:getViewSize()
    local sSize = self._mapSize
    local visSize = cc.Director:getInstance():getVisibleSize()

    local x = self._chgPos.x*self._scale
    local y = self._chgPos.y*self._scale

    local sideX = math.abs(visSize.width - vSize.width)*self._scale*(self._scale - 1)*2   --优化X边界判定范围，尽量显示完整地图
    if self._curScene == ModuleName.LegionSceneModule then
        sideX = 0   --军团场景不用再优化偏移
    end

    self._maxX = visSize.width * (self._scale - 1) / 2 + x -- sideX
    self._maxY = vSize.height * (self._scale - 1) / 2 + y
    self._minX = vSize.width - sSize.width * self._scale + vSize.width * (self._scale - 1) / 2 + x + sideX
    self._minY = vSize.height - sSize.height * self._scale + vSize.height * (self._scale - 1) / 2 + y

    -- logger:error("重置 x,y,scale,sideX = %d, %d, %f, %d", x, y, self._scale, sideX)
    -- logger:info("可视大小 visSize.width, visSize.height = %d,%d", visSize.width, visSize.height)
    -- logger:info("视窗大小 vSize.width, vSize.height = %d,%d", vSize.width, vSize.height)
    -- logger:info("重置边界 _maxX,_maxY,_minX,_minY = %d,%d,%d,%d,", self._maxX,self._maxY,self._minX,self._minY)
end

function SceneMap:setCurScene(ModuleName)
    -- body
    self._curScene = ModuleName
end

function SceneMap:getPosition()
    return self._rootNode:getPosition()
end

function SceneMap:setPosition(x, y)
    x, y = self:adjustPosition(x, y)
    -- logger:info("00 SceneMap:setPosition x,y = %d,%d", x, y)
    self._rootNode:setPosition(x, y)
end

function SceneMap:adjustPosition(x, y)
    if x < self._minX then
        x = self._minX
    end

    if y < self._minY then
        y = self._minY
    end

    if x > self._maxX then
        x = self._maxX
    end

    if y > self._maxY then
        y = self._maxY
    end
    return x, y
end

function SceneMap:setScale(scale, centerPos, fouse)
    if scale < self._minScale then
        scale = self._minScale
    end
    if scale > self._maxScale then
        scale = self._maxScale
    end

    if self._curScene == ModuleName.LegionSceneModule then
        scale = 1/NodeUtils:getAdaptiveScale()
    end

    if math.abs(self._scale - scale) > self._scaleDt * 1.5 and fouse == nil then --2倍的容错
        return
    end

    local centerPostion1 = self._rootNode:convertToNodeSpace(centerPos)

    local srcScale = self._scale
    self._scale = scale
    self:resetLimitHeight()
    self._rootNode:setScale(scale)
    -- print("场景地图 _rootNode scale",scale)
    local minScale = 0.60 --主城建筑图标能够最小的缩放值
    for _, data in pairs(self._sceneWidgetList) do
        if data.widget.barPanel ~= nil then  --建筑的Icon。保持原有的大小
            local newScale = minScale / scale
             if scale >= minScale then
                newScale = 0.9  --原大小
            end
            
            -- print("~~~~~~~~~ata.widget.barPanel~~~~~~~~~", newScale)
            local widget = data.widget
            widget.barPanel:setScale(newScale)
            widget.productPanel:setScale(newScale)
            widget.closeImg:setScale(newScale)
--            widget.namePanel:setScale(newScale)

--            if widget.namePanel.isShow then
--                widget.namePanel:setVisible(self:getScale() > GlobalConfig.nameShowScale)
--            end
        end
    end

    local centerPostion2 = self._rootNode:convertToNodeSpace(centerPos)
    local dif = cc.pSub(centerPostion2, centerPostion1)

    dif.x = dif.x * scale --修正地图缩放时的偏移量
    dif.y = dif.y * scale --修正地图缩放时的偏移量
    -- logger:error("设偏移 scale=%.2f, dif=(%d,%d), cPos=(%d,%d), cpos2=(%d,%d), cpos1=(%d,%d)", scale, dif.x, dif.y, centerPos.x, centerPos.y, centerPostion2.x,centerPostion2.y,centerPostion1.x,centerPostion1.y)
    self:onSceneMove(cc.p(dif.x, dif.y))

end

function SceneMap:addChildToMap(child)
    self._rootNode:addChild(child)
end

function SceneMap:getChildByName(name)
    self._rootNode:getChildByName(name)
end

function SceneMap:getViewSize()
    local vSize = cc.Director:getInstance():getWinSize()
    return cc.size(vSize.width, vSize.height - 100 - self._dtSceneY)
end

--移动到child里面去
function SceneMap:moveToChild(child, callback)
    local x, y = child:getPosition()

    local centerPos = cc.p(320, 480)
    local centerPostion1 = self._rootNode:convertToNodeSpace(centerPos)

    local dx = centerPostion1.x - x
    local dy = centerPostion1.y - y

    local posX,posY = self:getPosition()
    local targetX = posX + dx * self._scale
    local targetY = posY + dy * self._scale
    targetX, targetY = self:adjustPosition(targetX, targetY)

    local actionCallback = function()
        if callback ~= nil then
            callback()
        end
    end
    local positinX = self:getPosition()
    local distance = math.abs(positinX - targetX)
    if distance < 100 then
        time = 0.1
    elseif distance < 200 then
        time = 0.2
    elseif distance < 300 then
        time = 0.3
    elseif distance < 400 then
        time = 0.4
    elseif distance < 500 then
        time = 0.5
    elseif distance < 600 then
        time = 0.6
    elseif distance < 700 then
        time = 0.7
    elseif distance < 800 then
        time = 0.8
    else
        time = 0.8
    end
    local action = cc.MoveTo:create(time, cc.p(targetX, targetY))
    self._rootNode:runAction(cc.Sequence:create(action, cc.CallFunc:create(actionCallback)))

end

-- 进入场景地图的缩放动画
function SceneMap:runEnterAction(centerPos,fScale,tScale,delayTime)
    -- -- 主城场景地图和军团场景地图共用以下配置参数
    -- -- 配置参数  start--------------------------------------------------------------------------
    -- local fromScale = 2.0                           --缩放起始的值
    -- local toScale = 0.565                           --缩放结束的值(最终显示的缩放大小)
    -- local delay = 1.5                               --缩放动画时长
    -- -- 配置参数  end  --------------------------------------------------------------------------
    -- logger:info("进入场景地图的缩放动画........00011111")

    local fromScale = GlobalConfig.fromScale
    local toScale = GlobalConfig.toScale
    local delay = GlobalConfig.delay
    if fScale ~= nil or fScale == 0 then
        fromScale = fScale                          --缩放起始的值
    end
    if tScale ~= nil or tScale == 0 then
        toScale = tScale                            --缩放结束的值(最终显示的缩放大小)
    end
    if delayTime ~= nil or delayTime == 0 then
        delay = delayTime                           --缩放动画时长
    end

    local toPos = cc.p(320, 320)
    local initPos = cc.p(0, 0)                      --
    self:setScale(toScale, toPos, true)             --
    self:setPosition(initPos.x, initPos.y)          --

    local scale = self._rootNode:getScale()         --
    self._rootNode:setScale(fromScale)              --

  --  self._minScale = GlobalConfig.toScale --tudo:将最小的缩放比例改为预先设置好的  by zhangfan

    -- 全部子节点做偏移
    if centerPos ~= nil then
        self._chgPos = centerPos
        if self._isChgPos == false then
            self:resetLimitHeight()
            self:updateChildendsPosition(self._chgPos)
            self._isChgPos = true
            -- print("-- 全部子节点做偏移 ......00000000")
        else
            -- 断线重连走这里
            self:setPosition(0-self._chgPos.x*toScale, 0-self._chgPos.y*toScale)
        end

    end

    local function callback()
        self._initRunAction = false
        -- self._panel:setMask(false)
        -- self._rootNode:setScale(scale)  --再手动设置下缩放大小，测试能否解决动画播放时被点击打断问题
        print("callback self._initRunAction == false  --动画结束，可处理点击事件 0000000000")
    end

    -- self._panel:setMask(true)
    self._initRunAction = true
    local action = cc.ScaleTo:create(delay, scale)  --缩放动画
    self._rootNode:runAction(cc.Sequence:create(action, cc.CallFunc:create(callback)))
end

function SceneMap:getDtSceneY()
    return self._dtSceneY
end

function SceneMap:setVisible(visible)
    self._rootNode:setVisible(visible)
end

function SceneMap:updateChildendsPosition(initPos)
   local children = self._rootNode:getChildren()
   for k,v in pairs(children) do
        if v.isChgPos == nil then
            local x,y = v:getPosition()
            v:setPosition(x-initPos.x, y-initPos.y)
        end
   end
end

function SceneMap:getMapSize()
    return self._mapWidth,self._mapHeight
end

-- 获取同步缩放参数
function SceneMap:getMapNewScale()
    local minScale = 0.60 --主城建筑图标能够最小的缩放值
    local newScale = minScale / self._scale
    if self._scale >= minScale then
        newScale = 0.9  --原大小
    end
    return newScale
end