local GuideAction117 = class("GuideAction117", AreaClickAction)

function GuideAction117:ctor()
    GuideAction117.super.ctor(self)
    
    self.info = "试试武将的威力"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction117:onEnter(guide)
    GuideAction117.super.onEnter(self, guide)
    local panel = guide:getPanel(ModuleName.EquipModule,"EquipMainPanelNewPanel")
    panel:hide()
    guide:hideModule(ModuleName.EquipModule)
end

return GuideAction117