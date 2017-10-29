

CollectionDetailPanel = class("CollectionDetailPanel", BasicPanel)

CollectionDetailPanel.NAME = "CollectionDetailPanel"

CollectionDetailPanel.TYPE01  = 1 -- 资源

CollectionDetailPanel.TYPE00  = 0 -- 玩家



function CollectionDetailPanel:ctor(view, panelName)

    -- 重写之后，类似类似于实例方法，忽略self

    CollectionDetailPanel.super.ctor(self, view, panelName, 400) 



    self:setUseNewPanelBg(true)

end



function CollectionDetailPanel:finalize()

    CollectionDetailPanel.super.finalize(self)

end



function CollectionDetailPanel:initPanel()

	CollectionDetailPanel.super.initPanel(self)

    self:setTitle(true, self:getTextWord(1121))

    self.collectionPanel = self:getPanel(CollectionPanel.NAME)

    -- 勾选按钮列表

    self._tagPanelList = List.new()



    --local midImg = self:getChildByName("infoImg/midImg")

    --TextureManager:updateImageView(midImg, "images/guiScale9/Frame_item_bg.png")



end



function CollectionDetailPanel:registerEvents()

	CollectionDetailPanel.super.registerEvents(self)

end





------

-- 数据传进来，初始化

function CollectionDetailPanel:onShowHandler(btnData)

    self._infoImg = self:getChildByName("infoImg")

    self._deleteBtn = self._infoImg:getChildByName("deleteBtn")

    self._closeBtn = self:getCloseBtn()

    self._headPanel = self:getChildByName("infoImg/midImg/headPanel")

    self._iconPanel = self:getChildByName("infoImg/midImg/iconPanel")

    self._playerPanel = self:getChildByName("infoImg/playerPanel")

    self._resourPanel = self:getChildByName("infoImg/resourPanel")

    self._selectPanel = self._infoImg:getChildByName("selectPanel")

    -- 勾选层

    self._tagPanelList:pushBack(self._selectPanel:getChildByName("tagPanel1"))

    self._tagPanelList:pushBack(self._selectPanel:getChildByName("tagPanel2"))

    self._tagPanelList:pushBack(self._selectPanel:getChildByName("tagPanel3"))

    -- 数据存储

    self._btnData = btnData

    -- 事件响应

    self:addTouchEventListener(self._deleteBtn, self.onDelect)  

    self:addTouchEventListener(self._closeBtn, self.onClose)  

    -- 详细信息设置

    self:setDetails(self._btnData)



    --按钮初始化设置

    self:setSelect(self._btnData)

end



------

-- 删除收藏

function CollectionDetailPanel:onDelect(btn)

    local function okCallBack()

        local friendProxy = self:getProxy(GameProxys.Friend)

        friendProxy:delWorldCollectionInfo(self._btnData)

        self:onClose()

    end

    local content = string.format(self:getTextWord(1114),self._btnData.name)

    self:showMessageBox(content,okCallBack)

end



-----

-- 关闭界面

function CollectionDetailPanel:onClose()

    self:hide()

    -- 刷新listView

    self.collectionPanel:renderListByType()

end



------

-- 初始化详细信息

function CollectionDetailPanel:setDetails(btnData)

    self._playerPanel:setVisible(false)

    self._resourPanel:setVisible(false)



    if btnData.isPerson == CollectionDetailPanel.TYPE00 then

    -- 玩家

        local pendantId = btnData.pendantId --挂件

        local headInfo = {}

        headInfo.icon = btnData.iconId

        headInfo.pendant = pendantId

        --headInfo.preName1 = "headIcon"

        headInfo.preName1 = "headIcon"

        headInfo.preName2 = "headPendant"

        headInfo.isCreatPendant = false

        --headInfo.isCreatButton = true
        headInfo.playerId = rawget(btnData, "playerId")



        local head = self._head

        if head == nil then

            head = UIHeadImg.new(self._headPanel, headInfo,self)

            self._head = head

        else

            self._head:updateData(headInfo)

        end

        self._headPanel:setVisible(true)

        self._iconPanel:setVisible(false)

        --self._headPanel:setScale(0.9)

        --self._head:setHeadTransparency()



        -- 详细信息

        self._playerPanel:setVisible(true)

        local Label_85 = self._playerPanel:getChildByName("Label_85")
        Label_85:setString(TextWords:getTextWord(136))

        local nameTxt  = self._playerPanel:getChildByName("nameTxt")

        local powerTxt = self._playerPanel:getChildByName("powerTxt")

        local guildTxt = self._playerPanel:getChildByName("guildTxt")

        local lvTxt = self._playerPanel:getChildByName("lvTxt")

        -- “军团”文本

        local legionTxt = self._playerPanel:getChildByName("legionTxt")

        -- 设置属性，

        nameTxt :setString(btnData.name)

        powerTxt:setString( StringUtils:formatNumberByK3(btnData.power, nil))

        if btnData.legionName == "" then

            legionTxt:setVisible(false)

            guildTxt:setString("")

        else

            legionTxt:setVisible(true)

            guildTxt:setString(btnData.legionName)

        end

        lvTxt:setString(btnData.level)

    elseif btnData.isPerson == CollectionDetailPanel.TYPE01 then

    -- 资源

        local iconInfo = {}

        iconInfo.power = GamePowerConfig.Collection

        iconInfo.typeid = btnData.buildingType --暂无法获取资源类型

        iconInfo.num = 0



        local icon = self._icon

        if icon == nil then

            icon = UIIcon.new(self._iconPanel,iconInfo,false)

            self._icon = icon

        else

            self._icon:updateData(iconInfo)

        end

        self._headPanel:setVisible(false)

        self._iconPanel:setVisible(true)

        -- 详细信息

        self._resourPanel:setVisible(true)

        local nameTxt  = self._resourPanel:getChildByName("nameTxt")

        local posTxt = self._resourPanel:getChildByName("posTxt")

        nameTxt:setString(btnData.name)

        posTxt :setString( string.format("(%d,%d)", btnData.tileX, btnData.tileY))

    end





end





function CollectionDetailPanel:setSelect(btnData)

    -- 初始化

    for i = 1, self._tagPanelList:size() do

        self._tagPanelList:at(i).info = btnData

        self:setBottomBtnState(self._tagPanelList:at(i), false)

        self:addTouchEventListener(self._tagPanelList:at(i), self.onChangeTagPanelTouch)

    end

    for key, value in pairs(btnData.tags) do

        self:setBottomBtnState(self._tagPanelList:at(value), true)

    end

end





function CollectionDetailPanel:setBottomBtnState(tagPanel, state)

    local tickBg = tagPanel:getChildByName("tickBgImg")

    if tickBg == nil then

        print("tickBg == nil ")

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

end





function CollectionDetailPanel:onChangeTagPanelTouch(sender)

    local curState = sender.curState -- 在setTagPanelState预先设置值

    self:setBottomBtnState(sender, not curState)

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



------

-- 接收界面的值

function CollectionDetailPanel:setSelectList(selectList)

    self._selectList = selectList

end



