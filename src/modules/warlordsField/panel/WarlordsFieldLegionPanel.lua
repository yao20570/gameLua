------------军团战场
WarlordsFieldLegionPanel = class("WarlordsFieldLegionPanel", BasicPanel)
WarlordsFieldLegionPanel.NAME = "WarlordsFieldLegionPanel"

function WarlordsFieldLegionPanel:ctor(view, panelName)
    WarlordsFieldLegionPanel.super.ctor(self, view, panelName)

end

function WarlordsFieldLegionPanel:finalize()
    WarlordsFieldLegionPanel.super.finalize(self)
end

function WarlordsFieldLegionPanel:initPanel()
	WarlordsFieldLegionPanel.super.initPanel(self)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)

	local data = self._battleActivityProxy:onGetFightReports(2)
	self._uiFightInfosPanel = UIFightInfosPanel.new(self,data,nil,2)
end

function WarlordsFieldLegionPanel:registerEvents()
	WarlordsFieldLegionPanel.super.registerEvents(self)

	local signBtn = self:getChildByName("PanelDown/signBtn")
	self:addTouchEventListener(signBtn, self.onBtnClickHandle)

	local signBtn = self:getChildByName("PanelTop/tipBtn")
	self:addTouchEventListener(signBtn, self.showTips)
end

function WarlordsFieldLegionPanel:showTips(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
    local line = {}
    local lines = {}
    for i=1,18 do
        local foneS = ColorUtils.tipSize20
        local color = ColorUtils.commonColor.MiaoShu
        if i == 1 or i == 8 or i == 11 then
            foneS = ColorUtils.tipSize24
            color = ColorUtils.commonColor.FuBiaoTi
        end
    	line[i] = {{content = self:getTextWord(280151+i), foneSize = foneS, color = color}}
    	table.insert(lines, line[i])
    end
    uiTip:setAllTipLine(lines)
end

function WarlordsFieldLegionPanel:onBtnClickHandle()
	local id = self._battleActivityProxy:onGetWorloardsActId()
	self._battleActivityProxy:onTriggerNet330001Req({activityId = id})
	--self:dispatchEvent(WarlordsFieldEvent.HIDE_SELF_EVENT)
end

function WarlordsFieldLegionPanel:onShowHandler()
	local data = self._battleActivityProxy:onGetFightReports(2)
	self._uiFightInfosPanel:updateData(data)
end