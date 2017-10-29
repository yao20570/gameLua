--
-- Author: zlf
-- Date: 2016-04-19
-- 军师府主界面
ConsigliereListPanel = class("ConsigliereListPanel", BasicPanel)
ConsigliereListPanel.NAME = "ConsigliereListPanel"


function ConsigliereListPanel:ctor(view, panelName)
    ConsigliereListPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ConsigliereListPanel:finalize()
	if self._uiConsigliereInfo ~= nil then
        self._uiConsigliereInfo:finalize()
        self._uiConsigliereInfo = nil
    end
    if self._uiSharePanel ~= nil then
        self._uiSharePanel:finalize()
        self._uiSharePanel = nil
    end
    ConsigliereListPanel.super.finalize(self)
end

function ConsigliereListPanel:initPanel()

	ConsigliereListPanel.super.initPanel(self)
	self.curIndex = 1
	-- self.first = true
	self.listView = self:getChildByName("ListView_14")
	local panel_bottom = self:getChildByName("panel_bottom")
	self.proxy = self:getProxy(GameProxys.Consigliere)

	-- local item = self.listView:getItem(0)
 --    self.listView:setItemModel(item)

	for i=1,3 do
		local btn = panel_bottom:getChildByName("btn_"..i)
		btn:setTitleText(self:getTextWord(270100 + i))
		btn.type = i
		self:addTouchEventListener(btn, self.btnCall)
	end

	self:updateNumberTxt(0)
end

-- 更新军师数量
function ConsigliereListPanel:updateNumberTxt(curNum)
	curNum = curNum or 0
	local maxNum = 200  --數量上限200
	local infoStr = {{{ self:getTextWord(270104), 20, "#eed6aa" }, { curNum, 20, "#66ff00" }, { "/" .. maxNum, 20, "#eed6aa" }},}

	local numberTxt = self:getChildByName("panel_bottom/numberTxt")
	if numberTxt == nil then
		return
	end

	local richLabel = numberTxt.richLabel
	if richLabel == nil then
	    richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
	    numberTxt:addChild(richLabel)
	    numberTxt.richLabel = richLabel
	end
	richLabel:setString(infoStr)

	local size = richLabel:getContentSize()
	richLabel:setPositionX(0 - size.width / 2)

end

function ConsigliereListPanel:doLayout()
	local panel_bottom = self:getChildByName("panel_bottom")
	NodeUtils:adaptiveListView(self.listView, panel_bottom, self:getTabsPanel() )


end

function ConsigliereListPanel:topBtnCall(sender)
	if self.curIndex ~= sender.id then
		self["btn_bg"..self.curIndex]:setVisible(false)
		self.curIndex = sender.id
		self["btn_bg"..sender.id]:setVisible(true)
		local startArr = self.proxy:getAllInfo()--self.proxy:getQuiltyById(sender.id - 1)
		self:renderListView(self.listView, startArr, self, self.renderItemPanel)
		self:updateNumberTxt(table.size(startArr))
	end
end

function ConsigliereListPanel:registerEvents()
	ConsigliereListPanel.super.registerEvents(self)
end

function ConsigliereListPanel:btnCall(sender)
	if sender.type == 1 then
		local moduleName = ModuleName.ConsigliereImgModule
    	self:dispatchEvent(ConsigliereEvent.SHOW_OTHER_EVENT,moduleName)
    elseif sender.type == 2 then
    	local panel = self:getPanel(ConsigliereResolvePanel.NAME)
		panel:show()
	elseif sender.type == 3 then
		local panel = self:getPanel(AdvancePanel.NAME)
		panel:show()
	end
end

function ConsigliereListPanel:onClosePanelHandler()
	self.view:dispatchEvent(ConsigliereEvent.HIDE_SELF_EVENT)
end

function ConsigliereListPanel:onShowHandler()
	-- if self.curIndex ~= 1 or self.first then
	-- 	self.first = nil
	-- 	self["btn_bg"..self.curIndex]:setVisible(false)
	-- 	self.curIndex = 1
	-- 	self["btn_bg"..self.curIndex]:setVisible(true)
	-- end
	 --self.proxy:getQuiltyById( self.curIndex - 1)
	 self:getPanel(ConsiglierePanel.NAME):setblacklayer(true)
	self:updateView()
end

function ConsigliereListPanel:updateView()

	-- local data = self.proxy:getAllInfo()

	-- if not data then return end
	-- local num = self.proxy:getAllNum()
	-- print("数量", num )
	-- local mAllNum = self:getChildByName("panel_bottom/lab_num")
	-- mAllNum:setVisible(num~=0)
	-- mAllNum:setString(num.."")
	local newData = {}
	local _data = self.proxy:getAllInfo() --self.proxy:getQuiltyById( self.curIndex - 1)
	local i = 0
	for _,data in pairs(_data) do
		i = i + 1
		local index = math.floor((i-1)/3)+1
		newData[index] = newData[index] or {}
		table.insert( newData[index], data )
	end
    self:renderListView(self.listView, newData, self, self.renderItemsPanel )
    self:updateNumberTxt(table.size(_data))
	-- TimerManager:addOnce(60, self.jumpToWantPoint, self)
end
-- -- 列表竖直方向滚动到指定位置
-- function ConsigliereListPanel:jumpToWantPoint()
--     self.listView:jumpToPercentVertical( 0 )
-- end

function ConsigliereListPanel:renderItemsPanel(itemPanel, datas)
	for i=1,3 do
		local item = itemPanel:getChildByName( "Panel_item"..i )
		if not item then break end
		item:setVisible( datas[i] ~= nil )
		if datas[i] then
			self:renderItemPanel( item, datas[i] )
		end
	end
end
function ConsigliereListPanel:renderItemPanel(item, data)
	--local allChild = self:getChild(item)
	-- local lab_attack = item:getChildByName("Label_18_2") --

	-- local img_icon = item:getChildByName("img_icon")  --头像
	-- local lab_name = item:getChildByName("lab_name")
	-- local star = item:getChildByName("Label_18_8_10")
	-- local batImg = item:getChildByName("img_battle")

	-- local itemData = self.proxy:getDataById(data.typeId)
	-- local sLvStr = ""
	-- if data.lv>0 then
	-- 	sLvStr = " +"..data.lv
	-- end
	-- lab_name:setString( itemData.name..sLvStr..itemData.skillID )
	-- lab_name:setColor( ColorUtils:getColorByQuality(itemData.quality) )
	-- star:setString( itemData.quality )
	-- batImg:setVisible( data.pos and data.pos<0 )
	-- local url = string.format("images/consigliereImg/%d.png", itemData.icon)
	-- TextureManager:updateImageView(img_icon, url)

	-- if itemData.skillID or itemData.skillID~="[]" then
	-- 	self.view:updateSkills( item, itemData.skillID )
 --    else
 --    	skIcon:setVisible(false)
 --    end

	--self:setStarNum(star, itemData.quality)
	-- allChild.have:setString(data.num.."") 
	-- allChild.battle:setString(data.fightnum.."")
	--self:setInfoData(itemData.property, info, num)
	
	--技能图标
	-- if itemData.skillID ~= 0 and itemData.skillID then
	-- 	local skillData = self.proxy:getSkillData(itemData.skillID)
	-- 	print(">>>>>>>>>>>>>>>>>>", itemData.skillID, skillData)
    
	-- local iconData = {}
	-- iconData.url = url
	-- iconData.skId = itemData.skillID
	-- iconData.info = itemData.property
	-- iconData.starNum = itemData.quality
	-- iconData.iconName = itemData.name
	-- iconData.typeId = data.typeId
	-- iconData.id = data.id
	-- iconData.lv = data.lv
	-- iconData.num = 1--data.num - data.fightnum

	-- item.data = iconData

    -- print( data, ">>>>>>>>>>>>>>>>>>>>" )
    -- for i,v in pairs(data) do
    -- 	print(i,v)
    -- end
    local posUrl = nil
    if data.pos>0 then
        posUrl = "images/newGui1/adviser_state2.png"
    elseif data.pos<0 then
        posUrl = "images/newGui1/adviser_state.png"
    end
    ComponentUtils:renderConsigliereItem( item, data.typeId, data.lv, posUrl ,nil, nil, nil, nil, nil,true)

    local img_battle = item:getChildByName("img_battle")
    if img_battle then
    	if img_battle.oldY == nil then
    		img_battle.oldY = img_battle:getPositionY()
    	end
    	img_battle:setPositionY(img_battle.oldY + 35)
    end

	item.id = data.id
	item.data = data
	self:addTouchEventListener(item, self.showIconInfo)

	if self._uiConsigliereInfo and self._uiConsigliereInfo:getUseTypeId()==data.typeId then
		self._uiConsigliereInfo:renderView( data )
	end
end

function ConsigliereListPanel:showIconInfo(sender)
	local data = {}
	data.adviserInfo = sender.data
	data.callbackId = sender.id
	data.obj = self
	data.tBtnfn = {
		{
			name = self:getTextWord(270010), --"升星",
			click = self.onClickLevelup,
		},{
			name = self:getTextWord(270011), --"分解",
			isRed = true,
			click = self.onClickResolve,
		},{
			name = self:getTextWord(270012), --"分享",
			click = self.onClickSend,
		}
	}

	if self._uiConsigliereInfo == nil then
		self._uiConsigliereInfo = UIAdviserInfo.new(self, data)
	else
		self._uiConsigliereInfo:show(data)
	end
	-- panel:show( data )
end

--print("升星", id, self)	
function ConsigliereListPanel:onClickLevelup( id )
	print("点击升星")
	local data = self.proxy:getInfoById( id )
	local conf = self.proxy:getLvData( data.typeId, data.lv+1 )
	if data.lv and data.lv>=3 then
		self:showSysMessage( self:getTextWord(270040) ) --已经满星
		return
	end
	if not conf then
		self:showSysMessage(TextWords:getTextWord(270039)) --不可升星
		return
	end
	if not self.proxy:isFreeAdviser(id) then
		self:showSysMessage( self:getTextWord(270076) )
		return
	end
	local panel = self:getPanel(AdvancedPanel.NAME)
	panel:show( data )
end

--print("分解", id )
function ConsigliereListPanel:onClickResolve( id )
	print("点击分解")
	if not self.proxy:isFreeAdviser(id) then
		self:showSysMessage( self:getTextWord(270079) )
		return
	end
	local data = {}
	data.ids = {id}
	data.id = id
	local panel = self:getPanel( ConsigliereTipsPanel.NAME )
	panel:show( data )
end

--分享
function ConsigliereListPanel:onClickSend( id, sender )
	print("点击分享")
    if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new( self:getParent(), self, true)
    end
    local data = {}
    data.type = ChatShareType.ADVISER_TYPE
    data.id = id
    self._uiSharePanel:showPanel(sender, data, 170)
end

--直接getChildByName了

-- function ConsigliereListPanel:getChild(item)
-- 	local allChild = {}
-- 	allChild.img_icon = item:getChildByName("img_icon")
-- 	allChild.lab_attack = item:getChildByName("Label_18_2")
-- 	allChild.lab_name = item:getChildByName("lab_name")
-- 	allChild.skIcon = item:getChildByName("Image_34") 
-- 	local info = {}
-- 	local num = {}
-- 	for i=1,5 do
-- 		local label = item:getChildByName("Label_"..(17+i))
-- 		info[i] = label
-- 		num[i] = item:getChildByName("Label_"..(17+i).."_num")
-- 	end
-- 	allChild.info = info
-- 	allChild.num = num
-- 	for i=1,2 do
-- 		local label = item:getChildByName("Label_"..(22+i))
-- 		label:setString(TextWords:getTextWord(270015+i))
-- 	end
-- 	allChild.have = item:getChildByName("Label_18_8_10")
-- 	allChild.battle = item:getChildByName("Label_18_8_12")
-- 	allChild.batImg = item:getChildByName("img_battle")
-- 	allChild.sk_icon = item:getChildByName("Image_34")
-- 	local star = {}
-- 	for i=1,5 do
-- 		star[i] = item:getChildByName("star_"..i)
-- 	end
-- 	allChild.star = star
-- 	return allChild
-- end

-- function ConsigliereListPanel:setStarNum(stars, count)
-- 	for i=1,count do
-- 		stars[i]:setVisible(true)
-- 		TextureManager:updateImageView(stars[i], "images/newGui1/IconStar.png")
-- 	end
-- 	if count >= 5 then
-- 		return
-- 	end
-- 	for i=count+1,5 do
-- 		stars[i]:setVisible(false)
-- 	end
-- end

function ConsigliereListPanel:resolveSuccess()
	local panelName = {ConsigliereResolvePanel.NAME, ConsigliereTipsPanel.NAME}
	for k,v in pairs(panelName) do
		self:getPanel(v):hide()
	end
	if self._uiConsigliereInfo then
		self._uiConsigliereInfo:hide()
	end
end

-- function ConsigliereListPanel:showOtherView(data)
-- 	local panel = self:getPanel(ConsigliereTipsPanel.NAME)
-- 	panel:show(data)
-- end














