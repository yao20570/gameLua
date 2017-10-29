
ShopPanel = class("ShopPanel", BasicPanel)
ShopPanel.NAME = "ShopPanel"

function ShopPanel:ctor(view, panelName)
    ShopPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function ShopPanel:finalize()
    ShopPanel.super.finalize(self)
end

function ShopPanel:initPanel()
	ShopPanel.super.initPanel(self)
	
    ----
    self:addTabControl()
    self:setBgType(ModulePanelBgType.NONE)
    
end

function ShopPanel:addTabControl()
   
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(ShopResourcePanel.NAME, self:getTextWord(1601))
    self._tabControl:addTabPanel(ShopGainPanel.NAME, self:getTextWord(1602))
    self._tabControl:addTabPanel(ShopGrowUpPanel.NAME, self:getTextWord(1603))
    self._tabControl:addTabPanel(ShopSpecialPanel.NAME, self:getTextWord(1604))
    self._tabControl:setTabSelectByName(ShopResourcePanel.NAME)
    
    -- self:setTitle(true,self:getTextWord(1600))
    self:setTitle(true, "shop", true)
end

--每次打开系统时调用
function ShopPanel:onShowHandler()
--    ShopPanel.super.onShowHandler(self)
--    self:changeTabSelectByName(ShopResourcePanel.NAME)
--    local panel = self:getPanel(ShopResourcePanel.NAME)
--    panel:show()
end 
--获取商店配置数据
function ShopPanel:getShopConfigDataByType(type)
    --type:1资源，2增益，3成长，4特殊
    local type = type or 1
    local shopConfig = ConfigDataManager:getConfigData(ConfigData.ShopConfig)
    if shopConfig == nil then
        print("shopConfig is nil")
        return
    end 
    local t = {}
    for _,v in pairs(shopConfig) do
        if v.type == type then
            local itemConfig = ConfigDataManager:getConfigById(ConfigData.ItemConfig,v.itemID)
            local data = {}
            data.shopData = v
            data.itemData = itemConfig
            data.power = GamePowerConfig.Item
            table.insert(t,data)
        end 
    end 
    print("type,#t=====",type,#t)
    table.sort(t,function(a,b) return a.shopData.sort < b.shopData.sort end )
    return t
end 
--设置文本颜色
function ShopPanel:setLabelColor(label,quality)
    local white  = ColorUtils.wordWhiteColor
    local green  = ColorUtils.wordGreenColor
    local blue   = ColorUtils.wordBlueColor
    local purple = ColorUtils.wordPurpleColor
    local orange = ColorUtils.wordOrangeColor
    local color = white
    if quality == 2 then
        color = green
    elseif quality == 3 then
        color = blue
    elseif quality == 4 then
        color = purple
    elseif quality == 5 then
        color = orange
    end 
    label:setColor(color)
end 

--发送关闭系统消息
function ShopPanel:onClosePanelHandler()
    self.view:dispatchEvent(ShopEvent.HIDE_SELF_EVENT)
end

function ShopPanel:resetTabSelectByName(name)
    self._tabControl:setTabSelectByName(name)
end

function ShopPanel:setFirstPanelShow(extraMsg)
    if extraMsg ~= nil then
        if extraMsg.panelName ~= nil then
            return
        end
    end
end

function ShopPanel:getItemChildren(item, func)
    local itemChildren = {}
    itemChildren.iconCon   = item:getChildByName("Image_icon")
    itemChildren.labelName = item:getChildByName("Label_name")
    itemChildren.labelDesc = item:getChildByName("Label_desc")
    itemChildren.labelCost = item:getChildByName("Label_cost")
    itemChildren.btnBuy    = item:getChildByName("Button_buy")
    itemChildren.btnBuy:setTitleText(self:getTextWord(1605))
    self:addTouchEventListener(itemChildren.btnBuy, func)

    return itemChildren
end