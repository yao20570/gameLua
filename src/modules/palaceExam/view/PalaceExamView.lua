
PalaceExamView = class("PalaceExamView", BasicView)

function PalaceExamView:ctor(parent)
    PalaceExamView.super.ctor(self, parent)
end

function PalaceExamView:finalize()
    PalaceExamView.super.finalize(self)
end

function PalaceExamView:registerPanels()
    PalaceExamView.super.registerPanels(self)

    require("modules.palaceExam.panel.PalaceExamPanel")
    self:registerPanel(PalaceExamPanel.NAME, PalaceExamPanel)

    require("modules.palaceExam.panel.PalaceExamAnswerPanel")
    self:registerPanel(PalaceExamAnswerPanel.NAME, PalaceExamAnswerPanel)

    require("modules.palaceExam.panel.PalaceExamRankPanel")
    self:registerPanel(PalaceExamRankPanel.NAME, PalaceExamRankPanel)

    require("modules.palaceExam.panel.PalaceExamRewardPanel")
    self:registerPanel(PalaceExamRewardPanel.NAME, PalaceExamRewardPanel)
end

function PalaceExamView:initView()
    local panel = self:getPanel(PalaceExamPanel.NAME)
    panel:show()
end
function PalaceExamView:showView(state)
    local panel = self:getPanel(PalaceExamAnswerPanel.NAME)
    panel:showView(state)
end
function PalaceExamView:palaceExamRankUpdate()
    local panel = self:getPanel(PalaceExamRankPanel.NAME)
    panel:showView()
end
function PalaceExamView:palaceExamRewardUpdate(rankReard)
    local panel = self:getPanel(PalaceExamRankPanel.NAME)
    panel:showView()
    local panel = self:getPanel(PalaceExamPanel.NAME)
    panel:updateTips(rankReard)
end
function PalaceExamView:palaceExamHadAnswer(rs)
    local panel = self:getPanel(PalaceExamAnswerPanel.NAME)
    panel:palaceExamHadAnswer(rs)
end

function PalaceExamView:palaceExamPassQues()
    local panel = self:getPanel(PalaceExamAnswerPanel.NAME)
    panel:palaceExamPassQues()
end
function PalaceExamView:palaceExamNoAnswerTip()
    local panel = self:getPanel(PalaceExamAnswerPanel.NAME)
    panel:palaceExamNoAnswerTip()
end
function PalaceExamView:palaceExamNumOneUpdate()
    local panel = self:getPanel(PalaceExamAnswerPanel.NAME)
    panel:palaceExamNumOneUpdate()
end

