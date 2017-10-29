local GuideAction408 = class("GuideAction408", AreaClickAction)

function GuideAction408:ctor()
    GuideAction408.super.ctor(self)
    
    self.info = "征召10只刀兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "_btnRecruit"
    self.isShowArrow = false
end

function GuideAction408:onEnter(guide)
    GuideAction408.super.onEnter(self, guide)
end

return GuideAction408