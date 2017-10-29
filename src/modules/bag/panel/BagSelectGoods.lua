BagSelectGoods = class("BagSelectGoods", BasicPanel)
BagSelectGoods.NAME = "BagSelectGoods"

function BagSelectGoods:ctor(view, panelName)
    BagSelectGoods.super.ctor(self, view, panelName, 400)

    self:setUseNewPanelBg(true)
end

function BagSelectGoods:finalize()
    BagSelectGoods.super.finalize(self)
end

function BagSelectGoods:initPanel()
    BagSelectGoods.super.initPanel(self)
    self._Pane2 = self:getChildByName("Panel_2")
--    self._Pane2:setVisible(false)
    self:setTitle(true, self:getTextWord(5049)) --[[批量使用]]
    self:createMoveBtn()    
end
function BagSelectGoods:registerEvents()
    -- self._closeBtn = self:getChildByName("Panel_2/closeBtn")
    self._useBtn = self:getChildByName("Panel_2/useBtn")
    -- self:addTouchEventListener( self._closeBtn,self.useEvents)
    self:addTouchEventListener(self._useBtn,self.useEvents)
    self["useBtn"] = useBtn
end
--一开始就会调用
function BagSelectGoods:onShowHandler(info)
--  self._Pane2:setVisible(true)
    -- self._ID = info.ID  --换成下一句
    self._ID = info.info.ID
    self._curIndex = info.index   --当前道具在列表中的位置
    self._info = info
    local itemProxy = self:getProxy(GameProxys.Item)
    self._itemNumber = itemProxy:getItemNumByType( self._ID)
    
    local maxCount = self._itemNumber
    if maxCount > 100 then
        maxCount = 100
    end
    self._uiMoveBtn:setEnterCount(maxCount)

    self:showAllTxt(info)
    self:setNumberView(self._itemNumber) 
end

--获取更新信息
function BagSelectGoods:onshowSecondResp(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    local onSencondInfo = itemProxy:onHandleData(data)
    local addTwoTable = itemProxy:onAdd()
    logger:info("AAAAAAAAAAAAA: len %d",table.size(addTwoTable))
    self._useBtn.data = data
end
function BagSelectGoods:createMoveBtn( )
    -- body
    local moveBtnContainer = self:getChildByName("Panel_2/container")
    local args = {}
    args["moveCallobj"] = self
    args["moveCallback"] = self.onCallback
    args["count"] = 1
    self._uiMoveBtn = UIMoveBtn.new(moveBtnContainer, args)
end

function BagSelectGoods:showAllTxt(sender)
    local info = sender["info"]
    local data = sender["data"]
    local descripe = self:getChildByName("Panel_2/descripe")
    local nameTxt = self:getChildByName("Panel_2/nameTxt")
    local container = self:getChildByName("Panel_2/Image_11")
    descripe:setString(info.info)
    nameTxt:setString(info.name)
    nameTxt:setColor(ColorUtils:getColorByQuality(info.color))

    if container.icon ~= nil then
        -- container.icon:removeFromParent()
    end
    local icon = container.icon
    if icon == nil then
        icon = UIIcon.new(container, data)
        container.icon = icon
    else
        icon:updateData(data)
    end
end

function BagSelectGoods:onCallback(count)
    self:setNumberView(count)
end

function BagSelectGoods:setNumberView(count)
    local useBtn = self:getChildByName("Panel_2/useBtn")
    local numTxt = self:getChildByName("Panel_2/numTxt")
    if count == 0 then  --默认1 这时确定按钮 置灰
        NodeUtils:setEnable(useBtn, false)
        count = 1
    else
        NodeUtils:setEnable(useBtn, true)
    end
    
    self._itemNumber = count

    if(count<=self._itemNumber) then
        -- local numStr = string.format("self:getTextWord(495)", count)
        numTxt:setString(count)
    else
        numTxt:setString(self._itemNumber)
    end
end
--使用按钮点击事件
function BagSelectGoods:useEvents(sender)
    if sender == self._useBtn then

        local function removeSwa()
            NodeUtils:removeSwallow()
        end

        local function use()
            local itemProxy = self:getProxy(GameProxys.Item)
            itemProxy:setCurIndex(self._curIndex)
            self:dispatchEvent(BagEvent.ITEM_USE,{typeId = self._ID,num = self._itemNumber})
            TimerManager:addOnce(150, removeSwa, self)
            return ""
        end
        NodeUtils:addSwallow()
        self:hide(use)
        
        if self._info.info.tipShow == 1 then 
            self:showSysMessage(self._info.info.useTips)
        end
    elseif sender == self._closeBtn then
        self:hide()
    end
end
--使用更新
function BagSelectGoods:onUseUpdate(data)

end


-- function BagSelectGoods:onShowHandler(info)
--     self._ID = info.info.ID
--     if self._uiGoodsPanel == nil then
--         self._uiGoodsPanel = UIGoodsPanel.new(self, self, self._ID, 2)
--     else
--         self._uiGoodsPanel:show(self._ID, 2)
--     end
-- end
