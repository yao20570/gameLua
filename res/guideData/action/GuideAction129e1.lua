local GuideAction129 = class("GuideAction129", AreaClickAction)

function GuideAction129:ctor()
    GuideAction129.super.ctor(self)
    
    self.info = "张角善于弓兵，我们用步兵克制它"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city8"
    
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction129:onEnter(guide)
    GuideAction129.super.onEnter(self, guide)
end

return GuideAction129