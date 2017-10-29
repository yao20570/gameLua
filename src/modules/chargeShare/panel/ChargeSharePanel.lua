
ChargeSharePanel = class("ChargeSharePanel", BasicPanel)
ChargeSharePanel.NAME = "ChargeSharePanel"
function ChargeSharePanel:ctor(view, panelName)
    ChargeSharePanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function ChargeSharePanel:finalize()
    ChargeSharePanel.super.finalize(self)
end

--function ChargeSharePanel:doLayout()
--	local topPanel = self:getChildByName("topPanel")
--
--	local bestTopPanel = self:topAdaptivePanel()
--	NodeUtils:adaptiveUpPanel(topPanel, bestTopPanel, GlobalConfig.topAdaptive - 20)
--end

function ChargeSharePanel:initPanel()
	ChargeSharePanel.super.initPanel(self)
	local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(ActDescPanel.NAME, self:getTextWord(249997))
    tabControl:addTabPanel(GetRewardPanel.NAME, self:getTextWord(249998))
    tabControl:setTabSelectByName(ActDescPanel.NAME)
    self._tabControl = tabControl
    self:setTitle(true,"legshare", true)
	self:setBgType(ModulePanelBgType.ACTIVITY)
end

function ChargeSharePanel:registerEvents()
	ChargeSharePanel.super.registerEvents(self)
end

function ChargeSharePanel:onClosePanelHandler()
	self.view:dispatchEvent(ChargeShareEvent.HIDE_SELF_EVENT)
end

function ChargeSharePanel:onShowHandler()
    if self._tabControl then
        self:updateRad()
    end
end

function ChargeSharePanel:updateRad()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local data = activityProxy:returnInfo()
    local num = 0
    for k,v in pairs(data) do
        num = num + 1
    end
    self._tabControl:setItemCount(2, num > 0, num)
end

function ChargeSharePanel:getColor(quality)
    local white  = ColorUtils.wordWhiteColor
    local green  = ColorUtils.wordGreenColor
    local blue   = ColorUtils.wordBlueColor
    local purple = ColorUtils.wordPurpleColor
    local orange = ColorUtils.wordOrangeColor
    local color = white
    if quality == 2 then
        color = green
    elseif quality == 3 then
        color = blue
    elseif quality == 4 then
        color = purple
    elseif quality == 5 then
        color = orange
    end 
    return color
end