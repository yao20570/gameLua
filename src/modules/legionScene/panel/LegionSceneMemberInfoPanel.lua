-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 军团成员-成员查看
--  */

LegionSceneMemberInfoPanel = class("LegionSceneMemberInfoPanel", BasicPanel)
LegionSceneMemberInfoPanel.NAME = "LegionSceneMemberInfoPanel"

function LegionSceneMemberInfoPanel:ctor(view, panelName)
    LegionSceneMemberInfoPanel.super.ctor(self, view, panelName, 400)
    
    self:setUseNewPanelBg(true)
end

function LegionSceneMemberInfoPanel:finalize()
    LegionSceneMemberInfoPanel.super.finalize(self)
end

function LegionSceneMemberInfoPanel:initPanel()
    LegionSceneMemberInfoPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(3022))
    -- local Image_bg = self:getChildByName("mainPanel/Image_bg")
    -- TextureManager:updateImageView(Image_bg, "images/guiScale9/Frame_item_bg.png")
end

function LegionSceneMemberInfoPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionSceneMemberInfoPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
end

function LegionSceneMemberInfoPanel:onShowHandlerNew(memberInfo)
    self._curMemberInfo = memberInfo
    local infoPanel = self:getChildByName("mainPanel/infoPanel")
    self:renderInfoPanel(infoPanel, memberInfo)
end

-- 界面更新
function LegionSceneMemberInfoPanel:onLegionInfoUpdate(data)
    -- body
    if self:isVisible() ~= true then
        return
    end

    self:onShowHandlerNew(data)
end

function LegionSceneMemberInfoPanel:renderInfoPanel(infoPanel, info)
    local nameTxt = infoPanel:getChildByName("nameTxt")--名字
    local jobTxt = infoPanel:getChildByName("jobTxt")
    local rankTxt = infoPanel:getChildByName("rankTxt")
    local levelTxt = infoPanel:getChildByName("levelTxt")--等级
    local capacityTxt = infoPanel:getChildByName("capacityTxt")
    local devoteTxt = infoPanel:getChildByName("devoteTxt")
    local onlineTxt = infoPanel:getChildByName("onlineTxt")
    local Image_head = infoPanel:getChildByName("Image_head")

    local numTxtxxx = infoPanel:getChildByName("numTxtxxx")
    numTxtxxx:setString(self:getTextWord(136))

    nameTxt:setString(info.name)
    rankTxt:setString(info.capityrank)
    levelTxt:setString(string.format(self:getTextWord(3200), info.level))
    -- capacityTxt:setString(info.capacity)
    capacityTxt:setString( StringUtils:formatNumberByK( info.capacity, 0))
    devoteTxt:setString(info.devote)


    -- 头像和挂件
    -- print("iconId="..info.iconId..",,pendantId="..info.pendantId)
    local headInfo = {}
    headInfo.icon = info.iconId
    headInfo.pendant = info.pendantId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    --headInfo.isCreatButton = false
    headInfo.playerId = rawget(info, "id")

    local head = infoPanel.head
    if head == nil then
        head = UIHeadImg.new(Image_head,headInfo,self)        
        infoPanel.head = head
    else
        head:updateData(headInfo)
    end

    local size = levelTxt:getContentSize()
    local size2 = nameTxt:getContentSize()
    nameTxt:setPositionX(levelTxt:getPositionX() + size.width + 12)
    -- onlineTxt:setPositionX(levelTxt:getPositionX() + size.width + 12 + size2.width)


    local legionProxy = self:getProxy(GameProxys.Legion)
    local jobName = legionProxy:getJobName(info.job)
    jobTxt:setString(jobName)

    print("info.isOnline===",info.isOnline)
    if info.isOnline == 0 then
        -- 在线
        onlineTxt:setString(self:getTextWord(3106))
        onlineTxt:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.Green))
    else
        -- 离线
        local timeText = TimeUtils:getOfflineTime(info.isOnline)
        onlineTxt:setString(timeText)
        onlineTxt:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.Red))
    end
    -- 设置vip等级
    local vipLevel = info.vipLevel
    local vipNode = infoPanel:getChildByName("vipNode")
    self:addvipFont(vipNode, vipLevel)
    NodeUtils:alignNodeL2R(nameTxt, vipNode, 10)
    local widthV   = self:getWidth(vipNode, "vipImg")
    local widthNum = self:getWidth(vipNode, "text")
    -- onlineTxt:setPositionX(onlineTxt:getPositionX() + widthV + widthNum + 8)

    --从名字开始对齐
    if vipLevel == 0 then
        NodeUtils:alignNodeL2R(nameTxt,onlineTxt,2)
    else
        -- local imgV = vipNode:getChildByName("vipImg")
        -- local imgVNum = vipNode:getChildByName("text")
        -- NodeUtils:alignNodeL2R(nameTxt,imgV,imgVNum,onlineTxt)
        NodeUtils:alignNodeL2R(nameTxt,vipNode,onlineTxt,2)
    end

    --TODO 这里会根据自己的职位 以及查看的职位的关系，来处理功能按钮的灰暗
    local mineJob = legionProxy:getMineJob()    --自己的职位
    local otherJob = info.job                   --对方的职位
    local otherID = info.id
    logger:info("seeName = "..info.name.."mineJob="..mineJob..",".."seeJob="..otherJob..",成员的在线状态info.isOnline = "..info.isOnline)

    local roleProxy = self:getProxy(GameProxys.Role)
    local mineID = roleProxy:getPlayerId()


    NodeUtils:setEnable(self._mailBtn, true)
    NodeUtils:setEnable(self._chatBtn, true)
    NodeUtils:setEnable(self._upJobBtn, true)
    NodeUtils:setEnable(self._kickBtn, true)
    NodeUtils:setEnable(self._transferBtn, true)
    NodeUtils:setEnable(self._exitBtn, true)


    if mineID == otherID and mineJob == otherJob then
        -- 点击自己
        NodeUtils:setEnable(self._mailBtn, false)
        NodeUtils:setEnable(self._chatBtn, false)
        NodeUtils:setEnable(self._kickBtn, false)
        NodeUtils:setEnable(self._transferBtn, false)
        self._upJobBtn:setTitleText(self:getTextWord(3114)) -- "升职"

        -- 副盟主/盟主点自己可升职，其他职位均置灰
        if mineJob == 7 or mineJob == 6 then 
            NodeUtils:setEnable(self._upJobBtn, true)
        else
            NodeUtils:setEnable(self._upJobBtn, false)
        end
    else
        -- 点击其他玩家
        NodeUtils:setEnable(self._mailBtn, true)
        NodeUtils:setEnable(self._chatBtn, true)

        if mineJob == 7 then --我是团长
            self._upJobBtn:setTitleText(self:getTextWord(3113)) -- "设定职位"
            NodeUtils:setEnable(self._exitBtn, false)
        elseif mineJob == 6 then --我是副团长
            if mineJob > otherJob then
                -- 我的职位高比对方高
                self._upJobBtn:setTitleText(self:getTextWord(3114))
                NodeUtils:setEnable(self._upJobBtn, false)
                NodeUtils:setEnable(self._transferBtn, false)
                NodeUtils:setEnable(self._exitBtn, false)
            else
                self._upJobBtn:setTitleText(self:getTextWord(3114))
                NodeUtils:setEnable(self._upJobBtn, false)
                NodeUtils:setEnable(self._kickBtn, false)
                NodeUtils:setEnable(self._transferBtn, false)
                NodeUtils:setEnable(self._exitBtn, false)                
            end
        else --我是普通成员or自定义职位
            self._upJobBtn:setTitleText(self:getTextWord(3114))
            NodeUtils:setEnable(self._upJobBtn, false)
            NodeUtils:setEnable(self._kickBtn, false)
            NodeUtils:setEnable(self._transferBtn, false)
            NodeUtils:setEnable(self._exitBtn, false)
        end

    end

end

function LegionSceneMemberInfoPanel:registerEvents()
    LegionSceneMemberInfoPanel.super.registerEvents(self)

    self._mailBtn = self:getChildByName("mainPanel/mailBtn")
    self._chatBtn = self:getChildByName("mainPanel/chatBtn")
    self._upJobBtn = self:getChildByName("mainPanel/upJobBtn")
    self._kickBtn = self:getChildByName("mainPanel/kickBtn")
    self._transferBtn = self:getChildByName("mainPanel/transferBtn")
    self._exitBtn = self:getChildByName("mainPanel/exitBtn")
    -- self._closeBtn = self:getChildByName("mainPanel/closeBtn")

    self:addTouchEventListener(self._mailBtn, self.onMailBtnTouch)
    self:addTouchEventListener(self._chatBtn, self.onChatBtnTouch)
    self:addTouchEventListener(self._upJobBtn, self.onUpJobBtnTouch)
    self:addTouchEventListener(self._kickBtn, self.onKickBtnTouch)
    self:addTouchEventListener(self._transferBtn, self.onTransferBtnTouch)
    self:addTouchEventListener(self._exitBtn, self.onExitBtnTouch)
    -- self:addTouchEventListener(self._closeBtn, self.onCloseBtnTouch)
end

function LegionSceneMemberInfoPanel:onMailBtnTouch(sender)
--TODO 发邮件
    -- 现在改为玩家不在线也可以发邮件
--    if self._curMemberInfo.isOnline == 0 then
--        self:showSysMessage(self:getTextWord(3015))
--        return
--    end
    local roleProxy = self:getProxy(GameProxys.Role)
    local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if lv < GlobalConfig.chatMinLv then
        self:showSysMessage(string.format(TextWords:getTextWord(1238), GlobalConfig.chatMinLv))
        return
    end
    
    local nameContext = self._curMemberInfo.name
    local data = {}
    data["moduleName"] = ModuleName.MailModule
    data["extraMsg"] = {}
    data["extraMsg"]["type"] = "writeMail"
    data["extraMsg"]["isCloseModule"] = true
    data["extraMsg"]["name"] = nameContext --你要写给对方的名字

    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:enterWriteMsg(data)

end

function LegionSceneMemberInfoPanel:onChatBtnTouch(sender)
    --TODO 私聊

    -- 请求玩家的信息
    local data = {playerId = self._curMemberInfo.id}
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:watchPlayerInfoReq(data)

end

-- 打开私聊界面
function LegionSceneMemberInfoPanel:onChatPersonInfoResp(data)
    -- body
    data.index = 0
    data.isFromWorldMap = true  --暂时当军团是世界地图
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:enterPrivate(data)
    logger:info("···enterPrivate.........先请求了140001..导致ChatModule接收140001打开了UIWatchPlayerInfoPanel")
end


function LegionSceneMemberInfoPanel:onUpJobBtnTouch(sender)
--TODO 升职
    local legionProxy = self:getProxy(GameProxys.Legion)
    local mineJob = legionProxy:getMineJob()    --自己的职位
    local otherJob = self._curMemberInfo.job    --对方的职位

    if mineJob == otherJob then
        -- 点击自己
        if mineJob == 7 then
            -- 团长
            self:showSysMessage(self:getTextWord(3115))
        else
            -- 其他职位升职
            local data = {}
            data.type = 2   -- 2=升职
            data.id = self._curMemberInfo.id
            data.job = otherJob
            local legionProxy = self:getProxy(GameProxys.Legion)
            legionProxy:onTriggerNet220221Req(data)
        end

    elseif mineJob == 7 then
        -- 设置职位
        local panel = self:getPanel(LegionSceneSetJobPanel.NAME)
        panel:show()
        panel:onShowHandlerNew(self._curMemberInfo)
    else
        --其他职位升职
        local data = {}
        data.type = 2   -- 2=升职
        data.id = self._curMemberInfo.id
        data.job = otherJob
        local legionProxy = self:getProxy(GameProxys.Legion)
        legionProxy:onTriggerNet220221Req(data)

    end
end

function LegionSceneMemberInfoPanel:onKickBtnTouch(sender)
    --TODO 踢出军团
    local function okCallBack()
        local data = {}
        data.id = self._curMemberInfo.id
        data.type = 1

        local legionProxy = self:getProxy(GameProxys.Legion)
        legionProxy:onTriggerNet220201Req(data)

        -- 关闭界面
        self:onCloseBtnTouch(sender)
    end
    local function cancelCallBack()
    end
    local content = string.format(self:getTextWord(3118), self._curMemberInfo.name)
    self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))

end

function LegionSceneMemberInfoPanel:onTransferBtnTouch(sender)
--TODO 转让团长
    local function okCallBack()
        local data = {}
        data.id = self._curMemberInfo.id
        data.type = 2

        local legionProxy = self:getProxy(GameProxys.Legion)
        legionProxy:onTriggerNet220201Req(data)
    end
    local function cancelCallBack()
    end
    local content = string.format(self:getTextWord(3117), self._curMemberInfo.name)
    self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))


end

function LegionSceneMemberInfoPanel:onExitBtnTouch(sender)
--TODO 退出军团
    local function okCallBack()
        local data = {}
        data.id = self._curMemberInfo.id
        data.type = 3

        local legionProxy = self:getProxy(GameProxys.Legion)
        legionProxy:onTriggerNet220201Req(data)

        -- 关闭界面
        self:onCloseBtnTouch(sender)
    end
    local function cancelCallBack()
    end
    local content = self:getTextWord(3116)
    self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))
    
end

function LegionSceneMemberInfoPanel:onCloseBtnTouch(sender)
    -- body
    self:onClose()
end

function LegionSceneMemberInfoPanel:onClose()
    -- body
    self:hide()
end

function LegionSceneMemberInfoPanel:addvipFont(node, vip)
    if vip == 0 then
        local vipImg = node:getChildByName("vipImg")
        local text = node:getChildByName("text")
        if vipImg then
            vipImg:setVisible(false)
        end
        if text then
            text:setVisible(false)
        end
        return
    end

    -- V图片
    local vipImg = node:getChildByName("vipImg")
    if vipImg == nil then 
        vipImg = TextureManager:createImageView("images/roleInfo/IconVIP.png")
        -- vipImg = TextureManager:createImageView("images/chat/V.png")
        vipImg:setAnchorPoint(cc.p(0, 0))
        vipImg:setName("vipImg")
        node:addChild(vipImg)
      
    end
    
    --lv
    local text = node:getChildByName("text")
    local font_width = 14
    local font_height = 20
    if text == nil then
        text = ccui.TextAtlas:create()
        -- text:setProperty("1234567890", "ui/images/fonts/VIP123456789.png", 14, 23, "0")
        text:setProperty("1234567890", "ui/images/fonts/num_vip.png", font_width, font_height, "0")
        text:setAnchorPoint(cc.p(0, 0))
        text:setName("text")
        node:addChild(text)
    end
    text:setString(vip)

    local vsize = vipImg:getContentSize()
    local numsize = text:getContentSize()
    local size = cc.size(vsize.width + numsize.width+3,vsize.height)
    node:setContentSize(size)

    vipImg:setVisible(true)
    text:setVisible(true)
    NodeUtils:alignNodeL2R(vipImg, text, 1)
end


function LegionSceneMemberInfoPanel:getWidth(vipNode, childName)
    local nodeWidth = 0
    local targetNode = vipNode:getChildByName(childName)
    if targetNode ~= nil then
        if targetNode:isVisible() then
            nodeWidth = targetNode:getContentSize().width
        else
            nodeWidth = 0
        end
    else
        nodeWidth = 0
    end

    return nodeWidth
end




