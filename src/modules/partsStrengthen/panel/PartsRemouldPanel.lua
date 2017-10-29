PartsRemouldPanel = class("PartsRemouldPanel", BasicPanel) --改造
PartsRemouldPanel.NAME = "PartsRemouldPanel"

function PartsRemouldPanel:ctor(view, panelName)
    PartsRemouldPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function PartsRemouldPanel:finalize()
    PartsRemouldPanel.super.finalize(self)
end

function PartsRemouldPanel:initPanel()
    PartsRemouldPanel.super.initPanel(self)
    -- self:setTitle(true,"Remould",true)
    self._roleProxy = self:getProxy(GameProxys.Role)
    self._element = self:getPanelElement()
    local mainPanel = self:getPanel(PartsStrengthenPanel.NAME)
    local data = mainPanel:getData()
    if data ~= nil then
        self:updatePanelInfo(data)
    end 
    
end

function PartsRemouldPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    local mainPanel = self:getChildByName("mainPanel")
    NodeUtils:adaptiveTopPanelAndListView(mainPanel, nil,GlobalConfig.downHeight,tabsPanel)
end

function PartsRemouldPanel:onShowHandler()
    PartsRemouldPanel.super.onShowHandler(self)
    for i=1,4 do
        local node = self:getChildByName("mainPanel/infoPanel/Image_use_icon"..i)
        node:stopAllActions()
        node:setScale(1)
        node:setPosition(self.allPos[i])
        node:setRotation(0)
    end
    local mainPanel = self:getPanel(PartsStrengthenPanel.NAME)
    local data = mainPanel:getData()
    self:updatePanelInfo(data)
end

function PartsRemouldPanel:getPanelElement()
    local tElement = {}
    local mainPanel = self:getChildByName("mainPanel")
    local infoPanel = mainPanel:getChildByName("infoPanel")
    local topPanel = mainPanel:getChildByName("topPanel")
    tElement.partsIcon = topPanel:getChildByName("Image_icon")
    tElement.partsName = topPanel:getChildByName("Label_name")
    tElement.attrPanel = topPanel:getChildByName("Panel_attr")
    tElement.maxLvTip = topPanel:getChildByName("maxLvTip")

    self.allPos = {}
    
    local pos = tElement.partsIcon:getWorldPosition()
    self.targetPos = infoPanel:convertToNodeSpace(pos)

    local size = tElement.attrPanel:getContentSize()
    --print("size ===",size.width,size.height)
    tElement.AttrLabel = ComponentUtils:createRichLabel("",cc.size(size.width,0))
    tElement.AttrLabel:setPosition(10, size.height)
    tElement.AttrLabel:setAnchorPoint(cc.p(0,1))
    tElement.attrPanel:addChild(tElement.AttrLabel)
    --消耗1
    tElement.useIcon1 = infoPanel:getChildByName("Image_use_icon1")
    self.allPos[1] = cc.p(tElement.useIcon1:getPosition())
    tElement.useName1 = infoPanel:getChildByName("Label_use_name1")
    tElement.useNeed1 = infoPanel:getChildByName("Label_use_need1")
    tElement.useHave1 = infoPanel:getChildByName("Label_use_have1")
    --消耗2
    tElement.useIcon2 = infoPanel:getChildByName("Image_use_icon2")
    self.allPos[2] = cc.p(tElement.useIcon2:getPosition())
    tElement.useName2 = infoPanel:getChildByName("Label_use_name2")
    tElement.useNeed2 = infoPanel:getChildByName("Label_use_need2")
    tElement.useHave2 = infoPanel:getChildByName("Label_use_have2")
    --消耗3
    tElement.useIcon3 = infoPanel:getChildByName("Image_use_icon3")
    self.allPos[3] = cc.p(tElement.useIcon3:getPosition())
    tElement.useName3 = infoPanel:getChildByName("Label_use_name3")
    tElement.useNeed3 = infoPanel:getChildByName("Label_use_need3")
    tElement.useHave3 = infoPanel:getChildByName("Label_use_have3")
    --消耗4
    tElement.useIcon4 = infoPanel:getChildByName("Image_use_icon4")
    self.allPos[4] = cc.p(tElement.useIcon4:getPosition())
    tElement.useName4 = infoPanel:getChildByName("Label_use_name4")
    tElement.useNeed4 = infoPanel:getChildByName("Label_use_need4")
    tElement.useHave4 = infoPanel:getChildByName("Label_use_have4")
    --改造图纸
    tElement.useIcon5 = infoPanel:getChildByName("Image_use_icon5")
    tElement.useName5 = infoPanel:getChildByName("Label_use_name5")
    tElement.useNeed5 = infoPanel:getChildByName("Label_use_need5")
    tElement.useHave5 = infoPanel:getChildByName("Label_use_have5")
    --复选框
    tElement.checkbox = infoPanel:getChildByName("CheckBox")
    local function  onCheckBoxClicked(sender,state)
        self:onCheckBoxClicked()
    end 
    tElement.checkbox:addEventListener(onCheckBoxClicked)
    tElement.remouldBtn = self:getChildByName("downPanel/Button_remould")
    self:addTouchEventListener(tElement.remouldBtn, self.onRemouldBtnClicked)
    infoPanel:getChildByName("Label_word_9"):setString(self:getTextWord(8235))
    self._infoPanel = infoPanel
    self._remouldBtn = tElement.remouldBtn
    self._maxLvTip = tElement.maxLvTip
    return tElement

end 
--更新panel信息
function PartsRemouldPanel:updatePanelInfo(data)
    self._data = data
    self._isMaterialEnough = true
    self._isPaperEnough = true
    local partsInfo = data.parts
    local configData = data.configData
    local element = self._element
    
   
    element.checkbox:setSelectedState(false)
    --配件图标
    local tempData = {}
    tempData.num =  data.num --test
    tempData.power =  data.power --test
    tempData.typeid =  data.typeid --配件的唯一标志ID
    tempData.parts = partsInfo
    local uiIcon = element.partsIconUIIcon
    if uiIcon == nil then
        local uiIcon = UIIcon.new(element.partsIcon,tempData,false, self)
        uiIcon:setPosition(element.partsIcon:getContentSize().width/2,element.partsIcon:getContentSize().height/2)
        element.partsIconUIIcon = uiIcon
    else
        uiIcon:updateData(tempData)
    end

    --配件名
    element.partsName:setString(configData.name)
   
    self:initAttrData(false)
end    

--消耗道具
function PartsRemouldPanel:initItem()
    local partsInfo = self._data.parts
    local element = self._element

    local roleProxy = self:getProxy(GameProxys.Role)
    
    local need = self:getPartsRemouldConfigData(partsInfo.remoulv,partsInfo.quality,partsInfo.part)
    local need1 = need[1]
    local need2 = need[2]
    local need3 = need[3]
    local need4 = need[4]


    element.useNeed1:setString("/"..self:convertToString(need1[3]))
    local have1 = roleProxy:getRolePowerValue(GamePowerConfig.Item,need1[2])
    element.useHave1:setString(self:convertToString(have1))
    if need1[3] > have1 then
        self._isMaterialEnough = false
    end

    element.useNeed2:setString("/"..self:convertToString(need2[3]))
    local have2 = roleProxy:getRolePowerValue(GamePowerConfig.Item,need2[2])
    element.useHave2:setString(self:convertToString(have2))
    if need2[3] > have2 then
        self._isMaterialEnough = false
    end 
    
    element.useNeed3:setString("/"..self:convertToString(need3[3]))
    local have3 = roleProxy:getRolePowerValue(GamePowerConfig.Item,need3[2])
    element.useHave3:setString(self:convertToString(have3))
    if need3[3] > have3 then
        self._isMaterialEnough = false
    end 
    
    element.useNeed4:setString("/"..self:convertToString(need4[3]))
    local have4 = roleProxy:getRolePowerValue(GamePowerConfig.Item,need4[2])
    element.useHave4:setString(self:convertToString(have4))
    if need4[3] > have4 then
        self._isMaterialEnough = false
    end 
    
    local itemConfig1 = ConfigDataManager:getConfigById(ConfigData.ItemConfig,need1[2])
    local itemConfig2 = ConfigDataManager:getConfigById(ConfigData.ItemConfig,need2[2])
    local itemConfig3 = ConfigDataManager:getConfigById(ConfigData.ItemConfig,need3[2])
    local itemConfig4 = ConfigDataManager:getConfigById(ConfigData.ItemConfig,need4[2])
    element.useName1:setString(itemConfig1.name)
    element.useName2:setString(itemConfig2.name)
    element.useName3:setString(itemConfig3.name)
    element.useName4:setString(itemConfig4.name)
    --图标
    local tt1 = {}
    tt1.num = self._roleProxy:getRolePowerValue(GamePowerConfig.Item, need1[2])
    tt1.power =  GamePowerConfig.Item 
    tt1.typeid = need1[2]
    if self._useIcon1 == nil then
        self._useIcon1 = UIIcon.new(element.useIcon1,tt1,false, self)
        self._useIcon1:setPosition(element.useIcon1:getContentSize().width/2,element.useIcon1:getContentSize().height/2)
    else
        self._useIcon1:updateData(tt1)
    end
    local tt4 = {}
    tt4.num = self._roleProxy:getRolePowerValue(GamePowerConfig.Item, need4[2])
    tt4.power =  GamePowerConfig.Item 
    tt4.typeid = need4[2]
    if self._useIcon4 == nil then
        self._useIcon4 = UIIcon.new(element.useIcon4,tt4,false, self)
        self._useIcon4:setPosition(element.useIcon4:getContentSize().width/2,element.useIcon4:getContentSize().height/2)
    else
        self._useIcon4:updateData(tt4)
    end
    local tt2 = {}
    tt2.num = self._roleProxy:getRolePowerValue(GamePowerConfig.Item, need2[2])
    tt2.power =  GamePowerConfig.Item 
    tt2.typeid = need2[2]
    if self._useIcon2 == nil then
        self._useIcon2 = UIIcon.new(element.useIcon2,tt2,false, self)
        self._useIcon2:setPosition(element.useIcon2:getContentSize().width/2,element.useIcon2:getContentSize().height/2)
    else
        self._useIcon2:updateData(tt2)
    end
    local tt3 = {}
    tt3.num = self._roleProxy:getRolePowerValue(GamePowerConfig.Item, need3[2])
    tt3.power =  GamePowerConfig.Item 
    tt3.typeid = need3[2]
    if self._useIcon3 == nil then
        self._useIcon3 = UIIcon.new(element.useIcon3,tt3,false, self)
        self._useIcon3:setPosition(element.useIcon3:getContentSize().width/2,element.useIcon3:getContentSize().height/2)
    else
        self._useIcon3:updateData(tt3)
    end
    --改造图纸4020
    local useNum5 = 5
    local typeid = 4020
    local itemConfig5 = ConfigDataManager:getConfigById(ConfigData.ItemConfig,typeid)
    element.useName5:setString(itemConfig5.name)
    element.useNeed5:setString("/"..useNum5 )
    local have5 = roleProxy:getRolePowerValue(GamePowerConfig.Item,typeid)
    element.useHave5:setString(self:convertToString(have5))
    local t = {}
    t.num = self._roleProxy:getRolePowerValue(GamePowerConfig.Item, typeid)
    t.power =  GamePowerConfig.Item 
    t.typeid = typeid 
    if self._useIcon5 == nil then
        self._useIcon5 = UIIcon.new(element.useIcon5,t,false, self)
        self._useIcon5:setPosition(element.useIcon5:getContentSize().width/2,element.useIcon5:getContentSize().height/2)
    else
        self._useIcon5:updateData(t)
    end
    if have5 < useNum5 then
        self._isPaperEnough = false
    end


    self:onSetNumberColor(element.useNeed1, element.useHave1, need1[3], have1)
    self:onSetNumberColor(element.useNeed2, element.useHave2, need2[3], have2)
    self:onSetNumberColor(element.useNeed3, element.useHave3, need3[3], have3)
    self:onSetNumberColor(element.useNeed4, element.useHave4, need4[3], have4)
    self:onSetNumberColor(element.useNeed4, element.useHave5, useNum5, have5)
    self:onSetNumberPosX(element.useHave1, element.useNeed1)    
    self:onSetNumberPosX(element.useHave2, element.useNeed2)    
    self:onSetNumberPosX(element.useHave3, element.useNeed3)    
    self:onSetNumberPosX(element.useHave4, element.useNeed4)    
    self:onSetNumberPosX(element.useHave5, element.useNeed5)    
end

--初始化属性
function PartsRemouldPanel:initAttrData(isUsePaper)
    self._infoPanel:setVisible(true)
    self._remouldBtn:setVisible(true)
    self._maxLvTip:setVisible(false)

    local data = self._data
    local attrPanel = self._element.attrPanel
    local parts = data.parts
    local configData = data.configData
    local nextParts = {}
    local minusIntenLv = 3
    if parts.strgthlv < 3 then
        minusIntenLv = parts.strgthlv
    end 
    if isUsePaper == true then
        minusIntenLv = 0
    end 
    nextParts.part = parts.part
    nextParts.quality = parts.quality
    nextParts.strgthlv = parts.strgthlv - minusIntenLv
    nextParts.remoulv = parts.remoulv +1
    nextParts.type = parts.type

    local proxy = self:getProxy(GameProxys.Parts)
    local nextConfigData = proxy:getDataFromOrdnanceConfig(nextParts)
    
    --------------------------------------------------------
    --TODO 改造到满级的时候，nextConfigData为空，做具体逻辑
    if nextConfigData == nil or parts.remoulv == 10 then
        self:maxAttrData(isUsePaper)
        return
    end
    --------------------------------------------------------

    local attrAdd = self:getAttrAdd(configData,nextConfigData)
    local attrAddNames = attrAdd.attrName
    local attrNums = attrAdd.attrNum
    local attrAddNums = attrAdd.attrAddNum
    local lines = {}
    --配件强度：10
    local strengthNum = parts.strength
    local strengthWordStr = self:getTextWord(8205)--..strengthNum
    local line1 = {}
    line1[1] = {}
    line1[1].content = strengthWordStr
    line1[1].foneSize = 20
    line1[1].color = ColorUtils.commonColor.FuBiaoTi--"#F19715"

    line1[2] = {}
    line1[2].content = strengthNum
    line1[2].foneSize = 20
    line1[2].color = ColorUtils.commonColor.White--"#F19715"

    table.insert(lines,line1)
    for k,v in pairs(attrAddNames) do
        local line = {}
        line[1] = {}
        line[2] = {}
        line[1].content = v
        line[1].foneSize = 20
        line[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"
       
        line[2] = {}
        line[2].content = " "..attrNums[k]
        line[2].foneSize = 20
        line[2].color = ColorUtils.commonColor.White--"#46ff3d"

        line[3] = {}
        line[3].content = "    ↑ "..attrAddNums[k]
        line[3].foneSize = 20
        line[3].color = ColorUtils.commonColor.Green--"#46ff3d"
        table.insert(lines,line)
    end 
     --改造等级：0
    local remLv = parts.remoulv
    local addRemLv = 1
    local remWordStr = self:getTextWord(8207)--..remLv
    local addRemStr = "    ↑ "..addRemLv
    local line4 = {}
    line4[1]={}
    line4[1].content = remWordStr
    line4[1].foneSize = 20
    line4[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"


    line4[2]={}
    line4[2].content = remLv
    line4[2].foneSize = 20
    line4[2].color = ColorUtils.commonColor.White--"#46ff3d"

    line4[3]={}
    line4[3].content = addRemStr
    line4[3].foneSize = 20
    line4[3].color = ColorUtils.commonColor.Green--"#46ff3d"
    table.insert(lines,line4)
    --强化等级：1 ↑1
    local intenLv = parts.strgthlv
    local addIntenLv = 1
    local intenWordStr = self:getTextWord(8206)--..intenLv
    
    local line3 = {}
    line3[1] = {}
    
    line3[1].content = intenWordStr
    line3[1].foneSize = 20
    line3[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"

    line3[2]={}
    line3[2].content = tostring(intenLv)
    line3[2].foneSize = 20
    line3[2].color = ColorUtils.commonColor.White--"#46ff3d"

    if isUsePaper == false and parts.strgthlv>0 then
        local minusIntenLv = 3
        if parts.strgthlv < 3 then
            minusIntenLv = parts.strgthlv
        end 
        local minusIntenStr = "    ↓ "..minusIntenLv
        line3[3] = {}
        line3[3].content = minusIntenStr
        line3[3].foneSize = 20
        line3[3].color = ColorUtils.commonColor.Red--"#ff3e3e"
        
    end 
    table.insert(lines,line3)
    
    self:initAttrLabel(lines)
    self:initItem()
end
function PartsRemouldPanel:initAttrLabel(lines)
--    local texts = StringUtils:getHtmlByLines(lines)
    self._element.AttrLabel:setString(lines)
end 
function PartsRemouldPanel:getAttrAdd(configData,nextConfigData)
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
        local numStr2 = (nextConfigData.life-configData.life) .."%"
        table.insert(attrAddNums,numStr2)
    end 
    if configData.attack > 0 then
        table.insert(attrNames,tempNames[2])
        local numStr1 = configData.attack .."%"
        table.insert(attrNums,numStr1)
        local numStr2 = (nextConfigData.attack-configData.attack) .."%"
        table.insert(attrAddNums,numStr2)
    end 
    if configData.protection > 0 then
        table.insert(attrNames,tempNames[3])
        table.insert(attrNums,configData.protection)
        table.insert(attrAddNums,nextConfigData.protection-configData.protection)
    end 
    if configData.puncture > 0 then
        table.insert(attrNames,tempNames[4])
        table.insert(attrNums,configData.puncture)
        table.insert(attrAddNums,nextConfigData.puncture-configData.puncture)
    end 
    local temp = {}
    temp.attrName = attrNames
    temp.attrNum = attrNums
    temp.attrAddNum = attrAddNums
    return temp
end

--满级属性
function PartsRemouldPanel:maxAttrData(isUsePaper)
    self._infoPanel:setVisible(false)
    self._remouldBtn:setVisible(false)
    self._maxLvTip:setVisible(true)
    self._maxLvTip:setString(self:getTextWord(8231))

    local data = self._data
    local attrPanel = self._element.attrPanel
    local parts = data.parts
    local configData = data.configData
    local nextParts = {}
    local minusIntenLv = 3
    if parts.strgthlv < 3 then
        minusIntenLv = parts.strgthlv
    end 
    if isUsePaper == true then
        minusIntenLv = 0
    end 
   

    local attrAdd = self:maxAttrAdd(configData)
    local attrAddNames = attrAdd.attrName
    local attrNums = attrAdd.attrNum
    -- local attrAddNums = attrAdd.attrAddNum
    local lines = {}


    --配件强度：10
    local strengthNum = parts.strength
    local strengthWordStr = self:getTextWord(8205)--..strengthNum
    local line1 = {}
    line1[1] = {}
    line1[1].content = strengthWordStr.." "
    line1[1].foneSize = 20
    line1[1].color = ColorUtils.commonColor.FuBiaoTi--"#F19715"

    line1[2] = {}
    line1[2].content = strengthNum
    line1[2].foneSize = 20
    line1[2].color = ColorUtils.commonColor.White--"#F19715"


    table.insert(lines,line1)
    for k,v in pairs(attrAddNames) do
        local line = {}
        line[1] = {}
        line[1].content = v
        line[1].foneSize = 20
        line[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"
       
        line[2] = {}
        line[2].content = attrNums[k]
        line[2].foneSize = 20
        line[2].color = ColorUtils.commonColor.White--"#46ff3d"
        table.insert(lines,line)
    end 
     --改造等级：0
    local remLv = parts.remoulv
    local addRemLv = 1
    local remWordStr = self:getTextWord(8207)--..remLv
    -- local addRemStr = "    ↑"..addRemLv
    local line4 = {}
    line4[1]={}
    line4[1].content = remWordStr
    line4[1].foneSize = 20
    line4[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"

    line4[2]={}
    line4[2].content = remLv
    line4[2].foneSize = 20
    line4[2].color = ColorUtils.commonColor.White--"#eed6aa"

    -- line4[2].content = addRemStr
    -- line4[2].foneSize = 20
    -- line4[2].color = "#FF32CD"


    table.insert(lines,line4)

    --强化等级：1 ↑1
    local intenLv = parts.strgthlv
    -- local addIntenLv = 1
    local intenWordStr = self:getTextWord(8206)--..intenLv
    
    local line3 = {}
    line3[1] = {}
    line3[1].content = intenWordStr
    line3[1].foneSize = 20
    line3[1].color = ColorUtils.commonColor.FuBiaoTi--"#eed6aa"

    line3[2] = {}
    line3[2].content = intenLv
    line3[2].foneSize = 20
    line3[2].color = ColorUtils.commonColor.White--"#eed6aa"

    -- if isUsePaper == false and parts.strgthlv>0 then
    --     local minusIntenLv = 3
    --     if parts.strgthlv < 3 then
    --         minusIntenLv = parts.strgthlv
    --     end 
    --     local minusIntenStr = "    ↓"..minusIntenLv
    --     line3[2] = {}
    --     line3[2].content = minusIntenStr
    --     line3[2].foneSize = 20
    --     line3[2].color = "#FF32CD"
        
    -- end 
    table.insert(lines,line3)
    
    self:maxAttrLabel(lines)
end
function PartsRemouldPanel:maxAttrLabel(lines)
--    local texts = StringUtils:getHtmlByLines(lines)
    self._element.AttrLabel:setString(lines)
end

function PartsRemouldPanel:maxAttrAdd(configData)
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

local actionTime = 0.5
local rotate = 50
local scaleValue = 0

function PartsRemouldPanel:partsChange()
    self:playEffect()


end

function PartsRemouldPanel:playEffect()
    local no = 1

    local targetNode = self:getChildByName("mainPanel/topPanel/Image_icon")
    if targetNode.effect ~= nil then
        targetNode.effect:finalize()
    end

    local effect = self:createUICCBLayer("rgb-js-gaizhao", targetNode, nil, nil, true)
    targetNode.effect = effect
    local size = targetNode:getContentSize()
    effect:setPosition(size.width/2, size.height/2)

    for i=1,4 do
        local node = self:getChildByName("mainPanel/infoPanel/Image_use_icon"..i)
        node.index = i
        -- self._canPlay[i] = 0
        local sk = cc.RotateBy:create(actionTime, rotate)
        local sca = cc.ScaleTo:create(actionTime, scaleValue)
        local move = cc.MoveTo:create(actionTime, self.targetPos)
        local action = cc.Spawn:create(sk, sca, move)
        local call = cc.CallFunc:create(function(sender)
            local index = sender.index
            sender:setScale(1)
            sender:setPosition(self.allPos[index])
            sender:setRotation(0)
            no = no + 1
            if no >= 4 then
                -- EffectQueueManager:completeEffect()
            end
            -- self._canPlay[index] = 1
        end)
        local seq = cc.Sequence:create(action, call)
        node:runAction(seq)
    end
end

--军械改造数据表
function PartsRemouldPanel:getPartsRemouldConfigData(remLv,quality,part)
    local t = ConfigDataManager:getConfigData(ConfigData.OrdnanceRemConfig)
    local need = {}
    for _,v in pairs(t) do
        if remLv == v.remouldLv and quality == v.quality  and part == v.part then
            need = StringUtils:jsonDecode(v.need)
            break
        end 
    end 
    return need
end 
function PartsRemouldPanel:convertToString(num)
   local numStr = StringUtils:formatNumberByK3(num)
   --[[ if num > 999999 then
        num = num/100000
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
-------------回调函数定义-----------

--点击复选框
function PartsRemouldPanel:onCheckBoxClicked()
    if self._isMaterialEnough == false then
        self._element.checkbox:setSelectedState(false)
        self:showSysMessage(self:getTextWord(8218))
    elseif self._isPaperEnough == false then
        self._element.checkbox:setSelectedState(false)
        self:showSysMessage(self:getTextWord(8219))
    end 
    local state = self._element.checkbox:getSelectedState()
    self:initAttrData(state)
end 
--改造
function PartsRemouldPanel:onRemouldBtnClicked(sender)
    local checkBox = self._element.checkbox
    local state = checkBox:getSelectedState()
    --print("state===",state)
    local type = 1
    if state == false then
        type = 0
    end 
    
    -- for i=1,4 do
    --     local node = self:getChildByName("mainPanel/infoPanel/Image_use_icon"..i)
    --     node:stopAllActions()
    --     node:setScale(1)
    --     node:setPosition(self.allPos[i])
    --     node:setRotation(0)
    -- end

    local partsInfo = self._data.parts
    local partsProxy = self:getProxy(GameProxys.Parts)
    local data = {}
    data.id = partsInfo.id  --配件id
    data.type = type --是否使用道具，1使用
    partsProxy:ordnanceRemouldReq(data)
end


function PartsRemouldPanel:onSetNumberColor(needSprite, haveSprite, needNumber, haveNumber)
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
        -- haveSprite:setColor(ColorUtils.wordColorLight04)
        haveSprite:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.Red))
    else
        -- haveSprite:setColor(ColorUtils.wordColorLight03)
        haveSprite:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.Green))
    end
end

-- 左对齐
function PartsRemouldPanel:onSetNumberPosX(lSprite, rSprite)
    -- body
    if lSprite == nil or rSprite == nil then
        --print("onSetNumberPosX: lSprite == nil or rSprite == nil")
        return
    end

    local size = lSprite:getContentSize()
    rSprite:setPositionX(lSprite:getPositionX() + size.width)
end 