UIPanelBgNew = class("UIPanelBgNew")

function UIPanelBgNew:ctor(parent, closeCallback)
    local uiSkin = UISkin.new("UIPanelBgNew")

    uiSkin:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)

    uiSkin:setParent(parent)

    self._bgEffect = nil

    -- 自定义背景图
    self._bgImg = uiSkin:getChildByName("bgImg")
    -- NodeUtils:adaptive(self._bgImg)

    -- 默认01棕色背景
    self._defaultBg01 = uiSkin:getChildByName("defaultBg01")
    NodeUtils:adaptive(self._defaultBg01)
    -- 默认02中间圆形图
    self._defaultBg02 = uiSkin:getChildByName("defaultBg02")
    NodeUtils:adaptive(self._defaultBg02)
    TextureManager:updateImageViewFile(self._defaultBg02,"bg/newGuiBg/BgPanel.pvr.ccz")
 
    self.titlePanel = uiSkin:getChildByName("titlePanel")
    self.titlePanel:setTouchEnabled(false)
    self.titlePanel:setLocalZOrder(10008)

    self._closeBtn = uiSkin:getChildByName("closeBtn")    
    self._closeBtn:setLocalZOrder(10009)
    self._closeBtn:addTouchRange(50, 50)

    self._helpBtn = uiSkin:getChildByName("helpBtn")
    self._helpBtn:setLocalZOrder(10010)

    self._helpOldBtn = uiSkin:getChildByName("helpOldBtn")
    self._helpOldBtn:setLocalZOrder(10011)

    self._commentBtn = uiSkin:getChildByName("commentBtn")
    self._commentBtn:setLocalZOrder(10011)

    -- 多关闭模块按钮
    self._closeMultiBtn = uiSkin:getChildByName("closeMultiBtn")
    self._closeMultiBtn:setLocalZOrder(10011)
    self._closeMultiBtn:setVisible(false)

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
    NodeUtils:adaptive(bgImg6)


    -- 面板
    self._bgImg3 = bgImg3    
    self._bgImg3_1 = bgImg3_1
    self._bgImgR = bgImgR
    self._bgImgR2 = bgImgR2
    self._bgImgR3 = bgImgR3
    self._bgImg4 = bgImg4
    self._bgImg5 = bgImg5
    self._bgImg6 = bgImg6
    

	-- 背景图总表
    self._bgImgMap = {self._defaultBg01, self._defaultBg02, self._bgImg, self._bgImg3,self._bgImg3_1,self._bgImgR,self._bgImgR2,self._bgImgR3,self._bgImg4,self._bgImg5, self._bgImg6}


    self._htmlStr = nil
    self._uiSkin = uiSkin
    self._closeCallback = closeCallback
    self:setBgType(ModulePanelBgType.NONE)
    self:setDownLineStatus(false)
    self:registerEvents()

end

function UIPanelBgNew:finalize()
    self._uiSkin:finalize()
end

function UIPanelBgNew:setBgImg3Tab()
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
function UIPanelBgNew:getBgTopY()
    local size = self._bgImg3:getContentSize()
    local x, y = self._bgImg3:getPosition()
    
    return x + size.height / 2
end

--设置背景类型
function UIPanelBgNew:setBgType(type)
    local target1 = nil
    local target2 = nil
    self.bgType = type
    -- self._bgImg:setVisible(type ~= ModulePanelBgType.BATTLE)
    if self._bgEffect then
        self._bgEffect:finalize()
        self._bgEffect = nil
    end
    
    self._bgImg6:setLocalZOrder(2)
    if type == ModulePanelBgType.BACK then
        target1 = self._bgImg3
    elseif type == ModulePanelBgType.WHITE then
        target1 = self._bgImg3_1
        --TextureManager:updateImageViewFile(self._bgImg3_1,"bg/ui/Bg_teamset.pvr.ccz")
    elseif type == ModulePanelBgType.BACKR then
        target1 = self._bgImgR
    elseif type == ModulePanelBgType.BACKR_WHITER then
        target1 = self._bgImgR
        target1 = self._bgImgR2
    elseif type == ModulePanelBgType.BACKR_WHITER2 then
        target1 = self._bgImgR
        target1 = self._bgImgR3
    elseif type == ModulePanelBgType.NONE then
        target1 = self._defaultBg02
        if self._bgEffect == nil then
            self._bgEffect = UICCBLayer.new("rgb-beijing", self._defaultBg02)
            local size = self._defaultBg02:getContentSize()
            self._bgEffect:setPosition(size.width/2,size.height/2)
            self._bgEffect:setLocalZOrder(12)
        end
    elseif type == ModulePanelBgType.LOTTERY then
        target1 = self._bgImg4
    elseif type == ModulePanelBgType.BLACKFULL then
        target1 = self._defaultBg01
    elseif type == ModulePanelBgType.BATTLE then
        target1 = self._bgImg6
        self:initBattleBg()
        TimerManager:add(5, self.moveBg, self, -1)
    elseif type == ModulePanelBgType.GOSSIP then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/consigliere/gossip.jpg")
    elseif type == ModulePanelBgType.ROOM then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/consigliere/room.jpg")
    elseif type == ModulePanelBgType.TEAM then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/team/teamSetBg.jpg")
    elseif type == ModulePanelBgType.BIGSTATION then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/bigStation/bg.jpg")
    elseif type == ModulePanelBgType.PUBNOR then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/pub/pubBg.pvr.ccz")
    elseif type == ModulePanelBgType.ACTIVITY then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/newGuiBg/BgPanelActivity.jpg")
    elseif type == ModulePanelBgType.MARTIALTEACH then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/martialTeach/bg.jpg")
    elseif type == ModulePanelBgType.COOKINGWINE then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/cookingwine/bg.jpg")
    elseif type == ModulePanelBgType.CELESTIALSOLDIER then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/celesrtialSolider/bg.jpg")
    elseif type == ModulePanelBgType.WARLORDS then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/warlords/bg1.jpg")
    elseif type == ModulePanelBgType.RICHPOWERFULVILLAGE then 
        target1 = self._bgImg 
        TextureManager:updateImageViewFile(self._bgImg,"bg/richPowerfulVillage/richPowerfulVillage.jpg")
    elseif type == ModulePanelBgType.LORDCITY then
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/lordCity/bg.jpg")
    elseif type == ModulePanelBgType.GETLOTOFMONEY then 
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/getLotOfMoney/getLotOfMoney.jpg")
    elseif type == ModulePanelBgType.COUNTRY_ROYAL then --皇族背景
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/country/royal_bg.jpg")
    elseif type == ModulePanelBgType.COUNTRY_PRISON then --监狱背景
        target1 = self._bgImg
        TextureManager:updateImageViewFile(self._bgImg,"bg/country/prison_bg.jpg")
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
function UIPanelBgNew:initBattleBg()
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

function UIPanelBgNew:moveBg()
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
function UIPanelBgNew:setBgImg3Full()
--    local visibleSize = cc.Director:getInstance():getVisibleSize()
--    local winSize = cc.Director:getInstance():getWinSize()
--    local scale = winSize.width / visibleSize.width
--    
--    local size = self._bgImg3:getContentSize()
--    self._bgImg3:setContentSize(size.width, size.height + 80 * scale)
end
function UIPanelBgNew:registerEvents()
    
    local obj = self
    ComponentUtils:addTouchEventListener(self._closeBtn, self.onCloseTouch, nil,obj)
    ComponentUtils:addTouchEventListener(self._helpBtn, self.onHelpTouch, nil,obj)

    ComponentUtils:addTouchEventListener(self._helpOldBtn,self.onHelpTouch,nil,obj)
    
    ComponentUtils:addTouchEventListener(self._closeMultiBtn, self.onCloseMultiBtn, nil,obj)
    
    ComponentUtils:addTouchEventListener(self._commentBtn, self.onCommentBtn, nil,obj) -- 要提高层级
end

function UIPanelBgNew:onHelpTouch(sender)
    logger:info("===========UIPanelBgNew:onHelpTouch===========")
    local helpOldBtn="images/newGui1/BtnHelp16964.png"
    local helpOldBtn2 = "images/newGui1/BtnHelp26964.png"
    
    if sender.htmlStr ~= nil then
        if sender.htmlStr == "html/help_player.html" then
        ModuleJumpManager:jump(ModuleName.SettingModule, "SettingPanel")
        else
        SDKManager:showWebHtmlView(sender.htmlStr)
        end
    end
end

function UIPanelBgNew:setHtmlStr(htmlStr)
	if htmlStr ~= nil then
        self._helpBtn.htmlStr = htmlStr
		self._helpOldBtn.htmlStr = htmlStr

		if htmlStr == "html/help_player.html" then
            self._helpOldBtn:setVisible(false)
            self._helpBtn:setVisible(true)
		else
			self._helpOldBtn:setVisible(true)
		end
	end
end

function UIPanelBgNew:onCloseTouch(sender)
    logger:info("===========UIPanelBgNew:onCloseTouch===========")
    TimerManager:remove(self.moveBg, self)
    if self._closeCallback ~= nil then
        self._closeCallback()
    end
end

function UIPanelBgNew:setVisible(visible)
    self._uiSkin:setVisible(visible)
end

--当isImg为true是，exContent可能会带文本
function UIPanelBgNew:setIsShowName(isShow,content, isImg, exContent)
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
        titleImg:setVisible(false) 
    end
    name:setVisible(false)--新版本换皮 名字等级的都是显示在下方
end

function UIPanelBgNew:getCloseBtn()
    -- return self._uiSkin:getChildByName("titlePanel/titleBg/closeBtn")
    return self._uiSkin:getChildByName("closeBtn")
end

function UIPanelBgNew:getHelpBtn()
    return self._uiSkin:getChildByName("helpBtn")
end

-- 无标签的panel，自适应顶部适应
function UIPanelBgNew:topAdaptivePanel()
    return self._uiSkin:getChildByName("closeBtn/topAdaptivePanel")
end

-- 无标签的部队panel，自适应顶部适应
function UIPanelBgNew:topAdaptivePanel2()
    return self._uiSkin:getChildByName("closeBtn/topAdaptivePanel2")
end

-- 找到titlebg pnl  页签上一点
function UIPanelBgNew:getTopTitleBg()
    return self._uiSkin:getChildByName("titlePanel/topTitleBgImg")
end


function UIPanelBgNew:setLocalZOrder(order)
    self._uiSkin:setLocalZOrder(order)
end

function UIPanelBgNew:setNewbgImg3(downWidget,status)
    local scale = NodeUtils:getAdaptiveScale()
    
    local size = downWidget:getContentSize()
    local srcSize = self._bgImg3:getContentSize()
    local posx,posy = self._bgImg3:getPosition()
    local newSize = cc.size(srcSize.width, srcSize.height - size.height * scale)
    self._bgImg3:setContentSize(newSize)
    self._bgImg3:setPosition(posx , posy + size.height * scale / 2)
    
    self:setDownLineStatus(status)
end

function UIPanelBgNew:setDownLineStatus(status)
    if status == nil then
        status = false  --默认不显示线
    end
    local downPanelLine = self._bgImg3:getChildByName("downPanelLine")
    downPanelLine:setVisible(status)

end

function UIPanelBgNew:adjustBootomBg(downWidget, upWidget,isHideBg, status)
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
function UIPanelBgNew:setNewbgImg(param)
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

function UIPanelBgNew:show()
    if self.bgType == ModulePanelBgType.BATTLE then
        TimerManager:add(5, self.moveBg, self, -1)
    end
end

function UIPanelBgNew:stopBgMove()
    TimerManager:remove(self.moveBg, self)
end

function UIPanelBgNew:setCommentHandle(func)
    if func ~= nil then
        self._commentBtn.callback = func
    end
end

function UIPanelBgNew:onCommentBtn(sender)
    if sender.callback ~= nil then
        sender.callback()
    end
end

function UIPanelBgNew:setCommentBtnVisible(isVisible)
    self._commentBtn:setVisible(isVisible)
end

function UIPanelBgNew:setCloseMultiBtn(isVisible, onCloseMultiBtnlHandler)
    self._closeMultiBtn:setVisible(isVisible)
    self.onCloseMultiBtnlHandler = onCloseMultiBtnlHandler
end

function UIPanelBgNew:onCloseMultiBtn()
    if self.onCloseMultiBtnlHandler ~= nil then
        self.onCloseMultiBtnlHandler()
    end
end

function UIPanelBgNew:updateTopTitleBg(url)
    local topTitle = self._uiSkin:getChildByName("titlePanel/topTitleBgImg")
    TextureManager:updateImageView(topTitle, url)
    --NodeUtils:adaptiveUpPanel(self._bgImg6, self._uiSkin:getChildByName("titlePanel"), -20)
end