-- /**
--  * @Author:	  lizhuojian
--  * @DateTime:	2016-11-2
--  * @Description: 科举(乡试殿试)数据代理
--  */

ExamActivityProxy = class("ExamActivityProxy", BasicProxy)

function ExamActivityProxy:ctor()
    ExamActivityProxy.super.ctor(self)
    self.proxyName = GameProxys.ExamActivity
end
-- 初始化活动数据 M20000
function ExamActivityProxy:initSyncData(data)
    ExamActivityProxy.super.initSyncData(self, data)
	self.provExamServerInfo = {}       --全服活动里乡试状态数据
    self.palaceExamServerInfo = {}        --全服活动里殿试状态数据
	local activityInfo = {}
	activityInfo.rs = 0
	activityInfo.infos = data.serverActivityInfo
	self:onTriggerNet310000Resp(activityInfo)
    --获取乡试与殿试的控制控制表数据
    self.provExamCtrlConfig = ConfigDataManager:getConfigById(ConfigData.JuniorExamConfig,1)
    self.palaceExamCtrlConfig = ConfigDataManager:getConfigById(ConfigData.SeniorExamConfig,1)
    --默认乡试一道题的时间未校准
    self.timeCalibration = false
    --乡试刷新排行榜标记 0表示需要请求协议刷新 1表示不用请求数据用本地数据
    self.provExamRankTag = 0
    --殿试刷新排行榜标记
    self.palaceExamRankTag = 0 
    --殿试答题标志 0表示该题目没有答题直接跳过 1表示已经答过请求过
    self.palaceExamAnswerTag = 0


end

function ExamActivityProxy:afterInitSyncData()

end


function ExamActivityProxy:resetAttr()

end
function ExamActivityProxy:resetCountSyncData()
end

function ExamActivityProxy:registerNetEvents()

end

function ExamActivityProxy:unregisterNetEvents()

end
function ExamActivityProxy:onTriggerNet310000Req()       --全服活动协议打开模块请求
	self:syncNetReq(AppEvent.NET_M31, AppEvent.NET_M31_C310000, {})
end

function ExamActivityProxy:onTriggerNet310000Resp(data)  --全服活动协议
	if data.rs == 0 then
		for k,v in pairs(data.infos) do
		    if v.activityId == 3 then
			    self.provExamServerInfo = v   
                self:onTriggerNet370000Req()
		    end
            if v.activityId == 4 then
                self.palaceExamServerInfo = v
                self.palaceExamRankTag = 0 
                self:onTriggerNet370100Req()
            end
		end

	end
end
--查看具体的乡试信息
function ExamActivityProxy:onTriggerNet370000Req()

	self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370000, {})
end

function ExamActivityProxy:onTriggerNet370000Resp(data)
	if data.rs == 0 then
       
        self:setProvExamInfo(data.info)

    	self:sendNotification(AppEvent.PROXY_PROVEXAM_SHOW_VIEW)
        if data.info.lessTime and data.info.lessTime >= 0 then
            self:pushRemainTime("ProvExam_RemainTime",data.info.lessTime, AppEvent.NET_M37_C370000, nil, self.ProvExamRemainTimeComplete)
        end
        if data.info.nextTime and data.info.nextTime >= 0 then
            self:pushRemainTime("SingleProvExam_RemainTime",data.info.nextTime, AppEvent.NET_M37_C370000, nil, self.singleProvExamRemainTimeComplete)
        end
        

        
	end

    
end
function ExamActivityProxy:ProvExamRemainTimeComplete()
    -- print("ProvExamRemainTimeComplete")
    self._remainTimeMap["ProvExam_RemainTime"] = nil

    self:onTriggerNet370000Req()
end

--乡试倒计时回调
function ExamActivityProxy:singleProvExamRemainTimeComplete()
    -- print("singleProvExamRemainTimeComplete")
    --self:showSysMessage(TextWords:getTextWord(360002))
    --没答题提示
    if self.provExamInfo.state == 2  then
        self:sendNotification(AppEvent.PROXY_PROVEXAM_TIP_NO_ANSWER)
    end

    self._remainTimeMap["SingleProvExam_RemainTime"] = nil

    
    -- if self.timeCalibration == true then
    --     --已经校准过时间了

    --     self:passQuestion()

    -- elseif self.timeCalibration == false then
        self:onTriggerNet370005Req()

    -- end


end
--殿试倒计时回调
function ExamActivityProxy:singlePalaceExamRemainTimeComplete()
    -- print("singlePalaceExamRemainTimeComplete")
    self._remainTimeMap["SinglePalaceExam_RemainTime"] = nil
    --没有作答的时候提示,客户端加用时
    
    if self.palaceExamAnswerTag == 0 and self.palaceExamInfo.isOnRank == 1 and self.palaceExamInfo.state == 2 then
        self:sendNotification(AppEvent.PROXY_PALACEEXAM_TIP_NO_ANSWER)
        self:setCurPalaceUseTime(self:getCurPalaceUseTime() + self.provExamCtrlConfig.answerTime)
    end
    
    --判断题号
    if self:getAnswerNumPalaceExam() > #self.palaceExamInfo.testIds then
    else
        self:passPalaceQuestion()
    end

end
function ExamActivityProxy:passQuestion()
    local answerTime = self.provExamCtrlConfig.answerTime
    self:pushRemainTime("SingleProvExam_RemainTime",answerTime, AppEvent.NET_M37_C370000, nil, self.singleProvExamRemainTimeComplete)
    self:setHasAnswerNumProvExam(self:getHasAnswerNumProvExam() + 1)
    self:sendNotification(AppEvent.PROXY_PROVEXAM_PASS_QUES)
    self:sendNotification(AppEvent.PROXY_PROVEXAM_SHOW_VIEW)
    self.timeCalibration = false

end
function ExamActivityProxy:passPalaceQuestion()
    --self.palaceExamAnswerTag = 0
    self:setStateOfAnswerPalaceExam(0)
    local answerTime = self.palaceExamCtrlConfig.answerTime
    self:pushRemainTime("SinglePalaceExam_RemainTime",answerTime, AppEvent.NET_M37_C370100, nil, self.singlePalaceExamRemainTimeComplete)
    self:setAnswerNumPalaceExam(self:getAnswerNumPalaceExam() + 1)



                --
    if self.newPalaceIntegral then
        if self.newPalaceIntegral > self:getCurPalaceIntegral()  then
            self:setCurPalaceIntegral(self.newPalaceIntegral)
        end
    end
    if self.newPalaceUseTime then
        if self.newPalaceUseTime > self:getCurPalaceUseTime()  then
            self:setCurPalaceUseTime(self.newPalaceUseTime)
        end
    end

    self:sendNotification(AppEvent.PROXY_PALACEEXAM_PASS_QUES)
    self:sendNotification(AppEvent.PROXY_PALACEEXAM_SHOW_VIEW)
end


--乡试开始答题
function ExamActivityProxy:onTriggerNet370001Req(data)
    self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370001, {})
end

function ExamActivityProxy:onTriggerNet370001Resp(data)
	if data.rs == 0 then
        self:setCurQuestionsInfos(data.testIds)
		self:showSysMessage(TextWords:getTextWord(360011))
        self:onTriggerNet370000Req()
	end

end
--乡试提交答题
function ExamActivityProxy:onTriggerNet370002Req(data)
	self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370002, data)
end

function ExamActivityProxy:onTriggerNet370002Resp(data)

    if data.integral then
        self:setCurIntegral(data.integral)
    end
	if data.rs == 0 then
		--self:showSysMessage(TextWords:getTextWord(360009))
        self:sendNotification(AppEvent.PROXY_PROVEXAM_CORRECT)
    elseif data.rs == 1 then
        --self:showSysMessage(TextWords:getTextWord(360010))
        self:sendNotification(AppEvent.PROXY_PROVEXAM_WRONG)

	end
    if data.rs >= 0 then
        self:passQuestion()
    end




end
--乡试排行榜
function ExamActivityProxy:onTriggerNet370003Req()

	self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370003, {})
end

function ExamActivityProxy:onTriggerNet370003Resp(data)
	if data.rs == 0 then
        self:setProvExamRankInfos(data.infos)
        self:setMyProvExamRankInfo(data.myInfo)
        self:sendNotification(AppEvent.PROXY_PROVEXAM_RANK_UPDATE)
	end
end
--领取本次乡试积分奖励
function ExamActivityProxy:onTriggerNet370004Req()
    self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370004, {})
end

function ExamActivityProxy:onTriggerNet370004Resp(data)
    if data.rs == 0 then
        --领取成功通知
        local data = {}
        data.hasReward = 2
        self:setStateOfProvExamReward(data)


    end
end
--乡试在场景时间到了请求下一题倒计时到0时
function ExamActivityProxy:onTriggerNet370005Req()
    self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370005, {})
end

function ExamActivityProxy:onTriggerNet370005Resp(data)

    if data.integral then
        self:setCurIntegral(data.integral)
    end
    --错误码0成功1不成功
    if data.rs == 0 then
        self:passQuestion()
    elseif data.rs == 1 then
        --1需要时间校验，获取data.time重新倒计时
        self:pushRemainTime("SingleProvExam_RemainTime",data.time, AppEvent.NET_M37_C370000, nil, self.singleProvExamRemainTimeComplete)
        self.timeCalibration = true
    end

end

--查看具体的殿试信息
function ExamActivityProxy:onTriggerNet370100Req()
    self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370100, {})
end
function ExamActivityProxy:startPalaceExamComplete()
    -- print("startPalaceExamComplete")
    self._remainTimeMap["StartPalaceExam_RemainTime"] = nil
    self:onTriggerNet370100Req()
end

function ExamActivityProxy:onTriggerNet370100Resp(data)
    if data.rs == 0 then
        --接收殿试具体信息data.info
        self:setPalaceExamInfo(data.info)
        -- if data.info.first and data.info.first ~= "" then
        --     print("info.first---info.firstScore---in---370100")
        --     print(data.info.first)
        --     print(data.info.firstScore)
        -- end
        if data.info.sort then
            -- print("data.info.sort------------ " .. data.info.sort)

        end
        if data.info.waitTime and data.info.state == 1 then

            if data.info.waitTime == 0 then
                --print("data.info.waitTime == 0")
                self:startPalaceExamComplete()
            else
                self:pushRemainTime("StartPalaceExam_RemainTime",data.info.waitTime, AppEvent.NET_M37_C370100, nil, self.startPalaceExamComplete)
            end
            
        end
        if data.info.countTime and data.info.state == 2 then

            if data.info.countTime == 0 then
            --print(" data.info.countTime == 0")
                self:singlePalaceExamRemainTimeComplete()
            else
                -- print("data.info.countTime-----------------" .. data.info.countTime)
                self:pushRemainTime("SinglePalaceExam_RemainTime",data.info.countTime, AppEvent.NET_M37_C370100, nil, self.singlePalaceExamRemainTimeComplete)
            end
            
        end

        self:sendNotification(AppEvent.PROXY_PALACEEXAM_SHOW_VIEW)
        
    end
end
--殿试通知开启答题了
function ExamActivityProxy:onTriggerNet370101Req()
    self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370101, {})
end

function ExamActivityProxy:onTriggerNet370101Resp(data)
    if data.rs == 0 then
        --接收殿试试卷ids信息data.testIds
        self:setCurPalaceQuesInfos(data.testIds)
        self:showSysMessage(TextWords:getTextWord(360011))
        --self:onTriggerNet370100Req()

    end
end
--殿试提交答题
function ExamActivityProxy:onTriggerNet370102Req(data)
    self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370102, data)
end

function ExamActivityProxy:onTriggerNet370102Resp(data)

    --错误码0正确，1答错
    if data.rs >= 0 then
        --[[
        print("-------------data.first------")
        print(data.first)
        if data.first and data.first ~= "" then
            self:setCurPalaceExamNumOneInfo({firstNameStr = data.first, firstScoreNum = data.firstScore})
        end
        ]]
        if data.integral then
            self:setStateOfAnswerPalaceExam(1)
            --self:setCurPalaceIntegral(data.integral)
            self.newPalaceIntegral = data.integral
        end
        if data.answerTime then
            --self:setCurPalaceUseTime(data.answerTime)
            self.newPalaceUseTime = data.answerTime
        end
        self:sendNotification(AppEvent.PROXY_PALACEEXAM_ANSWER,data.rs)
    end

end
--殿试排行榜 在殿试关闭状态才会请求 且请求一次就好了
function ExamActivityProxy:onTriggerNet370103Req()
    if self.palaceExamRankTag == 0 then
        self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370103, {})
    else
        self:sendNotification(AppEvent.PROXY_PALACEEXAM_RANK_UPDATE)
    end
    
end

function ExamActivityProxy:onTriggerNet370103Resp(data)
    if data.rs == 0 then
        --接收殿试排行榜信息data.infos个人排行榜信息data.myInfo
        self.palaceExamRankTag = 1
        self:setPalaceExamRankInfos(data.infos)
        if data.myInfo then
            self:setMyPalaceExamRankInfo(data.myInfo)
        end

        self:sendNotification(AppEvent.PROXY_PALACEEXAM_RANK_UPDATE)
    end
end
--领取殿试排行榜
function ExamActivityProxy:onTriggerNet370104Req()
    if self.palaceExamInfo.isOnRank == 1 then
        self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370104, {})
    else
        self:showSysMessage(TextWords:getTextWord(360014))
    end

end

function ExamActivityProxy:onTriggerNet370104Resp(data)
    if data.rs == 0 then
                --领取成功通知
        self:setStateOfPalaceExamReward(2)
    end
end
--状元推送
function ExamActivityProxy:onTriggerNet370105Req()
    self:syncNetReq(AppEvent.NET_M37, AppEvent.NET_M37_C370105, {})
end

function ExamActivityProxy:onTriggerNet370105Resp(data)
    if data.rs == 0 then
        -- if data.name then
        --     print("data.name---data.score---in---370105")
        --     print(data.name)
        --     print(data.score)
        -- end
        if data.name then
            if data.name == "" then
                self:setCurPalaceExamNumOneInfo()
            else
                local info = {}
                info.firstNameStr = data.name
                info.firstScoreNum = data.score
                self:setCurPalaceExamNumOneInfo(info)
            end
        end

    end
end
--关闭乡试模块通知停止倒数
function ExamActivityProxy:closeAllRemainTime()
    self._remainTimeMap["SingleProvExam_RemainTime"] = nil
    self._remainTimeMap["ProvExam_RemainTime"] = nil
end
--关闭殿试模块通知停止倒数
function ExamActivityProxy:closeAllPalaceRemainTime()
    self._remainTimeMap["SinglePalaceExam_RemainTime"] = nil
    self._remainTimeMap["StartPalaceExam_RemainTime"] = nil
end

------------------------------------------------------------- get function 外部调用接口
--总的乡试信息
function ExamActivityProxy:getProvExamInfo()
    return self.provExamInfo or {}
end
function ExamActivityProxy:setProvExamInfo(data)
    self.provExamInfo = data or {}
    if data.testIds then
        self:setCurQuestionsInfos(data.testIds)
    end
    if data.hasReward ~= nil and self.provExamInfo.hasReward ~= nil then
        local aData = {}
        aData.hasReward = data.hasReward
        aData.state = data.state
        self:setStateOfProvExamReward(aData)
    end
end
--总的殿试信息
function ExamActivityProxy:getPalaceExamInfo()
    return self.palaceExamInfo or {}
end
function ExamActivityProxy:setPalaceExamInfo(data)
    self.palaceExamInfo = data or {}
    if data.testIds then
        self:setCurPalaceQuesInfos(data.testIds)
    end
    if self.palaceExamInfo.rankReard and data.rankReard then
        self:setStateOfPalaceExamReward(data.rankReard)
    end
    if data.first then
        if data.first == "" then
            self:setCurPalaceExamNumOneInfo()
        else
            self:setCurPalaceExamNumOneInfo({firstNameStr = data.first, firstScoreNum = data.firstScore})
        end

    end
end

--答卷信息
function ExamActivityProxy:getCurQuestionsInfos()
    return self.questionsInfos or {}
end
function ExamActivityProxy:setCurQuestionsInfos(data)
    self.questionsInfos = data or {}
end
function ExamActivityProxy:getCurPalaceQuesInfos()
    return self.palaceQuesInfos or {}
end
function ExamActivityProxy:setCurPalaceQuesInfos(data)
    self.palaceQuesInfos = data or {}
end




--全部排行榜信息
function ExamActivityProxy:getPalaceExamRankInfos()
    return self.palaceExamRankInfos or {}
end
function ExamActivityProxy:setPalaceExamRankInfos(data)
    self.palaceExamRankInfos = data or {}
end
function ExamActivityProxy:getProvExamRankInfos()
    return self.provExamRankInfos or {}
end
function ExamActivityProxy:setProvExamRankInfos(data)
    self.provExamRankInfos = data or {}
end

--个人排行榜信息
function ExamActivityProxy:getMyProvExamRankInfo()
    return self.myProvExamRankInfo or {}
end
function ExamActivityProxy:setMyProvExamRankInfo(data)
    self.myProvExamRankInfo = data or {}
end
function ExamActivityProxy:getMyPalaceExamRankInfo()
    return self.myPalaceExamRankInfo or {}
end
function ExamActivityProxy:setMyPalaceExamRankInfo(data)
    self.myPalaceExamRankInfo = data or {}
end

--传入显示的第几题返回该题目的争取答案编好（examType为1乡试为2殿试）
function ExamActivityProxy:getTrueAnswerNumByShowQuesNum(showQuesNum,examType)
    local configID
    local config = {}
    if examType == 1 then
        configID = self.questionsInfos[showQuesNum]
        config = ConfigDataManager:getConfigById(ConfigData.JuniorQuConfig, configID)
    else
        configID = self.palaceQuesInfos[showQuesNum]
        config = ConfigDataManager:getConfigById(ConfigData.SeniorQuConfig, configID)
    end
    return   config.trueAnswerId
end
--传入试题ID返回已经封装好的答案table,examType为1乡试为2殿试
function ExamActivityProxy:packAnswerByQueNum(quesNum,examType)
--array
    local quesTable = {}
    local config
    if examType == 1 then
        config = ConfigDataManager:getConfigById(ConfigData.JuniorQuConfig, quesNum)
    else
        config = ConfigDataManager:getConfigById(ConfigData.SeniorQuConfig, quesNum)
    end
    local trueAnswerId = config.trueAnswerId
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local ans1 = {}
    ans1.str = config.trueAnswer
    ans1.id = trueAnswerId
    ans1.ranNum = math.random(1,999)
    table.insert(quesTable,ans1)

    local ans2 = {}
    ans2.str = config.falseAnswer1
    ans2.ranNum = math.random(1,999)
    table.insert(quesTable,ans2)

    local ans3 = {}
    ans3.str = config.falseAnswer2
    ans3.ranNum = math.random(1,999)
    table.insert(quesTable,ans3)

    local temp = {}
    for i=1,3 do
      if i ~= trueAnswerId then
          table.insert(temp, i)
      end
    end
    for i,v in ipairs(temp) do
      quesTable[i+1].id = v
    end

    table.sort(quesTable,function(a,b) 
        return a.ranNum > b.ranNum
end)

    return quesTable
end
--返回乡试所有段位奖励列表
function ExamActivityProxy:getProvEaxmAllRewardArray()
    local integralreward = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, self.provExamCtrlConfig.rankingID).integralreward
    local config = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CIntegralRewardConfig, "integralreward", integralreward)
    return config
end
--返回殿试所有段位奖励列表
function ExamActivityProxy:getPalaceEaxmAllRewardArray()
    local rankingreward = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, self.palaceExamCtrlConfig.rankingID).rankingreward
    local config = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CRankingRewardConfig, "rankingreward", rankingreward)
    return config
end
--主动修改乡试领取状态
function ExamActivityProxy:setStateOfProvExamReward(data)
    local hasReward = data.hasReward
    self.provExamInfo.hasReward = hasReward
    self:sendNotification(AppEvent.PROXY_PROVEXAM_REWARD_UPDATE,data)
end
--主动修改殿试领取状态
function ExamActivityProxy:setStateOfPalaceExamReward(num)
    self.palaceExamInfo.rankReard = num
    self:sendNotification(AppEvent.PROXY_PALACEEXAM_REWARD_UPDATE,num)
end
--主动修改殿试考试状态
function ExamActivityProxy:setStateOfPalaceExam(num)
    self.palaceExamInfo.state = num
    self:sendNotification(AppEvent.PROXY_PALACEEXAM_SHOW_VIEW)
end


--返回乡试奖励领取的状态0不可领，1，可领，2已领取
function ExamActivityProxy:getProvExamHasRewardAndState()
    return self.provExamInfo.hasReward,self.provExamInfo.state
end
--返回殿试奖励领取的状态0不可领取，1可领取，2已领取
function ExamActivityProxy:getStateOfPalaceExamReward()
    return self.palaceExamInfo.rankReard
end
--更新乡试当前本次积分
function ExamActivityProxy:setCurIntegral(num)
    self.provExamInfo.integral = num
end
--返回乡试当前本次积分
function ExamActivityProxy:getCurIntegral()
    return self.provExamInfo.integral
end
--更新殿试当前本次积分
function ExamActivityProxy:setCurPalaceIntegral(num)
    self.palaceExamInfo.integral = num
end
--返回殿试当前本次积分
function ExamActivityProxy:getCurPalaceIntegral()
    return self.palaceExamInfo.integral
end
--更新殿试当前总用时
function ExamActivityProxy:setCurPalaceUseTime(num)
    self.palaceExamInfo.answerTime = num
end
--返回殿试当前总用时
function ExamActivityProxy:getCurPalaceUseTime()
    return self.palaceExamInfo.answerTime
end
--更新乡试已经答题数
function ExamActivityProxy:setHasAnswerNumProvExam(num)
    self.provExamInfo.hasNum = num
end
--乡试已经答题数
function ExamActivityProxy:getHasAnswerNumProvExam()
    return self.provExamInfo.hasNum  or 0
end
--更新殿试答题号
function ExamActivityProxy:setAnswerNumPalaceExam(num)
    self.palaceExamInfo.sort = num
end
--殿试答题号
function ExamActivityProxy:getAnswerNumPalaceExam()
    return self.palaceExamInfo.sort  or 1
end
--得到殿试答题状态 ,殿试答题标志 0表示该题目没有答题直接跳过 1表示已经答过请求过
function ExamActivityProxy:getStateOfAnswerPalaceExam()
    return self.palaceExamAnswerTag
end
function ExamActivityProxy:setStateOfAnswerPalaceExam(num)
    self.palaceExamAnswerTag = num
    --print("setStateOfAnswerPalaceExam" .. num)
end
--获取殿试第一名信息（名字，总用时）
function ExamActivityProxy:getCurPalaceExamNumOneInfo()
    return self.curPalaceExamNumOneInfo
end
--设置殿试第一名信息（名字，积分）
function ExamActivityProxy:setCurPalaceExamNumOneInfo(info)
    self.curPalaceExamNumOneInfo = info
    self:sendNotification(AppEvent.PROXY_PALACEEXAM_NUM_ONE_UPDATE)
end
--获得上一次殿试情况（答对、答错、漏答题目数量）
function ExamActivityProxy:getLastPalaceExamInfo()
    if self.palaceExamInfo.trueNum == nil or self.palaceExamInfo.falseNum == nil then
        return
    end
    if self.palaceExamInfo.trueNum < 0 or self.palaceExamInfo.falseNum < 0 then
        return
    end
    local info = {}
    info.trueNum = self.palaceExamInfo.trueNum
    info.falseNum = self.palaceExamInfo.falseNum
    info.skipNum = self.palaceExamCtrlConfig.examNum - self.palaceExamInfo.trueNum - self.palaceExamInfo.falseNum
    return info
end


--------------------------------------------------------
