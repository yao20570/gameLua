-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-04-25 11:31:12
--  * @Description: 排行榜
--  */
RankPanel = class("RankPanel", BasicPanel)
RankPanel.NAME = "RankPanel"

function RankPanel:ctor(view, panelName)
    RankPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function RankPanel:finalize()
	if self._watchPlayInfoPanel ~= nil then
		self._watchPlayInfoPanel:finalize()
	end
	self._watchPlayInfoPanel = nil
    RankPanel.super.finalize(self)
end

function RankPanel:initPanel()
	RankPanel.super.initPanel(self)
	self:setTitle(true,"rank",true)
	self:setBgType(ModulePanelBgType.NONE)


	self._topTitleTab, self._rankTitleTab = self:initTabData()
	self._rankProxy = self:getProxy(GameProxys.Rank)

	self.ListView_btn = self:getChildByName("ListView_btn")
	--self.ListView_rank = self:getChildByName("ListView_rank")
    self._svRank = self:getChildByName("svRank")

	
	local roleProxy = self:getProxy(GameProxys.Role)
	self.MyName = roleProxy:getRoleName()
end

function RankPanel:doLayout()
	local bestTopPanel = self:topAdaptivePanel()
	local bgImg = self._uiPanelBg._bgImgR
	NodeUtils:adaptivePanelBg(bgImg, GlobalConfig.downHeight, bestTopPanel)

	local Panel_top = self:getChildByName("emptyPanel")
	NodeUtils:adaptiveListView(self.ListView_btn, GlobalConfig.downHeight, bestTopPanel, 180)

	local Panel_title = self:getChildByName("Panel_title")
    local titileBg = self:getChildByName("Panel_title/imgTopBg1")
	local bottomPanel = self:getChildByName("BottomPanel")
	--NodeUtils:adaptiveListView(self.ListView_rank,GlobalConfig.downHeight + 5,titileBg, 25)
    NodeUtils:adaptiveListView(self._svRank,bottomPanel,titileBg, 20)

    self:createScrollViewItemUIForDoLayout(self._svRank)
    --重置地图大小和位置
    local imgListBg = self:getChildByName("Panel_title/imgListBg")
    local listHeight = self._svRank:getContentSize().height
    imgListBg:setContentSize(imgListBg:getContentSize().width, listHeight)
    imgListBg:setPositionY(titileBg:getPositionY() - (titileBg:getContentSize().height + listHeight) * 0.5)
end

-- 关闭排行榜
function RankPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

-- 数据排序
function RankPanel:onSort()
	-- body
end

function RankPanel:initTabData()
	-- body
	local topTitleTab = {
		{1915,1916},
		{1917,1918},
		{1915,1919},
		{1915,1920},
		{1921,1922},
		{1921,1923},
		{1921,1924},
		{1915,1925},
		{1915,1926},
		{1915,1926},
		{1915,1937},
		{1915,1937},
		{1915,1939},
	}

	local rankTitleTab = {
		{1915,1916},
		{1917,1918},
		{1915,1919},
		{1915,1920},
		{1921,1922},
		{1921,1923},
		{1921,1924},
		{1915,1925},
		{1915,1926},
		{1915,1926},
		{1915,1937},
		{1915,1937},
		{1940,1939},
	}

	return topTitleTab,rankTitleTab
end


function RankPanel:getPlayerData(typeId)
	-- body
   	local tabData = self._rankProxy:getPlayerData(typeId)
	return tabData
end

function RankPanel:getRankData(typeId)
	-- body
   	local tabData = self._rankProxy:getRankList(typeId)
	return tabData
end

-- 打开排行榜
function RankPanel:onShowHandler()
	-- body
	self._typeId = 1
    self._rankProxy:onTriggerNet210000Req({typeId = 1})

	-- self:onRenderHandler(self._typeId)
	self:renderTileInfo(self._typeId)
end

--动画结束后
function RankPanel:onAfterActionHandler()
    self:renderRankListInfo(self._typeId)
end

function RankPanel:jumpToTop()
	--self.ListView_rank:scrollToTop(0.1, true)
	-- body
end
-- 分类排行榜
function RankPanel:onRenderHandler(typeId)
	-- if self.ListView_rank then
	-- 	self.ListView_rank:jumpToPercentVertical(0.1)
	-- 	TimerManager:addOnce(100, self.jumpToTop, self)
	-- end

	-- body

	--self.ListView_rank:setVisible(typeId ~= -1)
    self._svRank:setVisible(typeId ~= -1)

	local Panel_title = self:getChildByName("Panel_title")
	Panel_title:setVisible(typeId ~= -1)
	local Panel_top = self:getChildByName("Panel_top")
	Panel_top:setVisible(typeId ~= -1)
	local panel = self:getPanel(RankResPanel.NAME)
	if typeId ~= -1 then
		self:renderTileInfo(typeId)
		self:renderRankListInfo(typeId)
		panel:hide()
	else
		self:onRankBtnList()
		panel:show()
	end
	
end

function RankPanel:renderTileInfo(typeId)
    local playerData = self:getPlayerData(typeId)
	local rankData = self:getRankData(typeId)
	self:onRankTitle(typeId)            --标题
	self:onRankBtnList()                --按钮列表		
	self:onTopPanel(playerData, typeId) --玩家信息
end

function RankPanel:renderRankListInfo(typeId)
    local rankData = self:getRankData(typeId)
    self:onRankList(rankData)           --排行列表
end

function RankPanel:onTopPanel(data, typeId)
	-- body
	local Panel_top = self:getChildByName("Panel_top")
	-- local Label_title = Panel_top:getChildByName("Label_title")

	local Rank1 = Panel_top:getChildByName("Rank1")
	local Rank2 = Panel_top:getChildByName("Rank2")
	local Rank3 = Panel_top:getChildByName("Rank3")
	local rank = Panel_top:getChildByName("rank")
	local lv = Panel_top:getChildByName("lv")
	local value = Panel_top:getChildByName("value")


	-- local rankTitle = 1927 + typeId
	-- Label_title:setString(self:getTextWord(rankTitle))
	-- Label_title:setColor(ColorUtils.riceColor)
	
	local lvtxt = self._topTitleTab[typeId][1]
	local valuetxt = self._topTitleTab[typeId][2]


	-- print("···RankPanel:onTopPanel(data, typeId)-->",data,typeId)

	local rankNumber = data.rank
	local playerLevel = data.level
	local playerValue = data.rankValue

	if typeId == 1 or typeId == 8 then
		playerValue = StringUtils:formatNumberByK3(playerValue, nil)
	elseif typeId >= 5 and typeId <= 7 then
		playerValue = tostring(playerValue/100).."%"
	end

	if rankNumber <= 0 then
		rank:setString(self:getTextWord(1912))
		rank:setColor(ColorUtils.wordBadColor)
		
		if typeId >=5 and typeId <= 7 then
			Rank2:setVisible(false)
			Rank3:setVisible(false)
			lv:setVisible(false)
			value:setVisible(false)
		else
			Rank2:setVisible(true)
			Rank3:setVisible(true)
			lv:setVisible(true)
			value:setVisible(true)
			Rank2:setString(self:getTextWord(lvtxt)..":")		
			Rank3:setString(self:getTextWord(valuetxt)..":")
		end
	else
		rank:setString(rankNumber)
		rank:setColor(ColorUtils.wordYellowColor01)

		Rank2:setVisible(true)
		Rank3:setVisible(true)
		lv:setVisible(true)
		value:setVisible(true)
		Rank2:setString(self:getTextWord(lvtxt)..":")		
		Rank3:setString(self:getTextWord(valuetxt)..":")
	end
	
	local textId = 560205 --我的排名
	if typeId == 13 then
		Rank2:setVisible(false)
		lv:setVisible(false)
		local myJob = self:getProxy(GameProxys.Legion):getMineJob()
        if myJob ~= 7 then --玩家自己是盟主
            textId = 560204 --我的排名
        end
	end
	Rank1:setString(TextWords:getTextWord(textId))

	lv:setString(playerLevel)
	value:setString(playerValue)

	-- lv:setColor(ColorUtils.wordOrangeColor)
	-- value:setColor(ColorUtils.wordOrangeColor)

end

function RankPanel:onRankTitle(typeId)
	-- body
	local Panel_title = self:getChildByName("Panel_title")
	local Image_rank = Panel_title:getChildByName("Image_rank")
	local Image_name = Panel_title:getChildByName("Image_name")
	local Image_lv = Panel_title:getChildByName("Image_lv")
	local Image_value = Panel_title:getChildByName("Image_value")
	local Label_rank = Image_rank:getChildByName("Label_rank")
	local Label_name = Image_name:getChildByName("Label_name")
	local Label_lv = Image_lv:getChildByName("Label_lv")
	local Label_value = Image_value:getChildByName("Label_value")

	local lv = self._rankTitleTab[typeId][1]
	local value = self._rankTitleTab[typeId][2]

	Label_lv:setString(self:getTextWord(lv))
	Label_value:setString(self:getTextWord(value))
end

function RankPanel:onRankBtnList()
-- 基础值 1950
--    TextWords[1949] = "征矿榜"
--    TextWords[1951] = "战力榜"
--    TextWords[1952] = "编制榜"
--    TextWords[1953] = "关卡榜"
--    TextWords[1954] = "战绩榜"
--    TextWords[1955] = "攻击强化"
--    TextWords[1956] = "暴击强化"
--    TextWords[1957] = "闪避强化"
--    TextWords[1958] = "演武场"
--    TextWords[1959] = "成就榜"
--    TextWords[1962] = "平乱榜"
--    TextWords[1962] = "名师榜"
--    TextWords[1964] = "同盟身价榜"

	local isLock = FunctionShieldConfig:isShield( FunctionShield.THIRD )
	local tabData = nil
	if isLock then
		tabData = {{1},{3},{4},{8},{13}} -- 
	else
		tabData = {{1},{3},{4},{8},{13},{12}} 
	end
	

	local ListView_btn = self.ListView_btn
	self:renderListView(ListView_btn, tabData, self, self.onRenderListBtn, false, true, 2)
end

function RankPanel:onRankList(data)
     self:renderScrollView(self._svRank, "Panel_rank", data, self, self.onRenderListRank, 1)
end


-- 渲染分类按钮列表
function RankPanel:onRenderListBtn(itempanel, info, index)
	-- body
	itempanel:setVisible(true)

	local activeBtn = itempanel:getChildByName("activeBtn")
	local normalBtn = itempanel:getChildByName("normalBtn")
	local Label_nor = normalBtn:getChildByName("Label_nor")
	local Label_act = activeBtn:getChildByName("Label_act")
	
	local txt = self:getTextWord(1950+info[1])

	local tmp = info[1] - self._typeId
	if tmp == 0 then
		Label_act:setString(txt)
		activeBtn:setTitleText("")
		activeBtn:setVisible(true)
		normalBtn:setVisible(false)
	else
		Label_nor:setString(txt)
		normalBtn:setTitleText("")
		activeBtn:setVisible(false)
		normalBtn:setVisible(true)
		normalBtn.typeId = info[1]
		self:addTouchEventListener(normalBtn, self.onTypeBtn)
	end

end

-- 渲染排行榜列表
function RankPanel:onRenderListRank(itempanel, info, index)

	local Label_rankumber   = itempanel:getChildByName("Label_rankumber")
	local rankImg           = itempanel:getChildByName("rankImg")
	local Label_name        = itempanel:getChildByName("Label_name")
	local Label_name_New    = itempanel:getChildByName("Label_name_New")
	local Label_lv          = itempanel:getChildByName("Label_lv")
	local Label_value       = itempanel:getChildByName("Label_value")
	local lineImg           = itempanel:getChildByName("Image_line")
	local imgSelf           = itempanel:getChildByName("ImgSelf")

	--lineImg:setVisible(index%2 == 0)
    if index%2 == 0 then
	 TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Brown.png")
    else
	 TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Gray.png")
    end
	imgSelf:setVisible(self.MyName == info.name)
	local rankValue = info.rankValue
	local typeId = info.typeId
	if typeId == 1 or typeId == 8 then
		-- print("rankValue = "..rankValue)
		rankValue = StringUtils:formatNumberByK3(rankValue, nil)
	elseif typeId >= 5 and typeId <= 7 then
		rankValue = tostring(rankValue/100).."%"
	end

	-- print("..................typeId, rank, rankValue, name:", typeId, info.rank, rankValue, info.name)
	if typeId == 13 then 
		Label_lv:setString(info.legionName) 
	else
		Label_lv:setString(info.level)
	end
	
	Label_value:setString(rankValue)

	Label_name_New:setString("")
	Label_name:setString("")


	local rank = info.rank
	rankImg:setVisible(false)
	Label_rankumber:setVisible(true)
	if rank > 3 then
		Label_rankumber:setString(info.rank)
		Label_name:setString(info.name)
	else  --榜单前三名
		local url = ""
		local color = ColorUtils.wordColor01
		if rank == 1 then
			url = "images/newGui2/IconNum_1.png"
			color = ColorUtils.wordAddColor
		elseif rank == 2 then
			url = "images/newGui2/IconNum_2.png"
			color = ColorUtils.wordPurpleColor
		elseif rank == 3 then
			url = "images/newGui2/IconNum_3.png"
			color = ColorUtils.wordBlueColor
		end
		-- print("rank img url",url)
		TextureManager:updateImageView(rankImg, url)
        rankImg:setVisible(true)

        Label_rankumber:setString("")
		Label_name_New:setColor(color)
		Label_name_New:setString(info.name)
	end

	itempanel.info = info
	itempanel.index = index
	-- self:addTouchEventListener(itempanel, self.onRankBtn)
	itempanel:addTouchEventListener(function(sender, eventType)
		self:onRankBtn(sender, eventType)
	end)

	-- table.insert(self._listItem, itempanel)
end

function RankPanel:updateRankHandler()
	-- body
	if self._typeId ~= -1 then
		self:onRenderHandler(self._typeId)
	end
	
end

-- 监听分类按钮 --查看分类榜单
function RankPanel:onTypeBtn(sender)
	-- body
    -- print("===========分类按钮onTypeBtn===============")
	self._typeId = sender.typeId
	self:onRenderHandler(self._typeId)
end

-- 监听榜单项按钮
function RankPanel:onRankBtn(sender, eventType)
	local lineImg = sender:getChildByName("Image_line")
	-- local isVisible = lineImg:isVisible()
	if eventType == ccui.TouchEventType.ended then
		local info = sender.info
		self:onPlayerInfoReq(info.playerId)
        if sender.index%2 == 0 then
		    TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Brown.png")
        else
		    TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Gray.png")
        end
		--TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Bg.png")
		--lineImg:setVisible(sender.index%2 == 0)
    elseif eventType == ccui.TouchEventType.began then
    	--lineImg:setVisible(true)
    	TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Self.png")
    elseif eventType == ccui.TouchEventType.canceled then
        if sender.index%2 == 0 then
		    TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Brown.png")
        else
		    TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Gray.png")
        end
    	--TextureManager:updateImageView(lineImg, "images/newGui9Scale/S9Bg.png")
		--lineImg:setVisible(sender.index%2 == 0)
    end
end

-- 显示玩家数据
function RankPanel:onPlayerInfoResp(data)
    if self._watchPlayInfoPanel == nil then
        self._watchPlayInfoPanel = UIWatchPlayerInfo.new(self:getParent(), self, false, true)
    end
    -- self._watchPlayInfoPanel:setMialShield(true)
    self._watchPlayInfoPanel:showAllInfo(data)
end

-- 请求玩家数据
function RankPanel:onPlayerInfoReq(playerId)
	if StringUtils:isFixed64Minus(playerId) == true then
		return
	end
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:watchPlayerInfoReq({playerId = playerId})
end
