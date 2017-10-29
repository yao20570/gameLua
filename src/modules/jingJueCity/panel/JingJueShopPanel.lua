-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-02-22
--  * @Description: 限时活动_精绝古城_地下黑市
--  */
JingJueShopPanel = class("JingJueShopPanel", BasicPanel)
JingJueShopPanel.NAME = "JingJueShopPanel"

function JingJueShopPanel:ctor(view, panelName)
    JingJueShopPanel.super.ctor(self, view, panelName)

end

function JingJueShopPanel:finalize()
    JingJueShopPanel.super.finalize(self)
end

function JingJueShopPanel:initPanel()
	JingJueShopPanel.super.initPanel(self)
	self._listview = self:getChildByName("ListView")
	self.proxy = self:getProxy(GameProxys.Activity)
end
function JingJueShopPanel:onShowHandler()
	self:updateJingJueShopView()
end
function JingJueShopPanel:updateJingJueShopView()
	--获得获得数据
	self.myData = self.proxy:getCurActivityData()
	self.jingJueInfo = self.proxy:getJingJueInfoById(self.myData.activityId)
	local jsonConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.TombCityConfig, "effectID", self.myData.effectId)
	--特殊物品的显示uiicon
	local img = self:getChildByName("topPanel/img")
    local compoundIcon = StringUtils:jsonDecode(jsonConfig.compoundIcon)
    local iconData = {}
    iconData.typeid = compoundIcon[2]
    iconData.power = compoundIcon[1]
    if img.uiIcon == nil then
        img.uiIcon = UIIcon.new(img,iconData,true,self)
    else
        img.uiIcon:updateData(iconData)
    end
    --显示名字、描述、数量
    local nameLab = self:getChildByName("topPanel/nameLab")
    local descLab = self:getChildByName("topPanel/descLab")
    local numLab = self:getChildByName("topPanel/numLab")
    nameLab:setString(img.uiIcon._data.name)
    descLab:setString(img.uiIcon._data.dec)
    numLab:setString(self.jingJueInfo.num)
    -- logger:info(jsonConfig.marketID)

    local info = ConfigDataManager:getInfosFilterByOneKey(ConfigData.TombMarketConfig,"marketID",jsonConfig.marketID)
    self:renderListView(self._listview, info, self, self.renderItemPanel)

end
function JingJueShopPanel:renderItemPanel(itemPanel, info, index)
    local img = itemPanel:getChildByName("img")
    local nameLab = itemPanel:getChildByName("nameLab")
    local descLab = itemPanel:getChildByName("descLab")
    local numLab = itemPanel:getChildByName("numLab")
    local btn = itemPanel:getChildByName("btn")
    
    local lab1 = itemPanel:getChildByName("lab1")
    local labNum = itemPanel:getChildByName("labNum")
    local labNumMax = itemPanel:getChildByName("labNumMax")

    local compoundIcon = StringUtils:jsonDecode(info.compoundItem)
    local iconData = {}
    iconData.typeid = compoundIcon[2]
    iconData.power = compoundIcon[1]
    iconData.num = compoundIcon[3]
    if img.uiIcon == nil then
        img.uiIcon = UIIcon.new(img,iconData,true,self)
    else
        img.uiIcon:updateData(iconData)
    end
    --拼接字符串 如 道具名（0/1）
    local fullStr
    if info.compoundTime ~= 0 then
        local mergeNum = self.proxy:getJingJueMergeByActIdAndID( self.myData.activityId,info.ID )
        --fullStr = img.uiIcon._data.name .. "(" .. mergeNum .. "/" .. info.compoundTime .. ")"
        lab1:setVisible(true)
        labNum:setVisible(true)
        labNumMax:setVisible(true)
        fullStr = img.uiIcon._data.name
        nameLab:setString(fullStr)
        lab1:setString("(")
        labNum:setString(mergeNum)
        labNumMax:setString("/" .. info.compoundTime .. ")")
        NodeUtils:alignNodeL2R(nameLab, lab1, labNum, labNumMax, 1)
    else
        lab1:setVisible(false)
        labNum:setVisible(false)
        labNumMax:setVisible(false)
        fullStr = img.uiIcon._data.name
        nameLab:setString(fullStr)
    end
    --描述
    if img.uiIcon._data.dec == "" or img.uiIcon._data.dec == nil or type(img.uiIcon._data.dec) ~= type("string") then
        descLab:setVisible(false)
    else
        descLab:setVisible(true)
        descLab:setString(img.uiIcon._data.dec)
    end
    --合成需要的数量
    local expendItem = StringUtils:jsonDecode(info.expendItem)
    numLab:setString(expendItem[3])
    --按钮
    btn.info = info
    self:addTouchEventListener(btn, self.onItemBtnHandler)


end
function JingJueShopPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, self._listview, GlobalConfig.downHeight, tabsPanel,3)
end

function JingJueShopPanel:registerEvents()
	JingJueShopPanel.super.registerEvents(self)
end
function JingJueShopPanel:onItemBtnHandler(sender)
    --判断兑换所需材料是否足够
    local expendItem = StringUtils:jsonDecode(sender.info.expendItem)
    local needNum = expendItem[3]
    if needNum > self.jingJueInfo.num then
        self:showSysMessage(self:getTextWord(460006))
        return
    end
    --判断是否达到兑换上限
    local mergeNum = self.proxy:getJingJueMergeByActIdAndID( self.myData.activityId,sender.info.ID )
    if mergeNum >= sender.info.compoundTime and sender.info.compoundTime ~= 0 then
        self:showSysMessage(self:getTextWord(460007))
        return
    end

    local function sureFun()
        local sendData = {}
        sendData.activityId = self.myData.activityId
        sendData.typeId = sender.info.ID
        self.proxy:onTriggerNet230049Req(sendData)
    end
    self:showMessageBox(string.format(self:getTextWord(460008),needNum),sureFun)

end