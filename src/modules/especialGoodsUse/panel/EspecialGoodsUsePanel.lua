
EspecialGoodsUsePanel = class("EspecialGoodsUsePanel", BasicPanel)
EspecialGoodsUsePanel.NAME = "EspecialGoodsUsePanel"

function EspecialGoodsUsePanel:ctor(view, panelName)
    EspecialGoodsUsePanel.super.ctor(self, view, panelName, 280)

    self:setUseNewPanelBg(true)
end

function EspecialGoodsUsePanel:finalize()
    EspecialGoodsUsePanel.super.finalize(self)
end

function EspecialGoodsUsePanel:initPanel()
	EspecialGoodsUsePanel.super.initPanel(self)
	self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)
	--点这里搜索
--	local lookUpPanel = self:getChildByName("Panel_1/Panel_13")
--    self._chatEditBox = ComponentUtils:addEditeBox(lookUpPanel,30,self:getTextWord(3154),nil,false,"images/newGui2/Windows.png")
--    self._chatEditBox:setMaxLength(40)
    self._contentTxt = self:getChildByName("Panel_1/memoTxt")
    local proxy = self:getProxy(GameProxys.Role)
    self.myName = proxy:getRoleName()
end

function EspecialGoodsUsePanel:onShowHandler(data)
	self.typeId = data.typeid
	self.num = data.num

	self.itemType = data.itemtype --物品类型

	-- self.titleTxt:setString(data.name)
	self:setTitle(true, data.name)
	
	local num = data.num
	print("特殊道具 num,typeid",num,data.typeid,data.name)
    local lookUpPanel = self:getChildByName("Panel_1/Panel_13")
    local imgBg = self:getChildByName("Panel_1/Image_42")
    local edit1 = lookUpPanel:getChildByName("editBox")
    local edit2 = imgBg:getChildByName("editBox")
    if edit1 then
        edit1:removeFromParent()
        self._chatEditBox = nil
    end
    if edit2 then
        edit2:removeFromParent()
        self._notiEditBox = nil
    end
    
    if num ~= 4 then    
        self._chatEditBox = ComponentUtils:addEditeBox(lookUpPanel,30,self:getTextWord(3154),nil,true)
        self._chatEditBox:setMaxLength(40)
        lookUpPanel:setVisible(true)
        imgBg:setTouchEnabled(false)
    else
        local function callback()
            self:setContentToLabel()
        end
        self._notiEditBox = ComponentUtils:addEditeBox(imgBg,800,"", callback)
        self._notiEditBox:setVisible(false)
        self._notiEditBox:setMaxLength(40)
        lookUpPanel:setVisible(false)
        imgBg:setTouchEnabled(true)
    end
    
    -- 如果存在 初始化
    if self._chatEditBox then
        self._chatEditBox:setText("")
        self._contentTxt:setString("")
    end
    if self._notiEditBox then
        self._notiEditBox:setText("")
        self._contentTxt:setString(self:getTextWord(4013))
        -- 颜色恢复
        self._contentTxt:setColor(cc.c3b(116, 98, 79))
    end

    

	if num and num == 0 then
		self.button_2:setVisible(false)
		self.button_4:setTitleText(self:getTextWord(100)) -- [[确定]]
		self._chatEditBox:setPlaceHolder(self:getTextWord(3154))
	elseif num and num == 1 then
		self.button_2:setVisible(false)
		self.button_4:setTitleText(self:getTextWord(100))
		self._chatEditBox:setPlaceHolder(self:getTextWord(4010))
	elseif num and num == 2  then --矿点勘察
		self.button_2:setVisible(true)
		self.button_4:setTitleText(self:getTextWord(109)) -- [[搜索]]
		self._chatEditBox:setPlaceHolder(self:getTextWord(4011))
	elseif num and num == 3 then  --私人发红包
		self._chatEditBox:setPlaceHolder(self:getTextWord(4012))
		self.button_2:setVisible(true)
		self.button_4:setTitleText(self:getTextWord(100))
	elseif num and num == 4 then  -- 公告  喇叭
		self.button_2:setVisible(false)
		self.button_4:setTitleText(self:getTextWord(100))
	elseif num and num == 5 then --矿点侦查，定位仪
	else
		self.button_2:setVisible(true)
	end
end

function EspecialGoodsUsePanel:registerEvents()
	EspecialGoodsUsePanel.super.registerEvents(self)
	for i=1,4 do
		self["button_"..i] = self:getChildByName("Panel_1/Button_"..i)
		self["button_"..i].index = i
		self:addTouchEventListener(self["button_"..i],self.touchButtonEvent)
	end
	-- self.titleTxt = self:getChildByName("Panel_1/Label_5")
	-- self.expendTxt = self:getChildByName("Panel_1/Label_6")

	local closeBtn = self:getCloseBtn()
	self:addTouchEventListener(closeBtn,self.closeThisPanel)
end

function EspecialGoodsUsePanel:touchButtonEvent(sender)
	if sender.index == 1 then
		self:dispatchEvent(EspecialGoodsUseEvent.HIDE_SELF_EVENT)
	elseif sender.index == 2 then
		local panel = self:getPanel(EspecialSelectPanel.NAME)
        panel:show()
	elseif sender.index == 3 then
		self:dispatchEvent(EspecialGoodsUseEvent.HIDE_SELF_EVENT)
	elseif sender.index == 4 then --去改名 搜索等功能都在这里
		local text 
        
        if self._chatEditBox then
            text = self._chatEditBox:getText()
        end

		if text == "" then 
            return 
        end	

		if self.num == 0 then
			if not StringUtils:checkStringSize(text) then
				self:showSysMessage(self:getTextWord(3156))
				return
			end
        elseif self.num == 1 then
			if not StringUtils:checkStringSize(text) then
				self:showSysMessage(self:getTextWord(219))
				return
			end
        elseif self.num == 2 then
            if not StringUtils:checkStringSize(text, 2, 11) then
				self:showSysMessage(self:getTextWord(5060))
				return
			end
		elseif self.num == 4 then --发送公告
			local _typeId = self.typeId
            text = self._notiEditBox:getText()
            if text == "" then 
                self:showSysMessage(self:getTextWord(40201))
                
                return 
            end
			self:dispatchEvent(EspecialGoodsUseEvent.USESENDNOTICE_REQ,{typeId = _typeId,mess = text})
			self:dispatchEvent(EspecialGoodsUseEvent.HIDE_SELF_EVENT)
			return
		end

		if self.num == 2 then -- 定位仪--
			local _typeId = self.typeId
			self:dispatchEvent(EspecialGoodsUseEvent.CHECKPLAYERPOINTREQ,{typeId = _typeId, name = text})
			-- self:dispatchEvent(EspecialGoodsUseEvent.HIDE_SELF_EVENT)
			return
		elseif self.num == 3 then --发红包确认
			if text == self.myName then
			 	self:showSysMessage(self:getTextWord(4032))
			 	return 
			end 
			if self.itemType and self.itemType == 42 then --私人红包
				local data = {}
				data.itemId = self.typeId
				data.channel = 0 --私人红包
				data.name = text
				self:dispatchEvent(EspecialGoodsUseEvent.REDPACKET_ITEMGOODS_USE_REQ,data)
				return
			end
		end
		local _typeId = self.typeId
		self:dispatchEvent(EspecialGoodsUseEvent.ESPECIALGOODSUSE_REQ,{typeId = _typeId,name = text})
		-- self:dispatchEvent(EspecialGoodsUseEvent.HIDE_SELF_EVENT)  --暂时测试(先关闭)
	end
end
function EspecialGoodsUsePanel:updatePlayerInfo(data)
	self._chatEditBox:setText(data.name)
end

function EspecialGoodsUsePanel:closeThisPanel(sender)
    self:dispatchEvent(EspecialGoodsUseEvent.HIDE_SELF_EVENT)
end

function EspecialGoodsUsePanel:setContentToLabel()
    if self._contentTxt then
        local text = self._notiEditBox:getText()
        if text == "" then
            self._contentTxt:setString(self:getTextWord(4013))
            -- 颜色恢复
            self._contentTxt:setColor(cc.c3b(116, 98, 79))
            return 
        end
        self._contentTxt:setString(StringUtils:getStringAddBackEnter(text,20))
        self._contentTxt:setColor(cc.c3b(238, 214, 170))
	end
end
