--实现拖动的接口
--在同一层实现
local HeroChangeUI = class("HeroChangeUI")

-----有好几个回调函数--------
--callback1 = getWhichPosEnable  获取当前的wight是否open
--callback2 = onPopTouch  是否弹出佣兵列表选择界面
--callback3 =   交换之后的位置，提交
function HeroChangeUI:ctor(widget,args)

    self.widget = widget
    self.data = args["data"]
    self.callback1 = args["callback1"]
    self.callback2 = args["callback2"]
    self.callback3 = args["callback3"]
    self.callback4 = args["callback4"]
    widget.srcPos = cc.p(widget:getPosition())
    widget.drag = self
    self:addTouchEvent()
    self._srcLocalZOrder = widget:getLocalZOrder()
end

-------interface-------------
-------需要基类实现的接口----------

--widget.srcPos =
--widget.drag = 
function HeroChangeUI:getWidget()
    return self.widget
end


function HeroChangeUI:getData()
    return self.data
end

function HeroChangeUI:runAction(action)
    local widget = self:getWidget()
    widget:runAction(action)
end

-------------------------------------
function HeroChangeUI:onCellSwitch(targetCell)
    if targetCell == nil then
        targetCell = self
    end
    
    local widget = self:getWidget()
    local twidget = targetCell:getWidget()
    
    local selfPos = widget.srcPos
    local tarPos = twidget.srcPos
    
    local istwidgetOpen = true
    if self.callback1(twidget.pos) == false then  --目标wight判断是否open
        istwidgetOpen = false
    end
    
    if targetCell == self or istwidgetOpen == false then
        local action1 = cc.ScaleTo:create(0.15,1)
        local action2 = cc.MoveTo:create(0.15, selfPos)
        action2 = cc.Spawn:create(action1,action2)
        self:runAction(action2)
        --logger:info("我又还回到开始位置了！！")
    else
        --交换
        widget.srcPos = tarPos
        twidget.srcPos = selfPos
        
        self:swicthPos(widget,twidget)

        self.callback3(widget)
        self.callback3(twidget)
        local action1 = cc.ScaleTo:create(0.2,1)
        local action2 = cc.MoveTo:create(0.2, tarPos)
        action2 = cc.Spawn:create(action1,action2)
        self:runAction(action2)

        action1 = cc.MoveTo:create(0.15, selfPos)
        action2 = cc.ScaleTo:create(0.15, 1)
        action2 = cc.Spawn:create(action1,action2)
        targetCell:runAction( action2 )
    end
end



------------------------
--
function HeroChangeUI:_onTouchBegin(x,y)
    local widget = self:getWidget()
    if self.callback1(widget.pos) == false then  --判断是否open
        return
    end
    
    local wx, wy = widget:getPosition()
    local pos = widget:getParent():convertToNodeSpace(cc.p(x, y))
    
    self._begPosX = pos.x
    self._begPosY = pos.y
    
    --logger:info("touch begin   %d   %d",pos.x,pos.y)
    
    self._dx = wx - pos.x
    self._dy = wy - pos.y
    
    
    widget:setLocalZOrder(1000)
    
end

function HeroChangeUI:_onTouchMove(x, y)
    local widget = self:getWidget()
    if self.callback1(widget.pos) == false then  --判断是否open
        return
    end
    
    local pos = widget:getParent():convertToNodeSpace(cc.p(x, y))
    
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    if x < 50 or y < 50 or visibleSize.width < x -10 or visibleSize.height < y-50 then
            local posMark = widget:getParent():convertToNodeSpace(cc.p(self._markX, self._markY))
            widget:setPosition(posMark.x , posMark.y)   
        return
    end
    self._markX = x
    self._markY = y
    local children = widget:getParent():getChildren()
    widget:setPosition(pos.x + self._dx, pos.y + self._dy)
    for _, child in pairs(children) do
        if child:hitTest(cc.p(x,y)) == true and widget ~= child then
            if child.drag then
                child:setScale(GameConfig.Hero.MinScale)
                self.callback4(child,2)
            end
        elseif child == widget then
            self.callback4(child,2)
            child:setScale(GameConfig.Hero.MaxScale) 
        else
            self.callback4(child,1)
            child:setScale(1.0)
        end
    end
end

function HeroChangeUI:_onTouchEnd(x, y)
    local widget = self:getWidget()
    if self.callback1(widget.pos) == false then  --判断是否open
        return
    end
    
    local pos = widget:getParent():convertToNodeSpace(cc.p(x, y))
    local lenx =  (self._begPosX - pos.x)*(self._begPosX - pos.x)
    local leny =  (self._begPosY - pos.y)*(self._begPosY - pos.y)
    local len = math.sqrt(lenx + leny)
    
    if len < 10 then --偏移量小的时候
        logger:info("this is only click !  %d",widget.pos)
        self.callback2(widget)
        return
    end
    
    local targetCell = nil
    local children = widget:getParent():getChildren()
    for _, child in pairs(children) do
        if child:hitTest(cc.p(x,y)) == true and widget ~= child then
    	    targetCell = child.drag
        end
        child:setScale(1.0)
        self.callback4(child,1)
    end
    
    widget:setLocalZOrder(self._srcLocalZOrder)
    self:onCellSwitch(targetCell)
end
------------------

function HeroChangeUI:addTouchEvent()
   
    local function onTouchEnd(touch,eventType)
        local location = touch:getLocation() 
        local x, y = location.x, location.y 
        self:_onTouchEnd(x,y)
        
    end
    
    local function onTouchHandler(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pos = sender:getTouchEndPosition()
                self:_onTouchEnd(pos.x, pos.y)
        elseif eventType == ccui.TouchEventType.moved then
            local pos = sender:getTouchMovePosition() 
            self:_onTouchMove(pos.x, pos.y)
        elseif eventType == ccui.TouchEventType.began then
            local beganPos = sender:getTouchBeganPosition()
            self:_onTouchBegin(beganPos.x,beganPos.y)

        elseif eventType == ccui.TouchEventType.canceled then
            self:_onTouchEnd(self._markX, self._markY)
        end
    end
 
    local widget = self:getWidget()
    widget:setTouchEnabled(true)
    widget:addTouchEventListener(onTouchHandler)
end

function HeroChangeUI:swicthPos(srcWight,destWight)  --坑位的对调
    logger:info("11src dest  %d  %d",srcWight.pos,destWight.pos)
    local srcPos = srcWight.pos
    srcWight.pos = destWight.pos
    destWight.pos = srcPos
    logger:info("22src dest  %d  %d",srcWight.pos,destWight.pos)
end

return HeroChangeUI