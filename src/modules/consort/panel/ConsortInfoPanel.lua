
ConsortInfoPanel = class("ConsortInfoPanel", BasicPanel)
ConsortInfoPanel.NAME = "ConsortInfoPanel"

function ConsortInfoPanel:ctor(view, panelName)
    ConsortInfoPanel.super.ctor(self, view, panelName)

end

function ConsortInfoPanel:finalize()

    if self._ccbRenWu ~= nil then
        self._ccbRenWu:finalize()
        self._ccbRenWu = nil
    end

    if self._ccbRenWuH ~= nil then
        self._ccbRenWuH:finalize()
        self._ccbRenWuH = nil
    end

    if self._panelProgress ~= nil then
        for i = 1, 5 do
            if self._panelProgress[i].ccb ~= nil then
                self._panelProgress[i].ccb:finalize()
                self._panelProgress[i].ccb = nil
            end
        end
        self._panelProgress = nil
    end
    if self._tasselEffect ~= nil then
        self._tasselEffect:finalize()
        self._tasselEffect = nil
    end

    ConsortInfoPanel.super.finalize(self)
end

function ConsortInfoPanel:initPanel()
    ConsortInfoPanel.super.initPanel(self)

    self._proxy = self:getProxy(GameProxys.Consort)

    -- info面板
    self._panelInfor = self:getChildByName("panelInfor")
    self._imgInfoBg2 = self._panelInfor:getChildByName("imgInfoBg2")    
    self._txtTime = self._imgInfoBg2:getChildByName("txtTime")
    self._txtDesc = self._imgInfoBg2:getChildByName("txtDesc")
    self._txtDesc:setColor(cc.c3b(244,244,244))
    

    -- 军师面板
    self._panelConsigliere = self._panelInfor:getChildByName("panelConsigliere")

    self._imgName = self._panelConsigliere:getChildByName("imgName")
    self._imgNpcImg = self._panelConsigliere:getChildByName("imgNpcImg")
    

    -- 属性UI
    self._uiPropertys = { }
    for i = 1, 4 do
        -- 属性图片
        local uiProperty = self._panelConsigliere:getChildByName("imgProperty" .. i)
        uiProperty.img = uiProperty:getChildByName("img")

        -- 属性值
        uiProperty.richTxt = ComponentUtils:createRichLabel("", nil, nil, 2)
        local lab = uiProperty:getChildByName("lab")
        lab:addChild(uiProperty.richTxt)

        self._uiPropertys[i] = uiProperty
    end

    -- 技能UI
    self._richTxtSkill = { }
    for i = 1, 2 do
        self._richTxtSkill[i] = ComponentUtils:createRichLabel("", nil, nil, 2)
        local lab = self._panelConsigliere:getChildByName("txtSkill" .. i)
        lab:addChild(self._richTxtSkill[i])
    end

   

    -- 动画UI
    self._panelAnima = self._panelInfor:getChildByName("panelAnima")

    self._panelAnimaClose = self._panelAnima:getChildByName("panelAnimaClose")
    self:addTouchEventListener(self._panelAnimaClose, self.onCloseAnima)

    self._anima = { }
    self._anima[1] = { }
    self._anima[1][1] = self._panelAnima:getChildByName("consigItem1")
    self._anima[5] = { }
    for i = 1, 5 do
        self._anima[5][i] = self._panelAnima:getChildByName("consigItem5_" .. i)
    end

    -- 礼贤消耗UI
    self._panelBtn = self._panelInfor:getChildByName("panelBtn")

     -- 亲密度进度UI
    self._panelProgress = { }
    for i = 1, 5 do
        local panelProgress = { }
        panelProgress = self._panelBtn:getChildByName("panelProgress" .. i)
        panelProgress.img = panelProgress:getChildByName("imgYu")
        panelProgress.initWidth = panelProgress:getContentSize().width
        panelProgress.initHeight = panelProgress:getContentSize().height
        panelProgress.initY = panelProgress:getPositionY()
        panelProgress.ccb = nil
        self._panelProgress[i] = panelProgress
    end


    self._txtIntimacy = self._panelBtn:getChildByName("txtIntimacy")
    self._ProgressBar = self._panelBtn:getChildByName("progressBar")

    self._imgGoldOne = self._panelBtn:getChildByName("imgGoldOne")
    self._imgGoldTen = self._panelBtn:getChildByName("imgGoldTen")
    self._txtGoldOne = self._panelBtn:getChildByName("txtGoldOne")
    self._txtGoldTen = self._panelBtn:getChildByName("txtGoldTen")
    self._labFree = self._panelBtn:getChildByName("labFree")

    self._btnOne = self._panelBtn:getChildByName("btnOne")
    self:addTouchEventListener(self._btnOne, self.onConsortOne)

    self._btnFive = self._panelBtn:getChildByName("btnFive")
    self:addTouchEventListener(self._btnFive, self.onConsortFive)

    
end

function ConsortInfoPanel:registerEvents()
    ConsortInfoPanel.super.registerEvents(self)
end

function ConsortInfoPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self._panelInfor, nil, GlobalConfig.downHeight, tabsPanel, 3)
end

function ConsortInfoPanel:update()

end

function ConsortInfoPanel:onClosePanelHandler()
    self:dispatchEvent(ConsortEvent.HIDE_SELF_EVENT)
end

function ConsortInfoPanel:onShowHandler()
    local parent = self:getParent()
    if parent.infoPanel ~= nil then
        parent.infoPanel:hide()
    end

    self._curActivityId = self._proxy:getCurActivityId();

    self:switchInforOrAnima(true)

    self:updateUI()
end


function ConsortInfoPanel:updateUI()    
    self:updateBaseInfor()

    self:updateFree()

    self:updateProgress()
end


function ConsortInfoPanel:updateBaseInfor()
    -- 礼贤下士活动配置
    local courteousData = self._proxy:getCurConsortCfgData()

    -- 消耗
    self._txtGoldOne:setString(courteousData.onePrice)
    self._txtGoldTen:setString(courteousData.fivePrice)
    self._btnOne.money = courteousData.onePrice
    self._btnFive.money = courteousData.fivePrice

    if self._ccbRenWu == nil then
        local x, y = self._imgNpcImg:getPosition()
        self._ccbRenWu = self:createUICCBLayer("rgb-lxxs-renwu", self._panelConsigliere)        
        self._ccbRenWu:setPosition(x, y - 46)
        self._ccbRenWu:setLocalZOrder(3)

    end
    
    if self._ccbRenWuH == nil then
        local x, y = self._imgNpcImg:getPosition()
        self._ccbRenWuH = self:createUICCBLayer("rgb-lxxs-renwuh", self._panelConsigliere)        
        self._ccbRenWuH:setPosition(x, y - 46)
        self._ccbRenWuH:setLocalZOrder(1)
    end
    
    --流苏特效
    if self._tasselEffect == nil then
        local imgTassel = self._panelBtn:getChildByName("imgTassel")
        self._tasselEffect = self:createUICCBLayer("rgb-lxxs-diaozhui", imgTassel)
    end

    -- 谋士信息配置
    local assignInfo = StringUtils:jsonDecode(courteousData.assignID)
    local assignId = assignInfo[1]
    local counsellorData = ConfigDataManager:getConfigById(ConfigData.CounsellorConfig, assignId)

    -- 半身像和名字
    TextureManager:updateImageView(self._imgNpcImg, string.format("images/consort/%s_1.png", assignId), "images/consort/501_1.png")
    TextureManager:updateImageView(self._imgName, string.format("images/consort/%s_2.png", assignId), "images/consort/501_1.png")


    -- 带兵量
    self._uiPropertys[1].richTxt:setString( { { { self:getTextWord(430002), 18, ColorUtils.commonColor.FuBiaoTi}, { " +" .. counsellorData.command, 18, ColorUtils.commonColor.Green} } })

    -- 属性
    local propertys = StringUtils:jsonDecode(counsellorData.property)
    local index = 2
    for k, v in pairs(propertys) do
        local uiProperty = self._uiPropertys[index]
        if uiProperty == nil then
            break
        end

        uiProperty:setVisible(true)

        local resourceData = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, v[1])
        uiProperty.richTxt:setString( { { { resourceData.name .. ":", 18, ColorUtils.commonColor.FuBiaoTi}, { " +" ..(v[2] / 100) .. "%", 18, ColorUtils.commonColor.Green} } })

        local url = string.format("images/consort/%s.png", v[1])
        TextureManager:updateImageView(uiProperty.img, url, "images/consort/0.png")

        index = index + 1
    end

    local maxPropertyUICount = #self._uiPropertys
    for i = index, maxPropertyUICount do
        self._uiPropertys[index]:setVisible(false)
    end

    -- 技能
    index = 1
    local maxSkillUICount = 2
    local skillIDs = StringUtils:jsonDecode(counsellorData.skillID)
    for k, v in pairs(skillIDs) do
        local skillData = ConfigDataManager:getConfigById(ConfigData.CounsellorSkillConfig, v)
        self._richTxtSkill[index]:setString( { { { skillData.name, 18 }, { "  " .. skillData.info, 18, ColorUtils.commonColor.MiaoShu} } })
        self._richTxtSkill[index]:setVisible(true)
        index = index + 1
    end
    for i = index, maxSkillUICount do
        self._richTxtSkill[index]:setVisible(false)
    end

    -- 活动时间
    local activityProxy = self:getProxy(GameProxys.Activity)
    local activityData = activityProxy:getLimitActivityDataByUitype(ActivityDefine.LIMIT_CONSORT_ID)
    -- local startTime = TimeUtils:setTimestampToString(activityData.startTime)
    -- local endTime = TimeUtils:setTimestampToString(activityData.endTime)
    -- self._txtTime:setString(startTime .. "  -  " .. endTime)
    self._txtTime:setString(TimeUtils.getLimitActFormatTimeString(activityData.startTime,activityData.endTime,true))

    -- 描述
    local desc = string.format(self:getTextWord(430003), counsellorData.name,self:getTextWord(260004))
    self._txtDesc:setString(desc)
end


function ConsortInfoPanel:updateFree()
    -- 是否有免费
    local isFree = self._proxy:isHasFreeTimes(self._curActivityId)
    self._imgGoldOne:setVisible(not isFree)
    self._txtGoldOne:setVisible(not isFree)
    self._labFree:setVisible(isFree)
    if isFree then
        TextureManager:updateButtonNormal(self._btnOne, "images/newGui1/BtnMaxGreen1.png")
    else
        TextureManager:updateButtonNormal(self._btnOne, "images/newGui1/BtnMaxYellow1.png")
    end
end

function ConsortInfoPanel:updateProgress()
    -- 礼贤下士活动配置
    local courteousData = self._proxy:getCurConsortCfgData()

    local maxYuCount = 5
    -- 密度上限
    local maxIntimate = courteousData.intimateLimit
    -- 当前亲密度
    local curIntimate = self._proxy:getIntimate(self._curActivityId)
    -- 一块玉的进度上限
    local maxYuProgress = maxIntimate / maxYuCount

    -- 设置亲密度
    self._txtIntimacy:setString( curIntimate .. " / " .. maxIntimate )

    --进度条
    local percent = curIntimate / maxIntimate * 100
    if percent < 0 then
        percent = 0
    end
    self._ProgressBar:setPercent(percent)

    local index = 1
    -- 满了的玉
    local fullCount = math.floor(curIntimate / maxYuProgress)
    for i = 1, fullCount do
        local progress = self._panelProgress[i]
        progress:setContentSize(progress.initWidth, progress.initHeight)
        progress:setVisible(true)
        if progress.ccb == nil then
            local x, y = progress:getPosition()
            local size = progress:getContentSize()
            --progress.ccb = self:createUICCBLayer("rgb-lxxs-yupei", self._panelBtn)
            --progress.ccb:setPosition(x + size.width / 2, y + size.height / 2)
            progress.ccb = self:createUICCBLayer("rgb-lxxs-yupei", progress)
            progress.ccb:setPosition(size.width / 2, size.height / 2)
            progress.ccb:setLocalZOrder(10)
        else
            progress.ccb:setVisible(true)
        end
        index = index + 1
    end

    -- 没满的玉
    if index <= maxYuCount then
        local curYuProgress = curIntimate % maxYuProgress
        if curYuProgress ~= 0 then
            local progress = self._panelProgress[index]
            progress:setVisible(true)
            if progress.ccb ~= nil then
                progress.ccb:setVisible(true)
            else
                local x, y = progress:getPosition()
                local size = {width = 50, height  = 50}--写死特效大小
                --progress.ccb = self:createUICCBLayer("rgb-lxxs-yupei", self._panelBtn)
                --progress.ccb:setPosition(x + size.width / 2, y + size.height / 2)
                progress.ccb = self:createUICCBLayer("rgb-lxxs-yupei", progress)
                progress.ccb:setPosition(size.width / 2, size.height / 2)
                progress.ccb:setLocalZOrder(10)
            end
            local h = curYuProgress / maxYuProgress * progress.initHeight
            progress:setContentSize(progress.initWidth, h)
            --progress.ccb:setContentSize(progress.initWidth, h)
            index = index + 1
        end
    end

    -- 剩下的玉
    if index <= maxYuCount then
        for i = index, maxYuCount do
            local progress = self._panelProgress[i]
            progress:setContentSize(progress.initWidth, 0)
            progress:setVisible(false)
            if progress.ccb ~= nil then
                progress.ccb:setVisible(false)
            end
        end
    end

end

function ConsortInfoPanel:onConsortOne(sender)
    local isFree = self._proxy:isHasFreeTimes(self._curActivityId)
    if isFree == true then
        local activityId = self._proxy:getCurActivityId()
        self._proxy:onTriggerNet230041Req( { activityId = activityId, time = 1 })
    else
        self:Consort(1)
    end
end

function ConsortInfoPanel:onConsortFive(sender)
    self:Consort(5)
end

function ConsortInfoPanel:Consort(times)

    -- 礼贤需要的gold
    local consortCfg = self._proxy:getCurConsortCfgData()
    local needGold = 0
    if times == 1 then
        needGold = consortCfg.onePrice
    elseif times == 5 then
        needGold = consortCfg.fivePrice
    end

    -- 请求购买
    local function reqBuy()
        local activityId = self._proxy:getCurActivityId()
        self._proxy:onTriggerNet230041Req( { activityId = activityId, time = times })
    end


    local function showMessageBox()
        local messageBox = self:showMessageBox(string.format(self:getTextWord(430005), needGold, times), reqBuy)
        messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
    end
    
    self:isShowRechargeUI( { money = needGold, callFunc = showMessageBox })
       
end

function ConsortInfoPanel:isShowRechargeUI(data)
    local needMoney = data.money

    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
    -- 拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end
    else
        data.callFunc()
    end
end

-- 切换到信息或显示动画
function ConsortInfoPanel:switchInforOrAnima(isInfo)
    self._panelConsigliere:setVisible(isInfo)
    self._imgInfoBg2:setVisible(isInfo)
    self._panelAnima:setVisible(not isInfo)
end

function ConsortInfoPanel:playerAnima(data)    

    local ids = data    
    local consortType = #ids

    if consortType > 0 then
        self:switchInforOrAnima(false)
        self._panelAnimaClose:setTouchEnabled(false)
    else
        return
    end
    
    local consortCfg = self._proxy:getCurConsortCfgData()
    local assignId = consortCfg[1]
    
    for k, v in pairs(self._anima[1]) do
        v:setVisible(consortType == 1)
    end

    for k, v in pairs(self._anima[5]) do
        v:setVisible(consortType ~= 1)
    end
    
    for i = 1, consortType do
        local item = self._anima[consortType][i]

        item:setScale(0)
        ComponentUtils:renderConsigliereItem(item, ids[i])
        item:runAction(cc.Sequence:create(
        cc.DelayTime:create(i * 0.1),
        cc.CallFunc:create( function()
            if ids[i] == assignId then
                local effect = self:createUICCBLayer("rgb-lxxs-gchuxian", item:getParent(), nil, nil, true)
                effect:setPosition(item:getPositionX(), item:getPositionY() -30-60)
            else
                local effect = self:createUICCBLayer("rgb-jsf-zhaomuchuxian", item:getParent(), nil, nil, true)
                effect:setPosition(item:getPositionX(), item:getPositionY() -30-60)
            end
        end ),
        cc.EaseBackOut:create(cc.ScaleTo:create(0.25, 1)),
        cc.DelayTime:create(0.3),
        cc.CallFunc:create( function()
            self._panelAnimaClose:setTouchEnabled(true)
        end )
        ))
    end
end


function ConsortInfoPanel:onCloseAnima(sender)
    self:switchInforOrAnima(true)
end