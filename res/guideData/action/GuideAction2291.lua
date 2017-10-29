local GuideAction2291 = class( "GuideAction101", AreaClickAction)
function GuideAction2291:ctor(guide)
    GuideAction2291.super.ctor(self)

    self.info = "选择一个空地建造资源点"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPos1"
    
    local panel = guide:getPanel(self.moduleName, self.panelName)
    local index = panel:getOneOfAllLand2()  ----这里的12跟上面的12一致
    self.widgetName = string.format("buildingPos%d",index)
end

function GuideAction2291:onEnter(guide)
    GuideAction2291.super.onEnter(self, guide)
end

return GuideAction2291