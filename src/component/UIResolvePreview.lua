-----------
---查看配置信息-----

UIResolvePreview = class("UIResolvePreview")

--即关即释放
function UIResolvePreview:ctor(panel, data)
    local uiSkin = UISkin.new("UIResolvePreview")
    uiSkin:setParent(panel:getParent())
    uiSkin:setTouchEnabled(true)
    local secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    secLvBg:setContentHeight(560)
    secLvBg:setBackGroundColorOpacity(128)
    secLvBg:setTitle(TextWords:getTextWord(326))

    self._secLvBg = secLvBg
    self._uiSkin = uiSkin
    self._panel = panel

    self._data = data
    self:_updateInfo(data)

    self:registerEventHandler()
end

function UIResolvePreview:finalize()
    self._uiSkin:finalize()
end

function UIResolvePreview:hide()
    TimerManager:addOnce(1, self.finalize, self)
end

function UIResolvePreview:_updateInfo(data)
    local tag = data.tag --碎片分解还是配件分解：1配件，2碎片，3宝具，4宝具碎片
    local isBatch = data.isBatch --是否是批量分解：true or false
    local infos = data.datas --配件或碎片数组
    local items = {}
    self._ids = {} --待分解的id
    if tag == 1 then
        for _,v in pairs(infos) do
            table.insert(self._ids,v.id)
        end 
        items = self:getPartsBack()
    elseif tag == 2 then
        for _,v in pairs(infos) do
            table.insert(self._ids,v.typeid)
        end
        items = self:getPieceBack()
    elseif tag == 3 then
        for _,v in pairs(infos) do
            table.insert(self._ids,v.id)
        end
        
        items = self:getTreasureBack()
    elseif tag == 4 then
        for _,v in pairs(infos) do
            table.insert(self._ids,v.typeid)
        end
        items = self:getTreasurePieceBack()
    end
    --改变背景大小
    local lines = 1
    if #items > 4 then
        lines = 3
        self._secLvBg:setContentHeight(560)
    elseif #items > 2 then
        lines = 2
        self._secLvBg:setContentHeight(460)
    else
        self._secLvBg:setContentHeight(360)
    end 
    local mainPanel = self._uiSkin:getChildByName("mainPanel")
    NodeUtils:adaptivePanel(mainPanel,lines,3,100)  --通过行数调整背景大小
    local maxItems = 6
    for i=1,maxItems,1 do
        local iconPanel = self._uiSkin:getChildByName("mainPanel/midBg/iconPanel" .. i)
        if i > #items then
            iconPanel:setVisible(false)
        else
            local conIcon = iconPanel:getChildByName("iconContainer")
            local labelName = iconPanel:getChildByName("Label_name")
            local labelNum = iconPanel:getChildByName("Label_num")
            local temp = {}
            temp.num = 1
            temp.power = items[i].power
            temp.typeid = items[i].typeid
            local uiIcon = UIIcon.new(conIcon,temp,false)
            uiIcon:setPosition(conIcon:getContentSize().width/2,conIcon:getContentSize().height/2)
            local configData = ConfigDataManager:getConfigByPowerAndID(items[i].power,items[i].typeid)--getConfigById(items[i].config, items[i].typeid)
            labelName:setString(configData.name)
            labelNum:setString(items[i].num)
        end 
    end
end
--获取配件分解返还
function UIResolvePreview:getPartsBack()
    local infos = self._data.datas --配件数组
    local items = {}
    for _,v in pairs(infos) do
        --强化返回:固定typeid:201
        local intensifyBack = self:getPartsIntensifyConfigData(v.strgthlv,v.quality,v.part)
        if #intensifyBack > 0 and intensifyBack[1][3] > 0 then
            local index = self:getIndexByTypeid(items,intensifyBack[1][2])
            if index == 0 then
                local temp = {}
                temp.num = intensifyBack[1][3]
                temp.typeid = intensifyBack[1][2]
                temp.power = intensifyBack[1][1]--GamePowerConfig.Resource
                temp.config = ConfigData.ResourceConfig
                table.insert(items,1,temp) 
            else
                local item = items[index]
                item.num = item.num + intensifyBack[1][3]
            end 
        end 
        --改造返回
        local remouldBack = self:getPartsRemouldConfigData(v.remoulv,v.quality,v.part)
        if #remouldBack > 0 then
            for _,value in pairs(remouldBack) do
                if value[3] > 0 then
                    local index = self:getIndexByTypeid(items,value[2])
                    if index == 0 then
                        local temp = {}
                        temp.num = value[3]
                        temp.typeid = value[2]
                        temp.power = value[1]--GamePowerConfig.Item
                        temp.config = ConfigData.ItemConfig
                        table.insert(items,temp)
                    else
                        local item = items[index]
                        item.num = item.num + value[3]
                    end 
                end
            end 
        end 
    end 
    return items
end 
function UIResolvePreview:getIndexByTypeid(table,typeid)
    local index = 0
    for k,v in pairs(table) do
        if v.typeid == typeid then
            index = k
            break
        end 
    end 
    return index
end 
--获取碎片分解返还
function UIResolvePreview:getPieceBack()
    local infos = self._data.datas --碎片数组
    local isBatch = self._data.isBatch
    local num = 0
    local items = {} 
    for _,v in pairs(infos) do
        local configData = ConfigDataManager:getConfigById(ConfigData.OrdnancePieceConfig, v.typeid)
        local mul = 1
        if isBatch == true then
            mul = v.num
        end 
        num = num + configData.remouldItemFour*mul
    end 
    if num > 0 then
        local temp = {}
        temp.num = num
        temp.typeid = 4018 --零件
        temp.power = GamePowerConfig.Item
        temp.config = ConfigData.ItemConfig
        table.insert(items,temp)
    end 
    return items
end
--获取宝具分解返还
function UIResolvePreview:getTreasureBack()
    local infos = self._data.datas --数组
    local items = {}
    for _,v in pairs(infos) do
        local configData = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, v.typeid)
        local resolveBack = StringUtils:jsonDecode(configData.resolve)
        if #resolveBack > 0 and resolveBack[1][3] > 0 then
            local index = self:getIndexByTypeid(items,resolveBack[1][2])
            if index == 0 then
                local temp = {}
                temp.num = resolveBack[1][3]
                temp.typeid = resolveBack[1][2]
                temp.power = resolveBack[1][1]--GamePowerConfig.Resource
                temp.config = ConfigData.ResourceConfig
                table.insert(items,1,temp) 
            else
                local item = items[index]
                item.num = item.num + resolveBack[1][3]
            end 
        end 


    end 
    return items
end
--获取宝具碎片分解返还
function UIResolvePreview:getTreasurePieceBack()
    local infos = self._data.datas --宝具碎片数组
    local isBatch = self._data.isBatch
    local num = 0
    local items = {}
    for _,v in pairs(infos) do
        --强化返回:固定typeid:201
        local configData = ConfigDataManager:getConfigById(ConfigData.TreasurePieceConfig, v.typeid)
        local intensifyBack = StringUtils:jsonDecode(configData.remouldItemFour)
        if #intensifyBack > 0 and intensifyBack[1][3] > 0 then
            local index = self:getIndexByTypeid(items,intensifyBack[1][2])
            if index == 0 then
                local temp = {}
                
                if isBatch == true then
                     temp.num = v.num*intensifyBack[1][3]
                 else
                     temp.num = intensifyBack[1][3]
                end 
                temp.typeid = intensifyBack[1][2]
                temp.power = intensifyBack[1][1]--GamePowerConfig.Resource
                temp.config = ConfigData.ResourceConfig
                table.insert(items,1,temp) 
            else
                local item = items[index]
                --item.num = item.num + intensifyBack[1][3]
                if isBatch == true then
                    item.num = item.num + intensifyBack[1][3]*v.num
                 else
                    item.num = item.num + intensifyBack[1][3]
                end 
            end 
        end 


    end 
    return items
end
function UIResolvePreview:registerEventHandler()
    --分解按钮
    local resolveBtn = self:getChildByName("mainPanel/downPanel/resolveBtn")
    --取消按钮
    local cancelBtn = self:getChildByName("mainPanel/downPanel/cancelBtn")
    -- local closeBtn = self:getChildByName("mainPanel/bigBg/closeBtn")
    
    ComponentUtils:addTouchEventListener(resolveBtn, self.onResolveBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(cancelBtn, self.onCancelBtnTouch, nil, self)
    -- ComponentUtils:addTouchEventListener(closeBtn, self.onCloseBtnTouch, nil, self)

end
--读取军械强化配置表
function UIResolvePreview:getPartsIntensifyConfigData(strenLv,quality,part)
    local t = ConfigDataManager:getConfigData(ConfigData.OrdnanceStrConfig)
    for _,v in pairs(t) do
        if strenLv == v.level and quality == v.quality then
            local back = {}
            if part < 5 then
                back = StringUtils:jsonDecode(v.onetofourresolve)
            else
                back = StringUtils:jsonDecode(v.fivetoreightresolve)
            end 
            return back
        end 
    end 
end 
--读取军械改造配置表
function UIResolvePreview:getPartsRemouldConfigData(remLv,quality,part)
    local t = ConfigDataManager:getConfigData(ConfigData.OrdnanceRemConfig)
    local back = {}
    for _,v in pairs(t) do
        if remLv == v.remouldLv and quality == v.quality  and part == v.part then
            back = StringUtils:jsonDecode(v.remould)
            break
        end 
    end 
    return back
end 
function UIResolvePreview:onCloseBtnTouch(sender)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIResolvePreview:onResolveBtnTouch(sender)
    --self._panel:onResolveTouchHandler(self._data)
    if #self._ids > 0 then
        local partsProxy = self._panel:getProxy(GameProxys.Parts)
        if self._data.tag == 1 then
            
            local data = {}
            data.id = self._ids
            partsProxy:ordnanceResolveReq(data)
        elseif self._data.tag == 2 then
            local type = 1
            if self._data.isBatch == true then
                type = 2
            end 
            local data = {}
            data.type = type --1单个分解,2批量分解
            data.typeid = self._ids
            partsProxy:pieceResolveReq(data)
        elseif self._data.tag == 3 then
            local type = 1
            if self._data.isBatch == true then
                type = 2
            end 
            local data = {}
            data.treasuredId = self._ids
            local htProxy = self._panel:getProxy(GameProxys.HeroTreasure)
            htProxy:onTriggerNet350003Req(data)
        elseif self._data.tag == 4 then
            local type = 1
            if self._data.isBatch == true then
                type = 2
            end 
            local data = {}
            data.type = type --1单个分解,2批量分解
            data.typeid = self._ids
            local htProxy = self._panel:getProxy(GameProxys.HeroTreasure)
            htProxy:onTriggerNet350004Req(data)
        end 
    end 
    TimerManager:addOnce(1, self.finalize, self)
end

function UIResolvePreview:onCancelBtnTouch(sender)
    --self._panel:onCancelTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end
function UIResolvePreview:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

