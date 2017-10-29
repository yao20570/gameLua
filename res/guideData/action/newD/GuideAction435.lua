local GuideAction435 = class("GuideAction435", AreaClickAction)

function GuideAction435:ctor()
    GuideAction435.super.ctor(self)
    
    self.info = "进入第一章"
    self.moduleName = ModuleName.RegionModule
    self.panelName = "CenterRegionPanel"
    self.widgetName = "panel101"
    
    self.isShowArrow = false
end

function GuideAction435:onEnter(guide)
    GuideAction435.super.onEnter(self, guide)
end

return GuideAction435