-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CountryCheckPanel = class("CountryCheckPanel", BasicPanel)
CountryCheckPanel.NAME = "CountryCheckPanel"

function CountryCheckPanel:ctor(view, panelName)
    CountryCheckPanel.super.ctor(self, view, panelName, 500)

end

function CountryCheckPanel:finalize()
    CountryCheckPanel.super.finalize(self)
end

function CountryCheckPanel:initPanel()
	CountryCheckPanel.super.initPanel(self)

    self:setTitle(true, self:getTextWord(560011)) -- "册封"

    self._countryProxy = self:getProxy(GameProxys.Country)
    self._roleProxy = self:getProxy(GameProxys.Role)
end

function CountryCheckPanel:registerEvents()
	CountryCheckPanel.super.registerEvents(self)
    self._mainPanel = self:getChildByName("mainPanel")
    self._roleInfoPanel = self._mainPanel:getChildByName("roleInfoPanel")


    self._appointBtn    = self._mainPanel:getChildByName("appointBtn")
    self._tipTxt        = self._mainPanel:getChildByName("tipTxt")
    self:addTouchEventListener(self._appointBtn, self.onAppointBtn)
    self._removeBtn     = self._mainPanel:getChildByName("removeBtn")
    self:addTouchEventListener(self._removeBtn, self.onRemoveBtn)

    self._buffListView = self._mainPanel:getChildByName("buffListView")

    self._skillListView = self._mainPanel:getChildByName("skillListView")

end

function CountryCheckPanel:onShowHandler()

end

function CountryCheckPanel:updatePanelView(memberInfo, configInfo, cloneNode)
    self._configInfo = configInfo
    self._cloneNode  = cloneNode

    
    -- 设置角色信息
    self:setRoleInfoPanel(memberInfo, configInfo)

    -- 设置头像
    self:setHeadPanel(memberInfo, configInfo, cloneNode)

    -- 设置增益与技能
    self:setBuffAndSkill(configInfo)

    -- 设置提示文本
    self:setTipTxt(memberInfo, cloneNode)

    -- 设置卸任/出任按钮
    self:setTakeBtn(memberInfo, configInfo, cloneNode)
end


-- 设置角色信息
function CountryCheckPanel:setRoleInfoPanel(memberInfo)
    if memberInfo == nil then
        self._roleInfoPanel:setVisible(false)
        return
    end
    self._roleInfoPanel:setVisible(true)
    local playerName = memberInfo.playerName
    local level      = memberInfo.level
    local vipLevel   = memberInfo.vipLevel
    local capacity   = memberInfo.capacity

    local nameTxt     = self._roleInfoPanel:getChildByName("nameTxt")    
    local levelTxt    = self._roleInfoPanel:getChildByName("levelTxt")   
    local powerTxt    = self._roleInfoPanel:getChildByName("powerTxt")   
    local vipLevelTxt = self._roleInfoPanel:getChildByName("vipLevelTxt")

    nameTxt:setString(playerName)  
    levelTxt:setString( string.format("Lv.%s", level))     
    powerTxt:setString( StringUtils:formatNumberByK3(capacity))     
    vipLevelTxt:setString(vipLevel)  
end


-- 设置头像
function CountryCheckPanel:setHeadPanel(memberInfo, configInfo, cloneNode)

    if cloneNode:getChildByName("headbg") then
        self:setOfficePanel(memberInfo, configInfo, cloneNode)
    else
        self:setRoyalPanel(memberInfo, configInfo, cloneNode)
    end

end

-- 更新t头像
function CountryCheckPanel:updateOfficePanel(memberInfo, cloneNode)
    local headImg = cloneNode:getChildByName("headImg")
    local nameTxt = cloneNode:getChildByName("nameTxt")
    -- 没有则隐藏头像
    if memberInfo == nil then
        headImg:setVisible(false)
        -- 名字设置回去
        nameTxt:setString(self:getTextWord(560007))
        return 
    end

    self:updateHeadImg(headImg, memberInfo.iconId, memberInfo.playerId)

    headImg:setVisible(true)

    
    nameTxt:setString(memberInfo.playerName)

    self:addTouchEventListener(headImg, self.onTouchHeadImg)
end


-- 普通官职头像设置
function CountryCheckPanel:setOfficePanel(memberInfo, configInfo, cloneNode)
    self:removeHeadPanel()


    self._mainPanel:addChild(cloneNode, 5)
    cloneNode:setPosition(64, 422) -- 固定坐标
    cloneNode:setName("officePanel")


    local addBtn  = cloneNode:getChildByName("addBtn")
    local headImg = cloneNode:getChildByName("headImg")
    self:addTouchEventListener(addBtn, self.onTouchAddBtn)

    self:addTouchEventListener(headImg, self.onTouchHeadImg)
end

function CountryCheckPanel:setRoyalPanel(memberInfo, configInfo, cloneNode)
    self:removeHeadPanel()

    self._mainPanel:addChild(cloneNode, 5)
    cloneNode:setPosition(40, 390) -- 固定坐标
    cloneNode:setName("royalPanel")
    cloneNode:setScale(0.9)

    local id = configInfo.ID
    local frameNode = cloneNode:getChildByName("frameNode"..id)
    local headNode  = cloneNode:getChildByName("headNode"..id)
    -- 隐藏同盟
    local img = frameNode:getChildByName("Image_10")
    local txt = frameNode:getChildByName("legionNameTxt")
    img:setVisible(false)
    txt:setVisible(false)


    -- 点击没反应
    self:addTouchEventListener(headNode, self.onHeadNode)
end




-- 设置增益与技能
function CountryCheckPanel:setBuffAndSkill(configInfo)
    local listData = {}
    local positionBuff = StringUtils:jsonDecode(configInfo.positionBuff) 
    for i = 1, #positionBuff do
        local buffId = positionBuff[i]
        local info = {}
        info.infoStr = self:getBuffInfoStr(buffId)

        table.insert(listData, info)
    end
    self:renderListView(self._buffListView, listData, self, self.renderItemTxt)

    -- 技能部分
    local listData01 = {}
    local skill = StringUtils:jsonDecode(configInfo.skill) 
    for i =1, #skill do
        local skillId = skill[i]
        local configInfo = ConfigDataManager:getConfigById(ConfigData.CountrySkillConfig, skillId)
        table.insert(listData01, configInfo)
    end
    self:renderListView(self._skillListView, listData01, self, self.renderSkillItem)
end

function CountryCheckPanel:renderItemTxt(itemTxt, data, index)
    itemTxt:setString(data.infoStr)
end

function CountryCheckPanel:renderSkillItem(itemPanel, data, index)
--    local skillImg = itemPanel:getChildByName("skillImg")
--    local skillId = data.skillId
--    TextureManager:updateImageView(skillImg, string.format("images/countryIcon/skill_%s.png", skillId))
--    skillImg.skillId = skillId
--    self:addTouchEventListener(skillImg, self.onSkillImg)


    local skillImg = itemPanel:getChildByName("skillImg")
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local url = string.format("images/countryIcon/skill_iocn%s.png", data.Icon)
    TextureManager:updateImageView(skillImg, url)
    nameTxt:setString(data.skillName)
    skillImg.data = data

    local skillId = data.ID
    skillImg.skillId = skillId

    self:addTouchEventListener(skillImg, self.onSkillImg)
end

function CountryCheckPanel:onSkillImg(sender)
    self._uiCountrySkillPanel = UICountrySkillPanel.new(self)
    self._uiCountrySkillPanel:updateSkillPanel(sender.skillId, nil, nil)
end

-----
-- 
function CountryCheckPanel:getBuffInfoStr(buffId)
    local configInfo = ConfigDataManager:getConfigById(ConfigData.BuffShowConfig, buffId)
    if configInfo then
        return configInfo.info
    else
        return ""
    end
end


-- 设置提示文本
function CountryCheckPanel:setTipTxt(memberInfo, cloneNode)
    if memberInfo ~= nil then
        self._tipTxt:setVisible(false)
    else
        self._tipTxt:setVisible(true)

        if cloneNode:getChildByName("headbg") then
            self._tipTxt:setString(self:getTextWord(560012)) 
        else
            self._tipTxt:setString(self:getTextWord(560013)) 
        end
    end

end


-- 设置卸任/出任按钮
function CountryCheckPanel:setTakeBtn(memberInfo, configInfo, cloneNode)
    self._removeBtn:setVisible(false)

    -- 有头像有权限，卸任显示
    local headImg = cloneNode:getChildByName("headImg")

    if headImg then
        if headImg:isVisible() and self._powerState then
            self._removeBtn:setVisible(true)
        end
    end

    -- 是否为王位
    if cloneNode:getChildByName("headbg") == nil then
        self._removeBtn:setVisible(false)
    end
end

-- 设置节点的显示问题
function CountryCheckPanel:setAddBtnHeadImgVisible(memberInfo, cloneNode)
    local addBtn  = cloneNode:getChildByName("addBtn")
    if memberInfo then
        addBtn:setVisible(false)
    else
        addBtn:setVisible(true)
    end
end


function CountryCheckPanel:onTouchAddBtn(sender)
    logger:info("点击添加")   
    -- 无权限
    if self._powerState == false then
        self:showSysMessage(self:getTextWord(560008))
        return
    end
    self._uiFindPlayerPanel = UIFindPlayerPanel.new(self, self.getApointInfo)
    self._uiFindPlayerPanel:setHoldTxt(self:getTextWord(560016)) -- "请输入要册封的玩家名称"
    self._uiFindPlayerPanel:setListHandler(self.getLegionMemberHandler)
    self._uiFindPlayerPanel:setLegionBtnVisible(true)
    self._isFindVisible = true
end

-- 点击进行任命官职操作
function CountryCheckPanel:getApointInfo(nameStr)
    logger:info("点击任命")

    local function callback()
        local data = {}
        data.playerName = nameStr              -- 玩家名字	
        data.positionId = self._configInfo.ID  -- 职位ID
        self._countryProxy:onTriggerNet562001Req(data)
    end

    local cdStr = TimeUtils:getStandardFormatTimeString8(self._configInfo.appointCD)
    local content = string.format(self:getTextWord(560038), nameStr, self._configInfo.name, cdStr)
    self:showMessageBox(content, callback)
end

function CountryCheckPanel:onTouchHeadImg()
    logger:info("点击头像无反应")
end


-- 点击获取同盟列表
function CountryCheckPanel:getLegionMemberHandler()
    logger:info("点击获取同盟列表")
    -- 点击获取同盟列表
    self._countryProxy:onTriggerNet560003Req({})

end


-- 任职成功后的Resp/卸任成功后的Resp
function CountryCheckPanel:onAppointSucceedResp()
    -- 回调刷新界面并关闭弹窗
    local memberInfo = self._countryProxy:getCurAppointInfo()

    -- 设置角色信息
    self:setRoleInfoPanel(memberInfo, self._configInfo)

    -- 设置头像
    self:updateOfficePanel(memberInfo,  self._cloneNode)

    -- 设置提示文本
    self:setTipTxt(memberInfo, self._cloneNode)

    -- 设置卸任/出任按钮
    self:setTakeBtn(memberInfo, self._configInfo, self._cloneNode)

    -- 设置节点的显示问题
    self:setAddBtnHeadImgVisible(memberInfo, self._cloneNode)

    -- 任职成功，关闭寻找窗口
    if self._isFindVisible then
        self._uiFindPlayerPanel:finalize()
        self._isFindVisible = false
    end
end

-- 560003resp
-- 打开同盟成员信息界面
function CountryCheckPanel:onNewChooseLegionMember()
    -- 传递数据
    self._legionMemberPanel = UIChooseLegionMember.new(self, self.chosenCallback)

    local listData = self._countryProxy:getMemberInfoList()
    self._legionMemberPanel:setMemberListView(listData)
end

-- 选择成员回调
function CountryCheckPanel:chosenCallback(index)
    -- 取到名字
    local listData = self._countryProxy:getMemberInfoList()

    if self._uiFindPlayerPanel then
        self._uiFindPlayerPanel:setEditText( listData[index].playerName)
    end

    if self._legionMemberPanel then
        self._legionMemberPanel:hide()
    end
end


------
-- 点击确定
function CountryCheckPanel:onAppointBtn(sender)
    self:hide()
end

------
-- 点击卸任
function CountryCheckPanel:onRemoveBtn(sender)
    logger:info("点击卸任")   

    if self._powerState == false then
        self:showSysMessage(self:getTextWord(560008))
        return
    end

    -- 确定进行卸任
    local function callback()
        local data = {}
        data.positionId = self._configInfo.ID
        self._countryProxy:onTriggerNet563003Req(data)
    end

    local name = self._roleInfoPanel:getChildByName("nameTxt"):getString()
    local content = string.format(self:getTextWord(560037), name, self._configInfo.name)
    self:showMessageBox(content, callback)
end

-- 操作权限
function CountryCheckPanel:setPowerState(powerState)
    self._powerState = powerState
end


-- 皇帝与王族头像点击响应函数
function CountryCheckPanel:onHeadNode()

end


function CountryCheckPanel:removeHeadPanel()
    local officePanel = self._mainPanel:getChildByName("officePanel")
    if officePanel then
        officePanel:removeFromParent()
    end
    local royalPanel = self._mainPanel:getChildByName("royalPanel")
    if royalPanel then
        royalPanel:removeFromParent()
    end
end


------
-- 添加头像
function CountryCheckPanel:updateHeadImg(headImg, iconId, playerId)
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

-- 关闭发送
function CountryCheckPanel:onHideHandler()
    self._countryProxy:onTriggerNet560001Req({})
    self._isFindVisible = false
end


