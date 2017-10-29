



ActivityCenterPanel = class("ActivityCenterPanel", BasicPanel)

ActivityCenterPanel.NAME = "ActivityCenterPanel"



ActivityCenterPanel.LIGHT_URL_ENABLE = "images/gameActivity/BtnDengLong2.png"
ActivityCenterPanel.LIGHT_URL_DISABLE = "images/gameActivity/BtnDengLong1.png"


ActivityCenterPanel.TXT_XIAN_SHI_ENABLE = "images/activityCenter/TxtXianShi1.png"
ActivityCenterPanel.TXT_XIAN_SHI_DISABLE = "images/activityCenter/TxtXianShi2.png"

ActivityCenterPanel.TXT_CHANG_GUI_ENABLE = "images/activityCenter/TxtChangGui1.png"
ActivityCenterPanel.TXT_CHANG_GUI_DISABLE = "images/activityCenter/TxtChangGui2.png"


function ActivityCenterPanel:ctor(view, panelName)

    -- ActivityCenterPanel.super.ctor(self, view, panelName, true)
    ActivityCenterPanel.super.ctor(self, view, panelName, 100)


    self:setUseNewPanelBg(true)

end


function ActivityCenterPanel:finalize()
    if self._btnEffect ~= nil then
        self._btnEffect:finalize()
        self._btnEffect = nil
    end

    ActivityCenterPanel.super.finalize(self)

end


function ActivityCenterPanel:initPanel()

    ActivityCenterPanel.super.initPanel(self)

    self._pnlTabs = { }

    local pnl = self:getChildByName("Panel_2_0")

    self._btnClose = pnl:getChildByName("btnClose")
    self:swingAction(self._btnClose)

    self._imgHead = pnl:getChildByName("imgHead")
    self._pnlTab = pnl:getChildByName("pnlTab")
    self._imgTail = pnl:getChildByName("imgTail")
    
    self:swingAction(self._imgTail)

    table.insert(self._pnlTabs, self._pnlTab)
    self.cur_tab_num = 0

    -- 当前页签
    self._curName = nil

    -- 当前显示内容的pnl
    self._curShowPnl = nil


    --self:setTitle(true, "limit", true)

    -- 创建两个标签
    self:addTabPanel()
    self:addTabPanel()
   
    
end

function ActivityCenterPanel:registerEvents()

    ActivityCenterPanel.super.registerEvents(self)

    self:addTouchEventListener(self._btnClose, self.onClose)
end

function ActivityCenterPanel:onShowHandler()
    
    -- 是否播放动画
    self._isShowAction = true

    -- 不显示默认二级弹窗样式
    self:setDefaultBgVisible(false)

    -- 更新灯笼(灯笼可能增删)
    self:updateDenglongUI()
        
    -- 打开界面重新计算小红点总数量
    local activityProxy = self:getProxy(GameProxys.Activity)
    activityProxy:updateLimitRedpoint()
    self:updateRedPoint()

    
end

function ActivityCenterPanel:updateDenglongUI()
    
    -- 显示的Index
    local dengLongCount = 1


    -- 根据条件显示并设置标签
    local activityProxy = self:getProxy(GameProxys.Activity)
    local data = activityProxy:getLimitActivityInfo()
    if #data ~= 0 then
       self._pnlTabs[1].name = ActivityFirstPanel.NAME
       self:setTabSelectEnable(self._pnlTabs[1])

       self._pnlTabs[2]:setVisible(true)
       self._pnlTabs[2].name = ActivitySecondPanel.NAME
       self:setTabSelectEnable(self._pnlTabs[2])

       dengLongCount = 2

    else
       self._pnlTabs[1].name = ActivitySecondPanel.NAME
       self:setTabSelectEnable(self._pnlTabs[1])

       self._pnlTabs[2]:setVisible(false)
       self._pnlTabs[2].name = nil

       dengLongCount = 1
    end

    -- 指定当前显示标签
    if self._curName == nil then
        -- 初始化
        self._curName = self._pnlTabs[1].name
    else
        -- 标签是否被移除了
        local isTabDel = true
        for k, v in pairs(self._pnlTabs) do
            if v.name == self._curName then
                isTabDel = false
                break
            end
        end
        if isTabDel == true then
            self._curName = self._pnlTabs[1].name   
        end
    end
    -- 指定选中的标签
    self:setTabSelectByName(self._curName)
    
    -- 修正灯笼尾位置
    local lastDengLong = self._pnlTabs[dengLongCount]
    local size = lastDengLong:getContentSize()
    local x = lastDengLong:getPositionX() + size.width / 2
    local y = lastDengLong:getPositionY()
    self._imgTail:setPosition(cc.p(x, y))    
end

-- function ActivityCenterPanel:onClosePanelHandler()
--    --self:dispatchEvent(ActivityCenterEvent.HIDE_SELF_EVENT)
-- end

function ActivityCenterPanel:onClose()
    self.view:dispatchEvent(ActivityCenterEvent.HIDE_SELF_EVENT)
end

function ActivityCenterPanel:updateBlurSprite()
    self:releaseBlurSprite()
    self:addBlurSprite()
end

function ActivityCenterPanel:updateRedPoint()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local data = activityProxy:getLimitActivityInfo()
    local proxy = self:getProxy(GameProxys.RedPoint)

    local tabIndex = 1

    local function getInfo(id)
        for k, v in pairs(data) do
            if v.activityId == id then
                return v
            end
        end
    end
    if #data ~= 0 then
        local allRedPointData = proxy:getAllRedData()
        local num = 0
        for k, v in pairs(allRedPointData) do
            local activityData = getInfo(k)
            if activityData ~= nil then
                num = num + v
            end
        end
        self:setItemCount(tabIndex, num > 0, num)

        tabIndex = tabIndex + 1
    end

    local battleActivity = self:getProxy(GameProxys.BattleActivity)
    local info = battleActivity:getActivityInfo()
    if #info ~= 0 then
        local allRedNum = proxy:getServerActivityRedNum()        
        self:setItemCount(tabIndex, allRedNum > 0, allRedNum)

        tabIndex = tabIndex + 1
    end    
end


function ActivityCenterPanel:setItemCount(index, isShow, Count)
    if self._pnlTabs[index] == nil then
        return
    end

    local imgDot = self._pnlTabs[index]:getChildByName("imgDot")
    local imgDotVal = imgDot:getChildByName("val")
    imgDotVal:setString(tostring(Count))
    imgDot:setVisible(isShow)
end

-- 标签是否存在
function ActivityCenterPanel:isTabPanelExist(pnlName)
    for k, v in pairs(self._pnlTabs) do
        if v.name == pnlName then
            return true
        end
    end

    return false
end

-- 新增标签
function ActivityCenterPanel:addTabPanel()
    self.cur_tab_num = self.cur_tab_num + 1
    
    if self.cur_tab_num == 1 then
        self:addTouchEventListener(self._pnlTab, self.tabTouch)
    else
        local new_tab = self._pnlTab:clone()
        table.insert(self._pnlTabs, new_tab)
        self:addTouchEventListener(new_tab, self.tabTouch)
        self._pnlTab:getParent():addChild(new_tab)

        local per_tab = self._pnlTabs[#self._pnlTabs - 1]
        new_tab:setPositionY(per_tab:getPositionY() - per_tab:getContentSize().height)
    end
end

function ActivityCenterPanel:setTabSelectByName(curPnlName)

--    if self._isShowAction == false and curPnlName == self._curName then
--        return
--    end

    self._curName = curPnlName

    for i = 1, #self._pnlTabs do
        self:setTabSelectEnable(self._pnlTabs[i], self._pnlTabs[i].name == self._curName)
--        if self._pnlTabs[i].name == self._curName then
--            if self._curPnlTab then
--                self:setTabSelectEnable(self._curPnlTab, false)
--            end
--                self:setTabSelectEnable(self._pnlTabs[i], true)
--                self._curPnlTab = self._pnlTabs[i]
--            break
--        end
    end

    if self._curShowPnl then
        self._curShowPnl:hide()
    end
        
    local pnl = self:getPanel(self._curName)
    pnl:show()    
    if self._isShowAction == true then
        pnl:showAction()
        self._isShowAction = false
    end
    pnl:setLocalZOrder(2)
    self._curShowPnl = pnl    
end

function ActivityCenterPanel:tabTouch(sender)
    logger:info("touch")
    self:setTabSelectByName(sender.name)
end


function ActivityCenterPanel:setTabSelectEnable(item, bool)
    local imgLight = item:getChildByName("imgLight")
    local imgWord = item:getChildByName("imgWord")
    -- local imgDot    =   item:getChildByName("imgDot")
    -- local imgDotVal =   imgDot:getChildByName("val")
    
    if self._btnEffect == nil then        
        local btnSize = imgLight:getContentSize()
        self._btnEffect = self:createUICCBLayer("rgb-hd-denglong", imgLight)
        self._btnEffect:setPosition(btnSize.width / 2, btnSize.height / 2)
    else
        self._btnEffect:changeParent(imgLight)
    end
    self._btnEffect:setLocalZOrder(20)

    if bool then
        TextureManager:updateImageView(imgLight, ActivityCenterPanel.LIGHT_URL_ENABLE)
        if item.name == ActivityFirstPanel.NAME then
            TextureManager:updateImageView(imgWord, ActivityCenterPanel.TXT_XIAN_SHI_ENABLE)
        elseif item.name == ActivitySecondPanel.NAME then
            TextureManager:updateImageView(imgWord, ActivityCenterPanel.TXT_CHANG_GUI_ENABLE)
        end
    else
        TextureManager:updateImageView(imgLight, ActivityCenterPanel.LIGHT_URL_DISABLE)
        if item.name == ActivityFirstPanel.NAME then
            TextureManager:updateImageView(imgWord, ActivityCenterPanel.TXT_XIAN_SHI_DISABLE)
        elseif item.name == ActivitySecondPanel.NAME then
            TextureManager:updateImageView(imgWord, ActivityCenterPanel.TXT_CHANG_GUI_DISABLE)
        end
    end
end

--------------------------------------------------------------
-- 下面是复制firstpanel的函数过来的
--------------------------------------------------------------

--[[
function ActivityCenterPanel:onShowFirstPanel()

    self:updateRedPoint()

    self:updateInfo()
end

function ActivityCenterPanel:updateInfo(isRemove)
    local activityProxy = self:getProxy(GameProxys.Activity)
    local data = activityProxy:getLimitActivityInfo()
    self:renderListView(self._ListView, data, self, self.renderItemPanel)
end

function ActivityCenterPanel:renderItemPanel(item, data, index)
    item:setVisible(true)
    local Label_name = item:getChildByName("Label_name")
    local Label_desc = item:getChildByName("Label_desc")
    local img = item:getChildByName("Image_icon")
    local Image_icon = img:getChildByName("icon")
    -- local helpBtn = item:getChildByName("Button_buy")
    local endImg = item:getChildByName("endImg")
    Label_name:setString(data.name)


    --小红点
    local redIconImg = item:getChildByName("redIconImg")
    redIconImg:setVisible(false)
    local redPoint = self:getProxy(GameProxys.RedPoint)
    local redNum = redPoint:getRedPointById(data.activityId)
    local numLab = redIconImg:getChildByName("numLab")
    redIconImg:setVisible(redNum ~= 0)
    numLab:setString(redNum)

    local startTime = TimeUtils:setTimestampToString(data.startTime)
    local endTime = TimeUtils:setTimestampToString(data.endTime)
    Label_desc:setString(startTime .." - ".. endTime )
    item.data = data
    -- item.actId = data.activityId
    -- item.effectId = data.effectId
    self:touchItem(item)
    -- helpBtn.data = data
    -- helpBtn.actId = data.activityId
    -- helpBtn.effectId = data.effectId
    -- self:addTouchEventListener(helpBtn, self.onCallItemTouch)

    local url = "bg/limitActivity/"..data.bgIcon .. TextureManager.bg_type
    TextureManager:updateImageViewFile(Image_icon,url)
    --活动过期显示优化
    if GameConfig.serverTime >= data.endTime then
        endImg:setVisible(true)
        -- helpBtn:setVisible(false)
        redIconImg:setVisible(false)
    else
        endImg:setVisible(false)
        -- helpBtn:setVisible(true)
    end

end

function ActivityCenterPanel:touchItem(item)
    if item.isAdd == true then return end
    item.isAdd = true
    local function call(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
--            sender:setScale(1.0)
            self:onCallItemTouch(sender)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:playButtonEffect()
--            sender:setScale(0.98)
        elseif eventType == ccui.TouchEventType.canceled then
--            sender:setScale(1.0)
        end
    end
    item:addTouchEventListener(call)
end


function ActivityCenterPanel:onCallItemTouch(sender)
    local activityData = sender.data
    local activityProxy = self:getProxy(GameProxys.Activity)
    activityProxy:onOpenActivityModule( activityData )
    print( "activityId:", sender.data.activityId, "uitype:", sender.data.uitype)
end

--]]

function ActivityCenterPanel:swingAction(object)
    if object then
        local time = 0.5
        local rotate = 3
        local rotate1 = cc.RotateBy:create(time, rotate)
        local rotate2 = cc.RotateBy:create(time, 0 - rotate)
        local rotate3 = cc.RotateBy:create(time, 0 - rotate)
        local rotate4 = cc.RotateBy:create(time, rotate)
        --local ease1 = cc.EaseSineIn:create(rotate1)
        --local ease2 = cc.EaseSineOut:create(rotate2)
        --local ease3 = cc.EaseSineIn:create(rotate3)
        --local ease4 = cc.EaseSineOut:create(rotate4)
        --local seq = cc.Sequence:create(ease1, ease2, ease3, ease4)
        
        local seq = cc.Sequence:create(rotate1, rotate2, rotate3, rotate4)
        local repeatAction = cc.RepeatForever:create(seq)
        object:stopAllActions()
        object:runAction(repeatAction)
    end
end