--[[
城主战：战场界面
]]
LordCityBattlePanel = class("LordCityBattlePanel", BasicPanel)
LordCityBattlePanel.NAME = "LordCityBattlePanel"

function LordCityBattlePanel:ctor(view, panelName)
    LordCityBattlePanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function LordCityBattlePanel:finalize()
    if self._effectBg then
        self._effectBg:finalize()
        self._effectBg = nil
    end
    if self._smokeEffect then
        self._smokeEffect:finalize()
        self._smokeEffect = nil
    end
    LordCityBattlePanel.super.finalize(self)
end

function LordCityBattlePanel:initPanel()
	LordCityBattlePanel.super.initPanel(self)
    
    self:setBgType(ModulePanelBgType.LORDCITY)

	self.allLen = 0
    self._effectBg = nil
    self._isNoEffect = false
    self._isPlayFireworksEffect = false

	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
	self._chatProxy = self:getProxy(GameProxys.Chat)
	self:initConfigData()

    local downPanel = self:getChildByName("downPanel")
    self._barrage = UIChatBarrage.new(self,downPanel)
    self._barrage:setHeight(44)
end

function LordCityBattlePanel:registerEvents()
	LordCityBattlePanel.super.registerEvents(self)

	self._topPanel = self:getChildByName("topPanel")
	self._middlePanel = self:getChildByName("middlePanel")
	self._downPanel = self:getChildByName("downPanel")
	
    self._smokeEffect = self:createUICCBLayer("rpg-zcz-yw", self._middlePanel)
    self._smokeEffect:setPosition(320,320)

	--战场显示的城池
	self._fightCityPanel = self:getChildByName("topPanel/fightCityPanel")  

	---- 背景图
	--self._bgImg = self:getChildByName("bgImg")
	--TextureManager:updateImageViewFile(self._bgImg,"bg/lordCity/bg.jpg")

	-- 聊天
	self._chatTxt = self:getChildByName("downPanel/chatTxt")
	self._chatDotBg = self:getChildByName("downPanel/chatBtn/dotBg")
	self._chatDotTxt = self:getChildByName("downPanel/chatBtn/dot")
	self:addTouchEventListener(self._downPanel, self.onChatBtnTouch)
	self._chatDotBg:setVisible(false)
	self._chatDotTxt:setVisible(false)

    --返回按钮
	self._backBtn = self:getChildByName("topPanel/backBtn")
	self._backBtn:setVisible(false)
	self:addTouchEventListener(self._backBtn, self.onClosePanelHandler)
	
	self:initStatePanel()
end

function LordCityBattlePanel:onClosePanelHandler()
	local panel = self:getPanel(LordCityMainPanel.NAME)
	panel:show()
	self:hide()
end

function LordCityBattlePanel:doLayout()
	local upWidget = self:getChildByName("topAdaptivePanel")
    --NodeUtils:adaptivePanelBg(self._bgImg, 0, upWidget)
    --NodeUtils:adaptiveUpPanel(self._bgImg, nil, GlobalConfig.topAdaptive)
    NodeUtils:adaptiveTopPanelAndListView(self._middlePanel, nil, GlobalConfig.downHeight, upWidget)
end

function LordCityBattlePanel:onAfterActionHandler()
    self._isNoEffect = true
	self:onShowHandler()
end

function LordCityBattlePanel:onShowHandler()
	if self:isModuleRunAction() == true then
		return
	end

	self:onShowPanelByType1()
	self._backBtn:setVisible(true)

	self:resumeAllCCB()

	self:updateChatInfos( {self._chatProxy:getLastChatInfo()} )  --聊天

end

-- 战场界面显示入口
function LordCityBattlePanel:onShowPanelByType1()
	self:updateFightTopPanel()
	self:updateFightCityPanel()
	self:updateStatePanel()
end

-------------------------------------------------------------------------------
-- 数据更新
-------------------------------------------------------------------------------
function LordCityBattlePanel:onCityInfoUpdate()
    self._isNoEffect = true
	self:onShowHandler()
end
function LordCityBattlePanel:onStateChangeUpdate(data)
	-- print("......... 城池占领状态变更显示")
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 战场界面
-------------------------------------------------------------------------------
-- 战场界面信息
function LordCityBattlePanel:updateFightTopPanel()
	self._topPanel:setVisible(true)

	if self._topBtnMap == nil then
		local ruleBtn = self._topPanel:getChildByName("ruleBtn")		--争夺规则
		local recordBtn = self._topPanel:getChildByName("recordBtn")	--战斗记录
		local buffBtn = self._topPanel:getChildByName("buffBtn")		--攻城鼓舞
		local rankBtn = self._topPanel:getChildByName("rankBtn")		--攻城排行
		
		self._topBtnMap = {ruleBtn,recordBtn,buffBtn,rankBtn}
		for _,btn in pairs(self._topBtnMap) do
			self:addTouchEventListener(btn, self.onTopBtnTouch)
		end
	end

	local cityName = self._topPanel:getChildByName("cityName")
	local curBlood = self._topPanel:getChildByName("curBlood")
	local maxBlood = self._topPanel:getChildByName("maxBlood")
	local bloodBar = self._topPanel:getChildByName("bloodBar")
	
	local selectCityId = self._lordCityProxy:getSelectCityId()
	local config = self._cityConfig[selectCityId]
	local cityHost = self._lordCityProxy:getCityHostById(selectCityId)
	
	local curHp = 0
	local maxHp = 0
	local name = config.name

	local cityConfig
	if cityHost.bossNowHp > 0 then  --boss HP
		cityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityBossConfig,"bossID",config.bossID)
		local monsterGroup = ConfigDataManager:getConfigById(ConfigData.MonsterGroupConfig,cityConfig.mongroup)
		curHp = cityHost.bossNowHp
		-- maxHp = cityConfig.bossHp
		maxHp = cityHost.bossMaxHp
		name = monsterGroup.name
	elseif cityHost.wallNowHp > 0 then  --城墙 HP
		cityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityWallConfig,"ID",config.wallID)
		local monsterGroup = ConfigDataManager:getConfigById(ConfigData.MonsterGroupConfig,cityConfig.mongroup)
		curHp = cityHost.wallNowHp
		maxHp = cityConfig.wallHp
		name = monsterGroup.name
	end

    local percent = curHp/maxHp*100
	cityName:setString(name)
	curBlood:setString(curHp)
	maxBlood:setString("/"..maxHp)
	bloodBar:setPercent(percent)
    bloodBar.percent = percent

	self:updateBattleRemainTime()
end


--显示 休战中/争夺准备时间/争夺剩余时间
function LordCityBattlePanel:updateBattleRemainTime()
	local remainTime = 0
	local strNO = 370059
	local stateNum = 0  --休战阶段=0,准备阶段=1,争夺阶段=2
	local selectCityId = self._lordCityProxy:getSelectCityId()

	local cityHost = self._lordCityProxy:getCityHostById(selectCityId)
	if cityHost.cityState == 0 then  --休战中
		strNO = 370067
		remainTime = self:getTextWord(strNO)
	else
		stateNum = 1
		remainTime = self._lordCityProxy:getBattleReadyRemainTime(selectCityId)  --剩余准备时间
		if remainTime <= 0 then
			stateNum = 2
			strNO = 370008
			remainTime = self._lordCityProxy:getBattleRemainTime(selectCityId)  --剩余争夺时间
		end
		remainTime = TimeUtils:getStandardFormatTimeString(remainTime)
		remainTime = string.format(self:getTextWord(strNO),remainTime)
	end

	self:updateTimePanel(remainTime)
	self:updateBattleStateImg(stateNum)      --争夺阶段有效
	self:updateBattleStateCCB(stateNum)   --争夺阶段有效
end

-- 显示：准备时间/剩余时间/休战中
function LordCityBattlePanel:updateTimePanel(remainTime)
	local timePanel,lessTime
	--local isVisible = self._statePanel:isVisible()
	--if isVisible == true then
	--	-- 攻防转换倒计时
	--	self:getChildByName("timePanel"):setVisible(false)
	--	timePanel = self._statePanel:getChildByName("timePanel")
	--else
	--	-- 非攻防转换倒计时
	--	self._statePanel:getChildByName("timePanel"):setVisible(false)
	--	timePanel = self:getChildByName("timePanel")
	--end
	timePanel = self:getChildByName("topPanel/timePanel")
	lessTime = timePanel:getChildByName("lessTime")
	lessTime:setString(remainTime)
	timePanel:setVisible(true)
end

-- 显示：准备时间/剩余时间/休战中(初始化隐藏)
function LordCityBattlePanel:initTimePanel()
	self:getChildByName("timePanel"):setVisible(false)
	self._statePanel:getChildByName("timePanel"):setVisible(false)
end

-- -------------------------------------------------------------------------------
-- -- 争夺规则弹窗
-- function LordCityBattlePanel:showRuleTips()
-- 	local parent = self:getParent()
--     local uiTip = UITip.new(parent)

--     local lines = {}
--     local text = nil
--     local tmp = nil
--     local fontSize,color = nil,nil
--     for i=1,23 do
--     	text = self:getTextWord(372000-1+i)
--     	tmp = string.sub(text,1,1)
--     	-- print("..... 截取字符串",tmp)

--     	if tmp == "\n" then
--  			-- print("...标题！！！",text)
--     		fontSize = ColorUtils.tipSize18
--     		color = ColorUtils.wordColorDark1602
--     	else
--     		fontSize = ColorUtils.tipSize16
--     		color = ColorUtils.wordColorDark1601
--     	end

--     	local line = {{content = text, foneSize = fontSize, color = color}}
-- 	    table.insert(lines, line)
--     end
--     uiTip:setAllTipLine(lines)

-- end
-- -------------------------------------------------------------------------------

-- 战场界面顶部按钮
function LordCityBattlePanel:onTopBtnTouch(sender)
	if sender == self._topBtnMap[1] then  --规则
		SDKManager:showWebHtmlView("html/help_cityFight.html")
		return
	elseif sender == self._topBtnMap[2] then  --记录
		local data = {}
		data.moduleName = ModuleName.LordCityRecordModule
		data.srcModule = ModuleName.LordCityModule   --关闭目标模块，重新打开当前模块
		data.srcExtraMsg = {panelName = "LordCityBattlePanel"}
		self:dispatchEvent(LordCityEvent.SHOW_OTHER_EVENT, data)
	
	elseif sender == self._topBtnMap[3] then  --鼓舞
		local selectCityId = self._lordCityProxy:getSelectCityId()
		local data = {}
		data.cityId = selectCityId
		self._lordCityProxy:onTriggerNet360041Req(data)
		local panel = self:getPanel(LordCityBuffPanel.NAME)
		panel:show()

	elseif sender == self._topBtnMap[4] then  --排行
		local data = {}
		data.moduleName = ModuleName.LordCityRankModule
		data.srcModule = ModuleName.LordCityModule   --关闭目标模块，重新打开当前模块
		data.srcExtraMsg = {panelName = "LordCityBattlePanel"}
		self:dispatchEvent(LordCityEvent.SHOW_OTHER_EVENT, data)
	end
end

-- 战场的城池信息
function LordCityBattlePanel:updateFightCityPanel()
	local selectCityId = self._lordCityProxy:getSelectCityId()
	local info = self._lordCityProxy:getCityInfoById(selectCityId)
	local cityPanel = self._fightCityPanel
	if cityPanel then
		self:updateFightCity(cityPanel,info)
		self:updateRewardBox(cityPanel,0)  --战场不显示宝箱
		self:createCCBKnife(cityPanel, info.cityState == 3)
		self:createCCBBing(cityPanel, info.cityState == 3)
	end

	self:createCCBSmokeM(self._middlePanel, false)
end

-- 渲染争夺界面 城池信息
function LordCityBattlePanel:updateFightCity(cityPanel,data)
	if cityPanel == nil or data == nil then
		return
	end
	local config = self._cityConfig[data.cityId]
	if config == nil then
		logger:error(".........城池配表信息 config is nil (ID=%d)......",data.cityId)
		return
	end

	cityPanel:setVisible(true)
	cityPanel:setBackGroundColorOpacity(0)

	local cityImg = cityPanel:getChildByName("cityImg")
	local cityName = cityPanel:getChildByName("cityName")
	local cityNum = cityPanel:getChildByName("cityNum")
	local rewardBtn = cityPanel:getChildByName("rewardBtn")  --宝箱奖励
	local stateTxt = cityPanel:getChildByName("stateTxt")  --显示未开启的提示

	cityImg:setVisible(true)

	local urlCity = string.format("bg/map/iconCity%d.png",config.icon)
	local urlName = string.format("images/lordCity/Txt_name%d.png",data.cityId)
	local urlNum = string.format("images/lordCity/Txt_num%d.png",data.cityId)
	TextureManager:updateImageViewFile(cityImg, urlCity)
	TextureManager:updateImageView(cityName, urlName)
	TextureManager:updateImageView(cityNum, urlNum)

	--local scale = self._lordCityProxy:getCityScaleById(data.cityId)
	cityImg:setScale(config.iconScale / 100)

	cityPanel.data = data
	cityPanel.config = config

	if cityPanel.isAddEvent == nil then
		cityPanel.isAddEvent = true
		self:addTouchEventListener(cityPanel, self.onCityBtnTouch)
	end

	rewardBtn.cityId = data.cityId
	cityPanel.rewardBtn = rewardBtn
	if rewardBtn.isAddEvent == nil then
		rewardBtn.isAddEvent = true
		self:addTouchEventListener(rewardBtn, self.onRewardBtnTouch)
	end
	
	-- 渲染宝箱
	self:updateRewardBox(cityPanel,data.rewardState)

	--开启状态的提示文字
	self:setStateTxt(stateTxt,data.cityState)
end

-- 播放活动开启特效
-------------------------------------------------------------------------------
function LordCityBattlePanel:checkWarningAction(data)
	-- 当血量变少的时候，播放一次全屏特效
	local isPlay = false
	if self._cloneBossNowHp == nil then
		self._cloneBossNowHp = data.bossNowHp
	end
	if self._cloneWallNowHp == nil then
		self._cloneWallNowHp = data.wallNowHp
	end

	if self._cloneBossNowHp > data.bossNowHp and self._cloneBossNowHp > 0 then
		logger:info("-- 播放扣血特效 boss血量减少 lasthp,nowhp = %d %d !",self._cloneBossNowHp , data.bossNowHp)
		isPlay = true
		self._cloneBossNowHp = data.bossNowHp
	elseif self._cloneWallNowHp > data.wallNowHp and self._cloneWallNowHp > 0 then
		logger:info("-- 播放扣血特效 城墙血量减少 lasthp,nowhp = %d %d !",self._cloneWallNowHp , data.wallNowHp)
		isPlay = true
		self._cloneWallNowHp = data.wallNowHp
	end

	if isPlay == true then
		logger:info("-- 播放扣血特效 ~~~~~~~~!!!!!")
		self:createCCBBlood()
	end
end

-- 防守方的有部队被击杀,防守方播放全屏动画
function LordCityBattlePanel:onDefTeamDie()
	logger:info("-- -- 防守部队被击杀,播放全屏动画 ~~~~~~~~!!!!! 11")
	
	local state = self._lordCityProxy:getCityState()
	if state == 2 then
		logger:info("-- -- 防守部队被击杀,播放全屏动画 ~~~~~~~~!!!!! 00")
		self:playWarningAction(self,3)  --全屏警告动画
	end
end

---@param ccbname ccbi名字
---@param parent  父容器
---@param owner   回调方法表
---@param completeFunc 完成回调方法,如果不为nil，则表示播放一次，辅助字段，默认为nil，
--                   如果为function，则该ccbi资源需要增加一个complete的callback,美术处理(处理方式，详见上面的注意)
--                   最终执行completeFunc回调，且默认会删除掉该实例资源
--@param isPlayOnce 是否播放一次，如果为true，则在complete回调的时候，同时删除掉资源
-- function BasicPanel:createUICCBLayer(ccbname, parent, owner, completeFunc, isPlayOnce)

-- 争夺胜利 烟花特效
function LordCityBattlePanel:createCCBWin(isShow)
	local panel = self._fightCityPanel
	if panel == nil or self._isPlayFireworksEffect == false then
		return
	end

	local win = self:createUICCBLayer("rgb-zcz-shengli", panel, nil, nil, true)
	win:setPosition(100,40)
	self:addCCBToMap(win)

end

--卷轴特效
function LordCityBattlePanel:createCCBJuanZhou(callback)
    local panel = self._middlePanel
	if panel == nil  or not self._isNoEffect then
		return
	end
    --self._isNoEffect = false

    local callback1 = function()
        if self._effectBg == nil then
	        self._effectBg = self:createUICCBLayer("rpg-zcz-slzh", panel:getChildByName("effectPanel"), nil, callback, true)
            self._effectBg:setLocalZOrder(9)
	        self:addCCBToMap(self._effectBg)
        --else
        --    self._effectBg:setVisible(true)
        end
        if callback then
            callback()
        end
    end
    --local bgPanel = panel:getChildByName("bgPanel")

    --if self._effectBg == nil then
	--    self._effectBg = self:createUICCBLayer("rpg-zcz-slzh", panel:getChildByName("effectPanel"), nil, nil, true)
    --    self._effectBg:setLocalZOrder(9)
	--    self:addCCBToMap(self._effectBg)
    --else
    --    self._effectBg:setVisible(true)
    --end
	local effect = self:createUICCBLayer("rpg-zcz-sl", panel:getChildByName("effectPanel"), nil, callback1, true)
    effect:setLocalZOrder(10)
	--effect:setPosition(100,40)
	self:addCCBToMap(effect)
end

-- 争夺中 血条特效
function LordCityBattlePanel:createCCBBlood()
	local bloodBar = self._topPanel:getChildByName("bloodBar")
	if bloodBar == nil then
		return
	end

    local percent = bloodBar.percent
    local w = bloodBar:getContentSize().width
    logger:error("==============================" .. percent .."---width----" .. w)

	local blood = self:createUICCBLayer("rgb-zcz-diaoxue", bloodBar, nil, nil, true)
	blood:setPosition(w * percent,20)
	self:addCCBToMap(blood)
end

-- 争夺中城池 匕首攻击特效
function LordCityBattlePanel:createCCBKnife(panel, isShow)
	if panel == nil then
		return
	end

	local knife = panel.knife
    if knife == nil then
    	if isShow == false then
    		return
    	end
        knife = self:createUICCBLayer("rgb-zcz-pishou", panel)
        knife:setPosition(120,160)
        panel.knife = knife
    	self:addCCBToMap(knife)
    end
    knife:setVisible(isShow)
end

-- 争夺中 兵攻击特效
function LordCityBattlePanel:createCCBBing(panel, isShow)
	if panel == nil then
		return
	end

    local bing = panel.bing
    if bing == nil then
    	if isShow == false then
    		return
    	end
        bing = self:createUICCBLayer("rgb-zcz-bing", panel)  
        bing:setPosition(100,80)
        panel.bing = bing
        self:addCCBToMap(bing)
    end
    bing:setVisible(isShow)
end

-- 主界面城池 烟雾特效
function LordCityBattlePanel:createCCBSmokeM(panel, isShow)
	if panel == nil then
		return
	end

	local smokeM = panel.smokeM
    if smokeM == nil then
    	if isShow == false then
    		return
    	end
        smokeM = self:createUICCBLayer("rpg-zcz-yw", panel)
        smokeM:setPosition(320,320)
        panel.smokeM = smokeM
        self:addCCBToMap(smokeM)
    end
    smokeM:setVisible(isShow)
end

-- 攻守方的状态特效
function LordCityBattlePanel:createCCBFightState(panel, isShow, string)
	if panel == nil then
		return
	end
    	-- logger:info(" 状态特效的文字 00 %s",string)

	local fightState = panel.fightState
    if fightState == nil then
    	if isShow == false then
    		return
    	end
    	-- logger:info(" 状态特效的文字 11 %s",string)
		local owner = {}
        fightState = self:createUICCBLayer("rgb-zcz-zhiying", panel, owner)
        fightState:setPosition(100,100)
        panel.fightState = fightState
        self:addCCBToMap(fightState)

	    local guideTxt = tolua.cast(owner["nameTxt"], "cc.Label")
	    fightState.guideTxt = guideTxt
    end

    if fightState.guideTxt then
    	-- logger:info(" 状态特效的文字 22 %s",string)
    	fightState.guideTxt:setString(string)
    end

    -- logger:info(" 状态特效的文字 33 %s",string)

    fightState:setVisible(isShow)
end

-- 根据显示类型，恢复特效
function LordCityBattlePanel:resumeAllCCB()
	local ccbiMap = self._ccbiMap
	if ccbiMap == nil then
		-- logger:info("= -- 根据显示类型，无法恢复特效~~~！！！ %d=",key)
		return
	end
    for k, v in pairs(ccbiMap) do
        if v:isFinalize() == true then 
            ccbiMap[k] = nil
        else
            -- logger:info("= -- 根据显示类型，恢复特效 =")
            v:resume()
        end
    end
end


function LordCityBattlePanel:addCCBToMap(ccb)
	if self._ccbiMap == nil then
		self._ccbiMap = {}
	end
	table.insert(self._ccbiMap,ccb)
end

-------------------------------------------------------------------------------

function LordCityBattlePanel:updateRewardBox(panel,state)
	local rewardBtn = panel.rewardBtn
	if rewardBtn then
		if state ~= 0 then
			local normalUrl = "images/lordCity/boxClose.png"
			if state == 2 then
				normalUrl = "images/lordCity/boxOpen.png"
			end
			TextureManager:updateButtonNormal(rewardBtn, normalUrl)
			rewardBtn:setVisible(true)
		else
			rewardBtn:setVisible(false)
		end
	end
end

function LordCityBattlePanel:setStateTxt(stateTxt,cityState)
	if stateTxt == nil or cityState == nil then
		return
	end
	-- print("...--开启状态",cityState)	

	--开启状态的提示文字
	local stateStr = ""
	local stateColor
	if cityState == 2 then  --准备阶段
		stateStr = self:getTextWord(370080)
		--stateColor = "#10e6ff"
        stateColor = cc.c3b(16,230,255)
	elseif cityState == 3 then  --争夺阶段
		stateStr = self:getTextWord(370081)
		--stateColor = "#ff8b3d"
        stateColor = cc.c3b(255,139,61)
	else  --未开启
		stateStr = self:getTextWord(370082)
		--stateColor = "#b6b6b6"
        stateColor = cc.c3b(182,182,182)
	end
	stateTxt:setString(stateStr)
	stateTxt:setColor(stateColor)
end

function LordCityBattlePanel:initConfigData()
	self._cityConfig = ConfigDataManager:getConfigDataBySortId(ConfigData.CityBattleConfig)
end

-------------------------------------------------------------------------------
-- 争夺状态弹窗界面
-------------------------------------------------------------------------------
-- 初始化
function LordCityBattlePanel:initStatePanel()
	self._statePanel = self:getChildByName("statePanel")
	self._middlePanel = self:getChildByName("middlePanel")
	self._stateBgImg = self._statePanel:getChildByName("bgPanel")
	self._stateTimeTxt = self._stateBgImg:getChildByName("timeTxt") --攻防倒计时xxx
	self._stateInfoTxt = self._middlePanel:getChildByName("infoTxt") --文本信息：攻防转换xxx
	self._stateCatchImg = self._stateBgImg:getChildByName("catchImg") --成功占领img格式
	self._stateCityImg = self._stateBgImg:getChildByName("cityImg") --城池名字img格式
	
	--self._infoTxt = self:getChildByName("infoTxt") --文本信息：提示设置防守xxx
	self._stateImg = self:getChildByName("stateImg") --图片信息：提示正在进攻OR正在防守OR观战中
	--self._infoTxt:setLocalZOrder(9)  --因为挡住ccb特效，调低点
	self._stateImg:setLocalZOrder(9)  --因为挡住ccb特效，调低点
	self._stateImg:setVisible(false)

	self._stateCatchImg:setVisible(false)
	self._stateCityImg:setVisible(false)

	self:isShowStatePanel(false,false)
	self._statePanel:setTouchEnabled(false)
	-- self._stateBgImg:setTouchEnabled(true)
	-- self:addTouchEventListener(self._stateBgImg, self.onStatePanelTouch)
	--self:initTimePanel()
end

-- 显示状态图片
function LordCityBattlePanel:updateBattleStateImg(stateNum)
	if stateNum == 0 then
		logger:info("状态图片 不显示 休战中")
		self._stateImg:setVisible(false)
		return
	end
    
    self._isPlayFireworksEffect = true
	--[[
	type:
		1>>  xx占领XX
		2>>  xx占领XX 倒计时 xx
		3>>  xx被抢夺，即将切换到进攻方 倒计时 xx
		4>>  恭喜XX获得XX归属权
		5>>  xx未被占领
		6>>  提示设置防守阵型
		7>>  占领成功，提示设置防守阵型 倒计时 xx
		-- 8>>  准备战斗  （准备阶段显示）
	]]

	local cityId = self._lordCityProxy:getSelectCityId()
	local stateType = self._stateType
	local urlNO = nil

	local playerInfo = self._lordCityProxy:getPlayerInfo(cityId)
	if playerInfo and playerInfo.participate == 0 then
		urlNO = 3  --观战中
	elseif stateType == 1 or stateType == 5 then
		urlNO = 1  --正在进攻中
	elseif stateType == 0 or stateType == 6 then
		urlNO = 2  --正在防守中
	end

	if stateNum == 1 then  --准备阶段：只显示2个状态(观战中、准备战斗)
		if urlNO == 1 or urlNO == 2 then
			urlNO = 4  --准备战斗
		end
		if urlNO == nil then
			logger:info(" 准备阶段 居然不显示图")
			self._stateImg:setVisible(false)
			return
		end
	end


	if urlNO then
		local url = "images/newOriginal/Img_state_%s.png"
		url = string.format(url,urlNO)
		logger:info("状态图片 显示 %s",url)
		TextureManager:updateImageView(self._stateImg,url)
		self._stateImg:setVisible(true)
		return
	else
		logger:info("状态图片 不显示")
		self._stateImg:setVisible(false)
	end
end

-- 显示状态特效
function LordCityBattlePanel:updateBattleStateCCB(stateNum)
	if stateNum == 0 then
		logger:info("状态特效 不显示 休战中")
		self._stateImg:setVisible(false)
		-- logger:info("-- 隐藏状态特效 ~~")
		self:createCCBFightState(self._fightCityPanel, false, "")
		return
	end

	--[[
	type:
		1>>  xx占领XX
		2>>  xx占领XX 倒计时 xx
		3>>  xx被抢夺，即将切换到进攻方 倒计时 xx
		4>>  恭喜XX获得XX归属权
		5>>  xx未被占领
		6>>  提示设置防守阵型
		7>>  占领成功，提示设置防守阵型 倒计时 xx
	]]


	local cityId = self._lordCityProxy:getSelectCityId()
	local stateType = self._stateType
	local playerInfo = self._lordCityProxy:getPlayerInfo(cityId)

	if playerInfo and playerInfo.participate == 0 then
		--观战中，不显示特效
	elseif stateType == 1 or stateType == 5 then
		--正在进攻中，判定有没CD
		local restTime = self._lordCityProxy:getRestAttRemainTime(cityId)
		if restTime <= 0 and stateNum == 2 then
			self:createCCBFightState(self._fightCityPanel, true, self:getTextWord(370095))
			return
		end
	elseif stateType == 0 or stateType == 6 then
		--正在防守中，判定有没防守部队
		local isHaveTeam = self._lordCityProxy:getIsHaveTeam()
		if isHaveTeam == false then
			self:createCCBFightState(self._fightCityPanel, true, self:getTextWord(370096))
			return
		end
	end

	-- 隐藏特效
	-- logger:info("-- 隐藏状态特效 ~~")
	self:createCCBFightState(self._fightCityPanel, false, "")

end

-- 点击弹窗
function LordCityBattlePanel:onStatePanelTouch(sender)
	-- 有倒计时，不隐藏弹窗
	local cityId = self._lordCityProxy:getSelectCityId()
	local type = self._stateType
	local time = self:getStateRemainTime(cityId,type)
	if time == 0 then
		self:isShowStatePanel(false,false)
	end
end

-- 可见性
function LordCityBattlePanel:isShowStatePanel(isShowPanel,isShowTxt)
	if self._statePanel ~= nil then
		self._statePanel:setVisible(isShowPanel)
	end
	--if self._infoTxt ~= nil and isShowTxt ~= nil then
	--	self._infoTxt:setVisible(isShowTxt)
	--end
end

-- 显示状态文字
function LordCityBattlePanel:updateStatePanel()
	--[[
	type:
		1>>  xx占领XX
		2>>  xx占领XX 倒计时 xx
		3>>  xx被抢夺，即将切换到进攻方 倒计时 xx
		4>>  恭喜XX获得XX归属权
		5>>  xx未被占领
		6>>  提示设置防守阵型
		7>>  占领成功，提示设置防守阵型 倒计时 xx
		-- 8>>  准备战斗 （准备阶段显示）
	]]


	local roleProxy = self:getProxy(GameProxys.Role)
	local selfLegionName = roleProxy:getLegionName()
	local cityId = self._lordCityProxy:getSelectCityId()
	local cityHost = self._lordCityProxy:getCityHostById(cityId)
	local remainTime = self._lordCityProxy:getChangeRemainTime(cityId)  --攻防CD
	-- local readyTime = self._lordCityProxy:getBattleReadyRemainTime(cityId)  --剩余准备时间

	-- 当血量变少的时候，播放一次全屏特效
	self:checkWarningAction(cityHost)
    
	self._stateType = 0  --默认值
	if cityHost.hostLegion == "" or cityHost.bossNowHp > 0 then --有boss，未被占领
		self._stateType = 5
		remainTime = 0
	elseif cityHost.wallNowHp > 0 then --有城墙
		if selfLegionName == cityHost.hostLegion then  --己方军团，提示设置防守阵型
			local isHaveTeam = self._lordCityProxy:getIsHaveTeam()
			if cityHost.cityState == 0 then
				self._stateType = 4  --休战中
			elseif isHaveTeam == true then
				self._stateType = 0  --已设防,本来是0,应该加个8类型
			else
				self._stateType = 6  --未设防
			end
			if remainTime > 0 then
				self._stateType = 7
			end
		else --非己方军团，提示对方占领
			self._stateType = 1
			if remainTime > 0 then
				self._stateType = 3
			end
		end
	end

	logger:info("....... 战场显示状态 %d",self._stateType)

	self._lordCityProxy:setCityState(cityId,self._stateType)  --缓存城池争夺状态

	local config = self._cityConfig[cityId]
	local info = {}
	info.type = self._stateType
	info.legionName = cityHost.hostLegion or ""
	info.cityName = config.name or ""
	info.cityId = cityId

	if remainTime > 0 then
		info.isShowTime = true
	else
		info.isShowTime = false
	end

	if self._stateType ~= 0 then
		self:updateStatePanelByType(info)
		self:isShowStatePanel(info.isShowTime, not info.isShowTime)
	else
		self:isShowStatePanel(false, false)
	end
end

function LordCityBattlePanel:getStateRemainTime(cityId, type)
	local remainTime = self._lordCityProxy:getChangeRemainTime(cityId)
	return remainTime
end

-- 定时器刷新回调 攻防转换倒计时
function LordCityBattlePanel:flushStateTime()
	local cityId = self._lordCityProxy:getSelectCityId()
	local type = self._stateType
	local time = self:getStateRemainTime(cityId,type)
	self:updateStateTime(time)
	
	-- self._stateBgImg:setTouchEnabled(time <= 0) --没倒计时，则可点击

	if time > 0 then
		self._isEndFlush = nil
	end
	if time == 0 and self._isEndFlush == nil then
		self._isEndFlush = true
		self:onCityInfoUpdate()  --攻防时间为0 刷一下界面显示
	end
end

function LordCityBattlePanel:updateStatePanelByType(data)
	self:updateStatePanelInfo(data)

	self._stateTimeTxt:setVisible(data.isShowTime)

	if data.isShowTime == true then
		self:flushStateTime()
	end


	if data.type == 4 then
		if self._statePanel ~= nil then
			local isVisible = self._statePanel:isVisible()
			if isVisible == false then
				self:createCCBWin()
			end
		end
	end
    
end

-- -- 争夺结束，占领方播胜利特效
-- function LordCityBattlePanel:playWinCCB()
-- 	local roleProxy = self:getProxy(GameProxys.Role)
-- 	local selfLegionName = roleProxy:getLegionName()
-- 	local cityId = self._lordCityProxy:getSelectCityId()
-- 	local cityHost = self._lordCityProxy:getCityHostById(cityId)
-- 	if cityHost.cityState == 0 and selfLegionName == cityHost.hostLegion then  --休战中,并且是我盟占领
-- 		self:createCCBWin()
-- 	end
-- end

-- 富文本显示内容
function LordCityBattlePanel:updateStatePanelInfo(info)
	local legionName = info.legionName
	local cityName = info.cityName
	local type = info.type

	local fontSize = 20
	local color0 = ColorUtils.commonColor.White
	local color1 = ColorUtils.commonColor.BiaoTi
	local color2 = ColorUtils.commonColor.Green

	self._stateCatchImg:setVisible(false)
	self._stateCityImg:setVisible(false)
    
    if self._effectBg then
        self._effectBg:finalize()
        self._effectBg = nil
    end
    
	local stateInfoTxt = self._stateInfoTxt
	--if info.isShowTime ~= true then
	--	stateInfoTxt = self._infoTxt
	--end
	stateInfoTxt:setString("")
	stateInfoTxt:setVisible(false)

	local infoStr
	if type == 1 then
		infoStr = {{{legionName,fontSize,color1},{self:getTextWord(370043),fontSize,color0},{cityName,fontSize,color2},},}
	elseif type == 2 then
		infoStr = {{{legionName,fontSize,color1},{self:getTextWord(370038),fontSize,color0},{cityName,fontSize,color2},},}
	elseif type == 3 then
		infoStr = {{{cityName,fontSize,color1},{self:getTextWord(370039),fontSize,color0},},}
	elseif type == 4 then
		infoStr = {{{self:getTextWord(370040),fontSize,color0},{legionName,fontSize,color1},{self:getTextWord(370041),fontSize,color0},{cityName,fontSize,color2},{self:getTextWord(370042),fontSize,color0},},}
	elseif type == 5 then
		infoStr = {{{cityName,fontSize,color1},{self:getTextWord(370044),fontSize,color0},},}
	elseif type == 6 then
		-- infoStr = {{{self:getTextWord(370010),fontSize,color2},},}
		infoStr = {{{"",fontSize,color2},},}
	elseif type == 7 then
		infoStr = {
			-- {{self:getTextWord(370012),fontSize,color0},{cityName,fontSize,color1},},
			{{self:getTextWord(370013),fontSize,color1},{self:getTextWord(370010),fontSize,color1},},
		}

		local url = "images/lordCity/Txt_name%d.png"
		url = string.format(url,info.cityId)
		TextureManager:updateImageView(self._stateCityImg, url)
		self._stateCatchImg:setVisible(true)
		self._stateCityImg:setVisible(true)
	end


	
	local richLabel = stateInfoTxt.richLabel
	if richLabel == nil then
	    richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
	    stateInfoTxt:addChild(richLabel)
	    stateInfoTxt.richLabel = richLabel
	end


    local callback = function()
	    stateInfoTxt:setVisible(true)
	    richLabel:setString(infoStr)
	    -- 居中显示
	    local size = richLabel:getContentSize()
	    local x = - size.width/2
	    richLabel:setPositionX(x)
    end

    --if type == 1 or type == 4 or type == 7 then
    --    self:createCCBJuanZhou(nil)
    --    self._stateInfoTxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(callback)))
    --    --callback()
    --else
    --    callback()
    --end
    if type ~= 6 then
        self:createCCBJuanZhou(nil)
        self._stateInfoTxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(callback)))
        --callback()
    else
        callback()
    end
    
	
end

-- 富文本显示攻防倒计时
function LordCityBattlePanel:updateStateTime(time)
	time = TimeUtils:getStandardFormatTimeString9(time)

	local fontSize = 20
	local color1 = ColorUtils.commonColor.Red
	local color2 = ColorUtils.commonColor.Green
	local timeStr = {
		{{self:getTextWord(370014),fontSize,color1},{time,fontSize,color2},},
	}

	self._stateTimeTxt:setString("")
	local richLabel = self._stateTimeTxt.richLabel
	if richLabel == nil then
	    richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
	    self._stateTimeTxt:addChild(richLabel)
	    self._stateTimeTxt.richLabel = richLabel
	end
	richLabel:setString(timeStr)

	-- 居中显示
	local size = richLabel:getContentSize()
	local x = - size.width/2
	richLabel:setPositionX(x)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 点击城池
function LordCityBattlePanel:onCityBtnTouch(sender)
	local cityId = sender.data.cityId
	if cityId == nil then
		logger:error("-- 点击城池 cityId = nil ")
		return
	end

	self._lordCityProxy:setSelectCityId(cityId)
	
	local data = {cityId = cityId}
	-- 战场 则弹窗攻防列表
	self._lordCityProxy:onTriggerNet360020Req(data)
	self._lordCityProxy:onTriggerNet360042Req(data)  --刷新玩家信息--TODO应该服务端推送才对

	local panel = self:getPanel(LordCityDefeatPanel.NAME)
	panel:show()
end

-- 点击宝箱领奖
function LordCityBattlePanel:onRewardBtnTouch(sender)
	local cityInfo = self._lordCityProxy:getCityInfoById(sender.cityId)
	if cityInfo.rewardState == 2 then
		self:showSysMessage(self:getTextWord(370084))  --当天已领取过
		return
	end
	local data = {cityId = sender.cityId}
	self._lordCityProxy:onTriggerNet360031Req(data)
end

-------------------------------------------------------------------------------
-- 聊天信息刷新
function LordCityBattlePanel:updateChatInfos(chats)    
    if self.allLen == 0 then
        self.allLen = table.size(chats)
    else
        self.allLen = self.allLen + table.size(chats)
    end
    if chats[table.size(chats)] then
        self:updateChatLineInfo(chats[table.size(chats)])
    end
end

function LordCityBattlePanel:updateChatLineInfo(chat)
    local chatProxy = self:getProxy(GameProxys.Chat)
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
 
    self._chatTxt:setVisible(false)
    self._chatTxt:setString("")

    local nameSize = self._chatTxt:getContentSize()
    local nameX = self._chatTxt:getPositionX()
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
            self._chatTxt:getParent():addChild(self._chatItem)
        else
            self._chatItem:setData(chatParams)
        end
        self._chatItem:setVisible(true)
        self._chatItem:setAnchorPoint(0, 0.5)
        self._chatItem:setPosition(self._chatTxt:getPosition())
    else
        if self._chatItem ~= nil then
            self._chatItem:setVisible(false)
        end
        self._chatTxt:setVisible(true)
        local text = RichTextMgr:getInstance():getNoticeParams(chat.context, true)
        local labelText = chat.name..":"..text
        local chatText = StringUtils:formatShortContent(labelText, 20)
        self._chatTxt:setColor(ColorUtils.wordGreenColor)
        self._chatTxt:setString(chatText)
    end
end

--更新聊天的小红点
function LordCityBattlePanel:renderChatNum(param)
    self._chatDotTxt:setVisible(false)  --聊天面板实时刷新，这里就不显示小红点了    
    self._chatDotBg:setVisible(false)  --聊天面板实时刷新，这里就不显示小红点了    
end

-- 点击聊天
function LordCityBattlePanel:onChatBtnTouch(sender)
    self.chatInfoNumber = 0
    self._chatDotTxt:setString("")

    local data = {}
    data.moduleName = ModuleName.ChatModule
    data.srcModule = ModuleName.LordCityModule   --关闭目标模块，重新打开当前模块
    data.srcExtraMsg = {panelName = "LordCityBattlePanel"}

    self:dispatchEvent(LordCityEvent.SHOW_OTHER_EVENT, data)
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function LordCityBattlePanel:update()
	self:updateBattleRemainTime()
	self:flushStateTime()
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function LordCityBattlePanel:onUpdateBarrage(data)
      for k,v in pairs(data) do
        if v.context ~= 2 then
            if v.name ~= "系统公告" then
            TimerManager:addOnce(1000,self._barrage:updateDataChat(k,v),self) 
            end
        end 
    end  
end