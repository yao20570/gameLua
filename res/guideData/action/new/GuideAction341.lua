local GuideAction341 = class("GuideAction341", AreaClickAction)

function GuideAction341:ctor()
    GuideAction341.super.ctor(self)
    
    self.info = "挑战关卡三"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city3"
    
    self.callbackArg = true
end

function GuideAction341:onEnter(guide)
    GuideAction341.super.onEnter(self, guide)
end

return GuideAction341