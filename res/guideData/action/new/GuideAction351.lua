local GuideAction351 = class("GuideAction351", AreaClickAction)

function GuideAction351:ctor()
    GuideAction351.super.ctor(self)
    
    self.info = "加速征召"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "RecruitingPanel"
    self.widgetName = "quickBtn1"

    self.callbackArg = true
end

function GuideAction351:onEnter(guide)
    GuideAction351.super.onEnter(self, guide)
    
end

return GuideAction351