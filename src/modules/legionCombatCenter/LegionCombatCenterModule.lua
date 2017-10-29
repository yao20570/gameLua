
LegionCombatCenterModule = class("LegionCombatCenterModule", BasicModule)

function LegionCombatCenterModule:ctor()
    LegionCombatCenterModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionCombatCenterModule:initRequire()
    require("modules.legionCombatCenter.event.LegionCombatCenterEvent")
    require("modules.legionCombatCenter.view.LegionCombatCenterView")
end

function LegionCombatCenterModule:finalize()
    LegionCombatCenterModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionCombatCenterModule:initModule()
    LegionCombatCenterModule.super.initModule(self)
    self._view = LegionCombatCenterView.new(self.parent)

    self:addEventHandler()
end

function LegionCombatCenterModule:addEventHandler()
    self._view:addEventListener(LegionCombatCenterEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionCombatCenterEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_CHAPTER_UPDATE, self, self.onChapterUpdate)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_BATTLEACTIVITY_UPDATE_LISTVIEW, self, self.newBattleActivity)
end

function LegionCombatCenterModule:removeEventHander()
    self._view:removeEventListener(LegionCombatCenterEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionCombatCenterEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_CHAPTER_UPDATE, self, self.onChapterUpdate)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_BATTLEACTIVITY_UPDATE_LISTVIEW, self, self.newBattleActivity)
end

function LegionCombatCenterModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionCombatCenterModule:onShowOtherHandler(data)
    local moduleMap = {}

    moduleMap.moduleName = data.moduleName
    moduleMap.extraMsg = {info = data.info}
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, moduleMap)
end

-- 每次从onShowOtherHandler过来都走这条
function LegionCombatCenterModule:onOpenModule()
    LegionCombatCenterModule.super.onOpenModule(self)
    self._view:setFirstPanelShow()
    self._view:isShowActivityTab()

    -- 每次打开都请求270000，有变化才就发过来更新
    local dungeonXProxy = self:getProxy(GameProxys.DungeonX)
    dungeonXProxy:onTriggerNet270000Req({})
end

-- 章节信息更新，
function LegionCombatCenterModule:onChapterUpdate()
    -- body
    self._view:onChapterUpdate()
end

function LegionCombatCenterModule:newBattleActivity()
    self._view:newBattleActivity()
end


