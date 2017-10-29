-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorLegionPanel = class("EmperorLegionPanel", BasicPanel)
EmperorLegionPanel.NAME = "EmperorLegionPanel"

function EmperorLegionPanel:ctor(view, panelName)
    EmperorLegionPanel.super.ctor(self, view, panelName)

end

function EmperorLegionPanel:finalize()
    EmperorLegionPanel.super.finalize(self)
end

function EmperorLegionPanel:initPanel()
	EmperorLegionPanel.super.initPanel(self)
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
end

function EmperorLegionPanel:registerEvents()
	EmperorLegionPanel.super.registerEvents(self)

    self._listView = self:getChildByName("listView")
end

function EmperorLegionPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView, GlobalConfig.downHeight, tabsPanel)

    self:createScrollViewItemUIForDoLayout(self._listView)
end


function EmperorLegionPanel:onShowHandler()
    
    self:onUpdateLegionPanel()
end


function EmperorLegionPanel:onUpdateLegionPanel()
    local listData = self._emperorCityProxy:getCityFightInfoList()
    -- 战报排序，按时间倒序排
    table.sort(listData, 
    function(item1, item2)
        if item1.fightTime == item2.fightTime then
            return item1.battleId > item2.battleId
        else
            return item1.fightTime > item2.fightTime
        end
    end)
    
    self:renderScrollView(self._listView, "itemPanel", listData, self, self.renderItem, 1)
end

function EmperorLegionPanel:renderItem(itemPanel, data, index)
    local memoTxt = itemPanel:getChildByName("memoTxt")
    local posTxt  = itemPanel:getChildByName("posTxt")
    local timeTxt = itemPanel:getChildByName("timeTxt")
    local playBtn = itemPanel:getChildByName("playBtn")

    local fightTime = data.fightTime -- 时间
    local positionName = data.positionName -- 地点

    local ourSideName = data.ourSideName
    local enemyName   = data.enemyName  
    local legionName  = data.legionName 
    local result      = data.result -- （0负，1胜）

    local legionNameStr = ""
    if legionName ~= "" then
        legionNameStr = string.format("(%s)", legionName)
    end

    local infoStr = {}
    if result == 0 then
        infoStr = {{{ourSideName, 20, "#FFFFFF"}, {self:getTextWord(3513), 20, "#FCDA7E"}, { enemyName, 20, "#FFFFFF"}, { legionNameStr, 20, "#2ba532"}, {self:getTextWord(550011), 20, "#FCDA7E"}}}
    elseif result == 1 then
        infoStr = {{{ourSideName, 20, "#FFFFFF"}, {self:getTextWord(550011), 20, "#FCDA7E"}, { enemyName, 20, "#FFFFFF"}, { legionNameStr, 20, "#2ba532"}}}
    end

    local richLabel = memoTxt.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        memoTxt:addChild(richLabel)
        memoTxt.richLabel = richLabel
        richLabel:setPositionY(memoTxt:getContentSize().height + richLabel:getPositionY())
    end
    richLabel:setString(infoStr)

    posTxt:setString(positionName)
    timeTxt:setString( TimeUtils:setTimestampToString4(fightTime))


    playBtn.battleId = data.battleId
    self:addTouchEventListener(playBtn, self.onPlayBtn)
end

-- 点击播放
function EmperorLegionPanel:onPlayBtn(sender)
    local battleId = sender.battleId

    self._emperorCityProxy:onTriggerNet160005Req({battleId = battleId})
end