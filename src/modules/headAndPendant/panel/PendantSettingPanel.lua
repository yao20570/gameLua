
PendantSettingPanel = class("PendantSettingPanel", BasicPanel)
PendantSettingPanel.NAME = "PendantSettingPanel"

function PendantSettingPanel:ctor(view, panelName)
    PendantSettingPanel.super.ctor(self, view, panelName)
    self.ROW_MAX = 4
end

function PendantSettingPanel:finalize()
    PendantSettingPanel.super.finalize(self)
end

function PendantSettingPanel:initPanel()
	PendantSettingPanel.super.initPanel(self)
	self.listView = self:getChildByName("ListView_58")
	self:initConfigData()


	-- 确定按钮
	local sureBtn = self:getChildByName("downPanel/sureBtn")
	sureBtn:setTitleText(self:getTextWord(1427))
	self:addTouchEventListener(sureBtn, self.onSureBtn)
end

function PendantSettingPanel:doLayout()

	local tabsPanel = self:getTabsPanel()
	local downPanel = self:getChildByName("downPanel")

	NodeUtils:adaptiveDownPanel(downPanel,nil,GlobalConfig.downHeight)

	NodeUtils:adaptiveListView(self.listView, downPanel, tabsPanel)

	-- NodeUtils:adaptiveListView(self.listView, downPanel, tabsPanel)

end

function PendantSettingPanel:onShowHandler()

	self:updatePlayerData()
	self:renderListView(self.listView, self._allPendantInfo, self, self.onRenderHead)

end



function PendantSettingPanel:initConfigData()
	local config = ConfigDataManager:getConfigData(ConfigData.PendantConfig)
	local vipConfig = {}
	local norConfig = {}
	local otherConfig = {}
	for k,v in pairs(config) do
		if v.type == 1 then
			table.insert(norConfig, v)
		elseif v.type==2 then
			table.insert(vipConfig, v)
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
		self._allPendantInfo = self._allPendantInfo or {}
    	
		for i=1,#data, 4 do
			self._allPendantInfo[index] = self._allPendantInfo[index] or {}
	        table.insert(self._allPendantInfo[index], data[i])
	        table.insert(self._allPendantInfo[index], data[i+1])
	        table.insert(self._allPendantInfo[index], data[i+2])
	        table.insert(self._allPendantInfo[index], data[i+3])
	        index = index + 1
		end
	end
	initData(norConfig)
	initData(vipConfig)
	initData(otherConfig)
end
function PendantSettingPanel:updatePlayerData()
	local roleProxy = self:getProxy(GameProxys.Role)
    self._selectHead = roleProxy:getHeadId()
    self._selectPendantId = roleProxy:getPendantId()

    if self._selectHead == 0 then
    	self._selectHead = 101
    end
    if self._selectPendantId == 0 then
    	self._selectPendantId = 101
    end
    
    return self._selectHead, self._selectPendantId


end
function PendantSettingPanel:onRenderHead(item, data, index)
	print("刷新", index)
	
	if data[1] ~= nil then
		--文本的设置，不需要遍历
		local title = item:getChildByName("title")
		local imgTitleBg = item:getChildByName("imgTitleBg")
		local useneed = StringUtils:jsonDecode(data[1].useneed)
		local nType = data[1].type
		title:setVisible(#useneed == 0)
		if nType ~= 2 then
			if item.richText ~= nil then
				item.richText:setVisible(false)
			end
			title:setString( nType==1 and "普通挂饰" or "活动挂饰")
		else
			if item.richText == nil then
				item.richText = ComponentUtils:createRichLabel("", nil, nil, 2)
				local x, y = title:getPosition()
				item.richText:setPosition(x, y)
				title:getParent():addChild(item.richText)
			end
			item.richText:setVisible(true)
			local fontSize = title:getFontSize()
			local text = {{{"VIP专用挂饰 ", fontSize, ColorUtils.commonColor.FuBiaoTi},
							{"[VIP"..useneed[2].."以上]", fontSize, ColorUtils.commonColor.BiaoTi}}}
			item.richText:setString(text)
		end

		local idx = index + 1
		local last = self._allPendantInfo[idx - 1]
		if last ~= nil then
			if last[1].type == self._allPendantInfo[idx][1].type then
				title:setVisible(false)
				imgTitleBg:setVisible(false)
				if item.richText ~= nil then
					item.richText:setVisible(false)
				end
			end
		end
	end

	for i=1,self.ROW_MAX do
		local panel = item:getChildByName("Panel"..i)
		panel:setVisible(data[i] ~= nil)
		if data[i] ~= nil then

			local Image_29 = panel:getChildByName("Image_29")
			local selectImg = panel:getChildByName("Image_22")
			selectImg:setVisible(data[i].id == self._selectPendantId)
			if data[i].id == self._selectPendantId then
				self._selectImg = selectImg
			end

			local headInfo = {}
		    headInfo.icon = 9999
		    headInfo.pendant = data[i].icon
		    headInfo.preName1 = "headIcon"
		    headInfo.preName2 = nil
		    headInfo.isChat = true
		    headInfo.isCreatPendant = true
		    --headInfo.isCreatButton = false
		    --headInfo.isSettingPanel = false
		    --headInfo.isCreatCover = false

		    if panel.uiHead == nil then
		    	panel.uiHead = UIHeadImg.new(Image_29, headInfo, self)
                
		    else
		    	panel.uiHead:updateData(headInfo)
		    end

		    local has = true
		    if data[1].type==3 then
		    	local settingProxy = self:getProxy( GameProxys.Setting )
				has = settingProxy:isHasPendant( data[i].id )
				Image_29:setOpacity( has and 255 or 80 )
			end


		    panel.info = data[i]
		    panel.id = has and data[i].id or nil
			self:addTouchEventListener(panel, self.onSwitchHeadBtn)
		end
	end
end


function PendantSettingPanel:onSureBtn(sender)
	if not self._selectPendantId then
		self:showSysMessage( self:getTextWord(1434) )
		return
	end
	local data = {}
	data.pendantId = self._selectPendantId
	self.view:onHeadSettingReq(data)

end

function PendantSettingPanel:onSwitchHeadBtn(sender)

	if self._selectPendantId == sender.info.id then
		return
	end
	self._selectPendantId = sender.id
	if self._selectImg ~= nil then
		self._selectImg:setVisible(false)
	end
	self._selectImg = sender:getChildByName("Image_22")
	self._selectImg:setVisible(true)

end



-- 设置成功飘字
function PendantSettingPanel:onHeadSettingResp(data)
	-- body
end


