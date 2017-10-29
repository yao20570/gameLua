local GuideAction355 = class("GuideAction355", AreaClickAction)

function GuideAction355:ctor()
    GuideAction355.super.ctor(self)
    
    self.info = "点击三号槽位"
    self.moduleName = ModuleName.HeroModule
    self.panelName = "HeroPanel"
    self.widgetName = "btnItem3" --
    -- self.delayTime = 2 -- 延迟2秒
end

function GuideAction355:onEnter(guide)
    GuideAction355.super.onEnter(self, guide)
    
end

return GuideAction355