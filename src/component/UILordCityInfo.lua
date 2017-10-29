UILordCityInfo = class("UILordCityInfo")

UILordCityInfo.OPEN_SRC_MAP = 2
UILordCityInfo.OPEN_SRC_LORD_CITY = 1

--isMap  从map模块调用进来，要特殊处理
function UILordCityInfo:ctor(panel)
    self._uiSkin = UISkin.new("UILordCityInfo")
    self._uiSkin:setParent(panel)
    self._panel = panel   

    

    self:init()
    self:registerEvents()

end

function UILordCityInfo:finalize()
    if self._uiSharePanel ~= nil then
       self._uiSharePanel:finalize()
       self._uiSharePanel = nil 
    end

    --local chatProxy = self._panel:getProxy(GameProxys.Chat)
    -- chatProxy:removeEventListener(AppEvent.CLEAR_TOOLBAR_CMD, self, self.hide)
    self._uiSkin:finalize()
    self._uiSkin = nil
end




function UILordCityInfo:init()
    
	self._lordCityProxy = self._panel:getProxy(GameProxys.LordCity)

    local uiSkin = self._uiSkin 

    self._cityImg = uiSkin:getChildByName("mainPanel/cityImg")                        --城池图片
	self._holdCaptain = uiSkin:getChildByName("mainPanel/infoPanel/holdCaptain")		--城主团长名
	self._holdLegion = uiSkin:getChildByName("mainPanel/infoPanel/holdLegion")		--城主军团名
	self._childCaptain = uiSkin:getChildByName("mainPanel/infoPanel/childCaptain")	--附团团长名
	self._childLegion = uiSkin:getChildByName("mainPanel/infoPanel/childLegion")		--附团军团名
	self._psTxt = uiSkin:getChildByName("mainPanel/infoPanel/psTxt")					--城池加成
	self._buffTxt = uiSkin:getChildByName("mainPanel/infoPanel/buffTxt")				--城池加成buff
	self._timeTxt = uiSkin:getChildByName("mainPanel/infoPanel/timeTxt")				--下次时间

    self._voteBtn = uiSkin:getChildByName("mainPanel/voteBtn")				--投票
	self._setChildBtn = uiSkin:getChildByName("mainPanel/setChildBtn")		--设置附团
    self._battleBtn = uiSkin:getChildByName("mainPanel/battleBtn")          --进入战场
	self._warnTxt = uiSkin:getChildByName("mainPanel/infoPanel/warnTxt")			    --提示
    self._warnTxt:setString("")

    self._callbackVote = nil
    self._callbackChild = nil
    self._callbackBattle = nil
end

function UILordCityInfo:registerEvents()
	self._panel:addTouchEventListener(self._voteBtn, self.onVoteBtnTouch, nil, self)
	self._panel:addTouchEventListener(self._setChildBtn, self.onSetChildBtnTouch, nil, self)
	self._panel:addTouchEventListener(self._battleBtn, self.onBattleBtnTouch, nil, self)
end

-- 设置投票按钮回调
function UILordCityInfo:setBtnlVoteCallBack(callback)
    self._callbackVote = callback
end

-- 设置附团按钮回调
function UILordCityInfo:setBtnlChildCallBack(callback)
    self._callbackChild = callback
end

-- 设置进入战场按钮回调
function UILordCityInfo:setBtnlBattleCallBack(callback)
    self._callbackBattle = callback
end

function UILordCityInfo:onCityInfoUpdate()
    self._cityId = self._lordCityProxy:getSelectCityId()
    local cityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityBattleConfig,"ID",self._cityId)
    local urlCity = string.format("bg/map/iconCity%d.png",cityConfig.icon)
    local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
    -- local scale = self._lordCityProxy:getCityScaleById(self._cityId)
    TextureManager:updateImageViewFile(self._cityImg, urlCity)
    self._cityImg:setScale(cityConfig.iconScale/100)

	self:updateCityInfo(cityHost)
    self:updateCityDebuff()
end

function UILordCityInfo:updateCityInfo(data)
    if data == nil then
        return
    end
    -- //城主信息
    -- message CityHost{
    --     required int32  cityId=1;           //主城Id
    --     required string hostLegion=2;       //军团名字
    --     required string hostCommander=3;    //军团长名字
    --     required string viceLegion=4;       //附属军团名字
    --     required string viceCommander=5;    //附属军团长名字
    --     required int32  additionBuff=6;     //占领该城池后获得的加成
    --     required int32  prepareTime=7;      //下次争夺准备时间
    --     required int32  startTime=8;        //下次争夺开始时间
    --     required int64 bossMaxHp=9;         //BOSS最大血量
    --     required int64 bossNowHp=10;        //BOSS当前血量（0：BOSS死亡）
    --     required int64 wallMaxHp=11;        //城墙原始血量
    --     required int64 wallNowHp=12;        //城墙当前血量（0：城墙推倒）
    -- }

    self._holdCaptain:setString(data.hostCommander)
    self._holdLegion:setString(data.hostLegion)
    self._childCaptain:setString(data.viceCommander)
    self._childLegion:setString(data.viceLegion)
    self._psTxt:setString(self._panel:getTextWord(370021))

    local rewardConfig = ConfigDataManager:getConfigById(ConfigData.CityRewardConfig, self._cityId)
    local buffEffect = StringUtils:jsonDecode(rewardConfig.buffEffect)
    local buffConfig = ConfigDataManager:getConfigById(ConfigData.BuffShowConfig, buffEffect[1])
    local addBuff = buffConfig.info

    -- local fontSize = 18
    -- local color1 = "#e3dacf"
    -- local color2 = "#66ff00"
    -- local buffStr = {
    --     { { addBuff, fontSize, color1 } },
    --     { { self._panel:getTextWord(370022), fontSize, color1 } }
    -- }

    -- local richLabel = self._buffTxt.richLabel
    -- if richLabel == nil then
    --     richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
    --     self._buffTxt:addChild(richLabel)
    --     self._buffTxt.richLabel = richLabel
    -- end
    -- richLabel:setString(buffStr)
    self:updateBuffInfo()

    local prepareTime = rawget(data, "prepareTime")
    self:updateReadyRemainTime(prepareTime)

end

function UILordCityInfo:updateReadyTime()
    local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
    if cityHost == nil then
        return
    end

    local prepareTime = self._lordCityProxy:getBattleReadyRemainTime(self._cityId)
    self:updateReadyRemainTime(prepareTime)
end


function UILordCityInfo:updateReadyRemainTime(prepareTime)
    if self:isUnLock() == false then
        self:updateLockRemainTime()
        return
    end

    local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
    local cityState = cityHost.cityState
    local fontSize = 20
    local color1 = ColorUtils.commonColor.White
    local color2 = ColorUtils.commonColor.Green
    local timeStr
    if prepareTime == nil or cityState == 0 then   --未开启，显示开始时间
        local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
        local startTimeStr = TimeUtils:setTimestampToString4(cityHost.startTime)
        timeStr = {{{self._panel:getTextWord(370020),fontSize,color1},{startTimeStr,fontSize,color2},}}

    elseif prepareTime > 0 then  --已开启，显示准备时间
        local preTimeStr = TimeUtils:getStandardFormatTimeString9(prepareTime)
        timeStr = {{{self._panel:getTextWord(370019),fontSize,color1},{preTimeStr,fontSize,color2},},}
    else                         --争夺中，显示已开启
        timeStr = {{{self._panel:getTextWord(370056),fontSize,color1},{preTimeStr,fontSize,color2},},}
    end

    local richLabel = self._timeTxt.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        self._timeTxt:addChild(richLabel)
        self._timeTxt.richLabel = richLabel
    end
    richLabel:setString(timeStr)

end

function UILordCityInfo:updateLockRemainTime()
    local fontSize = 20
    local color2 = ColorUtils.commonColor.Gray
    local timeStr = {{{self._panel:getTextWord(370101),fontSize,color2}}}

    local richLabel = self._timeTxt.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        self._timeTxt:addChild(richLabel)
        self._timeTxt.richLabel = richLabel
    end
    richLabel:setString(timeStr)
end

--投票
function UILordCityInfo:onVoteBtnTouch(sender)
    if self:isUnLock() == false then
        self._panel:showSysMessage(self._panel:getTextWord(370101))
        return
    end

    local data = {cityId = self._cityId}
    self._lordCityProxy:onTriggerNet360017Req(data)
	--local panel = self._panel:getPanel(LordCityVotePanel.NAME)
	--panel:show()

    if self._callbackVote == nil then
        logger:error("===========>self._callbackVote is nil")
    else
        self._callbackVote()
    end

	self._panel:onClosePanelHandler()
end

--设置附团
function UILordCityInfo:onSetChildBtnTouch(sender)
    if self:isUnLock() == false then
        self._panel:showSysMessage(self._panel:getTextWord(370101))
        return
    end

    local isCanSet = self._lordCityProxy:getIsCanSetChildLegion(self._cityId)
    if isCanSet then
        self._lordCityProxy:setChildLegion(self._cityId)

        if self._callbackChild == nil then
            logger:error("===========>self._callbackChild is nil")
        else
            self._callbackChild()
        end    	
    else
        self._panel:showSysMessage(self._panel:getTextWord(370062))  --非归属城主不能设置
    end
end

-- 获取已占领城池的名字
function UILordCityInfo:getHoldCityNameMap()
    local roleProxy = self._panel:getProxy(GameProxys.Role)
    local myLegionName = roleProxy:getLegionName()
    local cityInfoMap = self._lordCityProxy:getCityInfoMap()
    local nameMap = {}
    for k,v in pairs(cityInfoMap) do
        if v.legionName == myLegionName then
            local cityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityBattleConfig, "ID", v.cityId)
            if cityConfig then
                table.insert(nameMap, cityConfig.name)
            end
        end
    end
    
    return nameMap
end

-- 显示削弱提示
function UILordCityInfo:updateCityDebuff()
    self._warnTxt:setString("")  --默认显示空字符串

    local cityInfo = self._lordCityProxy:getCityInfoById(self._cityId)
    local roleProxy = self._panel:getProxy(GameProxys.Role)
    local myLegionName = roleProxy:getLegionName()
    if cityInfo == nil or cityInfo.legionName == myLegionName then
        return
    end

    local cityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityBattleConfig,"ID",self._cityId)
    local isNeedSub,sameCount = self._lordCityProxy:isNeedSubCommand(cityConfig.level)

    if isNeedSub then
        local weaken = nil
        if sameCount == 1 then
            weaken = cityConfig.firstNerf
        elseif sameCount == 2 then
            weaken = cityConfig.secondNerf
        elseif sameCount == 3 then
            weaken = cityConfig.thirdNerf
        end

        -- local debuff
        if weaken then
            -- weaken = StringUtils:jsonDecode(weaken)
            -- local config = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, weaken[1][1])
            -- debuff = weaken[1][2] .. "%" .. config.name
            
            local nameMap = self:getHoldCityNameMap()
            local nameStr = ""
            for k,v in pairs(nameMap) do
                print(k,v)
                if k == table.size(nameMap) then
                    nameStr = nameStr .. v
                else
                    nameStr = nameStr .. v .. "、"
                end
            end

            -- local infoStr = string.format(TextWords[370100],"城池、地方、可见，","城市","30%血量")
            local infoStr = string.format(TextWords[370100], nameStr, cityConfig.name, weaken)
            self._warnTxt:setColor(ColorUtils.wordColorDark04)
            self._warnTxt:setString(infoStr)

        end

    end


end

-- 进入战场
function UILordCityInfo:onBattleBtnTouch(sender)
    if self:isUnLock() == false then
        self._panel:showSysMessage(self._panel:getTextWord(370101))
        return
    end

    local data = { cityId = self._cityId }
    self._lordCityProxy:onTriggerNet360042Req(data)

    if self._callbackBattle == nil then
        logger:error("===========>self._callbackBattle is nil")
    else
        self._callbackBattle()
    end

    self._panel:onClosePanelHandler()
end

function UILordCityInfo:update()
    self:updateReadyTime()
end

-- 城主战的城池弹窗面板，Buff信息显示读表
function UILordCityInfo:updateBuffInfo()
    local CityTip = ConfigDataManager:getConfigData(ConfigData.CityTipConfig)
    local infos = {}
    for k,v in pairs(CityTip) do
        if v.groupID == self._cityId then
            table.insert(infos,v)
        end
    end

    local lines = {}
    local fontSize = 18
    local color1 = ColorUtils.commonColor.White
    for k,v in pairs(infos) do
        local line = {{ v.panelTip, fontSize, color1 }}
        table.insert(lines,line)
    end


    local richLabel = self._buffTxt.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        self._buffTxt:addChild(richLabel)
        self._buffTxt.richLabel = richLabel
    end
    richLabel:setString(lines)
    self._buffTxt:setString("")

end

-- 当城主战未在常规活动列表时,显示未开启
function UILordCityInfo:isUnLock()
    local proxy = self._panel:getProxy(GameProxys.BattleActivity)
    local data = proxy:getActivityInfo()
    for k,v in pairs(data) do
        if v.activityType == ActivityDefine.SERVER_ACTION_LORDCITY_BATTLE then
            if v.state ~= 2 then
                return true
            end
        end
    end
    return false
end
