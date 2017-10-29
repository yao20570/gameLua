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
    tabControl:addTabPanel(EmperorCityInfoPanel.NAME, self:getTextWord(550000)) -- "�ʳ�"
    tabControl:addTabPanel(EmperorCityRankPanel.NAME, self:getTextWord(550001)) -- "����"
    tabControl:addTabPanel(EmperorCityHelpPanel.NAME, self:getTextWord(550002)) -- "����"

    self._tabControl = tabControl
    self._tabControl:setTabSelectByName(EmperorCityInfoPanel.NAME)
end


function EmperorCityPanel:onClosePanelHandler()
    self:dispatchEvent(EmperorCityEvent.HIDE_SELF_EVENT)
end


-- ���ñ�ǩ���
function EmperorCityPanel:setTabRedPoint()
    -- ��Ϣ������
    local count = self._emperorCityProxy:getCityInfosRedCount()
    self._tabControl:setItemCount(1, true, count)

    -- ������ǩ���
    local btnState = self._emperorCityProxy:getRewardState()
    if btnState == 1 then
        self._tabControl:setItemCount(2, true, 1)
    else
        self._tabControl:setItemCount(2, false, 0)
    end
end


