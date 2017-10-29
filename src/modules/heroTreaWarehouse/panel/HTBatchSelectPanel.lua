HTBatchSelectPanel = class("HTBatchSelectPanel", BasicPanel)
HTBatchSelectPanel.NAME = "HTBatchSelectPanel"

function HTBatchSelectPanel:ctor(view, panelName)
    HTBatchSelectPanel.super.ctor(self, view, panelName, 350)

end

function HTBatchSelectPanel:finalize()
    HTBatchSelectPanel.super.finalize(self)
end

function HTBatchSelectPanel:initPanel()
    HTBatchSelectPanel.super.initPanel(self)
    self:setLocalZOrder (PanelLayer.UI_Z_ORDER_1)
    self:registerTouchEventListener()

    local Image_bg = self:getChildByName("mainPanel/Image_18")
    TextureManager:updateImageView(Image_bg, "images/guiScale9/Frame_item_bg.png")
    
    self:setTitle(true, self:getTextWord(331))
end
function HTBatchSelectPanel:registerTouchEventListener()
    --按钮
    --local closeBtn = self:getChildByName("mainPanel/Button_close")
    local cancelBtn = self:getChildByName("mainPanel/cancelBtn")
    local confirmBtn = self:getChildByName("mainPanel/confirmBtn")
    --self:addTouchEventListener(closeBtn, self.onCloseBtnClicked)
    self:addTouchEventListener(cancelBtn, self.onCancelBtnClicked)
    self:addTouchEventListener(confirmBtn, self.onConfirmBtnClicked)
    --复选框 
    self._checkBox1 = self:getChildByName("mainPanel/cb1")
    self._checkBox2 = self:getChildByName("mainPanel/cb2")
    self._checkBox3 = self:getChildByName("mainPanel/cb3")
    self._checkBox4 = self:getChildByName("mainPanel/cb4")
end 
function HTBatchSelectPanel:onShowHandler(data)
    --print("type====",data)
    --data:3宝具分解，4宝具碎片分解
    self._type = data
    self:resetCheBox()
    local conParts = self:getChildByName("mainPanel/container_parts")
    local conPiece = self:getChildByName("mainPanel/container_piece")
    if data == 3 then
        conParts:setVisible(true)
        conPiece:setVisible(false)
    else
        conParts:setVisible(false)
        conPiece:setVisible(true)
    end 
end 
function HTBatchSelectPanel:resetCheBox()
    self._checkBox1:setSelectedState(false)
    self._checkBox2:setSelectedState(false)
    self._checkBox3:setSelectedState(false)
    self._checkBox4:setSelectedState(false)
end 

--读取碎片配置表
function HTBatchSelectPanel:getPieceConfigData(typeid)
    local t = ConfigDataManager:getConfigData(ConfigData.OrdnancePieceConfig)
    for _,v in pairs(t)do
        if v.ID == typeid then
            return v
        end 
    end 
end 
-------------回调函数定义--------------
--确定
function HTBatchSelectPanel:onConfirmBtnClicked(sender)
    local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
    local white  = self._checkBox1:getSelectedState()
    local green   = self._checkBox2:getSelectedState()
    local blue = self._checkBox3:getSelectedState()
    local purple = self._checkBox4:getSelectedState()
    --print("g,b,p,o 2==",green,blue,purple,orange)

    local temp = {}
    temp.datas = {}
    local infos = {}
    if self._type == 3 then
        infos = heroTreasureProxy:getUnEquipInfosList() or {}
    else
        infos =  heroTreasureProxy:getAllTreasurePieceInfosList()  or {}
    end
    for _,v in pairs(infos) do
        local quality = 1
        if self._type == 3 then
            local config = heroTreasureProxy:getDataFromTreasureBaseConfig(v.typeid)
            quality = config.color
        else
            quality = heroTreasureProxy:getDataFromTreasurePieceConfig(v.typeid).quality
        end  
        if quality == 1 and white == true then
                table.insert(temp.datas,v)
            elseif quality == 2 and green == true then
                table.insert(temp.datas,v)
            elseif quality == 3 and blue == true then
                table.insert(temp.datas,v)
            elseif quality == 4 and purple == true then
                table.insert(temp.datas,v)
        end 
    end 
    temp.tag = self._type --3宝具4宝具碎片
    temp.isBatch = true --是否是批量分解
    if table.size(temp.datas) == 0 then
        if self._type == 3 then
        self:showSysMessage(self:getTextWord(3807))
        else
        self:showSysMessage(self:getTextWord(3808))
        end 
    else
        UIResolvePreview.new(self, temp)
    end
    

    self:onClosePanelHandler()

end 
--取消
function HTBatchSelectPanel:onCancelBtnClicked(sender)
    --self:resetCheBox()
    self:onClosePanelHandler()
end
--关闭
function HTBatchSelectPanel:onCloseBtnClicked(sender)
    self:onClosePanelHandler()
end
function HTBatchSelectPanel:onClosePanelHandler()
    HTBatchSelectPanel.super.onClosePanelHandler(self)
    self:hide()
end