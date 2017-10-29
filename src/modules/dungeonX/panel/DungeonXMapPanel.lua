-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-05-23 16:14:09
--  * @Description: 军团副本地图-作战所
--  */
DungeonXMapPanel = class("DungeonXMapPanel", BasicPanel)
DungeonXMapPanel.NAME = "DungeonXMapPanel"

function DungeonXMapPanel:ctor(view, panelName)
    DungeonXMapPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function DungeonXMapPanel:finalize()
    DungeonXMapPanel.super.finalize(self)
end

function DungeonXMapPanel:initPanel()
    DungeonXMapPanel.super.initPanel(self)
    -- print("显示 DungeonXMapPanel...")
    
    self._roleProxy = self:getProxy(GameProxys.Role)
    self._dungeonXProxy = self:getProxy(GameProxys.DungeonX)
    
    --star 测试数据--------------------------------------------------------------
    --对应的5个据点坐标
    -- self._posx = {0228, 0198, 0308, 0550, 0683}
    -- self._posy = {0574, 0402, 0250, 0460, 0633}

    self._maxCityCount = 5  --每章最大据点数
    self._maxScrollPercent = 0
    self._conf = self._dungeonXProxy:getConfigData()
    self._titleConf = ConfigDataManager:getConfigData(ConfigData.LegionCapterConfig)

    self._percentTab = {
        0,      --1
        15,
        50,     --3
        80,
        100,     --5
    }


    self._allCityInfo = {}
    for index = 1,self._maxCityCount do
        self._allCityInfo[index] = {city = nil}
    end
    --end 测试数据--------------------------------------------------------------

    self._scrollView = self:getChildByName("ScrollView_1")
    self._scrollView:setBounceEnabled(false)
   

    local topPanel = self:getChildByName("TopPanel")

    local downPanel = self:getChildByName("DownPanel")
    self._titleTxt = topPanel:getChildByName("title")
    self._curCountTxt = topPanel:getChildByName("Totalcount")  --剩余挑战次数
    self._maxCountTxt = topPanel:getChildByName("tili")        --总挑战次数
    -- self._infoTxt = downPanel:getChildByName("infoTxt")
    self._infoBar = downPanel:getChildByName("ProgressBar")
    -- self._infoTxt:setString("")
    self._topPanel = topPanel
    self._downPanel = downPanel
    downPanel:setVisible(false)

    
    self:createDirectAction()
    self:setDirectActionVisible(false)

    self:registerEvent()
    self:onUpdateBgImg(nil)

end

function DungeonXMapPanel:registerEvent()
    local exitBtn = self._topPanel:getChildByName("exitBtn")
    exitBtn:setTouchEnabled(true)
    self:addTouchEventListener(exitBtn, self.onExitBtnTouch)
    exitBtn:addTouchRange(50,50)

    local btnClose = self._topPanel:getChildByName("btnClose")
    btnClose:setTouchEnabled(true)
    self:addTouchEventListener(btnClose, self.onCloseBtnTouch)
    btnClose:addTouchRange(50,50)


    local function scrollViewEvent(sender, evenType)
         self:scrollViewEvent()
    end
    self._scrollView:addEventListener(scrollViewEvent)
end

function DungeonXMapPanel:scrollViewEvent()
    -- if self._minScrollOffset == nil then
    --     return
    -- end
    -- local container = self._scrollView:getInnerContainer()
    -- local x , y = container:getPosition()
    -- if y < self._minScrollOffset then
    --     self._scrollView:jumpToPercentVertical(self._maxScrollPercent)
    -- end
end

-- 关闭界面
function DungeonXMapPanel:onCloseBtnTouch(sender)

   self:dispatchEvent(DungeonXEvent.CLOSE_ALL_EVENT)
end
-- 关闭界面
function DungeonXMapPanel:onExitBtnTouch(sender)

    for _,v in pairs(self._allCityInfo) do
        if v.city ~= nil then
            v.city:setVisible(false)
        end
    end
    self:dispatchEvent(DungeonXEvent.HIDE_SELF_EVENT)
end

-- -- 更新地图背景
function DungeonXMapPanel:onUpdateBgImg(info)
    self:addBgImg( self._scrollView )
end

function DungeonXMapPanel:addBgImg( parent )
    -- body
    local bgImgTab = {1,2}
    local bgPath = "bg/dungeon/1/dungeon_bg%d%s"
    local bg_pic
    local bg_type = ".jpg" --TextureManager.bg_type
    for k,v in pairs(bgImgTab) do
        bg_pic = TextureManager:createImageViewFile(string.format(bgPath, v, bg_type)) 
        bg_pic:setAnchorPoint(cc.p(0.0, 0.0))
        
        if k == 1 then
            bg_pic:setPosition(0,0)
        else
            local size = bg_pic:getContentSize()
            bg_pic:setPosition(size.width,0)
        end

        parent:addChild(bg_pic)
    end
end

-- 当前关卡指示动画
function DungeonXMapPanel:createDirectAction()
    -- body
    local arrowPanel = self:getChildByName("ScrollView_1/arrowPanel")
    arrowPanel:setVisible(false)

    local x,y = arrowPanel:getPosition()

    -- 匕首攻击特效
    self._cirCle = self._scrollView.knifeLayer
    if self._cirCle == nil then
        local knifeLayer = UICCBLayer.new("rgb-fight-knife", self._scrollView)  
        knifeLayer:setPosition(arrowPanel:getPosition())
        knifeLayer:setLocalZOrder(1000)
        self._scrollView.knifeLayer = knifeLayer
        self._cirCle = self._scrollView.knifeLayer
    else
        self._cirCle:setVisible(true)
    end

end

function DungeonXMapPanel:setDirectActionVisible(isShow)
    -- body
   self._cirCle:setVisible(isShow) 
end

function DungeonXMapPanel:onShowHandler()

    -- body
    logger:info("···DungeonXMapPanel:onShowHandler()--------0")
    local proxy = self:getProxy(GameProxys.DungeonX)
    local curChapterId = proxy:getCurChapterID()
    local data = proxy:getOneChapterEventsInfoByID(curChapterId)
    local allMapData = proxy:getAllDungeonData()
    self:onDungeonInfoResp(data,curChapterId,allMapData)
    self._scrollView:jumpToPercentHorizontal(0)

    for i=1,#self._allCityInfo do
        local v = self._allCityInfo[i]
        if v.city ~= nil and v.city.data ~= nil then
            local info = v.city.data
            local city = v.city
            if info.curProgress ~= -1 and info.curProgress ~= 0 then
                local arrowPanel = self:getChildByName("ScrollView_1/arrowPanel")
                local posX,posY = city:getPosition()
                local contentSize = city:getContentSize()
                local x = posX + contentSize.width / 2 - arrowPanel:getContentSize().width - 25
                local y = posY + contentSize.height / 2 - arrowPanel:getContentSize().height + 82
                arrowPanel:setPosition(x,y)

                self:setDirectActionVisible(true)
                self._cirCle:setPosition(x + 60,y - contentSize.height/6+10)
                return
            end
        end
    end
end

function DungeonXMapPanel:updateTopPanel(id,data)
    -- body
    local str = self._titleConf[id].name
    self._titleTxt:setString(str)
    -- 挑战次数刷新
    self._curCountTxt:setString(data.curCount)
    self._maxCountTxt:setString(data.totalCount)

    if data.curCount == 0 then
        self._curCountTxt:setColor(ColorUtils.commonColor.c3bRed)
    else
        self._curCountTxt:setColor(ColorUtils.commonColor.c3bGreen)
    end
    

end

function DungeonXMapPanel:updateDownPanel(data)
    -- body

    -- -- 进度条
    -- local per = data.curCount/data.totalCount*100
    -- self._infoBar:setPercent(per)

    -- -- 挑战次数刷新
    -- self._curCountTxt:setString(data.curCount)
    -- self._maxCountTxt:setString(data.totalCount)

    -- -- 纯文字富文本显示
    -- local color = ColorUtils.wordColorDark1603 --red
    -- if data.curCount == 0 then
    --     color = ColorUtils.wordColorDark1604
    -- end
    -- local text = {{{self:getTextWord(3701),20,"#eed6aa"},{data.curCount,20,color},{"/"..data.totalCount,20,"#ffffff"}}}

    -- local rickLabel = self._infoTxt._rickLabel
    -- if rickLabel == nil then
    --     rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
    --     rickLabel:setPosition(self._infoTxt:getPosition())
    --     self._infoTxt:getParent():addChild(rickLabel)
    --     self._infoTxt._rickLabel = rickLabel
    -- end
    -- rickLabel:setString(text)
    -- rickLabel:setLocalZOrder(10)

end

-- 据点信息更新 
--TODO 暂时用onDungeonInfoResp来更新据点
function DungeonXMapPanel:onEventsUpdate()
    -- body
    logger:info("据点信息更新DungeonXMapPanel:onEventsUpdate()")
end


-- 据点信息渲染/更新
function DungeonXMapPanel:onDungeonInfoResp(data,curChapterId,allMapData)
    logger:info("据点信息渲染···DungeonXMapPanel:onDungeonInfoResp()--------0")
    
    local info = nil    
    local index = 1
    local city
    local lastCity = nil
    for _,v in pairs(data) do
        city = self._allCityInfo[index].city
        local info = self._conf[v.id]
        if city == nil then           
            -- 坐标读UI
            city = self._scrollView:getChildByName("city"..index)
            self._allCityInfo[info.sort].city = city

            local targetIcon = city:getChildByName("targetIcon")
            targetIcon:setScale(GlobalConfig.dungeonTargetIconScale)
        end
        
        city.info = info
        city.data = v
        city.index = index
        index = index + 1
        lastCity = city
        self:registerItemEvents(city,info,data)
    end
    
    self.lastCity = lastCity
    self:updateScrollViewHorizontal()

    
    self:updateTopPanel(curChapterId,allMapData)
    -- self:updateDownPanel(allMapData)    
end

function DungeonXMapPanel:updateScrollViewHorizontalOld()
    local lastCity = self.lastCity
    local percent = nil
    local maxId = self._dungeonXProxy:getMaxPassedID()

    if lastCity.data.id <= maxId then
        -- 已解锁据点
        percent = self._percentTab[lastCity.index]
    else
        -- 最新进度据点
        maxId = maxId % 5 + 1
        percent = self._percentTab[maxId]
    end
    self._scrollView:jumpToPercentHorizontal(percent)

end    

function DungeonXMapPanel:updateScrollViewHorizontal(sort)
    if sort then
        percent = self._percentTab[sort]
        self._scrollView:jumpToPercentHorizontal(percent)
        return
    end

    self:updateScrollViewHorizontalOld()
end  

function DungeonXMapPanel:registerItemEvents(city,info,importantData,isPass)
    if city == nil or city.index > 5 then
        return
    end
    
    local data = city.data
    self["city" .. city.index] = city
    city:setVisible(true)
    city.data._info = info

    -- print("据点信息···city.index, data.id, data.curProgress, data.haveBox",city.index,data.id,data.curProgress,data.haveBox)

    local boxPanel = city:getChildByName("boxPanel")
    boxPanel.data = data
    if data.curProgress == 0 then
        self:showBoxPanel( city,boxPanel,data,info )
    else
        self:showTargetCity( city,boxPanel,data,info )
    end

end

function DungeonXMapPanel:showTargetInfo( city,isShowCity,isShowBox )
    -- body
    local targetIcon = city:getChildByName("targetIcon")
    local nameBgImg = city:getChildByName("nameBgImg")
    local name = city:getChildByName("name")
    local nameIcon = city:getChildByName("nameIcon")
    local progressBG = city:getChildByName("progressBG")
    local boxPanel = city:getChildByName("boxPanel")

    targetIcon:setVisible(isShowCity)
    nameBgImg:setVisible(isShowCity)
    name:setVisible(isShowCity)
    nameIcon:setVisible(false)
    progressBG:setVisible(isShowCity)
    boxPanel:setVisible(isShowBox)

end

function DungeonXMapPanel:updateCityName(city,nameStr)
    -- 据点名字
    local name = city:getChildByName("name")
    name:setString(nameStr)  
end

function DungeonXMapPanel:hideBoxCCBI(boxBtn)
    local boxEffect = boxBtn.boxEffect
    if boxEffect ~= nil then
        boxEffect:finalize()  --隐藏的时候直接移除
        boxBtn.boxEffect = nil
    end
end

-- 据点显示宝箱
function DungeonXMapPanel:showBoxPanel( city,boxPanel,data,info )
    -- print("据点显示宝箱。。。")
    self:showTargetInfo( city,true, true )
    self:updateCityName(city,info.boxname)
    self:onPlayEffect(city)
    self:setDirectActionVisible(false)
    
    local progressBG = city:getChildByName("progressBG")
    progressBG:setVisible(false)

    local boxBtn = boxPanel:getChildByName("boxBtn")

    local boxEffect = boxBtn.boxEffect
    if data.haveBox == 1 then
        -- 宝箱可领取

        -- 宝箱特效显示处理
        if boxEffect == nil then
            boxEffect = UICCBLayer.new("rgb-gk-xiang",boxBtn )
            boxBtn.boxEffect = boxEffect
        end

        TextureManager:updateButtonNormal(boxBtn, "images/newGui1/none.png")
        NodeUtils:setEnable(boxBtn, true)

    else
        -- 宝箱已领取
        TextureManager:updateButtonNormal(boxBtn, "images/newGui1/Icon_chest1.png")
        NodeUtils:setEnable(boxBtn, false) --显示disable图片
        -- if boxEffect ~= nil then
        --     boxEffect:finalize()  --隐藏的时候直接移除
        --     boxBtn.boxEffect = nil
        -- end
        self:hideBoxCCBI(boxBtn)
    end

    city.touchType = "box"
    city:setEnabled(true)
    city.importantData = importantData
    self:addItemTouchEvent(city)  
end

-- 据点显示怪物
function DungeonXMapPanel:showTargetCity( city,boxPanel,data,info )
    -- print("据点显示怪物。。。")
    self:showTargetInfo( city,true, false )

    -- 据点图片
    local targetIcon = city:getChildByName("targetIcon")
    if targetIcon.icon ~= info.icon then
        targetIcon.icon = info.icon
        local url = string.format("images/dungeon/Icon_%d.png", info.sort)
        targetIcon.url = url
    end
    
    -- 据点名字
    self:updateCityName(city,info.name)

    -- 据点名字的图标
    local nameIcon = city:getChildByName("nameIcon")
    if info.icon == 1 or info.icon == 2 then
        nameIcon:setVisible(true)
        local url = string.format("images/newGui1/Icon_dungeon%d.png",info.icon)--Iimages/newGui1/Icon_dungeon1.png
        TextureManager:updateImageView(nameIcon, url)
    else
        nameIcon:setVisible(false)
    end


    local progressBG = city:getChildByName("progressBG")
    local maxId = self._dungeonXProxy:getMaxPassedID()
    if data.curProgress == -1 then
        -- 未解锁据点
        progressBG:setVisible(false)
        
        if data.id < maxId then
            -- 当前据点不是最新据点
        else
            self:createEffect(city)
            city:setEnabled(false)
        end

    else
        -- 当前挑战据点
        city:setEnabled(true)
        progressBG:setVisible(true)
        self:onPlayEffect(city)

        local bar = progressBG:getChildByName("bar")
        local per = data.curProgress/100
        bar:setPercent(per)

        if data.id < maxId then
        --默认显示第一关
        -- if city.index ~= 1 then
            -- 当前据点不是最新据点
            self:setDirectActionVisible(false)

        else
            -- 当前据点箭头动画
            local arrowPanel = self:getChildByName("ScrollView_1/arrowPanel")
            local posX,posY = city:getPosition()
            local contentSize = city:getContentSize()
            local x = posX + contentSize.width / 2 - arrowPanel:getContentSize().width - 25
            local y = posY + contentSize.height / 2 - arrowPanel:getContentSize().height + 82
            arrowPanel:setPosition(x,y)

            self:setDirectActionVisible(true)
            self._cirCle:setPosition(x + 60,y - contentSize.height/6+10)

            self:updateScrollViewHorizontal(info.sort)
        end
    end

    city.touchType = "city"
    city.importantData = importantData
    self:addItemTouchEvent(city)    
end


-- 战争迷雾 创建
function DungeonXMapPanel:createEffect( target )
    -- body
    local ccbLayer = target.ccbLayer
    if ccbLayer == nil then
        ccbLayer = UICCBLayer.new("rgb-zhanzheng-miwu",target )
        ccbLayer:setLocalZOrder(100)
        ccbLayer:setPosition(56,50)  --统一坐标偏移
        target.ccbLayer = ccbLayer
        ccbLayer:pause()
    end
end

-- 战争迷雾 播放
function DungeonXMapPanel:onPlayEffect( target, isPlay )
    -- body
    local ccbLayer = target.ccbLayer
    if ccbLayer then
        ccbLayer:resume()
        target.ccbLayer = nil
    end
end

-- 战争迷雾 关闭界面时移除全部
function DungeonXMapPanel:removeAllEffect( data )
    -- body
    for k,target in pairs(data) do
        local ccbLayer = target.ccbLayer
        if ccbLayer then
            ccbLayer:finalize()
        end
    end
end

function DungeonXMapPanel:addItemTouchEvent(item)
    if item.isAdd == true then
        return
    end
    item.isAdd = true

    -- local function call(sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         sender:setScale(1.0)
    --         self:onCallItemTouch(sender)
    --     elseif eventType == ccui.TouchEventType.began then
    --         AudioManager:playButtonEffect()
    --         sender:setScale(0.98)
    --     elseif eventType == ccui.TouchEventType.canceled then
    --         sender:setScale(1.0)
    --     end
    -- end
    -- item:addTouchEventListener(call)
    self:addTouchEventListener(item,self.onCallItemTouch)
end

-- 点击据点的回调事件
function DungeonXMapPanel:onCallItemTouch(sender, callArg)
    -- logger:info("···DungeonXMapPanel:onCallItemTouch(sender, callArg)")
    local data = sender.data

    if data.haveBox == 0 and data.curProgress == 0 then
        -- 宝箱已领取
        self:showSysMessage(self:getTextWord(3704))
        return
    end

    local touchType = sender.touchType
    if touchType == "box" then
        self:onCallBoxTouch(sender)
    elseif touchType == "city" then
        -- -- new panel
        local proxyX = self:getProxy(GameProxys.DungeonX)
        local curChapterId = proxyX:getCurChapterID()

        local proxy = self:getProxy(GameProxys.Dungeon)
        proxy:setCurrCityType(sender.data.id)
        proxy:setCurrType(curChapterId, GameConfig.battleType.legion)

        -- local panel = self:getPanel(DungeonXCityPanel.NAME)
        -- panel:show(data)

        -- local function callFunc()
        --    local panel = self:getPanel(DungeonXCityPanel.NAME)
        --    panel:show(sender.data)
        -- end
        -- sender.data.extra = {callback = callFunc, obj = self}
        local panel = self:getPanel(DungeonXCityInfoPanel.NAME)
        panel:show(sender.data)
    end
end

function DungeonXMapPanel:onCallBoxTouch(sender)
    -- body
    -- logger:info("···DungeonXMapPanel:onCallBoxTouch(sender)")

    local data = sender.data
    local info = sender.info
    local sendData = {id = data.id}

    if data.haveBox == 0 and data.curProgress == 0 then
        -- 宝箱已领取
        self:showSysMessage(self:getTextWord(3704))
        return
    end

    local openprice = StringUtils:jsonDecode(info.openprice)
    local price = openprice[3]
    if price ~= nil then
                
        -- 弹框
        local function callFunc()
            local proxy = self:getProxy(GameProxys.Legion)
            local mineInfo = proxy:getMineInfo()
            -- print("mineInfo.myContribute，price", mineInfo.myContribute, price)

            mineInfo.myContribute = price  --TODO 测试代码
            
            if mineInfo.myContribute < price then
                -- print("你的贡献不足，领取失败")
                self:showSysMessage(self:getTextWord(3705))
            else
                self._dungeonXProxy:onTriggerNet270003Req(sendData)
            end
        end
        local content = string.format(self:getTextWord(3703),price)
        self:showMessageBox(content,callFunc)

    else
        self._dungeonXProxy:onTriggerNet270003Req(sendData)
    end
end


-- 领取完宝箱 更新宝箱
function DungeonXMapPanel:onGetBoxUpdate(data)
    -- body
    local info = self._conf[data.id]
    local city = self._allCityInfo[info.sort].city
    if city ~= nil then
        if data.haveBox == 0 then
            -- 宝箱已领取
            local boxPanel = city:getChildByName("boxPanel")
            local boxBtn = boxPanel:getChildByName("boxBtn")
            TextureManager:updateButtonNormal(boxBtn, "images/newGui1/Icon_chest1.png")
            NodeUtils:setEnable(boxBtn, false) --显示disable图片
            self:hideBoxCCBI(boxBtn)
        end
    end

end



-- --start 图片变灰----------------------------------------------------------------------------
-- --start 图片变灰----------------------------------------------------------------------------
-- --TODO 只对sprite有效，对图片sprite无效,并且变灰的sprite的X锚点是反的.
-- function DungeonXMapPanel:showGreyView(node) 
--     logger:info("调用了图片变灰···DungeonXMapPanel:showGreyView(node)")

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
 
--     --变灰
--                             -- "gl_FragColor.xyz = vec3(0.299*c.r + 0.587*c.g +0.114*c.b); \n"..    --默认灰度值
--     local psGrayShader = "#ifdef GL_ES \n" ..
--                             "precision mediump float; \n" ..
--                             "#endif \n" ..
--                             "varying vec4 v_fragmentColor; \n" ..
--                             "varying vec2 v_texCoord; \n" ..
--                             "void main(void) \n" ..
--                             "{ \n" ..
--                             "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
--                             "gl_FragColor.xyz = vec3(0.287*c.r + 0.287*c.g +0.287*c.b); \n"..
--                             "gl_FragColor.w = c.w; \n"..
--                             "}" 


--     local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,psGrayShader)
    
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
--     pProgram:link()
--     pProgram:use()
--     pProgram:updateUniforms()
--     node:setGLProgram(pProgram)
-- end
-- --end 图片变灰----------------------------------------------------------------------------
