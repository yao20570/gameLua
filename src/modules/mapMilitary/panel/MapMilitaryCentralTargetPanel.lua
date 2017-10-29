-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MapMilitaryCentralTargetPanel = class("MapMilitaryCentralTargetPanel", BasicPanel)
MapMilitaryCentralTargetPanel.NAME = "MapMilitaryCentralTargetPanel"

local zhangjie = {
	[1] = "rgb-zymb-dyz",
	[2] = "rgb-zymb-dez",
	[3] = "rgb-zymb-dsz",
}
function MapMilitaryCentralTargetPanel:ctor(view, panelName)
    MapMilitaryCentralTargetPanel.super.ctor(self, view, panelName)
    self.isShowOpen = nil  --是否第一次打开界面（用于区分是打开界面还是更新界面）
    self.isChangeChapter = nil --是否进入下一章

    self.oldChapter = nil
    self.isInAction = nil

    self.listCCb = {}
    self:initCCBAction()
end

function MapMilitaryCentralTargetPanel:finalize()
	self.isShowOpen = nil
	self.isChangeChapter = nil
	self.oldChapter = nil
	self.isInAction = nil

	self:relaseCCBAction()
	self.listCCb = {}
    MapMilitaryCentralTargetPanel.super.finalize(self)
end

function MapMilitaryCentralTargetPanel:relaseCCBAction()
	if self.ccbHuoShao then
		self.ccbHuoShao:finalize()
		self.ccbHuoShao = nil
	end
	if self.ccbZhanKai then
		self.ccbZhanKai:finalize()
		self.ccbZhanKai = nil
	end
	if self.ccbZhangjie then
		self.ccbZhangjie:finalize()
		self.ccbZhangjie = nil 
	end

	for k,v in pairs(self.listCCb) do
		if v then
			v:finalize()
		end 
	end 
end

function MapMilitaryCentralTargetPanel:initCCBAction()
	self.ccbHuoShao = nil
	self.ccbZhanKai = nil
	self.ccbZhangjie = nil
end 

function MapMilitaryCentralTargetPanel:initPanel()
	MapMilitaryCentralTargetPanel.super.initPanel(self)

	self._panelMain = self:getChildByName("mainPanel")
	self._mapMilitaryproxy = self:getProxy(GameProxys.MapMilitary)
	self._roleProxy = self:getProxy(GameProxys.Role)

	self:setIsShowAndHideAction(false)
end

function MapMilitaryCentralTargetPanel:registerEvents()
	MapMilitaryCentralTargetPanel.super.registerEvents(self)
end

function MapMilitaryCentralTargetPanel:onShowHandler()
	self.isShowOpen = true
	self.isChangeChapter = false
	self:plainschapterUpdate()
	-- self:testAction()
end

function MapMilitaryCentralTargetPanel:onHideHandler()
end

function MapMilitaryCentralTargetPanel:renderTaget(item,data)
	local taskId = data.id
	local num = data.num
	local state = data.state

	local bg = item:getChildByName("bg")
	local configInfo = ConfigDataManager:getConfigById(ConfigData.CentralPlainsMissionConfig,taskId)
	local targetDes = bg:getChildByName("targetDes")
	targetDes:setString(configInfo.info)

	local function goToBtnOnTap()--点击前往
		print("goToBtnOnTap")
		--[[
		do 
	    	local openData = {}
	        openData.moduleName = ModuleName.TellTheWorldModule
	        openData.extraMsg = {eventId = 1,winnerInfo = nil,loserInfo = nil}
	        self._mapMilitaryproxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, openData)
	        return 
	    end
	    --]]
	    -- configInfo.jumpmodule = ModuleName.ChatModule
	    -- configInfo.reaches = "LegionChatPanel"
		if configInfo.jumpmodule then
			if configInfo.jumpmodule == ModuleName.WarlordsModule then --群雄逐鹿
				local id = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
				if id <= 0 then
					self._roleProxy:showSysMessage(TextWords:getTextWord(280139))
					return
				end
				local battle = self:getProxy(GameProxys.BattleActivity)
				battle:onTriggerNet330000Req({activityId = 2})
				return
			elseif jumpModule == ModuleName.WorldBossModule then --讨伐物资
				local battle = self:getProxy(GameProxys.BattleActivity)
                local battleInfo = battle:getActivityInfoByUitype(ActivityDefine.SERVER_ACTION_WORLD_BOSS)
                if battleInfo == nil then
                    self:showSysMessage(TextWords:getTextWord(249992))
                    return
                end
			elseif configInfo.jumpmodule == ModuleName.MapMilitaryModule then 
				if self._roleProxy:isFunctionUnLock(61, true) then
		            local moduleName = configInfo.jumpmodule
		       	 	local panelName = configInfo.reaches
		       	 	ModuleJumpManager:jump(moduleName, panelName)
		        	self:dispatchEvent(MapMilitaryEvent.HIDE_SELF_EVENT, {})
		        	return 
		        end
		    elseif configInfo.jumpmodule == ModuleName.LegionSceneModule then
		    	local legionId = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
		    	local moduleName,panelName
			    if legionId < 1 then
		            local isOpen = self._roleProxy:isFunctionUnLock(7)
		            if isOpen then
		                moduleName = ModuleName.LegionApplyModule
		                panelName = "LegionRecommendPanel"
		            end 
		        else
		            moduleName = ModuleName.LegionSceneModule
		            panelName = "LegionSceneHallPanel"
		        end
		        if panelName ~= nil and moduleName ~= nil then
		            ModuleJumpManager:jump(moduleName, panelName)
		            self:dispatchEvent(MapMilitaryEvent.HIDE_SELF_EVENT, {})
		        end
		        return
			end

			local moduleName = configInfo.jumpmodule
       	 	local panelName = configInfo.reaches    
        	ModuleJumpManager:jump(moduleName, panelName)

        	self:dispatchEvent(MapMilitaryEvent.HIDE_SELF_EVENT, {})
		else 
		end 
	end 
	local function downBtnOnTap()--点击领取
		print("getRewardBtnOnTap")
		local param = {}
		param.id = taskId
		self._mapMilitaryproxy:onTriggerNet580000Req(param)
	end

	local goToBtn = bg:getChildByName("goToBtn") --前往
	local downBtn = bg:getChildByName("downBtn") --领取
	self:addTouchEventListener(goToBtn,goToBtnOnTap)
	self:addTouchEventListener(downBtn,downBtnOnTap)

	local finishedNum,needFinishedNum = num,configInfo.finishcond2

	if configInfo.type == 68 or configInfo.type == 72 then
		needFinishedNum = 1
		finishedNum = 0
	end 

	local color = ColorUtils.wordRedColor
	if state == 0 then--未完成
		goToBtn:setVisible(true)
		downBtn:setVisible(false)
		color = ColorUtils.wordRedColor
	elseif state == 1 then --已完成
		goToBtn:setVisible(false)
		downBtn:setVisible(true)
		downBtn:setTitleText(TextWords:getTextWord(230205))
		NodeUtils:setEnable(downBtn,true)
		finishedNum = needFinishedNum
		color = ColorUtils.wordGreenColor
	elseif state == 2 then --已领取
		goToBtn:setVisible(false)
		downBtn:setVisible(true)
		downBtn:setTitleText(TextWords:getTextWord(1112))
		NodeUtils:setEnable(downBtn,false)

		finishedNum = needFinishedNum
		color = ColorUtils.wordGreenColor
	end

	local leftC = bg:getChildByName("leftC")
	leftC:setPositionX(targetDes:getPositionX() + targetDes:getContentSize().width + 10)
	local downTimes = bg:getChildByName("downTimes")
	downTimes:setString(finishedNum)
	downTimes:setColor(color)
	downTimes:setPositionX(leftC:getPositionX())
	local needTimes = bg:getChildByName("needTimes")
	needTimes:setString("/" .. needFinishedNum .. ")")
	needTimes:setPositionX(downTimes:getPositionX() + downTimes:getContentSize().width)
end

function MapMilitaryCentralTargetPanel:renderReward(item,data)
	local itemIcon = item:getChildByName("itemIcon")
	local itemInfo = {}
	itemInfo.power = data[1]
	itemInfo.typeid = data[2]
	itemInfo.num = data[3]
	if itemIcon.icon == nil then
        local icon = UIIcon.new(item,itemInfo,true,self)
       	itemIcon.icon = icon
    else
        itemIcon.icon:updateData(itemInfo)
    end
end

function MapMilitaryCentralTargetPanel:testAction()
	self:relaseCCBAction()
	local data = {
		id = 1,
		taskInfo = {{id = 1,num = 2,state = 1},{id = 2,num = 2,state = 3},{id = 3,num = 3,state = 2}},
	}
	self.isShowOpen = false
	self.isChangeChapter = true
	self:runCCBAction(data)
end

local function sortFunc(a,b)
	return a.sort < b.sort
end 

function MapMilitaryCentralTargetPanel:updateUI(data)
	if not data then
		return 
	end

	if self.isInAction then 
		return
	end
	self:relaseCCBAction()

	local chapterId = data.id
	local state = data.state

	--整理数据进行排序
	for k,v in pairs(data.taskInfo) do
		local configInfo = ConfigDataManager:getConfigById(ConfigData.CentralPlainsMissionConfig,v.id)
		v.sort = configInfo.sort
	end

	table.sort(data.taskInfo,sortFunc)

	local taskInfo = data.taskInfo
	print("self.oldChapter ,chapterId",self.oldChapter ,chapterId)
	if not self.oldChapter then
		self.oldChapter = chapterId
		self.isChangeChapter = false
	else
		if self.oldChapter == chapterId then 
			self.isChangeChapter = false
			self.oldChapter = chapterId
		else
			self.oldChapter = chapterId
			self.isChangeChapter = true
		end 
	end 

	local targetStage = self._panelMain:getChildByName("targetStage")
	local url = "images/mapMilitary/target_" .. chapterId ..".png"
	TextureManager:updateImageView(targetStage,url)

	--领取章节奖励
	local function getRewardBtnOnTap()
    	local data = {}
    	data.id = chapterId
    	self._mapMilitaryproxy:onTriggerNet580001Req(data)
    end

	local getRewardBtn = self._panelMain:getChildByName("getRewardBtn")
	self:addTouchEventListener(getRewardBtn,getRewardBtnOnTap)
	if state == 0 then --未完成
		getRewardBtn:setVisible(false)
	elseif state == 1 then --已完成
		getRewardBtn:setVisible(true)
	elseif state == 2 then --已领取
		getRewardBtn:setVisible(false)
	end

	--打开界面或者非进入新章节时 直接渲染list
	if self.isShowOpen or not self.isChangeChapter then--and false then 
		self.targetList = self._panelMain:getChildByName("targetList")
	    self:renderListView(self.targetList, taskInfo, self, self.renderTaget)
	end
    local configInfo = ConfigDataManager:getConfigById(ConfigData.CentralPlainsChapterConfig,chapterId)
    if not configInfo then
    	logger:error("请查看服务器下推数据 章节id:".. chapterId)
    end 
    local reward = StringUtils:jsonDecode(configInfo.award)

    self.rewardList = self._panelMain:getChildByName("rewardList")
    self:renderListView(self.rewardList, reward, self, self.renderReward)


    self:runCCBAction(data)

    self.isShowOpen = false
end

function MapMilitaryCentralTargetPanel:plainschapterUpdate()
	local data = self._mapMilitaryproxy:getPlainsChapterInfo()
	self:updateUI(data)
end

function MapMilitaryCentralTargetPanel:doListAction()
	local items = self.targetList:getItems()
    for i = 1, #items do
        local bg = items[i]:getChildByName("bg")
        local d1 = cc.DelayTime:create(0.1 * i)
        local a1 = cc.ScaleTo:create(0.1, 1, 0)
        local a2 = cc.ScaleTo:create(0.1, 1, 1)
        local seq = cc.Sequence:create(d1, a1, a2)
        bg:stopAllActions()
        bg:runAction(seq)
        if self.listCCb[i] then
        	self.listCCb[i]:finalize()
        	self.listCCb[i] = nil
        end 
        local ccb = UICCBLayer.new("rgb-zymb-fanzhuan",bg,nil, nil, true,nil,nil)
        ccb:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
        self.listCCb[i] = ccb
    end
end 

function MapMilitaryCentralTargetPanel:runCCBAction(data)
	--不是刚打开界面 并且 只有在进入新章节时才播放动画
	if (not self.isShowOpen and self.isChangeChapter) then -- or true then
		self.isInAction = true
	  	local scrollLeft = self._panelMain:getChildByName("scrollLeft")
		local scrollRight = self._panelMain:getChildByName("scrollRight")
		local targetStage = self._panelMain:getChildByName("targetStage")
		targetStage:setLocalZOrder(3)
		scrollLeft:setLocalZOrder(4)
		scrollRight:setLocalZOrder(4)
		scrollLeft:setVisible(false)
		scrollRight:setVisible(false)

		local function completeFunc()
			self.isInAction = false
			self:plainschapterUpdate()
		end

		local function pauseFunc()
			if not self.targetList then 
				self.targetList = self._panelMain:getChildByName("targetList")
			end 
		   	self:renderListView(self.targetList, data.taskInfo, self, self.renderTaget)

			self:doListAction()
		end 

		local function completeFuncHuoshao()
			print("completeFuncHuoshao")
			-- self:dispatchEvent(MapMilitaryEvent.SHOW_OTHER_EVENT,{name = ModuleName.DungeonModule,id = chapter,type = 1,info = info})
		end

		local function zhanKaiPause()
			print("zhanKaiPause")
			targetStage:setLocalZOrder(31)
			scrollLeft:setLocalZOrder(32)
			scrollRight:setLocalZOrder(32)
			scrollLeft:setVisible(true)
			scrollRight:setVisible(true)

			self.ccbZhangjie = UICCBLayer.new( zhangjie[data.id],self._panelMain,nil, completeFunc, true,nil,pauseFunc)
			self.ccbZhangjie:setPosition(targetStage:getPosition())
			self.ccbZhangjie:setLocalZOrder(35)
		end 

		local function zhanKaiEnd()
			print("zhanKaiEnd")

		end 

		local function pauseFuncHuoshao()
			self.ccbZhanKai = UICCBLayer.new( "rgb-zymb-zhankai",self._panelMain,nil, zhanKaiEnd, true,nil,zhanKaiPause)
			self.ccbZhanKai:setPosition(targetStage:getPosition())
			self.ccbZhanKai:setLocalZOrder(32)
		end
		self.ccbHuoShao = UICCBLayer.new( "rgb-zymb-huoshao",self._panelMain,nil, completeFuncHuoshao, true,nil,pauseFuncHuoshao)
		self.ccbHuoShao:setPosition(targetStage:getPosition())
		self.ccbHuoShao:setLocalZOrder(30)
	end
end 