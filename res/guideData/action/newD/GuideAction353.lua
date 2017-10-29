local GuideAction353 = class("GuideAction353", AreaClickAction)

function GuideAction353:ctor()
    GuideAction353.super.ctor(self)
    
    self.info = "点击二号槽位"
    self.moduleName = ModuleName.HeroModule
    self.panelName = "HeroPanel"
    self.widgetName = "btnItem2" --
    -- self.delayTimePre = 2 -- 延迟1秒
    -- self.delayNextActionTime = 2
end

function GuideAction353:onEnter(guide)
    GuideAction353.super.onEnter(self, guide)
    
end

return GuideAction353