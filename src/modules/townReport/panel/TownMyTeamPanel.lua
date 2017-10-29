TownMyTeamPanel = class("TownMyTeamPanel", BasicPanel)
TownMyTeamPanel.NAME = "TownMyTeamPanel"

function TownMyTeamPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    TownMyTeamPanel.super.ctor(self, view, panelName, 700, layer)
end

function TownMyTeamPanel:finalize()
    TownMyTeamPanel.super.finalize(self)


end

function TownMyTeamPanel:initPanel()
    TownMyTeamPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(371001))
    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
end

function TownMyTeamPanel:registerEvents()
    local mainPanel = self:getChildByName("mainPanel")
    self._topPanel = mainPanel:getChildByName("topPanel")
    self._countTxt = self._topPanel:getChildByName("countTxt")
    
    self._listView = mainPanel:getChildByName("listView")
end


function TownMyTeamPanel:onShowHandler(data)
    local myTeamData = data

    self._countTxt:setString(#myTeamData)
    self:renderListView( self._listView, myTeamData, self, self.renderItem)
end

function TownMyTeamPanel:renderItem(itemPanel, data, index)
    index = index + 1

    local img01 = itemPanel:getChildByName("img01")
    local img02 = itemPanel:getChildByName("img02")
    local replayBtn = itemPanel:getChildByName("replayBtn")


    local attackTeam = data.attackTeam
    local defendTeam = data.defendTeam
    local battleId   = data.battleId
    local wins = data.wins

    itemPanel.battleId = battleId

    self:setTeamInfo(img01, attackTeam)
    self:setTeamInfo(img02, defendTeam)

    self:addTouchEventListener(replayBtn, self.onReplayBtn)
end

function TownMyTeamPanel:setTeamInfo(img, info)
    local playerName = info.playerName 
    local legionName = info.legionName 

    local nameTxt01  = img:getChildByName("numTxt")      
    local nameTxt02  = img:getChildByName("legionNameTxt")

    
    nameTxt01:setString(playerName)
    nameTxt02:setString(legionName)
end

function TownMyTeamPanel:onReplayBtn(sender)
    local itemPanel = sender:getParent()
    local battleId = itemPanel.battleId

    logger:info(battleId)

    self._cityWarProxy:onTriggerNet160005Req({battleId = battleId})
    self:hide()
end









