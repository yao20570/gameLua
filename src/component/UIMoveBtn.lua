UIMoveBtn = class("UIMoveBtn") --来回移动的btn



UIMoveBtn.MOVE_BTN_OFFSET_Y = -3 --移动按钮偏移值

--args初始化相关参数
--minNum默认最小左值为1，特殊可以设定为0
function UIMoveBtn:ctor(parent, args, minNum)
    self._uiSkin = UISkin.new("UIMoveBtn")
    self._uiSkin:setVisible(true)
    self._uiSkin:setParent(parent)
    self._panel = self._uiSkin:getChildByName("Panel_10")
    self:initMoveBtn()
    self._minNum = minNum or 1
    local count = args["count"]
    local obj = args["moveCallobj"]
    local moveCallback = args["moveCallback"] --移动回调方法
    
    self._callObj = obj
    self._moveCallback = moveCallback
    
    self:setEnterCount(count)
end

function UIMoveBtn:finalize()
    self._uiSkin:finalize()
end

-------------外部调用方法-----------------


function UIMoveBtn:setEnterCount(count,isLeft) --要输人的值,留出来的接口
    self._totalCount = count  --总共输入的数量
    self._pointMap = {}
    self._pointMap[1] = self._minPosX
    self._pointMap[0] = self._minPosX

    if count - 1 > 0 then
        local per
        --最小值为0的时候，就要分count份
        --最小值为1的时候，只能分count - 1份，因为1在minposx
        if self._minNum == 0 then
            per = (self._maxPosX - self._minPosX) / count
        else
            per = (self._maxPosX - self._minPosX) / (count-1)
        end
        
        --最小index是0的时候  1要往前走一个位置
        if self._minNum == 0 then
            self._pointMap[1] = self._minPosX + per
        end

        for index = 1,count do
            self._pointMap[index] = self._pointMap[1] + (index - 1)*per
        end
        self._pointMap[count] = self._maxPosX
    else
    end


    if isLeft ~= true then
        self:moveToRight()
        self._currPoint = count
    else
        self:moveToLeft()
        self._currPoint = self._minNum
    end
    self:showPencet()
end

-- function UIMoveBtn:update(0.1)
--     self._isLockTime = false
--     print("11111111")
-- end

--@param:count 设置当前购买个数
--@param:isNeedCallBack 是否回调movecallback
--函数内自动转为百分比并设置进度条进度
function UIMoveBtn:setBarPercent(count, isNeedCallBack)
    count = count < self._minNum and self._minNum or count
    count = count < self._totalCount and count or self._totalCount
    local percent = count/self._totalCount*100
    percent = percent > 100 and 100 or percent
    self._toolBar:setPercent(percent)
    self._currPoint = count
    self._curX = self._pointMap[self._currPoint]
    if percent == 100 then
        self._curX = self._maxPosX
    end
    self._curX = self._curX < self._minPosX and self._minPosX or self._curX
    self._curX = self._curX > self._maxPosX and self._maxPosX or self._curX
    self._moveBtn:setPositionX(self._curX)
    if isNeedCallBack then
        if self._moveCallback ~= nil then
            self._moveCallback(self._callObj, self._currPoint )
        end
    end
end

function UIMoveBtn:initMoveBtn()
    --ps这三者要在同一个父panel下面
    self._moveBtn = self._panel:getChildByName("moveBtn") --要移动的按钮
    self._backImg = self._panel:getChildByName("backImg") --背景图片
    self._toolBar = self._panel:getChildByName("toolBar") --伸缩的进度条
    local imgSize = self._backImg:getContentSize()  --背景图片的尺寸
    local imgPosX,imgPosY = self._backImg:getPosition()
    self._backImg.size = imgSize
    local moveBtnSize = self._moveBtn:getContentSize()  --移动按钮的尺寸
    self._moveBtn.size = moveBtnSize
    self._movePosY = imgPosY + UIMoveBtn.MOVE_BTN_OFFSET_Y  --可移动的固定Y值                            
    self._minPosX =  imgPosX - imgSize.width/2 + moveBtnSize.width/2  --最小的x值
    self._maxPosX =  imgPosX + imgSize.width/2 - moveBtnSize.width/2  --最小的x值
    
    self._curX = self._minPosX --当前的x坐标
    self._minusBtn = self._panel:getChildByName("minusBtn")
    self._plusBtn = self._panel:getChildByName("plusBtn")
    
    local function setMinOrPlusHandle(sender, eventType)
        local function btnBeganTouch()
            if sender == self._minusBtn then
                self:setMinusBtn()
            elseif sender == self._plusBtn then
                self:setPlusBtn()
            end
        end
        local function loopBtnCall()
            if self._markTime ~= nil then
                -- local nowTime = os.clock()
                -- if self._lastTime ~= nil and nowTime - self._lastTime > 0.1 then
                    btnBeganTouch()
                    -- self._lastTime = nowTime
                    local noAction = cc.DelayTime:create(0.1)
                    self._moveBtn:runAction(cc.Sequence:create(noAction, cc.CallFunc:create(loopBtnCall)))
                -- elseif self._lastTime == nil then
                    -- self._lastTime = nowTime
                -- end
            end
        end
        if eventType == ccui.TouchEventType.began then
            btnBeganTouch()
            self._markTime = os.clock()
            local noAction = cc.DelayTime:create(0.1)
            self._moveBtn:runAction(cc.Sequence:create(noAction, cc.CallFunc:create(loopBtnCall)))
        -- elseif eventType == ccui.TouchEventType.moved then
        --     self._markTime = nil
        elseif eventType == ccui.TouchEventType.moved then
            self._markTime = os.clock()
        elseif  eventType == ccui.TouchEventType.canceled then
            self._markTime = nil       
        elseif eventType == ccui.TouchEventType.ended then
            self._markTime = nil
        end

    end
    self._minusBtn:addTouchEventListener(setMinOrPlusHandle)
    self._plusBtn:addTouchEventListener(setMinOrPlusHandle)
    
    self:initTouchEvent()
end

function UIMoveBtn:_loopBtn()

end

function UIMoveBtn:moveToLeft()
    self._moveBtn:setPosition(self._minPosX,self._movePosY)
    self._curX = self._minPosX
    self._toolBar:setPercent(0)
end

function UIMoveBtn:moveToRight()
    self._moveBtn:setPosition(self._maxPosX,self._movePosY)
    self._curX = self._maxPosX
    self._toolBar:setPercent(100)
end

function UIMoveBtn:setMinusBtn()
    if self._totalCount == 1 then
        self._curX = self._pointMap[self._minNum]
        self._moveBtn:setPositionX(self._curX)
        self._currPoint = self._minNum
        self._toolBar:setPercent(0)
        self:showPencet()
    else
        if self._currPoint > self._minNum then
            self._currPoint = self._currPoint - 1
            self._curX = self._pointMap[self._currPoint]
            self._moveBtn:setPositionX(self._curX)
            self:showPencet()
        end
    end
end

function UIMoveBtn:setPlusBtn()
    if self._totalCount == 1 then
        self._curX = self._maxPosX
        self._moveBtn:setPositionX(self._curX)
        self._toolBar:setPercent(100)
        self._currPoint = self._totalCount
        self:showPencet()
    else
        if self._currPoint < self._totalCount then
            self._currPoint = self._currPoint + 1
            self._curX = self._pointMap[self._currPoint]
            self._moveBtn:setPositionX(self._curX)
            self:showPencet()
        end
    end
end

function UIMoveBtn:initTouchEvent()
    local function onTouchHandler(sender, eventType)
        local pos = nil 
        if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            local pos = sender:getTouchMovePosition()
            self:handlerMoveTouch(pos)
        elseif eventType == ccui.TouchEventType.moved then
            if os.clock() - self._startMove < 0.03 then
                return
            end
            self._startMove = os.clock()
            local pos = sender:getTouchMovePosition()
            self:handlerMoveTouch(pos)
            
        elseif eventType == ccui.TouchEventType.began then
            self._startMove = os.clock()
        end
    end

    self._moveBtn:setTouchEnabled(false)
    -- self._moveBtn:addTouchEventListener(onTouchHandler)


    local function onTouchImgHandler(sender, eventType)
        if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            self._startMove = os.clock()
            local pos = sender:getTouchEndPosition()
            self:handlerMoveTouch(pos)
        elseif eventType == ccui.TouchEventType.moved then
            if self._startMove ==nil or os.clock() - self._startMove < 0.03 then
                return
            end
            self._startMove = os.clock()
            local pos = sender:getTouchMovePosition()
            self:handlerMoveTouch(pos)
        elseif eventType == ccui.TouchEventType.began then
            self._startMove = os.clock()
        end
    end
    self._backImg:setTouchEnabled(true)
    self._backImg:addTouchEventListener(onTouchImgHandler)
end

function UIMoveBtn:countAbs(x1,x2)
    if x1 - x2 < 0 then
        return x2 - x1
    end
    return x1 - x2
end

function UIMoveBtn:handlerMoveTouch(pos)
    local _pos = self._moveBtn:getParent():convertToNodeSpace(cc.p(pos.x, pos.y))
    local currX = _pos.x

    if currX >= self._minPosX and currX <= self._maxPosX then  --正常范围
        local per = self:countAbs(currX,self._pointMap[1])
        local point = 1
        for k,v in pairs(self._pointMap) do
            if self:countAbs(currX,v) <= per then
                per = self:countAbs(currX,v)
                point = k
            end
        end
        if point == 1 then
            currX = self._minPosX
        end
        if point == self._totalCount then
            currX = self._pointMap[self._totalCount]
        end
        self._currPoint = point
    else
        if _pos.x < self._minPosX then
            self._currPoint = self._minNum
            currX = self._minPosX
        else
            self._currPoint = self._totalCount
            currX = self._maxPosX
            --特殊处理，道具总数为0的时候，进度条强制不能拖动
            if self._totalCount == 0 then
                currX = self._minPosX
            end
        end
    end 
    self._moveBtn:setPosition(currX,self._movePosY)
    self._curX = currX
    self:showPencet()
end

function UIMoveBtn:showPencet()
    local len = (self._curX -  self._minPosX) / (self._maxPosX - self._minPosX )
    self._toolBar:setPercent(100*len)
    if self._moveCallback ~= nil then
        self._moveCallback(self._callObj, self._currPoint )
    end
end

function UIMoveBtn:getCurrCount()
    --return self._currCount
end

function UIMoveBtn:setPos(x,y)
    self._panel:setPosition(x,y)
end



