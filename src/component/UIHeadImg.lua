-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-02-27 15:05:50
--  * @Description: 头像通用控件
--  */

-- data表结构：
    -- data = {}
    -- data.icon = 100              --头像ID
    -- data.pendant = 100           --挂件ID
    -- data.preName1 = "headIcon"   --图片资源文件夹名称（头像headIcon）
    -- data.preName2 = nil          --图片资源文件夹名称（挂件headPendant）
    -- data.isCreatPendant = false  --是否创建挂件，默认不创建（例如：主城无挂件false，个人信息有挂件true）
    -- data.isCreatButton = false   --是否创建头像按钮，默认不创建（true=创建，false=不创建）
    -- data.isSettingPanel = false  --是否属于设置头像，默认false（true=是，false=不是）
    -- data.isCreatCover = true    --是否创建相框遮挡，默认创建（true=创建，false=不创建）


UIHeadImg = class("UIHeadImg")
UIHeadImg.HEAD_CHAT_ICON_PATH = "images/headChatIcon/%s.png"
UIHeadImg.HEAD_SQUARE_FRAME = "images/newGui2/Frame_prop_1.png"
UIHeadImg.HEAD_HEAD_FRAMEICON = "images/frameIcon/%s.png"

UIHeadImg.ZORDER_ICON_BG = 1
UIHeadImg.ZORDER_ICON = 2
UIHeadImg.ZORDER_ICON_FRAME = 3
UIHeadImg.ZORDER_ICON_SELECT = 4
UIHeadImg.ZORDER_ICON_FRAMEICON = 5 -- 头像框


UIHeadImg.ZORDER_VIP_EFFECT = 5 -- 特效层

UIHeadImg.ZORDER_PENDANT = 10 -- 头饰

function UIHeadImg:setPosition(x, y)
    if self._headNode then
        self._headNode:setPosition(x, y)
    end
end

function UIHeadImg:setScale( s )
    if self._headNode then
        self._headNode:setScale( s )
    end
end

function UIHeadImg:ctor(parent, data, panel)
    self._parent = parent
    self._panel = panel 
    
    self._noticeHead = 999 --系统公告头像
    self._nullHead = 9999 --挂件设置界面头像/头像框设置界面
    
    self:updateData(data)
end

function UIHeadImg:finalize()
    if self._pendantImg ~= nil then
        self._pendantImg:stopAllActions()
        self._pendantImg:setScale(1)
    end
    
    self:finalizeCCB()

    if self._headNode ~= nil then
        --self._headNode:removeAllChildren()
        self._headNode:removeFromParent()
    end

    self._headNode = nil
end


function UIHeadImg:finalizeCCB()
    if self._headFrame and self._headFrameCcb ~= nil then
        self._headFrameCcb:finalize()
        self._headFrameCcb = nil
    end
end

-- 做一下数据检测，数据没变化不执行渲染
function UIHeadImg:isSame(data)
    local flag = false

    if self._data ~= nil and data ~= nil then

        local o_icon = rawget(self._data,"icon")
        local o_pendant = rawget(self._data,"pendant")
        local o_preName1 = rawget(self._data,"preName1")
        local o_preName2 = rawget(self._data,"preName2")
        local o_isCreatPendant = rawget(self._data,"isCreatPendant")
        local o_isCreatButton = rawget(self._data,"isCreatButton")
        local o_isSettingPanel = rawget(self._data,"isSettingPanel")
        local o_isCreatCover = rawget(self._data,"isCreatCover")
        local o_chat = rawget(self._data,"chat")

        local n_icon = rawget(data,"icon")
        local n_pendant = rawget(data,"pendant")
        local n_preName1 = rawget(data,"preName1")
        local n_preName2 = rawget(data,"preName2")
        local n_isCreatPendant = rawget(data,"isCreatPendant")
        local n_isCreatButton = rawget(data,"isCreatButton")
        local n_isSettingPanel = rawget(data,"isSettingPanel")
        local n_isCreatCover = rawget(data,"isCreatCover")
        local n_chat = rawget(data,"chat")

    
        if o_icon == n_icon
            and o_pendant == n_pendant
            and o_preName1 == n_preName1
            and o_preName2 == n_preName2
            and o_isCreatPendant == n_isCreatPendant
            and o_isCreatButton == n_isCreatButton
            and o_isSettingPanel == n_isSettingPanel
            and o_isCreatCover == n_isCreatCover
            and o_chat == n_chat
            then
            flag = true
        end


    end
    return flag
end

-- 更新头像显示
function UIHeadImg:updateData(data)
--    local isSame = self:isSame(data)
--    if isSame == true then
--        -- print("...数据没有变化，不刷新头像")
--        return
--    end
    self._data = data


    local initHead = 101
    local initPendant = nil  --
    local initPreName1 = "headIcon"
    local initPreName2 = "headPendant"
    local initCreateCover = true
        
    local icon = data.icon
    local pendant = data.pendant
    local frameId = data.frameId -- 头像框的frameId

    self._customHeadIcon = data.customHeadIcon
    self._playerId = data.playerId

    self._isDownloadCallback = data.isDownloadCallback

    local isNotModifyCache = true --没有修改
    if self._iconImg ~= nil then
        local cacheId = self._iconImg.cacheId
        local nowCacheId = TextureManager:getCacheId(self._iconImg.url)
        isNotModifyCache = cacheId == nowCacheId
    end
    --logger:error("===============>UIHeadImg:updateData icon:%s, self._lastIcon:%s", icon, self._lastIcon)
    if isNotModifyCache and icon == self._lastIcon and pendant == self._lastPendant and frameId == self._lastFrameId then
        --logger:error("头像数据没变化，不走刷新。")
        return
    end

    if self._pendantImg then --兼容如果之前有挂件，现在没有挂件的情况
        self._pendantImg:setVisible(false)
    end
    
    local preName1 = data.preName1
    local preName2 = data.preName2
    local isCreatPendant = data.isCreatPendant
    local isCreatButton = data.isCreatButton
    local isSettingPanel = data.isSettingPanel
    local isCreatCover = data.isCreatCover

    local isBattleHead = data.isBattleHead
    -- 头像容错
    if icon == nil then
        icon = initHead
        -- logger:error("-- icon == nil >>> 显示头像容错00")
    elseif icon == 1 or icon == self._noticeHead then --系统公告头像
        icon = self._noticeHead
    elseif icon == self._nullHead then 
       -- icon = 0
       -- print("..................卧槽. icon = 0 ")
    elseif isBattleHead ~= nil then
        logger:info("战斗头像显示：".. icon)
    else
        local conf = ConfigDataManager:getConfigData(ConfigData.HeadPortraitConfig)
--        local isHave = false 
--        for k,v in pairs(conf) do
--            if v.id == icon then
--                isHave = true
--                break
--            end
--        end
        
        local isHave = conf[icon] ~= nil 
        if icon >= CustomHeadManager.CUSTOM_HEAD_ID then
            isHave = true
        end

        if isHave == false and initPreName1 == preName1 then -- 判断有问题
            icon = initHead
            --logger:error("-- isHave == nil >>> 显示头像容错11")
        end
    end

    -- 挂件容错
    if pendant == nil then
        pendant = initPendant
        isCreatPendant = false
    else
        local conf = ConfigDataManager:getConfigData(ConfigData.PendantConfig)
--        local isHave = false
--        for k,v in pairs(conf) do
--            if v.id == pendant then
--                isHave = true
--                pendant = v.icon
--                break
--            end
--        end
        local isHave = conf[pendant] ~= nil 
        if isHave == false then
            pendant = initPendant
        end
        isCreatPendant = isHave
    end

    -- 聊天才显示挂件?
    if rawget(data, "isChat") == nil and isCreatPendant then
        isCreatPendant = false
    end

    if preName1 == nil then
        preName1 = initPreName1
    end

    if preName2 == nil then
        preName2 = initPreName2
    end

    if isCreatCover == nil then
        isCreatCover = initCreateCover
    end

    if icon == nil then
        return
    else
        if icon == self._nullHead then 
            self:updateOnlyPendant(icon, pendant, preName1, preName2, isCreatPendant, isCreatButton, isSettingPanel, isCreatCover, frameId)
        else
            self:updateHead(icon, pendant, preName1, preName2, isCreatPendant, isCreatButton, isSettingPanel, isCreatCover, frameId)
        end
        
    end
    
    self._lastPendant = pendant
    self._lastFrameId = frameId

end

------------------------------
-- 默认设置头像背景框为空图
function UIHeadImg:updateHead(icon, pendant, preName1, preName2, isCreatPendant, isCreatButton, isSettingPanel, isCreatCover, frameId)
    -- 头像框    
    if self._headNode == nil then
        --local bg = TextureManager:createImageView("images/newGui1/none.png")        
        local size = self._parent:getContentSize()
        local headNode = ccui.Widget:create()
        headNode:setPosition(size.width/2, size.height/2)
        self._parent:addChild(headNode)
        self._headNode = headNode

        local function onNodeEvent(event)
            if event == "enter" then
            elseif event == "enterTransitionFinish" then
            elseif event == "exit" then
                self:finalizeCCB()
            elseif event == "exitTransitionDidStart" then
            elseif event == "cleanup" then
            end
        end
        self._headNode:registerScriptHandler(onNodeEvent)

        self._iconBg = TextureManager:createImageView("images/component/HeroHeadBg100.png")  
        self._iconBg:setLocalZOrder(UIHeadImg.ZORDER_ICON_BG)
        headNode:addChild(self._iconBg)

        self._iconFrame = TextureManager:createImageView("images/component/HeroHeadFrame100.png")  
        self._iconFrame:setLocalZOrder(UIHeadImg.ZORDER_ICON_FRAME)
        headNode:addChild(self._iconFrame)          
    end
    self:updateHeadImg(icon, preName1)
    
--    -- 按钮
--    if isCreatButton == true then
--        -- 不要相框
--        -- print("....................................... -- 不要相框")
--        self:createButton()
--    elseif isCreatCover then
--        -- print("....................................... -- 没按钮 则创建相框")
--        -- 没按钮 则创建相框
--        if self._headCover == nil then
--            self:addHeadCoverImg(isSettingPanel,preName1)
--        end
--    end

    
    -- start 当前版本暂时屏蔽挂件----------------------------------------------------------
    -- 挂件
    if isCreatPendant == true and pendant then
         self:updateHeadPendant(pendant, preName2)
    end
    -- end   当前版本暂时屏蔽挂件----------------------------------------------------------
    
    -- 头像框
    self:setHeadTopFrame(frameId)

end
-- 兼容单独展示挂件
function UIHeadImg:updateOnlyPendant(icon, pendant, preName1, preName2, isCreatPendant, isCreatButton, isSettingPanel, isCreatCover, frameId)
    -- 头像框    
    if self._headNode == nil then
        --local headNode = TextureManager:createImageView("images/newGui1/none.png")        
        local size = self._parent:getContentSize()
        self._headNode = cc.Node:create()
        self._headNode:setPosition(size.width/2, size.height/2)
        self._parent:addChild(self._headNode)
    end
    

    self._headNode:setVisible(true)
    -- local url = "images/headIcon/000.png"
    
    self._lastIcon = icon
    local url = string.format("images/headIcon/%d.png",icon)
    if self._iconImg == nil then
        self._iconImg = TextureManager:createImageView(url)
        self._headNode:addChild(self._iconImg)
    else
        TextureManager:updateImageView( self._iconImg,url)
    end
    -- start 当前版本暂时屏蔽挂件----------------------------------------------------------
    -- 挂件
    if isCreatPendant == true and pendant then
         self:updateHeadPendant(pendant, "headPendant")
    end
    -- end   当前版本暂时屏蔽挂件----------------------------------------------------------

    self:setHeadTopFrame(frameId)
end

-- 增加头像相框覆盖图片
function UIHeadImg:addHeadCoverImg(isSettingPanel,preName1)
    -- 抛弃?   
    -- body
--    local url = "images/newGui2/Frame_head.png"
--    if isSettingPanel then
--        url = "images/setting/Bg_circletool.png"
--    end

--    if preName1=="headChatIcon" then
--        url = "images/gui/Frame_head_square.png"
--    end

--    local bg = TextureManager:createImageView(url)
--    self._headNode:addChild(bg)
--    self._headCover = bg
end

-- 创建头像
function UIHeadImg:updateHeadImg(icon, preName)
    -- if icon == self._nullHead then
    --     icon = "000.png"
    -- else
    --     icon = icon..".png"
    -- end

    self._headNode:setVisible(true)

    -- 创建Image
    if self._iconImg == nil then
        self._iconImg = ccui.ImageView:create() 
        self._iconImg:setLocalZOrder(UIHeadImg.ZORDER_ICON)
        self._iconImg:setContentSize(cc.size(100, 100))
        self._iconImg:ignoreContentAdaptWithSize(false)
        self._headNode:addChild(self._iconImg)
    end
    self._iconImg:setTouchEnabled(self.isCreatButton)

    -- 是否使用玩家自定义头像
    local isUseCustomImg = false

    -- 使用玩家自定义头像

    --logger:error("===============>UIHeadImg:updateHeadImg1 icon:%s, self._playerId:%s", icon, self._playerId)
    if icon >= CustomHeadManager.CUSTOM_HEAD_ID and self._playerId ~= nil then --9999是个性头像，直接写死了
        local isFileExist, filename = CustomHeadManager:isCustomHeadExist(icon, self._playerId)
        --logger:error("===============>UIHeadImg:updateHeadImg2 isFileExist:%s", isFileExist)
        if isFileExist then
            isUseCustomImg = true
            self._lastIcon = icon
            TextureManager:updateImageViewFile(self._iconImg, filename) --直接用文件更新
        else
            ---------标记为自定义头像了，但是文件不存在，则开始下载
            local playerId = self._playerId
            local iconImg = self._iconImg
            local function callback()
                local isFileExist, filename = CustomHeadManager:isCustomHeadExist(icon, playerId)
                --logger:error("!!!!!!下载回调更新头像:%s!!!!!isFileExist:%s!!!!", filename, tostring(isFileExist))
                if isFileExist then
                    self._lastIcon = icon
                    TextureManager:updateImageViewFile(iconImg, filename)
                    iconImg:stopAllActions()
                end
            end
            --logger:error("===============>self._isDownloadCallback:%s, UIHeadImg:updateHeadImg3 icon:%s, self._playerId:%s", self._isDownloadCallback, icon, self._playerId)
            if self._isDownloadCallback == true then
                CustomHeadManager:downloadHeadPic(icon, self._playerId, callback)
            else
                CustomHeadManager:downloadHeadPic(icon, self._playerId, nil)
                local d = cc.DelayTime:create(1)
                local cb = cc.CallFunc:create(callback)
                local seq = cc.Sequence:create(d, cb)
                local rep = cc.Repeat:create(seq, 10)
                self._iconImg:stopAllActions()
                self._iconImg:runAction(rep)
            end
        end        
    end

    -- 使用配置表头像
    if isUseCustomImg == false then
        

        local newIcon = icon
        if icon >= CustomHeadManager.CUSTOM_HEAD_ID then  --9999有特殊用场了，用99999来代表个性头像
            newIcon = 9999
        end
        --logger:error("===============>UIHeadImg:updateHeadImg4 newIcon:%s", newIcon)
        self._lastIcon = newIcon
        local url = string.format("images/%s/%s.png", preName, newIcon)
        TextureManager:updateImageView(self._iconImg, url)
    end

end

-- 创建挂件
function UIHeadImg:updateHeadPendant(pendant, preName)
    local config = ConfigDataManager:getConfigById(ConfigData.PendantConfig, pendant)
    if config == nil then
        pendant = 101
    else
        pendant = config.icon
    end
    local pendantStr = pendant .. ".png"
    self._iconImg:setVisible(true)
    local url = string.format("images/%s/%s", preName, pendantStr)


    if self._pendantImg == nil then
        self._pendantImg = TextureManager:createImageView(url)
        self._pendantImg:setLocalZOrder(UIHeadImg.ZORDER_PENDANT)
        self._headNode:addChild(self._pendantImg)
    else
        self._pendantImg:setVisible(true)
        TextureManager:updateImageView(self._pendantImg, url)
    end

    local size2 = self._pendantImg:getContentSize()
    if config then
        local offsetTable = StringUtils:jsonDecode(config.movexy)
        self._pendantImg:setPositionY(size2.height + offsetTable[2])
        self._pendantImg:setPositionX(offsetTable[1])
    else
        self._pendantImg:setPositionY(size2.height)
    end
end

-- 创建头像外框
function UIHeadImg:setHeadTopFrame(frameId)
    if frameId == 0 then
        frameId = nil
    end

    if frameId == nil then
        if self._headFrame ~= nil then
            self:finalizeCCB()
            self._headFrame:removeFromParent()
            self._headFrame = nil
        end
    else
        local frameUrl = string.format(UIHeadImg.HEAD_HEAD_FRAMEICON, frameId) 
        if self._headFrame == nil then
            self._headFrame = TextureManager:createImageView(frameUrl)
            self._headFrame:setLocalZOrder(UIHeadImg.ZORDER_ICON_FRAMEICON)
            self._headNode:addChild(self._headFrame)
            self._headFrame:setPosition(0, 0)
            self._headFrame:setScale(1.25)
        else
            self._headFrame:setVisible(true)
            TextureManager:updateImageView(self._headFrame, frameUrl)
        end
    end

    -- 头像框特效
    if frameId == nil then
        self:finalizeCCB()
    elseif frameId ~= nil then
        self:finalizeCCB()
        local configInfo = ConfigDataManager:getConfigById(ConfigData.HeadFrameConfig, frameId)        
        if configInfo ~= nil and rawget(configInfo,"effectFrame") ~= nil then
            self._headFrameCcb = UICCBLayer.new(configInfo.effectFrame, self._headFrame)
            self._headFrameCcb:setPosition(60, 58)
        end
    end

end

-------------------------------------------------------------------------------
-- 创建VIP等级显示
--[[
传入参数vip等级，等级为0不显示
]]
function UIHeadImg:updateVIPLevel(num)
    print("-- 创建VIP等级显示 ",num)
    local function updateNum(num)
        if self._vipBg then
            self._vipBg:removeFromParent()
            self._vipBg = nil
        end
        if num == nil or num <= 0 then
            if self._vipImg then
                self._vipImg:removeFromParent()
                self._vipImg = nil
            end
            if self._vipNumTxt then
                self._vipNumTxt:removeFromParent()
                self._vipNumTxt = nil
            end
            return
        end

        local dstY = -42  --VIP的Y坐标
        if self._vipNumTxt == nil then
            -- V图片
            local vipImg = TextureManager:createImageView("images/chat/V.png")
            vipImg:setLocalZOrder(1000)
            vipImg:setAnchorPoint(cc.p(0, 0))
            vipImg:setPosition(-35,dstY)
            self._headNode:addChild(vipImg)
            self._vipImg = vipImg

            -- vip等级数字标签
            local text = ccui.TextAtlas:create()
            text:setProperty("1234567890", "ui/images/fonts/VIP123456789.png", 14, 23, "0")
            text:setLocalZOrder(1000)
            text:setAnchorPoint(cc.p(0, 0))
            text:setPosition(-35+self._vipImg:getContentSize().width,dstY)
            self._headNode:addChild(text)
            self._vipNumTxt = text
        end

        self._vipNumTxt:setString(num)

        -- 数量背景框        
        local url = "images/newGui2/Frame_prop_box_1.png"  
        local rect_table = cc.rect(10,0,1,1)   --小背景框的9宫格参数
        local vipBg = TextureManager:createScale9ImageView(url,rect_table)

        vipBg:setLocalZOrder(800)
        vipBg:setAnchorPoint(cc.p(0, 0))
        local bgPos = cc.p(-39,dstY)
        vipBg:setPosition(bgPos) ---这是小背景框的位置

        local vipImgWidth = self._vipImg:getContentSize().width
        local vipNumWidth = self._vipNumTxt:getContentSize().width
        local totalWidth = vipNumWidth + vipImgWidth
        bgPos.x = bgPos.x + vipImgWidth + 4
        totalWidth = totalWidth + 6

        self._vipNumTxt:setPosition(bgPos.x, bgPos.y)  ----这是vip等级数字标签的位置

        local initSize = vipBg:getContentSize()
        vipBg:setContentSize(initSize.width * totalWidth / 25, initSize.height)
        vipBg:setName("vipBg")
        self._headNode:addChild(vipBg)
        self._vipBg = vipBg
    end
    
    updateNum(num)

end
-------------------------------------------------------------------------------

-- 单独对头像的图片缩放
function UIHeadImg:setHeadScale(float)
    self._iconImg:setScale(float)
end

-- 整个头像控件缩放
function UIHeadImg:setScale(float)
    self._headNode:setScale(float)
end

function UIHeadImg:getNode()
    return self._headNode
end

-- 承载特效的层
function UIHeadImg:getVipEffectNode()
    local vipNode = self._headNode:getChildByName("vipEffectNode")
    if vipNode == nil then
        --logger:info("================>UIHeadImg:getVipEffectNode")
        vipNode = cc.Node:create()
        vipNode:setName("vipEffectNode")
        vipNode:setLocalZOrder(UIHeadImg.ZORDER_VIP_EFFECT)
        self._headNode:addChild(vipNode)
    end
    return vipNode
end


-------------------------------------------------------------------------------

function UIHeadImg:createButton()
    -- 抛弃?
--    local url=nil
--    local url2=nil
--    url = "images/newGui2/Frame_head.png"     --normal
--    url2 = "images/newGui2/Frame_head2.png"   --pressed
--    if self._button == nil then
--        -- print("···神秘感...UIHeadImg:createButton")

--        self._button = ccui.Button:create()
--        self._headNode:addChild(self._button)

--        local plist = TextureManager:getUIPlist(url)
--        cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
--        local plist2 = TextureManager:getUIPlist(url2)
--        cc.SpriteFrameCache:getInstance():addSpriteFrames(plist2)

--        self._button:loadTextures(url, url2, "", 1)
--    end

end

-- 获取头像按钮 在外部的panel里添加触摸事件
function UIHeadImg:getButton()
    --return self._button 
    return self._iconImg
end

-- 获取头像Icon
function UIHeadImg:getHeadIcon()
    return self._iconImg
end

-- 获取头像路径
function UIHeadImg:getHeadIconPath()
    return UIHeadImg.HEAD_CHAT_ICON_PATH 
end


------
-- 设置方形头像
-- @param  iconId [int] 头像id
function UIHeadImg:setHeadSquare(iconId)
    local iconId = iconId
    self._iconImg:setLocalZOrder(1)
    -- 专用方形头像icon
    local headUrl = string.format(self:getHeadIconPath(), iconId) 
    TextureManager:updateImageView( self._iconImg,headUrl)
--    if self:getButton() == nil then
--    -- 如果没按钮只换底图
--        TextureManager:updateImageView(self._headCover, UIHeadImg.HEAD_SQUARE_FRAME )

--    else
--    -- 有按钮换按钮材质
--        self._button:loadTextures(UIHeadImg.HEAD_SQUARE_FRAME, UIHeadImg.HEAD_SQUARE_FRAME, "", 1)
--    end
end

function UIHeadImg:runPendantAction()
    if self._pendantImg ~= nil then
        if  self._pendantImg:isVisible() then
            local scaleTo1 = cc.ScaleTo:create(0.4, 1.1)
            local scaleTo2 = cc.ScaleTo:create(0.4, 1)
            local seq = cc.Sequence:create(scaleTo1, scaleTo2)
            local action = cc.RepeatForever:create(seq)
            self._pendantImg:runAction(action)
        else
            self._pendantImg:stopAllActions()
        end
    end
end

--设置成透明底框
function UIHeadImg:setHeadTransparency()
--    local url = "images/gui/Frame_head_square.png"     --normal
--    local url2 = "images/gui/Frame_head_square.png"   --pressed

--    if self._button ~= nil then
--        local plist = TextureManager:getUIPlist(url)
--        cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
--        local plist2 = TextureManager:getUIPlist(url2)
--        cc.SpriteFrameCache:getInstance():addSpriteFrames(plist2)

--        self._button:loadTextures(url, url2, "", 1)
--    end
    self._iconBg:setVisible(false)
    self._iconFrame:setVisible(false)
end

function UIHeadImg:showHeadBg(isShow)
    self._iconBg:setVisible(isShow)
    if isShow then
        TextureManager:updateImageView(self._iconBg, "images/newGui1/IconHeadBg.png")
    end
end