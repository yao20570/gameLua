
-- 军师内政  军师子标签界面
-- by fwx 2016.10.20

ConsigliereForeignPanel = class("ConsigliereForeignPanel", BasicPanel)
ConsigliereForeignPanel.NAME = "ConsigliereForeignPanel"

local Select_ZOrder_Normal = 1
local Select_ZOrder_Mask = 10
local Select_ZOrder_Select = 11

function ConsigliereForeignPanel:ctor(view, panelName)
    ConsigliereForeignPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ConsigliereForeignPanel:finalize()
    if self.infoPanel ~= nil then
        self.infoPanel:finalize()
        self.infoPanel = nil
    end
    if self._ccbLeft ~= nil then
        self._ccbLeft:finalize()
        self._ccbLeft = nil
    end
    if self._ccbRight ~= nil then
        self._ccbRight:finalize()
        self._ccbRight = nil
    end


    self._nCurPos = nil
    -- 当前选中标记，在这个界面有效
    ConsigliereForeignPanel.super.finalize(self)
end

function ConsigliereForeignPanel:initPanel()
    ConsigliereForeignPanel.super.initPanel(self)
    self._skin:setLocalZOrder(0)
    -- 当前选中标记，在这个界面有效
    self._nCurPos = nil

    -- 军师配置表
    self._consigConf = ConfigDataManager:getConfigData(ConfigData.InteriorConfig) or { }

    -- 军师代理
    self._proxy = self:getProxy(GameProxys.Consigliere)

    -- 主panel
    self._pnlMain = self:getChildByName("pnlMain")

    self._itemUIMap = { }
    for pos, conf in ipairs(self._consigConf) do
        self._itemUIMap[pos] = self._pnlMain:getChildByName("Panel_" .. pos)
    end


    -- 选择列表
    self._pnlSelect = self._pnlMain:getChildByName("pnlSelect")
    self._pnlSelect:setLocalZOrder(Select_ZOrder_Mask)
    self._pnlSelectMain = self._pnlSelect:getChildByName("pnlSelectMain")
    self._labKey1 = self._pnlSelectMain:getChildByName("labKey1")
    self._labKey2 = self._pnlSelectMain:getChildByName("labKey2")
    self._svConsigliere = self._pnlSelectMain:getChildByName("scrollView")

    self._imgPnlBg = self._pnlSelectMain:getChildByName("imgPnlBg")
    self._labTips = self._pnlSelectMain:getChildByName("labTips")
    self._labTips:setString(self:getTextWord(270083))
    self._imgArrow = self._pnlSelectMain:getChildByName("imgArrow")
    local imgLeft  = self._pnlSelectMain:getChildByName("imgLeft")
    local imgRight = self._pnlSelectMain:getChildByName("imgRight")
    self._ccbLeft = self:createUICCBLayer("rgb-fanye", imgLeft)
    self._ccbRight = self:createUICCBLayer("rgb-fanye", imgRight)  
    imgRight:setScaleX(-1)

    self:hideSelectUI()
end

function ConsigliereForeignPanel:doLayout()

    -- local topPanel = self:getChildByName("Panel_971")
    -- local tabsPanel = self:getTabsPanel()
    -- NodeUtils:adaptiveTopPanelAndListView( topPanel, nil, nil, tabsPanel)
    -- NodeUtils:adaptivePanelBg(self._pnlMain, GlobalConfig.downHeight, topPanel)
    -- NodeUtils:adaptivePanelBg(self._panelBg, GlobalConfig.downHeight-5, tabsPanel) --遮罩

end

function ConsigliereForeignPanel:registerEvents()
    ConsigliereForeignPanel.super.registerEvents(self)

    self:addTouchEventListener(self._pnlSelect, self.onHideSelectList)
end

-- ======================================================
-- 外部调用
-- ======================================================
function ConsigliereForeignPanel:onShowHandler()
    self:updateForeign()
    self:getPanel(ConsiglierePanel.NAME):setblacklayer(false)
end

function ConsigliereForeignPanel:updateForeign()
    local roleProxy = self:getProxy(GameProxys.Role)
    local consigProxy = self._proxy
    local nRoleLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) or 0

    for pos, conf in ipairs(self._consigConf) do
        local item = self._itemUIMap[pos]
        if item then
            item.setSelectState = function(sender, isSelect)
                sender:setLocalZOrder(isSelect and Select_ZOrder_Select or Select_ZOrder_Normal)
                local btnFire = sender:getChildByName("btnFire")
                btnFire:setVisible(isSelect and sender.AdviserInfo ~= nil)
            end

            local lab_lock = item:getChildByName("lab_lock")
            local btnFire = item:getChildByName("btnFire")
            

            local visiLock = conf.openlv and nRoleLevel < conf.openlv
            local strLock = string.format(self:getTextWord(270058), conf.openlv or 0)
            lab_lock:setString(strLock)
            lab_lock:setVisible(visiLock)

            -- 头像
            local posUrl = nil
            local typeId = nil
            local lv = nil
            local name = conf.info or ""
            if pos > 0 then
                posUrl = string.format("images/consigliere/tit2_%d.png", tonumber(pos))
            elseif pos < 0 then
                posUrl = "images/newGui1/adviser_state.png"
            end
            local AdviserInfo = consigProxy:getPosInfoByPos(pos)
            -- 内政职业服务器数据 ForeignInfo { {id,pos}, {id,pos}, ...}
            if AdviserInfo then
                local info = consigProxy:getInfoById(AdviserInfo.id)
                local adviserConf = consigProxy:getDataById(info.typeId) or { }
                typeId = info.typeId
                lv = info.lv
                local vul = consigProxy:analyzeForeignAddVul(adviserConf.quality, conf.effectshow)
                local addShow = StringUtils:jsonDecode(adviserConf.addShow or "[]")
                if addShow and addShow[1] == pos then
                    vul = vul +(addShow[2] or 0)
                end
                name = name .. "+" .. vul ..(pos ~= 1 and "%" or "")
            end

            btnFire:setVisible(self._nCurPos == pos and AdviserInfo ~= nil)

            ComponentUtils:renderConsigliereItem(item, typeId, lv, posUrl, true, nil, nil, name)

            item.AdviserInfo = AdviserInfo
            item.pos = pos
            item.visiLock = visiLock
            item.strLock = strLock
            self:addTouchEventListener(item, self.onShowSelectList)

            btnFire.pos = pos
            self:addTouchEventListener(btnFire, self.onClickReliev)
        end
    end

    self:updateSelectUI()
end

function ConsigliereForeignPanel:showSelectUI()
    local allInfo = self._proxy:getAllInfo()

    local listData = self._proxy:getForeignSelectList()

    if #allInfo == 0 then
        --没有军师
        self:showSysMessage(self:getTextWord(270084))
        local panel = self:getPanel(ConsiglierePanel.NAME)
        panel._tabControl:changeTabSelectByName(ConsigliereRecruitsPanel.NAME)

    elseif #listData <= 0 then
        -- 没军师去抽军师
        self:showSysMessage(self:getTextWord(270084))

    else
        -- 有军师则打开选择列表
        self._pnlSelect:setVisible(true)
        self._jumpIndex = 1
        self:updateSelectUI()
    end
end

function ConsigliereForeignPanel:hideSelectUI()
    self._pnlSelect:setVisible(false)
end

function ConsigliereForeignPanel:updateSelectUI()
    if self._pnlSelect:isVisible() == false then
        return
    end
    
    local item = self._itemUIMap[self._nCurPos]
    local itemSize = item:getContentSize()
    local posWorld = item:convertToWorldSpace(cc.p(0, 0))

    local pnlMainSize = self._pnlSelectMain:getContentSize()
    local posInParent = self._pnlSelectMain:getParent():convertToNodeSpace(posWorld)
    posInParent.x = posInParent.x + itemSize.width


    if self._nCurPos == 1 then
        -- 选择列表在下
        self._pnlSelectMain:setPositionY(posInParent.y - pnlMainSize.height)
        self._labTips:setPositionY(self._imgPnlBg:getPositionY() - self._imgPnlBg:getContentSize().height / 2 - self._labTips:getContentSize().height)
        self._imgArrow:setFlippedY(false)
        self._imgArrow:setPositionY(self._imgPnlBg:getPositionY() + self._imgPnlBg:getContentSize().height / 2)
        self._imgArrow:setPositionX(item:getPositionX() + item:getContentSize().width / 2 + 10)
    else
        -- 选择列表在上
        self._pnlSelectMain:setPositionY(posInParent.y + itemSize.height - 55)
        self._labTips:setPositionY(self._imgPnlBg:getPositionY() + self._imgPnlBg:getContentSize().height / 2)
        self._imgArrow:setFlippedY(true)
        self._imgArrow:setPositionY(self._imgPnlBg:getPositionY() - self._imgPnlBg:getContentSize().height / 2 - self._imgArrow:getContentSize().height)
        self._imgArrow:setPositionX(item:getPositionX() + item:getContentSize().width / 2 - 25)
    end



    local cfgData = self._consigConf[self._nCurPos]
    self._labKey2:setString(cfgData.info)

    local listData = self._proxy:getForeignSelectList()
    self:renderScrollView(self._svConsigliere, "pnlItem", listData, self, self.renderSelectItemUI, self._jumpIndex)
    self._jumpIndex = nil
end

function ConsigliereForeignPanel:renderSelectItemUI(itemUI, data, index)

    if self._nCurPos == nil then
        return
    end

    local imgHead = itemUI:getChildByName("imgHead")
    local labVal = itemUI:getChildByName("labVal")
    local labName = itemUI:getChildByName("labName")

    local serverData = self._proxy:getDataById(data.typeId)

    local cfgData = self._consigConf[self._nCurPos]
    local vul = self._proxy:analyzeForeignAddVul(serverData.quality, cfgData.effectshow)
    local addShow = StringUtils:jsonDecode(serverData.addShow or "[]")
    if addShow and addShow[1] == self._nCurPos then
        vul = vul +(addShow[2] or 0)
    end

    local iconData = { }
    iconData.num = 1
    iconData.typeid = data.typeId
    iconData.power = GamePowerConfig.Counsellor
    if itemUI.iconHead == nil then
        itemUI.iconHead = UIIcon.new(imgHead, iconData, true, self)
        itemUI.iconHead:setTouchEnabled(false)
    else
        itemUI.iconHead:updateData(iconData)
    end

    labName:setColor(ColorUtils:getColorByQuality(serverData.quality))
    labName:setString(serverData.name)

    labVal:setColor(ColorUtils:getColorByQuality(serverData.quality))
    labVal:setString(vul .. (self._nCurPos ~= 1 and "%" or ""))

    itemUI.data = data
    self:addTouchEventListener(itemUI, self.onSetPos)

end


-- ====================================================
-- 打开选择列表
function ConsigliereForeignPanel:onShowSelectList(sender)
    if sender.visiLock then
        -- 已锁定
        self:showSysMessage(sender.strLock)
        return
    end

    -- 前一个选中的item
    if self._nCurPos ~= nil then
        self._itemUIMap[self._nCurPos]:setSelectState(false)
    end

    -- 当前选中的item
    self._nCurPos = sender.pos
    self._itemUIMap[self._nCurPos]:setSelectState(true)

    self:showSelectUI()
end

-- 关闭选择列表
function ConsigliereForeignPanel:onHideSelectList(sender)

    self._itemUIMap[self._nCurPos]:setSelectState(false)

    self._nCurPos = nil

    self:hideSelectUI()
end

-- 卸任请求
function ConsigliereForeignPanel:onClickReliev(sender)
    local pos = sender.pos
    local consigProxy = self:getProxy(GameProxys.Consigliere)
    consigProxy:onTriggerNet260008Req( { pos = pos })
end

-- 任命请求
function ConsigliereForeignPanel:onSetPos(sender)
    local data = {
        id = sender.data.id,
        pos = self._nCurPos,
    }

    local consigProxy = self:getProxy(GameProxys.Consigliere)
    consigProxy:onTriggerNet260007Req(data)
end