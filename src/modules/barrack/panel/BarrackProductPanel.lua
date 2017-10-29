--兵营建造生产信息
BarrackProductPanel = class("BarrackProductPanel", BasicPanel)
BarrackProductPanel.NAME = "BarrackProductPanel"

function BarrackProductPanel:ctor(view, panelName)
    BarrackProductPanel.super.ctor(self, view, panelName,700)

    self:setUseNewPanelBg(true)
end

function BarrackProductPanel:finalize()
    BarrackProductPanel.super.finalize(self)
end

function BarrackProductPanel:initPanel()
    BarrackProductPanel.super.initPanel(self)
    
    self._curSelectCount = 1
    self.MAX_PRODUCT_NUM = 100 --最大生产数量
    self:addMoveBtn()
end

function BarrackProductPanel:addMoveBtn()
    local moveBtnContainer = self:getChildByName("mainPanel/moveBtnContainer")
    
    local args = {}
    args["moveCallobj"] = self
    args["moveCallback"] = self.onMoveBtnCallback
    args["count"] = 1
    self._uiMoveBtn = UIMoveBtn.new(moveBtnContainer, args)
    
--    self._uiMoveBtn:setEnterCount(100)
end

function BarrackProductPanel:onMoveBtnCallback(count)
    self:setAllMinNumCount(count)
end

--show时候 触发的事件
function BarrackProductPanel:onShowHandler(data)
    print(".................什么鬼 function BarrackProductPanel:onShowHandler(data) ")
    local info = data.info
    local minValue = data.minValue --最小生产数
    self:setTitle(true, self:getTextWord(328))
    self._typeid = info.ID
    
    --local downPanel1 = self:getChildByName("mainPanel/downPanel")
    --local downPanel2 = self:getChildByName("mainPanel/downPanel2")
    --
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    --
    local downPanel = self:getChildByName("mainPanel/downPanel2")
    --if buildingInfo.buildingType == BuildingTypeConfig.MAKE  then --工匠坊
    --    downPanel1:setVisible(false)
    --    downPanel2:setVisible(true)
    --    downPanel = downPanel2
    --else
    --    downPanel1:setVisible(true)
    --    downPanel2:setVisible(false)
    --    downPanel = downPanel1
    --end

    local headPanel = self:getChildByName("mainPanel/headPanel")
    --local Panel_attribute = self:getChildByName("mainPanel/Panel_attribute") --佣兵属性
    
    self:renderHeadPanel(headPanel, info, buildingInfo)
    self:renderDownPanel(downPanel, info, buildingInfo, minValue)
    --self:renderAttributePanel(Panel_attribute, info, buildingInfo)
end


function BarrackProductPanel:renderHeadPanel(headPanel, info, buildingInfo)
    local nameTxt = headPanel:getChildByName("nameTxt")
    local infoTxt = headPanel:getChildByName("infoTxt")
    nameTxt:setString(info.name)
    self._nameStr = info.name
    self._topNameTxt = nameTxt
    
    
    local timeneed= info.timeneed
    local buildingProxy = self:getProxy(GameProxys.Building)
    local speedRate, timeneed = buildingProxy:getProductionSpeedRate(buildingInfo.buildingType, buildingInfo.index, info.ID)
    
    local timeStr = TimeUtils:getStandardFormatTimeString6(timeneed)
    infoTxt:setString(timeStr)
    
    local soldierIcon = headPanel:getChildByName("soldierIcon")
    --local soldierPanel = headPanel:getChildByName("soldierPanel")
    -- local url = string.format("images/barrackIcon/%d.png", info.ID)
    -- TextureManager:updateImageView(soldierIcon,url)
    local url = nil
    local isSoldier = false
    if buildingInfo.buildingType == BuildingTypeConfig.MAKE  then --工匠坊 
        self:setTitle(true, self:getTextWord(8105))  --道具制造
        url = string.format("images/otherIcon/%d.png", info.icon)
    elseif buildingInfo.buildingType == BuildingTypeConfig.BARRACK then --兵营（战车工厂）
        self:setTitle(true, self:getTextWord(328)) --标题：征召士兵
        url = string.format("images/barrackIcon/%d.png", info.ID)
        isSoldier = true
    elseif buildingInfo.buildingType == BuildingTypeConfig.REFORM then --校场
        self:setTitle(true, self:getTextWord(336)) --标题：训练士兵
        url = string.format("images/barrackIcon/%d.png", info.ID)
        isSoldier = true
    end
    

    local num = 0
    if buildingInfo.buildingType == BuildingTypeConfig.MAKE  then --工匠坊 
        local itemProxy = self:getProxy(GameProxys.Item)
        num = itemProxy:getItemNumByType(info.ID)
    else
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        num = soldierProxy:getSoldierCountById(info.ID)
    end
    local numTxt = headPanel:getChildByName("numTxt")
    numTxt:setString(string.format(self:getTextWord(807), num) )

    if num == 0 then
        num = nil
    end
    
    if isSoldier == true then
        -- ComponentUtils:updateSoliderPos(soldierPanel, info.ID, num)
        --ComponentUtils:updateSoliderPos(soldierPanel, info.ID, num, nil, nil, nil, false) --隐藏infoImg
        --ComponentUtils:setTeamSelectStatusByTeam(soldierPanel,false)
        --soldierPanel:setVisible(true)
        soldierIcon:setVisible(false)
    else
        TextureManager:updateImageView(soldierIcon,url)
        --soldierPanel:setVisible(false)
        soldierIcon:setVisible(true)
    end
    
    

    self._timeneed = timeneed
    --yyy
--    local soldier_btn = self:getChildByName("mainPanel/barrack_btn")
--    local lvneed = StringUtils:jsonDecode(info.Lvneed)
--    local buildingType = lvneed[1]
--    if buildingType == 9 then --是兵
--        soldier_btn:setVisible(true)
--        self:addTouchEventListener(soldier_btn, self.showSoldierInfo)
--    else
--        soldier_btn:setVisible(false)
--    end
    ----yyy

    -- 只有点评界面才显示点评按钮
    --self._commentBtn:setVisible(isSoldier)
end

--minValue 自定义最小值 nil则为算出来的上限值
function BarrackProductPanel:renderDownPanel(downPanel,info, buildingInfo, minValue)

    local needListView = downPanel:getChildByName("needListView")
    
    
    local need = StringUtils:jsonDecode(info.need)
    local itemneed = StringUtils:jsonDecode(info.itemneed)
    local tankneed = StringUtils:jsonDecode(info.tankneed or "[]")
    
    self._minNum = 2000000000
    local roleProxy = self:getProxy(GameProxys.Role)
    local buildingType = buildingInfo.buildingType
    
    local infos = {}
    for _, v in pairs(need) do
        local info = {}
        info.power = GamePowerConfig.Resource
        info.typeid = v[1]
        info.num = v[2]
        info.isRes = true
        table.insert(infos, info)
    end
    for _, v in pairs(itemneed) do
        local info = {}
        if buildingType == BuildingTypeConfig.MAKE then  --工匠坊
            info.power = GamePowerConfig.Item
            info.typeid = v[1]
            info.num = v[2]
        else
            info.power = v[1] --v[1]=GamePowerConfig.Item=401
            info.typeid = v[2]
            info.num = v[3]
        end        
        table.insert(infos, info)
    end
    
    for _, v in pairs(tankneed) do
        local info = {}
        info.power = GamePowerConfig.Soldier
        info.typeid = v[1]
        info.num = v[2]
        table.insert(infos, info)
    end
    
    self._needTxtMap = {}
    
    for _, data in pairs(infos) do
        local haveNum = roleProxy:getRolePowerValue(data.power, data.typeid)
        local minNum = math.floor(haveNum / data.num) 
        if minNum < self._minNum then
            self._minNum = minNum
        end
    end
    
    self:renderListView(needListView,infos, self, self.renderNeetListView, nil, true, 0)
    
    if self._minNum > self.MAX_PRODUCT_NUM then
        self._minNum = self.MAX_PRODUCT_NUM
    end


    
    local ifLeft = nil
    local curValue = self._minNum
    if minValue ~= nil then
        curValue = minValue
        ifLeft = true
    end
    -- local buildingProxy = self:getProxy(GameProxys.Building)
    -- local buildingInfo = buildingProxy:getCurBuildingInfo()
    -- local buildingType = buildingInfo.buildingType
    if buildingType == BuildingTypeConfig.MAKE then
        curValue = 1
        ifLeft = true
    end
    
    self._uiMoveBtn:setEnterCount(self._minNum, ifLeft)
    --兵营再加一层判断   带兵量  100   资源可以生产的最大数量
    if buildingType == BuildingTypeConfig.BARRACK and minValue == nil then
        local curMakeNum = self._minNum
        local command = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
        curMakeNum = curMakeNum > command and command or curMakeNum
        self._uiMoveBtn:setBarPercent(curMakeNum)
        self:setAllMinNumCount(curMakeNum)
        return
    end
    self:setAllMinNumCount(curValue)
end

-- 渲染佣兵属性
--function BarrackProductPanel:renderAttributePanel(panel, info, buildingInfo)
--    -- body
--    -- local buildingProxy = self:getProxy(GameProxys.Building)
--    -- local buildingInfo = buildingProxy:getCurBuildingInfo()
--    local buildingType = buildingInfo.buildingType
--    if buildingType == BuildingTypeConfig.MAKE then --工匠坊
--        panel:setVisible(false)
--    
--    else
--
--        local conf = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,info.ID)
--        local basePowerMap = {}
--        basePowerMap[SoliderPowerDefine.POWER_hpMax] = conf.hpmax   --生命
--        basePowerMap[SoliderPowerDefine.POWER_atk]   = conf.atk     --攻击
--        basePowerMap[SoliderPowerDefine.weight] = conf.load         --辎重
--        basePowerMap[SoliderPowerDefine.skill] = conf.skillinfo     --攻击方式
--
--        -- local soldierProxy = self:getProxy(GameProxys.Soldier)
--        -- local soldier = soldierProxy:getSoldier(info.ID)
--        self._topNameTxt:setColor(ColorUtils:getColorByQuality(conf.color))
--
--        if buildingType == BuildingTypeConfig.BARRACK or buildingType == BuildingTypeConfig.REFORM then --兵营--校场
--            panel:setVisible(true)
--
--            for power,v in pairs(basePowerMap) do
--                local item = panel:getChildByName("item"..power)
--                if item ~= nil then                  
--                    local name = item:getChildByName("name")
--                    local value = item:getChildByName("value")
--
--                    -- 名字
--                    local nameStr = TextWords:getTextWord(7000 + power) or ""
--                    name:setString(nameStr)
--
--                    -- 数值
--                    value:setString(basePowerMap[power])
--
--                    -- icon
--                    if power == 30 then
--                        name:setString(conf.skillinfo)
--                        value:setString("")   
--                        local icon = item:getChildByName("icon")
--                        local url = string.format("images/littleIcon/"..conf.type..".png")
--                        if url and icon then
--                            TextureManager:updateImageView(icon, url)
--                        end
--                    end
--
--                end
--
--            end
--        
--        -- elseif buildingType == BuildingTypeConfig.REFORM then --校场
--            -- panel:setVisible(true)
--
--        end
--
--    end
--
--
--end



function BarrackProductPanel:setAllMinNumCount(count)
    if self._needTxtMap == nil then
        return
    end
    
    local sureBtn = self:getChildByName("mainPanel/sureBtn")
    if count == 0 or self._minNum == 0 then  --默认1 这时确定按钮 置灰
        NodeUtils:setEnable(sureBtn, false)
        count = 1
    else
        NodeUtils:setEnable(sureBtn, true)
    end
    
    self._curSelectCount = count
    
    for _, needTxt in pairs(self._needTxtMap) do
    	local info = needTxt.info
        local str = StringUtils:formatNumberByK(count * info.num, needTxt.typeid)
        needTxt:setString(str)
    end
    local infoTxt = self:getChildByName("mainPanel/downPanel2/infoTxt")
    local numTxt = self:getChildByName("mainPanel/downPanel2/numTxt") 
    --local numBg = self:getChildByName("mainPanel/downPanel2/Image_1400")
    --local downPanel = self:getChildByName("mainPanel/downPanel")
    --if downPanel:isVisible() then
    --    infoTxt = self:getChildByName("mainPanel/downPanel/infoTxt")
    --    numTxt = self:getChildByName("mainPanel/downPanel/numTxt")
    --    --numBg = self:getChildByName("mainPanel/downPanel/Image_13")
    --else
    --    infoTxt = self:getChildByName("mainPanel/downPanel2/infoTxt")
    --    numTxt = self:getChildByName("mainPanel/downPanel2/numTxt") 
    --    numBg = self:getChildByName("mainPanel/downPanel2/Image_1400")
    --end
    local timeneed = self._timeneed * count
    local timeStr = TimeUtils:getStandardFormatTimeString6(timeneed)
    infoTxt:setString(timeStr)
    
    local numStr = string.format(self:getTextWord(806), count)
    numTxt:setString(numStr)
    local size = numTxt:getContentSize()
    --local bgSize = numBg:getContentSize()
    --numBg:setContentSize(size.width + 17, bgSize.height)
    
    self._curSelectNum = count
end

function BarrackProductPanel:renderNeetListView(itemPanel, info, index)
    itemPanel:setVisible(true)

    local iconContainer = itemPanel:getChildByName("iconContainer")
    
    local itemBg = itemPanel:getChildByName("itemBg")
    if index%2 == 0 then
	 TextureManager:updateImageView(itemBg, "images/newGui9Scale/S9Gray.png")
    else
	 TextureManager:updateImageView(itemBg, "images/newGui9Scale/S9Brown.png")
    end

    local data = info
    
    local icon = iconContainer.icon

    local iconData = clone(info)    
    if info.power == GamePowerConfig.Soldier then
        iconData.power = GamePowerConfig.SoldierBarrack
        iconContainer:setPositionY(38)  --佣兵图标调整坐标
        iconContainer:setScale(0.40)    --佣兵图标调整大小
    end
    
    if icon == nil then
        icon = UIIcon.new(iconContainer, iconData, false)
        iconContainer.icon = icon
    else
        icon:updateData(iconData)
    end
    icon:setShowIconBg(true, nil)
    if iconData.power == GamePowerConfig.Resource then
        icon:setScale(1)
    else
        icon:setScale(0.5)
    end
    
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local needTxt = itemPanel:getChildByName("needTxt")
    local haveTxt = itemPanel:getChildByName("haveTxt")
    local stateTxt = itemPanel:getChildByName("stateTxt")
    needTxt:setString(StringUtils:formatNumberByK(data.num * self._curSelectCount, data.typeid))
    
    nameTxt:setString(icon:getName())
    
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveNum = roleProxy:getRolePowerValue(data.power, data.typeid)
    local fnum = StringUtils:formatNumberByK(haveNum, data.typeid)


    --算出一个最大可以使用的数量
    local color = nil
    local signStr = ""
    if haveNum >= data.num  then 
        --资源够
        color = ColorUtils.wordColorLight03
        signStr = "√"
    else
        --资源不够
        color = ColorUtils.wordColorLight04
        signStr = "×"
    end
    haveTxt:setString(fnum)
    stateTxt:setString(signStr)
    haveTxt:setColor(color)
    stateTxt:setColor(color)



    needTxt.info = info
    needTxt.typeid = data.typeid
    self._needTxtMap[index] = needTxt
end


function BarrackProductPanel:registerEvents()
    
    local sureBtn = self:getChildByName("mainPanel/sureBtn")
    self:addTouchEventListener(sureBtn, self.onSureTouch)
    
    self["sureBtn"] = sureBtn

    --self._commentBtn = self:getChildByName("mainPanel/commentBtn")
    --self:addTouchEventListener(self._commentBtn, self.onCommentBtn) -- 
end

function BarrackProductPanel:onCloseSelfTouch(sender)
    self:hide()
end

function BarrackProductPanel:onSureTouch(sender)
    AudioManager:playEffect("yx01")
    --开始生产兵
    local buildingProxy = self:getProxy(GameProxys.Building)
    local curBuildingInfo = buildingProxy:getCurBuildingInfo()
    
    local data = {}
    data.buildingType = curBuildingInfo.buildingType
    data.index = curBuildingInfo.index
    data.typeid = self._typeid
    data.num = self._curSelectNum
    
    -- self:dispatchEvent(BarrackEvent.PRODUCTION_REQ, data)
    
    -- self:hide()
    -- local panel = self:getPanel(BarrackPanel.NAME)
    -- panel:changeTabSelectByName(RecruitingPanel.NAME)


    --建筑生产
    local isBuildingCanProduction = buildingProxy:isBuildingCanProduction(data.buildingType, data.index)
    if isBuildingCanProduction == 0 then
        data.isBuildingCanProduction = isBuildingCanProduction
        self:dispatchEvent(BarrackEvent.PRODUCTION_REQ, data)
        
        -- self:hide()
        -- local panel = self:getPanel(BarrackPanel.NAME)
        -- panel:changeTabSelectByName(RecruitingPanel.NAME)
    else
        local msg
        if data.buildingType == BuildingTypeConfig.MAKE  then --工匠坊
            msg = TextWords:getTextWord(360)
        elseif data.buildingType == BuildingTypeConfig.BARRACK then --兵营
            msg = nil--TextWords:getTextWord(357)
            
            local panel = self:getPanel(BarrackTipPanel.NAME)
            panel:show()
        else--校场
            msg = TextWords:getTextWord(358)
        end
        if msg ~= nil then
            self:showSysMessage(msg)
        end
        --TODO 弹错误码 生产队列上限
        -- buildingProxy:errorCodeHandler(AppEvent.NET_M28_C280006, isBuildingCanProduction)

    end

end

--function BarrackProductPanel:showSoldierInfo(sender)  --显示佣兵属性
--    local typeid = self._typeid
--    self.view:showSoldierInfo(typeid)
--end

-- 类型  1-兵营 2-武将 3-太学院 4-战法 5-军师 
--function BarrackProductPanel:onCommentBtn(sender)
--    local proxy = self:getProxy(GameProxys.Comment)
--    proxy:toCommentModule(1, self._typeid, self._nameStr)
--    self:hide()
--end

