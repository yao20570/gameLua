local GuideAction316 = class("GuideAction316", AreaClickAction)

function GuideAction316:ctor()
    GuideAction316.super.ctor(self)
    
    self.info = "开始讨伐"
    self.moduleName = ModuleName.MapModule
    self.panelName = "BanditPanel"
    self.widgetName = "fightBtn"
    
end

function GuideAction316:onEnter(guide)
    GuideAction316.super.onEnter(self, guide)
end

return GuideAction316