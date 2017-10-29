
TigerMachinePanel = class("TigerMachinePanel", BasicPanel)
TigerMachinePanel.NAME = "TigerMachinePanel"

function TigerMachinePanel:ctor(view, panelName)
    TigerMachinePanel.super.ctor(self, view, panelName, 480)
    self.isCanDrawGoods = true
    self.listInfo1 = {{407,206,5},{407,206,10},{407,206,15},{407,206,20},{407,206,50}}
	self.listInfo2 = {{407,104,150},{407,104,200},{407,104,250},{407,104,300},{407,104,500}}
	self.listInfo3 = {{401,4013,1},{401,4014,1},{406,405,1},{406,404,1},{406,305,1},{406,304,1},
 					{406,205,1},{406,204,1},{406,105,1},{406,104,1},{409,101,1},{409,102,1},{409,103,1}}


end
function TigerMachinePanel:finalize()
    TigerMachinePanel.super.finalize(self)
    self._frameQueue:finalize()
end
function TigerMachinePanel:initPanel()
	TigerMachinePanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(340))

    local closePanelBtn = self:getCloseBtn()
    self:addTouchEventListener(closePanelBtn,self.closeTigerMachinePanel)  --二级弹窗关闭按钮

	self._frameQueue = FrameQueue.new(3)
	for i=1,3 do
		self["listView"..i] = self:getChildByName("Panel_1/Image_5/ListView_"..i)
		self["listView"..i]:setEnabled(false)
	end
	self:showAllItem()
end

function TigerMachinePanel:touchEndCallback(listView)
    listView:jumpToBottom()
end

function TigerMachinePanel:showAllItem(data)
	if data and #data > 0 then
		self.listInfo1[4] = data[1]
		self.listInfo2[4] = data[2]
		self.listInfo3[5] = data[3]
	end
	local tmpList1 = self.listInfo1
	local tmpList2 = self.listInfo2
	local tmpList3 = self.listInfo3
	self:renderListView(self.listView1, tmpList1, self, self.renderItemPanel)
	self:renderListView(self.listView2, tmpList2, self, self.renderItemPanel)
	self:renderListView(self.listView3, tmpList3, self, self.renderItemPanel)
end
function TigerMachinePanel:renderItemPanel(item, itemInfo, index)
	local container = item:getChildByName("container")
	local last_data = {}
	last_data.power = itemInfo[1]
	last_data.typeid = itemInfo[2]
	last_data.num = itemInfo[3]
	local icon = container.icon
 	if icon == nil then
 		icon = UIIcon.new(container, last_data, true, self)
 		container.icon = icon
 	else
 		icon:updateData(last_data)
 	end
end
function TigerMachinePanel:onShowHandler(data)
	local tmpData = {}
	tmpData.type = 0
	self:dispatchEvent(TigerMachineEvent.SHOW_ALL_PANEL_EVENT_REQ,tmpData) 
end
function TigerMachinePanel:updatePanel(data)  --更新本面板
	if data.rs == 0 then
		self.drawBtn:setVisible(false)
		return
	end
	local tmpData = {}
	if data.rewardInfo then
		if #data.rewardInfo > 0 then
			self.drawBtn:setVisible(false)
			for i=1,#data.rewardInfo do
				tmpData[i] = {}
				table.insert(tmpData[i],data.rewardInfo[i].power)
				table.insert(tmpData[i],data.rewardInfo[i].itemId)
				table.insert(tmpData[i],data.rewardInfo[i].num)
			end
		end
	end
	if #tmpData>0 then
		self:showAllItem(tmpData)
		self._frameQueue:pushParams(self.addDisListViewJumpToButton, self)
	end
end

function TigerMachinePanel:addDisListViewJumpToButton()
	for i=1,3 do
        ComponentUtils:addListViewTouchEndEvent(self["listView"..i], self, self.touchEndCallback)
        local function touchEndCallback()
            self:touchEndCallback(self["listView"..i])
        end
        TimerManager:addOnce(30,touchEndCallback, self)
	end
end
function TigerMachinePanel:registerEvents()
	TigerMachinePanel.super.registerEvents(self)
	self.closeBtn = self:getChildByName("Panel_1/Button_19")
	self:addTouchEventListener(self.closeBtn,self.closeTigerMachinePanel)  --关闭
	self.drawBtn = self:getChildByName("Panel_1/Button_17")
	self:addTouchEventListener(self.drawBtn,self.drawEveryDayRewards) --抽奖
	-- local closeAllBtn = self:getChildByName("Panel_1/closeAllBtn")
	-- self:addTouchEventListener(closeAllBtn,self.closeTigerMachinePanel)  --关闭
end

function TigerMachinePanel:drawEveryDayRewards(sender)
	local data = {}
	data.type = 1
	self:dispatchEvent(TigerMachineEvent.SHOW_ALL_PANEL_EVENT_REQ,data) --抽奖
	self.listView3:scrollToPercentVertical(200,1.5,true)
	self.listView2:scrollToPercentVertical(100,1,true)
	self.listView1:scrollToPercentVertical(100,0.5,true)
	local roleProxy = self:getProxy(GameProxys.Role) 
	roleProxy:setTigerMachinePoint()
end

function TigerMachinePanel:closeTigerMachinePanel(sender) --关闭
	self:dispatchEvent(TigerMachineEvent.HIDE_SELF_EVENT)
end

