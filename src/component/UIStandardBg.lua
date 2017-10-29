UIStandardBg = class("UIStandardBg")

function UIStandardBg:ctor(panel,upWidget,downWidget)
    local uiSkin = UISkin.new("UIStandardBg")
    local root = panel:getPanelRoot()
    uiSkin:setParent(root)
    self._bg = uiSkin:getChildByName("Bg")

    uiSkin:setTouchEnabled(false)
    self._uiSkin = uiSkin
    
    self._panel = panel
    self._bg = uiSkin:getChildByName("Bg")
    self._defaultSize = self._bg:getContentSize()
    self:setDownOffset(upWidget,downWidget)
end

--设置背景的相对于下面的偏移量
function UIStandardBg:setDownOffset(upWidget,downWidget)
    local scale = 1 / NodeUtils:getAdaptiveScale()

    local upWorldPos
    local upSize
    if type(upWidget) == type(0) then
        upWorldPos = cc.p(0, upWidget)
        upSize = cc.size(0,0)
    else
        upWorldPos = upWidget:getWorldPosition()
        upSize = upWidget:getContentSize()
    end

    local posY

    local downWorldPos = 0
    local downSize = nil
    if type(downWidget) == type(0) then
        downWorldPos = cc.p(0, downWidget)
        downSize = cc.size(0,0)
        posY = downWidget
    else
        downWorldPos = downWidget:getWorldPosition()
        downSize = downWidget:getContentSize()
        local y = downWidget:getAnchorPoint().y
        if y >= 0.5 then
            posY = downWidget:getPositionY() + downSize.height * scale / 2
        else
            posY = downWidget:getPositionY() + downSize.height * scale
        end
    end

    local skinHeight = upWorldPos.y -  downWorldPos.y - downSize.height
    local skinRoot = self._uiSkin:getRootNode()
    skinRoot:setContentSize(self._uiSkin:getContentSize().width, skinHeight)
    skinRoot:setPosition(0 , posY)
end

function UIStandardBg:setLocalZOrder(zOrder)
    self._uiSkin:setLocalZOrder(zOrder)
end

function UIStandardBg:getLocalZOrder()
    return self._uiSkin:getLocalZOrder()
end











