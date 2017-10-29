local GuideAction2261 = class( "GuideAction101", AreaClickAction)
function GuideAction2261:ctor(guide)
    GuideAction2261.super.ctor(self)

    self.info = "选择一个空地建造资源点"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPos1"
    
    local panel = guide:getPanel(self.moduleName, self.panelName)
    local index = panel:getOneOfAllLand(1)  ----这里的12跟上面的12一致
    self.widgetName = string.format("buildingPos%d",index)
end

function GuideAction2261:onEnter(guide)
    GuideAction2261.super.onEnter(self, guide)
end

return GuideAction2261