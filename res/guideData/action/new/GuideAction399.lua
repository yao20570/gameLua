local GuideAction312 = class("GuideAction312", AreaClickAction)

function GuideAction312:ctor()
    GuideAction312.super.ctor(self)
    
    self.info = "回城"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "sceneBtn"
    
    self.isShowArrow = false
end

function GuideAction312:onEnter(guide)
    GuideAction312.super.onEnter(self, guide)
end


return GuideAction312