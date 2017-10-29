
PubView = class("PubView", BasicView)

function PubView:ctor(parent)
    PubView.super.ctor(self, parent)
end

function PubView:finalize()
    for _, var in ipairs(self.effectArr) do
        var:finalize()
    end
    PubView.super.finalize(self)
end

function PubView:registerPanels()
    PubView.super.registerPanels(self)
    require("modules.pub.panel.PubPanel")
    self:registerPanel(PubPanel.NAME, PubPanel)
    require("modules.pub.panel.PubNorPanel")
    self:registerPanel(PubNorPanel.NAME, PubNorPanel)
    require("modules.pub.panel.PubSpePanel")
    self:registerPanel(PubSpePanel.NAME, PubSpePanel)
    require("modules.pub.panel.PubShopPanel")
    self:registerPanel(PubShopPanel.NAME, PubShopPanel)

    
end

function PubView:initView()
    local panel = self:getPanel(PubPanel.NAME)
    panel:show()
    --管理特效的数组
    self.effectArr = {}
    --控制小宴是否能播放开箱特效
    self.canNorPubPlayEffect = true
	--控制盛宴是否能播放开箱特效
	self.canSpePubPlayEffect = true
end

function PubView:hideModuleHandler()
	self:dispatchEvent(PubEvent.HIDE_SELF_EVENT, {})
end

function PubView:setFirstPanelShow(data)
	
end

--设置背景图
function PubView:setBgType( n )
    local panel = self:getPanel(PubPanel.NAME)
    panel:setBgType(n)
end

-- 重写onShowView(),用于每次打开panel都执行onShowHandler()
function PubView:onShowView(extraMsg, isInit)
    PubView.super.onShowView(self,extraMsg, isInit, true)
end
--购买探宝币协议返回后调整界面按钮与消耗数量
function PubView:onLotterRespHandle(data)
	local panel = self:getPanel(PubNorPanel.NAME)
	panel:onLotterRespHandle(data)

	panel = self:getPanel(PubSpePanel.NAME)
    panel:onLotterRespHandle(data)

    --self._data = data
end

--function PubView:getData()

	--return self._data
--end
-- 抽一次的刷新 150002后的单抽调用
function PubView:onBuyOnceHandler(data)
	local panel 
	if data.type == 1 then
		panel = self:getPanel(PubNorPanel.NAME)
	else
		panel = self:getPanel(PubSpePanel.NAME)
	end
	panel:onRewardRespHandle(data)
    -- 刷新标签页的红点
    local pubPanel = self:getPanel(PubPanel.NAME)
    pubPanel:updateTabItemCount()
end
-- 抽多次的刷新
function PubView:onTenRewardRespHandle(data)
	local panel 
	if data.type == 1 then
		panel = self:getPanel(PubNorPanel.NAME)
	else
		panel = self:getPanel(PubSpePanel.NAME)
	end
	panel:onTenRewardRespHandle(data)
    -- 刷新标签页的红点
    local pubPanel = self:getPanel(PubPanel.NAME)
    pubPanel:updateTabItemCount()
end

function PubView:playEffect(data,openItem,callback,openItemParent,isShowDouble,pubType)

	local oldEffectFun = function ()
		local icon = openItem:getChildByName("rewardImg")
		local doubleImg = openItem:getChildByName("doubleImg")
		if doubleImg ~= nil then
			doubleImg:setVisible(false)
		end

		icon:setVisible(true)
	    --播放特效
	    icon:setLocalZOrder(5)

		if data then

	        local uiIcon = icon.uiIcon
	        if not uiIcon then
	            uiIcon = UIIcon.new(icon, data, true, self)
	            icon.uiIcon = uiIcon
	            uiIcon:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2+15) -- 
	            uiIcon:setTouchEnabled(false) -- 
	        else
	            uiIcon:updateData(data)

	        end
	        if isShowDouble == true then
	        	if data.power == GamePowerConfig.Soldier then
	        		doubleImg:setVisible(true)
	        	end
	        end
	        uiIcon:setScale(0.1)
	        local actionScale = cc.ScaleTo:create(0.1, GameConfig.TwoLevelShells.SCALE_MAX)
	        uiIcon:runAction(actionScale)
	    end
	    

	    
	    local ccbLayer = openItem.ccbLayer
	    if ccbLayer == nil then
	        local ccbLayer = UICCBLayer.new("rpg-bxwupin", openItem) -- 循环特效  
			ccbLayer:setLocalZOrder(4)          
	        ccbLayer:setPosition(icon:getPosition())
	        ccbLayer:setVisible(true)
	        openItem.ccbLayer = ccbLayer
	    else
	        ccbLayer:setVisible(true)
	    end

	    callback()
	    -- local ccbLayer2 = UICCBLayer.new("rpg-baoxiangtexiao", openItem, nil, callback, true)  

	    -- ccbLayer2:setPosition(icon:getPosition())
	end


	local owner = {}
	owner["pause"] = function() 
		-- print("rgb-jg-xiangz```````````pause`")


		if pubType == 1 then
			if self.canNorPubPlayEffect == true then
				local coverImg = openItemParent:getChildByName("coverImg")
				local openCoverImg = openItemParent:getChildByName("openCoverImg")
				coverImg:setVisible(false)
				openCoverImg:setVisible(true)
				oldEffectFun()
			end
		elseif pubType == 2 then
			if self.canSpePubPlayEffect == true then
				local coverImg = openItemParent:getChildByName("coverImg")
				local openCoverImg = openItemParent:getChildByName("openCoverImg")
				coverImg:setVisible(false)
				openCoverImg:setVisible(true)
				oldEffectFun()
			end
		end
	end
	owner["complete"] = function() 
		-- print("rgb-jg-xiangz```````````complete`")
		if self.effectArr[1] then
			self.effectArr[1]:finalize()
			table.remove(self.effectArr,1)
		end
	end
	local oneBoxEft = UICCBLayer.new("rgb-jg-xiangz", openItemParent, owner)
	local openSize = openItemParent:getContentSize()
	oneBoxEft:setLocalZOrder(1)
	oneBoxEft:setPosition(openSize.width*0.5, openSize.height*0.6)
	table.insert(self.effectArr, oneBoxEft) 


end

function PubView:onUpdateRoleInfo()
	local panel = self:getPanel(PubNorPanel.NAME)
	if panel:isVisible() == true then
		panel:updateBtnPosAndInfo()
	end
	panel = self:getPanel(PubSpePanel.NAME)
	if panel:isVisible() == true then
		panel:updateBtnPosAndInfo()
	end

end

function PubView:setCanNorPubPlayEffect( bl )
	self.canNorPubPlayEffect = bl
end
function PubView:setCanSpePubPlayEffect( bl )
	self.canSpePubPlayEffect = bl
end

-- --------------------------------------------------------------------
function PubView:afterBuyNorItem()
    local pubNorPanel = self:getPanel(PubNorPanel.NAME)
    pubNorPanel:afterBuyNorItem()
end 
function PubView:afterBuySpeItem()
    local pubSpePanel = self:getPanel(PubSpePanel.NAME)
    pubSpePanel:afterBuySpeItem()
end 
function PubView:afterOpenOneNor(reward)
    local pubNorPanel = self:getPanel(PubNorPanel.NAME)
    pubNorPanel:afterOpenOneNor(reward)
        -- 刷新标签页的红点
    local pubPanel = self:getPanel(PubPanel.NAME)
    pubPanel:updateTabItemCount()
end 
function PubView:afterOpenNineNor(rewards)
    local pubNorPanel = self:getPanel(PubNorPanel.NAME)
    pubNorPanel:afterOpenNineNor(rewards)
        -- 刷新标签页的红点
    local pubPanel = self:getPanel(PubPanel.NAME)
    pubPanel:updateTabItemCount()
end 
function PubView:afterOpenOneSpe(reward)
    local pubSpePanel = self:getPanel(PubSpePanel.NAME)
    pubSpePanel:afterOpenOneSpe(reward)
        -- 刷新标签页的红点
    local pubPanel = self:getPanel(PubPanel.NAME)
    pubPanel:updateTabItemCount()
end 
function PubView:afterOpenNineSpe(rewards)
    local pubSpePanel = self:getPanel(PubSpePanel.NAME)
    pubSpePanel:afterOpenNineSpe(rewards)
        -- 刷新标签页的红点
    local pubPanel = self:getPanel(PubPanel.NAME)
    pubPanel:updateTabItemCount()
end 
function PubView:norHistoryUpdate()
    local pubNorPanel = self:getPanel(PubNorPanel.NAME)
    pubNorPanel:norHistoryUpdate()
end 
function PubView:speHistoryUpdate()
    local pubSpePanel = self:getPanel(PubSpePanel.NAME)
    pubSpePanel:speHistoryUpdate()
end 
function PubView:pubShopUpdate()
    local pubShopPanel = self:getPanel(PubShopPanel.NAME)
    pubShopPanel:updatePubShopView()
end 
function PubView:updateNorInfo()
    local pubNorPanel = self:getPanel(PubNorPanel.NAME)
    pubNorPanel:updatePubNorPanel()
end 
function PubView:updateSpeInfo()
    local pubSpePanel = self:getPanel(PubSpePanel.NAME)
    pubSpePanel:updatePubSpePanel()
end 
function PubView:pubAllUpdate()
    local pubNorPanel = self:getPanel(PubNorPanel.NAME)
    pubNorPanel:onShowHandler()
    local pubSpePanel = self:getPanel(PubSpePanel.NAME)
    pubSpePanel:onShowHandler()
	local pubShopPanel = self:getPanel(PubShopPanel.NAME)
    pubShopPanel:onShowHandler()
	local pubPanel = self:getPanel(PubPanel.NAME)
    pubPanel:onShowHandler()
end 
function PubView:after450005(rs)
    local pubNorPanel = self:getPanel(PubNorPanel.NAME)
    pubNorPanel:after450005(rs)
end 
function PubView:after450007(rs)
    local pubSpePanel = self:getPanel(PubSpePanel.NAME)
    pubSpePanel:after450007(rs)
end 

function PubView:after450002(rs)
    local pubNorPanel = self:getPanel(PubNorPanel.NAME)
    pubNorPanel:after450002(rs)
end 
function PubView:after450003(rs)
    local pubSpePanel = self:getPanel(PubSpePanel.NAME)
    pubSpePanel:after450003(rs)
end 