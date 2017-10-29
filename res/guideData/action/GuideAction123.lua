local GuideAction123 = class("GuideAction123", AreaClickAction)

function GuideAction123:ctor()
    GuideAction123.super.ctor(self)
    
    self.info = "兵营可征召步、骑、枪、弓四类兵种"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "itemPanel1"
    self.isShowArrow = false
end

function GuideAction123:onEnter(guide)
    GuideAction123.super.onEnter(self, guide)
end

return GuideAction123