
DramaPanel = class("DramaPanel", BasicPanel)
DramaPanel.NAME = "DramaPanel"

DramaPanel.CREATE_NODE_COUNT = 84
DramaPanel.CREATE_NODE_CD = 0.05
DramaPanel.FADE_IN_TIME_CHAR = 0.15
DramaPanel.FADE_IN_TIME_BG = 3
DramaPanel.DELAY_FINISH = 3
function DramaPanel:ctor(view, panelName)
    DramaPanel.super.ctor(self, view, panelName)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_POP_LAYER
end

function DramaPanel:finalize()

    if self._renderQueue ~= nil then
        self._renderQueue:finalize()
        self._renderQueue = nil
    end

    if self._ccbZj ~= nil then
        self._ccbZj:finalize()
        self._ccbZj = nil
    end

    if self._ccbZjLiZi ~= nil then
        self._ccbZjLiZi:finalize()
        self._ccbZjLiZi = nil
    end

    if self._finishAnima ~= nil then
        self._finishAnima:finalize()
        self._finishAnima = nil
    end

    if self._finishCCB ~= nil then
        self._finishCCB:finalize()
        self._finishCCB = nil
    end

    DramaPanel.super.finalize(self)
end

function DramaPanel:initPanel()
    DramaPanel.super.initPanel(self)

    self._panelBtn = self:getChildByName("panelBtn")
    self._btnSkip = self._panelBtn:getChildByName("btnSkip")




    self._panelMain = self:getChildByName("panelMain")
    self._panelMain:setTouchEnabled(false)
    self._imgBg = self._panelMain:getChildByName("imgBg")
    TextureManager:updateImageViewFile(self._imgBg, "bg/drama/dramaBg.jpg")
    self._imgBg:setPositionX(self._panelMain:getContentSize().width - self._imgBg:getContentSize().width / 2)
    

    self._panelCCBContainer = self._imgBg:getChildByName("panelCCBContainer")
    local containerSize = self._panelCCBContainer:getContentSize()
    self._ccbZj = self:createUICCBLayer("rgb-zj", self._panelCCBContainer)
    self._ccbZj:setPosition(containerSize.width / 2, containerSize.height / 2 - 60)


    local cx, cy = NodeUtils:getCenterPosition()
    self._ccbZjLiZi = self:createUICCBLayer("rgb-zj-lizi", self._panelMain)
    --self._ccbZjLiZi = self:createUICCBLayer("rgb-boss-smoke", self._panelMain)
    --self._ccbZjLiZi = self:createUICCBLayer("rgb-feixu", self._panelMain)
    --self._ccbZjLiZi = self:createUICCBLayer("rpg-xielian", self._panelMain)
    self._ccbZjLiZi:setPosition(cx, cy)
    self._ccbZjLiZi:setLocalZOrder(1)

--    self._panelMask = self._panelMain:getChildByName("panelMask")
--    self._panelMask:setOpacity(0)
--    self._panelMask:setLocalZOrder(2)

    -- 图片的删格遮罩
    self._imgMask = self._imgBg:getChildByName("imgMask")
    TextureManager:updateImageViewFile(self._imgMask, "bg/drama/dramaMask.png")

    self._renderQueue = FrameQueue.new(DramaPanel.CREATE_NODE_CD)

    self.charIndex = 0

    self:renderContentTxt()
end

function DramaPanel:registerEvents()
    DramaPanel.super.registerEvents(self)
    self:addTouchEventListener(self._btnSkip, self.onSkip)
end

function DramaPanel:doLayout()
end


function DramaPanel:renderContentTxt()
    -- TextWords[20] = "公元189年 董贼之乱"
    -- TextWords[21] = "十八路诸侯洛阳城下一聚"
    -- TextWords[22] = "乱局中联军得知玉玺下落"
    -- TextWords[23] = "联军群雄各自密谋夺玺大计"
    -- TextWords[24] = "导致袁军中计大败，且元气大伤"
    -- TextWords[25] = "自此，关东联军退出中华历史舞台"
    -- TextWords[26] = "一颗星光慢慢照耀出新的时代"

    self:moveBg()

    self:renderTitle()

    self:renderContent()

    self:renderFinish()
end

function DramaPanel:moveBg()
    local endPostion = self._imgBg:getContentSize().width / 2 - 125
    local endPos = cc.p(endPostion, self._imgBg:getPositionY())
    local ac = cc.MoveTo:create(DramaPanel.CREATE_NODE_COUNT * DramaPanel.CREATE_NODE_CD, endPos)
    self._imgBg:runAction(ac)
end

function DramaPanel:renderTitle()
    local titleStr = { { "公", "元", "一", "八", "九", "年", "董", "贼", "之", "乱" } }
    local titlePosX = 535
    local titlePosY = { 422, 383, 345, 306, 277, 239, 120, 80, 41, 2 }
    -- 上面的坐标是在self._panelMain上的坐标
    for x, col in pairs(titleStr) do
        for y, c in pairs(col) do
            self._renderQueue:pushParams(self.renderChar, self, titleStr, x, y, 24, titlePosX, titlePosY[y])
        end
    end
end

function DramaPanel:renderContent()
    local contentStr = {
        { "十", "八", "路", "诸", "侯", "洛", "阳", "城", "下", "一", "聚" },
        { "乱", "局", "中", "联", "军", "得", "知", "玉", "玺", "下", "落" },
        { "联", "军", "群", "雄", "各", "自", "密", "谋", "夺", "玺", "大", "计" },
        { "导", "致", "袁", "军", "中", "计", "大", "败", "且", "元", "气", "大", "伤" },
        { "自", "此", "关", "东", "联", "军", "退", "出", "中", "华", "历", "史", "舞", "台" },
        { "一", "颗", "星", "光", "慢", "慢", "照", "耀", "出", "新", "的", "时", "代" }
    }
    local aryPosX = { 466, 390, 321, 252, 184, 115 }
    local initPosY = 445
    local aryPoxYSpace = 40
    -- 上面的坐标是在self._panelMain上的坐标
    for x, col in pairs(contentStr) do
        for y, c in pairs(col) do
            self._renderQueue:pushParams(self.renderChar, self, contentStr, x, y, 30, aryPosX[x], initPosY - aryPoxYSpace *(y - 1))
        end
    end
end

function DramaPanel:renderFinish()
    self._renderQueue:pushParams(self.onFinish, self)
end

function DramaPanel:renderChar(strAry, indexX, indexY, fontSize, posX, poxY)

    
    local ac = cc.FadeIn:create(DramaPanel.FADE_IN_TIME_CHAR)
    local imgBgSize = self._imgBg:getContentSize()

    self.charIndex = self.charIndex + 1
    local url = string.format("images/drama/%02d.png", self.charIndex)
    local imgChar = ccui.ImageView:create()
    TextureManager:updateImageView( imgChar, url )
    imgChar:setPosition(posX - 360 + imgBgSize.width / 2, poxY - 200 + imgBgSize.height / 2)
    imgChar:setOpacity(0)
    imgChar:runAction(ac)
    imgChar:setLocalZOrder(10)
    self._imgBg:addChild(imgChar)

--    local txt = ccui.Text:create()
--    txt:setFontSize(fontSize)
--    txt:setString(strAry[indexX][indexY])
    -- posX，poxY是在self._panelMain上的坐标
--    txt:setPosition(posX - 320 + imgBgSize.width / 2, poxY - 200 + imgBgSize.height / 2)
--    txt:setOpacity(0)

--    txt:runAction(ac)
--    self._imgBg:addChild(txt)

end

function DramaPanel:endDrama()    

    TimerManager:addOnce(30, function() 
        self:dispatchEvent(DramaEvent.FINALIZE_SELF_EVENT, { }) 
        -- 103新版新手引导 这里就可以触发了
        --GuideManager:trigger(GuideManager.EndGuideId)
    end, self)
    
end

function DramaPanel:playFinishAnima()
    local cx, cy = NodeUtils:getCenterPosition()

    local owner = {}
    owner["pause"] = function() 
        self._panelMain:setVisible(false)
        self._panelBtn:setVisible(false)
    end
    owner["complete"] = function() 
        self:endDrama() 
    end
    self._finishCCB = self:createUICCBLayer("rgb-zj-huo", self:getPanelRoot(), owner)
    self._finishCCB:setPosition(cx, cy)
    self._finishCCB:setLocalZOrder(2)

    
end

function DramaPanel:onFinish()
    local d1 = cc.DelayTime:create(DramaPanel.DELAY_FINISH)
    local cb = cc.CallFunc:create(function() self:playFinishAnima() end)
    local seq = cc.Sequence:create(d1, cb)
    local root = self:getPanelRoot()
    root:runAction(seq)
end

function DramaPanel:onSkip(sender)
    local root = self:getPanelRoot()
    root:stopAllActions()
    sender:setVisible(false)
    self:playFinishAnima()
end