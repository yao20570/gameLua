
BagView = class("BagView", BasicView)

function BagView:ctor(parent)
    BagView.super.ctor(self, parent)
end

function BagView:finalize()
    BagView.super.finalize(self)
end

function BagView:registerPanels()
    BagView.super.registerPanels(self)

    require("modules.bag.panel.BagPanel")
    self:registerPanel(BagPanel.NAME, BagPanel)
    
    require("modules.bag.panel.BagAllItemPanel")
    self:registerPanel(BagAllItemPanel.NAME, BagAllItemPanel)
    
    require("modules.bag.panel.BagGItemPanel")
    self:registerPanel(BagGItemPanel.NAME, BagGItemPanel)
    
    require("modules.bag.panel.BagOItemPanel")
    self:registerPanel(BagOItemPanel.NAME, BagOItemPanel)
    
    require("modules.bag.panel.BagResourcePanel")
    self:registerPanel(BagResourcePanel.NAME, BagResourcePanel)
    
    require("modules.bag.panel.BagSelectGoods")
    self:registerPanel(BagSelectGoods.NAME, BagSelectGoods)
end

function BagView:initView()
    local panel = self:getPanel(BagPanel.NAME)
    panel:show()
end

function BagView:onItemUpdate()
    local panel = self:getPanel(BagPanel.NAME)
    panel:onItemUpdate()
end

function BagView:hideModuleHandler()
    self:dispatchEvent(BagEvent.HIDE_SELF_EVENT, {})
end
function BagView:onBagInfoResp(data)
    local panel = self:getPanel(BagAllItemPanel.NAME)
    panel:onBagInfoResp(data)
end
--function BagView:onshowSecondResp(data)
--    local panel = self:getPanel(BagSelectGoods.NAME)
--    panel:onshowSecondResp(data)
--end
function BagView:onGetUseResp(data)
    local panel = self:getPanel(BagSelectGoods.NAME)
    panel:useEvents()
end

function BagView:useSurfaceGoods(data)
    -- local panel = self:getPanel(BagPanel.NAME)
    self:useSurfaceGoods(data)
end

function BagView:useEvents(sender, itemList)

    self.lastTypeid = sender.data.typeid
    local itemCfgData = sender.info
    local itemId = sender.data.typeid

    local isHaveGoods1 = false
    local isHaveGoods2 = false
    for k, v in pairs(itemList) do
        for kk, vv in pairs(v) do
            if vv == 4001 then
                isHaveGoods1 = true
            elseif vv == 4002 then
                isHaveGoods2 = true
            end
        end
    end
    if itemId == 3161 then
        if isHaveGoods1 == true then
            self:appearTipIsUse(itemId, 1, 1, 5033, sender)
        else
            self:appearTipIsUse(itemId, 1, 2, 5044, sender)
        end
        return
    elseif itemId == 3162 then
        -- 新春礼包
        if isHaveGoods2 == true then
            self:appearTipIsUse(itemId, 1, 1, 5045, sender)
        else
            self:appearTipIsUse(itemId, 1, 2, 5046, sender)
        end
        return
    elseif itemId == 3351 then
        -- 军团改名卡
        self:enterBaguseGoods(itemCfgData.name, 3351, 0)
        return
    elseif itemId == 3331 then
        -- 身份名牌
        self:enterBaguseGoods(itemCfgData.name, 3331, 1)
        return
    elseif itemCfgData.type == 32 or itemCfgData.type == 29 then
        -- 矿点勘察,定位仪
        self:enterBaguseGoods(itemCfgData.name, itemId, 2)
        return
    elseif itemCfgData.type == 27 then --私人红包
        -- 红包
        self:enterBaguseGoods(itemCfgData.name, itemId, 3)
        return
    elseif itemCfgData.type == 36 then
        -- 公告
        self:enterBaguseGoods(itemCfgData.name, itemId, 4)
        return
        --    elseif itemCfgData.type == 18 then --外观道具
        --        local _typeid = itemId
        --        self:dispatchEvent(BagEvent.SURFACEGOODSUSE_REQ,{})
        --        return
    elseif itemCfgData.type == 42 then
        --红包道具（世界和同盟频道发送红包道具）
        local roleProxy = self:getProxy(GameProxys.Role)
        local roleLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        local itemInfo = ConfigDataManager:getRedItemInfo(itemId) --物品信息
        local redPaketId = itemInfo.redPacketId --红包id
        local redPaketInfo = ConfigDataManager:getRedPacketInfoById(redPaketId) --红包信息
        local limitLv = redPaketInfo.grantLevel--发红包等级限制
        print("jiang ***********************************redPacketId",redPaketId)
        print("jiang ***********************************limitLv",limitLv)
        if roleLevel < limitLv then
            self:showSysMessage(string.format(TextWords:getTextWord(391001),limitLv))
        else
            self:enterBaguseGoods(itemCfgData.name, itemId, 5,itemCfgData.type)
        end 
        return
    elseif itemCfgData.type == 38 then
        -- 军团贡献道具
        local roleProxy = self:getProxy(GameProxys.Role)
        local isHaveLegion = roleProxy:hasLegion()
        if isHaveLegion then
            local data = { }
            data.typeId = itemId
            data.num = 1
            self:dispatchEvent(BagEvent.LEGIONCONTRIBUTEGOODSUSE_REQ, data)
        else
            self:showSysMessage(self:getTextWord(4025))
        end
        return
    elseif itemCfgData.type == 30 then
        -- 迁移主城
        local function useItem()
            self:dispatchEvent(BagEvent.CHANGEPOINTGOODSUSE_REQ, { })
        end
        local function notUseItem()
        end
        local content = string.format(self:getTextWord(5048))
        self:showMessageBox(content, useItem, notUseItem, self:getTextWord(100), self:getTextWord(101))
        return
    end
    local isOtherCanBatch = self:getProxy(GameProxys.Item):isOthenCanBatch(itemId)
    if sender.data.num <= 1 or itemCfgData.use == ItemProxy.USE_TYPE_SINGLE then
        -- 如果数量只有一个直接使用
        local _typeid = itemId
        self:dispatchEvent(BagEvent.ITEM_USE, { typeId = _typeid, num = 1 })
        logger:info(" 使用了一个道具 ".._typeid)
        local itemProxy = self:getProxy(GameProxys.Item)
        itemProxy:setCurIndex(sender.index)
        if itemCfgData.tipShow == 1 then
            self:showSysMessage(itemCfgData.useTips)
        end
        return
    elseif itemCfgData.ShowType == 3 and isOtherCanBatch then
        local panel = self:getPanel(BagSelectGoods.NAME)
        local data = { }
        data.info = itemCfgData
        data.data = sender.data
        data.index = sender.index
        panel:show(data)
        return
    end
    local panel = self:getPanel(BagSelectGoods.NAME)
    -- 物品批量使用选择界面
    local data = { }
    data.info = itemCfgData
    data.data = sender.data
    data.index = sender.index
    panel:show(data)
end

function BagView:enterBaguseGoods(_name,_itemId,_tag,_itemType) --进入特殊道具使用界面
    local data = {}
    data.moduleName = ModuleName.EspecialGoodsUseModule  --特殊道具使用 extraMsg
    data.extraMsg = {name=_name,typeid=_itemId,num=_tag,itemtype=_itemType} 

    self:dispatchEvent(BagEvent.SHOW_OTHER_EVENT,data)

    print("已打开特殊物品使用界面！")

    self:dispatchEvent(BagEvent.HIDE_SELF_EVENT)
end

function BagView:useSurFaceGoods(_typeid) --用外观道具
    local currentUseTypeid = _typeid
    if currentUseTypeid ~= 0 then
        if self.lastTypeid == currentUseTypeid then
            self:dispatchEvent(BagEvent.ITEM_USE,{typeId = self.lastTypeid,num = 1})
            return
        end
    else
        local tmpTypeid = self.lastTypeid
        self:dispatchEvent(BagEvent.ITEM_USE,{typeId = tmpTypeid,num = 1})
        return
    end
    local currentItem = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID",_typeid)
    local function useItem()
             local tmpTypeid = self.lastTypeid
             self:dispatchEvent(BagEvent.ITEM_USE,{typeId = tmpTypeid,num = 1})
          end
          local function notUseItem()
          end
    local content = string.format(self:getTextWord(5047),currentItem.name)
    self:showMessageBox(content, useItem, notUseItem,"使用","取消")
end

function BagView:appearTipIsUse(_typeid,_num,_costType,wordNum, sender)
    local function useItem()
        -- self:dispatchEvent(BagEvent.ITEM_USE,{typeId = _typeid,num = _num,costType = _costType})
        
        if _typeid == 3161 or _typeid == 3162 then
            local function callFunc()
                -- 请求元宝替代开启
                self:dispatchEvent(BagEvent.ITEM_USE,{typeId = _typeid,num = _num,costType = _costType})
            end
            sender.callFunc = callFunc
            sender.money = 50
            self:isShowRechargeUI(sender)

        else
            self:dispatchEvent(BagEvent.ITEM_USE,{typeId = _typeid,num = _num,costType = _costType})
        end
    end

    local function notUseItem()
    end
    local content = string.format(self:getTextWord(wordNum))
    self:showMessageBox(content, useItem, notUseItem,"使用","取消")
end


-- 是否弹窗元宝不足
function BagView:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end

    else
        sender.callFunc()
    end

end
