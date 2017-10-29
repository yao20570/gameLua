
TeamChoosePanel = class("TeamChoosePanel", BasicPanel)
TeamChoosePanel.NAME = "TeamChoosePanel"

function TeamChoosePanel:ctor(view, panelName)
    TeamChoosePanel.super.ctor(self, view, panelName,759)
    self._currPos = 1 --当前的坑位
    self._moveBtn = nil --可移动的按钮
    self._currPanel = nil
    self._maxFightCount = 0
        
    self:setUseNewPanelBg(true)
end

function TeamChoosePanel:finalize()
    TeamChoosePanel.super.finalize(self)
end

function TeamChoosePanel:initPanel()
	TeamChoosePanel.super.initPanel(self)
    self:registerEvent()
    local MovebtnPanel = self:getChildByName("Image_3/MovebtnPanel")

    self._roleProxy = self:getProxy(GameProxys.Role)
    self._soliderProxy = self:getProxy(GameProxys.Soldier)
    self:setTitle(true, self:getTextWord(335))
end

function TeamChoosePanel:onUpdateMaxCount()
	self._maxFightCount = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
end

function TeamChoosePanel:registerEvent()
    local listview = self:getChildByName("Image_3/ListView_6")
    local item = listview:getItem(0)
    listview:setItemModel(item)
    item:setVisible(false)

    local giveUpBtn = self:getChildByName("Image_3/giveUpBtn")
    self._sureBtn = self:getChildByName("Image_3/sureBtn")
    --local exitBtn = self:getChildByName("Image_3/exitBtn")
    self._useCount = self:getChildByName("Image_3/useCount")
    
    giveUpBtn:setTouchEnabled(true)
    self._sureBtn:setTouchEnabled(true)
    --exitBtn:setTouchEnabled(true)
    
    self:addTouchEventListener(giveUpBtn, self.onHideSelfTouch)
    self:addTouchEventListener(self._sureBtn, self.onHideSelfTouch)
    --self:addTouchEventListener(exitBtn, self.onHideSelfTouch)
end

function TeamChoosePanel:onHideSelfTouch(sender)
    if sender == self._sureBtn then
        self._teamPanel:setPuppetById(self._currPos,sender.modleId,sender.count)
    end
    self:hide()
    self:setSelectImgStatus(self._currPanel,false)
end

function TeamChoosePanel:onShowHandler()
    self:onUpdateMaxCount()
end

function TeamChoosePanel:setCurrPos()
    local listview = self:getChildByName("Image_3/ListView_6")
    local item = listview:getItem(0)
    local panel = item:getChildByName("panel0")
    local rest = panel:getChildByName("rest")
    local select = panel:getChildByName("select")
    local changeCount = 0
    changeCount = panel.data.num
    local maxCount = self._maxFightCount--self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)  --佣兵上线的提交
    if changeCount >  maxCount then
        changeCount = maxCount
    end
    select:setString(panel.data.num) 
    rest:setString("")
    self._useCount:setString(changeCount)
    self._currPanel = panel
    self:onItemTouch(panel)
    self:setSelectImgStatus(panel,true)
end

function TeamChoosePanel:setSelectImgStatus(panel,isShow)
    local Image_19 = panel:getChildByName("Image_19")
    local selectImg = Image_19:getChildByName("selectImg")
    selectImg:setVisible(isShow)
end

function TeamChoosePanel:updateSoliderList(data)
    local listview = self:getChildByName("Image_3/ListView_6")
    local index = 0
    local len = 0
    local item

    for _,v in pairs(data) do
        if index % 3 == 0 then
            item = listview:getItem(len)
            if item == nil then
                listview:pushBackDefaultItem()
                item = listview:getItem(len)
            end
            len = len + 1
        end
        self:registerItemEvents(item,v,index)
        index = index + 1
    end

    local tail = table.size(data) % 3
    local lastId = 0
    if tail ~= 0 then
        lastId = math.floor(table.size(data) / 3)
        local lastItem = listview:getItem(lastId)
        if lastItem then
            local panel3 = lastItem:getChildByName("panel2")
            panel3:setVisible(false)
            if tail == 1 then
                local panel2 = lastItem:getChildByName("panel1")
                panel2:setVisible(false)
            end
        end
        lastId = lastId + 1
    else
        lastId = table.size(data) / 3
    end

    while( listview:getItem(lastId) ~= nil ) do
        listview:removeItem(lastId)
    end
end

function TeamChoosePanel:registerItemEvents(item,data,index)
    if item == nil or data == nil then
        return
    end
    
    local id = index % 3
    local panel = item:getChildByName("panel"..id)
    if id == 0 then
        item:setVisible(true)
    end
    panel.index = index
    panel:setVisible(true)
    panel.data = data

--    local name = panel:getChildByName("name")
--    local info = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",data.typeid)
--    name:setString(info.name)
--    name:setColor(ColorUtils:getColorByQuality(info.color))
    
    local rest = panel:getChildByName("rest")
    local select = panel:getChildByName("select")
    
    select:setString(data.num)
    rest:setString("")
    
    if index >= 3 then
        local dot = panel:getChildByName("dot")
        local dotPositionY = dot:getPositionY()
        dot:setPositionY(dotPositionY - 30)  --模型偏移量Y，加了的给他减回来
    end
    ComponentUtils:updateSoliderPos(panel,data.typeid)
    
    local team = panel:getChildByName("Image_19")
--    -- local isNew = false
--    -- if team.puppet ~= nil then
--    --     if team.modeId ~= data.typeid then
--    --         team.puppet:finalize()
--    --         team.puppet = nil
--    --         isNew = true
--    --     end
--    -- else
--    --     isNew = true
--    -- end
--    -- if isNew == true then
--    --     local realModelId = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",info.model).modelID
--    --     local dot = team:getChildByName("dot")
--    --     local puppet = SpineModel.new(realModelId,dot)
--    --     puppet:playAnimation("wait",true)
--    --     team.puppet = puppet
--    --     team.modeId = data.typeid
--    -- end
--    local dot = team:getChildByName("dot")
--    if dot.url ~= data.typeid then
--        dot.url = data.typeid
--        TextureManager:onUpdateSoldierImg(dot,data.typeid)
--    end
    local selectImg = team:getChildByName("selectImg")
    selectImg:setVisible(false)

    self:addTouchEvent(panel)
end

function TeamChoosePanel:addTouchEvent(team)
    if team.isAdd == true then
        return
    end
    team.isAdd = true
    self:addTouchEventListener(team, self.onItemTouch)
end

function TeamChoosePanel:onItemTouch(sender)
    if self._currPanel ~= sender then
        self:setSelectImgStatus(self._currPanel,false)
        self._currPanel = sender
        self:setSelectImgStatus(self._currPanel,true)
    end
    if self._moveBtn == nil then
        local MovebtnPanel = self:getChildByName("Image_3/MovebtnPanel")
        self._moveBtn = UIMoveBtn.new(MovebtnPanel,{count = 1,moveCallback = self.setMoveCount,moveCallobj = self})
    end

    local changeCount = 0
    changeCount = sender.data.num
    local maxCount = self._maxFightCount --self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)  --佣兵上线的提交
    if changeCount >  maxCount then
        changeCount = maxCount
    end
    self._moveBtn:setEnterCount(changeCount)
    self._sureBtn.count = changeCount
    self._sureBtn.modleId = sender.data.typeid
    self._useCount:setString(changeCount)
end

function TeamChoosePanel:setMoveCount(count)
    local rest = self._currPanel:getChildByName("rest")
    local select = self._currPanel:getChildByName("select")
    rest:setString(self._currPanel.data.num - count)
    select:setString(count)
    self._sureBtn.count = count
    self._useCount:setString(count)
end

function TeamChoosePanel:onMakeCurrData(realData,panel,pos)
    --self:show()
    -- local serverListData = self._soliderProxy:getRealSoldierList()
    -- local listData = self:copyTab(serverListData)
    self._currPos = pos
    self._teamPanel = panel
    -- local exterList = {}
    -- for _ , v in pairs(list) do
    --     if v.num > 0 and v.typeid > 0 then
    --         if exterList[v.typeid] == nil then
    --             exterList[v.typeid] = v.num 
    --         else
    --             exterList[v.typeid] = exterList[v.typeid] + v.num
    --         end
    --     end
    -- end

    -- local realData = {}
    -- if table.size(exterList) > 0 then
    --     for key,v in pairs(exterList) do
    --         if listData[key] ~= nil then
    --             listData[key].num  = listData[key].num - v
    --         end
    --     end

    --     for _,v in pairs(listData) do
    --         if v.num > 0 then
    --             table.insert(realData,v)
    --         end
    --     end
    -- else
    --     realData = listData
    -- end
    
    -- if table.size(realData) <= 0 then
    --     self:showSysMessage(self:getTextWord(710))
    --     return
    -- end
    self:updateSoliderList(realData)
    self:setCurrPos()
end

-- function TeamChoosePanel:copyTab(st)  --lua的深拷贝
--     local tab = {}
--     for k, v in pairs(st or {}) do
--         if type(v) ~= "table" then
--             tab[k] = v
--         else
--             tab[k] = self:copyTab(v)
--         end
--     end
--     return tab
-- end

