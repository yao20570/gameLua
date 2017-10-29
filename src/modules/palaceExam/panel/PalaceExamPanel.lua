--
-- Author: lizhuojian
-- Date: 2016年11月17日
-- 科举殿试
PalaceExamPanel = class("PalaceExamPanel", BasicPanel)
PalaceExamPanel.NAME = "PalaceExamPanel"

function PalaceExamPanel:ctor(view, panelName)
    PalaceExamPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function PalaceExamPanel:finalize()
    PalaceExamPanel.super.finalize(self)
end

function PalaceExamPanel:initPanel()
	PalaceExamPanel.super.initPanel(self)
	self:addTabControl()
end
function PalaceExamPanel:addTabControl()
    local function callback(panel, panelName, oldPanelName) 
        if panelName == PalaceExamAnswerPanel.NAME then
            self:setBgType(ModulePanelBgType.ACTIVITY)
        else
            self:setBgType(ModulePanelBgType.NONE)
        end
        return true
    end
    self._tabControl = UITabControl.new(self, callback)
    self._tabControl:addTabPanel(PalaceExamAnswerPanel.NAME, self:getTextWord(360000))
    self._tabControl:addTabPanel(PalaceExamRankPanel.NAME, self:getTextWord(360001))
    self._tabControl:setTabSelectByName(PalaceExamAnswerPanel.NAME)
    --self:setTitle(true,"科举殿试")
    self:setTitle(true, "kejudianshi", true)
    self:setBgType(ModulePanelBgType.ACTIVITY)
end


function PalaceExamPanel:registerEvents()
	PalaceExamPanel.super.registerEvents(self)
end
function PalaceExamPanel:onClosePanelHandler()
    self:dispatchEvent(PalaceExamEvent.HIDE_SELF_EVENT)
end
function PalaceExamPanel:updateTips(rankReard)
--0不可领取，1可领取，2已领取
    if rankReard == 1 then
        self._tabControl:setItemCount(2,true,1)
    else
        self._tabControl:setItemCount(2,true,0)
    end
end