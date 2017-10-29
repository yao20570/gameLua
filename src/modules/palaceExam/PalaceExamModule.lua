
PalaceExamModule = class("PalaceExamModule", BasicModule)

function PalaceExamModule:ctor()
    PalaceExamModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function PalaceExamModule:initRequire()
    require("modules.palaceExam.event.PalaceExamEvent")
    require("modules.palaceExam.view.PalaceExamView")
end

function PalaceExamModule:finalize()
    PalaceExamModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function PalaceExamModule:initModule()
    PalaceExamModule.super.initModule(self)
    self._view = PalaceExamView.new(self.parent)

    self:addEventHandler()
end

function PalaceExamModule:addEventHandler()
    self._view:addEventListener(PalaceExamEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PalaceExamEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --370100查看具体的殿试信息
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_SHOW_VIEW, self, self.showView)
    --370103殿试排行榜
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_RANK_UPDATE, self, self.palaceExamRankUpdate)
    --370104领取本次殿试积分奖励后
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_REWARD_UPDATE, self, self.palaceExamRewardUpdate)
    --370102殿试科举答题了通知特效
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_ANSWER, self, self.palaceExamHadAnswer)
    --殿试切换题目时通知
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_PASS_QUES, self, self.palaceExamPassQues)
    --殿试单题倒计时结束没有答题的提示
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_TIP_NO_ANSWER, self, self.palaceExamNoAnswerTip)
    --370103殿试第一名信息更新
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_NUM_ONE_UPDATE, self, self.palaceExamNumOneUpdate)

end

function PalaceExamModule:removeEventHander()
    self._view:removeEventListener(PalaceExamEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PalaceExamEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_SHOW_VIEW, self, self.showView)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_RANK_UPDATE, self, self.palaceExamRankUpdate)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_REWARD_UPDATE, self, self.palaceExamRewardUpdate)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_ANSWER, self, self.palaceExamHadAnswer)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_PASS_QUES, self, self.palaceExamPassQues)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_TIP_NO_ANSWER, self, self.palaceExamNoAnswerTip)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PALACEEXAM_NUM_ONE_UPDATE, self, self.palaceExamNumOneUpdate)
end

function PalaceExamModule:onHideSelfHandler()
    local proxy = self:getProxy(GameProxys.ExamActivity)
    proxy:closeAllPalaceRemainTime()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function PalaceExamModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
function PalaceExamModule:showView(state)
    self._view:showView(state)
end
function PalaceExamModule:palaceExamRankUpdate()
    self._view:palaceExamRankUpdate()
end

function PalaceExamModule:palaceExamRewardUpdate(rankReard)
    self._view:palaceExamRewardUpdate(rankReard)
end
function PalaceExamModule:palaceExamHadAnswer(rs)
    self._view:palaceExamHadAnswer(rs)
end

function PalaceExamModule:palaceExamPassQues()
    self._view:palaceExamPassQues()
end
function PalaceExamModule:palaceExamNoAnswerTip()
    self._view:palaceExamNoAnswerTip()
end
function PalaceExamModule:palaceExamNumOneUpdate()
    self._view:palaceExamNumOneUpdate()
end




