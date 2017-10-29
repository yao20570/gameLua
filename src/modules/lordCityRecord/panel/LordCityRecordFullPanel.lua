-- 全服战报
LordCityRecordFullPanel = class("LordCityRecordFullPanel", BasicPanel)
LordCityRecordFullPanel.NAME = "LordCityRecordFullPanel"

function LordCityRecordFullPanel:ctor(view, panelName)
    LordCityRecordFullPanel.super.ctor(self, view, panelName)

end

function LordCityRecordFullPanel:finalize()
    LordCityRecordFullPanel.super.finalize(self)
end

function LordCityRecordFullPanel:initPanel()
	LordCityRecordFullPanel.super.initPanel(self)
	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
end

function LordCityRecordFullPanel:registerEvents()
	LordCityRecordFullPanel.super.registerEvents(self)
	local listView = self:getChildByName("listView")
	local panel = listView:getItem(0)
	panel:setVisible(false)
	self._listView = listView
end

function LordCityRecordFullPanel:doLayout()
	local topPanel = self:getChildByName("topPanel")
	local tabsPanel = self:getTabsPanel()
	NodeUtils:adaptiveTopPanelAndListView(topPanel,self._listView,GlobalConfig.downHeight,tabsPanel)
end

function LordCityRecordFullPanel:onAfterActionHandler()
	self:onShowHandler()
end

function LordCityRecordFullPanel:onShowHandler()
	if self:isModuleRunAction() == true then
		return
	end

	local cityId = self._lordCityProxy:getSelectCityId()
	local data = {cityId = cityId}
	self._lordCityProxy:onTriggerNet360026Req(data)
end

function LordCityRecordFullPanel:onFullRecordMapUpdate(data)
	if self._listView then
		self._listView:jumpToTop()
		
		local rankMap = self._lordCityProxy:getFullCityReportMap()
		table.sort( rankMap, function(a,b) return a.time > b.time end )
		self:renderListView(self._listView,rankMap,self,self.renderItem, false, false, 0)
	end
end

function LordCityRecordFullPanel:renderItem(itemPanel,info, index)
	if itemPanel == nil or info == nil then
		return
	end
	itemPanel:setVisible(true)

	-- print(".............. 全服战报  ",info.time,info.attackerName,info.result)

	local timeTxt = itemPanel:getChildByName("timeTxt")
	local nameLTxt = itemPanel:getChildByName("nameLTxt")
	local nameRTxt = itemPanel:getChildByName("nameRTxt")
	local legionNameLTxt = itemPanel:getChildByName("legionNameLTxt")
	local legionNameRTxt = itemPanel:getChildByName("legionNameRTxt")
	local resultImg = itemPanel:getChildByName("resultImg")  --战斗结果
	local replayBtn = itemPanel:getChildByName("replayBtn")  --回看战斗按钮
	local itemBgImg = itemPanel:getChildByName("bgImg")

    
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end


	timeTxt:setString(TimeUtils:setTimestampToString5(info.time))
	nameLTxt:setString(info.attackerName)
	legionNameLTxt:setString(info.attackerLegionName)

	if info.type == 1 then 						--//战报类型1：BOSS
		legionNameRTxt:setString(info.defenderLegionName)
		nameRTxt:setString(info.defenderName)
	elseif info.type == 2 then  				--//战报类型 2：守军
		legionNameRTxt:setString(info.defenderLegionName)
		nameRTxt:setString(info.defenderName)
	else  										--//战报类型 3:城墙
		legionNameRTxt:setString(info.defenderLegionName)	
		nameRTxt:setString(info.defenderName)
	end


	local url = "images/component/win.png"
	if info.result == 1 then  --（1：进攻方失败 0:进攻方胜利）
		url = "images/component/fail.png"
	end
	TextureManager:updateImageView(resultImg, url)

	replayBtn.info = info
	if replayBtn.addEvent == nil then
		replayBtn.addEvent = true
		self:addTouchEventListener(replayBtn, self.onReplayBtnTouch)
	end
end

function LordCityRecordFullPanel:onReplayBtnTouch(sender)
	local data = {battleId = sender.info.battleId}
	self._lordCityProxy:onTriggerNet160005Req(data)
end


