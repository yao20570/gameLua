
LordCityPanel = class("LordCityPanel", BasicPanel)
LordCityPanel.NAME = "LordCityPanel"

function LordCityPanel:ctor(view, panelName)
    LordCityPanel.super.ctor(self, view, panelName)

end

function LordCityPanel:finalize()
    LordCityPanel.super.finalize(self)
end

function LordCityPanel:initPanel()
	LordCityPanel.super.initPanel(self)

	local panel = self:getPanel(LordCityMainPanel.NAME)
	panel:show()
end

function LordCityPanel:registerEvents()
	LordCityPanel.super.registerEvents(self)
end

