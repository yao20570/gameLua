
GainInfoPanel = class("GainInfoPanel", BasicPanel)
GainInfoPanel.NAME = "GainInfoPanel"

function GainInfoPanel:ctor(view, panelName)
    GainInfoPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function GainInfoPanel:finalize()
    if self._UIResourceBuy ~= nil then
        self._UIResourceBuy:finalize()
        self._UIResourceBuy = nil
    end
    GainInfoPanel.super.finalize(self)
end
--显示界面时调用
function GainInfoPanel:onShowHandler(data)
    GainInfoPanel.super.onShowHandler(self)
    -- local btnPanel = self:getChildByName("btnPanel")
    -- NodeUtils:adaptiveListView(self._listView, btnPanel, GlobalConfig.topHeight)
    if self._listView ~= nil then
        self._listView:jumpToTop()
        self:updateData2()
    end 
end 

function GainInfoPanel:onClosePanelHandler()
    self.view:dispatchEvent(GainEvent.HIDE_SELF_EVENT)
end

function GainInfoPanel:initPanel()
    GainInfoPanel.super.initPanel(self)

    -- 新手保护罩Buff，获取按钮隐藏
    self._itemBuffProxy = self:getProxy(GameProxys.ItemBuff)
    self._newRoleBuffConfig = self._itemBuffProxy:addNewRoleBuff()

    --配置表数据
    local gainInfoConfig = self:getGainInfoConfig()
    self._configData = gainInfoConfig.configData
    self._constantInfos = gainInfoConfig.constantInfos
    self._powerList = gainInfoConfig.powerList
    self._ruinInfo = gainInfoConfig.ruinInfo
    --buffer数据
    self._serverDatas = {} 
    --items
    self._items = {}

    
    self._listView = self:getChildByName("ListView")
    local vipBtn = self:getChildByName("btnPanel/Button_vip")
    local resGainBtn = self:getChildByName("btnPanel/Button_resGain")
    self:addTouchEventListener(vipBtn,self.onBtnVipClicked)
    self:addTouchEventListener(resGainBtn,self.onBtnResGainClicked)
    
    
    self:initListView()
end

function GainInfoPanel:doLayout()
    self:adaptivePanel()
end

function GainInfoPanel:adaptivePanel()
    -- body
    local btnPanel = self:getChildByName("btnPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,btnPanel, tabsPanel)

end

--获取增益信息配置表数据
function GainInfoPanel:getGainInfoConfig()
    local configData = ConfigDataManager:getConfigData(ConfigData.BuffMessageConfig)
    local powerList = {}
    local constantInfos = {} 
    local ruinInfo = nil
    for _,v in pairs(configData) do 
        if v.showtype == 1 then
            table.insert(constantInfos,v) -- 类型1的表
        end 
        if v.showtype == 3 then
            ruinInfo = v -- 废墟数据
        end 
        local powers = StringUtils:jsonDecode(v.power)
        for _,w in pairs(powers) do
            powerList[w] = v.type -- power对应的type表格
        end 
    end 
    table.sort(constantInfos,function(a,b) return a.sort < b.sort end)

    -- 新手保护罩Buff
    local isHave = self._itemBuffProxy:isHaveNewRoleBuff()
    if isHave == true then
        local newRoleBuff = self._itemBuffProxy:addNewRoleBuff()
        table.insert(constantInfos,newRoleBuff)
    end

    local temp = {}
    temp.configData = configData        -- 整张配置表
    temp.powerList = powerList          -- power对应的type表格
    temp.constantInfos = constantInfos  -- 类型1的表
    temp.ruinInfo = ruinInfo            -- 废墟数据
    return temp
end 

--通过type值获取增益配置数据
function GainInfoPanel:getDataByType(type)
    local configData = self._configData
    for _,v in pairs(configData) do
        if v.type == type then
            return v
        end 
    end 
    return nil
end 

-----------------------------------------------------------------------------------------
--更新数据
function GainInfoPanel:updateData(data)
    if data == nil then return end 

    local temp = {}
    --筛选增益模块的buffer数据,存放在temp中
    for k,v in pairs(self._powerList) do
       for _,w in pairs(data) do
          if k == w.powerId and w.buffType == 0 then
              -- print("增益Buffer数据：itemId,powerId,value,time",w.itemId,w.powerId,w.value,w.time)
              temp[v] = w
              break 
          end 
       end   
    end

    local sDatas = self._serverDatas --上一次的增益buffer数据
    local updates = {} --存放新增和结束的buffer数据
    --把增益buffer结束的数据删除
    for k,v in pairs(sDatas)do
        -- print("已存放的增益Buffer数据：itemId,powerId,value,time",v.itemId,v.powerId,v.value,v.time)
        if temp[k] == nil then --如果不在增益buffer数据中说明已结束
            sDatas[k] = nil --删除但不移动元素，保证可以全部遍历
            table.insert(updates,k)
            -- print("updates···插入删除 k",k)
        end 
    end

    --把新增的增益buffer数据存放在self._serverDatas中和修改有效时间变了的数据
    for k,v in pairs(temp) do
        if sDatas[k] == nil then --新增的则插入
            sDatas[k] = v
            table.insert(updates,k)
        else
            if sDatas[k].time ~= v.time or sDatas[k].value ~= v.value then --有效时间或加成比变了则更新
                sDatas[k] = v
                table.insert(updates,k)
            end
        end 
    end

    --只更新新增、有效时间加成比变了和结束的item
    for _,v in pairs(updates)do
        local itemPanel = self._items[v]
        local info = self:getDataByType(v)
        if info.showtype == 1 then
            -- print("L132···renderItemPanel -- showtype",info.showtype)
            self:renderItemPanel(itemPanel,info)
        else
            if self._serverDatas[v] == nil then 
                if itemPanel ~= nil then
                    local index = self._listView:getIndex(itemPanel)
                    -- print("buff...removeItem index",index)
                    self._listView:removeItem(index)
                    self._items[v] = nil
                end 
            else
                if itemPanel == nil then
                    -- print("···itemPanel == nil 头部插入")
                    
                    -- 头部插入
                    self._listView:insertDefaultItem(0)
                    itemPanel = self._listView:getItem(0)

                    -- -- 尾部插入
                    -- self._listView:pushBackDefaultItem()
                    -- itemPanel = self._listView:getItem(table.size(items)-1)

                    -- local items = self._listView:getItems()
                    -- print("···table.size(items) itemPanel",table.size(items),itemPanel)
                end 
                -- print("新增buff···v ID showType power type", v, info.ID, info.showtype, info.power, info.type)
                self:renderItemPanel(itemPanel,info)
            end 
        end 
    end
end

function GainInfoPanel:updateData2()
    local roleProxy = self:getProxy(GameProxys.Role)
    local state = roleProxy:getBoomState()
    local allTime = roleProxy:getBoomRemainTime(3)
    local boomState = 1
    if state == true then
        boomState = 0
    end 
    local type = self._ruinInfo.type
    local itemPanel = self._items[type]
    self._ruinTime = allTime
    if boomState == 0 then --废墟
        if itemPanel == nil then
            self._listView:insertDefaultItem(0)
            itemPanel = self._listView:getItem(0)
            self:renderItemPanel(itemPanel,self._ruinInfo)
        end 
    else --正常
        if itemPanel ~= nil then
            local index = self._listView:getIndex(itemPanel)
            self._listView:removeItem(index)
            self._items[type] = nil
        end 
    end 
end 
function GainInfoPanel:initListView()
    if self._listView == nil then
        return 
    end 
    --初始化listView
    local infos = self._constantInfos
    self:renderListView(self._listView, infos, self, self.renderItemPanel)    
end

function GainInfoPanel:renderItemPanel(itemPanel,info,index)
    if itemPanel == nil then 
        logger:error("=================itemPanel is nil !!!================")
        return 
    end
    itemPanel:setVisible(true)

    if itemPanel.itemChildren == nil then
        itemPanel.itemChildren = self:getItemChildren(itemPanel)
    end 
    local itemChildren = itemPanel.itemChildren
    
    local configData = info
    local serverData = self._serverDatas[configData.type]
    itemPanel.serverData = serverData  --保存服务器数据
    self._items[configData.type] = itemPanel   
    
    --图标 
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = configData.icon
    iconInfo.num = 0

    local icon = itemPanel.icon
    if icon == nil then
        local conImg = itemChildren.conImg
        icon = UIIcon.new(conImg,iconInfo,false)
        
        itemPanel.icon = icon
    else
        icon:updateData(iconInfo)
    end

    --描述
    local proBarVisible = false
    local nums = StringUtils:jsonDecode(configData.value)
    local num = nums[1]
    if serverData ~= nil then
        local base = 1
        if configData.change ~= 0 then
            base = configData.change/100
        end 
        num = serverData.value/base
        proBarVisible = true
    end
    if configData.showtype == self._ruinInfo.showtype then
        proBarVisible = true
    end 
    local descStr = configData.info
    if num > 0 then
        local numStr = num .."%"
        descStr = string.format(configData.info,numStr)
        -- print("增益...num",num)
    end 
    local labelDesc = itemChildren.labelDesc
    labelDesc:setString(descStr)
    --进度条
    local conProgress = itemChildren.conProgress
    conProgress:setVisible(proBarVisible) 
    --按钮
    local btnUpgrate = itemChildren.btnUpgrate 
    btnUpgrate.data = configData.type
    if configData.showtype ~= 1 then
        btnUpgrate:setVisible(false)
    end


    -- 新手保护罩Buff，获取按钮隐藏
    if configData.type == self._newRoleBuffConfig.type then
        btnUpgrate:setVisible(false)
        conProgress:setVisible(true)
    else
        btnUpgrate:setVisible(true)
    end

    -- print("渲染 === type, showtype, value index descStr",info.type,info.showtype,info.value,index,descStr) 
end 

--更新item的倒计时
function GainInfoPanel:updateItemProgress()
    if self._items == nil then return end 
    -- local systemProxy = self:getProxy(GameProxys.System)
    local buffProxy = self:getProxy(GameProxys.ItemBuff)
    for configDataType, v in pairs(self._items) do
        if v.serverData ~= nil then
            local itemChildren = v.itemChildren
            local proBar = itemChildren.proBar
            local labelTime = itemChildren.labelTime
            local data = v.serverData
            -- local time = systemProxy:getRemainTime(SystemTimerConfig.ITEM_BUFF, data.type, data.powerId)
            local time = buffProxy:getBuffRemainTimeByMore(data.itemId, data.type, data.powerId)
            -- print("增益.更新item的倒计时···time", time)
            if time == 0 then
                print("time,power===",time,data.powerId)
                local power = data.powerId
                local type = self._powerList[power]
                self._serverDatas[type] = nil
                local itemPanel = v
                local info = self:getDataByType(type)
                if info.showtype == 1 then
                    self:renderItemPanel(itemPanel,info)
                    proBar:setPercent(0)
                else
                    local index = self._listView:getIndex(itemPanel)
                    self._listView:removeItem(index)
                    self._items[type] = nil
                end 
            else
            
                local timeStr = TimeUtils:getStandardFormatTimeString8(time)
                local percent = (data.time-time)/data.time*100
                proBar:setPercent(percent)
                labelTime:setString(timeStr)
                -- print("增益 power,remainTime,allTime,percent===",data.powerId,timeStr,data.time,percent)
                
            end 
        end 
    end 
end 

--更新废墟倒计时
function GainInfoPanel:updateRuinItemProgress()
    local type = self._ruinInfo.type
    local itemPanel = self._items[type]
    if itemPanel ~= nil then
        local allTime = self._ruinTime
        local itemChildren = itemPanel.itemChildren
        local proBar = itemChildren.proBar
        local labelTime = itemChildren.labelTime
        local roleProxy = self:getProxy(GameProxys.Role)
        local time = roleProxy:getBoomRemainTime(2)
        if time == 0 then
            local index = self._listView:getIndex(itemPanel)
            self._listView:removeItem(index)
            self._items[type] = nil
        else
            local timeStr = TimeUtils:getStandardFormatTimeString8(time)
            local percent = (allTime-time)/allTime*100
            proBar:setPercent(percent)
            labelTime:setString(timeStr)
        end 
    end 
end

--更新新手保护罩倒计时
function GainInfoPanel:updateNewRoleBuffTime()
    logger:info("--更新新手保护罩倒计时 00000000000000")
    local type = self._newRoleBuffConfig.type
    local itemPanel = self._items[type]
    if itemPanel ~= nil then
        logger:info("--更新新手保护罩倒计时 11111111111111")
        local remainTime = self._itemBuffProxy:getNewRoleRemainTime()
        local protectTime = self._itemBuffProxy:getValueFromConfigByDescribe("protectTime")
        local allTime = protectTime.number

        local itemChildren = itemPanel.itemChildren
        local proBar = itemChildren.proBar
        local labelTime = itemChildren.labelTime
        if remainTime == 0 then
            logger:info("--更新新手保护罩倒计时 22222222222222")
            local index = self._listView:getIndex(itemPanel)
            self._listView:removeItem(index)
            self._items[type] = nil
        else
            logger:info("--更新新手保护罩倒计时 3333333333333")
            local timeStr = TimeUtils:getStandardFormatTimeString8(remainTime)
            local percent = (allTime-remainTime)/allTime*100
            proBar:setPercent(percent)
            labelTime:setString(timeStr)
        end 
    end 
end

--获取item的子节点
function GainInfoPanel:getItemChildren(itemPanel)
    local itemChildren = {}
    itemChildren.conImg      = itemPanel:getChildByName("Image_icon")
    itemChildren.labelDesc   = itemPanel:getChildByName("Label_desc")
    itemChildren.conProgress = itemPanel:getChildByName("Panel_progress")
    local temp = itemChildren.conProgress
    itemChildren.proBar      = temp:getChildByName("ProgressBar")
    itemChildren.labelTime   = temp:getChildByName("Label_time")
    itemChildren.btnUpgrate  = itemPanel:getChildByName("Button_upgrate")
    
    itemChildren.labelTime:setString("")
    itemChildren.proBar:setPercent(0)
    self:addTouchEventListener(itemChildren.btnUpgrate,self.onBtnUpgrateClicked)
    return itemChildren
end

-------------回调函数定义--------------------

--VIP特权 按钮
function GainInfoPanel:onBtnVipClicked(sender)
 -- self:showSysMessage("on Vip 特权 Btn")
    SDKManager:showWebHtmlView("html/vip.html")
end 
--资源增益
function GainInfoPanel:onBtnResGainClicked(sender)
    local moduleName = ModuleName.WarehouseModule
    self:dispatchEvent(GainEvent.SHOW_OTHER_EVENT, moduleName)
end 
--提升
function GainInfoPanel:onBtnUpgrateClicked(sender)
    local type = sender.data
    if self._UIResourceBuy == nil then --判nil防止重复创建面板
        local parent = self:getParent()
        local UIResourceBuy = UIResourceBuy.new(parent, self, false)--false：创建但不显示
        self._UIResourceBuy = UIResourceBuy
    end    
    logger:info("type=%d",type)
    self._UIResourceBuy:show(type)--显示
end 
--使用/购买使用
function GainInfoPanel:onItemReq(data)
    self.view:dispatchEvent(GainEvent.SEND_BUY_EVENT,data)
end


-- 拿到道具buffer数据，更新界面显示
function GainInfoPanel:onItemBufferUpdate()
    -- body
    logger:info("更新道具buffer··· 增益:onItemBufferUpdate()----------------0")
    local itemBuffInfo = self._itemBuffProxy:getItemBuffInfos()
    self:updateData(itemBuffInfo)

end

-------------------------------------------------------------------------------
--定时器
-------------------------------------------------------------------------------
function GainInfoPanel:update()
    self:updateItemProgress()
    self:updateRuinItemProgress()
    self:updateNewRoleBuffTime()
end 


