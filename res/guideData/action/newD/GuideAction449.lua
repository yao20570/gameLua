local GuideAction449 = class("GuideAction449", AreaClickAction)

function GuideAction449:ctor()
    GuideAction449.super.ctor(self)
    
    self.info = "点击骑兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "_guideQi"

    --self.callbackArg = 40 
end

function GuideAction449:onEnter(guide)
    GuideAction449.super.onEnter(self, guide)
    
end

return GuideAction449