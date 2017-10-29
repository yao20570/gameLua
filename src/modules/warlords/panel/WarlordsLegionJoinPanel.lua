------------军团信息

WarlordsLegionJoinPanel = class("WarlordsLegionJoinPanel", BasicPanel)
WarlordsLegionJoinPanel.NAME = "WarlordsLegionJoinPanel"

function WarlordsLegionJoinPanel:ctor(view, panelName)
    WarlordsLegionJoinPanel.super.ctor(self, view, panelName,700)

end

function WarlordsLegionJoinPanel:finalize()
    WarlordsLegionJoinPanel.super.finalize(self)
end

function WarlordsLegionJoinPanel:initPanel()
	WarlordsLegionJoinPanel.super.initPanel(self)
	self:setTitle(true,self:getTextWord(380006),false)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
	--self:onPanelSpecialShow()
	self:setLocalZOrder(1000)

	self.Label_count = self:getChildByName("Image_bg/Label_count")
	self.listView = self:getChildByName("Image_bg/ListView")

	--self:addTouchEventListener(closeBtn, self.onHideSelfHandle)
end

-- function WarlordsLegionJoinPanel:onHideSelfHandle()
-- 	self:hide()
-- end

function WarlordsLegionJoinPanel:registerEvents()
	WarlordsLegionJoinPanel.super.registerEvents(self)
end

function WarlordsLegionJoinPanel:onShowHandler()
	local id = self._battleActivityProxy:onGetWorloardsActId()
	self._battleActivityProxy:onTriggerNet330002Req({activityId = id})
end

function WarlordsLegionJoinPanel:onGetlegionsList()
	local data = self._battleActivityProxy:getLegionInfosList()

	self.Label_count:setString(#data)
	self:renderListView(self.listView, data, self, self.registerItemEvents)
end

function WarlordsLegionJoinPanel:registerItemEvents(item,data,index)
	item.data = data
	local Label_level = item:getChildByName("Label_level")
	local Label_fight  = item:getChildByName("Label_fight")
	local Label_count = item:getChildByName("Label_count")
	local Label_name  = item:getChildByName("Label_name")
	local itemBgImg = item:getChildByName("bgImg")
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end

	Label_level:setString(data.level)
	Label_name:setString(data.name)
	Label_count:setString(data.memberNum)
	Label_fight:setString(StringUtils:formatNumberByK(data.capacity))
end