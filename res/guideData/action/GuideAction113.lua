local GuideAction113 = class("GuideAction113", AreaClickAction)

function GuideAction113:ctor()
    GuideAction113.super.ctor(self)
    
    self.info = "再下一城，可以获得更多奖励！"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city4"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction113:onEnter(guide)
    GuideAction113.super.onEnter(self, guide)
end

return GuideAction113