local GuideAction126 = class("GuideAction126", AreaClickAction)

function GuideAction126:ctor()
    GuideAction126.super.ctor(self)
    
    self.info = "要快，敌军来了"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "RecruitingPanel"
    self.widgetName = "boxOkBtn"
    self.isShowArrow = false
    
end

function GuideAction126:onEnter(guide)
    GuideAction126.super.onEnter(self, guide)
end

return GuideAction126