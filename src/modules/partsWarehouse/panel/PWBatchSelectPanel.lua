PWBatchSelectPanel = class("PWBatchSelectPanel", BasicPanel)
PWBatchSelectPanel.NAME = "PWBatchSelectPanel"

function PWBatchSelectPanel:ctor(view, panelName)
    PWBatchSelectPanel.super.ctor(self, view, panelName, 320)
    
    self:setUseNewPanelBg(true)
end

function PWBatchSelectPanel:finalize()
    PWBatchSelectPanel.super.finalize(self)
end

function PWBatchSelectPanel:initPanel()
    PWBatchSelectPanel.super.initPanel(self)
    self:setLocalZOrder (PanelLayer.UI_Z_ORDER_1)
    self:registerTouchEventListener()

    -- local Image_bg = self:getChildByName("mainPanel/Image_18")
    -- TextureManager:updateImageView(Image_bg, "images/guiScale9/Frame_item_bg.png")
    
    self:setTitle(true, self:getTextWord(331))
end
function PWBatchSelectPanel:registerTouchEventListener()
    --按钮
    --local closeBtn = self:getChildByName("mainPanel/Button_close")
    local cancelBtn = self:getChildByName("mainPanel/Button_cancel")
    local confirmBtn = self:getChildByName("mainPanel/Button_confirm")
    --self:addTouchEventListener(closeBtn, self.onCloseBtnClicked)
    self:addTouchEventListener(cancelBtn, self.onCancelBtnClicked)
    self:addTouchEventListener(confirmBtn, self.onConfirmBtnClicked)
    --复选框 
    self._checkBox1 = self:getChildByName("mainPanel/CheckBox_1")
    self._checkBox2 = self:getChildByName("mainPanel/CheckBox_2")
    self._checkBox3 = self:getChildByName("mainPanel/CheckBox_3")
    self._checkBox4 = self:getChildByName("mainPanel/CheckBox_4")
end 
function PWBatchSelectPanel:onShowHandler(data)
    --print("type====",data)
    --data:1配件分解，2碎片分解
    self._type = data
    self:resetCheBox()
    local conParts = self:getChildByName("mainPanel/container_parts")
    local conPiece = self:getChildByName("mainPanel/container_piece")
    if data == 1 then
        conParts:setVisible(true)
        conPiece:setVisible(false)
    else
        conParts:setVisible(false)
        conPiece:setVisible(true)
    end 
end 
function PWBatchSelectPanel:resetCheBox()
    self._checkBox1:setSelectedState(false)
    self._checkBox2:setSelectedState(false)
    self._checkBox3:setSelectedState(false)
    self._checkBox4:setSelectedState(false)
end 

--读取碎片配置表
function PWBatchSelectPanel:getPieceConfigData(typeid)
    local t = ConfigDataManager:getConfigData(ConfigData.OrdnancePieceConfig)
    for _,v in pairs(t)do
        if v.ID == typeid then
            return v
        end 
    end 
end 
-------------回调函数定义--------------
--确定
function PWBatchSelectPanel:onConfirmBtnClicked(sender)
    local partsProxy = self:getProxy(GameProxys.Parts)
    local green  = self._checkBox1:getSelectedState()
    local blue   = self._checkBox2:getSelectedState()
    local purple = self._checkBox3:getSelectedState()
    local orange = self._checkBox4:getSelectedState()
    --print("g,b,p,o 2==",green,blue,purple,orange)
    local temp = {}
    temp.datas = {}
    local infos = {}
    if self._type == 2 then
        infos = partsProxy:getPieceInfos()
    else
        infos =  partsProxy:getOrdnanceUnEquipInfos() or {}
    end
    for _,v in pairs(infos) do
        local quality = 2
        if self._type == 1 then
            quality = v.quality
        else
            local t = self:getPieceConfigData(v.typeid)
            quality = t.quality
        end  
        if quality == 2 and green == true then
                table.insert(temp.datas,v)
            elseif quality == 3 and blue == true then
                table.insert(temp.datas,v)
            elseif quality == 4 and purple == true then
                table.insert(temp.datas,v)
            elseif quality == 5 and orange == true then
                table.insert(temp.datas,v)
        end 
    end 
    temp.tag = self._type --碎片分解
    temp.isBatch = true --是否是批量分解
    if table.size(temp.datas) == 0 then
        self:showSysMessage(self:getTextWord(8232))
    else
        UIResolvePreview.new(self, temp)
    end
    
    --[[
    if self._type == 1 then --批量分解配件
        local unEquipParts = partsProxy:getOrdnanceUnEquipInfos()
        for _,v in pairs(unEquipParts)do
            if v.quality == 2 and green == true then
                table.insert(temp.datas,v)
            elseif v.quality == 3 and blue == true then
                table.insert(temp.datas,v)
            elseif v.quality == 4 and purple == true then
                table.insert(temp.datas,v)
            elseif v.quality == 5 and orange == true then
                table.insert(temp.datas,v)
            end 
        end 
        --if #data.id>0 then
            --发送请求
            --partsProxy:ordnanceResolveReq(data)
        --end 
    else --批量分解碎片
        local pieceInfos = partsProxy:getPieceInfos()
        local data = {}
        data.type = 2 -- 批量分解
        data.typeid = {}
        for _,v in pairs(pieceInfos)do
            local temp1 = self:getPieceConfigData(v.typeid)
            local quality = temp1.quality
            if quality == 2 and green == true then
                table.insert(temp.datas,v)
            elseif quality == 3 and blue == true then
                table.insert(temp.datas,v)
            elseif quality == 4 and purple == true then
                table.insert(temp.datas,v)
            elseif quality == 5 and orange == true then
                table.insert(temp.datas,v)
            end 
        end 
        --if #data.typeid>0 then
            --发送请求
           -- partsProxy:pieceResolveReq(data)
        --end 
    end  
  --]]  
    
    self:onClosePanelHandler()
end 
--取消
function PWBatchSelectPanel:onCancelBtnClicked(sender)
    --self:resetCheBox()
    self:onClosePanelHandler()
end
--关闭
function PWBatchSelectPanel:onCloseBtnClicked(sender)
    self:onClosePanelHandler()
end
function PWBatchSelectPanel:onClosePanelHandler()
    PWBatchSelectPanel.super.onClosePanelHandler(self)
    self:hide()
end