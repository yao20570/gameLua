-- 增益模块
GainModule = class("GainModule", BasicModule)

function GainModule:ctor()
    GainModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    --
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self:initRequire()
    
end

function GainModule:initRequire()
    require("modules.gain.event.GainEvent")
    require("modules.gain.view.GainView")
end

function GainModule:finalize()
    GainModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function GainModule:initModule()
    GainModule.super.initModule(self)
    self._view = GainView.new(self.parent)

    self:addEventHandler()
    
end
--显示Module时调用
function GainModule:showModule(extraMsg)
    GainModule.super.showModule(self)
    print("GainModule Open !!!")
    
    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- local data = roleProxy:getGainInfo()
    -- self:onBufferInfoResp(data)
    
    local buffProxy = self:getProxy(GameProxys.ItemBuff)
    local bufferInfo = buffProxy:getItemBuffInfos()
    self._view:updateData(bufferInfo)
end 

function GainModule:addEventHandler()
    self._view:addEventListener(GainEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(GainEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(GainEvent.SEND_BUY_EVENT, self, self.onBuyHandler)

    -- self:addProxyEventListener(GameProxys.Role, AppEvent.GAIN_INFO_UPDATE, self, self.onBufferInfoResp)
    self:addProxyEventListener(GameProxys.ItemBuff, AppEvent.ITEM_BUFF_UPDATE, self, self.onItemBufferUpdate)
    self:addProxyEventListener(GameProxys.ItemBuff, AppEvent.BUFF_SHOW_UPDATE, self, self.onItemBufferUpdate)
    
    self:addEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onPropUseResp)
    self:addEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onPropBuyResp)
--    self:addEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90003, self, self.onBufferInfoResp)
end

function GainModule:removeEventHander()
    self._view:removeEventListener(GainEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(GainEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(GainEvent.SEND_BUY_EVENT, self, self.onBuyHandler)
    
    -- self:removeProxyEventListener(GameProxys.Role, AppEvent.GAIN_INFO_UPDATE, self, self.onBufferInfoResp)
    self:removeEventListener(GameProxys.ItemBuff, AppEvent.ITEM_BUFF_UPDATE, self, self.onItemBufferUpdate)
    self:removeEventListener(GameProxys.ItemBuff, AppEvent.BUFF_SHOW_UPDATE, self, self.onItemBufferUpdate)
    self:removeEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onPropUseResp)
    self:removeEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onPropBuyResp)
--    self:removeEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90003, self, self.onBufferInfoResp)

end

function GainModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function GainModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
------------发送请求---------------

-- --请求Buffer信息
-- function GainModule:sendDataReq()
--     --local sendData = {}
--     --sendData["moduleId"] = AppEvent.NET_M9 --协议大类
--     --sendData["cmdId"]    = AppEvent.NET_M9_C90003 --子协议
--     --sendData["obj"]      = {} --发送的数据
--     --self:sendNotification("net_event", "net_send_data", sendData)
-- end 
--使用/购买
function GainModule:onBuyHandler(data)
    print("onBuyHandler(data):",data.type,data.itemID,data.num)
    local sendData = {}
    if data.type == 0 then --使用
        sendData.typeId = data.itemID
        sendData.num = data.num
        self:sendServerMessage(AppEvent.NET_M9, AppEvent.NET_M9_C90001, sendData)
    elseif data.type == 1 then --购买使用
        sendData.id = data.id
        self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100007, sendData)
    end
end 

----------收到服务器数据-------------

--使用
function GainModule:onPropUseResp(data)
    
    if data.rs == 0 then
        local info = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID",data.typeId)
        if info.tipShow == 1 then 
            self:showSysMessage(info.useTips)
        else
            self:showSysMessage(self:getTextWord(1011)) --使用物品成功飘字
        end
    end
end

--购买
function GainModule:onPropBuyResp(data)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(1012))
    end 
end
 
-- --增益信息
-- function GainModule:onBufferInfoResp(data)
--     -- print("onBufferInfoResp(data):",data.rs)
--     if data.rs == 0 then
--         local bufferInfo = data.itemBuffInfo
--         self._view:updateData(bufferInfo)
--     end 
-- end  


-- buff信息更新
function GainModule:onItemBufferUpdate(data)
    -- body
    self._view:onItemBufferUpdate(data)
end

