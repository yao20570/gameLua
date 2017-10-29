PartsPanel = class("PartsPanel", BasicPanel)
PartsPanel.NAME = "PartsPanel"

function PartsPanel:ctor(view, panelName)
    PartsPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function PartsPanel:finalize()
    PartsPanel.super.finalize(self)
end

function PartsPanel:initPanel()
	PartsPanel.super.initPanel(self)
	self:setTitle(true,"parts",true)
	--self:onSetTitle()
	-- self:setBgType(ModulePanelBgType.WHITE)
end
function PartsPanel:onSetTitle()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local info = buildingProxy:getCurBuildingConfigInfo()
  
    -- self:setTitle(true, self:getTextWord(8201))
    
end

--发送关闭系统消息
function PartsPanel:onClosePanelHandler()
    self.view:dispatchEvent(PartsEvent.HIDE_SELF_EVENT)
end