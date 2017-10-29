-- /**
--  * @Author:	  	lizhuojian
--  * @DateTime:	2017-4-11
--  * @Description: 小宴（普通探宝、点奇兵）
--  */
PubNorPanel = class("PubNorPanel", BasicPanel)
PubNorPanel.NAME = "PubNorPanel"

function PubNorPanel:ctor(view, panelName)
    PubNorPanel.super.ctor(self, view, panelName)
end

function PubNorPanel:finalize()
    PubNorPanel.super.finalize(self)
end

function PubNorPanel:initPanel()
	PubNorPanel.super.initPanel(self)


    self.proxy = self:getProxy(GameProxys.Pub)

	self._topPanel 		= self:getChildByName("topPanel")	--居上容器
    self._btnPanel 		= self:getChildByName("btnPanel")	--按钮容器
	self._oneBtn 		= self:getChildByName("btnPanel/oneBtn")    --单次按钮
	self._nineBtn 	    = self:getChildByName("btnPanel/nineBtn")	--九次按钮
    self._freeBtn 	    = self:getChildByName("btnPanel/freeBtn")	--免费按钮
    self._menoyPanel 	= self:getChildByName("btnPanel/menoyPanel")	--按钮价格容器
    self._oneNumLab 	= self._menoyPanel:getChildByName("oneN")	--按钮单次价格数量文本
    self._nineNumLab 	= self._menoyPanel:getChildByName("nineN")	--按钮九次价格数量文本
    self._ninePirceIcon	= self._menoyPanel:getChildByName("menoyIcon1")	--按钮九次价格图标
    self._onePirceIcon 	= self._menoyPanel:getChildByName("menoyIcon2")	--按钮单次价格图标
    self._tipPanel 		= self:getChildByName("btnPanel/infoBg")			--描述父容器
    self._bigTouchPanel = self:getChildByName("topPanel/bigTouchPanel")		--大触摸遮罩层
    self._itemPanel 	= self:getChildByName("topPanel/itemPanel")			--九个箱子的父容器
    self._tipTxt 		= self._itemPanel:getChildByName("tipTxt") 	--点击返回闪烁提示文本
	self._coverPanel 	= self:getChildByName("coverPanel")     	--半透明阴影层
	self._playerInfoPanel= self._btnPanel:getChildByName("moneyPanel")		--玩家消耗品信息层
	self._playerItemLab	= self._playerInfoPanel:getChildByName("playerItemLab")		--玩家女儿红数量文本
	self._playerGoldLab	= self._playerInfoPanel:getChildByName("playerGoldLab")		--玩家金币数量文本
	self._playerJiulingLab	= self._playerInfoPanel:getChildByName("jiulingNumLab")		--玩家酒令数量文本
	self._panelBg 		= self:getChildByName("bgImgNew")					--最底下的大背景
	-- TextureManager:updateImageViewFile(self._panelBg,"bg/pub/pubBg.pvr.ccz")
	local infoLab 		= self:getChildByName("btnPanel/infoBg/infoLab") 	--描述文本
    infoLab:setString(self:getTextWord(366005))

    self._itemAllArr = {}	--存放九个Item
    self._itemCoverImgArr = {}	--存放九个Item的关闭状态的盖子图片
    self._itemOpenImgArr = {}	--存放九个Item的已打开状态的盖子图片
    for index = 1 ,9 do 
    	self._itemAllArr[index] = self:getChildByName("topPanel/itemPanel/itemPanel" .. index)
    	self._itemCoverImgArr[index] = self:getChildByName("topPanel/itemPanel/itemPanel" .. index .. "/coverImg")
    	self._itemOpenImgArr[index] = self:getChildByName("topPanel/itemPanel/itemPanel" .. index .. "/openCoverImg")
		self._itemCoverImgArr[index].index = index
		self:addTouchEventListener(self._itemCoverImgArr[index],self.onItemClickHandle)
    end

    self:setTouchEnable(true)
    
    --数据

    self._lotteryType   = 1               --小宴固定大ID 1
    local pubDrawConfig = ConfigDataManager:getConfigById(ConfigData.PubDrawConfig, self._lotteryType)
    local consume = StringUtils:jsonDecode(pubDrawConfig.consume)
    local oneConfigKey = pubDrawConfig.preci1 -- 小宴单抽对应价格表格的一个key值
    local nineConfigKey = pubDrawConfig.preci2 -- 小宴九抽对应价格表格的一个key值

    local onePriceConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.PubPreciConfig, "tepy",oneConfigKey)
    local ninePriceConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.PubPreciConfig, "tepy",nineConfigKey)

    self._itemTypeId    = consume[1][2]       --女儿红(奇宝币)typeId 4014

    self._onePrice 	    = onePriceConfig.preci	--小宴单次价格(固定)
    self._ninePrice 	= ninePriceConfig.preci	--小宴九次价格(固定)

    self._itemNum       = 0       --女儿红(奇宝币) 显示数量
    self._freeTimeNum   = 0       --单抽免费次数
    self._jiulingNum    = 0       --酒令 显示数量



end
function PubNorPanel:onShowHandler()
	--self:updatePubNorPanel()
    
	self.view:setBgType(ModulePanelBgType.PUBNOR)

	if self.proxy == nil then
 		self.proxy = self:getProxy(GameProxys.Pub)
	end
	self:updateItemAndGoldNum()
    --请求跑马灯历史记录
    self.proxy:onTriggerNet450009Req()
	self.proxy:onTriggerNet450000Req()
end


function PubNorPanel:updatePubNorPanel()

	self.canNine = true
    --重新获取女儿红的数量和免费次数
    local itemProxy = self:getProxy(GameProxys.Item)
    self._itemNum = itemProxy:getItemNumByType(self._itemTypeId)
    self._freeTimeNum = self.proxy:getPubFreeData(self._lotteryType)
    self._timeLimitInfo = self.proxy:getBanquetInfo().banquetInfo
    local roleProxy = self:getProxy(GameProxys.Role)
    self._jiulingNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_jiuling)
    --更新女儿红与货币信息
    self:updateItemAndGoldNum()
	--更新按钮上的消耗信息与按钮对应的位置改变
	self:updateBtnPosAndInfo()
	--触摸层
	self._bigTouchPanel:setVisible(false)
	--重置箱子
	self:resetAllBox()
	--显示蒙板、按钮层
	self:panelOprater(true)

end

function PubNorPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
	local coverPanel 	= self:getChildByName("coverPanel")     	--半透明阴影层

	local topPanel 		= self:getChildByName("topPanel")	--居上容器
    local btnPanel 		= self:getChildByName("btnPanel")	--按钮容器
	local panelBg 		= self:getChildByName("bgImgNew")					--最底下的大背景

	NodeUtils:adaptivePanelBg(coverPanel,GlobalConfig.downHeight-6,tabsPanel) --遮罩
	NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, tabsPanel)  
	NodeUtils:adaptiveTopPanelAndListView(panelBg, nil, nil, tabsPanel)  
	NodeUtils:adaptiveTopPanelAndListView(btnPanel, nil, nil, tabsPanel)  
end



function PubNorPanel:registerEvents()
	self:addTouchEventListener(self._oneBtn,self.onOneBtnHander)        -- 1次
	self:addTouchEventListener(self._nineBtn,self.onNineBtnHandler)     -- 9次
    self:addTouchEventListener(self._freeBtn,self.openCover)            -- 免费
    self:addTouchEventListener(self._bigTouchPanel , self.onTouchCover) -- 屏蔽层

    self["nineBtn"] = self._nineBtn
end

--抽奖时，对相关的panel进行显示和隐藏
function PubNorPanel:panelOprater(isShow)
	--阴影
	self._coverPanel:setVisible(isShow)
	--按钮层
	self._btnPanel:setVisible(isShow)

end

--网络或者机器本身关系 多次点击无效 self._btnOrTenBtnEnable
function PubNorPanel:setTouchEnable(isEnable)
	self._btnOrTenBtnEnable = isEnable
end

function PubNorPanel:getTouchEnable()
	return self._btnOrTenBtnEnable
end


-- 箱子点击回调事件
function PubNorPanel:onItemClickHandle(sender)
	print("``````onItemClickHandle````````sender.index",sender.index)
    for k,v in pairs(self._itemCoverImgArr) do
		v:setEnabled(false)
	end
	--请求单抽
	self.proxy:onTriggerNet450004Req({})
	self._sender = sender -- 赋值
end





-- 是否弹窗元宝不足
function PubNorPanel:isShowRechargeUI(sender)
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

function PubNorPanel:onAfterActionHandler()
    
	--self:updatePubNorPanel()
end


function PubNorPanel:norHistoryUpdate()

	self:showHistories()
end

function PubNorPanel:showHistories()
	-- 显示历史玩家信息20条
	self._histories = self.proxy:getNorHistoryInfos()
	
	if self._histories ~= nil and table.size(self._histories) > 0 then
		if self._richText == nil then
		    self._richText = RichTextAnimation.new(self,self._histories,self._coverPanel)
		else
			self._richText:updateTextInfos(self._histories)
		end
	end
end
function PubNorPanel:updateItemAndGoldNum()
    local roleProxy = self:getProxy(GameProxys.Role)
	local goldNumber = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
	self._playerGoldLab:setString(goldNumber)
    local itemProxy = self:getProxy(GameProxys.Item)
    self._itemNum = itemProxy:getItemNumByType(self._itemTypeId)
	self._playerItemLab:setString(self._itemNum)
    self._jiulingNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_jiuling)
	self._playerJiulingLab:setString(self._jiulingNum)
end

function PubNorPanel:updateBtnPosAndInfo()
    local itemProxy = self:getProxy(GameProxys.Item)
    self._itemNum = itemProxy:getItemNumByType(self._itemTypeId)
    self._freeTimeNum = self.proxy:getPubFreeData(self._lotteryType)
    -- 根据探宝币改变按钮上的消耗品信息
    if self._itemNum >= 1 then
        TextureManager:updateImageView(self._onePirceIcon, "images/pub/nverhong.png")
        self._oneNumLab:setString(1)
    else
        TextureManager:updateImageView(self._onePirceIcon, "images/newGui1/IconRes6.png")
        self._oneNumLab:setString(self._onePrice)
    end

    if self._itemNum >= 9 then
        TextureManager:updateImageView(self._ninePirceIcon, "images/pub/nverhong.png")
        self._nineNumLab:setString(9)
    else
        TextureManager:updateImageView(self._ninePirceIcon, "images/newGui1/IconYuanBao.png")
        self._nineNumLab:setString(self._ninePrice)
    end

    local guideId = GuideManager:getCurGuideId()
    if guideId == 104 then
        -- 引导中，特殊处理了
        self._menoyPanel:setVisible(true)
        self._oneBtn:setVisible(true)
        self._nineBtn:setVisible(true)
        self._freeBtn:setVisible(false)
    else
        -- 如果有免费次数，隐藏单次和九次
        self._menoyPanel:setVisible(self._freeTimeNum <= 0)
        self._oneBtn:setVisible(self._freeTimeNum <= 0)
        self._nineBtn:setVisible(self._freeTimeNum <= 0)
        self._freeBtn:setVisible(self._freeTimeNum > 0)
    end

    self:updateItemAndGoldNum()
end


function PubNorPanel:playEffect(data,openItem,callback,openItemParent)
	AudioManager:playEffect("yx_dianbing")
	self.view:playEffect(data,openItem,callback,openItemParent,nil,1)
end


-- 点击单抽按钮
function PubNorPanel:onOneBtnHander(sender)


     
    --单抽两种情况，存在女儿红直接打开蒙板，不存在就买女儿红，购买成功后才打开蒙板

	if self._itemNum < 1 then
		--达到限制次数
		self._timeLimitInfo = self.proxy:getBanquetInfo().banquetInfo
	    if self._timeLimitInfo.oneLotteryTime <= 0 then
	        -- self:showSysMessage(self:getTextWord(366000))
			local function okcallbk()
    			--打开充值界面
    			ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
			end	
	        self:showMessageBox(string.format(self:getTextWord(366000), self._timeLimitInfo.nextOneTime - 1),okcallbk,nil,self:getTextWord(366015))
	        return
	    end
		--金币购买女儿红 
		local function okcallbk()
            local sendData = {}
            sendData.itemTypeId = self._itemTypeId
            self.canNine = false
			-- 请求购买女儿红
            self.proxy:onTriggerNet450002Req(sendData)
		end		
		local function moneyJudge()
			local messageBox = self:showMessageBox(string.format(self:getTextWord(1817), self._onePrice),okcallbk)
            messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
		end
		local temp = {}
		temp.callFunc = moneyJudge
		temp.money = self._onePrice
		self:isShowRechargeUI(temp)
	else
		--存在女儿红，打开蒙板
		for k,v in pairs(self._itemCoverImgArr) do
			v:setEnabled(true)
		end
		self:panelOprater(false)
		
		
	end
end
-- 点击9连抽按钮
function PubNorPanel:onNineBtnHandler(sender)
	if self.canNine == false then
		return
	end

	
    local function okcallbk()
		-- 请求九连抽
		self.canNine = false
        self.proxy:onTriggerNet450005Req()
	end		
	local function cancelcb()
	end

	if self._itemNum < 9 then
		--达到限制次数
		self._timeLimitInfo = self.proxy:getBanquetInfo().banquetInfo
	    if self._timeLimitInfo.nineLotteryTime <= 0 then
	        -- self:showSysMessage(self:getTextWord(366001))
			local function okcallbk()
    			--打开充值界面
    			ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
			end	
	        self:showMessageBox(string.format(self:getTextWord(366001), self._timeLimitInfo.nextNimeTime - 1),okcallbk,nil,self:getTextWord(366015))
	        return
	    end
		--女儿红不够九个 
    	--九连抽没有让玩家选择的操作，直接抽

		local function moneyJudge()
			local messageBox = self:showMessageBox(string.format(self:getTextWord(1817), self._ninePrice),okcallbk,cancelcb)
            messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
		end
		local temp = {}
		temp.callFunc = moneyJudge
		temp.money = self._ninePrice
		self:isShowRechargeUI(temp)
	else

		if GuideManager:isStartGuide() then
    	    local guideId = GuideManager:getCurGuideId()
    	    if guideId == 104 then  --引导中，特殊处理了
    	    	okcallbk() --直接使用了
    	    end
    	else
    		--消耗女儿红九个
		    self:showMessageBox(self:getTextWord(366013),okcallbk,cancelcb)
    	end
		
	end
end
function PubNorPanel:after450005(rs)
	if rs < 0 then
		self.canNine = true
	end
end
function PubNorPanel:after450002(rs)
	if rs < 0 then
		self.canNine = true
	end
end

--重置箱子
function PubNorPanel:resetAllBox()

	for index = 1,9 do
		self._itemCoverImgArr[index]:setVisible(true)
		self._itemCoverImgArr[index]:setEnabled(false)
		self._itemOpenImgArr[index]:setVisible(false)
	end
end


--关闭panel时重置界面
function PubNorPanel:onClosePanelHandler()
	TimerManager:remove(self._playNineEffect, self)
	self.view:setCanNorPubPlayEffect(false)
	self:panelOprater(true)
	self:resetAllBox()
    if self._richText then
        self._richText:removeAll()
        self._richText = nil
    end
end
--点击Tab切换重置界面
function PubNorPanel:hideCallBack()
    TimerManager:remove(self._playNineEffect, self)
    self.view:setCanNorPubPlayEffect(false)
    self:resetAllBox()
    self:panelOprater(true)
end


function PubNorPanel:onTouchCover()
	-- print("self._bigTouchPanel````onTouchCover")
    local isVisible = self._btnPanel:isVisible()
    if isVisible == true then
        return
    end
    --[[
    self._bigTouchPanel:setVisible(false)
	self:resetAllBox() -- 重置箱子，不可点击
	self:panelOprater(true)
	self:setTouchEnable(true)
	]]
	self:updatePubNorPanel()
end
--购买完女儿红之后打开蒙板
function PubNorPanel:afterBuyNorItem()
 --    for k,v in pairs(self._itemCoverImgArr) do
	-- 	v:setEnabled(true)
	-- end
	self:openCover()
end
--打开蒙板,放开宝箱触摸
function PubNorPanel:openCover(sender)
	-- print("openCover```")
	self._bigTouchPanel:setVisible(false)
	self:panelOprater(false)
    for _,v in pairs(self._itemCoverImgArr) do
        v:setEnabled(true)
    end
end

--单抽显示奖励
function PubNorPanel:afterOpenOneNor(reward)
	function callback()
    	self._bigTouchPanel:setVisible(true)
		-- self._oneBtn:setTitleText(self:getTextWord(1826)) -- 抽一次
	end
	


	self.view:setCanNorPubPlayEffect(true)
	self:playEffect(reward,self._itemOpenImgArr[self._sender.index],callback,self._itemAllArr[self._sender.index])

	--敬酒特效
	
	local beiEft = self:createUICCBLayer("rgb-jg-yinbei", self._itemPanel, nil,nil,true)
	local itemPanelSize = self._itemPanel:getContentSize()
	beiEft:setLocalZOrder(3)
	beiEft:setPosition(itemPanelSize.width*0.5, itemPanelSize.height*0.6)
end
--九抽显示奖励
function PubNorPanel:afterOpenNineNor(rewards)
	
    --先打开蒙板
    self._bigTouchPanel:setVisible(false)
	self:panelOprater(false)
    for _,v in pairs(self._itemCoverImgArr) do
        v:setEnabled(false)
    end

	local dataIndex = 0
    local itemIndex = 0
    self.itemIndex = 0
	-- 特效执行完一次，就执行一次回调callback()
	function callback()
		--当第9个箱子播放完特效后，才可点击重置
        self.itemIndex = self.itemIndex + 1

		if self.itemIndex == 9 then
			self._bigTouchPanel:setVisible(true)
		end
	end
	local function playNineEffect()
		dataIndex = dataIndex + 1

		-- local item = self._itemCoverImgArr[dataIndex]
		-- item:setVisible(false)

		-- self._itemOpenImgArr[dataIndex]:setVisible(true)

		self:playEffect(rewards[dataIndex],self._itemOpenImgArr[dataIndex], callback,self._itemAllArr[dataIndex])
	end

	self._playNineEffect = playNineEffect
	self.view:setCanNorPubPlayEffect(true)
	TimerManager:add(1, playNineEffect,self, 9) 

		--敬酒特效
	local beiEft = self:createUICCBLayer("rgb-jg-yinbei", self._itemPanel, nil,nil,true)
	local itemPanelSize = self._itemPanel:getContentSize()
	beiEft:setLocalZOrder(3)
	beiEft:setPosition(itemPanelSize.width*0.5, itemPanelSize.height*0.6)

end
