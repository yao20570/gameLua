local GuideAction416 = class("GuideAction416", AreaClickAction)

function GuideAction416:ctor()
    GuideAction416.super.ctor(self)
    
    self.info = "开始讨伐"
    self.moduleName = ModuleName.MapModule
    self.panelName = "BanditPanel"
    self.widgetName = "fightBtn"
    
end

function GuideAction416:onEnter(guide)
    GuideAction416.super.onEnter(self, guide)
end

return GuideAction416