-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-12-03 15:03:00
--  * @Description: 世界地图查看玩家的弹窗
--  */

UIWatchWorldPlayerInfo = class("UIWatchWorldPlayerInfo")

--isMap  从map模块调用进来，要特殊处理
function UIWatchWorldPlayerInfo:ctor(panel)
    self._uiSkin = UISkin.new("UIWatchWorldPlayerInfo")
    self._uiSkin:setParent(panel)
    self._panel = panel

    self._btnListview = self._uiSkin:getChildByName("basePanel/tabPanel/btnListview")  --标签
    self._infoPanel = self._uiSkin:getChildByName("basePanel/infoPanel")
    self._btnPanel1 = self._uiSkin:getChildByName("basePanel/btnPanel1")
    self._btnPanel2 = self._uiSkin:getChildByName("basePanel/btnPanel2")
    self._btnPanel3 = self._uiSkin:getChildByName("basePanel/btnPanel3")
    self._btnPanel1:setVisible(false)
    self._btnPanel2:setVisible(false)
    self._btnPanel3:setVisible(false)

    self._selectIndex = 0  --当前选中的按钮标签
    self._btnMap = {}
    self._data = {}
    self.isFromWorldMap = false  
    self.isMyCity = false  --是否查看了自己
    self.isCan = false  --是否有查看技能标签页的权限

    self:registerEvents()

end

function UIWatchWorldPlayerInfo:finalize()
    if self._uiSharePanel ~= nil then
       self._uiSharePanel:finalize()
       self._uiSharePanel = nil
    end
    UIWatchWorldPlayerInfo.super.finalize(self)
end

function UIWatchWorldPlayerInfo:updateTabPanel(data)
    -- 标签按钮数据
    local btnInfos = {}
    btnInfos[1] = {ID = 1, name = TextWords[291001]}
    btnInfos[2] = {ID = 2, name = TextWords[291002]}

    ComponentUtils:renderListView(self._btnListview, btnInfos, self, self.renderBtn)

    self:updateBtnPanelByIndex(self._selectIndex)
end

-- 渲染标签按钮
function UIWatchWorldPlayerInfo:renderBtn(btn, info, index)
    if btn == nil or info == nil then
        return
    end

    btn.info = info
    btn.index = index

    local tabName = btn:getChildByName("tabName")
    tabName:setString(info.name)

    self:updateBtnImg(btn,self._selectIndex)

    if btn.eventTrue == nil then
        btn.eventTrue = true
        ComponentUtils:addTouchEventListener(btn, self.onBtnTouch, nil , self)
    end

    self._btnMap[index] = btn
end

-- 更新标签按钮图片
function UIWatchWorldPlayerInfo:updateBtnImg(btn,index)
    if btn and index then
        local color = ColorUtils.wordYellowColor02
        local url = "images/newGui2/BtnTab_normal.png"
        if index == btn.index then
            url = "images/newGui2/BtnTab_selected.png"
            color = ColorUtils.wordNameColor
        end
        TextureManager:updateImageView(btn, url)

        local tabName = btn:getChildByName("tabName")
        tabName:setColor(color)

    end
end

-- 点击标签按钮
function UIWatchWorldPlayerInfo:onBtnTouch(sender)
    logger:info("点击标签按钮: %d %s",sender.index,sender.info.name)

    -- if self.isCan == false then
    --     self._panel:showSysMessage(TextWords[370102])
    --     return
    -- end

    local index = sender.index
    if self._selectIndex == index then -- 重复选中
        logger:info("重复选中 %d",index)
        return
    else        
        if self._btnMap[index] then
            -- 显示选中
            logger:info("-- 显示选中 %d",index)
            self:updateBtnImg(self._btnMap[index], index)
            self:updateBtnPanelByIndex(index)
        end

        if self._btnMap[self._selectIndex] then
            -- 显示未选中
            logger:info("-- 显示未选中 %d",self._selectIndex)
            self:updateBtnImg(self._btnMap[self._selectIndex], index)
            self._selectIndex = index

        end

        --TODO 然后 请求标签页数据
    end
end

function UIWatchWorldPlayerInfo:updateBtnPanelByIndex(index)
    if index == 1 then  --技能标签
        self._btnPanel1:setVisible(false)
        self._btnPanel2:setVisible(false)
        self._btnPanel3:setVisible(true)
        self:updateBtnPanel3()
        return
    end

    if index ~= 1 then
        self._btnPanel1:setVisible(self.isMyCity)
        self._btnPanel2:setVisible(not self.isMyCity)
        self._btnPanel3:setVisible(false)
        return
    end
end

-- 刷新技能列表
function UIWatchWorldPlayerInfo:useSkillResp()
    local str = string.format(TextWords[291011],self._name,self._skillName)
    self._panel:showSysMessage(str)

    self:updateBtnPanel3()
end

function UIWatchWorldPlayerInfo:updateBtnPanel3(infos)
    local lordCityProxy = self._panel:getProxy(GameProxys.LordCity)
    local skillInfos = lordCityProxy:getSkillInfos()

    local listView = self._btnPanel3:getChildByName("listView")
    ComponentUtils:renderListView(listView, skillInfos, self, self.renderItem)

    -- 没有技能，则显示提示语
    local infoTxt = self._btnPanel3:getChildByName("infoTxt")
    if table.size(skillInfos) == 0 then
        infoTxt:setString(TextWords[370102])
    else
        infoTxt:setString("")
    end
end

function UIWatchWorldPlayerInfo:renderItem(itemPanel, data, index)
    if itemPanel == nil or data == nil then
        return
    end

    local config = ConfigDataManager:getConfigById(ConfigData.CityBattleSkillConfig, data.typeId)
    if config == nil then
        logger:error("城主战技能读取不到配表数据")
        return
    end
    local lessNum = data.leesNum

    local iconImg = itemPanel:getChildByName("iconImg")
    local iconName = itemPanel:getChildByName("iconName")
    local useBtn = itemPanel:getChildByName("useBtn")
    iconName:setVisible(false)


    -- 技能图标
    local info = {}
    info.num = lessNum
    info.power = GamePowerConfig.CitySkill
    info.typeid = config.icon
    info.name = config.name
    info.dec = config.describe
    info.customTipNum = string.format(TextWords[291006],lessNum)
    
    local iconUI = iconImg.iconUI
    if iconUI == nil then
        iconUI = UIIcon.new(iconImg, info, true, self._panel, nil, true)
        iconImg.iconUI = iconUI
        iconUI:setNameFontSize(18)
    end
    iconUI:updateData(info)

    -- 使用技能按钮
    data.playerId = self._playerId
    data.config = config
    useBtn.data = data   

    NodeUtils:setEnable(useBtn,false)
    if lessNum > 0 then
        NodeUtils:setEnable(useBtn,true)
    end

    ComponentUtils:addTouchEventListener(useBtn, self.onUseBtnTouch, nil , self)

end

-- 使用技能按钮
function UIWatchWorldPlayerInfo:onUseBtnTouch(sender)
    --不能对自己使用
    if self.isMyCity == true then
        self._panel:showSysMessage(TextWords[291008])
        return
    end
    --次数不足
    local lessNum = sender.data.leesNum
    if lessNum == 0 then
        self._panel:showSysMessage(TextWords[291009])
        return
    end

    self._skillName = sender.data.config.name
    self._panel:useBtnCallback(sender.data)
end


function UIWatchWorldPlayerInfo:showAllInfo( data )
    self._uiSkin:setVisible(true)

    self._nameTxt = self._infoPanel:getChildByName("nameTxt")
    self._vipImg = self._infoPanel:getChildByName("vipImg")
    self._vipLab = self._infoPanel:getChildByName("vipLab")
    self._lvTxt = self._infoPanel:getChildByName("levelTxt")
    self._powerTxt = self._infoPanel:getChildByName("powerTxt")
    self._solidierTxt = self._infoPanel:getChildByName("solidierTxt")
    self._coordTxt = self._infoPanel:getChildByName("coordTxt")
    self._bgImg = self._infoPanel:getChildByName("bgImg")
    self._iconImg = self._infoPanel:getChildByName("iconImg")

    local ProgressBarBg = self._infoPanel:getChildByName("ProgressBarBg")
    self._ProgressBar = ProgressBarBg:getChildByName("ProgressBar")
    self._loadingNumBar = self._infoPanel:getChildByName("loadingNumBar")

    local power = self._infoPanel:getChildByName("label_power")
    local solidier = self._infoPanel:getChildByName("label_solidier")
    local coord = self._infoPanel:getChildByName("label_coord")
    power:setString(TextWords:getTextWord(136))
    solidier:setString(TextWords:getTextWord(137))
    coord:setString(TextWords:getTextWord(138))
    
    

    self._data = data
    self.isFromWorldMap = false
    self.isMyCity = false
    self.isCan = false
    self._selectIndex = 0  --当前选中的按钮标签

    local tileInfo = rawget(data, "tileInfo")
    self:showInfo(data.info, tileInfo)

    self:updateTabPanel(data)

end

function UIWatchWorldPlayerInfo:setLocalZOrder(order)
    self._uiSkin:setLocalZOrder(order)
end

function UIWatchWorldPlayerInfo:isMyCity()
    return self.isMyCity
end

function UIWatchWorldPlayerInfo:showInfo(data, tileInfo)
    self._tileInfo = tileInfo
    self._playerId = data.playerId
    self._name = data.name

    -- 玩家基地
    local myNumIcon = data.cityIcon
    local url = ComponentUtils:getWorldBuildingUrl(myNumIcon)
    TextureManager:updateImageView(self._iconImg,url)
    -- _iconImg:setScale(1.25) --屏蔽

    
    self._nameTxt:setString(data.name)
    self._lvTxt:setString(data.level)

    self._vipLab:setVisible(data.vipLv ~= 0 and data.vipLv ~= nil)
    self._vipImg:setVisible(data.vipLv ~= 0 and data.vipLv ~= nil)
    self._vipLab:setString(data.vipLv)
    self._vipImg:setPositionX(self._nameTxt:getPositionX()+self._nameTxt:getContentSize().width+10)
    self._vipLab:setPositionX(self._vipImg:getPositionX()+self._vipImg:getContentSize().width)

    self._powerTxt:setString(StringUtils:formatNumberByK3(data.capacity, nil))
    self._solidierTxt:setString(data.legion)

    -- 繁荣
    self._loadingNumBar:setString(data.boom.."/"..data.boomUpLimit)
    local per = 0
    if data.boom >= data.boomUpLimit then
        per = 100
    else
        per = data.boom/data.boomUpLimit * 100
    end
    self._ProgressBar:setPercent(per)


    -- 世界地图
    self.isFromWorldMap = true
    self._coordTxt:setString("(" .. tileInfo.buildingInfo.x .. "/" .. tileInfo.buildingInfo.y ..")")
    local roleProxy = self._panel:getProxy(GameProxys.Role)
    local worldTileX, worldTileY = roleProxy:getWorldTilePos()
    
    local isHaveLegion = roleProxy:hasLegion()

    -- if isHaveLegion then
    --     local legionProxy = self._panel:getProxy(GameProxys.Legion)
    --     local myJob = legionProxy:getMineJob()
    --     if myJob == 7 then --玩家自己是盟主
    --         self.isCan = true
    --     end
    -- end

    if worldTileX == tileInfo.buildingInfo.x and worldTileY == tileInfo.buildingInfo.y then
        --在世界地图查看自己
        self.isMyCity = true
        self._btnPanel1:setVisible(true)
        self._btnPanel2:setVisible(false)
        NodeUtils:setEnable(self._legionBtn, isHaveLegion == true)        
    else
        -- 在世界地图查看别人
        self.isMyCity = false
        self._btnPanel1:setVisible(false)
        self._btnPanel2:setVisible(true)

        if isHaveLegion then
            local isSameLegion = false
            local myLegionName = roleProxy:getLegionName()
            if myLegionName ~= nil and data.legion ~= nil and myLegionName == data.legion then
                isSameLegion = true
            end
            if isSameLegion then  
                self.isAttack = false
                self._attackBtn:setTitleText(TextWords:getTextWord(111))--驻军
            else  
                self.isAttack = true
                self._attackBtn:setTitleText(TextWords:getTextWord(732))--攻击
            end
        else
            self.isAttack = true
            self._attackBtn:setTitleText(TextWords:getTextWord(732))--攻击
        end
    end
    
    -- 加好友按钮显示
    local friendProxy = self._panel:getProxy(GameProxys.Friend)
    local isFriend = friendProxy:isFriend(data.playerId)
    if isFriend == true then
        self._addFriendBtn:setTitleText(TextWords:getTextWord(1109)) --删好友
    else
        self._addFriendBtn:setTitleText(TextWords:getTextWord(1105)) --加好友
    end
    self._addFriendBtn.isFriend = isFriend
    
end
function UIWatchWorldPlayerInfo:registerEvents()
    self._addFriendBtn = self._btnPanel2:getChildByName("addFriendBtn")
    self._writeBtn = self._btnPanel2:getChildByName("writeBtn")
    self._privateChatBtn = self._btnPanel2:getChildByName("privateChatBtn") 
    self._collectBtn = self._btnPanel2:getChildByName("collectBtn") 
    self._spyBtn = self._btnPanel2:getChildByName("spyBtn") 
    self._attackBtn = self._btnPanel2:getChildByName("attackBtn") 

    self._sceneBtn = self._btnPanel1:getChildByName("sceneBtn")
    self._legionBtn = self._btnPanel1:getChildByName("legionBtn") 

    ComponentUtils:addTouchEventListener(self._addFriendBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._writeBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._privateChatBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._collectBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._spyBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._attackBtn, self.onClickEvents, nil , self)

    ComponentUtils:addTouchEventListener(self._legionBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._sceneBtn, self.onClickEvents, nil , self)

    local shareBtn = self._infoPanel:getChildByName("shareBtn")
    ComponentUtils:addTouchEventListener(shareBtn, self.onShare, nil ,self)

end
function UIWatchWorldPlayerInfo:onAddFriendResp(isFriend)
    local friendProxy = self._panel:getProxy(GameProxys.Friend)
    
    if isFriend == true then --是好友，则请求删除好友
        friendProxy:removeFriendReq(self._playerId)
    else
        friendProxy:addFriendReq(self._playerId)
    end
end

-- 消息发送，type//0:邮件，1：聊天
function UIWatchWorldPlayerInfo:onShieldResp()
    local chatProxy = self._panel:getProxy(GameProxys.Chat)
    if self._mailShield ~= nil then
        chatProxy:onShieldPlayerReq(0,self._playerId)
        self._mailShield = nil
    else
        chatProxy:onShieldPlayerReq(1,self._playerId)
    end
end

function UIWatchWorldPlayerInfo:setMialShield(mailShield)
    self._mailShield = mailShield
end

function UIWatchWorldPlayerInfo:onClickEvents( sender )
    if sender == self._addFriendBtn then    --添加或删除好友
        self:onAddFriendResp(self._addFriendBtn.isFriend)
    elseif sender == self._privateChatBtn then--私聊
        local isFromRank = self._isRank
        self._mailShield = nil
        local data = self._data
        local chatProxy = self._panel:getProxy(GameProxys.Chat)
        data.index = 0
        data.isFromWorldMap = self.isFromWorldMap
        if isFromRank == nil or isFromRank == false then
            data.isFromRank = false
        else
            data.isFromRank = true
        end
        chatProxy:enterPrivate(data)
    elseif sender ==  self._writeBtn then   --写信
        local roleProxy = self._panel:getProxy(GameProxys.Role)
        local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        if lv < GlobalConfig.chatMinLv then
            roleProxy:showSysMessage(string.format(TextWords:getTextWord(1238), GlobalConfig.chatMinLv))
            return
        end

        local nameContext = self._data.info.name
        local data = {}
        if self._mailShield == true then --已经在邮件模块里面
            data.name = nameContext
            data.type = "writeMail"
        else   
            data["moduleName"] = ModuleName.MailModule
            data["extraMsg"] = {}
            data["extraMsg"]["type"] = "writeMail"
            data["extraMsg"]["isCloseModule"] = true
            data["extraMsg"]["name"] = nameContext --你要写给对方的名字
        end
        self._mailShield = nil
        local chatProxy = self._panel:getProxy(GameProxys.Chat)
        chatProxy:enterWriteMsg(data)
    elseif sender == self._collectBtn then  --收藏
        if self._tileInfo ~= nil then
            self._tileInfo.playerInfo = self._data.info --玩家信息
            self._panel:onPlayerCollectTouch(self._tileInfo)
        end
    elseif sender == self._attackBtn then  --攻击
        if self.isAttack then
            self._panel:onAttackPlayerTouch(self._tileInfo)
        else
            self._panel:onGoStationTouch(self._tileInfo)
        end
        
    elseif sender == self._spyBtn then --侦查
        self._panel:onSpyPriceTouch(self._tileInfo)
    elseif sender == self._sceneBtn then --回到场景
        self._panel:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.MainSceneModule})
    elseif sender == self._legionBtn then --进入军团基地
        self._panel:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.LegionSceneModule})
    end

    self._uiSkin:setVisible(false)
    self._mailShield = nil

    if self._uiSharePanel ~= nil then
        if self._uiSharePanel:isVisible() == true then
            self._uiSharePanel:hidePanel()
        end
    end
    self:onClosePanelHandler()
end

-- function UIWatchWorldPlayerInfo:hide()
--     if self._uiSkin == nil then
--         return
--     end
--     if self._uiSkin.root ~= nil and tolua.isnull(self._uiSkin.root) then
--         return
--     end
--     if self._uiSharePanel ~= nil then
--         self._uiSharePanel:hidePanel()
--     end
--     if self._uiSkin:isVisible() then
--         self._uiSkin:setVisible(false)
--     end
-- end

function UIWatchWorldPlayerInfo:onClosePanelHandler()
    self._panel:hide()
end

function UIWatchWorldPlayerInfo:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UIWatchWorldPlayerInfo:onShare(sender)
    if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new(sender, self._panel)
    end
    local tileInfo = self._tileInfo
    local data = {}
    data.type = ChatShareType.RESOURCE_TYPE
    data.postinfo = {x = tileInfo.buildingInfo.x, y = tileInfo.buildingInfo.y}
    self._uiSharePanel:showPanel(sender, data)
end