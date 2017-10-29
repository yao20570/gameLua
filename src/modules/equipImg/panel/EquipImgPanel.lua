
EquipImgPanel = class("EquipImgPanel", BasicPanel)
EquipImgPanel.NAME = "EquipImgPanel"

function EquipImgPanel:ctor(view, panelName)
    EquipImgPanel.super.ctor(self, view, panelName, true)
end

function EquipImgPanel:finalize()
    EquipImgPanel.super.finalize(self)
end

function EquipImgPanel:initPanel()
	EquipImgPanel.super.initPanel(self)


	self.bottomPanel = self:getChildByName("bottomPanel")
	self.bottomPanel:setClippingEnabled(true)
	local topPanel = self:getChildByName("topPanel")

 	self:adjustBootomBg(self.bottomPanel, topPanel, true)
 	self.proxy = self:getProxy(GameProxys.Equip)
 	
 	self.skLab = self:getChildByName("topPanel/infoPanel/SkillLab")
 	self.skDescLab = self:getChildByName("topPanel/infoPanel/Label_22_0")
 	self.skLab:setVisible(false)
 	self.skDescLab:setVisible(false)

 	self.nameLab = self:getChildByName("topPanel/infoPanel/nameImg/nameLab")
 	self.nameLab:ignoreContentAdaptWithSize(false)
 	local size = self.nameLab:getContentSize()
 	self.nameLab:setContentSize(cc.size(size.width + 3, 100))
 	self.LvLab = self:getChildByName("topPanel/infoPanel/nameImg/LvLab")
 	self.iconImg = self:getChildByName("topPanel/infoPanel/iconImg")

 	self.equipInfo = {{imgId = 5, name = TextWords:getTextWord(732), sxId = 12}, {imgId = 8, name = TextWords:getTextWord(724), sxId = 4}, 
 					  {imgId = 10, name = TextWords:getTextWord(726), sxId = 6}, {imgId = 6, name = TextWords:getTextWord(733), sxId = 11},
 					  {imgId = 9, name = TextWords:getTextWord(725), sxId = 5}, {imgId = 11, name = TextWords:getTextWord(727), sxId = 7}}
 	for k,v in pairs(self.equipInfo) do
 		self["lab"..v.sxId] = self:getChildByName("topPanel/infoPanel/Lab"..v.sxId)
 		self["DescLab"..v.sxId] = self:getChildByName("topPanel/infoPanel/DescLab"..v.sxId)
 		self["icon"..v.sxId] = self:getChildByName("topPanel/infoPanel/icon"..v.sxId.."Img")
 	end
end

function EquipImgPanel:registerEvents()
	EquipImgPanel.super.registerEvents(self)
end

function EquipImgPanel:onClosePanelHandler()
	self.isCanTouch = false
    self.view:dispatchEvent(EquipImgEvent.HIDE_SELF_EVENT)
end

function EquipImgPanel:onShowHandler()
	self.allData = self.proxy:getGeneralinfo()
	self.config = ConfigDataManager:getConfigData(ConfigData.GeneralsConfig)
	if self.read == nil then
		self.read = true
		self:initView()
		self:initTouch()
	else
		self:updateView(self.curIndex, true)
	end
	self.isCanTouch = true
end

function EquipImgPanel:initView()
	local size = self.bottomPanel:getContentSize()
	local x, y = size.width/2, size.height/2
	self.maxZOrder = #self.config + 1
	self.curIndex = 1
	for i=1,#self.config do
		self["item"..i] = ItemChild:create(self.config[i], self)
		self["item"..i]:setPosition(x + (i - 1) * 140, y)
		local scale = 1.2 - (i - 1)*0.1
		scale = scale >= 1 and scale or 1
		self["item"..i]:setScale(scale)
		self.bottomPanel:addChild(self["item"..i])
		local zOrder
		if i < self.curIndex then
			zOrder = i
		elseif i == self.curIndex then
			zOrder = self.maxZOrder
		else
			zOrder = #self.config - i
		end
		self["item"..i]:setLocalZOrder(zOrder)
		self["item"..i].layout:setVisible(i ~= self.curIndex)
	end
	self:renderTopPanel(1)
end

function EquipImgPanel:initTouch()
	local listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(false)

    listenner:registerScriptHandler(function(touch, event)    
    	local location = touch:getLocation()   
    	x = location.x
    	return self.isCanTouch    
    end, cc.Handler.EVENT_TOUCH_BEGAN )  
    listenner:registerScriptHandler(function(touch, event)    
    	local location = touch:getLocation() 
    	local function updateIdx(isRight)
    		if isRight then
    			if self.curIndex > 1 then
					self.curIndex = self.curIndex - 1
				end
    		else
    			if self.curIndex < self.maxZOrder - 1 then
					self.curIndex = self.curIndex + 1
				end
    		end
    		self:updateView(self.curIndex)
    	end
    	if location.x - x > 30 then
    		updateIdx(true)
    	elseif location.x - x < -30 then
    		updateIdx()
    	end
    end, cc.Handler.EVENT_TOUCH_ENDED ) 

    local eventuDispatcher = self.bottomPanel:getEventDispatcher()
    eventuDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.bottomPanel)
end

function EquipImgPanel:updateView(index, forceUpdate)
	if forceUpdate then
		self.allData = self.proxy:getGeneralinfo()
	end
	self.curIndex = index
	local size = self.bottomPanel:getContentSize()
	local x, y = size.width/2, size.height/2
	for i=1,#self.config do
		local offset = math.abs(index - i)
		local scale = 1.2 - offset*0.1
		scale = scale >= 1 and scale or 1
		local moveTo = cc.MoveTo:create(0.2, cc.p(x + (i - index) * 140, y))
		local scaleTo = cc.ScaleTo:create(0.2, scale)
		local action = cc.Spawn:create(moveTo, scaleTo, cc.CallFunc:create(function()
			self["item"..i].layout:setVisible(i ~= index)
			local zOrder
			if i < index then
				zOrder = i
			elseif i == index then
				zOrder = self.maxZOrder
			else
				zOrder = self.maxZOrder - 1 - i
			end
			self["item"..i]:setLocalZOrder(zOrder)
		end))
		self["item"..i]:runAction(action)
	end
	self:renderTopPanel(index, forceUpdate)
end

function EquipImgPanel:renderTopPanel(index, forceUpdate)
	local data = self.config[index]
	local equipData = nil
	for k,v in pairs(self.allData) do
		if v.generalId == index then
			equipData = v
			break
		end
	end
	local isHas = equipData ~= nil
	if (data == nil or self.oldIdx == index) and (not forceUpdate) then
		return
	end
	self.oldIdx = index
	local infoPanel = self:getChildByName("topPanel/infoPanel")
	infoPanel:stopAllActions()
	infoPanel:setOpacity(255)
	local function render()
		local name = string.format("images/generals/%d.png", 1)
		TextureManager:updateImageView(self.iconImg, name)
		self.nameLab:setString(data.name)
		self.nameLab:setColor(ColorUtils:getColorByQuality(data.color))
		--暂时没有等级数据
		local lv = isHas and equipData.generalLevel or TextWords:getTextWord(756)
		self.LvLab:setString("Lv."..lv)
		local propertyData = StringUtils:jsonDecode(data.property)
		for i=1,6 do
			local infoData = self.equipInfo[i]
			local otherInfo = self.proxy:getPlusById(index)
			local info = nil
			if otherInfo ~= nil then
				info = otherInfo[infoData.sxId]
			end
 			self["lab"..(infoData.sxId)]:setString(infoData.name)
 			local imageName = string.format("images/littleIcon/%d.png", infoData.imgId)
 			TextureManager:updateImageView(self["icon"..(infoData.sxId)], imageName)
 			local percent = "0"
 			if propertyData[i] ~= nil then
 				percent = tostring(propertyData[i][2]/100)
 			end
 			if info ~= nil then
 				percent = tostring(tonumber(percent) + info)
 			end
 			self["DescLab"..(infoData.sxId)]:setString("+" .. percent .. "%")
		end
	end
	if self.first == nil then
		render()
		self.first = true
		return
	end
	local FadeIn = cc.FadeIn:create(0.3)
	local FadeOut = cc.FadeOut:create(0.3)
	local callback = cc.CallFunc:create(render)
	local action = cc.Sequence:create(FadeOut, callback, FadeIn)
	infoPanel:runAction(action)
end






ItemChild = class("ItemChild", function()
	return ccui.ImageView:create()
end)

function ItemChild:create(data, parent)
	local ret = ItemChild.new()
	ret:init(data, parent)
	return ret
end

function ItemChild:init(data, parent)
	self._parent = parent
	local color = data.color
	local id = 1
	local name = string.format("images/equip/wujiangBg%d.png", color)
	TextureManager:updateImageView(self, name)
	name = string.format("images/generalsSmall/%d.png", id)
	local icon = TextureManager:createImageView(name)
	local size = self:getContentSize()
	icon:setPosition(size.width/2, size.height/2)
	self:addChild(icon)
	self.id = data.ID
	icon:setTouchEnabled(true)
	self:setTouchEnabled(true)
	ComponentUtils:addTouchEventListener(self, self.callback, nil, self)
	ComponentUtils:addTouchEventListener(icon, self.callback, nil, self)


	local bgSize = icon:getContentSize()

	local nameBg = cc.LayerColor:create(cc.c4b(0,0,0,150))
    nameBg:setContentSize(cc.size(bgSize.width, bgSize.height*0.2))
    nameBg:setAnchorPoint(0,0)
    icon:addChild(nameBg)

    local nameLab = ccui.Text:create()
    nameLab:setFontName(GlobalConfig.fontName)
    nameLab:setFontSize(20)
    nameLab:setString(data.name)
    nameLab:setPosition(bgSize.width/2, bgSize.height*0.1)
    nameLab:setColor(ColorUtils:getColorByQuality(color))
    icon:addChild(nameLab)



	self.layout = cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.layout:setContentSize(bgSize)
    self.layout:setAnchorPoint(0,0)
    icon:addChild(self.layout)
end

function ItemChild:callback()
	self.oldId = self.id
	self._parent:updateView(self.id)
end