
ConsigliereImgAllPanel = class("ConsigliereImgAllPanel", BasicPanel)
ConsigliereImgAllPanel.NAME = "ConsigliereImgAllPanel"

function ConsigliereImgAllPanel:ctor(view, panelName)
    ConsigliereImgAllPanel.super.ctor(self, view, panelName,true )

    self:setUseNewPanelBg(true)
end

function ConsigliereImgAllPanel:finalize()
    if self._uiInfoPanel ~= nil then
        self._uiInfoPanel:finalize()
        self._uiInfoPanel = nil
    end
    ConsigliereImgAllPanel.super.finalize(self)
end

function ConsigliereImgAllPanel:initPanel()
	ConsigliereImgAllPanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)

    self:setTitle(true,"tujian", true)
    
    self.listView = self:getChildByName("ListView_1")
    self.proxy = self:getProxy(GameProxys.Consigliere)
end

function ConsigliereImgAllPanel:doLayout()
    local panel_top = self:getChildByName("panel_top")
    NodeUtils:adaptiveListView(self.listView, GlobalConfig.downHeight, panel_top)
end

function ConsigliereImgAllPanel:registerEvents()
	ConsigliereImgAllPanel.super.registerEvents(self)
end

function ConsigliereImgAllPanel:onShowHandler()
    local newData = {}
    local arrList = self.proxy:getAllSortConsig()
    for i,data in ipairs(arrList) do
        local index = math.floor((i-1)/3)+1
        newData[index] = newData[index] or {}
        table.insert( newData[index], data )
    end
    self:renderListView(self.listView, newData, self, self.renderItemsPanel )
end

function ConsigliereImgAllPanel:renderItemsPanel(itemPanel, datas)
    for i=1,3 do
        local item = itemPanel:getChildByName( "Panel_item"..i )
        if not item then break end
        item:setVisible( not not datas[i] )
        if datas[i] then
            self:renderItemPanel( item, datas[i] )
        end
    end
end

function ConsigliereImgAllPanel:renderItemPanel(item, data)
    local typeId = data.ID
    local isGrey = self.proxy:getInfoByTypeId(typeId)
    ComponentUtils:renderConsigliereItem( item, typeId, nil, nil, nil, nil, not isGrey ,nil,nil,true)
    item.typeId = typeId
    self:addTouchEventListener(item, self.showIconInfo)
end

function ConsigliereImgAllPanel:showIconInfo(sender)
    local data = {}
    data.adviserInfo = {typeId = sender.typeId}
    if self._uiInfoPanel == nil then
        self._uiInfoPanel = UIAdviserInfo.new(self.view, data)
    else
        self._uiInfoPanel:show(data)
    end
end



-- function ConsigliereImgAllPanel:registerItemEvents(item, data, index)
-- 	item:setVisible(true)
-- 	for i=1, 3 do
-- 		local oneItem = item:getChildByName("item_"..i)
-- 		oneItem:setVisible(false)
-- 		if data[i] ~= nil then
-- 			self:renderOneItem(oneItem,data[i],i)
-- 		end
-- 	end
-- end

-- function ConsigliereImgAllPanel:renderOneItem(item,data,index)
-- 	item:setVisible(true)
-- 	local name = item:getChildByName("name")
-- 	local img_icon = item:getChildByName("img_icon")
-- 	local touchPanel = item:getChildByName("touchPanel")
-- 	local skillImg = item:getChildByName("skillImg")
-- 	name:setString(data.name)
-- 	local url = string.format("images/consigliereImg/101.png")
--     if img_icon.iconImg == nil then
--         img_icon.iconImg = TextureManager:createImageView(url)
--         img_icon.iconImg:setLocalZOrder(2)
--         img_icon:addChild(img_icon.iconImg)
--     else
--         TextureManager:updateImageView(img_icon.iconImg,url)
--     end
--     img_icon.iconImg.isHave = data.isHave
--     if data.isHave == true then
--     	img_icon.iconImg:setColor(ColorUtils:getColorByQuality(1))
--     else
--     	img_icon.iconImg:setColor(ColorUtils:getColorByQuality(8))
--     end
--     touchPanel.data = data
--     self:touchItem(touchPanel,img_icon.iconImg)
--     local star = {}
--     for i = 1,5 do
--     	star[i] = touchPanel:getChildByName("star_"..i)
--     	if i <= data.quality then
--     		star[i]:setVisible(true)
--     	else
--     		star[i]:setVisible(false)
--     	end
--     end
--     print("data.skillID", data.skillID, type(data.skillID), tonumber(data.skillID))

--     if data.skillID ~= "" then
--     	skillImg:setVisible(true)
--     else
--     	skillImg:setVisible(false)
--     end
-- end

-- function ConsigliereImgAllPanel:touchItem(item,icon)
-- 	if item.isAdd == true then return end
-- 	item.isAdd = true
--     local function call(sender, eventType)
--         if eventType == ccui.TouchEventType.ended then
--             if icon.isHave == true then
--             	icon:setColor(ColorUtils:getColorByQuality(1))
--             else
--             	icon:setColor(ColorUtils:getColorByQuality(8))
--             end
--             self:onCallItemTouch(sender)
--         elseif eventType == ccui.TouchEventType.began then
--             AudioManager:playButtonEffect()
--             if icon.isHave == true then
--             	icon:setColor(ColorUtils:getColorByQuality(8))
--             else
--             	icon:setColor(ColorUtils:getColorByQuality(1))
--             end
--         elseif eventType == ccui.TouchEventType.canceled then
--             if icon.isHave == true then
--             	icon:setColor(ColorUtils:getColorByQuality(1))
--             else
--             	icon:setColor(ColorUtils:getColorByQuality(8))
--             end
--         end
--     end
--     item:addTouchEventListener(call)
-- end

-- function ConsigliereImgAllPanel:onCallItemTouch(sender)
-- 	local panel = self:getPanel(ConsigliereImgInfoPanel.NAME)
--     panel:show(sender.data)
-- end

function ConsigliereImgAllPanel:onClosePanelHandler()
    self:dispatchEvent(ConsigliereImgEvent.HIDE_SELF_EVENT)
end

-- function ConsigliereImgAllPanel:touchBtn(sender)
-- 	self:updateInfo(sender.index)
-- end