-- -------------------------------------------------------------------------------
-- 邮件选择联系人弹窗
-- -------------------------------------------------------------------------------
MailSelectFriendPanel = class("MailSelectFriendPanel", BasicPanel)
MailSelectFriendPanel.NAME = "MailSelectFriendPanel"

function MailSelectFriendPanel:ctor(view, panelName)
    MailSelectFriendPanel.super.ctor(self, view, panelName,770)
    
    self:setUseNewPanelBg(true)
end

function MailSelectFriendPanel:finalize()
    MailSelectFriendPanel.super.finalize(self)
end

function MailSelectFriendPanel:initPanel()
    MailSelectFriendPanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(339))
    self:setLocalZOrder(111)

end

function MailSelectFriendPanel:registerEvents()
    MailSelectFriendPanel.super.registerEvents(self)
    
    self._friendProxy = self:getProxy(GameProxys.Friend)

    local connect_Image = self:getChildByName("connect_Image")
    local teamBtn = connect_Image:getChildByName("teamBtn")
    local nearBtn = connect_Image:getChildByName("nearBtn")
    local friBtn = connect_Image:getChildByName("friBtn")
    local getBtn = connect_Image:getChildByName("getBtn")
    local closeBtn = connect_Image:getChildByName("closeBtn")
    self._chooseAllbtn = connect_Image:getChildByName("choosebtn")
    self._allBtn = connect_Image:getChildByName("allBtn")

    self._tabBtnsMap = {teamBtn,nearBtn,friBtn,getBtn}
    for k,v in pairs(self._tabBtnsMap) do
        v.type = 50000 + k
        v.listview = connect_Image:getChildByTag(v.type)
        self:addTouchEventListener(v,self.onGetFriendsHandle)
    end

    self:addTouchEventListener(self._allBtn,self.onSelectAllHandler)
    self:addTouchEventListener(self._chooseAllbtn,self.onFinallChooseHandler)

end

function MailSelectFriendPanel:onClosePanelHandler()
    -- body
    self:hide()
end

function MailSelectFriendPanel:onShowHandler(data)
    self._nameEditBox = data.nameEditBox
    -- self:onSetFriendPanelStatus(true)
    self._preBtn = nil
    self:onIsShowAllSelect(false)
    -- self:onGetFriendsHandle(self:getChildByName("connect_Image/teamBtn"))
    self:onGetFriendsHandle(self._tabBtnsMap[1])

end

function MailSelectFriendPanel:onGetFriendsHandle(sender)
    self:onSetTabBtnsStatus(sender)
    if sender ~= self._preBtn then
        if self._preBtn ~= nil then
            local preData = self._preBtn.data
            for _,v in pairs(preData) do
                rawset(v,"isSelect",false)
            end
        end
        self._preBtn = sender
        self:onIsShowAllSelect(false)
        local teamBtn = self:getChildByName("connect_Image/teamBtn")
        --if sender.data == nil then
            local nearBtn = self:getChildByName("connect_Image/nearBtn")
            local friBtn = self:getChildByName("connect_Image/friBtn")
            local getBtn = self:getChildByName("connect_Image/getBtn")

            if sender == teamBtn then   --军团
                local roleProxy = self:getProxy(GameProxys.Role)
                if roleProxy:hasLegion() then
                    -- 已加入军团
                    -- 未获取军团信息
                    local proxy = self:getProxy(GameProxys.Legion)
                    sender.data = proxy:getMemberInfoList(false) -- 没有包括自己
                else
                    -- 玩家还没加入军团
                    -- self:showSysMessage(self:getTextWord(4025))
                    sender.data = {}
                end

            elseif sender == nearBtn then  --最近
                -- sender.data = {}
                self._nearBtn = sender
                self:dispatchEvent(MailEvent.GET_LATERPERSON_REQ,{})
                return
            elseif sender == friBtn then   --好友
                sender.data = self._friendProxy:getFriendInfos()
            elseif sender == getBtn then    --收藏
                sender.data = self._friendProxy:getWorldCollectionsByIsPerson(0)
            end
        --end
        for _,v in pairs(sender.data) do
            rawset(v,"isSelect",false)
        end
        self._preBtn.data = sender.data
        self._allBtn:setVisible(false)
        if sender == teamBtn then
            self._allBtn:setVisible(true)
            self:renderListView(sender.listview, sender.data, self, self.registerItemEvents)
        else
            self:renderListView(sender.listview, sender.data, self, self.registerItemEvents1)
        end
    end
end

function MailSelectFriendPanel:onSetTabBtnsStatus(btn)
    for _,v in pairs(self._tabBtnsMap) do
        if v == btn then
            v.listview:setVisible(true)
            v:setColor(cc.c3b(255, 255, 255))
        else
            v.listview:setVisible(false)
            v:setColor(cc.c3b(95, 88, 78))
        end
    end
end

function MailSelectFriendPanel:onUpdateChooseItem(item,data)
    item:setVisible(true)
    
    local person = item:getChildByName("person") --头像
    local name = item:getChildByName("name")
    local chooseBtn = item:getChildByName("chooseBtn")
    local img = chooseBtn:getChildByName("img")
    local fight = item:getChildByName("lvAndFight")
    local lv = item:getChildByName("lv")
    fight:setString("")
    lv:setString("")
    name:setString(data.name)

    chooseBtn.data = data
    if rawget(data,"isSelect") == true then
        img:setVisible(true)
    else
        img:setVisible(false)
    end
    self:addChooseBtnHandle(chooseBtn)


    -- 头像和挂件
    print("玩家：iconId="..data.iconId)
    local headInfo = {}
    headInfo.icon = data.iconId
    headInfo.pendant = nil
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = nil
    headInfo.isCreatPendant = false
    --headInfo.isCreatButton = false
    headInfo.playerId = rawget(data, "playerId") or rawget(data, "id")--[[同盟成员]]

    local head = item.head
    if head == nil then
        head = UIHeadImg.new(person,headInfo,self)
        
        item.head = head
    else
        head:updateData(headInfo)
    end

end

-- 军团联系人列表
function MailSelectFriendPanel:registerItemEvents(item,data,index)
    if item == nil then
        return
    end
    self:onUpdateChooseItem(item,data)

    local fight = item:getChildByName("lvAndFight")
    local lv = item:getChildByName("lv")
    fight:setString(string.format(self:getTextWord(1217), StringUtils:formatNumberByK(data.capacity)))
    lv:setString("Lv."..data.level)
end

-- 最近、好友、收藏联系人列表
function MailSelectFriendPanel:registerItemEvents1(item,data,index)
    if item == nil then
        return
    end
    self:onUpdateChooseItem(item,data)
end

function MailSelectFriendPanel:addChooseBtnHandle(btn)
    if btn.isAddEvent == true then
        return 
    end
    btn.isAddEvent = true
    self:addTouchEventListener(btn,self.onChooseImgHandle)
end

function MailSelectFriendPanel:onChooseImgHandle(sender)
    local img = sender:getChildByName("img")
    if rawget(sender.data,"isSelect") == true then
        img:setVisible(false)
        rawset(sender.data,"isSelect",false)
    else
        img:setVisible(true)
        rawset(sender.data,"isSelect",true)
    end
end

function MailSelectFriendPanel:onCloseFriendsHandler()
    -- self:onSetFriendPanelStatus()
    for _,v in pairs(self._tabBtnsMap) do
        v.data = nil
    end
end

function MailSelectFriendPanel:onAddFriendsHandler(sender) --进入
    -- self:onSetFriendPanelStatus(true)
    self._preBtn = nil
    self:onIsShowAllSelect(false)
    self:onGetFriendsHandle(self:getChildByName("connect_Image/teamBtn"))
end

-- 点击确定按钮
function MailSelectFriendPanel:onFinallChooseHandler(sender)
    local index = 0
    local totalName = ""
    for _,v in pairs(self._preBtn.data) do
        if rawget(v,"isSelect") == true then
            if index ~= 0 then
                totalName = totalName..";"..v.name
            else
                totalName = totalName..v.name
            end
            index = index + 1
        end
    end
    if index == 0 then
        self:showSysMessage(self:getTextWord(1206))
        return
    end
    self._nameEditBox:setText(totalName)
    -- self:onSetFriendPanelStatus()
    self:onClosePanelHandler()
end

function MailSelectFriendPanel:onSelectAllHandler(sender)
    local data = self._preBtn.data
    local status = false
    if sender.isShow == false then
        status = true
    else
        status = false
    end
    for _,v in pairs(data) do
        rawset(v,"isSelect",status)
        rawset(v,"isUpdate",true)
    end
    self:onIsShowAllSelect(status)
    self:renderListView(self._preBtn.listview, self._preBtn.data, self, self.registerItemEvents)
end

function MailSelectFriendPanel:onIsShowAllSelect(isShow)  --全选的图片是否显示
    local img = self._allBtn:getChildByName("img")
    img:setVisible(isShow)
    self._allBtn.isShow = isShow
end

function MailSelectFriendPanel:onLaterPersonResp(data)  --最近联系人列表
    print("最近联系人列表长度: data="..#data)

    for _,v in pairs(data) do
        rawset(v,"isSelect",false)
    end

    local sender = self._nearBtn
    sender.data = data

    self._preBtn.data = sender.data
    self._allBtn:setVisible(false)

    self:renderListView(sender.listview, sender.data, self, self.registerItemEvents1)

end


-- function MailSelectFriendPanel:onSetFriendPanelStatus(sender)
--     local connect_Image = self:getChildByName("connect_Image")
--     if sender ~= nil then
--         connect_Image:setVisible(true)
--     else
--         connect_Image:setVisible(false)
--     end
-- end
