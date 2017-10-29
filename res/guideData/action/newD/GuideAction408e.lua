local GuideAction408e = class("GuideAction408e", AreaClickAction)

function GuideAction408e:ctor()
    GuideAction408e.super.ctor(self)
    
    self.info = "征召20只刀兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "_btnRecruit"
    self.isShowArrow = false
end

function GuideAction408e:onEnter(guide)
    GuideAction408e.super.onEnter(self, guide)
end

return GuideAction408e