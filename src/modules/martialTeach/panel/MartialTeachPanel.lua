-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-23
--  * @Description: 武学讲堂标签
--  */
MartialTeachPanel = class("MartialTeachPanel", BasicPanel)
MartialTeachPanel.NAME = "MartialTeachPanel"

function MartialTeachPanel:ctor(view, panelName)
    MartialTeachPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function MartialTeachPanel:finalize()
    MartialTeachPanel.super.finalize(self)
end

function MartialTeachPanel:initPanel()
	MartialTeachPanel.super.initPanel(self)
	self:addTabControl()
end
function MartialTeachPanel:addTabControl()

    local function callback(panel, panelName, oldPanelName) 
        if panelName == MartialMainPanel.NAME then
	        self:setBgType(ModulePanelBgType.MARTIALTEACH)
        else
	        self:setBgType(ModulePanelBgType.NONE)
        end
        return true
    end
    
	local proxy = self:getProxy(GameProxys.Activity)
    local isRank = proxy.curActivityData.rankId

    self._tabControl = UITabControl.new(self, callback)
    self._tabControl:addTabPanel(MartialMainPanel.NAME, self:getTextWord(392000))
    if isRank ~= 0 then
        self._tabControl:addTabPanel(MartialRankPanel.NAME, self:getTextWord(392001))
    end
    -- self._tabControl:addTabPanel(MartialRewardPanel.NAME, self:getTextWord(392002))
    self._tabControl:setTabSelectByName(MartialMainPanel.NAME)
    self:setTitle(true, "wuxuejiangtang", true)
    self:setBgType(ModulePanelBgType.MARTIALTEACH)

end

function MartialTeachPanel:registerEvents()
	MartialTeachPanel.super.registerEvents(self)
end
function MartialTeachPanel:onClosePanelHandler()
    self.view:dispatchEvent(MartialTeachEvent.HIDE_SELF_EVENT)
end
