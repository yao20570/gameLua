
EmperorAwardPanel = class("EmperorAwardPanel", BasicPanel)
EmperorAwardPanel.NAME = "EmperorAwardPanel"

function EmperorAwardPanel:ctor(view, panelName)
    EmperorAwardPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)

    self.EmperorEnfeoffsConfig = require("excelConfig.EmperorEnfeoffsConfig")
    self.emperorAwardProxy = self:getProxy(GameProxys.EmperorAward)
    self.tb = {}
end

function EmperorAwardPanel:finalize()
    EmperorAwardPanel.super.finalize(self)
end

function EmperorAwardPanel:initPanel()
	EmperorAwardPanel.super.initPanel(self)
	self:setTitle(true,"EmperorEnfeoffs",true)
	local topPanel = self:getChildByName("topPanel")
	-- self._downPanel = self:getChildByName("downPanel")
	-- self:adjustBootomBg(self._downPanel, topPanel,true)
    self:setBgType(ModulePanelBgType.ACTIVITY)
	self._timeLab = self:getChildByName("topPanel/infoPanel/timeLab") --活动时间
    self._descLab = self:getChildByName("topPanel/infoPanel/descLab") --活动描述
    self._descLab:setColor(cc.c3b(244,244,244))
    self._descLab:setFontSize(18)
----------------------------------------------------------
	self._chargeBtn = self:getChildByName("topPanel/mainPanel/bottonPanel/chargeBtn") -- 链接充值panel
	self._chargeNunLab = self:getChildByName("topPanel/mainPanel/bottonPanel/chargeNunLab")--充值数量
	self._tipsBtn = self:getChildByName("topPanel/infoPanel/tipsBtn") --！提示说明
	self._loadingBar = self:getChildByName("topPanel/mainPanel/loadingBar") --进度条
	self._items = {}
	for i = 1, 5 do
		self._items[i] = self:getChildByName("topPanel/mainPanel/itemPanel/item"..i.."Panel")
	end

    self._descLab:setString(TextWords:getTextWord(230204))

    local tipLab = self:getChildByName("topPanel/mainPanel/bottonPanel/tipLab")--提示文本
    --tipLab:setVisible(false)
    
end

function EmperorAwardPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local topAdaptivePanel = self:topAdaptivePanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, topAdaptivePanel)
end

function EmperorAwardPanel:registerEvents()
	EmperorAwardPanel.super.registerEvents(self)
	self:addTouchEventListener(self._chargeBtn,self.onchargeBtnToch)
    self:addTouchEventListener(self._tipsBtn,self.onTipsBtnToch)
    for i = 1, 5 do
        local getBtn = self:getChildByName("topPanel/mainPanel/itemPanel/item"..i.."Panel/getBtn")
        self:addTouchEventListener(getBtn,self.onGetBtnTouch)
    end
end

function EmperorAwardPanel:onTipsBtnToch(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	local lines = {}
	for i=1,3 do
		lines[i] = {{content = TextWords:getTextWord(230200 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}
	end
	uiTip:setAllTipLine(lines)
end

function EmperorAwardPanel:onClosePanelHandler()
    self:dispatchEvent(EmperorAwardEvent.HIDE_SELF_EVENT)
end

function EmperorAwardPanel:onchargeBtnToch()
    ModuleJumpManager:jump( ModuleName.RechargeModule)
end

function EmperorAwardPanel:onShowHandler()
    -- logger:info(" EmperorAwardPanel:onShowHandler()")
    self.emperorAwardProxy:updateCurActivityData()
    self:updateDatas()
    self:updateBtns()
    self:updateThisPanel()
end

function EmperorAwardPanel:updateDatas()
    self.info = {}
    local effectid = self.emperorAwardProxy:getEffectId()
    for i, v in ipairs(self.EmperorEnfeoffsConfig) do
        if v.effectgroup == effectid then
            v.id = i
            table.insert(self.info, v)
        end
    end
end


function EmperorAwardPanel:updateThisPanel()
    local chargeValue = self.emperorAwardProxy:getChargeValue()
    if chargeValue < self.info[1].recharge then
        pct = 0
    elseif chargeValue< self.info[2].recharge then
        pct = 20
    elseif chargeValue< self.info[3].recharge then
        pct = 40 
    elseif chargeValue< self.info[4].recharge then
        pct = 60
    elseif chargeValue< self.info[5].recharge then
        pct = 80
    elseif chargeValue >= self.info[5].recharge then
        pct = 100
    end
    self._loadingBar:setPercent(pct)

    self._timeLab:setString(self.emperorAwardProxy:getAwardTime())
    local chargeValue = self.emperorAwardProxy:getChargeValue()
    self._chargeNunLab:setString(chargeValue)
    for index = 1, 5 do
        self:updateItem(index)
    end
end

function EmperorAwardPanel:updateItem(index)
    local info = self.info[index]
    local needChargeLab = self._items[index]:getChildByName("needChargeLab")
    needChargeLab:setString(info.recharge)
    -- local getLab = self._items[index]:getChildByName("getLab")
    local getBtn = self._items[index]:getChildByName("getBtn")
    local getBtnLab = getBtn:getChildByName("getBtnLab")
    local changePanel = self._items[index]:getChildByName("changePanel")
    local changeBtn = changePanel:getChildByName("changeBtn")
    local fixGoods = RewardManager:jsonRewardGroupToArray(info.reward)
    for i, v in pairs(fixGoods) do
        local iconContainer = self._items[index]:getChildByName("goods"..i.."Panel")
        if self._items[index][i] then
            self._items[index][i]:updateData(v)
        else
            self._items[index][i] = UIIcon.new(iconContainer, v, true, self)
        end
    end
    local ChoiceRewardConfig = require("excelConfig.ChoiceRewardConfig")
    if self._items[index][3] then
        self._items[index][3]:setVisible(#fixGoods == 3)
    end
    local changeImg = self._items[index]:getChildByName("changePanel")
    changeImg:setVisible(#fixGoods < 3)
    -- changeImg:setVisible(false)
    if #fixGoods < 3  then
        local btnChoose = self._items[index]:getChildByName("goods3Panel")
        btnChoose.index = info.ID
        -- btnChoose:setAnchorPoint(0.5,0.5)
        local url = "images/itemIcon/"..ChoiceRewardConfig[info.bonus].icon..".png"
        local quality = ChoiceRewardConfig[info.bonus].color
        local chooseGetIDs = self.emperorAwardProxy:getChooseGetIDs(info.ID)
        if chooseGetIDs then
            if #chooseGetIDs == 1 then
                local ChoiceContentConfig = require("excelConfig.ChoiceContentConfig")
                local goodsItem  = ChoiceContentConfig[chooseGetIDs[1]]
                local power,typeid = goodsItem.type, goodsItem.contentID
                infos = ConfigDataManager:getConfigByPowerAndID(power, typeid)
                url = infos.url
                quality = infos.quality
                if quality == nil then
                    quality = infos.color
                end
                if quality == nil then
                    quality = 1
                end
            end
        end
        local url2 = "images/newGui1/IconPinZhi"..quality..".png"
        if btnChoose.spr then
            btnChoose.spr:setVisible(true)
            TextureManager:updateImageView(btnChoose.spr, url)
            TextureManager:updateSprite(btnChoose.Effect,url2)
        else
            local url3 ="images/newGui2/Frame_prop_1.png"
            btnChoose.bg= TextureManager:createImageView(url3)
            btnChoose.bg:setAnchorPoint(0.5,0.5)
            btnChoose.bg:setPosition(cc.p(btnChoose.bg:getContentSize().width * 0.5, btnChoose.bg:getContentSize().height * 0.5 - 5))
            btnChoose.bg:setTouchEnabled(false)
            btnChoose:addChild(btnChoose.bg)
            btnChoose.spr= TextureManager:createImageView(url)
            btnChoose.spr:setAnchorPoint(0.5,0.5)
            btnChoose.spr:setPosition(btnChoose.bg:getPosition())
            -- btnChoose.spr:setTouchEnabled(false)
            btnChoose:addChild(btnChoose.spr)
            btnChoose.Effect = TextureManager:createSprite(url2)
            --btnChoose.Effect:setAnchorPoint(0.03,0.03)
            btnChoose.Effect:setAnchorPoint(0.5,0.5)
            btnChoose.Effect:setPosition(btnChoose.bg:getPosition())
            --btnChoose.Effect:setPosition(cc.p(5, 5))
            btnChoose:addChild(btnChoose.Effect)
        end
        btnChoose:setContentSize(80,80)
        btnChoose.num = ChoiceRewardConfig[info.bonus].choicenum
        btnChoose:setTouchEnabled(false)
        -- self:addTouchEventListener(btnChoose,self.chooseTouch)
        self:addTouchEventListener(btnChoose.spr,self.chooseTouch)

        btnChoose.spr.num = ChoiceRewardConfig[info.bonus].choicenum
        btnChoose.spr.index = info.ID

        changeBtn.index = btnChoose.spr.index
        changeBtn.num = btnChoose.spr.num
        self:addTouchEventListener(changeBtn,self.chooseTouch)
    else
        local btnChoose = self._items[index]:getChildByName("goods3Panel")
        if btnChoose.spr then
            btnChoose.spr:setVisible(false)
        end
        table.insert(self.tb,info.ID)
    end
end

function EmperorAwardPanel:chooseTouch(sender)
    print("chooseTouch" ,sender.index)
    if not self.PopPanel then
        local parent = self:getParent()
        self.PopPanel = EmperorAwardPopPanel.new(parent, self)--,sender.index,sender.num)
    end
    self.PopPanel:show(sender.index,sender.num) 
end

function EmperorAwardPanel:updateBtns()
    self.hasGetIds = self.emperorAwardProxy:getHasgetIds()
    for index = 1, 5 do
        self:updateBtn(index)
    end
end

function EmperorAwardPanel:updateBtn(index)
    local info = self.info[index]
    self:getChildByName("topPanel/mainPanel/itemPanel/item"..index.."Panel/imgMark"):setVisible(false)
    -- local Lab = self:getChildByName("topPanel/mainPanel/itemPanel/item"..index.."Panel/getLab")
    local Btn = self:getChildByName("topPanel/mainPanel/itemPanel/item"..index.."Panel/getBtn")
    local getBtnLab = Btn:getChildByName("getBtnLab")
    Btn:setVisible(true)
    Btn.id = info.id
    local function setVisible(bool)
        -- Lab:setVisible(bool)
        -- Btn:setEnabled(not bool)
        -- Btn:setVisible(not bool)
        NodeUtils:setEnable(Btn, not bool)
    end
    -- setVisible(self.emperorAwardProxy:getChargeValue() <  info.recharge) 
    if self.emperorAwardProxy:getChargeValue() <  info.recharge then
        NodeUtils:setEnable(Btn, false)
        getBtnLab:setString(TextWords:getTextWord(230206))
    else
        NodeUtils:setEnable(Btn, true)
        getBtnLab:setString(TextWords:getTextWord(230205))
        TextureManager:updateImageView(self:getChildByName("topPanel/mainPanel/itemPanel/item"..index.."Panel/Image_24"), "images/emperorAward/itemBg_light.png")
    end
    -- local getBtnLab = Btn:getChildByName("getBtnLab")
    -- getBtnLab:setString("领 取")
    -- Btn:setBright(true)
    -- Btn:setTouchEnabled(true)
    -- NodeUtils:setEnable(Btn, true)
    for _, v in pairs(self.hasGetIds) do
        if v == info.ID then 
            getBtnLab:setString(TextWords:getTextWord(230207))
            -- Btn:setBright(false)
            -- Btn:setTouchEnabled(false)
            NodeUtils:setEnable(Btn, false)
            Btn:setVisible(false)
            self:getChildByName("topPanel/mainPanel/itemPanel/item"..index.."Panel/imgMark"):setVisible(true)
        TextureManager:updateImageView(self:getChildByName("topPanel/mainPanel/itemPanel/item"..index.."Panel/Image_24"), "images/emperorAward/itemBg.png")
        end
    end 
end

function EmperorAwardPanel:onGetBtnTouch(sender)
    local flage = false
    local data = {}
    data.id = sender.id
    data.activityId = self.emperorAwardProxy:getActivityId()
    data.choiceIds = self.emperorAwardProxy:getChooseGetIDs(sender.id)
    for k,v in pairs(self.tb) do
        if sender.id == v then
            flage = true
        end
    end
    if data.choiceIds or flage then
        self:dispatchEvent(EmperorAwardEvent.GET_EVNET,data)
    else
        self:showSysMessage("请选择奖励！")
    end
end





















EmperorAwardPopPanel = class("EmperorAwardPopPanel", BasicComponent)

function EmperorAwardPopPanel:ctor(parent, panel,index,num)
    EmperorAwardPopPanel.super.ctor(self)
    self._uiSkin = UISkin.new("EmperorAwardPopPanel")
    self._uiSkin:setParent(parent)
    -- self._uiSkin:setVisible()
    self.secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    self.secLvBg:setContentHeight(560)
    self.secLvBg:setTitle(TextWords:getTextWord(338))
    self.secLvBg:hideCloseBtn(false)
    self._panel = panel
    self.obj = panel
    self.num = num 
end


function EmperorAwardPopPanel:setTitle(titileStr)
    self.secLvBg:setTitle(titileStr)
end

function EmperorAwardPopPanel:hide()
    local proxy = self.obj:getProxy(GameProxys.EmperorAward)
    if #self.choose == self.num or self.flage then
        proxy:setChooseGetIDs(self.choose, self.index)
        self._uiSkin:setVisible(false)
        self.obj:onShowHandler()
    else
        self.obj:showSysMessage(string.format("请选择%d个奖励",self.num))
    end
end

function EmperorAwardPopPanel:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function EmperorAwardPopPanel:show(index,num)
    self.flage = false
    self.index = index
    self.num = num 
    self.choose = {}
    local EmperorEnfeoffsConfig = require("excelConfig.EmperorEnfeoffsConfig")
    self.info = EmperorEnfeoffsConfig[index]
   	self.secLvBg:setTitle("选择物品")
    self:delayShow()
end


function EmperorAwardPopPanel:delayShow()
    self._uiSkin:setVisible(true)
    local listView = self:getChildByName("mainPanel/ListView_1")
    local closeBtn = self:getChildByName("mainPanel/sureBtn")
    ComponentUtils:addTouchEventListener(closeBtn, self.hide, nil, self)
    local srcX = listView.srcX
    local srcY = listView.srcY
    if srcX == nil then
        listView.srcX, listView.srcY = listView:getPosition()
        srcX, srcY = listView.srcX, listView.srcY
    end
    self._listView = listView
    self._listView:jumpToTop()
    local tepinfo = RewardManager:getAddedRewardById(self.info.bonus)
    local info = {}
    for _, v in pairs(tepinfo.canGets) do
        table.insert(info,v)
    end
    --for _, v in pairs(tepinfo.cannotGets) do
    --    table.insert(info,v)        
    --end

	local tempInfo = self:infoTodouble(info)
    


    local info_1 = {}
    for _, v in pairs(tepinfo.cannotGets) do
        if info_1[v.Power_value] == nil then
            info_1[v.Power_value] = {}
        end
        if info_1[v.Power_value][v.needLv] == nil then
            info_1[v.Power_value][v.needLv] = {}
        end
        table.insert(info_1[v.Power_value][v.needLv],v)        
    end

    
    for _, v in pairs(info_1) do
        local temp = self:infoTodouble(v)
        for _, e in pairs(temp) do   
            for _, f in pairs(e) do   
                table.insert(tempInfo, f)
            end     
        end      
    end


    local bg = self:getChildByName("mainPanel/imgBg")

    if #tempInfo == 1 then
        self._listView:setPosition(srcX, srcY + 165)
        self._listView:setContentSize(525, 190)
        self.secLvBg:setContentHeight(330)
        bg:setContentSize(578, 230)
    else 
        self._listView:setPosition(srcX, srcY + 80)
        self._listView:setContentSize(525, 360)
        self.secLvBg:setContentHeight(500)
        bg:setContentSize(578, 400)
    end

	self:renderListView(self._listView, tempInfo, self, self.renderItemPanel)
    local y = self._listView:getPositionY()
    local height = closeBtn:getContentSize().height
    closeBtn:setPositionY(y - height/2 - 50)
end

function EmperorAwardPopPanel:renderItemPanel(item,data)
	for i=1, 4 do
		local icon = item:getChildByName("icon"..i)
		icon:setVisible(data[i] ~= nil)
		if data[i] ~= nil then
            local uiIcon = icon.uiIcon
			local uiIconEffect = icon.uiIconEffect
            local info = ConfigDataManager:getConfigByPowerAndID(data[i].power,data[i].typeid)
            local color = nil
            if rawget(info, "quality") ~= nil then
                color = rawget(info, "quality")
            else
                color = rawget(info, "color")
            end
            color = color or 1
            local url = "images/newGui1/IconPinZhi"..color..".png"
            -- if not uiIcon then
            --     uiIcon = TextureManager:createSprite(info.url)
            --     uiIconEffect = TextureManager:createSprite(url)

            --     icon:addChild(uiIcon)
            --     icon:addChild(uiIconEffect)
            --     uiIconEffect:setAnchorPoint(cc.p(0.5,0.5)) 
            --     uiIconEffect:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)

                --优化内容
                
                -- uiIcon:setVisible(false)
                -- uiIconEffect:setVisible(false)
            local iconData = {}
            iconData.num = data[i].num 
            iconData.power = data[i].power
            iconData.typeid = data[i].typeid
            if icon.uiIcon == nil then
                local uiIcon = UIIcon.new(icon, iconData, true, self)
                uiIcon:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
                uiIcon:setTouchEnabled(false)
                icon.uiIcon = uiIcon
            else
                icon.uiIcon:updateData(iconData)
            end 
                
                -------
            -- end
            -- TextureManager:updateSprite(uiIcon, info.url)
            -- TextureManager:updateSprite(uiIconEffect, url)
            local nameLab = icon:getChildByName("nameLab")
            local color = ColorUtils:getColorByQuality(info.color or 1)
            nameLab:setColor(color)
            -- icon.uiIcon = uiIcon
            -- icon.uiIconEffect = uiIconEffect
            if data[i].needLv then
                local str 
                if data[i].Power_value == 114 then
                    str = "VIP"
                elseif data[i].Power_value == 110 then
                    str = "等级"
                end
                icon.choose = nil
                --self:showGreyView(icon.uiIcon,3)
                item:getChildByName("labTitle"):setVisible(true)
                item:getChildByName("imgTitleBg"):setVisible(true)
                item:getChildByName("labTitle"):setString(str..data[i].needLv)
            else
                --self:showGreyView(icon.uiIcon,1)
                icon.choose = 1
                item:getChildByName("labTitle"):setVisible(false)
                item:getChildByName("imgTitleBg"):setVisible(false)
            end 
            nameLab:setString(info.name)
			icon.ID = data[i].ID
            local checkImg = icon:getChildByName("checkImg")
            checkImg:setVisible(false)
            -- if self.index 
            local proxy = self.obj:getProxy(GameProxys.EmperorAward)
            local choiceIds = proxy:getChoiceIdsByid(self.index)
            icon:setTouchEnabled(false)
            if choiceIds then
                self.flage = true
                for _, v in pairs(choiceIds) do
                    if v == data[i].ID then
                        checkImg:setVisible(true)
                    end
                end
            else
                icon:setTouchEnabled(true)
			    ComponentUtils:addTouchEventListener(icon, self.printsIcon, nil, self)
		    end
        end
	end
end

function EmperorAwardPopPanel:printsIcon(sender)
    if sender.choose then
        if #self.choose ==  self.num then
            sender.choose = sender.choose + 1
            if sender.choose == 3 then
                sender.choose = 1
                local checkImg = sender:getChildByName("checkImg")
                checkImg:setVisible(sender.choose== 2)
                for k,v in pairs(self.choose) do
                    if v == sender.ID then
                        table.remove(self.choose, k)
                    end
                end

            else
                sender.choose = 1
                self.obj:showSysMessage(string.format("最多选择%d个奖励",self.num))
            end
            return
        end
        sender.choose = sender.choose + 1
        if sender.choose == 3 then
            sender.choose = 1
        end
        local checkImg = sender:getChildByName("checkImg")
        checkImg:setVisible(sender.choose== 2)
        --self:showGreyView(sender.uiIcon,sender.choose)
        if sender.choose == 2  then
            table.insert(self.choose, sender.ID)
        else
            for k,v in pairs(self.choose) do
                if v == sender.ID then
                    table.remove(self.choose, k)
                end
            end

        end 
    end
end

function EmperorAwardPopPanel:infoTodouble(info)
    info = TableUtils:map2list(info)
    local tempInfo = {}
    local index = 1
    for i=1, #info, 4 do
        tempInfo[index] = tempInfo[index] or {}
        table.insert(tempInfo[index], info[i])
        table.insert(tempInfo[index], info[i+1])
        table.insert(tempInfo[index], info[i+2])
        table.insert(tempInfo[index], info[i+3])
        index = index + 1
    end
    return tempInfo
end


-- function EmperorAwardPopPanel:showGreyView(node,nodeType) 
--     local vertDefaultSource = "\n"..
--                            "attribute vec4 a_position; \n" ..
--                            "attribute vec2 a_texCoord; \n" ..
--                            "attribute vec4 a_color; \n"..                                                    
--                            "#ifdef GL_ES  \n"..
--                            "varying lowp vec4 v_fragmentColor;\n"..
--                            "varying mediump vec2 v_texCoord;\n"..
--                            "#else                      \n" ..
--                            "varying vec4 v_fragmentColor; \n" ..
--                            "varying vec2 v_texCoord;  \n"..
--                            "#endif    \n"..
--                            "void main() \n"..
--                            "{\n" ..
--                             "gl_Position = CC_PMatrix * a_position; \n"..
--                            "v_fragmentColor = a_color;\n"..
--                            "v_texCoord = a_texCoord;\n"..
--                            "}"
 
--     --变亮
--     local psGrayShader1 = "#ifdef GL_ES \n" ..
--                             "precision mediump float; \n" ..
--                             "#endif \n" ..
--                             "uniform sampler2D u_texture;"..
--                             "varying vec4 v_fragmentColor; \n" ..
--                             "varying vec2 v_texCoord; \n" ..
--                             "void main(void) \n" ..
--                             "{ \n" ..
--                             "vec4 c = v_fragmentColor * texture2D(CC_Texture0, v_texCoord); \n"..  
--                             "c *= vec4(1.5, 1.5, 1.5, 1.5); \n"..  
--                             "gl_FragColor = c; \n"..  
--                             "} \n" 
--     --变灰
--     local psGrayShader2 = "#ifdef GL_ES \n" ..
--                             "precision mediump float; \n" ..
--                             "#endif \n" ..
--                             "uniform sampler2D u_texture;"..
--                             "varying vec4 v_fragmentColor; \n" ..
--                             "varying vec2 v_texCoord; \n" ..
--                             "void main(void) \n" ..
--                             "{ \n" ..
--                             "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
--                             "gl_FragColor.xyz = vec3(0.299*c.r + 0.587*c.g +0.114*c.b); \n"..
--                             "gl_FragColor.w = c.w; \n"..
--                             "} \n"  
--     --正常
--     local psGrayShader3 = "#ifdef GL_ES \n" ..
--                             "precision mediump float; \n" ..
--                             "#endif \n" ..
--                             "uniform sampler2D u_texture;"..
--                             "varying vec4 v_fragmentColor; \n" ..
--                             "varying vec2 v_texCoord; \n" ..
--                             "void main(void) \n" ..
--                             "{ \n" ..
--                             "vec4 c = v_fragmentColor * texture2D(CC_Texture0, v_texCoord); \n"..  
--                             "c *= vec4(1, 1, 1, 1); \n"..  
--                             "gl_FragColor = c; \n"..  
--                             "} \n" 
--     local pProgram
--     if nodeType == 2 then 
--       	pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,psGrayShader1)
--       	print("变亮了！")
--     elseif nodeType == 3 then
--       	pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,psGrayShader2)
--       	print("变灰了！")
--     elseif nodeType == 1 then
--       	pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,psGrayShader3)
--       	print("正常了！")
--     end 
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
--     pProgram:link()
--     pProgram:use()
--     pProgram:updateUniforms()
--     node:setGLProgram(pProgram)
-- end