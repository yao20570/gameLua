-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
LegionCityPanel = class("LegionCityPanel", BasicPanel)
LegionCityPanel.NAME = "LegionCityPanel"

function LegionCityPanel:ctor(view, panelName)
    LegionCityPanel.super.ctor(self, view, panelName,true)
    self:setUseNewPanelBg(true)
    --self:setTitle(true,"legionCity",true)
end

function LegionCityPanel:finalize()
    LegionCityPanel.super.finalize(self)
end

function LegionCityPanel:initPanel()
	LegionCityPanel.super.initPanel(self)
    self:setTitle(true,"legionCity",true)
	self:setBgType(ModulePanelBgType.NONE)
    self:addTabControl()
end

function LegionCityPanel:registerEvents()
	LegionCityPanel.super.registerEvents(self)
end

function LegionCityPanel:onClosePanelHandler()

    self.view:hideModuleHandler()

end

function LegionCityPanel:addTabControl()
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(LegionTownPanel.NAME,self:getTextWord(560501))           -- 郡城
    tabControl:addTabPanel(LegionCapitalPanel.NAME,self:getTextWord(560502))          -- 都城
    tabControl:addTabPanel(LegionImperialPanel.NAME,self:getTextWord(560503))         -- 皇城
    tabControl:setTabSelectByName(LegionTownPanel.NAME)
    self._tabControl = tabControl
end

function LegionCityPanel:getControl()
    return  self._tabControl
end


function LegionCityPanel:setFirstPanelShow()
end

function LegionCityPanel:onShowHandler()
    local proxy =self:getProxy(GameProxys.Legion)
    proxy:onTriggerNet220810Req()
end

function LegionCityPanel:updateRedPoint(data)
    
    local redPoint =data.redPoint
    for k,v  in pairs(redPoint) do
        if v.panel == 47 then 
            self._tabControl:setItemCount(1,true,v.num) 
        elseif v.panel == 36 then
            self._tabControl:setItemCount(2,true,v.num) 
        elseif v.panel == 55 then
            self._tabControl:setItemCount(3,true,v.num) 
        end
    end

    local panelName = self._tabControl:getCurPanelName()
    local panel =self:getPanel(panelName)
    panel:onShowHandler() 
end

