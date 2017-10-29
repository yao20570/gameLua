-- 军团排行
LordCityRankLegionPanel = class("LordCityRankLegionPanel", BasicPanel)
LordCityRankLegionPanel.NAME = "LordCityRankLegionPanel"

function LordCityRankLegionPanel:ctor(view, panelName)
    LordCityRankLegionPanel.super.ctor(self, view, panelName)

end

function LordCityRankLegionPanel:finalize()
    LordCityRankLegionPanel.super.finalize(self)
end

function LordCityRankLegionPanel:initPanel()
	LordCityRankLegionPanel.super.initPanel(self)
	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
end

function LordCityRankLegionPanel:registerEvents()
	LordCityRankLegionPanel.super.registerEvents(self)
	local listView = self:getChildByName("listView")
	local panel = listView:getItem(0)
	panel:setVisible(false)
	self._listView = listView

	local fightCapLabel = self:getChildByName("topPanel/fightCapLabel")
	fightCapLabel:setString(self:getTextWord(371005))

	local rewardBtn = self:getChildByName("downPanel/rewardBtn")
	self:addTouchEventListener(rewardBtn, self.onRewardBtnTouch)
end

-- 奖励预览
function LordCityRankLegionPanel:onRewardBtnTouch(sender)
	local panel = self:getPanel(LordCityRankRewardPrePanel.NAME)
	panel:show()
end

function LordCityRankLegionPanel:doLayout()
	local topPanel = self:getChildByName("topPanel")
	local downPanel = self:getChildByName("downPanel")
	local tabsPanel = self:getTabsPanel()
	NodeUtils:adaptiveTopPanelAndListView(topPanel, self._listView, downPanel, tabsPanel)
end

function LordCityRankLegionPanel:onAfterActionHandler()
	self:onShowHandler()
end

function LordCityRankLegionPanel:onShowHandler()
	if self:isModuleRunAction() == true then
		return
	end

	local cityId = self._lordCityProxy:getSelectCityId()
	local data = {cityId = cityId}
	self._lordCityProxy:onTriggerNet360033Req(data)
end

-- 协议更新
function LordCityRankLegionPanel:onLegionRankMapUpdate(data)
	if self._listView then
		self._listView:jumpToTop()
		
		local rankMap = self._lordCityProxy:getLegionDamageRankMap()
		self:renderListView(self._listView,rankMap,self,self.renderItem, false, false, 0)
        
        local posY = self:getChildByName("topPanel/Image_25"):getPositionY()
        local num = #rankMap
        local offsetHeight = num * 60
        local listHeight = self._listView:getContentSize().height
        if offsetHeight > listHeight then
            offsetHeight = listHeight 
        end
        self:getChildByName("topPanel/imgBottomLine"):setPositionY(posY - offsetHeight - 21)
	end
end

function LordCityRankLegionPanel:renderItem(itemPanel,info)
	if itemPanel == nil or info == nil then
		return
	end
	itemPanel:setVisible(true)
	
	-- print(".............. 军团排行  ",info.rank,info.name)
	local level = rawget(info,"level") or 0

	local itemBgImg = itemPanel:getChildByName("bgImg")
	local rankTxt = itemPanel:getChildByName("rankTxt")
	local nameTxt = itemPanel:getChildByName("nameTxt")
	local lvTxt = itemPanel:getChildByName("lvTxt")
	local countTxt = itemPanel:getChildByName("countTxt")
	local fightCapTxt = itemPanel:getChildByName("fightCapTxt")  --战力/积分
    local rankImg = itemPanel:getChildByName("imgRank")
    rankImg:setVisible(false)
    
	local rank = info.rank
    if rank < 4 then 
        rankImg:setVisible(true)
	    TextureManager:updateImageView(rankImg, "images/newGui2/IconNum_" .. rank .. ".png")
    end
    if rank%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end
    
	rankTxt:setString(rank)
	nameTxt:setString(info.name)
	lvTxt:setString(level)
	countTxt:setString(info.times)
	fightCapTxt:setString(info.score)

end




