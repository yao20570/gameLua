local GuideAction424 = class("GuideAction424", AreaClickAction)

function GuideAction424:ctor()
    GuideAction424.super.ctor(self)
    
    self.info = "升级官邸"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "quickBtn"
    self.isShowArrow = false
--    self.callbackArg = true
end

function GuideAction424:onEnter(guide)
    GuideAction424.super.onEnter(self, guide)
    
end

return GuideAction424