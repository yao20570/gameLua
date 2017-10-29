
PalaceExamAnswerPanel = class("PalaceExamAnswerPanel", BasicPanel)
PalaceExamAnswerPanel.NAME = "PalaceExamAnswerPanel"

function PalaceExamAnswerPanel:ctor(view, panelName)
    PalaceExamAnswerPanel.super.ctor(self, view, panelName)

end

function PalaceExamAnswerPanel:finalize()
    --if self.xuanzhongEffect ~= nil then
    --    self.xuanzhongEffect:finalize()
    --    self.xuanzhongEffect = nil
    --end
    if self.duiEffect ~= nil then
        self.duiEffect:finalize()
        self.duiEffect = nil
    end
    PalaceExamAnswerPanel.super.finalize(self)
end

function PalaceExamAnswerPanel:initPanel()
	PalaceExamAnswerPanel.super.initPanel(self)
    self.proxy = self:getProxy(GameProxys.ExamActivity)
    self.noOpenPanel = self:getChildByName("topPanel/noOpenPanel")
    self.readyPanel = self:getChildByName("topPanel/readyPanel")
    self.openningPanel = self:getChildByName("topPanel/openningPanel")
    self.answerPanel = self:getChildByName("topPanel/answerPanel")


    local descLab1 = self:getChildByName("topPanel/noOpenPanel/descLab1")
    local descLab2 = self:getChildByName("topPanel/noOpenPanel/descLab2")
    descLab1:setString(self:getTextWord(360003))
    descLab2:setString(self:getTextWord(360004))
    local tipsBtn = self:getChildByName("topPanel/noOpenPanel/tipsBtn")
    self:addTouchEventListener(tipsBtn, self.onTipsBtnHandler)
    local descLab11 = self:getChildByName("topPanel/readyPanel/descLab1")
    local descLab22 = self:getChildByName("topPanel/readyPanel/descLab2")
    descLab11:setString(self:getTextWord(360003))
    descLab22:setString(self:getTextWord(360004))
    local tipsBtn2 = self:getChildByName("topPanel/readyPanel/tipsBtn")
    self:addTouchEventListener(tipsBtn2, self.onTipsBtnHandler)


    for i=1,3 do
        local answerBtn = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
        answerBtn.tag = i
        self:addTouchEventListener(answerBtn, self.onAnswerBtnHandler)
    end
    self.quesPanel = self:getChildByName("topPanel/openningPanel/quesPanel")
    self.oldQuesPanel = self:getChildByName("topPanel/openningPanel/quesPanel/quesPanel1")
    self.newQuesPanel = self:getChildByName("topPanel/openningPanel/quesPanel/quesPanel2")
    --答题情况标识，无上一题2 上一题答对了1 上一题大错了-1 上一题没答0
    self.answerState = 2
    --换题标志，只要跳下一题就为true
    self.alreadyPass = false
    --标志是否在答题中（答题回馈动画控制）
    self.isAnswering = false

end
function PalaceExamAnswerPanel:doLayout()
    local panelBg = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(panelBg, nil, GlobalConfig.downHeight, tabsPanel, 3)
end

function PalaceExamAnswerPanel:registerEvents()
	PalaceExamAnswerPanel.super.registerEvents(self)
end
function PalaceExamAnswerPanel:onShowHandler()
    PalaceExamAnswerPanel.super.onShowHandler(self)
    self.proxy:onTriggerNet370100Req()
   
end

function PalaceExamAnswerPanel:showView()
    local palaceExamInfo = self.proxy:getPalaceExamInfo()
    --是否在可参加殿试的榜单0不在，1在  

    self.isOnRank = palaceExamInfo.isOnRank
     --print("---------------isOnRank")
        --print(self.isOnRank)
    local state = palaceExamInfo.state
    self:changeUIwithState(state)
    print("---------------The state of Exam is " .. state)
    local dey = 0.3
    
    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
    TextureManager:updateImageView(answerPanelImg, "images/common/item_bg_1.png")
    answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
    TextureManager:updateImageView(answerPanelImg, "images/common/item_bg_1.png")
    answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg")
    TextureManager:updateImageView(answerPanelImg, "images/common/item_bg_1.png")

    if state ==  0 or state ==  3 then
    --0未开启
        local nextTimeLab = self:getChildByName("topPanel/noOpenPanel/nextTimeLab")
        nextTimeLab:setString(TimeUtils:setTimestampToString(palaceExamInfo.nextOpenTime))
        local lastPalaceExamInfo =  self.proxy:getLastPalaceExamInfo()
        local lastExamPanel = self:getChildByName("topPanel/noOpenPanel/lastExamPanel")
        if lastPalaceExamInfo then
            lastExamPanel:setVisible(true)
            local trueLab = self:getChildByName("topPanel/noOpenPanel/lastExamPanel/trueLab")
            local falseLab = self:getChildByName("topPanel/noOpenPanel/lastExamPanel/falseLab")
            local skipLab = self:getChildByName("topPanel/noOpenPanel/lastExamPanel/skipLab")
            trueLab:setString(string.format("%s%d%s", self:getTextWord(360019),lastPalaceExamInfo.trueNum,self:getTextWord(360018)))
            falseLab:setString(string.format("%s%d%s", self:getTextWord(360020),lastPalaceExamInfo.falseNum,self:getTextWord(360018)))
            skipLab:setString(string.format("%s%d%s", self:getTextWord(360021),lastPalaceExamInfo.skipNum,self:getTextWord(360018)))
        else
            lastExamPanel:setVisible(false)
        end
    elseif state ==  1 then
    --1等待中（倒计时）
        --准备中的资格显示
        local qualificationLab = self:getChildByName("topPanel/readyPanel/qualificationLab")
        qualificationLab:setString(self:getTextWord(360012))
        qualificationLab:setVisible(self.isOnRank ~= 1)
        local countDownPanel = self:getChildByName("topPanel/readyPanel/countDownPanel")
        countDownPanel:setVisible(self.isOnRank == 1)
    elseif state ==  2 then
        --没资格参加的特殊处理
        if self.isOnRank ~= 1 then
            self.proxy:setStateOfPalaceExam(1)
            return
        end
    --2答题中

        local curQuestionsInfos = self.proxy:getCurPalaceQuesInfos()

        local answerNum = self.proxy:getAnswerNumPalaceExam()
        --print("num----------------------" .. answerNum)
        if self.curPanelanswerNum == nil then
            self.curPanelanswerNum = answerNum   
        elseif self.curPanelanswerNum == answerNum then
            return
        else
            self.alreadyPass = true
            self.curPanelanswerNum = answerNum
            self.proxy:setStateOfAnswerPalaceExam(0)
        end
        -- print("-----------------第几题")
        -- print(answerNum)
        -- print("------------------表题号")
        -- print(curQuestionsInfos[answerNum])

        local sumScoreLab = self:getChildByName("topPanel/openningPanel/sumScoreLab")
        --#curQuestionsInfos + 1 
        if answerNum == #curQuestionsInfos + 1 then
        --最后一题特殊处理
            --处理积分

            local sumScoreLab = self:getChildByName("topPanel/openningPanel/sumScoreLab")
            sumScoreLab:setString(self.proxy:getCurPalaceIntegral())
            --处理耗时
            local sumUseTimeLab = self:getChildByName("topPanel/openningPanel/sumUseTimeLab")
            sumUseTimeLab:setString(self.proxy:getCurPalaceUseTime())
            


            ----先去掉选中框
            for i = 1, 3 do
                local selectedImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .. "/answerPanelImg/itemImg/selectedImg")
                selectedImg:setVisible(false)
                local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/wrongImg")
                wrongImg:setVisible(false)
            end
            --if self.xuanzhongEffect ~= nil then
            --    self.xuanzhongEffect:finalize()
            --    self.xuanzhongEffect = nil
            --end

            --倒计时显示关闭
            local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
            local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
            timePanel:setVisible(false)
            timeNoAnswerPanel:setVisible(false)
            --答题滑动动画(四部曲)
            local questionLab = self.newQuesPanel:getChildByName("questionLab")
            questionLab:setString(self.newQuesStr)
            local Image_12 = self:getChildByName("topPanel/Image_12")
            local aEffect = self:createUICCBLayer("rgb-kjks-guang", Image_12, nil, nil, true)
            local size = Image_12:getContentSize()
            aEffect:setPosition(size.width*0.5,size.height - 70)
            --aEffect:setPosition(size.width*0.44,-size.height*0.28)
            aEffect:setLocalZOrder(10)

            --print("last--ques---handler------------self.answerState")
            --print(self.answerState)

            --没有答题特效
            if self.answerState == 0 then

                --1显示正确金色外框特效
                local correctTag = self:getCorrectAnswerTag(self.newAnswerInfos,self.showQuesNum)
                local cafunc2 = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. correctTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --2依次翻牌

                ----翻第一张牌
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    if correctTag == 1 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --end)
                ----翻第二张牌
                --local fanpaiFunc2 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    if correctTag == 2 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --end)
                ----翻第三张牌
                --local fanpaiFunc3 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --    if correctTag == 3 and self.duiEffect ~= nil then
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

                local dt3 = cc.DelayTime:create(0.1)
                local dt2 = cc.DelayTime:create(1)
                local dt1 = cc.DelayTime:create(0.3)    

                local refreshFunc = cc.CallFunc:create(function ()
                    self:showSysMessage(self:getTextWord(360005))
                    self.proxy:onTriggerNet370100Req()
                end)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                seletAnswerPanelImg:runAction(cc.Sequence:create(dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3],dt2,refreshFunc))
            end

            
            --答错了特效
            if self.answerState == -1 then
                self.answerState = 0
                --1缩小然后恢复
                local scaleto1 = cc.ScaleTo:create(0.1,0.8)
                local scaleto2 = cc.ScaleTo:create(0.05,1)
                --2显示错误图标
                local cafunc1 = cc.CallFunc:create(function ()
                    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg/itemImg/cuoImg")
                    cuoImg:setVisible(true)        
                    AudioManager:playEffect("yx_error")  
                end)
                local correctTag = self:getCorrectAnswerTag(self.newAnswerInfos,self.showQuesNum)
                --3显示正确金色外框特效

                local cafunc2 = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. correctTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --4依次翻牌

                ----翻第一张牌
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/itemImg/cuoImg")
                --    cuoImg:setVisible(false)
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --
                --    if correctTag == 1 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --end)
                ----翻第二张牌
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
                ----翻第三张牌
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
                        local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/answerPanelImg/itemImg/cuoImg")
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
                    self.proxy:onTriggerNet370100Req()
                end)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                
                local cafuncSelected = cc.CallFunc:create(function ()
                    local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/wrongImg")
                    wrongImg:setVisible(true)
                end)
                local scaleTo09 = cc.ScaleTo:create(0.1, 0.9)
                local scaleTo10 = cc.ScaleTo:create(0.05, 1.0)

                seletAnswerPanelImg:runAction(cc.Sequence:create(cafuncSelected, scaleTo09, scaleTo10, dt1,cafunc1,dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3],dt2,refreshFunc))

            end
            --答对了特效
            if self.answerState == 1 then
                self.answerState = 0
                --1缩小然后恢复
                local scaleto1 = cc.ScaleTo:create(0.1,0.8)
                local scaleto2 = cc.ScaleTo:create(0.05,1)

                --2显示正确金色外框特效
                local cafunc2 = cc.CallFunc:create(function ()
                    AudioManager:playEffect("yx_dianbing")
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                    self.duiEffect = UICCBLayer.new("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --3依次翻牌

                ----翻第一张牌
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
                --end)
                ----翻第二张牌
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
                --end)
                ----翻第三张牌
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
                --
                --end)
                
                local funcLict = {} 

                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                        local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                        answerPanelImg:setScale(0.1)
                        answerPanelImg:runAction(cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey)))
                        if self.selectedTag == i and self.duiEffect ~= nil then
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
                    self.proxy:onTriggerNet370100Req()
                end)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                seletAnswerPanelImg:runAction(cc.Sequence:create(dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3],dt2,refreshFunc))
            end

        elseif answerNum > #curQuestionsInfos + 1 then
            self:showSysMessage(self:getTextWord(360005))
            self.proxy:onTriggerNet370100Req()
        else
            --处理题目信息

            local config = ConfigDataManager:getConfigById(ConfigData.SeniorQuConfig, curQuestionsInfos[answerNum])
            if self.newQuesStr  then
                self.oldQuesStr = self.newQuesStr
            end
            self.newQuesStr = config.question
            if self.oldQuesStr == nil then
                self.oldQuesStr = self.newQuesStr
                local questionLab = self.oldQuesPanel:getChildByName("questionLab")
                questionLab:setString(self.newQuesStr)

                local quesNumLab = self:getChildByName("topPanel/openningPanel/quesIndexLab")
                quesNumLab:setString(string.format(TextWords:getTextWord(360024), answerNum))
                self.showQuesNum = answerNum

                local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel1/wrongImg")
                wrongImg:setVisible(false)
                wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel2/wrongImg")
                wrongImg:setVisible(false)
                wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel3/wrongImg")
                wrongImg:setVisible(false)
                --第一次进来 第一名的信息
                if self.proxy:getCurPalaceExamNumOneInfo() then
                    self:palaceExamNumOneUpdate()
                end
            end
            --处理答案信息
            if self.newAnswerInfos  then
                self.oldAnswerInfos = self.newAnswerInfos
            end
            self.newAnswerInfos = self.proxy:packAnswerByQueNum(curQuestionsInfos[answerNum],2)
            if self.oldAnswerInfos == nil then
                self.oldAnswerInfos = self.newAnswerInfos
                for i=1,3 do
                    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .. "/answerPanelImg/answerLab")
                    answerLab:setString(self.newAnswerInfos[i].str)
                end
                --单题倒计时信息

                local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
                local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
                if self.isOnRank == 1 then
                    timePanel:setVisible(false)
                    timeNoAnswerPanel:setVisible(true)
                else
                    timePanel:setVisible(false)
                    timeNoAnswerPanel:setVisible(false)    
                end

            end


            --处理积分
            if self.newScore  then
                self.oldScore = self.newScore
            end
            self.newScore = self.proxy:getCurPalaceIntegral()
            if self.oldScore == nil then
                self.oldScore = self.newScore
                local sumScoreLab = self:getChildByName("topPanel/openningPanel/sumScoreLab")
                sumScoreLab:setString(self.newScore)
            end
            --处理总耗时
            if self.newUseTime  then
                self.oldUseTime = self.newUseTime
            end
            self.newUseTime = self.proxy:getCurPalaceUseTime()
            if self.oldUseTime == nil then
                self.oldUseTime = self.newUseTime
                local sumUseTimeLab = self:getChildByName("topPanel/openningPanel/sumUseTimeLab")
                sumUseTimeLab:setString(self.newUseTime)
            end


            --转下一题的特效
            if self.alreadyPass == true then
            self.isAnswering = true
            --先去掉选中框
                for i = 1, 3 do
                    local selectedImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .. "/answerPanelImg/itemImg/selectedImg")
                    selectedImg:setVisible(false)
                    local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/wrongImg")
                    wrongImg:setVisible(false)
                end
                --if self.xuanzhongEffect ~= nil then
                --    self.xuanzhongEffect:finalize()
                --    self.xuanzhongEffect = nil
                --end
            --答题滑动动画(四部曲)
                --1新题
                local questionLab = self.newQuesPanel:getChildByName("questionLab")
                questionLab:setString(self.newQuesStr)
                --2新旧Panel移动
                local time = 0.5
                local conSize = self.quesPanel:getContentSize()
                local offset = conSize.height
                local target = cc.p(0, -offset)
                local move1 = cc.MoveBy:create(time, target)
                local move2 = cc.MoveBy:create(time, target)
                local function moveCallback()
                    self.alreadyPass = false
                    --3改变旧题的位置
                    self.oldQuesPanel:setPositionY(offset)
                    --4交换新旧panel指向
                    self.newQuesPanel,self.oldQuesPanel = self.oldQuesPanel,self.newQuesPanel 
                    
                     --积分跟随刷新
                    local sumScoreLab = self:getChildByName("topPanel/openningPanel/sumScoreLab")
                    sumScoreLab:setString(self.newScore)
                    local Image_12 = self:getChildByName("topPanel/Image_12")
                    local aEffect = self:createUICCBLayer("rgb-kjks-guang", Image_12, nil, nil, true)
                    local size = Image_12:getContentSize()
                    aEffect:setPosition(size.width*0.5,size.height - 70)
                   -- aEffect:setPosition(size.width*0.44,-size.height*0.28)
                    aEffect:setLocalZOrder(10)

                    --耗时跟随刷新

                    local sumUseTimeLab = self:getChildByName("topPanel/openningPanel/sumUseTimeLab")
                    sumUseTimeLab:setString(self.newUseTime)


                    local aEffect2 = self:createUICCBLayer("rgb-kjks-guang", Image_12, nil, nil, true)
                    aEffect2:setPosition(size.width*0.5,size.height - 70)
                    aEffect2:setLocalZOrder(10)


                    local quesNumLab = self:getChildByName("topPanel/openningPanel/quesIndexLab")
                    quesNumLab:setString(string.format(TextWords:getTextWord(360024), answerNum))
                    self.showQuesNum = answerNum

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
                    quesTime = 1.5
                elseif self.answerState == 1 then
                    quesTime = 1.5
                else 
                    quesTime = 1.8
                end
                local dt = cc.DelayTime:create(quesTime)
                local act1 = cc.Spawn:create(cc.FadeIn:create(time * 2), move1)
                local act2 = cc.Spawn:create(cc.FadeOut:create(time - 0.3), move2)
                self.newQuesPanel:runAction((cc.Sequence:create(dt, cc.FadeOut:create(0.0001), act1, cc.CallFunc:create(moveCallback))))
                self.oldQuesPanel:runAction(cc.Sequence:create(dt,act2))
            end


            --没有答题特效(没答题也给他显示正确答案)
            if self.answerState == 0 then
                --1显示正确金色外框特效
                local correctTag = self:getCorrectAnswerTag(self.oldAnswerInfos,self.showQuesNum)

                local cafunc2 = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. correctTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --2依次翻牌

                ----翻第一张牌
                --local fanpaiFunc1 = cc.CallFunc:create(function ()
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                --
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[1].str)
                --
                --    if correctTag == 1 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --end)
                ----翻第二张牌
                --local fanpaiFunc2 = cc.CallFunc:create(function ()
                --
                --    --local orbitCamera = cc.OrbitCamera:create(0.1, 1, 0, 0,89, 90, 0)
                --    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg")
                --    --answerPanelImg:runAction(cc.Sequence:create(orbitCamera,orbitCamera:reverse()))
                --    answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.FadeIn:create(dey)))
                --
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[2].str)
                --
                --    if correctTag == 2 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --end)
                ----翻第三张牌
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
                --    --倒计时
                --    local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
                --    local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
                --
                --
                --    if correctTag == 3 and self.duiEffect ~= nil then
                --        self.duiEffect:finalize()
                --        self.duiEffect = nil
                --    end
                --    if self.isOnRank == 1 then
                --        timePanel:setVisible(false)
                --        timeNoAnswerPanel:setVisible(true)
                --    else
                --        timePanel:setVisible(false)
                --        timeNoAnswerPanel:setVisible(false)    
                --    end
                --
                --
                --end)
                
                local funcLict = {} 

                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                        local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                        local act = cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey))
                        answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.ScaleTo:create(0.0001, 0.1), act))
                        
                        local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .."/answerPanelImg/answerLab")
                        answerLab:setString(self.newAnswerInfos[i].str)

                        if correctTag == i and self.duiEffect ~= nil then
                            self.duiEffect:finalize()
                            self.duiEffect = nil
                        end

                        if correctTag == 3 then
                            --倒计时
                            local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
                            local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
                            if self.isOnRank == 1 then
                                timePanel:setVisible(false)
                                timeNoAnswerPanel:setVisible(true)
                            else
                                timePanel:setVisible(false)
                                timeNoAnswerPanel:setVisible(false)    
                            end
                        end

                    end)
                    funcLict[i] = func
                end

                local dt1 = cc.DelayTime:create(0.3)
                local dt2 = cc.DelayTime:create(1)
                local dt3 = cc.DelayTime:create(0.1)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg")
                seletAnswerPanelImg:runAction(cc.Sequence:create(dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3]))
            end

            
            --答错了特效
            if self.answerState == -1 then
                self.answerState = 0
                --1显示错误图标
                local cafunc1 = cc.CallFunc:create(function ()
                    local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg/itemImg/cuoImg")
                    cuoImg:setVisible(true)    
                    AudioManager:playEffect("yx_error")      
                end)
                local correctTag = self:getCorrectAnswerTag(self.oldAnswerInfos,self.showQuesNum)
                --2显示正确金色外框特效

                local cafunc2 = cc.CallFunc:create(function ()
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. correctTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --3依次翻牌

                ----翻第一张牌
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
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[1].str)
                --end)
                ----翻第二张牌
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
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[2].str)
                --end)
                ----翻第三张牌
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
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[3].str)
                --                        --倒计时
                --    local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
                --    local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
                --    if self.isOnRank == 1 then
                --        timePanel:setVisible(false)
                --        timeNoAnswerPanel:setVisible(true)
                --    else
                --        timePanel:setVisible(false)
                --        timeNoAnswerPanel:setVisible(false)    
                --    end
                --
                --end)
                
                local funcLict = {} 

                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                        local cuoImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/answerPanelImg/itemImg/cuoImg")
                        cuoImg:setVisible(false)
                        
                        local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel".. i .. "/wrongImg")
                        wrongImg:setVisible(false)

                        local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                        local act = cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey))
                        answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.ScaleTo:create(0.0001, 0.1), act))
                        
                        local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .."/answerPanelImg/answerLab")
                        answerLab:setString(self.newAnswerInfos[i].str)

                        if correctTag == i and self.duiEffect ~= nil then
                            self.duiEffect:finalize()
                            self.duiEffect = nil
                        end

                        if correctTag == 3 then
                            --倒计时
                            local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
                            local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
                            if self.isOnRank == 1 then
                                timePanel:setVisible(false)
                                timeNoAnswerPanel:setVisible(true)
                            else
                                timePanel:setVisible(false)
                                timeNoAnswerPanel:setVisible(false)    
                            end
                        end

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
                local scaleTo09 = cc.ScaleTo:create(0.1, 0.9)
                local scaleTo10 = cc.ScaleTo:create(0.05, 1.0)
                seletAnswerPanelImg:runAction(cc.Sequence:create(cafuncSelected, scaleTo09, scaleTo10, dt1,cafunc1,dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3]))

            end
            --答对了特效
            if self.answerState == 1 then
                self.answerState = 0
                --1显示正确金色外框特效
                local cafunc2 = cc.CallFunc:create(function ()
                    AudioManager:playEffect("yx_dianbing")
                    local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                    self.duiEffect = self:createUICCBLayer("rpg-kj-dui", answerPanelImg, nil, nil, true)
                    local size = answerPanelImg:getContentSize()
                    self.duiEffect:setPosition(size.width*0.5,size.height*0.508)
                    self.duiEffect:setLocalZOrder(10)

                end)
                --2依次翻牌

                ----翻第一张牌
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
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel1/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[1].str)
                --end)
                ----翻第二张牌
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
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel2/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[2].str)
                --end)
                ----翻第三张牌
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
                --    local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel3/answerPanelImg/answerLab")
                --    answerLab:setString(self.newAnswerInfos[3].str)
                --                        --倒计时
                --    local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
                --    local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
                --    if self.isOnRank == 1 then
                --        timePanel:setVisible(false)
                --        timeNoAnswerPanel:setVisible(true)
                --    else
                --        timePanel:setVisible(false)
                --        timeNoAnswerPanel:setVisible(false)    
                --    end
                --
                --end)
                
                local funcLict = {} 

                for i = 1, 3 do
                    local func = cc.CallFunc:create(function ()
                        local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. i)
                        local act = cc.Spawn:create(cc.ScaleTo:create(dey, 1.0), cc.FadeIn:create(dey))
                        answerPanelImg:runAction(cc.Sequence:create(cc.FadeOut:create(dey), cc.DelayTime:create(dey - 0.3), cc.ScaleTo:create(0.0001, 0.1), act))
                        
                        local answerLab = self:getChildByName("topPanel/answerPanel/answerPanel" .. i .."/answerPanelImg/answerLab")
                        answerLab:setString(self.newAnswerInfos[i].str)

                        if self.selectedTag == i and self.duiEffect ~= nil then
                            self.duiEffect:finalize()
                            self.duiEffect = nil
                        end

                        if self.selectedTag == 3 then
                            --倒计时
                            local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
                            local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
                            if self.isOnRank == 1 then
                                timePanel:setVisible(false)
                                timeNoAnswerPanel:setVisible(true)
                            else
                                timePanel:setVisible(false)
                                timeNoAnswerPanel:setVisible(false)    
                            end
                        end

                    end)
                    funcLict[i] = func
                end
                local dt1 = cc.DelayTime:create(0.3)
                local dt2 = cc.DelayTime:create(1)
                local dt3 = cc.DelayTime:create(0.1)
                local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
                seletAnswerPanelImg:runAction(cc.Sequence:create(dt1,cafunc2,dt2,funcLict[1],dt3,funcLict[2],dt3,funcLict[3]))
            end

        end

    end

end
--答题后显示选中特效
function PalaceExamAnswerPanel:showSelectEffect()
        --1缩小然后恢复
    local scaleto1 = cc.ScaleTo:create(0.1,0.8)
    local scaleto2 = cc.ScaleTo:create(0.05,1)
    --2显示正确金色外框特效
    local cafunc2 = cc.CallFunc:create(function ()
        --if self.xuanzhongEffect ~= nil then
        --    self.xuanzhongEffect:finalize()
        --    self.xuanzhongEffect = nil
        --end
        --local answerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
        --self.xuanzhongEffect = self:createUICCBLayer("rgb-kjks-xuanzhong", answerPanelImg, nil, nil, true)
        --local size = answerPanelImg:getContentSize()
        --self.xuanzhongEffect:setPosition(size.width*0.509,size.height*0.508)
        --self.xuanzhongEffect:setLocalZOrder(10)

        
       local selectedImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg/itemImg/selectedImg")
       selectedImg:setVisible(true)
       local wrongImg = self:getChildByName("topPanel/answerPanel/answerPanel".. self.selectedTag .. "/wrongImg")
       wrongImg:setVisible(true)
    end)
    local seletAnswerPanelImg = self:getChildByName("topPanel/answerPanel/answerPanel" .. self.selectedTag .. "/answerPanelImg")
    seletAnswerPanelImg:runAction(cc.Sequence:create(scaleto1,scaleto2,cafunc2))


    --答题后倒计时显示改变
    local timePanel = self:getChildByName("topPanel/answerPanel/timePanel")
    local timeNoAnswerPanel = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel")
    timePanel:setVisible(true)
    timeNoAnswerPanel:setVisible(false)

end
function PalaceExamAnswerPanel:update()
    self._waitPalaceExamRemainTime = self.proxy:getRemainTime("StartPalaceExam_RemainTime")
    local countDownLab = self:getChildByName("topPanel/readyPanel/countDownPanel/countDownLab")
    if self._waitPalaceExamRemainTime > 0 then
    	local timeStr = TimeUtils:getStandardFormatTimeString(self._waitPalaceExamRemainTime)
        countDownLab:setString(timeStr)
	else
		countDownLab:setString(0)
	end


    self._singlePalaceExamRemainTime = self.proxy:getRemainTime("SinglePalaceExam_RemainTime")
    local oneLastTimeLab = self:getChildByName("topPanel/answerPanel/timePanel/oneLastTimeLab")
    local oneLastTimeLab2 = self:getChildByName("topPanel/answerPanel/timeNoAnswerPanel/oneLastTimeLab")
    if self._singlePalaceExamRemainTime > 0 then
    	--local timeStr = TimeUtils:getStandardFormatTimeString(self._singleProvExamRemainTime)
        oneLastTimeLab:setString(self._singlePalaceExamRemainTime)
        oneLastTimeLab2:setString(self._singlePalaceExamRemainTime)
        --print("self._singlePalaceExamRemainTime =")
        --print(self._singlePalaceExamRemainTime)
	else
		oneLastTimeLab:setString("0")
        --print("self._singlePalaceExamRemainTime = 0")
	end

end
function PalaceExamAnswerPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {}
    for i=1,8 do
        lines[i] = {{content = TextWords:getTextWord(363000 + i), foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    end
    uiTip:setAllTipLine(lines)
end
function PalaceExamAnswerPanel:onAnswerBtnHandler(sender)
    if self.isOnRank == 1 then
        if self.proxy:getStateOfAnswerPalaceExam() == 1 then
            self:showSysMessage(self:getTextWord(360013))
        else
            if self.isAnswering == true then
                self:showSysMessage(self:getTextWord(360009))
            else
                local sendData = {}
                sendData.result = self.newAnswerInfos[sender.tag].id
                sendData.sort = self.proxy:getAnswerNumPalaceExam()
                --记录已经选定的选项 1为A,2为B,3为C
                self.selectedTag = sender.tag
                self.proxy:onTriggerNet370102Req(sendData)
            end
        end

        
    else
        self:showSysMessage(self:getTextWord(360012))
    end

end


function PalaceExamAnswerPanel:changeUIwithState(state)
    self.noOpenPanel:setVisible(false)
    self.readyPanel:setVisible(false)
    self.openningPanel:setVisible(false)
    self.answerPanel:setVisible(false)
    if state ==  0  or state ==  3 then
        self.noOpenPanel:setVisible(true)
    elseif state ==  1 then
        self.readyPanel:setVisible(true)
    elseif state ==  2 then
        self.openningPanel:setVisible(true)
        self.answerPanel:setVisible(true)
    end
end
function PalaceExamAnswerPanel:palaceExamHadAnswer(rs)
    if rs == 0 then
        self.answerState = 1
    elseif rs == 1 then
        self.answerState = -1
    end
    print("come---from--370102")
    self:showSelectEffect()
end
function PalaceExamAnswerPanel:palaceExamPassQues()
    self.alreadyPass = true
end
--获得正确答案坐在的选项tag(info答案信息，showQuesNum显示第几题)
function PalaceExamAnswerPanel:getCorrectAnswerTag(info,showQuesNum)
    local tag
    local trueTag = self.proxy:getTrueAnswerNumByShowQuesNum(showQuesNum,2)
    for i,v in ipairs(info) do
        if v.id == trueTag then
            tag = i
            break
        end
    end
    return tag
end
function PalaceExamAnswerPanel:palaceExamNoAnswerTip()
    self.answerState = 0
    -- self:showSysMessage(self:getTextWord(360002))
end
--第一名信息变更刷新
function PalaceExamAnswerPanel:palaceExamNumOneUpdate() 
    local numOneInfo = self.proxy:getCurPalaceExamNumOneInfo()
    local numOneNameLab = self:getChildByName("topPanel/openningPanel/numOnePanel/NumOneNameLab")
    local staLab = self:getChildByName("topPanel/openningPanel/numOnePanel/Label_55")
    

    local numOnePanel = self:getChildByName("topPanel/openningPanel/numOnePanel")
    if numOneInfo and self.isOnRank == 1 then
        numOnePanel:setVisible(true)
        numOneNameLab:setString("  " .. numOneInfo.firstNameStr .. "(" .. numOneInfo.firstScoreNum .. ")")
        --[[
        staLab:setContentSize(cc.size(80 + numOneNameLab:getContentSize().width, staLab:getContentSize().height))
        numOneNameLab:setPositionX(staLab:getPositionX()-staLab:getContentSize().width/2+80)
        ]]
        local widthAll =  staLab:getContentSize().width + numOneNameLab:getContentSize().width
        local parentWidth = self.openningPanel:getContentSize().width
        staLab:setPositionX(parentWidth/2-widthAll/2)
        numOneNameLab:setPositionX(staLab:getPositionX()+staLab:getContentSize().width)


    else
        numOnePanel:setVisible(false)
    end

end
