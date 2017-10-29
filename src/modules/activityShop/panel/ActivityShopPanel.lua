-- /**
--  * @Author:      wzy
--  * @DateTime:    2016-12-13 20:45:00
--  * @Description: 洛阳闹市
--  */
ActivityShopPanel = class("ActivityShopPanel", BasicPanel)
ActivityShopPanel.NAME = "ActivityShopPanel"

function ActivityShopPanel:ctor(view, panelName)
    ActivityShopPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function ActivityShopPanel:finalize()
    ActivityShopPanel.super.finalize(self)
end

function ActivityShopPanel:initPanel()
	ActivityShopPanel.super.initPanel(self)
    self:addTabControl()
end

function ActivityShopPanel:registerEvents()
	ActivityShopPanel.super.registerEvents(self)
end

function ActivityShopPanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(ActivityShopHotPanel.NAME, self:getTextWord(410000))
    self._tabControl:addTabPanel(ActivityShopSpecialPanel.NAME, self:getTextWord(410001))    
    self._tabControl:setTabSelectByName(ActivityShopHotPanel.NAME)
    self._tabControl:setChainVisbale(true)
    --self:setTitle(true,"叛军")
    self:setTitle(true, "luoyannaoshi", true)
    self:setBgType(ModulePanelBgType.ACTIVITY)

    --self._tabControl:setTabTexturesByIndex(1,"images/springActivityIcon/x_off.png","images/springActivityIcon/x_on.png")
    --self._tabControl:setTabTexturesByIndex(2,"images/springActivityIcon/x_off.png","images/springActivityIcon/x_on.png")
end

function ActivityShopPanel:onClosePanelHandler()
    self:dispatchEvent(ActivityShopEvent.HIDE_SELF_EVENT)
end