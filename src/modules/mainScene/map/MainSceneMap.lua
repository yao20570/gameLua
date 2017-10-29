--主场景地图

MainSceneMap = class("MainSceneMap",SceneMap)

function MainSceneMap:ctor(panel)
    MainSceneMap.super.ctor(self, panel)

    self.url = "bg/scene/1_%02d"  .. ".pvr.ccz"
end