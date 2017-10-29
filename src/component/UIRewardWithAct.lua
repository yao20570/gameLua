UIRewardWithAct = class("UIRewardWithAct")

UIRewardWithAct.INIT_Y = 495 -- 初始Y坐标
UIRewardWithAct.DIFF_X = 100 -- X间隔100

UIRewardWithAct.DIFF_Y = 120 -- Y间隔100

function UIRewardWithAct:ctor(parent, panel, isShow, completeCallback)
    local layout = parent:getChildByName("mask")
    if layout == nil then
        local winSize = cc.Director:getInstance():getWinSize()
        layout = ccui.Layout:create()
        layout:setContentSize(winSize)
        layout:setPosition(cc.p(0, 0))
        layout:setBackGroundColor(cc.c3b(0, 0, 0))
        layout:setOpacity(104)        
        layout:setAnchorPoint(0, 0)
        layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        layout:setName("mask")
        layout:setTouchEnabled(true)
        parent:addChild(layout)
    end

    -- 遮罩层
    self._layout = layout

    self._isShowBag = isShow

    -- 完成回调
    self._completeCallback = completeCallback

    -- 特效对象表
    self._ccbList = List.new()
    -- 图标对象表
    self._iconList = List.new()

    self._ccbFinalizeMap = {}
end

function UIRewardWithAct:finalize()
    for k, v in pairs(self._ccbFinalizeMap) do
        v:finalize()
    end
    self._ccbFinalizeMap = nil
end

function UIRewardWithAct:show(rewardData, targetPos)
    -- 清空表
    self._ccbList:clear()
    self._iconList:clear()
    -- 图标个数

--    --测试      
--    local temp = {}
--    for i = 1, 5 do
--        for k, v in pairs(rewardData) do
--            table.insert(temp, v)
--        end
--    end
--    rewardData = temp

    self._itemCount = #rewardData
    -- 加载特效但是不播放，占坑
    for i = 1, self._itemCount do
        -- 先创建图标
        local sprite = cc.Sprite:create()
        sprite:setPosition(self:getShowPos(i, self._itemCount))
        self._layout:addChild(sprite)

        local owner = { }
        owner["pause"] = function()
            local icon = UIIcon.new(sprite, rewardData[i], true, self, nil, true)

            -- Y坐标修改
            local nameTxt = icon:getNameChild()
            nameTxt:setPositionY(nameTxt:getPositionY() - 5)
            
            icon:setLocalZOrder(2)
            self._iconList:pushBack(sprite)
            icon:setTouchEnabled(false)

            local ccb2 = UICCBLayer.new("rgb-huoquwupin-wu", sprite, nil, nil, true)
            ccb2:setLocalZOrder(1)

            table.insert(self._ccbFinalizeMap, ccb2)
        end

        owner["complete"] = function()
        end

        local ccbLayer = UICCBLayer.new("rgb-huoquwupin", sprite, owner)
        ccbLayer:pause()        
        ccbLayer:setLocalZOrder(3)
        self._ccbList:pushBack(ccbLayer)

        table.insert(self._ccbFinalizeMap, ccbLayer)
    end
    -- 开始启动
    self:startAction(self._ccbList, self._itemCount, targetPos)

    
end

------
-- 返回一个特效
function UIRewardWithAct:addCcbInPos(name, pos, parent)
    local ccbLayer = UICCBLayer.new(name, parent, nil, nil, true)
    ccbLayer:setPositionType(0)
    if pos then
        ccbLayer:setPosition(pos.x, pos.y)
    end
    table.insert(self._ccbFinalizeMap, ccbLayer)
    return ccbLayer
end

------
-- 开始启动
function UIRewardWithAct:startAction(ccbList, itemCount, targetPos)
    local times = 0
    local function start()
        if times < itemCount then
            times = times + 1

            ccbList:at(times):resume()            
            TimerManager:addOnce(70, start, self)

            AudioManager:playEffect("yx_item")

        else           
            -- 关闭
            local function onFinish(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:finish(targetPos)
                    self._layout:addTouchEventListener(function() end)
                end
            end

            local function delayTouch()
                self._layout:addTouchEventListener(onFinish)
            end

            --TimerManager:addOnce(500, delayTouch, self)
            TimerManager:addOnce(700, function()self:finish(targetPos)end, self)
        end
    end
    start()
end

-- itemCount 总个数
function UIRewardWithAct:getShowPos(i, itemCount)
    
    
    local row = math.ceil(itemCount / 5 )
    local offsetY = row / 2 * UIRewardWithAct.DIFF_Y 

    -- 初始Y坐标
    local initY = UIRewardWithAct.INIT_Y + offsetY
    
    -- 间隔100
    local diffX = UIRewardWithAct.DIFF_X
    local diffY = UIRewardWithAct.DIFF_Y
    
    -- 每行个数
    local stepCount = 5
    
    local winSize = cc.Director:getInstance():getWinSize()

    -- 真实位置index
    local function getIp(index, stepCount)
        index = index % stepCount
        if index == 0 then
            index = stepCount
        end
        return index
    end

    -- 是不是最后一行
    local function getReamin(i, stepCount, itemCount)
        local remain = itemCount -(math.ceil(i / stepCount) -1) * stepCount
        if remain <= stepCount then
            return remain
        else
            return false
        end
    end

    -- 算出中心点
    local function getPosX(index, stepCount, itemCount)
        local curCount = index
        local midPosX = winSize.width / 2
        -- 获取真实位置index
        index = getIp(index, stepCount)
        -- 最后一行不足5个的时候做特殊处理
        local remain = getReamin(curCount, stepCount, itemCount)
        if remain then
            stepCount = remain
        end
        -- 计算中间位置index
        local midIndex =(stepCount + 1) / 2
        -- 差量 = 真实位置index - 中点位置index
        local diffI = index - midIndex
        local posX = diffI * diffX + midPosX
        return posX
    end

    local posX = getPosX(i, stepCount, itemCount)
    local posY = initY -(math.ceil(i / stepCount) -1) * diffY
    return cc.p(posX, posY)
end

function UIRewardWithAct:finish(targetPos)
    local function stepFinish(sprite, targetPos, step)
        --local delayAction = cc.DelayTime:create(0.5)
        -- 所有定住多久
        local moveTo00 = cc.MoveTo:create(0.3, self._layout:convertToNodeSpace(targetPos))
        -- print("move的目标为： "..targetPos.x.."||".. targetPos.y)
        local scaleAction = cc.ScaleTo:create(0.3, 0)

        local playAudio = cc.CallFunc:create( function()
            AudioManager:playEffect("TouchMarket")
        end)
        -- 组合缩放和移动
        local moveAndScale = cc.Spawn:create(moveTo00, scaleAction)
        local removeCall = cc.CallFunc:create( function()
            -- 加背包特效
            if self._isShowBag then
                local ccbLayer = self:addCcbInPos("rgb-huoquwuping-beibao", targetPos, self._layout)
                ccbLayer:setLocalZOrder(100)
            end
            -- 加载到最后一个
            if step == self._itemCount then                
                local function delayRemove()
                    self:finalize()
                    self._layout:removeFromParent()   
                    if self._completeCallback then
                        self._completeCallback()      
                    else
                        --logger:info("=========>it's not set self._completeCallback")
                    end           
                end
                TimerManager:addOnce(100, delayRemove, self)
            end
        end )

        local seqAction = cc.Sequence:create(--[[delayAction,]] playAudio, moveAndScale, removeCall)
        sprite:runAction(seqAction)
    end

    local count = 0
    local function finish()
        if count < self._ccbList:size() then
            count = count + 1
            stepFinish(self._iconList:at(count), targetPos, count)
            TimerManager:addOnce(70, finish, self)        
        end
    end

    finish()
end
