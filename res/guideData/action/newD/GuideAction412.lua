local GuideAction412 = class("GuideAction412", AreaClickAction)

function GuideAction412:ctor()
    GuideAction412.super.ctor(self)
    
    self.info = "前往世界"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "sceneBtn"
    
    self.isShowArrow = false

end

function GuideAction412:onEnter(guide)
    self._guide = guide
    local mapModule = guide:getModule(ModuleName.MapModule)
    if mapModule ~= nil and mapModule:isVisible() then  --在世界里面的，直接跳过了
        self._isSkipAction = true
    else
         GuideAction412.super.onEnter(self, guide)
    end
    local mapPanel = guide:getPanel(ModuleName.MapModule, "MapPanel")
    if mapPanel == nil then
        return
    end
    local banditDungeonProxy = guide:getProxy(GameProxys.BanditDungeon)
    local x, y = banditDungeonProxy:getOneBanditPosition()
    mapPanel._worldMap:gotoTileXY(x, y)  --开挂代码，勿仿！

    if self._isSkipAction then
        self:delayNextAction()
    end

end

function GuideAction412:delayNextAction()
    -- print("~~~~~~~delayNextAction()~~~~~~~~~", self._isSkipAction)
    if self._isSkipAction == true then
        self._guide:skipAction()
    else
        self:nextAction()
    end
end



return GuideAction412