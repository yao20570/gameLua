
LegionSceneHallPanel = class("LegionSceneHallPanel", BasicPanel)
LegionSceneHallPanel.NAME = "LegionSceneHallPanel"

function LegionSceneHallPanel:ctor(view, panelName)
    LegionSceneHallPanel.super.ctor(self, view, panelName)
    self.chatInfoNumber = 0
    self.allLen = 0
    
    self:setUseNewPanelBg(true)
end

function LegionSceneHallPanel:finalize()
    LegionSceneHallPanel.super.finalize(self)    
end

function LegionSceneHallPanel:initPanel()
    
    self._bigPanel = self:getChildByName("bigPanel") --upPanel
    self._topPanel = self._bigPanel:getChildByName("topPanel")
    self._infoPanel = self._topPanel:getChildByName("infoPanel")
    self._gongPanel = self._topPanel:getChildByName("gongPanel")
    self._mainPanelBg = self:getChildByName("bigPanel/mainPanelBg") --上部背景

    self._buildingModuleMap = {}
    self._buildingModuleMap[1] = ModuleName.LegionScienceTechModule     --科技大厅
    self._buildingModuleMap[2] = ModuleName.LegionHallModule            --军团大厅
    self._buildingModuleMap[3] = ModuleName.LegionWelfareModule         --福利院
    self._buildingModuleMap[4] = ModuleName.LegionAdviceModule          --情报所
    self._buildingModuleMap[5] = ModuleName.LegionShopModule            --军团商店
    self._buildingModuleMap[6] = ModuleName.LegionCombatCenterModule    --作战所
    self._buildingModuleMap[7] = ModuleName.LegionHelpModule            --互助
    self._buildingModuleMap[8] = ModuleName.LegionModule                --同盟设置
    self._buildingModuleMap[9] = ModuleName.LegionTaskModule            --同盟任务
    self._buildingModuleMap[10] = ModuleName.LegionCityModule           --同盟城池

    self._btnMap = {}
    self._btnMap[1] = self._mainPanelBg:getChildByName("scieneBtn")
    self._btnMap[2] = self._infoPanel:getChildByName("devoteBtn")
    self._btnMap[2]:setVisible(false)
    self._btnMap[3] = self._mainPanelBg:getChildByName("welfareBtn")
    self._btnMap[4] = self._mainPanelBg:getChildByName("infoBtn")
    self._btnMap[5] = self._mainPanelBg:getChildByName("shopBtn")
    self._btnMap[6] = self._mainPanelBg:getChildByName("battleBtn")
    self._btnMap[7] = self._mainPanelBg:getChildByName("helpBtn")
    self._btnMap[8] = self._mainPanelBg:getChildByName("setBtn")
    self._btnMap[9] = self._mainPanelBg:getChildByName("taskBtn")
    self._btnMap[10] = self._mainPanelBg:getChildByName("cityBtn")

    self:addBtnTouchEvent()
   
end
function LegionSceneHallPanel:registerEvents()
    --聊天
    local bottomPanel = self:getChildByName("bottomPanel")
    local chatPanel = bottomPanel:getChildByName("chatPanel")
    local chatItem = chatPanel:getChildByName("infoImg")

    self:addTouchEventListener(chatPanel, self.onChatBtnTouch)
    self:addTouchEventListener(chatItem, self.onChatBtnTouch)

    self.chatNumBg = chatItem:getChildByName("Image_66")
    self.chatNumBg:setVisible(false)
    self.chatNumTxt = self.chatNumBg:getChildByName("num")
    self:renderChatNum()
    self.talkTxt = chatPanel:getChildByName("talkTxt")
    self.talkNameTxt = chatPanel:getChildByName("talkNameTxt")

    local chatProxy = self:getProxy(GameProxys.Chat)
    self:updateChatInfos( {chatProxy:getLastChatInfo()} )

    local power = self._infoPanel:getChildByName("power")
    power:setString(self:getTextWord(141))
end

function LegionSceneHallPanel:updateChatInfos(chats)    
    if self.allLen == 0 then
        self.allLen = table.size(chats)
    else
        self.allLen = self.allLen + table.size(chats)
    end
    if chats[table.size(chats)] then
        self:updateChatLineInfo(chats[table.size(chats)])
    end
end

function LegionSceneHallPanel:updateChatLineInfo(chat)
    local chatProxy = self:getProxy(GameProxys.Chat)
    --self:renderChatNum(chatProxy:getAllNotRenderChatNum())
    self:renderChatNum(chatProxy:getAllReadChatNum())
    self.isCanDisappear = 0
    if chat.playerId ~= self._ID or chat.extendValue == 1 then
        self.chatInfoNumber = self.allLen
        if self.chatInfoNumber >= 5 then
            self.chatInfoNumber = 5
        end
    end
    --------jjjjj

    local context = chat.context
    if chat.contextType == 2 then --语音不显示内容
        context = ""
    end
 
    self.talkNameTxt:setVisible(false)

    -- talkNameTxt:setString(chat.name .. ":")
    self.talkNameTxt:setString("")
    self.talkTxt:setString("")

    local nameSize = self.talkNameTxt:getContentSize()
    local nameX = self.talkNameTxt:getPositionX()
    if StringUtils:isFixed64Zero(chat.playerId) == false and StringUtils:isGmNotice(chat.playerId) == false then
        local chatText = ""
        local redBag = nil
        if chat.extendValue ~= 1 and rawget(chat, "isShare") ~= true then
            --chatText = chat.name..":"..chat.context
            chatText = chat.context
        else
            redBag = RichTextMgr:getInstance():getNoticeParams(chat.context)
            if chat.extendValue == 1 then
                redBag[1].txt = redBag[1].txt..":"
            end
            --不能去掉，红包富文本带data字段会导致不能点击
            for k,v in pairs(redBag) do
                if rawget(v, "data") ~= nil then
                    redBag[k].data = nil
                end
                -- if rawget(v, "isUnderLine") ~= nil then
                --     redBag[k].isUnderLine = nil
                -- end
            end
        end

        chatText = StringUtils:formatShortContent(chatText, 20)
        local chatParams = ComponentUtils:getChatItem(chatText, 0.6)
        if chat.extendValue == 1 or rawget(chat, "isShare") then
            chatParams = redBag
        elseif chat.extendValue == 3 then 
            local p = {}
            p.txt = chat.name .. ":" ..TextWords:getTextWord(391009)
            table.insert(chatParams, 1, p)
        else
            local p = {}
            p.txt = chat.name .. ":"
            table.insert(chatParams, 1, p)
        end
        
        
        if self._chatItem == nil then
            self._chatItem = RichTextMgr:getInstance():getRich(chatParams, 320, nil, nil, nil, 2)
            self.talkNameTxt:getParent():addChild(self._chatItem)
        else
            self._chatItem:setData(chatParams)
        end
        self._chatItem:setVisible(true)
        self._chatItem:setAnchorPoint(0, 0.5)
        self._chatItem:setPosition(self.talkNameTxt:getPosition())
    else
        if self._chatItem ~= nil then
            self._chatItem:setVisible(false)
        end
        self.talkNameTxt:setVisible(true)
        local text = RichTextMgr:getInstance():getNoticeParams(chat.context, true)
        local labelText = chat.name..":"..text
        local chatText = StringUtils:formatShortContent(labelText, 20)
        self.talkNameTxt:setColor(ColorUtils.wordGreenColor)
        self.talkNameTxt:setString(chatText)
    end
end

--聊天跳转
function LegionSceneHallPanel:onChatBtnTouch()
    self.chatInfoNumber = 0
    self.chatNumBg:setVisible(false)
    self.chatNumTxt:setString("")
    self:hideChatContent()
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.ChatModule} )
end

--更新聊天的NUM
function LegionSceneHallPanel:onUpdateNoSeeChatNum(num)

    -- if self.chatNumTxt then
    --     if num > 0 then
    --         self.chatNumBg:setVisible(true)
    --         self.chatNumTxt:setString(num)
    --     else
    --         self.chatNumBg:setVisible(false)
    --         self.chatNumTxt:setString("")
    --     end
    -- end
end


function LegionSceneHallPanel:renderChatNum(param)
    local proxy = self:getProxy(GameProxys.Chat)
    local num = param or 0 

    -- if num > 0 then
    --     self.chatNumBg:setVisible(true)
    --     self.chatNumTxt:setString(num)
    -- else
    --     self.chatNumBg:setVisible(false)
    --     self.chatNumTxt:setString("")
    -- end
    
    self.chatNumBg:setVisible(false) --by zxq 聊天面板实时刷新，这里就不显示小红点了
end

function LegionSceneHallPanel:hideChatContent()
    self.allLen = 0
    self.talkNameTxt:setVisible(false)
    self.talkTxt:setVisible(false)
end


function LegionSceneHallPanel:addBtnTouchEvent()
    for i = 1,table.size(self._btnMap) do
        self._btnMap[i].index = i
        self:addTouchEventListener(self._btnMap[i], self.onClickItemGetBtn)
    end
end

function LegionSceneHallPanel:onClickItemGetBtn(sender)
   local index = sender.index
   local moduleName = self._buildingModuleMap[index]
   if moduleName ~= nil then
        if moduleName == ModuleName.LegionTaskModule then
            local mineInfo = self._legionProxy:getMineInfo()
            --local config = ConfigDataManager:getConfigById(ConfigData.MiscellanyConfig,1)

            local legionTaskOpenLvValue = ConfigDataManager:getInfoFindByOneKey(ConfigData.MiscellanyConfig,"describe","legionTaskOpenLv")

            if mineInfo.level < legionTaskOpenLvValue.number then
                self:showSysMessage(string.format(self:getTextWord(560202),legionTaskOpenLvValue.number))
                return
            end

            --打开界面  如果上次请求时间超过5分钟或者没有时间数据  则打开时请求
            local lastTime = self._legionProxy:getLastGetTaskInfoTime()
            if lastTime then 
            --打开界面请求数据
                local currentTime = os.time()
                if (currentTime - lastTime) > 300 then
                    self._legionProxy:onTriggerNet590000Req()
                end 
            else
                self._legionProxy:onTriggerNet590000Req()
            end 
        end 
       self:dispatchEvent(LegionSceneEvent.SHOW_OTHER_EVENT, {moduleName = moduleName})
   else
       self:showSysMessage(self:getTextWord(821))
   end
end

function LegionSceneHallPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    local bottomPanel = self:getChildByName("bottomPanel")
    local tigerPanel  = self:getChildByName("tigerPanel")

    NodeUtils:adaptiveTopPanelAndListView(self._bigPanel, nil, nil, tabsPanel)
    -- NodeUtils:adaptiveTopPanelAndListView(self._mainPanelBg, bottomPanel, GlobalConfig.downHeight, self._bigPanel)
    NodeUtils:adaptivePanelBg(tigerPanel, GlobalConfig.downHeight, self._bigPanel)
end


function LegionSceneHallPanel:onShowHandler()
    self._legionProxy = self:getProxy(GameProxys.Legion)
    self._legionProxy:onTriggerNet220600Req({})
end

-- 军团列表界面更新 来自协议220600的数据
function LegionSceneHallPanel:onLegionAllListResp(data)
    self:initPoint()
    self:onRenderHandler(data)
end

function LegionSceneHallPanel:onRenderHandler(data)

    -- table.sort(data, function(a,b) return a.rank < b.rank end)
    local roleProxy = self:getProxy(GameProxys.Role)
    local name = roleProxy:getLegionName()
    local info = nil
    for k,v in pairs(data) do
        if v.name == name then
            info = v
            break
        end
    end
    
    local power = self._infoPanel:getChildByName("power")
    local powerValue  = self._infoPanel:getChildByName("powerValue")
    powerValue:setString(StringUtils:formatNumberByK(info.capacity, 0))
    NodeUtils:alignNodeL2R(power,powerValue)
    if self._legionProxy:getMineInfo() ~= nil then
        self:renderMineInfoPanel(self._topPanel, self._legionProxy:getMineInfo())
    end
end



function LegionSceneHallPanel:renderMineInfoPanel(infoPanel, mineInfo)
    --建设度进度条
    local armyInfo = self._legionProxy:getArmyInfo()
    self:onDevoteResp(armyInfo) 
    --盟主显示设置按钮

    --更新小红点
    self._btnMap[8]:setVisible( self._legionProxy:getShowStateByJob(mineInfo.mineJob, "settingShow")) -- 只有盟主才显示 TODO：读表配置
    

    local level = self._infoPanel:getChildByName("level")
    local powerValue  = self._infoPanel:getChildByName("powerValue")
    local leginNameKey = self._infoPanel:getChildByName("legionOwner")
    self._legionLeader = self._infoPanel:getChildByName("legionName")
    local online = self._infoPanel:getChildByName("online")
    local total = self._infoPanel:getChildByName("total")
    local legionDesc = self._infoPanel:getChildByName("legionDesc")
    local rank = self._infoPanel:getChildByName("rank")
    local rankTxt = self._infoPanel:getChildByName("rankTxt")
    local teamOnline = self._infoPanel:getChildByName("teamOnline")
    local teamTotal = self._infoPanel:getChildByName("teamTotal")

    local  gongTxt = self._gongPanel:getChildByName("gongTxt")

    rankTxt:setString(mineInfo.rank)
    NodeUtils:alignNodeL2R(rank,rankTxt)
    level:setString("Lv."..mineInfo.level)
    legionDesc:setString(mineInfo.name)
    level:setPositionX(legionDesc:getPositionX()+legionDesc:getContentSize().width+15)
    --level:setPositionX(legionDesc:getPositionX()+legionDesc:getContentSize().width+10)
    self._legionLeader:setString(mineInfo.leaderName)
    online:setString(mineInfo.curNum)
    total:setString("/"..mineInfo.maxNum)
    total:setPositionX(online:getPositionX()+online:getContentSize().width)

    --对齐
    NodeUtils:alignNodeL2R(leginNameKey,self._legionLeader)

    local str1 = mineInfo.joinCond1
    local str2 = mineInfo.joinCond2

    if mineInfo.affiche=="" then
        gongTxt:setString( self:getTextWord(3006) )
    else
        gongTxt:setString( mineInfo.affiche )
    end

    --获取副盟主总数和在线数
    local legionProxy = self:getProxy(GameProxys.Legion)
    local memberInfoList = legionProxy:getMemberInfoList()
    local teamTotalNum = 0
    local teamOnlineNum = 0
    for k, v in pairs(memberInfoList) do
        if v.job == 6 then 
            teamTotalNum = teamTotalNum + 1
            if v.isOnline == 0 then 
                teamOnlineNum = teamOnlineNum + 1
            end
        end
    end
    teamTotal:setString("/"..teamTotalNum)
    teamOnline:setString(teamOnlineNum)
    teamTotal:setPositionX(teamOnline:getPositionX()+teamOnline:getContentSize().width)
end

--编辑公告后，更新公告
function LegionSceneHallPanel:updateLegionSceneAffiche(data)
    local  gongTxt = self._gongPanel:getChildByName("gongTxt")
    if data.affiche=="" then
        gongTxt:setString( self:getTextWord(3006) )
    else
        gongTxt:setString( data.affiche )
    end
end

--更新军团成员数量
function LegionSceneHallPanel:updateLegionSceneMenberNum()
    local legionProxy = self:getProxy(GameProxys.Legion)
    local memberInfoList = legionProxy:getMemberInfoList()
    local mineInfo = legionProxy:getMineInfo()
    local people = self._infoPanel:getChildByName("people")
    local online = self._infoPanel:getChildByName("online")
    local total = self._infoPanel:getChildByName("total")

    local team = self._infoPanel:getChildByName("team")
    local teamOnline = self._infoPanel:getChildByName("teamOnline")
    local teamTotal = self._infoPanel:getChildByName("teamTotal")

    self._legionLeader:setString(mineInfo.leaderName)
    online:setString(table.size(memberInfoList))
    -- total:setPositionX(online:getPositionX()+online:getContentSize().width)
    NodeUtils:alignNodeL2R(people,online,total)
    
    local teamTotalNum = 0
    local teamOnlineNum = 0
    --获取副盟主总数和在线数
    for k, v in pairs(memberInfoList) do
        if v.job == 6 then 
            teamTotalNum = teamTotalNum + 1
            if v.isOnline == 0 then 
                teamOnlineNum = teamOnlineNum + 1
            end
        end
    end
    teamTotal:setString("/"..teamTotalNum)
    teamOnline:setString(teamOnlineNum)
    -- teamTotal:setPositionX(teamOnline:getPositionX()+teamOnline:getContentSize().width)
    NodeUtils:alignNodeL2R(team,teamOnline,teamTotal)
end

function LegionSceneHallPanel:initPoint()
    self:onHelpPointUpdate()
    self:onWelfarePointUpdate()
    self:initBattlePointUpdate()
end

--更新互助按钮小红点
function LegionSceneHallPanel:onHelpPointUpdate()
    local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
    local num = legionHelpProxy:isCanHelp()
    local helpDot = self._btnMap[7]:getChildByName("dotBg")
    helpDot:setVisible(num > 0)
    local dot = helpDot:getChildByName("dot")
    dot:setString(num)
end

--更新福利按钮小红点
function LegionSceneHallPanel:onWelfarePointUpdate()
    local legionProxy = self:getProxy(GameProxys.Legion)
    local dailyReward = legionProxy:getDailyReward()
    local resourceNum = legionProxy:canGetResourceNum()
    local num = 0
    if dailyReward == 0 then 
        num = num + 1
    end

    if resourceNum > 0 then 
        num = num + 1
    end
    local welfareDot = self._btnMap[3]:getChildByName("dotBg")
    welfareDot:setVisible(num>0)
    local dot = welfareDot:getChildByName("dot")
    dot:setString(num)

end

--初始化战争按钮小红点
function LegionSceneHallPanel:initBattlePointUpdate()
    local legionProxy = self:getProxy(GameProxys.Legion)
    local boxCount = legionProxy:canGetAllCurBoxCount()
    local battleDot = self._btnMap[6]:getChildByName("dotBg")
    battleDot:setVisible(boxCount>0)
    local dot = battleDot:getChildByName("dot")
    dot:setString(boxCount)

end

--更新战争按钮小红点
function LegionSceneHallPanel:onBattlePointUpdate()
    local dungeonXProxy = self:getProxy(GameProxys.DungeonX)
    local boxCount = dungeonXProxy:canGetAllCurBoxCount()
   
    local battleDot = self._btnMap[6]:getChildByName("dotBg")
    battleDot:setVisible(boxCount>0)
    local dot = battleDot:getChildByName("dot")
    dot:setString(boxCount)

end

--更新贡献度和大厅待续
function LegionSceneHallPanel:onDevoteResp(data)
    local progressPanel = self._infoPanel:getChildByName("progressPanel")
    local progressTxt = progressPanel:getChildByName("progressTxt")
    local progressBar = progressPanel:getChildByName("progressBar")
    local level = self._infoPanel:getChildByName("level")
    level:setString("Lv."..data.armyLv )

    local isActive = self._infoPanel:getChildByName("isActive") --活跃度
    -- isActive:setVisible(false)
    local activeUrl = "images/legionScene/activeLevel_" .. data.oomph .. ".png"
    TextureManager:updateImageView(isActive,activeUrl)

    if data.oomph == 0 then
        isActive:setVisible(false)
    else
        isActive:setVisible(true)
    end 

    if data.buildNeed == 0 then
        progressTxt:setString(data.allBuild)
    else
        progressTxt:setString(data.allBuild .. "/" .. data.buildNeed)
    end
    local percent = data.allBuild / data.buildNeed * 100
    if percent > 100 then
        percent = 100
    elseif percent < 0 then
        percent = 0
    end
    progressBar:setPercent(percent)
end

function LegionSceneHallPanel:onClearCmd()
    self.chatNumBg:setVisible(false)
    self.talkNameTxt:setString("")
    if self._chatItem ~= nil then
        self._chatItem:dispose()
        self._chatItem = nil
    end
end


function LegionSceneHallPanel:updateRedPoint(data)
    local cityBtn =self:getChildByName("bigPanel/mainPanelBg/cityBtn")
    local num = 0
    for k,v in pairs(data.redPoint) do
        num =v.num + num
    end
    
    local dotBg = cityBtn:getChildByName("dotBg")
    local dot =dotBg:getChildByName("dot")

    logger:info(" 当前 刷新红点 数量 "..num)

    if num >0 then
        dotBg:setVisible(true)
    else
        dotBg:setVisible(false)
    end

    dot:setString(num)

end


