UIPanelBg = class("UIPanelBg")

function UIPanelBg:ctor(parent, closeCallback)
    local uiSkin = UISkin.new("UIPanelBg")
    uiSkin:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    local bgImg = uiSkin:getChildByName("bgImg")
    -- TextureManager:updateImageViewFile(bgImg,"bg/ui/Bg_background.pvr.ccz")
    NodeUtils:adaptive(bgImg)
    local bgImg2 = uiSkin:getChildByName("bgImg2")
    NodeUtils:adaptive(bgImg2)
    local bgImg3 = uiSkin:getChildByName("bgImg3")
    NodeUtils:adaptive(bgImg3)
    local bgImg3_1 = uiSkin:getChildByName("bgImg3_1")
    NodeUtils:adaptive(bgImg3_1)
    local bgImgR = uiSkin:getChildByName("bgImgR")      --深色
    NodeUtils:adaptive(bgImgR)
    local bgImgR2 = uiSkin:getChildByName("bgImgR2")    --浅色
    NodeUtils:adaptive(bgImgR2)
    local bgImgR3 = uiSkin:getChildByName("bgImgR3")    --浅色 半封闭
    NodeUtils:adaptive(bgImgR3)
    local bgImg4 = uiSkin:getChildByName("bgImg4")      --名匠背景
    NodeUtils:adaptive(bgImg4)
    local bgImg5 = uiSkin:getChildByName("bgImg5")      --全屏黑色背景
    NodeUtils:adaptive(bgImg5)
    local bgImg6 = uiSkin:getChildByName("Panel_27")      --全屏黑色背景

 
    uiSkin:setParent(parent)
    self.titlePanel = uiSkin:getChildByName("titlePanel")
    self.titlePanel:setTouchEnabled(false)


    -- local bgImg3_10 = uiSkin:getChildByName("bgImg3_10")
    self._bgImg = bgImg
    --默认黑色面板
    self._bgImg3 = bgImg3    
    self._bgImg3_1 = bgImg3_1
    -- self._bgImg3_10 = bgImg3_10
    self._bgImgR = bgImgR
    self._bgImgR2 = bgImgR2
    self._bgImgR3 = bgImgR3
    self._bgImg4 = bgImg4
    self._bgImg5 = bgImg5
    self._bgImg6 = bgImg6
    self._htmlStr = nil
    self._bgImgMap = {self._bgImg3,self._bgImg3_1,self._bgImgR,self._bgImgR2,self._bgImgR3,self._bgImg4,self._bgImg5, self._bgImg6}

    self._uiSkin = uiSkin
    self._closeCallback = closeCallback
    
    self:setBgType(ModulePanelBgType.BACK)
    self:setDownLineStatus(false)
    self:registerEvents()

end

function UIPanelBg:finalize()
    self._uiSkin:finalize()
end

function UIPanelBg:setBgImg3Tab()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local winSize = cc.Director:getInstance():getWinSize()
    local scale = winSize.width / visibleSize.width
    
    local dy = 110
    local size = self._bgImg3:getContentSize()
    self._bgImg3:setContentSize(size.width, size.height - dy ) --* scale
    self._bgImg3_1:setContentSize(size.width, size.height - dy )
    self._bgImg3:setVisible(false)
    self._bgImg3_1:setVisible(false)

    local sizeR = self._bgImgR:getContentSize()
    self._bgImgR:setContentSize(sizeR.width, sizeR.height - dy )
    self._bgImgR2:setContentSize(sizeR.width, sizeR.height - dy )
    self._bgImgR:setVisible(false)
    self._bgImgR2:setVisible(false)
    
    local sizeR3 = self._bgImgR3:getContentSize()
    self._bgImgR3:setContentSize(sizeR3.width, sizeR3.height - dy )
    self._bgImgR3:setVisible(false)
    
end

--获取背景的高度Y坐标
function UIPanelBg:getBgTopY()
    local size = self._bgImg3:getContentSize()
    local x, y = self._bgImg3:getPosition()
    
    return x + size.height / 2
end

--设置背景类型
function UIPanelBg:setBgType(type)
    local target1 = nil
    local target2 = nil
    self.bgType = type
    -- self._bgImg:setVisible(type ~= ModulePanelBgType.BATTLE)
    self.titlePanel:setLocalZOrder(10008)
    self._bgImg6:setLocalZOrder(2)
    if type == ModulePanelBgType.BACK then
        -- self._bgImgR3:setVisible(false)
        -- self._bgImgR2:setVisible(false)
        -- self._bgImgR:setVisible(false)
        -- self._bgImg3:setVisible(true)  
        -- self._bgImg3_1:setVisible(false)
        -- self._bgImg3_10:setVisible(false)
        target1 = self._bgImg3
    elseif type == ModulePanelBgType.WHITE then
        -- self._bgImgR3:setVisible(false)
        -- self._bgImgR2:setVisible(false)
        -- self._bgImgR:setVisible(false)
        -- self._bgImg3:setVisible(false)  
        -- self._bgImg3_1:setVisible(true)
        -- self._bgImg3_10:setVisible(true)
        target1 = self._bgImg3_1
        TextureManager:updateImageViewFile(self._bgImg3_1,"bg/ui/Bg_teamset.pvr.ccz")
        -- target2 = self._bgImg3_10
    elseif type == ModulePanelBgType.BACKR then
        -- self._bgImgR3:setVisible(false)
        -- self._bgImgR2:setVisible(false)
        -- self._bgImgR:setVisible(true)
        -- self._bgImg3:setVisible(false)  
        -- self._bgImg3_1:setVisible(false)
        -- self._bgImg3_10:setVisible(false)
        target1 = self._bgImgR
    elseif type == ModulePanelBgType.BACKR_WHITER then
        -- self._bgImgR3:setVisible(false)
        -- self._bgImgR2:setVisible(true)
        -- self._bgImgR:setVisible(true)
        -- self._bgImg3:setVisible(false)  
        -- self._bgImg3_1:setVisible(false)
        -- self._bgImg3_10:setVisible(false)
        target1 = self._bgImgR
        target1 = self._bgImgR2
    elseif type == ModulePanelBgType.BACKR_WHITER2 then
        -- self._bgImgR3:setVisible(true)
        -- self._bgImgR2:setVisible(false)
        -- self._bgImgR:setVisible(true)
        -- self._bgImg3:setVisible(false)  
        -- self._bgImg3_1:setVisible(false)
        -- self._bgImg3_10:setVisible(false)
        target1 = self._bgImgR
        target1 = self._bgImgR3
    elseif type == ModulePanelBgType.NONE then
        -- self._bgImgR3:setVisible(false)
        -- self._bgImgR2:setVisible(false)
        -- self._bgImgR:setVisible(false)
        -- self._bgImg3:setVisible(false)  
        -- self._bgImg3_1:setVisible(false)
        -- self._bgImg3_10:setVisible(false)
    elseif type == ModulePanelBgType.LOTTERY then
        target1 = self._bgImg4
    elseif type == ModulePanelBgType.BLACKFULL then
        target1 = self._bgImg5
    elseif type == ModulePanelBgType.BATTLE then
        target1 = self._bgImg6
        self:initBattleBg()
        TimerManager:add(5, self.moveBg, self, -1)
    elseif type == ModulePanelBgType.BIGSTATION then
        target1 = nil
        target2 = nil
    end

    for _,v in pairs(self._bgImgMap) do
        if v == target1 or v == target2 then
            v:setVisible(true)
        else
            v:setVisible(false)
        end
    end
end

--!!!注意，这个只能在世界BOSS中使用，因为世界BOSS分包掉了
function UIPanelBg:initBattleBg()
    local parentSize = self._bgImg6:getContentSize()
    local scale =  NodeUtils:getAdaptiveScale()
    if self.bg1 == nil then
        self.bg1 = TextureManager:createImageViewFile("bg/worldBoss/bg.jpg")
        self.bg1:setScale(scale)
        self.bg1:setAnchorPoint(0.5, 1)
        self.bg1:setPosition(480 * scale, parentSize.height)
        self._bgImg6:addChild(self.bg1)
    end
    if self.bg2 == nil then
        self.bg2 = TextureManager:createImageViewFile("bg/worldBoss/bg.jpg")
        self.bg2:setPosition(1440 * scale, parentSize.height)
        self.bg2:setScale(scale)
        self.bg2:setAnchorPoint(0.5, 1)
        
        self._bgImg6:addChild(self.bg2)
    end
end

function UIPanelBg:moveBg()
    local scale =  NodeUtils:getAdaptiveScale()
    local bgSize = self.bg1:getContentSize()

    bgSize.width = bgSize.width * scale
    local posX1 = self.bg1:getPositionX()
    local posX2 = self.bg2:getPositionX()
    local Speed = -1
    posX1 = posX1 + Speed
    posX2 = posX2 + Speed
    
    local winHeight = bgSize.width
    if posX1 < -winHeight*0.5 then
      posX2 = bgSize.width/2
      posX1 = winHeight*1.5
    end
    if posX2 < -winHeight*0.5 then
      posX1 = bgSize.width/2
      posX2 = winHeight*1.5
    end
    self.bg1:setPositionX(posX1)
    self.bg2:setPositionX(posX2)
end

--设置背景3平铺，对于全屏，没有标签切换的，需要调用这个接口
function UIPanelBg:setBgImg3Full()
--    local visibleSize = cc.Director:getInstance():getVisibleSize()
--    local winSize = cc.Director:getInstance():getWinSize()
--    local scale = winSize.width / visibleSize.width
--    
--    local size = self._bgImg3:getContentSize()
--    self._bgImg3:setContentSize(size.width, size.height + 80 * scale)
end

function UIPanelBg:registerEvents()
    -- local closeBtn = self._uiSkin:getChildByName("titlePanel/titleBg/closeBtn")
    local closeBtn = self._uiSkin:getChildByName("closeBtn")
    self._helpBtn = self._uiSkin:getChildByName("helpBtn")
    local obj = self
    ComponentUtils:addTouchEventListener(closeBtn, self.onCloseTouch, nil,obj)
    ComponentUtils:addTouchEventListener(self._helpBtn, self.onHelpTouch, nil,obj)

    self._commentBtn = self._uiSkin:getChildByName("commentBtn")
    ComponentUtils:addTouchEventListener(self._commentBtn, self.onCommentBtn, nil,obj)
end

function UIPanelBg:onHelpTouch(sender)
    logger:info("===========UIPanelBg:onHelpTouch===========")
    if sender.htmlStr ~= nil then
        SDKManager:showWebHtmlView(sender.htmlStr)
    end
end

function UIPanelBg:setHtmlStr(htmlStr)
    if htmlStr ~= nil then
        self._helpBtn.htmlStr = htmlStr
        self._helpBtn:setVisible(true)
    end
end

function UIPanelBg:onCloseTouch(sender)
    logger:info("===========UIPanelBg:onCloseTouch===========")
    TimerManager:remove(self.moveBg, self)
    if self._closeCallback ~= nil then
        self._closeCallback()
    end
end

function UIPanelBg:setVisible(visible)
    self._uiSkin:setVisible(visible)
end

--当isImg为true是，exContent可能会带文本
function UIPanelBg:setIsShowName(isShow,content, isImg, exContent)
    local name = self._uiSkin:getChildByName("titlePanel/titleBg/name")
    local titleImg = self._uiSkin:getChildByName("titlePanel/titleBg/titleImg")
    if isShow == true then
        name:setVisible(true)
        titleImg:setVisible(false)
        name:setString(content)
        if isImg == true then
            local url = string.format("images/titleIcon/%s.png", content)
            -- local width, _ = TextureManager:updateImageView(titleImg,url)
            TextureManager:updateImageView(titleImg,url)
            local titleSize = titleImg:getContentSize()
            local width = titleSize.width
            
            name:setVisible(false)
            titleImg:setVisible(true)
            if exContent ~= nil then
                name:setVisible(true)
                name:setString(exContent)
                local tx = titleImg:getPositionX()
                local nSize = name:getContentSize()
                name:setPositionX(tx + width / 2 + nSize.width / 2)
            end
        end
    else
        name:setVisible(false)
        titleImg:setVisible(false)
    end
end

function UIPanelBg:getCloseBtn()
    -- return self._uiSkin:getChildByName("titlePanel/titleBg/closeBtn")
    return self._uiSkin:getChildByName("closeBtn")
end

function UIPanelBg:getHelpBtn()
    return self._uiSkin:getChildByName("helpBtn")
end

-- 无标签的panel，自适应顶部适应
function UIPanelBg:topAdaptivePanel()
    return self._uiSkin:getChildByName("closeBtn/topAdaptivePanel")
end

function UIPanelBg:setLocalZOrder(order)
    self._uiSkin:setLocalZOrder(order)
end

function UIPanelBg:setNewbgImg3(downWidget,status)
    local scale = NodeUtils:getAdaptiveScale()
    
    local size = downWidget:getContentSize()
    local srcSize = self._bgImg3:getContentSize()
    local posx,posy = self._bgImg3:getPosition()
    local newSize = cc.size(srcSize.width, srcSize.height - size.height * scale)
    self._bgImg3:setContentSize(newSize)
    self._bgImg3:setPosition(posx , posy + size.height * scale / 2)
    
    self:setDownLineStatus(status)
end

function UIPanelBg:setDownLineStatus(status)
    if status == nil then
        status = false  --默认不显示线
    end
    local downPanelLine = self._bgImg3:getChildByName("downPanelLine")
    downPanelLine:setVisible(status)

end

function UIPanelBg:adjustBootomBg(downWidget, upWidget,isHideBg, status)
    local scale = NodeUtils:getAdaptiveScale()
    local upX, upY = upWidget:getPosition()


    local size = downWidget:getContentSize()
    downWidget:setPositionY(upY - size.height)
    if isHideBg == true then
        self._bgImg3:setVisible(false)
        return
    end
    local srcSize = self._bgImg3:getContentSize()
    self._bgImg3:setContentSize(cc.size(size.width,size.height))

    self:setDownLineStatus(status)
end

--参数param.Widget 需要加BG的Widget
--    param.noLine 不需要下横线
function UIPanelBg:setNewbgImg(param)
    local Widget = param.Widget
    local upX, upY = Widget:getPosition()
    self._bgImg3:setPosition(upX,upY)
    local aP = Widget:getAnchorPoint()
    self._bgImg3:setAnchorPoint(aP)
    local size = Widget:getContentSize()
    local srcSize = self._bgImg3:getContentSize()
    self._bgImg3:setContentSize(size.width,size.height)
    if not param.noLine then 
        local downPanelLine = self._bgImg3:getChildByName("downPanelLine")
        downPanelLine:setVisible(true)
    end
end

function UIPanelBg:show()
    if self.bgType == ModulePanelBgType.BATTLE then
        TimerManager:add(5, self.moveBg, self, -1)
    end
end

function UIPanelBg:stopBgMove()
    TimerManager:remove(self.moveBg, self)
end

function UIPanelBg:setCommentHandle(func)
    if func ~= nil then
        self._commentBtn.callback = func
    end
end

function UIPanelBg:onCommentBtn(sender)
    if sender.callback ~= nil then
        sender.callback()
    end
end

function UIPanelBg:setCommentBtnVisible(isVisible)
    self._commentBtn:setVisible(isVisible)
end

