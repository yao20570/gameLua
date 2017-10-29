local GuideAction407e = class("GuideAction407e", AreaClickAction)

function GuideAction407e:ctor()
    GuideAction407e.super.ctor(self)
    
    self.info = "征召刀兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "_guideDao"
    self.isShowArrow = false

    self.callbackArg = 20
end

function GuideAction407e:onEnter(guide)
    GuideAction407e.super.onEnter(self, guide)
end

return GuideAction407e