ServerListPanel = class("ServerListPanel", BasicPanel)

ServerListPanel.NAME = "ServerListPanel"

function ServerListPanel:ctor(view, panelName)
    ServerListPanel.super.ctor(self, view, panelName, 860)
end

function ServerListPanel:finalize()
    ServerListPanel.super.finalize(self)

end

function ServerListPanel:initPanel()
    ServerListPanel.super.initPanel(self)
    
    self._serverListView = self:getChildByName("bgPanel/serverListView")
    local item = self._serverListView:getItem(0)
    self._serverListView:setItemModel(item)
    
    self.MAX_PAGE_SEVER_NUM = 50
    self._serverInfoMap = {}
    self._serverInfoList = {}
    self._curSelectIndex = 1
    
    local loginPanel = self:getPanel(LoginPanel.NAME)
    local info = loginPanel:getLastServerInfo()
    self:updateLastServerPanel(info)
    
    self:setTitle(true, self:getTextWord(329))
end

function ServerListPanel:updateNewServerPanel(info)
    local newServerPanel = self:getChildByName("bgPanel/newServerPanel")
    self:renderServerPanel(newServerPanel, info, false)
end

function ServerListPanel:updateLastServerPanel(info)
    local lastServerPanel = self:getChildByName("bgPanel/lastServerPanel")
    self:renderServerPanel(lastServerPanel, info, false)
end

--升序
local function sortServerListUp(a,b)
    return tonumber(a.serverId) < tonumber(b.serverId)
end

--降序
local function sortServerListDown(a,b)
    return tonumber(a.serverId) > tonumber(b.serverId)
end 

function ServerListPanel:updateServerInfoList(list)
    self._serverInfoList = {}
    local index = 1
    local num = 0
    if list and type(list) == "table" then 
        table.sort(list,sortServerListUp)
        for k,v in pairs(list) do
            index = math.floor(num/self.MAX_PAGE_SEVER_NUM) + 1
            if self._serverInfoList[index] == nil then
                self._serverInfoList[index] = {}
            end 
            table.insert(self._serverInfoList[index],1,v)
            num = num + 1
        end
    end 

    local newInfo = nil
    --将数据分组
    self._serverInfoMap = {}
    
    local curLen = 1
    for i = 1, index do 
        for _, info in pairs(self._serverInfoList[i]) do     
            if self._serverInfoMap[i] == nil then
                self._serverInfoMap[i] = {}
                curLen = 1
            end
            
            local dataList = self._serverInfoMap[i]
            if dataList[curLen] == nil then
                dataList[curLen] = {}
            end
            
            if #dataList[curLen] < 2 then
                table.insert(dataList[curLen], info)
                
                if #dataList[curLen] == 2 then
                    curLen = curLen + 1
                end
            else
            end
            
            --是否是
            if tonumber(info.state) == 2 then
                self._curSelectIndex = i
                newInfo = info
            end 
        end
    end 
    --没有新服的情况下  选最大serverId的服
    self:updateNewServerPanel(newInfo or self._serverInfoList[index][1])
    self:updateTabBtnView()
    self:updateListView()
    
end

function ServerListPanel:updateListView()
    local dataList = self._serverInfoMap[self._curSelectIndex]
    
    self:renderListView(self._serverListView,dataList,self,self.renderServerItem)
end


function ServerListPanel:renderServerItem(item, infoList)

    for index=1, 2 do
    	local data = infoList[index]
        local serverPanel = item:getChildByName("serverPanel" .. index)
        if data == nil then
            serverPanel:setVisible(false)
        else
            serverPanel:setVisible(true)
            self:renderServerPanel(serverPanel, data, true)
        end
    end
end

function ServerListPanel:renderServerPanel(serverPanel, info, flag)

    local serverNameTxt = serverPanel:getChildByName("serverNameTxt")
    serverNameTxt:setString(info.name)
    
    local state = tonumber( info.state)
    local stateTxt = serverPanel:getChildByName("stateTxt")
    stateTxt:setString(self:getTextWord(280 + state))
    
    local color = ColorUtils:getColorByState(state)
    stateTxt:setColor(color)
    
    local loginPanel = self:getPanel(LoginPanel.NAME)
    local info2 = loginPanel:getLastServerInfo()
    local isSelect = info.serverId == info2.serverId
    local stateImg = serverPanel:getChildByName("stateImg")
    stateImg:setVisible(isSelect)
    
    if flag then
        local Image_select = serverPanel:getChildByName("Image_select")
        Image_select:setVisible(isSelect)
    end        
    
    serverPanel.serverInfo = info
    
    if serverPanel.isAddEvent == true then
        return
    end   
    serverPanel.isAddEvent = true 
    self:addTouchEventListener(serverPanel, self.onServerInfoTouch)
end

function ServerListPanel:onServerInfoTouch(sender)
    local serverInfo = sender.serverInfo
    self.view:onSelectedServerInfo(serverInfo)
    
    self:hide()
end

function ServerListPanel:updateTabBtnView()
    for index=1, 4 do
        local tabBtn = self:getChildByName("bgPanel/tabBtn" .. index)
    	local Image_selected = tabBtn:getChildByName("Image_selected")
        local imgUrl
        if self._serverInfoMap[index] ~= nil then
            tabBtn:setVisible(true)
            Image_selected:setVisible(true)
            if index == self._curSelectIndex then
                imgUrl = "images/login/Bth_down_fram.png"    
            else
                imgUrl = "images/login/Bth_been_fram.png"
            end
            TextureManager:updateImageView(Image_selected,imgUrl)
        else
            tabBtn:setVisible(false)
            Image_selected:setVisible(false)
        end
    end
end

function ServerListPanel:registerEvents()
    
    for index=1, 4 do
        local tabBtn = self:getChildByName("bgPanel/tabBtn" .. index)
        local Image_selected = tabBtn:getChildByName("Image_selected")
        Image_selected:setVisible(false)

    	tabBtn.index = index
        self:addTouchEventListener(tabBtn, self.onTabBtnTouch)
    end
    
    local root = self:getPanelRoot()
    self:addTouchEventListener(root, self.onCloseTouch)
end

function ServerListPanel:onCloseTouch(sender)
    self:hide()
end

function ServerListPanel:onTabBtnTouch(sender)

    local index = sender.index
    if index == self._curSelectIndex then
        return
    end
    self._curSelectIndex = index
    self:updateTabBtnView()
    self:updateListView()
end



