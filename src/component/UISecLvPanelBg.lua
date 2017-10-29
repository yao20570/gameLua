-----------------------
--[[
通用二级弹窗背景控件

参数
panel:    点击弹窗关闭按钮时会关闭panel,默认值nil  
extra：   自定义关闭按钮的回调函数,默认值nil  
isTipBg ：true表示显示UITip弹窗的背景,默认值nil  

示例：
if extra ~= nil then
    self._closeBtnType = extra["closeBtnType"]  -- 0=隐藏panel 1=隐藏uiskin
    self._closeCallback = extra["callBack"]     -- 关闭按钮的回调
    self._obj = extra["obj"]       
end

接口：
UISecLvPanelBg:setTitle(title, isImg, color)    设置弹窗标题接口， isImg=true标题为图片
UISecLvPanelBg:setContentHeight(height)         设置弹窗高度接口
UISecLvPanelBg:hideCloseBtn(isShow)             设置弹窗关闭按钮可见性接口
UISecLvPanelBg:setBackGroundColorOpacity(opacity) 设置全屏遮罩透明度
]]

-------------------
UISecLvPanelBg = class("UISecLvPanelBg")

function UISecLvPanelBg:ctor(parent, panel, extra, isTipBg)
    local uiSkin = UISkin.new("UISecLvPanelBg")
    uiSkin:setParent(parent)
    uiSkin:setName("UISecLvPanelBg")
    self._panel = panel
    self._uiSkin = uiSkin


    self._mainPanel = uiSkin:getChildByName("mainPanel")
    self._frameTop = uiSkin:getChildByName("mainPanel/frameTop")
    self._frameMiddle = uiSkin:getChildByName("mainPanel/frameMiddle")
    self._frameBottom = uiSkin:getChildByName("mainPanel/frameBottom")
    self._MidBlackBg = uiSkin:getChildByName("mainPanel/bg")--中间的黑底一层
    
    self._nameTxt = self._frameTop:getChildByName("nameTxt")
    self._titleImg = self._frameTop:getChildByName("titleImg")

    self._mainPanel:setTouchEnabled(false)
    uiSkin:setTouchEnabled(false)

    
    local allFrames = {}
    allFrames[1] = self._frameTop
    allFrames[2] = self._frameMiddle
    allFrames[3] = self._frameBottom
    self._isTipBg = isTipBg or false
    
    self:setAliasTexParameters(self._isTipBg,allFrames)

    self._tileWidget = UITileWidget.new(self._frameMiddle)


    if extra ~= nil then
        self._closeBtnType = extra["closeBtnType"]  -- 0=隐藏panel 1=隐藏uiskin
        self._closeCallback = extra["callBack"]     -- 关闭按钮的回调
        self._obj = extra["obj"]       
    end

    self:registerEvents()
end

function UISecLvPanelBg:finalize()
    self._uiSkin:finalize()
end

function UISecLvPanelBg:setVisible(visible)
    self._uiSkin:setVisible(visible)
end

function UISecLvPanelBg:setIsShowName(isShow,content, isImg)
    if isShow == true then
        self._nameTxt:setVisible(true)
        self:setTitle(content, isImg)
    else
        self._nameTxt:setVisible(false)
        self._titleImg:setVisible(false)
    end
end

function UISecLvPanelBg:getCloseBtn()
    return self._btnClose
end

function UISecLvPanelBg:setAliasTexParameters(isTipBg,allFrames)
    -- body
    --local urlTab = {}
    ---- 二级弹窗资源
    --urlTab[1] = {   
    --    "images/newGui9Scale/Frame_top.png",
    --    "images/newGui9Scale/Frame_middle.png",
    --    "images/newGui9Scale/Frame_bottom.png",
    --}
    ----UItip弹窗资源
    --urlTab[2] = {   
    --    "images/guiScale9/Frame_tip_top.png",
    --    "images/guiScale9/Frame_tip_middle.png",
    --    "images/guiScale9/Frame_tip_down.png",
    --}
        
    local curUrlTab = {   
        "images/newGui9Scale/Frame_top.png",
        "images/newGui9Scale/Frame_middle.png",
        "images/newGui9Scale/Frame_bottom.png",
    }

    if isTipBg then
        --curUrlTab = urlTab[2]
        --self:setTitle("")           --tip弹窗标题为空
        if self._bgImg == nil then
            self._bgImg = TextureManager:createScale9ImageView("images/newGui9Scale/SpTanChuangHeiDi.png", cc.rect(3, 3, 1, 1))
            self._bgImg:setAnchorPoint(0, 0.5)--self._frameMiddle:setContentSize
            self._frameMiddle:addChild(self._bgImg)
        end

        self:hideCloseBtn(false)    --tip弹窗隐藏关闭按钮
    else
        --curUrlTab = urlTab[1]
    end
 

    local texture
    for k,url in pairs(curUrlTab) do
        texture = TextureManager:getUITexture(url)
        texture:setAliasTexParameters()
        TextureManager:updateImageView(allFrames[k],url)
    end

end

---[[
--设置背景高度，frameMiddle进行克隆平铺
---]]

function UISecLvPanelBg:setContentHeight(height)
    local sizeTop = self._frameTop:getContentSize()
    local sizeMiddle = self._frameMiddle:getContentSize()
    local sizeBottom = self._frameBottom:getContentSize()
    
    local tileHeight = height - sizeTop.height - sizeBottom.height+5
    --self._tileWidget:setContentHeight(tileHeight)
    
    self._frameMiddle:setContentSize(cc.size(sizeMiddle.width,tileHeight))

    -- local tileY = self._tileWidget:getPositionY()
    
    -- self._frameTop:setPositionY(tileY + tileHeight / 2 + sizeTop.height / 2 )
    -- self._frameBottom:setPositionY(tileY - tileHeight / 2 - sizeBottom.height / 2)
    
    local winSize = cc.Director:getInstance():getWinSize()
    local midPosition = cc.p(winSize.width/2,winSize.height/2)
    local half = height / 2 

    local topY = midPosition.y + half - sizeTop.height/2
    self._frameTop:setPositionY(topY-8)

    local bottomY = midPosition.y - half + sizeBottom.height/2
    self._frameBottom:setPositionY(bottomY-7)

    local midY = (topY-sizeTop.height/2 + bottomY+sizeBottom.height/2)/2 
    self._frameMiddle:setPositionY(midY-7)
    self._frameMiddle:setAnchorPoint(cc.p(0.5,0.5))

    -- local sizeTopAndBottom = sizeTop.height + sizeBottom.height


    if self._isTipBg then
        self._bgImg:setContentSize(cc.size(self._bgImg:getContentSize().width, self._frameMiddle:getContentSize().height))
        self._bgImg:setPositionX((self._frameMiddle:getContentSize().width - self._bgImg:getContentSize().width) * 0.5)
        self._bgImg:setPositionY(self._bgImg:getPositionY() + self._frameMiddle:getContentSize().height * 0.5)
    end

    -- self:updateOtherPos()    
end

--设置弹窗背景高度
--param isVisible:是否可见
--param distance_up:离最上边距离,最小为0
--param distance_down:离最下面距离,最小为0
function UISecLvPanelBg:setTanChuangBgSize(isVisible,distance_up,distance_down)
    self._MidBlackBg:setVisible(isVisible or false)

    if not distance_up then
        distance_up = 0
    elseif distance_up < 0 then
        distance_up = 0
    end

    if not distance_down then
        distance_down = 0
    elseif distance_down < 0 then
        distance_down = 0
    end

    local size = self._frameMiddle:getContentSize()

    local height = size.height - distance_up - distance_down
    if height <= 0 then
        logger:error("弹窗黑色背景设置值 <= 0 ,我设置看不到弹窗背景")
        self._MidBlackBg:setVisible(false)
        return
    end

    self._MidBlackBg:setContentSize(cc.size(self._MidBlackBg:getContentSize().width,height))

    local frameMiddleMidPointY = self._frameMiddle:getPositionY()

    local toY = frameMiddleMidPointY - size.height/2 + distance_down + height / 2
    self._MidBlackBg:setPositionY(toY)


end

function UISecLvPanelBg:updateOtherPos()
    -- body
    local topX,topY = self._frameTop:getPosition()
    local sizeTop = self._frameTop:getContentSize()

    local btnClose = self._btnClose
    local closeSize = btnClose:getContentSize()
    local nameSize = self._nameTxt:getContentSize()
    local nameImgSize = self._titleImg:getContentSize()
    btnClose:setPositionX(topX + sizeTop.width/2 - closeSize.width)
    
    -- local visSize = cc.Director:getInstance():getVisibleSize()
    -- local winSize = cc.Director:getInstance():getWinSize()
    -- self._nameTxt:setPositionX(winSize.width/2 - nameSize.width/2)
    -- self._titleImg:setPositionX(topX - nameImgSize.width/2)

end

function UISecLvPanelBg:setTitle(title, isImg, color)
    
    local color = color or ColorUtils.wordTitleColor--ColorUtils.wordOrangeColor
    self._nameTxt:setColor(color)
    self._nameTxt:setFontSize(24)
    
    self._nameTxt:setString(title)
    self._nameTxt:setVisible(true)
    self._titleImg:setVisible(false)
    if isImg == true then
        local url = string.format("images/titleIcon/%s.png", title)
        TextureManager:updateImageView(self._titleImg,url)
        self._titleImg:setVisible(true)
        self._nameTxt:setVisible(false)
    end
end

function UISecLvPanelBg:setHtmlStr(htmlStr)
	if htmlStr ~= nil then
        self._btnHelp.htmlStr = htmlStr
        self._btnHelp:setVisible(true)
    else
        self._btnHelp:setVisible(false)
	end
end

------------------------
function UISecLvPanelBg:registerEvents()
    self._btnClose = self._frameTop:getChildByName("btnClose")
    self._btnClose:addTouchRange(20, 20)
    self._btnClose.type = self._closeBtnType or 0
    self:hideCloseBtn(true)
    ComponentUtils:addTouchEventListener(self._btnClose, self.onCloseTouch, nil, self)

    self._btnHelp = self._frameTop:getChildByName("btnHelp")
    self._btnHelp:addTouchRange(20, 20)
    self._btnHelp:setVisible(false)
    ComponentUtils:addTouchEventListener(self._btnHelp, self.onHelp, nil, self)
end

function UISecLvPanelBg:onCloseTouch(sender)
    if sender.type == 0 then
        self._panel:hide()
    else
        self._uiSkin:setVisible(false)
        self._closeCallback(self._obj)
    end
end

function UISecLvPanelBg:onHelp(sender)
    logger:info("===========UISecLvPanelBg:onHelpTouch===========")    
    if sender.htmlStr ~= nil then
        SDKManager:showWebHtmlView(sender.htmlStr)
    end
end

function UISecLvPanelBg:setBackGroundColorOpacity(opacity)
    opacity = opacity or 120
    self._uiSkin:setBackGroundColorOpacity(opacity)
end

function UISecLvPanelBg:hideCloseBtn(isShow)    
    self._btnClose = self._btnClose or self._frameTop:getChildByName("btnClose")
    self._btnClose:setVisible(isShow)
end

function UISecLvPanelBg:setLocalZOrder( order )
    -- body
    self._uiSkin:setLocalZOrder(order)
end

------
-- 获取此界面的MainPanel
function UISecLvPanelBg:getMainPanel()
    return self._mainPanel
end

function UISecLvPanelBg:setTouchEnabled(isTrue)
    -- body
    self._uiSkin:setTouchEnabled(isTrue)
end

function UISecLvPanelBg:hideAllUI(bool)
    self._mainPanel:setVisible(false)
end

function UISecLvPanelBg:ShowBg()
    if self._bgImg == nil then
        self._bgImg = TextureManager:createScale9ImageView("images/newGui9Scale/SpTanChuangHeiDi.png", cc.rect(3, 3, 1, 1))
        self._frameMiddle:addChild(self._bgImg)
    end
    self._bgImg:setAnchorPoint(0, 0)--self._frameMiddle:setContentSize
    self._bgImg:setVisible(true)
    self._bgImg:setContentSize(cc.size(self._bgImg:getContentSize().width, self._frameMiddle:getContentSize().height - 350))
    self._bgImg:setPositionX((self._frameMiddle:getContentSize().width - self._bgImg:getContentSize().width) * 0.5)
    self._bgImg:setPositionY(75)
end