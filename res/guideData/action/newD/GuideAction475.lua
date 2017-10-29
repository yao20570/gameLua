local GuideAction475 = class("GuideAction475", AreaClickAction)

function GuideAction475:ctor()
    GuideAction475.super.ctor(self)
    
    self.info = "战役宝箱"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "boxBtn1"
    
    
end

function GuideAction475:onEnter(guide)
    GuideAction475.super.onEnter(self, guide)
end

return GuideAction475