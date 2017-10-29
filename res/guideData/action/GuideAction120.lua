local GuideAction120 = class("GuideAction120", DialogueAction)

function GuideAction120:ctor()
    GuideAction120.super.ctor(self)
    
    self.info = "缴获军资，征召士兵"  --
    self.openIconName = "Icon_train"

    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city7"
end

function GuideAction120:onEnter(guide)
    GuideAction120.super.onEnter(self, guide)
    
end

function GuideAction120:callback()
    GuideAction120.super.callback(self)
    self._guide:hideModule(ModuleName.DungeonModule)
end

return GuideAction120