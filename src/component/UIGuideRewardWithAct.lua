UIGuideRewardWithAct = class("UIGuideRewardWithAct")

-- 父节点
function UIGuideRewardWithAct:ctor(layer, panel)
    local uiSkin = UISkin.new("UIGuideReward")
    uiSkin:setParent(layer) 
    self._uiSkin = uiSkin
    -- 全部设置1
    local children = uiSkin:getRootNode():getChildren()
    for _,child in pairs(children) do
        local zorder = child:getLocalZOrder()
        if zorder == 0 then
            child:setLocalZOrder(1)
            child:setTouchEnabled(false)
        end
    end
    -- 加遮罩
    local layout = self._uiSkin:getChildByName("mask")
    if layout == nil then
        layout = ccui.Layout:create()
        local winSize = cc.Director:getInstance():getWinSize()
        layout:setContentSize(winSize)
        layout:setPosition(cc.p(0, 0))
        layout:setBackGroundColor(cc.c3b(0, 0, 0))
        layout:setOpacity(104) -- 40%的透明度
        layout:setAnchorPoint(0, 0)
        layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        layout:setName("mask")
        self._uiSkin:addChild(layout)
    end
    self._layout = layout -- 遮罩层
    -- 数据结构
    self._iconList = List.new()
    -- 目标位置 
    if panel then 
        local posX, posY = panel:getToolbarPanel():getBtnItem5Pos()
        self._targetPos = cc.p(posX, posY)
    else
        self._targetPos = cc.p(543, 44)
    end
    self:initPanel()

end

-- 初始化
function UIGuideRewardWithAct:initPanel()
    -- 领取按钮隐藏
    self._mainPanel = self._uiSkin:getChildByName("mainPanel")
    local rewardBtn = self._mainPanel:getChildByName("rewardBtn")
    local textField_8 = self._mainPanel:getChildByName("TextField_8")
    self._bgImg = self._mainPanel:getChildByName("Image_11")
    rewardBtn:setVisible(false)
    textField_8:setVisible(false)
    self._mainPanel:setAnchorPoint(0.5, 0.5)
    -- 加载图标
    self:initRewardPanel()
    -- 加载特效
    self:addCCB(self._bgImg)
    -- 打开动作
    self._mainPanel:setScale(0)
    local action1 = cc.ScaleTo:create(0.1, 1)
    local delayTime = cc.DelayTime:create(1.5) -- 展示时间，多久后开始动作
    local action2 = cc.CallFunc:create( function()
        self:startIconAct(self._iconList, self._targetPos)
    end)
    local action3 = cc.Sequence:create(action1,delayTime,action2)
    self._mainPanel:runAction(action3)
    -- 
end

function UIGuideRewardWithAct:initRewardPanel()
    local rewardList = {}
    table.insert(rewardList, {power = 401, typeid = 1001, num = 1})
    table.insert(rewardList, {power = 401, typeid = 1010, num = 1})
    table.insert(rewardList, {power = 401, typeid = 1019, num = 1})
    table.insert(rewardList, {power = 401, typeid = 4014, num = 3})
    self._iconList:clear()
    for index = 1, #rewardList do
        local iconContainer = self._uiSkin:getChildByName("mainPanel/rewardPanel/iconContainer" .. index)
        local sprite = cc.Sprite:create()
        self._mainPanel:addChild(sprite)
        sprite:setName("icon")
        sprite:setPosition(cc.p(45 + 110*index, 525))
        local icon = UIIcon.new(sprite, rewardList[index], true, nil, nil, true)
        self._iconList:pushBack(sprite)
    end
end

-- 加特效
function UIGuideRewardWithAct:addCCB(bgImg)
    local sp = cc.Sprite:create()
    bgImg:addChild(sp)
    local size = bgImg:getContentSize()
    sp:setPosition(size.width/2, size.height/2)
    UICCBLayer.new("rgb-xslb", sp, nil,nil, true)
    local chuxian = UICCBLayer.new("rgb-xslb-chuxian", sp, nil,nil, true)
    --chuxian:setLocalZOrder(-1)
end


function UIGuideRewardWithAct:startIconAct(iconList, targetPos)
    local times = 0
    local function start()
        if times < iconList:size() then
            times = times + 1
            iconList:at(times):stopAllActions()
            self:action(iconList:at(times), targetPos , times)
            TimerManager:addOnce(100, start, self) -- 有毒啊，为什么函数后面不用跟括号"()"，加了括号后瞬间全部执行
        else
            TimerManager:remove(start, self)
        end
    end
    start()
    -- 隐藏除了rewardpanel外所有的子节点
    local children = self._mainPanel:getChildren()
    for _,child in pairs(children) do
        local name = child:getName()
        if name ~= "icon" then
            child:setVisible(false)
        end
    end
end

-- 第一阶段的MoveTo
function UIGuideRewardWithAct:action(icon, targetPos, times)
    local x = icon:getPositionX() - 50
    local y = icon:getPositionY() + 50
    local action1 = cc.MoveTo:create(0.1, cc.p(x, y))
    local stopActCall = cc.CallFunc:create(function()
        icon:stopAllActions() 
    end)

    local action2 = cc.MoveTo:create(0.3, cc.p(targetPos.x, targetPos.y))
    local scaleAction = cc.ScaleTo:create(0.3, 0)
    local moveScale = cc.Spawn:create(action2, scaleAction)

    local playAudio = cc.CallFunc:create( function()
                AudioManager:playEffect("TouchMarket")
            end
    )

    local removeCall = cc.CallFunc:create(function()
        -- 加背包特效
        local layer = UICCBLayer.new("rgb-huoquwuping-beibao", self._mainPanel, nil, nil, true) 
        layer:setPosition(targetPos.x, targetPos.y)
        -- 加载到最后一个
        if times == self._iconList:size() then
            self._uiSkin:finalize()
        end
        -- print(times)
    end)

    local seq = cc.Sequence:create(action1, playAudio, moveScale, removeCall)

    icon:runAction(seq)
end












