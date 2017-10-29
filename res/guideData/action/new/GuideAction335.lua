local GuideAction335 = class("GuideAction335", AreaClickAction)

function GuideAction335:ctor()
    GuideAction335.super.ctor(self)
    
    self.info = "进入第一章"
    self.moduleName = ModuleName.RegionModule
    self.panelName = "CenterRegionPanel"
    self.widgetName = "panel101"
    
    self.isShowArrow = false
end

function GuideAction335:onEnter(guide)
    GuideAction335.super.onEnter(self, guide)
end

return GuideAction335