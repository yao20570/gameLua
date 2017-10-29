local GuideAction324 = class("GuideAction324", AreaClickAction)

function GuideAction324:ctor()
    GuideAction324.super.ctor(self)
    
    self.info = "升级官邸"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "BuildingUpPanel"
    self.widgetName = "quickBtn"
    self.isShowArrow = false
--    self.callbackArg = true
end

function GuideAction324:onEnter(guide)
    GuideAction324.super.onEnter(self, guide)
    
end

return GuideAction324