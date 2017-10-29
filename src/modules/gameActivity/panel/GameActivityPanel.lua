
GameActivityPanel = class("GameActivityPanel", BasicPanel)
GameActivityPanel.NAME = "GameActivityPanel"


GameActivityPanel.LEFT_ITEM_PATH_ENABLE     = "images/gameActivity/SpItem%d1.png"
GameActivityPanel.LEFT_ITEM_PATH_DISABLE    = "images/gameActivity/SpItem%d2.png"

GameActivityPanel.TOP_ITEM_PATH_ENABLE      = "bg/activity/titleOn%d.png"
GameActivityPanel.TOP_ITEM_PATH_DISABLE     = "bg/activity/title%d.png"

GameActivityPanel.TOP_BG_PATH_ENABLE        = "images/gameActivity/BtnTab2.png"
GameActivityPanel.TOP_BG_PATH_DISABLE       = "images/gameActivity/BtnTab1.png"

--艺术字标题
GameActivityPanel.RIGHT_ART_WORD_PATH       = "bg/activity/artIcon%d.png"

--礼包兑换两个渠道的图片
GameActivityPanel.TK_CHANNEL_PATH           = "bg/activity/3k.jpg"
GameActivityPanel.MR_CHANNEL_PATH           = "bg/activity/mr.jpg"
GameActivityPanel.EDITBOX_URL               = "images/gameActivity/changeBar.png"
GameActivityPanel.REDBG                     = "bg/activity/SpActiveBg.png"

--登录有礼 新的图片资源 同时保留旧资源
GameActivityPanel.LOGINPIC                  ="bg/activity/activity_Login.png"

function GameActivityPanel:ctor(view, panelName)
    GameActivityPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function GameActivityPanel:finalize()
    if self._btnEffect ~= nil then
        self._btnEffect:finalize()
        self._btnEffect = nil
    end

    if self._getBtnEff ~= nil then
        self._getBtnEff:finalize()
        self._getBtnEff = nil
    end

    if self._diaozhui ~= nil then
        self._diaozhui:finalize()
        self._diaozhui = nil
    end

    GameActivityPanel.super.finalize(self)
end

function GameActivityPanel:initPanel()
    GameActivityPanel.super.initPanel(self)

    self._proxy = self:getProxy(GameProxys.Activity)

    self:setTitle(true, "activity", true)
    self:setBgType(ModulePanelBgType.NONE)


    self._pnlLeft = self:getChildByName("pnlLeft")

    self._leftLv = self:getChildByName("pnlLeft/leftLv")
    self._imgZhuangShiBottom = self:getChildByName("pnlLeft/imgZhuangShiBottom")

    self._Panel_bg = self:getChildByName("Panel_bg")

    self._redBg = self._Panel_bg:getChildByName("imgRedBg")

    self._bgImgO = self:getChildByName("Panel_bg/bgImgO")
    self._bgImg10 = self:getChildByName("Panel_bg/bgImg10")
    self._bgImg20 = self:getChildByName("Panel_bg/bgImg20")

    self._centerBtn = self:getChildByName("Panel_bg/centerBtn")
    self._centerBtn.oldPosition = cc.p(self._centerBtn:getPosition())


    self._btnGo = self:getChildByName("Panel_bg/btnGo")--去历练专用



    self._topPnl = self:getChildByName("pnlTop")

    self._listviewTop = self._topPnl:getChildByName("listviewTop")

    self._allPanel = {
        ActivityTwoPanel.NAME,
        ActivityFourPanel.NAME,
        ActivityOnePanel.NAME,
        ActivityOnePanel.NAME,
        ActivityThreePanel.NAME,
        [8] = ActivityFivePanel.NAME,
        [13] = ActivityFivePanel.NAME,
        [19] = ActivitySixPanel.NAME
    }

    self._curBtn = nil --当前左边选择的btn
    self._curTopBtn = nil -- 当前上面选择的btn
        
    self._topActionItemMap = {}
end

function GameActivityPanel:registerEvents()
    GameActivityPanel.super.registerEvents(self)
end

function GameActivityPanel:doLayout()
    local bestTopPanel = self:topAdaptivePanel()

    --左
    -- NodeUtils:adaptiveTopPanelAndListView(self._pnlLeft, nil, nil, bestTopPanel, GlobalConfig.listViewRowSpace)
    NodeUtils:adaptiveUpPanel(self._pnlLeft,bestTopPanel,40)
    --左 listview的item有多长,size就有多长
    local size = self._leftLv:getContentSize()

    local pos = cc.p(self._leftLv:getPosition())
    local scaleX = self._leftLv:getScaleX()
    local scaleY = self._leftLv:getScaleY()

    local imgZhuangShiHead = self._pnlLeft:getChildByName("imgZhuangShiHead")
    imgZhuangShiHead:setPosition(pos.x + size.width/2*scaleX,self._leftLv:getPositionY() + size.height*scaleY)

    local count = self._leftLv:getChildrenCount()
    local lastItem = self._leftLv:getItem(count-1)
    local size = lastItem:getContentSize()
    local imgZhuangShiBottom = self._imgZhuangShiBottom        
    imgZhuangShiBottom:setPosition(size.width/2,0)
    imgZhuangShiBottom:setVisible(true)
    imgZhuangShiBottom:retain()
    imgZhuangShiBottom:removeFromParent()
    lastItem:addChild(imgZhuangShiBottom)
    imgZhuangShiBottom:release()

    if self._diaozhui == nil then
        self._diaozhui = self:createUICCBLayer("rgb-hd-diaozhui", imgZhuangShiBottom)
    end

    --上
    -- NodeUtils:adaptiveTopPanelAndListView(self._topPnl, nil, nil, bestTopPanel, 10)
    NodeUtils:adaptiveTopPanelAndListView(self._topPnl, nil, nil, GlobalConfig.topHeight3)

    --中
    local panel = self:getChildByName("Panel_bg")
    -- NodeUtils:adaptiveListView(panel, 10, bestTopPanel,10)
    NodeUtils:adaptiveTopPanelAndListView(panel, nil, nil, self._topPnl, 10)

end

function GameActivityPanel:onShowHandler(extraMsg)
    self:onUpdateActivity(extraMsg)
end

function GameActivityPanel:onUpdateActivity(extraMsg)
    -- 领取完奖励，刷新所有item的夹带数据
    local data = self._proxy:getActivityInfo()

    local flag = self._proxy:getDataById(99999)
    if not flag then
        local cdkActivity = { 
                                name = "兑换礼包", 
                                activityId = 99999, 
                                uitype = GameActivityModule.UI_TYPE_CDK, 
                                sort = 99999, 
                                reveal = 0 ,
                                artIcon = 53,
                                titleIcon = 53,
                                type = 4,
                            }
        if VersionManager:isShowCDKey() == true then
            -- ios cdk 审查
            table.insert(data, cdkActivity)
        end
    end

    local flag99998 = self._proxy:getDataById(99998)
    if not flag99998 then
        local openInfo = self._proxy:getWeekCardOpenInfo()
        --有周卡开放数据且等级足够才有周卡切页
        local roleproxy = self:getProxy(GameProxys.Role)
        local isOpen = roleproxy:isFunctionUnLock(54,false)
        if openInfo.id ~= -1 and isOpen == true then
        local weekCardActivity =    {   name = "周卡特供", 
                                        activityId = 99998, 
                                        uitype = GameActivityModule.UI_TYPE_ZHOU_KA,
                                        sort = 4, 
                                        reveal = 0,
                                        artIcon = 52,
                                        titleIcon = 52,
                                        type = 1,
                                    }
        table.insert(data, weekCardActivity)
        end
    end

    local btnData = { }
    for k, v in pairs(data) do
        -- 是否已领取完所有奖励
        if v.reveal == 0 then
            if rawget(v, "isHide") == true then
            else
            table.insert(btnData, v)
            end                
        end
    end

    ---[[TODO 策划表还没有到,先做住先
    self._btnDataFenLei = self:getBtnFenLei(btnData)
    btnDataFenLei = self._btnDataFenLei
    --]]
    

    -- 传入额外数据，获取id跳转
    local jumpToId = nil
    if extraMsg ~= nil then
        jumpToId = extraMsg.jumpToId
    end
    ----如果有跳转,则调到左第n个,上面第m个
    self._initItemIndex = {
        jumpLeft = 0;
        jumpTop = 0;
    }
    if jumpToId ~= nil then
        for leftIdx, activityContainer in pairs(btnDataFenLei) do
            for topIdx,activityConf in pairs(activityContainer) do
                if activityConf.activityId == jumpToId then
                    self._initItemIndex.jumpLeft = leftIdx - 1
                    self._initItemIndex.jumpTop = topIdx - 1
                    logger:info(string.format("欲跳转到活动标签(左,上):%d,%d",self._initItemIndex.jumpLeft,self._initItemIndex.jumpTop))
                end
            end
        end
    end

    --放置没有活动
    if #btnDataFenLei > 0 then
        -- self:renderListView(self._leftLv, btnData, self, self.renderAllLeftBtn, nil, true,0)
        self:renderListView(self._leftLv, btnDataFenLei, self, self.renderAllLeftBtn, nil, true,0)
        --点left listview 第0个位置
        self:leftBtnTouch(self._leftLv:getItem(self._initItemIndex.jumpLeft),true)
        
        --点击top listview 第0个位置
        self:updateTopListView(self._leftLv:getItem(self._initItemIndex.jumpLeft))
    end
    -- if self._listviewTop:getItem(self._initItemIndex) ~= nil then
    if #btnDataFenLei > 0  then
        --根据toplistview 第0个位置的数据 刷新右边pnl的ui
        self:updateRightView(self._listviewTop:getItem(self._initItemIndex.jumpTop), true)
    else
        -- 空，隐藏右边
        logger:info("初始化为空，隐藏右边显示")
        local panel = self:getChildByName("Panel_bg")
        panel:setVisible(false) 
    end
    --]]

    -- -- 判空，防止没有任何活动的情况
    -- if self._listviewTop:getItem(self._initItemIndex) ~= nil then
    --     -- self:updateRightView(self._leftLv:getItem(self._initItemIndex))
    --     self:updateRightView(self._listviewTop:getItem(self._initItemIndex))
    -- else
    --     -- 空，隐藏右边
    --     logger:info("初始化为空，隐藏右边显示")
    --     local panel = self:getChildByName("Panel_bg")
    --     panel:setVisible(false) 
    -- end
    local Panel_144 = self._bgImg10:getChildByName("Panel_144")
    if self._contentEditBox == nil then
        self._contentEditBox = ComponentUtils:addEditeBox(Panel_144,440,self:getTextWord(18008),nil,false,GameActivityPanel.EDITBOX_URL)
        self._contentEditBox:setCenterPlaceHolder(6)
    end

    local getBtn = self._bgImg10:getChildByName("getBtn")
    getBtn:setTitleText(TextWords:getTextWord(1111))
    if getBtn.isAdd ~= true then
        getBtn.isAdd = true
        local function callBack()
            if self._contentEditBox:getText() == "" then
                self:showSysMessage(TextWords:getTextWord(18018))
                return
            end
            self._proxy:onTriggerNet240000Req({cdkey = self._contentEditBox:getText()})
        end
        self:addTouchEventListener(getBtn,callBack)
    end

    local buyBtn = self._bgImg20:getChildByName("buyBtn")
    if buyBtn.isAdd ~= true then
        buyBtn.isAdd = true
        self:addTouchEventListener(buyBtn,self.weekCardBtnHandler,nil,nil,2000)
    end

    --//增加一个周卡续费的按钮
    local renewBtn = self._bgImg20:getChildByName("renewBtn")
    self:addTouchEventListener(renewBtn,self.weekCardBtnRenewHandler,nil,nil,2000)


    if self._getBtnEff == nil then
        self._getBtnEff = self:createUICCBLayer("rgb-daanniu-huang", getBtn)
    end
    local size = getBtn:getContentSize()
    self._getBtnEff:setPosition(size.width /2, size.height/2)

end

function GameActivityPanel:newCDKChange(key,bool)
    local bgImg=self:getChildByName("Panel_bg/imgRedBg")
    local downBar=bgImg:getChildByName("Image_50_0")
    local Image_50=bgImg:getChildByName("Image_50")
    local Image_53=bgImg:getChildByName("Image_53")
    TextureManager:updateImageViewFile(bgImg,GameActivityPanel.REDBG)
    --还原坐标
    Image_53:setPositionY(264)
    Image_50:setPositionY(262)
    downBar:setPositionY(0)
    if  not bool then
    return nil
    end

    if  FunctionWebManager:isFunctionOpen(FunctionWebConfig.MR_CHANNEL) then
    TextureManager:updateImageViewFile(bgImg,GameActivityPanel.MR_CHANNEL_PATH)
    Image_53:setPositionY(727)
    Image_50:setPositionY(725)
    --downBar:setPositionY(-723)
    else 
    TextureManager:updateImageViewFile(bgImg, GameActivityPanel.TK_CHANNEL_PATH)
    --downBar:setPositionY(-723)
    Image_53:setPositionY(727)
    Image_50:setPositionY(725)
    end
    --NodeUtils:adaptiveUpPanel(downBar, bgImg, 0)
end

function GameActivityPanel:getCurrentActivityId()

    local left = self._leftLv:getIndex(self._curBtn)
    local top = self._listviewTop:getIndex(self._curTopBtn)
    if left and top then
        left = left+1
        top = top+1
        if self._btnDataFenLei[left][top] then
            return self._btnDataFenLei[left][top].activityId
        end
    end
end

function GameActivityPanel:onUpdateAllData()
    local currentActivityId = self:getCurrentActivityId()
    local msg
    if currentActivityId then
        msg = {jumpToId = currentActivityId}
    end
    self:onUpdateActivity(msg)
end

function GameActivityPanel:renderAllLeftBtn(item, data, index)
    
    --传递数据
    local topItemData = {}
    for key,val in pairs(data) do
        if type(val) == type({}) then--由于data经过renderListview处理,会多出一个参数isUpdate
            table.insert(topItemData,val)
        end
    end
    item.topItemData = topItemData

    local btn = item:getChildByName("itemBtn")
    local activityName = item:getChildByName("name")
    local selectBg = item:getChildByName("bg")
    local imgWord = item:getChildByName("imgWord")
    local imgTop = item:getChildByName("imgTop")

    imgTop:setVisible(#self._btnDataFenLei ~= (index + 1))

    selectBg:setVisible(false)
    --默认黑色
    -- local disable_url = string.format(GameActivityPanel.LEFT_ITEM_PATH_DISABLE,data[1].type)
    -- --local able_url = string.format(GameActivityPanel.LEFT_ITEM_PATH_ENABLE,data[1].type)

    -- --if index == 0 then
    -- --    TextureManager:updateImageView(imgWord, able_url )
    -- --else
    --     TextureManager:updateImageView(imgWord, disable_url )
    -- --end
    self:setLeftTabEnable(item,false)


    self:addTouchEventListener(item, self.leftBtnTouch)

    --这是left的红点
    self:setItemRed(item, topItemData)

    --设置第一个为默认打开

    -- self:renderListView(self._listviewTop, data, self, self.renderAllTopBtn, nil, true,0)
    --[[
    item.data = data
    self.allItems[data.activityId] = item

    local btn = item:getChildByName("itemBtn")
    local activityName = item:getChildByName("name")
    local selectBg = item:getChildByName("bg")

    selectBg:setVisible(self._curBtn == item)
    local color = self._curBtn == item and ColorUtils.wordWhiteColor or ColorUtils.wordGreyColor
    activityName:setColor(color)
    activityName:setString(data.name)
    self:addTouchEventListener(item, self.leftBtnTouch)
    self:setItemRed(item, data)
    --]]
end

function GameActivityPanel:setLeftTabEnable(item, bool)
    if item then
        local data = item.topItemData

        local imgWord = item:getChildByName("imgWord")

        if bool then
            -- local disable_url = string.format(GameActivityPanel.LEFT_ITEM_PATH_ENABLE,data[1].test_type)
            local disable_url = string.format(GameActivityPanel.LEFT_ITEM_PATH_ENABLE,data[1].type)
            TextureManager:updateImageView(imgWord, disable_url )
        else
            -- local disable_url = string.format(GameActivityPanel.LEFT_ITEM_PATH_DISABLE,data[1].test_type)
            local disable_url = string.format(GameActivityPanel.LEFT_ITEM_PATH_DISABLE,data[1].type)
            TextureManager:updateImageView(imgWord, disable_url )
        end
    else
        logger:error("item 为 nil")
    end
end


function GameActivityPanel:setTopTabEnable(topTabItem,bool)
    if topTabItem then
        local data = topTabItem.data
        local titleIcon = rawget(data,"titleIcon")

        local imgBg = topTabItem:getChildByName("imgBg")
        local imgName = topTabItem:getChildByName("imgName")
        local labTextName = topTabItem:getChildByName("labTextName")
        if bool then
            TextureManager:updateImageView(imgBg, GameActivityPanel.TOP_BG_PATH_ENABLE )
            if titleIcon and titleIcon ~= 0 then
                imgName:setVisible(true)
                labTextName:setVisible(false)
                TextureManager:updateImageViewFile(imgName, 
                        string.format(GameActivityPanel.TOP_ITEM_PATH_ENABLE,data.titleIcon))
            else
                imgName:setVisible(false)
                labTextName:setVisible(true)
            end
        else
            TextureManager:updateImageView(imgBg, GameActivityPanel.TOP_BG_PATH_DISABLE )
            if titleIcon and titleIcon ~= 0 then
                imgName:setVisible(true)
                labTextName:setVisible(false)
                TextureManager:updateImageViewFile(imgName, 
                        string.format(GameActivityPanel.TOP_ITEM_PATH_DISABLE,data.titleIcon))
            else
                imgName:setVisible(false)
                labTextName:setVisible(true)
            end
        end
    end
end

function GameActivityPanel:getBtnFenLei(btnData)
    ---[[TODO 策划表还没有到,先做住先

    --兼容性处理
    if btnData[1].type == nil or btnData[1].type == 0 then
        for key,val in pairs(btnData) do
            val.type = key%4+1
            logger:info(val.type)
        end
    end

    --二次处理 要把活动分成N类
    -- local btnDataFenLei = {}
    -- for key,val in pairs(btnData) do
    --     if val.test_type then
    --         if btnDataFenLei[val.test_type] == nil then
    --             btnDataFenLei[val.test_type] = {}
    --         end
    --         table.insert(btnDataFenLei[val.test_type],val)
    --     else
    --         logger:error("策划没有配置类型,设置默认为1")
    --         if btnDataFenLei[val.test_type] == nil then
    --             btnDataFenLei[val.test_type] = {}
    --         end
    --         table.insert(btnDataFenLei[1],val)
    --     end
    -- end


    local btnDataFenLei = {}
    for key,val in pairs(btnData) do
        if val.type then
            if btnDataFenLei[val.type] == nil then
                btnDataFenLei[val.type] = {}
            end
            table.insert(btnDataFenLei[val.type],val)
        else
            logger:error("策划没有配置类型,设置默认为1")
            if btnDataFenLei[val.type] == nil then
                btnDataFenLei[val.type] = {}
            end
            table.insert(btnDataFenLei[1],val)
        end
    end

    --放置中间断层
    local max = 0
    for key,val in pairs(btnDataFenLei) do
        max = math.max(max,key)
    end

    local tmp = {}

    for key,val in pairs(btnDataFenLei) do
        table.insert(tmp,val)
    end

    table.sort(tmp,function(a,b)
        return a[1].type < b[1].type
    end)

    --排序,根据sort字段排序
    for key,val in pairs(tmp) do
        table.sort(val,function(a,b)
            return a.sort < b.sort
        end)
    end

    return tmp

    --for i = max,1,-1 do 
    --    if btnDataFenLei[i] == nil then
    --        btnDataFenLei[i] = 0 --当table的值为nil的时候,是不会remove的
    --        table.remove(btnDataFenLei,i)
    --    end
    --end

    --排序,根据sort字段排序
    --for key,val in pairs(btnDataFenLei) do
    --    table.sort(val,function(a,b)
    --        return a.sort < b.sort
    --    end)
    --end
    --]]
    --return btnDataFenLei
end


function GameActivityPanel:topBtnTouch(sender)
    if self._curTopBtn == sender then 
        return
    end

    self:updateTopButton(sender)


end


function GameActivityPanel:updateTopButton(sender)

    --更新top item 背景图
    --[[
    local function showBg(visible)
        local imgBg = self._curTopBtn:getChildByName("imgBg")

        if visible then
            TextureManager:updateImageView(imgBg, GameActivityPanel.TOP_BG_PATH_ENABLE )
        else
            TextureManager:updateImageView(imgBg, GameActivityPanel.TOP_BG_PATH_DISABLE )
        end
    end

    local data = sender.data

    if self._curTopBtn ~= nil then
        showBg(false)
    end
    self._curTopBtn = sender
    showBg(true)
    --]]
    --更新具体内容
    self:updateRightView(sender, true)
end


function GameActivityPanel:getItemRedNum(data)
    local buttons = data.buttons
    local effectInfos = data.effectInfos
    local uitype = data.uitype
    local count = 0
    if effectInfos ~= nil then
        for k, v in pairs(effectInfos) do
            if v.iscanget == 1 then
                count = count + 1
            end
        end
    end

    if buttons ~= nil and uitype ~= 2 then
        -- uitype=2 建国基金跳过
        for k, v in pairs(buttons) do
            if v.type == 2 then
                count = count + 1
            end
        end
    end
    --周卡特殊处理领取数量
    if uitype == GameActivityModule.UI_TYPE_ZHOU_KA then
        local cardState = self._proxy:getWeekCardState()
        if cardState == 0 then
            return 1
        end
    end

    return count
end
--左left listview 使用
function GameActivityPanel:setItemRed(item, data)

	local count = 0
	for key, val in pairs(data) do
		local tmp = self:getItemRedNum(val)
		count = count + tmp
		--- print("val.titleIcon "..val.titleIcon)
		if val.titleIcon == 53 then
			-- CDK兑换特殊处理
			local redProxy = self:getProxy(GameProxys.RedPoint)
			if redProxy._isFirst then
				count = count + 1
				-- print("第一次 登录 模块")
			end
		end
	end

	local dotBg = item:getChildByName("dotBg")
	if count == 0 then
		dotBg:setVisible(false)
	else
		dotBg:setVisible(true)
	end

	if count ~= 0 then
		local dot = dotBg:getChildByName("dot")
		dot:setString(count)
	end


	--[[
    local buttons = data.buttons
    local effectInfos = data.effectInfos
    local uitype = data.uitype
    local count = 0
    if effectInfos ~= nil then
        for k, v in pairs(effectInfos) do
            if v.iscanget == 1 then
                count = count + 1
            end
        end
    end

    if buttons ~= nil and uitype ~= 2 then
        -- uitype=2 建国基金跳过
        for k, v in pairs(buttons) do
            if v.type == 2 then
                count = count + 1
            end
        end
    end

    local dotBg = item:getChildByName("dotBg")
    dotBg:setVisible(count ~= 0)
    if count ~= 0 then
        local dot = dotBg:getChildByName("dot")
        dot:setString(count)
    end
    --]]
end

--上listview 使用
function GameActivityPanel:setTopItemRed(item, data)

    local count = self:getItemRedNum(data)
    print("data.titleIcon"..data.titleIcon)
    if data.titleIcon == 53 then
            -- CDK兑换特殊处理
			local redProxy = self:getProxy(GameProxys.RedPoint)
			if redProxy._isFirst then
				count = count + 1
				-- print("第一次 登录 模块")
			end
    end
    local dotBg = item:getChildByName("dotBg")
    if count == 0 then
        dotBg:setVisible(false)
    else
        dotBg:setVisible(true)
    end

    if count ~= 0 then
        local dot = dotBg:getChildByName("dot")
        dot:setString(count)
    end

end
--@param isForce:强行点击按钮(第一次初始化)
function GameActivityPanel:leftBtnTouch(sender,isForce)
    if not isForce and self._curBtn == sender then
        return
    end

    local imgWord = sender:getChildByName("imgWord")

    --更新左listview的item 背景
    local function showBg(visible)
        local bg = self._curBtn:getChildByName("bg")
        bg:setVisible(visible)

        local a1 = cc.ScaleTo:create(0.1, 1.02)
        local a2 = cc.ScaleTo:create(0.1, 1)
        local seq = cc.Sequence:create(a1, a2)
        bg:stopAllActions()
        bg:runAction(seq)
    end

    local data = sender.topItemData


    if self._curBtn ~= nil then
        showBg(false)
        self:setLeftTabEnable(self._curBtn,false)
    end
    self._curBtn = sender
    showBg(true)

    --更新左listview的item的艺术字
    self:setLeftTabEnable(sender,true)

    -- 转个弯，因为第一次打开界面一定要刷新界面，所以不走上面的判断
    -- self:updateRightView(sender)

    --防止第一次初始化两次
    if not isForce then
        self:updateTopListView(sender)
        self:updateRightView(self._listviewTop:getItem(0), true)
    end

end


function GameActivityPanel:updateTopListView(sender, noJump)

    -- 更新 上listview的item
    local topItemData = sender.topItemData

    self._listviewTop:jumpToLeft()
    self:renderListView(self._listviewTop, topItemData, self, self.renderAllTopBtn, nil, true, 10)

    -- 顶部列表动作
    self:runTopAction()
end

function GameActivityPanel:renderAllTopBtn(item, data, index)
    
    item.data = data
    --更新top item 艺术字
    -- local imgName = item:getChildByName("imgName")
    local labTextName = item:getChildByName("labTextName")
    -- local imgBg = item:getChildByName("imgBg")
    local imgTopRedBg = item:getChildByName("imgTopRedBg")
    local imgTopRedBg_num = item:getChildByName("num")

    -- local url = string.format("bg/activity/TxtTop11.png")--图片还没有确定的命名好 先默认用首冲

    -- TextureManager:updateImageView(imgName, url )
    --底板是否高亮
    if index == 0 then
        -- TextureManager:updateImageView(imgBg, GameActivityPanel.TOP_BG_PATH_ENABLE )
        self:setTopTabEnable(item,true)
        -- self:setTopTabTitleEnable(item,true,data)
    else
        -- TextureManager:updateImageView(imgBg, GameActivityPanel.TOP_BG_PATH_DISABLE )
        self:setTopTabEnable(item,false)
        -- self:setTopTabTitleEnable(item,false,data)
    end

    self:addTouchEventListener(item, self.topBtnTouch)
    --测试名字
    labTextName:setString(data.name)
    --红点
    self:setTopItemRed(item, data)

end

function GameActivityPanel:runTopAction()

    -- 暂定5个吧
    local viewSize = self._listviewTop:getContentSize()
    local inner = self._listviewTop:getInnerContainer()
    local innerPosX = inner:getPositionX()

    local items = self._listviewTop:getItems()
    for i = 1, #items do
        item = items[i]
        if item:getPositionX() < viewSize.width then
            local d1 = cc.DelayTime:create(0.05 * i)
            local a1 = cc.ScaleTo:create(0.1, 1, 0)
            local a2 = cc.ScaleTo:create(0.1, 1, 1)
            local seq = cc.Sequence:create(d1, a1, a2)

            item:setAnchorPoint(0.5, 0.5)
            item:stopAllActions()
            item:runAction(seq)
        else
            return
        end
    end
end


function GameActivityPanel:updateRightView(sender, noJump)
    -- 如果原先被隐藏，则重新显示出来
    local panelBg = self:getChildByName("Panel_bg")
    if not panelBg:isVisible() then
        panelBg:setVisible(true)
    end

    local bg = self._curBtn:getChildByName("bg")
    if self._btnEffect == nil then        
        local btnSize = bg:getContentSize()
        self._btnEffect = self:createUICCBLayer("rgb-hd-denglong", bg)
        self._btnEffect:setPosition(btnSize.width / 2, btnSize.height / 2)
    else
        self._btnEffect:changeParent(bg)
    end

    self._btnEffect:setLocalZOrder(20)

    local data = sender.data

    logger:info("ActivityId == " .. data.activityId)

    if self._curTopBtn ~= nil then
        -- showBg(false)
        self:setTopTabEnable(self._curTopBtn, false)
    end
    -- self._curBtn = sender
    self._curTopBtn = sender
    -- showBg(true)
    self:setTopTabEnable(self._curTopBtn, true)

    self._bgImg10:setVisible(data.uitype == 10)
    --if self._bgImg10:isVisible() == true then
    --self:newCDKChange(nil,true)
    --else
    --self:newCDKChange(nil,false)
    --end

    self._bgImg20:setVisible(data.uitype == GameActivityModule.UI_TYPE_ZHOU_KA)
    if data.uitype == GameActivityModule.UI_TYPE_ZHOU_KA then
        if self._bgImg20.bg == nil then
            self._bgImg20.bg = self._bgImg20:getChildByName("bgImg")
            local url = "bg/activity/weekCardBg.jpg"
            TextureManager:updateImageViewFile(self._bgImg20.bg, url)
        end

        local openInfo = self._proxy:getWeekCardOpenInfo()
        if openInfo.id ~= -1 then
            -- 活动开放了
            local rewardArr = StringUtils:jsonDecode(openInfo.dayReward)
            local materialDataTable = rewardArr
            local roleProxy = self:getProxy(GameProxys.Role)
            local rewardPanel = self._bgImg20:getChildByName("rewardPanel")
            local remainLab = self._bgImg20:getChildByName("remainLab")
            local staticLab = self._bgImg20:getChildByName("staticLab")
            local buyBtn = self._bgImg20:getChildByName("buyBtn")
            local renewBtn = self._bgImg20:getChildByName("renewBtn")        
            for i = 1, 2 do
                local iconData = { }
                iconData.typeid = rewardArr[i][2]
                iconData.num = rewardArr[i][3]
                iconData.power = rewardArr[i][1]

                local img = rewardPanel:getChildByName("img" .. i)
                if img.uiIcon == nil then
                    img.uiIcon = UIIcon.new(img, iconData, true, self, nil, true)
                else
                    img.uiIcon:updateData(iconData)
                end
            end

            local cardInfo = self._proxy:getWeekCardInfo()

            --// 领取 x 267 已领取 x 380
            if cardInfo.id ~= -1 then
                -- 买过周卡，有剩余次数数据
                remainLab:setVisible(true)
                staticLab:setVisible(true)
                remainLab:setString(string.format(self:getTextWord(18010), cardInfo.remainTimes))

                local cardState = self._proxy:getWeekCardState()
                if cardState == 1 then
                    -- 今天已经领过了
                    NodeUtils:setEnable(buyBtn, false)
                    buyBtn:setTitleText(TextWords:getTextWord(18013))
                    buyBtn:setPositionX(380)
                    renewBtn:setVisible(true)
                else
                    -- 今天可以领取
                    NodeUtils:setEnable(buyBtn, true)
                    buyBtn:setTitleText(TextWords:getTextWord(18012))
                    buyBtn:setPositionX(380)
                    renewBtn:setVisible(true)

                end
            else
                -- 没买过周卡，无购买次数数据，但周卡活动开放了
                remainLab:setVisible(false)
                staticLab:setVisible(false)
                local config = ConfigDataManager:getConfigById(ConfigData.ChargeCardConfig, openInfo.id)
                local amount = config.limit
                NodeUtils:setEnable(buyBtn, true)
                renewBtn:setVisible(false)
                buyBtn:setTitleText(string.format(TextWords:getTextWord(18011), amount))
            end
        end


    end
    self._bgImgO:setVisible((data.uitype <= 9 and data.uitype >= 3) or data.uitype == 13 or data.uitype == 19  )
 
    -- uitype为4的时候，要显示进度条
    self:setBarPercent(data)



    -- 更新下面中间的按钮
    self:updateCenterBtn(data)

    -- 点其他按钮隐藏界面
    if self._oldPanel ~= nil and self._oldUitype ~= data.uitype and self._oldPanel.NAME ~= self.NAME then
        self._oldPanel:hide()
    end

    local panel = self:getShowPanel(data.uitype)
    if panel ~= nil then
        self._oldPanel = panel
        if type(panel.jumpToStart) == "function" then
            if noJump == true then
                panel:jumpToStart(1)
            else
                panel:jumpToStart(nil)
            end
        end

        if type(panel.updateView) == "function" then
            panel:show()
            panel:updateView(data)
            local bgImg = self:getChildByName("Panel_bg/imgRedBg")
            TextureManager:updateImageViewFile(bgImg, GameActivityPanel.REDBG )
        else
            panel:show(data)
        end
    end

    -- 根据uitype需要来更新上面面板的信息
    self:setRedBgVisible(true)
    if (data.uitype <= 9 and data.uitype >= 3) or data.uitype == 13 or data.uitype == 19 then
        self:updateTopView(data)
    elseif data.uitype == GameActivityModule.UI_TYPE_CDK then
        -- 兑换
        self:updateArtWord(data, true)
    elseif data.uitype == GameActivityModule.UI_TYPE_SHOU_CHONG then
        self:setRedBgVisible(false)
    elseif data.uitype == GameActivityModule.UI_TYPE_ZHOU_KA then
        self:setRedBgVisible(false)
    end

    self._oldUitype = data.uitype
    

end


function GameActivityPanel:setRedBgVisible(bool)
    self._redBg:setVisible(bool)
end

function GameActivityPanel:onClosePanelHandler()
    self._leftLv:jumpToTop()
    if self._curBtn ~= nil then
        local bg = self._curBtn:getChildByName("bg")
        bg:setVisible(false)
    end
    self._curBtn = nil
    local items = self._leftLv:getItems()
    if #items > 0 then
        self:leftBtnTouch(items[1])
    end
    self:dispatchEvent(GameActivityEvent.HIDE_SELF_EVENT)
end

function GameActivityPanel:getShowPanel(uitype)
    if self._allPanel == nil then
        self._allPanel = {
            ActivityTwoPanel.NAME,ActivityFourPanel.NAME,ActivityOnePanel.NAME,ActivityOnePanel.NAME,
            ActivityThreePanel.NAME,
            [8] = ActivityFivePanel.NAME,
            [13] = ActivityFivePanel.NAME,
            [19] = ActivitySixPanel.NAME
        }
    end
    local name = self._allPanel[uitype]
    if name == nil then
        return
    end
    return self:getPanel(name)
end


function GameActivityPanel:updateArtWord(data, isHide)
	local artic = self._bgImgO:getChildByName("artic")
	local url = string.format(GameActivityPanel.RIGHT_ART_WORD_PATH, data.artIcon)
	if data.artIcon ~= 0 then
		TextureManager:updateImageViewFile(artic, url)
	end

    local redProxy = self:getProxy(GameProxys.RedPoint)
    if data.artIcon == 53 and redProxy._isFirst then
        redProxy._isFirst = false
        local actData={}
        actData.activityId = 99999
        self:onUpdateOnceData(actData)
        redProxy:checkActivityRedPoint()
    end

	-- //加一个新的登录有礼界面 如果是 替换界面  如果不是 返回原来的替换 特殊处理
    local bgImg = self:getChildByName("Panel_bg/imgRedBg")
    --TextureManager:updateImageViewFile(bgImg, GameActivityPanel.REDBG )
    if FunctionWebManager:isFunctionOpen(FunctionWebConfig.MR_CHANNEL) then
        print("联运渠道")
        if data.uitype ==  10 then
        self:newCDKChange(nil,true)
        else
        self:newCDKChange(nil,false)
        end
        return nil
    end
	print("###############------跳转" .. data.artIcon)

	local info = self._bgImgO:getChildByName("info")
   
    local Image_53=self._bgImgO:getChildByName("Image_53")
	if data.artIcon == 28 then
        TextureManager:updateImageViewFile(bgImg, GameActivityPanel.LOGINPIC)
		artic:setVisible(false)
		info:setVisible(false)
        Image_53:setVisible(false)
	else
		artic:setVisible(true)
		info:setVisible(true)
        Image_53:setVisible(true)
        TextureManager:updateImageViewFile(bgImg, GameActivityPanel.REDBG )

        if data.uitype ==  10 then
        self:newCDKChange(nil,true)
        end
	end

end

-- 3和4的顶部信息区域的区别只是进度条
-- 3和4的时候要刷新
function GameActivityPanel:updateTopView(data)
    local artic = self._bgImgO:getChildByName("artic")
    -- url = "bg/activity/artIcon" .. data.artIcon .. TextureManager.bg_type
    -- local url = string.format(GameActivityPanel.RIGHT_ART_WORD_PATH,data.artIcon)
    -- if data.artIcon ~= 0 then
    --     -- TextureManager:updateImageViewFile(artic, url)
    --     TextureManager:updateImageViewFile(artic, url)
    -- end
    self:updateArtWord(data)

    -- local title = self._bgImgO:getChildByName("title")
    -- -- 日期下方的小标题
    -- title:setString(data.title)

    local info = self._bgImgO:getChildByName("info")
    info:setString(data.info)

    local stratTime = self._bgImgO:getChildByName("stratTime")
    local endTime = self._bgImgO:getChildByName("endTime")
    local timeLabel = self._bgImgO:getChildByName("timeLabel")

    -- 永久时限(-1,-1) 不显示
    stratTime:setVisible(data.startTime > 0 and data.endTime > 0)
    timeLabel:setVisible(data.startTime > 0 and data.endTime > 0)
    endTime:setVisible(data.startTime > 0 and data.endTime > 0)


    if data.startTime > 0 and data.endTime > 0 then
        local timeStr = TimeUtils:setTimestampToString(data.startTime)
        stratTime:setString(timeStr .. " - ")
        timeStr = TimeUtils:setTimestampToString(data.endTime)
        endTime:setString(timeStr)

        local posx = stratTime:getPositionX()
        local size = stratTime:getContentSize()
        endTime:setPositionX(posx + size.width)
    end

    -- 纯文本类型  照搬以前逻辑
    local getInfo = self._bgImgO:getChildByName("getInfo")
    getInfo:setVisible(data.uitype == 6)
    if self._richLab ~= nil then
        self._richLab:setVisible(data.uitype == 6)
    end

    local function addRichText()
        if self._richLab == nil then
            self._richLab = ComponentUtils:createRichLabel("", nil, nil, 2)
            self._richLab:setPosition(getInfo:getPosition())
            getInfo:getParent():addChild(self._richLab)
        end
        self._richLab:setString(data.text)
    end

    if data.uitype == 6 and type(data.text) == "string" then
        data.text = StringUtils:splitString(data.text, "@")
        -- @换行标记
        for k, v in pairs(data.text) do
            v = self:StringRemove(v, "'")
            -- 删除单引号
            v = StringUtils:splitString(v, ";")
            -- 分号；同一行拼接
            for i, j in pairs(v) do
                j = StringUtils:splitString(j, ",")
                -- 逗号，属性切割
                v[i] = j
            end
            data.text[k] = v
        end

        addRichText()
    elseif data.uitype == 6 and type(data.text) == "table" then
        addRichText()
    end

end

function GameActivityPanel:getTopPanel()
    return self._bgImgO
end

function GameActivityPanel:getBestPanel()
    return self:topAdaptivePanel()
end

function GameActivityPanel:getTopListView()
    return self._listviewTop
end
--红色背景
function GameActivityPanel:getMidBg()
    return self._Panel_bg
end

-- 删除字符串的字符
function GameActivityPanel:StringRemove(str, remove)
    local lcSubStrTab = { }
    while true do
        local lcPos = string.find(str, remove)
        if not lcPos then
            lcSubStrTab[#lcSubStrTab + 1] = str
            break
        end
        local lcSubStr = string.sub(str, 1, lcPos - 1)
        lcSubStrTab[#lcSubStrTab + 1] = lcSubStr
        str = string.sub(str, lcPos + 1, #str)
    end
    local lcMergeStr = ""
    local lci = 1
    while true do
        if lcSubStrTab[lci] then
            lcMergeStr = lcMergeStr .. lcSubStrTab[lci]
            lci = lci + 1
        else
            break
        end
    end
    return lcMergeStr
end

-- 通用跳转函数
function GameActivityPanel:commonJumpMethod(buttons)
    local isJumped
    if buttons.jumpPanel == "" then
        isJumped = ModuleJumpManager:jump(buttons.jump)
    else
        isJumped = ModuleJumpManager:jump(buttons.jump, buttons.jumpPanel)
    end
    if isJumped then
        self:onClosePanelHandler()
    end
end

function GameActivityPanel:updateCenterBtn(data)

    self._centerBtn:setVisible(false)
    if data.uitype == GameActivityModule.UI_TYPE_CHUN_WEN_ZI then
        self._btnGo:setVisible(true)
    else
        self._btnGo:setVisible(false)
    end

    self._btnGo.data = data
    self:addTouchEventListener(self._btnGo, self.centerBtnTouch)
    if type(data.buttons) == "table" then
        local buttons = data.buttons[1]
        if buttons ~= nil then
            self._btnGo:setTitleText(buttons.name)
        else
            self._btnGo:setVisible(false)
        end
    else
        self._btnGo:setVisible(false)
    end

end

function GameActivityPanel:centerBtnTouch(sender)
    if type(sender.data.buttons) ~= "table" then
        return
    end
    local buttons = sender.data.buttons[1]
    if buttons.type == 1 then
        self:commonJumpMethod(buttons)
    end
end

--刷新左边listview
--刷新上边listview
--刷新当前显示pnl的内容
function GameActivityPanel:onUpdateOnceData(data)


    -- 领取完奖励，刷新所有item的夹带数据
    local allData = self._proxy:getActivityInfo()
    local isLeftLVToTop = false
    local btnData = { }
    for k, v in pairs(allData) do
        repeat
            -- 特殊的首冲礼包领取完
            if v.uitype == GameActivityModule.UI_TYPE_SHOU_CHONG and v.conditiontype == 101 then
                if v.buttons[1].type == 3 then    
                    if data.activityId == v.activityId then
                        isLeftLVToTop = true
                    end               			
                    break
                end
            end

            -- 是否已领取完所有奖励
            if v.reveal == 0 then
                if rawget(v, "isHide") == true then
                    if data.activityId == v.activityId then
                        isLeftLVToTop = true
                    end
                else
                    table.insert(btnData, v)
                end                
            end
        until (true)
    end



    -- self.allItems = { }

    self._btnDataFenLei = self:getBtnFenLei(btnData)
    btnDataFenLei = self._btnDataFenLei
    
    --重新初始化 left listview
    -- self:renderListView(self._leftLv, btnData, self, self.renderAllLeftBtn)
    self:renderListView(self._leftLv, btnDataFenLei, self, self.renderAllLeftBtn)
    -- if self.allItems[data.activityId] ~= nil then
    --     self.allItems[data.activityId].data = data
    -- end
    --强行刷新left listview 按钮
    self:leftBtnTouch(self._curBtn,true)


    --重新初始化 top listview
    -- local topItemData = self._curBtn.topItemData
    -- self:renderListView(self._listviewTop, topItemData, self, self.renderAllTopBtn, nil, true,0)
    --刷新top listview 按钮
    self:updateTopListView(self._curBtn)


    --由于重新初始化top listview 默认为点击位置0 
    self:setTopTabEnable(self._listviewTop:getItem(0),false)
    self:setTopTabEnable(self._curTopBtn,true)

    --刷新右pnl
--    local isJumpToStart = nil
--    local data = self._curTopBtn.data
--    local name = self._allPanel[data.uitype]
--    local rewardFlag = self._proxy:getRewardFlag()
--    if name and name == ActivityFivePanel.NAME and rewardFlag == true then
--        isJumpToStart = true
--    end
    self:updateRightView(self._curTopBtn, false--[[isJumpToStart]])

end

function GameActivityPanel:setBarPercent(data)
    local bar = self._bgImgO:getChildByName("Image_187")
    bar:setVisible(data.uitype == 4)
    if data.uitype == 4 then
        local toolBar = bar:getChildByName("toolBar")
        local count = bar:getChildByName("count")
        local count_L = bar:getChildByName("count_L")
        local count_R = bar:getChildByName("count_R")
        local percent = 100 * data.already / data.total > 100 and 100 or 100 * data.already / data.total
        toolBar:setPercent(percent)
        count:setString(data.already)
        count_R:setString(string.format(self:getTextWord(1334), data.total))

        -- 文本对齐
        local toolBarX = toolBar:getPositionX()
        local size0 = count_L:getContentSize()
        local size1 = count:getContentSize()
        local size2 = count_R:getContentSize()
        local allLen = size0.width + size1.width + size2.width
        local x0 = toolBarX - allLen / 2
        local x1 = x0 + size0.width
        local x2 = x1 + size1.width

        count_L:setPositionX(x0)
        count:setPositionX(x1)
        count_R:setPositionX(x2)
    end
end

-- 公共请求230001领取奖励或者购买限购
function GameActivityPanel:commonMethod(activityId, effectId, sort, isBig, isBuy)
    local sendData = { }
    sendData.activityId = activityId
    sendData.effectId = effectId
    sendData.sort = sort
    self._proxy:onTriggerNet230001Req(sendData, sort, isBig, isBuy)
end

-- 公共请求230001领取奖励或者购买限购
function GameActivityPanel:commonMethodThree(activityId, effectId, sort, index, isBig, isBuy)
    local sendData = { }
    sendData.activityId = activityId
    sendData.effectId = effectId
    sendData.sort = sort
    self._proxy:onTriggerNet230001Req(sendData, index, isBig, isBuy)
end
function GameActivityPanel:weekCardBtnHandler(sender)
    logger:info("点击充值周卡")
    local openInfo = self._proxy:getWeekCardOpenInfo()
    if openInfo.id ~= -1 then
            local cardInfo = self._proxy:getWeekCardInfo()
            if cardInfo.id ~= -1 then
                --买过周卡，有剩余次数数据,请求领取今日奖励
                self._proxy:onTriggerNet490001Req({id = openInfo.id})
            else
                --没买过周卡，无购买次数数据，请求购买充值卡
                self._proxy:onTriggerNet490000Req({id = openInfo.id})
            end
    else
        logger:error("weekCard id error")
    end
end

--弃用 直接用原来的周卡充值 替代续费
function GameActivityPanel:weekCardBtnRenewHandler(sender)
    logger:info("点击周卡续费")
    local openInfo = self._proxy:getWeekCardOpenInfo()
    if openInfo.id ~= -1 then
            local cardInfo = self._proxy:getWeekCardInfo()
            self._proxy:onTriggerNet490000Req({id = openInfo.id})
    else
        logger:error("weekCard id error")
    end
end
--通知调用SDK充值
function GameActivityPanel:onOpenSDKWeekCard(id)
    local config = ConfigDataManager:getConfigById(ConfigData.ChargeCardConfig,id)
    local amount = config.limit
    local chargeType = config.chargeType
    SDKManager:charge(amount, chargeType)
end
--周卡数据刷新（ChargeCardOpenInfo 刷新）
function GameActivityPanel:onWeekCardUpdate(data)
    local isShow = self._bgImg20:isVisible()
    if isShow == true then
        local openInfo = self._proxy:getWeekCardOpenInfo()
        if openInfo.id ~= -1 then
            --活动开放了
            local rewardArr = StringUtils:jsonDecode(openInfo.dayReward)
            local materialDataTable = rewardArr
            local roleProxy = self:getProxy(GameProxys.Role)
            local rewardPanel = self._bgImg20:getChildByName("rewardPanel")
            local remainLab = self._bgImg20:getChildByName("remainLab")
            local staticLab = self._bgImg20:getChildByName("staticLab")
            local buyBtn = self._bgImg20:getChildByName("buyBtn")
            local renewBtn = self._bgImg20:getChildByName("renewBtn")        
            for i=1,2 do
                local iconData = {}
                iconData.typeid = rewardArr[i][2]
                iconData.num = rewardArr[i][3]
                iconData.power = rewardArr[i][1]

                local img = rewardPanel:getChildByName("img" .. i)
                if img.uiIcon == nil then
                    img.uiIcon = UIIcon.new(img, iconData, true, self, nil, true)
                else
                    img.uiIcon:updateData(iconData)
                end
            end

            local cardInfo = self._proxy:getWeekCardInfo()
            if cardInfo.id ~= -1 then
                --买过周卡，有剩余次数数据
                remainLab:setVisible(true)
                staticLab:setVisible(true)
                remainLab:setString(string.format(self:getTextWord(18010), cardInfo.remainTimes) )
                local cardState = self._proxy:getWeekCardState()
                if cardState == 1 then
                    --今天已经领过了
                    NodeUtils:setEnable(buyBtn, false)
                    buyBtn:setTitleText(TextWords:getTextWord(18013))
                    buyBtn:setPositionX(380)
                    renewBtn:setVisible(true)
                else
                    --今天可以领取
                    NodeUtils:setEnable(buyBtn, true)
                    buyBtn:setTitleText(TextWords:getTextWord(18012))
                    buyBtn:setPositionX(380)
                    renewBtn:setVisible(true)

                end
            else
                --没买过周卡，无购买次数数据，但周卡活动开放了
                remainLab:setVisible(false)
                staticLab:setVisible(false)
                local config = ConfigDataManager:getConfigById(ConfigData.ChargeCardConfig,openInfo.id)
                local amount = config.limit
                NodeUtils:setEnable(buyBtn, true)
                renewBtn:setVisible(false)
                buyBtn:setPositionX(267)
                buyBtn:setTitleText(string.format( TextWords:getTextWord(18011), amount))
            end
        end
    end
    local actData = {}
    actData.activityId = 99998
    self:onUpdateOnceData(actData)
end


