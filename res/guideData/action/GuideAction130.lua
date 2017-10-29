local GuideAction129 = class("GuideAction129", AreaClickAction)

function GuideAction129:ctor()
    GuideAction129.super.ctor(self)
    self.delayTimePre = 3
    self.info = "战绩不错，回营发展"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "exitBtn"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction129:onEnter(guide)
    GuideAction129.super.onEnter(self, guide)
    guide:hideModule(ModuleName.TaskModule)
end

return GuideAction129