--
-- Author: zlf
-- Date: 2016年8月5日15:23:42
-- 活动通用排行榜界面

ActivityRankPanel = class("ActivityRankPanel", BasicPanel)
ActivityRankPanel.NAME = "ActivityRankPanel"

function ActivityRankPanel:ctor(view, panelName)
    ActivityRankPanel.super.ctor(self, view, panelName, true)
end

function ActivityRankPanel:finalize()
    ActivityRankPanel.super.finalize(self)
end

function ActivityRankPanel:initPanel()
	ActivityRankPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self.ListView_rank = self:getChildByName("Panel_1/ListView_rank")

	local item = self.ListView_rank:getItem(0)
    self.ListView_rank:setItemModel(item)

    local roleProxy = self:getProxy(GameProxys.Role)
	self.myName = roleProxy:getRoleName()

	self.MyRank = self:getChildByName("Panel_1/Panel_top/rank")
	self.MyValue = self:getChildByName("Panel_1/Panel_top/value")

	self.proxy = self:getProxy(GameProxys.Activity)
end

function ActivityRankPanel:doLayout()
	local Panel_title = self:getChildByName("Panel_1/Panel_title")
	NodeUtils:adaptiveListView(self.ListView_rank, 40, Panel_title)
end

function ActivityRankPanel:registerEvents()
	ActivityRankPanel.super.registerEvents(self)
end

function ActivityRankPanel:onClosePanelHandler()
	self.view:dispatchEvent(ActivityRankEvent.HIDE_SELF_EVENT)
end

function ActivityRankPanel:onShowHandler()
	local id = self.proxy.curActivityId
	self.proxy:onTriggerNet230019Req({activityid = id})
end

function ActivityRankPanel:updateView(data)
	if data.myRankInfo ~= nil then
		self.MyRank:setString(data.myRankInfo.rank <= 0 and TextWords:getTextWord(1701) or data.myRankInfo.rank)
		self.MyValue:setString(data.myRankInfo.rankValue)
	else
		self.MyRank:setString("未上榜")
		self.MyValue:setString(0)
	end
	self:renderListView(self.ListView_rank, data.activityRankInfos, self, self.renderItem)
end

function ActivityRankPanel:renderItem(item, info, index)
	local Label_rankumber = item:getChildByName("Label_rankumber")
	local Label_lv = item:getChildByName("Label_lv")
	local Label_name = item:getChildByName("Label_name")
	local lineImg = item:getChildByName("Image_line")
	lineImg:setVisible(index%2 == 0)

	Label_rankumber:setString(info.rank)
	Label_lv:setString(info.rankValue)
	Label_name:setString(info.name)
	local imgSelf = item:getChildByName("ImgSelf")
	imgSelf:setVisible(self.myName == info.name)

	-- item.info = info
	-- item.index = index
	-- item:addTouchEventListener(function(sender, eventType)
	-- 	self:onRankBtn(sender, eventType)
	-- end)
end

-- function ActivityRankPanel:onRankBtn(sender, eventType)
-- 	local info = sender.info
-- 	local lineImg = sender:getChildByName("Image_line")
-- 	if eventType == ccui.TouchEventType.ended then
-- 		print("info.type===",info.type)
-- 		if info.type == 1 then
-- 			self:onPlayerInfoReq(info.id)
-- 		else
-- 			self:onLegionInfoReq(info)
-- 		end
-- 		TextureManager:updateImageView(lineImg, "images/guiNew/item_bivision.png")
-- 		lineImg:setVisible(sender.index%2 == 0)
--     elseif eventType == ccui.TouchEventType.began then
--     	lineImg:setVisible(true)
--     	TextureManager:updateImageView(lineImg, "images/guiNew/item_bivision_select.png")
--     elseif eventType == ccui.TouchEventType.canceled then
--     	TextureManager:updateImageView(lineImg, "images/guiNew/item_bivision.png")
-- 		lineImg:setVisible(sender.index%2 == 0)
--     end
-- end

-- function ActivityRankPanel:onPlayerInfoResp(data)
--     if self._watchPlayInfoPanel == nil then
--         self._watchPlayInfoPanel = UIWatchPlayerInfo.new(self:getParent(), self, false, true)
--     end
--     self._watchPlayInfoPanel:showAllInfo(data)
-- end

-- function ActivityRankPanel:onPlayerInfoReq(playerId)
-- 	if StringUtils:isFixed64Minus(playerId) == true then
-- 		return
-- 	end
--     local chatProxy = self:getProxy(GameProxys.Chat)
--     chatProxy:watchPlayerInfoReq({playerId = playerId})
-- end

-- function ActivityRankPanel:onLegionInfoReq(info)
-- 	self.curLegInfo = info
-- 	local legionProxy = self:getProxy(GameProxys.Legion)
--     legionProxy:onTriggerNet220101Req({id = info.id})
-- end

-- function ActivityRankPanel:showInfoPanel(data)
-- 	local panel = self:getPanel(ActivityInfoPanel.NAME)
-- 	panel:show(data)
-- end