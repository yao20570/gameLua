
GuidePanel = class("GuidePanel", BasicPanel)
GuidePanel.NAME = "GuidePanel"

function GuidePanel:ctor(view, panelName)
    GuidePanel.super.ctor(self, view, panelName)
    self._isNotTouch = false
    self.isShowFlag = false
end

function GuidePanel:finalize()
    -- self._model:finalize()
    self._isNotTouch = false

    GuidePanel.super.finalize(self)

    if self._guideEffect ~= nil  then
    self._guideEffect:finalize()
    self._guideEffect=nil
    end

    if self._guideEffectHand~=nil then
    self._guideEffectHand:finalize()
    self._guideEffectHand = nil
    end

end

function GuidePanel:initPanel()
    GuidePanel.super.initPanel(self)

    self._roleProxy = self:getProxy(GameProxys.Role)

    self._onlyDialogPanel = self:getChildByName("onlyDialogPanel")
    self._txtName = self._onlyDialogPanel:getChildByName("txtName")
    self._imgNpc = self._onlyDialogPanel:getChildByName("imgNpc") 
    self._imgSkip = self._onlyDialogPanel:getChildByName("imgSkip")   
    self._imgSkipJump = self._imgSkip:getChildByName("imgSkipJump")
    self._richLab = self._onlyDialogPanel:getChildByName("richLab")
    if self._richLab == nil then
        local richLabContainer = self._onlyDialogPanel:getChildByName("richLabContainer")
        local x, y = richLabContainer:getPosition()
        self._richLab = RichTextMgr:getInstance():getRich( { }, richLabContainer:getContentSize().width, nil, nil, nil, RichLabelAlign.left_top)
        self._richLab:setName("richLab")
        self._richLab:setPositionX(x)
        self._richLab:setPositionY(y)
        self._richLab:setLocalZOrder(richLabContainer:getLocalZOrder())
        richLabContainer:getParent():addChild(self._richLab)
        richLabContainer:setVisible(false)
    end


    local areaClickPanel = self:getChildByName("areaClickPanel")
    self._plotPanel = self:getChildByName("plotPanel")


    areaClickPanel:setLocalZOrder(1)


    self._areaClickPanel = areaClickPanel

    -- //null 初始化的时候 给circleImg添加两个特效
    local circleImg = self._areaClickPanel:getChildByName("circleImg")
    local arrowImg = self._areaClickPanel:getChildByName("arrowImg")
    arrowImg:setOpacity(0)
    circleImg:setOpacity(0)
    local size = circleImg:getContentSize()
    if self._guideEffect == nil then
        self._guideEffect = self:createUICCBLayer("rgb-xszy", circleImg)
        self._guideEffect:setPosition(size.width / 2, size.height / 2)
    end

    if self._guideEffectHand == nil then
        self._guideEffectHand = self:createUICCBLayer("rgb-xszy-shou", circleImg)
        self._guideEffectHand:setPosition(size.width / 2, size.height / 2)
    end


    self._areaClickPanel:setVisible(false)

    self._onlyDialogPanel:setVisible(false)
    self._plotPanel:setVisible(false)

    self._taskIcon = self:getChildByName("taskImg")

    self._plotListView = self._plotPanel:getChildByName("listView")
    self:addClippingNode()
end

function GuidePanel:registerEvents()
    GuidePanel.super.registerEvents(self)
    
    local panelRoot = self:getPanelRoot()
    self:addTouchEventListener(panelRoot, self.onGuidePanelTouch, nil, nil, nil, nil, nil, true)

    local skipBtn = self:getChildByName("skipBtn")
    self:addTouchEventListener(skipBtn, self.onSkipBtnTouch)

    
    self._runPlotBtn = self._plotPanel:getChildByName("runPlotBtn")
    local plotTouchPanel = self._plotPanel:getChildByName("plotTouchPanel")
    self:addTouchEventListener(plotTouchPanel, self.onRunPlot)
    self:addTouchEventListener(self._runPlotBtn, self.onRunPlot)
end

function GuidePanel:onShowHandler()
    
end

function GuidePanel:onHideHandler()
    -- 因为self._imgSkipJump是无限循环，在面板关闭的情况下必选删除
    self._imgSkipJump:stopAllActions()

    -- 如果有高斯模糊则隐藏
    self:removeBlurBg()
end

function GuidePanel:setSkipBtnVisible(visible)
    local skipBtn = self:getChildByName("skipBtn")
    skipBtn:setVisible(visible)
end

function GuidePanel:onSkipBtnTouch(sender)

    local function callback()
        GuideManager:skipGuide()
        self:resetPanel()
    end

    local msgId = 113
    if GuideManager:getCurGuideId() ~= GuideManager.EndGuideId then
        msgId = 130
    end
    local messageBox = self:showMessageBox(self:getTextWord(msgId), callback)
    messageBox:setLocalZOrder(3000) --这个提示框提到最高
end

function GuidePanel:updateBlurSprite()
    local blurSprite = self:getBlurSprite()
    if blurSprite == nil then
        local skin = self:getSkin()
        skin:setLocalZOrder(1)
        self:releaseBlurSprite()
        self:addBlurSprite()
    else
        blurSprite:setVisible(true)
    end
end

function GuidePanel:playDialogueAnima()

    self._isPlayDialogueAnima = true
    local xStart = 0
    local xEnd = 155
    local y = self._imgNpc:getPositionY()

    -- 标记动画中，2秒后解除，防止快速点击关闭对话
    local dt = cc.DelayTime:create(2)
    local cb = cc.CallFunc:create( function() self._isPlayDialogueAnima = false end)
    local seq = cc.Sequence:create(dt, cb)
    self._onlyDialogPanel:stopAllActions()
    self._onlyDialogPanel:runAction(seq)

    -- Npc半身像移动淡出
    local mt = cc.MoveTo:create(0.5, cc.p(xEnd, y))
    local ft = cc.FadeTo:create(0.5, 255)
    local e = cc.EaseBackOut:create(mt)
    self._imgNpc:setPositionX(xStart)
    self._imgNpc:setOpacity(0)
    self._imgNpc:stopAllActions()
    self._imgNpc:runAction(e)
    self._imgNpc:runAction(ft)

    -- 富文本淡出
    local ft = cc.FadeTo:create(0.8, 255)
    self._richLab:setOpacity(0)
    self._richLab:stopAllActions()
    self._richLab:runAction(ft)

    -- 跳过标记循环跳动
    local size = self._imgSkip:getContentSize()
    local mt1 = cc.MoveTo:create(0.3, cc.p(size.width / 2, 6))
    local mt2 = cc.MoveTo:create(0.3, cc.p(size.width / 2, 3))
    -- local cb = cc.CallFunc:create(function() logger:info("==>x:%s, y:%s", self._imgSkip:getPositionX(),self._imgSkip:getPositionY()) end)
    local seq = cc.Sequence:create(mt1, mt2, cb)
    local rep = cc.RepeatForever:create(seq)
    self._imgSkipJump:stopAllActions()
    self._imgSkipJump:runAction(rep)
end

--更新对话框信息
function GuidePanel:updateDialogueInfo(info, callback)
    if info == nil then
        return
    end
    
    -- 设置背景模糊
    self:updateBlurSprite()

    -- 播放对话动画(隐藏到显示的情况下才播放)
    if self._onlyDialogPanel:isVisible() == false then        
        self:playDialogueAnima()
    end


    self.isShowFlag = false
    self._nextcallback = callback

    self:setSkipBtnVisible(false)
    self._onlyDialogPanel:setVisible(true)
    self._plotPanel:setVisible(false)
    self._areaClickPanel:setVisible(false)

    local function callbackVisible()
        self._isNotTouch = false
    end

    -- 对白
    local memo = nil
    if type(info) == "string" then
        memo = { {txt = info, fontSize = 22} }
    elseif type(info) == "table" then
        memo = loadstring("return " .. info.memo)()    

        -- 名称
        self._txtName:setString(info.name)    
        -- 半身像
        TextureManager:updateImageView(self._imgNpc, info.head)

    else
        memo = {txt = "...", fontSize = 22}
    end
    self._richLab:setData(memo)
    

    self._isNotTouch = true
    -- self:playAction("guide_npc",callbackVisible)
    callbackVisible()

    self:resetGuide()
end

function GuidePanel:onEnterScene()
    local function callbackVisible()
        TimerManager:addOnce(GameConfig.guideParams.TIME_EFFECT_STOP, self.callbackTouch,self)
    end 
    self._isNotTouch = true
    --self:playAction("guide_npc",callbackVisible)
    callbackVisible()
end

function GuidePanel:setInfoVisible(isShow)
    local areaClickPanel = self._areaClickPanel
    local infoTxt = areaClickPanel:getChildByName("infoTxt")
    infoTxt:setVisible(isShow)
    local infoBg = areaClickPanel:getChildByName("infoBg")
    infoBg:setVisible(isShow)    
    --local circleImg = areaClickPanel:getChildByName("circleImg")
    --circleImg:setVisible(isShow)
end

function GuidePanel:moveAreaClick(len)
    local areaClickPanel = self._areaClickPanel
    areaClickPanel:setVisible(false)
    self:setInfoVisible(false)

    self._onlyDialogPanel:setVisible(false)
    self._plotPanel:setVisible(false)

    self:setTouchEnabled(false) --移动的时候不能点击
end

function GuidePanel:moveEnd()  --移动结束
    self:setTouchEnabled(true)
end

--
--@arrowDir 箭头的方向 配置的时候，强制设置
function GuidePanel:updateAreaClick(widget, callback, info, isMove, arrowDir)
    self.isShowFlag = true
    self._nextAreaClickCallback = callback

    local areaClickPanel = self._areaClickPanel
    areaClickPanel:setVisible(true)
    self:setInfoVisible(true)

    self._onlyDialogPanel:setVisible(false)
    self._plotPanel:setVisible(false)

    local worldPosition = widget:getWorldPosition()
    local root = self:getPanelRoot()
    local curPos = root:convertToNodeSpace(worldPosition)
    
    --areaClickPanel:setPosition(curPos)
    
    local infoTxt = areaClickPanel:getChildByName("infoTxt")
    infoTxt:setString(info)
    print("新手引导--流程   "..info)
    
    local widgetSize = widget:getContentSize()
    local scale = widgetSize.height / 197
    local circleImg = areaClickPanel:getChildByName("circleImg")

    if scale > 1 then
        self._guideEffect:setScale(1)
    else
        --circleImg:setScale(scale + 0.2)
        self._guideEffect:setScale(0.8)
    end
    
    -- local scaleAction = cc.ScaleTo:create(0.15,scale + 0.2)
    -- circleImg:runAction(scaleAction)
    local anchor = widget:getAnchorPoint()
    if widget.isOffset == false then
        anchor.y = 0.5
        anchor.x = 0.5
    end
    if self._curPos then
--        local dx = ( self._anchorX - anchor.x ) * self._x
--        local dy = ( self._anchorY - anchor.y ) * self._y
--        self._areaClickPanel:setPosition(cc.p(self._curPos.x + dx, self._curPos.y + dy))
    end
    local circleY = (0.5 - anchor.y) * widgetSize.height
    local circleX = (0.5 - anchor.x) * widgetSize.width
    
    if  self._circleX ~= nil then
        local ax, ay = self._areaClickPanel:getPosition()
        self._areaClickPanel:setPosition(ax + self._circleX - circleX, ay + self._circleY - circleY)
    end
    
    self._circleX = circleX
    self._circleY = circleY
    local circleH = widgetSize.height * scale
    circleImg:setPositionY(circleY)
    circleImg:setPositionX(circleX)
    
    print("circle x y "..circleX.."=="..circleY)
    --self._guideEffect:setPositionX(circleX)
    --self._guideEffect:setPositionY(circleY)
    --self._guideEffectHand:setPositionX(circleX)
    --self._guideEffectHand:setPositionY(circleY)

    --self._guideEffect:setPosition(circleImg:getPosition())
    --self._guideEffectHand:setPosition(circleImg:getPosition())
    
    local cwp = circleImg:getWorldPosition()
    local ccp = self._clippingNode:convertToNodeSpace(cwp)
    --self._circleImgNode:setScale(1)
    self._circleImgNode:setContentSize(widgetSize)
    --self._circleImgNode:ScaleTo
    self._circleImgNode:setVisible(true)
    self._circleImgNode:setPosition(ccp)

    local size = infoTxt:getContentSize()
    local infoBg = areaClickPanel:getChildByName("infoBg")
    local width = size.width + 60
    if width < 288 then
        width = 288
    end
    infoBg:setContentSize(width, infoBg:getContentSize().height)
    local arrowImg = areaClickPanel:getChildByName("arrowImg")
    local arrowImgSize = arrowImg:getContentSize()
    local dir = 1
    local scale = 1

    if type(arrowDir) == type(0) then
        if arrowDir < 0 then
            dir = -1
        else
            dir = 1
        end
    else
        if curPos.y > 600 then --widget在上边，需要倒转
            dir = -1
        else
            dir = 1
        end
    end
    if dir == -1 then
        arrowImg:setScale(-1)
            --infoBg:setScale(-1)
        circleImg:setRotation(90)
        scale = NodeUtils:getAdaptiveScale()
    else
        arrowImg:setScale(1)
        circleImg:setRotation(0)
        infoBg:setScale(1)
        scale = 1 / NodeUtils:getAdaptiveScale()
    end
    
    local MaxDeviatePositionY = 150
--    local MaxDeviatePositionY = circleH / 2 + arrowImgSize.height / 2
--    if MaxDeviatePositionY > 110 then
--        MaxDeviatePositionY = 110
--    end 
    local arrowImgY = circleY + MaxDeviatePositionY * dir 
    arrowImg:setPositionY(arrowImgY)
    arrowImg:setPositionX(circleX)
    local txtY = arrowImgY + (arrowImgSize.height / 2 + size.height / 2) * dir - 5 * scale * dir
    if txtY > 0 then
        infoTxt:setPositionY(txtY)
        infoBg:setPositionY(txtY )
    else
        infoBg:setPositionY(txtY )
        infoTxt:setPositionY(txtY)
    end
    local adaptiveScale = 1 / NodeUtils:getAdaptiveScale()
    local txtX = 0
    if curPos.x + circleX - width / 2 < 0 then
        txtX = width / 2 - curPos.x - circleX
    elseif curPos.x + circleX + width / 2 > 640 * adaptiveScale then
        txtX = -(width / 2 + curPos.x - 640  * adaptiveScale) - circleX
    end
    infoTxt:setPositionX(txtX + circleX)
    infoBg:setPositionX(txtX + circleX)
    infoBg:setOpacity(0)
    infoTxt:setOpacity(0)
    self._areaClickPanel:setVisible(true)
    self:connectRunGuideAction(circleImg,arrowImg, infoBg, infoTxt, dir,curPos,ccp)
end

function GuidePanel:onGuidePanelTouch(sender)
    if self._isNotTouch then
        --print("没到时间不能点击")
        return
    end

    if self._nextcallback ~= nil then
        if self._isTouchNpc == nil then  
            --防止快速点击2次响应
            self._isTouchNpc = true
            local function callbackVisible()
                -- 这个有点绕，因为在self._nextcallback的回调中会对self._nextcallback进行了赋值。。。
                local n = self._nextcallback
                self._nextcallback = nil
                n()                
                self._isTouchNpc = nil
            end
            --self:playAction("guide_npc_jieshu",callbackVisible)
            callbackVisible()
        end
    end

    if self._nextAreaClickCallback ~= nil then
        self._nextAreaClickCallback()
        self._nextAreaClickCallback = nil
    end
    
end

function GuidePanel:resetPanel(isShowFlag)
    if isShowFlag then
        self._areaClickPanel:setVisible(true) 
        self:setInfoVisible(false) 
    else
        self._areaClickPanel:setVisible(false)  
    end
    --self._dialogPanel:setVisible(false)
    self._clippingNode:setVisible(false)
    self._onlyDialogPanel:setVisible(false) 
    self._plotPanel:setVisible(false)

    --self._plotListView:removeAllItems()
    self._plotListView:removeAllChildren()
    self:getSkin():setBackGroundColorOpacity(0)
end

function GuidePanel:resetGuide()
    local circleImg = self._areaClickPanel:getChildByName("circleImg")
    local arrowImg = self._areaClickPanel:getChildByName("arrowImg")
    local infoBg = self._areaClickPanel:getChildByName("infoBg")
    local infoTxt = self._areaClickPanel:getChildByName("infoTxt")

    circleImg:stopAllActions()
    arrowImg:stopAllActions()
    infoBg:stopAllActions()
    infoTxt:stopAllActions()

    -- circleImg:setRotation(0)
    self._clippingNode:setVisible(false)

    
end

function GuidePanel:connectRunGuideAction(circleImg, arrowImg, infoBg, infoTxt,dir,curPos,ccp)
    self:resetGuide()
    self:showClippintNode()
    local pointX, pointY = self._areaClickPanel:getPosition()
    local distance = math.sqrt(math.pow((pointX - curPos.x), 2) + math.pow((pointY - curPos.y), 2))
    local speed = 0  
    if distance < 300 then
        speed = GameConfig.guideParams.SPEED1 
    elseif distance <600 then
        speed = GameConfig.guideParams.SPEED2
    else
        speed = GameConfig.guideParams.SPEED3
    end
    local time = distance / speed
    local moveAction1 = cc.MoveTo:create(time, curPos)
    self._curPos = curPos
    self._isNotTouch = true
    self._areaClickPanel:runAction(moveAction1)
    TimerManager:addOnce(1000 * time, self.runGuideAction,self,circleImg, arrowImg, infoBg, infoTxt,dir)
end

function GuidePanel:callbackTouch()
    self._isNotTouch = false
end
function GuidePanel:runGuideAction(circleImg, arrowImg, infoBg, infoTxt,dir)
    local fadeAction = cc.FadeTo:create(0.5, 255)
    local fadeAction1 = cc.FadeTo:create(0.5, 255)
    --local callbackAction = cc.Sequence:create(fadeAction1, cc.CallFunc:create(callbackTouch))
    infoBg:runAction(fadeAction)
    infoTxt:runAction(fadeAction1)
    TimerManager:addOnce(GameConfig.guideParams.TIME_ACTION_STOP, self.callbackTouch,self)
    -- self._circleImgNode:setVisible(true)
    local circleImg =self._areaClickPanel:getChildByName("circleImg")
    local cwp = circleImg:getWorldPosition()
    local ccp = self._clippingNode:convertToNodeSpace(cwp) 
    --self._circleImgNode:setPosition(ccp)

    local curCircleScale = circleImg:getScale()
    local scaleAction2 = cc.ScaleTo:create(GameConfig.guideParams.TIME_QUAN_MARK, curCircleScale*GameConfig.guideParams.QUAN_SCALE_MAX)
    local scaleAction1 = cc.ScaleTo:create(GameConfig.guideParams.TIME_QUAN_MARK, curCircleScale *GameConfig.guideParams.QUAN_SCALE_MIN)
    --local rotateAction1 = cc.RotateTo:create(0.5, 180)
    --local rotateAction2 = cc.RotateTo:create(0.5, 360)
    
    local seq1 = cc.Sequence:create(scaleAction1, scaleAction2)
    --local seq2 = cc.Sequence:create(rotateAction1, rotateAction2)
    --local spaw = cc.Spawn:create(seq1, seq2)
    local ease = cc.EaseOut:create(seq1,0.8)
    local circleAction = cc.RepeatForever:create(ease)
    --circleImg:runAction(circleAction)
    
    -------------------------
    local x, y = arrowImg:getPosition()
    arrowImg:setPosition(cc.p(x, y + 15 * dir))
    local moveAction2 = cc.MoveTo:create(GameConfig.guideParams.TIME_QUAN_MARK,cc.p(x, y + 20 * dir))
    local moveAction1 = cc.MoveTo:create(GameConfig.guideParams.TIME_QUAN_MARK,cc.p(x, y ))--))dir ))
    local moveAction = cc.Sequence:create(moveAction1, moveAction2)
    local easeMove = cc.EaseOut:create(moveAction, 0.8)
    local action = cc.RepeatForever:create(easeMove)
    --arrowImg:runAction(action)
    
    -- local x, y = infoBg:getPosition()
    -- local moveAction1 = cc.MoveTo:create(1,cc.p(x, y + 5 * dir))
    -- local moveAction2 = cc.MoveTo:create(1,cc.p(x, y -5 * dir))
    -- local action = cc.RepeatForever:create(cc.Sequence:create(moveAction1, moveAction2))
    -- infoBg:runAction(action)
    
    -- local x, y = infoTxt:getPosition()
    -- local moveAction1 = cc.MoveTo:create(1,cc.p(x, y + 5 * dir))
    -- local moveAction2 = cc.MoveTo:create(1,cc.p(x, y -5 * dir))
    -- local action = cc.RepeatForever:create(cc.Sequence:create(moveAction1, moveAction2))
    -- infoTxt:runAction(action)
end

--增加遮罩
function GuidePanel:addClippingNode()
    local back = cc.LayerColor:create(cc.c4b(0,0,0,0))
    back:setContentSize(cc.size(5000, 5000))
    back:setPosition(-2500, -2500)
    local clippingNode = cc.ClippingNode:create()
   -- clippingNode:setAlphaThreshold(0.0)
    clippingNode:setInverted(true)
    self._areaClickPanel:addChild(clippingNode, -1)
    clippingNode:addChild(back)
    local circleImg = self._areaClickPanel:getChildByName("circleImg")
    local clipNode = self._areaClickPanel:getChildByName("clipNode")
    local circleImgNode = clipNode:clone()
    clippingNode:setStencil(circleImgNode)
    self._circleImgNode = circleImgNode 
    self._clippingNode = clippingNode
end

function GuidePanel:showClippintNode()
    self._clippingNode:setVisible(true)
end

function GuidePanel:updateIconPos(widget, offsetX, offsetY)
    self._taskIcon:setVisible(true)
    local pos = widget:getWorldPosition()
    local root = self:getPanelRoot()
    local curPos = root:convertToNodeSpace(pos)
    offsetY = offsetY or 0
    offsetX = offsetX or 0
    print(offsetX, offsetY)
    curPos.x = curPos.x + offsetX
    curPos.y = curPos.y + offsetY
    self._taskIcon:setPosition(curPos)
    
end

function GuidePanel:setTaskIconVisible(isShow)
    self._taskIcon:setVisible(isShow)
end

function GuidePanel:updatePlot(plotData, nextCallback)
    self.isShowFlag = false
    self._plotNextCallback = nextCallback

    self:getSkin():setBackGroundColorOpacity(120)
    self._stepCount = 1 -- 计数
    self._plotData = plotData
    local totalCount = #plotData
    -- 显示
    self._areaClickPanel:setVisible(false)
    --self._dialogPanel:setVisible(false)
    self._onlyDialogPanel:setVisible(false)
    self._plotPanel:setVisible(true)

    self._plotListView:removeAllChildren()
    -- 初始化卡片
    local leftHead = self._plotPanel:getChildByName("leftHead")
    local rightHead = self._plotPanel:getChildByName("rightHead")
    leftHead:setScale(1)
    rightHead:setScale(1)
    self:updateItemPanel(plotData[self._stepCount])

    self:resetGuide()
end

-- 设置剧情显示属性 
function GuidePanel:updateItemPanel(plotInfo)
    -- 卡片
    if self._stepCount ~= 1 then
        local itemPanel = self._plotPanel:getChildByName("itemPanel01")
        local cloneItem = itemPanel:clone()
        self:setItemShow(cloneItem, plotInfo)
    end

    -- 非卡片表情等
    if self._stepCount == 1 then
        -- 初始化头像2
        for i = 1, #self._plotData do
            local plotInfo = self._plotData[i]
            -- 如果第一个是1
            if self._plotData[1].direction == 1 then
                if plotInfo.direction == 2 then
                    self:updatePlotTop(plotInfo)
                    break
                end
            end
            -- 如果第一个是2
            if self._plotData[1].direction == 2 then
                if plotInfo.direction == 1 then 
                    self:updatePlotTop(plotInfo)
                    break
                end
            end
        end
        self:updatePlotTop(plotInfo)
        self:runHeadAction(plotInfo)
    else
        self:updatePlotTop(plotInfo)
        -- 执行动作
        self:runHeadAction(plotInfo)
    end

end

function GuidePanel:setItemShow(cloneItem, plotInfo)
    local itemBg = nil 
    local itemBg01 = cloneItem:getChildByName("itemBg01")
    local itemBg02 = cloneItem:getChildByName("itemBg02")
    itemBg01:setVisible(false)
    itemBg02:setVisible(false)

    if plotInfo.direction == 1 then
        itemBg = itemBg01
        itemBg:setVisible(true)
    else
        itemBg = itemBg02
        itemBg:setVisible(true)
    end

    local nameTxt  = itemBg:getChildByName("nameTxt")
    
    local memoText = itemBg:getChildByName("memoText")


    local plotInfoName = self:getPlotInfoName(plotInfo.name) -- 获取角色名称
    nameTxt:setString(plotInfoName)
   
    memoText:setString(plotInfo.memo)

    cloneItem.plotInfo = plotInfo
    cloneItem:setOpacity(0)

    self._plotListView:addChild(cloneItem)
    cloneItem:setPositionX(24)
    cloneItem:setPositionY(460)
    cloneItem:setName( "item"..self._stepCount)
    local allItems = self._plotListView:getChildren()
    for k, item in pairs(allItems) do
        if item:getName() ~= "item"..self._stepCount then
            item:stopAllActions()
            local moveTo = cc.MoveTo:create(0.15, cc.p(item:getPositionX(), item:getPositionY() - item:getContentSize().height - 5))
            item:runAction(moveTo)
        end
    end

    -- 动作
    local act01 = cc.FadeTo:create(0.15, 255)
    cloneItem:runAction(act01)
    

    -- 上一个变灰
    if self._stepCount >= 2 then
        self:itemToGray(self._plotListView:getChildByName("item"..self._stepCount-1))
    end
    
end

function GuidePanel:onRunPlot(sender)
     
    if self._stepCount == #self._plotData then
        -- 剧情回调函数
        if self._plotNextCallback ~= nil then
            self._plotNextCallback()
            self._plotNextCallback = nil
        end
        return
    end

    self._stepCount = self._stepCount + 1
    
    self:updateItemPanel(self._plotData[self._stepCount])
end

-- 变灰
function GuidePanel:itemToGray(itemPanel)
    local itemBg01 = itemPanel:getChildByName("itemBg01")
    local itemBg02 = itemPanel:getChildByName("itemBg02")
    local itemBg = nil
    if itemBg01:isVisible() then
        itemBg = itemBg01
    elseif itemBg02:isVisible() then
        itemBg = itemBg02
    end

    -- 字色
    local memoText = itemBg:getChildByName("memoText")
    --memoText:setColor(cc.c3b(74, 50, 29))

    TextureManager:updateImageView(itemBg,"images/guideIcon/item_bg01.png", nil, ModuleName.GuideModule)
    
    local dirIcon  = itemBg:getChildByName("dirIcon")
    TextureManager:updateImageView(dirIcon,"images/guideIcon/dir_icon02.png", nil, ModuleName.GuideModule)

end


-- 非卡片表情等
function GuidePanel:updatePlotTop(plotInfo)
    local leftHead = self._plotPanel:getChildByName("leftHead")
    local rightHead = self._plotPanel:getChildByName("rightHead")
    local face01  = leftHead:getChildByName("faceIcon")
    local face02  = rightHead:getChildByName("faceIcon")
    face01:setVisible(false)
    face02:setVisible(false)

    -- 更新头像
    if plotInfo.head ~= 0 then
        --------------------
        if plotInfo.direction == 1 then
            if plotInfo.name ~= "玩家名" then
                if plotInfo.name == "小婵" then
                    plotInfo.head = 1
                end
                local headUrl = string.format("images/guideHeadIcon/head%d.png", plotInfo.head)
                TextureManager:updateImageView(leftHead, headUrl, nil, ModuleName.GuideModule)
            else
                local roleSex = self._roleProxy:getSexByHeadId() -- 1=boy,2=girl
                local headUrl = ""
                if roleSex == 1 then
                    headUrl = "images/guideHeadIcon/head5.png"
                elseif roleSex == 2 then
                    headUrl = "images/guideHeadIcon/head6.png"
                end
                TextureManager:updateImageView(leftHead, headUrl, nil, ModuleName.GuideModule) 
            end
        else
            if plotInfo.name ~= "玩家名" then
                if plotInfo.name == "小婵" then
                    plotInfo.head = 1
                end

                local headUrl = string.format("images/guideHeadIcon/head%d.png", plotInfo.head)
                TextureManager:updateImageView(rightHead, headUrl, nil, ModuleName.GuideModule)
            else
                local roleSex = self._roleProxy:getSexByHeadId() -- 1=boy,2=girl
                local headUrl = ""
                if roleSex == 1 then
                    headUrl = "images/guideHeadIcon/head5.png"
                elseif roleSex == 2 then
                    headUrl = "images/guideHeadIcon/head6.png"
                end
                TextureManager:updateImageView(rightHead, headUrl, nil, ModuleName.GuideModule) 
            end
        end
    end

    -- 对话时的颜色切换
    if plotInfo.direction == 1 then
        leftHead:setColor(cc.c3b(255, 255, 255))
        rightHead:setColor(cc.c3b(130, 130, 130))
    else
        leftHead:setColor(cc.c3b(130, 130, 130))
        rightHead:setColor(cc.c3b(255, 255, 255))
    end

    -- 翻转和坐标调整
    if plotInfo.direction == 1 then
        self:headFlipDiffPos(leftHead, plotInfo)
    else
        self:headFlipDiffPos(rightHead, plotInfo)
    end
end

function GuidePanel:headFlipDiffPos(headNode, plotInfo)
    -- 重置还原
    headNode:setFlippedX(false)
    if plotInfo.direction == 1 then
        headNode:setPosition(160, 747)
    else
        headNode:setPosition(480, 747)
    end
    -- 翻转
    local flip = rawget(plotInfo, "flip")
    if flip ~= nil then
        if flip == 1 then
            headNode:setFlippedX(true)
        end
    end
    -- 坐标
    local diffPos = rawget(plotInfo, "diffPos")
    if diffPos ~= nil then
        headNode:setPositionX(headNode:getPositionX() + diffPos[1])
        headNode:setPositionY(headNode:getPositionY() + diffPos[2])
    end

end


------
-- 执行动作
function GuidePanel:runHeadAction(plotInfo)
    -- 回调函数
    local function callFunc()
        local itemPanel = self._plotPanel:getChildByName("itemPanel01")
        local cloneItem = itemPanel:clone()
        self:setItemShow(cloneItem, plotInfo)
        self:setMask(false)
    end

    local leftHead = self._plotPanel:getChildByName("leftHead")
    local rightHead = self._plotPanel:getChildByName("rightHead")

    -- 头像动作
    leftHead:stopAllActions()
    rightHead:stopAllActions()
    leftHead:setPositionX(160) -- 160,747
    rightHead:setPositionX(480) -- 480

    if self._stepCount == 1 then
        self:setMask(true)
        leftHead:setPositionX( -300 ) -- 160,747
        rightHead:setPositionX( 940 ) -- 480
        local comDelay= cc.DelayTime:create(0.1)
        local comCallFunc = cc.CallFunc:create(callFunc)

        local leftDelay= cc.DelayTime:create(0.1)
        local leftMove = cc.MoveTo:create(0.35, cc.p(160, 747))
        local leftScale= cc.ScaleTo:create(0.15, 1.2,1.2)
        local rightDelay= cc.DelayTime:create(0.3)
        local rightMove = cc.MoveTo:create(0.35, cc.p(480, 747))
        local rightScale= cc.ScaleTo:create(0.15, 1, 1)

        if plotInfo.direction == 1 then
            leftHead:runAction(cc.Sequence:create(leftDelay, leftMove, comDelay, leftScale, comCallFunc))
            rightHead:runAction(cc.Sequence:create(rightDelay, rightMove, comDelay, rightScale))
        else
            leftHead:runAction(cc.Sequence:create(rightDelay, leftMove, comDelay, rightScale))
            rightHead:runAction(cc.Sequence:create(leftDelay, rightMove, comDelay, leftScale, comCallFunc))
        end
    else
        if plotInfo.direction == 1 then
            local act01 = cc.ScaleTo:create(0.15, 1.2,1.2)
            local act02 = cc.ScaleTo:create(0.15, 1, 1)
            leftHead:runAction(act01)

            rightHead:runAction(act02)
        else
            local act01 = cc.ScaleTo:create(0.15, 1.2,1.2)
            local act02 = cc.ScaleTo:create(0.15, 1, 1)
            leftHead:runAction(act02)
            rightHead:runAction(act01)
        end
    end
end

------
-- 获取名称
function GuidePanel:getPlotInfoName(name)
    if name == "玩家名" then
        name = self._roleProxy:getRoleName()
    end
    return name
end
