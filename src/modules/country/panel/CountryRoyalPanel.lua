-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CountryRoyalPanel = class("CountryRoyalPanel", BasicPanel)
CountryRoyalPanel.NAME = "CountryRoyalPanel"

function CountryRoyalPanel:ctor(view, panelName)
    CountryRoyalPanel.super.ctor(self, view, panelName)

end

function CountryRoyalPanel:finalize()
    CountryRoyalPanel.super.finalize(self)
end

function CountryRoyalPanel:initPanel()
	CountryRoyalPanel.super.initPanel(self)
    self._countryProxy = self:getProxy(GameProxys.Country)
    self._roleProxy = self:getProxy(GameProxys.Role)
end

function CountryRoyalPanel:registerEvents()
	CountryRoyalPanel.super.registerEvents(self)
    
    self._topPanel = self:getChildByName("topPanel")

    self._listView01 = self:getChildByName("midPanel/listView1")
    self._listView02 = self:getChildByName("midPanel/listView2")
    self._listView03 = self:getChildByName("midPanel/listView3")

    self._dynastyBtn = self._topPanel:getChildByName("dynastyBtn")

    self:addTouchEventListener(self._dynastyBtn, self.onDynastyBtn)

    self._showTipBtn = self._topPanel:getChildByName("showTipBtn")
    self:addTouchEventListener(self._showTipBtn, self.onShowTipBtn)
    self._showTipBtn:setPosition(562, 343)
end

function CountryRoyalPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    local midPanel = self:getChildByName("midPanel")
    NodeUtils:adaptiveTopPanelAndListView( self._topPanel, midPanel, GlobalConfig.downHeight, tabsPanel, 0)
end

function CountryRoyalPanel:onShowHandler()
    self:setDynasty() -- 设置朝代按钮
     self:onUpdateRoyalPanel()
end

function CountryRoyalPanel:onUpdateRoyalPanel()
    self:setTopPanel()

    self:onUpdateListPanel()
end

function CountryRoyalPanel:onUpdateListPanel()

    self:setListView01()
    self:setListView02()
    self:setListView03()
end

function CountryRoyalPanel:setListView01()
    local listData = self._countryProxy:getListViewData01()

    self:renderListView(self._listView01, listData, self, self.renderItem01, nil, true,0)
end

function CountryRoyalPanel:renderItem01(itemPanel, data, index)
    
    for i = 1, 2 do
        local roleItem = itemPanel:getChildByName("roleItem"..i)
        local jobFont = roleItem:getChildByName("jobFont")
        local nameTxt = roleItem:getChildByName("nameTxt")
        local headImg = roleItem:getChildByName("headImg")
        local addBtn  = roleItem:getChildByName("addBtn")
        local positionType = data[i].positionType
        TextureManager:updateImageView(jobFont, "images/countryIcon/type_"..positionType..".png")


        local memberInfo = self._countryProxy:getPosInfoById(data[i].ID)

        if memberInfo == nil then
            headImg:setVisible(false)
            addBtn:setVisible(true)
            nameTxt:setString(self:getTextWord(560007))
        else
            headImg:setVisible(true)
            addBtn:setVisible(false)
            self:updateHeadImg(headImg, memberInfo.iconId, memberInfo.playerId)
            -- 名字
            nameTxt:setString(memberInfo.playerName)
        end

        headImg.memberInfo = memberInfo
        addBtn.memberInfo = memberInfo
        headImg.configData = data[i]
        addBtn.configData = data[i]

        self:addTouchEventListener(headImg, self.onTouchAddBtn)
        self:addTouchEventListener(addBtn, self.onTouchAddBtn)
    end
end

function CountryRoyalPanel:setListView02()
    local listData = self._countryProxy:getListViewData02()

    self:renderListView(self._listView02, listData, self, self.renderItem, nil, true,0)
end

function CountryRoyalPanel:setListView03()
    local listData = self._countryProxy:getListViewData03()

    self:renderListView(self._listView03, listData, self, self.renderItem, nil, true,0)
end

function CountryRoyalPanel:renderItem(itemPanel, data, index)
    local jobFont = itemPanel:getChildByName("jobFont")
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local headImg = itemPanel:getChildByName("headImg")
    local addBtn  = itemPanel:getChildByName("addBtn")

    local positionType = data.positionType
    TextureManager:updateImageView(jobFont, "images/countryIcon/type_"..positionType..".png")
    
    local memberInfo = self._countryProxy:getPosInfoById(data.ID)

    if memberInfo == nil then
        headImg:setVisible(false)
        addBtn:setVisible(true)
        nameTxt:setString(self:getTextWord(560007))
    else
        headImg:setVisible(true)
        addBtn:setVisible(false)

        self:updateHeadImg(headImg, memberInfo.iconId, memberInfo.playerId)
        -- 名字
        nameTxt:setString(memberInfo.playerName)
    end

    headImg.memberInfo = memberInfo
    addBtn.memberInfo = memberInfo
    headImg.configData = data
    addBtn.configData = data

    self:addTouchEventListener(headImg, self.onTouchAddBtn)
    self:addTouchEventListener(addBtn, self.onTouchAddBtn)

end

function CountryRoyalPanel:onTouchHeadImg(sender)
    logger:info("点击头像")

end


function CountryRoyalPanel:onTouchAddBtn(sender)
    logger:info("点击加号")
    local configData = sender.configData

    -- 判断权限, 这里任撤同权
    local powerState = false -- 可操作权限标识
    local powerList = self._countryProxy:getMyPowerStateList(self._roleProxy:getRoleName(), "appointPosition")
    for i, typeInfo in pairs(powerList) do
        if typeInfo == configData.positionType then
            powerState = true
            break
        end
    end
    if powerState == false then
        -- self:showSysMessage(self:getTextWord(560008))
    end


    -- 复制节点
    local cloneNode = sender:getParent():clone()

    -- 弹窗
    local checkPanel = self:getPanel(CountryCheckPanel.NAME)
    checkPanel:show(sender.memberInfo)
    checkPanel:setPowerState(powerState)
    checkPanel:updatePanelView(sender.memberInfo, configData, cloneNode)
end

function CountryRoyalPanel:onDynastyBtn(sender)
    -- 设置状态
    local ableState = false
    local myName = self._roleProxy:getRoleName()
    local royalInfo = self._countryProxy:getPosInfoById(1) -- 皇帝ID == 1
    if royalInfo and royalInfo.playerName == myName then
        ableState = true
    end
    if ableState == false then
        self:showSysMessage(self:getTextWord(560008))
        return 
    end
    local dynastyPanel = self:getPanel(CountryDynastyPanel.NAME) 
    dynastyPanel:show()
end

-- 点击查看帮助
function CountryRoyalPanel:onShowTipBtn(sender)
    local content1 = self:getTextWord(560042)
	local content2 = self:getTextWord(560043)
	local content3 = self:getTextWord(560044)
	local content4 = self:getTextWord(560045)

    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local line1 = {{content = content1, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line2 = {{content = content2, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line3 = {{content = content3, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line4 = {{content = content4, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}

    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)
    table.insert(lines, line3)	    
    table.insert(lines, line4)	    
    uiTip:setAllTipLine(lines)
end



-- 设置朝代
function CountryRoyalPanel:setDynasty()
    local dynastyName = self._countryProxy:getDynastyName()
    if dynastyName == "" then
        dynastyName = self:getTextWord(560005) -- "汉"
    end

    local str = string.format(self:getTextWord(560003), dynastyName) -- "%s朝"
    local dynastyTxt = self._dynastyBtn:getChildByName("dynastyTxt")
    dynastyTxt:setString(str)

    -- 
    local emperorName = self._countryProxy:getEmperorName()
    if emperorName == "" then
        emperorName = self:getTextWord(560035) -- "献"
    end
    local emperorStr = string.format(self:getTextWord(560036), dynastyName, emperorName) -- "%s%s帝"
    local emperorTxt = self._dynastyBtn:getChildByName("emperorTxt")
    emperorTxt:setString(emperorStr)
end

-- 设置顶层信息
function CountryRoyalPanel:setTopPanel()
    local data = self._countryProxy:getEmperorIdList()
    
    for i = 1, #data do
        local id = data[i]
        local panel = self._topPanel:getChildByName("panel"..id)
        local headNode = panel:getChildByName("headNode"..id)
        local frameNode= panel:getChildByName("frameNode"..id)
        local memberInfo = self._countryProxy:getPosInfoById(id)
        local configData = ConfigDataManager:getConfigById(ConfigData.CountryPositionConfig, id)
        self:setTopImgView(headNode, frameNode, memberInfo, configData)
    end
end

function CountryRoyalPanel:setTopImgView(headNode, frameNode, memberInfo, configData)
    local headImg = headNode:getChildByName("headImg")

    if memberInfo ~= nil then
        self:updateHeadImg(headImg, memberInfo.iconId, memberInfo.playerId, 1)

        headImg:setVisible(true)
    end
    headImg:setVisible(memberInfo ~= nil)


    local nameTxt = frameNode:getChildByName("nameTxt")
    local legionNameTxt = frameNode:getChildByName("legionNameTxt")
    if memberInfo ~= nil then 
        nameTxt:setString(memberInfo.playerName)
        legionNameTxt:setString(self._countryProxy:getLegionName(configData.ID))
    else
        -- 默认
        nameTxt:setString(self:getTextWord(7090))
        legionNameTxt:setString(self:getTextWord(560007))
    end 


    headNode.memberInfo = memberInfo
    headNode.configData = configData
    -- 点击头像背景
    self:addTouchEventListener(headNode, self.onTouchHeadNode)
end

function CountryRoyalPanel:onTouchHeadNode(sender)
    logger:info("点击了王族头像")

    -- 复制节点
    local cloneNode = sender:getParent():clone()

    -- 弹窗
    local checkPanel = self:getPanel(CountryCheckPanel.NAME)
    checkPanel:show(sender.memberInfo)
    checkPanel:updatePanelView(sender.memberInfo, sender.configData, cloneNode)
end

function CountryRoyalPanel:onTabChangeEvent()
    local panel = self:getPanel(CountryPanel.NAME)
    panel:setBgType(ModulePanelBgType.COUNTRY_ROYAL)
end

------
-- 添加头像
function CountryRoyalPanel:updateHeadImg(headImg, iconId, playerId, scale)
    
    local headInfo = {}
    headInfo.icon = iconId
    headInfo.pendant = 0
    headInfo.preName1 = "headIcon"
	headInfo.preName2 = nil
    headInfo.playerId = playerId

    if headImg.head == nil then
        headImg.head = UIHeadImg.new(headImg, headInfo, self)
        headImg.head:setScale(scale or 0.8)
    else
        headImg.head:updateData(headInfo)
    end
end

