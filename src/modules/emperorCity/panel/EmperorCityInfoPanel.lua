-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorCityInfoPanel = class("EmperorCityInfoPanel", BasicPanel)
EmperorCityInfoPanel.NAME = "EmperorCityInfoPanel"

function EmperorCityInfoPanel:ctor(view, panelName)
    EmperorCityInfoPanel.super.ctor(self, view, panelName)

end

function EmperorCityInfoPanel:finalize()
    EmperorCityInfoPanel.super.finalize(self)
end

function EmperorCityInfoPanel:initPanel()
	EmperorCityInfoPanel.super.initPanel(self)

    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
    self._roleProxy = self:getProxy(GameProxys.Role)
end

function EmperorCityInfoPanel:registerEvents()
	EmperorCityInfoPanel.super.registerEvents(self)
    self._bottomPanel = self:getChildByName("bottomPanel")
    self._listView = self:getChildByName("listView")

    self._reportBtn = self._bottomPanel:getChildByName("reportBtn") -- 历史战绩
    self._powerBtn = self._bottomPanel:getChildByName("powerBtn") -- 皇权

    self:addTouchEventListener(self._reportBtn, self.onReportBtn)
    self:addTouchEventListener(self._powerBtn, self.onPowerBtn) -- 皇权按钮未开放
end

function EmperorCityInfoPanel:doLayout()
   local tabPanel = self:getTabsPanel()
   NodeUtils:adaptiveListView(self._listView, self._bottomPanel, tabPanel, GlobalConfig.topTabsHeight)
end

function EmperorCityInfoPanel:onShowHandler(data)
    -- self:onUpdateInfoPanel()

    self._listView:setVisible(false)
end

-- 刷新界面
function EmperorCityInfoPanel:onUpdateInfoPanel()
    -- 领取时间
    self._nextRewardTime = self:getNextRewardTime()

    self._listView:setVisible(true)
    self._listData = self._emperorCityProxy:getCityStateInfoList()
    
    table.sort(self._listData, 
    function(item1, item2)
        return item1.cityInfo.cityId > item2.cityInfo.cityId
    end)

    -- 渲染列表
    self:renderListView(self._listView, self._listData, self, self.renderItem, nil, nil, 0)

    -- 战绩红点
    self:updateReportBtnRedPoint()
end

function EmperorCityInfoPanel:renderItem(itemPanel, data, index)
    index = index + 1
    local cityImg = itemPanel:getChildByName("cityImg")
    local nameImg = itemPanel:getChildByName("nameImg")
    local stateImg= itemPanel:getChildByName("stateImg")
    local legionTxt     = itemPanel:getChildByName("legionTxt")   
    local jobBuffTxt    = itemPanel:getChildByName("jobBuffTxt")   
    local rewardTxt     = itemPanel:getChildByName("rewardTxt")    
    local legionNameTxt = itemPanel:getChildByName("legionNameTxt")
    local jobBuffNumTxt = itemPanel:getChildByName("jobBuffNumTxt")
    local rewardTimeTxt = itemPanel:getChildByName("rewardTimeTxt")
    local goBtn         = itemPanel:getChildByName("goBtn")
    local getBtn        = itemPanel:getChildByName("getBtn")       
    local hitBtn        = itemPanel:getChildByName("hitBtn")       
    local resPanel      = itemPanel:getChildByName("resPanel")
    resPanel:setVisible(false)
    
    local cityInfo = data.cityInfo -- 皇城信息
    local officeBuff = data.officeBuff -- 官职加成
    local nextRewardTime = self._nextRewardTime -- 下次领取奖励时间点
    local rewardState = data.rewardState -- 领取状态，0不可领取，1可领取，2已领取
     
    local cityId     = cityInfo.cityId -- id
    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarConfig, cityId)

    -- 底下收益显示
    local rewardData = StringUtils:jsonDecode( configInfo.occupyBuff)
    self:setResPanel(resPanel, rewardData)

    -- 期间状态标志
    local cityStatus = self:getCityStatus(cityInfo.cityStatus, cityInfo.legionName) 
    if cityStatus == 2 then
        stateImg:setVisible(false)
    else
        stateImg:setVisible(true)
        local stateUrl   = "images/emperorCityIcon/font_status"..cityStatus..".png"
        TextureManager:updateImageView(stateImg, stateUrl)
    end
    

    -- 艺术字icon
    local id       = configInfo.ID
    local cityType = configInfo.type 
    TextureManager:updateImageView(nameImg, "images/emperorCityIcon/font_city_name"..id..".png")
    TextureManager:updateImageView(cityImg, "images/emperorCityIcon/icon_city"..cityType..".png")
    -- 文本
    if cityInfo.cityStatus == 2 then -- 归属期
        legionNameTxt:setString(cityInfo.legionName == "" and self:getTextWord(3108) or cityInfo.legionName) -- 归属
    else
        legionNameTxt:setString(self:getTextWord(3108))
    end
    
    jobBuffNumTxt:setString(officeBuff.."%") -- 官职
    jobBuffTxt:setVisible(false)
    jobBuffNumTxt:setVisible(false)

    rewardTimeTxt:setString(nextRewardTime) -- 下次领取


    -- 领取按钮，下次领取显示 1-未开放, 2-休战期(归属期), 3准备期(保护), 4-争夺期 
    if cityStatus == 22 then -- 2-休战期(22归属期)
        getBtn:setVisible(true)
        rewardTxt:setVisible(true)
        rewardTimeTxt:setVisible(true)
    else
        getBtn:setVisible(false)
        rewardTxt:setVisible(false)
        rewardTimeTxt:setVisible(false)
    end
    getBtn:setVisible(false)
    rewardTxt:setVisible(false)
    rewardTimeTxt:setVisible(false)
    
    -- 前往与攻打按钮
    if cityStatus == 4 then
        hitBtn:setVisible(true)
        goBtn:setVisible(false)
    else
        hitBtn:setVisible(false)
        goBtn:setVisible(true)
    end

    -- 前往按钮的位置调整
    if goBtn:isVisible() and hitBtn:isVisible() == false and getBtn:isVisible() == false then
        goBtn:setPositionY(115)
    else
        goBtn:setPositionY(142)
    end

    -- 添加数据
    goBtn.configInfo = configInfo
    getBtn.cityId = cityId
    hitBtn.configInfo = configInfo

    -- 按钮响应todocity
    self:addTouchEventListener(goBtn , self.onGoBtn )
    self:addTouchEventListener(getBtn, self.onGetBtn)
    self:addTouchEventListener(hitBtn, self.onHitBtn)

    -- 领取按钮
    self:setGetBtn(getBtn, rewardState)
end

-- 设置资源显示
function EmperorCityInfoPanel:setResPanel(resPanel, data)
    
    local warBuffId = data[1]
    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarBuffConfig, warBuffId)
    local buffInfo = StringUtils:jsonDecode(configInfo.buffInfo)

    --for i = 1 , #buffInfo do
    --    local info = buffInfo[i]

    --    local power  = info[1]
    --    local typeId = info[2]
    --    local num    = info[3]

    --    local node     = resPanel:getChildByName("img0"..(typeId - 200))
    --    local valueTxt = node:getChildByName("valueTxt")

    --    local numStr = StringUtils:formatNumberByK3(num)
    --    valueTxt:setString(string.format("%s/H", numStr))
    --    -- 位置
    --    --NodeUtils:fixTwoNodePos(nameTxt, valueTxt, -10)
    --end
end


function EmperorCityInfoPanel:onReportBtn(sender)
    logger:info("点击查看历史战绩")
    -- 加入同盟才可查看战绩
    local myLegionName = self._roleProxy:getLegionName()
    if myLegionName == "" then
        self:showSysMessage(self:getTextWord(915))
        return 
    end
    self._emperorCityProxy:onTriggerNet550002Req({})
end

function EmperorCityInfoPanel:onPowerBtn(sender)
    logger:info("点击皇权")
    -- 屏蔽检查
    if self:getProxy(GameProxys.Country):getIsOpen() == 0 then
        self:showSysMessage(self:getTextWord(821))
        return
    end

    local sendData = {}
    sendData.moduleName = "CountryModule"

    

    self:dispatchEvent(EmperorCityEvent.SHOW_OTHER_EVENT, sendData)
end

function EmperorCityInfoPanel:onGoBtn(sender)
    logger:info("前往")
    local configInfo = sender.configInfo

    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    data.extraMsg.tileX = configInfo.dataX
    data.extraMsg.tileY = configInfo.dataY
    self:dispatchEvent(EmperorCityEvent.GOTO_MAPPOS_REQ, data)
end

function EmperorCityInfoPanel:onGetBtn(sender)
    logger:info("领取")
    local cityId = sender.cityId
    local data = {}
    data.cityId = cityId
    self._emperorCityProxy:onTriggerNet551001Req(data)
end

function EmperorCityInfoPanel:onHitBtn(sender)

    logger:info("前往攻打")
    local configInfo = sender.configInfo

    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    data.extraMsg.tileX = configInfo.dataX
    data.extraMsg.tileY = configInfo.dataY
    self:dispatchEvent(EmperorCityEvent.GOTO_MAPPOS_REQ, data)
end

-- 回调打开皇城排行界面
function EmperorCityInfoPanel:onOpenReport()
    local data = {}
    data.moduleName = ModuleName.EmperorReportModule
    self:dispatchEvent(EmperorCityEvent.SHOW_OTHER_EVENT, data)
end

-- 获取下次奖励时间
function EmperorCityInfoPanel:getNextRewardTime()
    local timeNumber = 10
    local configData = ConfigDataManager:getConfigData(ConfigData.EmperorWarPointRewardConfig)
    local curHour = os.date("%H", GameConfig.serverTime) -- 最新的服务器时间
    logger:info(TimeUtils:setTimestampToString6(GameConfig.serverTime))
    curHour = tonumber(curHour)
    local timeNum = {10, 18, 22} 
    for i = 1, #timeNum do 
        if curHour < timeNum[1] then -- 还没到10点
            timeNumber = timeNum[1]
        elseif curHour >= timeNum[1] and curHour < timeNum[2] then
            timeNumber = timeNum[2]
        elseif curHour >= timeNum[2] and curHour < timeNum[3] then
            timeNumber = timeNum[3]
        end
    end

    return string.format("%s：00", timeNumber)
end

-- 状态标志id
function EmperorCityInfoPanel:getCityStatus(cityStatus, legionName)
    local myLegionName = self._roleProxy:getLegionName()
    if myLegionName == legionName and myLegionName ~= "" then
        if cityStatus == 3 then
            cityStatus = 33 -- 保护期
        end
        if cityStatus == 2 then
            cityStatus = 22 -- 归属期
        end

    end
    return cityStatus
end


-- 领取按钮
function EmperorCityInfoPanel:setGetBtn(getBtn, rewardState)
    if rewardState == 1 then
        getBtn:setTitleText(TextWords:getTextWord(230144)) -- "可领取"
        NodeUtils:setEnable(getBtn, true)
    elseif rewardState == 2 then
        getBtn:setTitleText(TextWords:getTextWord(230143)) -- "已领取"
        NodeUtils:setEnable(getBtn, false)
    else
        getBtn:setTitleText(TextWords:getTextWord(18003))
        NodeUtils:setEnable(getBtn, false)
    end

    -- 领取按钮的红点
    local redImg = getBtn:getChildByName("redImg")
    -- local numTxt = redImg:getChildByName("numTxt")

    if rewardState == 1 then
        redImg:setVisible(true)
    else
        redImg:setVisible(false)
    end
end

function EmperorCityInfoPanel:onTabChangeEvent()
    self:onUpdateInfoPanel()
end

------
-- 战绩红点
function EmperorCityInfoPanel:updateReportBtnRedPoint()
    local unreadNum = self._emperorCityProxy:getUnreadReportNum()
    local redImg = self._reportBtn:getChildByName("redImg")
    redImg:setVisible(unreadNum ~= 0)
    if redImg:isVisible() then
        local numTxt = redImg:getChildByName("numTxt")
        numTxt:setString(unreadNum)
    end
end