
ArenaMailAllPanel = class("ArenaMailAllPanel", BasicPanel)
ArenaMailAllPanel.NAME = "ArenaMailAllPanel"

function ArenaMailAllPanel:ctor(view, panelName)
    ArenaMailAllPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ArenaMailAllPanel:finalize()
    ArenaMailAllPanel.super.finalize(self)
end

function ArenaMailAllPanel:initPanel()
	ArenaMailAllPanel.super.initPanel(self)
	self._listview = self:getChildByName("bgListView")
	-- NodeUtils:adaptive(self._listview)
	
    
end

function ArenaMailAllPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
	local down_panel = self:getChildByName("down_panel")
	NodeUtils:adaptiveListView(self._listview,down_panel,tabsPanel,GlobalConfig.topTabsHeight)
end

function ArenaMailAllPanel:onTabChangeEvent(tabControl)
    local panel = self:getPanel(ArenaMailPanel.NAME)
    local downWidget = panel:getChildByName("down_panel")
    ArenaMailAllPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function ArenaMailAllPanel:onShowHandler()
	-- local data = self.view:getData()
	local proxy = self:getProxy(GameProxys.Arena)
	local data = proxy:onGetAllMailsMap()
	-- if data ~= nil then
	-- 	self:onUpdateData(self.view:getData())
	-- end
	self:onUpdateData(data)
end

function ArenaMailAllPanel:onUpdateData(data)
	self._data = data--.allInfos
	-- table.sort( self._data, function (a,b) return a.time > b.time end)
	self:renderListView(self._listview, self._data, self, self.registerItemEvents)
	self:updateReads(data)--.allInfos)
end

function ArenaMailAllPanel:updateReads(data)
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

function ArenaMailAllPanel:registerItemEvents(item,data,index)
	if item == nil then
		return
	end
	item.data = data
	--local resultTb = {"胜利","失败"}
	local resultTb = {self:getTextWord(200000),self:getTextWord(200001)}
	local Image_6 = item:getChildByName("Image_6")
	local name = Image_6:getChildByName("name")
	local bg = Image_6:getChildByName("bg")
	local time = Image_6:getChildByName("time")
	local Image_10 = Image_6:getChildByName("Image_10")
	local imgResult = Image_6:getChildByName("imgResult")
    
	if data.result == 1 then
        TextureManager:updateImageView(imgResult, "images/newGui2/font_victory.png")
	else
        TextureManager:updateImageView(imgResult, "images/newGui2/font_fail.png")
	end

	local strName = data.attack.." "..self:getTextWord(200002).." "..data.protect
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

function ArenaMailAllPanel:addItemHandle(item)
	if item.isAdd == true then
		return 
	end
	item.isAdd = true
	self:addTouchEventListener(item,self.onAddTouchHandle)
end

function ArenaMailAllPanel:onAddTouchHandle(sender)
	--local data = self.view:getDetailData()
	-- if data[sender.data.id] ~= nil then
	-- 	local panel = self:getPanel(ArenaMailInfoPanel.NAME)
	-- 	panel:show()
	-- 	panel:onUpdateData(data[sender.data.id])
	-- else
		self:dispatchEvent(ArenaMailEvent.READ_MAIL_REQ,{type = 2,id = sender.data.id})
	--end
end