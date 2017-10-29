local GuideAction119 = class("GuideAction119", AreaClickAction)

function GuideAction119:ctor()
    GuideAction119.super.ctor(self)
    
    self.info = "摧毁敌军，缴获军资训练步兵"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city6"
    self.delayTimePre = 0.3
    
    self.callbackArg = true
    self.isShowArrow = false
    
end

function GuideAction119:onEnter(guide)
    GuideAction119.super.onEnter(self, guide)
end

return GuideAction119