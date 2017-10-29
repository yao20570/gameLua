
UnlockNewPanel = class("UnlockNewPanel", BasicPanel)
UnlockNewPanel.NAME = "UnlockNewPanel"

function UnlockNewPanel:ctor(view, panelName)
    UnlockNewPanel.super.ctor(self, view, panelName )

end

function UnlockNewPanel:finalize()
    UnlockNewPanel.super.finalize(self)
    if self._bgEffect then
        self._bgEffect:finalize()
        self._bgEffect = nil
    end
    if self._bgEffect1 then
        self._bgEffect1:finalize()
        self._bgEffect1 = nil
    end
end

function UnlockNewPanel:initPanel()
	UnlockNewPanel.super.initPanel(self)
    self._bgEffect = nil
    self._bgEffect1 = nil

    -- local bg = TextureManager:createImageViewFile("bg/get/bg.webp")
    -- self:addChild(bg)

    self._mainPanel = self:getChildByName("mainPanel")

    self._funImg = self:getChildByName("mainPanel/funImg")

    -- local byLayer = UICCBLayer.new("rgb-hdwj-bg", self._mainPanel)
    -- byLayer:setPosition(320, 480)
    
    self._unlockQueue = Queue.new()
end

function UnlockNewPanel:registerEvents()
	UnlockNewPanel.super.registerEvents(self)

    local root = self:getPanelRoot()
    self:addTouchEventListener(root, self.onRootPanelTouch)
end


function UnlockNewPanel:onRootPanelTouch(sender)

    if self._startRender == true then
        return
    end


    self:updateUnlockFunction()
end

function UnlockNewPanel:onHideHandler()
    self:stopAnimation()
end

function UnlockNewPanel:onShowHandler(data)

    local list = ConfigDataManager:getInfosFilterByTwoKey(
        ConfigData.NewFunctionOpenConfig, "need", data.openLevel, "type", data.openType)
    for _, info in pairs(list) do
        if info.windowShow == 1 then  --等于1才弹窗解锁
            self._unlockQueue:push(info)
        end
    end

    self:updateUnlockFunction()

end

function UnlockNewPanel:stopAnimation()
    if self._funEffect then
        self._funEffect:finalize()
        self._funEffect = nil
    end
    
    if self._bgEffect1 then
        self._bgEffect1:finalize()
        self._bgEffect1 = nil
    end

    self:stopAction("Animation0")
end

function UnlockNewPanel:endRender()
    self._startRender = false
end

function UnlockNewPanel:completeEffect()
    if self._lastGuideId ~= nil then
        local flag = GuideManager:trigger(self._lastGuideId, true)
        logger:info("!!!!!触发引导!!!GuideId:%d!!!flag:" .. tostring(flag), self._lastGuideId)
        if flag ~= false then --引导成功 还原到主城
            self:resetInitState()
            self:dispatchEvent(UnlockEvent.SHOW_OTHER_EVENT, ModuleName.MainSceneModule)
        end
    end
    self._lastGuideId = nil
end

--¸üÐÂ½âËø¹¦ÄÜÏÔÊ¾
--@openType 开启类型
function UnlockNewPanel:updateUnlockFunction()

   
    self._startRender = true
    TimerManager:addOnce(900, self.endRender, self)

    self:stopAnimation()

    local info = self._unlockQueue:pop()
    if info == nil then
        self:dispatchEvent(UnlockEvent.HIDE_SELF_EVENT, {})
        EffectQueueManager:completeEffect()
        self:completeEffect()
        return
    end

    if self._lastGuideId == nil then  --一个引导组，只会触发一次引导
        self._lastGuideId = info.guideOpen
    end

    AudioManager:playEffect("yx_jiesuo")

    local index = 1
    local panel = self:getChildByName("mainPanel/funPanel" .. index)
    panel:setVisible(false)
    self:renderFunction(panel, info, index)
    
end

--
function UnlockNewPanel:renderFunction(panel, info, index)
    if panel == nil then
        return
    end
    if info == nil then
        panel:setVisible(false)
        return
    end
    panel:setVisible(true)


    local infoTxt = panel:getChildByName("infoTxt")
    local iconEffectBg = panel:getChildByName("iconEffectBg")
    local icon = iconEffectBg:getChildByName("Image_icon")
    local iconBg = panel:getChildByName("Image_title")

    infoTxt:setString(info.info)

    local nIconId = tonumber(info.icon) or 1
    local nWordIconId = tonumber(info.wordicon) or 1
    TextureManager:updateImageView(icon, "images/unlock/icon_" .. nIconId .. ".png") --图标
    TextureManager:updateImageView(iconBg, "images/unlock/" .. nWordIconId .. ".png")  --艺术字

    --if iconEffectBg.effect == nil then
    --    iconEffectBg.effect = UICCBLayer.new("rgb-gnkq-gongneng", iconEffectBg)
    --end

    self:playAction("Animation0")
     local function delay()
        local iconbg2 = panel:getChildByName("iconEffectBg_2")
        if self._funEffect==nil then
            self._funEffect = UICCBLayer.new("rgb-gnkq-gnz", iconbg2)
        end
     end
     TimerManager:addOnce(500, delay, panel)

     local function bgEffectFun()
        --标题图标动画
        if iconEffectBg.effect == nil then
            iconEffectBg.effect = UICCBLayer.new("rgb-gnkq-gongneng", iconEffectBg)
        end
        --背景上部特效
        local bgEffect = panel:getChildByName("bgEffect")
        if self._bgEffect == nil then
            self._bgEffect = UICCBLayer.new("rgb-res-light", bgEffect)
        end
        --背景下部特效
        local bgEffect1 = panel:getChildByName("bgEffect_1")
        if self._bgEffect1 == nil then
            self._bgEffect1 = UICCBLayer.new("rgb-res-light", bgEffect1)
            bgEffect1:setRotation(180)
        end
     end
     -- 
     TimerManager:addOnce(200, bgEffectFun, panel)
     
end