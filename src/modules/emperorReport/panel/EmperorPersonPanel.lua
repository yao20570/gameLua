-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorPersonPanel = class("EmperorPersonPanel", BasicPanel)
EmperorPersonPanel.NAME = "EmperorPersonPanel"

function EmperorPersonPanel:ctor(view, panelName)
    EmperorPersonPanel.super.ctor(self, view, panelName)

end

function EmperorPersonPanel:finalize()
    EmperorPersonPanel.super.finalize(self)
end

function EmperorPersonPanel:initPanel()
	EmperorPersonPanel.super.initPanel(self)
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
    self._roleProxy = self:getProxy(GameProxys.Role)
end

function EmperorPersonPanel:registerEvents()
	EmperorPersonPanel.super.registerEvents(self)
    self._listView = self:getChildByName("listView")
end


function EmperorPersonPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView, GlobalConfig.downHeight, tabsPanel)

    self:createScrollViewItemUIForDoLayout(self._listView)
end

function EmperorPersonPanel:onShowHandler()
    -- 清除未读战报数量
    self._emperorCityProxy:onTriggerNet550007Req({})

    self:onUpdateLegionPanel()
end


function EmperorPersonPanel:onUpdateLegionPanel()
    local roleName = self._roleProxy:getRoleName()
    local infoList = self._emperorCityProxy:getCityFightInfoList()
    local listData = {}
    for key, info in pairs(infoList) do
        if info.ourSideName == roleName then
            table.insert(listData, info)
        end
    end

    -- 排序
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

function EmperorPersonPanel:renderItem(itemPanel, data, index)
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
function EmperorPersonPanel:onPlayBtn(sender)
    local battleId = sender.battleId

    self._emperorCityProxy:onTriggerNet160005Req({battleId = battleId})
end