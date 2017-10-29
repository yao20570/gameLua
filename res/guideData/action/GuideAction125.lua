local GuideAction125 = class("GuideAction125", AreaClickAction)

function GuideAction125:ctor()
    GuideAction125.super.ctor(self)
    
    self.info = "加速征召，立即获得步兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "RecruitingPanel"
    self.widgetName = "quickBtn1"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction125:onEnter(guide)
    GuideAction125.super.onEnter(self, guide)
end

return GuideAction125