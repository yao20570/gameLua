------------个人战场
WarlordsFieldPerPanel = class("WarlordsFieldPerPanel", BasicPanel)
WarlordsFieldPerPanel.NAME = "WarlordsFieldPerPanel"

function WarlordsFieldPerPanel:ctor(view, panelName)
    WarlordsFieldPerPanel.super.ctor(self, view, panelName)

end

function WarlordsFieldPerPanel:finalize()
    WarlordsFieldPerPanel.super.finalize(self)
end

function WarlordsFieldPerPanel:initPanel()
	WarlordsFieldPerPanel.super.initPanel(self)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)

	local data = self._battleActivityProxy:onGetFightReports(3)
	self._uiFightInfosPanel = UIFightInfosPanel.new(self,data,nil,3)
end

function WarlordsFieldPerPanel:registerEvents()
	WarlordsFieldPerPanel.super.registerEvents(self)

	local signBtn = self:getChildByName("PanelDown/signBtn")
	self:addTouchEventListener(signBtn, self.onBtnClickHandle)

	local signBtn = self:getChildByName("PanelTop/tipBtn")
	self:addTouchEventListener(signBtn, self.showTips)
end

function WarlordsFieldPerPanel:showTips(sender)
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

function WarlordsFieldPerPanel:onBtnClickHandle()
	local panel = self:getPanel(WarlordsFieldPerFightPanel.NAME)
	local data = self._battleActivityProxy:onGetFightReports(3)
	panel:show(data)
end

function WarlordsFieldPerPanel:onShowHandler()
	local data = self._battleActivityProxy:onGetFightReports(3)

	local index = 1
	local _data = {}
	for _,v in pairs(data) do
		if v.type ~= 3 then
			_data[index] = v
			index = index + 1
		end
	end
	self._uiFightInfosPanel:updateData(_data)
end