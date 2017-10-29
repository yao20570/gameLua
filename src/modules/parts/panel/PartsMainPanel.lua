PartsMainPanel = class("PartsMainPanel", BasicPanel)
PartsMainPanel.NAME = "PartsMainPanel"



PartsMainPanel.ref_url = {
    string.format("bg/barrack/Parts_dao.png")  ,
    string.format("bg/barrack/Parts_qi.png")  ,
    string.format("bg/barrack/Parts_qiang.png")  ,
    string.format("bg/barrack/Parts_gong.png")   , 
}



function PartsMainPanel:ctor(view, panelName)
    PartsMainPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function PartsMainPanel:finalize()
    local touchLayer = self:getChildByName("pagePanel")
    if touchLayer.listenner ~= nil then
        local eventDispatcher = touchLayer:getEventDispatcher()
        eventDispatcher:removeEventListenersForTarget(touchLayer)
        touchLayer.listenner = nil
    end

    if self.leftEct ~= nil then
        self.leftEct:finalize()
        self.leftEct = nil
    end

    if self.rightEct ~= nil then
        self.rightEct:finalize()
        self.rightEct = nil
    end

    
    TimerManager:remove(self.removeMask, self)


    PartsMainPanel.super.finalize(self)
    
end

function PartsMainPanel:initPanel()
    PartsMainPanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true, "parts", true)
    --pageView控件
    self._index = 1 -- 初始化的页面

    self.allPos = {}
    self.allPos[1] = {0, 620, 1240, -620}
    self.allPos[2] = {-620, 0, 620, 1240}
    self.allPos[3] = {1240, -620, 0, 620}
    self.allPos[4] = {620, 1240, -620, 0}
    -- end

    self._partsProxy = self:getProxy(GameProxys.Parts)
    --     --页面选中标记
    self._mainPanel = self:getChildByName("pagePanel")
    self._pageSelectImg = self:getChildByName("Panel_pageTag/Image_pageSelect")
    local pageTagImg1 = self:getChildByName("Panel_pageTag/Image_page_1")
    local pageTagImg2 = self:getChildByName("Panel_pageTag/Image_page_2")
    local pageTagImg3 = self:getChildByName("Panel_pageTag/Image_page_3")
    local pageTagImg4 = self:getChildByName("Panel_pageTag/Image_page_4")
    self._selectMarkTable = {
    pageTagImg1,
    pageTagImg2,
    pageTagImg3,
    pageTagImg4
    }

    self._selectMarkBgTable = {}
    for i = 1,4 do 
        self._selectMarkBgTable[i] = self:getChildByName("Panel_pageTag/imgBg" .. i)
    end


    --     -- 左右红点，隐藏控制用
    self._leftNumPanel = self:getChildByName("pagePanel/Panel_leftNumBg") 
    self._rightNumPanel = self:getChildByName("pagePanel/Panel_rightNumBg")
    self._leftNumPanel:setVisible(false)
    self._rightNumPanel:setVisible(false)
    --     -- 配件系统基本配置数据
    self._soldierBaseConfig = self:getSoldierBaseInfo()
    -- 初始化系统按钮
    self:initMainPanelBtn()
    -- 初始属性相关UI
    self:initBottomAddAttr() 
    -- 标签页层级调整
    local panel = self:getChildByName("Panel_pageTag")
    panel:setLocalZOrder(2)
    -- 初始化所有界面，匹配仓库回来的回调
    self:onInitAllPage()
    self._canClick = true -- 点击图标初始化为true




        
end

function PartsMainPanel:addTouch()
    local touchLayer = self:getChildByName("pagePanel")
    touchLayer:setTouchEnabled(false)
    touchLayer:setLocalZOrder(20)
    local x, ox
    if touchLayer.listenner == nil then
        touchLayer.listenner = cc.EventListenerTouchOneByOne:create()
        touchLayer.listenner:setSwallowTouches(false)

        touchLayer.listenner:registerScriptHandler(function(touch, event)    
            local location = touch:getLocation()   
            x = location.x
            ox = x
            return self.canTouch  
        end, cc.Handler.EVENT_TOUCH_BEGAN )

        touchLayer.listenner:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            if not self.canMove then
                return
            end
            local rs = self:touchMoved(location.x - ox)
            ox = location.x
            if rs then
                return
            end
        end, cc.Handler.EVENT_TOUCH_MOVED )

        touchLayer.listenner:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            self:touchEnded(location.x - x)
        end, cc.Handler.EVENT_TOUCH_ENDED ) 

        local eventDispatcher = touchLayer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(touchLayer.listenner, touchLayer)
    end
end

function PartsMainPanel:touchMoved(offsetX)
    
    for i=1,4 do
        local panel = self:getChildByName("Panel_109/panel"..i)
        local x = panel:getPositionX()
        panel:setPositionX(x + offsetX)
        local posX = x + offsetX
        if posX > -0.3 and posX < 0.3 then
            self._index = i
            self:adjustPanelPos()
            --不给你继续拖
            return true
        end
    end
end

function PartsMainPanel:touchEnded(dir)
    local minDistance = 9999
    local showIndex = 0
    for i=1,4 do
        local panel = self:getChildByName("Panel_109/panel"..i)
        local x = panel:getPositionX()
        if (x < 0 and dir > 10) or (dir < -10 and x > 0 and x < 620) then
            local offsetX = math.abs(x)
            if offsetX < minDistance then
                showIndex = i
                minDistance = offsetX
            end
            self._canClick = false
        end
    end
    if showIndex ~= 0 then
        self._index = showIndex
    end
    -- 点击结束，回调响应函数
    self:adjustPanelPos(true, dir) 
    
end

-- ------
-- -- 自适应设置
function PartsMainPanel:doLayout()
    -- 自适应
    -- local bgImage = self:getChildByName("bg_image") -- 底图
    -- local bgPanel = self:getChildByName("bgPanel")
    -- local Image_117 = bgPanel:getChildByName("Image_117") -- 背景图、底图
    
    -- NodeUtils:adaptiveTopPanelAndListView(bgPanel, nil, nil, GlobalConfig.topHeight)

    local Panel_109 = self:getChildByName("Panel_109")
    NodeUtils:adaptiveTopPanelAndListView(Panel_109, nil, nil, GlobalConfig.topHeight)

    local topPanel = self:getChildByName("pagePanel")
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, GlobalConfig.topHeight)

    local pageTagPanel = self:getChildByName("Panel_pageTag")
    NodeUtils:adaptiveTopPanelAndListView(pageTagPanel, nil, nil, GlobalConfig.topHeight)

    --底部两个按钮向上适配
    --NodeUtils:adaptiveUpPanel(self:getChildByName("button_warehouse"), toppanel, 60)
    --NodeUtils:adaptiveUpPanel(self:getChildByName("button_explore"), toppanel, 60)

    local exploreBtn = self:getChildByName("Button_explore")
    local warehouseBtn = self:getChildByName("Button_warehouse")
    NodeUtils:adaptiveUpPanel(exploreBtn, topPanel,25 )
    NodeUtils:adaptiveUpPanel(warehouseBtn, topPanel,25 )
   --NodeUtils:adaptiveTopY(exploreBtn, 915)
   -- NodeUtils:adaptiveTopY(warehouseBtn, 915)
end

 --获取武将配置数据
 function PartsMainPanel:getSoldierBaseInfo()
     local partsProxy = self:getProxy(GameProxys.Parts)
     return partsProxy:getSoldierBaseInfo()
 end 

-- --为按钮设置回调函数
function PartsMainPanel:initMainPanelBtn()
    -- 左切按钮
    local pageMoveLeftBtn = self:getChildByName("pagePanel/Button_moveLeft")
    local size = pageMoveLeftBtn:getContentSize()
    self.leftEct = UICCBLayer.new("rgb-fanye", pageMoveLeftBtn)
    self.leftEct:setPosition(size.width/2, size.height/2)

    -- 右切按钮
    local pageMoveRightBtn = self:getChildByName("pagePanel/Button_moveRigth")
    self.rightEct = UICCBLayer.new("rgb-fanye", pageMoveRightBtn)
    self.rightEct:setPosition(size.width/2, size.height/2)

    -- 军械争夺
    local exploreBtn = self:getChildByName("Button_explore")
    -- 军械仓库
    local warehouseBtn = self:getChildByName("Button_warehouse")
    --//null
    self:addTouchEventListener(pageMoveLeftBtn, self.onPageMoveLeft)
    self:addTouchEventListener(pageMoveRightBtn,self.onPageMoveRight)
    self:addTouchEventListener(exploreBtn,      self.onPartsExplore)
    self:addTouchEventListener(warehouseBtn,    self.onPartsWarehouse)
    
    --信息按钮（感叹号）
    local pagePanel = self:getChildByName("pagePanel")
    pagePanel:setLocalZOrder(21)
    local infoBtn = pagePanel:getChildByName("Button_info")
    infoBtn:setVisible(false)


    --     -- 军械仓库红点
    self._warehoseNumPanel = warehouseBtn:getChildByName("Panel_numBg")

    self["warehouseBtn"] = warehouseBtn
end

-- ------
-- -- 显示开始
function PartsMainPanel:onShowHandler()
    PartsMainPanel.super.onShowHandler(self)
    self.canMove = true
    -- 保留index页码
    if self._index then
        self._index = self._index 
    else
        self._index = 1
    end
    
    -- 初始化所有界面，匹配仓库回来的回调
    self:onInitAllPage() -- 解决不了已穿戴装备的属性更新问题

    self.canTouch = true
    self:addTouch()
    -- 记录typeId，用来播放动画的变量
    self._recommendTypeId = 0
end

------
-- 初始化所有界面
function PartsMainPanel:onInitAllPage()

    for i=1,4 do
        local panel = self:getChildByName("Panel_109/panel"..i)
        panel:setPositionX(self.allPos[self._index][i])
        local Image_soldier = panel:getChildByName("Image_soldier")
        local url = PartsMainPanel.ref_url[i]--string.format("bg/parts/%d.pvr.ccz", i)
        TextureManager:updateImageViewFile(Image_soldier, url)
    end

    -- 配置数据
    local dataList = self:getDataList()
    for i = 1, 4 do
        -- 数据刷新
        local panel = self:getChildByName("Panel_109/panel"..i)
        self:initPage(panel, dataList[i])
        -- 刷新update图标等
        self:updatePage(panel)
        -- 槽位红点
        self:showEnableEquipPart(panel)
        if i == self._index then
            local panel = self:getChildByName("Panel_109/panel"..self._index)
            -- 更新下方文本属性
            self:updateBottomAddAttr(panel)
            -- 仓库红点
            self:updateWarehouseNum()
            -- 更新相邻页面可装备部位个数, 左右的红点
            --self:updateAdjacentEnableCount()
            -- 刷新标签页
            self:showSelectMark()
        end
    end
end

--- 翻页回调函数，只刷新下方属性，左右红点，标签页
function PartsMainPanel:adjustPanelPos(isAction, dir)

    if not self.canMove then
        return
    end

    self.canMove = false

    self._index = self._index or 1

    -- self.canMove = false
    local function call()
        if self._oldIndex ~= self._index then -- 点击没有换页则不更新
            
            local panel = self:getChildByName("Panel_109/panel"..self._index)
            -- 更新下方文本属性
            self:updateBottomAddAttr(panel)
        
            -- 换页更新图标
            self:updatePage(panel)
            --print(self._index)

            -- 槽位红点，容错
            self:showEnableEquipPart(panel)

            -- 刷新标签页
            self:showSelectMark()
        
            self._oldIndex = self._index
        end

    end

    -- 中间兵种图片
    for i=1,4 do
        local panel = self:getChildByName("Panel_109/panel"..i)
        if isAction then
            panel._code = i
            
            local posX = panel:getPositionX()
            local targetPos = cc.p(self.allPos[self._index][i], panel:getPositionY())
            --防止其他panel在移动造成界面闪烁
            if dir < 0 then
                if self.allPos[self._index][i] > posX and posX <= -620 then
                    panel:setVisible(false)
                end
            elseif dir > 0 then
                if self.allPos[self._index][i] < posX and posX >= 620 then
                    panel:setVisible(false)
                end
            end

            local move = cc.MoveTo:create(0.15, targetPos)
            local callFunc = cc.CallFunc:create(function(sender)
                self._canClick = true
                --再设置一下位置
                sender:setVisible(true)
                sender:setPositionX(self.allPos[self._index][sender._code])
                if sender._code == 4 then
                    call()
                    -- self.canMove = true
                    TimerManager:addOnce(80, function()
                        self.canMove = true
                    end, self)
                end
            end)
            local Image_soldier = panel:getChildByName("Image_soldier")
            --Image_soldier:setPositionX(315)
            local url = PartsMainPanel.ref_url[i]--string.format("bg/parts/%d.pvr.ccz", i)
            TextureManager:updateImageViewFile(Image_soldier, url)
            panel:runAction(cc.Sequence:create(move, callFunc))
        else
            panel:setPositionX(self.allPos[self._index][i])
            local Image_soldier = panel:getChildByName("Image_soldier")
            --Image_soldier:setPositionX(315)
            local url = PartsMainPanel.ref_url[i]--string.format("bg/parts/%d.pvr.ccz", i)
            TextureManager:updateImageViewFile(Image_soldier, url)
        end
    end

    if not isAction then
        call()
        self.canMove = true
    end
    ----------------------------------------------------
end

------
-- 网络回调刷新，包括强化等操作
function PartsMainPanel:updatePageShowHadler(respData)
    local panel = self:getChildByName("Panel_109/panel"..self._index) -- 当前index
    local dataList = self:getDataList()
    self:initPage(panel, dataList[self._index])  --TODO：可不进行这个
    -- 刷新update图标
    if respData ~= nil then
        self:updatePage(panel, true) -- 全清除
    else
        self:updatePage(panel)
    end
    
    -- 更新下方文本属性
    self:updateBottomAddAttr(panel)
    -- 仓库红点
    self:updateWarehouseNum()
    -- 槽位红点
    self:showEnableEquipPart(panel)
end

 ------
 -- 初始化翻页容器
 function PartsMainPanel:initBottomAddAttr() 
     local pagePanel = self:getChildByName("pagePanel")
     --增加属性
     local attrIconTab = {6, 5, 13, 12} --从左到右：生命-->穿刺-->攻击-->防护 的属性图标
     self._addAttrLabels = {}
     for j=1,4,1 do
         local nameStr = "Label_attrAddNum"..j
         local attrLabel = pagePanel:getChildByName(nameStr)
         attrLabel:setString("0") -- 初始化0
         table.insert(self._addAttrLabels,attrLabel)
         -- 显示属性图片
         -- local attrBg = pagePanel:getChildByName("Image_attr"..j)
         -- local dot = attrBg:getChildByName("dot")
         -- local img = dot.img
         -- if img == nil then
         --     local url = string.format("images/littleIcon/%s.png", attrIconTab[j])
         --     img = TextureManager:createImageView(url)
         --     dot:addChild(img)
         -- else
         --     TextureManager:updateImageView(img, url)
         -- end
     end 
 end


--更新单个page的信息 for循环里面调用
function PartsMainPanel:updatePage(page, state)
    local type = page.type
    -- 已装备的配件

    local partsStrength = 0
    local partsBtns = page.partsBtns
    -- 根据页面已装备列表加载图标
    local equipedParts = self:getEquipedPartsByType(type)
    local equipeTable  = self:getEquipeTable(equipedParts)
    -- 如果是军械的强化、改造、进阶等操作则做清除
    if state then
        -- 全清空
        for _,btn in pairs(partsBtns) do
            if btn.uiIcon then
                btn.uiIcon:finalize()
                btn.uiIcon = nil
            end 
        end 
    else
        -- 清理图标卸下操作, 位置无数据则清除
        for k,v in pairs(equipeTable) do
            if v == 0 then
                if  partsBtns[k].uiIcon then
                    partsBtns[k].uiIcon:finalize()
                    partsBtns[k].uiIcon = nil 
                end
            end
        end
    end

    if #equipedParts > 0 then
        local partsProxy = self:getProxy(GameProxys.Parts)
        for k,v in pairs(equipedParts) do
            partsStrength = partsStrength + v.strength
            -- 数据封装
            local data = {}
            data.num = 1
            data.power = GamePowerConfig.Ordnance 
            data.typeid = v.typeid 
            data.parts = v
            data.isInPartsMainPanel = true
            -- 加载图标
            local partsBtn = partsBtns[v.part] -- 要装备的partsBtn
            partsBtn.equipData = data
            if partsBtn.uiIcon == nil then -- 原先没有图标
                if self._recommendTypeId == data.typeid and self._recommendTypeId ~= 0 then
                    
                    -- 在指定位置创建一个空 page:addChild(img)
                    local iconImg = self:getNoneImg(page, self._watchOrdnancePos)
                    -- 如果有一个在飘动，就中断
                    if iconImg:getChildByName("Icon") then
                        return
                    end

                    local effect = UICCBLayer.new("rgb-jszb-shiqi", iconImg, nil, nil, true) -- 特效
                    local uiIconTemp = UIIcon.new(iconImg, data, false, self)
                    uiIconTemp:setTouchEnabled(false) 

                    -- 获取回调前动作
                    local targetPos = cc.p(partsBtn:getPositionX() + 0.5, partsBtn:getPositionY() + 0.5)
                    local beforeAction = self:getBeforeAction(iconImg, targetPos, partsBtn, effect)

                    -- 动画回调函数
                    local call = cc.CallFunc:create(function()
                        uiIconTemp:finalize()
                        iconImg:removeAllChildren() -- 去除全部
                        local uiIcon = UIIcon.new(partsBtn,data,false,self)
                        uiIcon:setTouchEnabled(false) 
                        uiIcon:setPosition(partsBtn:getContentSize().width/2,partsBtn:getContentSize().height/2)
                        partsBtn.uiIcon = uiIcon
                        partsBtn.partsId  = data.parts.id
                        iconImg:removeFromParent()
                        self._recommendTypeId = 0 -- 重置为0

                        NodeUtils:removeSwallow()
                        TimerManager:remove(self.removeMask, self)
                    end)
                    
                    local action = cc.Sequence:create(beforeAction, call)
                    iconImg:runAction(action)
                else
                    -- 非穿上装备逻辑
                    if partsBtn.uiIcon ~= nil then
                       partsBtn.uiIcon:finalize()
                    end
                    local uiIcon = UIIcon.new(partsBtn,data,false,self)
                    -- 图标点击关闭，以免影响到partsBtn的点击
                    uiIcon:setTouchEnabled(false) 
                    uiIcon:setPosition(partsBtn:getContentSize().width/2,partsBtn:getContentSize().height/2)
                    partsBtn.uiIcon = uiIcon
                    partsBtn.partsId  = data.parts.id
                end
            elseif partsBtn.uiIcon ~= nil then
                -- 原先就有图标，对比
                if data.parts.id ~= partsBtn.partsId then
                    --print("icon不一致,单个更新【】【】")
                    -- 去掉加新
                    partsBtn.uiIcon:updateData(data)
                    partsBtn.partsId = data.parts.id
                end
            end
        end
    end
    ---------------------------------------------
    --配件强度
    page.strengthLabel:setString(partsStrength)
end 

 ------
 -- 更新BottomAddAttr
 function PartsMainPanel:updateBottomAddAttr(page)
    --增加属性
    local addAttrs = {0.00,0.00,0.00,0.00}
    local equipedParts = self:getEquipedPartsByType(page.type)
    if #equipedParts > 0 then
        local partsProxy = self:getProxy(GameProxys.Parts)
        for k,v in pairs(equipedParts) do
            local attrData = partsProxy:getDataFromOrdnanceConfig(v)
            addAttrs[1] = addAttrs[1] + attrData.life
            addAttrs[2] = addAttrs[2] + attrData.attack
            addAttrs[3] = addAttrs[3] + attrData.protection
            addAttrs[4] = addAttrs[4] + attrData.puncture
        end
    end

    for k,v in ipairs(addAttrs) do
        local attrLabels = self._addAttrLabels[k]
        local numStr = "+"..v
        if k == 1 or k == 2 then
            numStr = "+"..v.."%"
        end 
        attrLabels:setString(numStr)
    end
 end
 --=============翻页回调handler  结束 ====



 --=============初始化  开始 ====
 -- 信息按钮回调、兵种名字、8开锁界面、属性图片、配件强度，数据引入
 function PartsMainPanel:initPage(page, data)
     --兵种名
     local soldierNameLabel = page:getChildByName("Label_soldierName")
     
     soldierNameLabel:setVisible(false)
     --配件按钮,限制等级
     local partBtns = {}
     local roleProxy = self:getProxy(GameProxys.Role)
     local playerLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
     local tPartLimitLv = self:getOrdnancePartConfig()
     for i=1,8,1 do
         local baseInfo = {}
         baseInfo.type = data.type
         baseInfo.part = i
         baseInfo.isLimit = true
         local nameStr = "Button_part"..i
         local partsBtn = page:getChildByName(nameStr)
         partsBtn.id = i -- id赋值
         partsBtn:setPressedActionEnabled(false) -- -- 无法点击
         local limitLvLabel = partsBtn:getChildByName("Label_limitLv")
         local lockImg = partsBtn:getChildByName("lockImg")
         self:addTouchEventListener(partsBtn, self.onPartClicked)
         table.insert(partBtns,partsBtn)
         local limitLv = tPartLimitLv[i]
         local lvStr = "Lv."..limitLv
         limitLvLabel:setString(lvStr)
         if playerLv >= limitLv then
             limitLvLabel:setVisible(false)
             lockImg:setVisible(false)
             baseInfo.isLimit = false
         end 
         partsBtn.baseInfo = baseInfo --按钮绑定基本信息
     end

     -- 兵种显示
     local soldierImg = page:getChildByName("Image_soldier")
     local url = PartsMainPanel.ref_url[data.model]--string.format("bg/parts/%d.pvr.ccz", data.model)
     TextureManager:updateImageViewFile(soldierImg,url)
     local x , y= soldierImg:getPosition()--310 
     -- local y = 438
     if data.model == 1 then
         soldierImg:setPositionX(315)
     elseif data.model == 2 then
        soldierImg:setPositionX(315)
     elseif data.model == 3 then
         soldierImg:setPositionX(315)
     elseif data.model == 4 then
         soldierImg:setPositionX(315)
     end

     --配件强度
     local strengthLabel = page:getChildByName("Label_intensifyNum")
     strengthLabel:setString(0)

     -- 数据进入
     page.type = data.type
     page.partsBtns = partBtns
     page.strengthLabel = strengthLabel
 end 
 --=============初始化  结束 ====


-- ------
-- -- 更新配件的解锁等级
 function PartsMainPanel:updatePageLock()
     --配件按钮,限制等级解锁
     local pages = self._pageView:getPages()
     for _,page in pairs(pages) do     

         local roleProxy = self:getProxy(GameProxys.Role)
         local playerLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
         local tPartLimitLv = self:getOrdnancePartConfig()

         for i=1,8,1 do
             local baseInfo = page.partsBtns[i].baseInfo
             local limitLv = tPartLimitLv[i]

             if playerLv >= limitLv then
                 local nameStr = "Button_part"..i
                 local partsBtn = page:getChildByName(nameStr)
                 local limitLvLabel = partsBtn:getChildByName("Label_limitLv")
                 local lockImg = partsBtn:getChildByName("lockImg")

                 limitLvLabel:setVisible(false)
                 lockImg:setVisible(false)
                 baseInfo.isLimit = false
             end
             page.partsBtns[i].baseInfo = baseInfo --按钮绑定基本信息 
         end

     end     
 end



-- --================================================================================
 --向右翻页
 function PartsMainPanel:onPageMoveRight()
    if not self.canMove then
        --严禁狂点
        return
    end
    -- self.canMove = false
    self._index = self._index + 1
    if self._index > 4 then
        self._index = 1
    end

    self:setPanelVisibleByDir(1)

    self:adjustPanelPos(true, 0)
 end

 --向左翻页
 function PartsMainPanel:onPageMoveLeft()
    if not self.canMove then
        --严禁狂点
        return
    end
    -- self.canMove = false
    self._index = self._index - 1
    if self._index < 1 then
        self._index = 4
    end

    self:setPanelVisibleByDir(-1)
    self:adjustPanelPos(true, 0)
 end

 function PartsMainPanel:setPanelVisibleByDir(dir)
    for i=1,4 do
        local panel = self:getChildByName("Panel_109/panel"..i)
        local visible 
        --防止其他panel在移动造成界面闪烁
        if dir == 1 and self._index == 1 then
            visible = (i == 4 or i == 1)
        elseif dir == -1 and self._index == 4 then
            visible = (i == 4 or i == 1)
        else
            visible = (math.abs(i - self._index) <= 1)
        end
        panel:setVisible(visible)
    end
 end

 -- 前往军械副本点击按钮响应
 function PartsMainPanel:onPartsExplore(sender)
     local proxy = self:getProxy(GameProxys.Dungeon)
     proxy:onExterInstanceSender(2)
 end

 --前往配件仓库
function PartsMainPanel:onPartsWarehouse(sender)
    local data = {}
    data.moduleName = ModuleName.PartsWarehouseModule
    self:dispatchEvent(PartsEvent.SHOW_OTHER_EVENT,data)
end

-- --================================================================================

 --点击配件
 function PartsMainPanel:onPartClicked(sender)
    if not self._canClick  then
        return
    end
     local baseInfo = sender.baseInfo
     local uiIcon = sender.uiIcon
     -- 动画用的记录touchId
     if uiIcon == nil then
         --获取推荐配件
         local data = {}
         data.num = 1 
         data.power = GamePowerConfig.Ordnance 
         data.equip = 1
         data.parts = self:getRecommendedParts(baseInfo.type,baseInfo.part)
         data.isInPartsMainPanel = true
         data.isRecommendParts = true
         if data.parts then
             data.typeid = data.parts.typeid 
             local uiPanel = UIWatchOrdnance.new(self, data)
             self._watchOrdnancePos = uiPanel:getIcon():getWorldPosition() -- 界面坐标
             -- 记录typeId，用来播放动画的变量
             --self._recommendTypeId = data.typeid
         end
     else
         -- 查看已装备的配件
         UIWatchOrdnance.new(self, sender.equipData)
         -- 记录typeId，用来播放动画的变量
         self._recommendTypeId = 0
     end 

 end

 --强化
 function PartsMainPanel:onStrengthTouchHandler(data)
     local data = data
     local temp = {}
     temp.moduleName = "PartsStrengthenModule"
     temp.extraMsg = {}
     temp.extraMsg.data = data
     temp.extraMsg.index = 1
     temp.extraMsg.panelName = "PartsIntensifyPanel"
     self:dispatchEvent(PartsEvent.SHOW_OTHER_EVENT,temp)
 end 

 --改造
 function PartsMainPanel:onReformTouchHandler(data)
     local data = data
     local temp = {}
     temp.moduleName = "PartsStrengthenModule"
     temp.extraMsg = {}
     temp.extraMsg.data = data
     temp.extraMsg.index = 2
     temp.extraMsg.panelName = "PartsRemouldPanel"
     self:dispatchEvent(PartsEvent.SHOW_OTHER_EVENT,temp)
 end 

 --配件卸下
 function PartsMainPanel:onWearTouchHandler(data)
     local partsInfo = data.parts
     local partsProxy = self:getProxy(GameProxys.Parts)
     local senddata = {}
     senddata.id = partsInfo.id  --配件id
     partsProxy:ordnanceUnwieldReq(senddata)
 end 

 --配件装备
function PartsMainPanel:onEquipTouchHandler(data)
   
    NodeUtils:addSwallow()
    self._recommendTypeId = data.typeid -- 记录typeId，用来播放动画的变量
    local partsInfo = data.parts
    local partsProxy = self:getProxy(GameProxys.Parts)
    local senddata = {}
    senddata.id = partsInfo.id  --配件id
    partsProxy:ordnanceEquipedReq(senddata, PartsMainPanel.NAME)
    TimerManager:add(5*1000, self.removeMask, self)
end 

 --进阶onEvolveTouchHandler
 function PartsMainPanel:onEvolveTouchHandler(data)
     local data = data
     local temp = {}
     temp.moduleName = "PartsStrengthenModule"
     temp.extraMsg = {}
     temp.extraMsg.data = data
     temp.extraMsg.index = 3
     temp.extraMsg.panelName = "PartsEvolvePanel"
     if data.parts.remoulv < 4 then
         temp.extraMsg.index = 2
         temp.extraMsg.panelName = "PartsRemouldPanel"
     end
     self:dispatchEvent(PartsEvent.SHOW_OTHER_EVENT,temp)
 end 



 function PartsMainPanel:change()

 end



 --显示可装备部位红点
 function PartsMainPanel:showEnableEquipPart(panel)
     if self._allPartHaveInfo == nil then
         self._allPartHaveInfo = {}
     end 
     for _,v in ipairs(self._soldierBaseConfig) do
         --0无装备，1有装备，2可装备
         self._allPartHaveInfo[v.type] = {0,0,0,0,0,0,0,0}
     end 

     local allPartHaveInfo = self._allPartHaveInfo
     local partsProxy = self:getProxy(GameProxys.Parts)
     local unEquipInfos = partsProxy:getOrdnanceUnEquipInfos()
     local equipedInfos = partsProxy:getOrdnanceEquipedInfos()
     --检查部位是否有装备
     if equipedInfos ~= nil  then
         for _,v in pairs(equipedInfos) do
             allPartHaveInfo[v.type][v.part] = 1
         end 
     end 
     --检查是否有可装备的配件
     if unEquipInfos ~= nil then
         for _,v in pairs(unEquipInfos) do
             local tag = allPartHaveInfo[v.type][v.part]
             if tag == 0 then
                 allPartHaveInfo[v.type][v.part] = 2
             end 
         end 
     end
     -- print("=======================")

     -- 显示可装备的部位标记


     for type,haveInfo in pairs(allPartHaveInfo) do
        if type == panel.type then
             local partsBtns = panel.partsBtns
             for k,v in ipairs(haveInfo) do
                 local panelNum = partsBtns[k]:getChildByName("Panel_enableTag")
                 if v == 2 then --部位可装备
                     -- 如果锁头显示则隐藏(),未开放不显示红点
                     if partsBtns[k]:getChildByName("lockImg"):isVisible() then
                         panelNum:setVisible(false)
                     else
                         panelNum:setVisible(true)
                     end
                 else
                     panelNum:setVisible(false)
                 end
             end 
        end
     end 
 end

 ------
 -- 更新配件仓库中配件的数量显示
 function PartsMainPanel:updateWarehouseNum(data)
     local partsProxy = self:getProxy(GameProxys.Parts)
     local unEquipParts = partsProxy:getOrdnanceUnEquipInfos()
     local num = 0
     if unEquipParts and #unEquipParts > 0 then
         num = #unEquipParts
     end 
     self:dispatchEvent(PartsEvent.PARTS_EVENT_UPDATE_RAD)
     if num == 0 then
         self._warehoseNumPanel:setVisible(false)
     else
         self._warehoseNumPanel:setVisible(true)
         local labelNum = self._warehoseNumPanel:getChildByName("Label_num") 
         labelNum:setString(num)
     end
 end 


 ------
 -- 显示标记
 function PartsMainPanel:showSelectMark()
     -- for key, node in pairs (self._selectMarkTable) do
     --    if key == self._index then
     --        node:setVisible(true)
     --    else
     --        node:setVisible(false)
     --    end
     -- end
    for i = 1,4 do 
        if i == self._index then
            self._selectMarkBgTable[i]:setScale(1)
            self._selectMarkBgTable[i]:setColor(cc.c3b(255,255,255))
            self._selectMarkTable[i]:setScale(1)
            self._selectMarkTable[i]:setColor(cc.c3b(255,255,255))
        else
            self._selectMarkBgTable[i]:setScale(0.8)
            self._selectMarkBgTable[i]:setColor(cc.c3b(150,150,150))
            self._selectMarkTable[i]:setScale(0.8)
            self._selectMarkTable[i]:setColor(cc.c3b(150,150,150))
        end
    end
 end


 --获取配件等级限制配置表
 function PartsMainPanel:getOrdnancePartConfig()
     local temp = self._partsProxy:getOrdnancePartConfig()
     return temp
 end

 function PartsMainPanel:getDataList()
    local dataList = {}
    for k,v in ipairs(self._soldierBaseConfig) do
        local data = {}
        data.name = v.name
        data.type = v.type
        data.model = v.model
        table.insert(dataList, data)
    end
    return dataList
 end

 -------
 -- 根据兵种类型获取对应的已装备配件
 function PartsMainPanel:getEquipedPartsByType(type)
     local partsProxy = self:getProxy(GameProxys.Parts)
     local equipedInfos = partsProxy:getOrdnanceEquipedInfos()
     local parts = {}
     if equipedInfos and #equipedInfos>0 then
         for _,v in pairs(equipedInfos) do
             if v.type == type then
                 table.insert(parts,v)
             end 
         end 
     end 
     return parts
 end 

 --获取推荐的配件
 function PartsMainPanel:getRecommendedParts(type,part)
     local partsProxy = self:getProxy(GameProxys.Parts)
     local unEquipInfos = partsProxy:getOrdnanceUnEquipInfos()
     local recomParts = nil
     if unEquipInfos == nil or #unEquipInfos == 0 then
         return recomParts
     end 
     local temp = {}
     for _,v in pairs(unEquipInfos) do 
         if v.type == type and v.part == part then
             table.insert(temp,v)
         end 
     end 
     if #temp > 0 then
         recomParts = temp[1]
     end
     return recomParts
 end 


-- -- 更新相邻页面可装备部位个数
 function PartsMainPanel:updateAdjacentEnableCount()
--     local pages = self._pageView:getPages()
     local maxIndex = 4
     local curIndex = self._index
     local leftIndex = curIndex - 1
     local rightIndex = curIndex + 1

     if leftIndex < 1 then
         leftIndex = maxIndex
     end 
     if rightIndex > maxIndex then
         rightIndex = 1
     end 

     local leftNum = self:getEnableCountByPageIndex(leftIndex)
     local rightNum = self:getEnableCountByPageIndex(rightIndex)
     if leftNum == 0 then
         self._leftNumPanel:setVisible(false)
     else
         self._leftNumPanel:setVisible(true)
         local labelNum = self._leftNumPanel:getChildByName("Label_leftNum")
         labelNum:setString(leftNum)
     end

     if rightNum == 0 then
         self._rightNumPanel:setVisible(false)
     else
         self._rightNumPanel:setVisible(true)
         local labelNum = self._rightNumPanel:getChildByName("Label_rightNum")
         labelNum:setString(rightNum)
     end 
 end


-- --计算指定页面索引有多少可装备的部位
 function PartsMainPanel:getEnableCountByPageIndex(index)
     local index = index - 1 -- index 从0开始
     local pageNum = #self._soldierBaseConfig
     if index < 0 or index >(pageNum -1) then
         return 0
     end
     local count = self._partsProxy:getPageRedCount(index + 1)
     return count
 end


------
-- 根据类型获取对应的页数
function PartsMainPanel:getPageIndexByType(type)
    local index = 0
    for k,v in pairs(self._soldierBaseConfig) do
        if type == v.type then
            index = k
            break
        end 
    end
    return index
end

-------
-- 取已装备带0表
function PartsMainPanel:getEquipeTable(equipedParts)
    local equipeTable = {}
    for i = 1 , 8 do
        equipeTable[i] = 0
    end
    -- 是0 表示没有装备
    for key, value in pairs(equipedParts) do
        equipeTable[value.part] = value
    end
    return equipeTable
end


-- 获得空img
function PartsMainPanel:getNoneImg(page, watchOrdnancePos)
    local inMianPanelPos = page:convertToNodeSpace(watchOrdnancePos)
    local iconImg = page:getChildByName("iconImg")
    if iconImg == nil then
        -- 创建一个iconimg，动画父节点
        iconImg = TextureManager:createImageView("images/newGui1/none.png")
        iconImg:setPosition(inMianPanelPos) -- 初始位置
        iconImg:setLocalZOrder(1000)
        iconImg:setName("iconImg")
        page:addChild(iconImg)
    end
    return iconImg
end

-- 获得之前的动作
function PartsMainPanel:getBeforeAction(iconImg, targetPos, partsBtn, effect)
    local firstTime = 0.15
    local firstTargetPos = cc.p(iconImg:getPositionX()+ 30, iconImg:getPositionY() + 80)
    local moveTo = cc.MoveTo:create(firstTime, firstTargetPos)
    local scaleTo = cc.ScaleTo:create(firstTime, 1.15, 1.15)
    local moveAndScale = cc.Spawn:create(moveTo, scaleTo) -- 上移动

    local moveSpeed = NodeUtils:getTwoPointDistance(cc.p(1, 1), cc.p(30, 80))/ firstTime  
    local secondTime = NodeUtils:getTwoPointDistance(firstTargetPos, targetPos)  /(moveSpeed + moveSpeed/2)


    local function hideWatchPanel()
        --print("关闭watch界面")
    end
    local hideAction = cc.CallFunc:create(hideWatchPanel)
    
    local moveToTarget = cc.MoveTo:create(secondTime, targetPos)
    local scaleToTarget = cc.ScaleTo:create(secondTime, 1)
    local moveAndScaleTarget = cc.Spawn:create(moveToTarget, scaleToTarget)

    local function showLuoxia()
        local ccbLuoxia = UICCBLayer.new("rgb-jszb-luoxia", iconImg, nil, nil, true) -- 特效
        ccbLuoxia:setLocalZOrder(-1)
        effect:setVisible(false)
    end
    local showLuoxiaAction = cc.CallFunc:create(showLuoxia)

    local targetScale = cc.ScaleTo:create(0.1, 0.8, 0.8)

    local targetScale1 = cc.ScaleTo:create(0.1, 1, 1)

    local delayTime = 0.25
    local delayAction = cc.DelayTime:create(delayTime)

    local beforeAction = cc.Sequence:create(moveAndScale, hideAction, moveAndScaleTarget, showLuoxiaAction, targetScale,  targetScale1, delayAction)
    
    return beforeAction 
end

function PartsMainPanel:removeMask()

    NodeUtils:removeSwallow()
--    print("计时器调用，mask清除")
    TimerManager:remove(self.removeMask, self)
end

 --------------------------------
 --------------------------------网络回调，刷新页面
 function PartsMainPanel:updatePageView()
     --self:adjustPanelPos()
     self:updatePageShowHadler()
 end


function PartsMainPanel:onClosePanelHandler()
    self.canTouch = false
    self:dispatchEvent(PartsEvent.HIDE_SELF_EVENT)
end


