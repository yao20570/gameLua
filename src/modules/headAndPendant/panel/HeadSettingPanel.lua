
HeadSettingPanel = class("HeadSettingPanel", BasicPanel)
HeadSettingPanel.NAME = "HeadSettingPanel"

function HeadSettingPanel:ctor(view, panelName)
    HeadSettingPanel.super.ctor(self, view, panelName)
    self.ROW_MAX = 4
end

function HeadSettingPanel:finalize()
    HeadSettingPanel.super.finalize(self)
end

function HeadSettingPanel:initPanel()
	HeadSettingPanel.super.initPanel(self)
	self.listView = self:getChildByName("ListView_58")
	self:initConfigData()

	-- 确定按钮
	local sureBtn = self:getChildByName("downPanel/sureBtn")
	sureBtn:setTitleText(self:getTextWord(1427))
	self:addTouchEventListener(sureBtn, self.onSureBtn)
	self._sureBtn = sureBtn

	local headBtn = self:getChildByName("downPanel/headBtn")
	self:addTouchEventListener(headBtn, self.onCustonHeadBtn)

    local headCostTxt = self:getChildByName("downPanel/costTxt")
    local config = ConfigDataManager:getConfigById(ConfigData.CustomIconConfig, 1)
    headCostTxt:setString(config.price)

    self._roleProxy = self:getProxy(GameProxys.Role)

    self._remainTxt = self:getChildByName("downPanel/remainTxt")
    self._remainTxt:setColor(ColorUtils.wordColorDark04)
    self:updateRemainTime()

end

function HeadSettingPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
	local downPanel = self:getChildByName("downPanel")
	-- NodeUtils:adaptiveListView(self.listView, downPanel, tabsPanel)

	NodeUtils:adaptiveDownPanel(downPanel,nil,GlobalConfig.downHeight)

	NodeUtils:adaptiveListView(self.listView, downPanel, tabsPanel)
end

function HeadSettingPanel:onShowHandler()
	self:updatePlayerData()
	self:renderListView(self.listView, self._allHeadInfo, self, self.onRenderHead,nil,nil,0)
end

function HeadSettingPanel:initConfigData()
	local config = ConfigDataManager:getConfigData(ConfigData.HeadPortraitConfig)
	local vipConfig = {}
	local norConfig = {}
	local otherConfig = {}
	local customConfig = {}
	for k,v in pairs(config) do
		if v.type == 1 then
			table.insert(norConfig, v)
		elseif v.type==2 then
			table.insert(vipConfig, v)
		elseif v.type == 4 then
			table.insert(customConfig, v)
		else
			table.insert(otherConfig, v)
		end
	end
	local index = 1
	local function initData(data)
		data = TableUtils:map2list(data)
		table.sort(data, function(a, b)
			return a.id < b.id
		end)
		self._allHeadInfo = self._allHeadInfo or {}
    	
		for i=1,#data, 4 do
			self._allHeadInfo[index] = self._allHeadInfo[index] or {}
	        table.insert(self._allHeadInfo[index], data[i])
	        table.insert(self._allHeadInfo[index], data[i+1])
	        table.insert(self._allHeadInfo[index], data[i+2])
	        table.insert(self._allHeadInfo[index], data[i+3])
	        index = index + 1
		end
	end
	initData(norConfig)
	initData(vipConfig)
	initData(otherConfig)
	initData(customConfig)
end

function HeadSettingPanel:updatePlayerData()
	local roleProxy = self:getProxy(GameProxys.Role)
    self._selectHead = roleProxy:getHeadId()
    self._pendantId = roleProxy:getPendantId()

    if self._selectHead == 0 then
    	self._selectHead = 101
    end
    if self._pendantId == 0 then
    	self._pendantId = 101
    end
    
    return self._selectHead, self._pendantId
end

function HeadSettingPanel:onRenderHead(item, data, index)
	
	if data[1] ~= nil then
		--文本的设置，不需要遍历
		local title = item:getChildByName("title")
		local imgTitleBg = item:getChildByName("imgTitleBg")
		local useneed = StringUtils:jsonDecode(data[1].useneed)
		local nType = data[1].type -- 1 普通     2 VIP    3 活动类型
		title:setVisible(#useneed == 0)

		local tipBtn = item:getChildByName("tipBtn")
		tipBtn:setVisible(false)

		if nType ~= 2 and nType ~= 4 then
			if item.richText ~= nil then
				item.richText:setVisible(false)
			end
			title:setString( nType==1 and "普通头像" or "活动头像")
		elseif nType == 4 then ---自定义头像
			title:setString("我的个性头像")
			-----------------个性头像，判断是否存在，不存在则显示默认的
			tipBtn:setVisible(true)
			self:addTouchEventListener(tipBtn, self.onCustomTipBtn)
		else
			if item.richText == nil then
				item.richText = ComponentUtils:createRichLabel("", nil, nil, 2)
				local x, y = title:getPosition()
				item.richText:setPosition(x, y)
				title:getParent():addChild(item.richText)
			end
			item.richText:setVisible(true)
			local text = {{{"VIP专用头像 ", 24, "#ffeed6aa"},{"[VIP"..useneed[2].."以上]", 24, "#FFFFBD30"}}}
			item.richText:setString(text)
		end

		local idx = index + 1
		local last = self._allHeadInfo[idx - 1]
		if last ~= nil then
			if last[1].type == self._allHeadInfo[idx][1].type then
				title:setVisible(false)
				imgTitleBg:setVisible(false)
				if item.richText ~= nil then
					item.richText:setVisible(false)
				end
			end
		end
	end

    local roleProxy = self:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()

	for i=1,self.ROW_MAX do
		local panel = item:getChildByName("Panel"..i)
		panel:setVisible(data[i] ~= nil)
		if data[i] ~= nil then

			local selectImg = panel:getChildByName("imgSelect")
			selectImg:setVisible(data[i].id == self._selectHead)
			if data[i].id == self._selectHead then
				self._selectImg = selectImg
			end

			local headInfo = {}
		    headInfo.icon = data[i].icon
		    headInfo.pendant = 100
		    headInfo.preName1 = "headIcon"
		    headInfo.preName2 = nil
		    headInfo.isCreatPendant = false
		    --headInfo.isCreatButton = false
		    --headInfo.isSettingPanel = true

		    headInfo.playerId = playerId

		    if panel.uiHead == nil then
		    	panel.uiHead = UIHeadImg.new(panel, headInfo, self)
                panel.uiHead:setPosition(selectImg:getPosition())
		    else
		    	panel.uiHead:updateData(headInfo)
		    end

		    local has = true
		    if data[1].type==3 then
		    	local settingProxy = self:getProxy( GameProxys.Setting )
				has = settingProxy:isHasHead( data[i].id )
			end

		    panel.info = data[i]
		    panel.id = has and data[i].id or nil
			self:addTouchEventListener(panel, self.onSwitchHeadBtn)

			if data[1].type==4 then
				self._customHeadPanel = panel
				self._customHeadInfo = headInfo
			end
		end
	end
end

--自动选择自定义头像
function HeadSettingPanel:selectCustomHead()
	if self._customHeadPanel ~= nil then
		self._customHeadPanel.uiHead:updateData(self._customHeadInfo)
		self:onSwitchHeadBtn(self._customHeadPanel)
		self:onSureBtn(self._sureBtn)
	end
end

function HeadSettingPanel:onSureBtn(sender)
	if not self._selectHead then
		self:showSysMessage( self:getTextWord(1433) )
		return
	end
	local data = {}
	data.iconId = self._selectHead
	self.view:onHeadSettingReq(data)
end

function HeadSettingPanel:onCustonHeadBtn(sender)
    
    --先请求服务端，看是否可以定制头像
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:onTriggerNet140200Req()
end

function HeadSettingPanel:onSwitchHeadBtn(sender)
	if self._selectHead == sender.info.id then
		return
	end
	self._selectHead = sender.id
	if self._selectImg ~= nil then
		self._selectImg:setVisible(false)
	end
	self._selectImg = sender:getChildByName("imgSelect")
	self._selectImg:setVisible(true)
end


-- 设置成功飘字
function HeadSettingPanel:onHeadSettingResp(data)
	-- body
end

function HeadSettingPanel:update()
	self:updateRemainTime()
end

function HeadSettingPanel:updateRemainTime()
	local remainTime = self._roleProxy:getCustomHeadCoolTime()
	-- self:showSysMessage("~~~~~updateRemainTime~~remainTime~~~:%d" .. remainTime)
	if remainTime <= 0 then
		self._remainTxt:setVisible(false)
	else
		self._remainTxt:setVisible(true)
		local info = string.format(TextWords:getTextWord(142009), 
			TimeUtils:getStandardFormatTimeString7(remainTime))
		self._remainTxt:setString(info)
	end
end

function HeadSettingPanel:onCustomTipBtn()
	local uiTip = UITip.new(self:getParent())
	local tipText = TextWords:getTextWord(142010)
	local text = {{{content = tipText, foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}}
    uiTip:setAllTipLine(text)
end
