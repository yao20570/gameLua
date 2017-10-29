
EspecialSelectPanel = class("EspecialSelectPanel", BasicPanel)
EspecialSelectPanel.NAME = "EspecialSelectPanel"

function EspecialSelectPanel:ctor(view, panelName)
    EspecialSelectPanel.super.ctor(self, view, panelName, 760)
    -- self.lastData = nil
    self:setUseNewPanelBg(true)
end

function EspecialSelectPanel:finalize()
	if self._watchPlayInfoPanel ~= nil then
		self._watchPlayInfoPanel:finalize()
	end
	self._watchPlayInfoPanel = nil
    EspecialSelectPanel.super.finalize(self)
end

function EspecialSelectPanel:initPanel()
	EspecialSelectPanel.super.initPanel(self)
	self:setTitle(true,self:getTextWord(339))

	self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

	self.mainPanel = self:getChildByName("mainPanel")
	self.mainPanel:setTouchEnabled(false)
	self.listViewFriend = self:getChildByName("mainPanel/ListView_friend")
	self.listViewLegion = self:getChildByName("mainPanel/ListView_legion")
	self.listViewLast = self:getChildByName("mainPanel/ListView_last")
	self.listViewCollect = self:getChildByName("mainPanel/ListView_collect")
end

-- function EspecialSelectPanel:onShowHandler()

-- end

function EspecialSelectPanel:onShowHandler()
	local friProxy = self:getProxy(GameProxys.Friend)
	self.friData = friProxy:getFriendInfos()
	self.collectData = friProxy:getWorldCollectionsByIsPerson(0)
	local roleProxy = self:getProxy(GameProxys.Role)
    local isHaveLegion = roleProxy:hasLegion()
	local legionProxy = self:getProxy(GameProxys.Legion)
	if isHaveLegion then
		self.legData = legionProxy:getMemberInfoList(1)
		for i=1,#self.legData do
			rawset(self.legData[i],"isSelect",false)
		end
	else
		self.legData = nil
	end
	for i=1,#self.friData do
		rawset(self.friData[i],"isSelect",false)
	end
	for i=1,#self.collectData do
		rawset(self.collectData[i],"isSelect",false)
	end
	self:updateBtnStatus(self.legionBtn)
	self:showAllInfo()

end



function EspecialSelectPanel:showAllInfo()
	self:setOtherListViewFalse(self.friBtn)
	self.listViewFriend:setVisible(false)
	self.listViewLegion:setVisible(true)
	self.listViewCollect:setVisible(false)
	self.listViewLast:setVisible(false)
	if self.legData == nil then
		self.legData = {}
	end
	self:renderListView(self.listViewLegion, self.legData, self, self.registerItemEventsLegion)	
end

function EspecialSelectPanel:registerItemEventsFriend(item,data,index)
	if item == nil then
		return
	end
	item:setVisible(true)
	local person = item:getChildByName("person")
	local name = item:getChildByName("name")
	local chooseBtn = item:getChildByName("chooseBtn")
	local img = chooseBtn:getChildByName("img")
	name:setString(data.name)
	chooseBtn.data = data
	self:addTouchEventListener(chooseBtn,self.onClickChoooseBtn)
	if rawget(data,"isSelect") == true then
		img:setVisible(true)
	else
		img:setVisible(false)
	end

	local headInfo = {}
    headInfo.icon = data.iconId
    headInfo.pendant = data.pendantId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    headInfo.playerId = rawget(data, "playerId")
    local head = person.head
    if head == nil then
        head = UIHeadImg.new(person,headInfo,self)
        person.head = head
    else
        head:updateData(headInfo)
    end 
    --head:setHeadScale(0.8)
    
--    local headBtn = head:getButton()
--    headBtn.id = data.playerId
--    self:addTouchEventListener(headBtn,self.onClickActor)
end

function EspecialSelectPanel:onClickChoooseBtn(sender)
	local isShowOk = rawget(sender.data,"isSelect")
	for i=1,#self.friData do
		rawset(self.friData[i],"isSelect",false)
	end
	if isShowOk == true then
		rawset(sender.data,"isSelect",false)
		self.lastData = nil
	else
		rawset(sender.data,"isSelect",true)
		self.lastData = sender.data
	end
	-- self:showAllInfo()
	self:showLegionPanel()
end
function EspecialSelectPanel:registerEvents()
	EspecialSelectPanel.super.registerEvents(self)
	-- self.closeBtn = self:getChildByName("mainPanel/closeBtn")
	self.legionBtn = self:getChildByName("mainPanel/teamBtn")
	self.nearBtn = self:getChildByName("mainPanel/nearBtn")
	self.friBtn = self:getChildByName("mainPanel/friBtn")
	self.getBtn = self:getChildByName("mainPanel/getBtn")
	self.chooseBtn = self:getChildByName("mainPanel/choosebtn")
	
	self.legionBtn.index = 1
	self.nearBtn.index = 2
	self.friBtn.index = 3
	self.getBtn.index = 4
	self.btnMap = {self.legionBtn,self.nearBtn,self.friBtn,self.getBtn}	
	self:updateBtnStatus(self.legionBtn)

	-- self:addTouchEventListener(self.closeBtn,self.touchButtonEvent)
	self:addTouchEventListener(self.legionBtn,self.touchButtonEvent)
	self:addTouchEventListener(self.nearBtn,self.touchButtonEvent)
	self:addTouchEventListener(self.friBtn,self.touchButtonEvent)
	self:addTouchEventListener(self.getBtn,self.touchButtonEvent)
	self:addTouchEventListener(self.chooseBtn,self.touchButtonEvent)
end

function EspecialSelectPanel:updateBtnStatus(sender)
	-- body
	-- 按钮高亮
	local index
	if sender == nil then
		index = 0
	else
		index = sender.index
	end

	for _,v in pairs(self.btnMap) do
		if v.index == index then
			v:setColor(cc.c3b(255, 255, 255))
		else
			v:setColor(cc.c3b(95, 88, 78))
		end
	end
end

function EspecialSelectPanel:touchButtonEvent(sender)
	-- local mask1 = self.legionBtn:getChildByName("mask")	
	-- local mask2 = self.nearBtn:getChildByName("mask")	
	-- local mask3 = self.friBtn:getChildByName("mask")	
	-- local mask4 = self.getBtn:getChildByName("mask")
	-- mask1:setVisible(true)
	-- mask2:setVisible(true)
	-- mask3:setVisible(true)
	-- mask4:setVisible(true)
	-- local mask = sender:getChildByName("mask")
	-- if mask ~= nil then
	-- 	mask:setVisible(false)
	-- end
	self:updateBtnStatus(sender)

	if self.legData then
		for i=1,#self.legData do
			rawset(self.legData[i],"isSelect",false)
		end
	end
	for i=1,#self.friData do
		rawset(self.friData[i],"isSelect",false)
	end
	for i=1,#self.collectData do
		rawset(self.collectData[i],"isSelect",false)
	end
	-- if self.nearData == nil then
		self.nearData = self.view:getNearData()
	-- end
	for i=1,#self.nearData do
		rawset(self.nearData[i],"isSelect",false)
	end
	if sender == self.closeBtn then
		self:hide()
		self:dispatchEvent(EspecialGoodsUseEvent.HIDE_SELF_EVENT) 
	elseif sender == self.legionBtn then
		self.listViewLegion:setVisible(true)
		self:showAllInfo()
	elseif sender == self.nearBtn then
		self.listViewLast:setVisible(true)
		self:showNearPanel()
	elseif sender == self.friBtn then
		self.listViewFriend:setVisible(true)
		self:showLegionPanel()
	elseif sender == self.getBtn then
		self.listViewCollect:setVisible(true)
		self:showCollectPanel()
	elseif sender == self.chooseBtn then
		if self.lastData == nil then
			self:showSysMessage(self:getTextWord(4015))
			return
		end
		self:setOtherListViewFalse(sender)
		self:hide()
		local data = self.lastData
		local panel = self:getPanel(EspecialGoodsUsePanel.NAME)
		panel:updatePlayerInfo(data)
		return
	end
	self.lastData = nil
	self:setOtherListViewFalse(sender)
end

function EspecialSelectPanel:setOtherListViewFalse(sender)
	if sender == self.closeBtn then
	elseif sender == self.legionBtn then
		self.listViewFriend:setVisible(false)
		self.listViewLast:setVisible(false)
		self.listViewCollect:setVisible(false)
	elseif sender == self.nearBtn then
		self.listViewFriend:setVisible(false)
		self.listViewCollect:setVisible(false)
		self.listViewLegion:setVisible(false)
	elseif sender == self.friBtn then
		self.listViewLast:setVisible(false)
		self.listViewCollect:setVisible(false)
		self.listViewLegion:setVisible(false)
	elseif sender == self.getBtn then
		self.listViewFriend:setVisible(false)
		self.listViewLast:setVisible(false)
		self.listViewLegion:setVisible(false)
	elseif sender == self.chooseBtn then
	end
end

function EspecialSelectPanel:showLegionPanel()
	if self.friData == nil then return end
	-- self:renderListView(self.listViewFriend, self.friData, self, self.registerItemEventsLegion)
	self:renderListView(self.listViewFriend, self.friData, self, self.registerItemEventsFriend)
end

function EspecialSelectPanel:registerItemEventsLegion(item,data,index)
	if item == nil then
		return
	end
	item:setVisible(true)
	local person = item:getChildByName("person")
	local name = item:getChildByName("name")
	local chooseBtn = item:getChildByName("chooseBtn")
	local img = chooseBtn:getChildByName("img")
	local fightTxt = item:getChildByName("fight")
	name:setString("Lv."..data.level.." "..data.name)
	fightTxt:setString(string.format(self:getTextWord(1217), StringUtils:formatNumberByK(data.capacity)))
	chooseBtn.data = data
	self:addTouchEventListener(chooseBtn,self.onClickChoooseLegionBtn)
	if rawget(data,"isSelect") == true then
		img:setVisible(true)
	else
		img:setVisible(false)
	end
	local headInfo = {}
    headInfo.icon = data.iconId
    headInfo.pendant = data.pendantId
    --headInfo.preName1 = "headIcon"
    --headInfo.preName1 = "headIcon"
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    headInfo.playerId = rawget(data, "id")
    --headInfo.isCreatButton = true
    local head = person.head
    if head == nil then
        head = UIHeadImg.new(person,headInfo,self)
        person.head = head
    else
        head:updateData(headInfo)
    end 
    --head:setHeadScale(0.8)
    
--    local headBtn = head:getButton()
--    headBtn.id = data.id
--    self:addTouchEventListener(headBtn,self.onClickActor)
end

function EspecialSelectPanel:showNearPanel()
	if self.nearData == nil then return end
	self:renderListView(self.listViewLast, self.nearData, self, self.registerItemEventsNear)
end

function EspecialSelectPanel:registerItemEventsNear(item,data,index)
	if item == nil then
		return
	end
	item:setVisible(true)
	local person = item:getChildByName("person")
	local name = item:getChildByName("name")
	local chooseBtn = item:getChildByName("chooseBtn")
	local img = chooseBtn:getChildByName("img")
	name:setString(data.name)
	chooseBtn.data = data
	self:addTouchEventListener(chooseBtn,self.onClickChoooseNearBtn)
	if rawget(data,"isSelect") == true then
		img:setVisible(true)
	else
		img:setVisible(false)
	end

	local headInfo = {}
    headInfo.icon = data.iconId
    -- headInfo.pendant = data.pendantId
    --headInfo.preName1 = "headIcon"
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = false
    headInfo.playerId = rawget(data, "playerId")
    --headInfo.isCreatButton = true
    local head = person.head
    if head == nil then
        head = UIHeadImg.new(person,headInfo,self)
        person.head = head
    else
        head:updateData(headInfo)
    end 
    --head:setHeadScale(0.8)
--    local headBtn = head:getButton()
--    headBtn.id = data.playerId
--    self:addTouchEventListener(headBtn,self.onClickActor)
end

function EspecialSelectPanel:onClickChoooseLegionBtn(sender)
	local isShowOk = rawget(sender.data,"isSelect")
	for i=1,#self.legData do
		rawset(self.legData[i],"isSelect",false)
	end
	if isShowOk == true then
		rawset(sender.data,"isSelect",false)
		self.lastData = nil
	else
		rawset(sender.data,"isSelect",true)
		self.lastData = sender.data
	end
	self:showAllInfo()
end

function EspecialSelectPanel:onClickActor(sender)
	local chatProxy = self:getProxy(GameProxys.Chat)
	if sender.id == 0 then 
		chatProxy:watchPlayerInfoReq({name = sender.name})
	else
		chatProxy:watchPlayerInfoReq({playerId = sender.id})
	end
    
end

function EspecialSelectPanel:onPlayerInfoResp(data)
    if self._watchPlayInfoPanel == nil then
        self._watchPlayInfoPanel = UIWatchPlayerInfo.new(self:getParent(), self, false, true)
    end
    -- self._watchPlayInfoPanel:setMialShield(true)
    self._watchPlayInfoPanel:showAllInfo(data)
end

function EspecialSelectPanel:showCollectPanel()  --收藏
	if self.collectData == nil then return end
	self:renderListView(self.listViewCollect, self.collectData, self, self.registerItemEventsCollect)
end

function EspecialSelectPanel:registerItemEventsCollect(item, data, index)
	if item == nil then
		return
	end
	item:setVisible(true)
	local person = item:getChildByName("person")
	local name = item:getChildByName("name")
	local chooseBtn = item:getChildByName("chooseBtn")
	local img = chooseBtn:getChildByName("img")
	name:setString(data.name)
	chooseBtn.data = data
	self:addTouchEventListener(chooseBtn,self.onClickChoooseCollectBtn)
	if rawget(data,"isSelect") == true then
		img:setVisible(true)
	else
		img:setVisible(false)
	end
	local headInfo = {}
    headInfo.icon = data.iconId
    headInfo.pendant = data.pendantId
    --headInfo.preName1 = "headIcon"
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    headInfo.playerId = rawget(data, "playerId")
    --headInfo.isCreatButton = true
    local head = person.head
    if head == nil then
        head = UIHeadImg.new(person,headInfo,self)
        person.head = head
    else
        head:updateData(headInfo)
    end 
    --head:setHeadScale(0.8)
--    local headBtn = head:getButton()
--    headBtn.name = data.name
--    headBtn.id = 0
--    self:addTouchEventListener(headBtn,self.onClickActor)
end

function EspecialSelectPanel:onClickChoooseCollectBtn(sender)
	local isShowOk = rawget(sender.data,"isSelect")
	for i=1,#self.collectData do
		rawset(self.collectData[i],"isSelect",false)
	end
	if isShowOk == true then
		rawset(sender.data,"isSelect",false)
		self.lastData = nil
	else
		rawset(sender.data,"isSelect",true)
		self.lastData = sender.data
	end
	self:showCollectPanel()
end

function EspecialSelectPanel:onClickChoooseNearBtn(sender)
	local isShowOk = rawget(sender.data,"isSelect")
	for i=1,#self.nearData do
		rawset(self.nearData[i],"isSelect",false)
	end
	if isShowOk == true then
		rawset(sender.data,"isSelect",false)
		self.lastData = nil
	else
		rawset(sender.data,"isSelect",true)
		self.lastData = sender.data
	end
	self:showNearPanel()
end