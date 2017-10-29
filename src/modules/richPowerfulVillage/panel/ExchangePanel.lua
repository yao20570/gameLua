-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
ExchangePanel = class("ExchangePanel", BasicPanel)
ExchangePanel.NAME = "ExchangePanel"

function ExchangePanel:ctor(view, panelName)
    ExchangePanel.super.ctor(self, view, panelName)
    self.activityId = nil
    self.activityInfo = nil
end

function ExchangePanel:finalize()
	self.activityId = nil
	self.activityInfo = nil
    ExchangePanel.super.finalize(self)
end

function ExchangePanel:initPanel()
	ExchangePanel.super.initPanel(self)

	self._mainPanel = self:getChildByName("mainPanel")
	self.valuePanel = self._mainPanel:getChildByName("myValuePanel")
	self.listView = self._mainPanel:getChildByName("ListView")
end

function ExchangePanel:registerEvents()
	ExchangePanel.super.registerEvents(self)
end

function ExchangePanel:onShowHandler()
	local function callback(activityId)
		self.activityId = activityId
	end
	self:dispatchEvent(RichPowerfulVillageEvent.GET_CURRENT_OPEN_ACTIVITY,{callback = callback})

	local activityProxy = self:getProxy(GameProxys.Activity)
	local activityInfo = activityProxy:getLimitActivityInfoById(self.activityId) --活动信息
	self.activityInfo = activityInfo

	self:updateListView()
	self:updateItemNum()
end

function ExchangePanel:updateListView()
	local changeItemList = {}
	if self.activityInfo then
		local effectId = self.activityInfo.effectId
		local activityProxy = self:getProxy(GameProxys.Activity)
		local exchangeInfo = activityProxy:getItemExchangeInfoBy(self.activityId) --富贵豪庄信息

		local richManorInfo = ConfigDataManager:getRichManorInfo(effectId)
		if richManorInfo then
			local exchangeID = richManorInfo.exchangeID
			local changeList = ConfigDataManager:getRichManorChangeInfo(exchangeID)

			--整理数据
			for k,v in pairs(changeList) do
				-- local limitTimes = v.exchangeLimit
				-- if exchangeInfo[v.ID] and v.isTimeLimit then
				-- 	limitTimes = limitTimes - exchangeInfo[v.ID].times --配置的兑换限制次数 - 已经兑换的次数
				-- end
				-- if limitTimes > 0 then
					if exchangeInfo[v.ID] then
						v.changeTimes = exchangeInfo[v.ID].times
					else
						v.changeTimes = 0
					end 
					table.insert(changeItemList,v)
				-- end 
			end 
		end 
	end
	self:renderListView(self.listView, changeItemList, self, self.renderListItem)
end

function ExchangePanel:renderListItem(item, data)
	local itemBtn = item:getChildByName("itemBtn")
	local iconImg = itemBtn:getChildByName("iconImg")
	local itemNameLab = itemBtn:getChildByName("itemNameLab")
	local itemDesLab = itemBtn:getChildByName("itemDesLab")
	local exchangeBtn = itemBtn:getChildByName("exchangeBtn")

	local needLab = itemBtn:getChildByName("needLab")
	local needValueLab = itemBtn:getChildByName("needValueLab")

	local Lab_0 = itemBtn:getChildByName("Lab_0")
	local Lab_1 = itemBtn:getChildByName("Lab_1")
	local Lab_2 = itemBtn:getChildByName("Lab_2")

	local item = StringUtils:jsonDecode(data.item)
	local exchangeLimit = data.exchangeLimit

	local uiIcon = iconImg.uiIcon
	local itemInfo = {}
	itemInfo.power = tonumber(item[1][1])
	itemInfo.typeid = tonumber(item[1][2])
	itemInfo.num = tonumber(item[1][3])
	if uiIcon == nil then
		uiIcon = UIIcon.new(iconImg, itemInfo , true,self)
		iconImg.uiIcon = uiIcon
	else
		uiIcon:updateData(itemInfo)
	end
	local itemConfig = ConfigDataManager:getConfigByPowerAndID(itemInfo.power, itemInfo.typeid)
	itemNameLab:setString(itemConfig.name)
	itemNameLab:setColor(ColorUtils:getColorByQuality(itemConfig.color))
	itemDesLab:setString(itemConfig.info)

	local itemCost =  StringUtils:jsonDecode(data.itemCost)
	local itemCostConfig = ConfigDataManager:getConfigByPowerAndID(tonumber(itemCost[1][1]), tonumber(itemCost[1][2]))
	needLab:setString(string.format(TextWords:getTextWord(540037),itemCostConfig.name))
	needValueLab:setString(itemCost[1][3])
	needValueLab:setPositionX(needLab:getPositionX() + needLab:getContentSize().width/2 + 5)
	

	if data.isTimeLimit then
		Lab_1:setString(data.changeTimes)
		Lab_2:setString("/" .. data.exchangeLimit .. ")")
		Lab_0:setPosition(itemNameLab:getPositionX() + itemNameLab:getContentSize().width + 5,itemNameLab:getPositionY() + 4)
		Lab_1:setPosition(Lab_0:getPositionX() + Lab_0:getContentSize().width + 3,Lab_0:getPositionY())
		Lab_2:setPosition(Lab_1:getPositionX() + Lab_1:getContentSize().width + 3,Lab_0:getPositionY())
	else
		Lab_0:setVisible(false)
		Lab_1:setVisible(false)
		Lab_2:setVisible(false)
	end 

	exchangeBtn.activityId = self.activityId
	exchangeBtn.data = data
	exchangeBtn.number = itemCost[1][3]
	self:addTouchEventListener(exchangeBtn, self.exchangeBtn)
end

function ExchangePanel:exchangeBtn(sender)
	if sender.data.isTimeLimit and ((sender.data.exchangeLimit - sender.data.changeTimes) <= 0) then
		self:showSysMessage(TextWords:getTextWord(460007))
	else
		-- local messageBox = self:showMessageBox(string.format(TextWords:getTextWord(460013),sender.number),function() 
		-- 						self:exchange(sender)
		-- 					end)

		--注意:需要考虑到是否买超出了范围
		local data = sender.data
        local itemCost = StringUtils:jsonDecode(data.itemCost)
        local itemCostData = {
        	power = itemCost[1][1],
        	typeid = itemCost[1][2],
        	num = itemCost[1][3]
    	}
        local item = StringUtils:jsonDecode(data.item)
        local itemData = {
        	power = item[1][1],
        	typeid = item[1][2],
        	num = item[1][3]
    	}
		local number = sender.number
	    local panel = self:getPanel(BuyPanel.NAME)

		local isTimeLimit = data.isTimeLimit
		local changeTimes = data.changeTimes
		local exchangeLimit = data.exchangeLimit
	    panel:show({
	    	itemCostData = itemCostData,--单价
	    	itemData = itemData,--物品数据
	    	iHaveNum = self._iHaveItemNum,
	    	activityId = sender.activityId,--协议使用
	    	ID = data.ID,--协议使用
	    	isTimeLimit = isTimeLimit,--是否限制购买
	    	maxBuyNum = exchangeLimit - changeTimes,--限制最大购买次数
	    	btnBuyCallback = function(num)
	    		if isTimeLimit then
	    			if num > exchangeLimit - changeTimes then
	    				--超出了上限
						self:showSysMessage(TextWords:getTextWord(540057))
	    			else
	    				self:exchange(sender.activityId,sender.data.ID,num)
	    			end
	    		else
	    			self:exchange(sender.activityId,sender.data.ID,num)
	    		end
	    	end,
	    })
	end 
end

function ExchangePanel:exchange(activityId,id,num)
	local data = {}
	data.activityId = activityId
	data.id = id
	data.num = num
	self:dispatchEvent(RichPowerfulVillageEvent.EXCHANGE_ITEM_REQ,data)
end

--更新彩豆数量
function ExchangePanel:updateItemNum()
	if self.activityInfo then 
		local effectId = self.activityInfo.effectId
		local richManorInfo = ConfigDataManager:getRichManorInfo(effectId)
		if richManorInfo then
			local rewardInfo = ConfigDataManager:getRichManorRewardInfo(richManorInfo.rewardGroup,1)
			local rewardItem = StringUtils:jsonDecode(rewardInfo.reward)

			local itemId = tonumber(rewardItem[1][2])

			local itemConfig = ConfigDataManager:getConfigById(ConfigData.ItemConfig,itemId)

			local myValueLab = self.valuePanel:getChildByName("myValueLab")
			local myValueDesLab = self.valuePanel:getChildByName("myValueDesLab")
			local bg = self.valuePanel:getChildByName("bg")
			local itemIcon_ex = self.valuePanel:getChildByName("itemIcon")
			--从背包中拿物品数量
			local itemProxy = self:getProxy(GameProxys.Item)
			local itemNum = itemProxy:getItemNumByType(itemId)
			-- myValueLab:setString(itemNum)
			-- myValueDesLab:setString(itemConfig.name .. " ")
			-- myValueDesLab:setPositionX(myValueLab:getPositionX() - myValueLab:getContentSize().width)
			-- bg:setContentSize(myValueLab:getContentSize().width + myValueDesLab:getContentSize().width + 20,27)

			self._iHaveItemNum = itemNum

			myValueLab:setString(itemNum)
			myValueDesLab:setString(itemConfig.name .. " ")
			local url = "images/richPowerfulVillage/" .. tostring(itemConfig.icon) ..".png"
			TextureManager:updateImageView(itemIcon_ex,url)
			itemIcon_ex:setPositionX(myValueLab:getPositionX() - myValueLab:getContentSize().width - itemIcon_ex:getContentSize().width/2 - 5)
			myValueDesLab:setPositionX(itemIcon_ex:getPositionX() - itemIcon_ex:getContentSize().width/2)
			bg:setContentSize(myValueLab:getContentSize().width + myValueDesLab:getContentSize().width + 30 + itemIcon_ex:getContentSize().width,27)
		end
	end
end

function ExchangePanel:exchangeItemResp(param)
	self:updateListView()
end

function ExchangePanel:doLayout()
	local tabsPanel = self:getTabsPanel()
	NodeUtils:adaptive(self.listView)
    -- NodeUtils:adaptiveUpPanel(self.listView,tabsPanel,10)
    NodeUtils:adaptiveDownPanel(self.listView,nil,0)
end 