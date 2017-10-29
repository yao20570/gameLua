UILoading = class("UILoading") --加载动画

function UILoading:ctor(parent)
    self._loadSkin = UISkin.new("UILoading")
    self._loadSkin:setParent(parent)
    self._loadSkin:setBackGroundColorOpacity(128)
    
    self._contentTxt = self._loadSkin:getChildByName("mainPanel/contentTxt")
    self._bgImg = self._loadSkin:getChildByName("mainPanel/Image_2")
    local Image_17 = self._loadSkin:getChildByName("mainPanel/Image_17")
    
    --self._contentTxt:setVisible(false)
    self._loadSkin:setVisible(false)
    Image_17:setVisible(false)
    self._contentTxt:setLocalZOrder(10)
    local y = y or self._contentTxt:getPositionY()
    self._contentTxt:setPositionY(y + 30)
    self._bgImg:setVisible(false)
end

function UILoading:finalize()
    if self._loadingEffect ~= nil then
        self._loadingEffect:finalize()
        self._loadingEffect = nil
    end
    self._loadSkin:finalize()
end

function UILoading:show(content, type)
    self:showAction()
    content = content or ""
    self._loadSkin:setVisible(true)
    self._contentTxt:setString(content)
    self._type = type
    --self._isShow = true
end

function UILoading:getType()
    return self._type
end

function UILoading:hide()
    --self._bgImg:stopAllActions()
    self._loadSkin:setVisible(false)
    --self._isShow = false
    if self._rpg_spoon ~= nil then
        self._rpg_spoon:removeFromParent()
        self._rpg_spoon = nil
    end

    -- if self._loadingEffect ~= nil then
    --     self._loadingEffect:setVisible()
    --     -- self._rpg_acompass:removeFromParent()
    --     -- self._rpg_acompass = nil
    -- end 
end

function UILoading:showAction()
    -- if self._isShow == true then
    --     return
    -- end


    -- local action1 = cc.RotateTo:create(1,180)
    -- local action2 = cc.RotateTo:create(1,360)
    -- local action = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
    -- self._bgImg:runAction(action)

    local mainPanel = self._loadSkin:getChildByName("mainPanel")
    local size = mainPanel:getContentSize()
    
    -- if self._zhuanpan == nil then
    --     local imageView = TextureManager:createSprite("images/common/zhuanpan.png")
    --     self._zhuanpan = imageView
    --     mainPanel:addChild(imageView)
    --     imageView:setPosition(size.width / 2  , size.height / 2 )
    -- end
    

    -- if self._rpg_acompass == nil then
    --     self._rpg_acompass = UIMovieClip.new("rpg-Acompass")
    --     self._rpg_acompass:setParent(mainPanel)
    --     self._rpg_acompass:setPosition(size.width / 2, size.height / 2)
    -- end
    -- self._rpg_acompass:play(true)
    if self._loadingEffect == nil then
        self._loadingEffect = UICCBLayer.new("rgb-loading", mainPanel)
        self._loadingEffect:setPosition(size.width / 2, size.height / 2)
    end
    self._loadingEffect:setVisible(true)
    self._loadingEffect:setLocalZOrder(10)
end



