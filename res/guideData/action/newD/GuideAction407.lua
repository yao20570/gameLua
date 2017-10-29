local GuideAction407 = class("GuideAction407", AreaClickAction)

function GuideAction407:ctor()
    GuideAction407.super.ctor(self)
    
    self.info = "征召刀兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "_guideDao"
    self.isShowArrow = false

    self.callbackArg = 20
end

function GuideAction407:onEnter(guide)
    GuideAction407.super.onEnter(self, guide)
end

return GuideAction407