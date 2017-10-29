-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-01-25 17:57:42
--  * @Description: 探险扫荡奖励
--  */
LimitExpSweepRewardPanel = class("LimitExpSweepRewardPanel", BasicPanel)
LimitExpSweepRewardPanel.NAME = "LimitExpSweepRewardPanel"

function LimitExpSweepRewardPanel:ctor(view, panelName)
    LimitExpSweepRewardPanel.super.ctor(self, view, panelName, 760)
    
    self:setUseNewPanelBg(true)
end

function LimitExpSweepRewardPanel:finalize()
    LimitExpSweepRewardPanel.super.finalize(self)
end

function LimitExpSweepRewardPanel:initPanel()
	LimitExpSweepRewardPanel.super.initPanel(self)
	self:setTitle(true, self:getTextWord(4101))
    -- local listView = self:getChildByName("rewardPanel/ListView_50")
    -- NodeUtils:adaptive(listView)    
end

function LimitExpSweepRewardPanel:onShowHandler(data)
    -- body
    self:onStopRewardResp(data)
end

function LimitExpSweepRewardPanel:onStopRewardResp(rewards)
	-- if #rewards > 0 then
		local rewardPanel = self:getChildByName("rewardPanel")
		rewardPanel:setVisible(true)

	    -- local closeBtn = rewardPanel:getChildByName("closeBtn")
	    -- self:addTouchEventListener(closeBtn, self.onCloseBtnTouche)


		local ListView_50 = rewardPanel:getChildByName("ListView_50")
		self:renderListView(ListView_50, rewards, self, self.registerStopRewItemEvents)

	-- end
end

function LimitExpSweepRewardPanel:registerStopRewItemEvents(item,data)
	if item == nil or data == nil then
		return
	end

	local itemName = item:getChildByName("itemName")
	local itemInfo = item:getChildByName("itemInfo")
	local itemNumber = item:getChildByName("itemNumber")

	-- local iconInfo = {}
	-- iconInfo.power = data.power
	-- iconInfo.typeid = data.typeid
	-- iconInfo.num = data.num

	-- function UIIcon:ctor(parent, data, isShowNum, panel, isMainScene, isShowName, isNumNotStr, otherNumber, effectDelayTime)

    local icon = item.icon
    if icon == nil then
		local iconImg = item:getChildByName("icon")
        icon = UIIcon.new(iconImg,data,false,self,nil,true)
        
        item.icon = icon
    else
        icon:updateData(data)
    end
    icon:getNameChild():setFontSize(18)
    
	-- local config = ConfigDataManager:getConfigByPowerAndID(data.power,data.typeid)
	-- print("名字="..config.name.."···数量="..data.num)
	-- itemName:setString(config.name)
	-- itemInfo:setString(config.info)

	-- itemNumber:setString(string.format(self:getTextWord(1009), data.num))

	-- itemName:setString(icon:getName())
	-- itemInfo:setString(icon:getDec())

end


-- function LimitExpSweepRewardPanel:registerEvents()
--     LimitExpSweepRewardPanel.super.registerEvents(self)
    
    -- local closeBtn = self:getChildByName("rewardPanel/closeBtn")
    -- self:addTouchEventListener(closeBtn, self.onCloseBtnTouche)
-- end

function LimitExpSweepRewardPanel:onCloseBtnTouche(sender)
    self:hide()
end
