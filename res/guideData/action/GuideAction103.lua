local GuideAction103 = class("GuideAction101", AreaClickAction)

function GuideAction103:ctor()
    GuideAction103.super.ctor(self)
    
    self.info = "开局大胜，再拿下一城可获得弓兵奖励！"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city2"
    self.delayTime = 0.4    
    
    self.callbackArg = false
    self.isShowArrow = false
end

function GuideAction103:onEnter(guide)
    GuideAction103.super.onEnter(self, guide)
end

return GuideAction103