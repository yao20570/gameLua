UIShowEarnPanel = class("UIShowEarnPanel")

function UIShowEarnPanel:ctor(panel)
    local uiSkin = UISkin.new("UIShowEarnPanel")
    
    uiSkin:setParent(panel:getParent())

    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_11)
    self._panel = panel
    self._parent = parent

    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    self._secLvBg = secLvBg
    secLvBg:setBackGroundColorOpacity(120)
    
    secLvBg:setContentHeight(320)
    self:registerEvents()
end


function UIShowEarnPanel:registerEvents()
    local mainPanel = self._uiSkin:getChildByName("mainPanel")

    self._listView = mainPanel:getChildByName("listView")

    self._panel01 = mainPanel:getChildByName("panel01")
    self._titleTxt = self._panel01:getChildByName("titleTxt")
    self._listView = self._panel01:getChildByName("listView")
    self._tipTxt = self._panel01:getChildByName("tipTxt")

    self._panel02 = mainPanel:getChildByName("panel02")
    self._imag01 = self._panel02:getChildByName("imag01")

--    nameTxt
--    valueTxt
end



function UIShowEarnPanel:finalize()
    if self._leftEffect~=nil then 
        self._leftEffect:finalize()
        self._leftEffect=nil
    end
    if self._rightEffect~=nil then 
        self._rightEffect:finalize()
        self._rightEffect=nil
    end
    self._uiSkin:finalize()
end

function UIShowEarnPanel:hide()
    TimerManager:addOnce(1, self.finalize, self)
end


function UIShowEarnPanel:setView(data, cityType, tipStr)
    if cityType == 1 then -- 军营
        self._panel01:setVisible(true)
        self._panel02:setVisible(false)
        self:setPanel01(data)
        self._secLvBg:setTitle(TextWords:getTextWord(550027)) -- "占领增益"
        self._tipTxt:setString(tipStr)
    else--if cityType == 2 then -- 皇城
        self._panel01:setVisible(false)
        self._panel02:setVisible(true)
        self:setPanel02(data)
        self._secLvBg:setTitle(TextWords:getTextWord(550028)) -- "占领收益"
        self._tipTxt:setString("")
    end
end

function UIShowEarnPanel:setPanel01(data)
    
    local listData = {}
    for i = 1, #data do
        local temp = {}
        temp.id = data[i]
        table.insert(listData, temp)
    end

    ComponentUtils:renderListView(self._listView, listData, self, self.renderItem, nil, nil, 0)
end


function UIShowEarnPanel:renderItem(itemPanel, data, index)
    local warBuffId = data.id-- id的值

    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarBuffConfig, warBuffId)
    local str = configInfo.buffInfo

    local memoTxt = itemPanel:getChildByName("memoTxt")
    memoTxt:setString(str)
end

function UIShowEarnPanel:setPanel02(data)
    local warBuffId = data[1]
    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarBuffConfig, warBuffId)
    local buffInfo = StringUtils:jsonDecode(configInfo.buffInfo)

    --for i = 1 , #buffInfo do
        --local info = buffInfo[i]

        --local power  = info[1]
        --local typeId = info[2]
        --local num    = info[3]

        --local node = self._panel02:getChildByName("img0"..(typeId - 200))
        --local nameTxt  = node:getChildByName("nameTxt")
        --local valueTxt = node:getChildByName("valueTxt")

        --local resInfo = ConfigDataManager:getConfigByPowerAndID(power, typeId)
        --local name = resInfo.name
        
        --nameTxt:setString(name)
        --local numStr = StringUtils:formatNumberByK3(num)
        --valueTxt:setString(string.format("%s/H", numStr))
    --end
    logger:info("   war  id "..warBuffId)
    local rewardList =self._panel02:getChildByName("rewardList")
    local buf = ConfigDataManager:getConfigById(ConfigData.EmperorWarBuffConfig, warBuffId)
    local rewardShow =StringUtils:jsonDecode(buf.buffInfo)
    ComponentUtils:renderListView(rewardList,rewardShow,self,self.renderItemRewardPanel)

    local Panel_34 =self._panel02:getChildByName("left")
    if self._leftEffect == nil then
      self._leftEffect = UICCBLayer.new("rgb-fanye", Panel_34)
      self._leftEffect:setPosition(Panel_34:getContentSize().width/2+10,Panel_34:getContentSize().height/2)
    end
    local Panel_35 =self._panel02:getChildByName("right")
    if self._rightEffect ==nil then
       self._rightEffect = UICCBLayer.new("rgb-fanye", Panel_35)
       self._rightEffect:setPosition(Panel_35:getContentSize().width/2+10,Panel_35:getContentSize().height/2)
       self._rightEffect:setScale(-1)
    end
end

function UIShowEarnPanel:renderItemRewardPanel(itemPanel,data,index)
    --logger:info("第 "..index.." 四个字段 "..data[1].." "..data[2].."  "..data[3])
    local rewardInfo={}
    rewardInfo.power=data[1]
    rewardInfo.typeid = data[2]
    rewardInfo.num =data[3]
   
    local Panel_39 = itemPanel:getChildByName("Panel_38")
    if itemPanel.icon == nil then
        local icon =UIIcon.new(Panel_39,rewardInfo,true,self,false,true)
        itemPanel.icon =icon
    else
        itemPanel.icon:updateData(rewardInfo)
    end
end
































