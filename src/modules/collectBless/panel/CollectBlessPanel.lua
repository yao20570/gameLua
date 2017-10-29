-- /**
--  * @Author:	 fwx
--  * @DateTime: 2016.12.12
--  * @Description:  迎春集福
--  */
CollectBlessPanel = class("CollectBlessPanel", BasicPanel)
CollectBlessPanel.NAME = "CollectBlessPanel"

function CollectBlessPanel:ctor(view, panelName)
	CollectBlessPanel.super.ctor(self, view, panelName, true)
	self.mEffs = {}
	self.topEff = {}
end

function CollectBlessPanel:finalize()
	for i,effs in ipairs(self.mEffs or {}) do
		for _,eff in ipairs(effs) do
			eff:finalize()
		end
		self.mEffs[i] = nil
	end
	self.mEffs = {}

	for _,eff in ipairs(self.topEff or {}) do
		eff:finalize()
	end
	self.topEff = {}
	CollectBlessPanel.super.finalize(self)
end

function CollectBlessPanel:initPanel()
	CollectBlessPanel.super.initPanel(self)

	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true,"collectBless",true)
	
	self.proxy = self:getProxy( GameProxys.Activity )
	self.config = ConfigDataManager:getConfigData( ConfigData.CollectBlessConfig ) or {}

	self.mTopPanel = self:getChildByName("Panel_224")
	self.listView = self:getChildByName("ListView_108")
	local itemPanel = self.listView:getItem(0)
	local item1 = itemPanel:getChildByName("Panel_item_1")
	local item2 = itemPanel:getChildByName("Panel_item_2")
	local item3 = itemPanel:getChildByName("Panel_item_3")
	self.itemWidth = math.abs(item2:getPositionX() - item1:getPositionX())
	self.itemHeight = math.abs(item1:getPositionY() - item3:getPositionY())

	local des1 = self.mTopPanel:getChildByName("desc1")
	local des2 = self.mTopPanel:getChildByName("desc2")
	local des3 = self.mTopPanel:getChildByName("desc3")
	des1:setString( self:getTextWord(230451) )
	des2:setString( self:getTextWord(230452) )
	des3:setString( self:getTextWord(230453) )
end
function CollectBlessPanel:doLayout()
	NodeUtils:adaptivePanelBg( self.listView, GlobalConfig.downHeight, self.mTopPanel)
end

function CollectBlessPanel:registerEvents()
	CollectBlessPanel.super.registerEvents(self)
end

--事件-----
function CollectBlessPanel:onClosePanelHandler()
	self.view:dispatchEvent( CollectBlessEvent.HIDE_SELF_EVENT )
end
function CollectBlessPanel:onShowHandler()
	self:updateList()
end

--刷新------
function CollectBlessPanel:updateList()
	self:renderListView( self.listView, self.config, self, self.renderItemPanel)
end
function CollectBlessPanel:renderItemPanel( itemPanel, conf, index )
	local arr = StringUtils:jsonDecode( conf.collectID or "[]") or {}

	local isGrey = false
	for i=1, 4 do
		local iconData = arr[i]
		local item = itemPanel:getChildByName( "Panel_item_"..i )
		local visi = not not iconData
		local addY = #arr<=2 and -self.itemHeight*0.5 or 0
		local addX = ((#arr%2)==1 and i==#arr) and self.itemWidth*0.5 or 0
		if not item then
			break
		end
		item.oldx = item.oldx or item:getPositionX()
		item.oldy = item.oldy or item:getPositionY()
		item:setPosition( item.oldx+addX, item.oldy+addY )
		item:setVisible( visi )
		if visi then
			local _isFullNumber = ComponentUtils:renderItemFormPanel( self, item, iconData[2], iconData[1], iconData[3] )
			if not _isFullNumber and not isGrey then
				isGrey = true
			end
		end
	end

	local reward = itemPanel:getChildByName("img_reward")
	local rename = itemPanel:getChildByName("txt_name")
	TextureManager:updateImageView( reward, "images/collectBless/"..conf.IconID..".png" )
	reward:addTouchEventListener(function(sender, evenType)
		if evenType~=ccui.TouchEventType.ended then return end
		local tip = UIIconTip.new(self:getParent(), {
			color = 4,
			name = conf.name,
			dec = conf.info
		}, true, self)
		local uiiocn = tip:getUIIcon()
		uiiocn:updateIconQuality(4)
		uiiocn:updateIconImg( "collectBless", conf.IconID )
	end)
	rename:setString( conf.name )

	local btn = itemPanel:getChildByName("btn_ok")
	self:addTouchEventListener( btn, function()
		if isGrey then
			self:showSysMessage( self:getTextWord(230454) )
		else
			local activityData = self.proxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_COLLECTBLESS_ID )
			self:showMessageBox( self:getTextWord(230455), function()
				if activityData then
					self.proxy:onTriggerNet230031Req({ activityId=activityData.activityId, blessId=conf.ID })  --请求集福
				end
			end )
		end
	end )
	--特效
	self.mEffs[index] = self.mEffs[index] or {}
	for i=1,2 do
		if not self.mEffs[index][i] then
			local panelDeng = itemPanel:getChildByName("panel_deng"..i)
			panelDeng:setBackGroundColorType(0)
			self.mEffs[index][i] = UICCBLayer.new( "rpg-fenweidenglong", panelDeng )--"rpg-fenweidenglong", panelDeng )
		end
	end
	self.topEff[index] = self.topEff[index] or UICCBLayer.new("rgb-jifu-caidai", itemPanel)
	self.topEff[index]:setPosition( 330, itemPanel:getContentSize().height )
end