--
-- 军师信息通用弹窗

UIAdviserInfo = class("UIAdviserInfo")

function UIAdviserInfo:ctor(panel, data, type)
	local uiSkin = UISkin.new("UIAdviserInfo")
    uiSkin:setParent(panel)
    uiSkin:setLocalZOrder(100)

    self.secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    self.secLvBg:setBackGroundColorOpacity(120)
    self.secLvBg:setContentHeight( 400 )

    self._showType = type
    self.proxy = panel:getProxy(GameProxys.Role)

    self._uiSkin = uiSkin
    self._panel = panel

    self.typeId = nil

    local mainPanel = self:getChildByName("Panel_Info")
    mainPanel:setTouchEnabled(false)
    mainPanel:setLocalZOrder(101)

    self._text_info_key = self:getChildByName("Panel_Info/Panel_57/text_getInfo_key")
    self._text_info_val = self:getChildByName("Panel_Info/Panel_57/text_getInfo_val")
	-- self.panel_pro = self:getChildByName("Panel_Info/Panel_57/panel_pro")


	self._attr_img = {}
	for i = 1,5 do
		self._attr_img[i] = self:getChildByName("Panel_Info/Panel_57/img" .. i)
        self._attr_img[i]._oldPos = cc.p(self._attr_img[i]:getPosition())
	end
    
    self._commentBtn = self:getChildByName("Panel_Info/Panel_57/Button_13")

    ComponentUtils:addTouchEventListener(self._commentBtn, self.toComment)

    self:show(data)
end

function UIAdviserInfo:finalize()
	self._uiSkin:finalize()
	self._uiSkin = nil
end

function UIAdviserInfo:show(info)

	-- print("打开刷新军师界面", info.title)

	self.secLvBg:setTitle(info.title or TextWords:getTextWord(270018))

	local data = info.adviserInfo
	self:renderView( data )

	self._uiSkin:setVisible(true)

	local btnData = info.tBtnfn
	if btnData == nil then
		for i=1,3 do
			local btn = self:getChildByName("Panel_Info/Panel_57/btn_"..i)
			btn:setVisible(false)
		end
		self._text_info_key:setVisible(true)
        self._text_info_val:setVisible(true)
		return
	else
		self._text_info_key:setVisible(false)
        self._text_info_val:setVisible(false)
	end

	local btnName = {
		{"btn_2", "btn_1", "btn_3"},
		{"btn_1", "btn_3", "btn_2"},
		{"btn_1", "btn_2", "btn_3"},
	}
	btnName = btnName[#btnData] or {}

	for i=1,3 do
		local btn = self:getChildByName("Panel_Info/Panel_57/"..(btnName[i] or ""))
		btn:setVisible(btnData[i] ~= nil)
		if btnData[i] ~= nil then
			local isRed = btnData[i].isRed and "R" or "Gre"
			btnData[i].isBright = btnData[i].isBright or false
			btn:loadTextureNormal( "images/newGui1/BtnMini"..isRed.."ed1.png", ccui.TextureResType.plistType )
			btn:loadTexturePressed( "images/newGui1/BtnMini"..isRed.."ed2.png", ccui.TextureResType.plistType )
			btn:setTitleText(btnData[i].name)
			ComponentUtils:addTouchEventListener(btn, function()
				local ret = true
				-- print("点击", btnData[i].click, info.obj, info.callbackId, btn)
				if btnData[i].click then
					ret = btnData[i].click(info.obj, info.callbackId, btn)
				end
				if ret==true then
					self:hide()
				end
			end, nil,self)
		end
	end


    
end

function UIAdviserInfo:btnClick(sender)
	
end

function UIAdviserInfo:renderView( data )

	local img_icon = self:getChildByName("Panel_Info/Panel_57/Panel_icon") 
	-- local bgImg = self:getChildByName("Panel_Info/Panel_57/Image_58")
	local text_des = self:getChildByName("Panel_Info/Panel_57/text_des")

	self.typeId = rawget(data, "typeId")

	logger:error("当前军师id:"..self.typeId)

	local roleProxy = self._panel:getProxy(GameProxys.Role)
    
	local isUnlock = roleProxy:isFunctionUnLock(45,false)
	local lv = rawget(data, "lv")
	ComponentUtils:renderConsigliereItem( img_icon, self.typeId, lv, nil, true, nil, nil, nil, isUnlock)

	local proxy = self._panel:getProxy(GameProxys.Consigliere)
	local config = proxy:getDataById( self.typeId ) or {} --ConfigDataManager:getConfigById(ConfigData.CounsellorConfig, self.typeId) or {}
	local addInfo = config.addInfo
    if config.getinfo then
        local a,b = string.find(config.getinfo,"：")
        if a and b then
            local left = string.sub(config.getinfo,1,a-1)
            local right = string.sub(config.getinfo,b+1)
            -- self._text_info_key:setString(left.."****"..right)
            self._text_info_key:setString(left .. "：")
            self._text_info_val:setString(right)
            NodeUtils:alignNodeL2R(self._text_info_key,self._text_info_val)
            NodeUtils:centerNodes(self._text_info_key:getParent(), {self._text_info_key,self._text_info_val})
        else--防止策划更改配置表,导致 "：" 这个符号不见了
            self._text_info_key:setString(config.getinfo or "")
            self._text_info_val:setString("")
            NodeUtils:centerNodes(self._text_info_key:getParent(), {self._text_info_key})
        end
    else
        self._text_info_key:setString("") --来源说明
        self._text_info_val:setString("")
    end

	config = proxy:getLvData( self.typeId, lv)

	-- ComponentUtils:updateConsigliereProperty( self.panel_pro, config, self._panel )
	self:initAttr(config)

	-- local desStr = ComponentUtils:analyzeConsiglierePropertyStr( config.skillID, addInfo )
	-- text_des:setString( desStr )
    text_des:setString("")
    if text_des.richLab == nil then
        text_des.richLab = ComponentUtils:createRichLabel("", nil, nil, 2)
        local pos = cc.p(text_des:getPosition())
        text_des.richLab:setPosition(pos)
        text_des:getParent():addChild(text_des.richLab)
    end

	local desStrConf = ComponentUtils:analyzeConsiglierePropertyStrConf(config.skillID, addInfo )
	--[[配置的格式
		{
			{
				key
				val
			}
			...
		}
	--]]

    ---[[ 把数字分开来插入 TODO 优化
	local text = {}
	for i,conf in pairs(desStrConf) do
		local str_conf = {}
		table.insert(str_conf,{conf.key,18,ColorUtils.commonColor.FuBiaoTi})
		local began,ended = string.find(conf.val,"[%+%-]*%d+[%%]*")
		local len = string.len(conf.val)--内政任命后提升太学院5%研发速度
		local v1 = string.sub(conf.val,1,began-1)--内政任命后提升太学院
		local v2 = string.sub(conf.val,began,ended)--5%
		local v3 = string.sub(conf.val,ended+1,len) or ""--研发速度
		table.insert(str_conf,{v1,18,ColorUtils.commonColor.MiaoShu})
		table.insert(str_conf,{v2,18,ColorUtils.commonColor.FuBiaoTi})
		table.insert(str_conf,{v3,18,ColorUtils.commonColor.MiaoShu})

		table.insert(text,str_conf)
	end
    if #text == 0 then
		local str_conf = {}
		table.insert(str_conf,{TextWords:getTextWord(270105),18, "#555555"})
		table.insert(text,str_conf)
        text_des.richLab:setPositionY(text_des:getPositionY()- 9)
    else
        text_des.richLab:setPositionY(text_des:getPositionY())
    end
    --]]
    text_des.richLab:setString(text)

	-- --自适应高度
	-- bgImg:setContentSize( cc.size( bgImg:getContentSize().width, math.max( 250, height) ) )
	-- local bgHeight =  bgImg:getContentSize().height
 --    local contextY = (bgImg:getPositionY()-bgHeight)*0.5+70
	-- local y = bgImg:getPositionY() + height*0.5
	-- panel_pro:setPositionY( y )
 --    self.secLvBg:setContentHeight( bgHeight+160 )
 --    for i=1,3 do
 --    	local btn = self:getChildByName("Panel_Info/Panel_57/btn_"..i )
 --    	btn:setPositionY( contextY )
 --    end
 --    self._text_info:setPositionY( contextY )

    local realName=proxy:getLvData( self.typeId, 0).name
    ComponentUtils:addTouchEventListener(self._commentBtn, 
    function()
        local proxy = self._panel:getProxy(GameProxys.Comment)

        --proxy:toCommentModule(5, self.typeId, config.name)
        --//null
        proxy:toCommentModule(5, self.typeId, realName)
        self:hide()
    end)
end

--此函数参考 ComponentUtils:updateConsigliereProperty
function UIAdviserInfo:initAttr(adviserConf)

	local begin_idx = 1

    local propertys = StringUtils:jsonDecode( adviserConf.property or "[]" )


    local function setText2Bg( img,key,val,icon_path)
    	if img then
    		img:setVisible(true)
    		if key then
	    		local labKey = img:getChildByName("labKey")
	    		labKey:setString(key or "")
    		end

    		if val then
	    		local labVal = img:getChildByName("labVal")
	    		labVal:setString(val or "")
    		end
            if icon_path then
    		    local icon = img:getChildByName("imgIcon")
        		TextureManager:updateImageView(icon, icon_path)--坑位编号
            end
    	end
    end

    local ResourceConfig = ConfigDataManager:getConfigData( ConfigData.ResourceConfig )

    local newPropertys = {}
    local P_KEY = 106  --带兵量Id是 106
    if adviserConf.command>0 then  --手动插入带兵量
        newPropertys = { {P_KEY, adviserConf.command} }
    end


    for i,v in ipairs(propertys) do
        table.insert(newPropertys, v) -- 新的属性加成
    end
    local len = #newPropertys
    begin_idx = 5-len+1

    for i = 1, begin_idx-1 do
    	self._attr_img[i]:setVisible(false)
    end
    local tmp = {}
    for i = begin_idx,#self._attr_img do
        table.insert(tmp,self._attr_img[i])
    end
    --重新设置回原来的位置,因为界面缓存了
    for i = 1,#self._attr_img do
        self._attr_img[i]:setPosition(self._attr_img[i]._oldPos)
    end

    --对中第三个
    NodeUtils:centerNodesGlobalY(self._attr_img[3],tmp)

    local keys = { [106]=true,  }  --需要隐藏百分号的，往这里加 基础资源key
    local mText = nil
    for i,v in ipairs(newPropertys) do

        local hidePercent = keys[v[1]]
        
        for kv, vul in ipairs(v) do
            local isLeft = kv%2==1

            local str = ""

            if isLeft then

                if vul == P_KEY then
                    str = "带兵: "
                    local url = string.format("images/newGui1/%s.png",GlobalConfig.SmallIconRefPath[14])
		        	setText2Bg( self._attr_img[begin_idx],str,nil ,url)
                else
                    local conf = ResourceConfig[vul] or {}
                    str = conf.name and (conf.name..": ") or ""
                    local icon_id = ResourceConfig[vul].icon
                    local url = 
                    	string.format(
                    		"images/newGui1/%s.png",GlobalConfig.SmallIconRefPath[icon_id])
		        	setText2Bg( self._attr_img[begin_idx],str,nil ,url)
                end



            else
                --hidePercent = keys[vul]
                if not hidePercent then
                    str = "+"..((vul or 0)*0.01).."%" 
                else
                    str = "+"..vul
                end

		        setText2Bg( self._attr_img[begin_idx],nil,str)
		        begin_idx = begin_idx + 1
            end
            -- mText = getProText( i, kv, isLeft, mText )
            -- mText:setString( str )
        end
    end


    -- for i=#newPropertys+1, MAX_LEN do
    --     for kv=1,2 do
    --         local name = "_mtext"..i.."_"..kv
    --         local mText = mPanel:getChildByName( name )
    --         if mText then
    --             mText:setString("")
    --         end
    --     end
    -- end

    --技能列表
    -- if _visiSkill then
    --     local skillStr = self:analyzeConsiglierePropertyStr( adviserConf.skillID, _addInfo, false )
    --     local mSkilllv = getText( "_mSkillLv" )
    --     mSkilllv:setAnchorPoint(0,1)
    --     mSkilllv:setColor( ColorUtils.wordTitleColor )
    --     mSkilllv:setPositionY( -height-SIZE+D )
    --     mSkilllv:setString( StringUtils:getStringAddBackEnter( skillStr, 14) )
    -- elseif mPanel:getChildByName("_mSkillLv") then
    --     mPanel:getChildByName("_mSkillLv"):setVisible(false)
    -- end

    -- mPanel:setBackGroundColorType(0)


end


function UIAdviserInfo:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UIAdviserInfo:getUseTypeId()
	return self.typeId
end

function UIAdviserInfo:hide()
    self._uiSkin:setVisible(false)
end
-- 类型  1-兵营 2-武将 3-太学院 4-战法 5-军师 
-- 子类id 0-表示没有子类
function UIAdviserInfo:toComment()
    
    
    self._commentProxy:toCommentModule(5, self.typeId)
end