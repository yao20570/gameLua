
LotteryEquipView = class("LotteryEquipView", BasicView)

function LotteryEquipView:ctor(parent)
    LotteryEquipView.super.ctor(self, parent)
end

function LotteryEquipView:finalize()
    LotteryEquipView.super.finalize(self)
end

function LotteryEquipView:registerPanels()
    LotteryEquipView.super.registerPanels(self)
    require("modules.lotteryEquip.panel.LotteryEquipPanel")
    self:registerPanel(LotteryEquipPanel.NAME, LotteryEquipPanel)
end

function LotteryEquipView:initView()
    local panel = self:getPanel(LotteryEquipPanel.NAME)
    panel:show()
end

function LotteryEquipView:hideModuleHandler()
	self:dispatchEvent(LotteryEquipEvent.HIDE_SELF_EVENT, {})
end

function LotteryEquipView:onGetLotteryInfoResp(type)
	local panel = self:getPanel(LotteryEquipPanel.NAME)
	panel:onGetLotteryInfoResp(type)
end

function LotteryEquipView:onUpdateGold(gold)
	local panel = self:getPanel(LotteryEquipPanel.NAME)
	panel:onUpdateGold(gold)
end

function LotteryEquipView:onChooseResp(data)
	local panel = self:getPanel(LotteryEquipPanel.NAME)
	panel:updateChooseResp(data)
	panel:onGetLotteryInfoResp(data.equipLotterInfos)
end