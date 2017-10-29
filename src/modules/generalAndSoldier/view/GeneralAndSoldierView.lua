
GeneralAndSoldierView = class("GeneralAndSoldierView", BasicView)

function GeneralAndSoldierView:ctor(parent)
    GeneralAndSoldierView.super.ctor(self, parent)
end

function GeneralAndSoldierView:finalize()
    GeneralAndSoldierView.super.finalize(self)
end

function GeneralAndSoldierView:registerPanels()
    GeneralAndSoldierView.super.registerPanels(self)

    require("modules.generalAndSoldier.panel.GeneralAndSoldierPanel")
    self:registerPanel(GeneralAndSoldierPanel.NAME, GeneralAndSoldierPanel)
end

function GeneralAndSoldierView:initView()

end

function GeneralAndSoldierView:onShowView(extraMsg, isInit, isAutoUpdate)
    GeneralAndSoldierView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(GeneralAndSoldierPanel.NAME)
    panel:show()
end

function GeneralAndSoldierView:getRecruitRsp(data)
	local GeneralAndSoldierProxy = self:getProxy(GameProxys.GeneralAndSoldier)
	GeneralAndSoldierProxy:updateWithRecruit(data)
	local panel = self:getPanel(GeneralAndSoldierPanel.NAME)
	local function delyfunc()
		panel:updateThisPanel()
	end
	TimerManager:addOnce(2650, delyfunc,self)
	panel:zhengzhaoAciton(data.times)
end

function GeneralAndSoldierView:getTrainRsp(data)
	local GeneralAndSoldierProxy = self:getProxy(GameProxys.GeneralAndSoldier)
	GeneralAndSoldierProxy:updateWithTrain(data)
	local panel = self:getPanel(GeneralAndSoldierPanel.NAME)
	panel:updateThisPanel()
	panel:xunlianAction(data.id)
end