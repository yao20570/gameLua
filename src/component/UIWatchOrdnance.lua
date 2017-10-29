-----------
---查看配置信息-----

UIWatchOrdnance = class("UIWatchOrdnance")

--即关即释放
function UIWatchOrdnance:ctor(panel, data, isShare)
    local uiSkin = UISkin.new("UIWatchOrdnance")
    uiSkin:setParent(panel:getParent())
    
    self._uiSkin = uiSkin
    self._panel = panel
    
    self._data = data
    
    
    
    
    local secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    self._secLvBg = secLvBg
    secLvBg:setContentHeight(425)
    secLvBg:setBackGroundColorOpacity(128)
    secLvBg:setTitle(TextWords:getTextWord(325))
    self._isShare = isShare
    self:registerEventHandler(isShare)
    self:_updateInfo(data)


end

function UIWatchOrdnance:finalize()
    if self.uiIcon ~= nil then
        self.uiIcon:finalize()
        self.uiIcon = nil
    end

    if self._uiSharePanel ~= nil then
        self._uiSharePanel:finalize()
        self._uiSharePanel = nil
    end
    self._uiSkin:finalize()
end

function UIWatchOrdnance:hide()
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnance:_updateInfo(data)
    self._data = data
    local partsInfo = self._data.parts
    local partsProxy = self._panel:getProxy(GameProxys.Parts)
    local configData = partsProxy:getDataFromOrdnanceConfig(partsInfo)
    --parts icon
    local partsIcon = self:getChildByName("mainPanel/iconContainer")
    local tempData = {}
    tempData.num =  self._data.num --test
    tempData.power =  self._data.power --test
    tempData.typeid =  self._data.typeid --配件的唯一标志ID
    tempData.parts = partsInfo
    if self.uiIcon == nil then
        self.uiIcon = UIIcon.new(partsIcon,tempData,false)
    else
        self.uiIcon:updateData(tempData)
    end
    self.uiIcon:setPosition(partsIcon:getContentSize().width/2,partsIcon:getContentSize().height/2)
    --parts name Label_name
    local partsName = self:getChildByName("mainPanel/Label_name")
    partsName:setString(configData.name)

    --初始化属性
    local attrPanel = self:getChildByName("mainPanel/Panel_attr")
    local size = attrPanel:getContentSize()
    self._AttrLabel = ComponentUtils:createRichLabel("",cc.size(size.width,0))
    self._AttrLabel:setPosition(10, size.height)
    self._AttrLabel:setAnchorPoint(cc.p(0,1))
    attrPanel:addChild(self._AttrLabel)
    self:initAttrData(configData)
    --卸下按钮wearBtn
    local wearBtn = self:getChildByName("mainPanel/wearBtn")
    --装备按钮equipBtn
    local equipBtn = self:getChildByName("mainPanel/equipBtn")
    if data.equip == nil then
        wearBtn:setVisible(true and self._isShare == nil)
        equipBtn:setVisible(false)
    else
        wearBtn:setVisible(false)
        equipBtn:setVisible(true and self._isShare == nil)
    end 
    self["equipBtn"] = equipBtn
    local numBgPanel = equipBtn:getChildByName("Panel_numBg")
    if data.isRecommendParts == true then
        numBgPanel:setVisible(true)
    else
        numBgPanel:setVisible(false)
    end
    --分解按钮partBtn
    local partBtn = self:getChildByName("mainPanel/partBtn")
    --设置按钮不可按且按钮变灰
    if self._data.isInPartsMainPanel == true then
        -- partBtn:setEnabled(false)
        -- partBtn:setBright(false)
        NodeUtils:setEnable(partBtn, false)
    end 

    --进阶按钮
    local evolveBtn = self:getChildByName("mainPanel/evolveBtn")
    if configData.isadvance == 0 then
        --evolveBtn:setVisible(false)
        NodeUtils:setEnable(evolveBtn, false)
    else
        --evolveBtn:setVisible(true)
        NodeUtils:setEnable(evolveBtn, true)
    end 

end

function UIWatchOrdnance:initAttrData(configData)
    local data = self._data
    local parts = data.parts
    local attrAdd = self:getAttrAdd(configData)
    local attrAddNames = attrAdd.attrName
    local attrNums = attrAdd.attrNum
    local lines = {}
    local fontSize = 20
    --配件强度：10
    local strengthNum = parts.strength
    local strengthWordStr = TextWords:getTextWord(8205)..strengthNum
    local line1 = {}
    line1[1] = {}
    line1[1].content = strengthWordStr
    line1[1].foneSize = fontSize
    line1[1].color = "#F19715"
    table.insert(lines,line1)
    for k,v in pairs(attrAddNames) do
        local line = {}
        line[1] = {}
        line[1].content = v
        line[1].foneSize = fontSize
        line[1].color = "#eed6aa"
        
        line[2] = {}
        line[2].content = " "..attrNums[k]
        line[2].foneSize = fontSize
        line[2].color = "#46ff3d"
        
        table.insert(lines,line)
    end 
    --使用兵种
    local configData = ConfigDataManager:getConfigData("OrdnancePageConfig")
    local nameStr = ""
    for _,v in pairs(configData) do
        if parts.type == v.tankType then
            nameStr = v.tankName
            break
        end 
    end 
    local nameWordStr = TextWords:getTextWord(8220)
    local line7 = {}
    line7[1]={}
    line7[1].content = nameWordStr
    line7[1].foneSize = fontSize
    line7[1].color = "#eed6aa"
    
    line7[2] = {}
    line7[2].content = " "..nameStr
    line7[2].foneSize = fontSize
    line7[2].color = "#46ff3d"
    table.insert(lines,line7)
    --改造等级：0
    local remLv = parts.remoulv
    local remWordStr = TextWords:getTextWord(8207)
    local line4 = {}
    line4[1]={}
    line4[1].content = remWordStr
    line4[1].foneSize = fontSize
    line4[1].color = "#eed6aa"
    
    line4[2] = {}
    line4[2].content = remLv
    line4[2].foneSize = fontSize
    line4[2].color = "#46ff3d"
    table.insert(lines,line4)
    --强化等级：1 ↑1
    local intenLv = parts.strgthlv
    local intenWordStr = TextWords:getTextWord(8206)
    local line3 = {}
    line3[1] = {}
    line3[1].content = intenWordStr
    line3[1].foneSize = fontSize
    line3[1].color = "#eed6aa"
    
    line3[2] = {}
    line3[2].content = intenLv
    line3[2].foneSize = fontSize
    line3[2].color = "#46ff3d"
    table.insert(lines,line3)
    
   
    self:initAttrLabel(lines)
end

function UIWatchOrdnance:initAttrLabel(lines)
--    local texts = StringUtils:getHtmlByLines(lines)
    self._AttrLabel:setString(lines)
end 

function UIWatchOrdnance:getAttrAdd(configData)
    local tempNames = {}
    local sid = 8210
    for i=1,4,1 do
        local id = sid + i
        tempNames[i] = TextWords:getTextWord(id)
    end 
    local attrNames = {}
    local attrNums = {}
    
    if configData.life > 0 then
        table.insert(attrNames,tempNames[1])
        local numStr = configData.life .."%"
        table.insert(attrNums,numStr) 
    end 
    if configData.attack > 0 then
        table.insert(attrNames,tempNames[2])
        local numStr = configData.attack .."%"
        table.insert(attrNums,numStr) 
    end 
    if configData.protection > 0 then
        table.insert(attrNames,tempNames[3])
        table.insert(attrNums,configData.protection)   
    end 
    if configData.puncture > 0 then
        table.insert(attrNames,tempNames[4])
        table.insert(attrNums,configData.puncture)
        
    end 
    local temp = {}
    temp.attrName = attrNames
    temp.attrNum = attrNums
    return temp
end 

function UIWatchOrdnance:registerEventHandler(isShare)
    if isShare then
        self._secLvBg:setContentHeight(330)
        local mainPanel = self:getChildByName("mainPanel")
        local childs = mainPanel:getChildren()
        for k,v in pairs(childs) do
            childs[k].y = childs[k].y or v:getPositionY()
            local y = childs[k].y
            v:setPositionY(y - 45)
        end
    end

    local partBtn = self:getChildByName("mainPanel/partBtn")
    local strengthBtn = self:getChildByName("mainPanel/strengthBtn")
    local reformBtn = self:getChildByName("mainPanel/reformBtn")
    local wearBtn = self:getChildByName("mainPanel/wearBtn")
    local equipBtn = self:getChildByName("mainPanel/equipBtn")
    local evolveBtn = self:getChildByName("mainPanel/evolveBtn")
    local shareBtn = self:getChildByName("mainPanel/shareBtn")
    shareBtn:setVisible(isShare == nil)
    evolveBtn:setVisible(isShare == nil)
    equipBtn:setVisible(isShare == nil)
    wearBtn:setVisible(isShare == nil)
    reformBtn:setVisible(isShare == nil)
    strengthBtn:setVisible(isShare == nil)
    partBtn:setVisible(isShare == nil)
    
    ComponentUtils:addTouchEventListener(partBtn, self.onPartBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(strengthBtn, self.onStrengthBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(reformBtn, self.onReformBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(wearBtn, self.onWearBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(equipBtn, self.onEquipBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(evolveBtn, self.onEvolveBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(shareBtn, self.onShareBtnTouch, nil, self)
    
end

function UIWatchOrdnance:onShareBtnTouch(sender)
    if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new(sender, self._panel)
    end
    
    local data = {}
    data.type = ChatShareType.ORDNANCE_TYPE
    data.id = self._data.parts.id -- #4556
    self._uiSharePanel:showPanel(sender, data)
end

function UIWatchOrdnance:onCloseBtnTouch(sender)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnance:onPartBtnTouch(sender)
    self._panel:onPartTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnance:onStrengthBtnTouch(sender)
    self._panel:onStrengthTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnance:onReformBtnTouch(sender)
    self._panel:onReformTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnance:onWearBtnTouch(sender)
    self._panel:onWearTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnance:onEquipBtnTouch(sender)
    self._panel:onEquipTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end

--onEvolveBtnTouch
function UIWatchOrdnance:onEvolveBtnTouch(sender)
    self._panel:onEvolveTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnance:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UIWatchOrdnance:getIcon()
    return self:getChildByName("mainPanel/iconContainer")
end
