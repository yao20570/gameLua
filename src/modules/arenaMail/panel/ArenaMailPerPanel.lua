
ArenaMailPerPanel = class("ArenaMailPerPanel", BasicPanel)
ArenaMailPerPanel.NAME = "ArenaMailPerPanel"

function ArenaMailPerPanel:ctor(view, panelName)
    ArenaMailPerPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ArenaMailPerPanel:finalize()
    ArenaMailPerPanel.super.finalize(self)
end

function ArenaMailPerPanel:initPanel()
	ArenaMailPerPanel.super.initPanel(self)
	self._listview = self:getChildByName("bgListView")
	-- NodeUtils:adaptive(self._listview)
	
	self:registerEvent()
end

function ArenaMailPerPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
	local down_panel = self:getChildByName("down_panel")
    NodeUtils:adaptiveListView(self._listview,down_panel,tabsPanel,GlobalConfig.topTabsHeight)
end

function ArenaMailPerPanel:onTabChangeEvent(tabControl)
    local panel = self:getPanel(ArenaMailPanel.NAME)
    local downWidget = panel:getChildByName("down_panel")
    ArenaMailPerPanel.super.onTabChangeEvent(self, tabControl, downWidget)

end

function ArenaMailPerPanel:registerEvent()
	local Button_14 = self:getChildByName("down_panel/Button_14")
	self:addTouchEventListener(Button_14,self.onDeleteAllMails)
end

function ArenaMailPerPanel:onDeleteAllMails()
	local function callback()
		local data = {}
		data.isAll = true
		data.id = {}
		for _,v in pairs(self._data) do
			table.insert(data.id,v.id)
		end
		self:dispatchEvent(ArenaMailEvent.DELETE_MAILS_REQ,data)
	end
	--self:showMessageBox("你确定要清空个人战报吗?",callback)
	self:showMessageBox(self:getTextWord(200014),callback)
end

function ArenaMailPerPanel:onShowHandler()
	--local data = self.view:getData()
	local proxy = self:getProxy(GameProxys.Arena)
	local data = proxy:onGetPerMailsMap()
	--if data ~= nil then
		self:onUpdateData(data)
	--end
end

function ArenaMailPerPanel:onUpdateData(data)
	self._data = data--.perInfos
	--table.sort( self._data, function (a,b) return a.time > b.time end)
	self:renderListView(self._listview, self._data, self, self.registerItemEvents)
	self:updateReads(self._data)--.perInfos)
end

function ArenaMailPerPanel:updateReads(data)
	local total = self:getChildByName("topPanel/total")
	local notRead = self:getChildByName("topPanel/notRead")
	total:setString(#data)
	local count = 0
	for _,v in pairs(data) do
		if v.isRead == 2 then
			count = count + 1
		end
	end
	notRead:setString(count)
end

function ArenaMailPerPanel:registerItemEvents(item,data,index)
	if item == nil then
		return
	end
	item.data = data
	local Image_6 = item:getChildByName("Image_6")
	local name = Image_6:getChildByName("name")
	local bg = Image_6:getChildByName("bg")
	local time = Image_6:getChildByName("time")
	local Image_10 = Image_6:getChildByName("Image_10")
	local imgResult = Image_6:getChildByName("imgResult")

	local strName = ""
	--local resultTb = {"胜利","失败"}
	local resultTb = {self:getTextWord(200000),self:getTextWord(200001)}
	if data.type == 1 then  --攻击
		--strName = "我 挑战 "..data.protect.." "..resultTb[data.result]
		strName = self:getTextWord(200015).." "..data.protect
	else
		--strName = data.attack.." 挑战 我 "..resultTb[data.result]
		strName = data.attack.." "..self:getTextWord(200016)
	end
	if data.result == 1 then  --攻击
		--strName = "我 挑战 "..data.protect.." "..resultTb[data.result]
        TextureManager:updateImageView(imgResult, "images/newGui2/font_victory.png")
	else
		--strName = data.attack.." 挑战 我 "..resultTb[data.result]
        TextureManager:updateImageView(imgResult, "images/newGui2/font_fail.png")
	end
	name:setString(strName)
	time:setString(TimeUtils:setTimestampToString(data.time))

	if data.isRead == 1 then  --已读
		Image_10:setVisible(true)
		bg:setVisible(false)
	else
		Image_10:setVisible(false)
		bg:setVisible(true)
	end
	self:addItemHandle(item)
end

function ArenaMailPerPanel:addItemHandle(item)
	if item.isAdd == true then
		return 
	end
	item.isAdd = true
	self:addTouchEventListener(item,self.onAddTouchHandle)
end

function ArenaMailPerPanel:onAddTouchHandle(sender)
    print("------------------------------touch 1111")
	-- local data = self.view:getDetailData()
	-- if data[sender.data.id] ~= nil then
	-- 	local panel = self:getPanel(ArenaMailInfoPanel.NAME)
	-- 	panel:show()
	-- 	panel:onUpdateData(data[sender.data.id])
	-- else
	 	self:dispatchEvent(ArenaMailEvent.READ_MAIL_REQ,{type = 1,id = sender.data.id})
	-- end
end