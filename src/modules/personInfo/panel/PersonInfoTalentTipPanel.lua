--
-- by fwx 1816.11.18
PersonInfoTalentTipPanel = class("PersonInfoTalentTipPanel", BasicPanel)
PersonInfoTalentTipPanel.NAME = "PersonInfoTalentTipPanel"

local WIN_HEIGHT = 400

function PersonInfoTalentTipPanel:ctor(view, panelName)
    PersonInfoTalentTipPanel.super.ctor(self, view, panelName, WIN_HEIGHT)

    self:setUseNewPanelBg(true)
end

function PersonInfoTalentTipPanel:finalize()
	if self._eff then
		self._eff:finalize()
		self._eff = nil
	end
    PersonInfoTalentTipPanel.super.finalize(self)
end

function PersonInfoTalentTipPanel:initPanel()
	PersonInfoTalentTipPanel.super.initPanel(self)


	self._talentProxy = self:getProxy(GameProxys.Talent)

	self.proxy = self:getProxy(GameProxys.Consigliere)
	self:setLocalZOrder(PanelLayer.UI_Z_ORDER_3)

	self.panel = self:getChildByName( "downPanel" )
	self.textPanel = self.panel:getChildByName("Panel_326")
	-- self.itemPanel = self.panel:getChildByName("Image_29")
	self.btnUse = self.panel:getChildByName("btn_used")

	self.curID = nil
	self.isFullLvState = nil
	self._costItems = {}
    self._notEnoughItem = {}

	self:addTouchEventListener( self.btnUse, function()
		if self.isBtnUse==true then
			self._talentProxy:onTriggerNet390003Req( {talentId=self.curID} )
		elseif self.isBtnUse==false then
			self:showSysMessage( self:getTextWord(210) )
		else
			self:hide()
		end
	end )
end

--事件=======================================================
function PersonInfoTalentTipPanel:registerEvents()
	PersonInfoTalentTipPanel.super.registerEvents( self )
end
function PersonInfoTalentTipPanel:doLayout()
	local panel = self:getChildByName( "downPanel" )
	if not self.oldY then
		self.oldY = panel:getPositionY()
		self:adaptiveContextHeight()
	end
end
function PersonInfoTalentTipPanel:adaptiveContextHeight()
	-- if not self.oldY then return end
	-- if self.isFullLvState then
	-- 	-- self._uiPanelBg:setContentHeight( WIN_HEIGHT-70 )
 --        self._uiPanelBg:setContentHeight( WIN_HEIGHT )
	-- 	-- self.panel:setPositionY( self.oldY - 30 )
	-- else
	-- 	self._uiPanelBg:setContentHeight( WIN_HEIGHT )
	-- 	self.panel:setPositionY( self.oldY )
	-- end
end

-- 390001升级成功返回
function PersonInfoTalentTipPanel:showLevelEff(isMiniIcon)
    
    TimerManager:addOnce(40, self.delayShowLevelEff, self, isMiniIcon)
end

function PersonInfoTalentTipPanel:delayShowLevelEff(isMiniIcon)
    if self._eff ~= nil then
        self._eff:finalize()
    end

    local effname = isMiniIcon and "rpg-zhanfashengjiyuan" or "rpg-zhanfashengjifenxing"
    local icon = self:getChildByName("downPanel/item_1/img_icon")

    if self._ccbnode == nil then
        self._ccbnode = cc.Node:create()
        icon:addChild(self._ccbnode)
    end

    self._eff = UICCBLayer.new(effname, self._ccbnode, nil, function()
        self._eff = nil
    end , true)
    self._eff:setPosition(icon:getContentSize().width * 0.5 , icon:getContentSize().height * 0.5)
end


--刷新=========================================================
function PersonInfoTalentTipPanel:onShowHandler()
	if self._eff then
		self._eff:finalize()
		self._eff = nil
	end
end

-- 刷新入口  M39.TalentInfo talentInfo  
function PersonInfoTalentTipPanel:renderLevel(talentInfo, isLock, callback)

    local id = talentInfo.talentId
    local lv = talentInfo.talentLv
    self.curID = id
    -- logger:info("天赋id", id, talentInfo.talentLv, talentInfo.talentState)

    local item = self.panel:getChildByName("item_1")
    local btnLv = self.panel:getChildByName("btn_levelup")
    local labDes = self.panel:getChildByName("lab_des")
    local labName = self.panel:getChildByName("lab_name")
    local labName2 = self.panel:getChildByName("lab_name2")
    local imgFulllv = self.panel:getChildByName("img_fulllv")
    local txtCost = self.panel:getChildByName("lab_tit")
    local img_bg = item:getChildByName("img_bg")
    local img_icon = item:getChildByName("img_icon")
    local labJiHuoTips = self.panel:getChildByName("labJiHuoTips")
    labJiHuoTips:setVisible(false)



    --记录旧位置
    if not img_bg.old_pos then
        img_bg.old_pos = cc.p(img_bg:getPosition())
    end


    local upgradeConf = self._talentProxy:getWarBookUpgradeByIdLv(id, lv)
    -- 升级表
    local nextConf = self._talentProxy:getWarBookUpgradeByIdLv(id, lv + 1)

    local conf = self._talentProxy:getWarBookConfById(id) or { }
    -- 基础表
    local isMiniIcon = conf.effectShow and conf.effectShow > 0



    local isLevelState = nextConf and not isLock
    -- 升级状态

    -- 名字
    local strDenji = self:getTextWord(573)
    local strLv = strDenji .. lv
    local strLock = not nextConf and(strDenji .. lv) or self:getTextWord(582)
    labName:setString(isLevelState and strLv or strLock)
    labName:setColor(isLock and 
                    ColorUtils:color16ToC3b(ColorUtils.commonColor.Red) or 
                    ColorUtils:color16ToC3b(ColorUtils.commonColor.White))
    labName2:setString(self:getTextWord(579) ..(lv + 1))
    labName2:setPositionX(labName:getPositionX() + labName:getContentSize().width + 3)
    labName2:setVisible(isLevelState)

    -- 描述
    if labDes.richLabel == nil then
        labDes:setString("")
        labDes.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        -- labDes.richLabel:setPositionY( labDes.richLabel:getPositionY()+labDes:getContentSize().height )
        labDes:addChild(labDes.richLabel)
    end

    local isActivate = conf.talentActivate == 1
    self.isFullLvState = nil
    if isLevelState then
        labDes.richLabel:setString(nextConf.info or { })
        txtCost:setString(self:getTextWord(575))
    elseif isLock then
        labDes.richLabel:setString(conf.info or { })
        txtCost:setString(self:getTextWord(574))
    else
        labDes.richLabel:setString(conf.show or { })
        -- 满级
        if isActivate == true then
            -- txtCost:setString(self:getTextWord(583))
            txtCost:setVisible(false)
            labJiHuoTips:setVisible(true)
            labJiHuoTips:setString(self:getTextWord(583))
        else
            txtCost:setString("")
        end
        self.isFullLvState = true
    end
    -- labDes.richLabel:setPositionY(labDes.richLabel:getContentSize().height / 2)

    self:adaptiveContextHeight()

    -- 激活按钮 或者 确定按钮	
    self.btnUse:setVisible(isActivate and lv > 0 or self.isFullLvState)
    -- 是否可激活
    self.btnUse:setColor(isActivate and talentInfo.talentState == 0 and ColorUtils.wordGreyColor or cc.c3b(255, 255, 255))
    self.btnUse:setTitleText(self:getTextWord(isActivate and 208 or 100))

    if isActivate then
        self.isBtnUse = talentInfo.talentState == 1
    else
        self.isBtnUse = nil
    end

    -- 升级按钮
    btnLv:setVisible(isLevelState or isLock)
    if isLock then
        btnLv:setTitleText(self:getTextWord(100))
        self:addTouchEventListener(btnLv, self.hide, nil, nil, 500)
    else
        btnLv:setTitleText(self:getTextWord(580))
        self:addTouchEventListener(btnLv, callback, nil, self, 500)
    end


    -- 标题、图标
    self:setTitle(true, conf.name or "")
    self:renderCostItem(isLevelState and nextConf.talentCost or "[]")
    self.view:renderItemIcon(img_icon, img_bg, isMiniIcon, id)

    if isMiniIcon then
        img_bg:setPosition(img_bg.old_pos.y+15,img_bg.old_pos.x+1)
    else
        img_bg:setPosition(img_bg.old_pos)
    end



    if isLock then
        nextConf = nil
    end

    imgFulllv:setVisible(not nextConf and not isLock)

    -- self.itemPanel:setVisible(isLock)
    self.textPanel:setVisible(isLock)

end

-- 解锁条件 arr且  arr2或  arr3建筑
function PersonInfoTalentTipPanel:renderNeedItem(andArr, orArr, buildingType, buildingLevel)
    local lab_term1 = self.textPanel:getChildByName("lab_term_and1")
    local lab_term2 = self.textPanel:getChildByName("lab_term_and2")
    local lab_term3 = self.textPanel:getChildByName("lab_term_build1")

    local lab_termOrP = self.textPanel:getChildByName("lab_term_or")
    local lab_termOr = self.textPanel:getChildByName("lab_term_or1")

    local texts = { lab_term1, lab_term2, lab_term3 }
    local len = 0

    local pItem

    local function getProperty(v)
        local _id, _lv = v[1], v[2]
        local conf = self._talentProxy:getWarBookConfById(_id) or { }
        local talentInfo = self._talentProxy:getTalentInfoById(_id)
        local _strName = conf.name or ""
        local _isGreenColor =(talentInfo and talentInfo.talentLv >= _lv) and true or false
        return _lv, _strName, _isGreenColor
    end

    for i, v in ipairs(andArr) do
        if v and v[1] then
            len = len + 1
            pItem = texts[len]
            pItem:setVisible(true)
            local addStr = string.format(self:getTextWord(576), len)
            self:renderNeedText(pItem, addStr, getProperty(v))
        end
    end
    self:renderNeedText(lab_termOr, "", getProperty(orArr[1]))
    lab_termOrP:setVisible(lab_termOr:isVisible())
    if pItem then
        lab_termOrP:setPosition(cc.p(pItem:getPositionX() + pItem:getContentSize().width + 5, pItem:getPositionY()))
        lab_termOr:setPosition(lab_termOrP:getPositionX() + 28, lab_termOrP:getPositionY())
    end

    --  -- 取消了建筑条件2017-03-21
    -- len = len + 1
    -- pItem = texts[len]

    -- if buildingType and pItem then
    -- 	local addStr = string.format( self:getTextWord(576), len )
    -- 	local conf = ConfigDataManager:getInfoFindByOneKey( ConfigData.BuildOpenConfig, "type", buildingType)
    -- 	local buildingProxy = self:getProxy( GameProxys.Building )
    -- 	local curBuildlv = buildingProxy:getBuildingMaxLvByType( buildingType )
    -- 	local isGreenColor = curBuildlv>=buildingLevel
    -- 	local strName = conf.name or ""
    -- 	self:renderNeedText( pItem, addStr, buildingLevel, strName, isGreenColor )
    -- elseif pItem then
    -- 	pItem:setVisible(false)
    -- end

    for i = len + 1, #texts do
        texts[i]:setVisible(false)
    end

    if not self.textPanelY then
        self.textPanelY = self.textPanel:getPositionY()
    end
    self.textPanel:setPositionY(self.textPanelY -(3 - len) * 16)
end

function PersonInfoTalentTipPanel:renderNeedText( text, addStr, lv, strName, isGreenColor )
	text:setVisible( not not lv )
	if not lv then return end

	local strLv = " "..lv.."级"
	local isOk = isGreenColor and "(√)" or "(×)"
	text:setString( addStr..strName..strLv..isOk )
	text:setColor( isGreenColor and 
                ColorUtils:color16ToC3b(ColorUtils.commonColor.Green) or 
                ColorUtils:color16ToC3b(ColorUtils.commonColor.Red) )
	return text
end


--消耗
function PersonInfoTalentTipPanel:renderCostItem( talentCost )
	talentCost = talentCost or self.talentCost
	self.talentCost = talentCost

   
    self._notEnoughItem = {}
	local panelCost = self.panel:getChildByName("panel_cost")

	local itemProxy = self:getProxy( GameProxys.Item )

	local ox = panelCost:getPositionX()+panelCost:getContentSize().width*0.5 --+ 50
	local oy = panelCost:getPositionY()+panelCost:getContentSize().height*0.5
	local arr = StringUtils:jsonDecode( talentCost )
	local len = #arr
	local maxLen = len
	local leftx = 0
	for i,v in ipairs(arr) do
		local numberAtBag = itemProxy:getItemNumByType( v[2] )
		local color = numberAtBag>=v[3] and ColorUtils.wordGreenColor16 or ColorUtils.wordRedColor16
		local numStr1 = StringUtils:formatNumberByK( numberAtBag )
		local numStr2 = "/"..StringUtils:formatNumberByK( v[3] )

        if numberAtBag < v[3] then
           self._notEnoughItem[v[2]] = v[3] - numberAtBag
        end
        
		local data = {
			power = v[1],
			typeid = v[2],
			customNumStr = {{{ numStr1, 18, color}, { numStr2, 18, ColorUtils.wordWhiteColor16}  }}
		}
		local item =  self._costItems[i]
		if not item then
			item = ccui.Widget:create()
			self.panel:addChild( item )
			self._costItems[i] = item
		end
		
		if not item.icon then
			item.icon = UIIcon.new( item, data, true, self, nil, true)
			item.contentSize = item.icon:getContentSize()
		else
			item.icon:updateData( data )
		end

		local width = item.contentSize.width + 20
		leftx = ox - width * maxLen * 0.5
		item:setPosition( ox + width * (i - 1) , oy )
		item:setVisible( true )

		len = i
	end

	--隐藏多余
	for i=len+1,10 do
		local item = self._costItems[i]
		if item then
			item:setVisible( false )
		end
	end
	panelCost:setVisible( false )
end

function PersonInfoTalentTipPanel:isUseID( id )
	return self.curID==id
end

