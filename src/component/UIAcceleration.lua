--加速生产 统一UI
UIAcceleration = class("UIAcceleration", BasicComponent)

function UIAcceleration:ctor(parent, panel,type)
    UIAcceleration.super.ctor(self)
    parent = panel:getPanelRoot()
    local uiSkin = UISkin.new("UIAcceleration", nil, nil, panel:getModuleName())
    uiSkin:setParent(parent)
    uiSkin:setLocalZOrder(100)
    uiSkin:setTouchEnabled(true)
    
    self.secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    self.secLvBg:setContentHeight(700)
    self.secLvBg:setTitle(TextWords:getTextWord(327))
    self.secLvBg:setBackGroundColorOpacity(120)
    
    self._uiSkin = uiSkin
    self._panel = panel
    
    self:registerProxyEvent()
    
    self:registerEventHandler()

    -- -- 自适应分辨率
    -- local scale = NodeUtils:getAdaptiveScale()
    -- local mainPanel = self:getChildByName("mainPanel")
    -- mainPanel:setScale(1/scale)

    self.type = type
end

function UIAcceleration:finalize()
    local proxy = self._panel:getProxy(GameProxys.Building)
    proxy:removeEventListener(AppEvent.PROXY_BUILDING_UPDATE, self, self.onBuildingUpdate)
    proxy:removeEventListener(AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.updateBuffNum)
    self._selectBox:removeFromParent()
    self._selectBox:release()
    self._selectBox = nil

    if self._uiMoveBtn then
        self._uiMoveBtn:finalize()
    end
    if self._uiGoodsPanel ~= nil then
        self._uiGoodsPanel:finalize()
        self._uiGoodsPanel = nil
    end
    self._uiSkin:finalize()
    UIAcceleration.super.finalize(self)
end

function UIAcceleration:registerProxyEvent()
    local proxy = self._panel:getProxy(GameProxys.Building)
    proxy:addEventListener(AppEvent.PROXY_BUILDING_UPDATE, self, self.onBuildingUpdate)
    proxy:addEventListener(AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.updateBuffNum)
end

function UIAcceleration:updateBuffNum()
    if self._uiSkin:isVisible() ~= true then
        return
    end
    self:renderAllItem(self._prospeeditem)
end

function UIAcceleration:onBuildingUpdate()
    if self._uiSkin:isVisible() ~= true then
        return
    end
    
    local nameTxt = self:getChildByName("mainPanel/itemPanel0/nameTxt")
    local buildingProxy = self._panel:getProxy(GameProxys.Building)

    local buildingInfo = buildingProxy:getCurBuildingInfo()
    if self._buildingInfo == nil or buildingInfo == nil or
       buildingInfo.level ~= self._buildingInfo.level then
        self:hide()
        return
    end
    --这里不调整buff列表的跳转，加多个参数，让updateBUffNum去控制
    self:renderAllItem(self._prospeeditem, nil, true)
    self:update()
    
end

function UIAcceleration:show(buildingInfo, productionInfo,extroInfo, maxTime)
    self:delayshow(buildingInfo, productionInfo,extroInfo, maxTime)
    -- TimerManager:addOnce(30, self.delayshow, self, buildingInfo, productionInfo,extroInfo, maxTime)
end

--typeid为空，或者等于0 则为建筑的 --计算出来的最大时间
function UIAcceleration:delayshow(buildingInfo, productionInfo,extroInfo, maxTime)

    self._buildingInfo = buildingInfo
    self._productionInfo = productionInfo
    self._extroInfo = extroInfo
    self._maxTime = maxTime
    
    self._uiSkin:setVisible(true)
    
    local buildingType = buildingInfo.buildingType
    
    local info = ConfigDataManager:getInfoFindByOneKey(
        ConfigData.BuildSheetConfig, "type", buildingType)
    --获取加速道具列表
    
    local prospeeditem = nil
    
    if productionInfo == nil then
        prospeeditem = {3134,3135,3136,3131,3137,3132,3133}  --建筑升级道具，直接先写死
        self:renderBuildingInfo(buildingInfo, maxTime)
        self.secLvBg:setTitle(TextWords:getTextWord(332))
    else
        prospeeditem = StringUtils:jsonDecode(info.prospeeditem)
        self:renderProductionInfo(productionInfo, buildingInfo, info.prosheet,extroInfo ,maxTime)
    end
    
    self._prospeeditem = prospeeditem
    self:renderAllItem(prospeeditem, true)
    self:update()
end

function UIAcceleration:isFreeAccelerate(time)
    local  goldBtn = self:getChildByName("mainPanel/itemPanel0/goldBtn")
    local  freeBtn = self:getChildByName("mainPanel/freeBtn")
    local  upBtn = self:getChildByName("mainPanel/Button_72")
    local  countTxt = self:getChildByName("mainPanel/Label_66_0_1")
    local  countNumTxt = self:getChildByName("mainPanel/numLab")
    local  Image_51 = self:getChildByName("mainPanel/itemPanel0/Image_51")
    local  numLab = self:getChildByName("mainPanel/itemPanel0/numLab")
    local roleProxy = self._panel:getProxy(GameProxys.Role)
    local freeTime = roleProxy:getFreeTime()
    if self.type then
        local isFree = nil
        if time <= freeTime then  --免费加速
            isFree = true
        else
            isFree = false
        end

        freeBtn:setVisible(isFree)
        upBtn:setVisible(not isFree)
        countTxt:setVisible(not isFree)
        countNumTxt:setVisible(not isFree)
        goldBtn:setVisible(not isFree)
        Image_51:setVisible(not isFree)
        numLab:setVisible(not isFree)
    end
end

--建筑类型的加速
function UIAcceleration:renderBuildingInfo(buildingInfo, maxTime)
    local nameTxt = self:getChildByName("mainPanel/itemPanel0/nameTxt")
    local imgContainer = self:getChildByName("mainPanel/itemPanel0/imgContainer")
    local lvlTxt = self:getChildByName("mainPanel/itemPanel0/lvlTxt")
    local buildingProxy = self._panel:getProxy(GameProxys.Building)
    lvlTxt:setVisible(true)
    
    local buildingType = buildingInfo.buildingType

    local info = buildingProxy:getBuildingConfigInfo(buildingType, buildingInfo.level)
    
    nameTxt:setString(info.name)

    lvlTxt:setString(string.format(TextWords:getTextWord(529), buildingInfo.level))
    NodeUtils:alignNodeL2R(nameTxt, lvlTxt, 10)

    local data = {}
    data.power = GamePowerConfig.Building
    data.typeid = buildingType
    data.num = 0
    local icon = imgContainer.icon
    if icon == nil then
        icon = UIIcon.new(imgContainer,data,false)
        
        imgContainer.icon = icon
    else
        icon:updateData(data)
    end

    local timeKeyInfo = {}
    timeKeyInfo.bigtype = SystemTimerConfig.BUILDING_LEVEL_UP
    timeKeyInfo.smalltype = buildingType
    timeKeyInfo.othertype = buildingInfo.index
    
    self._timerKeyInfo = timeKeyInfo
    
    local buildingType = buildingInfo.buildingType
    local level = buildingInfo.level
    local buildingProxy = self._panel:getProxy(GameProxys.Building)
    local configInfo = buildingProxy:getBuildingConfigInfo(buildingType, level)
    
    self._buildingType = buildingType
    self._index = buildingInfo.index
    
    self._maxTime = maxTime
    
    self._productionInfo = nil
end

--生产类型的加速
function UIAcceleration:renderProductionInfo(productionInfo, buildingInfo, prosheet,extroInfo, maxTime)
    --读取相关配置表，
    
    local typeid = productionInfo.typeid
    local nameTxt = self:getChildByName("mainPanel/itemPanel0/nameTxt")
    local imgContainer = self:getChildByName("mainPanel/itemPanel0/imgContainer")
    local lvlTxt = self:getChildByName("mainPanel/itemPanel0/lvlTxt")
    lvlTxt:setVisible(true)
    if buildingInfo.buildingType == BuildingTypeConfig.SCIENCE then --科技馆单独处理 ，太学院??
        -- print(".............. 生产 太学院（科技） ")
        self.secLvBg:setTitle(TextWords:getTextWord(334))
        local configData = extroInfo.configData
        local needTime = extroInfo.needTime
        local scienceLv = extroInfo.scienceLv
        nameTxt:setString(configData.name)
        lvlTxt:setString(string.format(TextWords:getTextWord(529), scienceLv))
        --lvlTxt:setPositionX(nameTxt:getPositionX() + nameTxt:getContentSize().width + 10)
        NodeUtils:alignNodeL2R(nameTxt, lvlTxt, 10)
--        self._maxTime = needTime
        -- -ceshi
        local iconInfo = {}
        iconInfo.power = GamePowerConfig.Other
        iconInfo.typeid = configData.icon
        iconInfo.num = 0
        local icon = imgContainer.icon
        if icon == nil then
            icon = UIIcon.new(imgContainer,iconInfo,false)
            imgContainer.icon = icon
        else
            icon:updateData(iconInfo)
        end
        imgContainer.icon:setIconCenter()
        -- -ceshi
    else
        lvlTxt:setVisible(false)
        -- print(".............. 生产 兵 吧 ？？？？  ")
        self.secLvBg:setTitle(TextWords:getTextWord(333))
        local info = ConfigDataManager:getConfigById(prosheet .. "Config", typeid)
        nameTxt:setString(info.name)
        local tmp = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,info.ID)
        nameTxt:setColor(ColorUtils:getColorByQuality(tmp.color))
--        self._maxTime = info.timeneed
        local data = {}
        data.power = GamePowerConfig.SoldierBarrack
        data.typeid = info.ID
        data.num = 1
        local icon = imgContainer.icon
        if icon == nil then
            icon = UIIcon.new(imgContainer, data, false)
            imgContainer.icon = icon
        else
            icon:updateData(data)
        end
        imgContainer.icon:setSoldierIconCenter()
    end 

    local scale = (buildingInfo.buildingType == BuildingTypeConfig.BARRACK or buildingInfo.buildingType == BuildingTypeConfig.REFORM) and 0.7 or 1
    imgContainer.icon:setScale(scale)
    
    self._maxTime = maxTime
    local timeKeyInfo = {}
    timeKeyInfo.bigtype = SystemTimerConfig.BUILDING_CREATE
    timeKeyInfo.smalltype = buildingInfo.index
    timeKeyInfo.othertype = productionInfo.order

    self._timerKeyInfo = timeKeyInfo
    
    
    self._productionInfo = productionInfo
end

--@param isOpenUpdate 是否打开更新，打开更新，才会初始化
function UIAcceleration:renderAllItem(prospeeditem, isOpenUpdate, jump)
    local data = {}
    local itemProxy = self._panel:getProxy(GameProxys.Item)
    for _, typeid in pairs(prospeeditem) do
        local num = itemProxy:getItemNumByType(typeid)
        table.insert(data,{typeid = typeid, num = num})
    end

    local upBtn = self:getChildByName("mainPanel/Button_72")
    ComponentUtils:addTouchEventListener(upBtn, self.onQuickBtnTouch, nil, self)
    local countImg = self:getChildByName("mainPanel/countImg")

    local listView1 = self:getChildByName("mainPanel/listView_0")
    self.jiasuType =  self.jiasuType or data[1].typeid 
    if isOpenUpdate == true then
        self.jiasuType = data[1].typeid --TODO 后面只能选择，只需要修改这里则可，并且滚动到对应的滚动条
    end

    upBtn.quickType = upBtn.quickType or 2
    upBtn.num = upBtn.num or 0

    self._panel["accUpBtn"] = upBtn


    

    if self.first == nil then
        self.first = true
        self:renderListView(listView1, data, self, self.renderOneItem, nil, true)
    end
    

    --
    if jump then
        return
    end

    --jumpItem  选出有可以用道具在items的下标（ps：从0开始的）
    local jumpItem = -1
    local items = listView1:getItems()
    for k,v in pairs(items) do
        if jumpItem == -1 and data[k].num > 0 then
                jumpItem = k - 1
                self.jiasuType = data[k].typeid
        end
        self:renderOneItem(v, data[k], k-1, isOpenUpdate)
    end

    local function showSelectImg(node)
        if self._selectBox == nil then
            self._selectBox = TextureManager:createImageView("images/newGui9Scale/S9Select.png")
            self._selectBox:setScale(0.8)
            self._selectBox:retain()
            node:addChild(self._selectBox)
        else
            self._selectBox:removeFromParent()
            node:addChild(self._selectBox)
        end
    end

    --跳转偏移量，加了道具类型，就是说items比6还多的时候，要再配
    local offsetX = {}
    offsetX[1] = -1
    offsetX[3] = 0.5
    offsetX[4] = 1.5
    offsetX[5] = 2.5
    offsetX[6] = 2.5
    TimerManager:addOnce(100, function()
        --因为下次自动换列的原因，这里的quickType也要更新一下，要不然会有bug，提示道具不足
        --quicktype是需要+2 奇怪的设定  而且是请求协议需要的字段
        local upBtn = self:getChildByName("mainPanel/Button_72")
        if jumpItem ~= -1 then
            local itemPanel = listView1:getItem(jumpItem)
            upBtn.quickType = jumpItem + 2
            jumpItem = jumpItem + (offsetX[jumpItem] or 0)
            local percent = jumpItem/#items*100
            showSelectImg(itemPanel:getChildByName("iconImg"))
            percent = percent > 100 and 100 or percent
            listView1:jumpToPercentHorizontal(percent)
        else
            upBtn.quickType = 2
            listView1:jumpToLeft()
            local itemPanel = listView1:getItem(0)
            showSelectImg(itemPanel:getChildByName("iconImg"))
        end
    end, self)

    --放在下面定义   因为要在上面筛选出有的道具的typeid 
    --使用加速道具时，建议判断，指派到背包内已有道具列
    local args = {}
    args["moveCallobj"] = self
    args["moveCallback"] = self.onMoveBtnCallback
    args["count"] = self:getMaxCount()
    if self._uiMoveBtn == nil then
        self._uiMoveBtn = UIMoveBtn.new(countImg, args, 1) -- 最少使用1
    end 

    local maxCont = self:getMaxCount()
    local isLeft = false
    if maxCont <= 0 then
        isLeft = true
    end
    self._uiMoveBtn:setEnterCount(maxCont, isLeft)

    
end

function UIAcceleration:onMoveBtnCallback(count)
    if self._timerKeyInfo == nil then
        return
    end
    local config = ConfigDataManager:getConfigById(ConfigData.ItemConfig, self.jiasuType)
    local effect = StringUtils:jsonDecode(config.effect)
    local oneTime = effect[1][1]*60
    local upBtn = self:getChildByName("mainPanel/Button_72")

    local maxCont = self:getMaxCount()
    count = count > maxCont and maxCont or count
    if count <= 0 then 
       count = tonumber(tostring(0))
    end
    upBtn.num = count

    local numLab = self:getChildByName("mainPanel/numLab")
    numLab:setString(count)
    local timeLab = self:getChildByName("mainPanel/timeLab")
    
    local time = math.abs(oneTime*count)

    local timeStr = TimeUtils:getStandardFormatTimeString6(time)
    timeLab:setString(timeStr)
end

-- 渲染加速道具
function UIAcceleration:renderOneItem(itemPanel, info, index, isOpenUpdate)
    local typeid = info.typeid
    local num = info.num

    local iconContainer = itemPanel:getChildByName("iconImg")
    local icon_img = iconContainer:getChildByName("icon_img")
    local numLab = iconContainer:getChildByName("numLab")
    local nameLab = itemPanel:getChildByName("nameLab")
    nameLab:setVisible(false)
    numLab:setVisible(false)
    TextureManager:updateImageView(iconContainer, "images/newGui1/none.png")
    local data = {}
    data.power = GamePowerConfig.Item
    data.typeid = typeid
    data.num = num
    local icon = iconContainer.icon
    if icon == nil then
        -- function UIIcon:ctor(parent, data, isShowNum, panel, isMainScene, isShowName, isNumNotStr, otherNumber, effectDelayTime)
        icon = UIIcon.new(iconContainer,data,true,nil,nil,true,0)
        iconContainer.icon = icon
        icon:setTouchEnabled(false)
        icon:getNameChild():setFontSize(18)
        local y = icon:getNameChild():getPositionY()
        icon:getNameChild():setPositionY(y - 8)
    else
        icon:updateData(data)
    end
    if num == 0 then
        icon:setNumColor(cc.c3b(255,0,0))
    end
    local color = icon:getQuality()

    if typeid == self.jiasuType and isOpenUpdate then
        local upBtn = self:getChildByName("mainPanel/Button_72")
        upBtn.quickType = index + 2
    end

    itemPanel.data = info
    itemPanel.num = num
    itemPanel.index = index
    

    ComponentUtils:addTouchEventListener(itemPanel, self.onChangeItem, nil,self)

end

function UIAcceleration:onChangeItem(sender)
    self._selectBox:removeFromParent()
    local node = sender:getChildByName("iconImg")
    -- self._selectBox:setPosition(node:getPosition())
    -- local size = node:getContentSize()
    -- self._selectBox:setPosition(size.width/2, size.height/2)
    node:addChild(self._selectBox)
    local num = sender.num
    self.jiasuType = sender.data.typeid

    local maxCont = self:getMaxCount()
    local isLeft = false
    if maxCont <= 0 then
        isLeft = true
    end
    self._uiMoveBtn:setEnterCount(maxCont, isLeft)

    local upBtn = self:getChildByName("mainPanel/Button_72")
    upBtn.quickType = sender.index + 2

    if num == 0 then
        if self._uiGoodsPanel == nil then
            local parent = self._panel:getPanelRoot()
            self._uiGoodsPanel = UIGoodsPanel.new(parent, self._panel, self.jiasuType, 1)
        else
            self._uiGoodsPanel:show(self.jiasuType, 1)
        end
    end

--    self:onMoveBtnCallback(0)
end

--计算减去免费时间后可以使用的当前加速道具类型的最大个数
--作为进度条的最大值
function UIAcceleration:getMaxCount()
    if self._timerKeyInfo == nil then
        return 0
    end

    local config = ConfigDataManager:getConfigById(ConfigData.ItemConfig, self.jiasuType)
    local effect = StringUtils:jsonDecode(config.effect)
    local oneTime = effect[1][1]*60

    local timeKeyInfo = self._timerKeyInfo
    local roleProxy = self._panel:getProxy(GameProxys.Role)
    local freeTime = roleProxy:getFreeTime()
    local remainTime = 0
    local buildingProxy = self._panel:getProxy(GameProxys.Building)
    if timeKeyInfo.bigtype == SystemTimerConfig.BUILDING_LEVEL_UP then
        remainTime = buildingProxy:getBuildingUpReTime(timeKeyInfo.smalltype, timeKeyInfo.othertype)
        remainTime = remainTime - freeTime
    else
        remainTime = buildingProxy:getBuildingProLineReTime(timeKeyInfo.smalltype, timeKeyInfo.othertype)
    end
    local maxTime = remainTime
    local maxCont = 0
    maxCont = math.ceil(maxTime/oneTime)
    local itemProxy = self._panel:getProxy(GameProxys.Item)
    local curNum = itemProxy:getItemNumByType(self.jiasuType) or 0
    maxCont = maxCont > curNum and curNum or maxCont
    return maxCont
end

function UIAcceleration:renderRemainTime(remainTime)
    local timeBar = self:getChildByName("mainPanel/itemPanel0/timeBar")
    local timeTxt = self:getChildByName("mainPanel/itemPanel0/timeTxt")
    local percent = (self._maxTime - remainTime) / self._maxTime * 100
    if percent < 0 then
        percent = 0
    end
    timeBar:setPercent(percent)
    
    local timeStr = TimeUtils:getStandardFormatTimeString6(remainTime)
    timeTxt:setString(timeStr)
    
    if remainTime == 0 then --加速完毕，先直接关闭面板
        self:hide()
    end
    self:isFreeAccelerate(remainTime)
end

function UIAcceleration:update()
    if self._timerKeyInfo == nil then
        return
    end
    local timeKeyInfo = self._timerKeyInfo
    
    local remainTime = 0
    local buildingProxy = self._panel:getProxy(GameProxys.Building)
    if timeKeyInfo.bigtype == SystemTimerConfig.BUILDING_LEVEL_UP then
        remainTime = buildingProxy:getBuildingUpReTime(timeKeyInfo.smalltype, timeKeyInfo.othertype) 
    else
        remainTime = buildingProxy:getBuildingProLineReTime(timeKeyInfo.smalltype, timeKeyInfo.othertype)
    end
    
    if self.numLab ~= nil then
        self.numLab:setString(self:getMoney())
    end    
    self:renderRemainTime(remainTime)
end

function UIAcceleration:registerEventHandler()
    self.numLab = self:getChildByName("mainPanel/itemPanel0/numLab")
    local goldBtn = self:getChildByName("mainPanel/itemPanel0/goldBtn")
    local freeBtn = self:getChildByName("mainPanel/freeBtn")
    self._freeBtn = freeBtn
    goldBtn.quickType = 1
    freeBtn.quickType = 1
    freeBtn:setVisible(false)
    ComponentUtils:addTouchEventListener(goldBtn, self.onQuickBtnTouch, nil,self)
    ComponentUtils:addTouchEventListener(freeBtn, self.onQuickBtnTouch, nil,self)

    self._panel["accQuickBtn"] = goldBtn
    self._panel["accFreeBtn"] = freeBtn
end

function UIAcceleration:onCloseBtnTouch(sender)
    self:hide()
    
end

function UIAcceleration:getMoney()
    local productionInfo = self._productionInfo
    local buildingProxy = self._panel:getProxy(GameProxys.Building)
        
    local time = 0
    if productionInfo ~= nil then --生产的加速
        time = buildingProxy:getCurBuildingProLineReTime(productionInfo.order)
    else
        local roleProxy = self._panel:getProxy(GameProxys.Role)
        local freeTime = roleProxy:getFreeTime()
        time = buildingProxy:getCurBuildingUpReTime() - freeTime
    end
    local cost = TimeUtils:getTimeCost(time)
    -- if  self.type and cost >= 5 then
    --     cost = cost - 5
    -- end
    return cost 
end

function UIAcceleration:hide()
    self._uiSkin:setVisible(false)
end

function UIAcceleration:isVisible()
    return self._uiSkin:isVisible()
end

function UIAcceleration:onQuickBtnTouch(sender)
    -- local function okCallback()
    --     self._panel:onQuickReq(sender.quickType, 0, self._productionInfo)
    -- end

    -- 免费加速
    if self._freeBtn:isVisible() == true then
        self._panel:onQuickReq(sender.quickType, 0, self._productionInfo)
        return
    end

    local quickType = sender.quickType
    local buildingProxy = self._panel:getProxy(GameProxys.Building)
    if quickType == 1 then --金币直接加速
        local productionInfo = self._productionInfo
        
        
        local time = 0
        if productionInfo ~= nil then --生产的加速
            time = buildingProxy:getCurBuildingProLineReTime(productionInfo.order)
        else
            time = buildingProxy:getCurBuildingUpReTime()
        end
        
        local cost = self:getMoney()
        -- local cost = TimeUtils:getTimeCost(time) - 5
        local content = string.format(TextWords:getTextWord(811), cost)

        local function onCallback()
            -- self._panel:onQuickReq(quickType, cost, productionInfo)

            local function callFunc()
                self._panel:onQuickReq(quickType, cost, productionInfo)
            end
            sender.callFunc = callFunc
            sender.money = cost
            self:isShowRechargeUI(sender)

        end
        onCallback()
        -- self._panel:showMessageBox(content, onCallback)
        
    else  --道具加速
        -- local function onCallback()
        --     local function callFunc()
        --         self._panel:onQuickReq(quickType, sender.cost, self._productionInfo)
        --     end
        --     sender.callFunc = callFunc
        --     sender.money = sender.cost
        --     self:isShowRechargeUI(sender)
        -- end
        -- local content = string.format(TextWords:getTextWord(811), sender.cost)
        local productionInfo = self._productionInfo
        
        
        local time = 0
        local roleProxy = self._panel:getProxy(GameProxys.Role)
        local freeTime = roleProxy:getFreeTime()
        if productionInfo ~= nil then --生产的加速
            time = buildingProxy:getCurBuildingProLineReTime(productionInfo.order)
        else
            time = buildingProxy:getCurBuildingUpReTime() - freeTime
        end
        if sender.num <= 0 and time > 0 then
            self._panel:showSysMessage(TextWords:getTextWord(8500))
        elseif sender.num <= 0 and time <= 0 then
            self._panel:showSysMessage(TextWords:getTextWord(8501))
        elseif sender.num > 0 and time > 0 then
            self._panel:onQuickReq(quickType, sender.cost, self._productionInfo, sender.num)
        end
    end
end

function UIAcceleration:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

-- 是否弹窗元宝不足
function UIAcceleration:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self._panel:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self._panel:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self._panel)
            parent.panel = panel
        else
            panel:show()
        end

    else
        sender.callFunc()
    end

end