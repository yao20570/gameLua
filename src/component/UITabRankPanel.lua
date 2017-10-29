--
-- Author: zlf
-- Date: 2016年8月9日16:27:41
-- 限时活动排行榜

--[[
	data传4个字段
	tipText 提示的文字
	rankID 奖励数据
	rankData 排行榜数据
	num 自己的排行榜积分 可传nil  因为有时候自己的积分会比较快刷新
]]

UITabRankPanel = class("UITabRankPanel", BasicComponent)

function UITabRankPanel:ctor(parent, panel, closeFunction, data)
	UITabRankPanel.super.ctor(self)
    local uiSkin = UISkin.new("UITabRankPanel")
    uiSkin:setParent(parent)
    self._uiSkin = uiSkin
    self._parent = parent
    self._panel = panel

    --self._uiPanelBg = UIPanelBg.new(self._uiSkin:getRootNode(), function()
    --	if type(closeFunction) == "function" then
    --		closeFunction()
    --	end
   	--	self._uiSkin:setVisible(false)
    --
   	--end)
    --self._uiPanelBg:setBgType(ModulePanelBgType.BLACKFULL)
    --
    --local topPanel = self._uiPanelBg:topAdaptivePanel()
    --
    --NodeUtils:adaptivePanelBg(self._uiPanelBg._bgImg5, GlobalConfig.downHeight, topPanel)
    --
    --self._uiPanelBg:setIsShowName(true, "rank", true)
   

    self:initPanel(data)
    self:updateData(data)

end

function UITabRankPanel:initPanel(info)
    
	local panel = self:getChildByName("Panel_14")
	panel:setLocalZOrder(2) -- 已经到2了
	self._top_panel = self:getChildByName("Panel_14/top_panel")
	--local bottom_panel = self:getChildByName("Panel_14/bottom_panel")
	--self._panel:adjustBootomBg(bottom_panel, self._top_panel, true)
	
	self._top_panel:setVisible(true)

	self.count_label = self._top_panel:getChildByName("count_label")
	self.level_label = self._top_panel:getChildByName("level_label")
	self.score_label = self._top_panel:getChildByName("score_label")

	self.tip_btn = self._top_panel:getChildByName("tip_btn")
	self._adaPanel =  self._top_panel:getChildByName("Image_40")

	self.proxy = self._panel:getProxy(GameProxys.Activity)

	self.listView = self._top_panel:getChildByName("listView")
    self.listView:setItemModel(item)

    for i=1,4 do
    	local label = self._top_panel:getChildByName("name"..i.."_label")
    	label:setString(TextWords:getTextWord(280004+i))
    end

	local rewardPanel = self:getChildByName("rewardPanel")
	self.rewardPanel = rewardPanel
	rewardPanel:setVisible(false)


     --start 二级弹窗 -------------------------------------------------------------------
    if self.secLvBg == nil then
	    local extra = {}
	    extra["closeBtnType"] = 1
	    extra["callBack"] = function() rewardPanel:setVisible(false)  self._layoutChild:setVisible(false) end
	    extra["obj"] = self
    
	    self.secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self, extra)
	    self.secLvBg:setContentHeight(720)
	    self.secLvBg:setTitle(TextWords:getTextWord(1325))
	    self.secLvBg:setVisible(false)
        
        self.secLvBg:setLocalZOrder(4)	
        rewardPanel:setLocalZOrder(4)	
    end
    
    -- 灰色背景
    self:setMask()
     --end 二级弹窗 --------------------------------------------------------------------

end

function UITabRankPanel:finalize()
	self._uiSkin:finalize()
	self._uiSkin = nil
	UITabRankPanel.super.finalize(self)
end

--function UITabRankPanel:setTitle(isShow,content, isImg, exContent)
--    self._uiPanelBg:setIsShowName(isShow,content, isImg, exContent)
--end

function UITabRankPanel:updateData(info)  --刷新listview数据
	self._uiSkin:setVisible(true)

	local jifen_label = self:getChildByName("Panel_14/top_panel/jifen_label")
	local name4_label = self:getChildByName("Panel_14/top_panel/name4_label")
	info.titleText = info.titleText or "积 分"
	jifen_label:setString("当前"..info.titleText)
	name4_label:setString(info.titleText)

	local reward_btn = self:getChildByName("Panel_14/down_panel/gift_btn")
    local rewardList = self.rewardPanel:getChildByName("listview")
	self._panel:addTouchEventListener(reward_btn, function()
    	self.rewardPanel:setVisible(true)
    	self.secLvBg:setVisible(true)
        self._layoutChild:setVisible(true)

    	local rewardData = {}

    	if self.oldRankId ~= info.rankID then
			self.oldRankId = info.rankID
			local config = ConfigDataManager:getConfigData("CRankingRewardConfig")
			local rewardData = {}
			for k,v in pairs(config) do
				if v.rankingreward == self.oldRankId then
					table.insert(rewardData, v)
				end
			end
			table.sort( rewardData, function(a, b)
				return a.ID < b.ID
			end )
			self.rewardData = rewardData
		end

		self:renderListView(rewardList, self.rewardData, self, self.renderRewardItem)
    end)

	self.tip_btn:setVisible(info.tipText ~= nil)
	if info.tipText ~= nil then
		self._panel:addTouchEventListener(self.tip_btn, function()
            local parent = self._parent:getParent()
            if parent == nil then
                parent = self._parent
            end
			local uiTip = UITip.new(parent)
			local text = {{{content = info.tipText, foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}}
		    uiTip:setAllTipLine(text)
            uiTip:setTitle(TextWords:getTextWord(7500))
		end)
	end
	local data = info.rankData
	local myInfo = data.myRankInfo
	if myInfo == nil then
		logger:error("DayTurnRankPanel error myInfo == nil !!!")
		return
	end
	self.count_label:setString( myInfo.rank <= 0 and TextWords:getTextWord(1701) or myInfo.rank )
	local roleProxy = self._panel:getProxy(GameProxys.Role)
    local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
	self.level_label:setString(level)
	local num = info.num or myInfo.rankValue
	num = num or 0
	self.score_label:setString(num)


	self:renderListView(self.listView, data.activityRankInfos, self, self.renderItem, false, false, 0)

    local posY = self:getChildByName("Panel_14/top_panel/Image_43"):getPositionY()
    local num = #data.activityRankInfos
    local offsetHeight = num * 60
    local listHeight = self.listView:getContentSize().height
    if offsetHeight > listHeight then
        offsetHeight = listHeight
    end

    self:getChildByName("Panel_14/top_panel/imgBottomLine"):setPositionY(posY - offsetHeight - 21)
end

function UITabRankPanel:renderItem(item, data, index)
	local rank_label = item:getChildByName("rank_label")
	local name_label = item:getChildByName("name_label")
	local level_label = item:getChildByName("level_label")
	local score_label = item:getChildByName("score_label")
    local itemBgImg   = item :getChildByName("itemBgImg")
    local rankImg = item:getChildByName("imgRank")
    rankImg:setVisible(false)
    if data.rank < 4 then 
        rankImg:setVisible(true)
	    TextureManager:updateImageView(rankImg, "images/newGui2/IconNum_" .. data.rank .. ".png")
    end
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end
	rank_label:setString(data.rank)
	name_label:setString(data.name)
	level_label:setString(data.level)
	score_label:setString(data.rankValue)
    --itemBgImg:setVisible(index%2 == 0)
end

function UITabRankPanel:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UITabRankPanel:renderRewardItem(item, data, index)
	if item == nil or data == nil then
		return
	end
	local index_label = item:getChildByName("index_label")
	local index_str = ""
	if data.ranking == data.rankingii then
		index_str = string.format(TextWords:getTextWord(250027), data.ranking)
	else
		index_str = string.format(TextWords:getTextWord(250028), data.ranking,data.rankingii)
	end
	index_label:setString(index_str)

	for count = 1,3 do
		local reIwItem = item:getChildByName("itemImg"..count)
		reIwItem:setVisible(false)
	end

	local countTb = StringUtils:jsonDecode(data.reward)
	local i = 1
	for _,v in pairs(countTb) do
		local reIwItem = item:getChildByName("itemImg"..i)
		local name = reIwItem:getChildByName("name_label")
		local num = reIwItem:getChildByName("num_label")
		local config = ConfigDataManager:getConfigByPowerAndID(v[1],v[2])

		local color = ColorUtils:getColorByQuality(config.color)
		name:setColor(color)        
		name:setString(config.name)

		local iconInfo = {}
		iconInfo.power = v[1]
		iconInfo.typeid = v[2]
		iconInfo.num = v[3]

		local iconSprite = item["item"..i]
		if iconSprite == nil then
			local icon = UIIcon.new(reIwItem, iconInfo, true, self._panel)
			item["item"..i] = icon
		else
			iconSprite:updateData(iconInfo)
		end
		reIwItem:setVisible(true)
		i = i + 1
	end
end


function UITabRankPanel:setMask()--设置灰色屏幕
    local rootNode = self._uiSkin:getRootNode()
    if self._layoutChild == nil then
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(3000, 3000))
        local winSize = rootNode:getContentSize()
        layout:setPosition(cc.p(winSize.width/2, winSize.height/2))
        layout:setBackGroundColor(cc.c3b(0, 0, 0))
        layout:setOpacity(100)
        layout:setAnchorPoint(0.5, 0.5)
        layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        rootNode:addChild(layout, 3)
        layout:setTouchEnabled(true)
        self._layoutChild = layout
        self._layoutChild:setVisible(false)
    end

end
