local GuideAction431 = class("GuideAction431", AreaClickAction)

function GuideAction431:ctor()
    GuideAction431.super.ctor(self)
    
    self.info = "上阵武将"
    self.moduleName = ModuleName.HeroModule
    self.panelName = "HeroPanel"
    self.widgetName = "trainBtn1" --上阵
    self.delayTime = 2 
    -- self.delayTimePre = 2 -- 延迟1秒
    -- self.delayNextActionTime = 2
end

function GuideAction431:onEnter(guide)
    GuideAction431.super.onEnter(self, guide)
    
end

return GuideAction431