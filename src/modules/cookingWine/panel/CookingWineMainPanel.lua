-- /**
--  * @Author:    luzhuojian
--  * @DateTime:    2017-01-06
--  * @Description: 限时活动 煮酒论英雄 主页面
--  */
CookingWineMainPanel = class("CookingWineMainPanel", BasicPanel)
CookingWineMainPanel.NAME = "CookingWineMainPanel"

function CookingWineMainPanel:ctor(view, panelName)
    CookingWineMainPanel.super.ctor(self, view, panelName)
    
end

function CookingWineMainPanel:finalize()
	if self.jiutanEffect ~= nil then
		self.jiutanEffect:finalize()
		self.jiutanEffect = nil
	end
	--if self.leftAddEffect ~= nil then
	--	self.leftAddEffect:finalize()
	--	self.leftAddEffect = nil
	--end
	--if self.rightAddEffect ~= nil then
	--	self.rightAddEffect:finalize()
	--	self.rightAddEffect = nil
	--end
	if self.qiehuanLEffect ~= nil then
		self.qiehuanLEffect:finalize()
		self.qiehuanLEffect = nil
	end
	if self.qiehuanREffect ~= nil then
		self.qiehuanREffect:finalize()
		self.qiehuanREffect = nil
	end
    CookingWineMainPanel.super.finalize(self)
end

function CookingWineMainPanel:initPanel()
	CookingWineMainPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Activity)
	local descLab = self:getChildByName("topPanel/descLab")
	descLab:setString(string.format("%s\n%s", self:getTextWord(420002), self:getTextWord(260003)) )

    local info= self.proxy.curActivityData.info
    logger:info("煮酒活动描述"..info)
    descLab:setString(string.format(info))

    descLab:setColor(cc.c3b(244,244,244))
	--标记是否敬酒特效播放中
	self.toasting = false
	--记录一下位置
	local addLeftImg = self:getChildByName("topPanel/addLeftImg")
	self.addLeftImgX,self.addLeftImgY = addLeftImg:getPosition()
	local addRightImg = self:getChildByName("topPanel/addRightImg")
	self.addRightImgX,self.addRightImgY = addRightImg:getPosition()
end
function CookingWineMainPanel:onShowHandler()
	-- local timeDescLab = self:getChildByName("topPanel/timeDescLab")
	self:updateCookingView()
end
function CookingWineMainPanel:updateCookingView(times)
	self.myData = self.proxy:getCurActivityData()
	local cookingWineConfig = ConfigDataManager:getConfigById(ConfigData.CookingWineConfig, self.myData.effectId)

	local topPanel = self:getChildByName("topPanel")
	local timeDescLab = self:getChildByName("topPanel/timeDescLab")
	-- local startTime = self:timestampToString(self.myData.startTime)
	-- local endTime = self:timestampToString(self.myData.endTime)
	-- if startTime == 0 or endTime == 0 then
	-- 	timeDescLab:setString("")
	-- else
		timeDescLab:setString(TimeUtils.getLimitActFormatTimeString(self.myData.startTime,self.myData.endTime,true))
	-- 	timeDescLab:setString(string.format("%s%s%s%s", self:getTextWord(420003),startTime,self:getTextWord(420004),endTime))
	-- end


	local cookInfo = self.proxy:getCookInfoyId(self.myData.activityId)
	self.cookInfoMap = {}
	for k,v in pairs(cookInfo.info) do
		self.cookInfoMap[v.pos] = v
		-- print(v.typeId)
	end
	--左边武将信息显示
	local addLeftImg = self:getChildByName("topPanel/addLeftImg")
	local heroNameLLab = self:getChildByName("topPanel/LHeroInfoPanel/heroNameLLab")
	local LProgressBar = self:getChildByName("topPanel/LHeroInfoPanel/LProgressBar")
	local pbNumLLab = self:getChildByName("topPanel/LHeroInfoPanel/pbNumLLab")
	local pbSumNumLLab = self:getChildByName("topPanel/LHeroInfoPanel/pbSumNumLLab")
	local LHeroInfoPanel = self:getChildByName("topPanel/LHeroInfoPanel")
	local rewardBg = self:getChildByName("topPanel/Image_27")
    rewardBg:setVisible(false)
	if self.cookInfoMap[1] then
		local heroConfig = ConfigDataManager:getConfigById(ConfigData.HeroConfig,self.cookInfoMap[1].typeId)
		--武将大图
		local url = ComponentUtils:getHeroHalfBodyUrl(self.cookInfoMap[1].typeId)
		TextureManager:updateImageViewFile(addLeftImg,url)
        --addLeftImg:setScale(0.7)
		--信息panel
		LHeroInfoPanel:setVisible(true)
		--名称
		heroNameLLab:setString(heroConfig.name)
		--忠诚值
		LProgressBar:setPercent(self.cookInfoMap[1].fidelity/cookingWineConfig.fullFidelity*100)
		pbNumLLab:setVisible(true)
		pbSumNumLLab:setVisible(true)
		pbNumLLab:setString(self.cookInfoMap[1].fidelity)
		pbSumNumLLab:setString("/" .. cookingWineConfig.fullFidelity)
		-- addLeftImg:setTouchEnabled(false)
		addLeftImg:setScale(0.64)
		--addLeftImg:setPosition(self.addLeftImgX,self.addLeftImgY-20)

		--if self.leftAddEffect ~= nil then
		--	self.leftAddEffect:finalize()
		--	self.leftAddEffect = nil
		--end
	else

		local url = "images/cookingWine/add.png"
		TextureManager:updateImageView(addLeftImg,url)
		LHeroInfoPanel:setVisible(false)
		-- addLeftImg:setTouchEnabled(true)
		addLeftImg:setScale(1)
		addLeftImg:setPosition(self.addLeftImgX,self.addLeftImgY)
		heroNameLLab:setString("")
		LProgressBar:setPercent(0)
		pbNumLLab:setVisible(false)
		pbSumNumLLab:setVisible(false)

		--if self.leftAddEffect == nil then
	    --	self.leftAddEffect = self:createUICCBLayer("rgb-jiahao", topPanel)--加号特效
		--    self.leftAddEffect:setPosition(self.addLeftImgX+15,self.addLeftImgY)
		--    self.leftAddEffect:setLocalZOrder(10)
		--end
	

	end
	--右边武将信息显示
	local addRightImg = self:getChildByName("topPanel/addRightImg")
	local heroNameRLab = self:getChildByName("topPanel/RHeroInfoPanel/heroNameRLab")
	local RProgressBar = self:getChildByName("topPanel/RHeroInfoPanel/RProgressBar")
	local pbNumRLab = self:getChildByName("topPanel/RHeroInfoPanel/pbNumRLab")
	local pbSumNumRLab = self:getChildByName("topPanel/RHeroInfoPanel/pbSumNumRLab")
	local RHeroInfoPanel = self:getChildByName("topPanel/RHeroInfoPanel")
	if self.cookInfoMap[2] then
		local heroConfig = ConfigDataManager:getConfigById(ConfigData.HeroConfig,self.cookInfoMap[2].typeId)
		--武将大图
		local url = ComponentUtils:getHeroHalfBodyUrl(self.cookInfoMap[2].typeId)
		TextureManager:updateImageViewFile(addRightImg,url)
		--信息panel
		RHeroInfoPanel:setVisible(true)
		--名称
		heroNameRLab:setString(heroConfig.name)
		--忠诚值
		RProgressBar:setPercent(self.cookInfoMap[2].fidelity/cookingWineConfig.fullFidelity*100)
		pbNumRLab:setVisible(true)
		pbSumNumRLab:setVisible(true)
		pbNumRLab:setString(self.cookInfoMap[2].fidelity)
		pbSumNumRLab:setString("/" .. cookingWineConfig.fullFidelity)
		-- addRightImg:setTouchEnabled(false)
		addRightImg:setScale(0.64)
		--addRightImg:setPosition(self.addRightImgX,self.addRightImgY-20)

		--if self.rightAddEffect ~= nil then
		--	self.rightAddEffect:finalize()
		--	self.rightAddEffect = nil
		--end


	else
		local url = "images/cookingWine/add.png"
		TextureManager:updateImageView(addRightImg,url)
		RHeroInfoPanel:setVisible(false)
		-- addRightImg:setTouchEnabled(true)
		addRightImg:setScale(1)
		addRightImg:setPosition(self.addRightImgX,self.addRightImgY)
		heroNameRLab:setString("")
		RProgressBar:setPercent(0)
		pbNumRLab:setVisible(false)
		pbSumNumRLab:setVisible(false)

		--if self.rightAddEffect == nil then
		--	self.rightAddEffect = self:createUICCBLayer("rgb-jiahao", topPanel)
		--    self.rightAddEffect:setPosition(self.addRightImgX-15,self.addRightImgY)
		--    self.rightAddEffect:setLocalZOrder(10)
		--end

	
	end
	--按钮显示
	local priceAry = StringUtils:jsonDecode(cookingWineConfig.onePrice)
	local onePriceNum = tonumber(priceAry[1][2])
	local fivePriceNum = tonumber(priceAry[2][2])

	local onceBtnNumLab = self:getChildByName("bottomPanel/onceBtnPanel/numLab")
	local fiveBtnNumLab = self:getChildByName("bottomPanel/fiveBtnPanel/numLab")
	local onceBtnIconImg = self:getChildByName("bottomPanel/onceBtnPanel/iconImg")
	local onceBtnFreeLab = self:getChildByName("bottomPanel/onceBtnPanel/freeLab")
	fiveBtnNumLab:setString(fivePriceNum)

	local freeTime = self.proxy:getCookFreeTime(self.myData.activityId)

	if freeTime > 0 then
		onceBtnNumLab:setVisible(false)
		onceBtnIconImg:setVisible(false)
		onceBtnFreeLab:setVisible(true)
	else
		onceBtnNumLab:setVisible(true)
		onceBtnIconImg:setVisible(true)
		onceBtnFreeLab:setVisible(false)
		onceBtnNumLab:setString(onePriceNum)
	end
	--特效
	local jiutanImg = self:getChildByName("topPanel/jiutanImg")
	local jiutanImgSize = jiutanImg:getContentSize()
	if self.jiutanEffect == nil then
	    self.jiutanEffect = self:createUICCBLayer("rgb-zjlyx-jiutan", jiutanImg)--酒坛特效
	    self.jiutanEffect:setPosition(jiutanImgSize.width*0.5, jiutanImgSize.height)
	end

	if self.qiehuanLEffect == nil then
		local changeLeftImg = self:getChildByName("topPanel/LHeroInfoPanel/changeLeftImg")
		local changeLeftImgSize = changeLeftImg:getContentSize()
	    self.qiehuanLEffect = self:createUICCBLayer("rgb-zjlyx-qiehuan", changeLeftImg)
	    self.qiehuanLEffect:setPosition(changeLeftImgSize.width*0.5, changeLeftImgSize.height*0.5)
	end

	if self.qiehuanREffect == nil then
		local changeRightImg = self:getChildByName("topPanel/RHeroInfoPanel/changeRightImg")
		local changeRightImgSize = changeRightImg:getContentSize()
	    self.qiehuanREffect = self:createUICCBLayer("rgb-zjlyx-qiehuan", changeRightImg)
	    self.qiehuanREffect:setPosition(changeRightImgSize.width*0.5, changeRightImgSize.height*0.5)
	end

	--记录忠诚值用于监控变化显示特效
	self.leftFidelity = self.cookInfoMap[1] and self.cookInfoMap[1].fidelity or 0
	self.rightFidelity = self.cookInfoMap[2] and self.cookInfoMap[2].fidelity or 0



end
function CookingWineMainPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, GlobalConfig.downHeight, tabsPanel)
end

function CookingWineMainPanel:registerEvents()
	CookingWineMainPanel.super.registerEvents(self)
	local addLeftImg = self:getChildByName("topPanel/addLeftImg")
	local addRightImg = self:getChildByName("topPanel/addRightImg")
	addLeftImg.tag = 1
	addRightImg.tag = 2
	self:addTouchEventListener(addRightImg,self.addHeroHandler)
	self:addTouchEventListener(addLeftImg,self.addHeroHandler)
	local onceBtn = self:getChildByName("bottomPanel/onceBtnPanel/btn")
	onceBtn.num = 1
	self:addTouchEventListener(onceBtn,self.toastHandler)
	local fiveBtn = self:getChildByName("bottomPanel/fiveBtnPanel/btn")
	fiveBtn.num = 5
	self:addTouchEventListener(fiveBtn,self.toastHandler)
	local changeLeftImg = self:getChildByName("topPanel/LHeroInfoPanel/changeLeftImg")
	local changeRightImg = self:getChildByName("topPanel/RHeroInfoPanel/changeRightImg")
	changeLeftImg.tag = 1
	changeRightImg.tag = 2
	self:addTouchEventListener(changeLeftImg,self.addHeroHandler)
	self:addTouchEventListener(changeRightImg,self.addHeroHandler)

end
function CookingWineMainPanel:addHeroHandler(sender)
    local panel = self:getPanel(CookingSelectHeroPanel.NAME)
    if self.cookInfoMap[sender.tag] then
    	panel:show({paymentType = 1,pos = sender.tag}) 
    else
    	panel:show({paymentType = 0,pos = sender.tag}) 
    end

end
function CookingWineMainPanel:toastHandler(sender)
	--特效播放中
	if self.toasting == true then
		self:showSysMessage(self:getTextWord(420016))
		return
	end

	--必须设置好2个宴请武将后,才能进行敬酒
	if self.cookInfoMap[1] == nil or self.cookInfoMap[2] == nil then
		self:showSysMessage(self:getTextWord(420015))
		return
	end


	local freeTime = self.proxy:getCookFreeTime(self.myData.activityId)

	local times =  sender.num or 1

	if freeTime > 0 and sender.num == 1 then
		local sendData = {}
		sendData.activityId = self.myData.activityId
		sendData.times = 0
		self.proxy:onTriggerNet230034Req(sendData)
	else
    	local roleProxy = self:getProxy(GameProxys.Role)
	    local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
	    local priceJson = ConfigDataManager:getConfigById(ConfigData.CookingWineConfig, self.myData.effectId).onePrice
	    local priceAry = StringUtils:jsonDecode(priceJson)
	    local realPriceNum
	    if times == 1 then
	    	realPriceNum = priceAry[1][2]
	    else
	    	realPriceNum = priceAry[2][2]
	    end
	    if realPriceNum > curNum then
	        local parent = self:getParent()
	        local panel = parent.panel
	        if panel == nil then
	            local panel = UIRecharge.new(parent, self)
	            parent.panel = panel
	        else
	            panel:show()
	        end
	    else
        	local function sureFun()
				local sendData = {}
				sendData.activityId = self.myData.activityId
				sendData.times = times
				self.proxy:onTriggerNet230034Req(sendData)
        	end
        	local messageBox = self:showMessageBox(string.format(self:getTextWord(420014),realPriceNum),sureFun)
            messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	    end
	end

end

function CookingWineMainPanel:timestampToString(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
	local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    return tab.year .. self:getTextWord(420005) .. tab.month .. self:getTextWord(420006) .. tab.day .. self:getTextWord(420007) .. hour ..":".. min
end
--敬酒成功后处理
function CookingWineMainPanel:afterToast(effectData)

    local scaleConst = 0.7--元宝缩放的比例
    local animationTime = 0.5--动画时间
    
	local rewardList = effectData.rewardList
	local times = effectData.time
	--先更新数据
	local cookInfo = self.proxy:getCookInfoyId(self.myData.activityId)
	self.cookInfoMap = {}
	for k,v in pairs(cookInfo.info) do
		self.cookInfoMap[v.pos] = v
	end
	local topPanel = self:getChildByName("topPanel")
	local jiutanImg = self:getChildByName("topPanel/jiutanImg")
	local jiutanImgSize = jiutanImg:getContentSize()
	--敬酒后的特效
	if times then
		if self.toasting == true then
			self:updateCookingView()
			return
		end
		self.toasting = true
		local leftChanged = self.leftFidelity ~= self.cookInfoMap[1].fidelity
		local rightChanged = self.rightFidelity ~= self.cookInfoMap[2].fidelity
		local side
		if leftChanged == true then
			side = -1
		else
			side = 1
		end

		local chuxianEffect = self:createUICCBLayer("rgb-zjlyx-chuxian", jiutanImg, nil, nil, true)
		chuxianEffect:setPosition(jiutanImgSize.width/2, jiutanImgSize.height - 30)
		chuxianEffect:setLocalZOrder(10)
		--一次敬酒特效
		if times == 1 or times == 0 then
			local url = "images/cookingWine/fs-jinzi.png"
			self.jiuBeiSprite = TextureManager:createSprite(url)
			jiutanImg:addChild(self.jiuBeiSprite)
			--self.jiuBeiSprite:setPosition(jiutanImgSize.width/2,jiutanImgSize.height)
			self.jiuBeiSprite:setPosition(self:randomStartPos())
            local endX, endY = self:randomEndPos()
			local moveByTop = cc.MoveBy:create(animationTime, cc.p(endX * side ,endY))
			--local moveByTop = cc.MoveBy:create(0.3, cc.p(195 * side ,100))cc.DelayTime:create(0.2)
			--local jumpBy = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
			--local RotateCallfunc =  cc.CallFunc:create(function ()
			--	self.jiuBeiSprite:setRotation(15*side)
			--end)
            local distanceY = self:getChildByName("topPanel/Image_15"):getPositionY() - jiutanImg:getPositionY()
			--local moveByOneSide = cc.MoveBy:create(0.5, cc.p(35*side * -1, distanceY - 100))
			local callfunc =  cc.CallFunc:create(function ()

				
				--local endPosX,endPosY = self.jiuBeiSprite:getPosition()
                --local endPosX,endPosY =self:getChildByName("topPanel/Image_15"):getPosition()

				local oneEffect = self:createUICCBLayer("rgb-zjlyx-bao", jiutanImg, nil, nil, true)
			    oneEffect:setPosition(160*side, distanceY)


				local progressBar
				local pbParentPanel
				if leftChanged == true then
					progressBar = self:getChildByName("topPanel/LHeroInfoPanel/LProgressBar")
					pbParentPanel = self:getChildByName("topPanel/LHeroInfoPanel")
					local duihuaEffect = self:createUICCBLayer("rgb-zjlyx-duihua", pbParentPanel, nil, nil, true)
					duihuaEffect:setPosition(200,290)
				else
					progressBar = self:getChildByName("topPanel/RHeroInfoPanel/RProgressBar")
					pbParentPanel = self:getChildByName("topPanel/RHeroInfoPanel")
					local duihuaEffect = self:createUICCBLayer("rgb-zjlyx-duihua2", pbParentPanel, nil, nil, true)
					duihuaEffect:setPosition(30,290)
				end

				local pbEffect = self:createUICCBLayer("rgb-jones-tixing", pbParentPanel, nil, nil, true)
			    local x,y = progressBar:getPosition()
			    pbEffect:setPosition(x - 30, y - 3)
			    pbEffect:setLocalZOrder(10)

			    local rewardCallfunc = cc.CallFunc:create(function ()
					local rewardBg = self:getChildByName("topPanel/Image_27")
                    rewardBg:setVisible(true)
			    	-- self.toasting = false
			    	if rewardList[1] then
			    		local rewardImg1 = self:getChildByName("topPanel/rewardImg1")
					    local rwEffect = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
					    local rwX,rwY = rewardImg1:getPosition()
					    rwEffect:setPosition(rwX,rwY+20)
					    rwEffect:setLocalZOrder(10)
					    if self.rewardIcon == nil then
							self.rewardIcon = UIIcon.new(rewardImg1, rewardList[1], true, self, nil,  true)
							self.rewardIcon:setPosition(0,20)
					    else

					    	self.rewardIcon:updateData(rewardList[1])
					    end
                		
			    	end
	
			    end)
			    local dt = cc.DelayTime:create(0.2)
			    local dt1 = cc.DelayTime:create(0.5)
			    local dt2 = cc.DelayTime:create(1)
			    local canTouchCallfunc = cc.CallFunc:create(function ()
					self.toasting = false  
			    end)
			    local removeRewardCallfunc = cc.CallFunc:create(function ()
					local rewardBg = self:getChildByName("topPanel/Image_27")
                    rewardBg:setVisible(false)
			        if self.rewardIcon ~= nil then
			            self.rewardIcon:finalize()
			            self.rewardIcon = nil
			        end
			        
			    end)
	

			    topPanel:runAction(cc.Sequence:create(dt,rewardCallfunc,dt1,canTouchCallfunc,dt2,removeRewardCallfunc))



				self.jiuBeiSprite:removeFromParent()
				self.jiuBeiSprite = nil
				self:updateCookingView()
			end)
            local delAct = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc)
            local act = cc.Spawn:create(moveByTop, cc.ScaleTo:create(animationTime, scaleConst), delAct)
			--local action = cc.Sequence:create(moveByTop,jumpBy,RotateCallfunc,moveByOneSide,callfunc)
			--local action = cc.Sequence:create(act,callfunc)

			self.jiuBeiSprite:runAction(act)



		end
		if times == 5 then
			--两边忠诚都加了,五个杯子两边飘
			if leftChanged == true and rightChanged == true then
				local url = "images/cookingWine/fs-jinzi.png"
				--第一个杯子
				self.jiuBeiSprite1 = TextureManager:createSprite(url)
				jiutanImg:addChild(self.jiuBeiSprite1)
				self.jiuBeiSprite1:setPosition(self:randomStartPos())
                local endX1, endY1 = self:randomEndPos()
				local moveByTop1 = cc.MoveBy:create(animationTime, cc.p(-1 * endX1, endY1))
				--local jumpBy1 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
				--local RotateCallfunc1 =  cc.CallFunc:create(function ()
				--	self.jiuBeiSprite1:setRotation(-15)
				--end)
				--local moveByOneSide1 = cc.MoveBy:create(0.5, cc.p(-160,10))
				local callfunc1 =  cc.CallFunc:create(function ()

					--local endPosX,endPosY = self.jiuBeiSprite1:getPosition()
					local oneEffect = self:createUICCBLayer("rgb-zjlyx-bao", jiutanImg, nil, nil, true)
				    oneEffect:setPosition(-160,self:getChildByName("topPanel/Image_15"):getPositionY() - jiutanImg:getPositionY())

					self.jiuBeiSprite1:removeFromParent()
					self.jiuBeiSprite1 = nil
					--两边进度条特效
					local progressBar1 = self:getChildByName("topPanel/LHeroInfoPanel/LProgressBar")
					local LHeroInfoPanel = self:getChildByName("topPanel/LHeroInfoPanel")
					local progressBar2 = self:getChildByName("topPanel/RHeroInfoPanel/RProgressBar")
					local RHeroInfoPanel = self:getChildByName("topPanel/RHeroInfoPanel")
					local pbEffect1 = self:createUICCBLayer("rgb-jones-tixing", LHeroInfoPanel, nil, nil, true)
				    local pb1X,pb1Y = progressBar1:getPosition()
				    pbEffect1:setPosition(pb1X - 30, pb1Y - 3)
				    pbEffect1:setLocalZOrder(10)

					local duihuaEffect1 = self:createUICCBLayer("rgb-zjlyx-duihua", LHeroInfoPanel, nil, nil, true)
					duihuaEffect1:setPosition(200,290)

					local pbEffect2 = self:createUICCBLayer("rgb-jones-tixing", RHeroInfoPanel, nil, nil, true)
				    local pb2X,pb2Y = progressBar2:getPosition()
				    pbEffect2:setPosition(pb2X - 30, pb2Y - 3)
				    pbEffect2:setLocalZOrder(10)

					local duihuaEffect2 = self:createUICCBLayer("rgb-zjlyx-duihua2", RHeroInfoPanel, nil, nil, true)
					duihuaEffect2:setPosition(30,200)

				    --五个奖励特效
				    local rewardCallfunc1 = cc.CallFunc:create(function ()
					    local rewardBg = self:getChildByName("topPanel/Image_27")
                        rewardBg:setVisible(true)
				    	-- self.toasting = false
				    	if rewardList[1] then
					    	local rewardImg1 = self:getChildByName("topPanel/rewardImg1")
						    local rwEffect1 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw1X,rw1Y = rewardImg1:getPosition()
						    rwEffect1:setPosition(rw1X,rw1Y+20)
						    rwEffect1:setLocalZOrder(10)
						    if self.rewardIcon1 == nil then
								self.rewardIcon1 = UIIcon.new(rewardImg1, rewardList[1], true, self, nil,  true)
								self.rewardIcon1:setPosition(0,20)
						    else
						    	self.rewardIcon1:updateData(rewardList[1])
						    end
						    
				    	end

				    end)
				    local rewardCallfunc2 = cc.CallFunc:create(function ()
				    	if rewardList[2] then
				    		local rewardImg2 = self:getChildByName("topPanel/rewardImg2")
						    local rwEffect2 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw2X,rw2Y = rewardImg2:getPosition()
						    rwEffect2:setPosition(rw2X,rw2Y+20)
						    rwEffect2:setLocalZOrder(10)
						    
						    if self.rewardIcon2 == nil then
								self.rewardIcon2 = UIIcon.new(rewardImg2, rewardList[2], true, self, nil,  true)
								self.rewardIcon2:setPosition(0,20)

						    else
						    	self.rewardIcon2:updateData(rewardList[2])
						    end
				    	end
						if rewardList[3] then
				    		local rewardImg3 = self:getChildByName("topPanel/rewardImg3")
						    local rwEffect3 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw3X,rw3Y = rewardImg3:getPosition()
						    rwEffect3:setPosition(rw3X,rw3Y+20)
						    rwEffect3:setLocalZOrder(10)
						    if self.rewardIcon3 == nil then
								self.rewardIcon3 = UIIcon.new(rewardImg3, rewardList[3], true, self, nil,  true)
								self.rewardIcon3:setPosition(0,20)
						    else
						    	self.rewardIcon3:updateData(rewardList[3])
						    end
						    
						end
	
				    end)
					local rewardCallfunc3 = cc.CallFunc:create(function ()
						if rewardList[4] then
				    		local rewardImg4 = self:getChildByName("topPanel/rewardImg4")
						    local rwEffect4 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw4X,rw4Y = rewardImg4:getPosition()
						    rwEffect4:setPosition(rw4X,rw4Y+20)
						    rwEffect4:setLocalZOrder(10)
						    if self.rewardIcon4 == nil then
								self.rewardIcon4 = UIIcon.new(rewardImg4, rewardList[4], true, self, nil,  true)
								self.rewardIcon4:setPosition(0,20)
						    else
						    	self.rewardIcon4:updateData(rewardList[4])
						    end
						    
						end
						if rewardList[5] then
				    		local rewardImg5 = self:getChildByName("topPanel/rewardImg5")
						    local rwEffect5 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw5X,rw5Y = rewardImg5:getPosition()
						    rwEffect5:setPosition(rw5X,rw5Y+20)
						    rwEffect5:setLocalZOrder(10)
						    if self.rewardIcon5 == nil then
								self.rewardIcon5 = UIIcon.new(rewardImg5, rewardList[5], true, self, nil,  true)
								self.rewardIcon5:setPosition(0,20)
						    else
						    	self.rewardIcon5:updateData(rewardList[5])
						    end
						    
						end
	
				    end)
				    local dt = cc.DelayTime:create(0.2)
				    local dt1 = cc.DelayTime:create(0.5)
				    local dt2 = cc.DelayTime:create(1)
				    local canTouchCallfunc = cc.CallFunc:create(function ()
						self.toasting = false  
				    end)
				    local removeRewardCallfunc = cc.CallFunc:create(function ()
					    local rewardBg = self:getChildByName("topPanel/Image_27")
                        rewardBg:setVisible(false)
				    	for i=1,5 do
				        	if self["rewardIcon" .. i] ~= nil then
					            self["rewardIcon" .. i]:finalize()
					            self["rewardIcon" .. i] = nil
					        end
				    	end
				    	
				    end)
		

				    topPanel:runAction(cc.Sequence:create(dt,rewardCallfunc1,dt,rewardCallfunc2,dt,rewardCallfunc3,dt1,canTouchCallfunc,dt2,removeRewardCallfunc))


					self:updateCookingView()
				end)
                local delAct1 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc1)
                local act1 = cc.Spawn:create(moveByTop1, cc.ScaleTo:create(animationTime, scaleConst), delAct1)
				--local action1 = cc.Sequence:create(moveByTop1,jumpBy1,RotateCallfunc1,moveByOneSide1,callfunc1)
			    --local action1 = cc.Sequence:create(act1,callfunc1)

				self.jiuBeiSprite1:runAction(act1)
				
				local cup23Callfunc =  cc.CallFunc:create(function ()
					--第二个杯子
					self.jiuBeiSprite2 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite2)
					self.jiuBeiSprite2:setPosition(self:randomStartPos())
                    local endX2, endY2 = self:randomEndPos()
					local moveByTop2 = cc.MoveBy:create(animationTime, cc.p(endX2 * -1 ,endY2))
					--local jumpBy2 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc2 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite2:setRotation(-15)
					--end)
					--local moveByOneSide2 = cc.MoveBy:create(0.5, cc.p(-160,20))
					local callfunc2 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite2:removeFromParent()
						self.jiuBeiSprite2 = nil
						-- self:updateCookingView()
					end)
                    local delAct2 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc2)
                    local act2 = cc.Spawn:create(moveByTop2, cc.ScaleTo:create(animationTime, scaleConst), delAct2)
					--local action2 = cc.Sequence:create(act2,callfunc2)

					self.jiuBeiSprite2:runAction(act2)
					--第三个杯子
					self.jiuBeiSprite3 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite3)
					self.jiuBeiSprite3:setPosition(self:randomStartPos())
                    local endX3, endY3 = self:randomEndPos()
					local moveByTop3 = cc.MoveBy:create(animationTime, cc.p(endX3 * -1, endY3))
					--local jumpBy3 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc3 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite3:setRotation(-15)
					--end)
					--local moveByOneSide3 = cc.MoveBy:create(0.5, cc.p(-160,30))
					local callfunc3 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite3:removeFromParent()
						self.jiuBeiSprite3 = nil
						-- self:updateCookingView()
					end)
                    local delAct3 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc3)
                    local act3 = cc.Spawn:create(moveByTop3, cc.ScaleTo:create(animationTime, scaleConst), delAct3)
					--local action3 = cc.Sequence:create(act3,callfunc3)

					self.jiuBeiSprite3:runAction(act3)
				end)
	
				
				local cup45Callfunc =  cc.CallFunc:create(function ()
					--第四个杯子
					self.jiuBeiSprite4 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite4)
					self.jiuBeiSprite4:setPosition(self:randomStartPos())
                    local endX4, endY4 = self:randomEndPos()
					local moveByTop4 = cc.MoveBy:create(animationTime, cc.p(endX4, endY4))
					--local jumpBy4 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc4 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite4:setRotation(15)
					--end)
					--local moveByOneSide4 = cc.MoveBy:create(0.5, cc.p(160,10))
					local callfunc4 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite4:removeFromParent()
						self.jiuBeiSprite4 = nil
						-- self:updateCookingView()
					end)
                    local delAct4 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc4)
                    local act4 = cc.Spawn:create(moveByTop4, cc.ScaleTo:create( animationTime, scaleConst), delAct4)
					--local action4 = cc.Sequence:create(act4,callfunc4)

					self.jiuBeiSprite4:runAction(act4)
					--第五个杯子
					self.jiuBeiSprite5 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite5)
					self.jiuBeiSprite5:setPosition(self:randomStartPos())
                    local endX5, endY5 = self:randomEndPos()
					local moveByTop5 = cc.MoveBy:create(animationTime, cc.p(endX5, endY5))
					--local jumpBy5 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc5 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite5:setRotation(15)
					--end)
					--local moveByOneSide5 = cc.MoveBy:create(0.5, cc.p(160,20))
					local callfunc5 =  cc.CallFunc:create(function ()
						--local endPosX,endPosY = self.jiuBeiSprite5:getPosition()
						local oneEffect = self:createUICCBLayer("rgb-zjlyx-bao", jiutanImg, nil, nil, true)
					    oneEffect:setPosition(160,self:getChildByName("topPanel/Image_15"):getPositionY() - jiutanImg:getPositionY())
						self.jiuBeiSprite5:removeFromParent()
						self.jiuBeiSprite5 = nil
						-- self:updateCookingView()
					end)
                    local delAct5 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc5)
                    local act5 = cc.Spawn:create(moveByTop5, cc.ScaleTo:create(animationTime, scaleConst), delAct5)
					--local action5 = cc.Sequence:create(act5,callfunc5)

					self.jiuBeiSprite5:runAction(act5)
				end)
	

				local dt = cc.DelayTime:create(0.05)
				topPanel:runAction(cc.Sequence:create(dt,cup23Callfunc,dt,cup45Callfunc))

			--只加了一边的忠诚,五个杯子飞向一边
			elseif leftChanged == true and rightChanged == false then
				local url = "images/cookingWine/fs-jinzi.png"
				--第一个杯子
				self.jiuBeiSprite1 = TextureManager:createSprite(url)
				jiutanImg:addChild(self.jiuBeiSprite1)
				self.jiuBeiSprite1:setPosition(self:randomStartPos())
                local endX1, endY1 = self:randomEndPos()
				local moveByTop1 = cc.MoveBy:create(animationTime, cc.p(endX1 * -1, endY1))
				--local jumpBy1 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
				--local RotateCallfunc1 =  cc.CallFunc:create(function ()
				--	self.jiuBeiSprite1:setRotation(-15)
				--end)
				--local moveByOneSide1 = cc.MoveBy:create(0.5, cc.p(-160,10))
				local callfunc1 =  cc.CallFunc:create(function ()

					--local endPosX,endPosY = self.jiuBeiSprite1:getPosition()
					local oneEffect = self:createUICCBLayer("rgb-zjlyx-bao", jiutanImg, nil, nil, true)
				    oneEffect:setPosition(-160,self:getChildByName("topPanel/Image_15"):getPositionY() - jiutanImg:getPositionY())

					self.jiuBeiSprite1:removeFromParent()
					self.jiuBeiSprite1 = nil

					local progressBar1 = self:getChildByName("topPanel/LHeroInfoPanel/LProgressBar")
					local LHeroInfoPanel = self:getChildByName("topPanel/LHeroInfoPanel")
					local pbEffect1 = self:createUICCBLayer("rgb-jones-tixing", LHeroInfoPanel, nil, nil, true)
				    local pb1X,pb1Y = progressBar1:getPosition()
				    pbEffect1:setPosition(pb1X - 30, pb1Y - 3)
				    pbEffect1:setLocalZOrder(10)

					local duihuaEffect1 = self:createUICCBLayer("rgb-zjlyx-duihua", LHeroInfoPanel, nil, nil, true)
					duihuaEffect1:setPosition(200,290)
				    --五个奖励特效
				    local rewardCallfunc1 = cc.CallFunc:create(function ()
					    local rewardBg = self:getChildByName("topPanel/Image_27")
                        rewardBg:setVisible(true)
				    	-- self.toasting = false
				    	if rewardList[1] then
				    		local rewardImg1 = self:getChildByName("topPanel/rewardImg1")
						    local rwEffect1 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw1X,rw1Y = rewardImg1:getPosition()
						    rwEffect1:setPosition(rw1X,rw1Y+20)
						    rwEffect1:setLocalZOrder(10)
						    if self.rewardIcon1 == nil then
								self.rewardIcon1 = UIIcon.new(rewardImg1, rewardList[1], true, self, nil,  true)
								self.rewardIcon1:setPosition(0,20)
						    else
						    	self.rewardIcon1:updateData(rewardList[1])
						    end
						    
				    	end
	
				    end)
				    local rewardCallfunc2 = cc.CallFunc:create(function ()
				    	if rewardList[2] then
				    		local rewardImg2 = self:getChildByName("topPanel/rewardImg2")
						    local rwEffect2 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw2X,rw2Y = rewardImg2:getPosition()
						    rwEffect2:setPosition(rw2X,rw2Y+20)
						    rwEffect2:setLocalZOrder(10)
						    if self.rewardIcon2 == nil then
								self.rewardIcon2 = UIIcon.new(rewardImg2, rewardList[2], true, self, nil,  true)
								self.rewardIcon2:setPosition(0,20)
						    else
						    	self.rewardIcon2:updateData(rewardList[2])
						    end
						    
				    	end
						if rewardList[3] then
				    		local rewardImg3 = self:getChildByName("topPanel/rewardImg3")
						    local rwEffect3 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw3X,rw3Y = rewardImg3:getPosition()
						    rwEffect3:setPosition(rw3X,rw3Y+20)
						    rwEffect3:setLocalZOrder(10)
						    if self.rewardIcon3 == nil then
								self.rewardIcon3 = UIIcon.new(rewardImg3, rewardList[3], true, self, nil,  true)
								self.rewardIcon3:setPosition(0,20)
						    else
						    	self.rewardIcon3:updateData(rewardList[3])
						    end
						    
						end
	
				    end)
					local rewardCallfunc3 = cc.CallFunc:create(function ()
						if rewardList[4] then
				    		local rewardImg4 = self:getChildByName("topPanel/rewardImg4")
						    local rwEffect4 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw4X,rw4Y = rewardImg4:getPosition()
						    rwEffect4:setPosition(rw4X,rw4Y+20)
						    rwEffect4:setLocalZOrder(10)
						    if self.rewardIcon4 == nil then
								self.rewardIcon4 = UIIcon.new(rewardImg4, rewardList[4], true, self, nil,  true)
								self.rewardIcon4:setPosition(0,20)
						    else
						    	self.rewardIcon4:updateData(rewardList[4])
						    end
						    
						end
						if rewardList[5] then
					    	local rewardImg5 = self:getChildByName("topPanel/rewardImg5")
						    local rwEffect5 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw5X,rw5Y = rewardImg5:getPosition()
						    rwEffect5:setPosition(rw5X,rw5Y+20)
						    rwEffect5:setLocalZOrder(10)
						    if self.rewardIcon5 == nil then
								self.rewardIcon5 = UIIcon.new(rewardImg5, rewardList[5], true, self, nil,  true)
								self.rewardIcon5:setPosition(0,20)
						    else
						    	self.rewardIcon5:updateData(rewardList[5])
						    end
						    
						end
	
				    end)
				    local dt = cc.DelayTime:create(0.2)
				    local dt1 = cc.DelayTime:create(0.5)
				    local dt2 = cc.DelayTime:create(1)
				    local canTouchCallfunc = cc.CallFunc:create(function ()
						self.toasting = false  
				    end)
				    local removeRewardCallfunc = cc.CallFunc:create(function ()
					    local rewardBg = self:getChildByName("topPanel/Image_27")
                        rewardBg:setVisible(false)
				    	for i=1,5 do
				        	if self["rewardIcon" .. i] ~= nil then
					            self["rewardIcon" .. i]:finalize()
					            self["rewardIcon" .. i] = nil
					        end
				    	end
				    	
				    end)

				    topPanel:runAction(cc.Sequence:create(dt,rewardCallfunc1,dt,rewardCallfunc2,dt,rewardCallfunc3,dt1,canTouchCallfunc,dt2,removeRewardCallfunc))

					self:updateCookingView()
				end)
                local delAct1 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc1)
                local act1 = cc.Spawn:create(moveByTop1, cc.ScaleTo:create(animationTime, scaleConst), delAct1)
				--local action1 = cc.Sequence:create(act1,callfunc1)

				self.jiuBeiSprite1:runAction(act1)
				local cup23Callfunc =  cc.CallFunc:create(function ()
					--第二个杯子
					self.jiuBeiSprite2 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite2)
					self.jiuBeiSprite2:setPosition(self:randomStartPos())
                    local endX2, endY2 = self:randomEndPos()
					local moveByTop2 = cc.MoveBy:create(animationTime, cc.p(endX2 * -1, endY2))
					--local jumpBy2 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc2 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite2:setRotation(-15)
					--end)
					--local moveByOneSide2 = cc.MoveBy:create(0.5, cc.p(-200,20))
					local callfunc2 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite2:removeFromParent()
						self.jiuBeiSprite2 = nil
						-- self:updateCookingView()
					end)
                    local delAct2 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc2)
                    local act2 = cc.Spawn:create(moveByTop2, cc.ScaleTo:create(animationTime,scaleConst), delAct2)
					--local action2 = cc.Sequence:create(act2,callfunc2)

					self.jiuBeiSprite2:runAction(act2)
					--第三个杯子
					self.jiuBeiSprite3 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite3)
					self.jiuBeiSprite3:setPosition(self:randomStartPos())
                    local endX3, endY3 = self:randomEndPos()
					local moveByTop3 = cc.MoveBy:create(animationTime, cc.p(endX3 * -1, endY3))
					--local jumpBy3 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc3 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite3:setRotation(-15)
					--end)
					--local moveByOneSide3 = cc.MoveBy:create(0.5, cc.p(-160,30))
					local callfunc3 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite3:removeFromParent()
						self.jiuBeiSprite3 = nil
						-- self:updateCookingView()
					end)
                    local delAct3 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc3)
                    local act3 = cc.Spawn:create(moveByTop3, cc.ScaleTo:create(animationTime, scaleConst), delAct3)
					--local action3 = cc.Sequence:create(act3,callfunc3)

					self.jiuBeiSprite3:runAction(act3)
				end)
				local cup45Callfunc =  cc.CallFunc:create(function ()
					--第四个杯子
					self.jiuBeiSprite4 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite4)
					self.jiuBeiSprite4:setPosition(self:randomStartPos())
                    local endX4, endY4 = self:randomEndPos()
					local moveByTop4 = cc.MoveBy:create(animationTime, cc.p(endX4 * -1, endY4))
					--local jumpBy4 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc4 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite4:setRotation(-15)
					--end)
					--local moveByOneSide4 = cc.MoveBy:create(0.5, cc.p(-255,10))
					local callfunc4 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite4:removeFromParent()
						self.jiuBeiSprite4 = nil
						-- self:updateCookingView()
					end)
                    local delAct4 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc4)
                    local act4 = cc.Spawn:create(moveByTop4, cc.ScaleTo:create(animationTime, scaleConst), delAct4)
					--local action4 = cc.Sequence:create(act4, callfunc4)

					self.jiuBeiSprite4:runAction(act4)
					--第五个杯子
					self.jiuBeiSprite5 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite5)
					self.jiuBeiSprite5:setPosition(self:randomStartPos())
                    local endX5, endY5 = self:randomEndPos()
					local moveByTop5 = cc.MoveBy:create(animationTime, cc.p(endX5 * -1, endY5))
					--local jumpBy5 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc5 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite5:setRotation(-15)
					--end)
					--local moveByOneSide5 = cc.MoveBy:create(0.5, cc.p(-160,20))
					local callfunc5 =  cc.CallFunc:create(function ()
						--local endPosX,endPosY = self.jiuBeiSprite5:getPosition()
						local oneEffect = self:createUICCBLayer("rgb-zjlyx-bao", jiutanImg, nil, nil, true)
					    oneEffect:setPosition(-160,self:getChildByName("topPanel/Image_15"):getPositionY() - jiutanImg:getPositionY())
						self.jiuBeiSprite5:removeFromParent()
						self.jiuBeiSprite5 = nil
						-- self:updateCookingView()
					end)
                    local delAct5 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc5)
                    local act5 = cc.Spawn:create(moveByTop5, cc.ScaleTo:create(animationTime, scaleConst), delAct5)
					--local action5 = cc.Sequence:create(act5, callfunc5)

					self.jiuBeiSprite5:runAction(act5)
				end)
				local dt = cc.DelayTime:create(0.05)
				topPanel:runAction(cc.Sequence:create(dt,cup23Callfunc,dt,cup45Callfunc))

			elseif leftChanged == false and rightChanged == true then
				local url = "images/cookingWine/fs-jinzi.png"
				--第一个杯子
				self.jiuBeiSprite1 = TextureManager:createSprite(url)
				jiutanImg:addChild(self.jiuBeiSprite1)
				self.jiuBeiSprite1:setPosition(self:randomStartPos())
                local endX1, endY1 = self:randomEndPos()
				local moveByTop1 = cc.MoveBy:create(animationTime, cc.p(endX1, endY1))
				--local jumpBy1 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
				--local RotateCallfunc1 =  cc.CallFunc:create(function ()
				--	self.jiuBeiSprite1:setRotation(15)
				--end)
				--local moveByOneSide1 = cc.MoveBy:create(0.5, cc.p(160,10))
				local callfunc1 =  cc.CallFunc:create(function ()

					--local endPosX,endPosY = self.jiuBeiSprite1:getPosition()
					local oneEffect = self:createUICCBLayer("rgb-zjlyx-bao", jiutanImg, nil, nil, true)
				    oneEffect:setPosition(160,self:getChildByName("topPanel/Image_15"):getPositionY() - jiutanImg:getPositionY())

					self.jiuBeiSprite1:removeFromParent()
					self.jiuBeiSprite1 = nil

					local progressBar2 = self:getChildByName("topPanel/RHeroInfoPanel/RProgressBar")
					local RHeroInfoPanel = self:getChildByName("topPanel/RHeroInfoPanel")
					local pbEffect2 = self:createUICCBLayer("rgb-jones-tixing", RHeroInfoPanel, nil, nil, true)
				    local pb2X,pb2Y = progressBar2:getPosition()
				    pbEffect2:setPosition(pb2X - 30, pb2Y - 3)
				    pbEffect2:setLocalZOrder(10)

					local duihuaEffect2 = self:createUICCBLayer("rgb-zjlyx-duihua2", RHeroInfoPanel, nil, nil, true)
				    duihuaEffect2:setPosition(30,290)

				    --五个奖励特效
				    local rewardCallfunc1 = cc.CallFunc:create(function ()
					    local rewardBg = self:getChildByName("topPanel/Image_27")
                        rewardBg:setVisible(true)
				    	-- self.toasting = false
				    	if rewardList[1] then
				    		local rewardImg1 = self:getChildByName("topPanel/rewardImg1")
						    local rwEffect1 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw1X,rw1Y = rewardImg1:getPosition()
						    rwEffect1:setPosition(rw1X,rw1Y+20)
						    rwEffect1:setLocalZOrder(10)
						    if self.rewardIcon1 == nil then
								 self.rewardIcon1 = UIIcon.new(rewardImg1, rewardList[1], true, self, nil,  true)
								 self.rewardIcon1:setPosition(0,20)
						    else
						    	self.rewardIcon1:updateData(rewardList[1])
						    end
						   
				    	end
	
				    end)
				    local rewardCallfunc2 = cc.CallFunc:create(function ()
				    	if rewardList[2] then
					    	local rewardImg2 = self:getChildByName("topPanel/rewardImg2")
						    local rwEffect2 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw2X,rw2Y = rewardImg2:getPosition()
						    rwEffect2:setPosition(rw2X,rw2Y+20)
						    rwEffect2:setLocalZOrder(10)
						    if self.rewardIcon2 == nil then
								self.rewardIcon2 = UIIcon.new(rewardImg2, rewardList[2], true, self, nil,  true)
								self.rewardIcon2:setPosition(0,20)
						    else
						    	self.rewardIcon2:updateData(rewardList[2])
						    end
						    
				    	end
				    	if rewardList[3] then
					    	local rewardImg3 = self:getChildByName("topPanel/rewardImg3")
						    local rwEffect3 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw3X,rw3Y = rewardImg3:getPosition()
						    rwEffect3:setPosition(rw3X,rw3Y+20)
						    rwEffect3:setLocalZOrder(10)
						    if self.rewardIcon3 == nil then
								self.rewardIcon3 = UIIcon.new(rewardImg3, rewardList[3], true, self, nil,  true)
								self.rewardIcon3:setPosition(0,20)
						    else
						    	self.rewardIcon3:updateData(rewardList[3])
						    end
						    
				    	end

				    end)
					local rewardCallfunc3 = cc.CallFunc:create(function ()
						if rewardList[4] then
					    	local rewardImg4 = self:getChildByName("topPanel/rewardImg4")
						    local rwEffect4 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw4X,rw4Y = rewardImg4:getPosition()
						    rwEffect4:setPosition(rw4X,rw4Y+20)
						    rwEffect4:setLocalZOrder(10)
						    if self.rewardIcon4 == nil then
								self.rewardIcon4 = UIIcon.new(rewardImg4, rewardList[4], true, self, nil,  true)
								self.rewardIcon4:setPosition(0,20)
						    else
						    	self.rewardIcon4:updateData(rewardList[4])
						    end
						    
						end
						if rewardList[5] then
					    	local rewardImg5 = self:getChildByName("topPanel/rewardImg5")
						    local rwEffect5 = self:createUICCBLayer("rgb-zjlyx-wupinccb", topPanel, nil, nil, true)
						    local rw5X,rw5Y = rewardImg5:getPosition()
						    rwEffect5:setPosition(rw5X,rw5Y+20)
						    rwEffect5:setLocalZOrder(10)
						    if self.rewardIcon5 == nil then
								self.rewardIcon5 = UIIcon.new(rewardImg5, rewardList[5], true, self, nil,  true)
								self.rewardIcon5:setPosition(0,20)
						    else
						    	self.rewardIcon5:updateData(rewardList[5])
						    end
						    
						end

				    end)
				    local dt = cc.DelayTime:create(0.2)
				    local dt1 = cc.DelayTime:create(0.5)
				    local dt2 = cc.DelayTime:create(1)
				    local canTouchCallfunc = cc.CallFunc:create(function ()
						self.toasting = false  
				    end)
				    local removeRewardCallfunc = cc.CallFunc:create(function ()
					    local rewardBg = self:getChildByName("topPanel/Image_27")
                        rewardBg:setVisible(false)
				    	for i=1,5 do
				        	if self["rewardIcon" .. i] ~= nil then
					            self["rewardIcon" .. i]:finalize()
					            self["rewardIcon" .. i] = nil
					        end
				    	end
				    	
				    end)
		

				    topPanel:runAction(cc.Sequence:create(dt,rewardCallfunc1,dt,rewardCallfunc2,dt,rewardCallfunc3,dt1,canTouchCallfunc,dt2,removeRewardCallfunc))


					self:updateCookingView()
				end)
                local delAct1 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc1)
                local act1 = cc.Spawn:create(moveByTop1, cc.ScaleTo:create(animationTime, scaleConst), delAct1)
				--local action1 = cc.Sequence:create(act1, callfunc1)

				self.jiuBeiSprite1:runAction(act1)

				local cup23Callfunc =  cc.CallFunc:create(function ()
					--第二个杯子
					self.jiuBeiSprite2 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite2)
					self.jiuBeiSprite2:setPosition(self:randomStartPos())
                    local endX2, endY2 = self:randomEndPos()
					local moveByTop2 = cc.MoveBy:create(animationTime, cc.p(endX2, endY2))
					--local jumpBy2 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc2 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite2:setRotation(15)
					--end)
					--local moveByOneSide2 = cc.MoveBy:create(0.5, cc.p(255,20))
					local callfunc2 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite2:removeFromParent()
						self.jiuBeiSprite2 = nil
						-- self:updateCookingView()
					end)
                    local delAct2 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc2)
                    local act2 = cc.Spawn:create(moveByTop2, cc.ScaleTo:create(animationTime, scaleConst), delAct2)
					--local action2 = cc.Sequence:create(act2,callfunc2)

					self.jiuBeiSprite2:runAction(act2)
					--第三个杯子
					self.jiuBeiSprite3 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite3)
					self.jiuBeiSprite3:setPosition(self:randomStartPos())
                    local endX3, endY3 = self:randomEndPos()
					local moveByTop3 = cc.MoveBy:create(animationTime, cc.p(endX3, endY3))
					--local jumpBy3 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc3 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite3:setRotation(15)
					--end)
					--local moveByOneSide3 = cc.MoveBy:create(0.5, cc.p(270,30))
					local callfunc3 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite3:removeFromParent()
						self.jiuBeiSprite3 = nil
						-- self:updateCookingView()
					end)
                    local delAct3 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc3)
                    local act3 = cc.Spawn:create(moveByTop3, cc.ScaleTo:create(animationTime, scaleConst), delAct3)
					--local action3 = cc.Sequence:create(act3,callfunc3)

					self.jiuBeiSprite3:runAction(act3)
				end)
				local cup45Callfunc =  cc.CallFunc:create(function ()
					--第四个杯子
					self.jiuBeiSprite4 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite4)
					self.jiuBeiSprite4:setPosition(self:randomStartPos())
                    local endX4, endY4 = self:randomEndPos()
					local moveByTop4 = cc.MoveBy:create(animationTime, cc.p(endX4, endY4))
					--local jumpBy4 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc4 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite4:setRotation(15)
					--end)
					--local moveByOneSide4 = cc.MoveBy:create(0.5, cc.p(185,10))
					local callfunc4 =  cc.CallFunc:create(function ()
						self.jiuBeiSprite4:removeFromParent()
						self.jiuBeiSprite4 = nil
						-- self:updateCookingView()
					end)
                    local delAct4 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc4)
                    local act4 = cc.Spawn:create(moveByTop4, cc.ScaleTo:create(animationTime, scaleConst), delAct4)
					--local action4 = cc.Sequence:create(act4,callfunc4)

					self.jiuBeiSprite4:runAction(act4)
					--第五个杯子
					self.jiuBeiSprite5 = TextureManager:createSprite(url)
					jiutanImg:addChild(self.jiuBeiSprite5)
					self.jiuBeiSprite5:setPosition(self:randomStartPos())
                    local endX5, endY5 = self:randomEndPos()
					local moveByTop5 = cc.MoveBy:create(animationTime, cc.p(endX5, endY5))
					--local jumpBy5 = cc.JumpBy:create(0.4, cc.p(0,0), 10, 1)
					--local RotateCallfunc5 =  cc.CallFunc:create(function ()
					--	self.jiuBeiSprite5:setRotation(15)
					--end)
					--local moveByOneSide5 = cc.MoveBy:create(0.5, cc.p(160,20))
					local callfunc5 =  cc.CallFunc:create(function ()
						--local endPosX,endPosY = self.jiuBeiSprite5:getPosition()
						local oneEffect = self:createUICCBLayer("rgb-zjlyx-bao", jiutanImg, nil, nil, true)
					    oneEffect:setPosition(160,self:getChildByName("topPanel/Image_15"):getPositionY() - jiutanImg:getPositionY())
						self.jiuBeiSprite5:removeFromParent()
						self.jiuBeiSprite5 = nil
						-- self:updateCookingView()
					end)
                    local delAct5 = cc.Sequence:create(cc.DelayTime:create(animationTime - 0.1), callfunc5)
                    local act5 = cc.Spawn:create(moveByTop5, cc.ScaleTo:create(animationTime, scaleConst), delAct5)
					--local action5 = cc.Sequence:create(act5,callfunc5)

					self.jiuBeiSprite5:runAction(act5)
				end)
				local dt = cc.DelayTime:create(0.05)
				topPanel:runAction(cc.Sequence:create(dt,cup23Callfunc,dt,cup45Callfunc))
			end
		end


	end

end

--随机起点位置
function CookingWineMainPanel:randomStartPos()
    local fun = function ()
        math.randomseed(os.time())
        return math.random(-50, 50)
    end
    local posX = fun()
    local posY = fun()

    return posX, posY
end


--随机结束位置160, 210
function CookingWineMainPanel:randomEndPos()
    --local fun = function ()
    --    math.randomseed(os.time())
    --    return math.random(-30, 30)
    --end
    math.randomseed(os.time())
    local posX = 160 + math.random(-30, 30)
    math.randomseed(os.time())
    local posY = 290 + math.random(-10, 30)

    return posX, posY
end