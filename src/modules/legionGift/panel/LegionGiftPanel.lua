-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
LegionGiftPanel = class("LegionGiftPanel", BasicPanel)
LegionGiftPanel.NAME = "LegionGiftPanel"

function LegionGiftPanel:ctor(view, panelName)
    LegionGiftPanel.super.ctor(self, view, panelName, 700)

end

function LegionGiftPanel:finalize()
    LegionGiftPanel.super.finalize(self)
end

function LegionGiftPanel:onShowHandler()
	local activityProxy = self:getProxy(GameProxys.Activity)
	--获取活动里同盟好礼的信息
	local name = self:getTextWord(1340)
	local legionData= activityProxy:getDataByName(name)
	self._activityData = legionData
	local iconData = legionData.effectInfos[1].rewards
	local btnState = legionData.buttons[1].type

	self:initBtn(btnState)
	self:initIconImg(iconData)
end

function LegionGiftPanel:initBtn(data)
	if data == 1 then
		--跳转
		self._createBtn:setVisible(true)
		self._joinBtn:setVisible(true)
		self._rewardBtn:setVisible(false)
	elseif data ==2 then
		--可领取
		self._createBtn:setVisible(false)
		self._joinBtn:setVisible(false)
		self._rewardBtn:setTitleText(self:getTextWord(1318))
		self._rewardBtn:setVisible(true)
		self._rewardBtn:setTouchEnabled(true)
	elseif data == 3 then
		--已领取
		self._createBtn:setVisible(false)
		self._joinBtn:setVisible(false)
		self._rewardBtn:setTitleText(self:getTextWord(1335))
		self._rewardBtn:setVisible(true)
		self._rewardBtn:setTouchEnabled(false)
	end
end

function LegionGiftPanel:initIconImg(data)
	for k , v in pairs(data) do
		local iconImg = self._topPanel:getChildByName("iconImg"..k)
		if iconImg ~= nil then
			local data = {}
	        data.power = v.power
	        data.typeid = v.typeid
	        data.num = v.num
	        local icon = iconImg.icon
	        if icon == nil then
	            icon = UIIcon.new(iconImg, data, true, self, nil, true)
	            iconImg.icon = icon
	        else
	        	icon:setShowName(true)
	            icon:updateData(data)
	        end
	    end
	end 
end

function LegionGiftPanel:initPanel()
	LegionGiftPanel.super.initPanel(self)
	self:setTitle(true, self:getTextWord(1339), false)
	self._topPanel = self:getChildByName("mainPanel/topPanel")
	self._downPanel = self:getChildByName("mainPanel/downPanel")

	self._createBtn = self._downPanel:getChildByName("createBtn")
	self._joinBtn = self._downPanel:getChildByName("joinBtn")
	self._rewardBtn = self._downPanel:getChildByName("rewardBtn")

	self:addTouchEventListener(self._createBtn,self.createBtnFun)
	self:addTouchEventListener(self._joinBtn,self.joinBtnFun)
	self:addTouchEventListener(self._rewardBtn,self.rewardBtnFun)

    local closeBtn = self:getCloseBtn() -- 背景的关闭按钮
	self:addTouchEventListener(closeBtn,self.hideHandler)
end

function LegionGiftPanel:createBtnFun()
	local buildingProxy = self:getProxy(GameProxys.Building)
    --同盟是否可开启
    local isOpen = buildingProxy:isBuildingOpen(17, 14)
    if isOpen == false then
        return
    end

	ModuleJumpManager:jump(ModuleName.LegionApplyModule,"LegionCreatePanel")
	self:hideHandler()
end

function LegionGiftPanel:joinBtnFun()
	local buildingProxy = self:getProxy(GameProxys.Building)
    --同盟是否可开启
    local isOpen = buildingProxy:isBuildingOpen(17, 14)
    if isOpen == false then
        return
    end
    
	ModuleJumpManager:jump(ModuleName.LegionApplyModule)
	self:hideHandler()
end

function LegionGiftPanel:rewardBtnFun()
	if self._activityData == nil then
		return
	end
	local data = {}
	data.activityId = self._activityData.activityId
	data.effectId = self._activityData.effectInfos[1].effectId
	data.sort = self._activityData.effectInfos[1].sort
	local id = 1
	local activityProxy = self:getProxy(GameProxys.Activity)
	activityProxy:onTriggerNet230001Req(data, id, true, false)
	self:hideHandler()
end


function LegionGiftPanel:registerEvents()
	LegionGiftPanel.super.registerEvents(self) 
end

function LegionGiftPanel:hideHandler()
    self:dispatchEvent(LegionGiftEvent.HIDE_SELF_EVENT)
end
