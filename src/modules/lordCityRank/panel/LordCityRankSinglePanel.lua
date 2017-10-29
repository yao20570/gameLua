-- 个人排行
LordCityRankSinglePanel = class("LordCityRankSinglePanel", BasicPanel)
LordCityRankSinglePanel.NAME = "LordCityRankSinglePanel"

function LordCityRankSinglePanel:ctor(view, panelName)
    LordCityRankSinglePanel.super.ctor(self, view, panelName)

end

function LordCityRankSinglePanel:finalize()
    LordCityRankSinglePanel.super.finalize(self)
end

function LordCityRankSinglePanel:initPanel()
	LordCityRankSinglePanel.super.initPanel(self)
	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
end

function LordCityRankSinglePanel:registerEvents()
	LordCityRankSinglePanel.super.registerEvents(self)
	local listView = self:getChildByName("listView")
	local panel = listView:getItem(0)
	panel:setVisible(false)
	self._listView = listView

	local fightCapLabel = self:getChildByName("topPanel/fightCapLabel")
	fightCapLabel:setString(self:getTextWord(371005))
	
	self._legionBtn = self:getChildByName("topPanel/legionBtn")
	self._singleBtn = self:getChildByName("topPanel/singleBtn")	
	self:updateBtnState(1)
	
	self:addTouchEventListener(self._legionBtn, self.onLegionBtnTouch)
	self:addTouchEventListener(self._singleBtn, self.onSingleBtnTouch)
		
end

function LordCityRankSinglePanel:updateBtnState(which)
	local urlNor = "images/newGui2/BtnTab_normal.png"
	local urlDown = "images/newGui2/BtnTab_selected.png"

	if which then
		self._curType = which

		if which == 1 then  --选中军团排行按钮
			self._legionBtn:loadTextureNormal(urlDown, ccui.TextureResType.plistType)
			self._singleBtn:loadTextureNormal(urlNor, ccui.TextureResType.plistType)
		elseif which == 2 then  --选中个人排行按钮
			self._legionBtn:loadTextureNormal(urlNor, ccui.TextureResType.plistType)
			self._singleBtn:loadTextureNormal(urlDown, ccui.TextureResType.plistType)
		end
	end

end

function LordCityRankSinglePanel:onLegionBtnTouch(sender)
	-- 军团成员排行
	local cityId = self._lordCityProxy:getSelectCityId()
	local data = {cityId = cityId}
	self._lordCityProxy:onTriggerNet360034Req(data)

	self:updateBtnState(1)
end

function LordCityRankSinglePanel:onSingleBtnTouch(sender)
	-- 个人排行
	local cityId = self._lordCityProxy:getSelectCityId()
	local data = {cityId = cityId}
	self._lordCityProxy:onTriggerNet360032Req(data)

	self:updateBtnState(2)
end

function LordCityRankSinglePanel:doLayout()
	local topPanel = self:getChildByName("topPanel")
	local tabsPanel = self:getTabsPanel()
	NodeUtils:adaptiveTopPanelAndListView(topPanel,self._listView,GlobalConfig.downHeight,tabsPanel)
end

function LordCityRankSinglePanel:onAfterActionHandler()
	self:onShowHandler()
end

function LordCityRankSinglePanel:onShowHandler()
	self:updateBtnState(1)
	if self:isModuleRunAction() == true then
		return
	end

	local cityId = self._lordCityProxy:getSelectCityId()
	local data = {cityId = cityId}
	-- self._lordCityProxy:onTriggerNet360032Req(data)
	self._lordCityProxy:onTriggerNet360034Req(data)
end

-- 协议更新
function LordCityRankSinglePanel:onSingleRankMapUpdate(data)
	if self._listView then
		self._listView:jumpToTop()
		
		local rankMap = {}
		if self._curType == 1 then
			rankMap = self._lordCityProxy:getMemberDamageRankMap()
		elseif self._curType == 2 then
			rankMap = self._lordCityProxy:getPlayerDamageRankMap()
		end
		-- print("......... 表长度 ",#rankMap,table.size(rankMap))

		self:renderListView(self._listView,rankMap,self,self.renderItem, false, false, 0)
        
        local posY = self:getChildByName("topPanel/bgImg"):getPositionY()
        local num = #rankMap
        local offsetHeight = num * 60
        local listHeight = self._listView:getContentSize().height
        if offsetHeight > listHeight then
            offsetHeight = listHeight 
        end
        self:getChildByName("topPanel/imgBottomLine"):setPositionY(posY - offsetHeight - 21)
	end
end

function LordCityRankSinglePanel:renderItem(itemPanel,info)
	if itemPanel == nil or info == nil then
		return
	end
	itemPanel:setVisible(true)

	local name = rawget(info,"name") or ""
	local level = rawget(info,"level") or 0

	local itemBgImg = itemPanel:getChildByName("bgImg")
	local rankTxt = itemPanel:getChildByName("rankTxt")
	local nameTxt = itemPanel:getChildByName("nameTxt")
	local lvTxt = itemPanel:getChildByName("lvTxt")
	local countTxt = itemPanel:getChildByName("countTxt")  --战斗次数
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

	nameTxt:setString(name)
	lvTxt:setString(level)
	countTxt:setString(info.times)
	fightCapTxt:setString(info.score)

end

function LordCityRankSinglePanel:onClosePanelHandler()
	self:updateBtnState(1)
end



