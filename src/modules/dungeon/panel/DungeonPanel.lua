
DungeonPanel = class("DungeonPanel", BasicPanel)
DungeonPanel.NAME = "DungeonPanel"

function DungeonPanel:ctor(view, panelName)
    DungeonPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function DungeonPanel:finalize()
    DungeonPanel.super.finalize(self)
end

function DungeonPanel:initPanel()
	DungeonPanel.super.initPanel(self)
end