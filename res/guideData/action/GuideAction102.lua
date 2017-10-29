local GuideAction102 = class("GuideAction101", AreaClickAction)

function GuideAction102:ctor()
    GuideAction102.super.ctor(self)
    
    self.info = "让臣妾辅助主公战斗吧！"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city1"
    
    self.callbackArg = false
    
    self.isShowArrow = false
end

function GuideAction102:onEnter(guide)
    GuideAction102.super.onEnter(self, guide)
end

return GuideAction102