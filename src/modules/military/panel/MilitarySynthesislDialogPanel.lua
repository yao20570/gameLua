MilitarySynthesislDialogPanel = class("MilitarySynthesislDialogPanel", BasicPanel)
MilitarySynthesislDialogPanel.NAME = "MilitarySynthesislDialogPanel"

function MilitarySynthesislDialogPanel:ctor(view, panelName)
    MilitarySynthesislDialogPanel.super.ctor(self, view, panelName, 700)
    
    self._panel = view

end

function MilitarySynthesislDialogPanel:initPanel()
	MilitarySynthesislDialogPanel.super.initPanel(self)
    self:setTitle(true, TextWords:getTextWord(510026))

    self._militaryProxy = self:getProxy(GameProxys.Military)

    self._okBtn = self:getChildByName("mainPanel/okBtn")

    self._currentCount = 1
    self._costItemCountArr = nil
    self._isEnable = true
end

function MilitarySynthesislDialogPanel:finalize()
    if self._uiMoveBtn then
        self._uiMoveBtn:finalize()
    end
    MilitarySynthesislDialogPanel.super.finalize(self)
end

--typeid为空，或者等于0 则为建筑的 --计算出来的最大时间
function MilitarySynthesislDialogPanel:onShowHandler(data)
    --获取加速道具列表
    self._synthesisDataId = data.ID
    self._targetData = StringUtils:jsonDecode(data.targetID)
    self._costData = StringUtils:jsonDecode(data.costID)
    
    self._costItemCountArr = {}
    self._isEnable = true

    self:initView()
    self:renderAllItem()
end

--@param isOpenUpdate 是否打开更新，打开更新，才会初始化
function MilitarySynthesislDialogPanel:renderAllItem()
    local data = {}
    for k, v in pairs(self._costData) do
        table.insert(data,{typeid = v[2], num = v[3]})
    end

    ComponentUtils:addTouchEventListener(self._okBtn, self.onOKBtnTouch, nil, self)
    local countImg = self:getChildByName("mainPanel/countImg")

    self._listView = self:getChildByName("mainPanel/listView_0")
    self._panel["accUpBtn"] = upBtn
    
    self:renderListView(self._listView, data, self, self.renderOneItem, nil, true)

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

function MilitarySynthesislDialogPanel:onMoveBtnCallback(count)
    local upBtn = self:getChildByName("mainPanel/okBtn")

    local maxCont = self:getMaxCount()
    count = count > maxCont and maxCont or count
    if count <= 0 then 
       count = tonumber(tostring(0))
    end

    local numLab = self:getChildByName("mainPanel/numLab")
    numLab:setString(count)
    
    self._currentCount = count
    self:updateCostItemCount()
end

function MilitarySynthesislDialogPanel:renderOneItem(itemPanel, info, index, isOpenUpdate)
    if info == nil then
        return
    end
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
    icon.num = num
end


--计算可以合成道具的最大个数
--作为进度条的最大值
function MilitarySynthesislDialogPanel:getMaxCount()
    local itemProxy = self:getProxy(GameProxys.Item)
    local num = 0
    local numCost = 0
    local maxCount = 0
    local numTmp = 0
    for k, v in pairs(self._costData) do
        num = itemProxy:getItemNumByType(v[2])
        numCost = v[3]
        if num == 0 or numCost > num then
            self._isEnable = false
            maxCount = 1
            break
        end
        numTmp = math.floor(num / numCost)
        if maxCount == 0 then
            maxCount = numTmp
        else
            if numTmp < maxCount then
                maxCount = numTmp
            end
        end
    end
    NodeUtils:setEnable(self._okBtn, self._isEnable)

    if maxCount > 100 then
        maxCount = 100
    end

    return maxCount
end

function MilitarySynthesislDialogPanel:onCloseBtnTouch(sender)
    self:hide()
end

function MilitarySynthesislDialogPanel:onOKBtnTouch(sender)
    local data = {}
    data.typeId = self._synthesisDataId
    data.num = self._currentCount
    self._militaryProxy:onTriggerNet90010Req(data)
    self:hide()
end

function MilitarySynthesislDialogPanel:initView()
    local iconContainer = self:getChildByName("mainPanel/itemPanel0/imgContainer")
    local data = {}
    data.power = self._targetData[1][1]
    data.typeid = self._targetData[1][2]
    data.num = num
    local icon = iconContainer.icon
    if icon == nil then
        icon = UIIcon.new(iconContainer,data, false)
        iconContainer.icon = icon
        icon:setTouchEnabled(false)
        --icon:getNameChild():setFontSize(18)
        --local y = icon:getNameChild():getPositionY()
        --icon:getNameChild():setPositionY(y - 8)
    else
        icon:updateData(data)
    end
    
    local nameTxt = self:getChildByName("mainPanel/itemPanel0/nameTxt")
    nameTxt:setString(icon:getName())
    
    local desTxt = self:getChildByName("mainPanel/itemPanel0/desTxt")
    desTxt:setString(icon:getDec())
end

function MilitarySynthesislDialogPanel:updateCostItemCount()
    local itemPanelArr = self._listView:getItems()
    if itemPanelArr == nil then
        return
    end
    for k, v in pairs(itemPanelArr) do
        local iconContainer = v:getChildByName("iconImg")
        local icon = iconContainer.icon
        icon:updateIconNum(icon.num * self._currentCount)
    end
end