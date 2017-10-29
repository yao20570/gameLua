PartsIntensifyPanel = class("PartsIntensifyPanel", BasicPanel) --强化
PartsIntensifyPanel.NAME = "PartsIntensifyPanel"

function PartsIntensifyPanel:ctor(view, panelName)
    PartsIntensifyPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function PartsIntensifyPanel:finalize()
    if self._uiIcon ~= nil then
        self._uiIcon:finalize()
        self._uiIcon = nil
    end 
    PartsIntensifyPanel.super.finalize(self)
end

function PartsIntensifyPanel:initPanel()
    PartsIntensifyPanel.super.initPanel(self)
    -- self:setTitle(true,"Intensify",true)
    self._roleProxy = self:getProxy(GameProxys.Role)
    self._element = self:getPanelElement()
    
    self._attrPanel = self:getChildByName("mainPanel/topPanel/Panel_attr")

end

function PartsIntensifyPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    local mainPanel = self:getChildByName("mainPanel")
    NodeUtils:adaptiveTopPanelAndListView(mainPanel, nil,GlobalConfig.downHeight,tabsPanel)
end

function PartsIntensifyPanel:onShowHandler()
    PartsIntensifyPanel.super.onShowHandler(self)
    local mainPanel = self:getPanel(PartsStrengthenPanel.NAME)
    local data = mainPanel:getData()
    self:updatePanelInfo(data)
end
--获取获取面板控件
function PartsIntensifyPanel:getPanelElement()
    local tElement = {}
    local mainPanel = self:getChildByName("mainPanel")
    local infoPanel = mainPanel:getChildByName("infoPanel")
    local topPanel = mainPanel:getChildByName("topPanel")
    tElement.partsIcon = topPanel:getChildByName("Image_icon")
    tElement.partsName = topPanel:getChildByName("Label_name")
    tElement.attrPanel = topPanel:getChildByName("Panel_attr")
    tElement.maxLvTip = topPanel:getChildByName("maxLvTip")

    
    tElement.useIcon = infoPanel:getChildByName("Image_use_icon")
    tElement.useName = infoPanel:getChildByName("Label_use_name")
    tElement.useHaveNum = infoPanel:getChildByName("Label_use_have")
    tElement.useNeedNum = infoPanel:getChildByName("Label_use_need")
    tElement.metalHaveNum = infoPanel:getChildByName("Label_num_metal")
    tElement.metalIcon = infoPanel:getChildByName("Image_metal_icon")
    -- tElement.metalIconName = infoPanel:getChildByName("labCaiLiaoName")


    tElement.metalUseNum = infoPanel:getChildByName("Label_num_useMetal")
    tElement.minusMetalBtn = infoPanel:getChildByName("Button_minus")
    tElement.addMetalBtn = infoPanel:getChildByName("Button_add")
    
    local size = tElement.attrPanel:getContentSize()
    --print("size ===",size.width,size.height)
    tElement.AttrLabel = ComponentUtils:createRichLabel("",cc.size(size.width,0))
    tElement.AttrLabel:setPosition(10, size.height)
    tElement.AttrLabel:setAnchorPoint(cc.p(0,1))
    tElement.attrPanel:addChild(tElement.AttrLabel)
    
    tElement.intensifyBtn = self:getChildByName("downPanel/Button_intensify")
    self:addTouchEventListener(tElement.intensifyBtn, self.onIntensifyBtnClicked)
    self:addTouchEventListener(tElement.minusMetalBtn, self.onMinusBtnClicked)
    self:addTouchEventListener(tElement.addMetalBtn, self.onAddBtnClicked)

    tElement.metalHaveNum.left = infoPanel:getChildByName("Label_num_metal_left")
    tElement.metalHaveNum.left:setString(self:getTextWord(8233))
    tElement.metalHaveNum.right = infoPanel:getChildByName("Label_num_metal_right")

    self._infoPanel = infoPanel
    self._intensifyBtn = tElement.intensifyBtn
    self._maxLvTip = tElement.maxLvTip
    return tElement
    
end 

--更新panel信息
function PartsIntensifyPanel:updatePanelInfo(data)
    local data = data
    if data == nil and self._data == nil then
        return
    end 
    if data ~= nil then
        self._data = data
    else
        data = self._data
    end 
    self._useMetalNum = 0  --使用记忆金属数量
    self._originalRate = 0 --成功率
    self._isMaterialEnough = true --材料是否足够
    self._vipAddRate = 0 --vip加成
    
    local partsInfo = data.parts
    local configData = data.configData
    local element = self._element
    --配件图标
    local tempData = {}
    tempData.num =  data.num 
    tempData.power =  data.power 
    tempData.typeid =  data.typeid 
    tempData.parts = partsInfo

    if self._uiIcon == nil then
        self._uiIcon = UIIcon.new(element.partsIcon,tempData,false, self)
    else
        self._uiIcon:updateData(tempData)
    end
    self._uiIcon:setPosition(element.partsIcon:getContentSize().width/2,element.partsIcon:getContentSize().height/2)
    --配件名
    element.partsName:setString(configData.name)
   
    --成功几率
    local strenConfig = self:getPartsIntensifyConfigData(partsInfo.strgthlv,partsInfo.quality,partsInfo.part)
    local rate = strenConfig.rate
    self._originalRate = rate
    local vipConfig = ConfigDataManager:getConfigData(ConfigData.VipDataConfig)
    local roleProxy = self:getProxy(GameProxys.Role)
    local vipLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    local vipAdd = 0
--    print("vipLv ==",vipLv)
    for _,v in pairs(vipConfig) do
--        print("vipConfig ==",v.level,v.StrengBaseRate)
        if vipLv == v.level then
            vipAdd = v.StrengBaseRate
            break
        end 
    end 

    self._vipAddRate = (vipAdd/100)*rate
--    print("vipAdd=====",vipAdd,self._vipAddRate)
    self:initAttrData(rate)
   
    --消耗物品
    self:initUse(strenConfig)

end 
--初始化属性
function PartsIntensifyPanel:initAttrData(rate)
    self._infoPanel:setVisible(true)
    self._intensifyBtn:setVisible(true)
    self._maxLvTip:setVisible(false)


    local data = self._data
    local attrPanel = self._element.attrPanel
    local parts = data.parts
    local configData = data.configData
    local nextParts = clone(parts)
    nextParts.strgthlv = parts.strgthlv + 1
    local proxy = self:getProxy(GameProxys.Parts)
    local nextConfigData = proxy:getDataFromOrdnanceConfig(nextParts)

    --------------------------------------------------------
    --TODO 强化到满级的时候，nextConfigData为空，做具体逻辑
    if nextConfigData == nil or parts.strgthlv == 80 then
        self:maxAttrData()
        return
    end
    --------------------------------------------------------

    local attrAdd = self:getAttrAdd(configData,nextConfigData)
    local attrAddNames = attrAdd.attrName
    local attrNums = attrAdd.attrNum
    local attrAddNums = attrAdd.attrAddNum
    
    local lines = {} -- 总表行数
    --(配件强度：)10
    local strengthNum = parts.strength
    local strengthWordStr = self:getTextWord(8205)--..strengthNum
    local line1 = {}
    line1[1] = {}
    line1[1].content = strengthWordStr
    line1[1].foneSize = 20
    line1[1].color = ColorUtils.commonColor.FuBiaoTi--"#F19715"
    --配件强度：(10)
    line1[2] = {}
    line1[2].content = strengthNum
    line1[2].foneSize = 20
    line1[2].color = ColorUtils.commonColor.White--"#F19715"

    table.insert(lines,line1)


    for k,v in pairs(attrAddNames) do -- 属性加成
        local line = {}
        line[1] = {}
        line[1].content = v
        line[1].foneSize = 20
        line[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"

        line[2] = {}
        line[2].content = " "..attrNums[k]
        line[2].foneSize = 20
        line[2].color = ColorUtils.commonColor.White--"#46ff3d"

        line[3] = {}
        line[3].content = "↑"..attrAddNums[k]
        line[3].foneSize = 20
        line[3].color = ColorUtils.commonColor.Green--"#46ff3d"
        table.insert(lines,line)
    end 
    --强化等级：1 ↑1
    local intenLv = parts.strgthlv
    local addIntenLv = 1
    local intenWordStr = self:getTextWord(8206)--..intenLv
    local addIntenStr = "↑"..addIntenLv
    local line3 = {}
    line3[1] = {}
    line3[1].content = intenWordStr
    line3[1].foneSize = 20
    line3[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"

    line3[2] = {}
    line3[2].content = intenLv
    line3[2].foneSize = 20
    line3[2].color = ColorUtils.commonColor.White--"#46ff3d"

    line3[3] = {}
    line3[3].content = addIntenStr
    line3[3].foneSize = 20
    line3[3].color = ColorUtils.commonColor.Green--"#46ff3d"
    table.insert(lines,line3)
    --改造等级：0
    local remLv = parts.remoulv
    local remWordStr = self:getTextWord(8207)..remLv
    local line4 = {}
    line4[1]={}
    line4[1].content = remWordStr
    line4[1].foneSize = 20
    line4[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"
    table.insert(lines,line4)
    --成功几率：10% + 11% (VIP加成)
    --[成功几率：]10% + 11% (VIP加成)
    local odds = rate
    local oddsStr = self:getTextWord(8208)--..odds.."%"
    local line5 = {}
    line5[1]={}
    line5[1].content = oddsStr
    line5[1].foneSize = 20
    line5[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"
    --成功几率：[10%] + 11% (VIP加成)
    table.insert(line5,{
        content = tostring(odds) .. "%",
        foneSize = 20,
        color = ColorUtils.commonColor.White,
    })

    --成功几率：10%[ + 11% ](VIP加成)
   -- if self._vipAddRate > 0 then
    local vipStr = string.format(self:getTextWord(8209),self._vipAddRate)
    --print("vipStr====",vipStr)
    line5[3] = {}
    line5[3].content = vipStr
    line5[3].foneSize = 20
    line5[3].color = ColorUtils.commonColor.Green--"#46ff3d"
    -- end   

    --成功几率：10% + 11% [(VIP加成)]
    table.insert(line5,{
        content = self:getTextWord(8210),
        foneSize = 20,
        color = ColorUtils.commonColor.BiaoTi,
    })

    table.insert(lines,line5)


    -- 富文本数据
    self:initAttrLabel(lines)
end

------
-- 设置富文本显示
function PartsIntensifyPanel:initAttrLabel(lines)
--    local texts = StringUtils:getHtmlByLines(lines)
    self._element.AttrLabel:setString(lines)
end

--满级属性
function PartsIntensifyPanel:maxAttrData()
    self._infoPanel:setVisible(false)
    self._intensifyBtn:setVisible(false)
    self._maxLvTip:setVisible(true)
    self._maxLvTip:setString(self:getTextWord(8230))


    local data = self._data
    local attrPanel = self._element.attrPanel
    local parts = data.parts
    local configData = data.configData

    local attrAdd = self:getMaxAttr(configData)
    local attrAddNames = attrAdd.attrName
    local attrNums = attrAdd.attrNum

    local lines = {}

    --配件强度：10
    local strengthNum = parts.strength
    local strengthWordStr = self:getTextWord(8205)..strengthNum
    local line1 = {}
    line1[1] = {}
    line1[1].content = strengthWordStr
    line1[1].foneSize = 20
    line1[1].color = "#F19715"
    table.insert(lines,line1)
    for k,v in pairs(attrAddNames) do
        local line = {}
        line[1] = {}
        line[2] = {}
        line[1].content = v
        line[1].foneSize = 20
        line[1].color = "#eed6aa"
  
        line[2].content = attrNums[k]
        line[2].foneSize = 20
        line[2].color = "#46ff3d"
        table.insert(lines,line)
    end 


    --强化等级：80
    local intenLv = parts.strgthlv
    local intenWordStr = self:getTextWord(8206)..intenLv
    local line3 = {}
    line3[1] = {}
    line3[1].content = intenWordStr
    line3[1].foneSize = 20
    line3[1].color = "#eed6aa"
    table.insert(lines,line3)

    --改造等级：0
    local remLv = parts.remoulv
    local remWordStr = self:getTextWord(8207)..remLv
    local line4 = {}
    line4[1]={}
    line4[1].content = remWordStr
    line4[1].foneSize = 20
    line4[1].color = "#eed6aa"
    table.insert(lines,line4)

    self:maxAttrLabel(lines)

end
function PartsIntensifyPanel:maxAttrLabel(lines)
--    local texts = StringUtils:getHtmlByLines(lines)
    self._element.AttrLabel:setString(lines)
end

-- 更新银币
function PartsIntensifyPanel:updateRoleInfoHandler()
    -- body
    logger:info("强化...更新银币")

    if self._configData ~= nil then
        local element = self._element
        local neednum = self._configData.num
        local needid = self._configData.id
        local roleProxy = self:getProxy(GameProxys.Role)
        local havenum = roleProxy:getRolePowerValue(GamePowerConfig.Resource,needid)

        logger:info("更新银币 havenum ==========%d",havenum)
        element.useHaveNum:setString(
                string.format(TextWords[8244],self:convertToString(havenum)))
        if havenum < neednum then
            self._isMaterialEnough = false
        end 

        self:onSetNumberColor(element.useNeedNum, element.useHaveNum, neednum, havenum)
        -- self:onSetNumberPosX(element.useHaveNum, element.useNeedNum)
        
    end
end

--消耗物品
function PartsIntensifyPanel:initUse(configData)
    self._configData = configData

    local element = self._element
    local needid = configData.id
    local neednum = configData.num
    local roleProxy = self:getProxy(GameProxys.Role)
    local havenum = roleProxy:getRolePowerValue(GamePowerConfig.Resource,needid)
    local resConfig = ConfigDataManager:getConfigByPowerAndID(configData.power,needid)--getConfigById(ConfigData.ResourceConfig, needid)
    local tt = {}
    tt.num = havenum
    tt.power =  GamePowerConfig.Resource 
    tt.typeid = needid
    if self._useIcon == nil then
        self._useIcon = UIIcon.new(element.useIcon,tt,false, self)
        self._useIcon:setPosition(element.useIcon:getContentSize().width/2,element.useIcon:getContentSize().height/2)
    else
        self._useIcon:updateData(tt)
    end
    --print("useHaveNum ==========",havenum)
    element.useName:setString(resConfig.name)
    -- element.useNeedNum:setString("/"..self:convertToString(neednum)) 

    element.useNeedNum:setString(self:convertToString(neednum))
    element.useHaveNum:setString(string.format(TextWords[8244],self:convertToString(havenum)))

    if havenum < neednum then
        self._isMaterialEnough = false
    end 

    self:onSetNumberColor(element.useNeedNum, element.useHaveNum, neednum, havenum)
    -- self:onSetNumberPosX(element.useHaveNum, element.useNeedNum)

    --使用记忆金属
    local t = {}
    t.num = self._roleProxy:getRolePowerValue(GamePowerConfig.Item, 4019)
    t.power =  GamePowerConfig.Item 
    t.typeid = 4019 
    if self._metalIcon == nil then
        self._metalIcon = UIIcon.new(element.metalIcon,t,false,self)
        self._metalIcon:setPosition(element.metalIcon:getContentSize().width/2,element.metalIcon:getContentSize().height/2)
        self._metalIcon:setShowName(true)
    else
        self._metalIcon:updateData(t)
    end

    -- element.metalIconName:setString(self._metalIcon:getName())

    self:updateUseMetalLabel()

end 
function PartsIntensifyPanel:getAttrAdd(configData,nextConfigData)
    local tempNames = {}
    local sid = 8210
    for i=1,4,1 do
        local id = sid + i
        tempNames[i] = self:getTextWord(id)
    end 
    local attrNames = {}
    local attrNums = {}
    local attrAddNums = {}
    if configData.life > 0 then
        table.insert(attrNames,tempNames[1])
        local numStr1 = configData.life .."%"
        --print("111111111111111111111111 ", numStr1)
        table.insert(attrNums,numStr1)
        local numStr2 = (nextConfigData.life-configData.life) .."%"
        --print("222222222222222222222222 ", numStr2)
        table.insert(attrAddNums,numStr2)
    end 
    if configData.attack > 0 then
        table.insert(attrNames,tempNames[2])
        local numStr1 = configData.attack .."%"
         --print("3333333333333333333333 ", numStr1)
        table.insert(attrNums,numStr1)
        local numStr2 = (nextConfigData.attack-configData.attack) .."%"
        table.insert(attrAddNums,numStr2)
        --print("44444444444444444444444 ", numStr2)
    end 
    if configData.protection > 0 then
        table.insert(attrNames,tempNames[3])
        table.insert(attrNums,configData.protection)
        local str = nextConfigData.protection-configData.protection
        table.insert(attrAddNums, string.format("%.2f",str))

    end 
    if configData.puncture > 0 then
        table.insert(attrNames,tempNames[4])
        table.insert(attrNums,configData.puncture)
        local str = nextConfigData.puncture-configData.puncture
        table.insert(attrAddNums, string.format("%.2f",str))
    end 
    local temp = {}
    temp.attrName = attrNames
    temp.attrNum = attrNums
    temp.attrAddNum = attrAddNums
    return temp
end

-- 满级加成
function PartsIntensifyPanel:getMaxAttr(configData)
    local tempNames = {}
    local sid = 8210
    for i=1,4,1 do
        local id = sid + i
        tempNames[i] = self:getTextWord(id)
    end 
    local attrNames = {}
    local attrNums = {}
    local attrAddNums = {}
    if configData.life > 0 then
        table.insert(attrNames,tempNames[1])
        local numStr1 = configData.life .."%"
        table.insert(attrNums,numStr1)
        -- local numStr2 = (nextConfigData.life-configData.life) .."%"
        -- table.insert(attrAddNums,numStr2)
    end 
    if configData.attack > 0 then
        table.insert(attrNames,tempNames[2])
        local numStr1 = configData.attack .."%"
        table.insert(attrNums,numStr1)
        -- local numStr2 = (nextConfigData.attack-configData.attack) .."%"
        -- table.insert(attrAddNums,numStr2)
    end 
    if configData.protection > 0 then
        table.insert(attrNames,tempNames[3])
        table.insert(attrNums,configData.protection)
        -- table.insert(attrAddNums,nextConfigData.protection-configData.protection)
    end 
    if configData.puncture > 0 then
        table.insert(attrNames,tempNames[4])
        table.insert(attrNums,configData.puncture)
        -- table.insert(attrAddNums,nextConfigData.puncture-configData.puncture)
    end 
    local temp = {}
    temp.attrName = attrNames
    temp.attrNum = attrNums
    -- temp.attrAddNum = attrAddNums
    return temp
end

--军械强化配置表
function PartsIntensifyPanel:getPartsIntensifyConfigData(strenLv,quality,part)
    local t = ConfigDataManager:getConfigData(ConfigData.OrdnanceStrConfig)
    local data = {}
    for _,v in pairs(t) do
        if strenLv == v.level and quality == v.quality then
            data.rate = (v.rate/1000)*100
            local need = {}
            if part < 5 then
                need = StringUtils:jsonDecode(v.onetofourneed)
            else
                need = StringUtils:jsonDecode(v.fivetoreightneed)
            end 
            data.id = need[1][2]
            data.num = need[1][3]
            data.power = need[1][1]
            break
        end 
    end 
    return data
end 
function PartsIntensifyPanel:convertToString(num)
    local numStr = StringUtils:formatNumberByK3(num)
    --[[if num > 999999 then
        num = num/1000000
        num = math.floor(num)
        numStr = num .."M"        
    elseif num > 999 then
        num = num/1000
        num = math.floor(num)
        numStr = num .."K"
    end 
    --]]
    return numStr
end 
function PartsIntensifyPanel:updateUseMetalLabel()
    --更新使用金属数量
    local useMetalLabel = self._element.metalUseNum
    useMetalLabel:setString(self._useMetalNum)
    local roleProxy = self:getProxy(GameProxys.Role)
    local metalNum = roleProxy:getRolePowerValue(GamePowerConfig.Item,4019)
    local temp = metalNum - self._useMetalNum
    self._element.metalHaveNum:setString(string.format(TextWords[8243],self:convertToString(temp)))
    
    NodeUtils:alignNodeL2R(self._element.metalHaveNum.left,self._element.metalHaveNum,self._element.metalHaveNum.right)

    --更新成功率
    local singleAdd = 5
    local totalAdd = self._useMetalNum*singleAdd
    local rate = totalAdd + self._originalRate
    -- if rate + self._vipAddRate > 100 then 
    --     rate  = 100
    -- end
    self:initAttrData(rate) 
    -- logger:info("num = %d before=%d, after=%d", totalAdd, (totalAdd + self._originalRate), rate)
    --self._element.oddsNum:setString(rate .."%")
end 
-------------回调函数定义----------------

-- 点击强化
function PartsIntensifyPanel:onIntensifyBtnClicked(sender)
    -- 检查等级
    local roleProxy = self:getProxy(GameProxys.Role)
    local roleLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) or 0
    local nextLevel = self._data.parts.strgthlv + 1
    if nextLevel > roleLevel then
        self:showSysMessage(self:getTextWord(8234))
        return 
    end
    if self._isMaterialEnough == false then
        self:showSysMessage(self:getTextWord(8215))--银币不足
        return 
    end 
    local partsInfo = self._data.parts
    local partsProxy = self:getProxy(GameProxys.Parts)
    local data = {}
    data.id = partsInfo.id  --配件id
    data.num = self._useMetalNum --增加几率道具数量
--    data.num = 40 --增加几率道具数量
    partsProxy:ordnanceStrengthenReq(data)
end 

function PartsIntensifyPanel:onMinusBtnClicked(sender)
    if self._useMetalNum > 0 then
        self._useMetalNum = self._useMetalNum - 1
    end 
    self:updateUseMetalLabel()
end

function PartsIntensifyPanel:onAddBtnClicked(sender)
    if self._isMaterialEnough == false then
        self:showSysMessage(self:getTextWord(8215))
        return 
    end 
    local roleProxy = self:getProxy(GameProxys.Role)
    local havenum = roleProxy:getRolePowerValue(GamePowerConfig.Item,4019)
    if self._useMetalNum < havenum then
        local singleAdd = 5
        local totalAdd = self._useMetalNum*singleAdd
        local rate = totalAdd + self._originalRate + self._vipAddRate
        if rate < 100 then
            self._useMetalNum = self._useMetalNum + 1
        else
            self:showSysMessage(self:getTextWord(8217))
        end
    else
        self:showSysMessage(self:getTextWord(8216))
    end 
    self:updateUseMetalLabel()
end 


function PartsIntensifyPanel:onSetNumberColor(needSprite, haveSprite, needNumber, haveNumber)
    -- body
    if needSprite == nil or haveSprite == nil then
        --print("onSetNumberColor: needSprite == nil or haveSprite == nil")
        return
    end

    if needNumber == nil or haveNumber == nil then
        --print("onSetNumberColor: needNumber == nil or haveNumber == nil")
        return
    end

    if needNumber > haveNumber then
        haveSprite:setColor(ColorUtils.wordColorLight04)
    else
        haveSprite:setColor(ColorUtils.wordColorLight03)
    end
end

-- 左对齐
function PartsIntensifyPanel:onSetNumberPosX(lSprite, rSprite)
    -- body
    if lSprite == nil or rSprite == nil then
        --print("onSetNumberPosX: lSprite == nil or rSprite == nil")
        return
    end

    local size = lSprite:getContentSize()
    rSprite:setPositionX(lSprite:getPositionX() + size.width)
end 

-- 强化成功/失败之后的回调
function PartsIntensifyPanel:updateStrengState(rs)
    local partsIcon = self:getChildByName("mainPanel/topPanel/Image_icon")
    local name = "rgb-js-qianghua"
    if rs == -6 then
        name = "rgb-js-shibai"
    end
    if rs ~= 0 and rs ~= -6 then
        return
    end
    local effect = self:createUICCBLayer(name, partsIcon, nil, nil, true)
    local size = partsIcon:getContentSize()
    effect:setPosition(size.width/2,size.height/2)

    -- 如果失败了，还原秘术，还有相关显示
    if rs == - 6 then
        self:intensifyFailureResp()  
    end
end

-- 如果失败了，还原秘术，还有相关显示
function PartsIntensifyPanel:intensifyFailureResp()
    self:initAttrData(self._originalRate) -- 几率
    self._useMetalNum = 0
    local useMetalLabel = self._element.metalUseNum
    useMetalLabel:setString(self._useMetalNum)
end