
ProvExamAnswerPanel = class("ProvExamAnswerPanel", BasicPanel)
ProvExamAnswerPanel.NAME = "ProvExamAnswerPanel"

function ProvExamAnswerPanel:ctor(view, panelName)
    ProvExamAnswerPanel.super.ctor(self, view, panelName)

end

function ProvExamAnswerPanel:finalize()
    if self.duiEffect ~= nil then
        self.duiEffect:finalize()
        self.duiEffect = nil
    end
    ProvExamAnswerPanel.super.finalize(self)
end

function ProvExamAnswerPanel:initPanel()
	ProvExamAnswerPanel.super.initPanel(self)
    self.proxy = self:getProxy(GameProxys.ExamActivity)
    self.noOpenPanel = self:getChildByName("topPanel/noOpenPanel")
    self.canOpenPanel = self:getChildByName("topPanel/canOpenPanel")
    self.openningPanel = self:getChildByName("topPanel/openningPanel")
    self.answerPanel = self:getChildByName("topPanel/answerPanel")


    local descLab1 = self:getChildByName("topPanel/noOpenPanel/descLab1")
    local descLab2 = self:getChildByName("topPanel/noOpenPanel/descLab2")
    descLab1:setString(self:getTextWord(360003))
    descLab2:setString(self:getTextWord(360004))
    local tipsBtn = self:getChildByName("topPanel/noOpenPanel/tipsBtn")
    self:addTouchEventListener(tipsBtn, self.onTipsBtnHandler)
    local descLab11 = self:getChildByName("topPanel/canOpenPanel/descLab1")
    local descLab22 = self:getChildByName("topPanel/canOpenPanel/descLab2")
    descLab11:setString(self:getTextWord(360003))
    descLab22:setString(self:getTextWord(360004))
    local tipsBtn2 = self:getChildByName("topPanel/canOpenPanel/tipsBtn")
    self:addTouchEventListener(tipsBtn2, self.onTipsBtnHandler)
    local startBtn = self:getChildByName("topPanel/canOpenPanel/startBtn")
    self:addTouchEventListener(startBtn, self.onStartBtnHandler)    


    for i=1,3 do
        local answerBtn = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
        answerBtn.tag = i
        self:addTouchEventListener(answerBtn, self.onAnswerBtnHandler)
    end
    self.quesPanel = self:getChildByName("topPanel/openningPanel/quesPanel")
    self.oldQuesPanel = self:getChildByName("topPanel/openningPanel/quesPanel/quesPanel1")
    self.newQuesPanel = self:getChildByName("topPanel/openningPanel/quesPanel/quesPanel2")
    -- self.oldQuesLab = self:getChildByName("topPanel/openningPanel/quesPanel/quesPanel1/questionLab")
    -- self.newQuesLab = self:getChildByName("topPanel/openningPanel/quesPanel/quesPanel2/questionLab")
    --���������ʶ������һ��0 ��һ������1 ��һ������-1
    self.answerState = 0
    --�����־��ֻҪ����һ���Ϊtrue
    self.alreadyPass = false
    --��־�Ƿ��ڴ����У���������������ƣ�
    self.isAnswering = false
    
end

function ProvExamAnswerPanel:doLayout()
    local panelBg = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(panelBg, nil, GlobalConfig.downHeight, tabsPanel, 3)
end

function ProvExamAnswerPanel:registerEvents()
	ProvExamAnswerPanel.super.registerEvents(self)
end

function ProvExamAnswerPanel:onShowHandler()
    ProvExamAnswerPanel.super.onShowHandler(self)
    self.proxy:onTriggerNet370000Req()

end
function ProvExamAnswerPanel:showView()
    local provExamInfo = self.proxy:getProvExamInfo()
    local state = provExamInfo.state
    self:changeUIwithState(state)
    print("---------------The state of Exam is " .. state)
    
    local dey = 0.3

    if state ==  0 or state ==  3 then
    --0δ���� 3���������,�ʱ��û����
        local nextTimeLab = self:getChildByName("topPanel/noOpenPanel/nextTimeLab")
        nextTimeLab:setString(TimeUtils:setTimestampToString(provExamInfo.nextOpenTime))
    elseif state ==  1 then
    --������
       
    elseif state ==  2 then
    --2������
        local curQuestionsInfos = self.proxy:getCurQuestionsInfos()
        local hasAnswerNum = self.proxy:getHasAnswerNumProvExam()
        hasAnswerNum = hasAnswerNum + 1
        if self.curPanelanswerNum == nil then
            self.curPanelanswerNum = hasAnswerNum   
        elseif self.curPanelanswerNum == hasAnswerNum then
            return
        else
            self.alreadyPass = true
        end
        self.curPanelanswerNum = hasAnswerNum
        if hasAnswerNum == #curQuestionsInfos + 1 then


            --���һ�����⴦��
            --��������ˢ��
            local sumScoreLab = self:getChildByName("topPanel/openningPanel/sumScoreLab")
            sumScoreLab:setString(self.proxy:getCurIntegral())
            local Image_12 = self:getChildByName("topPanel/Image_12")
            local aEffect = self:createUICCBLayer("rgb-kjks-guang", Image_12, nil, nil, true)
            local size = Image_12:getContentSize()
            aEffect:setPosition(size.width*0.5,size.height - 70)
            --aEffect:setPosition(size.width*0.44,-size.height*0.28)
            aEffect:setLocalZOrder(10)

            --û�д�����Ч
            if self.answerState == 0 then
                --���η���
                ----����һ����
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --end)
                ----���ڶ�����
                --local fanpaiFunc2 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --end)
                ----����������
                --local fanpaiFunc3 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --end)

                local funcLict = {} 

                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                        local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                        answerPanelImg:setScale(0.1)
                        answerPanelImg:runAction(cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey)))
                    end)
                    funcLict[i] = func
                end


                local dt3 = cc.DelayTime:create(0.1)
                local dt2 = cc.DelayTime:create(1)

                local refreshFunc = cc.CallFunc:create(function ()
                    self:showSysMessage(self:getTextWord(360005))
                    self.proxy:onTriggerNet370000Req()
                    if self.proxy:getCurIntegral() > 0 then
                        local aData = {}
                        aData.state = 1
                        self.proxy:setStateOfProvExamReward(aData) 
                    end

                end)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                seletAnswerPanelImg:runAction(cc.Sequence:create(funcLict[1],dt3,funcLict[2],dt3,funcLict[3],dt2,refreshFunc))
            end

            
           -- --[[
            --�������Ч
            if self.answerState == -1 then
                self.answerState = 0
                --1��СȻ��ָ�
                local scaleto1 = cc.ScaleTo:create(0.1,0.9)
                local scaleto2 = cc.ScaleTo:create(0.05,1)
                --2��ʾ����ͼ��
                local cafunc1 = cc.CallFunc:create(function ()
                    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg/itemImg/cuoImg")
                    cuoImg:setVisible(true)      
                    AudioManager:playEffect("yx_error")    
                end)
                local correctTag = self:getCorrectAnswerTag(self.newAnswerInfos,self.showQuesNum)
                --3��ʾ��ȷ��ɫ�����Ч

                local cafunc2 = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. correctTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --4���η���

                ----����һ����
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/itemImg/cuoImg")
                --    cuoImg:setVisible(false)
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    if correctTag == 1 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --end)
                ----���ڶ�����
                --local fanpaiFunc2 = cc.CallFunc:create(function ()
                --    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg/itemImg/cuoImg")
                --    cuoImg:setVisible(false)
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    if correctTag == 2 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --end)
                ----����������
                --local fanpaiFunc3 = cc.CallFunc:create(function ()
                --    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg/itemImg/cuoImg")
                --    cuoImg:setVisible(false)
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    if correctTag == 3 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --
                --end)
                
                local funcLict = {} 
                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                        local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .. "/answerPanelImg/itemImg/cuoImg")
                        cuoImg:setVisible(false)
                        local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/wrongImg")
                        wrongImg:setVisible(false)
                        local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                        answerPanelImg:setScale(0.1)
                        answerPanelImg:runAction(cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey)))

                        if correctTag == i and self.duiEffect ~= nil then
                            self.duiEffect:finalize()
                            self.duiEffect = nil
                        end
                    end)
                    funcLict[i] = func
                end

                local dt1 = cc.DelayTime:create(0.3)
                local dt2 = cc.DelayTime:create(1)
                local dt3 = cc.DelayTime:create(0.1)
                local refreshFunc = cc.CallFunc:create(function ()
                    self:showSysMessage(self:getTextWord(360005))
                    self.proxy:onTriggerNet370000Req()
                    if self.proxy:getCurIntegral() > 0 then
                        local aData = {}
                        aData.state = 1
                        self.proxy:setStateOfProvExamReward(aData) 
                    end

                end)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                local cafuncSelected = cc.CallFunc:create(function ()
                    local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/wrongImg")
                    wrongImg:setVisible(true)  
                end)
                seletAnswerPanelImg:runAction(cc.Sequence:create(cafuncSelected, scaleto1,scaleto2,dt1,cafunc1,dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3],dt2,refreshFunc))

            end
            --�������Ч
            if self.answerState == 1 then
                self.answerState = 0
                --1��СȻ��ָ�
                local scaleto1 = cc.ScaleTo:create(0.1,0.9)
                local scaleto2 = cc.ScaleTo:create(0.05,1)

                --2��ʾ��ȷ��ɫ�����Ч
                local cafunc2 = cc.CallFunc:create(function ()
                    AudioManager:playEffect("yx_dianbing")
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --3���η���

                ----����һ����
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    if self.selectedTag == 1 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --
                --end)
                ----���ڶ�����
                --local fanpaiFunc2 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    if self.selectedTag == 2 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --
                --end)
                ----����������
                --local fanpaiFunc3 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    if self.selectedTag == 3 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --
                --end)
                
                local funcLict = {} 
                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                        answerPanelImg:setScale(0.1)
                        answerPanelImg:runAction(cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey)))

                        if correctTag == i and self.duiEffect ~= nil then
                            self.duiEffect:finalize()
                            self.duiEffect = nil
                        end
                    end)
                    funcLict[i] = func
                end

                local dt1 = cc.DelayTime:create(0.3)
                local dt2 = cc.DelayTime:create(1)
                local dt3 = cc.DelayTime:create(0.1)
                local refreshFunc = cc.CallFunc:create(function ()
                    self:showSysMessage(self:getTextWord(360005))
                    self.proxy:onTriggerNet370000Req()
                    if self.proxy:getCurIntegral() > 0 then
                        local aData = {}
                        aData.state = 1
                        self.proxy:setStateOfProvExamReward(aData) 
                    end

                end)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                seletAnswerPanelImg:runAction(cc.Sequence:create(scaleto1,scaleto2,dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3],dt2,refreshFunc))
            end


        elseif hasAnswerNum > #curQuestionsInfos + 1 then
            self:showSysMessage(self:getTextWord(360005))
            self.proxy:onTriggerNet370000Req()
        else
            --������Ŀ��Ϣ
            local config = ConfigDataManager:getConfigById(ConfigData.JuniorQuConfig, curQuestionsInfos[hasAnswerNum])
            if self.newQuesStr  then
                self.oldQuesStr = self.newQuesStr
            end
            self.newQuesStr = config.question
            if self.oldQuesStr == nil then
                self.oldQuesStr = self.newQuesStr
                local questionLab = self.oldQuesPanel:getChildByName("questionLab")
                questionLab:setString(self.newQuesStr)
            end
            --�������Ϣ
            if self.newAnswerInfos  then
                self.oldAnswerInfos = self.newAnswerInfos
            end
            self.newAnswerInfos = self.proxy:packAnswerByQueNum(curQuestionsInfos[hasAnswerNum],1)
            if self.oldAnswerInfos == nil then
                self.oldAnswerInfos = self.newAnswerInfos
                for i=1,3 do
                    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .. "/answerPanelImg/answerLab")
                    answerLab:setString(self.newAnswerInfos[i].str)
                end
            end


            --�������
            if self.newScore  then
                self.oldScore = self.newScore
            end
            self.newScore = self.proxy:getCurIntegral()
            if self.oldScore == nil then
                self.oldScore = self.newScore
                local sumScoreLab = self:getChildByName("topPanel/openningPanel/sumScoreLab")
                sumScoreLab:setString(self.newScore)
                local quesNumLab = self:getChildByName("topPanel/openningPanel/quesIndexLab")
                quesNumLab:setString(string.format(TextWords:getTextWord(360024), hasAnswerNum))
                --��ʾ���
                self.showQuesNum = hasAnswerNum
                
                local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel1/wrongImg")
                wrongImg:setVisible(false)
                wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel2/wrongImg")
                wrongImg:setVisible(false)
                wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel3/wrongImg")
                wrongImg:setVisible(false)
            end

            --�κ���һ�ⶼ�е���Ч
            if self.alreadyPass == true then
                self.isAnswering = true
                --���⻬������(�Ĳ���)
                --1����
                local questionLab = self.newQuesPanel:getChildByName("questionLab")
                questionLab:setString(self.newQuesStr)
                --2�¾�Panel�ƶ�
                local time = 0.5
                local conSize = self.quesPanel:getContentSize()
                local offset = conSize.height
                local target = cc.p(0, -offset)
                local move1 = cc.MoveBy:create(time, target)
                local move2 = cc.MoveBy:create(time, target)
                local function moveCallback()
                    self.alreadyPass = false
                    --3�ı�����λ��
                    self.oldQuesPanel:setPositionY(offset)
                    --4�����¾�panelָ��
                    self.newQuesPanel,self.oldQuesPanel = self.oldQuesPanel,self.newQuesPanel 
                    
                     --���ָ���ˢ��
                    local sumScoreLab = self:getChildByName("topPanel/openningPanel/sumScoreLab")
                    sumScoreLab:setString(self.newScore)
                    local Image_12 = self:getChildByName("topPanel/Image_12")
                    local aEffect = self:createUICCBLayer("rgb-kjks-guang", Image_12, nil, nil, true)
                    local size = Image_12:getContentSize()
                    aEffect:setPosition(size.width*0.5,size.height - 70)
                    --aEffect:setPosition(size.width*0.44,-size.height*0.28)
                    aEffect:setLocalZOrder(10)
                    --���
                     local quesNumLab = self:getChildByName("topPanel/openningPanel/quesIndexLab")
                     quesNumLab:setString(string.format(TextWords:getTextWord(360024), hasAnswerNum))
                     self.showQuesNum = hasAnswerNum

                    self.isAnswering = false
                    
                    local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel1/wrongImg")
                    wrongImg:setVisible(false)
                    wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel2/wrongImg")
                    wrongImg:setVisible(false)
                    wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel3/wrongImg")
                    wrongImg:setVisible(false)
                end
                local quesTime
                if self.answerState == 0 then
                    quesTime = 0.2
                elseif self.answerState == 1 then
                    quesTime = 1.5
                else 
                    quesTime = 1.8
                end
                local dt = cc.DelayTime:create(quesTime)
                local act1 = cc.Spawn:create(cc.FadeIn:create(time * 2), move1)
                local act2 = cc.Spawn:create(cc.FadeOut:create(time - 0.3), move2)
                --self.newQuesPanel:runAction((cc.Sequence:create(dt, move1, cc.CallFunc:create(moveCallback))))
                self.newQuesPanel:runAction((cc.Sequence:create(dt, cc.FadeOut:create(0.0001), act1, cc.CallFunc:create(moveCallback))))
                self.oldQuesPanel:runAction(cc.Sequence:create(dt,act2))
            end
 
            --û�д�����Ч
            if self.answerState == 0 then
                --���η���
                --����һ����
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[1].str)
                --end)
                ----���ڶ�����
                --local fanpaiFunc2 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[2].str)
                --end)
                ----����������
                --local fanpaiFunc3 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[3].str)
                --
                --end)
                
                local funcLict = {} 
                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                    local act = cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey))
                    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.ScaleTo:create(0.0001, 0.1), act))

                    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/answerPanelImg/answerLab")
                    answerLab:setString(self.newAnswerInfos[i].str)
                    end)
                    funcLict[i] = func
                end

                local dt3 = cc.DelayTime:create(0.1)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                seletAnswerPanelImg:runAction(cc.Sequence:create(funcLict[1],dt3,funcLict[2],dt3,funcLict[3]))
            end

            
           -- --[[
            --�������Ч
            if self.answerState == -1 then
                self.answerState = 0
                --1��СȻ��ָ�
                local scaleto1 = cc.ScaleTo:create(0.1,0.9)
                local scaleto2 = cc.ScaleTo:create(0.05,1)
                --2��ʾ����ͼ��
                local cafunc1 = cc.CallFunc:create(function ()
                    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg/itemImg/cuoImg")
                    cuoImg:setVisible(true)      
                    AudioManager:playEffect("yx_error")   
                end)
                local correctTag = self:getCorrectAnswerTag(self.oldAnswerInfos,self.showQuesNum)
                --3��ʾ��ȷ��ɫ�����Ч

                local cafunc2 = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. correctTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --4���η���

                ----����һ����
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/itemImg/cuoImg")
                --    cuoImg:setVisible(false)
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --
                --    if correctTag == 1 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[1].str)
                --end)
                ----���ڶ�����
                --local fanpaiFunc2 = cc.CallFunc:create(function ()
                --    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg/itemImg/cuoImg")
                --    cuoImg:setVisible(false)
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --
                --    if correctTag == 2 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[2].str)
                --end)
                ----����������
                --local fanpaiFunc3 = cc.CallFunc:create(function ()
                --    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg/itemImg/cuoImg")
                --    cuoImg:setVisible(false)
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg")
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --
                --    if correctTag == 3 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[3].str)
                --
                --end)
                
                local funcLict = {} 
                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/answerPanelImg/itemImg/cuoImg")
                    cuoImg:setVisible(false)
                    
                    local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/wrongImg")
                    wrongImg:setVisible(false)

                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i)
                    local act = cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey))
                    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.ScaleTo:create(0.0001, 0.1), act))

                    if correctTag == i and self.duiEffect ~= nil then
                        self.duiEffect:finalize()
                        self.duiEffect = nil
                    end
                    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/answerPanelImg/answerLab")
                    answerLab:setString(self.newAnswerInfos[i].str)
                    end)
                    funcLict[i] = func
                end

                local dt1 = cc.DelayTime:create(0.3)
                local dt2 = cc.DelayTime:create(1)
                local dt3 = cc.DelayTime:create(0.1)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                local cafuncSelected = cc.CallFunc:create(function ()
                    local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/wrongImg")
                    wrongImg:setVisible(true)
                end)
                seletAnswerPanelImg:runAction(cc.Sequence:create(cafuncSelected, scaleto1,scaleto2,dt1,cafunc1,dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3]))

            end
            --�������Ч
            if self.answerState == 1 then
                self.answerState = 0
                --1��СȻ��ָ�
                local scaleto1 = cc.ScaleTo:create(0.1,0.9)
                local scaleto2 = cc.ScaleTo:create(0.05,1)

                --2��ʾ��ȷ��ɫ�����Ч
                local cafunc2 = cc.CallFunc:create(function ()
                    AudioManager:playEffect("yx_dianbing")
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --3���η���

                ----����һ����
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --
                --    if self.selectedTag == 1 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[1].str)
                --end)
                ----���ڶ�����
                --local fanpaiFunc2 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --
                --    if self.selectedTag == 2 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[2].str)
                --end)
                ----����������
                --local fanpaiFunc3 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg")
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --
                --    if self.selectedTag == 3 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[3].str)
                --
                --end)
                
                local funcLict = {} 
                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                    local act = cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey))
                    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.ScaleTo:create(0.0001, 0.1), act))

                    if self.selectedTag == i and self.duiEffect ~= nil then
                        self.duiEffect:finalize()
                        self.duiEffect = nil
                    end
                    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .. "/answerPanelImg/answerLab")
                    answerLab:setString(self.newAnswerInfos[i].str)
                    end)
                    funcLict[i] = func
                end

                local dt1 = cc.DelayTime:create(0.3)
                local dt2 = cc.DelayTime:create(1)
                local dt3 = cc.DelayTime:create(0.1)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                seletAnswerPanelImg:runAction(cc.Sequence:create(scaleto1,scaleto2,dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3]))
            end
            --]]

        end
  
    end

end
function ProvExamAnswerPanel:changeUIwithState(state)
    self.noOpenPanel:setVisible(false)
    self.canOpenPanel:setVisible(false)
    self.openningPanel:setVisible(false)
    self.answerPanel:setVisible(false)
    if state ==  0  or state ==  3 then
        self.noOpenPanel:setVisible(true)
    elseif state ==  1 then
        self.canOpenPanel:setVisible(true)
    elseif state ==  2 then
        self.openningPanel:setVisible(true)
        self.answerPanel:setVisible(true)
    end
end
function ProvExamAnswerPanel:onStartBtnHandler(sender)
    self.proxy:onTriggerNet370001Req()
end
function ProvExamAnswerPanel:onAnswerBtnHandler(sender)
    if self.isAnswering == true then
        self:showSysMessage(self:getTextWord(360009))
    else
        local sendData = {}
        sendData.answer = self.newAnswerInfos[sender.tag].id
        sendData.sort = self.proxy:getHasAnswerNumProvExam() + 1
        --��¼�Ѿ�ѡ����ѡ�� 1ΪA,2ΪB,3ΪC
        self.selectedTag = sender.tag
        self.proxy:onTriggerNet370002Req(sendData)
    end

end
function ProvExamAnswerPanel:update()
    self._provExamRemainTime = self.proxy:getRemainTime("ProvExam_RemainTime")
    local sumRemainTimeLab = self:getChildByName("topPanel/openningPanel/timePanel/sumRemainTimeLab")
    if self._provExamRemainTime > 0 then
    	--local timeStr = TimeUtils:getStandardFormatTimeString(self._provExamRemainTime)
        sumRemainTimeLab:setString(self._provExamRemainTime .. "S")
	else
		sumRemainTimeLab:setString("0S")
	end


    self._singleProvExamRemainTime = self.proxy:getRemainTime("SingleProvExam_RemainTime")
    local oneLastTimeLab = self:getChildByName("topPanel/openningPanel/timePanel/oneLastTimeLab")
    if self._singleProvExamRemainTime > 0 then
    	--local timeStr = TimeUtils:getStandardFormatTimeString(self._singleProvExamRemainTime)
        oneLastTimeLab:setString(self._singleProvExamRemainTime .. "S")
	else
		oneLastTimeLab:setString("0S")
	end



end
function ProvExamAnswerPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {}
    for i=1,7 do
        lines[i] = {{content = TextWords:getTextWord(361000 + i), foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    end
    uiTip:setAllTipLine(lines)
end
function ProvExamAnswerPanel:provExamAnswerCorrect()
    self.answerState = 1
end
function ProvExamAnswerPanel:provExamAnswerWrong()
    self.answerState = -1
end
function ProvExamAnswerPanel:provExamPassQues()
    self.alreadyPass = true
end
--�����ȷ�����ڵ�ѡ��tag(info����Ϣ��showQuesNum��ʾ�ڼ���)
function ProvExamAnswerPanel:getCorrectAnswerTag(info,showQuesNum)
    local tag
    local trueTag = self.proxy:getTrueAnswerNumByShowQuesNum(showQuesNum,1)
    for i,v in ipairs(info) do
        if v.id == trueTag then
            tag = i
            break
        end
    end
    return tag
end
function ProvExamAnswerPanel:provExamNoAnswerTip()
    self:showSysMessage(self:getTextWord(360002))
end