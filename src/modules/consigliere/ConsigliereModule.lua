
ConsigliereModule = class("ConsigliereModule", BasicModule)

function ConsigliereModule:ctor()
    ConsigliereModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self:initRequire()
end

function ConsigliereModule:initRequire()
    require("modules.consigliere.event.ConsigliereEvent")
    require("modules.consigliere.view.ConsigliereView")
end

function ConsigliereModule:finalize()
    ConsigliereModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ConsigliereModule:initModule()
    ConsigliereModule.super.initModule(self)
    self._view = ConsigliereView.new(self.parent)

    self:addEventHandler()
end

function ConsigliereModule:addEventHandler()
    self._view:addEventListener(ConsigliereEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ConsigliereEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_GET_CONINFO, self, self.onUpdateAllConsigliere)

    -- self._view:addEventListener(ConsigliereEvent.SHOW_OTHER_VIEW, self, self.onShowOtherView)
    self._view:addEventListener(ConsigliereEvent.CHOOSE_OVER_CALL, self, self.chooseCall)

    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_ADVANCED, self, self.onAdvanceReq)
    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_RESOLVE, self, self.onResolveReq)
    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_UPGRADE, self, self.onUpgradeReq)
    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_ONEKEY, self, self.onOneKeyReq)

    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSIGRE_FOREIGN, self, self.onForeignResp)
    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSIGRE_FOREIGN_RELIEV, self, self.onForeignReliveResp)

    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSIGRECRUIT, self, self.onRecruitingResp)


    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_UPDATE_BUY_VIEW, self, self.onUpdateBuyView)

    --self._view:addEventListener(ConsigliereEvent.GO_BATTLE_REQ, self, self.onGoBattleHandler)
end

function ConsigliereModule:removeEventHander()
    self._view:removeEventListener(ConsigliereEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ConsigliereEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_GET_CONINFO, self, self.onUpdateAllConsigliere)


    -- self._view:removeEventListener(ConsigliereEvent.SHOW_OTHER_VIEW, self, self.onShowOtherView)

    self._view:removeEventListener(ConsigliereEvent.CHOOSE_OVER_CALL, self, self.chooseCall)

    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_ADVANCED, self, self.onAdvanceReq)
    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_RESOLVE, self, self.onResolveReq)
    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_UPGRADE, self, self.onUpgradeReq)
    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_ONEKEY, self, self.onOneKeyReq)

    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSIGRE_FOREIGN, self, self.onForeignResp)
    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSIGRE_FOREIGN_RELIEV, self, self.onForeignReliveResp)

    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSIGRECRUIT, self, self.onRecruitingResp)

    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_UPDATE_BUY_VIEW, self, self.onUpdateBuyView)

    --self._view:removeEventListener(ConsigliereEvent.GO_BATTLE_REQ, self, self.onGoBattleHandler)
end

function ConsigliereModule:onOneKeyReq(data)
    if data.rs == 0 then
        self._view:onOneKeySuc(data.newids)
    end
end

function ConsigliereModule:onRecruitingResp(data)
    self._view:onRecruitingResp(data)
end

function ConsigliereModule:chooseCall(data)
    self._view:updateAdvView(data)
end

function ConsigliereModule:onAdvanceReq(data)
    self._view:advanceSuccess(data)
end

function ConsigliereModule:onUpgradeReq(data)
    if data.rs == 0 then
        self:showSysMessage(TextWords:getTextWord(270041))
        self._view:upgradeSuccess()
    end
end

-- function ConsigliereModule:onShowOtherView(data)
--     self._view:showOtherView(data)
-- end

--分解成功
function ConsigliereModule:onResolveReq(data)
    if data.rs == 0 then
        self:showSysMessage(TextWords:getTextWord(270026))
        self._view:resolveSuccess()
    end
end

--任命成功结果
function ConsigliereModule:onForeignResp(data)
    print("军师上任结果", data.rs)
    if data.rs==0 then
        self:showSysMessage(self:getTextWord(270062)) --任命成功
       
    end
end

function ConsigliereModule:onForeignReliveResp( data )
    print("军师卸任结果", data.rs )
    if data.rs==0 then
        self:showSysMessage(self:getTextWord(270063)) --卸任成功

    end
end

function ConsigliereModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ConsigliereModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ConsigliereModule:onUpdateAllConsigliere( newDataList )
    self._view:updateView( newDataList )
end

-- function ConsigliereModule:onGoBattleHandler(data)
--     self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
-- end

function ConsigliereModule:onOpenModule(extraMsg)
    ConsigliereModule.super.onOpenModule(self)

    local consigliereProxy = self:getProxy( GameProxys.Consigliere )
    local allInfos = consigliereProxy:getAllInfo()
    if #allInfos<=0 then
        self._view:jumpToTab( ConsigliereRecruitsPanel.NAME )
    else
        self._view:jumpToTab( ConsigliereForeignPanel.NAME )
    end

	--TODO 以下发现无用
    if extraMsg then
        if extraMsg.UITeamMiPanel then   --从阵型跳转过来
            self._view:onShowStatus(true)
        end
    else
        self._view:onShowStatus(false)
    end
end

--0点重置刷新招募界面
function ConsigliereModule:onUpdateBuyView()
    self._view:onUpdateBuyView()
end