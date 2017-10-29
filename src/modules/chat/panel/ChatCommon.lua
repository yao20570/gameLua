ChatCommon = ChatCommon or { }

local Type_Other = 1
local Type_My = 2
local Type_Sys = 3

local function addHeadIcon(this, chat, parent, vip)
    local headInfo = { }
    headInfo.icon = chat.iconId
    -- if StringUtils:isFixed64Zero(chat.playerId) or StringUtils:isGmNotice(chat.playerId) then
    --     headInfo.icon = 999
    -- end
    headInfo.pendant = chat.pendantId
    headInfo.isChat = true
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    headInfo.customHeadIcon = chat.customHeadIcon
    headInfo.playerId = chat.playerId
    headInfo.isDownloadCallback = true
    -- headInfo.isCreatButton = true
    local head = parent.head

    headInfo.frameId = chat.frameId
    if head == nil then
        head = UIHeadImg.new(parent, headInfo, this)
        head:setScale(0.8)
        head:runPendantAction()
        parent.head = head
    else
        head:updateData(headInfo)
    end

    if parent.effect ~= nil then
        parent.effect:setVisible(false)
        parent.effect:pause()
    end
    -- 特效层级要比挂件等，挂件和特效只能属于同一个parent
    if vip >= 4 then
        local effectPath = vip < 8 and "rgb-vippinzi-zi" or "rgb-vippinzi-jin"
        if parent.effect == nil then
            local effectNode = head:getVipEffectNode()
            effectNode:setScale(1.25)
            parent.effect = ComponentUtils:popCCBLayerPool(effectPath, effectNode)
            parent.effect:setLocalZOrder(100)
        else
            if parent.effect:getName() == effectPath then

                parent.effect:setVisible(true)
            else
                ComponentUtils:pushCCBLayerPool(parent.effect)
                local effectNode = head:getVipEffectNode()
                effectNode:setScale(1.25)
                parent.effect = ComponentUtils:popCCBLayerPool(effectPath, effectNode)
                parent.effect:setLocalZOrder(100)
            end
        end

        if this.view:isModuleVisible() then
            parent.effect:resume()
        else
            parent.effect:pause()
        end
    end

    local headBtn = head:getButton()
    headBtn:setTouchEnabled(false)

    if parent.effect ~= nil then
        if chat.frameId ~= 0 and parent.effect:isVisible() then
            parent.effect:setVisible(false)
        end
    end
    -- head:setHeadSquare(headInfo.icon)

    -- 系统头像不显示vip等级，D12.22需求vip等级不显示在头像里
    --        if StringUtils:isGmNotice(chat.playerId) == false then
    --            head:updateVIPLevel(vip)--显示vip等级
    --        end

    -- 自己的头像和系统头像不能点击
    if StringUtils:isFixed64Zero(chat.playerId) == false and StringUtils:isGmNotice(chat.playerId) == false then
        headBtn.id = chat.playerId
        this:addTouchEventListener(headBtn, this.onClickActor)
    end
    parent:setScale(1 / NodeUtils:getAdaptiveScale())
end

-- 添加vip, vip ~= 0, 返回长度
local function addVipFont(node, vip)
    -- V图片
    if node.vipImg == nil then
        node.vipImg = TextureManager:createImageView("images/chat/SpVip.png")
        node.vipImg:setAnchorPoint(0, 0)
        node.vipImg:setName("vipImg")
        node:addChild(node.vipImg)
    end
    -- 等级数字标签
    if node.vipText == nil then
        node.vipText = ccui.TextAtlas:create()
        node.vipText:setProperty("1234567890", "ui/images/fonts/num_vip.png", 14, 20, "0")
        node.vipText:setAnchorPoint(0, 0)
        node.vipText:setName("vipText")
        node:addChild(node.vipText)
    end

    node.vipText:setString(vip)
    NodeUtils:alignNodeL2R(node.vipImg, node.vipText)
    local vipImgWidth = node.vipImg:getContentSize().width
    local textWidth = node.vipText:getContentSize().width
    return vipImgWidth + textWidth
end

function ChatCommon.expandChatItem(parent)
    local allChild = parent._allChild

    if allChild == nil then
        parent._allChild = { }
        allChild = parent._allChild
        -- 按着UI里面的默认显示

        allChild.otherChatBg = parent:getChildByName("imgOtherBg")
        --allChild.otherChatBg.url ="images/newGui9Scale/S9ChatOther.png"
        allChild.otherChatBg:setTouchEnabled(true)
        allChild.otherChatBg:setVisible(true)
        allChild.otherRedPacktBg = parent:getChildByName("imgOtherRedBag")
        allChild.otherRedPacktBg:setTouchEnabled(true)
        allChild.otherRedPacktBg:setVisible(false)
        allChild.otherActor = parent:getChildByName("imgOtherActor")
        allChild.otherActor:setVisible(true)
        allChild.otherAudioImg = parent:getChildByName("imgOtherAudio")
        allChild.otherAudioImg:setVisible(true)
        allChild.otherEmotionImg = parent:getChildByName("imgOtherEmotion")
        allChild.otherEmotionImg:setVisible(true)
        allChild.otherContentTxt = parent:getChildByName("txtOtherContent")
        allChild.otherContentTxt:setVisible(true)
        allChild.otherDesignLab = parent:getChildByName("txtOtherDesign")
        allChild.otherDesignLab:setVisible(false)
        allChild.otherDesignLab:setString("")
        allChild.otherName = parent:getChildByName("txtOtherName")
        allChild.otherName:setVisible(true)
        allChild.especialTxt = parent:getChildByName("txtOtherEspecial")
        allChild.especialTxt:setVisible(true)
        allChild.legionName = parent:getChildByName("txtOtherLegionName")
        allChild.legionName:setVisible(true)        
        allChild.timeText = parent:getChildByName("txtOtherTime")
        allChild.timeText:setVisible(true)


        allChild.myChatBg = parent:getChildByName("imgSelfBg")
        --allChild.myChatBg.url ="images/newGui9Scale/S9ChatMy.png"
        allChild.myChatBg:setTouchEnabled(true)
        allChild.myChatBg:setVisible(true)
        allChild.myRedPacktBg = parent:getChildByName("imgSelfRedBag")
        allChild.myRedPacktBg:setTouchEnabled(true)
        allChild.myRedPacktBg:setVisible(false)
        allChild.myActor = parent:getChildByName("imgSelfActor")
        allChild.myActor:setVisible(true)
        allChild.myAudioImg = parent:getChildByName("imgSelfAudio")
        allChild.myAudioImg:setVisible(true)
        allChild.myEmotionImg = parent:getChildByName("imgSelfEmotion")
        allChild.myEmotionImg:setVisible(true)
        allChild.myContentTxt = parent:getChildByName("txtSelfContent")
        allChild.myContentTxt:setVisible(true)
        allChild.myDesignLab = parent:getChildByName("txtSelfDesign")
        allChild.myDesignLab:setVisible(false)
        allChild.myDesignLab:setString("")
        allChild.myName = parent:getChildByName("txtSelfName")
        allChild.myName:setVisible(true)


        allChild.imgSysBg = parent:getChildByName("imgSysBg")
        allChild.imgSysBg:setVisible(false)
        allChild.imgSysLaba = parent:getChildByName("imgSysLaba")
        allChild.imgSysLaba:setVisible(false)

        if allChild.contentRichLabel == nil then
            allChild.contentRichLabel = RichTextMgr:getInstance():getRich( { }, 440, nil, nil, nil, RichLabelAlign.left_top)
            allChild.contentRichLabel:setLocalZOrder(100000)
            parent:addChild(allChild.contentRichLabel)
        end
        
    end

    -- 重置元素位置
    for k, v in pairs(allChild) do
        allChild[k].y = allChild[k].y or allChild[k]:getPositionY()
        allChild[k]:setPositionY(allChild[k].y)
    end

    

    return allChild
end

ChatCommon.isNull = true

function ChatCommon.CommonRender(chatItem, chat, this)

   

    chatItem:setVisible(true)
    -- this.myType = 1
    -- chat.playerType = 1
    local chatItemSize = chatItem.srcContentSize
    if chatItemSize == nil then
        chatItemSize = chatItem:getContentSize()
        chatItem.srcContentSize = chatItemSize
    end

    local allChild = ChatCommon.expandChatItem(chatItem)


    allChild.otherActor.id = chat.playerId
    allChild.myActor.id = chat.playerId
    
    chat.design = chat.design or { }

    local contentTxt = nil
    local bgImg = nil
    local emotionImg = nil
    local x = nil
    local y = nil
    local isMy = false
    if allChild.myAudioImg ~= nil then
        allChild.myAudioImg:setVisible(false)
        allChild.otherAudioImg:setVisible(false)
    end

    if chat.contextType == 2 then
        -- 语音类型
        local chatId = chat.chatClientId
        if chat.context ~= "" then
            -- 表示外部传来的语音信息了，先保存起来
            AudioManager:saveRecorderSound(chatId, chat.context)
        end

        local audioImg = nil
        local audioSec = chat.audioSec
        --local space = StringUtils:copyString("  ", audioSec)
        local space = StringUtils:copyString("  ", 2)
        if this._ID == chat.playerId then
            allChild.myAudioImg:setVisible(true)
            audioImg = allChild.myAudioImg
            bgImg = allChild.myChatBg

            chat.context = string.format("%d'  %s", audioSec, space)
        else
            allChild.otherAudioImg:setVisible(true)
            audioImg = allChild.otherAudioImg
            bgImg = allChild.otherChatBg

            chat.context = string.format("  %s%d'", space, audioSec)
        end

        audioImg:setLocalZOrder(100000)

        local function playAudio()
            -- 播放音效
            -- if AudioManager.isPlayRecorder == true then
            --     return --正在播放录音中
            -- end
            local flag = AudioManager:playRecorderSound(chatId, nil, audioSec, audioImg)
            if flag == false then
                -- 播放失败，表示还没有缓存，请求数据
                local chatProxy = this:getProxy(GameProxys.Chat)
                chatProxy:onTriggerNet140100Req( { chatClientId = chatId, type = chat.type })
            else
                -- 正在播放，使用动画
                this:playRecorderAction(audioImg, audioSec)
            end
        end

        this:addTouchEventListener(bgImg, playAudio)
    end
      
    

    if this._ID == chat.playerId then
        

        isMy = true
        allChild.timeText:setVisible(false)

        allChild.otherActor:setVisible(false)
        allChild.otherChatBg:setVisible(false)
        allChild.otherContentTxt:setVisible(false)
        allChild.otherName:setVisible(false)
        allChild.otherDesignLab:setVisible(false)

        allChild.myActor:setVisible(true)
        allChild.myChatBg:setVisible(true)
        allChild.myContentTxt:setVisible(true)
        allChild.myName:setVisible(true)
        allChild.myDesignLab:setVisible(true)

        allChild.imgSysBg:setVisible(false)
        allChild.imgSysLaba:setVisible(false)

        contentTxt = allChild.myContentTxt
        bgImg = allChild.myChatBg

        TextureManager:updateImageView(bgImg,"images/newGui9Scale/S9ChatMy.png")

        if bgImg.redPacketDes then
            bgImg.redPacketDes:setVisible(false)
        end 
        emotionImg = allChild.myEmotionImg
        local legionStr = ""
        -- extendValue 扩展字段用于标志 默认0:没意义  1:红包聊天信息
        -- 私聊或者非红包信息添加军团和等级

        

        if (chat.type == 1 and chat.extendValue ~= 1 and chat.extendValue ~= 3) or chat.type == 0 then
            local addStr = ""
            if chat.legionName ~= "" and chat.legionName and chat.level then
                -- addStr = "Lv."..chat.level.." "..this._NAME
                addStr = this._NAME
                legionStr = "[" .. chat.legionName .. "]"
            elseif chat.level then
                -- addStr = "Lv."..chat.level.." "..this._NAME
                addStr = this._NAME
            elseif not chat.level then
                addStr = this._NAME
            end
            allChild.myName:setString(addStr)
        else

            -- 【优化】同盟聊天的时候显示职务
            if chat.legionName ~= "" and chat.legionName then
--                local legionJob = 5 -- 协议，没有的key绝对报错
                local legionJob = chat.legionJob -- 自定义1234 5普通 6 副团长 7团长-- 
                local legionProxy = this:getProxy(GameProxys.Legion)
                local jobName = legionProxy:getJobName(legionJob)
                legionStr = "["..jobName.."]" 
            end
            if chat.extendValue == 3 then 
                allChild.myName:setString(chat.name)
            else
                allChild.myName:setString(this._NAME)
            end 
        end
        allChild.legionName:setString(legionStr)

        -- 盟主的称号设为绿色job == 7
        if chat.legionJob == 7 then
            allChild.legionName:setColor(ColorUtils.wordGreenColor)
        else
            allChild.legionName:setColor(cc.c3b(255, 189, 48))
        end


        -- 自己的称号字符串-----------

        if allChild.myDesignLab.richLabel == nil then
            allChild.myDesignLab.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
            allChild.myDesignLab.richLabel:setPositionY(allChild.myDesignLab.richLabel:getPositionY() + 12)
            allChild.myDesignLab:addChild(allChild.myDesignLab.richLabel)
        end
        local richTable = { }
        table.sort(chat.design, function(a, b) return a < b end)
        for k, v in pairs(chat.design) do
            local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.TitleConfig, "type", v)
            local nameStr = config.title
            local color = config.titleLv
            local richShow = { }
            if #richTable == 0 then
                richShow = { nameStr, 20, ColorUtils:getRichColorByQuality(color) }
            else
                richShow = { " " .. nameStr, 20, ColorUtils:getRichColorByQuality(color) }
            end
            table.insert(richTable, richShow)
        end


        allChild.myDesignLab.richLabel:setString( { richTable })
        

        if allChild.myName.vipFontSp ~= nil then
            allChild.myName.vipFontSp:setVisible(false)
        end

        -- 加vip
        local vipWidth = 0
        if chat.vipLevel ~= 0 and chat.vipLevel ~= nil then
            if allChild.myName.vipFontSp == nil then
                allChild.myName.vipFontSp = cc.Sprite:create()
                allChild.myName:addChild(allChild.myName.vipFontSp)
            else
                allChild.myName.vipFontSp:setVisible(true)
            end

            local vipFontSp = allChild.myName.vipFontSp
            vipFontSp:setName("vipFontSp")
            vipWidth = addVipFont(vipFontSp, chat.vipLevel)
            vipFontSp:setPositionX(- vipWidth - 3)
        end


        local legionNameContext = allChild.legionName:getContentSize()
        local myNameContext = allChild.myName:getContentSize()
        local desiginSize = allChild.myDesignLab.richLabel:getContentSize()
        -- 新
        local namePoint = allChild.myName:getPosition()
        allChild.myDesignLab:setPositionX(namePoint - myNameContext.width - 3 - vipWidth)
        allChild.legionName:setPositionX(allChild.myDesignLab:getPositionX() - desiginSize.width - legionNameContext.width - 3)
        NodeUtils:alignNodeL2R(allChild.legionName, allChild.myDesignLab)
        -----end--------


        this:addTouchEventListener(allChild.myActor, this.onClickMyActor)

        -- allChild.vipLeft:setVisible(false)
        -- allChild.vipTxt1:setVisible(false)
        -- if chat.vipLevel > 0 then
        --     allChild.vipTxt2:setString(chat.vipLevel)
        -- else
        --     allChild.vipRight:setVisible(false)
        --     allChild.vipTxt2:setVisible(false)
        -- end

        if this.myType > 0 then
            allChild.especialTxt:setString(this:getTextWord(908))
            local textSize = allChild.especialTxt:getContentSize()
            allChild.legionName:setPositionX(allChild.legionName:getPositionX() - textSize.width)
            allChild.myName:setPositionX(allChild.myName:getPositionX() - textSize.width)

            allChild.myDesignLab:setPositionX(allChild.myDesignLab:getPositionX() - textSize.width)

            allChild.especialTxt:setPositionX(allChild.myName:getPositionX() + 2)
        else
            allChild.especialTxt:setString("")
        end

        x, y = allChild.myEmotionImg:getPosition()
        x = x + 20
        y = y + 15
        --ProfileUtils:PrintTime(290)
        addHeadIcon(this, chat, allChild.myActor, chat.vipLevel)
        --ProfileUtils:PrintTime(300)

    else
        --ProfileUtils:PrintTime(410)
        allChild.timeText:setVisible(true)
        allChild.otherActor:setVisible(true)
        allChild.otherChatBg:setVisible(true)
        allChild.otherContentTxt:setVisible(true)
        allChild.otherName:setVisible(true)
        allChild.otherDesignLab:setVisible(true)

        allChild.myActor:setVisible(false)
        allChild.myChatBg:setVisible(false)
        allChild.myContentTxt:setVisible(false)
        allChild.myName:setVisible(false)
        allChild.myDesignLab:setVisible(false)

        allChild.imgSysBg:setVisible(false)
        allChild.imgSysLaba:setVisible(false)

        contentTxt = allChild.otherContentTxt
        bgImg = allChild.otherChatBg
        if bgImg.redPacketDes then
            bgImg.redPacketDes:setVisible(false)
        end 
        --ProfileUtils:PrintTime(411)
        TextureManager:updateImageView(bgImg,"images/newGui9Scale/S9ChatOther.png")
        --ProfileUtils:PrintTime(412)
        emotionImg = allChild.otherEmotionImg
        --ProfileUtils:PrintTime(420)
        local legionStr = ""
        -- 世界、私聊，非系统信息添加军团和等级
        if (chat.type == ChatProxy.ChatType_World or chat.type == ChatProxy.ChatType_Private) 
            and (not StringUtils:isFixed64Zero(chat.playerId)) 
            and (not StringUtils:isGmNotice(chat.playerId)) then

            local addStr = ""
            if chat.legionName ~= "" and chat.legionName and chat.level then
                addStr = chat.name
                legionStr = "[" .. chat.legionName .. "]"
            elseif chat.level then
                addStr = chat.name
                addStr = chat.name
            elseif not chat.level then
                addStr = chat.name
                addStr = chat.name
            end
            allChild.otherName:setString(addStr)
        else

            -- 【优化】同盟聊天的时候显示职务
            if chat.legionName ~= "" and chat.legionName then
                --local legionJob = 5 -- 协议，没有的key绝对报错
                local legionJob = chat.legionJob -- 自定义1234 5普通 6 副团长 7团长--
                local legionProxy = this:getProxy(GameProxys.Legion)
                local jobName = legionProxy:getJobName(legionJob)
                legionStr = "["..jobName.."]"
            end
            allChild.otherName:setString(chat.name)
        end

        if StringUtils:isFixed64Zero(chat.playerId) or StringUtils:isGmNotice(chat.playerId) then
            allChild.otherName:setColor(cc.c3b(252, 218, 126))
        else
            allChild.otherName:setColor(cc.c3b(255, 255, 255))
        end


        allChild.legionName:setString(legionStr)
        -- 盟主的称号设为绿色job == 7
        if chat.legionJob == 7 then
            allChild.legionName:setColor(ColorUtils.wordGreenColor)
        else
            allChild.legionName:setColor(cc.c3b(255, 189, 48))
        end

        -- 他人的称号字符串--------- 
        if allChild.otherDesignLab.richLabel == nil then
            allChild.otherDesignLab.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
            allChild.otherDesignLab:addChild(allChild.otherDesignLab.richLabel)
            allChild.otherDesignLab.richLabel:setPositionY(allChild.otherDesignLab.richLabel:getPositionY() + 12)
        end
        local richTable = { }
        table.sort(chat.design, function(a, b) return a < b end)
        for k, v in pairs(chat.design) do
            local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.TitleConfig, "type", v)
            local nameStr = config.title
            local color = config.titleLv

            local richShow = { }
            if #richTable == 0 then
                richShow = { nameStr, 20, ColorUtils:getRichColorByQuality(color) }
            else
                richShow = { " " .. nameStr, 20, ColorUtils:getRichColorByQuality(color) }
            end
            table.insert(richTable, richShow)
        end

        
        allChild.otherDesignLab.richLabel:setString( { richTable })

       
        if allChild.otherName.vipFontSp ~= nil then
            allChild.otherName.vipFontSp:setVisible(false)
        end
        -- 加vip
        local vipWidth = 0
        if chat.vipLevel ~= 0 and chat.vipLevel ~= nil then
            if allChild.otherName.vipFontSp == nil then
                allChild.otherName.vipFontSp = cc.Sprite:create()
                allChild.otherName:addChild(allChild.otherName.vipFontSp)
            else
                allChild.otherName.vipFontSp:setVisible(true)
            end

            local vipFontSp = allChild.otherName.vipFontSp
            vipFontSp:setName("vipFontSp")
            vipWidth = addVipFont(vipFontSp, chat.vipLevel)
            vipFontSp:setPositionX(allChild.otherName:getContentSize().width + 3)
        end

        local nameContext = allChild.otherName:getContentSize()
        local desiginSize = allChild.otherDesignLab.richLabel:getContentSize()
        -- 新
        local namePoint = allChild.otherName:getPosition()
        allChild.otherDesignLab:setPositionX(namePoint + nameContext.width + 3 + vipWidth + 3)
        allChild.legionName:setPositionX(allChild.otherDesignLab:getPositionX() + desiginSize.width)
        ---------end--


        if chat.time ~= nil then
            local time = TimeUtils:setTimestampToString5(chat.time)
            allChild.timeText:setString(time)
        end



        if chat.playerType and chat.playerType > 0 then
            allChild.especialTxt:setVisible(true)
            allChild.especialTxt:setString(this:getTextWord(908))
            allChild.especialTxt:setPositionX(98)
            local textSize = allChild.especialTxt:getContentSize()
            allChild.legionName:setPositionX(allChild.legionName:getPositionX() + textSize.width)
            allChild.otherName:setPositionX(allChild.otherName:getPositionX() + textSize.width)
            allChild.otherDesignLab:setPositionX(allChild.otherDesignLab:getPositionX() + textSize.width)
        else
            allChild.especialTxt:setVisible(false)
        end

        local legionNameContext = allChild.legionName:getContentSize()
        local legionNamePoint = allChild.legionName:getPosition()
        allChild.timeText:setPositionX(legionNamePoint + legionNameContext.width)
        --ProfileUtils:PrintTime(430)
        x, y = allChild.otherContentTxt:getPosition()
        x = x + 2
        y = y - 3
        addHeadIcon(this, chat, allChild.otherActor, chat.vipLevel)
        --ProfileUtils:PrintTime(440)
    end


    --ProfileUtils:PrintTime(500)

    
    



    local lineNum = 0
    local width = 0
    -- 分享、系统公告也会进来？？好像是的
    if rawget(chat, "isShare") then
        if contentTxt.posy == nil then
            contentTxt.posy = contentTxt:getPositionY()
        end
        contentTxt:setPositionY(contentTxt.posy - 13)

        local isSystem = StringUtils:isFixed64Zero(chat.playerId) == true or StringUtils:isGmNotice(chat.playerId) == true 
        if isSystem == true then
            allChild.timeText:setVisible(false)
            allChild.otherActor:setVisible(false)
            allChild.otherChatBg:setVisible(false)
            allChild.otherContentTxt:setVisible(false)
            allChild.otherName:setVisible(false)
            allChild.otherDesignLab:setVisible(false)

            allChild.myActor:setVisible(false)
            allChild.myChatBg:setVisible(false)
            allChild.myContentTxt:setVisible(false)
            allChild.myName:setVisible(false)
            allChild.myDesignLab:setVisible(false)

            allChild.imgSysBg:setVisible(true)
            allChild.imgSysLaba:setVisible(true)
        else
            allChild.imgSysBg:setVisible(false)
            allChild.imgSysLaba:setVisible(false)
        end

        allChild.myRedPacktBg:setVisible(false)
        allChild.otherRedPacktBg:setVisible(false)
        -- TODO 需要增加下划线
        contentTxt.id = chat.shareId
        contentTxt.name = chat.shareName
        contentTxt.shareInfo = chat.shareInfo -- 这个shareInfo系统公告表示notice表的Id
        contentTxt.posInfo = rawget(chat, "posInfo") -- 系统公告跳转坐标
        -- 公共调整位置函数
        -- params：富文本的参数
        -- needChange 是不是系统公告
        -- 是系统公告或者是别人的分享都需要调整锚点

        local function adjustPos(params, needChange)

            

            local rich = allChild.contentRichLabel
            rich:setVisible(true)

            if isSystem == true then

                bgImg = allChild.imgSysBg
                rich:setData(params, 500, ColorUtils.commonColor.c3bFuBiaoTi)

                local sysHei = 20 + rich:getRealHeight()
                allChild.imgSysBg:setContentSize(allChild.imgSysBg:getContentSize().width, sysHei)

                allChild.imgSysLaba:setPositionY(sysHei - 25)

                rich:setPositionX(allChild.imgSysLaba:getPositionX() + 15)
                rich:setPositionY(rich:getRealHeight() + 10)
        
                chatItem:setContentSize(chatItemSize.width, sysHei)

            else
                rich:setData(params, 440, ColorUtils.commonColor.c3bFuBiaoTi)
                local sysWidth = rich:getRealWidth()

                local posY = contentTxt:getPositionY() + 8
                if needChange or((not needChange) and(not isMy)) then
                    rich:setPosition(contentTxt:getPositionX(), posY)
                else
                    rich:setPosition(contentTxt:getPositionX() - sysWidth, posY)
                end
                local sysHei = 20 + rich:getRealHeight()
                bgImg:setContentSize(sysWidth + 20, sysHei)

                local width = bgImg:getContentSize().width
                if isMy then
                    bgImg:setAnchorPoint((width-5)/width,1)
                else
                    bgImg:setAnchorPoint(1-(width-5)/width,1)
                end
            

                local _ih = nil
                local is = chatItemSize            
                if sysHei > 60 then
                    _ih = is.height + sysHei - 60
                    -- 调整所有控件的位置，顺便调整富文本的位置
                    for k, v in pairs(allChild) do
                        v.posy = v.posy or v:getPositionY()
                        v:setPositionY(v.posy + sysHei - 60)
                    end
                    rich.posy = rich.posy or rich:getPositionY()
                    rich:setPositionY(rich.posy + sysHei - 60)
                else
                    _ih = is.height
                end
                chatItem:setContentSize(is.width, _ih)
            end

            -- 在背景设置事件
            local function clickCallback(data)
                this.view:onClickLink(contentTxt.id, contentTxt.name, chat.type, contentTxt.shareInfo, contentTxt.posInfo)
            end
            this:addTouchEventListener(bgImg, clickCallback)
        end


        local _p = nil

        -- 系统公告，要解析文本
        -- 不是系统公告直接拼装成富文本的格式
        -- if StringUtils:isFixed64Zero(chat.playerId) then
        _p = RichTextMgr:getInstance():getNoticeParams(chat.context)
        -- if not StringUtils:isFixed64Zero(chat.playerId) then
        for k, v in pairs(_p) do
            rawset(_p[k], "data", { })
        end
        -- end
        -- else
        --     _p = {{txt=chat.context, color=ColorUtils.wordGreenColor, data = {}, isUnderLine=1}}
        -- endredBagNewBg
        --ProfileUtils:PrintTime(600)
        adjustPos(_p, StringUtils:isFixed64Zero(chat.playerId))
        --ProfileUtils:PrintTime(700)

    else
        --ProfileUtils:PrintTime(800)
        local co = allChild.contentRichLabel
        local params
        -- 红包逻辑，直接用服务端传回来的数据请求抢红包数据
        --1表示系统所发红包
        --3表示玩家所发红包
        if chat.extendValue == 1 or chat.extendValue == 3 then
            if chat.extendValue == 1 then 
                params = RichTextMgr:getInstance():getNoticeParams(chat.context)
                co:setData(params, 381, cc.c3b(220,205,192))
                local path = isMy and "images/chat/bgMy.png" or "images/chat/redbagBg.png"
                TextureManager:updateImageView(bgImg, path)
            elseif chat.extendValue == 3 then
                bgImg:setVisible(false)
                bgImg = isMy and allChild.myRedPacktBg or allChild.otherRedPacktBg
                bgImg:setVisible(true)
                params = {}
                params[1] = {txt = chat.name,color = "ffffff",fontSize = 22}
                params[2] = {txt = TextWords:getTextWord(391009),color = "ffffff",fontSize = 22}
                co:setData(params, 400, cc.c3b(220,205,192))
                local path = isMy and "images/chat/redBagNewBgMy.png" or "images/chat/redBagNewBg.png"
                TextureManager:updateImageView(bgImg, path)
                if not bgImg.redPacketDes then 
                    bgImg.redPacketDes = ccui.Text:create()
                    bgImg:addChild(bgImg.redPacketDes)
                else
                    bgImg.redPacketDes:setVisible(true)
                end
                bgImg.redPacketDes:setString(TextWords:getTextWord(391010))
                bgImg.redPacketDes:setFontSize(22)
                bgImg.redPacketDes:setFontName(GlobalConfig.fontName)
                bgImg.redPacketDes:setColor(ColorUtils:color16ToC3b("#5e5c5c"))
                if isMy then 
                    bgImg.redPacketDes:setPosition(77,17)
                else
                    bgImg.redPacketDes:setPosition(87,17)
                end  
            end 

            if chat.extendValue == 1 then 
                this:addTouchEventListener(bgImg, function(sender)
                    local activityProxy = this:getProxy(GameProxys.Activity)
                    activityProxy.chatName = params[1].txt or ""
                    activityProxy:onTriggerNet230018Req( { Id = tonumber(params[1].data or params[2].data) })
                end )
            elseif chat.extendValue == 3 then
                local data = {}
                data.redBag = chat.redBag
                data.fromName = chat.name
                data.playerIcon = chat.iconId
                data.playerId = chat.playerId

                this:addTouchEventListener(bgImg, function(sender)
                    local redBagProxy = this:getProxy(GameProxys.RedBag)
                    redBagProxy:onTriggerNet540001Req(data)
                end )
            end
        else
            params = ComponentUtils:getChatItem(chat.context, 0.6)
            co:setData(params, 440, cc.c3b(220,205,192));
        end

        local maxWidth = co:getRealWidth()

        local size = bgImg:getContentSize()
        local bgImgPosX, bgImgPoxY = bgImg:getPosition()

        local offsets = 20
        local lineHeight = 50

        -- 各种调整富文本的位置
        if isMy then
            if chat.extendValue == 1 then
                co:setPosition(bgImgPosX - (381 + maxWidth)/2 , lineHeight)
            elseif chat.extendValue == 3 then
                allChild.otherRedPacktBg:setVisible(false)
                co:setPosition(bgImgPosX - bgImg:getContentSize().width + 75 , lineHeight + 10)
            else
                co:setPosition(x - maxWidth, y + 6)
            end
        else
            if chat.extendValue == 1 then
                co:setPosition(bgImgPosX + (381 - maxWidth)/2, lineHeight)
            elseif chat.extendValue == 3 then
                allChild.myRedPacktBg:setVisible(false)
                co:setPosition(bgImgPosX + 70, lineHeight + 10)
            else
                co:setPosition(x, y - 1)
            end
        end
        

        local _height = offsets + co:getRealHeight()
        if _height < lineHeight then 
            _height = lineHeight
        end

        if chat.extendValue == 1 then
            _height = 71
        elseif chat.extendValue == 3 then 
            _height = 90
        end
        if maxWidth >= 45 then
            bgImg:setContentSize(maxWidth + 25, _height)
        else
            bgImg:setContentSize(70, _height)
        end
        if chat.extendValue == 1 then
            bgImg:setContentSize(381, _height)
        elseif chat.extendValue == 3 then
            if isMy then
                bgImg:setContentSize(394, _height)
            else
                bgImg:setContentSize(394, _height)
            end 
        end

        if chat.extendValue ~= 3 then
            allChild.myRedPacktBg:setVisible(false)
            allChild.otherRedPacktBg:setVisible(false)
        end 

        local width = bgImg:getContentSize().width
        if isMy then
            bgImg:setAnchorPoint((width-5)/width,1)
        else
            bgImg:setAnchorPoint(1-(width-5)/width,1)
        end

        local itemSize = chatItemSize
        local itemHeight = nil
        if _height > lineHeight then
            local sub = lineHeight
            itemHeight = itemSize.height + _height - sub
            for k, v in pairs(allChild) do
                allChild[k].posy = allChild[k].posy or v:getPositionY()
                v:setPositionY(allChild[k].posy + _height - sub)
            end
            co.posy = co.posy or co:getPositionY()
            co:setPositionY(co.posy + _height - sub)
        else
            itemHeight = itemSize.height
        end
        
        chatItem:setContentSize(itemSize.width, itemHeight + offsets)

    end
    --ProfileUtils:PrintTime(900)

    local itemSize = chatItem:getContentSize()
    return itemSize.height
end









--- 下面已废弃
ChatCommon.supInfo = function(num, key, info)
    local protoName = "M14.ChatInfo"
    local addLen = num + 1
    print("填充聊天信息" .. addLen)
    for i = addLen, 5 do
        local msg = LocalDBManager:getValueForKey(key .. i)
        if msg and msg ~= "" then
            local data = StringUtils:protoDecode(protoName, msg)
            if type(data) == "table" then
                ChatCommon.isNull = false
                table.insert(info, data)
            end
        end
    end
end

ChatCommon.chatShareInfo = { }
ChatCommon.legionShareInfo = { }
ChatCommon.legShow = false
ChatCommon.chatShow = false

ChatCommon.saveShareInfo = function(data)
    table.insert(ChatCommon.chatShareInfo, data)
end

ChatCommon.saveLegShareInfo = function(data)
    table.insert(ChatCommon.legionShareInfo, data)
end

ChatCommon.maxTen = function(data)
    if #data > 5 then
        local cinfo = { }
        for i = #data - 4, #data do
            table.insert(cinfo, data[i])
        end
        return cinfo
    end
    return data
end