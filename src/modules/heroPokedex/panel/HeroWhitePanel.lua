--
-- Author: zlf
-- Date: 2016年11月24日20:20:35
-- 白色英雄


HeroWhitePanel = class("HeroWhitePanel", BasicPanel)
HeroWhitePanel.NAME = "HeroWhitePanel"

local COLOR = 1

function HeroWhitePanel:ctor(view, panelName)
    HeroWhitePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function HeroWhitePanel:finalize()
    -- self._allItem有可能为nil? 5961 【新UI】点开“科技”标签出现报错 如图
	for k,v in pairs(self._allItem or {}) do
		-- if v.effect ~= nil then
		-- 	v.effect:finalize()
		-- 	self._allItem[k].effect = nil
		-- end
        v.uiHeroCard:finalize()
		v:removeFromParent()
	end
	self._allItem = {}

	self.isRender = false

	if self.listenner ~= nil then
		local touchPanel = self:getChildByName("touchPanel")
        local eventDispatcher = touchPanel:getEventDispatcher()
        eventDispatcher:removeEventListenersForTarget(touchPanel)
        self.listenner = nil
    end

    HeroWhitePanel.super.finalize(self)
end

function HeroWhitePanel:initPanel()
    HeroWhitePanel.super.initPanel(self)

    self._proxy = self:getProxy(GameProxys.Hero)
    local heroConfig = ConfigDataManager:getConfigData(ConfigData.HeroConfig)
   	self._item = self:getChildByName("middlePanel/imgHeroCard")
   	self._item:setVisible(false)
    
--   	--位置不知道为什么偏了，强制调整
--   	local size = self._item:getContentSize()
--	local x, y = self._item:getPosition()
--	local heroIcon = self._item:getChildByName("heroIcon")
--	local heroName = self._item:getChildByName("heroName")
--	local imgHeadBg = self._item:getChildByName("imgHeadBg")
--	local imgColor = self._item:getChildByName("imgColor")
--	local imgGuo = self._item:getChildByName("imgGuo")
--	-- local bgImg = self._item:getChildByName("item")
--    local commentBtn = self._item:getChildByName("commentBtn")
--	local iconx, icony = heroIcon:getPosition()
--	local namex, namey = heroName:getPosition()
--	-- local imgx, imgy = bgImg:getPosition()
--	local newIconX = iconx + size.width * 0.5
--	local newIconY = icony + size.height * 0.4
--	local iconOffSetX = newIconX - iconx
--	local iconOffSetY = newIconY - icony
--	heroIcon:setPosition(newIconX,newIconY )
--	imgHeadBg:setPosition(imgHeadBg:getPositionX() + iconOffSetX ,imgHeadBg:getPositionY() + iconOffSetY )
--	imgColor:setPosition(imgColor:getPositionX() + iconOffSetX ,imgColor:getPositionY() + iconOffSetY )
--	imgGuo:setPosition(imgGuo:getPositionX() + iconOffSetX ,imgGuo:getPositionY() + iconOffSetY )
--	commentBtn:setPosition(commentBtn:getPositionX() + iconOffSetX ,commentBtn:getPositionY() + iconOffSetY )
--	heroName:setPosition(heroName:getPositionX() + iconOffSetX ,heroName:getPositionY() + iconOffSetY )
--	-- heroName:setPosition(namex + size.width * 0.5, namey + size.height * 0.5)
--	-- bgImg:setPosition(imgx + size.width * 0.5, imgy + size.height * 0.5)

--    self:addTouchEventListener(commentBtn, self.onCommentBtn)
    self._allItem = {}

    self.isRender = false
end

function HeroWhitePanel:doLayout()
	TimerManager:addOnce(30, function()
		local middlePanel = self:getChildByName("middlePanel")
		local tabspanel = self:getTabsPanel()
		NodeUtils:adaptiveTopPanelAndListView(middlePanel, nil, nil, tabspanel)
	end, self)
	
end

function HeroWhitePanel:onShowHandler()
	local mainPanel = self:getPanel(HeroPokedexPanel.NAME)
	--设置移动回调,当回调的时候,特效位置改变
	mainPanel:setMoveCallBack(handler(self,self.moveCallback))

	if self.config == nil then
		self.config = mainPanel:getConfigByColor(COLOR)
		---[[这样做的目的,是为了,避免只有4个或者三个的时候,会有不连续的问题
		local cloneconf = clone(self.config)
		table.insertto(self.config,cloneconf,#self.config+1)
		--]]
	end
	local x,y  = self._item:getPosition()

	if not self.isRender then
		self.isRender = true
		for i=1,#self.config do
			local v = self.config[i]
			self._allItem[i] = self._item:clone()
			local middlePanel = self:getChildByName("middlePanel")
			self._allItem[i]:setPosition(x, y)
			self._allItem[i].itemData = v
			middlePanel:addChild(self._allItem[i])
			mainPanel:renderItem(self._allItem[i], v)
		end
	end
	mainPanel:adjustAllItem(self._allItem, x, 1, true, #self.config)

	local touchPanel = self:getChildByName("touchPanel")

	mainPanel:addTouch(touchPanel, self)

	local dir = -1
	for i=1,2 do
		local btn = self:getChildByName("middlePanel/btn"..i)
		btn.dir = dir
		dir = dir * -1
		self:addTouchEventListener(btn, self.dirBtnTouch)
	end

end

function HeroWhitePanel:showMiddlePanel( isShow )
    local middlePanel = self:getChildByName("middlePanel")
    middlePanel:setVisible(isShow)
end

function HeroWhitePanel:moveCallback(centerIdx)

end

function HeroWhitePanel:getAllItems()
	return self._allItem
end

function HeroWhitePanel:dirBtnTouch(sender)
	local mainPanel = self:getPanel(HeroPokedexPanel.NAME)
	mainPanel:dirBtnTouch(sender.dir, self)
end

-- 类型  1-兵营 2-武将 3-太学院 4-战法 5-军师 
function HeroWhitePanel:onCommentBtn(sender)
	local mainPanel = self:getPanel(HeroPokedexPanel.NAME)
    local proxy = self:getProxy(GameProxys.Comment)
    proxy:toCommentModule(2, mainPanel._typeId, mainPanel._heroName)
end