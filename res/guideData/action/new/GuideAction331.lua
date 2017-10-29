local GuideAction331 = class("GuideAction331", AreaClickAction)

function GuideAction331:ctor()
    GuideAction331.super.ctor(self)
    
    self.info = "上阵武将"
    self.moduleName = ModuleName.HeroModule
    self.panelName = "HeroPanel"
    self.widgetName = "trainBtn1" --上阵
    self.delayTime = 2 
    -- self.delayTimePre = 2 -- 延迟1秒
    -- self.delayNextActionTime = 2
end

function GuideAction331:onEnter(guide)
    GuideAction331.super.onEnter(self, guide)
    
end

return GuideAction331