

UIGetProp = class("UIGetProp")

function UIGetProp:ctor(parent, panel,isShow,callfunc)
    local uiSkin = UISkin.new("UIGetProp")
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(640, 960))
    layout:setAnchorPoint(cc.p(0.5,0.5))
    local winSize = cc.Director:getInstance():getWinSize()
    layout:setPosition(winSize.width/2, winSize.height/2)
    parent:addChild(layout)
    local secLvBg = UIRewardTips.new(layout, self) -- 新版的底图框
    secLvBg:setContentHeight(560)
    --secLvBg:setTitle(TextWords:getTextWord(338))
    secLvBg:setBackGroundColorOpacity(0)

    
    uiSkin:setParent(layout)
    uiSkin:setVisible(false)
    layout:setVisible(false)

    secLvBg:setLocalZOrder(2)
     
    self._parent = layout
    self._uiSkin = uiSkin
    self._panel = panel
    self.secLvBg = secLvBg
    self.callfunc = callfunc
    self["pos5"] = {40, 151, 262, 373, 485}
    for i=1,4 do
        self["pos"..i] = {}
        for j=1,i do
            self["pos"..i][j] = 525/(i + 1) * j
        end
    end

    self.bgImg = self:getChildByName("mainPanel/bgImg")
    self.bgImg:setVisible(false)
    if self.posY == nil then
        self.posY = self.bgImg:getPositionY()
    end

    self.sureBtn = self:getChildByName("mainPanel/sureBtn")
    self.btnX = self.sureBtn:getPositionX()
    self.bgImgX = self.bgImg:getPositionX()
    self._mainPanel = self:getChildByName("mainPanel")
    uiSkin:setLocalZOrder(30)
    uiSkin:setTouchEnabled(true)
    self.sureBtn:setVisible(false)
end

function UIGetProp:setTitle(titileStr)
    --self.secLvBg:setTitle(titileStr)
end

function UIGetProp:hide()
    self._uiSkin:setVisible(false)
    self._parent:setVisible(false)
    if type(self.callfunc) == "function" then
        self.callfunc()
    end
end

function UIGetProp:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UIGetProp:playAction(callback, isHideEff)    
    -- 半透明背景坐标偏移的微调
    local size = self._uiSkin:getContentSize()
    local scale =  NodeUtils:getAdaptiveScale()
    local tmp = math.abs(scale - 1)/6
    scale = math.abs(scale - tmp)    
    self._uiSkin:setPosition(size.width/2 * scale, size.height/2)

    -- self._uiSkin:setOpacity(GameConfig.TwoLevelShells.OPACITY_MIN)
    -- self._uiSkin:setScale(0)
    -- self._parent:setVisible(true)

    self._parent:setScale(0)
    self.secLvBg:setBackGroundColorOpacity(0)
    self._parent:setVisible(true)
    self.callfunc = callback
    --self.secLvBg:setTitle(TextWords:getTextWord(131))
    --self.secLvBg:hideCloseBtn(false)
    self._uiSkin:setVisible(true)

    
    self._uiSkin:setAnchorPoint(cc.p(0.5,0.5))
    local actionScale = cc.ScaleTo:create(0.1, GameConfig.TwoLevelShells.SCALE_MAX)
    -- local actionFade = cc.FadeTo:create(0.5, GameConfig.TwoLevelShells.OPACITY_MAX)
    -- local actionSpawn = cc.Spawn:create(actionScale)--,actionFade)
    local function localcallback()
        -- self:renderAllGoods(info)
        -- self._parent:setVisible(true)
        --self:createEffect()
        self.secLvBg:setBackGroundColorOpacity(120)
        local function call()
            self:playEffect()
        end
        -- TimerManager:addOnce(60,call,self)  
        if not isHideEff then
            call() 
        end
    end
    self._parent:runAction(cc.Sequence:create(actionScale, cc.CallFunc:create(localcallback)))

end


function UIGetProp:show(info, callback, isHideEff)
    -- body
    self:renderAllGoods(info)  --先渲染道具
    self:playAction(callback, isHideEff)  --再播放动画

end

function UIGetProp:renderAllGoods(infos)
    self._uiSkin:setVisible(true)
    local scale = NodeUtils:getAdaptiveScale()
    local listView = self:getChildByName("mainPanel/ListView_1")

    ComponentUtils:renderAllGoods(listView, self.bgImg, self.secLvBg, self.sureBtn, infos, self._panel, true)

    -- local closeBtn = self:getChildByName("mainPanel/sureBtn")
    ComponentUtils:addTouchEventListener(self.sureBtn, self.hide, nil, self)
    ComponentUtils:addTouchEventListener(self._uiSkin.root,self.hide, nil, self)
end

-- 特效
function UIGetProp:createEffect()
    -- body
    local mainPanel = self:getChildByName("mainPanel")
    local size = mainPanel:getContentSize()
    if self.movieChip == nil then
        self.movieChip = UIMovieClip.new("rpg-Criticalpoints")
        self.movieChip:setParent(mainPanel)
        self.movieChip:setLocalZOrder(12)
        self.movieChip:setPosition(size.width / 2 - 5, size.height / 2 + 10)
    end
    self.movieChip:setVisible(true)
    self.movieChip:play(false,function () self.movieChip:setVisible(false) end)

    
end


-- 加载获得物品的背景特效
function UIGetProp:playEffect()
    -- 取得seclvbg下的mianpanel
    --local mianPanel = self.secLvBg:getMainPanel()
    --local ccbLayer = mianPanel.ccbLayer
    --if ccbLayer == nil then
    --    local ccbLayer = UICCBLayer.new("rgb-res-light", mianPanel)        
    --    local size = mianPanel:getContentSize()
    --    ccbLayer:setPosition(size.width/2,size.height/2)
    --    ccbLayer:setLocalZOrder(-1)
    --    ccbLayer:setVisible(true)
    --    mianPanel.ccbLayer = ccbLayer
    --else
    --    ccbLayer:setVisible(true)
    --end
end


function UIGetProp:infoTodouble(info)
    info = TableUtils:map2list(info)
    local tempInfo = {}
    local index = 1
    for i=1, #info, 5 do
        tempInfo[index] = tempInfo[index] or {}
        table.insert(tempInfo[index], info[i])
        table.insert(tempInfo[index], info[i+1])
        table.insert(tempInfo[index], info[i+2])
        table.insert(tempInfo[index], info[i+3])
        table.insert(tempInfo[index], info[i+4])
        index = index + 1
    end
    return tempInfo
end

function UIGetProp:scrollToEnd()
    self._listView:scrollToBottom(2.5,true)
end

function UIGetProp:renderItemPanel(item, data)
    if (not item) or (not data) then
        return
    end
    for i=1,5 do
        local icon = item:getChildByName("icon"..i)
        icon:setVisible(data[i] ~= nil)
        if data[i] then
            local uiIcon = icon.uiIcon
            if not uiIcon then
                uiIcon = UIIcon.new(icon, data[i], true, self._panel)
                icon.uiIcon = uiIcon
            else
                uiIcon:updateData(data[i])
            end
            uiIcon:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)

            local info = ConfigDataManager:getConfigByPowerAndID(data[i].power, data[i].typeid)
            local nameLab = icon:getChildByName("nameLab")
            nameLab:setString(info.name)
            local color = ColorUtils:getColorByQuality(info.color or 1)
            nameLab:setColor(color)
        end
    end
    self:adjustIconPos(item, #data)
end

function UIGetProp:adjustIconPos(item, lenght)
    local posData = self["pos"..lenght]
    for i=1, lenght do
        local icon = item:getChildByName("icon"..i)
        icon:setPositionX(posData[i])
    end
end

function UIGetProp:removeFromParent()
    if self.movieChip ~= nil then
        self.movieChip:finalize()
    end
    self._parent:removeChild(self._uiSkin, true)
end

--外部 设置==================================
function UIGetProp:setBtnState( strTitleText, isGray )
    if strTitleText then
        self.sureBtn:setTitleText( strTitleText )
    end
    self.sureBtn:setColor( isGray and ColorUtils.wordGreyColor or ColorUtils.wordWhiteColor )
end
function UIGetProp:setBtnCallback( callback )
    ComponentUtils:addTouchEventListener(self.sureBtn, function()
        callback()
        self:hide()
    end)
end

function UIGetProp:finalize()
    self:removeFromParent()
end