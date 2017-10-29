-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorCityPanel = class("EmperorCityPanel", BasicPanel)
EmperorCityPanel.NAME = "EmperorCityPanel"

function EmperorCityPanel:ctor(view, panelName)
    EmperorCityPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function EmperorCityPanel:finalize()
    EmperorCityPanel.super.finalize(self)
end

function EmperorCityPanel:initPanel()
	EmperorCityPanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true, "huangcheng", true)

    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
    self:addTabControl()
end

function EmperorCityPanel:registerEvents()
	EmperorCityPanel.super.registerEvents(self)
end

function EmperorCityPanel:addTabControl()
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(EmperorCityInfoPanel.NAME, self:getTextWord(550000)) -- "皇城"
    tabControl:addTabPanel(EmperorCityRankPanel.NAME, self:getTextWord(550001)) -- "排名"
    tabControl:addTabPanel(EmperorCityHelpPanel.NAME, self:getTextWord(550002)) -- "帮助"

    self._tabControl = tabControl
    self._tabControl:setTabSelectByName(EmperorCityInfoPanel.NAME)
end


function EmperorCityPanel:onClosePanelHandler()
    self:dispatchEvent(EmperorCityEvent.HIDE_SELF_EVENT)
end


-- 设置标签红点
function EmperorCityPanel:setTabRedPoint()
    -- 信息界面红点
    local count = self._emperorCityProxy:getCityInfosRedCount()
    self._tabControl:setItemCount(1, true, count)

    -- 排名标签红点
    local btnState = self._emperorCityProxy:getRewardState()
    if btnState == 1 then
        self._tabControl:setItemCount(2, true, 1)
    else
        self._tabControl:setItemCount(2, false, 0)
    end
end


