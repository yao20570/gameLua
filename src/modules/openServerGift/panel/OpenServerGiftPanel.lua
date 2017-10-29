
OpenServerGiftPanel = class("OpenServerGiftPanel", BasicPanel)
OpenServerGiftPanel.NAME = "OpenServerGiftPanel"

function OpenServerGiftPanel:ctor(view, panelName)
    OpenServerGiftPanel.super.ctor(self, view, panelName,true)
    self.canReceiveDays = 0  --可领取的总天数
    self.infos = {}
end

function OpenServerGiftPanel:finalize()
    OpenServerGiftPanel.super.finalize(self)
end

function OpenServerGiftPanel:initPanel()
	OpenServerGiftPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true, "serverGift", true)
	self.listView = self:getChildByName("ListView")
	local item = self.listView:getItem(0)
	item:setVisible(false)
	
	-- NodeUtils:adaptive(self.listView)

	

	self.infos = ConfigDataManager:getConfigData(ConfigData.DayLandConfig)
	
    local proxy = self:getProxy(GameProxys.Role)
    local itemList = proxy:getOpenServerList()
    local data = proxy:getOpenServerData()
    self.canReceiveDays = data.allDay
    -- ComponentUtils:renderTableView(self.listView, itemList, self, self.renderItemPanel)
end

function OpenServerGiftPanel:doLayout()
	local topPanel = self:topAdaptivePanel()
	NodeUtils:adaptiveListView(self.listView, GlobalConfig.downHeight, topPanel)
end

function OpenServerGiftPanel:onShowHandler(sender)

    if self:isModuleRunAction() then
        return
    end

	self:updateOpenServerView()
--	self:jumpToWantPoint()
	-- TimerManager:addOnce(100, self.jumpToWantPoint, self)
	self:jumpToWantPoint()
	
end

function OpenServerGiftPanel:onAfterActionHandler()
	self:onShowHandler()
end

function OpenServerGiftPanel:jumpToWantPoint()
	-- local percent = self.canReceiveDays/30 * 100 - 7
	-- if percent <= 0 then
	-- 	self.listView:jumpToTop()
	-- 	return 
	-- end
	-- self.listView:scrollToPercentVertical(percent,0.5,true)
    --TODO 需要封装方法
    local proxy = self:getProxy(GameProxys.Role)
    local data = proxy:getOpenServerData()
    self.canReceiveDays = data.allDay
    self.listView.expandTableView:jumpToIndex(self.canReceiveDays - 1)
end
function OpenServerGiftPanel:updateOpenServerView()
	local proxy = self:getProxy(GameProxys.Role)
    local data = proxy:getOpenServerData()
    if data.canGet == nil then --预加载的时候，可能协议还没有收到，容错
        return
    end
    if self.getBtn then
    	self.getBtn:setVisible(false)
    end
    local isNotUpdate = true
    
    if self.canReceiveDays ~= data.allDay then
        isNotUpdate = false
    end
	self.canReceiveDays = data.allDay
	
    local itemList = proxy:getOpenServerList()
    -- self:renderListView(self.listView, itemList, self, self.renderItemPanel, false, true)
    ComponentUtils:renderTableView(self.listView, itemList, self, self.renderItemPanel, isNotUpdate) --只更新数据，不刷新
end

function OpenServerGiftPanel:renderItemPanel(item, itemInfo, index)
    item:setVisible(true)
	local bgNum = item:getChildByName("Image_14")
	local dayNumTxt = bgNum:getChildByName("txt")
	local receiveBtn = item:getChildByName("Button")
	local haveReceiveBtn = item:getChildByName("haveReceiveBtn")   --已经领取的
	local receiveTxt = haveReceiveBtn:getChildByName("Label_15")   --已经领取的文本
	local container = {}
	local text = {}
	for i=1,4 do
		container[i] = item:getChildByName("Panel_"..i)
		text[i] = item:getChildByName("text_"..i)
		text[i]:setVisible(false)
		local icon = container[i].icon
        if icon ~= nil then
            icon:setVisible(false)
        end
	end
	local str = string.format(self:getTextWord(2101),index+1)  
	dayNumTxt:setString(str)
	receiveBtn:setVisible(itemInfo.state == 2)
	if itemInfo.state == 0 then
		receiveTxt:setString(self:getTextWord(1112))
	elseif itemInfo.state == 1 then
		receiveTxt:setString(self:getTextWord(1111))
	end
	local tmp = self.infos[index+1].rewardId
	local data = StringUtils:jsonDecode(tmp)
	for k,v in pairs(data) do
		local last_data = ConfigDataManager:getRewardConfigById(v)--{}
		-- local tmpData = ConfigDataManager:getConfigById(ConfigData.FixRewardConfig,v)
		-- local lastData = ConfigDataManager:getConfigByPowerAndID(tmpData.type,tmpData.contentID)
		-- last_data.num = container[k].data.num
  --       last_data.typeid = tmpData.contentID
		-- last_data.power = container[k].data.type
		local icon = container[k].icon
 		if icon == nil then
 		    icon = UIIcon.new(container[k], last_data, true, self)
 		    container[k].icon = icon
 		else
		    icon:updateData(last_data)
            icon:setVisible(true)
 		end
 	    text[k]:setString(last_data.name)
 	    -- text[k]:setVisible(true) --隐藏icon标题
 		if last_data.quality then
 	   		text[k]:setColor(ColorUtils:getColorByQuality(last_data.quality))
 	   	else
 	   	   	text[k]:setColor(ColorUtils:getColorByQuality(last_data.color))
   	    end
	end
	receiveBtn.index = index+1
	receiveBtn.receiveTxt = receiveTxt
	self:addTouchEventListener(receiveBtn,self.receiveGift)
end

function OpenServerGiftPanel:receiveGift(sender)
	local data = {}
    data.dayNum = sender.index
	self:dispatchEvent(OpenServerGiftEvent.SHOW_ALLVIEW_EVENT_REQ,data) --请求面板
	sender.receiveTxt:setString(self:getTextWord(1112))
	self.getBtn = sender
end

function OpenServerGiftPanel:onClosePanelHandler()
    self:dispatchEvent(OpenServerGiftEvent.HIDE_SELF_EVENT)
end

