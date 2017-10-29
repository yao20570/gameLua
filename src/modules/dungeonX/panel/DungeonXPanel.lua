
DungeonXPanel = class("DungeonXPanel", BasicPanel)
DungeonXPanel.NAME = "DungeonXPanel"

function DungeonXPanel:ctor(view, panelName)
    DungeonXPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function DungeonXPanel:finalize()
    DungeonXPanel.super.finalize(self)
end

function DungeonXPanel:initPanel()
	DungeonXPanel.super.initPanel(self)
end

function DungeonXPanel:registerEvents()
	DungeonXPanel.super.registerEvents(self)
end