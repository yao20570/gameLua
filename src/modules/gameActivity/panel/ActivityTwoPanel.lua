--
-- Author: zlf
-- Date: 2016年11月30日22:05:13
-- 首充礼包、军团好礼界面

ActivityTwoPanel = class("ActivityTwoPanel", BasicPanel)
ActivityTwoPanel.NAME = "ActivityTwoPanel"

function ActivityTwoPanel:ctor(view, panelName)
    ActivityTwoPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ActivityTwoPanel:finalize()
    
	local btn = self:getChildByName("Panel_bg/btn")
	if btn.effect ~= nil then
		btn.effect:finalize()
		btn.effect = nil
	end
	-- if self._topEffect ~= nil then
	-- 	self._topEffect:finalize()
	-- 	self._topEffect = nil
	-- end

    ActivityTwoPanel.super.finalize(self)
end

function ActivityTwoPanel:initPanel()
	ActivityTwoPanel.super.initPanel(self)

	self._proxy = self:getProxy(GameProxys.Activity)
end

function ActivityTwoPanel:registerEvents()
	ActivityTwoPanel.super.registerEvents(self)
	
end

function ActivityTwoPanel:doLayout()
	local panel = self:getChildByName("Panel_bg")
	local mainpanel = self:getPanel(GameActivityPanel.NAME)
	if mainpanel ~= nil then
		-- NodeUtils:adaptivePanelBg(panel, 20, mainpanel:getBestPanel())
    	NodeUtils:adaptiveUpPanel(panel,mainpanel:getTopListView(),10)
	else
		-- NodeUtils:adaptivePanelBg(panel, 20, GlobalConfig.topHeight)
		NodeUtils:adaptivePanelBg(panel, 20, self:topAdaptivePanel():getPositionY()-85)
	end
end

function ActivityTwoPanel:onShowHandler(data)
	self._activityId = data.activityId
	local bgImg = self:getChildByName("Panel_bg/bgImg1Src")
	if bgImg.bgIcon ~= data.bgIcon then
		bgImg.bgIcon = data.bgIcon
		-- local url = "bg/activity/" .. data.bgIcon .. TextureManager.bg_type
		local url = "bg/activity/firstRecharge.jpg" 
		TextureManager:updateImageViewFile(bgImg, url)

		-- if self._topEffect == nil then
		-- 	--顶部有个圈若隐若现的特效
		-- 	self._topEffect = self:createUICCBLayer("rgb-hd-gcnd1", bgImg)
		-- 	local panelSize = bgImg:getContentSize()
		-- 	self._topEffect:setPosition(panelSize.width*0.4, panelSize.height*0.1+80)
		-- end

		-- 图片艺术字描述显示
		-- local Image_189 = self:getChildByName("Panel_bg/Image_189")
		-- url = "bg/activity/artIcon"..data.artIcon .. TextureManager.bg_type
		-- TextureManager:updateImageViewFile(Image_189,url)
		-- Image_189:setVisible(true)
	end

	-- local bottom = self:getChildByName("Panel_bg/bottom")
 --    local title = bottom:getChildByName("title") --小标题
 --    if data.title ~= nil then
 --    	title:setString(data.title)
 --    end

    local rewards = data.effectInfos[1].rewards or {}

    for k,v in pairs(rewards) do
    	local item = self:getChildByName("Panel_bg/item"..k)
    	if item ~= nil then
    		item:setVisible(true)
    		local name = item:getChildByName("name")
    		local isShowName = not (v.power == 407 and v.typeid == 206)
    		local isShowNum = not (v.power == 407 and v.typeid == 206)
    		name:setVisible(not isShowName)
    		if item.uiIcon == nil then
    			item.uiIcon = UIIcon.new(item, v, isShowNum, self, nil, isShowName)
    		else
    			item.uiIcon:updateData(v)
    		end
    		if not isShowName then
    			name:setString(self:getTextWord(1513))
				name:setFontSize(15)
				name:setPosition(0, -54)
    		end
    	end
    end

    for i=#rewards + 1,4 do
    	local item = self:getChildByName("Panel_bg/item"..k)
    	item:setVisible(false)
    end

    local btn = self:getChildByName("Panel_bg/btn") --绿色
	self.rankData = nil
	if data.buttons[1].type == 2 then
		--获取请求的数据
		self.rankData = self._proxy:getRankReqData(data.activityId)
	end
	
	--按钮的特效
	if btn.effect == nil then
		btn.effect = self:createUICCBLayer("rgb-daanniu-huang", btn)
		local btnSize = btn:getContentSize()
		btn.effect:setPosition(btnSize.width*0.5, btnSize.height*0.5)
	end

	btn:setTitleText(data.buttons[1].name)
    logger:info("btn.name "..data.buttons[1].name)
	btn.data = data
	if data.buttons[1].type > 2 then
		NodeUtils:setEnable(btn, false)
	else
		self:addTouchEventListener(btn, self.btnTouch)
	end
end

--除了建国基金写死两个-1  其他都去proxy拿effectid  和  sort
--type：1  跳转模块
--type：2  可领取状态
function ActivityTwoPanel:btnTouch(sender)
	local data = sender.data
	local buttons = data.buttons[1]
	local mainpanel = self:getPanel(GameActivityPanel.NAME)
	if buttons.type == 1 then
		mainpanel:commonJumpMethod(buttons)
	elseif buttons.type == 2 then
		if self.rankData == nil then
			logger:error("self.rankData是nil，缺少请求所需数据")
			return
		end
		mainpanel:commonMethod(self._activityId, self.rankData.effectId, self.rankData.sort, true, false)
	end
end