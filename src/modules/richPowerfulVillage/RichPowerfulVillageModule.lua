-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
RichPowerfulVillageModule = class("RichPowerfulVillageModule", BasicModule)

function RichPowerfulVillageModule:ctor()
    RichPowerfulVillageModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self.activityId = nil

    self:initRequire()
end

function RichPowerfulVillageModule:initRequire()
    require("modules.richPowerfulVillage.event.RichPowerfulVillageEvent")
    require("modules.richPowerfulVillage.view.RichPowerfulVillageView")
end

function RichPowerfulVillageModule:finalize()
    RichPowerfulVillageModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil

    self.activityId = nil
end

function RichPowerfulVillageModule:initModule()
    RichPowerfulVillageModule.super.initModule(self)
    self._view = RichPowerfulVillageView.new(self.parent)

    self:addEventHandler()
end

function RichPowerfulVillageModule:addEventHandler()
    self._view:addEventListener(RichPowerfulVillageEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(RichPowerfulVillageEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:addEventListener(RichPowerfulVillageEvent.GET_CURRENT_OPEN_ACTIVITY,self,self.getCurrentOpenActivity)

    self._view:addEventListener(RichPowerfulVillageEvent.STAR_OR_CHANGE_REQ,self,self.startOrChangeReq)
    self._view:addEventListener(RichPowerfulVillageEvent.CONFIRM_RESULT_REQ,self,self.confirmResultReq)

    self._view:addEventListener(RichPowerfulVillageEvent.EXCHANGE_ITEM_REQ,self,self.exchangeItemReq)

    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onItemUpdate)
    self:addProxyEventListener(GameProxys.Activity,AppEvent.PROXY_RICH_POWERFUL_START_CHANGE_RESP,self,self.startOrChangeResp)
    self:addProxyEventListener(GameProxys.Activity,AppEvent.PROXY_RICH_POWERFUL_COMFIRM_RESP,self,self.confirmResultResp)
    self:addProxyEventListener(GameProxys.Activity,AppEvent.PROXY_RICH_POWERFUL_EXCAHNGE_RESP,self,self.exchangeItemResp)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onUpdateRoleInfo)
end

function RichPowerfulVillageModule:removeEventHander()
    self._view:removeEventListener(RichPowerfulVillageEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(RichPowerfulVillageEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:removeEventListener(RichPowerfulVillageEvent.GET_CURRENT_OPEN_ACTIVITY,self,self.getCurrentOpenActivity)

    self._view:removeEventListener(RichPowerfulVillageEvent.STAR_OR_CHANGE_REQ,self,self.startOrChangeReq)
    self._view:removeEventListener(RichPowerfulVillageEvent.CONFIRM_RESULT_REQ,self,self.confirmResultReq)

    self._view:removeEventListener(RichPowerfulVillageEvent.EXCHANGE_ITEM_REQ,self,self.exchangeItemReq)

    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onItemUpdate)
    self:removeProxyEventListener(GameProxys.Activity,AppEvent.PROXY_RICH_POWERFUL_START_CHANGE_RESP,self,self.startOrChangeResp)
    self:removeProxyEventListener(GameProxys.Activity,AppEvent.PROXY_RICH_POWERFUL_COMFIRM_RESP,self,self.confirmResultResp)
    self:removeProxyEventListener(GameProxys.Activity,AppEvent.PROXY_RICH_POWERFUL_EXCAHNGE_RESP,self,self.exchangeItemResp)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onUpdateRoleInfo)
end

function RichPowerfulVillageModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function RichPowerfulVillageModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function RichPowerfulVillageModule:onOpenModule(extraMsg, isPerLoad)
    if extraMsg and type(extraMsg) == "table" then
        if extraMsg.activityId then
            self.activityId = extraMsg.activityId
        end
    end 
end

--可能会同种类型的活动开多个  用于拿当前活动id
function RichPowerfulVillageModule:getCurrentOpenActivity(param)
    param.callback(self.activityId)
end

--背包物品更新
function RichPowerfulVillageModule:onItemUpdate()
    self._view:onItemUpdate()
end

--角色信息更新
function RichPowerfulVillageModule:onUpdateRoleInfo()
    self._view:onUpdateRoleInfo()
end 

---[[
--开盘界面

--开盘界面打开或改命调用
function RichPowerfulVillageModule:startOrChangeReq()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local data = {}
    data.activityId = self.activityId
    activityProxy:onTriggerNet570000Req(data)
end

function RichPowerfulVillageModule:startOrChangeResp(param)
    self._view:startOrChangeResp(param)
end 

--结果确认接口调用
function RichPowerfulVillageModule:confirmResultReq()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local data = {}
    data.activityId = self.activityId
    activityProxy:onTriggerNet570001Req(data)
end

function RichPowerfulVillageModule:confirmResultResp(param)
    self._view:confirmResultResp(param)
end 

--]]

---[[
--兑换界面

function RichPowerfulVillageModule:exchangeItemReq(param)
    local activityProxy = self:getProxy(GameProxys.Activity)
    activityProxy:onTriggerNet570002Req(param)
end


function RichPowerfulVillageModule:exchangeItemResp(param)
    self._view:exchangeItemResp(param)
end 
--]]