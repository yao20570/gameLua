-- /**
--  * @Author:	  fzw
--  * @DateTime:	2015-12-17 11:55:23
--  * @Description: 充值面板
--  */
RechargePanel = class("RechargePanel", BasicPanel)
RechargePanel.NAME = "RechargePanel"

function RechargePanel:ctor(view, panelName)
    RechargePanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function RechargePanel:finalize()
    RechargePanel.super.finalize(self)
end

function RechargePanel:initPanel()
	RechargePanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true, "recharge", true)
	self._conf = ConfigDataManager:getConfigDataBySortId(ConfigData.VipDataConfig)
	self._chargeConf = self:initChargeConf()

	self._topPanel = self:getChildByName("topPanel") 
	self._middlePanel = self:getChildByName("middlePanel")
	self._listView = self:getChildByName("ListView")
	self._topPanel:setVisible(false)
	self._middlePanel:setVisible(false)
	self._listView:setVisible(false)

     --//null   新增充值界面的特效

    if self.effectVip~=nil then
    print("-------------------------------------fin1")
    self.effectVip:finalize()
    end

    if self.effectProBar~=nil then
    print("-------------------------------------fin2")
    self.effectProBar:finalize()
    end



    local topPanel = self._topPanel
    local barbg = topPanel:getChildByName("barbg")
    local Panel_43 = barbg:getChildByName("Panel_43")
    local ProgressBar_5 = barbg:getChildByName("ProgressBar_5")
    local Image_vip = topPanel:getChildByName("Image_vip")
    
    self.effectVip=self:createUICCBLayer("rgb-cz-vip"--[["rgb-zjm-tubiao"]], Image_vip )
    self.effectVip:setPositionX(self.effectVip:getPositionX()+Image_vip:getContentSize().width/2)
    self.effectVip:setPositionY(self.effectVip:getPositionY()+Image_vip:getContentSize().height/2)
    --local pos=Image_vip:getPosition()    
    self.effectProBar=self:createUICCBLayer("rgb-cz-jdt",Panel_43)                        --//rgb-jdt-huang 进度标志
    self.effectProBar:setPositionX(self.effectProBar:getPositionX()+ProgressBar_5:getContentSize().width/2)
    self.effectProBar:setPositionY(self.effectProBar:getPositionY()+ProgressBar_5:getContentSize().height/2)



    ----------------------------------------------------------------------------------------------------------
end

function RechargePanel:doLayout()
	self._topPanel:setVisible(true)
	self._listView:setVisible(true)
	
	local isFirstCharge = self:isFirstCharge()
	self._first = isFirstCharge
	if isFirstCharge == true then
		--带首冲的界面
		self._middlePanel:setVisible(true)
	    NodeUtils:adaptiveUpPanel(self._topPanel,nil,GlobalConfig.tabsHeight)
	    NodeUtils:adaptiveUpPanel(self._middlePanel,self._topPanel,-25)
	    NodeUtils:adaptiveListView(self._listView,GlobalConfig.downHeight, self._middlePanel,0)
	else
		--不带首冲的界面
		self._middlePanel:setVisible(false)
	    NodeUtils:adaptiveUpPanel(self._topPanel,nil,GlobalConfig.tabsHeight)
	    NodeUtils:adaptiveListView(self._listView,GlobalConfig.downHeight, self._topPanel,0)
	end


end

function RechargePanel:isFirstCharge()
	-- -- 1.首冲活动是否还在	
	local activityProxy = self:getProxy(GameProxys.Activity)
	local isFirst = activityProxy:isFirstCharge()

    local roleProxy = self:getProxy(GameProxys.Role)
    local viplv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    if viplv>0 then
    isFirst=false
    end
	return isFirst
end

function RechargePanel:initChargeConf()
	local conf = ConfigDataManager:getConfigDataBySortId(ConfigData.ChargeConfig) --充值配表
	for k,v in pairs(conf) do
		v.chargeType = GameConfig.chargeTypeNormal 	--插入字段：充值类型
		v.buyGold = v.limit * 10 					--插入字段：充值元宝=购买价格*10
	end

	table.sort(conf, function(a,b) return a.limit > b.limit end)

	return conf
end

function RechargePanel:onAfterActionHandler()
	-- print("==等一下渲染列表==")
	self:onShowHandler()
end

function RechargePanel:onShowHandler()
	if self:isModuleRunAction() == true then
		return
	end


	local isFirstCharge = self:isFirstCharge()
	if isFirstCharge == true then
		--带首冲的界面
		self._middlePanel:setVisible(true)
		if self._first ~= isFirstCharge then
		    NodeUtils:adaptiveUpPanel(self._topPanel,nil,GlobalConfig.tabsHeight)
		    NodeUtils:adaptiveUpPanel(self._middlePanel,self._topPanel,GlobalConfig.downHeight)
		    NodeUtils:adaptiveListView(self._listView,GlobalConfig.downHeight, self._middlePanel,0)
		end
	else
		--不带首冲的界面
		self._middlePanel:setVisible(false)
		if self._first ~= isFirstCharge then
		    NodeUtils:adaptiveUpPanel(self._topPanel,nil,GlobalConfig.tabsHeight)
		    NodeUtils:adaptiveListView(self._listView,GlobalConfig.downHeight, self._topPanel,0)
		end
	end

	self._first = nil

	local roleProxy = self:getProxy(GameProxys.Role)
    local viplv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    local vipexp = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipExp) or 0
	self:onTopPanel(self._topPanel, viplv, vipexp)


	-- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
 --    if cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
 --    	self._chargeConf = ConfigDataManager:getConfigData(ConfigData.ChargeGoodsConfig)
 --    	if self._lineData == nil then
 --    		self._lineData = self:changeConfigData(self._chargeConf)
 --    	end
 --    	self:renderListView(self._listView, self._lineData, self, self.onRenderListViewInfo)
 --    	return
 --    end


    if self._lineData == nil then
    	self._lineData = self:changeConfigData(self._chargeConf)
    end
    self:renderListView(self._listView, self._lineData, self, self.onRenderListViewInfo)

end

-- 推送已双倍充值的额度
function RechargePanel:updateRechargeInfo()
	logger:info("推送已双倍充值的额度 @@@@@@@@@@@@@@@@")
	self:onShowHandler()
end

function RechargePanel:changeConfigData(data)
	local size = table.size(data)
	local col = 3  --每行最大列数
	local maxLine = size / col
	local lessCol = size % col  --最后一行剩余列数
	if lessCol > 0 then
		maxLine = maxLine + 1
	end
	
	local newConfig = {}
	for i=1,maxLine do
		table.insert(newConfig,{i})
	end
	return newConfig
end


function RechargePanel:onTopPanel(panel, viplv, vipexp)
	-- local time = os.clock()
	local topPanel = self._topPanel

	local infoTxt = topPanel:getChildByName("infoTxt")
	local vipTipBtn = topPanel:getChildByName("vipTipBtn")
	local barbg = topPanel:getChildByName("barbg")
	local ProgressBar_5 = barbg:getChildByName("ProgressBar_5")
	local bartxt = ProgressBar_5:getChildByName("bartxt")
	local Image_vip = topPanel:getChildByName("Image_vip")
    local Panel_43 = barbg:getChildByName("Panel_43")

    --//null创建一个特效
    if self.effectHuang~=nil then
    print("-------------------------------------fin3")
    self.effectHuang:finalize()
    end
    self.effectHuang=self:createUICCBLayer("rgb-jdt-huang",ProgressBar_5)
    self.effectHuang:setPositionY(self.effectHuang:getPositionY()+ProgressBar_5:getContentSize().height/2)

	local vipTxt = Image_vip:getChildByName("vipTxt")

	barbg:setVisible(true)
	ProgressBar_5:setVisible(true)
	bartxt:setVisible(true)

	vipTxt:setString(viplv)


    --Image_vip 在单号6351调整位置不再居中      --//null


	--Image_vip 跟 vipTxt 永远居中 
	--local size_im =  Image_vip:getContentSize()
	--local size_font = vipTxt:getContentSize()
	--local all_width = size_im.width + size_font.width
	--local winsize = cc.Director:getInstance():getWinSize()
	--local to_x = winsize.width/2 + size_im.width-all_width/2
	--Image_vip:setPositionX(to_x)

   

	vipTipBtn:setTitleText(self:getTextWord(1505))	
	self:addTouchEventListener(vipTipBtn,self.onVipTipBtn)

	if barbg.initY == nil then
		barbg.initY = barbg:getPositionY()
	end
	if Image_vip.initY == nil then
		Image_vip.initY = Image_vip:getPositionY()
	end

	local nextVipLv = viplv + 1
	local maxVipLv = self._conf[#self._conf].level
	local per = 0
	local str
	local fontsize = 20
	local color1 = ColorUtils.wordWhiteColor16
	local color2 = "#EEbb11"

	local isFirstCharge = self:isFirstCharge()
	if isFirstCharge == true then
		-- 显示首冲奖励内容
        if nextVipLv >11 then
        nextVipLv=11
        end
		local value = self._conf[nextVipLv+1].value
		local v = StringUtils:jsonDecode(value)
		local maxExp = v[2]
		ProgressBar_5:setPercent(per)
		bartxt:setString(vipexp.."/"..maxExp)
		str = {{{"",fontsize,color1}}}

		self:updateMiddlePanel()
        --//null
        self.effectHuang:setVisible(false)
        Panel_43:setVisible(false)


	elseif viplv >= maxVipLv then
		-- vip 满级
		local value = self._conf[#self._conf].value
		local v = StringUtils:jsonDecode(value)
		local maxExp = v[2]
		per = 100
		ProgressBar_5:setPercent(per)
		bartxt:setString(maxExp.."/"..maxExp)

		str = {{{self:getTextWord(1507),fontsize,color1}}}

		barbg:setVisible(false)
		ProgressBar_5:setVisible(false)
		bartxt:setVisible(false)
		infoTxt:setPositionY(barbg:getPositionY())

        --//null
        self.effectHuang:setVisible(false)
        Panel_43:setContentSize(ProgressBar_5:getContentSize().width*per/100,ProgressBar_5:getContentSize().height)

	else
		-- vip 未满级
		local tmpLV = nextVipLv + 1
		local value = self._conf[tmpLV].value
		local v = StringUtils:jsonDecode(value)
		local maxExp = v[2]

    
		if vipexp > 0 and vipexp >= maxExp then
			per = 100
		else
			per = vipexp / maxExp  * 100
		end

            --//null
        print("-----------------------Per"..per)
        self.effectHuang:setPositionX(self.effectHuang:getPositionX()+ProgressBar_5:getContentSize().width*per/100)
        --//创建一个遮罩
        local x=ProgressBar_5:getContentSize().width*per/100
        local y=ProgressBar_5:getContentSize().height
        print(x.."------xy-------------"..y)
        Panel_43:setContentSize(ProgressBar_5:getContentSize().width*per/100,ProgressBar_5:getContentSize().height)


		ProgressBar_5:setPercent(per)
		bartxt:setString(vipexp.."/"..maxExp)
		str = {{
			{self:getTextWord(1514),fontsize,color1},
			{maxExp - vipexp,fontsize,color2},
			{self:getTextWord(1515),fontsize,color1},
			{string.format(self:getTextWord(1516),nextVipLv),fontsize,color2}
			}}
	end



	local rickLabel = infoTxt.rickLabel
	if rickLabel == nil then
		rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
		infoTxt:addChild(rickLabel)
		infoTxt.rickLabel = rickLabel
	end
	rickLabel:setString(str)
	--设置富文本居中
	if not rickLabel._old_x then
		rickLabel._old_x = rickLabel:getPositionX()
	end
	local size = rickLabel:getContentSize()
	rickLabel:setPositionX(rickLabel._old_x - size.width/2)
	print(size.width,"  ",size.height)

	infoTxt:setString("")
end

function RechargePanel:updateMiddlePanel()
	-- 首冲礼包数据
	self.giftData = GlobalConfig.FirstRechargeReward

	local ListView = self._middlePanel:getChildByName("ListView")
	self:renderListView(ListView, self.giftData, self, self.onRenderFirstRechargeReward)
end

-- 渲染首冲列表
function RechargePanel:onRenderFirstRechargeReward( itempanel, info, index )
	-- body
	itempanel:setVisible(true)
	local iconSprite = itempanel:getChildByName("icon")
	local iconName = itempanel:getChildByName("iconName")
	TextureManager:updateImageView(iconSprite, "images/newGui1/none.png")

	local iconInfo = {}
	iconInfo.power = info.power
	iconInfo.typeid = info.typeid
	iconInfo.num = info.num

    local icon = itempanel.icon
    if icon == nil then
        icon = UIIcon.new(iconSprite, iconInfo, info.isShowNum, self)
        
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end

	local quality = icon:getQuality()
	local color = ColorUtils:getColorByQuality(quality)
	iconName:setColor(color)        
	
	if info.typeid == 206 then
		-- 双倍元宝
		iconName:setString(self:getTextWord(1513))
	else
		iconName:setString(icon:getName())
	end
end

-- 渲染充值列表
function RechargePanel:onRenderListViewInfo(itempanel, info, index)
	local time = os.clock()

	if itempanel == nil or info == nil then
		return
	end
	itempanel:setVisible(true)

	local item,curIndex,curInfo
	for i=1,3 do
		item = itempanel:getChildByName("item"..i)
		curIndex = 3 * index + 0 + i
		curInfo = self._chargeConf[curIndex]
		if item ~= nil then
			if curInfo ~= nil then
				self:onRenderItem(item, curInfo, index)
			else
				item:setVisible(false)
			end
		else
			itempanel:setVisible(false)
		end
	end

	-- print("onRenderListViewInfo 耗时。。。。。。。。。",os.clock() - time)
end

-- 渲染一个充值卡片
function RechargePanel:onRenderItem(itempanel, info, index)
	local time = os.clock()

	if itempanel == nil or info == nil then
		return
	end
	itempanel:setVisible(true)
	
	local itemImg = itempanel:getChildByName("itemImg")
	local goldTxt = itemImg:getChildByName("goldTxt") --充值元宝
	local giftTxt = itemImg:getChildByName("giftTxt") --赠送元宝
	local moneyTxt = itemImg:getChildByName("moneyTxt") --购买价格 RMB
	local moneyImg = itemImg:getChildByName("moneyImg") --购买价格
	local Image_icon = itemImg:getChildByName("Image_icon") --元宝icon
	local doubleImg = itemImg:getChildByName("doubleImg") --首冲双倍图标

	local roleProxy = self:getProxy(GameProxys.Role)

	local isDouble = roleProxy:isDoubleByLimit(info.limit) or false
	doubleImg:setVisible(isDouble)
	
	local restore = info.restore
	if isDouble == true then
		restore = info.buyGold
	end

	logger:error("!!!!!!!RechargePanel:onRenderItem!!:%d!!!!!!!!", info.limit)
	print_r(info)

 	local url = string.format("images/recharge/%d.png",info.icon)
 	TextureManager:updateImageView(Image_icon,url)

	goldTxt:setString(info.buyGold)
	giftTxt:setString(restore)
	moneyTxt:setString(info.limit)


	--[[ 购买价格文本自适应对齐
	local posx = itemImg:getPositionX()
	local sizeM = itemImg:getContentSize()
	local sizeL = moneyTxt:getContentSize()
	local sizeR = moneyImg:getContentSize()
	sizeL.width = sizeL.width - 18 --18是一个数字的宽
	local allLen = sizeL.width + sizeR.width
	local x0 = (sizeM.width - allLen)/2  --得出左右空隙宽
	local x1 = posx - sizeM.width/2 + x0
	local x2 = x1 + sizeL.width
	moneyTxt:setPositionX(x1)
	moneyImg:setPositionX(x2)
	--]]


	if itempanel.addEvent ~= nil then
		return
	end
	itempanel.addEvent = true
	itempanel.info = info
	itempanel:setTouchEnabled(true)
	self:addTouchEventListener(itempanel,self.onItemBtnTouch)

	-- print("onRenderItem 耗时。。。。。。。。。",os.clock() - time)
end

-- 特权按钮
function RechargePanel:onVipTipBtn(sender)
    SDKManager:showWebHtmlView("html/vip.html")
end

-- 购买按钮
function RechargePanel:onItemBtnTouch(sender)
	-- 实名认证校验是否可以充值
	if GameConfig.isOpenRealNameVerify then
		local realNameProxy = self:getProxy(GameProxys.RealName)
        if realNameProxy:getIsPunish() then
            logger:error("实名惩罚状态：已开启")
		    local info = realNameProxy:getRealNameInfo()
		    if info ~= nil then
			    if info.state == 1 then
				    self:showSysMessage(self:getTextWord(461021)) --"未实名绑定无法充值"
				    return
			    end
			
                if info.state == 2 then
				    local roleProxy = self:getProxy(GameProxys.Role)
				    local money = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge) or 0 -- 元宝
                    local recharMoney = sender.info.limit + money/10
				    if recharMoney >= realNameProxy:getMaxDailyCharge() then
					    self:showSysMessage(self:getTextWord(461020)) -- "主公当日充值已达上限"
					    return
				    end
			    end
		    end
        else
            logger:error("实名惩罚状态：未开启")
        end
	end
    
	local info = sender.info
	local amount = info.limit
	local chargeType = info.chargeType
	SDKManager:charge(amount, chargeType)
end

function RechargePanel:onClosePanelHandler()
 
    --if self.effectVip~=nil then
    --print("-------------------------------------fin1")
    --self.effectVip:finalize()
    --end

    --if self.effectProBar~=nil then
    --print("-------------------------------------fin2")
    --self.effectProBar:finalize()
    --end

    --if self.effectHuang~=nil then
    --print("-------------------------------------fin3")
    --self.effectHuang:finalize()
    --end
    self.view:hideModuleHandler()
end

-- 购买按钮
function RechargePanel:onItemBtnTouchInIos(sender)
	-- body
--	self:showSysMessage("充值功能暂未开启，敬请期待!")

	local info = sender.info
	local amount = info.limit
	local chargeType = info.type
	SDKManager:charge(amount, chargeType,info.name..info.unit,info.code)
end

