
HeroGetPanel = class("HeroGetPanel", BasicPanel)
HeroGetPanel.NAME = "HeroGetPanel"


function HeroGetPanel:ctor(view, panelName)
    HeroGetPanel.super.ctor(self, view, panelName)
    self._ccbBgName = { "rgb-hdwj-bai", "rgb-hdwj-lv", "rgb-hdwj-lan", "rgb-hdwj-zi" }
    self._ccbTopName = { "rgb-hdwj-baidi", "rgb-hdwj-lv-di", "rgb-hdwj-landi", "rgb-hdwj-zidi" }
end

function HeroGetPanel:finalize()
    self:clearAnimation()

    HeroGetPanel.super.finalize(self)
end

function HeroGetPanel:initPanel()
    HeroGetPanel.super.initPanel(self)
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

    self._panelBg = self:getChildByName("panelBg")
    NodeUtils:adaptive(self._panelBg)
    TextureManager:updateImageViewFile(self._panelBg, "bg/newGuiBg/BgPanel.pvr.ccz")

    self._getImg = self:getChildByName("mainPanel/getImg")
    self._labTip1 = self:getChildByName("mainPanel/labTip1")
    self._btnSure = self:getChildByName("mainPanel/btnSure")



    self._heroIdQueue = Queue.new()
end

function HeroGetPanel:registerEvents()
    HeroGetPanel.super.registerEvents(self)

    --    local root = self:getPanelRoot()
    --    self:addTouchEventListener(root, self.onRootPanelTouch)

    self:addTouchEventListener(self._btnSure, self.onRootPanelTouch)
end

function HeroGetPanel:onRootPanelTouch(sender)
    if self._startRender == true then
        return
    end


    self:checkHeroResolve()

    self:updateHero()
end

function HeroGetPanel:onShowHandler(heroIdList)
    -- 如果有数据，则清空旧的，重新显示
    if not self._heroIdQueue:empty() then
        self._heroIdQueue:clear()
    end


    for _, hero in pairs(heroIdList) do
        self._heroIdQueue:push(hero)
    end

    self:updateHero()
end

function HeroGetPanel:clearAnimation()
    if self._uiHeroCard ~= nil then
        self._uiHeroCard:finalize()
        self._uiHeroCard = nil
    end

    if self._ccbTop ~= nil then
        self._ccbTop:finalize()
        self._ccbTop = nil
    end

    if self._ccbBg ~= nil then
        self._ccbBg:finalize()
        self._ccbBg = nil
    end

    if self._ccbTitle ~= nil then
        self._ccbTitle:finalize()
        self._ccbTitle = nil
    end

--    if self._effect ~= nil then
--        self._effect:finalize()
--        self._effect = nil
--    end

    self._labTip1:setVisible(false)
    self._labTip1:stopAllActions()

    self._btnSure:setVisible(false)
end

function HeroGetPanel:endRender()
    self._startRender = false
end

function HeroGetPanel:updateHero()

    self._startRender = true
    TimerManager:addOnce(1500, self.endRender, self)

    self:clearAnimation()

    self._curHero = self._heroIdQueue:pop()
    local hero = self._curHero
    if hero == nil then
        self._heroDbId = nil
        self:dispatchEvent(HeroGetEvent.HIDE_SELF_EVENT, { })

        EffectQueueManager:completeEffect()
        return
    end
    local heroId = hero.heroId
    self._heroDbId = hero.heroDbId
    AudioManager:playEffect("yx_jiesuo")

    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, hero.heroId)

    local this = self

    local owner = { }
    owner["pause"] = function()
        data = { }
        data.heroId = hero.heroId
        data.starNum = 0
        data.fightting = 0

        this._uiHeroCard = UIHeroCard.new(this, this._getImg, data)
        this._uiHeroCard:setLocalZOrder(2)

--        local color = config.color
--        if color > 0 and GlobalConfig.HeroColor2Effect[color] ~= nil then
--            self._effect = this:createUICCBLayer(GlobalConfig.HeroColor2Effect[color], this._getImg)
--            local size = this._uiHeroCard:getContentSize()
--            self._effect:setPosition(size.width / 2 - 25, 0)
--            self._effect:setLocalZOrder(3)
--        end

        local fade = cc.FadeIn:create(2)
        this._labTip1:setOpacity(0)
        this._labTip1:setVisible(true)
        this._labTip1:stopAllActions()
        this._labTip1:runAction(fade)

        this._btnSure:setVisible(true)
    end
    owner["complete"] = function()
    end

    self._ccbBg = self:createUICCBLayer(self._ccbBgName[config.color], self._getImg, owner)
    self._ccbBg:setLocalZOrder(1)

    self._ccbTop = self:createUICCBLayer(self._ccbTopName[config.color], self._getImg)
    self._ccbBg:setLocalZOrder(4)

    self._ccbTitle = self:createUICCBLayer("rgb-hdwj-gxhd", self._getImg)
    self._ccbTitle:setPositionY(366)

end

function HeroGetPanel:checkHeroResolve()
    local proxy = self:getProxy(GameProxys.Hero)
    -- local isResolve = proxy:isResolveHero(hero.heroDbId)
    local isResolve = proxy:isCanWorkOut(self._curHero)
    -- #3866 【优化】- 武将获得自动分解功能
    -- 服务端是旧表，兼容保持若是低等级不进行自动分解
    --    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, hero.heroId)
    --    if config.color <= 2 then
    --        logger:info("低品质不进行自动分解")
    --     return	
    -- end
    -- 直接发送分解消息
    if isResolve then
        proxy:onTriggerNet300101Req( { id = self._curHero.heroDbId })
    end
end

function HeroGetPanel:sendHeroResolveReq()
    if self._heroDbId == nil then
        return
    end
    local proxy = self:getProxy(GameProxys.Hero)
    proxy:onTriggerNet300101Req( { id = self._heroDbId })
end