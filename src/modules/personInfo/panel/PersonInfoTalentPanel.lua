-- 个人信息：国策兵法
-- by fwx 1816.11.18
PersonInfoTalentPanel = class("PersonInfoTalentPanel", BasicPanel)
PersonInfoTalentPanel.NAME = "PersonInfoTalentPanel"

local ICONBG_BIG = 0

local ItemZOrder = {}
ItemZOrder.Common = 1
ItemZOrder.LongLine= 10

function PersonInfoTalentPanel:ctor(view, panelName)
	PersonInfoTalentPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end
function PersonInfoTalentPanel:finalize()
	if self._uiRecharge then
		self._uiRecharge:finalize()
		self._uiRecharge = 0
	end
	for i, eff in pairs( self.effs or {} ) do
		eff:finalize()
	end
	self.effs = {}
	PersonInfoTalentPanel.super.finalize(self)
end
function PersonInfoTalentPanel:initPanel()
	PersonInfoTalentPanel.super.initPanel(self)


    -- self:setBgType(ModulePanelBgType.NONE)
    
	self._topPanel = self:getChildByName("downPanel")
	self._copy_item= self:getChildByName("copy_item")
	self._listView = self:getChildByName("bgListView")
	self._pnlTop   = self:getChildByName("pnlTop")
	self._copy_item:setVisible(false)

	local btn_reset = self._topPanel:getChildByName("btn_reset")
	local btn_tip = self._topPanel:getChildByName("btn_tip")
	self:addTouchEventListener( btn_reset, self.onReset )
	self:addTouchEventListener( btn_tip, self.onShowTip )

    -- self._panelBg = self:getChildByName("Img_bg")

	self._talentProxy = self:getProxy(GameProxys.Talent)
	self.effs = {}
	self.items = {} --引用id对应的item

	--计算行最大个数
	self.nMaxNumAtRow = 0
	local arr={}
	local conf = self._talentProxy:getWarBookConf()
	for i,v in pairs( conf ) do
		arr[v.talentClass] = arr[v.talentClass] or 0
		arr[v.talentClass] = arr[v.talentClass] + 1
		self.nMaxNumAtRow = math.max(self.nMaxNumAtRow, arr[v.talentClass] )
	end
	--跳至
	local itemPanel = self._listView:getItem(0)
	-- itemPanel:setBackGroundColorType(0)

	self.itemPanelWidth = itemPanel:getContentSize().width
	self.jumpToIndex = nil
end

function PersonInfoTalentPanel:doLayout() --居中
	local tabsPanel = self:getTabsPanel()
	local listView =  self:getChildByName("bgListView")
	local downPanel = self:getChildByName("downPanel")
	local pnlTop   = self:getChildByName("pnlTop")

    NodeUtils:adaptiveTopPanelAndListView(pnlTop, nil, nil, tabsPanel)

    -- NodeUtils:adaptivePanelBg(self._panelBg, GlobalConfig.downHeight-3, tabsPanel)
	NodeUtils:adaptiveListView( listView, downPanel, pnlTop , 0)
	
end

--=====================================================
--事件
--=====================================================
--重设
function PersonInfoTalentPanel:onReset()
	self:showMessageBox( self:getTextWord(571), function()
		self:tryRetTalent()
	end )
end
--点击item
function PersonInfoTalentPanel:onShowTip()
	local uiTip = UITip.new( self:getParent() )
	local text = {{{content = self:getTextWord(572), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}}
	uiTip:setAllTipLine(text)
end
-- 是否弹窗元宝不足
function PersonInfoTalentPanel:tryRetTalent()
	local needMoney = self._talentProxy:getWarBookParameter() or 0
	local roleProxy = self:getProxy(GameProxys.Role)
	local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
	if needMoney > haveGold then
		if self._uiRecharge == nil then
			self._uiRecharge = UIRecharge.new( self:getParent(), self)
		else
			self._uiRecharge:show()
		end
	else
		self._talentProxy:onTriggerNet390002Req()
	end
end

--=====================================================
--外部调用
--=====================================================
function PersonInfoTalentPanel:onShowHandler()
	self.jumpToIndex = nil
	self:renderPanel()
    self:jumpToWantPoint()
end

function PersonInfoTalentPanel:renderPanel()
	local configRowList = self._talentProxy:getWarBookConfigRowList()

	--重置每个item的标志位
	-- local children = self._listView:getChildren()
	-- for i = 1,#children do
	-- 	local item_children = children[i]:getChildren()
	-- 	for j = 1,#item_children do
	-- 		local item = item_children[j]
	-- 		item._is_init_ = false
	-- 	end
	-- end	

	self.items = {}
	self:renderListView( self._listView, configRowList, self, self.renderItemPanel, 5, false,0)

end

function PersonInfoTalentPanel:renderSingleItem(talentId)

    local warBookTalentCfgData = ConfigDataManager:getInfoFindByOneKey(ConfigData.WarBookTalent, "ID", talentId)
    if warBookTalentCfgData == nil then
        return
    end

    local index = warBookTalentCfgData.talentClass - 1

    local configRowList = self._talentProxy:getWarBookConfigRowList()

    for i = 1, 3 do
        local configRow = configRowList[index + i]
        if configRow ~= nil then
            local itemPanel = self._listView:getItem(index + i - 1)
            self:renderItemPanel(itemPanel, configRow, index + i - 1)
        end
    end

end

--=====================================================
--刷新
--=====================================================
function PersonInfoTalentPanel:renderItemPanel(itemPanel, configRow, index)

    table.sort(configRow, function(a, b) return a.ID < b.ID end)

    --itemPanel._is_init_ = false
    -- 先计算当前行可升级是否上限
    local curRowMaxNum = nil
    for i, v in ipairs(configRow) do
        if v then
            if curRowMaxNum == nil then
                curRowMaxNum = self._talentProxy:getUnlockNumByClass(v.talentClass) or 0
            end
            local talentInfo = self._talentProxy:getTalentInfoById(v.ID)
            if talentInfo and talentInfo.talentLv > 0 then
                curRowMaxNum = curRowMaxNum - 1
            end
        end
    end
    local isCurRowFullLimit = curRowMaxNum ~= nil and curRowMaxNum <= 0



    local size = itemPanel:getContentSize()

    local col = #configRow
    -- 刷新一行的item
    -- for i, conf in ipairs(configRow) do
    for i = 1,4 do
    	local conf = configRow[i]
        local item = itemPanel:getChildByName("item" .. i) --@param 第二个参数是item名字,用于区分
        item:setTag(i)
        if conf then
            local itemSize = item:getContentSize()
            item:setVisible(true)
            -- item:setBackGroundColorType(1)
		    if col == 4 then
            	item:setPositionX(size.width / (7+1)*(2*i-1)-itemSize.width/2)
		    else
            	item:setPositionX(size.width / (7+1)*(2*i)-itemSize.width/2)
		    end
            -- 默认大圆图标
            item.iconBgTypeIndex = conf.effectShow or ICONBG_BIG            

            -- 多个连线  --优化，只绘制刷新一次线条
            local tParentItems = self:renderItem(item, conf, isCurRowFullLimit, index, i)
            for j, pItemInfo in ipairs(tParentItems or {}) do
                -- TimerManager:addOnce(30, function()
                    local lineName = "line" .. i .. j .. index
                    self:renderItemLine(item, pItemInfo, lineName)
                -- end , self)
            end
        else
            item:setVisible(false)
        end
    end
    --[[ 旧代码
    table.sort(configRow, function(a, b) return a.ID < b.ID end)

    -- if #configRow > 3 then
    --     itemPanel:setContentSize(cc.size(self.itemPanelWidth, itemPanel:getContentSize().height * 0.59))
    -- end

    -- local size = itemPanel:getContentSize()
    -- local height = size.height / self.nMaxNumAtRow
    -- local addX =(self.nMaxNumAtRow - #configRow) * height * 0.5


    -- 先计算当前行可升级是否上限
    local curRowMaxNum = nil
    for i, v in ipairs(configRow) do
        if v then
            if curRowMaxNum == nil then
                curRowMaxNum = self._talentProxy:getUnlockNumByClass(v.talentClass) or 0
            end
            local talentInfo = self._talentProxy:getTalentInfoById(v.ID)
            if talentInfo and talentInfo.talentLv > 0 then
                curRowMaxNum = curRowMaxNum - 1
            end
        end
    end
    local isCurRowFullLimit = curRowMaxNum ~= nil and curRowMaxNum <= 0

    local size = itemPanel:getContentSize()
    local width = size.width / (self.nMaxNumAtRow)
    local addX =(self.nMaxNumAtRow - #configRow) * width * 0.5


    local col = #configRow
    -- 刷新一行的item
    for i, conf in ipairs(configRow) do
        local item = self:getPanelItem(itemPanel, "__item" .. i) --@param 第二个参数是item名字,用于区分
        if conf then
            local itemSize = item:getContentSize()
            item:setScale(1)
            item:setVisible(true)
            -- item:setBackGroundColorType(1)
		    if col == 4 then
            	item:setPositionX(size.width / (7+1)*(2*i-1)-itemSize.width/2)
		    else
            	item:setPositionX(size.width / (7+1)*(2*i)-itemSize.width/2)
		    end
            item:setPositionY((size.height - itemSize.height) * 0.5)
            -- 默认大圆图标
            item.iconBgTypeIndex = conf.effectShow or ICONBG_BIG            

            -- 多个连线  --优化，只绘制刷新一次线条
            local tParentItems = self:renderItem(item, conf, isCurRowFullLimit, index, i)
            for j, pItemInfo in ipairs(tParentItems) do
                TimerManager:addOnce(30, function()
                    local lineName = "line" .. i .. j .. index
                    self:renderItemLine(item, pItemInfo, lineName)
                end , self)

            end
        else
            item:setVisible(false)
        end
    end
    --]]
end




--单个item
function PersonInfoTalentPanel:renderItem( item, conf, isCurRowFullLimit, index, line )

	local talentInfo = self._talentProxy:getTalentInfoById( conf.ID ) or self._talentProxy:getDefautTalentInfoById( conf.ID, 0 )    

    local img_icon = item:getChildByName("img_icon")
	local img_bg = item:getChildByName("img_bg")--大背景图标


	---[[
	if not item._is_init_ then
		item._is_init_ = true
		for i = 1,6 do
			local name = "imgLineBg"..i
			item[name] = item:getChildByName(name)
			item[name]:setVisible(false)
		end
		--获得前景线
		for i = 1,6 do
			local name = "imgLineFace"..i
			item[name] = item:getChildByName(name)
			item[name]:setVisible(false)
			-- item[name]:setLocalZOrder(1)
		end
		--获得箭头,箭头背景
		item.imgJianTouBg = item:getChildByName("imgJianTouBg")
		item.imgJianTouFace = item:getChildByName("imgJianTouFace")
		item.imgJianTouBg:setVisible(false)
		item.imgJianTouFace:setVisible(false)
		-- item.imgJianTouFace:setLocalZOrder(1)
	end
	--]]


	local tParentItems = {}

	 --开锁状态
	local isOpenLock = true

	local strArr = StringUtils:jsonDecode( conf.unlockCondition or "[]" )   --且 多天赋条件  --第一发
	for i,v in ipairs(strArr) do
		local _id = v[1]
		if _id then
            local _info = self._talentProxy:getTalentInfoById( _id )
			local isOk = _info and _info.talentLv>=v[2] or false
			if isOpenLock then				
				isOpenLock = isOk
			end

            local pItem = self.items[ _id ]
			if pItem then
				table.insert( tParentItems, { pItem, isOk } )
			end
		end
	end

	local strArr2 = StringUtils:jsonDecode( conf.otherCondition or "[]" )   --或 一个天赋条件  --是否有机会解锁
	for i,v in ipairs(strArr2) do
		local _id = v[1]
		if _id then
			local _info = self._talentProxy:getTalentInfoById( _id )
			if _info and not isOpenLock then  
				isOpenLock = _info.talentLv>=v[2]
			end
		end
	end

	local strArr3 = StringUtils:jsonDecode( conf.buildCondition or "[]" )   --且 一个建筑条件  --直接允不允许解锁
	local buildingType = strArr3[1]
	local buildingLevel = strArr3[2] or 0
	if isOpenLock then --
		local buildingProxy = self:getProxy( GameProxys.Building )
		local curBuildlv = buildingProxy:getBuildingMaxLvByType( buildingType )

		isOpenLock = curBuildlv>=buildingLevel 
	end

	--设置图标
	local isMiniIcon = conf.effectShow and conf.effectShow>0
	self.view:renderItemIcon( img_icon, img_bg, isMiniIcon, conf.ID )

	--可升级上限状态、可升级状态、满级状态
	local isFullLimit = talentInfo.talentLv<=0 and isCurRowFullLimit  --当前行可升级已上限
	local isFullPoint = talentInfo.talentLv>=conf.levelLimit --点数加满
	local color = ColorUtils.wordGrayColor
	local grey = ColorUtils.wordGrayColor
	if isOpenLock and not isFullLimit then
		color = not isFullPoint and ColorUtils.wordGreenColor or ColorUtils.wordWhiteColor
		grey = ColorUtils.wordWhiteColor
	end
	local text_num1 = item:getChildByName("text_num")
	local text_num2 = item:getChildByName("text_num_0")
	local img_bg = item:getChildByName( "img_bg" )
	local img_textbg = item:getChildByName( "img_textbg" )
	text_num1:setColor( color )
	text_num2:setColor( color==ColorUtils.wordGrayColor and ColorUtils.wordGrayColor or ColorUtils.wordWhiteColor )
	text_num1:setString( talentInfo.talentLv )
	text_num2:setString( "/"..conf.levelLimit )
	local pox = text_num1:getContentSize().width-text_num2:getContentSize().width
	-- text_num1:setPositionX( pox*0.5 + item:getContentSize().width*0.5 )
	-- text_num2:setPositionX( pox*0.5 + item:getContentSize().width*0.5 )
	img_icon:setColor( grey )
	NodeUtils:alignNodeL2R(text_num1,text_num2)
	NodeUtils:centerNodes(img_textbg, {text_num1,text_num2})

	--微调 如果是小背景图标,字和图标离得太远
	if isMiniIcon then
		img_bg:setPosition(63,52)
		img_textbg:setPositionY(96)
		text_num1:setPositionY(96)
		text_num2:setPositionY(96)
	else
		img_bg:setPosition(50,51)
		text_num1:setPositionY(103)
		text_num2:setPositionY(103)
	end

	--激活状态
	if conf.talentActivate==1 then
		local key = "eff"..line..index
		if not self.effs[ key ] then
			self.effs[key] = UICCBLayer.new( "rgb-zhanfa-jihuo", img_icon )
			self.effs[key]:setPosition( 40, 40 )
		end
		self.effs[key]:setVisible( talentInfo.talentState==0 )
	end

	--点升级回调 返回参数一，消耗
	local function onClickTipLevelupCallback(obj, sender, value, dir)
        
		if isFullLimit then  --可解锁但已上限
			self:showSysMessage( self:getTextWord(590) )
		else
			self:reqLevelup( talentInfo.talentId , obj._notEnoughItem) --可升级
		end

	end

	--tip
	local panel = self:getPanel( PersonInfoTalentTipPanel.NAME )
	local function renderTipPanel()
		panel:renderLevel( talentInfo, not isOpenLock, onClickTipLevelupCallback )
		if not isOpenLock then  --如果是锁定状态，显示解锁条件
			panel:renderNeedItem( strArr, strArr2, buildingType, buildingLevel, isBuildFullLv )
		end
	end
	local function onClickItem( sender )
		panel:show()
		renderTipPanel()
	end

	--升级回返
	if panel:isVisible() and panel:isUseID( talentInfo.talentId ) then
		renderTipPanel()
		panel:showLevelEff( isMiniIcon )
	end

	--点item
	self:addTouchEventListener( item, onClickItem )

	self.items[ conf.ID ] =  item
	if self.jumpToIndex==nil and color==ColorUtils.wordGreenColor then
		self.jumpToIndex = index
	end

	return tParentItems

	--[[
	local talentInfo = self._talentProxy:getTalentInfoById( conf.ID ) or self._talentProxy:getDefautTalentInfoById( conf.ID, 0 )    

    local img_icon = item:getChildByName("img_icon")
	local img_bg = item:getChildByName("img_bg")--大背景图标

	local tParentItems = {}

	 --开锁状态
	local isOpenLock = true

	local strArr = StringUtils:jsonDecode( conf.unlockCondition or "[]" )   --且 多天赋条件  --第一发
	for i,v in ipairs(strArr) do
		local _id = v[1]
		if _id then
            local _info = self._talentProxy:getTalentInfoById( _id )
			local isOk = _info and _info.talentLv>=v[2] or false
			if isOpenLock then				
				isOpenLock = isOk
			end

            local pItem = self.items[ _id ]
			if pItem then
				table.insert( tParentItems, { pItem, isOk } )
			end
		end
	end

	local strArr2 = StringUtils:jsonDecode( conf.otherCondition or "[]" )   --或 一个天赋条件  --是否有机会解锁
	for i,v in ipairs(strArr2) do
		local _id = v[1]
		if _id then
			local _info = self._talentProxy:getTalentInfoById( _id )
			if _info and not isOpenLock then  
				isOpenLock = _info.talentLv>=v[2]
			end
		end
	end

	local strArr3 = StringUtils:jsonDecode( conf.buildCondition or "[]" )   --且 一个建筑条件  --直接允不允许解锁
	local buildingType = strArr3[1]
	local buildingLevel = strArr3[2] or 0
	if isOpenLock then --
		local buildingProxy = self:getProxy( GameProxys.Building )
		local curBuildlv = buildingProxy:getBuildingMaxLvByType( buildingType )

		isOpenLock = curBuildlv>=buildingLevel 
	end

	--设置图标
	local isMiniIcon = conf.effectShow and conf.effectShow>0
	self.view:renderItemIcon( img_icon, img_bg, isMiniIcon, conf.ID )

	--可升级上限状态、可升级状态、满级状态
	local isFullLimit = talentInfo.talentLv<=0 and isCurRowFullLimit  --当前行可升级已上限
	local isFullPoint = talentInfo.talentLv>=conf.levelLimit --点数加满
	local color = ColorUtils.wordGrayColor
	local grey = ColorUtils.wordGrayColor
	if isOpenLock and not isFullLimit then
		color = not isFullPoint and ColorUtils.wordGreenColor or ColorUtils.wordWhiteColor
		grey = ColorUtils.wordWhiteColor
	end
	local text_num1 = item:getChildByName("text_num")
	local text_num2 = item:getChildByName("text_num_0")
	local img_bg = item:getChildByName( "img_bg" )
	local img_textbg = item:getChildByName( "img_textbg" )
	text_num1:setColor( color )
	text_num2:setColor( color==ColorUtils.wordGrayColor and ColorUtils.wordGrayColor or ColorUtils.wordWhiteColor )
	text_num1:setString( talentInfo.talentLv )
	text_num2:setString( "/"..conf.levelLimit )
	local pox = text_num1:getContentSize().width-text_num2:getContentSize().width
	-- text_num1:setPositionX( pox*0.5 + item:getContentSize().width*0.5 )
	-- text_num2:setPositionX( pox*0.5 + item:getContentSize().width*0.5 )
	img_icon:setColor( grey )
	NodeUtils:alignNodeL2R(text_num1,text_num2)
	NodeUtils:centerNodes(img_textbg, {text_num1,text_num2})

	--微调 如果是小背景图标,字和图标离得太远
	if isMiniIcon then
		img_bg:setPosition(63,52)
		img_textbg:setPositionY(96)
		text_num1:setPositionY(96)
		text_num2:setPositionY(96)
	else
		img_bg:setPosition(50,51)
		text_num1:setPositionY(103)
		text_num2:setPositionY(103)
	end

	--激活状态
	if conf.talentActivate==1 then
		local key = "eff"..line..index
		if not self.effs[ key ] then
			self.effs[key] = UICCBLayer.new( "rgb-zhanfa-jihuo", img_icon )
			self.effs[key]:setPosition( 40, 40 )
		end
		self.effs[key]:setVisible( talentInfo.talentState==0 )
	end

	--点升级回调 返回参数一，消耗
	local function onClickTipLevelupCallback(obj, sender, value, dir)
        
		if isFullLimit then  --可解锁但已上限
			self:showSysMessage( self:getTextWord(590) )
		else
			self:reqLevelup( talentInfo.talentId , obj._notEnoughItem) --可升级
		end
	end

	--tip
	local panel = self:getPanel( PersonInfoTalentTipPanel.NAME )
	local function renderTipPanel()
		panel:renderLevel( talentInfo, not isOpenLock, onClickTipLevelupCallback )
		if not isOpenLock then  --如果是锁定状态，显示解锁条件
			panel:renderNeedItem( strArr, strArr2, buildingType, buildingLevel, isBuildFullLv )
		end
	end
	local function onClickItem( sender )
		panel:show()
		renderTipPanel()
	end

	--升级回返
	if panel:isVisible() and panel:isUseID( talentInfo.talentId ) then
		renderTipPanel()
		panel:showLevelEff( isMiniIcon )
	end

	--点item
	self:addTouchEventListener( item, onClickItem )

	self.items[ conf.ID ] =  item
	if self.jumpToIndex==nil and color==ColorUtils.wordGreenColor then
		self.jumpToIndex = index
	end

	return tParentItems
	--]]
end

function PersonInfoTalentPanel:reqLevelup( talentId, notEnoughItem )
    

	local function talentUpgrade()
        local _data = {}
	    _data.talentId = talentId
	    self._talentProxy:onTriggerNet390001Req( _data )
	end

	if table.size(notEnoughItem) > 0 then
		local context = TextWords:getTextWord(593)
        local heroProxy = self:getProxy(GameProxys.Hero)
		heroProxy:CommonLvUpEnough(notEnoughItem, self, talentUpgrade, context)
	else
		talentUpgrade()
	end    
	
end

--=====================================================
--其他方法
--=====================================================
function PersonInfoTalentPanel:getPanelItem(itemPanel, name)
	local item = itemPanel:getChildByName( name )
	if not item then
		item = self._copy_item:clone()
		item:setName( name )
		itemPanel:addChild( item )
	end
	return item
end
-- 列表竖直方向滚动到指定位置
function PersonInfoTalentPanel:jumpToWantPoint()
--	local jumpToIndex = self.jumpToIndex or 0
--	local item = self._listView:getItem( jumpToIndex )
--	percent = item:getPositionX()/self._listView:getInnerContainerSize().width*100
--	self._listView:scrollToPercentHorizontal( percent, 0.2, true )
    self._listView:jumpToLeft()
end
--[[
	线段标记:
		1.向下,竖,短
		2.在下,左,横
		3.在下,右,横
		4.向上,竖,短
		5.向上,竖,长
		6.向下,竖,长
--]]
function PersonInfoTalentPanel:renderItemLine(item, pItemInfo, lineName)



	--pItem 上面的item
	--item 下面的item

    local pItem = pItemInfo[1]		--指向的item  下面向上指
    local isShowLine = pItemInfo[2]	


    local item_idx = item:getTag()
    local item_parent = item:getParent()

    local pItem_idx = pItem:getTag()
    local pItem_parent = pItem:getParent()

	item_parent:setLocalZOrder(ItemZOrder.Common)
	pItem_parent:setLocalZOrder(ItemZOrder.Common)

    if item:getPositionX() == pItem:getPositionX() then--同一列getIndex
    	 --相邻两行 显示两条短线
    	if math.abs(self._listView:getIndex(item_parent) - self._listView:getIndex(pItem_parent)) == 1 then

	    	pItem.imgLineBg1:setVisible(true)
	    	item.imgLineBg4:setVisible(true)

	    	item_parent:setLocalZOrder(ItemZOrder.LongLine)
	    	pItem_parent:setLocalZOrder(ItemZOrder.LongLine)

	    	if isShowLine then
		    	pItem.imgLineFace1:setVisible(true)
		    	item.imgLineFace4:setVisible(true)
	    	end
	    	
    	else--非相邻两行 显示两条长线
    		pItem.imgLineBg6:setVisible(true)
    		item.imgLineBg5:setVisible(true)
	    	if isShowLine then
		    	pItem.imgLineFace6:setVisible(true)
		    	item.imgLineFace5:setVisible(true)
	    	end
    	end
    else
    	local isBigIcon = item.iconBgTypeIndex <= ICONBG_BIG
    	if isBigIcon then
    		if item:getTag() >= pItem:getTag() then
    			pItem.imgLineBg3:setVisible(true)

    			-- item.imgLineBg4:setVisible(true)
    			item.imgJianTouBg:setVisible(true)

	    		if isShowLine then
	    			pItem.imgLineFace1:setVisible(true)
	    			pItem.imgLineFace3:setVisible(true)

	    			-- item.imgLineFace4:setVisible(true)
	    			item.imgJianTouFace:setVisible(true)
	    		end
    		else
    			pItem.imgLineBg2:setVisible(true)

    			item.imgLineBg4:setVisible(true)
    			-- item.imgJianTouBg:setVisible(true)

	    		if isShowLine then
	    			pItem.imgLineFace2:setVisible(true)

	    			-- item.imgLineFace4:setVisible(true)
	    			item.imgJianTouFace:setVisible(true)
	    		end
    		end
    	else
    		logger:error("小图标目前不支持连大图标")
    	end
    end


--[[
    local pItem = pItemInfo[1]		--指向的突变  下面向上指
    local isShowLine = pItemInfo[2]	--这个参数是?
    local lineLight = pItem:getChildByName(lineName .. "light")
    local lineBg = pItem:getChildByName(lineName)

    local isBigIcon = pItem.iconBgTypeIndex <= ICONBG_BIG


    local colorlight = nil
    if isShowLine then
        -- 已开锁
        if pItem.iconBgTypeIndex <= ICONBG_BIG then
            colorlight = math.abs(item.iconBgTypeIndex)
        else
            colorlight = math.abs(pItem.iconBgTypeIndex) or 1
        end
    end
    local urlLight = "images/personInfo/personInfo_line" ..(colorlight or 1)

    -- 绘制线条 绘制只发生一次
    if not lineLight then
        local ItemPosx, ItemPosy = item:getPosition()
        local pItemPosx, pItemPosy = pItem:getPosition()
        local ItemPPosx, ItemPPosy = item:getParent():getPosition()
        local pItemPPosx, pItemPPosy = pItem:getParent():getPosition()
        if item.iconBgTypeIndex <= ICONBG_BIG then
            -- 是大圆
            ItemPosx = ItemPosx - 17
        end
        if isBigIcon then
            -- 是大圆
            pItemPosx = pItemPosx + 17
        end
        local A =(ItemPosx + ItemPPosx) -(pItemPosx + pItemPPosx)
        local B =(ItemPosy + ItemPPosy) -(pItemPosy + pItemPPosy)
        local distane = math.sqrt(math.pow(A, 2) + math.pow(B, 2))
        local size = pItem:getContentSize()
        local rotation = 180 - B / A *(180 / math.pi)
        local addx = isBigIcon and 40 or 0

        lineBg = TextureManager:createImageView("images/personInfo/personInfo_line0_long.png")
        -- lineBg = TextureManager:createImageView("images/newGui9Scale/S9GCPersonInfoLineBg.png")
        -- 平行底线
        lineBg:setPosition(size.width * 0.5 + addx, size.height * 0.5)
        lineBg:setName(lineName)
        if rotation == 180 then
            lineBg:setAnchorPoint(0, 0.5)
            lineBg:setScaleX(distane / lineBg:getContentSize().width)
        else
            TextureManager:updateImageView(lineBg, "images/personInfo/personInfo_line0_skew.png")
            -- 斜底线
            if rotation > 180 then
                lineBg:setAnchorPoint(1, 1)
                lineBg:setScaleX(-1)
            else
                lineBg:setAnchorPoint(0, 0)
                lineBg:setPosition(size.width * 0.5 + addx + 2, size.height * 0.5 - 2)
            end
        end
        pItem:addChild(lineBg)

        -- 颜色线
        lineLight = lineBg:clone()
        lineLight:setName(lineName .. "light")
        lineLight:setPosition(size.width * 0.5 + addx, size.height * 0.5)
        if rotation == 180 then
            lineLight.isSkewLine = ""
            TextureManager:updateImageView(lineLight, urlLight .. ".png")
            lineLight:setScaleX(distane / lineLight:getContentSize().width)
        else
            lineLight.isSkewLine = "_skew"
            TextureManager:updateImageView(lineLight, urlLight .. "_skew.png")
        end
        pItem:addChild(lineLight)

        if item.iconBgTypeIndex ~= ICONBG_BIG then
            local r = 1 - 37 / distane
            local point = TextureManager:createImageView("images/personInfo/personInfo_linePoint.png")
            if isBigIcon then
                point:setPosition(size.width * 0.5 + A * r + 19, size.height * 0.5 + B * r +(rotation > 180 and 4 or -2))
            else
                point:setPosition(size.width * 0.5 + A * r, size.height * 0.5 + B * r)
            end
            point:setRotation(rotation + 180)
            pItem:addChild(point)
        end
    else
        TextureManager:updateImageView(lineLight, urlLight .. lineLight.isSkewLine .. ".png")
    end
    lineLight:setVisible(isShowLine)
    --]]
end
