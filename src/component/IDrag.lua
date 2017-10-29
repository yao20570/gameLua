--实现拖动的接口
--在同一层实现
IDrag = class("IDrag")

-----有好几个回调函数--------
--callback1 = getWhichPosEnable  获取当前的wight是否open
--callback2 = onPopTouch  是否弹出佣兵列表选择界面
--callback3 =   交换之后的位置，提交
--isShowSelectedHightLigh是否开启选中时高亮
function IDrag:ctor(widget,args, isShowSelectedHightLight)
    self.widget = widget
    self.data = args["data"]
    self.callback1 = args["callback1"]
    self.callback2 = args["callback2"]
    self.callback3 = args["callback3"]
    self._selectHightLight = self.widget:getChildByName("selectImg")
    self._isShowSelectedHightLight = isShowSelectedHightLight
    widget.srcPos = cc.p(widget:getPosition())
    widget.drag = self
    self:setActionFlag(false)
    self:addTouchEvent()
end

-------interface-------------
-------需要基类实现的接口----------

--widget.srcPos =
--widget.drag = 
function IDrag:getWidget()
    return self.widget
end

--获取拖动事件widget
function IDrag:getTouchWidget()
    local touchPanel = self.widget:getChildByName("touchPanel")
    if touchPanel == nil then
        touchPanel = self.widget
    end
    return touchPanel
end


function IDrag:getData()
    return self.data
end

function IDrag:runAction(action)
    local widget = self:getWidget()
    widget:runAction(action)
end

-------------------------------------
function IDrag:onCellSwitch(targetCell)
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
    
    local function callback()
        -- print("... action end callback")
        self:setActionFlag(false)
    end
    self:setActionFlag(true)
    -- print("... action start ")


    if targetCell == self or istwidgetOpen == false then
        -- self:runAction( cc.MoveTo:create(0.15, selfPos) )
        -- logger:info("我又还回到开始位置了！！")
        local sequence = cc.Sequence:create(cc.MoveTo:create(0.15, selfPos), cc.CallFunc:create(callback))
        self:runAction(sequence)
    else
        --交换
        widget.srcPos = tarPos
        twidget.srcPos = selfPos
        
        self:swicthPos(widget,twidget)

        self.callback3(widget)
        self.callback3(twidget)
        
        -- self:runAction( cc.MoveTo:create(0.2, tarPos) )
        -- targetCell:runAction( cc.MoveTo:create(0.15, selfPos) )

        local sequence1 = cc.Sequence:create(cc.MoveTo:create(0.2, tarPos), cc.CallFunc:create(callback))
        local sequence2 = cc.Sequence:create(cc.MoveTo:create(0.15, selfPos), cc.CallFunc:create(callback))
        self:runAction(sequence1)
        targetCell:runAction(sequence2)
    end
end

--[[
self._flag :
    false=没动画时可点击，(初始值)
    true=有动画时不可点击，
    防止移动中响应点击事件
]]
function IDrag:setActionFlag(flag)
    self._flag = flag
end

function IDrag:getActionFlag()
    return self._flag
end

------------------------
--
function IDrag:_onTouchBegin(x,y)
    local widget = self:getWidget()
    if self.callback1(widget.pos) == false then  --判断是否open
        return
    end
    
    local flag = self:getActionFlag()
    if flag == true then
        -- print("... is running action , can't touch begin 嗯嗯")
        return
    end

    local wx, wy = widget:getPosition()
    local pos = widget:getParent():convertToNodeSpace(cc.p(x, y))
    
    self._begPosX = pos.x
    self._begPosY = pos.y
    
    -- logger:info("touch begin   %d   %d",pos.x,pos.y)
    
    self._dx = wx - pos.x
    self._dy = wy - pos.y
    
    self._srcLocalZOrder = widget:getLocalZOrder()
    
    widget:setLocalZOrder(1000)
    if self._isShowSelectedHightLight and self._selectHightLight then
        self._selectHightLight:setVisible(true)
    end
    
end

function IDrag:_onTouchMove(x, y)
    local widget = self:getWidget()
    if self.callback1(widget.pos) == false then  --判断是否open
        self:setActionFlag(false)
        return
    end

    local flag = self:getActionFlag()
    if flag == true then
        -- print("... is running ,can't touch move 嗯嗯")
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
    widget:setPosition(pos.x + self._dx, pos.y + self._dy)
end

function IDrag:_onTouchEnd(x, y)
    if self._isShowSelectedHightLight and self._selectHightLight then
        self._selectHightLight:setVisible(false)
    end

    local widget = self:getWidget()
    if self.callback1(widget.pos) == false then  --判断是否open
        return
    end

    local flag = self:getActionFlag()
    if flag == true then
        -- print("... is running ,can't touch end 嗯嗯")
        return
    end

    local selfTouchWidget = self:getTouchWidget()
    
    local pos = widget:getParent():convertToNodeSpace(cc.p(x, y))
    local lenx =  (self._begPosX - pos.x)*(self._begPosX - pos.x)
    local leny =  (self._begPosY - pos.y)*(self._begPosY - pos.y)
    local len = math.sqrt(lenx + leny)
    
    
    if len < 10 then --偏移量小的时候
        logger:info("this is only click !  %d",widget.pos)
        self.callback2(widget.pos)
        self:setActionFlag(false)
        return
    end
    
    local targetCell = nil
    local children = widget:getParent():getChildren()
    local overlapList = {}  --覆盖的Widget，还需要进行判断最近的Widget
    for _, child in pairs(children) do
        local touchPanel = child:getChildByName("touchPanel")
        if touchPanel == nil then
            touchPanel = child
        end
        --touchPanel:hitTest(cc.p(x,y)) == true

        if child.drag ~= nil and widget ~= child  and NodeUtils:isOverlap(selfTouchWidget, touchPanel) then
            table.insert(overlapList, child)
                -- targetCell = child.drag
                -- break
    	end
    end

    local minLen = 20000000
    for _,child in pairs(overlapList) do
        local wpos = child:getWorldPosition()
        local len = (x - wpos.x) * (x - wpos.x) + (y - wpos.y) * (y - wpos.y)
        if minLen > len then
            minLen = len
            targetCell = child.drag
        end
    end
    
    widget:setLocalZOrder(self._srcLocalZOrder)
    self:onCellSwitch(targetCell)

end
------------------

function IDrag:addTouchEvent()
   
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
 
    local widget = self:getTouchWidget()
    widget:setTouchEnabled(true)
    widget:addTouchEventListener(onTouchHandler)
end

function IDrag:swicthPos(srcWight,destWight)  --坑位的对调
    logger:info("11src dest  %d  %d",srcWight.pos,destWight.pos)
    local srcPos = srcWight.pos
    srcWight.pos = destWight.pos
    destWight.pos = srcPos
    logger:info("22src dest  %d  %d",srcWight.pos,destWight.pos)
end




