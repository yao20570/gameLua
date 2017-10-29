-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownLegionReportPanel = class("TownLegionReportPanel", BasicPanel)
TownLegionReportPanel.NAME = "TownLegionReportPanel"

function TownLegionReportPanel:ctor(view, panelName)
    TownLegionReportPanel.super.ctor(self, view, panelName)

end

function TownLegionReportPanel:finalize()
    TownLegionReportPanel.super.finalize(self)
end

function TownLegionReportPanel:initPanel()
	TownLegionReportPanel.super.initPanel(self)
    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
    self._roleProxy = self:getProxy(GameProxys.Role)

end

function TownLegionReportPanel:doLayout()
    
    NodeUtils:adaptiveListView(self._listView, self._bottomPanel, self:getTabsPanel())
end

function TownLegionReportPanel:registerEvents()
	TownLegionReportPanel.super.registerEvents(self)

    self._bottomPanel = self:getChildByName("bottomPanel")
    self._teamNumTxt  = self._bottomPanel:getChildByName("teamNumTxt")
    self._playbackBtn = self._bottomPanel:getChildByName("playbackBtn")
    self:addTouchEventListener(self._playbackBtn, self.onPlaybackBtn)

    self._listView = self:getChildByName("listView")
end

function TownLegionReportPanel:onShowHandler()
    self._listView:jumpToTop()

    self:onUpdateLegionReportPanel()
end

function TownLegionReportPanel:onUpdateLegionReportPanel()
    local townKey = self._cityWarProxy:getTownKey()
    local townId = self._cityWarProxy:getTownId()
    self._battleReportInfo = self._cityWarProxy:getBattleReportInfo(townId)
    local configInfo = self._cityWarProxy:getTownConfigInfoById(self._battleReportInfo.townId)

    local listData = self._battleReportInfo.townFightInfoList

    
    self:renderListView( self._listView, listData, self, self.renderItem, nil, nil, 0)

    -- 我的部队数据 
    local roleName = self._roleProxy:getRoleName()
    self._myTeamData, self._myTeamNum = self:getMyTeamData(listData, roleName)
    -- 计算空闲
    local count = 0
    for key, value in pairs(self._battleReportInfo.attackIdleTeamList) do
        if value.playerName == roleName then
            count = count + 1
        end
    end
    for key, value in pairs(self._battleReportInfo.defendIdleTeamList) do
        if value.playerName == roleName then
            count = count + 1
        end
    end
    self._myTeamNum = self._myTeamNum + count-- 空闲
    self._teamNumTxt:setString(self._myTeamNum)-- 我的队伍数量
end


function TownLegionReportPanel:renderItem(itemPanel, data, index)
    index = index + 1

    local img01 = itemPanel:getChildByName("img01")
    local img02 = itemPanel:getChildByName("img02")

    local attackTeam = data.attackTeam
    local defendTeam = data.defendTeam
    local wins = data.wins

    -- 胜利和失败(图缺) 4; //连胜次数 0表示失败 1胜利
    local resultImg = itemPanel:getChildByName("resultImg")
    local imgUrl = "images/newGui2/font_fail.png"
    TextureManager:updateImageView(resultImg, imgUrl)
    if wins == 1 then
        imgUrl = "images/newGui2/font_victory.png"
    end
    TextureManager:updateImageView(resultImg, imgUrl)


    local timeTxt = itemPanel:getChildByName("timeTxt")
    --timeTxt:setString(wins)

    self:setTeamInfo(img01, attackTeam)
    self:setTeamInfo(img02, defendTeam)
end


function TownLegionReportPanel:setTeamInfo(img, info)
    local playerName = info.playerName 
    local legionName = info.legionName 
    local percent	 = info.percent		

    local nameTxt01  = img:getChildByName("nameTxt")      
    local nameTxt02  = img:getChildByName("legionNameTxt")
    local loadBar    = img:getChildByName("loadBar")     
    local percentTxt = loadBar:getChildByName("percentTxt") 
    
    nameTxt01:setString(playerName)
    nameTxt02:setString(legionName)
    loadBar:setPercent(percent)
    percentTxt:setString(percent.."%")

    local nameTxt01_0 = img:getChildByName("nameTxt01_0")    
    nameTxt01_0:setVisible(legionName ~= "")

end


function TownLegionReportPanel:getMyTeamData(listData, roleName)
    local myTeamData = {}
    local tmp = {}
    local count = 0
    for key, info in pairs(listData) do
        local attackPlayerName = info.attackTeam.playerName
        local defendPlayerName = info.defendTeam.playerName
--        logger:info(attackPlayerName)
--        logger:info(defendPlayerName)

        if attackPlayerName == roleName then
            local teamId = info.attackTeam.teamId
            if tmp[teamId] == nil then
                tmp[teamId] = teamId
                count = count + 1
            end
            table.insert(myTeamData, info)
        elseif defendPlayerName == roleName then
            local teamId = info.defendTeam.teamId
            if tmp[teamId] == nil then
                tmp[teamId] = teamId
                count = count + 1
            end
            table.insert(myTeamData, info)
        end
    end
    return myTeamData, count
end



function TownLegionReportPanel:onPlaybackBtn()
    local myTeamPanel = self:getPanel(TownMyTeamPanel.NAME)
    myTeamPanel:show(self._myTeamData)
end
