
LegionScenePanel = class("LegionScenePanel", BasicPanel)
LegionScenePanel.NAME = "LegionScenePanel"

function LegionScenePanel:ctor(view, panelName)
    LegionScenePanel.super.ctor(self, view, panelName, true)
    self.isCanShowOtherPanel = true
    
    self:setUseNewPanelBg(true)
end

function LegionScenePanel:finalize()
    LegionScenePanel.super.finalize(self)
end

function LegionScenePanel:initPanel()
    LegionScenePanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    self:addTabControl()
end

function LegionScenePanel:addTabControl()
    self.isCanShowOtherPanel = false
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(LegionSceneHallPanel.NAME, self:getTextWord(3036))
    tabControl:addTabPanel(LegionSceneMemberPanel.NAME, self:getTextWord(3037))
    tabControl:addTabPanel(LegionSceneAllListPanel.NAME, self:getTextWord(3038))
    tabControl:setTabSelectByName(LegionSceneHallPanel.NAME)
    
    self._tabControl = tabControl
    
    self:setTitle(true,"legion",true)
end

function LegionScenePanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function LegionScenePanel:setItemCount(index,isShow)
    local legionProxy = self:getProxy(GameProxys.Legion)
    local num = legionProxy:getApprovePoint()
    local job = legionProxy:getMineJob()
    if job == 7 or job == 6 then
        if num ~=nil then
           self._tabControl:setItemCount(index,isShow,num)
        end
    else 
        self._tabControl:setItemCount(2,false)
    end
end

