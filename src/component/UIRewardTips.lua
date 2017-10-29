-----------------------
--[[
通用二级弹窗背景控件

参数
panel:    点击弹窗关闭按钮时会关闭panel,默认值nil  
extra：   自定义关闭按钮的回调函数,默认值nil  

示例：
if extra ~= nil then
    self._closeBtnType = extra["closeBtnType"]  -- 0=隐藏panel 1=隐藏uiskin
    self._closeCallback = extra["callBack"]     -- 关闭按钮的回调
    self._obj = extra["obj"]       
end

接口：
UIRewardTips:setContentHeight(height)         设置弹窗高度接口
UIRewardTips:setBackGroundColorOpacity(opacity) 设置全屏遮罩透明度
]]

-------------------
UIRewardTips = class("UIRewardTips")

function UIRewardTips:ctor(parent, panel, extra)
    local uiSkin = UISkin.new("UIRewardTips")
    uiSkin:setParent(parent)
    uiSkin:setName("UIRewardTips")
    self._panel = panel
    self._uiSkin = uiSkin


    self._mainPanel = uiSkin:getChildByName("mainPanel")
    self._frameTop = uiSkin:getChildByName("mainPanel/frameTop")
    self._frameMiddle = uiSkin:getChildByName("mainPanel/frameMiddle")
    self._frameBottom = uiSkin:getChildByName("mainPanel/frameBottom")


    self._imgEffectTop = uiSkin:getChildByName("mainPanel/effectTop")
    self._imgEffectBottom = uiSkin:getChildByName("mainPanel/effectBottom")
    
    if self._effectTop == nil then
        self._effectTop = UICCBLayer.new("rgb-res-light", self._imgEffectTop)
    end
    if self._effectBottom == nil then
        self._effectBottom = UICCBLayer.new("rgb-res-light", self._imgEffectBottom)
            self._imgEffectBottom:setRotation(180)
    end

    self._mainPanel:setTouchEnabled(false)
    uiSkin:setTouchEnabled(true)

    
    local allFrames = {}
    allFrames[1] = self._frameTop
    allFrames[2] = self._frameMiddle
    allFrames[3] = self._frameBottom


    if extra ~= nil then
        self._closeBtnType = extra["closeBtnType"]  -- 0=隐藏panel 1=隐藏uiskin
        self._closeCallback = extra["callBack"]     -- 关闭按钮的回调
        self._obj = extra["obj"]       
    end
    
--    ComponentUtils:addTouchEventListener(uiSkin.root,self.onCloseTouch, nil, self)
    --self:registerEvents()
end

function UIRewardTips:finalize()
    self._uiSkin:finalize()

    if self._effectTop then
        self._effectTop:finalize()
        self._effectTop = nil
    end
    if self._effectBottom then
        self._effectBottom:finalize()
        self._effectBottom = nil
    end
end

function UIRewardTips:setVisible(visible)
    self._uiSkin:setVisible(visible)
end

---[[
--设置背景高度，frameMiddle进行克隆平铺
---]]

function UIRewardTips:setContentHeight(height)
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
    
    self._imgEffectTop:setPositionY(self._frameTop:getPositionY() + 15)
    self._imgEffectBottom:setPositionY(self._frameBottom:getPositionY() - 15)
end

function UIRewardTips:updateOtherPos()
    -- body
    --local topX,topY = self._frameTop:getPosition()
    --local sizeTop = self._frameTop:getContentSize()
    --
    --local closeBtn = self._frameTop:getChildByName("closeBtn")
    --local closeSize = closeBtn:getContentSize()
    --local nameSize = self._nameTxt:getContentSize()
    --local nameImgSize = self._titleImg:getContentSize()
    --closeBtn:setPositionX(topX + sizeTop.width/2 - closeSize.width)
    
    -- local visSize = cc.Director:getInstance():getVisibleSize()
    -- local winSize = cc.Director:getInstance():getWinSize()
    -- self._nameTxt:setPositionX(winSize.width/2 - nameSize.width/2)
    -- self._titleImg:setPositionX(topX - nameImgSize.width/2)

end

------------------------
function UIRewardTips:registerEvents()
    --local closeBtn = self._frameTop:getChildByName("closeBtn")
    --closeBtn.type = self._closeBtnType or 0
    --self:hideCloseBtn(true)
    --ComponentUtils:addTouchEventListener(closeBtn, self.onCloseTouch, nil, self)
    ComponentUtils:addTouchEventListener(self._uiSkin.root,self.onCloseTouch, nil, self)
end

function UIRewardTips:onCloseTouch(sender)
    --if sender.type == 0 then
    --    self._panel:hide()
    --else
    --    self._uiSkin:setVisible(false)
    --    self._closeCallback(self._obj)
    --end
    
    self._panel:hide()
end

function UIRewardTips:setBackGroundColorOpacity(opacity)
    opacity = opacity or 120
    self._uiSkin:setBackGroundColorOpacity(opacity)
end


function UIRewardTips:setLocalZOrder( order )
    -- body
    self._uiSkin:setLocalZOrder(order)
end

------
-- 获取此界面的MainPanel
function UIRewardTips:getMainPanel()
    return self._mainPanel
end

function UIRewardTips:setTouchEnabled(isTrue)
    -- body
    self._uiSkin:setTouchEnabled(isTrue)
end

function UIRewardTips:hideAllUI(bool)
    self._mainPanel:setVisible(false)
end
