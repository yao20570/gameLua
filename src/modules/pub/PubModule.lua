-- /**
--  * @Description: 酒馆(原来探宝 点兵)模块
--  */
PubModule = class("PubModule", BasicModule)

function PubModule:ctor()
    PubModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function PubModule:initRequire()
    require("modules.pub.event.PubEvent")
    require("modules.pub.view.PubView")
    require("modules.pub.core.RichTextAnimation")
end

function PubModule:finalize()
    PubModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function PubModule:initModule()
    PubModule.super.initModule(self)
    self._view = PubView.new(self.parent)

    self:addEventHandler()
end

function PubModule:addEventHandler()
    self._view:addEventListener(PubEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PubEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)
    -- 硬币数量改变
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_ITEM_COIN_COUNT_UPDATE, self, self.updateTabItemCount)
    --M450000获取酒馆小宴信息成功通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NORINFO_UPDATE, self, self.updateNorInfo)
    --M450001获取酒馆盛宴信息成功通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPEINFO_UPDATE, self, self.updateSpeInfo)
    --M450002购买女儿红成功通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_BUY_NORITEM, self, self.afterBuyNorItem)
    --M450003购买竹叶青成功通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_BUY_SPEITEM, self, self.afterBuySpeItem)
    --M450004小宴单抽（购买）成功通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_ONE_OPEN, self, self.afterOpenOneNor)
    --M450005小宴九抽（购买）成功通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_NINE_OPEN, self, self.afterOpenNineNor)
    --M450006盛宴单抽（购买）成功通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_ONE_OPEN, self, self.afterOpenOneSpe)
    --M450007盛宴九抽
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_NINE_OPEN, self, self.afterOpenNineSpe)
    --M450009小宴界面公告(跑马灯历史数据)
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_HISTORY_UPDATE, self, self.norHistoryUpdate)
    --M450010盛宴界面公告(跑马灯历史数据)
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_HISTORY_UPDATE, self, self.speHistoryUpdate)
    --M450008酒令兑换完刷新
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SHOP_UPDATE, self, self.pubShopUpdate)
    --零点重置让界面刷新
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_ALL_UPDATE, self, self.pubAllUpdate)

    --M450005小宴九抽成功失败都会通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_NINE_450005, self, self.after450005)
    --M450007盛宴九抽成功失败都会通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_NINE_450007, self, self.after450007)

    --M450002小宴购买女儿红成功失败都会通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_BUYITEM_450002, self, self.after450002)
    --M450003盛宴购买竹叶青成功失败都会通知
    self:addProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_BUYITEM_450003, self, self.after450003)


    
end

function PubModule:removeEventHander()
    self._view:removeEventListener(PubEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PubEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_ITEM_COIN_COUNT_UPDATE, self, self.updateTabItemCount)

    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_BUY_NORITEM, self, self.afterBuyNorItem)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_BUY_SPEITEM, self, self.afterBuySpeItem)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_ONE_OPEN, self, self.afterOpenOneNor)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_NINE_OPEN, self, self.afterOpenNineNor)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_ONE_OPEN, self, self.afterOpenOneSpe)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_NINE_OPEN, self, self.afterOpenNineSpe)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_HISTORY_UPDATE, self, self.norHistoryUpdate)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_HISTORY_UPDATE, self, self.speHistoryUpdate)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SHOP_UPDATE, self, self.pubShopUpdate)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NORINFO_UPDATE, self, self.updateNorInfo)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPEINFO_UPDATE, self, self.updateSpeInfo)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_ALL_UPDATE, self, self.pubAllUpdate)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_NINE_450005, self, self.after450005)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_NINE_450007, self, self.after450007)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_NOR_BUYITEM_450002, self, self.after450002)
    self:removeProxyEventListener(GameProxys.Pub, AppEvent.PROXY_PUB_SPE_BUYITEM_450003, self, self.after450003)
end

function PubModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function PubModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function PubModule:onOpenModule(adata)
    PubModule.super.onOpenModule(self)
    --打开模块获取数据
    local pubProxy = self:getProxy(GameProxys.Pub)
    pubProxy:setOpenData()

end


function PubModule:onGetRoleInfo()
    self._view:onUpdateRoleInfo()
end


function PubModule:updateTabItemCount(itemInfo)
    -- 买一个才刷新红点
    if itemInfo.num == 1 then
        local pubPanel = self:getPanel(PubPanel.NAME)
        pubPanel:updateTabItemCount()
    end
end 

function PubModule:afterBuyNorItem()
    self._view:afterBuyNorItem()
end 
function PubModule:afterBuySpeItem()
    self._view:afterBuySpeItem()
end 
function PubModule:afterOpenOneNor(reward)
    self._view:afterOpenOneNor(reward)
end 
function PubModule:afterOpenNineNor(rewards)
    self._view:afterOpenNineNor(rewards)
end 
function PubModule:afterOpenOneSpe(reward)
    self._view:afterOpenOneSpe(reward)
end 
function PubModule:afterOpenNineSpe(rewards)
    self._view:afterOpenNineSpe(rewards)
end 
function PubModule:norHistoryUpdate()
    self._view:norHistoryUpdate()
end 
function PubModule:speHistoryUpdate()
    self._view:speHistoryUpdate()
end 
function PubModule:pubShopUpdate()
    self._view:pubShopUpdate()
end 
function PubModule:updateNorInfo()
    self._view:updateNorInfo()
end 
function PubModule:updateSpeInfo()
    self._view:updateSpeInfo()
end 
function PubModule:pubAllUpdate()
    self._view:pubAllUpdate()
end 
function PubModule:after450005(rs)
    self._view:after450005(rs)
end 
function PubModule:after450007(rs)
    self._view:after450007(rs)
end 
function PubModule:after450002(rs)
    self._view:after450002(rs)
end 
function PubModule:after450003(rs)
    self._view:after450003(rs)
end 







