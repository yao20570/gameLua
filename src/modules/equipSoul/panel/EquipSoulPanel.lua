
EquipSoulPanel = class("EquipSoulPanel", BasicPanel)
EquipSoulPanel.NAME = "EquipSoulPanel"

local actionTime = 0.2

function EquipSoulPanel:ctor(view, panelName)
    EquipSoulPanel.super.ctor(self, view, panelName, true)
end

function EquipSoulPanel:finalize()
    EquipSoulPanel.super.finalize(self)
end

function EquipSoulPanel:initPanel()
	EquipSoulPanel.super.initPanel(self)
	local bottomPanel = self:getChildByName("bottomPanel")
	local topPanel = self:getChildByName("topPanel")
	topPanel:setClippingEnabled(true)
 	self:adjustBootomBg(bottomPanel, topPanel, true)

 	self.listView = topPanel:getChildByName("infoLv")
 	local item = self.listView:getItem(0)
    self.listView:setItemModel(item)
    item:setVisible(false)
    self.infoText = {"生命", "攻击", "命中", "闪避", "暴击", "抗暴"}
    self.textInfo = "增加武将%s上限%s"
    self.proxy = self:getProxy(GameProxys.Equip)
    local resetBtn = bottomPanel:getChildByName("resetBtn")
    self:addTouchEventListener(resetBtn, self.resetDataRep)
    self.numLab = bottomPanel:getChildByName("numLab")
end

function EquipSoulPanel:registerEvents()
	EquipSoulPanel.super.registerEvents(self)
end

function EquipSoulPanel:onClosePanelHandler()
	self.proxy:sendNotification(AppEvent.PROXY_UPDATE_TOUCH_STATE)
    self.view:dispatchEvent(EquipSoulEvent.HIDE_SELF_EVENT)
end

function EquipSoulPanel:onShowHandler()
	local pos = self.proxy:getCurrentPos()
	local config = ConfigDataManager:getConfigById(ConfigData.GeneralsConfig, pos)
	self.potential = config.potential

	self.protoData = self.proxy:getInfoById(pos)
	local soulData = self.protoData.generalSoul
	local pointConfig = ConfigDataManager:getConfigById(ConfigData.GeneralsExpConfig, self.protoData.generalLevel)
	self.allPoint = pointConfig.potentialpoint - 1

	local soulInfo = ConfigDataManager:getConfigData(ConfigData.GeneralsSoulConfig)
	
	self.allSoulLv = {}

	for k,v in pairs(soulData) do
		rawset(soulData[k], "add", self.potential*v.generallevel/100)
		rawset(soulData[k], "need", soulInfo[v.id].pointneed)
		table.insert(self.allSoulLv, v.generallevel)
		self.proxy:setPlusById(pos, v.id, self.potential*v.generallevel/100)
		self.allPoint = self.allPoint - v.num
	end
	self.proxy:sendNotification(AppEvent.PROXY_UPDATE_EQUIP_MAINVIEW)
	self.allPoint = self.allPoint >= 0 and self.allPoint or 0
	self.numLab:setString(self.allPoint)
	self.generalId = self.protoData.generalId
	self:renderListView(self.listView, soulData, self, self.render, nil, true)
end

function EquipSoulPanel:render(item, data, index)
	if item.index == nil then
		item.index = index
	end
	self:drawWidget(item, data)
end

function EquipSoulPanel:drawWidget(item, data)
	local titleImg = item:getChildByName("titleImg")
	TextureManager:updateImageView(titleImg, string.format("images/equipSoul/%d.png", data.id))
	local lvLab = item:getChildByName("lvLab")
	lvLab:setString(data.generallevel)

	local descLab = item:getChildByName("descLab")
	descLab:setString(string.format(self.textInfo, self.infoText[data.id], tostring(data.add)) .. "%")

	local renderNum = data.generallevel % 5
	local lockBg = "images/equipSoul/lock.png"
	local showBg = "images/equipSoul/greenPoint.png"
	local renderLine = renderNum - 1
	renderLine = renderLine >= 0 and renderLine or 0
	for i=1,renderNum do
		local pointImg = item:getChildByName("pointImg"..i)
		TextureManager:updateImageView(pointImg, showBg)
		pointImg:setTouchEnabled(false)

	end

	for i=renderNum + 1, 5 do
		local pointImg = item:getChildByName("pointImg"..i)
		TextureManager:updateImageView(pointImg, lockBg)
		pointImg:setTouchEnabled(false)
	end

	lockBg = "images/equipSoul/grayBar.png"
	showBg = "images/equipSoul/brownline.png"
	for i=1, 5 do
		local img = item:getChildByName("img"..i)
		local bar = img:getChildByName("bar")
		if item["bar"..i] == nil then
			local rotate = bar:getRotation()
			local size = bar:getContentSize()
			--ProgressBar转ProgressTimer
			item["bar"..i] = ComponentUtils:addProgressbar(bar, "images/equipSoul/greenBar.png")
			item["bar"..i]:setRotation(rotate)
			--还原缩放  addProgressbar里面进行了缩放~~
			item["bar"..i]:setScale(1)
		end
		if renderLine == 0 or i > renderLine then
			item["bar"..i]:setPercentage(0)
			TextureManager:updateImageView(img, lockBg)
		else
			item["bar"..i]:setPercentage(100)
			TextureManager:updateImageView(img, showBg)
		end
	end
	
	if renderLine + 1 <= 5 then
		local img = item:getChildByName("img"..(renderLine + 1))
		TextureManager:updateImageView(img, showBg)
	end

	lockBg = "images/equipSoul/nullPoint.png"
	if renderNum + 1 <= 5 then
		local pointImg = item:getChildByName("pointImg"..(renderNum + 1))
		TextureManager:updateImageView(pointImg, lockBg)
		pointImg:setTouchEnabled(true)
		pointImg.parent = item
		pointImg.data = data
		pointImg.index = renderNum
		self:addTouchEventListener(pointImg, self.sendData)
	end
end

function EquipSoulPanel:sendData(sender)
	if self.allPoint <= 0 then
		self:showSysMessage("潜力点不足")
		return
	end
	local data = sender.data
	self.nowBtn = sender
	local info = {}
	info.id = self.generalId
	info.soulid = data.id
	info.soulnum = data.need
	self.proxy:onTriggerNet290004Req(info)
end

function EquipSoulPanel:updateView(num)
	self:showSysMessage("将魂升级成功")
	local data = self.nowBtn.data
	local item = self.nowBtn.parent
	local index = self.nowBtn.index
	index = index > 5 and 5 or index

	local function callback()
		self.proxy:updateData(data.id, self.generalId, num, data.need)
		self:onShowHandler()
	end

	if item["bar"..index] ~= nil then
		local callFunc = cc.CallFunc:create(callback)
		local to = cc.ProgressFromTo:create(0.3, 0, 100)
		local action = cc.Sequence:create(to, callFunc)
		item["bar"..index]:runAction(action)
	elseif index < 1 then
		callback()
	end
end

function EquipSoulPanel:resetDataRep(sender)
	local needSend = false
	for k,v in pairs(self.allSoulLv) do
		if v ~= 0 then
			needSend = true
			break
		end
	end
	if not needSend then
		self:showSysMessage("将魂等级全部为0，无需重置")
		return
	end

	local function callback()
		local roleProxy = self:getProxy(GameProxys.Role)
    	local coin = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
    	local isNeedBuy = coin < 58
    	if isNeedBuy then
    		local parent = self:getParent()
        	local panel = parent.panel
        	if panel == nil then
            	panel = UIRecharge.new(parent, self)
            	parent.panel = panel
        	end
        	panel:show()
    	else
    		self.proxy:onTriggerNet290005Req({id = self.generalId})
    	end
	end
	self:showMessageBox("提示：是否花费58元宝重置将魂？\n（重置后所有将魂等级置0，返还全部潜能点）", callback)
end