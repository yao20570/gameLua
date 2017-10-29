
LegionWelfarePanel = class("LegionWelfarePanel", BasicPanel)
LegionWelfarePanel.NAME = "LegionWelfarePanel"

function LegionWelfarePanel:ctor(view, panelName)
    LegionWelfarePanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function LegionWelfarePanel:finalize()
    LegionWelfarePanel.super.finalize(self)
end

function LegionWelfarePanel:initPanel()
	LegionWelfarePanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self:addTabControl()
end

function LegionWelfarePanel:addTabControl()

    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(LegionWelfareDailyPanel.NAME,self:getTextWord(3401))
    self._tabControl:addTabPanel(LegionWelfareWarPanel.NAME, self:getTextWord(3402)) --当前版本屏蔽--战事福利
    self._tabControl:addTabPanel(LegionWelfareActivePanel.NAME, self:getTextWord(3403))
    
    self._tabControl:setTabSelectByName(LegionWelfareDailyPanel.NAME)

    -- self:setTitle(true,self:getTextWord(3400))
    self:setTitle(true, "welfare", true)

end

--发送关闭系统消息
function LegionWelfarePanel:onClosePanelHandler()
    self.view:dispatchEvent(LegionWelfareEvent.HIDE_SELF_EVENT)
end

function LegionWelfarePanel:onShowHandler()
    -- 军团活跃红点    
    local legionProxy = self:getProxy(GameProxys.Legion)
    local state = legionProxy:checkGetResourceState()
    if state then
        self._tabControl:setItemCount(3,true,1)
    else
        self._tabControl:setItemCount(3,true,0)
    end

    local state = legionProxy:canGetDailyReward()
    if state then
        self._tabControl:setItemCount(1,true,1)
    else
        self._tabControl:setItemCount(1,false,0)
    end
end