local GuideAction2251 = class( "GuideAction101", AreaClickAction)
function GuideAction2251:ctor(guide)
    GuideAction2251.super.ctor(self)

    self.info = "选择一个空地建造资源点"
    self.moduleName = ModuleName.MainSceneModule
    self.panelName = "MainScenePanel"
    self.widgetName = "buildingPos12"  --这里的12跟下面的12一致

    local panel = guide:getPanel(self.moduleName, self.panelName)
    local index = panel:getOneOfAllLand(12)  ----这里的12跟上面的12一致
    self.widgetName = string.format("buildingPos%d",index)
end

function GuideAction2251:onEnter(guide)
    GuideAction2251.super.onEnter(self, guide)
end

return GuideAction2251