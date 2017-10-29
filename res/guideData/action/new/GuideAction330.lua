local GuideAction330 = class("GuideAction330", AreaClickAction)

function GuideAction330:ctor()
    GuideAction330.super.ctor(self)
    
    self.info = "点击一号位"
    self.moduleName = ModuleName.HeroModule
    self.panelName = "HeroPanel"
    self.widgetName = "btnItem1" --
end

function GuideAction330:onEnter(guide)
    GuideAction330.super.onEnter(self, guide)
    
end

return GuideAction330