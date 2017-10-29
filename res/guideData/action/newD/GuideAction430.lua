local GuideAction430 = class("GuideAction430", AreaClickAction)

function GuideAction430:ctor()
    GuideAction430.super.ctor(self)
    
    self.info = "点击一号位"
    self.moduleName = ModuleName.HeroModule
    self.panelName = "HeroPanel"
    self.widgetName = "btnItem1" --
end

function GuideAction430:onEnter(guide)
    GuideAction430.super.onEnter(self, guide)
    
end

return GuideAction430