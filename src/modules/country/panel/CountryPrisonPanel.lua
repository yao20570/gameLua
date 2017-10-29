-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CountryPrisonPanel = class("CountryPrisonPanel", BasicPanel)
CountryPrisonPanel.NAME = "CountryPrisonPanel"

function CountryPrisonPanel:ctor(view, panelName)
    CountryPrisonPanel.super.ctor(self, view, panelName)

end

function CountryPrisonPanel:finalize()
    CountryPrisonPanel.super.finalize(self)
    
end

function CountryPrisonPanel:initPanel()
	CountryPrisonPanel.super.initPanel(self)
    self._countryProxy = self:getProxy(GameProxys.Country)
    self._roleProxy = self:getProxy(GameProxys.Role)
end

function CountryPrisonPanel:registerEvents()
	CountryPrisonPanel.super.registerEvents(self)
    self._topPanel = self:getChildByName("topPanel")
    self._listView  = self:getChildByName("listView")

end

function CountryPrisonPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView( self._topPanel, self._listView, GlobalConfig.downHeight, tabsPanel, 0)
end

function CountryPrisonPanel:onShowHandler()
    -- 发送消息号M560002
    self._countryProxy:onTriggerNet560002Req({})
    self._listView:setVisible(false)

    self:onUpdataPrisonPanel()
end

function CountryPrisonPanel:onUpdataPrisonPanel()
    self._listView:setVisible(true)

    local listData = self._countryProxy:getPrisonListData()
    
    self:renderListView(self._listView, listData, self, self.renderItem, nil, true,0)
end


function CountryPrisonPanel:onTabChangeEvent()
    local panel = self:getPanel(CountryPanel.NAME)
    panel:setBgType(ModulePanelBgType.COUNTRY_PRISON) 
end


function CountryPrisonPanel:renderItem(itemPanel, data, index)
    for i = 1, 4 do
        local roleItem = itemPanel:getChildByName("roleItem"..i)
        local jobFont = roleItem:getChildByName("jobFont")
        local nameTxt = roleItem:getChildByName("nameTxt")
        local headImg = roleItem:getChildByName("headImg")
        local addBtn  = roleItem:getChildByName("addBtn")
        -- 位置
        local positionType = data[i].prisonType
        TextureManager:updateImageView(jobFont, "images/countryIcon/prison_"..positionType..".png")

        local prisonInfo = self._countryProxy:getPosPrisonInfoById(data[i].ID)
        if prisonInfo == nil then
            headImg:setVisible(false)
            addBtn:setVisible(true)
            nameTxt:setString(self:getTextWord(560007))
        else
            headImg:setVisible(true)
            addBtn:setVisible(false)
            nameTxt:setString(prisonInfo.info.playerName)

            local memberInfo = prisonInfo.info
            self:updateHeadImg(headImg, memberInfo.iconId, memberInfo.playerId)
        end

        addBtn.prisonInfo = prisonInfo
        addBtn.configData = data[i]

        headImg.prisonInfo = prisonInfo
        headImg.configData = data[i]

        self:addTouchEventListener(addBtn, self.onTouchAddBtn)
        self:addTouchEventListener(headImg, self.onTouchAddBtn)
        
    end
end

function CountryPrisonPanel:onTouchAddBtn(sender)
    logger:info("点击")


    -- 复制节点
    local cloneNode = sender:getParent():clone()

    local configData = sender.configData
    local prisonInfo = sender.prisonInfo

    -- 判断权限, 这里通缉，撤销同权
    local powerState = false -- 可操作权限标识
    local removeState = false -- 可撤销权限标识

    local powerList = self._countryProxy:getMyPowerStateList(self._roleProxy:getRoleName(), "appointWanted")
    for i, typeInfo in pairs(powerList) do
        if typeInfo == configData.prisonType then
            powerState = true
            break
        end
    end

    local removeList = self._countryProxy:getMyPowerStateList(self._roleProxy:getRoleName(), "cancelWanted")
    for i, typeInfo in pairs(removeList) do
        if typeInfo == configData.prisonType then
            removeState = true
            break
        end
    end

    -- 弹窗
    local checkPanel = self:getPanel(CountryPrisonCheckPanel.NAME)
    checkPanel:show()
    checkPanel:setPowerState(powerState)
    checkPanel:setRemoveState(removeState)

    checkPanel:updatePanelView(prisonInfo, configData, cloneNode)
end


------
-- 添加头像
function CountryPrisonPanel:updateHeadImg(headImg, iconId, playerId)
    local headInfo = {}
    headInfo.icon = iconId
    headInfo.pendant = 0
    headInfo.preName1 = "headIcon"
	headInfo.preName2 = nil
    headInfo.playerId = playerId

    if headImg.head == nil then
        headImg.head = UIHeadImg.new(headImg, headInfo, self)
        headImg.head:setScale(0.8)
    else
        headImg.head:updateData(headInfo)
    end
end