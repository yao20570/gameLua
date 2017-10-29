local GuideAction307 = class("GuideAction307", AreaClickAction)

function GuideAction307:ctor()
    GuideAction307.super.ctor(self)
    
    self.info = "征召步兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "itemPanel1"
    self.isShowArrow = false
end

function GuideAction307:onEnter(guide)
    GuideAction307.super.onEnter(self, guide)
end

return GuideAction307