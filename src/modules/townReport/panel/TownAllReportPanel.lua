-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownAllReportPanel = class("TownAllReportPanel", BasicPanel)
TownAllReportPanel.NAME = "TownAllReportPanel"

function TownAllReportPanel:ctor(view, panelName)
    TownAllReportPanel.super.ctor(self, view, panelName)

end

function TownAllReportPanel:finalize()
    TownAllReportPanel.super.finalize(self)
end

function TownAllReportPanel:initPanel()
	TownAllReportPanel.super.initPanel(self)
    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
end

function TownAllReportPanel:registerEvents()
	TownAllReportPanel.super.registerEvents(self)
    self._adapPanel = self:getChildByName("adapPanel")
    self._topPanel = self._adapPanel:getChildByName("topPanel")
    self._nameTxt = self._topPanel:getChildByName("nameTxt")
    self._posTxt = self._topPanel:getChildByName("posTxt")

    self._timeTxt01  = self._topPanel:getChildByName("timeTxt01")
    self._timeTxt02  = self._topPanel:getChildByName("timeTxt02")

    self._resultTxt     = self._topPanel:getChildByName("resultTxt")
    self._legionNameTxt = self._topPanel:getChildByName("legionNameTxt")
    self._tipTxt        = self._topPanel:getChildByName("tipTxt")

    --

    self._midPanel = self._adapPanel:getChildByName("midPanel")
    self._leftPanel = self._midPanel:getChildByName("leftPanel")
    self._rightPanel = self._midPanel:getChildByName("rightPanel")

    --
    
    self._listView  = self:getChildByName("listView")

end

function TownAllReportPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView( self._adapPanel, self._listView, GlobalConfig.downHeight, tabsPanel, 0)
end


function TownAllReportPanel:onShowHandler()
    self:onUpdateAllReportPanel()
    self._listView:jumpToTop()
end

------
-- 接收网络回调后设置信息
function TownAllReportPanel:onUpdateAllReportPanel()
    local townKey = self._cityWarProxy:getTownKey()
    local townId = self._cityWarProxy:getTownId()
    self._battleReportInfo = self._cityWarProxy:getBattleReportInfo(townId)


    local configInfo = self._cityWarProxy:getTownConfigInfoById(self._battleReportInfo.townId)
    self._nameTxt:setString(configInfo.stateName)

    local posX = configInfo.dataX
    local posY = configInfo.dataY
    self._posTxt:setString( string.format("(%s，%s)", posX, posY))

    self._timeTxt01:setString(TimeUtils:setTimestampToString6(self._battleReportInfo.endTime) )
    self._timeTxt02:setString("")

    local result = self._battleReportInfo.result
    if result == 1 then -- 1进攻胜利  2防守胜利
        self._resultTxt:setString(self:getTextWord(1215))
    else
        self._resultTxt:setString(self:getTextWord(1213))
    end

    local winLegionName = self._battleReportInfo.winLegionName

    if winLegionName ~= "" then 
        self._legionNameTxt:setString("("..winLegionName..")") -- 胜利盟
        self._tipTxt:setString(self:getTextWord(471021)) -- "获得郡城归属权"
    else
        self._legionNameTxt:setString("")
        self._tipTxt:setString(self:getTextWord(471029)) -- "本次无同盟获得郡城的归属权"
    end
    NodeUtils:fixTwoNodePos(self._resultTxt, self._legionNameTxt)
    NodeUtils:fixTwoNodePos(self._legionNameTxt, self._tipTxt)

    self:setMidPanel()

    self:setBattleListPanel()
end

function TownAllReportPanel:setMidPanel()

    self:setMidSidePanel(self._leftPanel, 1)
    self:setMidSidePanel(self._rightPanel, 2)
end

function TownAllReportPanel:setMidSidePanel(sidePanel, index)
    local spareTeamBtn = sidePanel:getChildByName("spareTeamBtn")
    spareTeamBtn.index =  index
    
    self:addTouchEventListener(spareTeamBtn, self.onSpareTeamBtn)
    if index == 2 then
        if self._battleReportInfo.defendIsMonster == 1 then -- 0否 1是守军是否为怪物
            NodeUtils:setEnable(spareTeamBtn, false)
        else
            NodeUtils:setEnable(spareTeamBtn, true)
        end
    end
    -- 文本
    local numTxt = sidePanel:getChildByName("numTxt")
    local numTxt01 = sidePanel:getChildByName("numTxt01")
    local numTxt02 = sidePanel:getChildByName("numTxt02")

    if index == 1 then
        numTxt01:setString(self._battleReportInfo.attackTeamNum)
        numTxt02:setString("/"..self._battleReportInfo.attackTotalNum.."）")
    else
        numTxt01:setString(self._battleReportInfo.defendTeamNum)
        numTxt02:setString("/"..self._battleReportInfo.defendTotalNum.."）")
    end
    NodeUtils:fixTwoNodePos(numTxt, numTxt01)
    NodeUtils:fixTwoNodePos(numTxt01, numTxt02)
end

function TownAllReportPanel:onSpareTeamBtn(sender)
    logger:info("点击：".. sender.index)

    local teamList = {}

    if sender.index == 1 then
        teamList = self._battleReportInfo.attackIdleTeamList
    elseif sender.index == 2 then
        teamList = self._battleReportInfo.defendIdleTeamList
    end

    local panel = self:getPanel(TownSpareTeamPanel.NAME)
    panel:show(teamList)
end

------
-- 战斗列表
function TownAllReportPanel:setBattleListPanel()
    self._attackTeamList = self._battleReportInfo.attackTeamList
    self._defendTeamList = self._battleReportInfo.defendTeamList

    local listData
    if #self._attackTeamList <= #self._defendTeamList then
        listData = self._defendTeamList
    else
        listData = self._attackTeamList
    end
    
    self:renderListView( self._listView, listData, self, self.renderItem, nil, nil, 0)
end

-- 渲染itemPanel
function TownAllReportPanel:renderItem(itemPanel, data, index)
    if itemPanel == nil then
        return 
    end
    
    index = index + 1

    local img01 = itemPanel:getChildByName("img01")
    local img02 = itemPanel:getChildByName("img02")
    img01:setVisible(true)
    img02:setVisible(true)


    local attackTeamInfo = self._attackTeamList[index]
    local defendTeamInfo = self._defendTeamList[index]
    
    if index%2 == 1 then
        TextureManager:updateImageView(img01, "images/newGui9Scale/S9ReportRedd01.png")  
        TextureManager:updateImageView(img02, "images/newGui9Scale/S9ReportBlue01.png")  
    elseif index%2 == 0 then
        TextureManager:updateImageView(img01, "images/newGui9Scale/S9ReportRedd02.png")  
        TextureManager:updateImageView(img02, "images/newGui9Scale/S9ReportBlue02.png")  
    end

    if attackTeamInfo == nil then
        img01:setVisible(false)
    else
        self:setTeamInfo(img01, attackTeamInfo)
    end

    if defendTeamInfo == nil then
        img02:setVisible(false)
    else
        self:setTeamInfo(img02, defendTeamInfo)
    end


end

-- 设置信息
function TownAllReportPanel:setTeamInfo(img, info)
    local playerName = info.playerName 
    local legionName = info.legionName 
    local percent	 = info.percent		

    local nameTxt01  = img:getChildByName("nameTxt01")
    local nameTxt02  = img:getChildByName("nameTxt02")
    local loadBar    = img:getChildByName("loadBar")
    local percentTxt = loadBar:getChildByName("percentTxt")
    nameTxt01:setString(playerName)
    nameTxt02:setString(legionName)
    loadBar:setPercent(percent)
    percentTxt:setString(percent.."%")
    NodeUtils:fixTwoNodePos(nameTxt01, nameTxt02, 3)
end

