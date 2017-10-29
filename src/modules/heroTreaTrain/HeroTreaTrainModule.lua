-- /**
--  * @DateTime:    2016-10-09 
--  * @Description: 宝具模块(宝具培养)
--  * @Author: lizhuojian
--  */
HeroTreaTrainModule = class("HeroTreaTrainModule", BasicModule)

function HeroTreaTrainModule:ctor()
    HeroTreaTrainModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.Animation
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function HeroTreaTrainModule:initRequire()
    require("modules.heroTreaTrain.event.HeroTreaTrainEvent")
    require("modules.heroTreaTrain.view.HeroTreaTrainView")
end

function HeroTreaTrainModule:finalize()
    HeroTreaTrainModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function HeroTreaTrainModule:initModule()
    HeroTreaTrainModule.super.initModule(self)
    self._view = HeroTreaTrainView.new(self.parent)

    self:addEventHandler()
end

function HeroTreaTrainModule:addEventHandler()
    self._view:addEventListener(HeroTreaTrainEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(HeroTreaTrainEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --20007宝具信息刷新
    self:addProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_UPDATE_INFO, self, self.treasureInfoChange)
   --20007刷新（进阶槽位）
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_TREASURE_POSTINFOS_UPDATE, self, self.postInfoChange)
    --M300006返回（进阶槽位成功）
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_TREASURE_ADVANCE_SUCCESS, self, self.advanceSuccessHandler)
    --M300006返回（进阶槽位失败）
    self:addProxyEventListener(GameProxys.Hero, AppEvent.PROXY_TREASURE_ADVANCE_FAIL, self, self.advanceFailHandler)
    --350000洗炼成功通知
    self:addProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_PURIFY_SUCCESS, self, self.purifySuccessHandler)

end

function HeroTreaTrainModule:removeEventHander()
    self._view:removeEventListener(HeroTreaTrainEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(HeroTreaTrainEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_UPDATE_INFO, self, self.treasureInfoChange)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_TREASURE_POSTINFOS_UPDATE, self, self.postInfoChange)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_TREASURE_ADVANCE_SUCCESS, self, self.advanceSuccessHandler)

    self:removeProxyEventListener(GameProxys.Hero, AppEvent.PROXY_TREASURE_ADVANCE_FAIL, self, self.advanceFailHandler)

    self:removeProxyEventListener(GameProxys.HeroTreasure, AppEvent.PROXY_TREASURE_PURIFY_SUCCESS, self, self.purifySuccessHandler)

  
end

function HeroTreaTrainModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function HeroTreaTrainModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
--宝具信息刷新
function HeroTreaTrainModule:treasureInfoChange()
    self._view:treasureInfoChange()
end
--信息槽位刷新
function HeroTreaTrainModule:postInfoChange()
    self._view:postInfoChange()
end
--洗炼成功
function HeroTreaTrainModule:purifySuccessHandler()
    self._view:purifySuccessHandler()
end
--进阶成功返回
function HeroTreaTrainModule:advanceSuccessHandler(time)
    self._view:advanceSuccessHandler(time)
end
--进阶失败返回
function HeroTreaTrainModule:advanceFailHandler(data)
    self._view:advanceFailHandler(data)
end


function HeroTreaTrainModule:onOpenModule(extraMsg)
    HeroTreaTrainModule.super.onOpenModule(self,extraMsg)
    self._view:saveCurTreasureData(extraMsg)
end

function HeroTreaTrainModule:onHideModule()
    EffectQueueManager:removeEffectByType(EffectQueueType.TREASURE_ADVANCE)
end
