--
-- Author: zlf
-- Date: 2016-04-19
-- 批量分解界面
ConsigliereResolvePanel = class("ConsigliereResolvePanel", BasicPanel)
ConsigliereResolvePanel.NAME = "ConsigliereResolvePanel"

function ConsigliereResolvePanel:ctor(view, panelName)
    ConsigliereResolvePanel.super.ctor(self, view, panelName,320)

    self:setUseNewPanelBg(true)
end

function ConsigliereResolvePanel:finalize()
    ConsigliereResolvePanel.super.finalize(self)
end

function ConsigliereResolvePanel:initPanel()
	ConsigliereResolvePanel.super.initPanel(self)

	self:setLocalZOrder( PanelLayer.UI_Z_ORDER_2 )

	self:setTitle(true, self:getTextWord(270019))
	-- self.proxy = self:getProxy(GameProxys.Consigliere)
	-- local close_btn = self:getChildByName("Panel_Resolve/btn_close")
	-- self:addTouchEventListener(close_btn, function(sender)
	-- 	self:hide()
	-- end)
	-- local title = self:getChildByName("Panel_Resolve/lab_title")
	-- title:setString(TextWords:getTextWord(270019))

	self.m_checks = {}
	for i=1,4 do
		local box = self:getChildByName("Panel_Resolve/Panel_check_"..i)
		-- self["box"..i] = box
		box.id = i
		box:setBackGroundColorType(0)
		self:addTouchEventListener(box, self.checkBox)
		self.m_checks[i] = self:getChildByName( "Panel_Resolve/Img_check_"..i )
		-- local lab = self:getChildByName("Panel_Resolve/lab_"..i)
		-- if i ~= 4 then
		-- 	lab:setString(TextWords:getTextWord(270000+i))
		-- else
		-- 	lab:setString(TextWords:getTextWord(270022))
		-- end
	end

	local sure_btn = self:getChildByName("Panel_Resolve/btn_yes")
	self:addTouchEventListener(sure_btn, self.onShowResolveView)

	local no_btn = self:getChildByName("Panel_Resolve/btn_no")
	self:addTouchEventListener(no_btn, function(sender)
		self:hide()
	end)

	local lab_desc = self:getChildByName("Panel_Resolve/lab_desc")
	lab_desc:setString(TextWords:getTextWord(270023))
end

function ConsigliereResolvePanel:onShowResolveView(sender)
	--local data = self:getInfo()
	local proxy = self:getProxy(GameProxys.Consigliere)
	local allInfo = proxy:getAllInfo()

	local idsData = {}
	local starList = {}
	for i, img in ipairs(self.m_checks) do
		if img:isVisible() then --选中星级
			table.insert( starList, i ) --星级列表
			for _,v in pairs(allInfo) do
				if v.pos==0 then --闲置的军师加入分解列表
					local conf = proxy:getDataById( v.typeId )
					local quality = conf.quality
					if quality==i then  
						table.insert( idsData, v.id )
					end
				end
			end
		end
	end
	if #idsData == 0 then
		self:showSysMessage(TextWords:getTextWord(270047))
		return
	end
	--self.view:dispatchEvent(ConsigliereEvent.SHOW_OTHER_VIEW, {data = data, type = 0})
	-- local panel = self:getPanel(ConsigliereTipsPanel.NAME)
	-- panel:show( {data = data, type = 0} )
	local data = {}
	data.starList = starList
	data.ids = idsData
	local panel = self:getPanel( ConsigliereTipsPanel.NAME )
	panel:show( data )
end

function ConsigliereResolvePanel:checkBox(sender)
	-- local state = sender:getSelectedState()
	local id = sender.id
	self:setImgSelected( sender.id )
	-- if state then
	-- 	--取消
	-- 	local startArr = self.proxy:getQuiltyById(id)
	-- 	for k,v in pairs(self.info) do
	-- 		if v.quilty == id then
	-- 			self.info[k] = nil
	-- 		end
	-- 	end
	-- else
	-- 	--增加
	-- 	local startArr = self.proxy:getQuiltyById(id)
	-- 	for k,v in pairs(startArr) do
	-- 		if v.quilty == id then
	-- 			table.insert(self.info, v)
	-- 		end
	-- 	end
	-- end
	-- self.proxy:Reset()
	-- for k,v in pairs(self.info) do
	-- 	self.proxy:addData(v.typeId)
	-- end
end

-- function ConsigliereResolvePanel:getInfo()
-- 	if #self.info == 0 then
-- 		return {}
-- 	end
-- 	local data = {}
-- 	local flag = {}
-- 	local index = 1
-- 	local count = 0
-- 	for k,v in pairs(self.info) do
-- 		local configData = self.proxy:getDataById(v.typeId)
-- 		local resolve = StringUtils:jsonDecode(configData.resolve)
-- 		for key,value in pairs(resolve) do
-- 			local dataInfo = {}
-- 			dataInfo.id = value[2]
-- 			dataInfo.num = value[3]*(v.num-v.fightnum)
-- 			count = count + dataInfo.num
-- 			print("num====",dataInfo.num)
-- 			local itemData = ConfigDataManager:getItemConfig()[value[2]]
-- 			dataInfo.name = itemData.name
-- 			dataInfo.power = value[1]
-- 			if not flag[value[2]] then
-- 				flag[value[2]] = index
-- 				data[index] = dataInfo
-- 				index = index + 1
-- 			else
-- 				data[flag[value[2]]].num = data[flag[value[2]]].num + dataInfo.num
-- 			end
-- 		end
-- 	end
-- 	if count == 0 then
-- 		return {}
-- 	end
-- 	-- local count = 0
-- 	-- for k,v in pairs(data) do
-- 	-- 	count = cou
-- 	-- end
-- 	return data
-- end

function ConsigliereResolvePanel:registerEvents()
	ConsigliereResolvePanel.super.registerEvents(self)
end

function ConsigliereResolvePanel:onShowHandler()
	--self:initView()
	self:setImgSelected( false )
end

-- function ConsigliereResolvePanel:initView()
-- 	self.info = {}
-- 	for i=1,4 do
-- 		self["box"..i]:setSelectedState(false)
-- 	end
-- end

function ConsigliereResolvePanel:setImgSelected( flag )
	flag = flag or false
	for i, img in ipairs(self.m_checks) do
		if type(flag)=="number" then
			if i==flag then
				img:setVisible( not img:isVisible() )
			end
		else
			img:setVisible( flag )
		end
	end
end