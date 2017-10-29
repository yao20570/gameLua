local GuideAction356 = class("GuideAction356", AreaClickAction)

function GuideAction356:ctor()
    GuideAction356.super.ctor(self)
    
    self.info = "点击上阵按钮"
    self.moduleName = ModuleName.HeroModule
    self.panelName = "HeroPanel"
    self.widgetName = "trainBtn3" --上阵
    self.delayTime = 1.5
end

function GuideAction356:onEnter(guide)
    GuideAction356.super.onEnter(self, guide)
    
end

return GuideAction356