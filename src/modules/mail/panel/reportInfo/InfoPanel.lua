InfoPanel = class("InfoPanel", BasicPanel)
InfoPanel.NAME = "InfoPanel"

function InfoPanel:ctor(panel,parent)
	self._panel = panel
	self._parent = parent
end

function InfoPanel:updateData(panel,data)
    self._data = data
    self._id   = data.id 
    print("成功赋值战报的id【】【】")
    local selfData = rawget(data.infos,self.NAME)
    
	if selfData ~= nil then
        if data.infos.mailType == 1 or data.infos.mailType == 2 then  --战斗
            local result = data.infos.InfoPanel.result -- -- 0胜利，1失败，3 采集成功
            if result == 3 then
                self:updateWhPanel(panel,data.infos)
                -- 收藏按钮
                self:updataCollectShow(panel, self._id)
            else
                self:updateFtPanel(panel,data.infos)
                -- 收藏按钮
                self:updataCollectShow(panel, self._id)
            end
        elseif data.infos.mailType == 3 then  --侦察
            self:updateWhPanel(panel,data.infos)
            -- 收藏按钮
            self:updataCollectShow(panel, self._id)
		end
	end
end

--战斗报告
function InfoPanel:updateFtPanel(clonePanel,infos)
	local selfData = rawget(infos,self.NAME)
    local ftPanel = clonePanel
	local where = ftPanel:getChildByName("where")
	local time = ftPanel:getChildByName("time")
	--local result = ftPanel:getChildByName("result")
	local ryu = ftPanel:getChildByName("ryu")
	local team = ftPanel:getChildByName("team")
	local helpBtn = ftPanel:getChildByName("helpBtn")
    --local resultTxt = ftPanel:getChildByName("resultTxt") -- 进攻结果文本
    local shareBtn  = ftPanel:getChildByName("shareBtn") -- 分享按钮
	local iconResult = ftPanel:getChildByName("IconResult")
	local IconResult_win = ftPanel:getChildByName("IconResult_win")

    ----------------------主题start------------------------------------------------
    -- 主题文本
    local titleTxt01 = ftPanel:getChildByName("titleTxt01") -- 默认黄色
    local titleTxt02 = ftPanel:getChildByName("titleTxt02")
    local titleTxt03 = ftPanel:getChildByName("titleTxt03") -- 默认黄色
    local titleTxt04 = ftPanel:getChildByName("titleTxt04")
    local titleTxt05 = ftPanel:getChildByName("titleTxt05") -- 默认黄色
    titleTxt01:setColor(cc.c3b(255, 230, 170))
    titleTxt02:setColor(cc.c3b(255, 255, 255))
    titleTxt04:setColor(cc.c3b(255, 255, 255))
    
    -- 设置主题
    for i = 1 , 5 do
        local titleTxt = ftPanel:getChildByName("titleTxt0"..i)
        titleTxt:setString("")
    end
    -- 进攻与防守
    if infos.mailType == 1 then -- 进攻情况：进攻主城/资源/被占领的资源
        -- 进攻
        --resultTxt:setString( TextWords:getTextWord(1241))
        local isTaken = infos.InfoPanel.aim == infos.InfoPanel.name
        if infos.isPerson == 0 then 
            -- 主城或被占领的资源
            if isTaken then
                -- 主城
                titleTxt01:setString( TextWords:getTextWord(1242))
                titleTxt02:setString(selfData.aim.." Lv."..selfData.level)                
                titleTxt04:setString( TextWords:getTextWord(1236))
                titleTxt05:setString(selfData.posX..","..selfData.posY)
            else
                -- 被占领的资源
                titleTxt01:setString( TextWords:getTextWord(1242)) -- [[我攻打了]]
                titleTxt02:setString(selfData.aim.." Lv."..selfData.level)
                titleTxt03:setString(TextWords:getTextWord(1240))
                titleTxt04:setString(selfData.name) -- 一定是矿点信息
                titleTxt05:setString(selfData.posX..","..selfData.posY)
                -- 
                local loyaltyCount = infos.loyaltyCount
                titleTxt04:setColor(self._parent:getColorValueByLoyalty(loyaltyCount))
            end
        else
            -- 资源
            titleTxt01:setString( TextWords:getTextWord(1242))
            titleTxt02:setString(selfData.name)
            titleTxt05:setString(selfData.posX..","..selfData.posY)
            -- 
            local loyaltyCount = infos.loyaltyCount
            titleTxt02:setColor(self._parent:getColorValueByLoyalty(loyaltyCount))
        end
    else 
        -- 防守
        --resultTxt:setString(TextWords:getTextWord(1244)) -- "防守结果:"
        local num = string.sub(selfData.name,1,1)
		local isCity =  not tonumber(num) -- 是否是主城
        if isCity then
            -- 主城防守
            titleTxt01:setString(TextWords:getTextWord(1245)) -- "遭到了"
            titleTxt02:setString(selfData.aim.." Lv."..selfData.level)
            
            titleTxt04:setString( TextWords:getTextWord(1237)) -- 的攻击
            titleTxt05:setString(selfData.posX..","..selfData.posY)
        else
            -- 资源防守 aim人name资源
            titleTxt01:setString(selfData.name)
            titleTxt02:setString(TextWords:getTextWord(1245)) -- "遭到了"
            titleTxt03:setString(selfData.aim.." Lv."..selfData.level)
            titleTxt04:setString(TextWords:getTextWord(1237)) -- 的攻击
            
            titleTxt05:setString(selfData.posX..","..selfData.posY)
            -- 
            local loyaltyCount = infos.loyaltyCount
            titleTxt01:setColor(self._parent:getColorValueByLoyalty(loyaltyCount))
        end
    end
    -- NodeUtils:fixTwoNodePos(titleTxt01, titleTxt02, 2)
    -- NodeUtils:fixTwoNodePos(titleTxt02, titleTxt03, 2)
    -- NodeUtils:fixTwoNodePos(titleTxt03, titleTxt04, 2)
    -- NodeUtils:fixTwoNodePos(titleTxt04, titleTxt05, 2)
    NodeUtils:alignNodeL2R(titleTxt01, titleTxt02,titleTxt03,titleTxt04, 2)
    ----------------------主题end------------------------------------------------

    ----------------------战斗结果start------------------------------------------------
    local resultStr  
	
    if infos.mailType == 1 then 
        -- 进攻
        --resultTxt:setString( TextWords:getTextWord(1241)) -- "防守结果:"
        if selfData.result == 0 then  --成功
			resultStr = TextWords[1215] -- 进攻胜利
            --result:setColor(ColorUtils:color16ToC3b("#25ef3c"))
            --TextureManager:updateImageView(iconResult, "images/battle/Txt_victory.png")
            IconResult_win:setVisible(true)
            iconResult:setVisible(false)
		else
			resultStr = TextWords[1216] -- 进攻失败
            --result:setColor(ColorUtils:color16ToC3b("#ff1212"))
            --TextureManager:updateImageView(iconResult, "images/battle/Txt_fail.png")
            IconResult_win:setVisible(false)
            iconResult:setVisible(true)
		end
    elseif infos.mailType == 2 then
        -- 防守
        --resultTxt:setString( TextWords:getTextWord(1244))
        if selfData.result == 0 then  --成功
			resultStr = TextWords[1213]
            --result:setColor(ColorUtils:color16ToC3b("#25ef3c"))
            --TextureManager:updateImageView(iconResult, "images/battle/Txt_victory.png")
            IconResult_win:setVisible(true)
            iconResult:setVisible(false)
		else   --失败
			resultStr = TextWords[1214]
            --result:setColor(ColorUtils:color16ToC3b("#ff1212"))
            --TextureManager:updateImageView(iconResult, "images/battle/Txt_fail.png")
            IconResult_win:setVisible(false)
            iconResult:setVisible(true)
			if selfData.legionName ~= "" then --有军团
				--helpBtn:setVisible(true)
			end
			local function helpHanle(sender, eventType)
				if eventType == ccui.TouchEventType.ended then
				end
			end
		end
    end
    
    iconResult:setScale(0.7)
	--result:setString(resultStr)
	helpBtn:setVisible(false) -- 军团求助按钮功能关闭
    ----------------------战斗结果end------------------------------------------------
	-- 时间
    time:setString(TimeUtils:setTimestampToString6(selfData.time))

    -- 分享按钮
    shareBtn.parent = self._parent
    shareBtn.data   = self._data
    
    ComponentUtils:addTouchEventListener(shareBtn, self.onTouchShare)

	--协议中暂未实现进攻地点是玩家名还是矿名
	--根据第一个字若是数字则是矿不是数字默认为玩家
--	function checkNameIsperson()
--		local num = string.sub(selfData.name,1,1)
--		return not tonumber(num)
--	end
end

------
-- 侦查报告，更新最上层的信息
function InfoPanel:updateWhPanel(clonePanel,infos)
	local selfData = rawget(infos,self.NAME) -- 相当于"InfoPanel"
    local reportData = infos -- 表示结构体 Report
    local whPanel = clonePanel --whPanelSrc:clone()
	local where = whPanel:getChildByName("where")
	local time = whPanel:getChildByName("time")
	local result = whPanel:getChildByName("result")
	local ryu = whPanel:getChildByName("ryu")
	local team = whPanel:getChildByName("team")
    local Label_71 = whPanel:getChildByName("Label_71")
	local targetBtn = whPanel:getChildByName("targetBtn")
	local progressBar = whPanel:getChildByName("progressBar")
    local progressBg  = whPanel:getChildByName("progressBg")
    local ofWhatTxt   = whPanel:getChildByName("ofWhatTxt")
    local resourceNameTxt   = whPanel:getChildByName("resourceNameTxt")
    local firstTxt01 = whPanel:getChildByName("firstTxt01")
    local firstTxt02 = whPanel:getChildByName("firstTxt02")
    local firstTxt03 = whPanel:getChildByName("firstTxt03")
    local Image_17 = whPanel:getChildByName("Image_17")
    firstTxt01:setString(TextWords:getTextWord(1252)) -- [[我查看了]]
    firstTxt02:setString(TextWords:getTextWord(1253)) -- [[据点驻军:]]
    firstTxt03:setString(TextWords:getTextWord(1254)) -- [[侦察时间:]]

    Image_17:setVisible(true)
    -- 颜色初始化
    resourceNameTxt:setColor(cc.c3b(255, 255, 255))
    where:setColor(cc.c3b(255, 255, 255))
    ------------第一行信息文本设置 start------------------
    -- 判断是否是被占领的资源
    local isTaken = reportData.InfoPanel.aim == reportData.InfoPanel.name
    if reportData.isPerson == 0 then -- 主城或被占领的资源
        if isTaken then
            where:setString(selfData.name)
            ofWhatTxt:setString( TextWords:getTextWord(1236)) -- 的主城
            resourceNameTxt:setString("")
        else
            -- 被占领的资源
            local name = reportData.InfoPanel.aim
            local resourceName = selfData.name
            where:setString(name)
            ofWhatTxt:setString(TextWords:getTextWord(1243)) -- "占领的"
            resourceNameTxt:setString(resourceName)
            -- 
            local loyaltyCount = infos.loyaltyCount
            resourceNameTxt:setColor(self._parent:getColorValueByLoyalty(loyaltyCount))
        end
    elseif reportData.isPerson == 1 then -- 资源点
        -- 无人占领
        local resourceName = selfData.name 
        where:setString(resourceName)
        ofWhatTxt:setString("")
        resourceNameTxt:setString("")
        -- 
        local loyaltyCount = infos.loyaltyCount
        where:setColor(self._parent:getColorValueByLoyalty(loyaltyCount))
    end

    -- 新增：采集成功
    if selfData.result == 3 then
        firstTxt01:setString(TextWords:getTextWord(1255)) -- [[我的部队从]]
        local resourceName = selfData.name 
        where:setString(resourceName)
        ofWhatTxt:setString(TextWords:getTextWord(1256)) -- "采集回来"
        firstTxt02:setString("")
        firstTxt03:setString(TextWords:getTextWord(4027)) -- "到达时间:"
        team:setString("")
        -- 
        Image_17:setVisible(false)
        local loyaltyCount = infos.loyaltyCount
        where:setColor(self._parent:getColorValueByLoyalty(loyaltyCount))
    end

    result:setString("("..selfData.posX..","..selfData.posY..")") -- 坐标
    -- NodeUtils:fixTwoNodePos(firstTxt01, where, 2)
    -- NodeUtils:fixTwoNodePos(where, ofWhatTxt, 2)
    -- NodeUtils:fixTwoNodePos(ofWhatTxt, resourceNameTxt, 2)
    -- NodeUtils:fixTwoNodePos(resourceNameTxt, result, 2)
    NodeUtils:alignNodeL2R(firstTxt01, where,ofWhatTxt,resourceNameTxt, result, 2)


    ------------第一行信息文本设置 end--------------------
	time:setString(TimeUtils:setTimestampToString6(selfData.time))
	
	if selfData.posX <0 and selfData.posY then
		result:setString("")
	end
	ryu:setString(selfData.legionName)
    if selfData.result ~= 3 then -- 不为采集
	    if selfData.posSoldier == "" then
		    team:setString(TextWords:getTextWord(3108)) -- 无
		    team:setColor(ColorUtils.wordWhiteColor)
	    else
		    team:setString(selfData.posSoldier) -- 有人
            team:setColor(ColorUtils.wordRedColor)
	    end
    end
	local prosper = rawget(selfData,"prosper")
	if prosper == nil then
		Label_71:setString("Lv."..selfData.level)
	else
		Label_71:setString(prosper.."/"..selfData.totalprosper)
        -- 是玩家的时候才显示
        if selfData.totalprosper == 0 then 
        -- 表示侦查资源点
            progressBar:setPercent(0)
            progressBg:setVisible(false)
            Label_71:setString("")
        else    
            local barPercent = prosper/selfData.totalprosper *100
            progressBar:setPercent(barPercent)
            progressBg:setVisible(true)
        end
	end
    

    -----------主城按钮begin
	local function miaoHanle(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self._parent:onGoToPosHandle()
		end
	end
	-----ceshi share
	if self._parent.tmp then
		if self._parent.tmp.index == 1 then
			result:setString("")
			targetBtn:setEnabled(false)
		else
			if infos.mailType == 1 then
				if infos.resourcePanel.cityIcon < 50 then
					result:setString("")
					targetBtn:setEnabled(false)
				end
			elseif infos.mailType == 3 then
				if infos.resourcePanel.cityIcon < 50 then
					result:setString("")
					targetBtn:setEnabled(false)
				else
					
				end
			end
		end
	end
	
	targetBtn:setVisible(true)
	targetBtn.callFun = miaoHanle
	targetBtn:addTouchEventListener(miaoHanle)
	local url
	if infos.resourcePanel.cityIcon > 0 then
		if infos.isPerson == 1 then
			local pointInfo = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, infos.resourcePanel.resourceId)
			url = ComponentUtils:getWorldBuildingUrl( pointInfo.icon,true)
		else
			if infos.resourcePanel.cityIcon >= 50 then
				url = ComponentUtils:getWorldBuildingUrl(infos.resourcePanel.cityIcon)
			else
				url = ComponentUtils:getWorldBuildingUrl(infos.resourcePanel.cityIcon,true)
			end
		end
		TextureManager:updateButtonNormal(targetBtn, url)
	end

	self:setIconScale(targetBtn, infos.isPerson)

    -- 需求，隐藏图标和进度条等
    Label_71:setVisible(false)
    progressBar:setVisible(false)
    progressBg:setVisible(false)
    targetBtn:setVisible(false)
end

-- icon缩放大小
function InfoPanel:setIconScale(targetBtn,targetType)
    local scale = 1
    if targetType == 1 then --资源缩放
        -- scale = GlobalConfig.worldMapResScaleConf[2][3]
    else  --建筑缩放        
        scale = GlobalConfig.worldMapBuildScale
    end
    targetBtn:setScale(scale)
end

------
-- 点击分享按钮
function InfoPanel:onTouchShare(sender)
--    print("点击分享")
--    if self._uiSharePanel == nil then
--        self._uiSharePanel = UISharePanel.new(sender, sender.parent)

--    end

--    local data = {}
--    data.type = ChatShareType.REPORT_TYPE 
--    data.id = sender.data.id
--    self._uiSharePanel:showPanel(sender, data, 170, -70)
--    self._uiSharePanel:rotationPanel()
    sender.parent:showShareView(sender )
end

function InfoPanel:setParentHandler(parent)
    self._parent = parent
end


function InfoPanel:updataCollectShow(panel, id)
   local collectBtn = panel:getChildByName("collectBtn")
   local collectCancleBtn = panel:getChildByName("collectCancleBtn") 
   self._parent:updataCollectShow(collectBtn, collectCancleBtn, id)
end


