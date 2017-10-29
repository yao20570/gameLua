FriendListPanel = class("FriendListPanel", BasicPanel)
FriendListPanel.NAME = "FriendListPanel"

function FriendListPanel:ctor(view, panelName)
    FriendListPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function FriendListPanel:finalize()
    FriendListPanel.super.finalize(self)
end

function FriendListPanel:initPanel()
    FriendListPanel.super.initPanel(self)
    self._friendProxy = self:getProxy(GameProxys.Friend)
    self._friendListView = self:getChildByName("friendListView")
    self._friendListView:getItem(0):setVisible(false)

    local inputPanel = self:getChildByName("downPanel/inputPanel")
    self._editBox = ComponentUtils:addEditeBox(inputPanel, 10, self:getTextWord(1104),nil,false)

end

function FriendListPanel:doLayout()
    local downPanel = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._friendListView,downPanel,tabsPanel)
end


function FriendListPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    FriendListPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

--显示搜索到的数据
function FriendListPanel:onFriendSearch(friendInfo)
    self._isSearchState = true
    self:renderListView(self._friendListView, {friendInfo}, self, self.renderItemPanel)
end

function FriendListPanel:resetPanel()
    self._isSearchState = false
    self:reShowFriendPanel()
end

function FriendListPanel:onHideHandler()
    self._isSearchState = false
end

function FriendListPanel:onShowHandler()
    -- 请求好友最新列表
    self._friendProxy:onTriggerNet170000Req()

    ---------
    self:isHaveFriend()
end


--在该面板上，只处理搜索到的更新
--其他面板添加时，重新打开面板 再刷新一遍的
function FriendListPanel:onFriendInfoUpdate(data)
    if #data > 0 then
        local friendInfo = data[1]
        self:renderListView(self._friendListView, {friendInfo}, self, self.renderItemPanel)
        self:updateFriendNum()
        self:isAllBlessed({friendInfo})
    else
        self:reShowFriendPanel()  --重刷一遍
    end
    self:isHaveFriend()
end

function FriendListPanel:reShowFriendPanel()
    if self._friendListView then
        self._friendListView:jumpToTop()
    end

    local friendProxy = self:getProxy(GameProxys.Friend)
    local friendInfos = friendProxy:getFriendInfos()
    self:renderListView(self._friendListView, friendInfos, self, self.renderItemPanel)
    self:updateFriendNum()
    self:isAllBlessed(friendInfos)
    self:isHaveFriend()
end

-- 一键祝福按钮是否变暗
function FriendListPanel:isAllBlessed(data)
    -- body
    local isAllBless = true
    for k,v in pairs(data) do
        if v.blessState == 0 then --未祝福
            isAllBless = false
            break
        end 
    end

    if isAllBless == true then --已全部祝福
        NodeUtils:setEnable(self._autoBlessBtn, false)
    elseif isAllBless == false then --还有未祝福
        NodeUtils:setEnable(self._autoBlessBtn, true)
    end

end

-- 没有好友的话：一键祝福按钮变暗
function FriendListPanel:isHaveFriend()
    local friendProxy = self:getProxy(GameProxys.Friend)
    local friendNum = friendProxy:getFriendNum()

    if friendNum <= 0 then --已全部祝福
        local autoBlessBtn = self:getChildByName("downPanel/autoBlessBtn") --一键祝福
        NodeUtils:setEnable(autoBlessBtn, false)
    end
end

function FriendListPanel:renderItemPanel(itemPanel, friendInfo)
    itemPanel:setVisible(true)
    local listImg = itemPanel:getChildByName("listImg")
    local nameTxt = listImg:getChildByName("nameTxt")
    local lvTxt = listImg:getChildByName("lvTxt")
    local addBtn = listImg:getChildByName("addBtn")
    local blessBtn = listImg:getChildByName("blessBtn")
    local headPanel = listImg:getChildByName("headPanel")
    -- local Button_head = itemPanel:getChildByName("Button_head")
    
    local friendProxy = self:getProxy(GameProxys.Friend)
    
    if self._isSearchState == true then  --搜索状态中
        addBtn:setVisible(true)
        blessBtn:setVisible(false)
        
        local isFriend = friendProxy:isFriend(friendInfo.playerId)
        if isFriend == true then  --已经是好友了
            addBtn:setVisible(false)
            blessBtn:setVisible(true)
            if friendInfo.blessState == 0 then--没祝福过
                NodeUtils:setEnable(blessBtn, true)
                blessBtn:setTitleText(self:getTextWord(1107))
            else
                NodeUtils:setEnable(blessBtn, false)
                blessBtn:setTitleText(self:getTextWord(1108))
            end
        else
            NodeUtils:setEnable(addBtn, true)
            addBtn:setTitleText(self:getTextWord(1105))
        end
    else
        addBtn:setVisible(false)
        blessBtn:setVisible(true)
        local blessState = friendInfo.blessState
        if blessState == 1 then  --已经祝福过了
            NodeUtils:setEnable(blessBtn, false)
            blessBtn:setTitleText(self:getTextWord(1108))
        else
            NodeUtils:setEnable(blessBtn, true)
            blessBtn:setTitleText(self:getTextWord(1107))
        end
    end
    
    nameTxt:setString(friendInfo.name)
    lvTxt:setString("Lv." .. friendInfo.level)


    -- 头像和挂件
    print("好友：iconId="..friendInfo.iconId..",,pendantId="..friendInfo.pendantId)
    local headInfo = {}
    headInfo.icon = friendInfo.iconId
    headInfo.pendant = friendInfo.pendantId
    --headInfo.preName1 = "headIcon"
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    --headInfo.isCreatButton = true
    -- headInfo.isCreatCover = false
    headInfo.playerId = rawget(friendInfo, "playerId")

    local head = itemPanel.head
    if head == nil then
        head = UIHeadImg.new(headPanel,headInfo,self)
        
        itemPanel.head = head
    else
        head:updateData(headInfo)
    end
    local headBtn = head:getButton()
    --headPanel:setScale(0.9)
    --head:setHeadTransparency()
    
    addBtn.friendInfo = friendInfo
    blessBtn.friendInfo = friendInfo
    itemPanel.friendInfo = friendInfo
    headBtn.friendInfo = friendInfo
    
    if itemPanel.addEvent == true then
        return
    end
    
    itemPanel.addEvent = true
    
    self:addTouchEventListener(headBtn, self.onWatchPlayerInfoTouch)
    self:addTouchEventListener(itemPanel, self.onWatchPlayerInfoTouch)
    self:addTouchEventListener(addBtn, self.onAddFriendTouch)
    self:addTouchEventListener(blessBtn, self.onBlessBtnTouch)
end

function FriendListPanel:onWatchPlayerInfoTouch(sender)
    local friendInfo = sender.friendInfo
    
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:watchPlayerInfoReq({playerId = friendInfo.playerId})
end

function FriendListPanel:onAddFriendTouch(sender)
    local friendInfo = sender.friendInfo
    
    local friendProxy = self:getProxy(GameProxys.Friend)
    friendProxy:addFriendReq(friendInfo.playerId)
end

function FriendListPanel:onBlessBtnTouch(sender)
    local friendInfo = sender.friendInfo
    local friendProxy = self:getProxy(GameProxys.Friend)
    friendProxy:blessFriendReq({friendInfo.playerId})
end

-----------
function FriendListPanel:updateFriendNum()
    local friendProxy = self:getProxy(GameProxys.Friend)
    local friendNum = friendProxy:getFriendNum()
    
    -- local text = string.format(self:getTextWord(1110), friendNum, 20)
    local numTxt = self:getChildByName("downPanel/numTxt")
    local numTxtR = self:getChildByName("downPanel/numTxtR")
    numTxt:setString(friendNum)
    -- numTxtR:setString("/20") --最多20个好友

    local size = numTxt:getContentSize()
    numTxtR:setPositionX(numTxt:getPositionX() + size.width)

end

function FriendListPanel:registerEvents()
    local searchBtn = self:getChildByName("downPanel/searchBtn")
    self:addTouchEventListener(searchBtn, self.onSearchBtnTouch)
    -- 关闭按钮废弃
--    local resetBtn = self:getChildByName("downPanel/resetBtn")
--    self:addTouchEventListener(resetBtn, self.onResetBtnTouch)
    
    local autoBlessBtn = self:getChildByName("downPanel/autoBlessBtn") --一键祝福
    self:addTouchEventListener(autoBlessBtn, self.onAutoBlessBtnTouch)
    self._autoBlessBtn = autoBlessBtn
end

function FriendListPanel:onSearchBtnTouch(sender)
    local roleName = self._editBox:getText()
    if roleName == "" then
        return
    end
    
    self:dispatchEvent(FriendEvent.SEARCH_ROLE_REQ, {roleName = roleName, type = 1})
    self._editBox:setText("")
end

function FriendListPanel:onResetBtnTouch(sender)
    if self._isSearchState == true then
        self._isSearchState = false
        self:reShowFriendPanel()  --重刷一遍
    end
    self._editBox:setText("")
end

--一键祝福
function FriendListPanel:onAutoBlessBtnTouch(sender)
    local friendProxy = self:getProxy(GameProxys.Friend)
    local idList = friendProxy:getCanBlessPlayerIdList()
    
    if #idList == 0 then
        return
    end

    local friendProxy = self:getProxy(GameProxys.Friend)
    local friendNum = friendProxy:getFriendNum()
    if friendNum == 0 then
        return
    end

    friendProxy:blessFriendReq(idList)
end






