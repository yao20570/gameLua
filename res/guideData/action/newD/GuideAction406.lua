local GuideAction406 = class("GuideAction406", AreaClickAction)

function GuideAction406:ctor()
    GuideAction406.super.ctor(self)
    
    self.info = "前往招兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "tabBtn2"
    self.isShowArrow = false

    self.callbackArg = 10
end

function GuideAction406:onEnter(guide)
    GuideAction406.super.onEnter(self, guide)
end

return GuideAction406