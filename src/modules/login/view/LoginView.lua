LoginView = class("LoginView", BasicView)

function LoginView:ctor(parent)
    LoginView.super.ctor(self, parent)
end

function LoginView:finalize()
    LoginView.super.finalize(self)
end

function LoginView:registerPanels()

    LoginView.super.registerPanels(self)
    require("modules.login.panel.LoginPanel")
    self:registerPanel(LoginPanel.NAME, LoginPanel)
    
    require("modules.login.panel.ServerListPanel")
    self:registerPanel(ServerListPanel.NAME, ServerListPanel)

    require("modules.login.panel.ActivationPanel")
    self:registerPanel(ActivationPanel.NAME, ActivationPanel)
    
end

function LoginView:showLoginPanel()
    local loginPanel = self:getPanel(LoginPanel.NAME)
    loginPanel:show()
end

function LoginView:onLoginReq(data)
    self:dispatchEvent(LoginEvent.LOGIN_REQ, data)
end

--------------------------------------------------
function LoginView:showServerListPanel()
    local serverListPanel = self:getPanel(ServerListPanel.NAME)
    serverListPanel:show()
end

function LoginView:updateServerList(info)

    local lastLoginServer =  self:getLocalData("lastLoginServer", true)
    local lastLoginServerInfo = nil
    
    local serverList = StringUtils:splitString(info,";")
    local serverInfoList = {}
    for _, infoStr in pairs(serverList) do
        if infoStr ~= "" then
            local infoTable = StringUtils:splitString(infoStr,",")
            local info = {}
            info["ip"] = infoTable[1]
            info["port"] = infoTable[2]
            info["area"] = infoTable[3]
            info["name"] = infoTable[4]
            info["state"] = infoTable[5]
            info["serverId"] = infoTable[6]
            info["openTime"] = tonumber(infoTable[7])
            info["isPre"] = infoTable[8] == "pre"  --¸Ã·þÎñÆ÷ÊÇ·ñÎªÔ¤ÀÀ°æ

--            for index=1, 20 do
                table.insert(serverInfoList, info)
--            end
            
            
            if lastLoginServer == info["serverId"] then
                lastLoginServerInfo = info
            end
        end
    end
    
    if lastLoginServerInfo == nil then
        lastLoginServerInfo = serverInfoList[1]
    end
    
    local loginPanel = self:getPanel(LoginPanel.NAME)
    loginPanel:setSelectedServerInfo(lastLoginServerInfo)
    
    self._serverInfoList = serverInfoList

    loginPanel._editBox:setMaxLength(100) --测试的包用

    if GameConfig:isIOS() then
        if #serverInfoList == 1 then
            local serverInfo = serverInfoList[1]
            local serverId = serverInfo["serverId"]
            if tonumber(serverId) > 9000 then  --只有1个服务器，且服务器ID大于9000，则表示已经进入审核状态了
                VersionManager:setToReviewed()
                if VersionManager:isShowFloatIcon() == true then   --是否显示3k悬浮标志
                    SDKManager:canShowFloatIcon(true)
                else
                    SDKManager:canShowFloatIcon(false)
                end
            end
        end
    end
    
end

function LoginView:addServerInfo(serverInfo)
    table.insert(self._serverInfoList, serverInfo)
end

function LoginView:getUserName()
    local loginPanel = self:getPanel(LoginPanel.NAME)
    local name = loginPanel:getUserName()
    return name
end

function LoginView:onShowServerListPanel()
    local serverListPanel = self:getPanel(ServerListPanel.NAME)
    serverListPanel:show()
    serverListPanel:updateServerInfoList(self._serverInfoList)
end

function LoginView:onSelectedServerInfo(serverInfo)
    local loginPanel = self:getPanel(LoginPanel.NAME)
    loginPanel:setSelectedServerInfo(serverInfo)
end




