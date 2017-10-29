--
-- Author: zlf
-- Date: 2016-04-20
-- 文官升星界面
AdvancedPanel = class("AdvancedPanel", BasicPanel)
AdvancedPanel.NAME = "AdvancedPanel"

local LEVEL_MAX = 3  --军师最大等级 

function AdvancedPanel:ctor(view, panelName)
    AdvancedPanel.super.ctor(self, view, panelName, 800 )
    -- self.noUesCoinAndNoMaterial = 1
    -- self.noUesCoinAndYesMaterial = 2
    -- self.canUesCoinAndNoMaterial = 3
    -- self.canUesCoinAndYesMaterial = 4

    self._uiPayPanel = nil
    self._isLeveling = nil  --状态： 是否正在升级

    self.needData = {}

    self:setUseNewPanelBg(true)
end

function AdvancedPanel:finalize()
    if self._uiPayPanel then
    	self._uiPayPanel:finalize()
    	self._uiPayPanel = nil
    end
    if self._effect then
    	self._effect:finalize()
    	self._effect = nil
    end
    AdvancedPanel.super.finalize(self)
end

function AdvancedPanel:initPanel()
	AdvancedPanel.super.initPanel(self)

	self:setLocalZOrder( PanelLayer.UI_Z_ORDER_3 )

	self.proxy = self:getProxy(GameProxys.Consigliere)
	self.itemProxy = self:getProxy(GameProxys.Item)

	self:setTitle(true, self:getTextWord(270010) )


	self.panel = self:getChildByName("Panel_80")

	self.btn_up = self.panel:getChildByName("btn_coin")
	local btn_return = self.panel:getChildByName("btn_return")

	self:addTouchEventListener(self.btn_up, self.onLevelup)

	self:addTouchEventListener(btn_return, function(sender)
		self:onClosePanelHandler()
	end)

	--左属性
	self._left_attr = {}
	for i = 1,5 do
		local name = "imgBg1"..i
		local node = self.panel:getChildByName(name)
		node._old_pos = cc.p(node:getPosition())
		self._left_attr[i] = node
	end

	--右属性
	self._right_attr = {}
	for i = 1,5 do
		local name = "imgBg2"..i
		local node = self.panel:getChildByName(name)
		node._old_pos = cc.p(node:getPosition())
		self._right_attr[i] = node
	end
	--左右两个技能
	self._skills = {}
	for i =1,2 do
		local name = "pnlSkill"..i
		local node = self.panel:getChildByName(name)
		node._old_pos = cc.p(node:getPosition())
		self._skills[i] = node
	end

	-- self.Price = {[4024]=12, [4012]=9, [4013]=28, [4025]=999}

	local Label_78 = self.panel:getChildByName("Label_78")

	self:initAllData()
end

function AdvancedPanel:initAllData()
	-- for i=1,2 do
	-- 	-- self["star"..i] = {}
	-- 	self["label"..i] = {}
	-- 	self["label_num"..i] = {}
	-- 	for j=1,5 do
	-- 		-- local star = self:getChildByName("Panel_80/panel_"..i.."/Panel_7/Image_"..(7+j))
	-- 		-- self["star"..i][j] = star
	-- 		local label = self:getChildByName("Panel_80/panel_"..i.."/Label_"..j)
	-- 		local label_num = self:getChildByName("Panel_80/panel_"..i.."/Label_"..j.."_num")
	-- 		self["label"..i][j] = label
	-- 		self["label_num"..i][j] = label_num
	-- 	end
	-- 	-- self["icon"..i] = self:getChildByName("Panel_80/panel_"..i.."/img_icon")
	-- 	-- self["skicon"..i] = self:getChildByName("Panel_80/panel_"..i.."/sk_icon")
	-- end

	self.upLab = {}
	self.haveLab = {}
	self.allIcon = {}
	self.allPos = {}
	for i=1,5 do
		self.allIcon[i] = self.panel:getChildByName("img_"..i)
		self.allPos[i] = self.allIcon[i]:getPositionX()
		self.haveLab[i] = self.panel:getChildByName("lab"..i.."_"..i)
		self.upLab[i] = self.panel:getChildByName("lab"..i)
	end
end

function AdvancedPanel:onLevelup()
	if self._isLeveling then
		return
	end

	if self.nState==false then
		if not self._uiPayPanel then
			self._uiPayPanel = UIPayPanel.new( self, self.showLevelUpAnim )
		end
		self._uiPayPanel:show( self.tNeedDataList )
	elseif self.nState==true then
		self._isLeveling = true
		self.proxy:onTriggerNet260002Req( {id=self.upId} )
	end
end
function AdvancedPanel:showLevelUpAnim()
	self._isLeveling = true
	local icon2 = self.panel:getChildByName("Panel_icon2")
	self._effect = UICCBLayer.new("rgb-jsf-shengxin", icon2, nil, function()
		self.proxy:onTriggerNet260002Req( {id=self.upId} )
		self._effect = nil
	end, true )
	self._effect:setPosition( -60, 30 )
end


function AdvancedPanel:registerEvents()
	AdvancedPanel.super.registerEvents(self)
end

function AdvancedPanel:onClosePanelHandler()
	self:hide()
end

function AdvancedPanel:getUpId()
	return self.upId
end

-- data  = { id, typeId, pos, lv  }  --AdviserInfo
function AdvancedPanel:onShowHandler(data)
	if self._uiPayPanel then
		self._uiPayPanel:hide()
	end
	
	data = data or {}
	self.upId = data.id

	self._isLeveling = nil

	for i=1,5 do
		self.allIcon[i]:setPositionX(self.allPos[i])
		self.haveLab[i]:setPositionX(self.allPos[i])
		self.upLab[i]:setPositionX(self.allPos[i])
	end

	local conf = self.proxy:getLvData( data.typeId, data.lv ) or {}
	local nextConf = self.proxy:getLvData( data.typeId, data.lv+1 ) or {}

	local icon1 = self.panel:getChildByName("Panel_icon1")
	local icon2 = self.panel:getChildByName("Panel_icon2")
	local pro1 = self.panel:getChildByName("Panel_pro_1")
	local pro2 = self.panel:getChildByName("Panel_pro_2")
	icon2:setLocalZOrder( icon1:getLocalZOrder()+1 )

	ComponentUtils:renderConsigliereItem( icon1, data.typeId, data.lv)
	ComponentUtils:renderConsigliereItem( icon2, data.typeId, data.lv+1)
	
	-- ComponentUtils:updateConsigliereProperty( pro1, conf, self, true )
	-- ComponentUtils:updateConsigliereProperty( pro2, nextConf, self, true )
	self:initAttr(conf,1)
	self:initAttr(nextConf,2)

	self.needData = StringUtils:jsonDecode( nextConf.itemneed or "[]" )
	self:updateNeedItem( self.needData )
end

function AdvancedPanel:onLevelUpSuccess()
	self._isLeveling = nil
	local data = self.proxy:getInfoById( self.upId )
	if data and data.lv<LEVEL_MAX then
		self:onShowHandler( data )
	else
		self:hide()
	end
end

function AdvancedPanel:updateNeedItem(data)
	self.nState = true

	self.tNeedDataList = {}
	for i=1,5 do
		self.allIcon[i]:setVisible(data[i] ~= nil)
		self.upLab[i]:setVisible(data[i] ~= nil)
		self.haveLab[i]:setVisible(data[i] ~= nil)
		if data[i] then
			local iconData = {}
			iconData.num = 1
			iconData.typeid = data[i][2]
			iconData.power = data[i][1]
			local uiIcon = self.allIcon[i].uiIcon
			if not uiIcon then
        		uiIcon = UIIcon.new(self.allIcon[i],iconData,true,self)
        		self.allIcon[i].uiIcon = uiIcon
    		else
        		uiIcon:updateData(iconData)
    		end
    		uiIcon:setPosition(self.allIcon[i]:getContentSize().width/2, self.allIcon[i]:getContentSize().height/2)

			local num = self.itemProxy:getItemNumByType(iconData.typeid)
			local isCurEnough = tonumber(num)>=tonumber(data[i][3])
			self.upLab[i]:setString( StringUtils:formatNumberByK(num) )
			self.haveLab[i]:setString( "/"..StringUtils:formatNumberByK(data[i][3]) )
			self.upLab[i]:setColor( isCurEnough and ColorUtils.wordWhiteColor or ColorUtils.wordRedColor )

			if self.nState==true then
				self.nState = isCurEnough
			end

			local payNum = tonumber(data[i][3])-tonumber(num)
			if payNum>0 then
				local coinData = {}
				coinData.num = payNum
				coinData.typeid = iconData.typeid
				coinData.power = iconData.power
				table.insert(self.tNeedDataList, coinData)
			end

			local shopData = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopConfig, "itemID", iconData.typeid )
			if not shopData and not isCurEnough then
				self.nState = nil
			end

		end
	end

	local lenght = #data
	if lenght ~= 5 then
		for i=1, lenght do
			self.allIcon[i]:setPositionX((600/(lenght+1))*i)
			self.upLab[i]:setPositionX((600/(lenght+1))*i)
			self.haveLab[i]:setPositionX((600/(lenght+1))*i)
		end
	end

	if self.nState==true or self.nState==nil then
		self.btn_up:setTitleText(TextWords:getTextWord(270010)) --升星
	else
		self.btn_up:setTitleText(TextWords:getTextWord(270027)) --元宝升星
	end
	NodeUtils:setEnable( self.btn_up, self.nState~=nil )
	-- else
	-- 	if not _isEnough then
	-- 		self.nState = self.canUesCoinAndNoMaterial
	-- 		self.btn_up:setTitleText(TextWords:getTextWord(270027))
	-- 		local price, needData = self:getData(numData)
	-- 		self.showData = needData
	-- 		self.proxy:setPrice(price)
	-- 	else
	-- 		self.btn_up:setTitleText(TextWords:getTextWord(270028))
	-- 		self.nState = self.canUesCoinAndYesMaterial
	-- 	end
	-- end
end

-- function AdvancedPanel:getData(data)

-- 	local needData = {}
-- 	local num = 0
-- 	for k,v in pairs(data) do
-- 		if v.count > 0 then
-- 			num = num + v.count*self.Price[v.id]
-- 			local info = {}
-- 			info.num = v.count
-- 			info.typeid = v.id
-- 			info.power = v.power
-- 			table.insert(needData, info)
-- 		end
-- 	end
-- 	return num, needData
-- end

-- function AdvancedPanel:getNum(num)
-- 	local _num = (type(num)=="number") and num or tonumber(num)
-- 	if _num < 1000 then
-- 		return _num
-- 	end
-- 	return (_num/1000).."K"
-- end

--idx:1==左边  2==右边
function AdvancedPanel:initAttr(adviserConf,idx)


	local begin_idx = 1

	local _attr_img
	local _skill_pnl
	if idx == 1 then
		_attr_img = self._left_attr
		_skill_pnl = self._skills[1]
	else
		_attr_img = self._right_attr
		_skill_pnl = self._skills[2]
	end

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
    		    local icon = img:getChildByName("imgHead")
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
    begin_idx = 1

    --后面的隐藏
    for i = len+1,#_attr_img do
    	_attr_img[i]:setVisible(false)
    end

    --前面的记录起来,用于排位
    local tmp = {}
    for i = 1, len do
        table.insert(tmp,_attr_img[i])
    end

	table.insert(tmp,_skill_pnl)
    
    --重新设置回原来的位置,因为界面缓存了
    -- for i = 1,#_attr_img do
    --     _attr_img[i]:setPosition(_attr_img[i]._oldPos)
    -- end

    --从上往下排
    NodeUtils:alignNodeU2DForTable(tmp,6)

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
		        	setText2Bg( _attr_img[begin_idx],str,nil ,url)
                else
                    local conf = ResourceConfig[vul] or {}
                    str = conf.name and (conf.name..": ") or ""
                    local icon_id = ResourceConfig[vul].icon
                    local url = 
                    	string.format(
                    		"images/newGui1/%s.png",GlobalConfig.SmallIconRefPath[icon_id])
		        	setText2Bg( _attr_img[begin_idx],str,nil ,url)
                end



            else
                if not hidePercent then
                    str = "+"..((vul or 0)*0.01).."%" 
                else
                    str = "+"..vul
                end

		        setText2Bg( _attr_img[begin_idx],nil,str)
		        begin_idx = begin_idx + 1
            end
        end
    end

    --处理技能
    local skillInfo = self:getAdviserSkillInfo(adviserConf)
    if #skillInfo > 0 then
    	_skill_pnl:setVisible(true)
    	for i = 1,2 do
    		local labKey = _skill_pnl:getChildByName("labKey" .. i)
    		local labVal = _skill_pnl:getChildByName("labVal" .. i)
    		if skillInfo[i] then
    			labKey:setString(skillInfo[i][1])
    			labVal:setString(skillInfo[i][2])
    		else
    			labKey:setString("")
    			labVal:setString("")
    		end
    	end
    else
    	_skill_pnl:setVisible(false)
    end


end

function AdvancedPanel:getAdviserSkillInfo(adviserConf)
    local skillID = StringUtils:jsonDecode( adviserConf.skillID or "[]" )

    local info = {}

    if #skillID > 0 then
		local skillconf = ConfigDataManager:getConfigData(ConfigData.CounsellorSkillConfig)
    	for i = 1,#skillID do
    		local skill_id = skillID[i]
        	local skillData = skillconf[skill_id] or {}
        	local lv = skillData.skillLevel or 0
        	local lvStr = "Lv." .. lv
        	local name = skillData.name
        	table.insert(info,{
        		name,lvStr
        	})
    	end

    end
	return info
end

