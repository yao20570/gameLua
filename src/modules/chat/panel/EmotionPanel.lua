EmotionPanel = class("EmotionPanel", BasicPanel)
EmotionPanel.NAME = "EmotionPanel"

function EmotionPanel:ctor(view, panelName)
    EmotionPanel.super.ctor(self, view, panelName)
    self.emotionId = 0

    self:setUseNewPanelBg(true)
end

function EmotionPanel:finalize()
    if self.listenner ~= nil then
        local eventDispatcher = self._touchLayer:getEventDispatcher()
        eventDispatcher:removeEventListenersForTarget(self._touchLayer)
        self.listenner = nil
    end

    if self._touchLayer ~= nil then
        self._touchLayer:removeFromParent()
        self._touchLayer = nil
    end
    EmotionPanel.super.finalize(self)
end

function EmotionPanel:initPanel()
    EmotionPanel.super.initPanel(self)
    self:setLocalZOrder (PanelLayer.UI_Z_ORDER_1)
    self.LINE_FACE_NUM = 6
    self.MAX_PAGE_NUM = 0

    self.allFaceData = {}
    local config = ConfigDataManager:getConfigData(ConfigData.ChatFaceConfig)
    for i=1,#config do
        if config[i].pagechange > self.MAX_PAGE_NUM then
            self.MAX_PAGE_NUM = config[i].pagechange
        end
        local curPage = config[i].pagechange
        self.allFaceData[curPage] = self.allFaceData[curPage] or {}
        table.insert(self.allFaceData[curPage], config[i])
    end

    --存放所有表情imageview   切换就updateImageView 不重复创建
    self.allFaceNode = {}

    local closeBtn = self:getChildByName("mainPanel/button")
    self:addTouchEventListener(closeBtn, self.closeSelfPanel)

    local bgImg = self:getChildByName("mainPanel/Image_25")
    bgImg:setTouchEnabled(false)
    -- ComponentUtils:addTouchEventListener(bgImg, self.touchEnded, nil, self)

    local mainPanel = self:getChildByName("mainPanel")
    self:addTouchLayer(mainPanel)

end

function EmotionPanel:touchEnded(sender, value, dir)
    self.oldPage = self.oldPage or 1
    if dir == 0 then
        return
    end
    self.oldPage = self.oldPage + dir
    self.oldPage = self.oldPage < 1 and 1 or self.oldPage
    self.oldPage = self.oldPage > self.MAX_PAGE_NUM and self.MAX_PAGE_NUM or self.oldPage
    self:initEmotionPanel(self.oldPage)
end

function EmotionPanel:onShowHandler(num)
    self.num = num
    self.touch = true
    self:initEmotionPanel(1)
end

function EmotionPanel:initEmotionPanel(curPage)
    for i=1,self.MAX_PAGE_NUM do
        local url = i == curPage and "images/chat/pointBg.png" or "images/chat/poingNode.png"
        local oldNode = self:getChildByName("mainPanel/targetBg"..i)
        TextureManager:updateImageView(oldNode, url)
    end
    for i=self.MAX_PAGE_NUM + 1, 3 do
        local oldNode = self:getChildByName("mainPanel/targetBg"..i)
        oldNode:setVisible(false)
    end

    self.oldPage = curPage or 1
    self.allFaceData[curPage] = self.allFaceData[curPage] or {}
    local row = math.ceil(#self.allFaceData[curPage] / self.LINE_FACE_NUM) 

    --命名太长了，换个短一点的
    local info = self.allFaceData[curPage]
    local mainPanel = self:getChildByName("mainPanel")


    --第三页  2个大表情，特殊处理
    if curPage == 3 then
        for k,v in pairs(self.allFaceNode) do
            v:setVisible(false)
        end
        for k,v in pairs(info) do
            local node = mainPanel:getChildByName("special"..k)
            local url = string.format("images/faceIcon/face_%d.png", v.iconID)
            TextureManager:updateImageView(node, url)
            node.id = v.ID
            self:addTouchEventListener(node, self.onEmotionTouch)
        end
        return
    end

    
    
    local startX = 106
    local startY = 215
    local widthSpacing = 80
    local heightSpacing = 65
    local index = 1
    for i=1, row do
        for j=1, self.LINE_FACE_NUM do
            local id = (i - 1) * self.LINE_FACE_NUM + j
            if id > #self.allFaceData[curPage] then
                for curId=id,#self.allFaceNode do
                    self.allFaceNode[curId]:setVisible(false)
                end
                break
            end
            local url = string.format("images/faceIcon/%d.png", info[id].iconID)

            local imageView = self.allFaceNode[index]
            if imageView == nil then
                imageView = TextureManager:createImageView(url)
                local x = startX + (j - 1) * widthSpacing
                local y = startY - (i - 1) * heightSpacing
                imageView:setPosition(x, y)
                mainPanel:addChild(imageView)
            else
                TextureManager:updateImageView(imageView, url)
            end
            imageView:setVisible(true)
            self.allFaceNode[index] = imageView
            imageView.id = info[id].ID
            self:addTouchEventListener(imageView, self.onEmotionTouch)
    	    index = index + 1
        end
    end
end

function EmotionPanel:onEmotionTouch(sender)
    local id = sender.id
    if self.num == 0 then
        local chatPanel = self:getPanel(WorldChatPanel.NAME)
        chatPanel:selectEmotion(id)
    elseif self.num == 1 then
        local privatePanel = self:getPanel(ChatPrivatePanel.NAME)
        privatePanel:selectEmotion(id)
    elseif self.num == 2 then
        local legionPanel = self:getPanel(LegionChatPanel.NAME)
        legionPanel:selectEmotion(id)
    end
end

function EmotionPanel:closeSelfPanel(sender)
    local chatPanel = self:getPanel(WorldChatPanel.NAME)
    local privatePanel = self:getPanel(ChatPrivatePanel.NAME)
    local legionPanel = self:getPanel(LegionChatPanel.NAME)
    chatPanel:canTouchEmotion()
    privatePanel:canTouchEmotion()
    legionPanel:canTouchEmotion()

    self:hide()
end

function EmotionPanel:hide()
    self.touch = false
    EmotionPanel.super.hide(self)
end

function EmotionPanel:addTouchLayer(mainPanel)
    if self._touchLayer == nil then
        self._touchLayer = cc.Layer:create()
        self._touchLayer:setContentSize(mainPanel:getContentSize())
        mainPanel:addChild(self._touchLayer)
        self._touchLayer:setLocalZOrder(10)
    end

    if self.listenner ~= nil then
        local eventDispatcher = self._touchLayer:getEventDispatcher()
        eventDispatcher:removeEventListenersForTarget(self._touchLayer)
        self.listenner = nil
    end

    local x = 0
    self.listenner = cc.EventListenerTouchOneByOne:create()
    self.listenner:setSwallowTouches(false)

    self.listenner:registerScriptHandler(function(touch, event)    
        local location = touch:getLocation()   
        x = location.x
        return self.touch    
    end, cc.Handler.EVENT_TOUCH_BEGAN )

    self.listenner:registerScriptHandler(function(touch, event)
        local location = touch:getLocation() 
        if location.x - x > 30 then
            self:touchEnded(nil, nil, -1)
        elseif location.x - x < -30 then
            self:touchEnded(nil, nil, 1)
        end
    end, cc.Handler.EVENT_TOUCH_ENDED ) 
    local eventDispatcher = self._touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenner, self._touchLayer)
end