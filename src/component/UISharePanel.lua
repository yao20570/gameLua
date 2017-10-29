UISharePanel = class("UISharePanel")

function UISharePanel:ctor(parent, panel, _isTurnUp)
    local uiSkin = UISkin.new("UISharePanel")
    uiSkin:setParent(parent)
    uiSkin:setLocalZOrder(5000)
    self._shareProxy = panel:getProxy(GameProxys.Share)
    self._uiSkin = uiSkin

    local sharePanel = self:getChildByName("sharePanel")
    local img = ccui.Layout:create()
    img:setContentSize(5000, 5000)
    img:setAnchorPoint(0.5,0.5)
    sharePanel:addChild(img)
    ComponentUtils:addTouchEventListener(img,self.onHideTouch,nil,self)

    self:setTurnTo( _isTurnUp )
    
    self:registerEvents()
end

function UISharePanel:finalize()
    self._uiSkin:finalize()
end

--_fx   x偏移量 默认0
--_fy   y偏移量 默认0
function UISharePanel:showPanel(sender, data, _fx, _fy )
    self._uiSkin:setVisible(true)
    self._data = data
    
    local sharePanel = self:getChildByName("sharePanel")
    self.sharePanel = sharePanel
    local worldPosition = sender:getWorldPosition()
    local curPos = self._uiSkin.root:convertToNodeSpace(worldPosition)
    
    local size = sharePanel:getContentSize()
    local senderSize = sender:getContentSize()
    
    local y = 0
    if curPos.y > 480 then
        y = curPos.y - size.height - senderSize.height / 2 - 5
    else
        y = curPos.y + senderSize.height / 2 + 5
    end
    local x = 0
    if curPos.x > 320 then
        x = curPos.x - size.width
    else
        x = curPos.x
    end
    
    if self._isTurnUp then
        y = y-size.height-senderSize.height
    end

    _fx = _fx or 0
    _fy = _fy or 0
    sharePanel:setPosition(x - 85 + _fx, y + _fy)
end

-- 从下方出现的分享界面
function UISharePanel:rotationPanel()
    local sharePanel = self:getChildByName("sharePanel")
    sharePanel:setRotation(180)
    local worldBtn = self:getChildByName("sharePanel/worldBtn")
    local legionBtn = self:getChildByName("sharePanel/legionBtn")
    worldBtn:setRotation(180)
    legionBtn:setRotation(180)
    
end

function UISharePanel:setSharePanelPos(pos)
    local sharePanel = self:getChildByName("sharePanel")
    sharePanel:setPosition(pos)
end


function UISharePanel:hidePanel()
    self._uiSkin:setVisible(false)
end

function UISharePanel:registerEvents()
    local worldBtn = self:getChildByName("sharePanel/worldBtn")
    local legionBtn = self:getChildByName("sharePanel/legionBtn")
    
    worldBtn.shareType = 1
    legionBtn.shareType = 2
    
    ComponentUtils:addTouchEventListener(worldBtn,self.onShareBtnTouch,nil,self)
    ComponentUtils:addTouchEventListener(legionBtn,self.onShareBtnTouch,nil,self)
    
    ComponentUtils:addTouchEventListener(self._uiSkin:getRootNode(),self.onHideTouch,nil,self)
end

function UISharePanel:onShareBtnTouch(sender)
    local reqData = self._data
    reqData.shareType = sender.shareType

    self._shareProxy:shareInfoReq(reqData)
    
    self:onHideTouch()
end

function UISharePanel:onHideTouch(sender)
    self:hidePanel()
end

function UISharePanel:isVisible()
    return self._uiSkin:isVisible()
end

function UISharePanel:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UISharePanel:getSharePanel()
    -- body
    return self.sharePanel
end

function UISharePanel:setTurnTo( _isTurnUp )
    self._isTurnUp = _isTurnUp
    local bg = self:getChildByName("sharePanel/Image_34")
    if self._isTurnUp then
        bg:setScaleY( -1 )
    else
        bg:setScaleY( 1 )
    end
end

