
ReportModule = class("ReportModule", BasicModule)

function ReportModule:ctor()
    ReportModule.super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil

    self.isFullScreen = false
    
    self:initRequire()
end

function ReportModule:initRequire()
    require("modules.report.event.ReportEvent")
    require("modules.report.view.ReportView")
end

function ReportModule:finalize()
    ReportModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ReportModule:initModule()
    ReportModule.super.initModule(self)
    self._view = ReportView.new(self.parent)

    self:addEventHandler()
end

function ReportModule:addEventHandler()
    self._view:addEventListener(ReportEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ReportEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:addEventListener(ReportEvent.REPORT_EVENT, self, self.onReportPlayerRep)

    self:addEventListener(AppEvent.NET_M14, AppEvent.NET_M14_C140010, self, self.onGetPlayerChatInfoResp)
    self:addEventListener(AppEvent.NET_M14, AppEvent.NET_M14_C140011, self, self.onReportPlayerResp)

end

function ReportModule:removeEventHander()
    self._view:removeEventListener(ReportEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ReportEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self._view:removeEventListener(ReportEvent.REPORT_EVENT, self, self.onReportPlayerRep)

    self:removeEventListener(AppEvent.NET_M14, AppEvent.NET_M14_C140010, self, self.onGetPlayerChatInfoResp)
    self:removeEventListener(AppEvent.NET_M14, AppEvent.NET_M14_C140011, self, self.onReportPlayerResp)
end

function ReportModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ReportModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


function ReportModule:openView( channelType, playerId )
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.ReportModule})
end


--[[返回 某玩家聊天信息
    required fixed64 reportId = 1;//举报信息的id（玩家id+该聊天时间戳）
    required int32 type = 2;//聊天频道 0：私聊; 1：世界; 2：军团
    required string context = 3;//内容   语音的不管
    required fixed64 playerId = 4; //被举报的玩家ID
    required int32 time = 5;//聊天时间戳
]]--
function ReportModule:onGetPlayerChatInfoResp( data )
    print( "返回 某玩家聊天信息data.rs", data.rs, data.reportInfo )--, #data.list)
    if data.rs == 0 then
        self._view:updateInfo( data.reportInfo )
    end
end
function ReportModule:onReportPlayerResp( data )
    print( "返回 举报玩家data.rs", data.rs )--, #data.list)
    if data.rs == 0 then
        self:showSysMessage( TextWords[921] )
    end 
end

--[[ extraMsg
*channelType    频道id
*playerId       玩家id
]]
function ReportModule:onOpenModule( extraMsg )
    self._view:openView( extraMsg.playerName )
    local data = {
        type = extraMsg.channelType or 0,
        playerId = extraMsg.playerId or 0,
    }
    self:onGetPlayerChatInfoRep( data )
    -- self._view:updateInfo( {
    --         {
    --             context="中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中"
    --         },{
    --             context="中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中"
    --         },{
    --             context="中中中中中中"
    --         },{
    --             context="中中中中中中"
    --         },{
    --             context="中中中中中中"
    --         }
    --     }
    -- )
end


--请求某玩家聊天信息\
function ReportModule:onGetPlayerChatInfoRep( data )
    print("请求某玩家聊天信息 onGetPlayerChatInfoRep(data)", data)
    self:sendServerMessage(AppEvent.NET_M14, AppEvent.NET_M14_C140010, data)
end
--请求举报玩家
function ReportModule:onReportPlayerRep(data)
    print("请求举报玩家 onReportPlayer(data)", data)
    self:sendServerMessage(AppEvent.NET_M14, AppEvent.NET_M14_C140011, data)
end