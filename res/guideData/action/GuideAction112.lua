local GuideAction112 = class("GuideAction112", AreaClickAction)

function GuideAction112:ctor()
    GuideAction112.super.ctor(self)
    
    self.info = "试试提升了统率、战法的威力"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city3"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction112:onEnter(guide)
    GuideAction112.super.onEnter(self, guide)
end

return GuideAction112