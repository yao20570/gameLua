local GuideAction451 = class("GuideAction451", AreaClickAction)

function GuideAction451:ctor()
    GuideAction451.super.ctor(self)
    
    self.info = "加速征召"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "RecruitingPanel"
    self.widgetName = "quickBtn1"

    self.callbackArg = true
end

function GuideAction451:onEnter(guide)
    GuideAction451.super.onEnter(self, guide)
    
end

return GuideAction451