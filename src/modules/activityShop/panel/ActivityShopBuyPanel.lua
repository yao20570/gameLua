-- /**
--  * @Author:
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description:
--  */
ActivityShopBuyPanel = class("ActivityShopBuyPanel", BasicPanel)
ActivityShopBuyPanel.NAME = "ActivityShopBuyPanel"


function ActivityShopBuyPanel:ctor(view, panelName)
    ActivityShopBuyPanel.super.ctor(self, view, panelName, 460)
    
    self._coupons = nil
    self._isCanBuyMany = true 
    self._shopItemCfg = nil
    self._num = 0
    self._buyNum = 0
    
    self._callBack = nil      

    self._totalMoney = 0
end

function ActivityShopBuyPanel:finalize()
    ActivityShopBuyPanel.super.finalize(self)
end

function ActivityShopBuyPanel:initPanel()
    ActivityShopBuyPanel.super.initPanel(self)

    -- 代理
    self._proxy = self:getProxy(GameProxys.ActivityShop)

    -- 标题
    self:setTitle(true, self:getTextWord(410007))

    -- 容器
    self._panelMain = self:getChildByName("panelMain")

    -- panelTop
    self._panelTop = self._panelMain:getChildByName("panelTop")
    self._imgIcon = self._panelTop:getChildByName("imgIcon")
    self._labName = self._panelTop:getChildByName("labName")
    self._labDesc = self._panelTop:getChildByName("labDesc")

    -- panelMiddle
    self._panelMiddle = self._panelMain:getChildByName("panelMiddle")
    self._labBuyNum = self._panelMiddle:getChildByName("labBuyNum")
    local conBar = self._panelMiddle:getChildByName("panelControl")
    local args = { }
    args["moveCallobj"] = self
    args["moveCallback"] = self.onMoveBtnCallback
    args["count"] = 1
    if self._uiMoveBtn == nil then
        self._uiMoveBtn = UIMoveBtn.new(conBar, args, 1)
    end

    -- panelBottom
    self._panelBottom = self._panelMain:getChildByName("panelBottom")
    
    self._imgBgPrice = self._panelBottom:getChildByName("imgBgPrice")
    self._labPrice = self._imgBgPrice:getChildByName("labPrice")

    self._imgBgRemainNum = self._panelBottom:getChildByName("imgBgRemainNum")
    self._labRemainNum = self._imgBgRemainNum:getChildByName("labRemainNum")
    
    self._imgBgTotal = self._panelBottom:getChildByName("imgBgTotal")
    self._labTotal = self._imgBgTotal:getChildByName("labTotal")

    self._imgBgHaveGold = self._panelBottom:getChildByName("imgBgHaveGold")
    self._labGold = self._imgBgHaveGold:getChildByName("labGold")
    self._labHaveGold = self._imgBgHaveGold:getChildByName("labHaveGold")
    self._imgHaveGold = self._imgBgHaveGold:getChildByName("imgHaveGold")

    self._imgBgRemainTimes = self._panelBottom:getChildByName("imgBgRemainTimes")
    self._labRemainTimes = self._imgBgRemainTimes:getChildByName("labRemainTimes")

    -- 文本位置
    self._txtPostion = {{x = 202, y = 148},{ x = 449, y = 148},{ x = 212, y = 102},{x = 449, y = 102}}


    local buyBtn = self:getChildByName("panelMain/panelBottom/btnBuy")
    self:addTouchEventListener(buyBtn, self.onBuy)
end

function ActivityShopBuyPanel:registerEvents()
    ActivityShopBuyPanel.super.registerEvents(self)
end

function ActivityShopBuyPanel:onClosePanelHandler()
    self:dispatchEvent(ActivityShopEvent.HIDE_SELF_EVENT)
end


-- data 的结构
-- data.sellerType      购买类型
-- data.remainTimes     剩余可购买次数
-- data.coupons         优惠券(没有就传nil)
-- data.isCanBuyMany    能否购买数量>1的
-- data.shopItemCfgId   ShopRewardConfig的Id
-- data.num             物品的库存数量
-- data.callBack        回调函数
-- Panel显示时调用
function ActivityShopBuyPanel:onShowHandler(data)

    --parseProto(data)

    self._coupons = data.coupons
    if self._coupons and self._coupons < 0 then
        self._coupons = 0 
    end

    self._remainTimes = data.remainTimes or 0

    self._isCanBuyMany = data.isCanBuyMany 

    self._shopItemCfg = self._proxy:getShopItemCfgDataByID(data.shopItemCfgId)
    
    self._buyNum = 1

    self._callBack = data.callBack    

    self:setUIByBuyType(data.sellerType)

    self:updatePanel(data.num)
end 

function ActivityShopBuyPanel:updatePanel( num )
    
    self._num = num

    if self._uiMoveBtn ~= nil then
        self._uiMoveBtn:setEnterCount(self._num, true)
    end



    local itemData = StringUtils:jsonDecode(self._shopItemCfg.commodity)
    -- local itemCfgData = ConfigDataManager:getConfigById(ConfigData.ItemConfig, itemData[2])
    local itemCfgData = ConfigDataManager:getConfigByPowerAndID(itemData[1], itemData[2])

    -- icon
    local data = { }
    data.num = 1
    data.power = itemData[1]
    data.typeid = itemData[2]
    if self._uiIcon == nil then
        self._uiIcon = UIIcon.new(self._imgIcon, data, false)
        -- self._uiIcon:setPosition(imgIcon:getContentSize().width / 2, imgIcon:getContentSize().height / 2)
    else
        self._uiIcon:updateData(data)
    end

    -- 名称
    local colorQuality = ColorUtils:getColorByQuality(itemCfgData.color)
    self._labName:setString(itemCfgData.name)
    self._labName:setColor(colorQuality)

    -- 描述
    local str = itemCfgData.info or itemCfgData.desc or ""
    self._labDesc:setString(str)

    -- 单价
    self._labPrice:setString(self._shopItemCfg.saleCost)


    -- 剩余数量
    self._labRemainNum:setString(self._num - self._buyNum)


    -- 总价
    self._labTotal:setString(self._totalMoney)

    -- 剩余可购买次数
    self._labRemainTimes:setString(self._remainTimes)

    -- 滑动条
    if self._isCanBuyMany then        
        self._panelMiddle:setVisible(true)
    else
        self._panelMiddle:setVisible(false)
        self._buyNum = 1
        self._labRemainNum:setString(self._num)
        self._labTotal:setString(self._buyNum * self._shopItemCfg.saleCost)    
    end



    -- 拥有的元宝或优惠券
    if self._coupons then
        self._labHaveGold:setString(self:getTextWord(410009))
        self._imgHaveGold:setVisible(false)
        --self._labGold:setString(self._proxy:getCouponsNum(self._sellerServerData.typeId))
        self._labGold:setString(self._coupons)
    else
        self._labHaveGold:setString(self:getTextWord(410008))
        self._imgHaveGold:setVisible(true)
        local roleProxy = self:getProxy(GameProxys.Role)
        local have = roleProxy:getRolePowerValue(GamePowerConfig.Resource, 206)
        self._labGold:setString(have)
    end

end

-- 是否元宝不足(不足则弹购买元宝面板)
function ActivityShopBuyPanel:isEnoughGold()
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
    -- 拥有元宝
    local coupons = self._coupons or 0
    return self._totalMoney <= ( haveGold + coupons )
end

-- 打开显示充值面板
function ActivityShopBuyPanel:showRechargePanel()
    local parent = self:getParent()
    local panel = parent.panel
    if panel == nil then
        local panel = UIRecharge.new(parent, self)
        parent.panel = panel
    else
        panel:show()
    end
end

-----------------------------------------------按钮事件----------------------------------------------
function ActivityShopBuyPanel:onMoveBtnCallback(count)
   
    self._buyNum = count or 0

    if self._shopItemCfg == nil then
        -- 没数据则返回
        return
    end
    local price = self._shopItemCfg.saleCost
    self._totalMoney = price * self._buyNum

    -- 购买数量
    if self._labBuyNum then
        self._labBuyNum:setString(self._buyNum)
    end

    -- 剩余数量
    if self._labRemainNum then
        self._labRemainNum:setString(self._num - self._buyNum)
    end

    -- 总价
    if self._labTotal then
        self._labTotal:setString(self._totalMoney)
    end
end 

function ActivityShopBuyPanel:onBuy(sender)

    if self:isEnoughGold() == true then
        self._callBack(self._buyNum)
    else
        -- 打开充值面板
        self:showRechargePanel()
    end    
end

function ActivityShopBuyPanel:setUIByBuyType(sellerType)
    
    if sellerType == ActivityShopProxy.SellerDiscount then        
        self._imgBgHaveGold:setPosition(self._txtPostion[3].x, self._txtPostion[3].y)
    else
        self._imgBgHaveGold:setPosition(self._txtPostion[4].x, self._txtPostion[4].y)
    end

    self._imgBgTotal:setVisible(sellerType ~= ActivityShopProxy.SellerDiscount)
    self._imgBgRemainTimes:setVisible(sellerType == ActivityShopProxy.SellerDiscount)
end


