local GuideAction310 = class("GuideAction310", AreaClickAction)

function GuideAction310:ctor()
    GuideAction310.super.ctor(self)
    
    self.info = "确定加速"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "RecruitingPanel"
    self.widgetName = "boxOkBtn"
    self.isShowArrow = false
    
end

function GuideAction310:onEnter(guide)
    GuideAction310.super.onEnter(self, guide)
end

return GuideAction310