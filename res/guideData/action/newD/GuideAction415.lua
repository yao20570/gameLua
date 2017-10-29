local GuideAction415 = class("GuideAction415", AreaClickAction)

function GuideAction415:ctor()
    GuideAction415.super.ctor(self)
    
    self.info = "点击"
    self.moduleName = ModuleName.MapModule
    self.panelName = "BanditPanel"
    self.widgetName = "maxFightBtn"
    self.delayTime = 0.5 
    
end

function GuideAction415:onEnter(guide)
    GuideAction415.super.onEnter(self, guide)
end

return GuideAction415