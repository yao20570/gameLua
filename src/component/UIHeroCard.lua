UIHeroCard = class("UIHeroCard") -- 武将半身像

-- data = {
--    heroId = 0,   -- 英雄Id
--    starNum = 0,  -- 星数
--    fightting = 0, -- 战力
--    isDisableCCB = true -- 是否禁用ccb
-- }
function UIHeroCard:ctor(panel, parent, data)
    self._panel = panel

    self._uiSkin = UISkin.new("UIHeroCard")
    self._uiSkin:setVisible(true)
    self._uiSkin:setParent(parent)

    self._isDisableCCB = false
    self._pnlHead = self._uiSkin:getChildByName("pnlHead")
    self._panel:addTouchEventListener(self._pnlHead, self.onTouchImg, nil, self)
    self._pnlHead:setTouchEnabled(false)

    self:init()

    self._data = data
    if data ~= nil then
        self:updateData(data)
    end
end

function UIHeroCard:finalize()

    if self._effect ~= nil then
        self._effect:finalize()
        self._effect = nil
    end

    if self._ccbZhanli ~= nil then
        self._ccbZhanli:finalize()
        self._ccbZhanli = nil
    end

    self._uiSkin:finalize()
end

function UIHeroCard:init()

    self._imgKuang = self._pnlHead:getChildByName("imgKuang")
    self._labName = self._pnlHead:getChildByName("labName")
    self._imgGuo = self._pnlHead:getChildByName("imgGuo")
    self._starPanel = self._pnlHead:getChildByName("starPanel")
    self._imgZhanLiBg = self._pnlHead:getChildByName("imgZhanLiBg")
    self._artZhanLi = self._imgZhanLiBg:getChildByName("artZhanLi")
    self._imgHead = self._pnlHead:getChildByName("imgHead")
    self._btnComment = self._pnlHead:getChildByName("btnComment")
    self._btnComment:setVisible(false)

    self._stars = { }
    for i = 1, 5 do
        self._stars[i] = self._starPanel:getChildByName("starImg" .. i)
    end



    self._panel:addTouchEventListener(self._btnComment, self.onCommentBtn, nil, self)
end
-------------外部调用方法-----------------

function UIHeroCard:getContentSize()
    return self._pnlHead:getContentSize()
end

function UIHeroCard:setLocalZOrder(index)
    self._uiSkin:setLocalZOrder(index)
end

function UIHeroCard:setBtnCommentVisible(b)
    self._btnComment:setVisible(b)
end

function UIHeroCard:setDisableCCB(isDisable)
    self._isDisableCCB = isDisable
end

function UIHeroCard:isDisableCCB()
    return self._isDisableCCB or false
end

function UIHeroCard:setTouchImgCallBack(callback)
    if type(callback) == "function" then
        self._touchImgCallBack = callback
        self._pnlHead:setTouchEnabled(true)
    else
        self._pnlHead:setTouchEnabled(false)
    end
end

function UIHeroCard:updateData(data)
    data.starNum = data.starNum or 0
    data.fightting = data.fightting or 0
    data.isDisableCCB = data.isDisableCCB or false

    self._data = data

    self._isDisableCCB = data.isDisableCCB


    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)

    -- 框
    local path = string.format("images/heroBgIcon/bgHeroColor%d.png", config.color)
    TextureManager:updateImageView(self._imgKuang, path)

    -- 品质框
    local color = config.color


    local effectUrl = GlobalConfig.HeroColor2Effect[color]
    if self._isDisableCCB ~= true and color > 0 and GlobalConfig.HeroColor2Effect[color] ~= nil then

        if self._effect ~= nil and self._effect:getName() ~= GlobalConfig.HeroColor2Effect[color] then
            self._effect:finalize()
            self._effect = nil
        end

        if self._effect == nil then
            local size = self._imgKuang:getContentSize()
            self._effect = self._panel:createUICCBLayer(effectUrl, self._imgKuang)
            self._effect:setPosition(size.width - 15, size.height / 2 - 19)
            self._effect:setLocalZOrder(3)
        else
            self._effect:setVisible(true)
        end
    else
        if self._effect ~= nil then
            self._effect:setVisible(false)
        end
    end


    -- 名称
    self._labName:setString(config.name)

    -- 国
    TextureManager:updateImageView(self._imgGuo, string.format("images/heroBgIcon/TxtGuo%d.png", config.countryIcon))

    -- 星级
    local starUrl = "images/newGui1/IconStarMini.png"
    local drakUrl = "images/newGui1/IconStarMiniBg.png"
    ComponentUtils:renderStar(self._stars, data.starNum, starUrl, drakUrl, config.starmax)

    -- 战力
    if data.fightting == 0 then
        self._imgZhanLiBg:setVisible(false)
    else
        self._imgZhanLiBg:setVisible(true)

        -- self.curHeroId
        self._artZhanLi:setString(string.format("%d", data.fightting))

        if self._ccbZhanli == nil then
            self._ccbZhanli = self._panel:createUICCBLayer("rgb-wj-zhanli", self._imgZhanLiBg)
            self._ccbZhanli:setPositionX(self._imgZhanLiBg:getContentSize().width / 2 - 20)
            self._artZhanLi:setLocalZOrder(1)
        end

    end

    -- 半身像
    local heroUrl = ComponentUtils:getHeroHalfBodyUrl(data.heroId)
    TextureManager:updateImageViewFile(self._imgHead, heroUrl)

end


-- 类型  1-兵营 2-武将 3-太学院 4-战法 5-军师 
function UIHeroCard:onCommentBtn(sender)

    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, self._data.heroId)
    if config ~= nil then
        local proxy = self._panel:getProxy(GameProxys.Comment)
        proxy:toCommentModule(2, config.ID, config.name)
    end
end

function UIHeroCard:onTouchImg(sender)
    if self._touchImgCallBack ~= nil then
        self._touchImgCallBack()
    end
end