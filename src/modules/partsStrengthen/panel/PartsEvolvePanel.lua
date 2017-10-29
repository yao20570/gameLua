PartsEvolvePanel = class("PartsEvolvePanel", BasicPanel) --进阶
PartsEvolvePanel.NAME = "PartsEvolvePanel"

function PartsEvolvePanel:ctor(view, panelName)
    PartsEvolvePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function PartsEvolvePanel:finalize()
    PartsEvolvePanel.super.finalize(self)
end

function PartsEvolvePanel:initPanel()
    PartsEvolvePanel.super.initPanel(self)
    self._roleProxy = self:getProxy(GameProxys.Role)
    self._element = self:getPanelElement()
end

function PartsEvolvePanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    local mainPanel = self:getChildByName("mainPanel")
    NodeUtils:adaptiveTopPanelAndListView(mainPanel, nil, GlobalConfig.downHeight, tabsPanel)
end

function PartsEvolvePanel:onShowHandler()
    PartsEvolvePanel.super.onShowHandler(self)
    local mainPanel = self:getPanel(PartsStrengthenPanel.NAME)
    local data = mainPanel:getData()
    self:updatePanelInfo(data)
end


function PartsEvolvePanel:getPanelElement()
    local tElement = {}
    local mainPanel = self:getChildByName("mainPanel")
    local infoPanel = mainPanel:getChildByName("infoPanel")
    tElement.partsIcon = infoPanel:getChildByName("Image_icon")
    tElement.partsName = infoPanel:getChildByName("Label_name")
    
    tElement.toPartsIcon = infoPanel:getChildByName("Image_icon_evolve")
    tElement.toPartsName = infoPanel:getChildByName("Label_name_evolve")
    
    tElement.useIcon1 = infoPanel:getChildByName("Image_use_icon1")
    tElement.useIcon2 = infoPanel:getChildByName("Image_use_icon2")
    tElement.useName1 = infoPanel:getChildByName("Label_use_name1")
    tElement.useName2 = infoPanel:getChildByName("Label_use_name2")
    tElement.useNeed1 = infoPanel:getChildByName("Label_use_need1")
    tElement.useNeed2 = infoPanel:getChildByName("Label_use_need2")
    tElement.useHave1 = infoPanel:getChildByName("Label_use_have1")
    tElement.useHave2 = infoPanel:getChildByName("Label_use_have2")

    tElement.tipsLabel = infoPanel:getChildByName("Label_tips")
    tElement.returnPanel = infoPanel:getChildByName("Panel_return")
   
    tElement.evolveBtn = self:getChildByName("downPanel/Button_evolve")
    self:addTouchEventListener(tElement.evolveBtn, self.onEvolveBtnClicked)
    
    tElement.Button_info = infoPanel:getChildByName("Button_info")
    self:addTouchEventListener(tElement.Button_info, self.onTipBtnClicked)

    return tElement

end 
--更新panel信息
function PartsEvolvePanel:updatePanelInfo(data)
    self._data = data
    local partsInfo = data.parts
    local configData = data.configData
    local element = self._element
    self._isadvace = configData.isadvance
    --配件图标
    local tempData = {}
    tempData.num =  data.num 
    tempData.power =  data.power 
    tempData.typeid =  data.typeid 
    tempData.parts = partsInfo
    if self._uiIcon then
        self._uiIcon:finalize()
        self._uiIcon = nil
    end 
    self._uiIcon = UIIcon.new(element.partsIcon,tempData,false, self)
    self._uiIcon:setPosition(element.partsIcon:getContentSize().width/2,element.partsIcon:getContentSize().height/2)
    --配件名
    element.partsName:setString(configData.name)
    element.toPartsName:setString("")
    if self._need1 ~= nil and self._need2 ~= nil then
        local roleProxy = self:getProxy(GameProxys.Role)
        local have1 = roleProxy:getRolePowerValue(self._need1[1], self._need1[2])
        local have2 = roleProxy:getRolePowerValue(self._need2[1], self._need2[2])
        
        element.useHave1:setString(self:convertToString(have1))
        element.useHave2:setString(self:convertToString(have2))
        self:onSetNumberColor(element.useNeed1, element.useHave1)
        self:onSetNumberColor(element.useNeed2, element.useHave2)
    end 

    --进阶消耗(进阶条件：紫色、改造4级及以上)
    if configData.isadvance == 1 then
        --配件名
        element.toPartsName:setString(configData.name)

        --进阶配件这操作好像有点
        local toParts = {}
        toParts.id = partsInfo.id 
        toParts.typeid = partsInfo.typeid 
        toParts.strgthlv=0 
        toParts.remoulv=0 
        toParts.type=partsInfo.type 
        toParts.quality=partsInfo.quality+1 
        toParts.part=partsInfo.part 
        toParts.position = partsInfo.position 
        toParts.strength=partsInfo.strength 
        local conData = self:getConfigData(toParts.typeid)

        local tempData = {}
        tempData.num =  1 
        tempData.power =  data.power 
        tempData.typeid =  conData.ID 
        local uiIcon = element.toPartsIconUIIcon
        if uiIcon == nil then
            uiIcon = UIIcon.new(element.toPartsIcon,tempData,false, self)
            uiIcon:setPosition(element.toPartsIcon:getContentSize().width/2,element.toPartsIcon:getContentSize().height/2)
            element.toPartsIconUIIcon = uiIcon
        else
            uiIcon:updateData(tempData)
        end

        --消耗
        local need = StringUtils:jsonDecode(configData.advanceitem)
        if need and #need > 0 then
            local need1 = need[1]
            local need2 = need[2]
            self._need1 = need1
            self._need2 = need2
            element.useNeed1:setString("/"..self:convertToString(need1[3]))
            element.useNeed2:setString("/"..self:convertToString(need2[3]))
            local roleProxy = self:getProxy(GameProxys.Role)
            local have1 = roleProxy:getRolePowerValue(need1[1],need1[2])
            local have2 = roleProxy:getRolePowerValue(need2[1],need2[2])
            element.useHave1:setString(self:convertToString(have1))
            element.useHave2:setString(self:convertToString(have2))
            local pieceConfig1 = ConfigDataManager:getConfigById(ConfigData.OrdnancePieceConfig,need1[2])
            local pieceConfig2 = ConfigDataManager:getConfigById(ConfigData.OrdnancePieceConfig,need2[2])
            element.useName1:setString(pieceConfig1.name)
            element.useName2:setString(pieceConfig2.name)
            
            self:onSetNumberColor(element.useNeed1, element.useHave1)
            self:onSetNumberColor(element.useNeed2, element.useHave2)
            -- self:onSetNumberPosX(element.useHave1, element.useNeed1)    
            -- self:onSetNumberPosX(element.useHave2, element.useNeed2)    
            NodeUtils:alignNodeL2R(element.useHave1,element.useNeed1 )
            NodeUtils:alignNodeL2R(element.useHave2,element.useNeed2 )
            NodeUtils:centerNodes(element.useName1, {element.useHave1,element.useNeed1})
            NodeUtils:centerNodes(element.useName2, { element.useHave2,element.useNeed2,})

            local t1 = {}
            t1.num = have1
            t1.power =  need1[1] --GamePowerConfig.OrdnanceFragment 
            t1.typeid =  need1[2] 
            t1.tag =  1 
            local useIcon1 = element.useIcon1UIIcon1
            if useIcon1 == nil then
                useIcon1 = UIIcon.new(element.useIcon1,t1,false, self)
                useIcon1:setPosition(element.useIcon1:getContentSize().width/2,element.useIcon1:getContentSize().height/2)
                element.useIcon1UIIcon1 = useIcon1
            else
                useIcon1:updateData(t1)
            end            

            local t2 = {}
            t2.num = have2
            t2.power =  need2[1] --GamePowerConfig.OrdnanceFragment 
            t2.typeid =  need2[2] 
            t2.tag =  1 
            local useIcon2 = element.useIcon2UIIcon2
            if useIcon2 == nil then
                local useIcon2 = UIIcon.new(element.useIcon2,t2,false, self)
                useIcon2:setPosition(element.useIcon2:getContentSize().width/2,element.useIcon2:getContentSize().height/2)
                element.useIcon2UIIcon2 = useIcon2
            else
                useIcon2:updateData(t2)
            end            

        end
        --材料返还
        local backConfigData = self:getEvolveBackConfigData(partsInfo.quality,partsInfo.part,partsInfo.remoulv)
        if backConfigData then
            element.tipsLabel:setVisible(false)
            element.returnPanel:setVisible(true)
            local back = StringUtils:jsonDecode(backConfigData.reback)
            local len = #back
            for k,v in pairs(back) do
                local backid = v[2]
                local backnum = v[3]
                local t = {}
                t.num = backnum
                t.power = GamePowerConfig.Item
                t.typeid = backid
                local size = element.returnPanel:getContentSize()
                local x = (size.width*k)/(len+1)
                local y = size.height/2


                -- returnPanel材料返回层，总共有多个
                local backIcon = element["returnPanelUIIcon"..k]
                if backIcon == nil then
                    local sprite = cc.Sprite:create()
                    element.returnPanel:addChild(sprite)
                    backIcon = UIIcon.new(sprite,t,true, self)

                    --修正x 让icon的间距平均分布
                    x = x -backIcon:getContentSize().width/2 + backIcon:getContentSize().width / (len+1) * k

                    backIcon:setPosition(x,y)
                    element["returnPanelUIIcon"..k] = backIcon
                    backIcon:setShowName(true)
                else
                    backIcon:updateData(t)
                end            

            end 
        else
            element.tipsLabel:setVisible(true)
            element.returnPanel:setVisible(false)
        end 
    end 
end


function PartsEvolvePanel:convertToString(num)
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
--获取配置表数据
function PartsEvolvePanel:getConfigData(parts)
    local idConfig = ConfigDataManager:getConfigById(ConfigData.OrdnanceConfig, parts)
    local upId = idConfig.advancetarget
    local upData = ConfigDataManager:getConfigById(ConfigData.OrdnanceConfig, upId)
    return upData
end 
--读取进阶材料返还表
function PartsEvolvePanel:getEvolveBackConfigData(quality,part,remLv)
    local t = ConfigDataManager:getConfigData(ConfigData.AdvanceRemouldConfig)
    local temp = nil
    for _,v in pairs(t) do
        if v.quality == quality and v.part == part and v.remouldLv == remLv then
            temp = v
            break
        end 
    end 
    return temp
end 
-------------回调函数定义-----------
function PartsEvolvePanel:onEvolveBtnClicked(sender)
    if self._isadvace == 0 then
        self:showSysMessage(self:getTextWord(8229))
        return
    end
    local partsInfo = self._data.parts
    local partsProxy = self:getProxy(GameProxys.Parts)
    local data = {}
    data.id = partsInfo.id  --配件id
    partsProxy:ordnanceEvolveReq(data)
end 

-- 进阶tip
function PartsEvolvePanel:onTipBtnClicked(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local line1 = {{content = self:getTextWord(12000), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line2 = {{content = self:getTextWord(12001), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line3 = {{content = self:getTextWord(12002), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}

    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)
    table.insert(lines, line3)          
    uiTip:setAllTipLine(lines)  
end 

function PartsEvolvePanel:onSetNumberColor(needSprite, haveSprite)
    -- body
    if needSprite == nil or haveSprite == nil then
        --print("onSetNumberColor: needSprite == nil or haveSprite == nil")
        return
    end

    local str = needSprite:getString()
    -- 第一个字符是"/"
    local needNumber = tonumber( string.sub(str, 2, ( string.len(str))))
    local haveNumber = tonumber(haveSprite:getString())

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
function PartsEvolvePanel:onSetNumberPosX(lSprite, rSprite)
    -- body
    if lSprite == nil or rSprite == nil then
        --print("onSetNumberPosX: lSprite == nil or rSprite == nil")
        return
    end

    local size = lSprite:getContentSize()
    rSprite:setPositionX(lSprite:getPositionX() + size.width)
end

-- 刷新材料
function PartsEvolvePanel:onUpdatePieceInfo()
    local element = self._element
    if element == nil then
        return
    end
    if self._need1 ~= nil and self._need2 ~= nil then
        local roleProxy = self:getProxy(GameProxys.Role)
        local have1 = roleProxy:getRolePowerValue(self._need1[1], self._need1[2])
        local have2 = roleProxy:getRolePowerValue(self._need2[1], self._need2[2])
        
        element.useHave1:setString(self:convertToString(have1))
        element.useHave2:setString(self:convertToString(have2))
        self:onSetNumberColor(element.useNeed1, element.useHave1)
        self:onSetNumberColor(element.useNeed2, element.useHave2)
    end

    if element.useIcon1UIIcon1 ~= nil then
        if self._need1 ~= nil  then
            local t1 = {}
            t1.num = self._roleProxy:getRolePowerValue(self._need1[1],self._need1[2])
            t1.power =  self._need1[1]
            t1.typeid =  self._need1[2]
            t1.tag =  1

            element.useIcon1UIIcon1:updateData(t1)
        end
    end

    if element.useIcon2UIIcon2 ~= nil then
        if self._need2 ~= nil  then
            local t1 = {}
            t1.num = self._roleProxy:getRolePowerValue(self._need2[1],self._need2[2])
            t1.power =  self._need2[1]
            t1.typeid =  self._need2[2]
            t1.tag =  1

            element.useIcon2UIIcon2:updateData(t1)
        end
    end

end
