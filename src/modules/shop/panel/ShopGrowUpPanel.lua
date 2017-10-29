
ShopGrowUpPanel = class("ShopGrowUpPanel", BasicPanel)
ShopGrowUpPanel.NAME = "ShopGrowUpPanel"

function ShopGrowUpPanel:ctor(view, panelName)
    ShopGrowUpPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function ShopGrowUpPanel:finalize()
    ShopGrowUpPanel.super.finalize(self)
end

function ShopGrowUpPanel:initPanel()
    ShopGrowUpPanel.super.initPanel(self)
    
    self:initListView()
end

function ShopGrowUpPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    -- NodeUtils:adaptiveListView(self._listView, GlobalConfig.downHeight, tabsPanel,GlobalConfig.topTabsHeight)
    NodeUtils:adaptiveListView(self._scrollView, GlobalConfig.downHeight, tabsPanel,GlobalConfig.topTabsHeight)
    self:createScrollViewItemUIForDoLayout(self._scrollView)
end

--显示界面时调用
function ShopGrowUpPanel:onShowHandler(data)
    -- if self._listView ~= nil then
    --     self._listView:jumpToTop()
    -- end 
    self._itemIndex = 1
    self:updateScrollView()
end

function ShopGrowUpPanel:initListView()
    -- local listView = self:getChildByName("ListView")
    -- local item = listView:getItem(0)
    -- listView:setItemModel(item)
    -- item:setVisible(true)
    local scrollView = self:getChildByName("ScrollView")
    
--    NodeUtils:adaptive(listView)
    -- self._listView = listView
    self._scrollView = scrollView
    self._itemIndex = 1
    -- self:updateListView()
    self:updateScrollView()
end 
-- function ShopGrowUpPanel:updateListView(data)
--     local shopPanel = self:getPanel(ShopPanel.NAME)
--     local data = shopPanel:getShopConfigDataByType(3)
--     self:renderListView(self._listView, data, self, self.renderItemPanel)

-- end 

function ShopGrowUpPanel:updateScrollView(data)
    local shopPanel = self:getPanel(ShopPanel.NAME)
    local data = shopPanel:getShopConfigDataByType(3)

    local tabData = self:translateDataFormat(data)

    --世界buff折扣
    local seasonsProxy = self:getProxy(GameProxys.Seasons)
    self._resCoupon = seasonsProxy:getResCoupon()
    
    self:renderScrollView(self._scrollView, "pnlItem", tabData, self, self.renderItemPanel, self._itemIndex, LayoutConfig.scrollViewRowSpace)
    self._itemIndex = nil
end 

function ShopGrowUpPanel:renderItemPanel(itemPanel,info)

    local panel = self:getPanel(ShopPanel.NAME)

    for i = 1,3 do

        local item = itemPanel:getChildByName("item"..i)

        if info[i] then
            item:setVisible(true)
            local shopData = info[i].shopData
            local itemData = info[i].itemData
            local power = info[i].power
            self:initItem(item)

            ComponentUtils:addTouchEventListener(item.btnBuy, self.onBuyBtnTouch, nil, self)
            --图标
            local imgIcon = item.iconCon
            local data = {}
            data.num = shopData.num
            data.power = power
            data.typeid = shopData.itemID
            local uiIcon = imgIcon.uiIcon
            if uiIcon == nil then
                uiIcon = UIIcon.new(imgIcon,data,true,self)
                imgIcon.uiIcon = uiIcon
            else
                uiIcon:updateData(data)
            end
            uiIcon:setPosition(imgIcon:getContentSize().width/2,imgIcon:getContentSize().height/2)
            --商品名
            item.labelName:setString(itemData.name)
            local quality = itemData.color
            local shopPanel = self:getPanel(ShopPanel.NAME)
            shopPanel:setLabelColor(item.labelName,quality)
            --描述
            item.labelDesc:setString(itemData.info)
            
            --价格（折扣：道具类型type=1有效）
            shopData.offprice = nil  --折扣价
            local price = shopData.goldprice
            if itemData.itemCoupon == 1 then
                price = math.ceil(price * self._resCoupon)
                shopData.offprice = price
            end
            item.labelCost:setString(price)

            --购买按钮
            item.btnBuy.data = info[i]
            --元宝图案和价格永远居中
            local icon_size = item.Image_goldIcon:getContentSize()
            local lab_size = item.labelCost:getContentSize()
            local diff_x = item.labelCost:getPositionX() - item.Image_goldIcon:getPositionX()
            local all_len = icon_size.width + diff_x + lab_size.width
            local parent_size = item:getContentSize()
            local gold_icon_x = (parent_size.width - all_len)/2 + icon_size.width
            item.Image_goldIcon:setPositionX(gold_icon_x)
            local lab_cost_x = gold_icon_x + diff_x
            item.labelCost:setPositionX(lab_cost_x)
        else
            item:setVisible(false)
        end
    end
end 
-- function ShopGrowUpPanel:renderItemPanel(itemPanel,info)
--     local shopData = info.shopData
--     local itemData = info.itemData
--     local power = info.power
--     -- local itemChildren = self:getItemChildren(itemPanel)

--     local panel = self:getPanel(ShopPanel.NAME)
--     local itemChildren = panel:getItemChildren(itemPanel, self.onBuyBtnTouch)
--     --图标
--     local imgIcon = itemChildren.iconCon
--     local data = {}
--     data.num = shopData.num
--     data.power = power
--     data.typeid = shopData.itemID
--     local uiIcon = imgIcon.uiIcon
--     if uiIcon == nil then
--         uiIcon = UIIcon.new(imgIcon,data,true,self)
--         imgIcon.uiIcon = uiIcon
--     else
--         uiIcon:updateData(data)
--     end
--     uiIcon:setPosition(imgIcon:getContentSize().width/2,imgIcon:getContentSize().height/2)
--     --商品名
--     itemChildren.labelName:setString(itemData.name)
--     local quality = itemData.color
--     local shopPanel = self:getPanel(ShopPanel.NAME)
--     shopPanel:setLabelColor(itemChildren.labelName,quality)
--     --描述
--     itemChildren.labelDesc:setString(itemData.info)
--     --价格
--     itemChildren.labelCost:setString(shopData.goldprice)
--     --购买按钮
--     itemChildren.btnBuy.data = info
-- end 
--获取item的子节点
-- function ShopGrowUpPanel:getItemChildren(item)
--     local itemChildren = {}
--     itemChildren.iconCon   = item:getChildByName("Image_icon")
--     itemChildren.labelName = item:getChildByName("Label_name")
--     itemChildren.labelDesc = item:getChildByName("Label_desc")
--     itemChildren.labelCost = item:getChildByName("Label_cost")
--     itemChildren.btnBuy    = item:getChildByName("Button_buy")
--     itemChildren.btnBuy:setTitleText(self:getTextWord(1605))
--     self:addTouchEventListener(itemChildren.btnBuy,self.onBuyBtnTouch)

--     return itemChildren
-- end
function ShopGrowUpPanel:initItem(item)
    item.iconCon            = item:getChildByName("Image_icon")
    item.labelName          = item:getChildByName("Label_name")
    item.labelDesc          = item:getChildByName("Label_desc")
    item.btnBuy             = item:getChildByName("Button_buy")
    item.Image_goldIcon     = item:getChildByName("Image_goldIcon")
    item.labelCost          = item:getChildByName("Label_cost")
end

--@每三个为一个数据
--@data:数组 key = 1...n
--@return:{} --二维数组
function ShopGrowUpPanel:translateDataFormat(data)

    local ret = {}

    local idx = 1

    for i = 1,#data do
        local key = math.floor((i-1)/3)+1
        if not ret[key] then
            ret[key] = {}
        end
        table.insert(ret[key],data[i])
    end

    return ret
end
-----------回调函数定义----------------
--购买按钮回调
function ShopGrowUpPanel:onBuyBtnTouch(sender)
    local panel = self:getPanel(ShopBuyPanel.NAME)
    local data = sender.data
    panel:show(data)
end 