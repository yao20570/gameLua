---------------------------------------------------------------------
---------------------------------------------------------------------
--UI控件功能：仓库资源道具、建筑资源道具的使用/购买
--Time:2015/12/04
--Author:FZW
---------------------------------------------------------------------
---------------------------------------------------------------------

UIFightDialogPanel = class("UIFightDialogPanel", BasicComponent)

function UIFightDialogPanel:ctor(panel)
    local uiSkin = UISkin.new("UIFightDialogPanel")
    local parent = panel:getParent()
    uiSkin:setParent(parent)
    uiSkin:setLocalZOrder(100)

    self.secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    self.secLvBg:setContentHeight(350)
    self.secLvBg:setBackGroundColorOpacity(120)
    self.secLvBg:setTitle(TextWords:getTextWord(1445))
    
    local mainPanel = uiSkin:getChildByName("mainPanel")
    mainPanel:setLocalZOrder(101)

    self._parent = panel
    self._uiSkin = uiSkin
end

function UIFightDialogPanel:finalize()
    self._uiSkin:finalize()
    UIFightDialogPanel.super.finalize(self)
end

function UIFightDialogPanel:updateData(callback)
    self._uiSkin:setVisible(true)
    self._sureCallback = callback
    
    self._sureBtn = self._uiSkin:getChildByName("mainPanel/sureBtn")
    self._cancelBtn = self._uiSkin:getChildByName("mainPanel/cancelBtn")
    ComponentUtils:addTouchEventListener(self._sureBtn, self.onSureBtnTouch, nil,self)
    ComponentUtils:addTouchEventListener(self._cancelBtn, self.onCancelBtnTouch, nil,self)

    local infoTxt = self._uiSkin:getChildByName("mainPanel/infoTxt")
    local infoTxt3 = self._uiSkin:getChildByName("mainPanel/infoTxt3")
    local checkBox = self._uiSkin:getChildByName("mainPanel/checkBox")
    local infoTxt1 = checkBox:getChildByName("infoTxt1")
    local infoTxt2 = checkBox:getChildByName("infoTxt2")
    self._checkBox = checkBox
    self._checkBox:setSelectedState(false)

    infoTxt:setString(TextWords:getTextWord(1440))
    infoTxt3:setString(TextWords:getTextWord(1441))
    infoTxt1:setString(TextWords:getTextWord(1443))
    infoTxt2:setString(TextWords:getTextWord(1444))
end

function UIFightDialogPanel:onCheckBoxBtnTouch(sender)
end

function UIFightDialogPanel:onSureBtnTouch(sender)
    local oldState = LocalDBManager:getValueForKey("FightResTile",true)
    local newState = self._checkBox:getSelectedState()
    local newState = tostring(newState == true and 0 or 1)
    -- nil 或者 1 为需要弹窗二次确认 , 0为不需要二次确认
    if newState ~= oldstate then
        LocalDBManager:setValueForKey("FightResTile", newState, true)
    end

    -- print("确定 ",newState, oldstate, self._sureCallback)
    if self._sureCallback then
        self._sureCallback(self._parent)
    end
    self:hide()
end

function UIFightDialogPanel:onCancelBtnTouch(sender)
    self:hide()
end

function UIFightDialogPanel:hide()
    self._uiSkin:setVisible(false)
end








