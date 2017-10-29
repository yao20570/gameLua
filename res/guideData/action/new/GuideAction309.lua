local GuideAction309 = class("GuideAction309", AreaClickAction)

function GuideAction309:ctor()
    GuideAction309.super.ctor(self)
    
    self.info = "加速征召，立即获得"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "RecruitingPanel"
    self.widgetName = "quickBtn1"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction309:onEnter(guide)
    GuideAction309.super.onEnter(self, guide)
end

return GuideAction309