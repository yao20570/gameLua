
ActivationPanel = class("ActivationPanel", BasicPanel)
ActivationPanel.NAME = "ActivationPanel"

function ActivationPanel:ctor(view, panelName)
    ActivationPanel.super.ctor(self, view, panelName, 320)

end

function ActivationPanel:finalize()
    ActivationPanel.super.finalize(self)
end

function ActivationPanel:initPanel()
	ActivationPanel.super.initPanel(self)

	local inputPanel = self:getChildByName("mainPanel/inputPanel")
    self._editBox = ComponentUtils:addEditeBox(inputPanel, 20, self:getTextWord(207), nil, false, "images/login/Bg_activate.png")

    local Image_8 = self:getChildByName("mainPanel/Image_8")
    TextureManager:updateImageView(Image_8, "images/newGui9Scale/Frame_item_bg.png")

    self:setTitle(true, self:getTextWord(208))
end

function ActivationPanel:registerEvents()
	ActivationPanel.super.registerEvents(self)

    local activateBtn = self:getChildByName("mainPanel/activateBtn")
    self:addTouchEventListener(activateBtn, self.onActivateBtnTouch)
end

function ActivationPanel:onActivateBtnTouch(sender)
    --点击激活

    local code = self._editBox:getText()
    if code == "" then
        self:showSysMessage(self:getTextWord(209))
        return
    end

    self:dispatchEvent(LoginEvent.ACTIVATE_REQ, {code = code})

end

