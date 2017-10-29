local GuideAction499 = class("GuideAction499", AreaClickAction)

function GuideAction499:ctor()
    GuideAction499.super.ctor(self)
    
    self.info = "回城"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "sceneBtn"
    
    self.isShowArrow = false
end

function GuideAction499:onEnter(guide)
    GuideAction499.super.onEnter(self, guide)
end


return GuideAction499