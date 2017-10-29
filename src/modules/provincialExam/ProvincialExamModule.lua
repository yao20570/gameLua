
ProvincialExamModule = class("ProvincialExamModule", BasicModule)

function ProvincialExamModule:ctor()
    ProvincialExamModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function ProvincialExamModule:initRequire()
    require("modules.provincialExam.event.ProvincialExamEvent")
    require("modules.provincialExam.view.ProvincialExamView")
end

function ProvincialExamModule:finalize()
    ProvincialExamModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ProvincialExamModule:initModule()
    ProvincialExamModule.super.initModule(self)
    self._view = ProvincialExamView.new(self.parent)

    self:addEventHandler()
end

function ProvincialExamModule:addEventHandler()
    self._view:addEventListener(ProvincialExamEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ProvincialExamEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --370000查看具体的乡试信息
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_SHOW_VIEW, self, self.showView)
    --370003乡试排行榜
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_RANK_UPDATE, self, self.provExamRankUpdate)
    --370004领取本次乡试积分奖励后
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_REWARD_UPDATE, self, self.provExamRewardUpdate)
    --370002乡试科举答对了通知特效
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_CORRECT, self, self.provExamAnswerCorrect)
    --370002乡试科举答错了通知特效
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_WRONG, self, self.provExamAnswerWrong)
    --只要题目换了就通知
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_PASS_QUES, self, self.provExamPassQues)
    --乡试单题倒计时没答题提示
    self:addProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_TIP_NO_ANSWER, self, self.provExamNoAnswerTip)

    
end

function ProvincialExamModule:removeEventHander()
    self._view:removeEventListener(ProvincialExamEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ProvincialExamEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_SHOW_VIEW, self, self.showView)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_RANK_UPDATE, self, self.provExamRankUpdate)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_REWARD_UPDATE, self, self.provExamRewardUpdate)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_CORRECT, self, self.provExamAnswerCorrect)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_WRONG, self, self.provExamAnswerWrong)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_PASS_QUES, self, self.provExamPassQues)
    self:removeProxyEventListener(GameProxys.ExamActivity, AppEvent.PROXY_PROVEXAM_TIP_NO_ANSWER, self, self.provExamNoAnswerTip)
end

function ProvincialExamModule:onHideSelfHandler()
    local proxy = self:getProxy(GameProxys.ExamActivity)
    proxy:closeAllRemainTime()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ProvincialExamModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end
-- function ProvincialExamModule:onOpenModule(extraMsg)
--     self.super.onOpenModule(self)
--     self._view:saveCurActivityData(extraMsg)
--     self.activityId = extraMsg.activityId
-- end
function ProvincialExamModule:showView(state)
    self._view:showView(state)
end
function ProvincialExamModule:provExamRankUpdate()
    self._view:provExamRankUpdate()
end

function ProvincialExamModule:provExamRewardUpdate(data)
    self._view:provExamRewardUpdate(data)
end
function ProvincialExamModule:provExamAnswerCorrect()
    self._view:provExamAnswerCorrect()
end
function ProvincialExamModule:provExamAnswerWrong()
    self._view:provExamAnswerWrong()
end
function ProvincialExamModule:provExamPassQues()
    self._view:provExamPassQues()
end
function ProvincialExamModule:provExamNoAnswerTip()
    self._view:provExamNoAnswerTip()
end



