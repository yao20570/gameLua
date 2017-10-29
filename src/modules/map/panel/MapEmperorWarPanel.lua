-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MapEmperorWarPanel = class("MapEmperorWarPanel", BasicPanel)
MapEmperorWarPanel.NAME = "MapEmperorWarPanel"

function MapEmperorWarPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapEmperorWarPanel.super.ctor(self, view, panelName, 450, layer)
end

function MapEmperorWarPanel:finalize()
    MapEmperorWarPanel.super.finalize(self)

        if self._leftEffect~=nil then 
        self._leftEffect:finalize()
        self._leftEffect=nil
    end
    if self._rightEffect~=nil then 
        self._rightEffect:finalize()
        self._rightEffect=nil
    end
end

function MapEmperorWarPanel:initPanel()
	MapEmperorWarPanel.super.initPanel(self)
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
end

function MapEmperorWarPanel:registerEvents()
	MapEmperorWarPanel.super.registerEvents(self)

    self._mainPanel = self:getChildByName("mainPanel")
    self._panel01 = self._mainPanel:getChildByName("panel01")
    self._panel02 = self._mainPanel:getChildByName("panel02")

    -- 隐藏收益按钮
    self._earnBtn = self._panel01:getChildByName("earnBtn")
    self._earnBtn:setVisible(false)
    --self:addTouchEventListener(self._earnBtn, self.onEarnBtn)

    -- 帮助按钮
    self._helpBtn = self._mainPanel:getChildByName("helpBtn")
    self:addTouchEventListener(self._helpBtn, self.onHelpBtn)

    self._buffPanel  = self._panel02:getChildByName("buffPanel")
    self._resPanel   = self._panel02:getChildByName("resPanel")

    self._listView = self._buffPanel:getChildByName("listView")
end

function MapEmperorWarPanel:onShowHandler()
    
    self._cityId = self._emperorCityProxy:getCityId()
    self._configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarConfig, self._cityId)

    self:onUpdataEmperorWarPanel()
end


function MapEmperorWarPanel:onUpdataEmperorWarPanel()
    local titleName = self._configInfo.cityName
    self:setTitle(true, titleName) -- 设置皇城名
    
    -- 设置静态显示
    self:setConfigShow(self._panel01)

    -- 设置收益
    self:setEarnPanel()

    -- 设置网络显示
    self:setRespShow()
end


-- 设置静态相关信息
function MapEmperorWarPanel:setConfigShow(panel)
    local nameImg = panel:getChildByName("nameImg")
    local cityImg = panel:getChildByName("cityImg")
    local posTxt  = panel:getChildByName("posTxt")
    
    local id = self._configInfo.ID
    local cityType = self._configInfo.type 

    TextureManager:updateImageView(nameImg, "images/emperorCityIcon/font_city_name"..id..".png")
    TextureManager:updateImageView(cityImg, "images/emperorCityIcon/icon_city"..cityType..".png")
    -- 设置坐标
    posTxt:setString( string.format("(%s, %s)",self._configInfo.dataX , self._configInfo.dataY) )
end

-- 
function MapEmperorWarPanel:setEarnPanel()
    local cityType = self._configInfo.type

    -- 设置标题
    local titleTxt = self._panel02:getChildByName("titleTxt")
    if cityType == 1 then
        -- 占领增益
        titleTxt:setString(self:getTextWord(550027))
    else
        -- 占领收益
        titleTxt:setString(self:getTextWord(550028))
    end

    local data = StringUtils:jsonDecode(self._configInfo.occupyBuff)

    self:setView(data, cityType)
end

------
-- 网络数据
function MapEmperorWarPanel:setRespShow()
    -- 占领
    local legionNameTxt = self._panel01:getChildByName("legionNameTxt")
    local legionName = self._emperorCityProxy:getCityInfo().legionName
    if legionName == "" then
        legionNameTxt:setColor(ColorUtils.wordBadColor)
        legionNameTxt:setString(self:getTextWord(3108))
    else
        legionNameTxt:setColor(ColorUtils.wordNameColor)
        legionNameTxt:setString(legionName)
    end

    -- 状态
    local stateTxt = self._panel01:getChildByName("stateTxt")
    local status = self._emperorCityProxy:getCityStatus()
    stateTxt:setString(self:getTextWord(550002 + status))

    -- 下轮时间
    local timeTxt = self._panel01:getChildByName("timeTxt")
    if status == 3 then -- 准备期，弹窗显示，下轮战斗时间隐藏起来不显示
        timeTxt:setString("")
    else
        local time = self._emperorCityProxy:getOpenTime()
        timeTxt:setString( string.format(self:getTextWord(550009), TimeUtils:setTimestampToString6(time)))
    end
end


function MapEmperorWarPanel:setView(data, cityType)
    if cityType == 1 then -- 军营
        self._buffPanel:setVisible(true)
        self._resPanel :setVisible(false)
        self:setBuffPanel(data)
    else--if cityType == 2 then -- 皇城
        self._buffPanel:setVisible(false)
        self._resPanel :setVisible(true)
        self:setResPanel(data)
    end
end

function MapEmperorWarPanel:setBuffPanel(data)
    
    local listData = {}
    for i = 1, #data do
        local temp = {}
        temp.id = data[i]
        table.insert(listData, temp)
    end

    ComponentUtils:renderListView(self._listView, listData, self, self.renderItem, nil, nil, 0)
end


function MapEmperorWarPanel:renderItem(itemPanel, data, index)
    local warBuffId = data.id-- id的值

    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarBuffConfig, warBuffId)
    local str = configInfo.buffInfo

    local memoTxt = itemPanel:getChildByName("memoTxt")
    memoTxt:setString(str)
end


function MapEmperorWarPanel:setResPanel(data)
    local warBuffId = data[1]
    local configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarBuffConfig, warBuffId)
    local buffInfo = StringUtils:jsonDecode(configInfo.buffInfo)

--    for i = 1 , #buffInfo do
--        local info = buffInfo[i]

--        local power  = info[1]
--        local typeId = info[2]
--        local num    = info[3]

--        local node = self._resPanel:getChildByName("img0"..(typeId - 200))
--        local nameTxt  = node:getChildByName("nameTxt")
--        local valueTxt = node:getChildByName("valueTxt")

----        local resInfo = ConfigDataManager:getConfigByPowerAndID(power, typeId)
----        local name = resInfo.name
----        nameTxt:setString()
--        nameTxt:setString("")

--        local numStr = StringUtils:formatNumberByK3(num)
--        valueTxt:setString(string.format("%s/H", numStr))
--        -- 位置
--        NodeUtils:fixTwoNodePos(nameTxt, valueTxt, -10)
--    end


    logger:info("   war  id "..warBuffId)
    local rewardList =self._resPanel:getChildByName("rewardList")
    local buf = ConfigDataManager:getConfigById(ConfigData.EmperorWarBuffConfig, warBuffId)
    local rewardShow =StringUtils:jsonDecode(buf.buffInfo)
    self:renderListView(rewardList,rewardShow,self,self.renderItemRewardPanel)

    local Panel_34 =self._resPanel:getChildByName("left")
    if self._leftEffect == nil then
      self._leftEffect = self:createUICCBLayer("rgb-fanye", Panel_34)
      self._leftEffect:setPosition(Panel_34:getContentSize().width/2+10,Panel_34:getContentSize().height/2)
    end
    local Panel_35 =self._resPanel:getChildByName("right")
    if self._rightEffect ==nil then
       self._rightEffect = self:createUICCBLayer("rgb-fanye", Panel_35)
       self._rightEffect:setPosition(Panel_35:getContentSize().width/2+10,Panel_35:getContentSize().height/2)
       self._rightEffect:setScale(-1)
    end

end

-- 点击跳转帮助
function MapEmperorWarPanel:onHelpBtn(sender)
    ModuleJumpManager:jump("EmperorCityModule", "EmperorCityHelpPanel")
    self:hide()
end

function MapEmperorWarPanel:renderItemRewardPanel(itemPanel,data,index)
    logger:info("第 "..index.." 四个字段 "..data[1].." "..data[2].."  "..data[3])
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