-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-22
--  * @Description: 限时活动_精绝古城
--  */
JingJueCityPanel = class("JingJueCityPanel", BasicPanel)
JingJueCityPanel.NAME = "JingJueCityPanel"

function JingJueCityPanel:ctor(view, panelName)
    JingJueCityPanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function JingJueCityPanel:finalize()
    JingJueCityPanel.super.finalize(self)
end

function JingJueCityPanel:initPanel()
	JingJueCityPanel.super.initPanel(self)
	self:addTabControl()
end
function JingJueCityPanel:addTabControl()
	local proxy = self:getProxy(GameProxys.Activity)
    local isRank = proxy.curActivityData.rankId

    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(JingJueMainPanel.NAME, self:getTextWord(460000))
    self._tabControl:addTabPanel(JingJueShopPanel.NAME, self:getTextWord(460001))
    if isRank ~= 0 then
        self._tabControl:addTabPanel(JingJueRankPanel.NAME, self:getTextWord(460002))
    end
    self._tabControl:setTabSelectByName(JingJueMainPanel.NAME)
    self:setTitle(true, "jingJueCity", true)
end

function JingJueCityPanel:registerEvents()
	JingJueCityPanel.super.registerEvents(self)
end
function JingJueCityPanel:onClosePanelHandler()
    self:dispatchEvent(JingJueCityEvent.HIDE_SELF_EVENT, {})
end