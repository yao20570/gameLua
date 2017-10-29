-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-05-09
--  * @Description: 限时活动_同盟致富
--  */
LegionRichPanel = class("LegionRichPanel", BasicPanel)
LegionRichPanel.NAME = "LegionRichPanel"

function LegionRichPanel:ctor(view, panelName)
    LegionRichPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function LegionRichPanel:finalize()
    LegionRichPanel.super.finalize(self)
end

function LegionRichPanel:initPanel()
	LegionRichPanel.super.initPanel(self)
	self:addTabControl()
end

function LegionRichPanel:addTabControl()
	local proxy = self:getProxy(GameProxys.Activity)
    local isRank = proxy.curActivityData.rankId

    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(LegionRichGatherPanel.NAME, self:getTextWord(394000))
    if isRank ~= 0 then
        self._tabControl:addTabPanel(LegionRichRankPanel.NAME, self:getTextWord(394001))
    end
    self._tabControl:setTabSelectByName(LegionRichGatherPanel.NAME)
    self:setTitle(true, "legionRich", true)
    self:setBgType(ModulePanelBgType.ACTIVITY)

end

function LegionRichPanel:registerEvents()
	LegionRichPanel.super.registerEvents(self)
end
function LegionRichPanel:onClosePanelHandler()
    self.view:dispatchEvent(LegionRichEvent.HIDE_SELF_EVENT)
end
function LegionRichPanel:updateTips(data)
	local proxy  = self:getProxy(GameProxys.Activity)
	local myData = proxy:getCurActivityData()
	local redNum = proxy:getLegionRichRedNumById(myData.activityId)
    self._tabControl:setItemCount(1,true,redNum)

end