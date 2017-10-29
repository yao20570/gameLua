UIChooseLegionMember = class("UIChooseLegionMember")

------
-- @param  panel [obj] ����
-- @param  callback [func] �����ȡ�Ļص�����
function UIChooseLegionMember:ctor(panel, callback)
    local uiSkin = UISkin.new("UIChooseLegionMember")
    
    uiSkin:setParent(panel:getParent())


    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_11)
    self._panel = panel
    self._parent = parent


    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    self._secLvBg = secLvBg
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(560017)) -- "������Ϣ"
    secLvBg:setContentHeight(700)
    
    -- ȷ����ť�ص�����
    self._chosenCallback = callback

    self:registerEvents()

    self:initPanel()
end


function UIChooseLegionMember:registerEvents()
    local mainPanel = self._uiSkin:getChildByName("mainPanel")
    self._chooseBtn  = mainPanel:getChildByName("chooseBtn")
    self._listView   = mainPanel:getChildByName("listView")

    ComponentUtils:addTouchEventListener(self._chooseBtn, self.onChooseBtn, nil, self)
end

function UIChooseLegionMember:finalize()
    self._uiSkin:finalize()
end

function UIChooseLegionMember:hide()
    TimerManager:addOnce(1, self.finalize, self)
end

-- ��ʼ��
function UIChooseLegionMember:initPanel()
    self._index = 0 


end

function UIChooseLegionMember:setMemberListView(listData)
    self._listData = listData

    ComponentUtils:renderListView(self._listView, self._listData, self, self.renderItem, nil, nil, 0)
end


function UIChooseLegionMember:renderItem(itemPanel, data, index)
    index = index + 1
    local nameTxt   = itemPanel:getChildByName("nameTxt")  
    local levelTxt  = itemPanel:getChildByName("levelTxt") 
    local powerTxt  = itemPanel:getChildByName("powerTxt") 
    local chosenImg = itemPanel:getChildByName("chosenImg")
    local chooseBg  = itemPanel:getChildByName("chooseBg")
    local headImg   = itemPanel:getChildByName("headImg")

    local powerNameTxt = itemPanel:getChildByName("Label_33")
    powerNameTxt:setString(TextWords:getTextWord(136)) -- ����

    
    nameTxt:setString(data.playerName)
    levelTxt:setString("Lv."..data.level)
    powerTxt:setString( StringUtils:formatNumberByK3(data.capacity) )

    if index == self._index then
        chosenImg:setVisible(true)
    else
        chosenImg:setVisible(false)
    end

    
    chooseBg.index = index
    ComponentUtils:addTouchEventListener(chooseBg, self.onChooseBg, nil, self)

    -- ͷ��
    local headInfo = {}
    headInfo.icon = data.iconId
    headInfo.pendant = 0
    headInfo.preName1 = "headIcon"
	headInfo.preName2 = nil
    headInfo.playerId = rawget(data, "playerId")


    if headImg.head == nil then
        headImg.head = UIHeadImg.new(headImg, headInfo, self)
        headImg.head:setScale(1)
    else
        headImg.head:updateData(headInfo)
    end

    NodeUtils:fixTwoNodePos(nameTxt, levelTxt, 5)
end


function UIChooseLegionMember:onChooseBtn()
    if self._index == 0 then -- ûѡ�����
        self._panel:showSysMessage(TextWords:getTextWord(560018)) -- "����ѡ��һλͬ�˳�Ա"
        return 
    end

    if self._chosenCallback ~= nil then
        self._chosenCallback(self._panel, self._index)
    end
end


function UIChooseLegionMember:onChooseBg(sender)
    self._index = sender.index
    ComponentUtils:renderListView(self._listView, self._listData, self, self.renderItem, nil, nil, 0)
end
















