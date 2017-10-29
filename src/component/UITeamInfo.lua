UITeamInfo = class("UITeamInfo", BasicComponent)

function UITeamInfo:ctor(parent,panel)
    UITeamInfo.super.ctor(self)
    local uiSkin = UISkin.new("UITeamInfo")
    uiSkin:setParent(parent)
    self._panel = panel
    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(5)
    self:registerEvents()
    self.info = ConfigDataManager:getConfigData(ConfigData.ResourcePointConfig)
    
    self.secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    self.secLvBg:setContentHeight(560)
    -- self.secLvBg:setTitle(TextWords:getTextWord(323))
end

function UITeamInfo:finalize()
    self._uiSkin:finalize()
    UITeamInfo.super.finalize(self)
end

function UITeamInfo:hide()
    self:onCloseTimerOpenFun()
    self._uiSkin:setVisible(false)
end

function UITeamInfo:showAllInfo(data,lastTime)
    self.listView2:setVisible(true)
    self.listView:setVisible(false)
    self.checkTeanBtn:setVisible(true)
    self.setDefendBtn:setVisible(true)
    self.secLvBg:setTitle(TextWords:getTextWord(323))
	self._uiSkin:setVisible(true)
    self.data = data
    self.lastTime = lastTime
    CountDownManager:add(100000000, self.onUpdate, self)
	if data == nil then return end
    local item = self.listView2:getItem(0)
	self:renderListView(self.listView2, data, self, self.renderItemPanel, true)
end

function UITeamInfo:renderItemPanel(item,itemInfo,index)
    if item == nil then return end
    item:setVisible(true)
	local container = item:getChildByName("container")
	local label_1 = item:getChildByName("Label_1")
	local label_2 = item:getChildByName("Label_2")
	local label_3 = item:getChildByName("Label_3")
    local button_0 = item:getChildByName("Button_0")
    local button_1 = item:getChildByName("Button_1")
    local button_2 = item:getChildByName("Button_2")
    button_1:setVisible(false)
    button_2:setVisible(false)
	local headInfo = {}
    headInfo.icon = itemInfo.iconId
    headInfo.pendant = itemInfo.iconId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = false
    local head = container.head
    if head == nil then
        head = UIHeadImg.new(container,headInfo,self)
        container.head = head
    else
        head:updateData(headInfo)
    end 
    
    label_1:setString(itemInfo.name.." Lv."..itemInfo.level..TextWords:getTextWord(7022))
    if itemInfo.id <= 0 then
    	label_2:setString(TextWords:getTextWord(7023).."("..itemInfo.x..","..itemInfo.y..")")
    else
        label_2:setString(TextWords:getTextWord(7024)..self.info[itemInfo.id].name.."("..itemInfo.x..","..itemInfo.y..")")
    end
    local soldierProxy = self._panel:getProxy(GameProxys.Soldier)
    local key = "teamBeAttactionTask"..itemInfo.key
    local remainTime = soldierProxy:getRemainTime(key)
    -- label_3:setString(TimeUtils:getStandardFormatTimeString6(itemInfo.time-self.lastTime,true))
    label_3:setString(TimeUtils:getStandardFormatTimeString6(remainTime,true))
end

function UITeamInfo:registerEvents()
	-- self.closeBtn = self._uiSkin:getChildByName("Panel_2/closeBtn")
	self.checkTeanBtn = self._uiSkin:getChildByName("Panel_2/Button_6")
	self.setDefendBtn = self._uiSkin:getChildByName("Panel_2/Button_7")
	-- ComponentUtils:addTouchEventListener(self.closeBtn, self.onClickEvents, nil, self)
	ComponentUtils:addTouchEventListener(self.checkTeanBtn, self.onClickEvents, nil, self)
	ComponentUtils:addTouchEventListener(self.setDefendBtn, self.onClickEvents, nil, self)
    self.listView = self._uiSkin:getChildByName("Panel_2/ListView")
	self.listView2 = self._uiSkin:getChildByName("Panel_2/ListView_2")

end

------
-- 按钮设置
function UITeamInfo:onClickEvents(sender)
	-- if sender == self.closeBtn then
 --        self:onCloseTimerOpenFun()
	-- 	self._uiSkin:setVisible(false)
	if sender == self.checkTeanBtn then -- 查看部队
		local data = {}
        data.moduleName = ModuleName.TeamModule
        data.extraMsg = "workTarget"
        self._panel:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, data)
	elseif sender == self.setDefendBtn then -- 设置部队
		local data = {}
        data.moduleName = ModuleName.TeamModule
        self._panel:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, data)
	end
end
function UITeamInfo:onCloseTimerOpenFun()
    CountDownManager:remove(self.onUpdate,self)
    CountDownManager:remove(self.onUpdate2,self)
end
function UITeamInfo:onUpdate()
    local data = self.data
    local soldierProxy = self._panel:getProxy(GameProxys.Soldier)
    for i=1,#data do
        local item = self.listView2:getItem(i-1)
        if item == nil then return end
        local label_3 = item:getChildByName("Label_3")
        -- local lastTime = data[i].time - self.lastTime
        local key = "teamBeAttactionTask"..data[i].key
        local lastTime = soldierProxy:getRemainTime(key)
        label_3:setString(TimeUtils:getStandardFormatTimeString6(lastTime,true))
    end
    -- self.lastTime = self.lastTime + 1
end
function UITeamInfo:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UITeamInfo:showBeStationInfo(data, lastTime)
    self.listView:setVisible(true)
    self.listView2:setVisible(false)
    self.checkTeanBtn:setVisible(false)
    self.setDefendBtn:setVisible(false)
    self.secLvBg:setTitle(TextWords:getTextWord(111))
    self._uiSkin:setVisible(true)
    self.data = data
    self.lastTime = lastTime
    CountDownManager:add(1000000000, self.onUpdate2, self)
    self:renderListView(self.listView, data, self, self.renderBeStationItem, true)
end

function UITeamInfo:renderBeStationItem(item,itemInfo,index)
    local container = item:getChildByName("container")
    local label_1 = item:getChildByName("Label_1")
    local label_2 = item:getChildByName("Label_2")
    local label_3 = item:getChildByName("Label_3")
    local button_0 = item:getChildByName("Button_0")
    local button_1 = item:getChildByName("Button_1")
    local button_2 = item:getChildByName("Button_2")
    label_1:setString("")
    label_2:setString("")
    label_3:setString("")
    button_0.index = 0
    button_0.data = itemInfo
    button_1.index = 1
    button_1.data = itemInfo
    button_1.index_num = index + 1
    button_2.index = 2
    button_2.data = itemInfo
    button_2.index_num = index + 1
    local headInfo = {}
    headInfo.icon = itemInfo.icon
    headInfo.pendant = itemInfo.icon
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = false
    local head = container.head
    if head == nil then
        head = UIHeadImg.new(container,headInfo,self)
        container.head = head
    else
        head:updateData(headInfo)
    end 
    label_1:setString(itemInfo.name.."Lv."..itemInfo.level)
    -- local lastTime = itemInfo.totalTime - itemInfo.alreadyTime - self.lastTime
    local key = "teamTask"..itemInfo.id
    local soldierProxy = self._panel:getProxy(GameProxys.Soldier)
    local lastTime = soldierProxy:getRemainTime(key)
    if lastTime <= 0 then
        if itemInfo.state == 1 then
            label_2:setString(TextWords:getTextWord(4023))
        else
            label_2:setString(TextWords:getTextWord(4030))
        end
    else
        label_2:setString(TextWords:getTextWord(4027)..TimeUtils:getStandardFormatTimeString6(lastTime,true))
    end
    label_3:setString("")
    button_0:setVisible(true)
    if itemInfo.state == 1 then
        button_1:setTitleText(TextWords:getTextWord(4024))
    else
        button_1:setTitleText(TextWords:getTextWord(121))
    end 
    ComponentUtils:addTouchEventListener(button_0, self.clickItemButton, nil, self)
    ComponentUtils:addTouchEventListener(button_1, self.clickItemButton, nil, self)
    ComponentUtils:addTouchEventListener(button_2, self.clickItemButton, nil, self)
end

function UITeamInfo:onUpdate2()
    local soldierProxy = self._panel:getProxy(GameProxys.Soldier)
    local data = self.data
    for i=1,#data do
        local item = self.listView:getItem(i-1)
        if item == nil then return end
        local label_2 = item:getChildByName("Label_2")
        local btn_1 = item:getChildByName("Button_1")
        local btn_2 = item:getChildByName("Button_2")
        local key = "teamTask"..data[i].id
        local lastTime = soldierProxy:getRemainTime(key)
        if lastTime > 0 then
            btn_1:setVisible(false)
            btn_2:setVisible(false)
            label_2:setString(TextWords:getTextWord(4027)..TimeUtils:getStandardFormatTimeString6(lastTime,true))
        else
            if btn_1:isVisible() == false then
                self:showBeStationInfo(self.data, self.lastTime)
            end
            btn_1:setVisible(true)
            btn_2:setVisible(true)
        end
    end
    self.lastTime = self.lastTime + 1
end 

function UITeamInfo:clickItemButton(sender)
    if sender.index == 0 then
        local soldierProxy = self._panel:getProxy(GameProxys.Soldier)
        local key = "teamTask"..sender.data.id
        local lastTime = soldierProxy:getRemainTime(key)
        if lastTime > 0 then
            self._panel:showSysMessage(TextWords:getTextWord(4031))
            return
        end
        local tmp = {}
        tmp["moduleName"] = ModuleName.CheckTeamModule
        tmp["extraMsg"] = sender.data
        self._panel:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, tmp)
    elseif sender.index == 1 then
        local playerId = sender.data.id
        local data = {}
        data.id = playerId
        self._panel:dispatchEvent(ToolbarEvent.SET_DEFEND_TEAM, data)
        if sender.data.state == 1 then
            self._panel:showSysMessage(TextWords:getTextWord(4028))
            sender:setTitleText(TextWords:getTextWord(4024))
            for i=1,#self.data do
                self.data[i].state = 2
            end
            self.data[sender.index_num].state = 2
        else
            self._panel:showSysMessage(TextWords:getTextWord(4029))
            sender:setTitleText(TextWords:getTextWord(121))
            for i=1,#self.data do
                self.data[i].state = 2
            end
            self.data[sender.index_num].state = 1
        end
        self:showBeStationInfo(self.data, self.lastTime)
    elseif sender.index == 2 then
        local playerId = sender.data.id
        local data = {}
        data.id = playerId
        self._panel:dispatchEvent(ToolbarEvent.SET_GO_HOME_TEAM, data)
        table.remove(self.data,sender.index_num)
        self:showBeStationInfo(self.data, self.lastTime)
    end
end