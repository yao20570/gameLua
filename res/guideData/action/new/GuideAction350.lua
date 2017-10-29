local GuideAction350 = class("GuideAction350", AreaClickAction)

function GuideAction350:ctor()
    GuideAction350.super.ctor(self)
    
    self.info = "开始征召"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackProductPanel"
    self.widgetName = "sureBtn"
end

function GuideAction350:onEnter(guide)
    GuideAction350.super.onEnter(self, guide)
    
end

return GuideAction350