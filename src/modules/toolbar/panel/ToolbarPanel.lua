

ToolbarPanel = class("ToolbarPanel", BasicPanel)
ToolbarPanel.NAME = "ToolbarPanel"

function ToolbarPanel:ctor(view, panelName)
    -- 正确顺序(从左到右)：关卡、部队、任务、邮件、背包、社交、增益、装备、排行、设置、帮助
    self.btnModuleList = {
        ModuleName.RegionModule,
        -- ModuleName.InstanceModule,  --关卡 1
        ModuleName.TeamModule,      --部队 2
        ModuleName.TaskModule,      --任务 3
        ModuleName.MailModule,      --邮件 4
        ModuleName.BagModule,       --背包 5
        ModuleName.FriendModule,    --社交 6
        ModuleName.GainModule,      --增益 7
        ModuleName.HeroModule,     --装备 8
        ModuleName.RankModule,      --排行 9
        ModuleName.SettingModule,   --设置 10
        "help",                     --帮助 11
        ModuleName.MapMilitaryModule,                     --军工玩法 12
    }
    self.vib={}
    self.vibL={}
    self.btneffect={}
    self.btnLeffect={}
    self._view=view
    self.maxBtn = #self.btnModuleList
    self.chatInfoNumber = 0
    self.isCanDisappear = 0
    self.isCanRequireBuyVip = 0  ---是否可购买vip
    self.buildingTimes = 0  --建筑次数
    self.lastTime = 0
    self.teamIntoTotalTime = 0
    self.teamType = 0
    self.isShowPercent = true
    self.teamInfoTimes = 0
    self.isAddTimeBeAttacted = true
    self.beAttactedTime = 0
    self.openRedBagFtag = 1
    self.point_2 = {}
    self.beAttactList = {}
    self._buildingMap = {}
    self.beStationData = {}
    self.canRemoveRedBagOpenEffect = true
    self._buildingMap["vipBuildBtn"] = {
        msg = self:getTextWord(304)
    }
    self._buildingMap["barrackBtn"] = {
        moduleName = ModuleName.BarrackModule,
        buildingType = BuildingTypeConfig.BARRACK, buildingIndexs = {2, 3}, 
        extraMsg = {panel = "BarrackRecruitPanel"}
    }
    self._buildingMap["buildingBtn"] = {
        moduleName = ModuleName.PersonInfoModule, building = true, 
        extraMsg = {panel = "PersonInfoBuildPanel"}
    }
    self._buildingMap["scienceBtn"] = {
        moduleName = ModuleName.ScienceMuseumModule,
        buildingType = BuildingTypeConfig.SCIENCE, buildingIndexs = {12}, 
        extraMsg = {panel = "ScienceResearchPanel"}
    }
    self._buildingMap["itemBtn"] = {
        moduleName = ModuleName.BarrackModule,
        buildingType = BuildingTypeConfig.MAKE, buildingIndexs = {11},
        extraMsg = {panel = "BarrackRecruitPanel"}
    }

    self._currOpenModule = ModuleName.MainSceneModule
    ToolbarPanel.super.ctor(self, view, panelName)
end

function ToolbarPanel:finalize()
    if self._boomTip ~= nil then
        self._boomTip:finalize()
        self._boomTip = nil
    end
    self._frameQueue:finalize()

    for i=1,2 do
        if self["btnEffect"..i] ~= nil then
            self["btnEffect"..i]:finalize()
            self["btnEffect"..i] = nil
        end
    end

    for i=1,3 do
        if self["redBagEffect" .. i] ~= nil then
            self["redBagEffect" .. i]:finalize()
            self["redBagEffect" .. i] = nil
        end
        if self["redBagNorEffect" .. i] ~= nil then
            self["redBagNorEffect" .. i]:finalize()
            self["redBagNorEffect" .. i] = nil
        end
    end
    if self.btneffect[2] ~= nil then
        self.btneffect[2]:finalize()
        self.btneffect[2] = nil
    end
    if self.openRedBagEffect ~= nil then
        self.openRedBagEffect:finalize()
        self.openRedBagEffect = nil
    end
    if self.openRedBagEffectIcon ~= nil then
        self.openRedBagEffectIcon:finalize()
        self.openRedBagEffectIcon = nil
    end
    if self.openRedBagEffect2 ~= nil then
        self.openRedBagEffect2:finalize()
        self.openRedBagEffect2 = nil
    end

    --8095 【iOS】进入游戏后使用SDK或者游戏设置的切换账号功能后，游戏直接闪退
    --self._xszyShou是self._xszy的"子节点",但是也需要finalize
    if self._xszyShou ~= nil then 
        self._xszyShou:finalize()
        self._xsztShou = nil
    end

    if self._xszy~= nil then
        self._xszy:finalize()
        self._xszy = nil 
        self._xsztShou = nil
    end


    ToolbarPanel.super.finalize(self)
end

ToolbarPanel.allLen = 0

function ToolbarPanel:initPanel()
    ToolbarPanel.super.initPanel(self)

    -- 位置修正
    self:setTouchEnabled(false)
    
    self._frameQueue = FrameQueue.new(3)

    local queuePanel = self:getChildByName("funcPanel1/queuePanel")
    queuePanel:setVisible(true)
    local buildBtn = self:getChildByName("funcPanel1/buildBtn")
    --buildBtn:setScaleX(-1)
    buildBtn.isVisible = true

    self:updateBuildingInfo()
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
    -- self.isCanRequireBuyVip = 1
--    self:dispatchEvent(ToolbarEvent.BUY_VIP_INFO_REQ)    --请求一下是否能看见vip建筑
    local roleProxy = self:getProxy(GameProxys.Role)
    self._roleProxy = roleProxy
    self._ID = roleProxy:getPlayerId()

    -- self:playAction("amin_zhushou", nil)    --小助手 动画
    --self:playAction("admin_juntuan", nil)   --军团好礼 动画


    local activityCenter = self:getChildByName("funcPanel3/activityCenter")  --活动中心
    activityCenter:setVisible(false)
    local activitybtn = activityCenter:getChildByName("btn")
    activitybtn:setPressedActionEnabled(true)
    self:addTouchEventListener(activitybtn, self.onActivityCenterTouch)
    self["activitybtn"] = activitybtn
    if self.btneffect[10] == nil then
        self.btneffect[10] = self:createUICCBLayer("rgb-zjm-tubiao"--[["rgb-zjm-tubiao"]], activityCenter:getChildByName("btn"))
        local size = activityCenter:getChildByName("btn"):getContentSize()
        self.btneffect[10]:setPosition(size.width/2-5, size.height/2-3)
    end

    self:onUpdateTipsResp() -- 小红点更新

    self:onUpdateLimitBtn(2)

    local name = roleProxy:getRoleName()   --新手阶段         
    if name == "" or GameConfig.isNewPlayer == true then
        -- self:onShowOrHidePanels(false)
    end

    -- 快捷任务按钮
    self._taskTips = self:getChildByName("funcPanel4/taskBtn")
    self._taskTips2 = self:getChildByName("funcPanel4/taskBtn2")
    self:addTouchEventListener(self._taskTips,self.onTaskTipsTouch)
    self:addTouchEventListener(self._taskTips2,self.onTaskTips2Touch)
    self["taskTips"] = self._taskTips
    self["taskTips2"] = self._taskTips2

    -- 扩大任务按钮点击范围
    local touchPanel = self:getChildByName("funcPanel4/taskBtn/touchPanel")
    local touchPanel2 = self:getChildByName("funcPanel4/taskBtn2/touchPanel")
    touchPanel:setTouchEnabled(true)
    touchPanel2:setTouchEnabled(true)
    self:addTouchEventListener(touchPanel,self.onTaskTipsTouch)
    self:addTouchEventListener(touchPanel2,self.onTaskTips2Touch)

    -- 实名制按钮
    self._realNameBtn = self:getChildByName("funcPanel4/realNameBtn")
    self._realNameBtn:setVisible(false)
    self:addTouchEventListener(self._realNameBtn,self.onRealNameBtnTouch)

    -- 聊天
    self._mainPanel = self:getChildByName("mainPanel")
    self._mainPanel:setTouchEnabled(false)
    local chatPanel = self._mainPanel:getChildByName("chatPanel")

    self._panelTalk = chatPanel:getChildByName("panelTalk")
    self._talkTxt = self._panelTalk:getChildByName("talkTxt")

    self._talkNameTxt = chatPanel:getChildByName("talkNameTxt")

    --弹幕
    local Panel_219 = self:getChildByName("Panel_219")
    self._barrage = UIChatBarrage.new(self,Panel_219)
    self._barrage:setHeight(133)

    -- 更新四季
    self:updateSeason()

    -- 更新世界等级
    self:updateWorldLevel()

    --添加ccb特效
    local sceneBtn = self:getChildByName("mainPanel/sceneBtn")
    if not sceneBtn.ccb then
        sceneBtn.ccb = self:createUICCBLayer("rgb-zhujiemiananniu",sceneBtn)
        sceneBtn.ccb:setPosition(60,40)
    end
    -- 设置移动动作
    self:setMoveAction()

    -- local Image_10 = self:getChildByName("mainPanel/Image_10")
    -- Image_10:setTouchEnabled(true)
    
    self._btnListView = self:getChildByName("mainPanel/btnListView")

    self._helpBtn = self:getChildByName("funcPanel1/helpBtn")
    
    self:onRoleInfoUpdateResp({})

    --self:playWarning()
        local queuePanel=self:getChildByName("funcPanel1/queuePanel")
        local ldBg=queuePanel:getChildByName("ldBg")
        self["ldBgbp"]=cc.p(ldBg:getPositionX(),ldBg:getPositionY())
        self["_acbtn"]={}
        self["_acbtn"][1]=queuePanel:getChildByName("itemBtn")
        self["_acbtn"][2]=queuePanel:getChildByName("scienceBtn")
        self["_acbtn"][3]=queuePanel:getChildByName("buildingBtn")
        self["_acbtn"][4]=queuePanel:getChildByName("barrackBtn")
        self["_acbtn"][5]=queuePanel:getChildByName("vipBuildBtn")
        self["_acbtn"]["posnull"]=true


    local jieqi_btn=self._btnListView:getChildByName("jieqi_btn")
    self:addTouchEventListener(jieqi_btn,self.onjijieTouch)

    self:onRealNameBtnVisible() --同时初始化显示按钮

    --// 增加 一个新手引导特效
    if self._xszy ==nil then
    --print("创建一个 新手指引的特效")
    self._xszy = self:createUICCBLayer("rgb-xszy",touchPanel) 
    self._xszy:setPosition(touchPanel:getContentSize().width/2,touchPanel:getContentSize().height/2)

    self._xszyShou = self:createUICCBLayer("rgb-xszy-shou",self._xszy)
    self._xszyShou:setPosition(self._xszy:getContentSize().width/2,self._xszy:getContentSize().height/2)
    end
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local url = "images/toolbar/guide_text.png"
    local img= TextureManager:createImageView(url)
    local label  = ccui.Text:create()
    label:setFontName(GlobalConfig.fontName)
    label:setFontSize(20)
    label:setPosition(img:getContentSize().width/2,img:getContentSize().height/2)
    label:setString(TextWords:getTextWord(145))
    img:addChild(label)
    img:setPositionY(150)
    self._xszy:addChild(img)

    if playerLevel >=  5 and playerLevel <=20 then
    self._xszy:setVisible(true)
    else
    self._xszy:setVisible(false)
    end
end  

--注意,在这里调用,有可能纹理还没有加载进来
function ToolbarPanel:onShowHandler()


end

function ToolbarPanel:onjijieTouch()
    local seasonProxy = self:getProxy(GameProxys.Seasons)

    local roleProxy = self:getProxy(GameProxys.Role)
    if roleProxy:isFunctionUnLock(52,true) then        
        if seasonProxy:isWorldSeasonOpen() then
            self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,{moduleName = ModuleName.SeasonsModule})
        else
            local WorldSeasonOpen = ConfigDataManager:getInfoFindByOneKey(ConfigData.WorldSeasonOpen,"ID",1)
            --四季系统未开放
            --local day = TimeUtils:getStandardFormatTimeString3(WorldSeasonOpen.serverOpenDay)
            self:showSysMessage(string.format(TextWords:getTextWord(500003), WorldSeasonOpen.serverOpenDay))            
        end
    end
end

function ToolbarPanel:posrefre()
    if self["_acbtn"]["posnull"] then
        self["_acbtn"][1]["pos"]=cc.p(self["_acbtn"][1]:getPositionX(),self["_acbtn"][1]:getPositionY())
        self["_acbtn"][2]["pos"]=cc.p(self["_acbtn"][2]:getPositionX(),self["_acbtn"][2]:getPositionY())
        self["_acbtn"][3]["pos"]=cc.p(self["_acbtn"][3]:getPositionX(),self["_acbtn"][3]:getPositionY())
        self["_acbtn"][4]["pos"]=cc.p(self["_acbtn"][4]:getPositionX(),self["_acbtn"][4]:getPositionY())
        self["_acbtn"][5]["pos"]=cc.p(self["_acbtn"][5]:getPositionX(),self["_acbtn"][5]:getPositionY())
        self["_acbtn"]["posnull"] =false
    end
end

-- 引导用到,滑动到指定水平百分百位置，默认滑动到0%
function ToolbarPanel:onUpdateBtnList(data)
    local percent
    if data == nil then
        percent = 0
    else
        percent = rawget(data,"percent")
        if percent == nil then
            percent = 0
        end
    end
    self._btnListView:jumpToPercentHorizontal(percent)
end


function ToolbarPanel:onRoleInfoUpdateResp(updatePowerList)
    -- body
    local powerlist = {}
    table.insert(powerlist, PlayerPowerDefine.POWER_buildingOnce)
    table.insert(powerlist, PlayerPowerDefine.POWER_buildsize)
    table.insert(powerlist, PlayerPowerDefine.POWER_buildingBuff)
    table.insert(powerlist, PlayerPowerDefine.POWER_level)
    table.insert(powerlist, PlayerPowerDefine.POWER_vipLevel)
    
    local isIntersect = table.isIntersect(powerlist, updatePowerList)
    if isIntersect == true then
        self:updateBuildingInfo()
    end
    
    -- 刷新繁荣数值
    -- self:updateBoomInfo()

    local name = self._roleProxy:getRoleName()   --新手阶段         
    if name == "" or GameConfig.isNewPlayer == true then
        return
    end

end

--建造信息更新了
function ToolbarPanel:updateBuildingInfo(buySuccess)
    --倒计时

    self._CountDownMap = {}
    
    local totalNum = 0
    local queuePanel = self:getChildByName("funcPanel1/queuePanel")
    local buildingProxy = self:getProxy(GameProxys.Building)
    for name, data in pairs(self._buildingMap) do
        local btn = queuePanel:getChildByName(name)
        local openNum = 0
        local buildingInfos = {}
        if data.buildingType ~= nil and data.buildingIndexs ~= nil then
            for _, buildingIndex in pairs(data.buildingIndexs) do
                local buildingInfo = buildingProxy:getBuildingInfo(data.buildingType, buildingIndex)
                if buildingInfo == nil or buildingInfo.level == 0 then
                else
                    openNum = openNum + 1
                    table.insert(buildingInfos, buildingInfo)
                end
            end

            local btnChild = btn:getChildByName("btn")
            if openNum > 0 then
                btn.isOpen = true
                btnChild.isOpen = true
            else
                btn.isOpen = false
                btnChild.isOpen = false
            end

            local remainCount = self:renderBuildBtn(btn, buildingInfos)
            totalNum = totalNum + remainCount
        elseif data.building ~= nil then --升级建筑的
            local roleProxy = self:getProxy(GameProxys.Role)
            local buildSize1 = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildingOnce)
            local buildSize2 = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildsize)
            local buildSize3 =  roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildingBuff)
            self.buildingTimes = buildSize1 + buildSize2 + buildSize3
            local num, buildingType, index = buildingProxy:buildingLvNum()
            local remainCount = self:renderAllBuildingBtn(btn, self.buildingTimes, num, buildingType, index,buySuccess)
            totalNum = totalNum + remainCount
        end
        -------------lllll
        if self.bgImg == nil or self.bgImg_2 == nil then
            local queuePanel = self:getChildByName("funcPanel1/queuePanel")
            local children = queuePanel:getChildren()
            for _, child in pairs(children) do
                local name = child:getName()
                if name == "bgImg" then
                    self.bgImg = child
                elseif name == "bgImg_2" then
                    self.bgImg_2 = child
                end
            end
        end
        local roleProxy = self:getProxy(GameProxys.Role)
        local buildSize1 = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildingOnce)
        local buildSize2 = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildsize)
        local buildSize3 =  roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildingBuff)
        self.buildingTimes = buildSize1 + buildSize2 + buildSize3
        if name =="vipBuildBtn" then
            if self.buildingTimes >= 7 then
                btn:setVisible(false)
                if self["numTxtall"]==nil then
                    self["numTxtall"]={}
                end
                self["numTxtall"][5]=0
                self:updata_ld()
            else
                btn:setVisible(true)
                local vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
                local vipData = ConfigDataManager:getConfigData("VipDataConfig")
                local canBuyNum = vipData[vipLevel+1].bulidqueue - self.buildingTimes
                local dot = btn:getChildByName("dot")
                local numTxt = btn:getChildByName("numTxt")
                if canBuyNum > 0 then
                    dot:setVisible(true)
                    numTxt:setVisible(true)
                    numTxt:setString(canBuyNum)
                else
                    canBuyNum = 0
                    dot:setVisible(false)
                    numTxt:setVisible(false)
                end
                if self["numTxtall"]==nil then
                    self["numTxtall"]={}
                end
                self["numTxtall"][5]=canBuyNum
                self:updata_ld()
                totalNum = totalNum + canBuyNum
            end
        end
        -------------lllll
    end
    
    local buildBtn = self:getChildByName("funcPanel1/buildBtn")
    local dot = self:getChildByName("funcPanel1/buildBtnDot")
    local numTxt = dot:getChildByName("dotNum")
    
    if totalNum > 0 then
        --dot:setVisible(true)
        numTxt:setString(totalNum)
        if buySuccess and buySuccess == 1 then
            numTxt:setString(totalNum+1)
        end
    else
        numTxt:setString("")
        --dot:setVisible(false)
    end
end

function ToolbarPanel:touchNoticTip(sender) --小助手tip
    if sender.index == 1 then
    else
        local guideId = 229
        GuideManager:trigger(guideId, true)
    end
    sender:getParent():setVisible(false)
end

function ToolbarPanel:renderAllBuildingBtn(btn,buildsize,num, buildingType, index,buySuccess)
    local numTxt = btn:getChildByName("numTxt")
    local dot = btn:getChildByName("dot")
    local curNum = 0

    if buildsize - num > 0 then
        curNum=buildsize - num
        if buySuccess and buySuccess == 1 then
            curNum=buildsize - num+1
        end
        dot:setVisible(true)
        numTxt:setVisible(true)
        numTxt:setString(curNum)
    else
      --建筑需要倒计时
        numTxt:setString("")
        dot:setVisible(false)
    end
        
        local tall=self["numTxtall"]
        if tall==nil then
            self["numTxtall"]={}
            self["numTxtall"][4]=curNum
        --     table.insert(table,curNum)
        else
            tall[4]=curNum
        --     table.insert(table,curNum)
        end
    self:updata_ld()
        -- print(curNum.."**********************************************")
    self:updateBtnStateTxt( btn, buildsize, num, buildingType, index, buySuccess, nil )
    
    return buildsize - num
end


-- 更新按钮状态的数量
function ToolbarPanel:updateBtnStateTxt( btn, buildsize, num, buildingType, index, buySuccess, minOrder )


    if buildsize - num > 0 then
        local numberR = buildsize
        -- stateLTxt:setString(num)
        -- stateRTxt:setString(buildsize)
        if buySuccess and buySuccess == 1 then
            -- stateRTxt:setString(buildsize+1)
            numberR = numberR + 1
        end

        self:showStateTxt(btn,num,numberR,nil,true)

    else
      --需要倒计时
        local data = {}
        data.stateTxt = btn
        data.buildingType = buildingType
        data.buildingIndex = index
        data.order = minOrder
        table.insert(self._CountDownMap, data)
    end

end

function ToolbarPanel:showStateTxt( btn, numberL, numberR, remainTime, isShow )
    -- body
    local stateLTxt = btn:getChildByName("stateLTxt")
    local stateRTxt = btn:getChildByName("stateRTxt")
    local stateLineImg = btn:getChildByName("stateLineImg")

    if remainTime then
        -- 倒计时

        if btn.buildFreeImg ~= nil and self.buildFreeTipSp ~= nil then
            --有免费加速的建筑时不显示倒计时
            return
        end
        if btn.stateTime == nil then
            -- logger:info("创建倒计时sprite...")
            local stateImg1 = stateLineImg:clone()
            local stateImg2 = stateLineImg:clone()
            local stateTime1 = stateLTxt:clone()
            local stateTime2 = stateRTxt:clone()
            
            stateImg1:setName("stateImg1")
            stateImg2:setName("stateImg2")
            stateTime1:setName("stateTime1")
            stateTime2:setName("stateTime2")

            btn:addChild(stateImg1)
            btn:addChild(stateImg2)
            btn:addChild(stateTime1)
            btn:addChild(stateTime2)
            btn.stateTime = true
        end

        stateLTxt:setVisible(not isShow)
        stateRTxt:setVisible(not isShow)
        stateLineImg:setVisible(not isShow)


        self:showTimeStringByImg(btn,remainTime)
        
    else
        -- 数量
        stateLTxt:setVisible(isShow)
        stateRTxt:setVisible(isShow)
        stateLineImg:setVisible(isShow)
        stateLTxt:setString(numberL)
        stateRTxt:setString(numberR)

        if btn.stateTime then
            local stateTime1 = btn:getChildByName("stateTime1")
            local stateTime2 = btn:getChildByName("stateTime2")
            local stateImg1 = btn:getChildByName("stateImg1")
            local stateImg2 = btn:getChildByName("stateImg2")
            stateTime1:setVisible(not isShow)
            stateTime2:setVisible(not isShow)
            stateImg1:setVisible(not isShow)
            stateImg2:setVisible(not isShow)
        end
    end
end

----格式：xxdxxh or xxhxxm or xxmxxs
function ToolbarPanel:showTimeStringByImg(btn,time)
    local day = math.floor(time / 86400)
    time = time % 86400
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60

    local urlTab = {}
    local strTab = {}

    if day > 0 then
        table.insert(urlTab,"D")
        table.insert(strTab,day)
        if hours >= 0 then
            table.insert(strTab,hours)
            table.insert(urlTab,"H")
        end
    elseif hours > 0 then
        table.insert(strTab,hours)
        table.insert(urlTab,"H")
        if minutes >= 0 then
            table.insert(strTab,minutes)
            table.insert(urlTab,"M")
        end
    else
        if minutes > 0 then
            table.insert(strTab,minutes)
            table.insert(urlTab,"M")
        end
        if seconds >= 0 then
            table.insert(strTab,seconds)
            table.insert(urlTab,"S")
        end
    end


    local stateTime1 = btn:getChildByName("stateTime1")
    local stateTime2 = btn:getChildByName("stateTime2")
    local stateImg1 = btn:getChildByName("stateImg1")
    local stateImg2 = btn:getChildByName("stateImg2")
    stateTime1:setVisible(false)
    stateTime2:setVisible(false)
    stateImg1:setVisible(false)
    stateImg2:setVisible(false)
    local timeTab = {stateTime1,stateTime2}
    local imgTab = {stateImg1,stateImg2}


    local url = nil
    local len = table.size(urlTab)
    for k,urlId in pairs(urlTab) do
        if imgTab[k] then
            url = string.format("images/newGui2/%s.png", urlId)
            TextureManager:updateImageView(imgTab[k],url)
        end

        if timeTab[k] then
            timeTab[k]:setString(strTab[k])
        end

        -- 调整坐标
        local btnSize = btn:getContentSize()
        local btnX = btnSize.width/2
        if len == 1 then
            -- 小于1分钟
            timeTab[k]:setVisible(true)
            imgTab[k]:setVisible(true)
            imgTab[k]:setAnchorPoint(0,0.5)
            timeTab[k]:setAnchorPoint(1,0.5)
            timeTab[k]:setPositionX(btnX+0)
            imgTab[k]:setPositionX(btnX+0)

        else
            -- 不小于1分钟
            if k == 1 then
                timeTab[k]:setVisible(true)
                imgTab[k]:setVisible(true)
                timeTab[k]:setAnchorPoint(1,0.5)
                imgTab[k]:setAnchorPoint(1,0.5)

                local size = imgTab[k]:getContentSize()
                timeTab[k]:setPositionX(btnX+0-size.width)
                imgTab[k]:setPositionX(btnX+0)

            else
                timeTab[k]:setVisible(true)
                imgTab[k]:setVisible(true)
                timeTab[k]:setAnchorPoint(0,0.5)
                imgTab[k]:setAnchorPoint(0,0.5)

                timeTab[k]:setPositionX(btnX+0)
                local size = timeTab[k]:getContentSize()
                imgTab[k]:setPositionX(btnX+size.width)

            end
        end
    end
end

function ToolbarPanel:renderBuildBtn(btn, buildingInfos)
    local isOpen = btn.isOpen
    if isOpen ~= true then
--        NodeUtils:hideChildren(btn)
        --如果没有建造，推送的红点屏蔽
        local noOpen_numTxt = btn:getChildByName("numTxt")
        local noOpen_dot = btn:getChildByName("dot")
        noOpen_dot:setVisible(false)
        noOpen_numTxt:setVisible(false)
        return 0
    end

--    NodeUtils:setChildrenVisible(btn,true)


    local buildingNum = #buildingInfos
    local fullNum = 0
    local minOrder = -1
    local remainTime = 140000000
    local buildingIndex = -1
    local buildingType = -1
    for _, buildingInfo in pairs(buildingInfos) do
        local isfull, order, minRemainTime = self:getProductionInfo(buildingInfo)
        if isfull == true then
            fullNum = fullNum + 1
        else --队列未满
            btn.buildingIndex = buildingInfo.index
        end

        if isfull and remainTime >= minRemainTime then
            remainTime = minRemainTime
            minOrder = order

            buildingIndex = buildingInfo.index
            buildingType = buildingInfo.buildingType
        end
    end

    if btn.buildingIndex == nil then
        btn.buildingIndex = buildingIndex
    end
    
    local maxNum = #buildingInfos
    local numTxt = btn:getChildByName("numTxt")
    local dot = btn:getChildByName("dot")
    local curNum = maxNum - fullNum
    if curNum == 0 then
        numTxt:setVisible(false)
        dot:setVisible(false)
    else
        numTxt:setString(curNum)
        numTxt:setVisible(true)
        dot:setVisible(true)
    end

    local tall=self["numTxtall"]
        local name=btn:getName()
        local bindex=0
        if name=="barrackBtn" then
            bindex=1
        elseif name=="scienceBtn" then
            bindex=2
        elseif name=="itemBtn" then
            bindex=3
        end
        if tall==nil then
            self["numTxtall"]={}
            tall=self["numTxtall"]
        end
        tall[bindex]=curNum
        self:updata_ld()

    --显示个数
    if fullNum < buildingNum then
        self:showStateTxt(btn,fullNum,buildingNum,nil,true)
    else
        local data = {}
        data.stateTxt = btn
        data.buildingType = buildingType
        data.buildingIndex = buildingIndex
        data.order = minOrder
        table.insert(self._CountDownMap, data)
    end
    
    return maxNum - fullNum
end
function ToolbarPanel:updata_ld()
    local tall=self["numTxtall"]
    if tall==nil then
        return
    end
    local num=0
    for i=1,5 do
        if tall[i]~=nil then
        num=num+tall[i]
        end
    end
    if self["workCountTxt"]~=nil then
    self["workCountTxt"]:setString(num)
    if num==0 then
        self["workCountTxt"]:getParent():setVisible(false)
    else
        self["workCountTxt"]:getParent():setVisible(true)
    end
    end
end

function ToolbarPanel:update(dt)
    local buildingProxy = self:getProxy(GameProxys.Building)
    local isZero = false
    for _, data in pairs(self._CountDownMap) do
        local btn = data.stateTxt
        local buildingIndex = data.buildingIndex
        local buildingType = data.buildingType
        local order = data.order
        
        local remainTime = 0
        if order ~= nil then
            remainTime = buildingProxy:getBuildingProLineReTime(buildingIndex, order)
        else
            remainTime = buildingProxy:getBuildingUpReTime(buildingType, buildingIndex)
        end
        
        self:showStateTxt(btn,nil,nil,remainTime,true)
        
        if remainTime == 0 then
            isZero = true
        end
    end
    if isZero == true then
        -- self:updateBuildingInfo()
    end
    
    self.isCanDisappear = self.isCanDisappear + dt / 1000
    if self.isCanDisappear > 1000  then
        self:hideChatContent()
    end
    -- self:updateFanrong()

    local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)

    local sceneBtn = self:getChildByName("mainPanel/sceneBtn")
    self._helpBtn:setVisible(legionHelpProxy:isCanHelp() > 0 and sceneBtn.index==1)

    local function helpOthersBuildings()
        legionHelpProxy:helpOthersBuildings()
    end
    self:addTouchEventListener(self._helpBtn,helpOthersBuildings)


    local sceneBtn = self:getChildByName("mainPanel/sceneBtn")
    -- local funcPanel5 = self:getChildByName("mainPanel/mailTigBtn")
    -- local dot = self:getChildByName("mainPanel/mailTigBtn/dot")
    -- local dotNum = dot:getChildByName("dotNum")
    -- --解决在玩家被打时不显示未读邮件提示

    -- if sceneBtn.index == 1 and tonumber(dotNum:getString()) > 0 then
    --     funcPanel5:setVisible(true)
    -- end  
    --红包
    self:setRedBagVisible()
    local btnArr = {}
    local redBagBtn1 = self:getChildByName("redBagPanel/redBagBtn1")
    table.insert(btnArr, redBagBtn1)
    local redBagBtn2 = self:getChildByName("redBagPanel/redBagBtn2")
    table.insert(btnArr, redBagBtn2)
    local redBagBtn3 = self:getChildByName("redBagPanel/redBagBtn3")
    table.insert(btnArr, redBagBtn3)
    for i=1,3 do
        if self.redBagData[i] then
            local numTxt = btnArr[i]:getChildByName("numTxt")
            numTxt:setString(self.redBagData[i].num)
            local countDownLab = btnArr[i]:getChildByName("countDownLab")
            local name = "RedBag_CoolingTime" ..  self.redBagData[i].id
            local proxy = self:getProxy(GameProxys.RedBag)
            local coolTime = proxy:getRemainTime(name)
            if coolTime > 0 then
                -- countDownLab:setString(coolTime)
                countDownLab:setString("")
                if self["redBagEffect" .. i] ~= nil then
                    self["redBagEffect" .. i]:finalize()
                    self["redBagEffect" .. i] = nil
                end
                if self["redBagNorEffect" .. i] == nil then
                    local btn = btnArr[i]:getChildByName("btn")
                    self["redBagNorEffect" .. i] = self:createUICCBLayer("rgb-hongbao-tubiaodan", btn, nil, nil,true)
                    local size = btnArr[i]:getContentSize()
                    self["redBagNorEffect" .. i]:setPosition(size.width*0.42,size.height*0.52)
                    self["redBagNorEffect" .. i]:setLocalZOrder(10)
                end
            else
                countDownLab:setString("")
                if self["redBagNorEffect" .. i] ~= nil then
                    self["redBagNorEffect" .. i]:finalize()
                    self["redBagNorEffect" .. i] = nil
                end
                if self["redBagEffect" .. i] == nil then
                    local btn = btnArr[i]:getChildByName("btn")
                    self["redBagEffect" .. i] = self:createUICCBLayer("rgb-hongbao-tubiao", btn, nil, nil,true)
                    local size = btnArr[i]:getContentSize()
                    self["redBagEffect" .. i]:setPosition(size.width*0.42,size.height*0.52)
                    self["redBagEffect" .. i]:setLocalZOrder(10)
                end
            end
            
        end
    end
    --热卖礼包
    self:setGiftBagVisible()
    self:updateLevel()

    --//等级判断 小红点

    local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if self._xszy:isVisible() == true then
        if playerLevel <  5 or playerLevel >20 then
           self._xszy:setVisible(false)
        end
    end

end

--获取现在建造的生产信息
--是否生产队列已满，现在的最小生产时间order
function ToolbarPanel:getProductionInfo(buildingInfo)
    local productionInfos = buildingInfo.productionInfos
    local productionNum = #productionInfos

    local minRemainTime = 140000000
    local minOrder = -1
    local isFull = false
    for _, productionInfo in pairs(productionInfos) do
        if minRemainTime > productionInfo.remainTime then
            if productionInfo.state == 1 then
                minRemainTime = productionInfo.remainTime
                minOrder = productionInfo.order
                isFull = true
            end
        end
    end
    --productionNum >= maxProductionLine
    local maxProductionLine = buildingInfo.productNum
    return isFull, minOrder, minRemainTime
end

function ToolbarPanel:registerEvents()
    local btnItem=nil
    for index=1, self.maxBtn do--11
        if index==4 or index==6 or index==7 or index==10 or index==11 or index==12 then
            btnItem = self:getChildByName("funcPanel2/btnItem" .. index)
            btnItem:getChildByName("btn"):setPressedActionEnabled(true)
        else
            btnItem = self:getChildByName("mainPanel/btnListView/ListView_btns/btnItem" .. index)
        end

        btnItem.index = index
        local btn = btnItem:getChildByName("btn")
        btn.index = index
        self:addTouchEventListener(btn, self.onBtnItemTouch)
        self["btnItem" .. index] = btn
    end
    -- 存储背包的世界坐标位置
    self:setBtnItem5Pos()

    local sceneBtn = self:getChildByName("mainPanel/sceneBtn")
    self:addTouchEventListener(sceneBtn, self.onSceneBtnTouch, nil, nil, GlobalConfig.moduleJumpAnimationDelay)
    sceneBtn.index = 1 --大营
    self:setSceneName(sceneBtn)
    
    self["sceneBtn"] = sceneBtn

    local chatPanel = self:getChildByName("mainPanel/chatPanel")
    self:addTouchEventListener(chatPanel, self.onChatBtnTouch)

    local chatItem = self:getChildByName("mainPanel/chatPanel/infoImg")
    self:addTouchEventListener(chatItem, self.onChatBtnTouch)

    self.chatNumBg = self:getChildByName("mainPanel/chatPanel/infoImg/Image_66")
    self.chatNumBg:setVisible(false)
    self.chatNumTxt = self:getChildByName("mainPanel/chatPanel/infoImg/Image_66/num")
    self:renderChatNum()
    -- for i=1,4 do
    --     self["teamInfoButton_"..i] = self:getChildByName("mainPanel/teamInfoPanel/Button_"..i)
    --     self["teamInfoText_"..i] = self["teamInfoButton_"..i]:getChildByName("Label")
    --     self["teamInfoButton_"..i].index = i
    --     self:addTouchEventListener(self["teamInfoButton_"..i], self.onTouchTeamInfoButton)
    -- end
    -- self.point_2.pointX= self.teamInfoButton_2:getPositionX()
    -- self.point_2.pointY= self.teamInfoButton_2:getPositionY()
    local buildBtn = self:getChildByName("funcPanel1/buildBtn")
    self:addTouchEventListener(buildBtn, self.onbuildBtnTouch)

    local queuePanel = self:getChildByName("funcPanel1/queuePanel")
    self:addTouchEventListener(queuePanel, self.onldTouch)

    local children = queuePanel:getChildren()
    for _, child in pairs(children) do
        local name = child:getName()
        if name ~= "bgImg" and name ~= "bgImg_2" and name ~= "helpBtn" and name ~= "Panel_204" and name ~= "ldBg" then
            local btn = child:getChildByName("btn")
            btn.name = name
            self:addTouchEventListener(btn, self.onTheBuildingTouch)
        else
            self[name] = child
        end
    end
    
    --增加商城按钮
    local shopBtn = self:getChildByName("funcPanel3/shopBtn")
    local btn = shopBtn:getChildByName("btn")
    btn:setPressedActionEnabled(true)
    self:addTouchEventListener(btn, self.onShopBtnTouch)
    self["shopBtn"] = btn
    
    -- 招募
    local lotteryEpBtn = self:getChildByName("funcPanel3/lotteryEpBtn")
    local btn = lotteryEpBtn:getChildByName("btn")
    self:addTouchEventListener(btn, self.onLotteryEpBtnTouch)
    self["lotteryEpBtn"] = btn
    lotteryEpBtn:setVisible(false)  --屏蔽拜访名匠
     --邮件
    -- local mailTigBtn = self:getChildByName("mainPanel/mailTigBtn")
    -- local dot = mailTigBtn:getChildByName("dot")
    -- local dotNum = dot:getChildByName("dotNum")
    -- local btn = mailTigBtn:getChildByName("btn")
    -- self:addTouchEventListener(btn, self.onMailTouch)
    -- self["mailTigBtn"] = btn
    -- mailTigBtn:setVisible(false)
    -- dotNum:setString(0)
    -- 抽奖
    local treasureBtn = self:getChildByName("funcPanel3/treasureBtn")
    local btn = treasureBtn:getChildByName("btn")
    btn:setPressedActionEnabled(true)
    self:addTouchEventListener(btn, self.onTreasureBtnTouch)
    self["treasureBtn"] = btn

    
    -- 开服礼包
    local openServerGiftBtn = self:getChildByName("funcPanel3/openServerBtn")
    local btn = openServerGiftBtn --openServerGiftBtn:getChildByName("btn")
    self:addTouchEventListener(btn,self.openServerGift)
    self["openServerGiftBtn"] = btn

    -- 活动
    local activBtn = self:getChildByName("funcPanel3/activBtn")
    local btn = activBtn:getChildByName("btn")
    btn:setPressedActionEnabled(true)
    self:addTouchEventListener(btn, self.onActivBtnTouch)
    self["activBtn"] = btn

   


    local noticeBtn = self:getChildByName("funcPanel3/noticeBtn")
    -- noticeBtn:setVisible(false)
    self.nBtn = noticeBtn
    local btn = noticeBtn:getChildByName("btn")
    btn:setPressedActionEnabled(true)
    self:addTouchEventListener(btn, self.onNoticeTouch)
    self["noticeBtn"] = btn

    local shopBtn = self:getChildByName("funcPanel3/shopBtn")
    
    local upPanel = {}
    upPanel.getChildren = function()
        -- 拜访名匠按钮没在队列中，lotteryEpBtn
        return {activBtn--[[, openServerGiftBtn]], treasureBtn, shopBtn}
    end
    -- upPanel.setVisible = function()
    
    -- end
    
    local lGiftBtn = self:getChildByName("funcPanel3/legionGiftBtn")
    local activityCenter = self:getChildByName("funcPanel3/activityCenter")
    local vipSupplyBtn = self:getChildByName("funcPanel3/vipSupplyBtn")
    local weekCardBtn = self:getChildByName("funcPanel3/weekCardBtn")

    self:updateVipSupplyPoint() -- vip特权显示设置
    self:updateWeekCardShowAndRedPoint() -- 周卡和红点显示设置
    

    if self.btneffect[3] == nil then
        self.btneffect[3] = self:createUICCBLayer("rgb-hdui-tmdl"--[["rgb-juntuandali"]], lGiftBtn:getChildByName("btn"))
        local size = lGiftBtn:getContentSize()
        self.btneffect[3]:setPosition(size.width*0.4, size.height*0.4)
        self.btneffect[3]:setLocalZOrder(0)
        local dotBtn = lGiftBtn:getChildByName("btn")
        dotBtn:setLocalZOrder(21)
    end
    
    local rightPanel = {}
    rightPanel.getChildren = function()
        return {noticeBtn, lGiftBtn, activityCenter}
    end
    -- rightPanel.setVisible = function()
    
    -- end
    local giftBagBtn=self:getChildByName("funcPanel3/giftBagBtn")
    local middlePanel = {}
    middlePanel.getChildren = function()
        return { vipSupplyBtn,giftBagBtn,lGiftBtn}
    end
    -- for _,v in pairs(middlePanel.getChildren()) do
    --     local t=0
    --     if v:getVisible() then
    --         t=t+1
    --     v:setPositionY(-282+(t-1)*(-86))    
    --     end
        
    -- end
    local middleLeftPanel = {}
    middleLeftPanel.tag = 1
    middleLeftPanel.getChildren = function()
        return { weekCardBtn}
    end


    self._upPanel = upPanel
    self._rightPanel = rightPanel
    self._middlePanel= middlePanel
    self._middleLeftPanel= middleLeftPanel

    local upBtn = self:getChildByName("funcPanel3/upBtn")
    self:addTouchEventListener(upBtn, self.onUpBtnTouch)
    upBtn.isVisible = true

    
    self.lGiftBtn = lGiftBtn
    
    self:addTouchEventListener(lGiftBtn:getChildByName("btn"), self.onLGiftTouch)
   
    local avtProxy = self:getProxy(GameProxys.Activity)
    -- avtProxy:updateLegionGiftData()
    local flag, info, id = avtProxy:getDataByCondition(ActivityDefine.LEGION_JOIN_CONDITION) --getDataById(15)军团好礼
    
    self:onUpdateLegionGift(info) -- 军团按钮显示设置

    --vip特供
    btn = vipSupplyBtn:getChildByName("btn")
    self["vipSupplyBtn"] = btn
    self:addTouchEventListener(btn, self.onVipSupplyTouch)

    --周卡
    local weekBtn = weekCardBtn:getChildByName("btn")
    self["weekCardBtn"] = weekBtn
    self:addTouchEventListener(weekBtn, self.onWeekCardTouch)
    

    local chatProxy = self:getProxy(GameProxys.Chat)
    self:updateChatInfos( {chatProxy:getLastChatInfo()} )

    -- 群雄或其他快捷活动入口
    self._worlordImpData = {}
    self._worlordsImg = {}
    for i = 1 , 4 do
        self._worlordsImg[i] = self:getChildByName("funcPanel1/actIcon" .. i)
    end

    -- 队列旗帜按钮
    self._queueBtnBg = self:getChildByName("mainPanel/queueBtnBg")
    self._queueBtn = self:getChildByName("mainPanel/queueBtnBg/queueBtn")
    self._queueBtnpos=cc.p(self._queueBtn:getPositionX(),self._queueBtn:getPositionY())
    
    self:addTouchEventListener(self._queueBtn, self.onShowQueuePanel)
    --抢红包
    for i=1,3 do
        local redBagBtn = self:getChildByName("redBagPanel/redBagBtn" .. i .. "/btn")
        redBagBtn.ftag = i
        -- local btn = redBagBtn:getChildByName("btn")
        self:addTouchEventListener(redBagBtn, self.onTouchRedBagHandler)
    end
    --热卖礼包
    -- local giftBagBtn = self:getChildByName("funcPanel3/giftBagBtn")
    self["giftBagBtn"] = giftBagBtn
    self:addTouchEventListener(giftBagBtn:getChildByName("btn"), self.onGiftBagTouch)
    self:setGiftBagVisible() -- 特卖显示设置
    
    --右下角铃铛
    local ldBtn=self:getChildByName("funcPanel1/ldBtnBg/ldBtn")
    self:addTouchEventListener(ldBtn, self.onldTouch)
    local workCountTxt=ldBtn:getChildByName("redDot"):getChildByName("workCountTxt")
    --workCountTxt:setString(88)
    self["workCountTxt"]=workCountTxt
    self:updata_ld()

    self:updateMidLeftVis() -- 周卡位置设置
end

-- 设置位置：VIP特供，特卖礼包，同盟礼包
function ToolbarPanel:updateMidVis()
    local funcPanel3=self:getChildByName("funcPanel3")

    local middlePanel = {}
    middlePanel.getChildren = function()
        return { funcPanel3:getChildByName("vipSupplyBtn"),
            funcPanel3:getChildByName("giftBagBtn"),
            funcPanel3:getChildByName("legionGiftBtn")}
    end

    local t=0
    for i,v in pairs(middlePanel.getChildren()) do
        if self.vib[i]==true then
            t = t + 1
            if self:getChildByName("funcPanel3/upBtn").isVisible then
                self.btneffect[i]:setVisible(true)
                v:setVisible(true)
                v:setOpacity(255)
                v:getChildByName("btn"):runAction(cc.RotateTo:create(0,0))
            end
            v:setPositionX(-163) 
            v:setPositionY(-281+(t-1)*(-83.5)) 
            
            --v:setPositionY(-278)   
        end
        
    end
end

-- 设置位置：周卡
function ToolbarPanel:updateMidLeftVis()
    local funcPanel3 = self:getChildByName("funcPanel3")
    
    local vipSupplyBtn = self:getChildByName("funcPanel3/vipSupplyBtn")
    local giftBagBtn = self:getChildByName("funcPanel3/giftBagBtn")
    local legionGiftBtn = self:getChildByName("funcPanel3/legionGiftBtn")

    local middleLeftPanel = {}
    middleLeftPanel.getChildren = function()
        return { funcPanel3:getChildByName("weekCardBtn")}
    end

    local t=0
    for i,v in pairs(middleLeftPanel.getChildren()) do
        if self.vibL[i]==true then
            t = t + 1
            if self:getChildByName("funcPanel3/upBtn").isVisible then
                 self.btnLeffect[i]:setVisible(true)
                 v:setVisible(true)
                 v:setOpacity(255)
                 v:getChildByName("btn"):runAction(cc.RotateTo:create(0,0))
            end

            -- 根据周卡右边列按钮的显示，调整位置
            if vipSupplyBtn:isVisible() or giftBagBtn:isVisible() or legionGiftBtn:isVisible() then
                v:setPositionX(-249)
            else
                v:setPositionX(-163)
                logger:info("周卡特殊位置设置 -162")
            end

            v:setPositionY(-281+(t-1)*(-83.5))    
        end
        
    end
end

function ToolbarPanel:updateVipSupplyPoint()
    local vipSupplyProxy = self:getProxy( GameProxys.VipSupply )
    local num = vipSupplyProxy:getReceiveState()

    local vipSupplyBtn = self:getChildByName("funcPanel3/vipSupplyBtn")
    local dot = self:getChildByName( "funcPanel3/vipSupplyBtn/btn/dot" )
    local numtxt = dot:getChildByName("dotNum")
    numtxt:setString( num )
    dot:setVisible( num>0 )


    --//null  如果vip特供活动不显示 就把左边的活动向右移动 如果显示则像左移动
    local weekCardBtn = self:getChildByName("funcPanel3/weekCardBtn")

    if  num>=0  then
    vipSupplyBtn:setVisible(true)
    self.vib[1]=true
    else
    vipSupplyBtn:setVisible(false)
    self.vib[1]=false
    end
    if self.btneffect[1] == nil then
        local vipSupplyBtn = self:getChildByName("funcPanel3/vipSupplyBtn")
        self.btneffect[1] = self:createUICCBLayer("rgb-hdui-vip"--[["rgb-zjm-tubiao"]], vipSupplyBtn:getChildByName("btn"))
        local size = vipSupplyBtn:getContentSize()
        print("---------------"..size.width.."----Ssssssss----"..size.height)
        self.btneffect[1]:setPosition(size.width*0.4, size.height*0.4)
        self.btneffect[1]:setVisible(true)
        self.btneffect[1]:setLocalZOrder(0)
    end
    self:updateMidVis() 
end
--刷新周卡小红点已经控制周卡入口显示
function ToolbarPanel:updateWeekCardShowAndRedPoint()
    --等级未到或者没有数据不显示入口
    local actProxy = self:getProxy(GameProxys.Activity)
    local openInfo = actProxy:getWeekCardOpenInfo()
    local isOpen = self._roleProxy:isFunctionUnLock(54,false)

    local weekCardBtn = self:getChildByName("funcPanel3/weekCardBtn")
    local dot = self:getChildByName( "funcPanel3/weekCardBtn/btn/dot" )
    local numtxt = dot:getChildByName("dotNum")
    if openInfo.id ~= -1 and isOpen == true then
        weekCardBtn:setVisible(true)
        self.vibL[1]=true
        --小红点
        local cardInfo = actProxy:getWeekCardInfo()
        if cardInfo.id ~= -1 then
            --买过周卡，有剩余次数数据
            local cardState = actProxy:getWeekCardState()
            if cardState == 1 then
                --今天已经领过了
                dot:setVisible(false)
                weekCardBtn:setVisible(false)
                self.vibL[1]=false
            else
                numtxt:setString( 1 )
                weekCardBtn:setVisible(false)
                self.vibL[1]=false
                dot:setVisible(false)
            end
        else
            dot:setVisible(false)
        end


    else
        weekCardBtn:setVisible(false)
        self.vibL[1]=false
    end

    if self.btnLeffect[1] == nil then
        self.btnLeffect[1] = self:createUICCBLayer("rgb-hdui-zk", weekCardBtn:getChildByName("btn"))
        local size = weekCardBtn:getContentSize()
        self.btnLeffect[1]:setPosition(size.width*0.4, size.height*0.4)
        self.btnLeffect[1]:setLocalZOrder(0)
    end
    self:updateMidLeftVis()
end


function ToolbarPanel:onRebelsImgTouch(sender)

end

function ToolbarPanel:onUpdatePkgNum(num)
    -- print("礼包过期，更新红点数量")
    local dot = self:getChildByName("funcPanel3/activityCenter/btn/dot")
    local numtxt = dot:getChildByName("dotNum")
    dot:setVisible(num>0)
    numtxt:setString(num.."")
end

function ToolbarPanel:onUpdateLimitBtn(param)
    local activityCenter = self:getChildByName("funcPanel3/activityCenter")
    local activityProxy = self:getProxy(GameProxys.Activity)
    local limitData = activityProxy:getLimitActivityInfo()
    local battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
    local battleActivityInfo = battleActivityProxy:getActivityInfo()
    battleActivityInfo = battleActivityInfo or {}
    local see = #limitData + #battleActivityInfo
    if param == 2 then
        activityCenter:setVisible(see > 0)
        return 
    end
    -- if param == true then
    --     logger:error("显示了小红点不是2万协议的啊")
    -- else
    --     logger:error("不显示小红点不是2万协议的啊")
    -- end
    activityCenter:setVisible(see > 0)
end

-- 军团好礼按钮显示隐藏
function ToolbarPanel:onUpdateLegionGift(data)
    if self.lGiftBtn ~= nil then
        self.lGiftBtn.btnData = data
        self.lGiftBtn:setVisible(data ~= nil)
        self.vib[3]=(data ~= nil)
    end
    self:updateMidVis()
end


function ToolbarPanel:setGiftBagVisible()
    if self["giftBagBtn"] == nil then
        return
    end

    local giftBagproxy = self:getProxy(GameProxys.GiftBag)
    local giftBagInfos = giftBagproxy:getGiftBagAllInfos()
    local giftBagBtn = self:getChildByName("funcPanel3/giftBagBtn")
    if giftBagInfos ~= nil and #giftBagInfos > 0 then
    if self.vib[2]~=true then
        giftBagBtn:setVisible(true)
        self.vib[2]=true
        if self.btneffect[2] == nil then
            local size = self["giftBagBtn"]:getContentSize()
            self.btneffect[2] = self:createUICCBLayer("rgb-hdui-rmlb", giftBagBtn:getChildByName("btn"),nil, nil, nil)
            self.btneffect[2]:setPosition(size.width*0.4, size.height*0.4)
            if self._rightPanelState==false then
                self.btneffect[2]:setVisible(false)
            end
        end
    end
    else
        self["giftBagBtn"]:setVisible(false)
        self.vib[2]=false
    end

    self:updateMidVis()
end


function ToolbarPanel:onLGiftTouch(sender)
    -- local roleProxy = self:getProxy(GameProxys.Role)

    -- local isOpen = roleProxy:isFunctionUnLock(49, true, TextWords:getTextWord(3824))
    -- if not isOpen then
    --     return
    -- end

    -- local proxy = self:getProxy(GameProxys.Activity)
    -- local activeID = proxy:getLegionGiftID()
    -- proxy:setTmpToLegionGiftID(true)
    local data = {}
    data.moduleName = ModuleName.LegionGiftModule   --活动
    -- data.moduleName = ModuleName.GameActivityModule   --活动
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
end

function ToolbarPanel:onVipSupplyTouch( sender )
    local data = {}
    data.moduleName = ModuleName.VipSupplyModule   --vip特供
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
end

function ToolbarPanel:onWeekCardTouch( sender )
    --前往周卡切页
    --等级未到或者没有数据不跳转
    local actProxy = self:getProxy(GameProxys.Activity)
    local openInfo = actProxy:getWeekCardOpenInfo()
    local isOpen = self._roleProxy:isFunctionUnLock(54,false)
    if openInfo.id ~= -1 and isOpen == true then
        local _data = {}
        _data.moduleName = ModuleName.GameActivityModule
        _data.extraMsg = {
        jumpToId = 99998
        }
        self._roleProxy:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT, _data)
    end
    if isOpen == false then
        self._roleProxy:isFunctionUnLock(54,true)
    end
    
end

function ToolbarPanel:onActivityCenterTouch(sender)

    local data = {}
    data.moduleName = ModuleName.ActivityCenterModule   --活动中心
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)

end


------
-- 按钮
function ToolbarPanel:onUpBtnTouch(sender) 
    self._rightPanelState=false
    local isVisible = sender.isVisible
    local newVisible = not isVisible
    sender.isVisible = newVisible
    -- 重新设置按钮响应
    if self["lotteryEpBtn"] then
        self["lotteryEpBtn"]:setTouchEnabled(newVisible)
    end
    if self["activBtn"] then
        self["activBtn"]:setTouchEnabled(newVisible)
    end
    if self["openServerGiftBtn"] then
        --暂时屏蔽游戏中的30天登陆礼包和30后的老虎机功能   2016年11月22日16:23:26
        -- self["openServerGiftBtn"]:setTouchEnabled(newVisible)
        self["openServerGiftBtn"]:setTouchEnabled(false)
    end
    if self["treasureBtn"] then
        self["treasureBtn"]:setTouchEnabled(newVisible)
    end
    if self["shopBtn"] then
        self["shopBtn"]:setTouchEnabled(newVisible)
    end

    -- 公告
    if self["noticeBtn"] then
        self["noticeBtn"]:setTouchEnabled(newVisible)
    end
    self.btneffect[10]:setVisible(newVisible)
    -- 限时活动
    if self["activitybtn"] then
        self["activitybtn"]:setTouchEnabled(newVisible)
    end
    -- VIP特供
    if self["vipSupplyBtn"] then
        self["vipSupplyBtn"]:setTouchEnabled(newVisible)
    end
    -- 周卡
    if self["weekCardBtn"] then
        self["weekCardBtn"]:setTouchEnabled(newVisible)
    end
    --热卖礼包
    if self["giftBagBtn"] then
        self["giftBagBtn"]:setTouchEnabled(newVisible)
        self["giftBagBtn"].newVisible = newVisible
    end

    
    local lGiftBtn = self:getChildByName("funcPanel3/legionGiftBtn") -- 同盟大礼

    
    if newVisible then
        --lGiftBtn:setVisible(self.lGiftBtn.btnData ~= nil)
        self.vib[3]=(self.lGiftBtn.btnData ~= nil)
        lGiftBtn:setTouchEnabled(self.lGiftBtn.btnData ~= nil)
    else
        lGiftBtn:setTouchEnabled(newVisible)
        --lGiftBtn:setVisible(newVisible)
        self.vib[3] = newVisible
    end

    self:updateMidVis()  -- 刷新
    self:updateMidLeftVis() -- 刷新
    -- local dir = 1
    local upBtn=self:getChildByName("funcPanel3/upBtn")
    local upBtnpos=cc.p(upBtn:getPositionX()-36,upBtn:getPositionY()-36)
    self:initfun3(self._upPanel,self._rightPanel,self._middlePanel,self._middleLeftPanel)
    sender:stopAllActions()
    if newVisible == true then
        -- dir = 1
    sender:runAction(cc.RotateTo:create(0.4,0))
    self:MoveShowInAction(self._upPanel, newVisible,upBtnpos)
    self:MoveShowInAction(self._rightPanel, newVisible,upBtnpos)
    self:MoveShowInAction(self._middlePanel, newVisible,upBtnpos,true)
    self:MoveShowInAction(self._middleLeftPanel, newVisible,upBtnpos,true)
    else
        -- dir = -1
    sender:runAction(cc.RotateTo:create(0.4,-180))
    self:MoveShowOutAction(self._upPanel, newVisible,upBtnpos)
    self:MoveShowOutAction(self._rightPanel, newVisible,upBtnpos)
    self:MoveShowOutAction(self._middlePanel, newVisible,upBtnpos,true)
    self:MoveShowOutAction(self._middleLeftPanel, newVisible,upBtnpos,true)
    end

    
end
function ToolbarPanel:initfun3(panel,panel2,panel3,panel4)
    
    if self.everpos==nil then
        self.everpos={}
        local children = panel:getChildren()
        for _, child in pairs(children) do
            -- local name = child:getName()
            self.everpos[child:getName()]=cc.p(child:getPositionX(),child:getPositionY())
        end
        local children = panel2:getChildren()
        for _, child in pairs(children) do
            -- local name = child:getName()
            self.everpos[child:getName()]=cc.p(child:getPositionX(),child:getPositionY())
        end
        local children3 = panel3:getChildren()
        for _, child in pairs(children3) do
            -- local name = child:getName()
            self.everpos[child:getName()]=cc.p(child:getPositionX(),child:getPositionY())
        end
        local children4 = panel4:getChildren()
        for _, child in pairs(children4) do
            -- local name = child:getName()
            self.everpos[child:getName()]=cc.p(child:getPositionX(),child:getPositionY())
        end
        for i=1, 4 do
            -- local name = child:getName()
            self.everpos["t"..i]=cc.p(-162,-277+(i-1)*(-86))
        end
    end
end
function ToolbarPanel:MoveShowOutAction(panel,visible,opos,haseff)
    local children = panel:getChildren()
    if haseff==nil then
    for i, child in pairs(children) do
        if child:getName()=="activityCenter" then--活动中心特殊，开始
            self.btneffect[10]:setVisible(false)
            local ac1=cc.Spawn:create(cc.MoveTo:create(0.2,opos),cc.FadeTo:create(0.2,0))
        local ac2=cc.Sequence:create(cc.DelayTime:create(0.07*i),ac1)
        child:stopAllActions()
        child:runAction(ac2)
        local btn=child:getChildByName("btn")
        btn:setRotation(0)
        btn:stopAllActions()
        btn:runAction(cc.RotateTo:create(0.4,-90))
        return
        end--活动中心结束
        local ac1=cc.Spawn:create(cc.MoveTo:create(0.2,opos),cc.FadeTo:create(0.2,0))
        local ac2=cc.Sequence:create(cc.DelayTime:create(0.07*i),ac1)
        child:stopAllActions()
        child:runAction(ac2)
        local btn=child:getChildByName("btn")
        btn:setRotation(0)
        btn:stopAllActions()
        btn:runAction(cc.RotateTo:create(0.4,-90))
    end
    -- local caf=cc.CallFunc:create(function()
    -- -- panel:setVisible(false)
    -- end)
    -- local ac4=cc.Sequence:create(cc.DelayTime:create(0.4),caf)

    -- self._mainPanel:runAction(ac4)
    elseif  haseff==true then
            local vib
            local btneffect
            if panel.tag == 1 then
                vib = self.vibL
                btneffect = self.btnLeffect
            else
                vib = self.vib
                btneffect = self.btneffect
            end


        for i, child in pairs(children) do
            if btneffect[i]~=nil then
                btneffect[i]:setVisible(false)
            end
            child:setEnabled(false)
            local ac1=cc.Spawn:create(cc.MoveTo:create(0.2,opos),cc.FadeTo:create(0.2,0))
            local ac2=cc.Sequence:create(cc.DelayTime:create(0.07*i),ac1)
            child:stopAllActions()
            child:runAction(ac2)
            local btn=child:getChildByName("btn")
            btn:setRotation(0)
            btn:stopAllActions()
            btn:runAction(cc.RotateTo:create(0.4,-90))
        end
    end
end
function ToolbarPanel:MoveShowInAction(panel, visible, opos, haseff)
    local c1 = cc.MoveTo:create(0, opos)
    local children = panel:getChildren()

    if haseff == nil then
        for i, child in pairs(children) do
            if child:getName() == "activityCenter" then
                -- 活动中心特殊，开始
                local function showinhdzx()
                    self.btneffect[10]:setVisible(true)
                end
                self.btneffect[10]:setVisible(false)
                local dpos = cc.p(self.everpos[child:getName()].x - opos.x, self.everpos[child:getName()].y - opos.y)
                local npos = cc.p(opos.x + dpos.x * 1.1, opos.y + dpos.y * 1.1)
                local bpos = cc.p(opos.x + dpos.x * 0.95, opos.y + dpos.y * 0.95)
                local action = cc.Sequence:create(c1, cc.DelayTime:create(i * 0.07), cc.Spawn:create(cc.FadeTo:create(0.2, 255), cc.Sequence:create(cc.MoveTo:create(0.2, npos), cc.MoveTo:create(0.1, bpos), cc.MoveTo:create(0.1, self.everpos[child:getName()]))), cc.CallFunc:create(showinhdzx))
                child:setOpacity(0)
                child:stopAllActions()
                child:runAction(action)
                child:getChildByName("btn"):stopAllActions()
                child:getChildByName("btn"):setRotation(30)
                local ac2 = cc.RotateTo:create(0.4, 0)
                child:getChildByName("btn"):runAction(ac2)
                return
            end
            -- 活动中心结束
            local dpos = cc.p(self.everpos[child:getName()].x - opos.x, self.everpos[child:getName()].y - opos.y)
            local npos = cc.p(opos.x + dpos.x * 1.1, opos.y + dpos.y * 1.1)
            local bpos = cc.p(opos.x + dpos.x * 0.95, opos.y + dpos.y * 0.95)
            local action = cc.Sequence:create(c1, cc.DelayTime:create(i * 0.07), cc.Spawn:create(cc.FadeTo:create(0.2, 255), cc.Sequence:create(cc.MoveTo:create(0.2, npos), cc.MoveTo:create(0.1, bpos), cc.MoveTo:create(0.1, self.everpos[child:getName()]))))

            child:setOpacity(0)
            child:stopAllActions()
            child:runAction(action)
            child:getChildByName("btn"):stopAllActions()
            child:getChildByName("btn"):setRotation(30)
            local ac2 = cc.RotateTo:create(0.4, 0)
            child:getChildByName("btn"):runAction(ac2)
        end
    elseif haseff == true then
        local vib
        local btneffect
        if panel.tag == 1 then
            vib = self.vibL
            btneffect = self.btnLeffect
        else
            vib = self.vib
            btneffect = self.btneffect
        end

        local t = 0

        for i, child in pairs(children) do
            if vib[i] then
                t = t + 1
                child:setEnabled(true)
                local dpos = cc.p(self.everpos[child:getName()].x - opos.x, self.everpos[child:getName()].y - opos.y)
                local npos = cc.p(opos.x + dpos.x * 1.1, opos.y + dpos.y * 1.1)
                local bpos = cc.p(opos.x + dpos.x * 0.95, opos.y + dpos.y * 0.95)
                local function callbackeff()
                    btneffect[i]:setVisible(true)
                end
                local action = cc.Sequence:create(c1, cc.DelayTime:create(i * 0.07), cc.Spawn:create(cc.FadeTo:create(0.2, 255), cc.Sequence:create(cc.MoveTo:create(0.2, npos), cc.MoveTo:create(0.1, bpos), cc.MoveTo:create(0.1, self.everpos[child:getName()]))), cc.CallFunc:create(callbackeff))

                child:setOpacity(0)
                btneffect[i]:setVisible(false)
                child:stopAllActions()
                child:runAction(action)
                child:getChildByName("btn"):stopAllActions()
                child:getChildByName("btn"):setRotation(30)
                local ac2 = cc.RotateTo:create(0.4, 0)
                child:getChildByName("btn"):runAction(ac2)
            end
        end
    end
end


function ToolbarPanel:onActivBtnTouch()
    local roleProxy = self:getProxy(GameProxys.Role)

    local isOpen = roleProxy:isFunctionUnLock(49, true, TextWords:getTextWord(3824))
    if not isOpen then
        return
    end
    local data = {}
    --data.moduleName = ModuleName.ActivityModule
    data.moduleName = ModuleName.GameActivityModule   --活动
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
end

function ToolbarPanel:openServerGift(sender,index)
    --暂时屏蔽游戏中的30天登陆礼包和30后的老虎机功能  2016年11月22日16:22:23 
    -- local proxy = self:getProxy(GameProxys.Role)
    -- local tmpData = proxy:getOpenServerData()
    -- if tmpData == nil then
    --     return
    -- end
    -- local data = {}
    -- if tmpData.type == 1 then
    --     if index and index == 1 then return end

    --     local isUnlock = self._roleProxy:isFunctionUnLock(4,true)
    --     if isUnlock then
    --         data.moduleName = ModuleName.OpenServerGiftModule  --开服礼包
    --         self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
    --     end

    -- else
    --     if tmpData.allDay == -1 and index == 1 then
    --         return
    --     end
    --     data.moduleName = ModuleName.TigerMachineModule  --每日登陆抽奖
    --     self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
    -- end
end

function ToolbarPanel:onTreasureBtnTouch(sender)
    local isUnlock = self._roleProxy:isFunctionUnLock(5,true)
    if isUnlock then
        local data = {}
        data.moduleName = ModuleName.PubModule
        self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
    end
end

function ToolbarPanel:onLotteryEpBtnTouch(sender)
    local data = {}
    data.moduleName = ModuleName.LotteryEquipModule
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
end

function ToolbarPanel:onTheBuildingTouch(sender)

    local name = sender.name --:getName()
    local data = self._buildingMap[name]
    if data ~= nil then
        if data.moduleName == nil then
            --self:showSysMessage(data.msg)   --购买vip的建筑队列
            self.isCanRequireBuyVip = 0
            -- showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName)
--            self:dispatchEvent(ToolbarEvent.BUY_VIP_INFO_REQ)
            local buildingProxy = self:getProxy(GameProxys.Building)
            buildingProxy:buyVipBuilding()
        else

            if data.buildingType ~= nil and data.buildingIndexs ~= nil then
                local isOpen = sender.isOpen
                if isOpen ~= true then
                    local tipsText = nil
                    if data.buildingType == BuildingTypeConfig.MAKE then
                        tipsText = self:getTextWord(317)
                    elseif data.buildingType == BuildingTypeConfig.SCIENCE then
                        tipsText = self:getTextWord(305)
                    end
                    if tipsText then
                        self:showSysMessage(tipsText)
                    end
                    return
                end
                local buildingProxy = self:getProxy(GameProxys.Building)
                buildingProxy:setBuildingPos(data.buildingType, sender.buildingIndex)
            end
            
            if data.buildingType == BuildingTypeConfig.MAKE then --工匠坊
                ModuleJumpManager:jump(data.moduleName.."11_11",data.extraMsg.panel)
            elseif data.buildingType == BuildingTypeConfig.BARRACK then --兵营
                -- 如果两个兵营都有空余建造队列，就跳转到高等级的那一个
                -- 如果两个兵营都没有空余建造队列，也跳转到高等级的那一个
                -- 如果只有一个兵营有空余建造队列，就跳到那个兵营

                local buildingProxy = self:getProxy(GameProxys.Building)
                local buildingInfo1  = buildingProxy:getBuildingInfo(data.buildingType, 2)
                local buildingInfo2  = buildingProxy:getBuildingInfo(data.buildingType, 3)
                
                local name = data.moduleName
                local proNum1 = buildingInfo1.productNum - #buildingInfo1.productionInfos
                local proNum2 = buildingInfo2.productNum - #buildingInfo2.productionInfos
                if proNum1 > proNum2 then
                    name = name.."9_2"
                else
                    if proNum1 == proNum2 then
                        if buildingInfo1.level >= buildingInfo2.level then
                            name = name.."9_2"                       
                        else
                            name = name.."9_3"                         
                        end
                    else
                        -- 判断修改，如果第二个兵营没开放，跳到第一个兵营
                        if buildingProxy:isBuildingOpen(data.buildingType, 3, true) then
                            name = name.."9_3"                         
                        else
                            name = name.."9_2" 
                        end
                    end
                end
                -- print("测试 name="..name..",proNum1="..proNum1..",proNum2="..proNum2)
                -- ModuleJumpManager:jump(data.moduleName,data.extraMsg.panel)
                ModuleJumpManager:jump(name,data.extraMsg.panel)
            else
                ModuleJumpManager:jump(data.moduleName,data.extraMsg.panel)
            end

        end
    end
end



function ToolbarPanel:onTaskTipsTouch()
    local taskProxy = self:getProxy(GameProxys.Task)
    local taskInfo = taskProxy:getMainTaskListByType(1)
    if taskInfo.state == 1 then
        --已完成
        -- TODO:该动画缺少complete帧,先用该方法替换上面
        if self._renwuZhiCCB ~= nil then
            self._renwuZhiCCB:finalize()
            self._renwuZhiCCB = nil
        end
        self._renwuZhiCCB = self:createUICCBLayer("rgb-renwu-zhi", self._taskTips:getChildByName("Image_89"), nil, nil, true) 
        self._renwuZhiCCB:setPosition(0,8)    
        local data = {}
        data.tableType = taskInfo.tableType
        data.typeId = taskInfo.typeId
        taskProxy:onTriggerNet190001Req(data)
    else
        --未完成
        local conf = taskInfo.conf
        --local conf = ConfigDataManager:getConfigById(ConfigData.MainMissionConfig, 84)

        if conf.guideID then
            -- print(".... 未完成 taskInfo.typeId,conf.guideID",taskInfo.typeId,conf.guideID)
            taskProxy:setMainTaskGuide(taskInfo,true)

            if conf.guideID ~= 231 then  --213剿匪任务，不跳转
                self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, { moduleName = ModuleName.MainSceneModule } )
                self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, { moduleName = ModuleName.RoleInfoModule } )
            end

            if conf.guideID == 105 then --引导特殊的副本任务，设置引导关卡信息
                taskProxy:setGuideDungeonInfo(conf.finishcond1)
            end

            GuideManager:trigger(conf.guideID, true)
        else
            -- print("前往 conf.jumpmodule="..conf.jumpmodule)
            taskProxy:setBarrackRecruitGuide(taskInfo)
            taskProxy:setMainTaskGuide(taskInfo,true)
            local moduleName = conf.jumpmodule
            local panelName = conf.reaches    
            ModuleJumpManager:jump(moduleName, panelName)
        end
    end
end

-- 支线任务
function ToolbarPanel:onTaskTips2Touch()
    local taskProxy = self:getProxy(GameProxys.Task)
    local taskInfo = taskProxy:getMainTaskListByType(2)
    -- if taskInfo.conf.finishcond2 <= taskInfo.num then
    if taskInfo.state == 1 then
        --已完成
        --local ccb = self:createUICCBLayer("rgb-renwu-zhu", self._taskTips2:getChildByName("icon"), nil, nil, true) 
        --ccb:setPosition(0,8)  
        -- TODO:该动画缺少complete帧,先用该方法替换上面
        if self._renwuZhuCCB ~= nil then
            self._renwuZhuCCB:finalize()
            self._renwuZhuCCB = nil
        end

        self._renwuZhuCCB = self:createUICCBLayer("rgb-renwu-zhu", self._taskTips2:getChildByName("icon"), nil, nil, true)
        self._renwuZhuCCB:setPosition(0,8)  

        
        local data = {}
        data.tableType = taskInfo.tableType
        data.typeId = taskInfo.typeId
        taskProxy:onTriggerNet190001Req(data)
    else
        --未完成
        local conf = taskInfo.conf
        if conf.guideID then
            taskProxy:setMainTaskGuide(taskInfo,true)

            if conf.guideID ~= 231 then  --213剿匪任务，不跳转
                self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, { moduleName = ModuleName.MainSceneModule } )
                self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, { moduleName = ModuleName.RoleInfoModule } )
            end

            if conf.guideID == 105 then --引导特殊的副本任务，设置引导关卡信息
                taskProxy:setGuideDungeonInfo(conf.finishcond1)
            end

            GuideManager:trigger(conf.guideID, true)
        else
            -- print("支线任务 前往 conf.jumpmodule="..conf.jumpmodule)
            taskProxy:setMainTaskGuide(taskInfo,true)
            local moduleName = conf.jumpmodule
            local panelName = conf.reaches    
            ModuleJumpManager:jump(moduleName, panelName)
        end
    end
end

-- 主线任务更新
function ToolbarPanel:updateTaskTips()
    local taskProxy = self:getProxy(GameProxys.Task)
    local taskInfo = taskProxy:getMainTaskListByType(1)
    if taskInfo == nil then
        self._taskTips:setVisible(false)  
        return 
    end
    self._taskTips:setVisible(true)  


    -- 任务已完成
    self:updateTaskTipsEffect(self._taskTips,taskInfo,"rgb-renwu-wancheng",40,22)


    local taskNameTxt = self._taskTips:getChildByName("taskNameTxt")


    local taskProTxt = self._taskTips:getChildByName("proTxt")

    local rickLabel = taskProTxt.rickLabel
    if rickLabel == nil then
        rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        taskProTxt:addChild(rickLabel)
        taskProTxt.rickLabel = rickLabel
    end
   
    local curColor
    if taskInfo.num < taskInfo.conf.finishcond2 then
        curColor = ColorUtils.wordRedColor16
    else
        curColor = ColorUtils.wordGreenColor16
        -- local ccb=UICCBLayer.new("rgb-renwu-zhi",self._taskTips:getChildByName("Image_89"))
    end

    -- 进度 默认显示格式 (xx/xx)
    local curNum,maxNum
    local stype = taskInfo.conf.stype
    -- if stype == 5 then  -- 任务小类：战胜xxx，显示格式（进度：0/1）
    --     maxNum = 1
    --     curNum = taskInfo.num
    --     if curNum > maxNum then
    --         curNum = maxNum
    --     end
    -- else
        curNum = StringUtils:formatNumberByK3(taskInfo.num)
        maxNum = StringUtils:formatNumberByK3(taskInfo.conf.finishcond2)        
    -- end
    --//null
    local info = {{{"(", 17,ColorUtils.wordWhiteColor16},{curNum, 17, curColor}, {"/"..maxNum, 17, ColorUtils.wordWhiteColor16},{")", 17,ColorUtils.wordWhiteColor16}}}
    if stype == 10 or stype == 46 or stype == 47 or stype == 38 or stype == 5 or stype == 41 then  --任务小类 显示格式 进度：未完成/已完成
        if taskInfo.conf.finishcond2 <= taskInfo.num then
            info = {{{"(", 17,ColorUtils.wordWhiteColor16},{TextWords:getTextWord(1330),17,curColor},{")", 17,ColorUtils.wordWhiteColor16}}}   
        else
            info = {{{"(", 17,ColorUtils.wordWhiteColor16},{TextWords:getTextWord(1329),17,curColor},{")", 17,ColorUtils.wordWhiteColor16}}}   
        end
    end
    rickLabel:setString(info)
    taskProTxt:setString("")
    logger:error("当前主线任务为：%s",taskInfo.conf.name)
    taskNameTxt:setString(taskInfo.conf.name)

    -- 对齐调整
    local nameSize = taskNameTxt:getContentSize()
    local richSize = rickLabel:getContentSize()
    taskProTxt:setPositionX(taskNameTxt:getPositionX() + nameSize.width + 4)
    rickLabel:setPosition(cc.p(0, 11))

    -- -- 底图长度根据文字长度动态变化
    -- local btnSize = self._taskTips:getContentSize()
    -- local totalTxtWidth = nameSize.width + richSize.width + 4
    -- local dx = totalTxtWidth + 40 + 10
    -- self._taskTips:setContentSize(dx,btnSize.height)

end

-- 支线任务更新
function ToolbarPanel:updateTaskTips2()
    local taskProxy = self:getProxy(GameProxys.Task)
    local taskInfo = taskProxy:getMainTaskListByType(2)
    self:updateQuickTaskPosY(taskInfo)
    if taskInfo == nil then
        self._taskTips2:setVisible(false)  
        return 
    end
    self._taskTips2:setVisible(true)


    -- 任务已完成
    self:updateTaskTipsEffect(self._taskTips2,taskInfo,"rgb-renwu-wancheng"--[["rgb-zjm-renwuzhih"]],40,22)


    local taskNameTxt = self._taskTips2:getChildByName("taskNameTxt")
    local taskProTxt = self._taskTips2:getChildByName("proTxt")

    local rickLabel = taskProTxt.rickLabel
    if rickLabel == nil then
        rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        taskProTxt:addChild(rickLabel)
        taskProTxt.rickLabel = rickLabel
    end
       
    local curColor
    if taskInfo.num < taskInfo.conf.finishcond2 then
        curColor = ColorUtils.wordRedColor16
    else
        curColor = ColorUtils.wordGreenColor16
        -- local ccb=UICCBLayer.new("rgb-renwu-zhu",self._taskTips2:getChildByName("icon"))
    end

    -- 进度 默认显示格式 (xx/xx)
    local curNum,maxNum
    local stype = taskInfo.conf.stype
    -- if stype == 5 then  -- 任务小类：战胜xxx，显示格式（进度：0/1）
    --     maxNum = 1
    --     curNum = taskInfo.num
    --     if curNum > maxNum then
    --         curNum = maxNum
    --     end
    -- else
        curNum = StringUtils:formatNumberByK3(taskInfo.num)
        maxNum = StringUtils:formatNumberByK3(taskInfo.conf.finishcond2)        
    -- end

    local info = {{{"(", 17,ColorUtils.wordWhiteColor16},{curNum, 17, curColor}, {"/"..maxNum, 17, ColorUtils.wordWhiteColor16},{")", 15,ColorUtils.wordWhiteColor16}}}
    if stype == 10 or stype == 46 or stype == 47 or stype == 38 or stype == 5 or stype == 41 then  --任务小类 显示格式 进度：未完成/已完成
        if taskInfo.conf.finishcond2 <= taskInfo.num then
            info = {{{"(", 17,ColorUtils.wordWhiteColor16},{TextWords:getTextWord(1330),17,curColor},{")", 17,ColorUtils.wordWhiteColor16}}}   
        else
            info = {{{"(", 17,ColorUtils.wordWhiteColor16},{TextWords:getTextWord(1329),17,curColor},{")", 17,ColorUtils.wordWhiteColor16}}}   
        end
    end
    taskProTxt:setString("")
    rickLabel:setString(info)
    taskNameTxt:setString(taskInfo.conf.name)

    -- 对齐调整
    local nameSize = taskNameTxt:getContentSize()
    local richSize = rickLabel:getContentSize()
    taskProTxt:setPositionX(taskNameTxt:getPositionX() + nameSize.width + 4)
    rickLabel:setPosition(cc.p(0, 11))

    -- -- 底图长度根据文字长度动态变化
    -- local btnSize = self._taskTips2:getContentSize()
    -- local totalTxtWidth = nameSize.width + richSize.width + 4
    -- local dx = totalTxtWidth + 40 + 10
    -- self._taskTips2:setContentSize(dx,btnSize.height)

end

function ToolbarPanel:updateTaskTipsEffect(target,taskInfo,effectName,posX,posY)
    -- 任务已完成特效
    if target.effectComplet then
        target.effectComplet:setVisible(false)
    end    
    if taskInfo.conf.finishcond2 <= taskInfo.num then
        --完成特效显示
        if target.effectComplet then
            target.effectComplet:setVisible(true)
        else
            target.effectComplet = self:createUICCBLayer(effectName, target, nil, nil, true)
            target.effectComplet:setPosition(posX,posY)
            -- local zhu=target:getChildByName("Image_89")
            -- zhu.effectComplet=UICCBLayer.new("rgb-renwu-zhu", zhu)
        end
    end

end

-- 动态调整快捷任务的Y坐标
function ToolbarPanel:updateQuickTaskPosY(taskInfo)
    local boomBtn = self.boomBtn
    if boomBtn == nil then
        boomBtn = self:getChildByName("funcPanel4/boomBtn")
    end

    local initY0 = boomBtn.initY
    local initY1 = self._taskTips.initY
    local initY2 = self._taskTips2.initY
    if initY0 == nil then
        initY0 = boomBtn:getPositionY()
        boomBtn.initY = initY0
    end

    if initY1 == nil then
        initY1 = self._taskTips:getPositionY()
        self._taskTips.initY = initY1
    end
    if initY2 == nil then
        initY2 = self._taskTips2:getPositionY()
        self._taskTips2.initY = initY2
    end

    if taskInfo == nil then
        -- 没有支线任务，坐标下移
        boomBtn:setPositionY(initY1)
        self._taskTips:setPositionY(initY2)
    else
        -- 有支线任务，坐标上移
        boomBtn:setPositionY(initY0)
        self._taskTips:setPositionY(initY1)
    end
end


-- 实名制按钮刷新
function ToolbarPanel:onRealNameBtnVisible()
    if GameConfig.isOpenRealNameVerify ~= true then
        self._realNameBtn:setVisible(false)  --未开启实名认证
        return
    end

    local realNameProxy = self:getProxy(GameProxys.RealName)
    local info = realNameProxy:getRealNameInfo()
    if info == nil then
        self._realNameBtn:setVisible(false)
        return
    end

--    -- 等级还没到
--    local openLevel = ConfigDataManager:getConfigById(ConfigData.RealNameConfig, 1).openLevel
--    if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) < openLevel then
--        self._realNameBtn:setVisible(false)
--        return
--    end

    if info.state == 1 then
        self._realNameBtn:setVisible(true)  --未实名
        local stateImg = self._realNameBtn:getChildByName("stateImg")
        TextureManager:updateImageView(stateImg,"images/toolbar/Img_realName_1.png")
    elseif info.state == 2 then
        self._realNameBtn:setVisible(true)  --未成年
        local stateImg = self._realNameBtn:getChildByName("stateImg")
        TextureManager:updateImageView(stateImg,"images/toolbar/Img_realName_2.png")
    elseif info.state == 3 then
        self._realNameBtn:setVisible(false) --已实名
    elseif info.state == 0 then -- 未开启
        self._realNameBtn:setVisible(false)
    end
end

-- 实名制按钮
function ToolbarPanel:onRealNameBtnTouch(sender)
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,{moduleName = ModuleName.RealNameModule})
end

function ToolbarPanel:onbuildBtnTouch(sender)
    local isVisible = sender.isVisible
    local queuePanel = self:getChildByName("funcPanel1/queuePanel")

    local newVisible = not isVisible
    sender.isVisible = newVisible
    
    local dir = 1
    if newVisible == true then
        dir = 1
    else
        dir = -1
    end
    sender:setScaleX(dir)
    
--    self:updateBuildingInfo()
--    queuePanel:setVisible(newVisible)
    
    NodeUtils:queueShowAction(queuePanel, newVisible, "y")
end
function ToolbarPanel:updateChatInfos(chats)
    local time = os.clock()
    --print("有新聊天", #chats)
    if self.allLen == 0 then
        self.allLen = #chats
    else
        self.allLen = self.allLen + #chats
    end
    if chats[#chats] then
        self:updateChatLineInfo(chats[#chats])
    end
end

function ToolbarPanel:hideChatContent()

--    print("关闭信息")
    self.allLen = 0
    self._talkNameTxt:setVisible(false)
    self._talkTxt:setVisible(false)
end

function ToolbarPanel:renderChatNum(param)
    local proxy = self:getProxy(GameProxys.Chat)
    local num = param or 0 

    if num > 0 then
        self.chatNumBg:setVisible(true)
        self.chatNumTxt:setString(num)
    else
        self.chatNumBg:setVisible(false)
        self.chatNumTxt:setString("")
    end
    
    --self.chatNumBg:setVisible(false) --by zxq 聊天面板实时刷新，这里就不显示小红点了
end

ToolbarPanel.noticeNum = 0
function ToolbarPanel:updateChatLineInfo(chat)
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
    local talkNameTxt = self._talkNameTxt

    local context = chat.context
    if chat.contextType == 2 then --语音不显示内容
        context = ""
    end
 
    talkNameTxt:setVisible(false)

    -- talkNameTxt:setString(chat.name .. ":")
    talkNameTxt:setString("")
    self._talkTxt:setString("")
    local nameSize = talkNameTxt:getContentSize()
    local nameX = talkNameTxt:getPositionX()
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
            self._chatItem = RichTextMgr:getInstance():getRich(chatParams, nil, nil, nil, nil, 2)
            self._panelTalk:addChild(self._chatItem)
         else
            self._chatItem:setData(chatParams)
        end
        self._chatItem:setVisible(true)
        self._chatItem:setAnchorPoint(0, 0.5)
        self._chatItem:setPosition(talkNameTxt:getPosition())
    else
        if self._chatItem ~= nil then
            self._chatItem:setVisible(false)
        end
        local text = RichTextMgr:getInstance():getNoticeParams(chat.context, true)
        local labelText = chat.name..":"..text
        local chatText = StringUtils:formatShortContent(labelText, 20)
        talkNameTxt:setVisible(true)
        talkNameTxt:setColor(ColorUtils.wordGreenColor)
        talkNameTxt:setString(chatText)
    end
end
-- function ToolbarPanel:Touchmove(obj, sender, movePos)
-- if obj==nil then return nil end
-- if obj:getTextureRect():containsPoint(movePos) then--如果点击了
-- obj:setScale(1.2)
-- else
-- obj:setScale(1)
-- end
-- end

-- function ToolbarPanel:Touchingbigger(sender)
--         sender:stopAllActions()
--         sender:setScale(1)
--         -- local act=cc.Sequence:create(,cc.ScaleTo:create(0.1,1))
--         sender:runAction(cc.ScaleTo:create(0.1,1.2))
-- end
--点击跳到对应的模块中去
function ToolbarPanel:onBtnItemTouch(sender, callbackArg)
    sender:stopAllActions()
    sender:runAction(cc.ScaleTo:create(0.1, 1))
    local index = sender.index
    local moduleName = self.btnModuleList[index]
    if moduleName == "help" then
        -- 打开帮助页面
        SDKManager:showWebHtmlView("html/help.html")

    elseif moduleName == ModuleName.MapMilitaryModule then
        if self._roleProxy:isFunctionUnLock(61, true) then
            self.view:showOtherModule( { moduleName = moduleName })
        end

    elseif moduleName == ModuleName.RankModule then
        local roleProxy = self:getProxy(GameProxys.Role)
        if self._roleProxy:isFunctionUnLock(48) then        
            self.view:showOtherModule( { moduleName = moduleName })
        end

    elseif moduleName ~= nil then
        if moduleName == ModuleName.InstanceModule or moduleName == ModuleName.RegionModule then
            if callbackArg == true then
                local dungeonProxy = self:getProxy(GameProxys.Dungeon)
                dungeonProxy:onExterInstanceSender(0)
                return
            end
        end
        self.view:showOtherModule( { moduleName = moduleName })
    end

end

function ToolbarPanel:setCurSceneState(moduleName, visible)
    if visible == nil then
        visible = true
    end

    self._currOpenModule = moduleName
    local sceneBtn = self:getChildByName("mainPanel/sceneBtn")
    if moduleName == ModuleName.MapModule then
        sceneBtn.index = 2
        -- 世界地图
        for index = 2, 3 do
            local funcPanel = self:getChildByName("funcPanel" .. index)
            funcPanel:setVisible(false)
        end
        local funcPanel = self:getChildByName("funcPanel4")
        funcPanel:setVisible(true)

        local redBagPanel = self:getChildByName("redBagPanel")
        redBagPanel:setVisible(false)

        local funcPanel2 = self:getChildByName("funcPanel2")
        funcPanel2:getChildByName("btnItem11"):setVisible(false)
        funcPanel2:getChildByName("btnItem10"):setVisible(false)
        funcPanel2:setVisible(true)
        self:getChildByName("funcPanel1/ldBtnBg"):setVisible(false)
        
    elseif moduleName == ModuleName.MainSceneModule then
        sceneBtn.index = 1
        -- 主城场景
        local funcPanel2 = self:getChildByName("funcPanel2")
        funcPanel2:getChildByName("btnItem11"):setVisible(false)
        funcPanel2:getChildByName("btnItem10"):setVisible(false)

        for index = 1, 4 do
            local funcPanel = self:getChildByName("funcPanel" .. index)
            funcPanel:setVisible(visible)
            -- 引导过程中，不显示其他按钮，只显示任务Tips
            self:getChildByName("mainPanel/queueBtnBg"):setVisible(visible)
            if index == 4 then
                funcPanel:setVisible(true)
            end
        end
        self:backInitPos()
        local upBtn = self:getChildByName("funcPanel3/upBtn")
        if self._rightPanelState then
            self:onUpBtnTouch(upBtn)
        end
        local redBagPanel = self:getChildByName("redBagPanel")
        redBagPanel:setVisible(visible)

        funcPanel2:getChildByName("btnItem11"):setVisible(true)
        funcPanel2:getChildByName("btnItem10"):setVisible(true)
        self:getChildByName("funcPanel1/ldBtnBg"):setVisible(true)
        -- self:getChildByName("mainPanel/bg_worldrank"):setVisible(false)
        local queuePanel = self:getChildByName("funcPanel1/queuePanel")
        queuePanel:setVisible(false)
        self:isShowleftBtn(false)
        self._queueBtn:stopAllActions()
        self._queueBtn:runAction(cc.MoveTo:create(0.3, self._queueBtnpos))
        self["queuePanelVis"] = false
    end

    self:setSceneName(sceneBtn)
end


--更新季节
function ToolbarPanel:updateSeason(isNotOne)

    local seasonUrl = {
        "images/toolbar/jj_c.png",
        "images/toolbar/jj_x.png",
        "images/toolbar/jj_q.png",
        "images/toolbar/jj_d.png",
        "images/toolbar/jj_j.png",--季节
    }


    local seasonProxy = self:getProxy(GameProxys.Seasons)

    local jieqiPng = self:getChildByName("mainPanel/btnListView/jieqi_btn/jijie")

    if seasonProxy:isWorldSeasonOpen() then
        local season =  seasonProxy:getCurSeason()
        TextureManager:updateImageView(jieqiPng, seasonUrl[season])
    else
        TextureManager:updateImageView(jieqiPng, seasonUrl[5])
    end

end

--更新世界等级

function ToolbarPanel:updateWorldLevel()

    local seasonProxy = self:getProxy(GameProxys.Seasons)

    local bg_worldrank = self:getChildByName("mainPanel/bg_worldrank")
    local text = bg_worldrank:getChildByName("worldrank")

    if seasonProxy:isWorldLevelOpen() then

        bg_worldrank:setVisible(true)

        local worldLevel = seasonProxy:getWorldLevel()

        text:setString(string.format(self:getTextWord(500013),worldLevel))
    else

        bg_worldrank:setVisible(false)

    end

end


function ToolbarPanel:onSceneBtnTouch(sender)
-- local url = "images/toolbar/Icon_camp.png"
    if sender.index == 1 then
--     url = "images/toolbar/Icon_camp_world.png"
-- TextureManager:updateImageView(sender, url)
        self.view:showOtherModule({moduleName = ModuleName.MapModule})
        -- self:showSysMessage(self:getTextWord(3025))--搜索敌人发起攻击
        -- setSceneName

    else
        -- TextureManager:updateImageView(sender, url)
        self.view:showOtherModule({moduleName = ModuleName.MainSceneModule})
        -- self:showSysMessage(self:getTextWord(3026))--管理主公的城池
    end
    -- NodeUtils:addSwallow()
    
end

function ToolbarPanel:setSceneName(sceneBtn)
    local index = sceneBtn.index

    local funcPanel6 = { }
    funcPanel6[1] = self:getChildByName("funcPanel2/btnItem12")
    funcPanel6[2] = self:getChildByName("funcPanel2/btnItem6")
    funcPanel6[3] = self:getChildByName("funcPanel2/btnItem4")
    funcPanel6[4] = self:getChildByName("funcPanel2/btnItem7")
    funcPanel6[5] = self:getChildByName("funcPanel2/btnItem10")
    funcPanel6[6] = self:getChildByName("funcPanel2/btnItem11")

    local url = "images/toolbar/Icon_camp.png"
    if index == 2 or index == 3 then
        for i = 1, 4 do
            funcPanel6[i]:setPosition(cc.p(funcPanel6[1]:getPositionX(), -300 -(3 - i) *(70)))
        end
    else

        url = "images/toolbar/Icon_camp_world.png"
        for i = 1, 4 do
            funcPanel6[i]:setPosition(cc.p(funcPanel6[1]:getPositionX(), -300 -(3 - i) *(70)))
        end
    end
    TextureManager:updateImageView(sceneBtn, url)
end

function ToolbarPanel:onChatBtnTouch()
    self.chatInfoNumber = 0
    self.chatNumBg:setVisible(false)
    self.chatNumTxt:setString("")
    self:hideChatContent()
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.ChatModule} )
end
--商城按钮回调
function ToolbarPanel:onShopBtnTouch(sender)

    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.ShopModule} )
end 

function ToolbarPanel:onClosePanelHandler()
    ToolbarPanel.super.onClosePanelHandler(self)
end

-- function ToolbarPanel:onNewMailsResp(data)
--     local notRead = self:getChildByName("mainPanel/btnListView/btnItem4/notRead")
--     notRead:setString(data.num)
-- end

-- 任务红点：可领取数量
--function ToolbarPanel:onTaskNumResp(data)
--    local dot = self:getChildByName("mainPanel/btnListView/btnItem6/dot")
--    local dotNum = dot:getChildByName("dotNum")
--    
--    local num = data.num or 0
--    if num == 0 then
--        dot:setVisible(false)
--        return
--    else
--        dot:setVisible(true)
--        dotNum:setString(data.num)
--    end
--
--end
--是否购买vip建筑位
function ToolbarPanel:isCanBuyVipBuilding(data)
    if self.isCanRequireBuyVip ~= 0 then
        self.isCanRequireBuyVip = 0
        return




    end
    local function buyBuildingVip()
        local sender = {}
        sender.gold = data
        self:sureBuyBuilding(sender)
    end
    local function notBuyBuildingVip()
    end
    local content = string.format(self:getTextWord(8304),data)
    self:showMessageBox(content, buyBuildingVip, notBuyBuildingVip,"购买","取消")
end

--执行购买vip建筑
function ToolbarPanel:sureBuyBuilding(sender)
    local function callFunc()
        --发送购买消息
        self:dispatchEvent(ToolbarEvent.BUY_VIP_INFO_SURE)
    end
    sender.callFunc = callFunc
    self:isShowRechargeUI(sender)
end

function ToolbarPanel:onShowRechargeUI()
    local parent = self:getParent()
    local panel = parent.panel
    if panel == nil then
        local panel = UIRecharge.new(parent, self)
        parent.panel = panel
    else
        panel:show()
    end
end

function ToolbarPanel:isShowRechargeUI(sender)
    local needMoney = sender.gold
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold  then
--        local parent = self:getParent()
--        local panel = parent.panel
--        if panel == nil then
--            local panel = UIRecharge.new(parent, self)
--            parent.panel = panel
--        else
--            panel:show()
--        end
        self:onShowRechargeUI()
    else
        sender.callFunc()
    end
end

-- 小红点更新
function ToolbarPanel:onUpdateTipsResp(data)  
    local btnTb = {}
    for index = 1,3 do
        btnTb[index] = self:getChildByName("mainPanel/btnListView/ListView_btns/btnItem"..index.."/dot")
    end
    btnTb[4] = self:getChildByName("funcPanel2/btnItem4/dot")
    btnTb[5] = self:getChildByName("mainPanel/btnListView/ListView_btns/btnItem5/dot")
    btnTb[6] = self:getChildByName("funcPanel2/btnItem6/dot")

    btnTb[7] = self:getChildByName("funcPanel3/lotteryEpBtn/dot") --拜访名将
    btnTb[8] = self:getChildByName("mainPanel/btnListView/ListView_btns/btnItem8/dot")
    btnTb[9] = self:getChildByName("funcPanel3/treasureBtn/dot") -- 点兵 9
    btnTb[10] = nil --军械
    btnTb[11] = self:getChildByName("funcPanel3/activBtn/dot") --活动
    btnTb[12] = self:getChildByName("funcPanel3/openServerBtn/dot") --开发礼包
    btnTb[13] = self:getChildByName("funcPanel3/activityCenter/btn/dot")
    btnTb[14] = self:getChildByName("funcPanel3/legionGiftBtn/btn/dot")
    btnTb[15] = self:getChildByName("funcPanel2/btnItem12/dot")

    for _, dot in pairs(btnTb) do
        dot:setVisible(false)
    end
    
    if data == nil then
        local activityProxy = self:getProxy(GameProxys.Activity)
        data = activityProxy:getAllTipsData()
        if data == nil then 
            return 
        end
    end

    local activityCenter = self:getChildByName("funcPanel3/activityCenter")  --活动中心
    local dot = self:getChildByName("funcPanel2/btnItem4/dot")
    local dotNum = dot:getChildByName("dotNum")

    local sceneBtn = self:getChildByName("mainPanel/sceneBtn")


    local activityProxy = self:getProxy(GameProxys.Activity)
    local limitData = activityProxy:getLimitActivityInfo()
    local battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
    local battleActivityInfo = battleActivityProxy:getActivityInfo()
    battleActivityInfo = battleActivityInfo or {}
    local len = #limitData + #battleActivityInfo

    local redPoint = self:getProxy(GameProxys.RedPoint)
   
    for _,v in pairs(data) do
        if btnTb[v.type] ~= nil then
            if v.type == 13 then
                activityCenter:setVisible(len > 0)
                v.num = redPoint:getAllLimitRedNum()
                v.num = v.num + redPoint:getServerActivityRedNum()
            end
            if v.type == 4 and v.num <= 0 then 
                -- mailTigBtn:setVisible(false)
                dot:setVisible(false)
                dotNum:setString(0)
            end
            
            if v.num == nil or v.num <= 0 then
                btnTb[v.type]:setVisible(false)

                if v.type == 15 then
                    local dotNum = btnTb[v.type]:getChildByName("dotNum")
                    dotNum:setString(v.num or 0)
                end 
            else
                if v.type == 4 and v.num > 0 then --邮件提示
                    dotNum:setString(v.num)
                end
                --if v.type ~= 6 then
                    btnTb[v.type]:setVisible(true)
                    local dotNum = btnTb[v.type]:getChildByName("dotNum")
                    dotNum:setString(v.num)  
                --end
            end
        end
    end

    self:updateLevel()
end

--更新聊天的NUM
function ToolbarPanel:onUpdateNoSeeChatNum(num)
    -- print("收到你的通知了，谢谢啊啊啊")
    local sceneBtn = self:getChildByName("mainPanel/sceneBtn")
    -- local funcPanel5 = self:getChildByName("mainPanel/mailTigBtn")
    -- local dot = self:getChildByName("mainPanel/mailTigBtn/dot")
    -- local dotNum = dot:getChildByName("dotNum")
    if sceneBtn.index ~= 2 then --世界地图
    end

    -- if sceneBtn.index ~= 3 and sceneBtn.index ~= 2 then --军团和世界不显现未读邮件提示
    --     if tonumber(dotNum:getString()) > 0 then
    --         funcPanel5:setVisible(true)
    --     else
    --         funcPanel5:setVisible(false)
    --     end
    -- end
    if self.chatNumTxt then
        if num > 0 then
            self.chatNumBg:setVisible(true)
            self.chatNumTxt:setString(num)
        else
            self.chatNumBg:setVisible(false)
            self.chatNumTxt:setString("")
        end
    end
end


------
-- 右侧的四个按钮的响应事件
function ToolbarPanel:onTouchTeamInfoButton(sender)
    if sender.index == 1 then
        local data = {}
        data.moduleName = ModuleName.TeamModule
        data.extraMsg = "workTarget"
        self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, data)
    elseif sender.index == 2 then
        local parent = self:getParent()
        if self._uiTeamInfo == nil then
            self._uiTeamInfo = UITeamInfo.new(parent,self,{})
        end
        self._uiTeamInfo:showAllInfo(self.beAttactList,self.beAttactedTime)
    elseif sender.index == 3 then
        local parent = self:getParent()
        if self._uiTeamInfo == nil then
            self._uiTeamInfo = UITeamInfo.new(parent,self,{})
        end
        local tmpTime = math.ceil(self.beStationTime)
        self._uiTeamInfo:showBeStationInfo(self.beStationData,tmpTime)
        -- self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.CheckTeamModule} )
    end
end
--跳到邮件模块
function ToolbarPanel:onMailTouch(sender)
 local data = {}
    data.moduleName = ModuleName.MailModule
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
end

function ToolbarPanel:onNoticeTouch(sender)
    -- print("touch")
    local dot = sender:getChildByName("dot")
    dot:setVisible(false)
    TimerManager:addOnce(1000, function()
        self.noticeNum = 0
        --self.nBtn:setVisible(false)
    end, self)
    local params = {}
    params["game_id"] = GameConfig.gameId
    params["os"] = GameConfig.osName
    params["plat_id"] = GameConfig.platformChanleId
    params["server_id"] = GameConfig.serverId
    params["service"] = "Notice.GetNotice"
    
    local url = HttpRequestManager:packUrlByParams(GameConfig.admincenter_api_url,params)
    SDKManager:showWebHtmlView(url)
end



function ToolbarPanel:setDefendTeam(data)
    self:dispatchEvent(ToolbarEvent.SET_DEFEND_TEAM,data)
end

function ToolbarPanel:isShowRankItem()
    if VersionManager:isShowRank() ~= true then
        local ListView_btns = self:getChildByName("mainPanel/btnListView/ListView_btns")
        for key,val in pairs(self.btnModuleList) do
            if val == ModuleName.RankModule then
                ListView_btns:removeChild(ListView_btns:getChildByName("btnItem" .. key))
                break
            end
        end
    end
end

function ToolbarPanel:onShowOrHidePanels(status)
    for index=1, 3 do
        local funcPanel = self:getChildByName("funcPanel" .. index)
        funcPanel:setVisible(status)
    end
    self:getChildByName("mainPanel/queueBtnBg"):setVisible(status)
end

------

-- 增加活动接口
function ToolbarPanel:addBattleActivityImp(activityType, url, callback)
    local activityData = self._worlordImpData[activityType]
    if activityData then
        activityData.activityType = activityType
        activityData.url = url
        activityData.callback = callback
    else
        local newImp = {}
        newImp.activityType = activityType
        newImp.url = url
        newImp.callback = callback
        self._worlordImpData[activityType] = newImp
    end

end
-- 移除活动接口
function ToolbarPanel:delBattleActivityImp(activityType)
    if self._worlordImpData[activityType] then 
        self._worlordImpData[activityType] = nil
    end
end

-- 更新活动接口UI
function ToolbarPanel:updateBattleActivityImp()
    local index = 1

    for _, v in pairs(self._worlordImpData) do
        if index > 4 then
            break
        end  
        local worlordsImg = self._worlordsImg[index]            
        worlordsImg:setVisible(true)
        worlordsImg.activityType = v.activityType
        local img=worlordsImg:getChildByName("img")
        TextureManager:updateImageView(img, v.url)
        self:addTouchEventListener(worlordsImg, v.callback)

        index = index + 1
    end

    for i = index, 4 do -- 没有的就隐藏
        local worlordsImg = self._worlordsImg[i]  
        worlordsImg:setVisible(false)   
    end 
    -- 红点添加
    self:updateWorlordImpRedPoint()
end

-- 红点添加
function ToolbarPanel:updateWorlordImpRedPoint()
    -- 皇位战红点SERVER_ACTION_REBELS -- SERVER_ACTION_EMPEROR_CITY
    local emperorActIcon = self:getWorlordImpByActivityType(ActivityDefine.SERVER_ACTION_EMPEROR_CITY, self._worlordImpData)
    local emperorCityCount = self._emperorCityProxy:getUnreadReportNum()
    self:setWorlordImpImgRedPoiont(emperorActIcon, emperorCityCount)
end

-- 
function ToolbarPanel:setWorlordImpImgRedPoiont(actIcon, count)
    if actIcon == nil then
        return 
    end

    local redPoint = actIcon:getChildByName("redPoint")
    local numTxt = redPoint:getChildByName("numTxt")
    if count == 0 or count == nil then
        redPoint:setVisible(false)
    else
        redPoint:setVisible(true)
        numTxt:setString(count)
    end
end


-- 根据activityType取worlordsImg节点, 没有返回空
function ToolbarPanel:getWorlordImpByActivityType(activityType, worlordImpData)
    local index = 1
    local worlordsImg = nil
    for _, v in pairs(worlordImpData) do
        if index > 4 then
            break
        end

        if v.activityType == activityType then
            worlordsImg = self._worlordsImg[index]
            break      
        end

        index = index + 1
    end
    return worlordsImg
end



-- 活动接口更新
function ToolbarPanel:onUpdateWarlordsStats()
   
    local rebelsProxy = self:getProxy(GameProxys.Rebels)
    local EAproxy = self:getProxy(GameProxys.ExamActivity)
    local proxy = self:getProxy(GameProxys.BattleActivity)
    local state = proxy:onGetWarlordsWorldState()
    local url 
    -- print("-------------------state")
    -- print(state)
    if state == 1 then --报名     
        self:addBattleActivityImp(ActivityDefine.SERVER_ACTION_LEGION_WAR, "images/team/signUp.png", function() 
            local proxy = self:getProxy(GameProxys.BattleActivity)
            proxy:onTriggerNet330000Req({activityId = 2})
        end)
    elseif state == 2 or state == 3 then
        self:addBattleActivityImp(ActivityDefine.SERVER_ACTION_LEGION_WAR, "images/team/battlefield.png", function() 
            local proxy = self:getProxy(GameProxys.BattleActivity)
            proxy:onTriggerNet330000Req({activityId = 2})
        end)
    else
        self:delBattleActivityImp(ActivityDefine.SERVER_ACTION_LEGION_WAR)
    end

    --乡试活动快捷入口
    local provActivity = proxy:getBattleActivityByType(ActivityDefine.SERVER_ACTION_PROVINCIAL_EXAM)
    if provActivity ~= nil and provActivity.state == 1 then
        self:addBattleActivityImp(ActivityDefine.SERVER_ACTION_PROVINCIAL_EXAM, proxy:getExamEntranceUrl(), function() 
            EAproxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.ProvincialExamModule})
        end)
    else
        self:delBattleActivityImp(ActivityDefine.SERVER_ACTION_PROVINCIAL_EXAM)
    end

    --殿试活动快捷入口
    local palaceActivity = proxy:getBattleActivityByType(ActivityDefine.SERVER_ACTION_PALACE_EXAM)
    if palaceActivity ~= nil and palaceActivity.state == 1 then
        self:addBattleActivityImp(ActivityDefine.SERVER_ACTION_PALACE_EXAM, proxy:getExamEntranceUrl(), function() 
            EAproxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.PalaceExamModule})
        end)
    else
        self:delBattleActivityImp(ActivityDefine.SERVER_ACTION_PALACE_EXAM)
    end

    --叛军活动快捷入口    
    local rebelsActivity = proxy:getBattleActivityByType(ActivityDefine.SERVER_ACTION_REBELS)
    if rebelsActivity ~= nil and rebelsActivity.state == 1 then
        self:addBattleActivityImp(ActivityDefine.SERVER_ACTION_REBELS, "images/team/dijunlaixi.png", function() 
            EAproxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.RebelsModule})
        end)
    else
        self:delBattleActivityImp(ActivityDefine.SERVER_ACTION_REBELS)
    end

    --讨伐物资活动 快捷入口
    local worldBoss = proxy:getBattleActivityByType(ActivityDefine.SERVER_ACTION_WORLD_BOSS)
    --print("-----------------------"..worldBoss.state)
    if worldBoss~= nil and worldBoss.state== 1 then
        self:addBattleActivityImp(ActivityDefine.SERVER_ACTION_WORLD_BOSS, "images/team/boss.png", function() 
      proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.WorldBossModule,extraMsg=worldBoss})
        end)
    else
        self:delBattleActivityImp(ActivityDefine.SERVER_ACTION_WORLD_BOSS)
    end

    --皇城战活动快捷入口    
    local cityActivity = proxy:getBattleActivityByType(ActivityDefine.SERVER_ACTION_EMPEROR_CITY)
    if cityActivity ~= nil and cityActivity.state == 1 then
        -- 皇城开启，把未读的报告数清零
        if self._emperorCityProxy:getUnreadReportNum() ~= 0 and self._initWarlordsStats == true then
            self._emperorCityProxy:setUnreadReportNum(0)
        end
        
        self:addBattleActivityImp(ActivityDefine.SERVER_ACTION_EMPEROR_CITY, "images/team/huangcheng.png", function() 
            EAproxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.EmperorCityModule})
        end)
    else
        self:delBattleActivityImp(ActivityDefine.SERVER_ACTION_EMPEROR_CITY)
    end

    if self._initWarlordsStats == nil then
        self._initWarlordsStats = true
    end

    
    --城主战活动 快捷入口
    local worldBoss = proxy:getBattleActivityByType(ActivityDefine.SERVER_ACTION_LORDCITY_BATTLE)
    --print("-----------------------"..worldBoss.state)
    if worldBoss~= nil and worldBoss.state== 1 then
        self:addBattleActivityImp(ActivityDefine.SERVER_ACTION_LORDCITY_BATTLE, "images/team/lordcity.png", 
            function() 
                -- 城主战校验等级解锁状态
                local rolePrxoy = self:getProxy(GameProxys.Role)
                if rolePrxoy:isFunctionUnLock(57,true) == false then
                    return
                end     
                proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.LordCityModule})
            end)
    else
        self:delBattleActivityImp(ActivityDefine.SERVER_ACTION_LORDCITY_BATTLE)
    end
    
    self:updateBattleActivityImp()
end

function ToolbarPanel:getldPositionY()
    return self._queueBtnBg:getPositionY()
end

function ToolbarPanel:onShowQueuePanel(sender)
if self.queueclick==false then
return
end
self.queueclick=false
local function canshowqueue()
    self.queueclick=true
end
self:getChildByName("mainPanel/queueBtnBg/queueBtn"):runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(canshowqueue)))

    self._queueBtnPos=cc.p(self._queueBtn:getPositionX(),self._queueBtn:getPositionY())
    self._queueBtnBg:setVisible(false)
    local panel = self:getPanel(QueuePanel.NAME)
    panel:show()

--    self:isShowToolBtn(tr)
    local funcPanel1 = self:getChildByName("funcPanel1")
    -- local movePanel1 = NodeUtils:selfMoveTo(funcPanel1)
    -- local wSize = cc.Director:getInstance():getWinSize()
    local movePanel1=cc.MoveBy:create(0.3,cc.p(300,0))
    funcPanel1:runAction(movePanel1)

    local redBagPanel = self:getChildByName("redBagPanel")
    local moveRedBagPanel = NodeUtils:selfMoveTo(redBagPanel)
    redBagPanel:runAction(moveRedBagPanel)


    local funcPanel4 = self:getChildByName("funcPanel4")
    local movePanel4 = NodeUtils:selfMoveTo(funcPanel4)
    funcPanel4:stopAllActions()
    funcPanel4:runAction(movePanel4)
    local upBtn = self:getChildByName("funcPanel3/upBtn")
    self:isShowleftBtn(true)
    
    if upBtn.isVisible then--如果正常
        self:onUpBtnTouch(upBtn)
        self._rightPanelState = true
    else
        self._rightPanelState = false
    end
end

function ToolbarPanel:onselfMovePanel()
    -- self._queueBtnPos=cc.p(self._queueBtn:getPositionX(),self._queueBtn:getPositionY())
    -- self._queueBtnBg:setVisible(false)
    -- local panel = self:getPanel(QueuePanel.NAME)
    -- panel:show()

--     self:isShowToolBtn(tr)
--     local funcPanel1 = self:getChildByName("funcPanel1")
--     local movePanel1 = NodeUtils:selfMoveTo(funcPanel1)
--     funcPanel1:runAction(movePanel1)

    local redBagPanel = self:getChildByName("redBagPanel")
    local moveRedBagPanel = NodeUtils:selfMoveTo(redBagPanel)
    redBagPanel:runAction(moveRedBagPanel)


    local funcPanel4 = self:getChildByName("funcPanel4")
    local movePanel4 = NodeUtils:selfMoveTo(funcPanel4)
    funcPanel4:stopAllActions()
    funcPanel4:runAction(movePanel4)
    local upBtn = self:getChildByName("funcPanel3/upBtn")
    self:isShowleftBtn(true)
    
    if upBtn.isVisible then--如果正常
        self:onUpBtnTouch(upBtn)
        self._rightPanelState = true
    else
        self._rightPanelState = false
    end
end
------
-- 存储数据
function ToolbarPanel:setMoveAction()
    self._posTable = {}
    local funcPanel1 = self:getChildByName("funcPanel1")
    local panel1PosX  = funcPanel1:getPositionX()
    local panel1PosY  = funcPanel1:getPositionY()
    local panel1Width = funcPanel1:getContentSize().width

    self._posTable.panel1PosX = panel1PosX
    self._posTable.panel1PosY = panel1PosY
    self._posTable.panel1Width= panel1Width

    local funcPanel4 = self:getChildByName("funcPanel4")
    local panel4PosX  = funcPanel4:getPositionX()
    local panel4PosY  = funcPanel4:getPositionY()
    local panel4Width = funcPanel4:getContentSize().width
    self._posTable.panel4PosX = panel4PosX
    self._posTable.panel4PosY = panel4PosY
    self._posTable.panel4Width= panel4Width


    local redBagPanel = self:getChildByName("redBagPanel")
    local redBagPanelPosX  = redBagPanel:getPositionX()
    local redBagPanelPosY  = redBagPanel:getPositionY()
    local redBagPanelWidth = redBagPanel:getContentSize().width
    self._posTable.redBagPanelPosX = redBagPanelPosX
    self._posTable.redBagPanelPosY = redBagPanelPosY
    self._posTable.redBagPanelWidth= redBagPanelWidth
end

------
-- 返回初始位置
function ToolbarPanel:backInitPos()
    local funcPanel1 = self:getChildByName("funcPanel1")
    local movePanel1 = cc.MoveTo:create(0.2, cc.p(self._posTable.panel1PosX, self._posTable.panel1PosY))
    funcPanel1:runAction(movePanel1)
    -- logger:info(self._posTable.panel1PosX.." "..self._posTable.panel1PosY)
    local funcPanel4 = self:getChildByName("funcPanel4")
    local movePanel4 = cc.MoveTo:create(0.2, cc.p(self._posTable.panel4PosX, self._posTable.panel4PosY))
    funcPanel4:runAction(movePanel4)

    local redBagPanel = self:getChildByName("redBagPanel")
    local moveRedBagPanel = cc.MoveTo:create(0.2, cc.p(self._posTable.redBagPanelPosX, self._posTable.redBagPanelPosY))
    redBagPanel:runAction(moveRedBagPanel)
--    if funcPanel1:getPositionX() ~= self._posTable.panel1PosX then
--        funcPanel1:setPosition(self._posTable.panel1PosX, self._posTable.panel1PosY)
--    end
end



function ToolbarPanel:showFlagQueueBtn()
    self._queueBtnBg:setVisible(true)
    self:backInitPos()
    local upBtn = self:getChildByName("funcPanel3/upBtn")
    if self._rightPanelState then
        self:onUpBtnTouch(upBtn)
    end
    self:isShowleftBtn(false)
end

-----
-- 设置队列红点
function ToolbarPanel:setQueueWorkCount()
    local redDot       = self._queueBtn:getChildByName("redDot")
    local workCountTxt = redDot:getChildByName("workCountTxt")

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local workCount = soldierProxy:getQueueWorkCount()
    if workCount == 0 then
        redDot:setVisible(false)
    else
        workCountTxt:setString(workCount)
        redDot:setVisible(true)
    end
end

-- 左边按钮
function ToolbarPanel:isShowleftBtn(state)
    local funcPanel6 = { }
    funcPanel6[1] = self:getChildByName("funcPanel2/btnItem6")
    funcPanel6[2] = self:getChildByName("funcPanel2/btnItem4")
    funcPanel6[3] = self:getChildByName("funcPanel2/btnItem7")
    funcPanel6[4] = self:getChildByName("funcPanel2/btnItem10")
    funcPanel6[5] = self:getChildByName("funcPanel2/btnItem11")
    funcPanel6[6] = self:getChildByName("funcPanel2/btnItem12")

    funcPanel6[4]:setVisible(false)
    funcPanel6[5]:setVisible(false)

    if state then
        for i = 1, 6 do
            funcPanel6[i]:stopAllActions()
            funcPanel6[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), NodeUtils:selfMoveTo(funcPanel6[i])))
        end
    else
        for i = 1, 6 do
            funcPanel6[i]:stopAllActions()
            funcPanel6[i]:runAction(cc.MoveTo:create(0.01, cc.p(-3, funcPanel6[i]:getPositionY())))
        end
    end
end
-----
-- 隐藏按钮和层
function ToolbarPanel:isShowToolBtn(state)
    local funcPanel1 = self:getChildByName("funcPanel1")
    local funcPanel3 = self:getChildByName("funcPanel3")
    -- local funcPanel2 = self:getChildByName("funcPanel2")
    local funcPanel4 = self:getChildByName("funcPanel4")
    local redBagPanel = self:getChildByName("redBagPanel")
    -- local funcPanel5 = self:getChildByName("mainPanel/mailTigBtn")
    -- local dot = funcPanel5:getChildByName("dot")
    -- local dotNum = dot:getChildByName("dotNum")
    -- local taskProTxt = self._taskTips:getChildByName("proTxt")
    -- local rickLabel = taskProTxt.rickLabel
    
--     for i=1,5 do
-- funcPanel6[i]:stopAllActions()
-- funcPanel6[i]:runAction(cc.MoveBy:create(0.2,cc.p(-100,0)))
--     end


    funcPanel1:stopAllActions()
    funcPanel3:stopAllActions()
    funcPanel4:stopAllActions()
    redBagPanel:stopAllActions()
    -- funcPanel5:stopAllActions()
    self._queueBtnBg:stopAllActions()
    for i = 1 , 4 do
        self._worlordsImg[i]:stopAllActions()
    end

    local function getHideAction()
        local action1 = cc.DelayTime:create(0.2)
        local action2 = cc.FadeTo:create (0.3, 0) 
        local action3 = cc.Sequence:create(action1, action2)
        return action3
    end
    local function getShowAction()
        local action1 = cc.DelayTime:create(0)
        local action2 = cc.FadeTo:create (0.3, 255) 
        local action3 = cc.Sequence:create(action1, action2)
        return action3
    end
    local function getDelayHide(node)
         local action1 = cc.DelayTime:create(0.1)
         local func1 = cc.CallFunc:create(
         function()
            node:setVisible(false)
         end)
         local action2 = cc.Sequence:create(action1,func1)
         node:runAction(action2)
    end 

    self:isShowleftBtn(state)

    if state then

        local function moveEnd()
            funcPanel1:setVisible(not state)
            funcPanel3:setVisible(not state)
            funcPanel4:setVisible(not state)
            redBagPanel:setVisible(not state)
            -- funcPanel5:setVisible(not state)
        end
    -- hide
        funcPanel1:runAction(getHideAction())
        funcPanel3:runAction(getHideAction())
        -- funcPanel2:runAction(getHideAction())
        redBagPanel:runAction(getHideAction())
        -- funcPanel5:runAction(getHideAction())

        self._queueBtnBg:runAction(getHideAction())
        for i = 1 , 4 do
            self._worlordsImg[i]:runAction(getHideAction())
        end
        -- funcPanel4 进行移动
        local action1 = cc.DelayTime:create(0.3)
        local movePanel4 = NodeUtils:selfMoveTo(funcPanel4)
        local action3 = cc.Sequence:create(action1, movePanel4, cc.CallFunc:create(moveEnd))
        funcPanel4:runAction(action3)

        
    else
    -- show
        funcPanel1:setVisible(true)
        funcPanel3:setVisible(true)
        funcPanel4:setVisible(true)
        redBagPanel:setVisible(true)

        -- if tonumber(dotNum:getString()) > 0 then
        --     funcPanel5:setVisible(true)
        -- else
        --     funcPanel5:setVisible(false)
        -- end

        funcPanel1:runAction(getShowAction())
        funcPanel3:runAction(getShowAction())
        redBagPanel:runAction(getShowAction())
        -- funcPanel5:runAction(getShowAction())
        self._queueBtnBg:runAction(getShowAction())
        for i = 1 , 4 do
            self._worlordsImg[i]:runAction(getShowAction())
        end
        -- funcPanel4 重置
        -- local movePanel4 = cc.MoveTo:create(0.3, cc.p(self._posTable.panel4PosX, self._posTable.panel4PosY))
        -- funcPanel4:runAction(movePanel4)
        -- funcPanel1:runAction(movePanel4)
        self:backInitPos()
        
    end
end
--[[
------
-- 繁荣度按钮信息设置
function ToolbarPanel:updateBoomInfo()
    local funcPanel = self:getChildByName("funcPanel4")
    local boomBtn = funcPanel:getChildByName("boomBtn")
    local curBoom   = boomBtn:getChildByName("curBoom")
    local maxBoom   = boomBtn:getChildByName("maxBoom")

    local boom = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boom) or 0             --繁荣值（cur）
    local boomUpLimit = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit) or 0--繁荣值（max）
    local boomLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boomLevel) or 0--繁荣等级

    local isDestroy,destroyBoom = self._roleProxy:getBoomState()


    -- 取繁荣倒计时(秒) 恢复到正常的时间
    local remainTime = self._roleProxy:getBoomRemainTime()

    if isDestroy == true then
        curBoom:setColor(ColorUtils.wordRedColor)
    else
        curBoom:setColor(ColorUtils.wordGreenColor)
    end
    curBoom:setString(boom)
    maxBoom:setString( string.format(self:getTextWord(312), boomUpLimit))

    NodeUtils:alignNodeL2R(curBoom, maxBoom)

    -- 底图长度根据文字长度动态变化
    local curSize = curBoom:getContentSize()
    local maxSize = maxBoom:getContentSize()
    local btnSize = boomBtn:getContentSize()
    local totalTxtWidth = curSize.width + maxSize.width
    local dx = totalTxtWidth + 60 + 10
    boomBtn:setContentSize(dx,btnSize.height)

    local data = {}
    data.boomLevel = boomLevel
    data.isDestroy = isDestroy
    data.remainTime = remainTime
    data.boom = boom
    data.boomUpLimit = boomUpLimit


    boomBtn.data = data
    NodeUtils:setEnable(boomBtn, true)
    self:addTouchEventListener(boomBtn, self.onBoomTipBtn)    
    self.boomBtn = boomBtn
    
    -- 扩大按钮点击范围
    self.boomBtnTouchPanel = boomBtn:getChildByName("touchPanel")
    self.boomBtnTouchPanel:setTouchEnabled(true)
    self.boomBtnTouchPanel.data = data
    self:addTouchEventListener(self.boomBtnTouchPanel,self.onBoomTipBtn)

end
]]
--[[
-- 繁荣度tip
function ToolbarPanel:onBoomTipBtn(sender, isUpdate)

--    local time = os.clock()

    -- body
    local BR = self:getTextWord(50059)

    local data = sender.data
    local boomlv = data.boomLevel

    local oldData = sender.oldData
    if isUpdate == true and oldData ~= nil then
        if oldData.boomLevel == boomlv and oldData.remainTime == data.remainTime 
            and oldData.isDestroy == data.isDestroy then
            return   --一样的数据，就不渲染了
        end
    end


    sender.oldData = {}
    sender.oldData.boomLevel = boomlv
    sender.oldData.remainTime = data.remainTime
    sender.oldData.isDestroy = data.isDestroy

    local info,lastData = ConfigDataManager:getInfoFindByOneKey2(ConfigData.BoomLevelConfig,"boomlv",boomlv)

    --繁荣0级 繁荣要求(0)
    local content1 = self:getTextWord(50042)
    local content101 = boomlv
    local content102 = self:getTextWord(50043)
    local content103 = info.numneed
    local content104 = self:getTextWord(50044)    

     --带兵量+000
    local content2 = self:getTextWord(50040)
    local content002 = string.format(self:getTextWord(50041),info.command)


    -- 下一等级
    local content21 = self:getTextWord(50038)
    local content22 = ""
    local content23 = ""
    local content24 = ""
    local content2202 = ""
    local content2301 = ""
    local content2401 = ""
    local content2401 = ""
    local content2403 = ""
    local content2404 = ""

    if boomlv < lastData.boomlv then
        local lv = boomlv + 1
        local info2 = ConfigDataManager:getInfoFindByOneKey(ConfigData.BoomLevelConfig,"boomlv",lv)

        --繁荣0级 繁荣要求(0)
        content24 = self:getTextWord(50042)
        content2401 = lv
        content2402 = self:getTextWord(50043)
        content2403 = info2.numneed
        content2404 = self:getTextWord(50044)

         --带兵量+000
        content22 = self:getTextWord(50040)
        content2202 = string.format(self:getTextWord(50041),info2.command)

        --编制经验+0%
        -- content23 = self:getTextWord(50045)
        -- content2301 = string.format(self:getTextWord(50046),math.floor(info2.estExpAddRate)) --编制经验+12%

    else
        content24 = self:getTextWord(50039)
    end

    -- 当前繁荣 00/00
    local content00 = self:getTextWord(50054)
    local content01 = data.boom
    local content02 = string.format(self:getTextWord(50055), data.boomUpLimit)
    
    local content03 = ""
    if data.remainTime > 0 then
        content03 = string.format(self:getTextWord(50056), TimeUtils:getStandardFormatTimeString8(data.remainTime)) -- + content03
    end

    local line0 = {{content = content00, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602}, 
        {content = content01, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603},
        {content = content02, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = content03, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604},
    }


    -- 当前等级
    local content13 = self:getTextWord(5002300)
    local line1 = {
        {content = content13, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602},
        {content = BR..content1, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = BR..content101, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603},
        {content = BR..content102, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = BR..content103, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603},
        {content = BR..content104, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601}
    }
    local line2 = {{content = content2, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},{content = content002, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}
    -- local line3 = {{content = content3, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},{content = content301, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}


    -- 下一级
    local line21 = {{content = content21, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602}, 
        {content = BR..content24, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = BR..content2401, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603},
        {content = BR..content2402, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = BR..content2403, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604},
        {content = BR..content2404, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601}
    }

    local line22 = {{content = content22, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},{content = content2202, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}
    -- local line23 = {{content = content23, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},{content = content2301, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}


    -- 先插入表中
    local lines = {}
    table.insert(lines, line0)
    table.insert(lines, line1)
    table.insert(lines, line2)
    -- table.insert(lines, line3)      
    table.insert(lines, line21)
    table.insert(lines, line22)
    -- table.insert(lines, line23)     


    -- 繁荣状态 正常/废墟
    local content3000 = self:getTextWord(50047)
    local content3001 = ""    
    if data.isDestroy == true then
        -- 废墟
        content3001 = self:getTextWord(50049)

        local content3002 = self:getTextWord(50050)    
        local content3003 = self:getTextWord(50051)    
        local content3004 = self:getTextWord(50052)    
        local content3005 = self:getTextWord(50053)    


        local line4 = {{content = content3000, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602}, {content = BR..content3001, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}
        local line5 = {{content = content3002, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}
        local line6 = {{content = content3003, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}
        local line7 = {{content = content3004, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}
        local line8 = {{content = content3005, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}

        table.insert(lines, line4)      
        table.insert(lines, line5)      
        table.insert(lines, line6)      
        table.insert(lines, line7)      
        table.insert(lines, line8)      

    else
        -- 正常
        content3001 = self:getTextWord(50048)        
        local line4 = {{content = content3000, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602}, {content = BR..content3001, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}
        table.insert(lines, line4)      
    end
  


    local parent = self:getParent()
    local uiTip = self._boomTip --parent:getChildByTag(9991)
    if uiTip == nil then
        uiTip = UITip.new(parent, nil, nil, true)
    end

    -- 最后 渲染
    uiTip:setAllTipLine(lines)
    
    uiTip.lines = lines
    self._boomTip = uiTip

--    print("~~~~~~_boomTip~~~~~~~~~~~", os.clock() - time)
end
]]
--[[
function ToolbarPanel:updateFanrong()
    -- body
    -- local roleProxy = self:getProxy(GameProxys.Role)
    local boom = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boom) or 0--繁荣值（cur）
    local boomUpLimit = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit) or 0--繁荣值（max）
    if boom < boomUpLimit then
        -- 繁荣未满
       local remainTime = self._roleProxy:getBoomRemainTime()
       -- print("···繁荣未满 remainTime", remainTime)
       self:updateRemainTimeView(remainTime)
    else
        -- 繁荣已满
       -- logger:info("···繁荣已满")
       self:updateRemainTimeView(0)
    end
end
]]
function ToolbarPanel:updateRemainTimeView(remainTime)
    local parent = self:getParent()
--    local uiTip = parent:getChildByTag(9991)
     
    if self._boomTip == nil then
        return
    end
    if self._boomTip:isVisible() == false then
        return
    end
--    if uiTip == nil then
--        return
--    end
    self.boomBtn.data.remainTime = remainTime
    -- self:onBoomTipBtn(self.boomBtn, true)
end

------
-- 保存背包按钮的坐标和类
function ToolbarPanel:setBtnItem5Pos()
    local posX = self["btnItem5"]:getWorldPosition().x
    local posY = self["btnItem5"]:getWorldPosition().y
    self._roleProxy:setBtnItem5Pos(posX, posY)
    self._roleProxy:setToolbarPanel(self)
end

------
-- 获取背包按钮的实时坐标
function ToolbarPanel:getBtnItem5Pos()
    local targetPos = self["btnItem5"]:getWorldPosition()
    return targetPos
end

function ToolbarPanel:onUpdateBtnPanel()
    local upBtn = self:getChildByName("funcPanel3/upBtn")
    if not upBtn.isVisible then
        upBtn.isVisible = false
        self:onUpBtnTouch(upBtn)
    end
end

function ToolbarPanel:setQueueBtn(isShow)
    self._queueBtnBg:setVisible(isShow)
end
-----------------------------------------------抢红包
function ToolbarPanel:setRedBagVisible()
    local btnArr = {}
    local redBagBtn1 = self:getChildByName("redBagPanel/redBagBtn1")
    table.insert(btnArr, redBagBtn1)
    local redBagBtn2 = self:getChildByName("redBagPanel/redBagBtn2")
    table.insert(btnArr, redBagBtn2)
    local redBagBtn3 = self:getChildByName("redBagPanel/redBagBtn3")
    table.insert(btnArr, redBagBtn3)
    -- redBagBtn1:setVisible(true)
    -- redBagBtn2:setVisible(true)
    -- redBagBtn3:setVisible(true)
    local proxy = self:getProxy(GameProxys.RedBag)
    local newRedBagInfos = proxy:getNewRedBagInfos()
    self.redBagData = {}

    for i=1,3 do
        -- btnArr[i]:setVisible(true)
        if newRedBagInfos[i] ~= nil and newRedBagInfos[i] ~= {} then
            self.redBagData[i] = newRedBagInfos[i]
            btnArr[i]:setVisible(true)
        else
            self.redBagData[i] = nil
            btnArr[i]:setVisible(false)
        end
    end
end
function ToolbarPanel:onTouchRedBagHandler(sender)
    -- print("onTouchRedBagHandler")
    if self.openRedBagEffect == nil then
        local proxy = self:getProxy(GameProxys.RedBag)
        local data = self.redBagData[sender.ftag] 
        self.openRedBagFtag = sender.ftag
        ----[[
        local name = "RedBag_CoolingTime" ..  data.id
        local coolTime = proxy:getRemainTime(name)
        if coolTime > 0 then
            self:showSysMessage(string.format(self:getTextWord(391000),coolTime))
        else
            local sendData = {}
            sendData.id = data.id
            proxy:onTriggerNet230027Req(sendData)
        end
    else
        self:removeRedBagOpenEffect()
    end
    
    --]]
end
--打开红包
function ToolbarPanel:openRedBag(data)

    self.canRemoveRedBagOpenEffect = false

    local redBagBtn = self:getChildByName("redBagPanel/redBagBtn" .. self.openRedBagFtag)
    local redBagPanel = self:getChildByName("redBagPanel")
    local x,y = redBagBtn:getPosition()
    local size = redBagBtn:getContentSize()

    local owner = {}
    owner["pause"] = function() 
        self.openRedBagEffectIcon = UIIcon.new(redBagPanel, data, true, self, nil,  true)
        self.openRedBagEffectIcon:setPosition(x + size.width*3,-size.height*4.7)

        self.canRemoveRedBagOpenEffect = true
        -- print("---------------pause")
    end
    owner["complete"] = function() 
        if self.openRedBagEffectIcon ~= nil then
            self.openRedBagEffectIcon:finalize()
            self.openRedBagEffectIcon = nil
        end
        if self.openRedBagEffect ~= nil then
            self.openRedBagEffect:finalize()
            self.openRedBagEffect = nil
        end
        if self.openRedBagEffect2 ~= nil then
            self.openRedBagEffect2:finalize()
            self.openRedBagEffect2 = nil
        end
        -- print("---------------complete")
    end
    --


    self.openRedBagEffect = self:createUICCBLayer("rgb-hongbao-dakai", redBagPanel, owner)
    self:addRedBagEffectTouch()

    self.openRedBagEffect:setPosition(x + size.width*3, - size.height*2)
    self.openRedBagEffect:setLocalZOrder(-2) 

    self.openRedBagEffect2 = self:createUICCBLayer("rgb-hongbao-dakaiwupin", redBagPanel)
    self.openRedBagEffect2:setPosition(x + size.width*3, - size.height*2)
    self.openRedBagEffect2:setLocalZOrder(-1) 
end

--打开后大红包特效上的触摸事件
function ToolbarPanel:addRedBagEffectTouch()
    local layer = self.openRedBagEffect:getLayer()

    local entDispatcher = layer:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()

    listener:setSwallowTouches(true)



    listener:registerScriptHandler(function(touch, event)    
        local location = touch:getLocation()   
        -- print("--------BEGAN-----------addTouch")
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN )

    listener:registerScriptHandler(function(touch, event)
        local location = touch:getLocation()
    end, cc.Handler.EVENT_TOUCH_MOVED )

    listener:registerScriptHandler(function(touch, event)
        local location = touch:getLocation()
        self:removeRedBagOpenEffect()
    end, cc.Handler.EVENT_TOUCH_ENDED ) 


    entDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end
function ToolbarPanel:removeRedBagOpenEffect()
    if self.canRemoveRedBagOpenEffect == true then
        if self.openRedBagEffect ~= nil then
            self.openRedBagEffect:finalize()
            self.openRedBagEffect = nil
        end
        if self.openRedBagEffectIcon ~= nil then
            self.openRedBagEffectIcon:finalize()
            self.openRedBagEffectIcon = nil
        end
        if self.openRedBagEffect2 ~= nil then
            self.openRedBagEffect2:finalize()
            self.openRedBagEffect2 = nil
        end
    end
end
-------------------------------------------
function ToolbarPanel:onClearCmd()
    local chatNum = self:getChildByName("mainPanel/chatPanel/infoImg/Image_66")
    chatNum:setVisible(false)
    local talkNameTxt = self:getChildByName("mainPanel/chatPanel/talkNameTxt")
    talkNameTxt:setString("")
    if self._chatItem ~= nil then
        self._chatItem:dispose()
        self._chatItem = nil
    end
end
--免费加速建筑按钮提示
function ToolbarPanel:buildFreeTip(isCanFreeBuild)
    self.isCanFreeBuild = isCanFreeBuild
    if isCanFreeBuild == false then

        if self.buildFreeTipSp ~= nil then
            self.buildFreeTipSp:stopAllActions()
            self.buildFreeTipSp:setVisible(false)
            self.buildFreeTipSp = nil
        end
    elseif isCanFreeBuild == true then
         --需要显示免费特效时隐藏倒计时和数量
        local buildingBtn = self:getChildByName("funcPanel1/queuePanel/buildingBtn")
        local stateRTxt = self:getChildByName("funcPanel1/queuePanel/buildingBtn/stateRTxt")
        local stateLineImg = self:getChildByName("funcPanel1/queuePanel/buildingBtn/stateLineImg")
        local stateLTxt = self:getChildByName("funcPanel1/queuePanel/buildingBtn/stateLTxt")
        if buildingBtn.stateTime ~= nil then
            local stateTime1 = buildingBtn:getChildByName("stateTime1")
            local stateTime2 = buildingBtn:getChildByName("stateTime2")
            local stateImg1 = buildingBtn:getChildByName("stateImg1")
            local stateImg2 = buildingBtn:getChildByName("stateImg2")
            stateTime1:setVisible(false)
            stateTime2:setVisible(false)
            stateImg1:setVisible(false)
            stateImg2:setVisible(false)
        end
        stateRTxt:setVisible(false)
        stateLineImg:setVisible(false)
        stateLTxt:setVisible(false)

        
        if self.buildFreeTipSp == nil then
            local buildFreeImg = self:getChildByName("funcPanel1/queuePanel/buildingBtn/buildFreeImg")
            local buildingBtn = self:getChildByName("funcPanel1/queuePanel/buildingBtn")
            buildingBtn.buildFreeImg = buildFreeImg
            self.buildFreeTipSp = buildFreeImg
            self.buildFreeTipSp:setVisible(true)
        
            self.buildFreeTipSp:stopAllActions()
            local action1 = cc.ScaleTo:create(0.5, 1.2)
            local action2 = cc.ScaleTo:create(0.5, 1)
            local action3 = cc.Sequence:create(action1,action2)
            local repeatAction = cc.RepeatForever:create(action3)
            self.buildFreeTipSp:runAction(repeatAction)
        end

    end
    
    
end
--热卖礼包
function ToolbarPanel:onGiftBagTouch(sender)
    --两万无数据
    -- local giftBagProxy = self:getProxy(GameProxys.GiftBag)
    -- local giftBagInfos = giftBagProxy:getGiftBagInfos()
    -- if #giftBagInfos == 0 then
    --     self:showSysMessage("两万下来根本没数据")
    --     return
    -- end
    local data = {}
    data.moduleName = ModuleName.GiftBagModule 
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT,data)
end
function ToolbarPanel:MovetoAndBackAction(index)
    local ac1=cc.MoveTo:create(0,self["ldBgbp"])--移动到指定位置
    local ac11=cc.FadeTo:create(0,0)--消失
    local ac2=cc.MoveTo:create(0.15, self["_acbtn"][index]["pos"])
    local ac3=cc.Spawn:create(ac2,cc.Sequence:create(cc.DelayTime:create(0.1) ,cc.FadeIn:create(0.3)))
return cc.Sequence:create(ac11,ac1,ac3)
end
function ToolbarPanel:BackActionAndMove(index)
    local ac3=cc.MoveTo:create(0,self["_acbtn"][index]["pos"])--回到原来的位置
    local ac4=cc.FadeIn:create(0)--出现
    local ac2=cc.MoveTo:create(0.15,self["ldBgbp"])
    local ac1=cc.Spawn:create(ac2,cc.FadeTo:create(0.08,0))
return cc.Sequence:create(ac1,ac3,ac4)
end

function ToolbarPanel:onldTouch(sender)
if self.EndableTouch==false then
    return
end
    self.EndableTouch=false
    local function canclick()
        self.EndableTouch=true
    end
    self:getChildByName("funcPanel1/ldBtnBg/ldBtn"):runAction( cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(canclick)))
    local queuePanel=self:getChildByName("funcPanel1/queuePanel")
    local ldBg=queuePanel:getChildByName("ldBg")
    self:posrefre()--记录坐标
    if self["queuePanelVis"] then
        for i=1,5 do
        local act=self:BackActionAndMove(i)
        self["_acbtn"][i]:stopAllActions()
        self["_acbtn"][i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.05*(i-1)),act,cc.CallFunc:create(function()
            self["_acbtn"][i]:setOpacity(0)
        end)))
        end

    local function lastCallback()
        queuePanel:setVisible(false)
        self["queuePanelVis"]=false        
    end
    local seqAction = cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(lastCallback))
    
    self._mainPanel:runAction(seqAction)

    self:backInitPos()
    local upBtn = self:getChildByName("funcPanel3/upBtn")
    if self._rightPanelState then
        self:onUpBtnTouch(upBtn)
    end
    self:isShowleftBtn(false)    
    self._queueBtn:stopAllActions()
    self._queueBtn:runAction(cc.MoveTo:create(0.3,self._queueBtnpos))
    else
        local kj=cc.FadeIn:create(0)
        local sx=cc.ScaleTo:create(0,0.1,0.1)
        local bd=cc.ScaleTo:create(0.2,1.5,1.5)
        local zsx=cc.ScaleTo:create(0.2,0.1,0.1)
        local xs=cc.FadeOut:create(0.2)
        local jt=cc.Spawn:create(zsx,xs)
        local action1=cc.Sequence:create(kj,sx,bd,jt)
        ldBg:stopAllActions()
        ldBg:runAction(action1)
        
        for i=1,5 do
        local act=self:MovetoAndBackAction(i,bp)
        self["_acbtn"][i]:stopAllActions()
        self["_acbtn"][i]:setOpacity(0)
        self["_acbtn"][i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.05*(i-1)),act))
        end

        self["queuePanelVis"]=true
        queuePanel:setVisible(true)
    self._queueBtn:stopAllActions()
    self._queueBtn:runAction(cc.MoveTo:create(0.3,cc.p(self._queueBtnpos.x+100,self._queueBtnpos.y)))
    self:onselfMovePanel()

    end
end


-- 有来袭队伍播放警告
function ToolbarPanel:playWarning()
    -- 判断之前清除上一个
    self:removeWarning()

    local state = false -- 控制只飘一个
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    if soldierProxy:hadBeingAttacked() then
        if self._warningImg == nil then 
            self._warningImg = self:playWarningAction(self, GlobalConfig.WarningTimes) -- #4964不一直播放
            state = true
        end
    else
        self:removeWarning()
    end

    -- 之前的没有警告
    if not state then 
        local quitAttackTimes = soldierProxy:getQuitAttackTimes()
        if quitAttackTimes ~= 0 and quitAttackTimes ~= nil then
            self:playWarningAction(self, GlobalConfig.WarningTimes + 2)
            soldierProxy:setQuitAttackTimes(0) -- 重置
        end
    end
end

-- 去除来袭警告
function ToolbarPanel:removeWarning()
    if self._warningImg ~= nil then
        self._warningImg:removeFromParent()
        self._warningImg = nil
    end
end

function ToolbarPanel:updateChatBarrage(data)
    for k,v in pairs(data) do
        if v.context ~= 2 then
            if v.name ~= "系统公告" then
            --TimerManager:addOnce(1000,self._barrage:updateDataChat(k,v),self) 
            self._barrage:updateDataChat(k,v)
            end
        end 
    end  
end


function ToolbarPanel:updateLevel()
    local dot = self:getChildByName("funcPanel2/btnItem12/dot")
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if dot == nil then
    return 
    end
    local norNeed = ConfigDataManager:getConfigById(ConfigData.NewFunctionOpenConfig,61).need
    if playerLevel >= norNeed then
        dot:setVisible(true)
     else
        dot:setVisible(false)
    end

    local num = dot:getChildByName("dotNum"):getString()
    if num == "0" then
    dot:setVisible(false)
    end
end


function ToolbarPanel:guideHide(data)                                           --全局事件  只要有操作 就隐藏掉引导特效
        --logger:info("按下")
        if self._xszy ~= nil then 
            self._xszy:setVisible(false)
        end

        if self._count == nil then 
           self._count = 1
        else
            self._count = self._count + 1
        end
end

function ToolbarPanel:guideShow(data)                                           -- 挂机事件  只要没有任何操作 延时5秒 显示
 --   if self._xszy ~= nil then
	--	self._xszy:setVisible(true)
	--end
    --print("计数 坚毅才对 "..self._count)
    TimerManager:addOnce(5000, function()
        if self._count >= 1 then
            self._count = self._count - 1
       --     print("当前计数 "..self._count)
        end
        if self.view._parent.module:getModule("GuideModule") ~= nil then 
            if self.view._parent.module:getModule("GuideModule"):isVisible() then
             return 
             end
        end
        if self._currOpenModule == "GuideModule" then
        return 
        end
        local roleProxy = self:getProxy(GameProxys.Role)
        local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        if playerLevel >=5 and playerLevel <= 20 then 
            if self._currOpenModule == "MainSceneModule" then
                if self._count <= 0 then
                self._xszy:setVisible(true)
                end
            end
        end
    end, self)
end