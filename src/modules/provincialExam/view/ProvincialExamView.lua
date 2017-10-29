
ProvincialExamView = class("ProvincialExamView", BasicView)

function ProvincialExamView:ctor(parent)
    ProvincialExamView.super.ctor(self, parent)
end

function ProvincialExamView:finalize()
    ProvincialExamView.super.finalize(self)
end

function ProvincialExamView:registerPanels()
    ProvincialExamView.super.registerPanels(self)

    require("modules.provincialExam.panel.ProvincialExamPanel")
    self:registerPanel(ProvincialExamPanel.NAME, ProvincialExamPanel)

    require("modules.provincialExam.panel.ProvExamAnswerPanel")
    self:registerPanel(ProvExamAnswerPanel.NAME, ProvExamAnswerPanel)

    require("modules.provincialExam.panel.ProvlExamRanklistPanel")
    self:registerPanel(ProvlExamRanklistPanel.NAME, ProvlExamRanklistPanel)

    require("modules.provincialExam.panel.ProvExamRewardPanel")
    self:registerPanel(ProvExamRewardPanel.NAME, ProvExamRewardPanel)
    
end

function ProvincialExamView:initView()
    local panel = self:getPanel(ProvincialExamPanel.NAME)
    panel:show()
end
function ProvincialExamView:saveCurActivityData(data)
	self.curData = data
end
function ProvincialExamView:getCurActivityData()
	return self.curData
end
function ProvincialExamView:showView(state)
    local panel = self:getPanel(ProvExamAnswerPanel.NAME)
    panel:showView(state)
end
function ProvincialExamView:provExamRankUpdate()
    local panel = self:getPanel(ProvlExamRanklistPanel.NAME)
    panel:showView()
end
function ProvincialExamView:provExamRewardUpdate(data)
    local panel = self:getPanel(ProvExamRewardPanel.NAME)
    panel:updateListView()
    local panel = self:getPanel(ProvincialExamPanel.NAME)
    panel:updateTips(data)
end
function ProvincialExamView:provExamAnswerCorrect()
    local panel = self:getPanel(ProvExamAnswerPanel.NAME)
    panel:provExamAnswerCorrect()
end
function ProvincialExamView:provExamAnswerWrong()
    local panel = self:getPanel(ProvExamAnswerPanel.NAME)
    panel:provExamAnswerWrong()
end
function ProvincialExamView:provExamPassQues()
    local panel = self:getPanel(ProvExamAnswerPanel.NAME)
    panel:provExamPassQues()
end
function ProvincialExamView:provExamNoAnswerTip()
    local panel = self:getPanel(ProvExamAnswerPanel.NAME)
    panel:provExamNoAnswerTip()
end




    