local GuideAction411 = class("GuideAction411", AreaClickAction)

function GuideAction411:ctor()
    GuideAction411.super.ctor(self)
    
    self.info = "离开兵营"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "closeBtn"
    self.isShowArrow = false
end

function GuideAction411:onEnter(guide)
    GuideAction411.super.onEnter(self, guide)
end

return GuideAction411