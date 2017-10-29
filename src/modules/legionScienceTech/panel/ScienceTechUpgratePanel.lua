
ScienceTechUpgratePanel = class("ScienceTechUpgratePanel", BasicPanel)
ScienceTechUpgratePanel.NAME = "ScienceTechUpgratePanel"
ScienceTechUpgratePanel.CONTRIBUTE_GOLD_TYPE = 1 -- 元宝类型
ScienceTechUpgratePanel.CONTRIBUTE_RES_TYPE = 2  -- 资源类型
function ScienceTechUpgratePanel:ctor(view, panelName)
    ScienceTechUpgratePanel.super.ctor(self, view, panelName, 700)
    
    self:setUseNewPanelBg(true)
end

function ScienceTechUpgratePanel:finalize()
    ScienceTechUpgratePanel.super.finalize(self)
end

function ScienceTechUpgratePanel:initPanel()
	ScienceTechUpgratePanel.super.initPanel(self)
	self:setTitle(true, self:getTextWord(3207))
    self._legionProxy = self:getProxy(GameProxys.Legion)
	self._iconImg = nil
	self._listview = self:getChildByName("mainPanel/ListView_1")

	-- local Image_bg = self:getChildByName("mainPanel/Image_bg")
 --    TextureManager:updateImageView(Image_bg, "images/guiScale9/Frame_item_bg.png")

    local Image_30 = self:getChildByName("mainPanel/Image_30")
    TextureManager:updateImageView(Image_30, "images/guiScale9/Frame_item_bg.png")

    self._labCurOwn= self:getChildByName("mainPanel/labCurOwn")--当前拥有,用时适配 --//null 不适配了 UI 写死
    

	-- NodeUtils:adaptive(self._listview)

end

function ScienceTechUpgratePanel:onShowHandler(data)
	self._topData = data.techInfo

    self._ID = data.info.subTechId
    self._listItem = {}
    self:onTopPanel(data)
    self:onNeedList(data)
end

function ScienceTechUpgratePanel:onTopPanel(data)
	-- body
	local conf = data.conf
	local info = data.info

	local maxNum = data.reqExp
    local level = info.subTechLv
    local curNum = info.subTechExp
    local name = conf.name
    local info = conf.info
    self._techLevel = level
    self._techName = name
    -- print("exp curNum = "..curNum)

	local mainPanel = self:getChildByName("mainPanel")
	local itemName = mainPanel:getChildByName("itemName")
	local itemValue = mainPanel:getChildByName("itemValue")
	local itemInfo = mainPanel:getChildByName("itemInfo")
	-- local closeBtn = mainPanel:getChildByName("closeBtn")
	local barbg = mainPanel:getChildByName("barbg")
	local ProgressBar = barbg:getChildByName("ProgressBar")
	local barValue = ProgressBar:getChildByName("barValue")

    -- icon
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = conf.icon
    iconInfo.num = 0

    local icon = self._iconImg
    if icon == nil then
		local iconImg = mainPanel:getChildByName("iconImg")
        icon = UIIcon.new(iconImg,iconInfo,false)        
        self._iconImg = icon
    else
        icon:updateData(iconInfo)
    end

	itemName:setString(name)    
	itemInfo:setString(info)    
	itemValue:setString(string.format(self:getTextWord(3200), level))    

	-- local color = ColorUtils.riceColor
	-- itemName:setColor(color)
	-- itemInfo:setColor(color)
	-- itemValue:setColor(color)

	local per = nil
	if self._topData.level <= level then
		per = 0
		-- curNum = 0
	else
		if curNum >= maxNum then
			per = 100
		else
			per = curNum/maxNum * 100
		end
	end
	ProgressBar:setPercent(per)
	barValue:setString(curNum.."/"..maxNum)

    -- closeBtn
	-- self:addTouchEventListener(closeBtn,self.onClose)
end

function ScienceTechUpgratePanel:onNeedList(data)
	-- body
	
	local legionProxy = self:getProxy(GameProxys.Legion)
	self._resCurNumber = legionProxy:getResNumber()  --拥有的资源
	self._curCount = legionProxy:getSciCurCount()  --已捐献次数
    self._totalCount = self._legionProxy:getSciTotalCount()  --已捐献总次数
	local tabData = legionProxy:getResData(self._curCount) --需求和奖励

	self:renderListView(self._listview, tabData, self, self.onRenderItemList,nil,nil,0)

end

function ScienceTechUpgratePanel:onRenderItemList(itempanel, info ,index)
	self:onRenderItem(itempanel, info ,index)
	itempanel.info = info
	table.insert(self._listItem, itempanel)
end

function ScienceTechUpgratePanel:onRenderItem(itempanel, info ,index)
	-- body
	itempanel:setVisible(true)

	local curNum = self._resCurNumber[info.restype]
	-- logger:info("res curNum = "..curNum..",restype = "..info.restype)

	local needValue = itempanel:getChildByName("needValue")
	local curValue = itempanel:getChildByName("curValue")
	local contribute = itempanel:getChildByName("contribute")
	local upBtn = itempanel:getChildByName("upBtn")
	-- local greyUpBtn = itempanel:getChildByName("greyUpBtn")
	local yes = itempanel:getChildByName("yes")
	local no = itempanel:getChildByName("no")
	-- local bgImg = itempanel:getChildByName("bgImg")
    local bg1 = itempanel:getChildByName("bg1")
    local bg2 = itempanel:getChildByName("bg2")
    if index%2 == 0 then
        bg1:setVisible(true)
        bg2:setVisible(false)
    else
        bg1:setVisible(false)
        bg2:setVisible(true)
    end

    local power = GamePowerConfig.Resource
    local typeId = info.restype
    if info.restype == 200 then
    	power = GamePowerConfig.Resource
    	typeId = 206
    end
    local iconInfo = {}
    iconInfo.power = power
    iconInfo.typeid = typeId
    iconInfo.num = 0
    iconInfo.isRes = true

    local icon = itempanel._iconImg
    if icon == nil then
		local iconImg = itempanel:getChildByName("iconImg")
        icon = UIIcon.new(iconImg,iconInfo,false)
        itempanel._iconImg = icon
    else
        icon:updateData(iconInfo)
    end

	needValue:setString(StringUtils:formatNumberByK3(info.reqneed, nil))
	curValue:setString(StringUtils:formatNumberByK(curNum, nil))
	contribute:setString("+"..info.contribute)

    -- no:setPositionX(curValue:getPositionX() + curValue:getContentSize().width/2)
    -- yes:setPositionX(curValue:getPositionX() + curValue:getContentSize().width/2)
    --NodeUtils:alignNodeL2R(curValue,no)
    --NodeUtils:alignNodeL2R(curValue,yes)
    --NodeUtils:centerNodesGlobal(self._labCurOwn,{curValue,no,yes})

	local isEnough = nil
	local color = nil
	if info.reqneed > curNum then
		-- 资源不足
		color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Red)--ColorUtils.wordRedColor
		isEnough = 0 -- 资源不足
		yes:setVisible(false)
		no:setVisible(true)
	else
		-- 资源足够
		color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Green)--ColorUtils.wordGreenColor
		isEnough = 1
		yes:setVisible(true)
		no:setVisible(false)
	end
	curValue:setColor(color)

	local curCount = self._curCount[info.restype].curCount
	local maxCount = self._curCount[info.restype].maxCount


	if curCount <= maxCount and self._topData.level > self._techLevel then
		-- 次数未满
		NodeUtils:setEnable(upBtn,true)
	elseif self._topData.level <= self._techLevel then
		-- 科技等级不能超过科技大厅等级
		isEnough = 2 --此科技等级已满
		NodeUtils:setEnable(upBtn,false) -- 等级满
	else
		-- 次数已满
		NodeUtils:setEnable(upBtn,false) -- 次数满
	end	
	
	upBtn.info = info
	upBtn.isEnough = isEnough
	self:addTouchEventListener(upBtn,self.onUpgrateBtn)
end

-- 关闭
function ScienceTechUpgratePanel:onClose()
    self:hide()
end

-- 关闭前检查贡献消息推送
function ScienceTechUpgratePanel:onHideHandler()
    -- 根据配置表判断
    local goldCount = self._legionProxy:getContributeGold()
    local resCount  = self._legionProxy:getContributeRes()
    --self:showSysMessage( string.format("总共捐献了%d元宝，%d资源", goldCount, resCount) )
    
    local data = {}
    data.gold = goldCount
    data.res  = resCount
    data.panel= 2
    -- 资源上限条件
    local roleProxy = self:getProxy(GameProxys.Role)
    local legionLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_legionLevel)
    local legionConfig = ConfigDataManager:getConfigData(ConfigData.LegionConfig)
    if legionConfig[legionLevel] ~= nil then
        if legionConfig[legionLevel].donateNum > resCount then
            data.res  = 0
        end
    end

    -- 元宝上限条件
    if goldCount < 15 then -- 写死15
        data.gold = 0
    end

    -- 符合条件发送消息
    if data.res ~= 0 or data.gold ~= 0 then    
        self._legionProxy:onTriggerNet220700Req(data)
    end

    -- 发完消息后重置贡献表
    self._legionProxy:clearContributeInfo()

end

-- 捐献按钮
function ScienceTechUpgratePanel:onUpgrateBtn(sender)
    
    local isEnough = sender.isEnough
    local info = sender.info
    local restype = info.restype
    self._resNeedCount = sender.info.reqneed -- 本次的预捐献数目
    if isEnough ~= nil and isEnough == 1 then
    	-- 发送请求
        local data = {}
        data.techId = self._ID
        data.power = info.restype
    	
    	-- print("req: techId = "..data.techId..",power = "..data.power)

    	self._contributeInfo = info --捐赠的

        -- 到达次数直接弹出提示
        if sender:getColor().r ~= 255 then 
            self:showSysMessage(self:getTextWord(3158)) -- [[您的捐献次数已达上限了]]
            return 
        end

    	if restype == 200 then
    		-- 元宝捐献弹提示框
    		local function okCallBack()

		    	local function callFunc()
		    	    -- 请求
					local legionProxy = self:getProxy(GameProxys.Legion)
			    	legionProxy:onTriggerNet220009Req(data)
                    self._reqContributeType = ScienceTechUpgratePanel.CONTRIBUTE_GOLD_TYPE-- 元宝类型
		    	end
		    	sender.callFunc = callFunc
		    	sender.money = info.reqneed
		    	self:isShowRechargeUI(sender)

    		end
    		local content = string.format(self:getTextWord(3213), info.reqneed)
    		self:showMessageBox(content,okCallBack)
    	else
    		-- 非元宝捐献
			local legionProxy = self:getProxy(GameProxys.Legion)
	    	legionProxy:onTriggerNet220009Req(data)
            self._reqContributeType = ScienceTechUpgratePanel.CONTRIBUTE_RES_TYPE  -- 资源类型
    	end

    elseif isEnough ~= nil and isEnough == 0 then -- 资源不足
    	if restype == 200 then
    		-- 元宝不足
    		local function callFunc()
    		    -- 请求
    			self:showSysMessage(self:getTextWord(3208))
    		end

    		-- 如果元宝不足且次数不够
            if sender:getColor().r ~= 255 then 
                self:showSysMessage(self:getTextWord(3158)) -- [[您的捐献次数已达上限了]]
                return 
            end

            sender.callFunc = callFunc
    		sender.money = info.reqneed
    		self:isShowRechargeUI(sender)
    	else
	    	-- 提示资源不足
	    	self:showSysMessage(self:getTextWord(3208))
    	end
    elseif isEnough ~= nil and isEnough == 2 then
    	-- 提示已满级
    	self:showSysMessage(self:getTextWord(3210))
    end
end

-- 是否弹窗元宝不足
function ScienceTechUpgratePanel:isShowRechargeUI(sender)
    -- body
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

-- 更新列表
function ScienceTechUpgratePanel:onUpdateListPanel(type, data)
	-- body

	for k,v in pairs(self._listItem) do
		local info = v.info
		-- if info.restype == type and self._curCount[type].curCount <= self._curCount[type].maxCount then
		if info.restype == type then
			self:onRenderItem(v, data[k], k)
			return
		end
	end
end

-- 科技捐献
function ScienceTechUpgratePanel:onSciContributeResp(data)
    local legSciexp = self._contributeInfo.LegSciexp

    -- 达到指定同盟活跃等级，当日每个成员第1次捐献科技，可获得X倍科技经验值
    if self._totalCount == 6 then
        local activityLv = self._legionProxy:getLegionActivityLevel()
        if activityLv > 0 then
            local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.LegionActiveConfig,"level",activityLv)    
            if config and config.scoretimes > 0 then
                legSciexp = legSciexp * config.scoretimes / 100
            end
        end
    end

	self:showSysMessage(string.format(self:getTextWord(3216), self._contributeInfo.contribute, self._techName, legSciexp))

    -- 添加贡献数据数据
    self._legionProxy:addContributeInfo(self._reqContributeType, self._resNeedCount)

	if self:isVisible() ~= true then
		return
	end

	local techInfo = data.techInfo
	self._topData = {}
	self._topData.level = techInfo.techLv		--科技厅等级
	self._topData.maxNum = techInfo.buildNeed	--升级需求
	self._topData.curNum = techInfo.allBuild		--总建设度
	self._topData.selfNum = techInfo.myContribute	--个人贡献


    self._ID = data.info.subTechId
    self._listItem = {}
    self:onTopPanel(data)
    self:onNeedList(data)	
end




