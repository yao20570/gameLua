--
-- Author: zlf
-- Date: 2016年4月21日15:27:29
-- 批量选将界面
ChoosePanel = class("ChoosePanel", BasicPanel)
ChoosePanel.NAME = "ChoosePanel"

local ITEM_MAX = 6

function ChoosePanel:ctor(view, panelName)
    ChoosePanel.super.ctor(self, view, panelName, 700)

    self.tCheckIds = {}

    self:setUseNewPanelBg(true)
end

function ChoosePanel:finalize()
    ChoosePanel.super.finalize(self)
end

function ChoosePanel:initPanel()
	ChoosePanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Consigliere)

	self:setLocalZOrder( PanelLayer.UI_Z_ORDER_3 )

	self.listView = self:getChildByName("Panel_Choose/ListView")
  	self.btn_sure = self:getChildByName("Panel_Choose/btn_sure")

  	
end

-- function ChoosePanel:chooseCallBack(sender)
-- 	self.view:dispatchEvent(ConsigliereEvent.CHOOSE_OVER_CALL, self.allData)
-- end

function ChoosePanel:registerEvents()
	ChoosePanel.super.registerEvents(self)
end

function ChoosePanel:onShowHandler(data)
	-- self.otherPanel = self:getPanel(AdvancePanel.NAME)
	-- self.mainPanel = self:getPanel(ConsiglierePanel.NAME)
	-- self.allId = {}
	-- self.allData = {}
	-- self.chooseNum = 0
	-- self.maxNum = self.proxy.maxNum

	self:setTitle(true, data.title or self:getTextWord(270054))

	self.ids = data.ids or {}
	self.isNewAdviserPanel = data.isNewAdviserPanel

	local renderData = {}
	local _data = data.dataList or {}
	if #_data<=0 then
		self:showSysMessage( self:getTextWord(270071) )
	else
		for i,data in ipairs(_data) do
			local index = math.floor((i-1)/3)+1
			renderData[index] = renderData[index] or {}
			table.insert( renderData[index], data )
		end
	end

	for index,v in ipairs(_data) do
		self.tCheckIds[index] = false
		for _,_id in pairs(self.ids) do
			if _id==v.id then
				self.tCheckIds[index] = v.id
			end
		end
	end


	self:renderListView(self.listView, renderData, self, self.renderItemsPanel)

	--重设按钮事件
	self:addTouchEventListener( self.btn_sure, function()
		if data.callback then
			local tCheckIds = self:getCheckIds()
			data.callback( tCheckIds )
		end
		self.tCheckIds = {}
		self:hide()
	end)
end

function ChoosePanel:renderItemsPanel(pitem, datas, index)
	for i=1,3 do
		local item = pitem:getChildByName( "Panel_"..i )

		item.saveX = item.saveX or item:getPositionX()

		local addX = self.isNewAdviserPanel and 15 or 0
		item:setPositionX( item.saveX+addX )
		if datas[i] then
			self:renderItemPanel( item, datas[i], index*3+i )
			item:setVisible( true )
		else
			item:setVisible( false )
		end
	end
	-- for i=1,2 do
	-- 	if data[i] then
	-- 		item:getChildByName("Panel_"..i):setVisible(true)
	-- 		local allChild = self:getChild(item:getChildByName("Panel_"..i))
	-- 		TextureManager:updateImageView(allChild.icon, data[i].url)
	-- 		allChild.checkBox.id = data[i].id
	-- 		self:addTouchEventListener(allChild.checkBox, self.checkBoxCall)
	-- 		allChild.name:setString(data[i].name)
	-- 		-- self.mainPanel:setStarNum(allChild.star, data[i].starNum)
	-- 		ComponentUtils:renderStar(allChild.star, data[i].starNum)
	-- 	else
	-- 		item:getChildByName("Panel_"..i):setVisible(false)
	-- 	end
	-- end
end
function ChoosePanel:renderItemPanel( item, data, index )
	
	local img_icon = item:getChildByName( "img_icon" )
	local CheckBox = item:getChildByName("CheckBox")
	local lab_name = item:getChildByName("lab_name")

	local conf = self.proxy:getDataById( data.typeId ) or {}
	local str = string.format("images/counsellorIcon/%d.png", conf.head or 1)
	TextureManager:updateImageView( img_icon, str )

	local sLvStr = ""
    if _lv and _lv>0 then
        sLvStr = " +".._lv
    end
    lab_name:setString( (conf.name or "")..sLvStr )
    lab_name:setColor( ColorUtils:getColorByQuality( conf.quality or 1 ) )

    if self.isNewAdviserPanel then
    	CheckBox:setVisible( false )
    	return
    end

    CheckBox:setVisible( true )
	CheckBox:addEventListener( function()
		local checkids = self:getCheckIds()
        local count = #checkids
        logger:info("#checkids:".. count)        
        logger:info(CheckBox:getSelectedState())

        if #checkids == ITEM_MAX then
            if not CheckBox:getSelectedState() then -- 点击已经选中状态的
                self.tCheckIds[index] = false
            else
                self:showSysMessage( self:getTextWord(270082))
                CheckBox:setSelectedState(false)
                return
            end
        end

        -- 确定，操作
        if CheckBox:getSelectedState() then
            self.tCheckIds[index] = data.id
        else
            -- 取消，点掉操作
            CheckBox:setSelectedState(false)
			self.tCheckIds[index] = false
        end

	end)
    CheckBox:setSelectedState( false )
    for _,_id in pairs(self.ids) do
    	if _id==data.id then
    		CheckBox:setSelectedState( true )
    	end
    end
end


function ChoosePanel:getCheckIds()
	local checkIds = {}
	for i,id in pairs(self.tCheckIds) do
		if id ~= false then
			table.insert( checkIds, id )
		end
	end
	return checkIds
end

-- function ChoosePanel:getCheckIds()
-- 	local tCurIds = {}
-- 	local items = self.listView:getItems()
-- 	for _, pitem in ipairs(items) do
-- 		for i=1,3 do
-- 			local item = pitem:getChildByName( "Panel_"..i )
-- 			local check = item:getChildByName( "CheckBox" )
-- 			if check:getSelectedState() and item.id then
-- 				table.insert( tCurIds, item.id )
-- 			end
-- 		end
-- 	end
-- 	return tCurIds
-- end
-- function ChoosePanel:checkBoxCall(sender)
-- 	local state = sender:getSelectedState()
-- 	if not state then
-- 		if self.chooseNum < self.maxNum then
-- 			self.chooseNum = self.chooseNum + 1
-- 			sender:setSelectedState(false)
-- 			self.allData[sender.id] = self.allId[sender.id]
-- 		else
-- 			self:showSysMessage(string.format(TextWords:getTextWord(270046), self.maxNum))
-- 			sender:setSelectedState(true)
-- 		end
-- 	else
-- 		self.allData[sender.id] = nil
-- 		self.chooseNum = (self.chooseNum-1>=0) and (self.chooseNum-1) or 0
-- 	end

-- end

-- function ChoosePanel:getChild(parent)
-- 	local allChild = {}
-- 	allChild.icon = parent:getChildByName("img_icon")
-- 	allChild.name = parent:getChildByName("lab_name")
-- 	allChild.checkBox = parent:getChildByName("cb1")
-- 	allChild.checkBox:setSelectedState(false)
-- 	allChild.star = {}
-- 	for i=1,5 do
-- 		allChild.star[i] = parent:getChildByName("star"..i)
-- 	end
-- 	return allChild
-- end

-- function ChoosePanel:getData(param)
-- 	local result = {}
-- 	local idx = 1
-- 	for k,v in pairs(param) do
-- 		local config = self.proxy:getDataById(v.id)
-- 		for i=1,v.count do
-- 			local data = {}
-- 			data.url = string.format("images/consigliereImg/%d.png", config.icon)
-- 			data.name = config.name
-- 			data.starNum = config.quality
-- 			data.id = idx
-- 			self.allId[idx] = v.id
-- 			table.insert(result, data)
-- 			idx = idx + 1
-- 		end
-- 	end
-- 	local index = 1
-- 	local returnData = {}
-- 	for i=1,#result, 2 do
-- 		local data = {}
-- 		data[1] = result[index]
-- 		data[2] = result[index+1]
-- 		table.insert(returnData, data)
-- 		index = index + 2
-- 	end
-- 	return returnData
-- end