local GuideAction129 = class("GuideAction129", AreaClickAction)

function GuideAction129:ctor()
    GuideAction129.super.ctor(self)
    
    self.info = "再下一城，继续摧毁黄巾贼的弓兵"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city9"
    
    self.callbackArg = true
    self.isShowArrow = false
    
end

function GuideAction129:onEnter(guide)
    GuideAction129.super.onEnter(self, guide)
end

return GuideAction129