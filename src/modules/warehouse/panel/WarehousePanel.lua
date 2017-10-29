-- 仓库储备界面
WarehousePanel = class("WarehousePanel", BasicPanel)
WarehousePanel.NAME = "WarehousePanel"

function WarehousePanel:ctor(view, panelName)
	self._resourceConfig = ConfigData.ResourceConfig
	self._listView = {}
    WarehousePanel.super.ctor(self, view, panelName, true)
        
    self:setUseNewPanelBg(true)
end

function WarehousePanel:finalize()
	self._listView = {}
    if self._uiResourceBuy ~= nil then
        self._uiResourceBuy:finalize()
    end
	self._uiResourceBuy = nil
    WarehousePanel.super.finalize(self)
end

function WarehousePanel:initPanel()
	WarehousePanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true,"warehouse", true)
    
    local listView = self:getChildByName("resourcesListView")
    
    self._resourcesListView = listView
	
    self._itemBuffer = {}
    self._faceItemBuff = {3191,3192,3193,3194} -- 资源外观道具buff 的ID
    self._uiResourceBuy = nil
    self._warehouseYield = nil
	self:onCreateUIResourceBuy()
end

function WarehousePanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
     local topAdaptivePanel = self:topAdaptivePanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, self._resourcesListView, GlobalConfig.downHeight,topAdaptivePanel)
end

function WarehousePanel:getItemBufferData(powerId)
    -- body
    if self._itemBuffer == nil then
        return nil
    end
    
    for _,v in pairs(self._itemBuffer) do
        if v.powerId == powerId and v.buffType == 0 then -- 只取道具加成的增益数据
            return v
        end
    end
    return nil
end

function WarehousePanel:getFaceItemBufferStatus()
    -- body

    local useStatus = false
    local face = self._faceItemBuff
    for k,v in pairs(self._itemBuffer) do
        for i=1,#face,1 do
            if v.itemId == face[i] then
                useStatus = true
                return useStatus
            end
        end
    end
    return useStatus
end

-- 读取仓库数据
function WarehousePanel:getWarehouseValue()
	local data = {}
	local info = {}
	local roleProxy = self:getProxy(GameProxys.Role)
	local conf = ConfigDataManager:getConfigData(self._resourceConfig)

	-- 银两
	data.capacity_cur = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_tael) or 0--当前拥有量
    data.capacity = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_tael_Capacity) or 0--容量
    data.yield = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_tael_Yield) or 0--产量
    -- data.capacity_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_tael_Capacity_Per) or 0--容量百分比
    data.yield_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_tael_Yield_Per) or 0--产量百分比
    data.name = conf[PlayerPowerDefine.POWER_tael].name
    data.itemBuffer = self:getItemBufferData(PlayerPowerDefine.POWER_tael_Yield_Per) or 0
    data.typeid = PlayerPowerDefine.POWER_tael
    table.insert( info, data )
    data = {}

    -- 铁锭
    data.capacity_cur = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_iron) or 0--当前拥有量
    data.capacity = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_iron_Capacity) or 0--容量
    data.yield = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_iron_Yield) or 0--产量
    -- data.capacity_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_iron_Capacity_Per) or 0--
    data.yield_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_iron_Yield_Per) or 0--
    data.name = conf[PlayerPowerDefine.POWER_iron].name
    data.itemBuffer = self:getItemBufferData(PlayerPowerDefine.POWER_iron_Yield_Per) or 0
    data.typeid = PlayerPowerDefine.POWER_iron
    table.insert( info, data )
    data = {}
    
    -- 石料
    data.capacity_cur = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_stones) or 0--当前拥有量
    data.capacity = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_stones_Capacity) or 0--容量
    data.yield = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_stones_Yield) or 0--产量
    -- data.capacity_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_stones_Capacity_Per) or 0--
    data.yield_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_stones_Yield_Per) or 0--
    data.name = conf[PlayerPowerDefine.POWER_stones].name
    data.itemBuffer = self:getItemBufferData(PlayerPowerDefine.POWER_stones_Yield_Per) or 0
    data.typeid = PlayerPowerDefine.POWER_stones
    table.insert( info, data )
    data = {}
    
    -- 木材
    data.capacity_cur = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_wood) or 0--当前拥有量
    data.capacity = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_wood_Capacity) or 0--容量
    data.yield = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_wood_Yield) or 0--产量
    -- data.capacity_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_wood_Capacity_Per) or 0--
    data.yield_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_wood_Yield_Per) or 0--
    data.name = conf[PlayerPowerDefine.POWER_wood].name
    data.itemBuffer = self:getItemBufferData(PlayerPowerDefine.POWER_wood_Yield_Per) or 0
    data.typeid = PlayerPowerDefine.POWER_wood
    table.insert( info, data )
    data = {}
    
    -- 粮食
    data.capacity_cur = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_food) or 0--当前拥有量
    data.capacity = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_food_Capacity) or 0--容量
    data.yield = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_food_Yield) or 0--产量
    -- data.capacity_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_food_Capacity_Per) or 0--
    data.yield_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_food_Yield_Per) or 0--
    data.name = conf[PlayerPowerDefine.POWER_food].name
    data.itemBuffer = self:getItemBufferData(PlayerPowerDefine.POWER_food_Yield_Per) or 0
    data.typeid = PlayerPowerDefine.POWER_food
    table.insert( info, data )
    data = {}

    -- 仓库
    data.capacity = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_warehouse_Capacity) or 0--仓库容量
    data.yield = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_warehouse_Yield) or 0--仓库保护量
    -- data.capacity_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_warehouse_Capacity_Per) or 0--仓库容量百分比
    data.yield_per = roleProxy:getRolePowerValue(GamePowerConfig.Resource,PlayerPowerDefine.POWER_warehouse_Yield_Per) or 0--仓库保护量百分比

    return info,data
end

-- 获取繁荣度的数据
function WarehousePanel:getBoomData()
    -- body
    local roleProxy = self:getProxy(GameProxys.Role)
    -- 获取繁荣度状态
    local isDestroy,destroyBoom = roleProxy:getBoomState()
    -- 取繁荣倒计时(秒) 恢复到正常的时间
    local remainTime = roleProxy:getBoomRemainTime(2)

    local data = {}
    data.isDestroy = isDestroy
    data.destroyBoom = destroyBoom
    data.remainTime = remainTime

    return data
end

function WarehousePanel:isDestroyYield(isDestroy, info)
    -- body
    if isDestroy == true then
       for k,v in pairs(info) do
            v.yield = v.yield / 2
            info[k] = v
        end 
    end
    return info
end

function WarehousePanel:table_is_empty(t)
    return _G.next( t ) == nil
end

-- 每次从panel:show()过来都走这条
function WarehousePanel:onShowHandler()
    local info1,info2 = self:getWarehouseValue()
    self._boomData = self:getBoomData()
    info1 = self:isDestroyYield(self._boomData.isDestroy, info1) --是否产量减半
    self._warehouseYield = info2.yield
    self:onShowTopPanel(info2.yield)

    self:renderListView(self._resourcesListView, info1, self, self.onRenderListViewInfo)
end

function WarehousePanel:onShowTopPanel(data)
	-- body
	local topPanel = self:getChildByName("topPanel")
	local titleLab = topPanel:getChildByName("titleLab")
	local infoLab = topPanel:getChildByName("infoLab")
    
    titleLab:setString(self:getTextWord(1000))

    local str = StringUtils:formatNumberByK3(data, PlayerPowerDefine.POWER_warehouse_Yield)
    local txtTab = {{{self:getTextWord(1001),18,"#9C724C"},{str,18,"#2ba532"},{self:getTextWord(1010),18,"#9C724C"}}}
    infoLab:setString("")

    -- 纯文字富文本显示
    local richInfoLab = self._richInfoLab
    if richInfoLab == nil then
     richInfoLab = ComponentUtils:createRichLabel("", nil, nil, 2)
     richInfoLab:setPosition(infoLab:getPosition())
     infoLab:getParent():addChild(richInfoLab)
     self._richInfoLab = richInfoLab
    end
    richInfoLab:setString(txtTab)
    self._richInfoLab:setVisible(true)

end

function WarehousePanel:onRenderListViewInfo(itempanel,info,index)
    -- body
	self:onRenderItem(itempanel,info,index)
	table.insert(self._listView,itempanel)
end

function WarehousePanel:onRenderItem(itempanel,info,index)
    -- body
    if itempanel == nil or info == nil then
    	return
    end
    itempanel:setVisible(true)

    local bgImg = itempanel:getChildByName("bgImg")
    local nameLab = bgImg:getChildByName("nameLab") --资源名字
    local resYield = bgImg:getChildByName("resYield") --资源产量
    local resYield2 = bgImg:getChildByName("resYield2") --资源产量/小时
    local capacityTitleLab = bgImg:getChildByName("capacityTitleLab") 
    local stateLab = bgImg:getChildByName("stateLab") --资源状态
    local arrowImg = bgImg:getChildByName("arrowImg") --加速箭头
    
    local barBgImg = bgImg:getChildByName("barBgImg")
    local capacityLab = barBgImg:getChildByName("capacityLab") --容量
    local capacityBar = barBgImg:getChildByName("capacityBar") --容量进度条
    
    local tipBtn = bgImg:getChildByName("tipBtn") --tip按钮
    local getBtn = bgImg:getChildByName("getBtn") --增产/减产 按钮

    local iconImg = bgImg:getChildByName("iconImg") --icon


    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Resource
    iconInfo.typeid = info.typeid
    iconInfo.num = 0
    local icon = itempanel.icon
    if icon == nil then
        icon = UIIcon.new(iconImg,iconInfo,false)
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end


    nameLab:setString(info.name)
    capacityTitleLab:setString(self:getTextWord(1003))

    -- resYield:setString(string.format(self:getTextWord(1002),StringUtils:formatNumberByK3(info.yield, nil)))--产量
    resYield:setString(StringUtils:formatNumberByK3(info.yield, nil))--产量
    local x,y = resYield:getPosition()
    local size = resYield:getContentSize()
    resYield2:setPosition(x + size.width, y) --/小时

	
    local curCapacity = StringUtils:formatNumberByK3(info.capacity_cur, nil)
    local maxCapacity = StringUtils:formatNumberByK3(info.capacity, nil)
	capacityLab:setString(curCapacity.."/"..maxCapacity)
	
    local per = nil
    if info.capacity_cur >= info.capacity then
        per = 100
    else
        per = info.capacity_cur / info.capacity * 100
    end
    capacityBar:setPercent(per)


    local curCap = tonumber(info.capacity_cur)
    local maxCap = tonumber(info.capacity)
    local warehouseCap = tonumber(self._warehouseYield)
    local txtID = nil
    local color = nil
    if curCap < warehouseCap then
        txtID = 1004 -- 完全保护
        color = ColorUtils.wordGoodColor
    elseif curCap >= maxCap then
        txtID = 1006 -- 爆仓停产
        color = ColorUtils.wordBadColor
    else
        txtID = 1005 -- 可被掠夺
        color = ColorUtils.wordWhiteColor
    end
    stateLab:setString(self:getTextWord(txtID))
    stateLab:setColor(color)


    local itemBuffer = info.itemBuffer
    if itemBuffer ~= 0 or self._useStatus == true then
        -- 加速中
        
        local url = "images/newGui2/State_add.png"
        if self._boomData.isDestroy == true then
            -- 废墟 箭头向下
            url = "images/newGui2/State_sub.png"
        end
        TextureManager:updateImageView(arrowImg,url)

        arrowImg:setVisible(true)--加速箭头
        tipBtn:setVisible(true)--加速tip按钮
        tipBtn.info = info
        self:addTouchEventListener(tipBtn,self.onTipBtnTouch)
    
    elseif self._boomData.isDestroy == true then
        -- 废墟 减速中

        local url = "images/newGui2/State_sub.png"
        TextureManager:updateImageView(arrowImg,url)

        arrowImg:setVisible(true)--加速箭头
        tipBtn:setVisible(true)--加速tip按钮
        tipBtn.info = info
        self:addTouchEventListener(tipBtn,self.onTipBtnTouch)
    else
        -- 常速
        arrowImg:setVisible(false)--加速箭头
        tipBtn:setVisible(false)--加速tip按钮
    end

	getBtn.index = index
	self:addTouchEventListener(getBtn,self.onGetBtnTouch)
end

function WarehousePanel:onTipBtnTouch(sender)
    -- body
    self:showTipContent(sender.info)
end

function WarehousePanel:onGetBtnTouch(sender)
	-- body
	--当前listview的index始于0，而配表资源道具类型始于1，故+1
	local typeRes = sender.index
	typeRes = typeRes + 1
	self:onOpenUIResourceBuy(typeRes)
end

--创建资源购买面板,只在WarehousePanel:initPanel()执行一次
function WarehousePanel:onCreateUIResourceBuy()
    local parent = self:getParent()
    local UIResourceBuy = UIResourceBuy.new(parent, self, false)--false：创建但不显示
    self._uiResourceBuy = UIResourceBuy
end

--打开资源购买面板
function WarehousePanel:onOpenUIResourceBuy(typeRes)
    if self._uiResourceBuy == nil then --判nil防止重复创建面板
        self:onCreateUIResourceBuy()
    end    
    self._uiResourceBuy:show(typeRes)--显示
end

--资源购买面板的按键请求
function WarehousePanel:onItemReq(data)
	-- body
	self.view:onItemReq(data)
end

function WarehousePanel:onUpdateListView(data)
	-- body
	for k,v in pairs(self._listView) do
		self:onRenderItem(v,data[k],k-1)
	end
end

function WarehousePanel:onWarehouseListInfo()
	-- body
	local info1,info2 = self:getWarehouseValue()
    self._boomData = self:getBoomData()
    info1 = self:isDestroyYield(self._boomData.isDestroy, info1) --是否产量减半
    self._warehouseYield = info2.yield
    self:onShowTopPanel(info2.yield)
	self:onUpdateListView(info1) --TODO 全部刷新效率待定
end

-- 拿到道具buffer数据，更新界面显示
function WarehousePanel:onItemBufferUpdate()
    -- body
    -- logger:info("更新道具buffer···WarehousePanel:onItemBufferUpdate()----------------0")
    local itemBuffProxy = self:getProxy(GameProxys.ItemBuff)
    local itemBuffInfo = itemBuffProxy:getItemBuffInfos()

    self._itemBuffer = itemBuffInfo
    self._useStatus = self:getFaceItemBufferStatus()

    if self._itemBuffer ~= nil then
        -- logger:info("更新道具buffer···WarehousePanel:onItemBufferUpdate()----------------1")
        self:onWarehouseListInfo()
    end
end

function WarehousePanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function WarehousePanel:getBuffRemainTime(itemId, typeid, powerid)
    -- body
    local itemBuffProxy = self:getProxy(GameProxys.ItemBuff)
    local remainTime = itemBuffProxy:getBuffRemainTimeByMore(itemId, typeid, powerid)

    -- print("仓库资源tip···WarehousePanel: itemId, typeid, powerid, remainTime", itemId, typeid, powerid, remainTime)
    return remainTime
end

-- 仓库资源tip
function WarehousePanel:showTipContent(info)
    -- body

    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {}
    
    local content1 = string.format(self:getTextWord(100000), info.name, StringUtils:formatNumberByK3(info.yield, nil))
    local content2 = self:getTextWord(100001)
    local line1 = {{content = content1, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line2 = {{content = content2, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    table.insert(lines, line1)
    table.insert(lines, line2)

    local itemBuffer = info.itemBuffer
    if itemBuffer ~= 0 then
        local time = self:getBuffRemainTime(itemBuffer.itemId,itemBuffer.type, itemBuffer.powerId)
        logger:info(itemBuffer.itemId .."||".. itemBuffer.type.."||"..itemBuffer.powerId)
        -- 资源道具buff
        if itemBuffer.type == 3 then
            local content4 = string.format(self:getTextWord(100003), info.name, itemBuffer.value, TimeUtils:getStandardFormatTimeString8(time))
            local line4 = {{content = content4, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1603}}
            table.insert(lines, line4)      
        end
    end

    -- 资源外观道具buff
    local conf = ConfigDataManager:getConfigData(ConfigData.ItemConfig)
    for k,v in pairs(self._itemBuffer) do
        for i,j in pairs(self._faceItemBuff) do
            if v.itemId == j and v.powerId == 79 then
                local time = self:getBuffRemainTime(v.itemId,v.type, v.powerId)
                local content3 = string.format(self:getTextWord(100002), conf[j].name, v.value, TimeUtils:getStandardFormatTimeString8(time))
                local line3 = {{content = content3, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1603}}
                table.insert(lines, line3)                 
            end
        end
    end

    -- 废墟时减产信息
    if self._boomData.isDestroy == true then
        local content = string.format(self:getTextWord(100004), TimeUtils:getStandardFormatTimeString8(self._boomData.remainTime))
        local line = {{content = content, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1604}}
        table.insert(lines, line)
    end

    uiTip:setAllTipLine(lines)  
end
