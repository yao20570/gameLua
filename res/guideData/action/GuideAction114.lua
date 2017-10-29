local GuideAction114 = class("GuideAction114", DialogueAction)

function GuideAction114:ctor()
    GuideAction114.super.ctor(self)
    
    self.info = "恭喜主公，开启装备功能！"  --
    self.openIconName = "Icon_Generals_none"

    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city5"
end

function GuideAction114:onEnter(guide)
    GuideAction114.super.onEnter(self, guide)
    
end

function GuideAction114:callback()
    GuideAction114.super.callback(self)
    self._guide:hideModule(ModuleName.DungeonModule)
end

return GuideAction114