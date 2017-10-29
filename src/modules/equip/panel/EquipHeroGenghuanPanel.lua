
EquipHeroGenghuanPanel = class("EquipHeroGenghuanPanel", BasicPanel)
EquipHeroGenghuanPanel.NAME = "EquipHeroGenghuanPanel"

function EquipHeroGenghuanPanel:ctor(view, panelName)
    EquipHeroGenghuanPanel.super.ctor(self, view, panelName,true)
    self._proxy = self:getProxy(GameProxys.Equip)
    self.GeneralsConfig = require("excelConfig.GeneralsConfig")
end

function EquipHeroGenghuanPanel:finalize()
    EquipHeroGenghuanPanel.super.finalize(self)
end

function EquipHeroGenghuanPanel:initPanel()
	EquipHeroGenghuanPanel.super.initPanel(self)
	self:setTitle(true,"equipup",true)
    local mainPanel = self:getChildByName("mainPanel")
    self:setNewbgImg({Widget = mainPanel})
    self.changeBtn = self:getChildByName("mainPanel/changeBtn")
end

function EquipHeroGenghuanPanel:registerEvents()
	EquipHeroGenghuanPanel.super.registerEvents(self)
	self:addTouchEventListener(self.changeBtn,self.onChangeBtnTouch)
end

function EquipHeroGenghuanPanel:onClosePanelHandler()
    EquipHeroGenghuanPanel.super.onClosePanelHandler(self)
    self:hide()
end

function EquipHeroGenghuanPanel:onShowHandler(pos)
	self._pos = pos or  self._pos
	self.info = nil 
	self.oldRoleSpr = nil
	self:updateListView()
end

function EquipHeroGenghuanPanel:updateListView()
	local datas = self._proxy:getGeneralInfoByStoreHouse()
	local listView = self:getChildByName("mainPanel/heroListView")
	self:renderListView(listView, datas, self,self.renderItems)
end

function EquipHeroGenghuanPanel:renderItems(items, data, index)
	for k = 1, 3 do
		local item = items:getChildByName("HeroCardImg"..k)	
		item:setVisible(false)
		if data[k] then
			item:setVisible(true)
			local info = data[k]
			self:renderItem(item, info)
		end
	end
end

function EquipHeroGenghuanPanel:renderItem(item, info)
	self:addTouchEventListener(item, self.onItemTouch)
	item.info = info
	local terrainImg = item:getChildByName("terrainImg") --地形图片
	--local roleImg = item:getChildByName("roleImg") --角色图
	local lvAndNameImg = item:getChildByName("lvAndNameImg") --名字和等级底图
	local lvLab = lvAndNameImg:getChildByName("lvLab") 
	local nameLab = lvAndNameImg:getChildByName("nameLab")

	local quality = self.GeneralsConfig[info.generalId].color
	local url = "images/equip/wujiangBg"..quality..".png"
	TextureManager:updateImageView(item, url)
	url = "images/equip/tiao"..quality..".png"
	TextureManager:updateImageView(lvAndNameImg, url)
	local name = self.GeneralsConfig[info.generalId].name
	nameLab:setString(name)
	lvLab:setString(info.generalLevel)
	--更新武将图片 更新地形图
	if item:getChildByName("roleSpr") then
		item:removeChildByName("roleSpr")
	end
	local roleSpr = TextureManager:createSprite("images/equip/wjsmall.png")
	item:addChild(roleSpr)
	roleSpr:setAnchorPoint(0,0)
	roleSpr:setName("roleSpr")
end

function EquipHeroGenghuanPanel:onItemTouch(sender)
	self.info = sender.info
	local roleSpr = sender:getChildByName("roleSpr")
	NodeUtils:renderBrightness(roleSpr,2,2,2,2)
	print("RoleSpr弄亮")
	if self.oldRoleSpr and self.oldRoleSpr~=roleSpr then
		print("self.oldRoleSpr被还原")
		NodeUtils:renderBrightness(self.oldRoleSpr)
	end
	self.oldRoleSpr = roleSpr
end

function EquipHeroGenghuanPanel:onChangeBtnTouch()
	if self.info then
		local data = {}
		data.generalId = self.info.generalId
		data.position = self._pos
		self:dispatchEvent(EquipEvent.CHANGGE_HERO,data)
	else
		self:showSysMessage("选择需要出战的武将！")
	end
	self.info = nil 
end
