local GuideAction354 = class("GuideAction354", AreaClickAction)

function GuideAction354:ctor()
    GuideAction354.super.ctor(self)
    
    self.info = "上阵武将"
    self.moduleName = ModuleName.HeroModule
    self.panelName = "HeroPanel"
    self.widgetName = "trainBtn2" --上阵
    self.delayTime = 1.5 -- 延迟2秒
end

function GuideAction354:onEnter(guide)
    GuideAction354.super.onEnter(self, guide)
    
end

return GuideAction354