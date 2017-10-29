
UnlockPanel = class("UnlockPanel", BasicPanel)
UnlockPanel.NAME = "UnlockPanel"

function UnlockPanel:ctor(view, panelName)
    UnlockPanel.super.ctor(self, view, panelName)

end

function UnlockPanel:finalize()
    UnlockPanel.super.finalize(self)
end

function UnlockPanel:initPanel()
	UnlockPanel.super.initPanel(self)

    local bg = TextureManager:createImageViewFile("bg/get/bg.webp")
    self:addChild(bg)

    self._mainPanel = self:getChildByName("mainPanel")

    self._funImg = self:getChildByName("mainPanel/funImg")

    local byLayer = UICCBLayer.new("rgb-hdwj-bg", self._mainPanel)
    byLayer:setPosition(320, 480)

end

function UnlockPanel:registerEvents()
	UnlockPanel.super.registerEvents(self)

    local root = self:getPanelRoot()
    self:addTouchEventListener(root, self.onRootPanelTouch)
end


function UnlockPanel:onRootPanelTouch(sender)

    if self._startRender == true then
        return
    end
    
    self:stopAnimation()
    self:dispatchEvent(UnlockEvent.HIDE_SELF_EVENT, {})

    EffectQueueManager:completeEffect()
end

function UnlockPanel:onHideHandler()
    self:stopAnimation()
end

function UnlockPanel:onShowHandler(data)

    self:playAnimation()
    self:updateUnlockFunction(data.openType, data.openLevel)

end

function UnlockPanel:playAnimation()
    self._isStopAnimation = false
    self._funEffect = UICCBLayer.new("rgb-gnkq-zi", self._funImg)
end

function UnlockPanel:stopAnimation()
    self._isStopAnimation = true
    if self._funEffect then
        self._funEffect:finalize()
        self._funEffect = nil
    end

    for index = 1, 3 do
        self:stopAction("funpane"..index.."-open")
        self:stopAction("funpane"..index.."-next")
    end
end

function UnlockPanel:endRender()
    self._startRender = false
end

--¸üÐÂ½âËø¹¦ÄÜÏÔÊ¾
--@openType 开启类型
function UnlockPanel:updateUnlockFunction(openType, openLevel)
    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)

    self._startRender = true

    TimerManager:addOnce(1500, self.endRender, self)

    AudioManager:playEffect("yx_jiesuo")

    local infoList = {}

    -- local list = ConfigDataManager:getInfosFilterByOneKey(ConfigData.NewFunctionOpenConfig, "need", level)
    local list = ConfigDataManager:getInfosFilterByTwoKey(
        ConfigData.NewFunctionOpenConfig, "need", openLevel, "type", openType)
    for _, info in pairs(list) do
        table.insert(infoList, {info = info, type = 1})
    end

    for _, info in pairs(list) do
        local nextidList = info.nextid
        for _, id in pairs(nextidList) do
            nextInfo = ConfigDataManager:getConfigById(ConfigData.NewFunctionOpenConfig, id)
            if nextInfo ~= nil then
                table.insert(infoList, {info = nextInfo, type = 2})
            end
        end
    end

    for index = 1, 3 do
        local panel = self:getChildByName("mainPanel/funPanel" .. index)
        panel:setVisible(false)
        local info = infoList[index]
        if info ~= nil then
            self:renderFunction(panel, info.info, info.type,index)
        end
    end
    
end

--
--@param funType 1¿ªÆô 2¼´½«¿ªÆô
function UnlockPanel:renderFunction(panel, info, funType,index)

    if panel == nil then
        return
    end
    if info == nil then
        panel:setVisible(false)
        return
    end
    panel:setVisible(true)

    local infoTxt = panel:getChildByName("infoTxt")
    infoTxt:setString(info.info)
    
    local iconBg = panel:getChildByName("iconBg")
    TextureManager:updateImageView(iconBg, "images/toolbar/" .. info.icon .. ".png")

    local openImg = panel:getChildByName("openImg")
    local nextImg = panel:getChildByName("nextImg")

    local iconEffectBg = panel:getChildByName("iconEffectBg")

    if funType == 1 then
        openImg:setVisible(true)
        nextImg:setVisible(false)

        if iconEffectBg.effect == nil then  --ÌØÐ§ÊÇ·ñ´æÔÚ
            iconEffectBg.effect = UICCBLayer.new("rgb-gnkq-gongneng", iconEffectBg)
        end

        iconEffectBg.effect:setVisible(true)
        local function delay()
            self:playAction("funpane"..index.."-open")
            panel:setVisible(true)
        end
        panel:setVisible(false)
        TimerManager:addOnce(500*index, delay, panel)
    else
        openImg:setVisible(false)
        nextImg:setVisible(true)
        if iconEffectBg.effect ~= nil then
            iconEffectBg.effect:setVisible(false)
        end
        local function delay()
            panel:setVisible(true)
            self:playAction("funpane"..index.."-next")
        end
        panel:setVisible(false)
        TimerManager:addOnce(500*index, delay, panel)
    end
    
end