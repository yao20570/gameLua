CollectionPanel = class("CollectionPanel", BasicPanel)
CollectionPanel.NAME = "CollectionPanel"

function CollectionPanel:ctor(view, panelName)
    CollectionPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function CollectionPanel:finalize()
    CollectionPanel.super.finalize(self)
end

function CollectionPanel:initPanel()
    CollectionPanel.super.initPanel(self)
    -- 选择列表初始化
    self._selectList = List.new()
    for i = 1, 3 do
        self._selectList:pushBack(0)
    end
--    self._selectList:replace(1, 1)
--    self._selectList:replace(2, 2)
--    self._selectList:replace(3, 3)

    self._collectionView = self:getChildByName("collectionView")
    
   
end

function CollectionPanel:doLayout()
     local downPanel = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._collectionView,downPanel,tabsPanel)
end

function CollectionPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    CollectionPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function CollectionPanel:onShowHandler()
    -- 底部按钮层属性设置
    local downPanel = self:getChildByName("downPanel")
    for index = 0, 3 do
        local tagPanel = downPanel:getChildByName("tagPanel" .. index)
        if index == 0 then
            self:setBottomBtnState(tagPanel, true)
        else
            self:setBottomBtnState(tagPanel, false)
        end
    end
    
    self:renderListByType()
    
end

------
--  筛选数据
-- @param  type [list] 参数
-- @return nil
function CollectionPanel:renderListByType()
    local friendProxy = self:getProxy(GameProxys.Friend)
    local infoList = friendProxy:getWorldCollectBySelect(self._selectList)
    -- 表克隆
    infoList = clone(infoList)
    self:renderListView(self._collectionView, infoList, self, self.renderItemPanel)
end

-- 渲染收藏列表
function CollectionPanel:renderItemPanel(itemPanel, info)
    --StringUtils:printKey(info)
    local nameTxt = itemPanel:getChildByName("nameTxt")   --
    local levelTxt = itemPanel:getChildByName("levelTxt") --
    local posTxt = itemPanel:getChildByName("posTxt")
    local watchBtn = itemPanel:getChildByName("watchBtn")
    local headPanel = itemPanel:getChildByName("headPanel")
    local iconPanel = itemPanel:getChildByName("iconPanel")
    local listBtn = itemPanel:getChildByName("listBtn")
    info.level = info.level or 0 --TODO
    
    -- 初始化
    levelTxt:setVisible(true)
    nameTxt:setPositionX(203)

    nameTxt:setString(info.name) -- 名字
    -- 等级
    if info.isPerson == 0 then
        levelTxt:setString( "Lv.".. info.level)
    else
        nameTxt:setPositionX(136)
        levelTxt:setVisible(false)
    end
    -- 坐标
    posTxt:setString(string.format("(%d,%d)", info.tileX, info.tileY))

    if info.isPerson == 0 then --玩家
        -- 头像和挂件
        local pendantId = info.pendantId --挂件
        local headInfo = {}
        headInfo.icon = info.iconId
        headInfo.pendant = pendantId
        --headInfo.preName1 = "headIcon"
        headInfo.preName1 = "headIcon"
        headInfo.preName2 = "headPendant"
        headInfo.isCreatPendant = false
        --headInfo.isCreatButton = true
        headInfo.playerId = rawget(info, "playerId")

        local head = itemPanel.head
        if head == nil then
            head = UIHeadImg.new(headPanel,headInfo,self)
            
            itemPanel.head = head
        else
            head:updateData(headInfo)
        end
        self.headBtn = head:getButton()
        --headPanel:setScale(0.9)
        --head:setHeadTransparency()

        headPanel:setVisible(true)
        headPanel:setScale(0.8)
        iconPanel:setVisible(false)

    elseif info.isPerson == 1 then --资源
        -- 资源图标
        local iconInfo = {}
        iconInfo.power = GamePowerConfig.Collection
        iconInfo.typeid = info.buildingType --暂无法获取资源类型
        iconInfo.num = 0

        local icon = itemPanel.icon
        if icon == nil then
            icon = UIIcon.new(iconPanel,iconInfo,false)
            itemPanel.icon = icon
        else
            icon:updateData(iconInfo)
        end

        headPanel:setVisible(false)
        iconPanel:setVisible(true)
    end

    -- 数据设置
    watchBtn.info = info
    -- ListBtn数据设置
    listBtn.info = info
    -- tgs是标识
    local tags = info.tags
    local tagMap = {}
    for _, tag in pairs(tags) do
    	tagMap[tag] = true
    end
    for index=1, 3 do
    	local tagPanel = itemPanel:getChildByName("tagPanel" .. index)
    	local state = tagMap[index] ~= nil
        self:setTagPanelState(tagPanel, state)
    	tagPanel.info = info
    end
    
    if itemPanel.isAddEvent ~= true then
        itemPanel.isAddEvent = true
        self:addItemPanelEvent(itemPanel)
    end
end

-- 注册收藏分类按钮监听事件
function CollectionPanel:addItemPanelEvent(itemPanel)
    local watchBtn = itemPanel:getChildByName("watchBtn")-- 前往
    local listBtn = itemPanel:getChildByName("listBtn")

    self:addTouchEventListener(watchBtn, self.onWatchBtnTouch) 

    self:addTouchEventListener(listBtn, self.onCheckOut)
end

function CollectionPanel:onWatchBtnTouch(sender)
    local info = sender.info
    local tileX = info.tileX
    local tileY = info.tileY
    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    data.extraMsg.tileX = tileX
    data.extraMsg.tileY = tileY
    self:dispatchEvent(FriendEvent.SHOW_OTHER_EVENT, data)
    self:dispatchEvent(FriendEvent.HIDE_SELF_EVENT, {})
end



-- 收藏分类按钮更新收藏数据
function CollectionPanel:onChangeTagPanelTouch(sender)
    local curState = sender.curState -- 在setTagPanelState预先设置值
    self:setTagPanelState(sender, not curState)
    
    local tags = {}
    local info = sender.info
    for index=1, 3 do
        local tagPanel = sender:getParent():getChildByName("tagPanel" .. index)
        if tagPanel.curState == true then
            table.insert(tags, index)
        end
    end
    info.isUpdate = nil
    info.tags = tags
    local friendProxy = self:getProxy(GameProxys.Friend)
    friendProxy:updateWorldCollectionInfo(info)
end

---------------------------------
-- 卡片按钮更新
--state true选中 false未选中
function CollectionPanel:setTagPanelState(tagPanel, state)
    local mask = tagPanel:getChildByName("mask")
    local selectedImg = tagPanel:getChildByName("selectedImg")
    tagPanel.curState = state
    if mask then
        mask:setVisible(not state) -- 暗图
        selectedImg:setVisible(state)
    end
end

------
-- 底部按钮更新 true表示选中
function CollectionPanel:setBottomBtnState(tagPanel, state)
    local tickBg = tagPanel:getChildByName("tickBgImg")
    if tickBg == nil then
        --print("tickBg == nil ")
        return
    end
    local mask = tickBg:getChildByName("mask")
    local tickImg = tickBg:getChildByName("tickImg")
    local selectedImg = tickBg:getChildByName("selectedImg")
    if mask then
        tickImg:setVisible(state)
        selectedImg:setVisible(state)
        mask:setVisible(not state)
    end
    tagPanel.curState = state
    -- 改变选中表的值
    if state then
        self._selectList:replace(tagPanel.index , tagPanel.index)
    else
        self._selectList:replace(tagPanel.index , 0)
    end
end
---------------------------------
--
function CollectionPanel:onHideHandler()
     local friendProxy = self:getProxy(GameProxys.Friend)
     friendProxy:setIsShowCollectSysMsg(false)
     friendProxy:synWorldCollectionInfo()
end

-- 注册收藏分类查看按钮监听事件
function CollectionPanel:registerEvents()
    local downPanel = self:getChildByName("downPanel")
    for index=0, 3 do
    	local tagPanel = downPanel:getChildByName("tagPanel" .. index)
        -- 标识
        tagPanel.index = index
        self:addTouchEventListener(tagPanel, self.onDownPanelTagTouch)
    end
end

-- 底部 收藏分类查看按钮
function CollectionPanel:onDownPanelTagTouch(sender) -- sender
    local tagPanel
    local name = sender:getName()
    local numStr = string.gsub(name,"tagPanel", "")
    local type = tonumber(numStr)
    local downPanel = self:getChildByName("downPanel")
    local curState = sender.curState
    self:setBottomBtnState(sender, not curState)
    self:renderListByType()
end

------
-- 点击查看
function CollectionPanel:onCheckOut(btn)
    local btnData = btn.info
    local detailPanel = self:getPanel(CollectionDetailPanel.NAME)
    detailPanel:show(btnData)
end

