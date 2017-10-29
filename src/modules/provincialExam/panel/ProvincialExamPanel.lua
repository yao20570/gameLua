--
-- Author: lizhuojian
-- Date: 2016��11��3��
-- �ƾ�����
ProvincialExamPanel = class("ProvincialExamPanel", BasicPanel)
ProvincialExamPanel.NAME = "ProvincialExamPanel"

function ProvincialExamPanel:ctor(view, panelName)
    ProvincialExamPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function ProvincialExamPanel:finalize()
    ProvincialExamPanel.super.finalize(self)
end

function ProvincialExamPanel:initPanel()
	ProvincialExamPanel.super.initPanel(self)
	self:addTabControl()
end
function ProvincialExamPanel:addTabControl()
    local function callback(panel, panelName, oldPanelName) 
        if panelName == ProvExamAnswerPanel.NAME then
            self:setBgType(ModulePanelBgType.ACTIVITY)
        else
            self:setBgType(ModulePanelBgType.NONE)
        end
        return true
    end

    self._tabControl = UITabControl.new(self, callback)
    self._tabControl:addTabPanel(ProvExamAnswerPanel.NAME, self:getTextWord(360000))
    self._tabControl:addTabPanel(ProvlExamRanklistPanel.NAME, self:getTextWord(360001))
    self._tabControl:addTabPanel(ProvExamRewardPanel.NAME, self:getTextWord(360007))
    self._tabControl:setTabSelectByName(ProvExamAnswerPanel.NAME)
    --self:setTitle(true, self:getTextWord(360002))
    self:setTitle(true, "kekuxiangshi", true)
    self:setBgType(ModulePanelBgType.ACTIVITY)
end
function ProvincialExamPanel:registerEvents()
	ProvincialExamPanel.super.registerEvents(self)
end
function ProvincialExamPanel:onClosePanelHandler()
    self:dispatchEvent(ProvincialExamEvent.HIDE_SELF_EVENT)
end
function ProvincialExamPanel:updateTips(data)
    local state = data.state or 0
    local hasReward = data.hasReward or 0
    --0�����죬1�����죬2����ȡ
    if hasReward == 1 then
        self._tabControl:setItemCount(3,true,1)
    else
        self._tabControl:setItemCount(3,true,0)
    end
    --����״̬�ж���������״̬Ϊ2�����У�����ʾС���
    if state == 2 then
        self._tabControl:setItemCount(3,true,0)
    end

end

