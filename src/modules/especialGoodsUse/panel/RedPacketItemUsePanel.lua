RedPacketItemUsePanel = class("RedPacketItemUsePanel", BasicPanel)
RedPacketItemUsePanel.NAME = "RedPacketItemUsePanel"

function RedPacketItemUsePanel:ctor(view, panelName)
    RedPacketItemUsePanel.super.ctor(self,view,panelName)

    -- self:setUseNewPanelBg(true)
end

function RedPacketItemUsePanel:finalize()
    RedPacketItemUsePanel.super.finalize(self)
end

function RedPacketItemUsePanel:initPanel()
	RedPacketItemUsePanel.super.initPanel(self)
	self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

	self.touchPanel = self:getChildByName("touchPanel")

	for i = 0,2 do
		self:getChildByName("mainPanel/toSendBtn_"..i):setVisible(false)
	end 
	-- self.toPersonBtn = self:getChildByName("mainPanel/toSendBtn_0")
	-- self.toWorldBtn = self:getChildByName("mainPanel/toSendBtn_1") --发送到世界
	-- self.toLegionBtn = self:getChildByName("mainPanel/toSendBtn_2") --发送到同盟

	-- self.toWorldBtn.index = 0
	-- self.toWorldBtn.index = 1
	-- self.toLegionBtn.index = 2

	-- self:addTouchEventListener(self.toWorldBtn,self.sendRedPacket)
	-- self:addTouchEventListener(self.toLegionBtn,self.sendRedPacket)

	self.close = self:getChildByName("mainPanel/closeBtn")
	self.close:setVisible(false)
	
	-- self._touchPanel = self:getChildByName("touchPanel")
	self:addTouchEventListener(self.close,self.closeThisPanel)
	self:addTouchEventListener(self.touchPanel,self.closeThisPanel)

	self.desLab = self:getChildByName("mainPanel/desLab")
end

function RedPacketItemUsePanel:registerEvents()
	RedPacketItemUsePanel.super.registerEvents(self)
end


--[[
@data
	name=物品名称
	typeid=物品id
	num=标记（这个界面目前无用到）
	itemtype=物品类型
--]]
function RedPacketItemUsePanel:onShowHandler(data)
	local itemInfo = ConfigDataManager:getRedItemInfo(data.typeid) --物品信息
	self.getData = data
	self.itemInfo = itemInfo
    local redPaketInfo = ConfigDataManager:getRedPacketInfoById(itemInfo.redPacketId) --红包信息
    local redType = StringUtils:jsonDecode(redPaketInfo.type)

    local sumInfo = StringUtils:jsonDecode(redPaketInfo.sum)
    local moneyUnit = sumInfo[2] --单位
    local allMoney = sumInfo[3] --红包总数
    local unit

    if tonumber(moneyUnit) == 201 then
        unit = TextWords:getTextWord(524) --银币
    elseif tonumber(moneyUnit) == 206 then
        unit = TextWords:getTextWord(525) --元宝
    end

    self.desLab:setString(string.format(TextWords:getTextWord(391011),allMoney,unit))

    for i = 0,2 do
		self:getChildByName("mainPanel/toSendBtn_"..i):setVisible(false)
	end

    local pos = {
    	[1] = {320},
    	[2] = {170 + 25,470 - 25},
    	[3] = {140,320,500},
	} 

    for k,v in pairs(redType) do
    	local btn = self:getChildByName("mainPanel/toSendBtn_"..v)
    	btn:setVisible(true)
    	self:addTouchEventListener(btn,self.sendRedPacket)
    	btn:setPositionX(pos[#redType][k])
    	btn.index = v
    end 
end

function RedPacketItemUsePanel:closeThisPanel(sender)
	self:hide()
	-- local moduleName = ModuleName.EspecialGoodsUseModule
	self:dispatchEvent(EspecialGoodsUseEvent.HIDE_SELF_EVENT)
end

function RedPacketItemUsePanel:sendRedPacket(sender) --发送红包
	local channelChoose = sender.index --选择的频道
	local data = {}
	data.itemId = self.itemInfo.ID
	data.channel = channelChoose

	if data.channel == 0 then --发送给私人
		local panel = self:getPanel(EspecialGoodsUsePanel.NAME)
        local noShowBlur = true
        panel:show({name=self.itemInfo.name,typeid=self.itemInfo.ID,num=3,itemtype=self.getData.itemtype}, nil, noShowBlur) --跳转到私人红包界面
        self:hide()
        return
	elseif data.channel == 1 then --发送到世界
		data.name = ""
	elseif data.channel == 2 then --发送到同盟
		--判断是否有同盟
		data.name = ""
		local roleProxy = self:getProxy(GameProxys.Role)
		local isHaveLegion = roleProxy:hasLegion()
		if not isHaveLegion then
			self:showSysMessage(self:getTextWord(391003))
			self:closeThisPanel()
			return
		end
	end 
	self:dispatchEvent(EspecialGoodsUseEvent.REDPACKET_ITEMGOODS_USE_REQ,data)
	self:hide()
end