-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CountryPrisonCheckPanel = class("CountryPrisonCheckPanel", BasicPanel)
CountryPrisonCheckPanel.NAME = "CountryPrisonCheckPanel"

function CountryPrisonCheckPanel:ctor(view, panelName)
    CountryPrisonCheckPanel.super.ctor(self, view, panelName, 500)

end

function CountryPrisonCheckPanel:finalize()
    CountryPrisonCheckPanel.super.finalize(self)

    if self._leftBtnEffect ~= nil then
        self._leftBtnEffect:finalize()
        self._leftBtnEffect = nil
    end
    if self._rightBtnEffect ~= nil then
        self._rightBtnEffect:finalize()
        self._rightBtnEffect = nil
    end
end

function CountryPrisonCheckPanel:initPanel()
	CountryPrisonCheckPanel.super.initPanel(self)

    self:setTitle(true, self:getTextWord(560021)) -- "通缉"
    self._countryProxy = self:getProxy(GameProxys.Country)
    self._roleProxy = self:getProxy(GameProxys.Role)
end

function CountryPrisonCheckPanel:registerEvents()
	CountryPrisonCheckPanel.super.registerEvents(self)
    self._mainPanel = self:getChildByName("mainPanel")
    self._roleInfoPanel = self._mainPanel:getChildByName("roleInfoPanel")
    self._tipTxt        = self._mainPanel:getChildByName("tipTxt")
    self._removeBtn     = self._mainPanel:getChildByName("removeBtn")
    self:addTouchEventListener(self._removeBtn, self.onRemoveBtn)

    self._debuffImg = self._mainPanel:getChildByName("debuffImg")

    self._listView = self._mainPanel:getChildByName("listView")

    self._leftBtn  = self._mainPanel:getChildByName("leftBtn")
    self._rightBtn = self._mainPanel:getChildByName("rightBtn")
    -- 添加按钮特效
    self:initSideBtn()
    
end

-- 左右按钮
function CountryPrisonCheckPanel:initSideBtn()
    if self._leftBtnEffect == nil then
        self._leftBtnEffect = self:createUICCBLayer("rgb-fanye", self._leftBtn)
        local size = self._leftBtn:getContentSize()
        self._leftBtnEffect:setPosition(size.width/2, size.height/2 + 15)
    end
    if self._rightBtnEffect == nil then
        self._rightBtnEffect = self:createUICCBLayer("rgb-fanye", self._rightBtn)
        local size = self._rightBtn:getContentSize()
        self._rightBtnEffect:setPosition(size.width/2, size.height/2 - 15)
    end
end


function CountryPrisonCheckPanel:onShowHandler()

end

function CountryPrisonCheckPanel:updatePanelView(prisonInfo, configInfo, cloneNode)
    self._configInfo = configInfo
    self._cloneNode  = cloneNode

    -- 传递memberInfo
    local memberInfo = nil 
    if prisonInfo then
        memberInfo = prisonInfo.info
    end

    -- 设置角色信息
    self:setRoleInfoPanel(memberInfo, configInfo)

    -- 设置头像
    self:setHeadPanel(cloneNode)

    -- 设置撤销按钮
    self:setTakeBtn(memberInfo)

    -- 通缉次数
    self:setRemainWantedTimes()

    -- 设置右侧减益效果
    self:setDebuffShow(prisonInfo)

    -- 设置技能显示listView
    self:setSkillListView()
end

-- 设置角色信息
function CountryPrisonCheckPanel:setRoleInfoPanel(memberInfo)
    if memberInfo == nil then
        self._roleInfoPanel:setVisible(false)
        -- 设置提示文本
        self._tipTxt:setVisible(true)
        self._tipTxt:setString(self:getTextWord(560019)) -- "无人被通缉"
        return
    end
    self._roleInfoPanel:setVisible(true)
    self._tipTxt:setVisible(false)
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
function CountryPrisonCheckPanel:setHeadPanel(cloneNode)
    self:removeHeadPanel()
    self._mainPanel:addChild(cloneNode, 5)
    cloneNode:setPosition(64, 418) -- 固定坐标
    cloneNode:setName("prisonItemPanel")

    
    local addBtn  = cloneNode:getChildByName("addBtn")
    local headImg = cloneNode:getChildByName("headImg")
    self:addTouchEventListener(addBtn, self.onTouchAddBtn)
    self:addTouchEventListener(headImg, self.onTouchHeadImg)
end

function CountryPrisonCheckPanel:onTouchHeadImg()
    logger:info("点击头像无反应")
end


function CountryPrisonCheckPanel:removeHeadPanel()
    local prisonItemPanel = self._mainPanel:getChildByName("prisonItemPanel")
    if prisonItemPanel then
        prisonItemPanel:removeFromParent()
    end
end


-- 设置撤销按钮
function CountryPrisonCheckPanel:setTakeBtn(memberInfo)
    self._removeBtn:setVisible(self._removeState and memberInfo ~= nil )

end


-- 通缉次数
function CountryPrisonCheckPanel:setRemainWantedTimes()
    local remainTimesTxt = self._mainPanel:getChildByName("remainTimesTxt")
    local myPositionId = self._countryProxy:getMyPositionId(self._roleProxy:getRoleName())
    if myPositionId == 0 then
        remainTimesTxt:setString("")
        return 
    end
    -- 最大次数
    local maxTimes = ConfigDataManager:getConfigById(ConfigData.CountryPositionConfig, myPositionId).wantedLimit
    if maxTimes == 0 then
        remainTimesTxt:setString("")
        return 
    end

    local remainWantedTimes = self._countryProxy:getRemainWantedTimes() -- 剩余通缉次数
    local str = string.format(self:getTextWord(560041), maxTimes - remainWantedTimes, maxTimes)
    remainTimesTxt:setString(str)
end


------
-- 点击撤销通缉，是否停留在当前界面
function CountryPrisonCheckPanel:onRemoveBtn(sender)
    logger:info("点击卸任")   
    local name = self._cloneNode:getChildByName("nameTxt"):getString()
    local data = {}
    data.positionId = self._configInfo.ID -- 职位ID
    self._countryProxy:onTriggerNet563002Req(data)
end


function CountryPrisonCheckPanel:onTouchAddBtn(sender)
    logger:info("点击添加")   

    -- 无权限
    if self._powerState == false then
        self:showSysMessage(self:getTextWord(560008))
         return
    end

    self._uiFindPlayerPanel = UIFindPlayerPanel.new(self, self.getWantedInfo)
    self._uiFindPlayerPanel:setHoldTxt(self:getTextWord(560020)) -- "请输入要通缉的玩家名称"
    self._uiFindPlayerPanel:setLegionBtnVisible(false)
    self._uiFindPlayerPanel:setCloseCallback(self.findCloseCallback)
    self._isFindVisible = true
end


function CountryPrisonCheckPanel:getWantedInfo(nameStr)
    logger:info("确定返回, 名字：".. nameStr)
    local data = {}
    data.playerName = nameStr              --  玩家名字
    data.positionId = self._configInfo.ID  --  通缉ID
    self._countryProxy:onTriggerNet563001Req(data)
end

function CountryPrisonCheckPanel:findCloseCallback()
    self._isFindVisible = false
end

-- 设置右侧减益效果
function CountryPrisonCheckPanel:setDebuffShow(prisonInfo)
    -- 判空
    local buffInfos = {}
    --=====
--    local testInfo = {}
--    testInfo.skillId     = 3
--    testInfo.remainTime = 10000
--    table.insert(buffInfos, testInfo)
    --=====

    if prisonInfo then
        buffInfos = prisonInfo.buffInfos -- 生效的技能信息
    end

    -- 总共6个位置
    for i = 1, 6 do
        local skillPanel = self._debuffImg:getChildByName("skillPanel"..i)
        
        if buffInfos[i] == nil then
            skillPanel:setVisible(false)
        else
            skillPanel:setVisible(true)
            local iconImg    = skillPanel:getChildByName("iconImg")
            local nameTxt    = skillPanel:getChildByName("nameTxt")
            local memoTxt    = skillPanel:getChildByName("memoTxt")
            local showSkillBtn = skillPanel:getChildByName("showSkillBtn")

            local skillId = buffInfos[i].skillId         -- 生效的技能ID
            local remainTime = buffInfos[i].remainTime -- 生效剩余时间
            -- 设置显示
            local skillUrl = string.format("images/countryIcon/skill_%d.png", skillId)
            TextureManager:updateImageView(iconImg, skillUrl)
            local configInfo = ConfigDataManager:getConfigById(ConfigData.CountrySkillConfig, skillId)
            local skillName = configInfo.skillName -- 技能名称
            nameTxt:setString(skillName)
            memoTxt:setString(TimeUtils:getStandardFormatTimeString8(remainTime))
            -- local description = configInfo.description -- 描述
            -- local hours = math.ceil(remainTime/3600)
            -- memoTxt:setString( string.format(description, hours))
            showSkillBtn.skillId = skillId
            self:addTouchEventListener(showSkillBtn, self.onShowSkillBtn)
        end
    end
end

-- 设置技能列表显示listView
function CountryPrisonCheckPanel:setSkillListView()
    -- 权限控制显示

    local listData = ConfigDataManager:getConfigData(ConfigData.CountrySkillConfig)

    self:renderListView(self._listView, listData, self, self.renderItem, nil, true,0)
end

function CountryPrisonCheckPanel:renderItem(itemPanel, data, index)
    local skillImg = itemPanel:getChildByName("skillImg")
    local nameTxt = itemPanel:getChildByName("nameTxt")
    
    local url = string.format("images/countryIcon/skill_iocn%s.png", data.Icon)
    TextureManager:updateImageView(skillImg, url)

    nameTxt:setString(data.skillName)

    skillImg.data = data

    local skillId = data.ID
    skillImg.skillId = skillId


    -- 判断使用技能权限
    local powerState = false -- 可操作权限标识
    local powerList = self._countryProxy:getMyPowerStateList(self._roleProxy:getRoleName(), "skill")
    for i, typeInfo in pairs(powerList) do
        if typeInfo == skillId then
            powerState = true
            break
        end
    end

    if powerState then
        self:addTouchEventListener(skillImg, self.onTouchSkillImg)
    else
        self:addTouchEventListener(skillImg, self.onTouchSkillImgNoPower)
    end
end

function CountryPrisonCheckPanel:onTouchSkillImg(sender)
    local configInfo = sender.data
    logger:info("点击技能："..configInfo.skillName)

    local data = {}
    data.skillId = configInfo.ID
    self._countryProxy:onTriggerNet560005Req(data)
end

function CountryPrisonCheckPanel:onTouchSkillImgNoPower(sender)
    self._uiCountrySkillPanel = UICountrySkillPanel.new(self)
    self._uiCountrySkillPanel:updateSkillPanel(sender.skillId, nil, nil)
end



function CountryPrisonCheckPanel:onOpenUseSkillBox()
    local skillInfo = self._countryProxy:getCurUseSkillInfo()
    local remainTimes = skillInfo.remainTimes -- 次数s
    local skillId     = skillInfo.skillId
    local cdTime      = skillInfo.cdTime -- 技能冷却时间

    self._uiCountrySkillPanel = UICountrySkillPanel.new(self, self.useSkillCallback)
    self._uiCountrySkillPanel:updateSkillPanel(skillId, nil, remainTimes, cdTime)
    -- 技能按键
    self._uiCountrySkillPanel:setUseBtnEnable(not self._tipTxt:isVisible())
end

-- 使用技能
function CountryPrisonCheckPanel:useSkillCallback(skillId)
    -- 判断使用技能权限
    local powerState = false -- 可操作权限标识
    local powerList = self._countryProxy:getMyPowerStateList(self._roleProxy:getRoleName(), "skill")
    for i, typeInfo in pairs(powerList) do
        if typeInfo == skillId then
            powerState = true
            break
        end
    end

    -- 无技能使用权限
    if powerState == false then
        self:showSysMessage(self:getTextWord(560031))
        return 
    end


    local data = {}
    data.positionId = self._configInfo.ID
    data.skillId    = skillId
    
    -- 流放单独处理
    local configInfo = ConfigDataManager:getConfigById(ConfigData.CountrySkillConfig, skillId)
    if configInfo.skillName == self:getTextWord(560033) then
        self._countryProxy:onTriggerNet563005Req(data) -- 使用流放
    else
        self._countryProxy:onTriggerNet563004Req(data) -- 使用技能
    end

    if self._uiCountrySkillPanel then
        self._uiCountrySkillPanel:hide()
    end
end

function CountryPrisonCheckPanel:onUsedSkillResp()
    local prisonInfo = self._countryProxy:getPosPrisonInfoById(self._configInfo.ID)
    -- 设置右侧减益效果
    self:setDebuffShow(prisonInfo)
end


-- 打开使用技能的messageBox
--function CountryPrisonCheckPanel:onOpenUseSkillBox()
--    local skillInfo = self._countryProxy:getCurUseSkillInfo()
--    local remainTimes = skillInfo.remainTimes
--    local skillId     = skillInfo.skillId
--    local configInfo = ConfigDataManager:getConfigById(ConfigData.CountrySkillConfig, skillId)
--    local skillName = configInfo.skillName
--    local description = configInfo.description

--    -- 确定使用技能
--    local function callback()
--        if remainTimes == 0 then
--            -- 提示次数不足
--            self:showSysMessage(self:getTextWord(560027)) -- "技能使用次数不足"
--            return 
--        end

--        local data = {}
--        data.positionId = self._configInfo.ID
--        data.skillId    = skillId
--        self._countryProxy:onTriggerNet563004Req(data) -- 使用技能
--    end


--    local data = {}
--    data.content = string.format(self:getTextWord(560026), skillName)
--    data.tip = description
--    data.num = string.format(TextWords:getTextWord(540017), remainTimes)

--    self:showMessageBox(data, callback)
--end





-- 563001Resp/563002Resp
function CountryPrisonCheckPanel:onWantedSucceedResp()
    local memberInfo = self._countryProxy:getCurWantedInfo()
    -- 设置角色信息
    self:setRoleInfoPanel(memberInfo, self._configInfo)

    -- 设置头像
    self:updateHeadPanel(memberInfo, self._cloneNode)

    -- 设置撤销按钮
    self:setTakeBtn(memberInfo)

    -- 设置右侧减益效果
    self:setDebuffShow(self._countryProxy:getPosPrisonInfoById(self._configInfo.ID))

    -- 通缉次数
    self:setRemainWantedTimes()

    -- 设置节点的显示问题
    self:setAddBtnHeadImgVisible(memberInfo, self._cloneNode)

    if self._isFindVisible then
        self._uiFindPlayerPanel:finalize()
        self._isFindVisible = false
    end
end



-- 回调设置头像
function CountryPrisonCheckPanel:updateHeadPanel(memberInfo, cloneNode)
    local headImg = cloneNode:getChildByName("headImg")
    local nameTxt = cloneNode:getChildByName("nameTxt")
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

-- 设置节点的显示问题
function CountryPrisonCheckPanel:setAddBtnHeadImgVisible(memberInfo, cloneNode)
    local addBtn  = cloneNode:getChildByName("addBtn")
    if memberInfo then
        addBtn:setVisible(false)
    else
        addBtn:setVisible(true)
    end
end

------
-- 添加头像
function CountryPrisonCheckPanel:updateHeadImg(headImg, iconId, playerId)
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


-- 是否有通缉权限
function CountryPrisonCheckPanel:setPowerState(powerState)
    self._powerState = powerState
end

-- 是否有撤销通缉权限
function CountryPrisonCheckPanel:setRemoveState(removeState)
    self._removeState = removeState
end


-- 点击查看技能详情
function CountryPrisonCheckPanel:onShowSkillBtn(sender)
    logger:info("技能详情")

    local remainTime = sender:getParent():getChildByName("memoTxt"):getString()

    self._uiCountrySkillPanel = UICountrySkillPanel.new(self)

    self._uiCountrySkillPanel:updateSkillPanel(sender.skillId, remainTime, nil)
end

------
-- 关闭发送
function CountryPrisonCheckPanel:onHideHandler()
    self._countryProxy:onTriggerNet560002Req({})
    self._isFindVisible = false
end


