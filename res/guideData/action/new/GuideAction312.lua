local GuideAction312 = class("GuideAction312", AreaClickAction)

function GuideAction312:ctor()
    GuideAction312.super.ctor(self)
    
    self.info = "前往世界"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "sceneBtn"
    
    self.isShowArrow = false

end

function GuideAction312:onEnter(guide)
    GuideAction312.super.onEnter(self, guide)

    local mapPanel = guide:getPanel(ModuleName.MapModule, MapPanel.NAME)
    local banditDungeonProxy = guide:getProxy(GameProxys.BanditDungeon)
    local x, y = banditDungeonProxy:getOneBanditPosition()
    mapPanel._worldMap:gotoTileXY(x, y)  --开挂代码，勿仿！

end



return GuideAction312