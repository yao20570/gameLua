
ArenaRewPanel = class("ArenaRewPanel", BasicPanel)
ArenaRewPanel.NAME = "ArenaRewPanel"

function ArenaRewPanel:ctor(view, panelName)
    ArenaRewPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function ArenaRewPanel:finalize()
    ArenaRewPanel.super.finalize(self)
end

function ArenaRewPanel:initPanel()
	ArenaRewPanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true,"paimingjiangli",true)
    self:setLocalZOrder(10) --标签的层级较高，提高本界面的层级，达到全屏效果

    self._listview = self:getChildByName("ListView_4") --Panel_3/

    self:registerEvent()
    self:onInitRewardInfos()
    self:setNewbgImg3(self:getChildByName("downPanel"))
end

function ArenaRewPanel:doLayout()
    local downPanel = self:getChildByName("downPanel")
    local topPanel = self:topAdaptivePanel()
    NodeUtils:adaptiveListView(self._listview,downPanel,topPanel,GlobalConfig.downHeight + 50)
end

function ArenaRewPanel:onShowHandler()
	--if self.view:onGetData() ~= nil then
    local prxoy = self:getProxy(GameProxys.Arena)
	self:updateBtnStatus(prxoy:getAllInfos())
	--end
end

function ArenaRewPanel:updateBtnStatus(data)
	local count = self:getChildByName("downPanel/count")
	if data.lasttimes < 1 then
		count:setString(self:getTextWord(19002))
        count:setColor(ColorUtils.wordColorDark04)
	else
		count:setString(data.lasttimes)
        count:setColor(ColorUtils.wordColorDark03)
	end

	if data.lastReward == 1 then  --可领取
		NodeUtils:setEnable(self._getRewBtn, true)
        self._getRewBtn:setTitleText(self:getTextWord(19008))
	elseif data.lastReward == 0 then  --未上榜，不可领取
		NodeUtils:setEnable(self._getRewBtn, false)
        self._getRewBtn:setTitleText(self:getTextWord(19008))
    elseif data.lastReward == 2 then  --已经领取
        NodeUtils:setEnable(self._getRewBtn, false)
        self._getRewBtn:setTitleText(self:getTextWord(19007))
	end
end

function ArenaRewPanel:onClosePanelHandler()
	self:hide()
end

function ArenaRewPanel:registerEvent()
	self._getRewBtn = self:getChildByName("downPanel/getRewBtn")
	self:addTouchEventListener(self._getRewBtn,self.onGetRewBtnHandle)
	NodeUtils:setEnable(self._getRewBtn, false)
end

function ArenaRewPanel:onGetRewBtnHandle()
	self:dispatchEvent(ArenaEvent.GET_REWRED_REQ)
end

function ArenaRewPanel:onInitRewardInfos()
	local ArenaReward = ConfigDataManager:getConfigData("ArenaRewardConfig")
	self:renderListView(self._listview, ArenaReward, self, self.registerItemEvents)
end

function ArenaRewPanel:registerItemEvents(item,data,index)
	if item == nil then
		return
	end
	item.data = data
	item:setVisible(true)
	local Label_7 = item:getChildByName("Label_7")
	local ids = StringUtils:jsonDecode(item.data.fixreward)
	Label_7:setString(item.data.info)
	local index = 1
    for _,v in pairs(ids) do
    	local team = item:getChildByName("team"..index)
    	team:setVisible(true)
    	local id = tonumber(v)
    	local configData = ConfigDataManager:getRewardConfigById(id)
    	
    	local data = {}
        data.power = configData.power
        data.typeid = configData.typeid
        data.num = configData.num
    	local icon = team.icon
    	if icon == nil then
            icon = UIIcon.new(team, data,nil, nil, nil, true)
            team.icon = icon
    	else
    	    icon:updateData(data)
    	end
    	
--    	local num = team:getChildByName("num")
--    	local name = team:getChildByName("name")
--    	num:setString(configData.num)
--    	name:setString(configData.name)
--    	TextureManager:updateImageView(team,configData.url)
    	index = index + 1
    end
    for i = index ,3 do
    	local team = item:getChildByName("team"..i)
    	team:setVisible(false)
   	end
end

------
-- 已经领取的回调函数
function ArenaRewPanel:onGetRewResp()
	NodeUtils:setEnable(self._getRewBtn, false)
    self._getRewBtn:setTitleText(self:getTextWord(19007))
end