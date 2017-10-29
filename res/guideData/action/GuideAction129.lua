local GuideAction129 = class("GuideAction129", AreaClickAction)

function GuideAction129:ctor()
    GuideAction129.super.ctor(self)
    
    self.info = "用压倒性的步兵数量压碾他们"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city7"
    
    self.callbackArg = true
    self.isShowArrow = false
    
end

function GuideAction129:onEnter(guide)
    GuideAction129.super.onEnter(self, guide)
end

return GuideAction129