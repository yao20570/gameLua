-----------
---查看配置信息-----

UIWatchOrdnancePiece = class("UIWatchOrdnancePiece")

--即关即释放
function UIWatchOrdnancePiece:ctor(panel, data)
    local uiSkin = UISkin.new("UIWatchOrdnancePiece")
    uiSkin:setParent(panel:getParent())
    uiSkin:setTouchEnabled(true)

    self._uiSkin = uiSkin
    self._panel = panel

    self._data = data
    self:_updateInfo(data)

    self:registerEventHandler()
    
    local secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    secLvBg:setContentHeight(300)
    secLvBg:setBackGroundColorOpacity(128)
    secLvBg:setTitle(TextWords:getTextWord(324))
end

function UIWatchOrdnancePiece:finalize()
    self._uiSkin:finalize()
end

function UIWatchOrdnancePiece:hide()
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnancePiece:_updateInfo(data)
    --兼容宝具碎片
    if data.tag == 2 then
        local pieceInfo = data.piece

        local configData = ConfigDataManager:getConfigById(ConfigData.TreasurePieceConfig, pieceInfo.typeid)

        --合成按钮
        local compoundBtn = self:getChildByName("mainPanel/compoundBtn")
        compoundBtn:setVisible(data.num >= configData.num)
        --parts icon
        local pieceIcon = self:getChildByName("mainPanel/iconContainer")
        local tempData = {}
        tempData.num =  self._data.num --test
        tempData.power =  self._data.power --test
        tempData.typeid =  self._data.typeid --配件的唯一标志ID
   
        local uiIcon = UIIcon.new(pieceIcon,tempData,false)
        uiIcon:setPosition(pieceIcon:getContentSize().width/2,pieceIcon:getContentSize().height/2)
        uiIcon:setShowIconBg(true, "images/newGui1/IconItemBg.png")
        --parts name Label_name
        local pieceName = self:getChildByName("mainPanel/Label_name")
        pieceName:setString(data.name)
        --当前数量
        local pieceNum = self:getChildByName("mainPanel/Label_num_piece")
        pieceNum:setString(pieceInfo.num)
        --碎片描述
        local pieceDec = self:getChildByName("mainPanel/Label_dec")
        pieceDec:setString(data.dec)
        --万能碎片
        local allPiece = self:getChildByName("mainPanel/Label_allPiece")
        local allPieceNum = self:getChildByName("mainPanel/Label_num_allPice")
        allPiece:setString(TextWords:getTextWord(8236)) -- [[万年寒铁]]
        allPiece:setVisible(false)
        allPieceNum:setVisible(false)

    else --军械碎片
        local pieceInfo = data.piece
        local configData = ConfigDataManager:getConfigById(ConfigData.OrdnancePieceConfig, pieceInfo.typeid)
        --parts icon
        local pieceIcon = self:getChildByName("mainPanel/iconContainer")
        local tempData = {}
        tempData.num =  self._data.num --test
        tempData.power =  self._data.power --test
        tempData.typeid =  self._data.typeid --配件的唯一标志ID
   
        local uiIcon = UIIcon.new(pieceIcon,tempData,false)
        uiIcon:setPosition(pieceIcon:getContentSize().width/2,pieceIcon:getContentSize().height/2)
        uiIcon:setShowIconBg(true, "images/newGui1/IconItemBg.png")
        --parts name Label_name
        local pieceName = self:getChildByName("mainPanel/Label_name")
        pieceName:setString(configData.name)
        --当前数量
        local pieceNum = self:getChildByName("mainPanel/Label_num_piece")
        pieceNum:setString(pieceInfo.num)
        --碎片描述
        local pieceDec = self:getChildByName("mainPanel/Label_dec")
        pieceDec:setString(configData.desc)
        --万能碎片
        local allPiece = self:getChildByName("mainPanel/Label_allPiece")
        local allPieceNum = self:getChildByName("mainPanel/Label_num_allPice")
        allPiece:setString(TextWords:getTextWord(8236)) -- [[万年寒铁]]
        -- 需要的数量
        self._needNum = configData.num 
        --获取万能碎片数量
        local partsProxy = self._panel:getProxy(GameProxys.Parts)
        local num = partsProxy:getPieceNumByID(OrdnancePieceType.Universal)
        if num > 0 then
            allPieceNum:setString("*" .. num)
            allPiece:setVisible(true)
            allPieceNum:setVisible(true)
        else
            allPiece:setVisible(false)
            allPieceNum:setVisible(false)
        end
    
        if self:isUniversal(configData) or configData.type == 2 then
            allPiece:setVisible(false)
            allPieceNum:setVisible(false)
        end
    
        --合成按钮
        local compoundBtn = self:getChildByName("mainPanel/compoundBtn")
    
        if self:isUniversal(configData) or configData.type == 2 then --万能碎片 or 不能合成
            compoundBtn:setVisible(false)
        else
            --获取按钮
            local getBtn = self:getChildByName("mainPanel/getBtn")
            if pieceInfo.num + num < configData.num  then
                compoundBtn:setVisible(false)
                getBtn:setVisible(true)
            else
                compoundBtn:setVisible(true)
                getBtn:setVisible(false)
            end 
        end

    end

    
end

function UIWatchOrdnancePiece:isUniversal(configData)
    return configData.ID == OrdnancePieceType.Universal
end


function UIWatchOrdnancePiece:registerEventHandler()
    --分解按钮
    local resolveBtn = self:getChildByName("mainPanel/partBtn")
    --合成按钮
    local compoundBtn = self:getChildByName("mainPanel/compoundBtn")
    --获取按钮
    local getBtn = self:getChildByName("mainPanel/getBtn")
    local closeBtn = self:getChildByName("mainPanel/closeBtn")

    ComponentUtils:addTouchEventListener(getBtn, self.onGetBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(resolveBtn, self.onResolveBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(compoundBtn, self.onCompoundBtnTouch, nil, self)
    
--    getBtn     :setPositionY(395)
--    resolveBtn :setPositionY(395)
--    compoundBtn:setPositionY(395)
end

function UIWatchOrdnancePiece:onCloseBtnTouch(sender)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnancePiece:onResolveBtnTouch(sender)
    self._panel:onResolveTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnancePiece:onCompoundBtnTouch(sender)
    local function sendNew()
        self._panel:onCompoundTouchHandler(self._data)
        TimerManager:addOnce(1, self.finalize, self)
    end
 
    if self._needNum > self._data.num then
        local content = string.format(TextWords:getTextWord(8237), self._needNum - self._data.num )
        self._panel:showMessageBox(content, sendNew)
    else
        sendNew()
    end
end

function UIWatchOrdnancePiece:onGetBtnTouch(sender)
    self._panel:onGetTouchHandler(self._data)
    TimerManager:addOnce(1, self.finalize, self)
end

function UIWatchOrdnancePiece:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

