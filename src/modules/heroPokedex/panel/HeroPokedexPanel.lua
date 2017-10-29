--
-- Author: zlf
-- Date: 2016年9月1日11:17:50
-- 英雄图鉴主界面

HeroPokedexPanel = class("HeroPokedexPanel", BasicPanel)
HeroPokedexPanel.NAME = "HeroPokedexPanel"
HeroPokedexPanel.HERO_MAX_STAR = 5

local offsetX = 320
local time = 0.15


function HeroPokedexPanel:ctor(view, panelName)
    HeroPokedexPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function HeroPokedexPanel:finalize()

    -- if self._ccbColor then
    --     self._ccbColor:finalize()
    --     self._ccbColor = nil
    -- end
    -- if self._ccbColorEff then
    -- 	self._ccbColorEff:finalize()
    -- 	self._ccbColorEff = nil
    -- end

    HeroPokedexPanel.super.finalize(self)

end

function HeroPokedexPanel:initPanel()
	HeroPokedexPanel.super.initPanel(self)


	self:setBgType(ModulePanelBgType.NONE)

	local tabControl = UITabControl.new(self)
	--调高标签页的层级   不然点击标签页的时候会回调touchend
	tabControl:setLocalZOrder(100)

    tabControl:addTabPanel(HeroWhitePanel.NAME, self:getTextWord(290019))
    tabControl:addTabPanel(HeroGreenPanel.NAME, self:getTextWord(290020))
    tabControl:addTabPanel(HeroBluePanel.NAME, self:getTextWord(290021))
    tabControl:addTabPanel(HeroVioletPanel.NAME, self:getTextWord(290022))
    tabControl:setTabSelectByName(HeroWhitePanel.NAME)

    self:setTitle(true, "tujian", true)


    self._tabControl = tabControl
    self._canMove = true

    local bttomPanel = self:getChildByName("Panel_11/bttomPanel")
    bttomPanel:setLocalZOrder(90)

    local talentLab = self:getChildByName("Panel_11/bttomPanel/infoLab")
    talentLab:ignoreContentAdaptWithSize(false) 
	talentLab:setContentSize(cc.size(500, 150))



    
	self._colors = {cc.c3b(255,255,255), cc.c3b(0,255,0), cc.c3b(0,0,255), cc.c3b(183,56,240)}

	-- self.allEffectName = {"rgb-tujian-lu", "rgb-tujian-lan", "rgb-tujian-zi", "rpg-wujiangpinzhi-huang"}

end

function HeroPokedexPanel:doLayout()

    local topPanel = self:getChildByName("topPanel")
    local bttomPanel = self:getChildByName("Panel_11")
    local panel = self._tabControl:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, panel)
    NodeUtils:adaptiveTopPanelAndListView(bttomPanel, nil, nil, panel)
end

function HeroPokedexPanel:registerEvents()
	HeroPokedexPanel.super.registerEvents(self)

--    local commentBtn = self:getChildByName("Panel_11/bttomPanel/commentBtn")
--    self:addTouchEventListener(commentBtn, self.onCommentBtn)
end

function HeroPokedexPanel:onShowHandler()
	if self.first ~= nil then
		local panel = self:getPanel(HeroWhitePanel.NAME)
		panel:show()
        panel:showMiddlePanel(false)
	end
	self.first = true
	self.isTouch = true
end

function HeroPokedexPanel:onAfterActionHandler()
    local panel = self:getPanel(HeroWhitePanel.NAME)
    panel:showMiddlePanel(true)
end

function HeroPokedexPanel:onClosePanelHandler()
	self._canMove = true
	self.isTouch = false
	local proxy = self:getProxy(GameProxys.Hero)
	proxy:sendNotification(AppEvent.PROXY_HERO_UPDATE_IMG)
	self.view:dispatchEvent(HeroPokedexEvent.HIDE_SELF_EVENT)
end

function HeroPokedexPanel:getConfigByColor(color)
	local heroConfig = ConfigDataManager:getConfigData(ConfigData.HeroConfig)

    local config = {}
    for k,v in pairs(heroConfig) do
    	if v.color == color and v.type ~= 1 then
    		table.insert(config, v)
    	end
    end
    return config
end

function HeroPokedexPanel:renderItem(item, data)

	item:setVisible(true)

    if item.uiHeroCard == nil then
        item.uiHeroCard = UIHeroCard.new(self, item)
    end

    local cardData = { }
    cardData.heroId = data.ID
    cardData.starNum = 0
    cardData.fightting = 0
    cardData.isDisableCCB = true
    item.uiHeroCard:updateData(cardData)
	item.uiHeroCard:setBtnCommentVisible(true)
end

--计算目标位置
--@return 1:位置
--@return 2:idx2 转换后的实际位置下标
local function calTargePosition(startX, idx, center, offsetX, maxHeroNum)
    local right = math.ceil((maxHeroNum - 1) / 2)
    local left = math.floor((maxHeroNum - 1) / 2)
    -- v3
    if idx - center >= 0 then
        -- 右边
        if idx - center <= right then
            -- 右边不动的部分
            return startX +(idx - center) * offsetX, idx
        else
            -- 右边变动的部分
            local idx2 = center -(left -(idx - center - right) + 1)
            -- center + (left-((idx-center+1)-right))
            return startX +(idx2 - center) * offsetX, idx2
        end
    else
        -- 左边
        if center - idx <= left then
            -- 左边不动的部分
            return startX +(idx - center) * offsetX, idx
        else
            -- 左边变动的部分
            local idx2 = center +(right -(center - left - idx)) + 1
            return startX +(idx2 - center) * offsetX, idx2
        end
    end
    -- v1
    -- return startX + (idx - center) * offsetX--原生位置计算
end

--[[
	@param items:根据颜色分类的widget的合集
	@param startX:中间位置的横坐标，记录起来用于做scale的计算
	@param center:items中居中的widget的在集合中的下标
	@param first:第一次初始化，不运行动作
	@param maxHeroNum:这个颜色的武将总数
]]
function HeroPokedexPanel:adjustAllItem(items, startX, center, first, maxHeroNum, finishCallback)
	if not self._canMove then
		return
	end
	


	self._centerIndex = center
	self._centerX = self._centerX or startX
	startX = startX or 310
	self._maxHeroNum = maxHeroNum or self._maxHeroNum
	local isUseAction = true
	for i=1, #items do
		local scale = i == center and 1 or 0.8
		items[i].index = i
		local toX,idx2 = calTargePosition(startX,i,center,offsetX,self._maxHeroNum)
		-- logger:info(string.format("i,idx2,center,差 = %d, %d, %d, %d",i,idx2,center,math.abs(idx2-center)))
		if math.abs(idx2-center)>1 then
			isUseAction = false
        else
			isUseAction = true
		end
		if first or (not isUseAction) then
			items[i]:setPositionX(toX)
			items[i]:setScale(scale)
			if items[i].effect ~= nil then
				items[i].effect:setVisible(scale == 1)
			end
			local name = items[i]:getChildByName("heroName")
--            local commentBtn = items[i]:getChildByName("commentBtn")
--			-- name:setVisible(scale == 1)
--            commentBtn:setVisible(scale == 1)
			if scale == 1 then
				self:updateBottomPanel(items[i].itemData)
			end
		else
			local target = cc.p(toX, items[i]:getPositionY())
			local move = cc.MoveTo:create(time, target)
			local scaleTo = cc.ScaleTo:create(time, scale)
			local action = cc.Spawn:create(move, scaleTo)
			local seq = cc.Sequence:create(action, cc.CallFunc:create(function(sender)
				if sender.effect ~= nil then
					sender.effect:setVisible(scale == 1)
				end
				local name = sender:getChildByName("heroName")
--                local commentBtn = sender:getChildByName("commentBtn")
--				-- name:setVisible(scale == 1)
--                commentBtn:setVisible(scale == 1)
				if scale == 1 then
					self:updateBottomPanel(sender.itemData)
				end
				if sender.index >= #items then
					self._canMove = true
				end
			end))
			items[i]:runAction(seq)
		end


	end


	--[[
	local color = items[center].itemData.color
	if self._ccbColor == color then--没有改变颜色
		if color > 0 and GlobalConfig.HeroColor2Effect[color] ~= nil then
			if self._ccbColorEff == nil then
				self._ccbColorEff = self:createUICCBLayer(GlobalConfig.HeroColor2Effect[color], items[center])
				local size = items[center]:getContentSize()
				self._ccbColorEff:setPosition(size.width-15,size.height/2-40)
				self._ccbColorEff:setLocalZOrder(1000)
			else
				self._ccbColorEff:changeParent(items[center])
			end
		end
	else--颜色改变了
		self._ccbColor = color
		if color > 0 and GlobalConfig.HeroColor2Effect[color] ~= nil then
			if self._ccbColorEff then
				self._ccbColorEff:finalize()
				self._ccbColorEff = nil
			end
			if self._ccbColorEff == nil then
				self._ccbColorEff = self:createUICCBLayer(GlobalConfig.HeroColor2Effect[color], items[center])
				local size = items[center]:getContentSize()
				self._ccbColorEff:setPosition(size.width-15,size.height/2-40)
				self._ccbColorEff:setLocalZOrder(1000)
			else
				self._ccbColorEff:changeParent(items[center])
			end
		end
	end
	--]]
	self:doMoveCallBack()

end

function HeroPokedexPanel:doMoveCallBack()
	if self.colorPanelMoveCallBack then
		self.colorPanelMoveCallBack(self._centerIndex)
	end
end

function HeroPokedexPanel:setMoveCallBack(colorPanelMoveCallBack)
	self.colorPanelMoveCallBack = colorPanelMoveCallBack
end


function HeroPokedexPanel:updateBottomPanel(data)
    self._heroName = data.name
    self._typeId   = data.ID

	local keys = {"lead", "brave", "sta"}
	local color = ColorUtils:getColorByQuality(data.color) or cc.c3b(255,255,255)
	for i=1,3 do
		local lab = self:getChildByName("Panel_11/bttomPanel/lab"..i)
		-- lab:setColor(color)
		lab:setString(data[keys[i]])
	end

	local iconImg = self:getChildByName("Panel_11/bttomPanel/Image_28/iconImg")
	local talentUrl = string.format("images/hero/talent%d.png", data.color)
	TextureManager:updateImageView(iconImg, talentUrl)

	local name = self:getChildByName("Panel_11/bttomPanel/name")



	local talentLab = self:getChildByName("Panel_11/bttomPanel/infoLab")

	

	local talentData = StringUtils:jsonDecode(data.talent)
	local talentStr = ""
	for k,v in pairs(talentData) do
		local heroTianFu = ConfigDataManager:getConfigById(ConfigData.HeroGiftConfig, v)
		if heroTianFu ~= nil then
			talentStr = talentStr .. heroTianFu.otherInfo
        	name:setString(heroTianFu.name)
		end
	end

	-- talentStr = string.gsub(talentStr, "\n", " ")
	talentLab:setString(talentStr)

	local infoLab = self:getChildByName("Panel_11/bttomPanel/talentLab")
	infoLab:setVisible(false)
	local pieceLab = self:getChildByName("Panel_11/bttomPanel/pieceLab")
	pieceLab:setVisible(false)
	local pieceImg = self:getChildByName("Panel_11/bttomPanel/Image_10_0")
	pieceImg:setVisible(false)
	

	local heroInfo = ConfigDataManager:getConfigById(ConfigData.HeroShowConfig, data.ID)

	if infoLab.richLabel == nil then
        infoLab.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        infoLab.richLabel:setPosition(cc.p(infoLab:getPosition()))
        infoLab:getParent():addChild(infoLab.richLabel)
    end
    infoLab.richLabel:setString(heroInfo.getinfo)
	if pieceLab.richLabel == nil then
        pieceLab.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        pieceLab.richLabel:setPosition(cc.p(pieceLab:getPosition()))
        pieceLab:getParent():addChild(pieceLab.richLabel)
    end

    if heroInfo.pieceGetInfo then
    	pieceImg:setVisible(true)
    end
    pieceLab.richLabel:setString(heroInfo.pieceGetInfo)

end

function HeroPokedexPanel:addTouch(panel, obj)
	local x, ox
	if obj.listenner == nil then
		obj.listenner = cc.EventListenerTouchOneByOne:create()
		obj.listenner:setSwallowTouches(false)

		obj.listenner:registerScriptHandler(function(touch, event)  
	        local location = touch:getLocation()   
	        x = location.x
	        ox = x
	        return (obj:isVisible() and self.isTouch)   
	    end, cc.Handler.EVENT_TOUCH_BEGAN )

		obj.listenner:registerScriptHandler(function(touch, event)
			local location = touch:getLocation()
	        self:touchMoved(location.x - ox, obj)
	        ox = location.x
	    end, cc.Handler.EVENT_TOUCH_MOVED )

	    obj.listenner:registerScriptHandler(function(touch, event)
	    	local location = touch:getLocation()
	    	self:touchEnded(obj, location.x - x)
	    end, cc.Handler.EVENT_TOUCH_ENDED ) 

	    local eventDispatcher = panel:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(obj.listenner, panel)
	end
end

--移动所有控件，计算缩放系数
function HeroPokedexPanel:touchMoved(x, obj)
	local data = obj:getAllItems()
	if data == nil then
		return
	end
	-- if self._centerIndex == 1 and x > 0 then
	-- 	return
	-- end

	-- if self._centerIndex == #data and x < 0 then
	-- 	return
	-- end

	--按着一直拖不松手
	--if data[#data]:getPositionX() <= self._centerX and x < 0 then
	--	return
	--end

	--if data[1]:getPositionX() >= self._centerX and x > 0 then
	--	return
	--end


	for k,v in pairs(data) do
		data[k]:setPositionX(data[k]:getPositionX() + x)
		local posX = data[k]:getPositionX()
		local offX = math.abs(posX - self._centerX)
		local scale = 1 - offX / self._centerX
		scale = scale < 0.8 and 0.8 or scale
		scale = scale > 1 and 1 or scale
		data[k]:setScale(scale)
	end
end

--触摸结束，调整所有item的位置
function HeroPokedexPanel:touchEnded(obj, dir)
	local data = obj:getAllItems()
	if data == nil then
		return
	end
	local index
	local minX = 100000
	for k,v in pairs(data) do
		local posX = data[k]:getPositionX()
		local offSetX = math.abs(posX - self._centerX)
		if offSetX < minX then
			minX = offSetX
			index = k
		end
	end
	if index == self._centerIndex then
		local x = data[index]:getPositionX()
        if math.abs(dir) > 20 then -- 位移超过20才进行切换
		    if dir < 0 then
			    index = index + 1
		    end
        
            if dir > 0 then
			    index = index - 1
		    end
        end
	end

	index = index > #data and #data or index
	index = index < 1 and 1 or index
	self:adjustAllItem(data, self._centerX, index)
end

function HeroPokedexPanel:dirBtnTouch(dir, obj)
	local data = obj:getAllItems()
	self._centerIndex = self._centerIndex or 1
	self._centerIndex = self._centerIndex + dir
	self._centerIndex = self._centerIndex < 1 and 1 or self._centerIndex
	self._centerIndex = self._centerIndex > #data and #data or self._centerIndex
	self:adjustAllItem(data, self._centerX, self._centerIndex)
	--防止熊孩子狂点
	self._canMove = false
end

-- 类型  1-兵营 2-武将 3-太学院 4-战法 5-军师 
function HeroPokedexPanel:onCommentBtn(sender)
    local proxy = self:getProxy(GameProxys.Comment)
    proxy:toCommentModule(2, self._typeId, self._heroName)
end


