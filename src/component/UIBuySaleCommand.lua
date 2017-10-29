UIBuySaleCommand = class("UIBuySaleCommand")

------
-- callback  点击购买的回调函数
function UIBuySaleCommand:ctor(panel, callback)
    local uiSkin = UISkin.new("UIBuySaleCommand")
    
    local parent = panel:getLayer(ModuleLayer.UI_TOP_LAYER) -- 弹窗层
    uiSkin:setParent(parent)


    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_11)
    self._panel = panel
    self._parent = parent


    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    self._secLvBg = secLvBg
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(550007)) -- "军资"
    secLvBg:setContentHeight(400)
    
    -- 购买按钮回调函数
    self._buyCallback = callback

    self:registerEvents()

    self:initPanel()
end


function UIBuySaleCommand:registerEvents()
    local mainPanel    = self._uiSkin:getChildByName("mainPanel")
    self._buyBtn       = mainPanel:getChildByName("buyBtn")
    --self._buyBtn:setTitle(TextWords:getTextWord(1605));      
    self._proPanel     = mainPanel:getChildByName("proPanel")    
    self._numTxt       = mainPanel:getChildByName("numTxt")      
    self._remianTimes  = mainPanel:getChildByName("remianTimes") 
    self._maxTimes     = mainPanel:getChildByName("maxTimes")    
    self._goldValueTxt = mainPanel:getChildByName("goldValueTxt")
    self._goldHaveTxt  = mainPanel:getChildByName("goldHaveTxt") 

    ComponentUtils:addTouchEventListener(self._buyBtn, self.onBuyBtn, nil, self)
end

function UIBuySaleCommand:finalize()
    self._uiSkin:finalize()
end

function UIBuySaleCommand:hide()
    TimerManager:addOnce(1, self.finalize, self)
end


function UIBuySaleCommand:initPanel()
    -- 
    self._roleProxy = self._panel:getProxy(GameProxys.Role)

end

-- 初始化
function UIBuySaleCommand:addMoveBtn()
    -- 添加滚动
    local args = {}
    args["moveCallobj"] = self
    args["moveCallback"] = self.onCallback
    local count = 0
--    if self._curBoughtTimes >= #self._configData then
--        count = 0
--    end
    args["count"] = count
    self._uiMoveBtn = UIMoveBtn.new(self._proPanel, args, 0)
    self._uiMoveBtn:setEnterCount(#self._configData - self._curBoughtTimes, true)
end

function UIBuySaleCommand:onCallback(buyCount)
    -- logger:info(buyCount)
    if self._curBoughtTimes >= #self._configData then
        buyCount = 0
    end
    self._buyCount = buyCount

    -- 剩余次数
    self._remianTimes:setString(#self._configData - self._curBoughtTimes - buyCount)
    NodeUtils:fixTwoNodePos(self._remianTimes, self._maxTimes)

    local targetTimes = self._curBoughtTimes + buyCount
    local expendNum = 0 -- 花费
    local gainNum   = 0 -- 购买数

    for i = 1 , #self._configData do
        if i > self._curBoughtTimes and i <= targetTimes then
            local expend = StringUtils:jsonDecode(self._configData[i].expend ) 
            local gain = StringUtils:jsonDecode(self._configData[i].gain ) 
            expendNum = expendNum + expend[3]
            gainNum = gainNum + gain[3]
        end
    end

    self._numTxt:setString(gainNum)
    self._expendNum = expendNum
    self._goldValueTxt:setString(self._expendNum)
end


function UIBuySaleCommand:updateSalePanel(configData, curBoughtTimes)
    self._configData     = configData
    self._curBoughtTimes = curBoughtTimes

    -- 进度
    self:addMoveBtn()

    -- 最大购买次数
    self._maxTimes:setString("/"..#self._configData)

    -- 拥有元宝
    local haveGold = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
    self._goldHaveTxt:setString(haveGold)

    -- 购买按钮
    NodeUtils:setEnable(self._buyBtn, self._curBoughtTimes < #self._configData) 
end




-- 点击购买
function UIBuySaleCommand:onBuyBtn()
    if self._buyCallback then
        if self._buyCount == 0 then
            self._panel:showSysMessage(TextWords:getTextWord(550008)) -- 请选择购买次数
            return 
        end

        self._buyCallback(self._panel, self._expendNum, self._buyCount)
    end
end
















