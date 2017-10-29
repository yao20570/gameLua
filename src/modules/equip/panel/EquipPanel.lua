
EquipPanel = class("EquipPanel", BasicPanel)
EquipPanel.NAME = "EquipPanel"

function EquipPanel:ctor(view, panelName)
    EquipPanel.super.ctor(self, view, panelName,true)

end

function EquipPanel:finalize()
    EquipPanel.super.finalize(self)
end

function EquipPanel:initPanel()
	EquipPanel.super.initPanel(self)
end

function EquipPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end