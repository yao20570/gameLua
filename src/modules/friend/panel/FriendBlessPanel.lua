FriendBlessPanel = class("FriendBlessPanel", BasicPanel) --好友祝福
FriendBlessPanel.NAME = "FriendBlessPanel"

function FriendBlessPanel:ctor(view, panelName)
    FriendBlessPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function FriendBlessPanel:finalize()
    FriendBlessPanel.super.finalize(self)
end

function FriendBlessPanel:initPanel()
    FriendBlessPanel.super.initPanel(self)
    
    self._blessListView = self:getChildByName("blessListView")
--    NodeUtils:adaptive(self._blessListView)
    
end

function FriendBlessPanel:doLayout()
    local downPanel = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._blessListView,downPanel,tabsPanel)
end

function FriendBlessPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    FriendBlessPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function FriendBlessPanel:onBlessUpdate(data)
    self:onShowHandler()
end

function FriendBlessPanel:onShowHandler()
    if self._blessListView then
        self._blessListView:jumpToTop()
    end
    local friendProxy = self:getProxy(GameProxys.Friend)
    local blessInfos = friendProxy:getBlessInfos()

    table.sort(blessInfos,function(a,b) return a.getState<b.getState end)

    self:renderListView(self._blessListView, blessInfos, self, self.renderItemPanel)

    self:updateGetBlessNum()
    self:isGetAllBlessed(blessInfos)
end


function FriendBlessPanel:renderItemPanel(itemPanel, blessInfo)
    local listImg = itemPanel:getChildByName("listImg")
    local nameTxt = listImg:getChildByName("nameTxt")
    local lvTxt = listImg:getChildByName("lvTxt")
    local getBtn = listImg:getChildByName("getBtn")
    local headPanel = listImg:getChildByName("headPanel")

    -- local friendProxy = self:getProxy(GameProxys.Friend)
    
    local getState = blessInfo.getState
    -- print("state====",getState)
    -- print("state====",getState)
    -- print("state====",getState)
    if getState == 1 then  --已经领取过了
        NodeUtils:setEnable(getBtn, false)
        getBtn:setTitleText(self:getTextWord(1112))
    else
        NodeUtils:setEnable(getBtn, true)
        getBtn:setTitleText(self:getTextWord(1111))
    end

    nameTxt:setString(blessInfo.name)
    lvTxt:setString("Lv." .. blessInfo.level)


    -- 头像和挂件
    -- print("iconId="..blessInfo.iconId..",,pendantId="..blessInfo.pendantId)
    local headInfo = {}
    headInfo.icon = blessInfo.iconId
    headInfo.pendant = blessInfo.pendantId
    --headInfo.preName1 = "headIcon"
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    --headInfo.isCreatButton = true
    headInfo.playerId = rawget(blessInfo, "playerId")

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

    getBtn.blessInfo = blessInfo
    itemPanel.blessInfo = blessInfo
    headBtn.blessInfo = blessInfo

    if itemPanel.addEvent == true then
        return
    end
    itemPanel.addEvent = true

    self:addTouchEventListener(headBtn, self.onWatchPlayerInfoTouch)
    self:addTouchEventListener(itemPanel, self.onWatchPlayerInfoTouch)
    self:addTouchEventListener(getBtn, self.onGetBtnTouch)
end

function FriendBlessPanel:onWatchPlayerInfoTouch(sender)
    local blessInfo = sender.blessInfo

    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:watchPlayerInfoReq({playerId = blessInfo.playerId})
end


function FriendBlessPanel:onGetBtnTouch(sender)
    local blessInfo = sender.blessInfo
    local friendProxy = self:getProxy(GameProxys.Friend)
    friendProxy:getBlessReq({blessInfo.playerId})
end

---------------------------

function FriendBlessPanel:updateGetBlessNum()
    local friendProxy = self:getProxy(GameProxys.Friend)
    local num = friendProxy:getGetBlessNum()
    if num >= GlobalConfig.BlessEnergyMaxCount then
        num = GlobalConfig.BlessEnergyMaxCount
    end

    -- local text = string.format(self:getTextWord(1113), num, 10)
    local numTxt = self:getChildByName("downPanel/numTxt")
    local numTxtR = self:getChildByName("downPanel/numTxtR")
    numTxt:setString(num)

    local size = numTxt:getContentSize()
    numTxtR:setPositionX(numTxt:getPositionX() + size.width)

end


function FriendBlessPanel:registerEvents()
    local autoGetBtn = self:getChildByName("downPanel/autoGetBtn")    
    self:addTouchEventListener(autoGetBtn, self.onAutoGetBtnTouch)
    self._autoGetBtn = autoGetBtn
end

--一键领取
function FriendBlessPanel:onAutoGetBtnTouch(sender)
    local friendProxy = self:getProxy(GameProxys.Friend)
    local idList = friendProxy:getCanGetBlessPlayerIdList()
    
    if #idList == 0 then
        return
    end
    
    friendProxy:getBlessReq(idList)
end


-- 一键祝福按钮是否变暗
function FriendBlessPanel:isGetAllBlessed(data)
    -- body
    local isAllBless = true
    for k,v in pairs(data) do
        if v.getState == 0 then --未领取祝福
            isAllBless = false
            break
        end 
    end

    if isAllBless == true then --无祝福可领取
        -- self._autoGetBtn:setBright(false)
        -- self._autoGetBtn:setEnabled(false)
        NodeUtils:setEnable(self._autoGetBtn, false)
    elseif isAllBless == false then --有祝福可领取
        -- self._autoGetBtn:setBright(true)
        -- self._autoGetBtn:setEnabled(true)
        NodeUtils:setEnable(self._autoGetBtn, true)
    end

end
