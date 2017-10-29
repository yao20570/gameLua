-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-04-20 15:08:30
--  * @Description: 西域远征主界面
--  */
LimitExpPanel = class("LimitExpPanel", BasicPanel)
LimitExpPanel.NAME = "LimitExpPanel"

function LimitExpPanel:ctor(view, panelName)
    LimitExpPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function LimitExpPanel:finalize()
    LimitExpPanel.super.finalize(self)
end

function LimitExpPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function LimitExpPanel:initPanel()
	LimitExpPanel.super.initPanel(self)
	self:setTitle(true,"limitExp",true)
	self:setBgType(ModulePanelBgType.NONE)


	local mainPanel = self:getChildByName("mianPanel")
	local downPanel = self:getChildByName("downPanel")

	self._mainPanel = mainPanel
	self._downPanel = downPanel

	

	self:registerEvent()
end

function LimitExpPanel:doLayout()
	local bastTopPanel = self:topAdaptivePanel() 
	local ltpanel = self:getChildByName("ltpanel")
	local mainPanel = self:getChildByName("mianPanel")
	local downPanel = self:getChildByName("downPanel")

	NodeUtils:adaptiveUpPanel(ltpanel,bastTopPanel,20)
	NodeUtils:adaptiveUpPanel(mainPanel,ltpanel,0)
	NodeUtils:adaptiveDownPanel(downPanel,nil,GlobalConfig.downHeight)

	-- NodeUtils:adaptiveTopPanelAndListView(self._mainPanel, self._downPanel,GlobalConfig.downHeight,bastTopPanel)


end

function LimitExpPanel:registerEvent()
	-- local talkBtn = self._downPanel:getChildByName("talkBtn") 		--聊天
	local indexBtn = self:getChildByName("mianPanel/Panel_20/midpanel/indexBtn") 	--排行
	local rewBtn = self:getChildByName("mianPanel/Panel_20/midpanel/rewBtn") 		--奖励预览
	local againBtn = self:getChildByName("mianPanel/Panel_20/midpanel/againBtn") 	--回播
	local tipBtn = self:getChildByName("mianPanel/Panel_20/midpanel/tipBtn")--提示
	local setBackBtn = self._downPanel:getChildByName("setBackBtn") --重置
	local clearBtn = self._downPanel:getChildByName("clearBtn") 	--扫荡
	local fightBtn = self._downPanel:getChildByName("fightBtn") 	--挑战

	self._fightBtn = fightBtn
	self._setBackBtn = setBackBtn
	self._clearBtn = clearBtn
	



	self:addTouchEventListener(indexBtn,self.onIndexBtnHandle)
	self:addTouchEventListener(rewBtn,self.onRewBtnHandle)
	self:addTouchEventListener(againBtn,self.onAgainBtnHandle)
	self:addTouchEventListener(tipBtn,self.onTipBtnHandle)
	self:addTouchEventListener(setBackBtn,self.onSetBackBtnHandle)
	self:addTouchEventListener(clearBtn,self.onClearBtnHandle)
	self:addTouchEventListener(self._fightBtn,self.onFightHandle)
	-- self:addTouchEventListener(talkBtn,self.onChatHandle)




	-- local Image_redPonit = talkBtn:getChildByName("Image_redPonit")
	-- local dot = Image_redPonit:getChildByName("dot")
	-- self.Image_redPonit = Image_redPonit
	-- self.dot = dot

end

-- function LimitExpPanel:updateNoSeeChatNum( num )
-- 	-- body

-- 	if num > 0 then
-- 		self.Image_redPonit:setVisible(true)
-- 		self.dot:setString(num)
-- 	else
-- 		self.Image_redPonit:setVisible(false)
-- 	end	
-- end

function LimitExpPanel:onChatHandle(sender)
	-- print("聊天···LimitExpPanel:onChatHandle(sender)")
    -- self:updateNoSeeChatNum( 0 )
    self:dispatchEvent(LimitExpEvent.SHOW_OTHER_EVENT, ModuleName.ChatModule )
end

function LimitExpPanel:onFightHandle(sender)
	if self._data == nil then
		logger:error(" self._data == nil >> %s",debug.traceback())
		return
	end

	if self._data.ismop == 1 then
		self:showSysMessage(self:getTextWord(4002))
	else
		-- old panel
		-- local panel = self:getPanel(limitExpCityPanel.NAME)
		-- panel:show()
		-- panel:updateCityInfo(self._data,sender.config)


		-- new panel
		local sendData = {}
		sendData.data = self._data
		sendData._info = sender.config
        sendData.id = sender.config.ID
		local dungeonProxy = self:getProxy(GameProxys.Dungeon)
	    dungeonProxy:setCurrCityType(self._data.id)
	    dungeonProxy:setCurrType(4, 2) --西域远征，探险
		local panel = self:getPanel(limitExpCityPanel.NAME)
		panel:show(sendData)


	end
end

-- 扫荡按钮
function LimitExpPanel:onClearBtnHandle(sender)
	if self._data == nil then
		logger:error("扫荡按钮 self._data = nil ", debug.traceback())
		return
	end

	local talk = nil
	local callback

	if sender.type == 0 then
		-- 扫荡
		-- print("扫荡按钮 id = "..self._data.id..",maxId = "..self._data.maxId)
		local config = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",self._data.id)


		if self._data.maxId == 0 or self._data.id > self._data.maxId then
			-- 无关卡可扫荡
			self:showSysMessage(self:getTextWord(4009))
			return		
		else
			-- 有关卡可扫荡
			local maxConfig = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",self._data.maxId)
			if config.sort > maxConfig.sort then
				config.sort = maxConfig.sort
			end
			-- print("扫荡 从关卡 = "..config.sort.." 到关卡 = "..maxConfig.sort)
	
			talk = string.format(self:getTextWord(4004), config.sort, maxConfig.sort)
			callback = function ()
				self:dispatchEvent(LimitExpEvent.BEGIN_FIGHT_REQ)
			end
		end

	elseif sender.type == 1 then
		-- 停止扫荡
		-- print("···停止扫荡")
		talk = self:getTextWord(4003)
		callback = function ()
			self:dispatchEvent(LimitExpEvent.STOP_FIGHT_REQ)
		end
	end
	-- print("扫荡按钮···talk, sender.type", talk, sender.type)
	self:showMessageBox(talk,callback)
end


-- 方法说明 判断是否 "不可以扫荡"
-- @method isCanNotSaoDang
-- @param null
-- @return bool
function LimitExpPanel:isCanNotSaoDang()
	return self._data.maxId == 0 or self._data.id > self._data.maxId
end

-- 重置按钮
function LimitExpPanel:onSetBackBtnHandle(sender)

	self._roleProxy = self:getProxy(GameProxys.Role)
	if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy) < 5 then  --体力值
		-- 体力不足，不可以重置
	    self._roleProxy:getBuyEnergyBox(self)
	else
		-- 体力足，可以重置
	    local function okCallBack()
	    	self:dispatchEvent(LimitExpEvent.BACKFIGHT_REQ,{id = self._data.id})
		end
		self:showMessageBox(self:getTextWord(4005),okCallBack)
	end
end

-- 是否弹窗元宝不足
function LimitExpPanel:isShowRechargeUI(sender)
	-- body
	local needMoney = sender.money

	local roleProxy = self._roleProxy
	local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

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
		sender.callFunc()
	end

end

-- tip提示
function LimitExpPanel:onTipBtnHandle(sender)
	local content00 = self:getTextWord(40000)
	local content01 = self:getTextWord(40001)
	local content02 = self:getTextWord(40002)
	local content03 = self:getTextWord(40003)
	local content04 = self:getTextWord(40004)
	local content05 = self:getTextWord(40005)
	local content06 = self:getTextWord(40006)
	local content07 = self:getTextWord(40007)
	local content08 = self:getTextWord(40008)
	local content09 = self:getTextWord(40009)
	local content10 = self:getTextWord(40010)
	local content11 = self:getTextWord(40011)

	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local line00 = {{content = content00, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.FuBiaoTi}}
    local line01 = {{content = content01, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line02 = {{content = content02, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line03 = {{content = content03, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line04 = {{content = content04, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line05 = {{content = content05, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line06 = {{content = content06, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line07 = {{content = content07, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line08 = {{content = content08, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line09 = {{content = content09, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    local line10 = {{content = content10, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}

    local lines = {}
    table.insert(lines, line00)
    table.insert(lines, line01)
    table.insert(lines, line02)	    
    table.insert(lines, line03)	    
    table.insert(lines, line04)	    
    table.insert(lines, line05)	    
    table.insert(lines, line06)	    
    table.insert(lines, line07)	    
    table.insert(lines, line08)	    
    table.insert(lines, line09)	    
    table.insert(lines, line10)	    
    uiTip:setAllTipLine(lines)	
end


-- 回放按钮
function LimitExpPanel:onAgainBtnHandle(sender)
	local panel = self:getPanel(LimitExpReplayPanel.NAME)
	panel:show(self._data)
end

-- 奖励预览按钮
function LimitExpPanel:onRewBtnHandle(sender)
	local panel = self:getPanel(LimitExpRewardPanel.NAME)
	panel:show(self._data)
end

-- 排行榜按钮
function LimitExpPanel:onIndexBtnHandle(sender)
	local panel = self:getPanel(LimitExpRankPanel.NAME)
	panel:show(self._data)
end

function LimitExpPanel:onLimitInfosResp(data, flag)
	if data == nil then
		logger:error(" data == nil >> %s", debug.traceback())
		return
	end
	self._data = data
	self._flushFlag = flag
	self:onUpdateMainPanel()

	-- local chatProxy = self:getProxy(GameProxys.Chat)
	-- local num = chatProxy:getNotRenderWorldChatNum() + chatProxy:getNotRenderPrivateChatNum()
	-- self:updateNoSeeChatNum(num)
end

function LimitExpPanel:onUpdateMainPanel()
	local curTarget = self._mainPanel:getChildByName("curTarget")
	local curTitle = self._mainPanel:getChildByName("curTitle")
	-- local nextTarget = self._mainPanel:getChildByName("nextTarget")
	-- local arrowImg = self._mainPanel:getChildByName("arrowImg")
	local fightCount = self._fightBtn:getChildByName("fightCount")
	local backCount = self._setBackBtn:getChildByName("backCount")



	-- print("···line 292 onUpdateMainPanel id="..self._data.id)
	local config = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",self._data.id)

	if self._flushFlag ~= nil and self._flushFlag == 1 then
		self._flushFlag = nil
		self:showSysMessage(string.format(self:getTextWord(4099), config.sort))
	end

	-- 当前敌人
	curTitle:setString(string.format(self:getTextWord(4006), config.sort, config.name))
	self:updateButtonImg(curTarget, config)



	-- 下一个敌人
	-- local nextConfig = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",(self._data.id + 1))
	-- if nextConfig ~= nil then
		-- self:updateButtonImg(nextTarget, nextConfig)
		-- nextTarget:setScale(0.8)
		-- nextTarget:setVisible(true)
		-- arrowImg:setVisible(true)
	-- else
		-- nextTarget:setVisible(false)
		-- arrowImg:setVisible(false)
	-- end

    if not self:isCanNotSaoDang() then
        NodeUtils:setEnable(self._clearBtn,true)
    end

	if self._data.fightCount <= 0 then
		-- 挑战次数不足，变灰不可点击
		NodeUtils:setEnable(self._fightBtn,false)
		-- fightCount:setColor(ColorUtils.wordRedColor)
		if config.sort >= 100 then
			NodeUtils:setEnable(self._clearBtn,false)
		end
	else
		NodeUtils:setEnable(self._fightBtn,true)
		-- fightCount:setColor(ColorUtils.wordGreenColor)
	end
	fightCount:setString(self._data.fightCount)


	backCount:setString(self._data.backCount)
	if self._data.backCount <= 0 then
		-- self._setBackBtn:setEnabled(false)
		-- self._setBackBtn:setBright(false)
		NodeUtils:setEnable(self._setBackBtn, false)
	else
		-- self._setBackBtn:setEnabled(true)
		-- self._setBackBtn:setBright(true)
		NodeUtils:setEnable(self._setBackBtn, true)
	end

	-- 扫荡倒计时
	self:updateRemainTimeView()

	local Label_28 = self._mainPanel:getChildByName("Label_28")
	local Label_29 = self._mainPanel:getChildByName("Label_29")
	Label_28:setString(config.passinfo)
	
	-- Label_29:setString(config.info)

    local rickLabel = self._mainPanel.rickLabel
    if rickLabel == nil then
        rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        rickLabel:setPosition(Label_29:getPosition())
        self._mainPanel:addChild(rickLabel)
        self._mainPanel.rickLabel = rickLabel
    end
    rickLabel:setString(config.info)

	-- local Image_21_1 = self._mainPanel:getChildByName("Image_21_1")--用于居中富文本
	-- local size = rickLabel:getContentSize()
	-- local posx = rickLabel:getPositionX()+size.width
	-- local diff_x = Image_21_1:getPositionX() - posx
	-- rickLabel:setPositionX(rickLabel:getPositionX() + diff_x)


	Label_29:setVisible(false)


	self._fightBtn.config = config

end

function LimitExpPanel:updateButtonImg(btn, config)
	-- body
	local eventype = config.eventype
	local imgPath = ""
	local url = ""
	if eventype == 1 then
		imgPath = "barrackIcon"
		url = string.format("images/%s/%d.png", imgPath, config.icon)
	elseif eventype == 2 then
		imgPath = "map"
		url = string.format("images/%s/building%d.png", imgPath, config.icon)
	end
	TextureManager:updateButtonNormal(btn,url)
end

-- 停止扫荡：有通关则显示扫荡奖励界面
function LimitExpPanel:onStopRewardResp(rewards)
	-- print("停止扫荡：扫荡奖励数据长度 = "..#rewards)
	if #rewards > 0 then
		local panel = self:getPanel(LimitExpSweepRewardPanel.NAME)
		panel:show(rewards)
	end
end

-- 正在扫荡ing
function LimitExpPanel:onFightingResp()
	-- body
	-- print("···正在扫荡ing")

end


-- 更新定时器UI显示
function LimitExpPanel:updateRemainTimeView()
	-- body
	local time = self._clearBtn:getChildByName("time")

	if self._data.ismop == 0 then  --不在扫荡
		self._clearBtn.type = 0
		self._clearBtn:setTitleText(self:getTextWord(4007))

		time:setVisible(false)

	elseif self._data.ismop == 1 then --正在扫荡
		local remainTime = self:getMopRemainTime()
		self._clearBtn.type = 1
		self._clearBtn:setTitleText(self:getTextWord(4008))

		time:setVisible(true)
		time:setString(TimeUtils:getStandardFormatTimeString8(remainTime))


		-- 每隔30秒请求一次60100
		if self._oldRemainTime == nil then
			self._oldRemainTime = remainTime
			return
		else
			if self._oldRemainTime == remainTime then
				return
			else
				self._oldRemainTime = remainTime
			end
		end

		-- local count = self._data.maxId - self._data.id + 1
		-- if remainTime % count == 0 then
		-- 	print("每隔30秒请求一次60100 ...less", less)
		-- 	local limitExpProxy = self:getProxy(GameProxuiys.LimitExp)
		-- 	limitExpProxy:onTriggerNet60100Req({})
		-- end

		local less = remainTime % 30
		if less == 0 then
			-- print("每隔30秒请求一次60100 ...less", less)
			local limitExpProxy = self:getProxy(GameProxys.LimitExp)
			limitExpProxy:onTriggerNet60100Req({})
		end		
	end

end

function LimitExpPanel:getMopRemainTime()
	-- body
	local proxy = self:getProxy(GameProxys.LimitExp)
	local key = proxy:getTimeKey()
	local remainTime = proxy:getRemainTime(key)
	-- print("getMopRemainTime···remainTime", remainTime)
	return remainTime
end

function LimitExpPanel:update()
	-- body
	if self._data then
		-- if self._data.ismop == 1 then 
			--正在扫荡
			-- print("···正在扫荡")
			self:updateRemainTimeView()
		-- end
	
	else
		--未在扫荡
		-- print("···未在扫荡")
		-- self:updateRemainTimeView()

	end
end
