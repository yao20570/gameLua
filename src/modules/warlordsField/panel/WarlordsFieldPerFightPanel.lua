------------个人战场播放
WarlordsFieldPerFightPanel = class("WarlordsFieldPerFightPanel", BasicPanel)
WarlordsFieldPerFightPanel.NAME = "WarlordsFieldPerFightPanel"

function WarlordsFieldPerFightPanel:ctor(view, panelName)
    WarlordsFieldPerFightPanel.super.ctor(self, view, panelName,700)
end

function WarlordsFieldPerFightPanel:finalize()
    WarlordsFieldPerFightPanel.super.finalize(self)
end

function WarlordsFieldPerFightPanel:initPanel()
	WarlordsFieldPerFightPanel.super.initPanel(self)
	self:setTitle(true,"个人战况",false)
	--self:onPanelSpecialShow()
	self:setLocalZOrder(1000)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
	--self._listView = self:getChildByName("Panel_42/Image_bg/ListView")
	self.Label_count = self:getChildByName("PanelTop/Label_count")
	--self._uiFightInfosPanel = UIFightInfosPanel.new(self,nil,true)

	-- local function call()  --移动偏移量
	-- 	self._uiFightInfosPanel:onSetTitleImg(false,true)
	-- 	self._uiFightInfosPanel:onSetPosOffset(10,-30)
	-- end
	-- TimerManager:addOnce(30, call, self)
	self.listview = self:getChildByName("PanelTop/ListView")
end

function WarlordsFieldPerFightPanel:registerEvents()
	WarlordsFieldPerFightPanel.super.registerEvents(self)
	-- local closeBtn = self:getChildByName("Panel_42/closeBtn")
	-- self:addTouchEventListener(closeBtn, self.onHideSelfHandle)
end

function WarlordsFieldPerFightPanel:onShowHandler(data)
	local index = 1
	local _data = {}
	for _,v in pairs(data) do
		if v.type == 1 then
			_data[index] = v
			index = index + 1
		end
	end

	self.Label_count:setString(#_data)
	-- self._uiFightInfosPanel:updateData(_data)
	self:renderListView(self.listview, _data, self, self.registerItemEvents)
end

function WarlordsFieldPerFightPanel:onHideSelfHandle()
	self:hide()
end

function WarlordsFieldPerFightPanel:registerItemEvents(item,data,index)
    local itemBgImg = item:getChildByName("bgImg")
    local Label_t = item:getChildByName("Label_t")
    local goBtn = item:getChildByName("goBtn")
    item.data = data
    
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end

    local Label_f = item:getChildByName("Label_f")          --攻击方军团名称
    local Label_p = item:getChildByName("Label_p")          --防守方军团名称
    local Label_namef = item:getChildByName("Label_namef")  --攻击方玩家名称
    local Label_namep = item:getChildByName("Label_namep")  --防守方玩家名称

    local serverData = data.fightInfo
    local attackTeam = serverData.attackTeam
    local defendTeam = serverData.defendTeam
    local time = serverData.time                              --发生时间
    local wins = serverData.wins                              --连胜次数 0表示失败 1胜利 2...连胜xxx

    Label_t:setString(TimeUtils:setTimestampToString5(time))

    Label_f:setString(attackTeam.legionName)
    Label_namef:setString(attackTeam.playerName.."("..attackTeam.percent.."%)")

    Label_p:setString(defendTeam.legionName)
    Label_namep:setString(defendTeam.playerName.."("..defendTeam.percent.."%)")

    goBtn.data = data
    if goBtn.isAdd == true then
        return
    end
    goBtn.isAdd = true
    ComponentUtils:addTouchEventListener(goBtn, self.onClickBtnTouch, nil, self)
end

function WarlordsFieldPerFightPanel:onClickBtnTouch(sender)
    self._battleActivityProxy:onTriggerNet330009Req({battleId = sender.data.fightInfo.battleId})
end