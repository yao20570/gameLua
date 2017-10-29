-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownTradeResPanel = class("TownTradeResPanel", BasicPanel)
TownTradeResPanel.NAME = "TownTradeResPanel"

function TownTradeResPanel:ctor(view, panelName)
    TownTradeResPanel.super.ctor(self, view, panelName)
end

function TownTradeResPanel:finalize()
    TownTradeResPanel.super.finalize(self)
end

function TownTradeResPanel:initPanel()
	TownTradeResPanel.super.initPanel(self)
    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
    self._roleProxy = self:getProxy(GameProxys.Role)
end

function TownTradeResPanel:registerEvents()
	TownTradeResPanel.super.registerEvents(self)

    self._mainPanel = self:getChildByName("mainPanel")

    self._tradeNumTxt01 = self._mainPanel:getChildByName("tradeNumTxt01")
    self._changeNumTxt = self._mainPanel:getChildByName("changeNumTxt")
    self._useOneTxt = self._mainPanel:getChildByName("useOneTxt")

    self._listView = self._mainPanel:getChildByName("listView")


    self._bottomPanel = self:getChildByName("bottomPanel")

    self._tradeBtn = self._bottomPanel:getChildByName("tradeBtn")
    self:addTouchEventListener(self._tradeBtn, self.onTradeBtn)
end
function TownTradeResPanel:doLayout()


end

function TownTradeResPanel:onShowHandler()
    
    self:onUpdateTownTradeResPanel()
end


function TownTradeResPanel:onClosePanelHandler()
    self:dispatchEvent(TownTradeEvent.HIDE_SELF_EVENT)
end

function TownTradeResPanel:onUpdateTownTradeResPanel()
    self._townId = self._cityWarProxy:getTownId()

    self._index = 1 -- 初始默认选择第一个

    self._configInfo = self._cityWarProxy:getTownConfigInfoById(self._townId)

    self._tradeOpen = self._configInfo.tradeOpen
    self._tradeConfigTimes = self._configInfo.tradeTimes
    self._tradeId = self._configInfo.tradeId


    self._tradeConfigInfo = ConfigDataManager:getConfigById(ConfigData.TradeConfig, self._tradeId)

    self._listData =  self:getTradeData(self._tradeConfigInfo)

    -- 贸易次数，和贸易券
    self:setTradeTxt()
    
    -- 设置初始的两个物品图标
    self:setTwoItemShow(self._index)

    -- 渲染列表
    self:renderListView(self._listView, self._listData, self, self.renderItem, nil, nil, 0)

end

function TownTradeResPanel:getTradeData(tradeConfigInfo)
    local tradeData = {}
    
    for i = 1, 4 do
        local config ={}
        config.resource = tradeConfigInfo.resource
        config.tradeNum = tradeConfigInfo.tradeNum

        local tradeKey = "tradeResource"..i

        config[tradeKey] = tradeConfigInfo[tradeKey]
        table.insert(tradeData, config)
    end
    return tradeData
end

-- 设置
function TownTradeResPanel:setTwoItemShow(index)
    local itemImg01     = self._mainPanel:getChildByName("itemImg01")    
    local itemImg02     = self._mainPanel:getChildByName("itemImg02")        
    local itemNameTxt01 = self._mainPanel:getChildByName("itemNameTxt01")    
    local itemNameTxt02 = self._mainPanel:getChildByName("itemNameTxt02")    
    
    local resource = StringUtils:jsonDecode(self._listData[index].resource )
    local data01 = {}
    data01.power = resource[1]
    data01.typeid= resource[2]
    data01.num   =  self:getCurTradeNum(self._listData[index].tradeNum) -- 兑换数量 = tradeNum*同盟等级

    if itemImg01.uiIcon == nil then
        itemImg01.uiIcon = UIIcon.new(itemImg01, data01, true, nil, nil, true)
        local nameTxt = itemImg01.uiIcon:getNameChild()
        nameTxt:setColor(cc.c3b(156, 114, 76))
        nameTxt:setFontSize(20)
        self._posY01 = nameTxt:getPositionY() - 5
        nameTxt:setPositionY(self._posY01)
    else
        itemImg01.uiIcon:updateData(data01)
        local nameTxt = itemImg01.uiIcon:getNameChild()
        nameTxt:setColor(cc.c3b(156, 114, 76))
        
        nameTxt:setFontSize(20)
        if self._posY01 then
            nameTxt:setPositionY(self._posY01)
        end
    end

    local tradeResource = StringUtils:jsonDecode(self._listData[index]["tradeResource"..index] )
    local data02 = {}
    data02.power = tradeResource[1][1]
    data02.typeid= tradeResource[1][2]
    data02.num   = data01.num *self:getCurTradeRatio(index)
    if itemImg02.uiIcon == nil then
        itemImg02.uiIcon = UIIcon.new(itemImg02, data02, true, nil, nil, true)
        local nameTxt = itemImg02.uiIcon:getNameChild()
        nameTxt:setColor(cc.c3b(156, 114, 76))
        nameTxt:setFontSize(20)
        self._posY02 = nameTxt:getPositionY() - 5
        nameTxt:setPositionY(self._posY02)
    else
        itemImg02.uiIcon:updateData(data02)
        local nameTxt = itemImg02.uiIcon:getNameChild()
        nameTxt:setColor(cc.c3b(156, 114, 76))

        nameTxt:setFontSize(20)
        if self._posY02 then
            nameTxt:setPositionY(self._posY02)
        end
    end



end

-- 获取兑换数量
function TownTradeResPanel:getCurTradeNum(tradeNum)
    --local legionLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_legionLevel)
    local legionLevel = self._roleProxy:getLegionLevel()
    return tradeNum* legionLevel
end

-- 获取当前兑换系数
function TownTradeResPanel:getCurTradeRatio(index)
    local ratio = 1
    local exchangeInfoList = self._cityWarProxy:getExchangeInfoList()
    if exchangeInfoList ~= nil then
        ratio = exchangeInfoList[index].exchangeRatio
    end
    return ratio/100 
end

-- 渲染列表
function TownTradeResPanel:renderItem(itemImg, data, index)
    index = index + 1

    -- 控件响应
    local selectBg = itemImg:getChildByName("selectBg")
    local selectImg = selectBg:getChildByName("selectImg")

    if index == self._index then
        selectImg:setVisible(true)
    else
        selectImg:setVisible(false)
    end

    selectBg.index = index
    self:addTouchEventListener(selectBg, self.onSelectBg)


    -- 显示图标
    local img01 = itemImg:getChildByName("img01")
    local img02 = itemImg:getChildByName("img02")

    -- img 01
    local resource = StringUtils:jsonDecode(self._listData[index].resource )
    local img01Typeid= resource[2]
    TextureManager:updateImageView(img01, string.format("images/newGui1/IconRes%s.png", img01Typeid - 200))

    -- img02
    local tradeResource = StringUtils:jsonDecode(self._listData[index]["tradeResource"..index] )
    local img02Typeid = tradeResource[1][2]
    TextureManager:updateImageView(img02, string.format("images/newGui1/IconRes%s.png", img02Typeid - 200))


    -- 名字
    local nameTxt01 = itemImg:getChildByName("nameTxt01")
    local nameTxt02 = itemImg:getChildByName("nameTxt02")
    nameTxt01:setString(self:getTextWord(407000 + img01Typeid))
    nameTxt02:setString(self:getTextWord(407000 + img02Typeid))

    -- 比例
    local ratioTxt = itemImg:getChildByName("ratioTxt")
    ratioTxt:setString("1："..self:getCurTradeRatio(index))
    
    -- 背景颜色
    local bgUrl = "images/newGui9Scale/S9Gray.png"
    if index %2 == 0 then
        bgUrl = "images/newGui9Scale/S9Black.png"
    end

    TextureManager:updateImageView(itemImg, bgUrl)
end


function TownTradeResPanel:onSelectBg(sender)
    if self._index == sender.index then
        return
    end

    self._index = sender.index
    logger:info("当前的兑换id："..self._index)
    self:renderListView(self._listView, self._listData, self, self.renderItem)

    -- 设置初始的两个物品图标
    self:setTwoItemShow(self._index)
end

-- 点击兑换
function TownTradeResPanel:onTradeBtn(sender)
    local data = {}
    data.townId     = self._townId -- 州城id
    data.exchangeId = self._index  -- 兑换id
    
    self._cityWarProxy:onTriggerNet470009Req(data)
end

function TownTradeResPanel:setTradeTxt()
    local curTownTradeNum = self._cityWarProxy:getCurTownTradeNum()
    local maxTownTradeNum = self._cityWarProxy:getMaxTownTradeNum()

    self._tradeNumTxt01:setString(maxTownTradeNum - curTownTradeNum)
    

    local tradeNum = self._cityWarProxy:getTradeNum() -- 剩余贸易兑换券数量
    self._changeNumTxt:setString(tradeNum)
    local useOne = 1
    self._useOneTxt:setString("/"..useOne)
    NodeUtils:fixTwoNodePos(self._changeNumTxt, self._useOneTxt)
end

------
-- 470009Resp
function TownTradeResPanel:onUpdateTradeEnd()
    self:setTradeTxt()
end





