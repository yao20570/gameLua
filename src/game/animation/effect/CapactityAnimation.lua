------战力特效---
CapactityAnimation = class("CapactityAnimation", BaseAnimation)


function CapactityAnimation:finalize()

	CapactityAnimation.super.finalize(self)

end

function CapactityAnimation:playComplete()
    EffectQueueManager:completeEffect()
end

function CapactityAnimation:play()

    local function handler()
    	local params = self.data
        self:realShowCapactityAction(params, 310 ,460)
    end

    EffectQueueManager:addEffect(EffectQueueType.CAPACTITY, handler,false, true)
	
end

function CapactityAnimation:realShowCapactityAction(params, x, y)
	AudioManager:playEffect("yx_power")

    local rootNode = cc.Node:create()
    rootNode:setPosition(x + FightingActionCapConfig.POSITION_X, y - 20 + FightingActionCapConfig.POSITION_Y)
    self.parent:addChild( rootNode )


    ----------------------数字滚动相关------------------------------
    local function numRoll()
        local clippingNode = cc.ClippingNode:create()
        clippingNode:setPosition(40 , -25)
        local sprite = TextureManager:createSprite("images/common/uiBg_4.png")
        sprite:setAnchorPoint(cc.p(0, 0))
        sprite:setScaleX(4.9)
        sprite:setScaleY(0.38)
        clippingNode:setStencil(sprite)
        clippingNode:setLocalZOrder(10)
    
        rootNode:addChild( clippingNode )
    
        local newPower = params.fightingVar
        local oldPower = params.fightingOldVar
        local oldNumList, newNumList = self:createCapactityNumGroup(clippingNode, oldPower, newPower)
        self:numRollAction(oldNumList, newNumList)
    end
    
    --------------------------------------------------------------

    ---------------------数字飘字---------------------------------
    local function numFlyAction()
        local numTxt = ccui.Text:create()
        numTxt:setFontName(GlobalConfig.fontName)
        numTxt:setAnchorPoint(cc.p(0, 0.5))
        local num = params.dt
        local numToStr
        if num > 0 then
            numTxt:setColor(ColorUtils.wordGreenColor)
            numToStr = string.format("+%d", num) -- 正数
        else
            numTxt:setColor(ColorUtils.wordRedColor)
            numToStr = string.format("%d", num)  -- 负数不需要加符号
        end
        numTxt:setFontSize(FightingActionCapConfig.FONT_SIZE)
        numTxt:setPosition(100, 0)
        numTxt:setString(numToStr)
        rootNode:addChild(numTxt)

        local x, y = numTxt:getPosition()
        local flyTxtAction = cc.MoveTo:create(FightingActionCapConfig.FLY_TIME, cc.p(x, y + FightingActionCapConfig.FLY_HIGHT))
        numTxt:runAction(cc.Sequence:create(cc.DelayTime:create(FightingActionCapConfig.TIME_THREE * 0.1), flyTxtAction))

    end

     ------------------------特效----------------------------
    local function playEffect()

        local function completeFunc()  --特效结束就结束，需要知道特效时间，来动态算出滚动的
            rootNode:removeFromParent()
            self:playComplete()
        end
        local ccbLayer = UICCBLayer.new("rgb-fighting", rootNode, nil, completeFunc ) 
        ccbLayer:setPosition(70, -8)
        ccbLayer:setVisible(true)
    end


    local mainAction = cc.Sequence:create(
        cc.CallFunc:create(playEffect),
        cc.DelayTime:create(FightingActionCapConfig.NUM_ROLL_TIME),
        cc.CallFunc:create(numRoll),
        cc.DelayTime:create(FightingActionCapConfig.NUM_FLY_TIME),
        cc.CallFunc:create(numFlyAction))
    rootNode:runAction(mainAction)

     --------------------------------------------------
    
    -----------------先用延迟做节奏，跟准备的是，在特效里面增加回调----------------
end


function CapactityAnimation:createCapactityNumGroup(parent, oldNum, newNum)

    local oldNumList = {}
    local newNumList = {}

    local oldNumStrAry = StringUtils:splitUtf8String(tostring(oldNum), "")
    local newNumStrAry = StringUtils:splitUtf8String(tostring(newNum), "")

    local index = 0
    for _, numStr in pairs(oldNumStrAry) do
        local atlas = self:createAtlas(numStr)
        atlas:setPosition(index * FightingActionCapConfig.NUM_SPACING, 0)
        parent:addChild(atlas)
        index = index + 1
        table.insert(oldNumList, atlas)
    end

    local index = 0
    for _, numStr in pairs(newNumStrAry) do
        local atlas = self:createAtlas(numStr)
        atlas:setPosition(index * FightingActionCapConfig.NUM_SPACING, 30)
        parent:addChild(atlas)
        index = index + 1
        table.insert(newNumList, atlas)
    end

    return oldNumList, newNumList
end

function CapactityAnimation:createAtlas(numStr)
    local textAtlas = ccui.TextAtlas:create()
    textAtlas:setAnchorPoint(cc.p(0, 0))
    textAtlas:setProperty("1234567890", "ui/images/fonts/num_small.png", 24, 30, "0")
    textAtlas:setVisible(true)
    textAtlas:setString(numStr)

    return textAtlas
end

--数字滚动动画
function CapactityAnimation:numRollAction(oldNumList, newNumList, completeCb)
    local moveAction = cc.MoveBy:create(0.125 * FightingActionCapConfig.NUM_ROLL_SPEED, cc.p(0, -30))
    local delayTime = 0.05 * FightingActionCapConfig.NUM_ROLL_SPEED
    
    local index = 1
    for _, numAtlas in pairs(oldNumList) do
        numAtlas:runAction( cc.Sequence:create(cc.DelayTime:create(delayTime * index), moveAction:clone()) )
        index = index + 1
    end

    local delayTime = 0.075 * FightingActionCapConfig.NUM_ROLL_SPEED
    local index = 1
    for _, numAtlas in pairs(newNumList) do
        numAtlas:runAction( cc.Sequence:create(cc.DelayTime:create(delayTime * index), moveAction:clone()) )
        index = index + 1
    end
end

   



    --------------------------------------------------------

--     do
--         return
--     end

-- 	local function complete()
-- 		self:playComplete()
--     end


--     -- 飘差值
--     local node = cc.Node:create()
--     local numTxt = ccui.Text:create()
--     numTxt:setFontName(GlobalConfig.fontName)
--     numTxt:setAnchorPoint(cc.p(0, 0.5))
--     local num = params.dt
--     local numToStr
--     if num > 0 then
--         numTxt:setColor(ColorUtils.wordGreenColor)
--         numToStr = string.format("+%d", num) -- 正数
--     else
--         numTxt:setColor(ColorUtils.wordRedColor)
--         numToStr = string.format("%d", num)  -- 负数不需要加符号
--     end
--     numTxt:setFontSize(FightingActionCapConfig.FONT_SIZE)
--     node:addChild(numTxt)
--     numTxt:setPosition(100, - 20)
--     numTxt:setString(numToStr)
--     local layer = self.parent
--     node:setPosition( x  , y + FightingActionCapConfig.POSITION_Y)
--     node:setVisible(false)
    
    
--     -- 节点
--     local fightingNode = cc.Node:create()
--     fightingNode:setPosition(x + FightingActionCapConfig.POSITION_X, y - 20 + FightingActionCapConfig.POSITION_Y)

--     local ccbLayer = UICCBLayer.new("rgb-fighting", layer ) 
--     ccbLayer:setPosition(fightingNode:getPositionX()+ 70, fightingNode:getPositionY() - 8)
--     ccbLayer:setVisible(true)
--     -- 设置背景特效的停留时间点
--     local function pauseBgShow()
--         ccbLayer:pause()
--     end
--     layer:addChild(node)
--     layer:addChild(fightingNode)
    
--     self:showFightingChangeAction(fightingNode, params, node, complete, ccbLayer)
-- end


-- --[[参数说明
--     node                    目前的层的对象
--     params.fightingVar      当前战力
--     params.fightingOldVar   旧战力
--     topNode                 飘字节点 
--     completeCallback        执行函数
--     movieChip               背景特效
--     roleProxy               角色数据
-- ]]
-- function CapactityAnimation:showFightingChangeAction(node, params, topNode, completeCallback,movieChip)
-- 	self._zhanliNum = nil -- 战斗力显示层
--     local uiFightNumGroup = nil
--     -- 最后的回调，清空操作
--     local function lastCallback()
--         uiFightNumGroup:finalize()
--         topNode:removeFromParent()
--         node:removeFromParent()
--         movieChip:finalize()
--         completeCallback()
--     end


--     local function setNum()
--         local newPower = params.fightingVar
--         local oldPower = params.fightingOldVar
--         uiFightNumGroup = UIFightNumGroup.new( node , oldPower , newPower ) -- UIFightNumGroup位于UIFightNum.lua self._zhanliNum =
--     end
--     -- 开始设置数字,并开始startChange
--     setNum()

--     local function flyTxtCallback() 
--         local noAction = cc.MoveBy:create(FightingActionCapConfig.END_TIME + 1.2, cc.p(0, 0)) -- 场景最后的停留时间控制
--         topNode:runAction(cc.Sequence:create(noAction, cc.CallFunc:create(lastCallback)))
--     end

--     local function flyTxt()
--         local x, y = topNode:getPosition()
--         local flyTxtAction = cc.MoveTo:create(FightingActionCapConfig.FLY_TIME, cc.p(x, y + FightingActionCapConfig.FLY_HIGHT))
--         topNode:setVisible(true)
--         topNode:runAction(cc.Sequence:create(flyTxtAction, cc.CallFunc:create(flyTxtCallback)))
--     end

--     topNode:runAction(cc.Sequence:create(cc.DelayTime:create(FightingActionCapConfig.TIME_THREE * 0.1), cc.CallFunc:create(flyTxt)))
-- end



---------------------------------------------------------------------------------------------


