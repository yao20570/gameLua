--
-- Author: zlf
-- Date: 2016-04-20
-- 分解物品展示界面
ConsigliereTipsPanel = class("ConsigliereTipsPanel", BasicPanel)
ConsigliereTipsPanel.NAME = "ConsigliereTipsPanel"

function ConsigliereTipsPanel:ctor(view, panelName)
    ConsigliereTipsPanel.super.ctor(self, view, panelName,400)

    self:setUseNewPanelBg(true)
end

function ConsigliereTipsPanel:finalize()
    ConsigliereTipsPanel.super.finalize(self)
end

function ConsigliereTipsPanel:initPanel()
	ConsigliereTipsPanel.super.initPanel(self)

    self._itemProxy = self:getProxy(GameProxys.Item)

	self:setTitle(true, self:getTextWord(270024))
	self.proxy = self:getProxy(GameProxys.Consigliere)
	self:setLocalZOrder(PanelLayer.UI_Z_ORDER_3)

	self.panel = self:getChildByName( "Panel_Tips/Panel_101" )
	self.panel:setBackGroundColorType(0)
	self.panelOldY=self.panel:getPositionY()

	self.sure_btn = self:getChildByName("Panel_Tips/btn_yes")

	local lab_desc = self:getChildByName("Panel_Tips/lab_desc")
	lab_desc:setString(self:getTextWord(270025))

	local no_btn = self:getChildByName("Panel_Tips/btn_no")
	self:addTouchEventListener( no_btn, function()
		self:hide()
	end)

	-- self.listView  = panel:getChildByName("ListView_216")
	-- local item = self.listView:getItem(0)
 --    self.listView:setItemModel(item)

    self._listView = self:getChildByName("Panel_Tips/ListView_17")
end

-- function ConsigliereTipsPanel:sendResolve(sender)
-- 	local data = {}
--     data.typeids = self.proxy:getRemoveId()
--     data.type = self.resolveType
--    	self.proxy:onTriggerNet260003Req(data)
-- end

function ConsigliereTipsPanel:registerEvents()
	ConsigliereTipsPanel.super.registerEvents(self)
end

--[[
data
  ids          客户端显示用
  starList, id 请求服务器用
]]
function ConsigliereTipsPanel:onShowHandler( data )
	self:initView( data.ids or {} )  
	self:addTouchEventListener( self.sure_btn, function()
		self.proxy:onTriggerNet260003Req( {star = data.starList, id=data.id } )  
	end)
end

function ConsigliereTipsPanel:initView( ids )
	local proxy = self:getProxy(GameProxys.Consigliere)

	--itemDataList
	local itemDataList = {}
	for i, id in ipairs( ids ) do
		local conf = proxy:getConfLvById( id ) or {}
		local sResolve = conf.resolve or "[]"
		local tResolve = StringUtils:jsonDecode( sResolve )

		for i, data in ipairs(tResolve) do
			local power = data[1] or 0
			local typeid = data[2] or 0
			local num = data[3] or 0
			local isNew = true
			for _,v in ipairs(itemDataList) do
				if v.typeid==typeid and v.power==power then
					v.num = v.num + num
					isNew = false
				end
			end
			if isNew then
				table.insert( itemDataList, {
					power = power,
					typeid=typeid,
					num= num,
				})
			end
		end
	end
	--logger:info("分解有几个 "..#itemDataList)
    if #itemDataList <5 then 
       self._listView:setVisible(false)
       self.panel:setVisible(true)
    else 
        self._listView:setVisible(true)
        self.panel:setVisible(false)
        local newData = {}
        local i = 0
	    for _,data in pairs(itemDataList) do
		i = i + 1
		local index = math.floor((i-1)/2)+1
		newData[index] = newData[index] or {}
		table.insert( newData[index], data )
  	    end
        --logger:info("重新分 组 "..#newData)
        self:renderListView(self._listView,newData,self,self.renderItemPanel)
    end

	--item
	local addY = -50
	for i=1,4 do
		local item = self.panel:getChildByName( "item"..i )
		if not item then
			break
		elseif itemDataList[i] then
			self:render( item , itemDataList[i] )
			item:setVisible(true)
			if i>2 then
				addY = 0
			end
		else
			item:setVisible(false)
		end
	end

	--自适应高度
	self.panel:setPositionY( self.panelOldY+addY )

	--self:renderListView(self.listView, data, self, self.render)
end

function ConsigliereTipsPanel:render(item, itemData)
	local icon = item:getChildByName("img_icon")
	local lab_name = item:getChildByName("lab_name")
	local lab_num = item:getChildByName("lab_num")

    local info = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID", itemData.typeid)
    if not info then
    	return 
    end
	lab_name:setString(info.name)
    lab_name:setColor(ColorUtils:getColorByQuality(info.color))

	lab_num:setString("+"..itemData.num.."")

    -- itemData.num = self._itemProxy:getItemNumByType(4024) -- 数量
	local uiIcon = icon.uiIcon
    if not uiIcon then
        uiIcon = UIIcon.new(icon, itemData, true, self)
        icon.uiIcon = uiIcon
    else
        uiIcon:updateData( itemData )
    end
    uiIcon:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
end

function ConsigliereTipsPanel:renderItemPanel(itemPanel,datas)
   -- print("调用 了 一次")
   for i=1,2 do
		local item = itemPanel:getChildByName( "item"..i )
		if not item then break end
		item:setVisible( datas[i] ~= nil )
		if datas[i] then
			self:render( item, datas[i] )
		end
	end 
end

