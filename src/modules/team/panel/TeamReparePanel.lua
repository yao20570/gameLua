
TeamReparePanel = class("TeamReparePanel", BasicPanel)
TeamReparePanel.NAME = "TeamReparePanel"

function TeamReparePanel:ctor(view, panelName)
    TeamReparePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function TeamReparePanel:finalize()
    TeamReparePanel.super.finalize(self)
end

function TeamReparePanel:initPanel()
	TeamReparePanel.super.initPanel(self)
    self._soldierProxy = self:getProxy(GameProxys.Soldier)
	self:registerEvents()
end

function TeamReparePanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    local downPanel = self:getChildByName("downPanel")
    NodeUtils:adaptiveListView(self.listview,downPanel,tabsPanel, GlobalConfig.topTabsHeight)
end

function TeamReparePanel:registerEvents()
	self.listview = self:getChildByName("ListView_71")
	self._yuanBtn = self:getChildByName("downPanel/yuanBtn")
	self._moneyBtn = self:getChildByName("downPanel/moneyBtn")
	
    

	self._yuanBtn.type = 2
	self._moneyBtn.type = 1
	self._yuanBtn.typeid = 0
	self._moneyBtn.typeid = 0
    self._yuanBtn.isTopButton = true 
    self._moneyBtn.isTopButton = true 
	self:addTouchEventListener(self._yuanBtn, self.onAllRepaireBtnHandle)
	self:addTouchEventListener(self._moneyBtn, self.onAllRepaireBtnHandle)
end

function TeamReparePanel:onShowHandler()
    self:onAllRepaireList()
end

function TeamReparePanel:onAllRepaireBtnHandle(sender)
	if sender.size <= 0 then
		return
	end
	local data = {}
	data.typeid = sender.typeid
	data.type = sender.type
    if sender.type == 1 then
        
        local much
        if sender.typeid == 0 then
            much = self._totalMoney
        else
            much = sender.cost
        end

        -- 元宝治疗
        local function okcallbk()
            -- self:dispatchEvent(TeamEvent.REPAIRE_REQ,data)

            local function callFunc()
                -- 确定
                self:dispatchEvent(TeamEvent.REPAIRE_REQ,data)
            end
            sender.callFunc = callFunc
            sender.money = much
            self:isShowRechargeUI(sender)
        end
        

        local strNumber = nil
        if sender.isTopButton then
            -- 全体治疗
            strNumber = 7069
        else
            -- 单个治疗
            strNumber = 7070
        end
        local content = string.format(self:getTextWord(strNumber), much)
        -- self:showMessageBox(self:getTextWord(7055)..much..self:getTextWord(7056),okcallbk)
        self:showMessageBox(content, okcallbk)
    else
        -- 银币治疗
        self:dispatchEvent(TeamEvent.REPAIRE_REQ,data)
    end
end

-- 是否弹窗元宝不足
function TeamReparePanel:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end

    else
        sender.callFunc()
    end

end

function TeamReparePanel:onAllRepaireList()
    local _data = self._soldierProxy:getBadSoldiersList()
	local index = 0
    local data = {}
	self._totalYuanB = 0  --宝石
	self._totalMoney = 0  --金币
    for _,v in pairs(_data) do
        self._totalYuanB = self._totalYuanB + v.repairCrys  --宝石
        self._totalMoney = self._totalMoney + v.repairMoney --金币
        index = index + 1
        table.insert(data,v)
    end
	self._yuanBtn.size = index
	self._moneyBtn.size = index
    local yuanb = self:getChildByName("downPanel/yuanb")
    local money = self:getChildByName("downPanel/money")
    yuanb:setString(StringUtils:formatNumberByK(self._totalYuanB))
    money:setString(StringUtils:formatNumberByK(self._totalMoney))
    self:renderListView(self.listview, data, self, self.registerItemEvents)

    local panel = self:getPanel(TeamPanel.NAME)
    panel:updateItemCount()
end

function TeamReparePanel:registerItemEvents(item,data,index)
	if item == nil then
        return
    end
    item:setVisible(true)
    local Image_73 = item:getChildByName("Image_73")
    item.data = data
    local person = Image_73:getChildByName("person")
    local name = Image_73:getChildByName("name")
    local count = Image_73:getChildByName("count")
    local yuanb = Image_73:getChildByName("yuanb")
    local money = Image_73:getChildByName("money")
    local yuanBtn = Image_73:getChildByName("yuanBtn")
    local moneyBtn = Image_73:getChildByName("moneyBtn")

    count:setString(data.num)
    yuanb:setString(StringUtils:formatNumberByK(data.repairCrys))
    money:setString(StringUtils:formatNumberByK(data.repairMoney))
    local info = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",data.typeid)
    name:setString(info.name)
    name:setColor(ColorUtils:getColorByQuality(info.color))
    -- local isNew = false
    -- if item.puppet ~= nil then
    --     if item.modeId ~= data.typeid then
    --         item.puppet:finalize()
    --         item.puppet = nil
    --         isNew = true
    --     end
    -- else
    --     isNew = true
    -- end
    -- if isNew == true then
    --     local realModelId = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",info.model).modelID
    --     puppet = SpineModel.new(realModelId,person)
    --     puppet:playAnimation("wait",true)
    --     item.puppet = puppet
    --     item.modeId = data.typeid
    -- end
    if person.y == nil then
        person.y = person:getPositionY()
        person.x = person:getPositionX()
    end
    person:setPosition(person.x - 10, person.y + 18)
    if person.url ~= data.typeid then
        person.url = data.typeid
        TextureManager:onUpdateSoldierImg(person,data.typeid)
    end
    person:setScale(0.7)
    moneyBtn.type = 1
    yuanBtn.type = 2
    moneyBtn.typeid = data.typeid
    yuanBtn.typeid = data.typeid
    moneyBtn.size = 1
    yuanBtn.size = 1
    moneyBtn.cost = data.repairMoney
    yuanBtn.cost = data.repairCrys
    self:addEventPopPanel(yuanBtn)
    self:addEventPopPanel(moneyBtn)
end

function TeamReparePanel:addEventPopPanel(btn)
	if btn.isAddEvent == true then
		return
	end
	btn.isAddEvent = true
    btn.isTopButton = false
	self:addTouchEventListener(btn,self.onAllRepaireBtnHandle)
end