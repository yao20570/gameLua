local GuideAction122 = class("GuideAction122", AreaClickAction)

function GuideAction122:ctor()
    GuideAction122.super.ctor(self)
    
    self.info = "点击招兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "tabBtn2"
    self.isShowArrow = false
end

function GuideAction122:onEnter(guide)
    GuideAction122.super.onEnter(self, guide)
end

return GuideAction122