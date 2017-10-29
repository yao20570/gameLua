TestState = class("TestState",GameBaseState)

function TestState:ctor()
    TestState.super.ctor(self)
end

function TestState:initialize()
    TestState.super.initialize(self)
    
--    self:testScene()
   -- self:testModel()
--    self:testEffect()
--    self:testVector2()
--    self:testGsub()
--    self:testTouch()
--    self:testRadian()
--    self:testExpandScrollView()
--    self:testExpandPageView()
--    self:testShaders()
--    self:testArgs()
    
--    self:testutf8strlen()

--    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile()
--    self:testTimerManger()
--   self:testListView()
--    self:testWarMap()
--    self:testPlist()
--    self:testOrbitCamera()
--    self:testFullName()
--    self:testSocket()
--    self:testCountDown()
--    self:testUIComponent()
--    self:testConfig()

--    self:testMap()
    -- self:testSpine()
--    self:testIcon()
--    self:testIDrag()
--    self:testHtml()
--    self:testIcon()

--    self:makeZhenfa()
--    self:testInt64()
--    self:testTopListView()
--    self:testAnimation()
--    self:testUITip()
--    self:testUIAdapt()
--    self:testSpineEffect()
--    self:testSpineModelPool()
--    self:testLayerTouch()
--    self:testJson()
--    self:testSortList()
--    self:testGetStringSize()
--    self:testRoate()
--    AppUtils:loadGameComplete()
--    self:testMainScene()
--    self:testClippingNode()
--    self:testUISecLvPanelBg()
--    self:testSplite()
--    self:testProcessBar()
--    self:testColor16()
--    self:testDrawDotted()
--    self:testIcon222()
   -- self:testModelLogin()
     -- self:testSoldierModel()  ---佣兵/军师模型和动作测试接口

    -- AppUtils:loadGameComplete()
    
--    self:testRenderTableListView()
--    self:testCsb()
    
--    self:testVideoPlayerPlay()
--    self:testPattern()
--    self:testNewListView()
--    self:testNewSocket()
--    self:testCompress()
--    self:testSpinePoolN()
--    self:testListViewN()

--    self:testUIListViewN()
--    self:testPlayPcm()
--    self:testBase64()
--    self:testIconN()
--    self:testTableView()
--    self:testGLCall()
    -- self:testWebp()

    --self:testTiledMap()
    -- self:testPartic()
    -- self:testModifyEffect()

      -- self:testCocosBuilder()
--    self:testRunText()
--    self:testTiledSprite()
--    self:testPlist11()
    -- self:testWriteProto()
    -- self:testCCBI()
--    self:testTextAction()
    --self:testPanelAction()
    --self:onLoginBtnTouch()
    -- self:testAliasTexParameters()
    -- self:testUITeamMessPanel2()
--    self:testMoveScaleAction()

    -- self:testText()
    -- self:testMemory()
    -- self:testGmatch()
    -- self:testSpineModelFinalize()

    --self:testIsOverlap()

    --self:testHttp()
    -- self:testCCBPlay()
    -- self:testLabel()
     self:playCCB()
    -- self:useTTF()
    -- self:testLabelContent()
    --self:testUIGetProp()
end


function TestState:testUIGetProp()

    local UIResourceGet = UIGetProp.new(self.gameScene, self, true)

    UIResourceGet:show({
            {},{},{},{},{},
            {},{},{},{},{},
            {},{},{},{},{},
            {},{},{},{},{},
            {},
        }, function() end)
end

function TestState:testLabelContent()
    local xx = ccui.Text:create()
    --xx:setFontName("fonts/DroidSansFallback.ttf")
    xx:setFontSize(30)
    xx:setString("海派腔调艺术粗黑简")

    local s = xx:getContentSize()

    print("========>w:" .. s.width .. ", h:" .. s.height)

    xx:setString("")

    s = xx:getContentSize()

    print("========>w:" .. s.width .. ", h:" .. s.height)

end

function TestState:useTTF()
    
    local startTime = 0
    
    local xx = ccui.Text:create()
    xx:setFontName("fonts/DroidSansFallback.ttf")
    xx:setFontSize(30)
    xx:setString("海派腔调艺术粗黑简")

    self.gameScene:addChild(xx)

    xx:setPosition(200, 300)
    startTime = os.clock()
    for i = 1, 100 do
        xx:setString("海派腔调艺术粗黑简" .. i)
    end
    print("=====================>2:", os.clock() - startTime)
    

    
    local lab = ccui.Text:create("海派腔调艺术粗黑简", "fonts/海派腔调艺术粗黑简1.0.ttf", 20)
    --local lab = ccui.Text:create("海派腔调艺术粗黑简", "fonts/微软雅黑.ttf", 20)
    self.gameScene:addChild(lab)
    lab:setPosition(200, 200)

    startTime = os.clock()
    for i = 1, 100 do
        lab:setString("海派腔调艺术粗黑简" .. i)
    end
    print("=====================>1:", os.clock() - startTime)
    

    local uiSkin = UISkin.new("WorldChatPanel")
    uiSkin:setParent(self.gameScene)
end

function TestState:playCCB()
    
    local layer = cc.Layer:create()
    self.gameScene:addChild(layer)
    
   --[[
    local owner = {}
    owner["pause"] = function()  end
    for index = 1, 10 do
        owner["pause" .. index] = function()  end
    end
    owner["complete"] = function() 
        -- self:endDrama() 
        -- self:addDramaHead()

    end

    local aEffect = UICCBLayer.new("rgb-gzzq-shuzi", layer, owner)


     --]]
    
    local time = 0
    for i = 1 , 1 do
        local function xx()
            --local ccbLayer1 = UICCBLayer.new("rgb-gzzq-shuzi", layer, nil, nil, true)
            local ccbLayer1 = UICCBLayer.new("rgb-energy-jinse", layer, nil, nil, true)
            ccbLayer1:setPosition(400, 400)
            ccbLayer1:setVisible(true)
        end
        
        time = i * 500
        TimerManager:addOnce(time, xx, self)
    
     end

     --TimerManager:addOnce(time + 1000, function() layer:setVisible(false) end, self)
    
end

-- label性能测试
function TestState:testLabel()
    local layer = cc.Layer:create()
    self.gameScene:addChild(layer)

    local startTime = 0
    local lab = nil
    
    startTime = os.clock()
    for i = 1 , 100 do
        lab = ccui.Widget:create()
    end
    print("creat Widget================>", os.clock() - startTime)

    startTime = os.clock()
    for i = 1 , 100 do
        lab = ccui.Layout:create()
    end
    print("creat Layout================>", os.clock() - startTime)

    startTime = os.clock()
    for i = 1 , 100 do
        lab = ccui.ImageView:create()
    end
    print("creat ImageView================>", os.clock() - startTime)

    startTime = os.clock()
    for i = 1 , 100 do
        lab = ccui.Button:create()
    end    
    print("creat button================>", os.clock() - startTime)

    startTime = os.clock()
    for i = 1 , 100 do
        lab = ccui.Text:create()
    end
    print("creat label================>", os.clock() - startTime)

    startTime = os.clock()
    for i = 1 , 1 do
        lab:setString("relative: gameproxyMailProxy.luafindfile: E:slgProjectclientslgGamesrcgameproxyMailProxy.luaLoad script(288): E:slgProjectclientslgGamesrcgameproxy" .. i)
    end
    print("================>", os.clock() - startTime)

    startTime = os.clock()
    for i = 1 , 5 do
        lab:setString("relative: gameproxyMailProxy.luafindfile: E:slgProjectclientslgGamesrcgameproxyMailProxy.luaLoad script(288): E:slgProjectclientslgGamesrcgameproxy" .. i)
    end
    print("================>", os.clock() - startTime)


    -- 粒子效果的动画
    --local ccbName = "rgb-lxxs-gchuxian"
    -- 使用action的动画
    local ccbName = "rgb-vippinzi-zi"
     startTime = os.clock()
    local ccbLayer1 = UICCBLayer.new(ccbName, self.gameScene)
    ccbLayer1:setPosition(200, 200)
    ccbLayer1:setVisible(true)
    print("ccb ================>", os.clock() - startTime)

end


-- CCB动画性能测试
function TestState:testCCBPlay()
    TimerManager:init()
    
    local layer = cc.Layer:create()
    self.gameScene:addChild(layer)

    -- 粒子效果的动画
    local ccbName = "rgb-lxxs-gchuxian"
    -- 使用action的动画
    --local ccbName = "rgb-vippinzi-zi"

    local ccbLayer1 = UICCBLayer.new(ccbName, self.gameScene)
    ccbLayer1:setPosition(200, 200)
    ccbLayer1:setVisible(true)

    local function finalize()
        ccbLayer1:finalize()
        print("===============================")
    end
    TimerManager:addOnce(5000, finalize, self)

    --[[
   
    local ccbMap = {}
    for i = 1, 80 do
        local ccbLayer = UICCBLayer.new(ccbName, ccbLayer1)
        ccbLayer:setPosition(200, 200)
        --ccbLayer:pause()
        ccbLayer:setVisible(true)
        table.insert(ccbMap, ccbLayer) 
    end

    -- 观察暂停和隐藏ccb的性能消耗
    local function removeccb()
        for k, v in pairs(ccbMap) do
            --v:pause()
            v:setVisible(false)
        end
    end

    TimerManager:addOnce(5000, removeccb, self)
    --]]
end

function TestState:testHttp()
    local function successCallback(obj, info)
        print("@@@@@@@@@@@@@@@@", info)
    end
    -- local url = "http://192.168.10.190/gcol/version/version.php"
    -- HttpRequestManager:send(url, {}, self, successCallback)

    self.assetsManager = cc.AssetsManager:new("http://download.5aiyoo.com/wk/gcol/patch/201611120628/5-package-0-5.zip",
            "http://203.195.140.103:8888/gcol/version/platform/testModule/version.lua",
            "tmpdir5")
    self.assetsManager:retain()
    self.assetsManager:update()

    local function onError(errorCode)
        
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            reason = "没有版本内容可以更新"
        elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
            reason = "解压失败"
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            reason = "网络异常"
        else
            reason = "未知错误：" .. errorCode
        end

        print("onError", errorCode, reason)
    end
    local function onProgress(percent)
        print("onProgress", percent)
    end
    local function onSuccess(errorCode)
        print("onSuccess", errorCode)
    end

    self.assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    self.assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    self.assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
end

function TestState:testIsOverlap()

    local function isOverlap(rc1, rc2)
        if rc1.x + rc1.width > rc2.x and
            rc2.x + rc2.width > rc1.x and
            rc1.y + rc1.height > rc2.y and
            rc2.y + rc2.height > rc1.y then
            return true
        else
            return false
        end
    end


    local rc1 = cc.rect(425, 419, 160, 91)
    local rc2 = cc.rect(406, 287, 160, 91)
    local isOverlap = isOverlap(rc1, rc2)
    print("~~~~~~~~~isOverlap~~~~~~~~", isOverlap)
end

function TestState:testSpineModelFinalize()

    SpineModelPool:preLoad(101)
    
    -- local modelList = {101, 102, 103, 104, 105, 106, 401, 402, 403}

    -- local parent = self.gameScene

    -- local function finalizeModel(obj, spineModel)
    --     spineModel:finalize()
    -- end

    -- local function createSpine(obj, modelType)
    --     local spineModel = SpineModel.new(modelType, parent)
    --     spineModel:setPosition(math.random(100,500), math.random(100, 800))
    --     TimerManager:addOnce(math.random(500, 5000), finalizeModel, {}, spineModel)
    -- end


    -- for i=1,100 do
    --     local modelType = modelList[math.random(1, #modelList)]
    --     TimerManager:addOnce(math.random(100, 300) * i, createSpine, {}, modelType)
    -- end

end


function TestState:testGmatch()

    local str = 'foo"中文"a"你好"fooア' 
    local tab = {}
    local _, count = string.gsub(str, "[^\128-\193]", "")
    for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
        print("~~~~~~~~~", uchar)
        tab[#tab+1] = uchar 
    end

    print("~~~~~~~~~", count)

    function CheckChinese(s) 
    local ret = {};
    local f = '[%z\1-\127\194-\244][\128-\191]*';
    local line, lastLine, isBreak = '', false, false;
    for v in s:gfind(f) do
        table.insert(ret, {c=v,isChinese=(#v~=1)});
    end
    return ret
    end
    for k, v in ipairs(CheckChinese('a中文ユb+')) do 
        print(k,v.c,#v.c,v.isChinese);
    end


    -- local ss = 'foo"中文"a"你好"foo' 
    -- self:extractChinese(ss)
end

function TestState:extractChinese(s)
    -- for m in string.gmatch(s,'"[\u4e00-\u9fa5]+"') do
    --     print(m)
    -- end
end

function TestState:testMemory()

   local str = StringUtils:toLowerCaseFirstOne("STRrrrr")
   print("~~~~~", str)

   local keys = cc.Director:getInstance():getTextureCache():getAllTextureKey()

    -- print("~~~~~~~~~~~~~~~cc.Director:getInstance():getTextureCache()~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", cc.Director:getInstance():getTextureCache().getAllTextureKey)

    GlobalConfig:preLoadImage()  --ui/gui_ui_resouce_big_0.pvr.ccz   ui/guiNew_ui_resouce_big_0.pvr.ccz

    local url = "images/newGui1/BtnMiniGreed1.png"
    local plist = TextureManager:getUIPlist(url)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)

    local button2 = ccui.Button:create()
    button2:setPosition(cc.p(150, 200))
    button2:loadTextures(url, url, "", 1)
    self.gameScene:addChild(button2)

    local layer = ccui.Layout:create()
    self.gameScene:addChild(layer)
    layer:setPosition(640 / 2, 960 / 2)
    --inputPanel, maxLength, placeHolder, returnCallback, isFilterWorld, bgurl
    local editBox = ComponentUtils:addEditeBox(button2, 3, "输入纹理名称", nil , false)

    local function onSpriteBtnTouch(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
           local keys = cc.Director:getInstance():getTextureCache():getAllTextureKey()
           print("~~~~~~~~~", keys)
           for _, key in pairs(keys) do
               print("@@@@@@@@@@@@@@@@@@@@@@@", key)
               TextureManager:removeTextureForKey(key)
               break
           end
           -- local i = 1
           -- cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()
           -- print("~~~~~~~~~~ccui.TouchEventType.ended~~~~~~~~~~")
   --         local text = editBox:getText()

   --         local str = StringUtils:toLowerCaseFirstOne(text)
   -- print("~~~~~", str)

           -- local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(text)
           -- cc.SpriteFrameCache:getInstance():removeSpriteFramesFromTexture(texture)
           -- cc.Director:getInstance():getTextureCache():removeTexture(texture)


           -- local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(text)
           -- print("~~~~~texture~~~~~~~~~", texture)

           -- cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()

       end
    end
    
    
    local button = ccui.Button:create()
    button:setPosition(cc.p(420, 200))
    button:loadTextures(url, url, "", 1)
    button:setTitleText("释放")
    button:addTouchEventListener(onSpriteBtnTouch)
    self.gameScene:addChild(button)

end

--测试Text的耗时
function TestState:testText()

    local time = os.clock()
    local text = ccui.Text:create()
    
    text:setString("是范德萨发发送到撒地方的算法是")
    text:setPosition(320, 480)
    -- text:setString("1")
    -- text:setString("1")
    -- text:setString("1")
    -- text:setString("1")
    
    self.gameScene:addChild(text)
    print("~~~~~~~~~~~~~~~", os.clock() - time)

    local time = os.clock()
    local label = cc.Label:create()
    label:setString("是范德萨发发送到撒地方的算法是")
    label:setPosition(320, 580)
    self.gameScene:addChild(label)
    print("~~~~~~~!!!~~~~~~~~", os.clock() - time)
    
end

-- -- 测试新特效代码
function TestState:onLoginBtnTouch(sender)
    local mainPanel = self.gameScene
    local size = mainPanel:getContentSize()
    local times = 4 -- 几个物品
    -- 第三阶段，移动缩放
    local function step03(sprite, targetPos)
        targetPos = cc.p(0, 0)
        local delayAction = cc.DelayTime:create(0.5) -- 定住多久
        local moveTo00 = cc.MoveTo:create(0.3, targetPos )
        local scaleAction = cc.ScaleTo:create(0.3, 0)
        -- 组合缩放和移动
        local moveAndScale = cc.Spawn:create(moveTo00,scaleAction)
        local seqAction = cc.Sequence:create(delayAction, moveAndScale)
        sprite:runAction(seqAction)
    end
    -- 第二阶段，震动效果
    local function step02(sprite, targetPos)
        local action1 = cc.ScaleTo:create(0.06, 1.3, 1.3)
        local action2 = cc.ScaleTo:create(0.06, 1, 1)
        local action11 = cc.ScaleTo:create(0.04, 1.2, 1.2)
        local action22 = cc.ScaleTo:create(0.04, 1, 1)
        local action3 = cc.ScaleTo:create(0.02, 1.1, 1.1)
        local action4 = cc.ScaleTo:create(0.02, 1, 1)
        local action5 = cc.CallFunc:create(function()
            step03(sprite, targetPos) 
        end)
        local action6 = cc.Sequence:create(action1, action2,action11, action22, action3,action4, action5)
        sprite:runAction(action6)
    end
    -- 第一阶段，缩放渐显
    local function step01(sprite, targetPos)
        sprite:setScale(0.2)
        local action1 = cc.ScaleTo:create(0.1, 1, 1)
        local action2 = cc.CallFunc:create(function()
            step02(sprite, targetPos) 
        end)
        local action3 = cc.Sequence:create(action1, action2)
        sprite:runAction(action3)
    end

    local function sp()
        if times > 0 then
            times  = times - 1
            local sprite = self:addCcbInPos("rgb-huoquwupin", cc.p( (4 - times)*500/4 , 700) , mainPanel)
            --local sprite = self:addCcbInPos("rgb-huoquwupin", cc.p(0 , 700) , mainPanel)

            step01(sprite, cc.p(0, 0))
            TimerManager:addOnce(70, sp, self)
        else
            TimerManager:remove(sp, self)
        end
    end
    -- 执行开始函数
    sp()
end


function TestState:addCcbInPos(name, pos , parent)
    local sprite = cc.Sprite:create()
    sprite:setPosition(pos)
    parent:addChild(sprite)
    sprite:setScale(1)
    local ccbLayer = UICCBLayer.new(name, sprite, nil, nil, true) 
    ccbLayer:setPositionType(0)
    --ccbLayer:setLocalZOrder(1)
    return sprite
end


function TestState:testMoveScaleAction()
    -- local url = "images/newGui1/BtnMiniGreed1.png"
    -- local plist = TextureManager:getUIPlist(url)
    -- cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)

    -- local button2 = ccui.Button:create()
    -- button2:setPosition(cc.p(150, 200))
    -- button2:loadTextures(url, url, "", 1)
    -- self.gameScene:addChild(button2)
    -- button2:setAnchorPoint(1, 0)

    local ccbLayer = UICCBLayer.new("rgb-huoquwupin", self.gameScene, nil, nil, false) 
    ccbLayer:setPositionType(0)
    ccbLayer:setPosition(150, 200)

    local delayAction = cc.DelayTime:create(0.5) -- 定住多久
    local moveTo00 = cc.MoveBy:create(5, cc.p(300, 500) )
    local scaleAction = cc.ScaleTo:create(3, 0.3)
        -- 组合缩放和移动
    local moveAndScale = cc.Spawn:create(moveTo00,scaleAction)
    local seqAction = cc.Sequence:create(delayAction, moveAndScale)
    ccbLayer:runAction(seqAction)


end

function TestState:testUITeamMessPanel2()
    -- local uiSkin = UISkin.new("UITeamMessPanel2")
    -- uiSkin:setParent(self.gameScene)
    local UITeamMessPanel = UITeamMessPanel.new(self.gameScene)
end

function TestState:testPanelAction()
    local uiSkin = UISkin.new("BattleResultPanel")
    uiSkin:setParent(self.gameScene)

    local function complete()
        ComponentUtils:playAction("BattleResultPanel", "battle_win")
    end
    TimerManager:addOnce(1000, complete, self)
    
end

function TestState:testWriteProto()
    local data = {}
    data.rc = 1
    data.waitTime = 1
    data.saveTraffic = 1

    local msg = LocalDBManager:writeProtobuf("proto.tmp", "M5.M50000.S2C", data)

    local ddata = LocalDBManager:readProtobuf("proto.tmp", "M5.M50000.S2C")
    print("xxxxxxxxxxxxxxxxxxxxxxxxx", ddata.rc)
end

function TestState:testModifyEffect()
    --rpg-the-sun
    local movieChip = UIMovieClip.new("rpg-Criticalpoint")
    movieChip:setParent(self.gameScene)
    movieChip:play(false)
    movieChip:setPosition(600 / 2, 600 / 2)

end

function TestState:testWebp()
    local resFilename = "ui/gui_ui_resouce_big_0.webp"
    local texture = cc.Director:getInstance():getTextureCache():addImage(resFilename)
    local sprite = cc.Sprite:createWithTexture(texture)
    
    self.gameScene:addChild(sprite)
end

function TestState:testGLCall()
    local data = {}
    data["power"] = GamePowerConfig.Item
    data["typeid"] = 2053
    data["num"] = 1
    
--    local icon = UIIcon.new(self.gameScene, data, nil, nil, nil, true)
--    local x = math.random(100,600)
--    local y = math.random(100,900)
--    icon:setPosition(x, y)

    local uiSkin = UISkin.new("UIIcon")
    uiSkin:setParent(self.gameScene)
end

function TestState:testBake()

    local layer = cc.Layer:create()
    
    layer:bake()
end

function TestState:testIconN()
    local data = {}
    data["power"] = GamePowerConfig.Item
    data["typeid"] = 2048
    data["num"] = 1
--    local icon = UIIcon.new(self.gameScene, data)
--    local x = math.random(100,600)
--    local y = math.random(100,900)
--    icon:setPosition(x, y)
    
    local uiSkin = UISkin.new("OpenServerGiftPanel")
    uiSkin:setParent(self.gameScene)
    
    local listView = uiSkin:getChildByName("ListView")
    local infos = ConfigDataManager:getConfigData(ConfigData.DayLandConfig)
    local function renderItemPanel(self, item, info)
            local data = StringUtils:jsonDecode(info.rewardId)
            for k,v in pairs(data) do
                local data = ConfigDataManager:getRewardConfigById2(v)
                local tmpData = ConfigDataManager:getConfigById(ConfigData.FixRewardConfig,v)
                local lastData = ConfigDataManager:getConfigByPowerAndID(tmpData.type,tmpData.contentID)
                local last_data = {}
                last_data.num = data.num
                last_data.typeid = tmpData.contentID
                last_data.power = data.type

                local container = item:getChildByName("Panel_"..k)
                local icon = UIIcon.new(container, last_data, true)
            end
    end
    
    ComponentUtils:renderListView(listView, infos, self, renderItemPanel,true ,true)

    
--    local item = listView:getItem(0)
--    item:retain()
--    listView:removeItem(0)
--    listView:setItemModel(item)
    
--    local index = 0
--    local infos = ConfigDataManager:getConfigData(ConfigData.DayLandConfig)
--    for _, info in pairs(infos) do
--        local data = StringUtils:jsonDecode(info.rewardId)
--        listView:pushBackDefaultItem()
--        
--        for k,v in pairs(data) do
--            local data = ConfigDataManager:getRewardConfigById2(v)
--            local tmpData = ConfigDataManager:getConfigById(ConfigData.FixRewardConfig,v)
--            local lastData = ConfigDataManager:getConfigByPowerAndID(tmpData.type,tmpData.contentID)
--            local last_data = {}
--            last_data.num = data.num
--            last_data.typeid = tmpData.contentID
--            last_data.power = data.type
--            
--            local item = listView:getItem(index)
--            local container = item:getChildByName("Panel_"..k)
--            local icon = UIIcon.new(container, last_data, true)
--            
----            if index >= 5 then
----                break
----            end
----            if index >= 5 then
----                icon._iconBg:setVisible(false)
----            end
--
----            local uiSkin = UISkin.new("UIIcon")
----            uiSkin:setParent(container)
----            if index < 10 then
----                local icon = UIIcon.new(self.gameScene, last_data, true)
----                icon:setPosition(100, 800)
----            end
--        end
--        
--        index = index + 1
--    end
    
end

function TestState:testBase64()
--    local str = "1weew32323"
--    local estr = base64_encode(str)
--    print("=====estr=========", estr)
--    
--    local dstr = base64_decode(estr)
--    print("=====estr=========", dstr)

--    local recorder1 = string.gsub(recorder, "\n", "")
--    print("====")
end

function TestState:testPlayPcm()
    AudioManager:playEffect("8_8.10.39.54", "pcm")
end

function TestState:testJson2Lua()
    local layout = ccui.Layout:create()
    layout:setName("Panel_14")
    layout:setLocalZOrder(0)
    
end


function TestState:testUIListViewN()
    local uiSkin = UISkin.new("OpenServerGiftPanel")
    uiSkin:setParent(self.gameScene)
    
    local listView = uiSkin:getChildByName("ListView")
    local item = listView:getItem(0)
    item:retain()
    listView:removeItem(0)
    listView:setItemModel(item)
    
    local infos = {}
    for index=1, 30 do
        table.insert(infos, index)
    end
    
    local function updateData(item)
        print("----------------", item.index)
        local info = infos[item.index + 1]
        local text = item:getChildByName("text_1")
        text:setString(info)
    end
    
    listView.updateData = updateData
    local size = item:getContentSize()
    local uiListView = UIListView.new(listView, size.width, size.height)
    uiListView:initListViewData(infos)
    
    _G["uiListView"] = uiListView
end


function TestState:testListViewN()
    local uiSkin = UISkin.new("OpenServerGiftPanel")
    uiSkin:setParent(self.gameScene)
    local listView = uiSkin:getChildByName("ListView")
    local itemClone = listView:getItem(0)
    
--    itemClone:retain()
    listView:setItemModel(itemClone)
    listView:setBounceEnabled(false) 
    
--    self._itemWidth = itemWidth
--    self._itemHeight = itemHeight

    local itemsMargin = listView:getItemsMargin()

    local time = os.clock()
    for i=1, 5 do
        listView:pushBackDefaultItem()
    end
    
    local items = listView:getItems()
    for index=0, #items - 1 do
    	local item = listView:getItem(index)
    	item.index = index
        local text = item:getChildByName("text_1")
        text:setString(index)
    end
    local maxIndex = 5
    local maxNum = 20
    local wh = listView:getContentSize().height
    local sh = itemClone:getContentSize().height + itemsMargin
    local exchange = 0
    
    local function updateIdx(index)
        print("===login==index======", index)
    end
    
    local lasty = nil
    
    local function scrollViewEvent(sender, evenType)
        local container = listView:getInnerContainer()
        local ch = container:getContentSize().height
        local x , y = container:getPosition()
        local sIndex = math.floor((ch - wh - math.abs(y)) / sh) 
--        print("=======scrollViewEvent===========",x, y, sIndex,
--            container:getContentSize().height, 
--            listView:getContentSize().height,
--            itemClone:getContentSize().height,
--            itemsMargin, evenType)
            
        if lasty == nil then
            lasty = y
            return
        end
        local dir = y - lasty
        local item = listView:getItem(maxIndex)    
        if sIndex == 2 and evenType == 4 and item.index < maxNum - 1 then
            local item = ComponentUtils:setListViewItemIndex(listView, 0, maxIndex) --把第一个放到最后
            item.index = item.index + maxIndex + 1
            container:setPosition(x, y - sh)
--            print("======scrollViewEvent============", item.index)
            for index=sIndex, sIndex + 4 do
                local item = listView:getItem(index - 1)
                print("=======index:========", item.index )
                local text = item:getChildByName("text_1")
                text:setString(item.index)
            end
        end
            
        if sIndex == 0 and evenType == 4 and item.index > maxIndex then
            local item = ComponentUtils:setListViewItemIndex(listView, maxIndex, 0) --把最后一个放到第一个
            item.index = item.index - maxIndex - 1
            container:setPosition(x, y + sh)
            print("======scrollViewEvent==xxx==========", item.index, sIndex)
            for index=sIndex, sIndex + 4 do
                local item = listView:getItem(index)
                print("=======index:========", item.index )
                local text = item:getChildByName("text_1")
                text:setString(item.index)
            end
        end
        
        
        if sIndex > 1 and evenType == 4 then
            exchange = exchange + 1
        end
        
        lasty = y
    end
    listView:addScrollViewEventListener(scrollViewEvent)
    
    
end

function TestState:testTableView()

    local uiSkin = UISkin.new("OpenServerGiftPanel")
    uiSkin:setParent(self.gameScene)
    local listView = uiSkin:getChildByName("ListView")
    local itemClone = listView:getItem(0)
--    itemClone:retain()
--    listView:removeItem(0)
    listView:setVisible(false)
    
    local infos = ConfigDataManager:getConfigData(ConfigData.DayLandConfig)
    local function renderItemPanel(self, item, info)
        local data = StringUtils:jsonDecode(info.rewardId)
        for k,v in pairs(data) do
            local data = ConfigDataManager:getRewardConfigById2(v)
            local tmpData = ConfigDataManager:getConfigById(ConfigData.FixRewardConfig,v)
            local lastData = ConfigDataManager:getConfigByPowerAndID(tmpData.type,tmpData.contentID)
            local last_data = {}
            last_data.num = data.num
            last_data.typeid = tmpData.contentID
            last_data.power = data.type

            local container = item:getChildByName("Panel_"..k)
            local icon = container.icon
            if icon ~= nil then
                icon:updateData(last_data)
            else
                icon = UIIcon.new(container, last_data, true)
                container.icon = icon
            end
            
--            local icon = UIIcon.new(container, last_data, true)
        end
    end
    
    
    local winSize = cc.Director:getInstance():getWinSize()
    local tableView = cc.TableView:create(cc.size(600,600))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(00, winSize.height / 2 - 150))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.gameScene:addChild(tableView)
    
    local function scrollViewDidScroll(view)
--        print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        print("scrollViewDidZoom")
    end

    local function tableCellTouched(table,cell)
        print("cell touched at index: " .. cell:getIdx())
    end

    local function cellSizeForTable(table,idx) 
--        local size = itemClone:getContentSize()
        local size = cc.size(590,240)
        return size.height, size.width
    end

    local function tableCellAtIndex(table, idx)
        local strValue = string.format("%d",idx)
        print("+=================", strValue)
        local cell = table:dequeueCell()
        local label = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            local panel = itemClone:clone()
            panel:setVisible(true)
            panel:setTouchEnabled(false)
--            panel:setEnabled(false)
            panel:setAnchorPoint(cc.p(0,0))
            panel:setPosition(cc.p(0, 0))
            panel:setTag(123)
            cell:addChild(panel)
            
            local info = infos[idx + 1]
            if info == nil then
                info = infos[1]
            end
            renderItemPanel(self, panel, infos[idx + 1])
--            local sprite = TextureManager:create("images/gui/Bg_Information.png")
--            sprite:setAnchorPoint(cc.p(0,0))
--            sprite:setPosition(cc.p(0, 0))
--            cell:addChild(sprite)
--
--            label = cc.Label:createWithSystemFont(strValue, "Helvetica", 20.0)
--            label:setPosition(cc.p(0,0))
--            label:setAnchorPoint(cc.p(0,0))
--            label:setTag(123)
--            cell:addChild(label)
        else
--            label = cell:getChildByTag(123)
--            if nil ~= label then
--                label:setString(strValue)
--            end
            local panel = cell:getChildByTag(123)
            local info = infos[idx + 1]
            if info == nil then
                info = infos[1]
            end
            renderItemPanel(self, panel, info)
        end

        return cell
    end

    local function numberOfCellsInTableView(table)
        return 250
    end
    
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function TestState:testSpinePoolN()
--    local model = SpineModel.new(101, self.gameScene)
--    model:setPosition(200, 300)
--    model:playAnimation("win", true)
--    
--    _G["finalizeModel"] = function()
--        model:finalize()
--    end
    
    local modelList = {}
    
    _G["addModule"] = function(name)
        local model = SpineEffect.new(name, self.gameScene)
        model:setPosition(200, 300)
--        model:playAnimation("win", true)
        
        table.insert(modelList, model)
    end
    
    _G["removeAll"] = function()
        for _, model in pairs(modelList) do
            model:finalize()
        end
        
        modelList = {}
    end

--    local modelType = 101
--    local json = "model/" .. modelType .. "/skeleton.json"
--    local atlas = "model/" .. modelType .. "/skeleton.atlas"
--    local spine = sp.SkeletonAnimation:create(json, atlas)
--    spine:retain()
--    
--    local newSpine = sp.SkeletonAnimation:createWithData(spine)
--    newSpine:setPosition(200, 300)
--    newSpine:setAnimation(0, "win", true)
--    self.gameScene:addChild(newSpine)
end

function TestState:testCompress()
    local src = "-----!!---!!-------------!XX"
    local csrc = compress(src)
    local usrc = uncompress(csrc)
    print("======usrc===============", usrc)
end

function TestState:testNewSocket()
    local socket = require("script/socket")
--    local udp = socket.udp()
--    print("setname", udp:setsockname("*", 8080))
--    udp:sendto("你不是人","192.168.10.124",8080);
    local socket = socket.connect("192.168.10.124",8080)
    socket:settimeout(0)
    
    socket:send("1111111111")

end

function TestState:testNewListView()
    local uiSkin = UISkin.new("BagAllItemPanel")
    uiSkin:setParent(self.gameScene)
    local listView = uiSkin:getChildByName("bgListView")
    local itemClone = listView:getItem(0)
    listView:setItemModel(itemClone)
    
    local time = os.clock()
    for i=1, 30 do
        listView:pushBackDefaultItem()
    end
    print("==========pushBackDefaultItem====================", os.clock() - time)
    
    local time = os.clock()
    for index=1, 30 do
    	local item = itemClone:clone()
    	item:retain()
    end
    
    print("==========testNewListView====================", os.clock() - time)
end

function TestState:testPattern()
    local fileTable = {}

    s = "from={world, to=Lua}";

    for k, v in string.gfind(s, "(%w+)=(%b{})") do

        print(k)

        fileTable[k] = v;

        print(v)

    end 
    
    local infos = ConfigDataManager:getConfigData(ConfigData.ChatFaceConfig)
    local pattern =   "(#笑)|(#莫言)"
    local str = "#笑#莫言111"
    print(string.find(str,pattern))
--    print(m)
--    local t = {}
--    for k, v in m do
--        t[k] = v
--    end
--    for k, v in pairs(t) do
--        print(k, v)
--    end
end

function TestState:testCsb()
    
--    string.gsub(s,"#*",repl,n)
    
    local time = os.clock()
    local root = ccs.GUIReader:getInstance():widgetFromBinaryFile("GainInfoPanel.csb")
    self.gameScene:addChild(root)
    print("====================", os.clock() - time)
    
    
    local time = os.clock()
    local root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/GainInfoPanel.ExportJson")
    self.gameScene:addChild(root)
    print("====================", os.clock() - time)
    
end

function TestState:testRenderTableListView()

    local uiSkin = UISkin.new("BagAllItemPanel")
    uiSkin:setParent(self.gameScene)
    local listView = uiSkin:getChildByName("bgListView")
    
    local typePanel = uiSkin:getChildByName("bgListView/itemPanel/useBtn")
    
    local tableInfos = {}
    tableInfos[1] = { {id = 1, name = "2"}, {id = 2, name = "2"} }
    tableInfos[2] = { {id = 1, name = "2"}, {id = 2, name = "2"} }
    tableInfos[3] = { {id = 1, name = "2"}, {id = 2, name = "2"} }
    
    local function rendercall(self, item, info)
        print(info.listTypetitle)
        if info.listTypetitle == true then 
        --渲染typePanel
        else
        --渲染itemPanel
        end
    end
    
    ComponentUtils:renderTableListView(listView, typePanel, tableInfos,self,rendercall)
    
end

function TestState:testVideoPlayerPlay()

    
    if ccexp.VideoPlayer ~= nil then
        local function onVideoEventCallback(sener, eventType)
            if eventType == ccexp.VideoPlayerEvent.PLAYING then
            elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
            elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
            elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
            end
            
            self:showSysMessage("...click..." .. eventType)
        end
        
        local function callback()
            local videoPlayer = ccexp.VideoPlayer:create()
            videoPlayer:setContentSize(cc.size(300, 300))

            local filename = cc.FileUtils:getInstance():fullPathForFilename("video/cg.mp4")
            videoPlayer:setFileName(filename)
            videoPlayer:play()
            videoPlayer:setPosition(100,100)
            videoPlayer:addEventListener(onVideoEventCallback)
            self.gameScene:addChild(videoPlayer)
        end
        
        TimerManager:addOnce(1000,callback,self)
    end
end

function TestState:testModelLogin()
    local model = SpineModel.new(209, self.gameScene)
    model:playAnimation("animation", true)
    model:setPosition(640, 0)
    model:setScale(0.5)
end

-- 查看士兵模型动作
function TestState:testSoldierModel()
    local scale = 2       --缩放大小
    
    local url = "images/newGui1/BtnBigGreed2.png"
    local plist = TextureManager:getUIPlist(url)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)

    local button1 = ccui.Button:create()
    button1:setPosition(cc.p(150, 350))
    button1:loadTextures(url, url, "", 1)
    self.gameScene:addChild(button1)

    local button2 = ccui.Button:create()
    button2:setPosition(cc.p(150, 250))
    button2:loadTextures(url, url, "", 1)
    self.gameScene:addChild(button2)

    local button23 = ccui.Button:create()
    button23:setPosition(cc.p(150, 150))
    button23:loadTextures(url, url, "", 1)
    self.gameScene:addChild(button23)

    local label = ccui.Text:create()
    label:setString("模型动作名 (attack,die,hurt,run,wait,win) ")
    label:setFontSize(20)
    label:setAnchorPoint(0,0.5)
    label:setPosition(70,100)
    self.gameScene:addChild(label)


    local editBox = ComponentUtils:addEditeBox(button2, 3, "输入模型id")
    local editBox2 = ComponentUtils:addEditeBox(button23, 3, "输入模型动作名")
    local editBox1 = ComponentUtils:addEditeBox(button1, 3, "缩放大小")


    local function onSpriteBtnTouch(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
           if editBox ~= nil then
                local txt = editBox:getText()
                if txt ~= "" then
                    local a = txt / 100
                    local b = txt % 100
                    logger:info("a,b= %d %d",a,b)
                    -- if a > 0 and a < 5 and b > 0 and b < 10 then
                    if a > 0 and b > 0 and b < 10 then
                        logger:info("=== 如果输入的模型没有对应资源，程序会报错！！！")
                        if self._testModel then
                            self._testModel:finalize()
                        end

                        -- ModelAnimation = {}  --模型动作名
                        -- ModelAnimation.Attack = "attack"
                        -- ModelAnimation.Die = "die"
                        -- ModelAnimation.Hurt = "hurt"
                        -- ModelAnimation.Run = "run"
                        -- ModelAnimation.Wait = "wait"
                        -- ModelAnimation.Win = "win"

                        local model = SpineModel.new(txt, self.gameScene)

                        local actionTxt = "attack"
                        if editBox2 ~= nil then
                            actionTxt = editBox2:getText()
                            if actionTxt == "" then
                                actionTxt = "attack"
                            end
                        end
                        model:playAnimation(actionTxt, true)  --默认播放attack动作

                        local scaleTxt = 1
                        if editBox1 ~= nil then
                            scaleTxt = editBox1:getText()
                            if scaleTxt == "" then
                                scaleTxt = 1
                            else
                                scaleTxt = tonumber(scaleTxt)
                            end
                        end
                        model:setScale(scaleTxt)  --默认缩放值1

                        model:setPosition(320, 480)
                        self._testModel = model
                    else
                        self:showSysMessage("= 输入的模型id 有误 =")
                    end

                end
           end

       end
    end
    
    
    local button = ccui.Button:create()
    button:setPosition(cc.p(460, 250))
    button:loadTextures(url, url, "", 1)
    button:setTitleText("播放")
    button:setTitleFontSize(30)
    button:addTouchEventListener(onSpriteBtnTouch)
    self.gameScene:addChild(button)

end


function TestState:testIcon222()
    local data = {}
    data.power = GamePowerConfig.SoldierBarrack
    data.num = 1
    data.typeid = 103
    
    local node = cc.Node:create()
    node:setPosition(300,300)
    self.gameScene:addChild(node)
    UIIcon.new(node, data, false)
end

function TestState:testDrawDotted()
    local node1 = TextureManager:createImageView("images/dungeon/evenBgD1.png")
    local node2 = TextureManager:createImageView("images/dungeon/evenBgD1.png")
    
    node1:setPosition(100, 100)
    node2:setPosition(300, 300)
    
    local dottedNode = TextureManager:createImageView("images/newGui2/Bg_spot.png")
    
    self.gameScene:addChild(node1)
    self.gameScene:addChild(node2)
    
    NodeUtils:drawDottedLine(node1,node2,dottedNode)
end

function TestState:testColor16()
    ColorUtils:color16ToC3b("#ff44ff")
end

function TestState:testProcessBar()
    local rect_table = cc.rect(14,8,1,1)
    local sprite = TextureManager:createScale9Sprite("images/gui/Progress.png", rect_table)
--    local sprite = TextureManager:createSprite("images/gui/Progress.png")

    local progressTimer = cc.ProgressTimer:create(sprite)
    progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progressTimer:setMidpoint(cc.p(0,0))
    progressTimer:setBarChangeRate(cc.p(1, 0))
    progressTimer:setPercentage(100)
    progressTimer:setPosition(300, 300)
    progressTimer:setLocalZOrder(1)
    self.gameScene:addChild(progressTimer)
end

function TestState:testSplite()
    local str = "BarrackModule9"
    local index = string.find(str, "Module")
    local sub = string.sub(str , index + 6)
    if sub ~= "" then
        local subAry = StringUtils:splitString(sub, "_")
        print(tonumber(subAry[1]))
        print(tonumber(subAry[2]))
    end
end

function TestState:testUISecLvPanelBg()
    local panel = {}
    panel.getParent = function()
        return self.gameScene
    end
    local secBg = UISecLvPanelBg.new(self.gameScene, panel)
    secBg:setContentHeight(500)
end

function TestState:testMainScene()
    local mainScene = MainScene.new()
    self.gameScene:addChild(mainScene)
end

MainScene = class("MainScene", function ()
    return UIMapNodeExtend.extend(cc.Layer:create())
end)

function MainScene:ctor()
    self._rootNode = cc.Layer:create()
    self:addChild(self._rootNode)
    
    self._minX = 0
    self._minY = 0
    self._maxX = 0
    self._maxY = 0
    
    self._mapWidth = 0
    self._mapHeight = 0
    self._bottom = 0
    self._scale = 1
    self._multBeganPoints = {}
    self._maxScale = 1.5
end

function MainScene:onEnter()
    self:initMap()
    self:registerEvent()
end

function MainScene:onExit()
end

function MainScene:registerEvent()
    self:touchOneByOne()
    self:touchAllAtOnce()
end

function MainScene:touchAllAtOnce()
    local listener = cc.EventListenerTouchAllAtOnce:create()
    local function onTouchesBegan(touches, event)
        self._isTouchBegan = true
        for i = 1,#touches do
            local point = touches[i]:getLocation()
            self._multBeganPoints[touches[i]:getId()] = point
            if 0 == touches[i]:getId() then
                self._firstTouchId = touches[i]:getId()
            elseif 1 == touches[i]:getId() then
                self._secondTouchId = touches[i]:getId()
                local firstPoint = self._multBeganPoints[self._firstTouchId]
                local secondPoint = self._multBeganPoints[self._secondTouchId]
                self._baseDistance = math.sqrt((firstPoint.x - secondPoint.x) * (firstPoint.x - secondPoint.x) + (firstPoint.y - secondPoint.y) * (firstPoint.y - secondPoint.y))
            elseif table.getn(touches) > 2 then
                local firstPoint = self._multBeganPoints[self._firstTouchId]
                local secondPoint = self._multBeganPoints[self._secondTouchId]
                local firstLong = math.abs(secondPoint.x - firstPoint.x)
                    + math.abs(secondPoint.y - firstPoint.y)
                local nextLong  = math.abs(point.x - firstPoint.x)
                    + math.abs(point.y - firstPoint.y)
                if nextLong > firstLong then
                    self._secondTouchId = touches[i]:getId()
                    local firstPoint = self._multBeganPoints[self._firstTouchId]
                    local secondPoint = self._multBeganPoints[self._secondTouchId]
                    math.sqrt((firstPoint.x - secondPoint.x) * (firstPoint.x - secondPoint.x) + (firstPoint.y - secondPoint.y) * (firstPoint.y - secondPoint.y))
                end
            end
        end
    end
    local function onTouchesMoved(touches, event)
        if 1 < #touches then
            self._isMultTouch = true
            local firstPoint = touches[self._firstTouchId + 1]:getLocation()
            local secondPoint = touches[self._secondTouchId + 1]:getLocation()
            if firstPoint and secondPoint then
                local curDistance = math.sqrt((firstPoint.x - secondPoint.x) * (firstPoint.x - secondPoint.x) + (firstPoint.y - secondPoint.y) * (firstPoint.y - secondPoint.y))
                local dscale = curDistance/self._baseDistance
                local scale  = dscale * self._scale
                self._baseDistance = curDistance
                self:setScale(scale)
            end
        end
    end
    local function onTouchesEnded(touches, event)
        if not self._isTouchBegan then
            return
        end
        if 1 < #touches then
            for i = 1,#touches do
                self._multBeganPoints[touches[i]:getId()] = nil
            end
            self._multBeganPoints = {}  
            self._baseDistance = 0
            self._isMultTouch = false
            self._isTouchBegan = false
        end
    end
    
    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED)
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

---

local isScale = false
function MainScene:onTouchBegan(touch, event)
--    if isScale == false then
--        self:setScale(math.random(0.5,1.5))
--        isScale = true
--    end
    return true
end

function MainScene:onTouchMoved(touch, event)
    local delta = touch:getDelta()
    self:onSceneMove(delta)
end

function MainScene:onTouchEnd(touch, event)
end

function MainScene:touchOneByOne()
    local listener = cc.EventListenerTouchOneByOne:create()
--    listener:setSwallowTouches(true)

    local function onTouchBegan(touch, event)
        return self:onTouchBegan(touch, event)
    end
    local function onTouchMoved(touch, event)
        self:onTouchMoved(touch, event)
    end
    local function onTouchEnded(touch, event)
        self:onTouchEnd(touch, event)
    end

    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function MainScene:initMap()
    local winSize = self:getContentSize()
    
    local width = 0
    local height = 0
    local lastSize = cc.size(0,0)
    local lastx, lasty = 0, 0
    for y=2, 1, -1 do  --暂时支持两行
        lastx = 0
        local dy = lasty + lastSize.height / 2
        lastSize = cc.size(0,0)
    	for x=1, 4 do
            local url = "images/mainScene/COK_0" .. (x + (y - 1) * 4) .. ".png"
--    		local sprite = cc.Sprite:create("bg/scene/COK_0" .. (x + (y - 1) * 4) .. ".png")
            local sprite = TextureManager:createSprite(url)
            self._rootNode:addChild(sprite)
            local size = sprite:getContentSize()
            

            lastx = lastx + lastSize.width / 2 + size.width / 2
            lasty = dy + size.height / 2
            
            sprite:setPosition(lastx,lasty)
            
            if y == 1 then
                self._mapWidth = self._mapWidth + size.width
            end
            
            if x == 1 then
                self._mapHeight = self._mapHeight + size.height
            end
            
            lastSize = size     
    	end
    end
    
    self._mapSize = cc.size(self._mapWidth, self._mapHeight)
    local vSize = cc.Director:getInstance():getWinSize()
    self._minScale = vSize.height / self._mapHeight --1 --
    self:resetLimitHeight()
end

function MainScene:onSceneMove(delta)
    local posX,posY = self:getPosition()
    self:setPosition(posX + delta.x, posY + delta.y)
end


function MainScene:resetLimitHeight()
    local vSize = cc.Director:getInstance():getWinSize()
    local sSize = self._mapSize
    
    self._maxX = vSize.width * (self._scale - 1) / 2 
    self._maxY = vSize.height * (self._scale - 1) / 2
    self._minX = vSize.width - sSize.width * self._scale + vSize.width * (self._scale - 1) / 2
    self._minY = vSize.height - sSize.height * self._scale + vSize.height * (self._scale - 1) / 2

end


function MainScene:getPosition()
    return self._rootNode:getPosition()
end

function MainScene:setPosition(x, y)

    if x < self._minX then
        x = self._minX
    end
    
    if y < self._minY then
        y = self._minY
    end
    
    if x > self._maxX then
        x = self._maxX
    end
    
    if y > self._maxY then
        y = self._maxY
    end

    self._rootNode:setPosition(x, y)
end

function MainScene:setScale(scale)
    if scale < self._minScale then
        scale = self._minScale
    end
    if scale > self._maxScale then
        scale = self._maxScale
    end
    self._scale = scale
    self:resetLimitHeight()
    self._rootNode:setScale(scale)
    
    if scale < 1 then
        self:onSceneMove(cc.p(0,0))
    end
end


------------------------------------------------------------

function TestState:testRoate()
    local bullet = SpineEffect.new("qi01_atk", self.gameScene, true)
    bullet:setPosition(300, 420)
    bullet:setDirection(-1)
    bullet:setRotation(30)
end

function TestState:testGetStringSize()
    local size, charSize = StringUtils:getStringSize("我的")
    print(size, charSize)
end

function TestState:testSortList()
    local sortList = SortList.new(6, "a")
    sortList:add({a = 1})
    sortList:add({a = 11})
    sortList:add({a = 21}, "a")
    sortList:add({a = 13}, "a")
    sortList:add({a = 12}, "a")
    sortList:add({a = 41}, "a")
    sortList:add({a = 15}, "a")
    sortList:add({a = 43}, "a")
    sortList:add({a = 10}, "a")
    
    sortList:print()
end

function TestState:testJson()
    local time = os.clock()
    local tmp = '[1,2,3]'
    local data = {1, 2, 3} --StringUtils:jsonDecode(tmp)
    print(os.clock() - time)

    local str = [[{"version":"6","url":"http:\/\/download-pt.kkk5.com\/yunying\/gcol\/20160720\/gcol_0_6397.apk","versionUrl":"http:\/\/203.195.140.103:8888\/gcol\/testModule\/version.lua"}]]
    str = string.gsub(str, "\\/", "/")
    require("json")
    local data = json.decode(str)
    print(data.versionUrl)
end

function TestState:testLayerTouch()
    
    local function onTouchBegan(touch, event)
        if not self:isPointInTopHalfAreaOfScreen(touch:getLocation()) then
            return false
        end
        local target = event:getCurrentTarget()
        assert(target:getTag() == TAG_BLUE_SPRITE, "Yellow blocks shouldn't response event.")
        if self:isPointInNode(touch:getLocation(), target) then
            target:setOpacity(180)
            return true
        end
        event:stopPropagation()
        return false
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        target:setOpacity(255)
    end

    local touchOneByOneListener = cc.EventListenerTouchOneByOne:create()
    touchOneByOneListener:setSwallowTouches(true)
    touchOneByOneListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    touchOneByOneListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    
--    
    local uiSkin = UISkin.new("UIResolvePreview")
    uiSkin:setParent(self.gameScene)
    uiSkin:setTouchEnabled(false)
    
    local layer = cc.Layer:create()
    self.gameScene:addChild(layer)
    
--    local rootNode = uiSkin:getRootNode()
--
--    local rootNode = ccui.Layout:create()
--    rootNode:setLocalZOrder(1000)
--    --    rootNode:setTouchEnabled(true)
--    rootNode:setContentSize(cc.size(640,960))
--    layer:addChild(rootNode)
    
--    local rootNode = ccui.Layout:create()
----    rootNode:setTouchEnabled(true)
--    rootNode:setContentSize(cc.size(640,960))
--    layer:addChild(rootNode)
    
--    local function checkTouches(touches, event)
--        print("-------------checkTouches---sss--------")
--    end
--    
--    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(checkTouches,-1)
    
    local function onTouchesBegan(touches, event)
        print("-------------onTouchesBegan-----------")
    end

    local function onTouchesEnd(touches, event)

    end
    

    local touchAllAtOnceListener = cc.EventListenerTouchAllAtOnce:create()
    touchAllAtOnceListener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    touchAllAtOnceListener:registerScriptHandler(onTouchesEnd,cc.Handler.EVENT_TOUCHES_ENDED )
    
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(
        touchAllAtOnceListener:clone(), layer)
end

function TestState:testClippingNode()
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setInverted(false)
    clippingNode:setAlphaThreshold(0.0)
    
    local sprite = TextureManager:createSprite("images/common/image210.png")
    sprite:setPosition(300,300)
    clippingNode:setStencil(sprite)
    
    self.gameScene:addChild(clippingNode)
    
    local text = ccui.Text:create()
    text:setString("hello")
    text:setFontSize(30)
    text:setPosition(500,300)
    clippingNode:addChild(text)
    
    local move = cc.MoveTo:create(5,cc.p(10, 300))
    text:runAction(move)
end

function TestState:testSpineModelPool()
    
    local model = SpineModel.new(101, self.gameScene)
    model:setPosition(200, 300)
    model:playAnimation("win", true)
    model:setScale(2)
--    local function createToo()
--        local model = SpineModel.new(101, self.gameScene)
--        model:setPosition(200, 300)
--        model:playAnimation("win", true)
--    end
--    
--    local function remove()
--        model:finalize()
--        TimerManager:addOnce(2000,createToo, self)
--    end
--    
--    TimerManager:addOnce(2000,remove, self)
end

function TestState:testSpineEffect()
    local spineEffect = SpineEffect.new("gong01_hit", self.gameScene)
    spineEffect:setPosition(200, 300)
    
    spineEffect:setDirection(1)
end

function TestState:testSharder()

end

function TestState:testUIAdapt()
    local uiSkin = UISkin.new("UIResolvePreview")
    uiSkin:setParent(self.gameScene)
    
    local mainPanel = uiSkin:getChildByName("mainPanel")
--    mainPanel:setContentSize(640, 800)
    NodeUtils:adaptivePanel(mainPanel,2,3,100)  --1 2 3
    
    for index=4, 5 do
    	local iconPanel = uiSkin:getChildByName("mainPanel/midBg/iconPanel" .. index)
    	iconPanel:setVisible(false)
    end
end

function TestState:testUITip()
    local uiTip = UITip.new(self.gameScene)
----    uiTip:setPosition(300, 300)
----    uiTip:setTip([[<font face="fn24" color = "#e6ffe0">这个一个测试个一个测试文这个一个测试个一个测试文本个一测试个一个测试文这个一个测试个一个测试文本个一个测试文本个一个测试文本文本本个一个测试文本个一个测试测试个一个测试文这个一个测试个一个测试文本个一个测试文本个一个测试文本文本本个一个测试文本个一个测试个测试文本个一个测试文本文本本个一个测试文本个一个测试文本文本</font>]])
--
    local line1 = {{content = "这是第一行"}, {content = "这是第一行第二段文本", foneSize = 22, color = "#ff0000"}}
--    local line2 = {{content = "这是第2行", foneSize = 24}}
--    local line3 = {{content = "这是第3行", foneSize = 22, color = "#ff0000"}}
--    
    local lines = {}
    table.insert(lines, line1)
--    table.insert(lines, line2)
--    table.insert(lines, line3)
--    
    uiTip:setAllTipLine(lines)
--    
    --繁荣2级　繁荣要求（11）
--    local label = ComponentUtils:createRichNodeWithString(
--        [[<font face="fn24" color = "#e6ffe0">111</font>]],cc.size(300 - 40,0))
--    label:setPosition(320 + 20, 300)
--    label:setAnchorPoint(cc.p(0, 0.5))
--    self.gameScene:addChild(label)
--    
--    local text = ccui.Text:create()
--    text:setString("-----个测试文---------")
--    text:setPosition(320 + 20, 500)
--    text:setAnchorPoint(cc.p(0, 0.5))
--    self.gameScene:addChild(text)
end

function TestState:testAnimation()

    local uiSkin = UISkin.new("BattlePanel")
    uiSkin:setParent(self.gameScene)
    
--    local mapPanel = uiSkin:getChildByName("mainPanel/starImg1")
    
    local parent = self.gameScene --mapPanel--
    local function dataLoaded(percent)
        if percent >= 1 then
            local armature = ccs.Armature:create("001")
            armature:getAnimation():play("Animation1")
            parent:addChild(armature)

            local function animationEvent(armatureBack,movementType,movementID)
            end
            armature:getAnimation():setMovementEventCallFunc(animationEvent)
        end
    end
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(
        "effect/001.ExportJson", dataLoaded)
end

function TestState:testTopListView()
    local uiSkin = UISkin.new("BarrackRecruitPanel")
    uiSkin:setParent(self.gameScene)
    
    local listView = uiSkin:getChildByName("listView")
    
    local item = listView:getItem(0)
    listView:setItemModel(item)
    local nameTxt = item:getChildByName("nameTxt")
    nameTxt:setString("0000000000000")
    
    listView:pushBackDefaultItem()
    listView:pushBackDefaultItem()
    
    local item1 = listView:getItem(1)
    local nameTxt = item1:getChildByName("nameTxt")
    nameTxt:setString("11111111111111111")
    
    local item2 = listView:getItem(2)
    local nameTxt = item2:getChildByName("nameTxt")
    nameTxt:setString("222222222222")
    
    local function callback(self)
        ComponentUtils:topListViewByIndex(listView, 2)
    end
    
    ComponentUtils:addTouchEventListener(item2,callback, nil, self)
    
--   
--    TimerManager:addOnce(2000, callback, self) 
end

function TestState:testCamera()
    local a = {readyaction = {"formationtab","1",180} }
end

function TestState:testInt64()
--    local str = string.formatNumberByK(9223372036854775808)
--    print(str)
--    local i = 1111111111 * 2111
--    
--    local num = tonumber("111111111111112221111")
--    if num > 999999999 then
--        local divider = 1000000000
--        print(num / divider)
--    end
--    print(i, num)
end

function TestState:makeZhenfa()
    local uiSkin = UISkin.new("battle_2")
    uiSkin:setParent(self.gameScene)
    local zhenfaPanel = uiSkin:getChildByName("zhenfaPanel")
    
    local zhenfaIdList = {}
    
    local children = zhenfaPanel:getChildren()
    for _, child in pairs(children) do
        local name = child:getName()
        local nstr = string.gsub(name,"zhenfa","")
        local zAry = StringUtils:splitString(nstr, "_")
        local id = tonumber( zAry[1] )
        local camp = zAry[2] == "R" and 2 or 1
        table.insert(zhenfaIdList, {id = id, camp = camp, key = nstr})
    end
    
    
    local config = "local ZhenfaConfig = {}\n"
    local uid = 1
    for _, data in pairs(zhenfaIdList) do
        local id = data.id
        local camp = data.camp
    	local zhenfa = zhenfaPanel:getChildByName("zhenfa" .. data.key )
    	local children = zhenfa:getChildren()
        for _, child in pairs(children) do
    		local name = child:getName()
            local indexStr = string.gsub(name,"p","")
            local index = tonumber( indexStr )
    		local x, y = child:getPosition()
            local info = string.format("ZhenfaConfig[%d] = {type = %d, eye = %d, camp = %d, x = %f, y = %f }\n", uid, id, index, camp, x, y)
            config = config .. info
            uid = uid + 1
    	end
    end
    config = config .. "return ZhenfaConfig"
    
    local f = io.open("../../res/excelConfig/ZhenfaConfig.lua","w")
    f:write(config)
    f:close()
    
    do
        return
    end
    
    require("modules.battle.core.const.BattleConst")
    require("modules.battle.core.Battle")
    require("modules.battle.core.Puppet")
    require("modules.battle.core.PuppetFactory")
    
    local type = 1
    local modelType = 101
    local animation = "win"
    local scale = 1
    require("excelConfig.ZhenfaConfig")
    
    zhenfaPanel:setVisible(false)
    
    local mapPanel = uiSkin:getChildByName("mapPanel")
    mapPanel:setVisible(true)
    for index=11, 16 do
        local indexPanel = mapPanel:getChildByName("indexPanel" .. index)
        indexPanel:setLocalZOrder(960 - indexPanel:getPositionY())
        
        local attr = {}
        attr.index = index
        attr.modelType = modelType
        attr.zhenfa = type
        attr.scale = scale
        local puppet = battleCore.Puppet.new(attr, indexPanel)
        puppet:playAnimation(animation, true)
    end
    for index=21, 26 do
        local indexPanel = mapPanel:getChildByName("indexPanel" .. index)
        indexPanel:setLocalZOrder(960 - indexPanel:getPositionY())
        
        local attr = {}
        attr.index = index
        attr.modelType = modelType
        attr.zhenfa = type
        attr.scale = scale
        local puppet = battleCore.Puppet.new(attr, indexPanel)
        puppet:playAnimation(animation, true)
    end

    local bg = TextureManager:createImageViewFile("bg/battle/bg.jpg")
    bg:setAnchorPoint(cc.p(0, 0)) --TODO记得释放
    bg:setLocalZOrder(0)
    mapPanel:addChild(bg)
    
    
end

function TestState:testIcon()
    local data = {}
    data["power"] = GamePowerConfig.Item
    data["typeid"] = 1024
    data["num"] = 1
    local icon = UIIcon.new(self.gameScene, data)
    icon:setPosition(300, 300)
end

function TestState:testHtml()
--    require("framework.utils.html")
   -- framework.utils.html.parse("hello")
    local label = cc.CCHTMLLabel:createWithString([[<a id="11" name="ss"><font face="fn18" color="#80d313">111</font></a>]], cc.size(100, 30))
    
    local function callback(id, name)
        print("...click...", id, name)
        self:showSysMessage("...click..." .. id .. name)
    end
    
    label:registerLuaClickListener(callback)
    
    label:setPosition(300, 300)
    self.gameScene:addChild(label)
    
--    local text = ccui.Text:create()
--    text:setString("整除")
--    text:setPosition(300, 200)
--    self.gameScene:addChild(text)
--    print("", label)
end

function TestState:testConfig()
    local time = os.clock()
    local info = ConfigDataManager:getInfoFindByOneKey(ConfigData.ChapterConfig,"sort",1)
    print(info.name, os.clock() - time)
    
    local time = os.clock()
    local infos = ConfigDataManager:getInfosFilterByOneKey(ConfigData.ChapterConfig,"sort",1)
    for _, info in pairs(infos) do
        print(info.name)
    end
--    print(info.name, os.clock() - time)
end

function TestState:testIDrag()
    local gameScene = self.gameScene
    local TestDrag = class("TestDrag", IDrag)
    function TestDrag:getWidget()
        if self.wiget ==nil then
            local sprite = TextureManager:createImageView("images/map/res1.png")
            gameScene:addChild(sprite)
            sprite:setPosition(300,300)
            
--            local pos = sprite:getWorldPosition()
            
            self.wiget = sprite
        end
        return self.wiget
    end
    
    TestDrag.new()
    TestDrag.new()
    
end

function TestState:testSpine()
    
    
    
    -- local actionList = {"attack", "die", "hurt", "run", "wait", "win"}
    -- for _, action in pairs(actionList) do
    --     local model = SpineModel.new(1002, self.gameScene)
    --     model:playAnimation(action, true)
    --     model:setPosition(math.random(10,600), math.random(10,600))
    -- end
    self.gameScene:setVisible(true)
    local jsonUrl = "model/109/skeleton.json"
    local atlasUrl = "model/109/skeleton.atlas"
    local spine = sp.SkeletonAnimation:create(jsonUrl, atlasUrl)
    self.gameScene:addChild(spine)
    --spine:setParent(self.gameScene)
    spine:setAnimation(0, 'attack', true)
    spine:setPosition(320,480)
    cc.Director:getInstance():getScheduler():setTimeScale(3.6)
end

function TestState:testMap()

    require("modules.map.map.MapDef")
    require("modules.map.map.WorldMap")
    require("modules.map.map.WorldMapFloor")
    
    
    local map = WorldMap.new()
    self.gameScene:addChild(map)

--    local mapFloor = WorldMapFloor.new(MapRes.worldMapRes)
--    mapFloor:setMapPosition(cc.p(0, 0))
--    self.gameScene:addChild(mapFloor)
    
--    local map = UIBaseMap.new()
--    self.gameScene:addChild(map)
--    local tileWidth = 256
--    local tileHeight = 128
--    
--    local scrollView = ccui.ScrollView:create()
--    scrollView:setDirection(ccui.ScrollViewDir.both)
--    scrollView:setContentSize(cc.size(640,960))
--    scrollView:setInnerContainerSize(cc.size(128 * 343,64 * 171))
--    
--    local map = cc.TMXTiledMap:create("map/map.tmx")
--    scrollView:addChild(map)
--    local mapPanel = ccui.Layout:create()
--    
--    scrollView:addChild(mapPanel)
--    
--    for x=0, 343 do
--    	for y=0, 171 do
--    	    local index = (x + y) % 2 + 1
--    		local tile = cc.Sprite:create("map/" .. index .. ".png")
--    		tile:setAnchorPoint(cc.p(0,0))
--            tile:setPosition(x * tileWidth / 2 , x * tileHeight / 2 + y * tileHeight)
--    		mapPanel:addChild(tile)
--    	end
--    end
    
--    local tile = cc.Sprite:create("map/1.png")
--    mapPanel:addChild(tile)
--    
--    local tile2 = cc.Sprite:create("map/2.png")
--    tile2:setPosition(256 / 2, 128 / 2)
--    mapPanel:addChild(tile2)
    
--    self.gameScene:addChild(scrollView)
end


function TestState:testTiledMap()
    -- 瓦片地图测试
    -- tiled地图CVS格式会导致模拟器崩溃 ！！！
    
    print("··· -- 瓦片地图测试 .....................")

    -- 世界地图配表格式测试
    -- id = '000_001' ：表示瓦片坐标(0, 1)
    -- gid = 2        : 表示瓦片使用的图块
    -- color = ColorUtils.wordRedColor  ：瓦片颜色
    local mapConf = {
        {id = '000_000', gid = 1, color = ColorUtils.wordRedColor},
        {id = '000_001', gid = 2, color = ColorUtils.wordOrangeColor},
        {id = '001_001', gid = 1, color = ColorUtils.wordRedColor},
        {id = '002_002', gid = 2, color = ColorUtils.wordOrangeColor},
        {id = '003_001', gid = 1, color = ColorUtils.wordRedColor},
        {id = '000_002', gid = 2, color = ColorUtils.wordBlueColor},
        {id = '001_001', gid = 1, color = ColorUtils.wordGreenColor},
        {id = '002_002', gid = 2, color = ColorUtils.wordBlueColor},
        {id = '003_001', gid = 1, color = ColorUtils.wordGreenColor},
    }

    local conf = {}
    for k,v in pairs(mapConf) do
        conf[v.id] = v
    end


    local url = "map/map2.tmx"
    local tmxTiledMap = ccexp.TMXTiledMap:create(url)
    if tmxTiledMap == nil then
        print("···tmxTiledMap = nil...  ", url)
        return
    end

    local mapSize = tmxTiledMap:getMapSize()  --瓦块数量
    local tileSize = tmxTiledMap:getTileSize() --单个瓦块大小
    local width = mapSize.width * tileSize.width
    local height = mapSize.height * tileSize.height

    print("tmxTiledMap ··· width, height", width, height)


    local group = tmxTiledMap:getObjectGroup("Objects")
    if group ~= nil then
        local objects = group:getObjects()
        for k,obj in pairs(objects) do
            if rawget(obj, "type_wood") == true then
                print("00 ··· 发现木头对象 ", k)
            end

            local url = nil
            if obj.type == "type_wood" then
                print("11 ··· 发现木矿对象 ", k)
                url = "images/map/res3.png"

            elseif obj.type == "type_iron" then
                print("11 ··· 发现银矿对象 ", k)
                url = "images/map/res1.png"
            elseif obj.type == "type_stone" then
                print("11 ··· 发现石矿对象 ", k)
                url = "images/map/res1.png"
            elseif obj.type == "type_steel" then
                print("11 ··· 发现铁矿对象 ", k)
                url = "images/map/res1.png"
            elseif obj.type == "type_iron" then
                print("11 ··· 发现银矿对象 ", k)
                url = "images/map/res1.png"
            elseif rawget(obj, "type") then
                print("11 ··· 发现对象 ", k, obj.type)
                if obj.name == "color" then

                    local colorX = math.floor(obj.x/tileSize.width)
                    local colorY = math.floor(obj.y/tileSize.height)
                    local colorW = math.floor(obj.width/tileSize.width)
                    local colorH = math.floor(obj.height/tileSize.height)
                    print("处理color对象... ", colorX, colorY, colorW, colorH)

                    local mapLayer  = tmxTiledMap:getLayer("layer")  --获取地图的指定图层
                    for x=colorX,colorX + colorW - 1 do
                        for y=colorY,colorY + colorH - 1 do
                            local tile = mapLayer:getTileAt(cc.p(x, math.floor(mapSize.height - y - 1)))
                            tile:setColor(ColorUtils.wordBlueColor)
                            print(" ··· 变色啦..", x, y)
                        end
                        
                    end

                    break
                else
                    url = "images/map/res1.png"
                end
            else
                print("···当前对象不用处理",obj.id, obj.name)
                break
                -- return
            end

            local function onSpriteBtnTouch(sender, eventType)
               if eventType == ccui.TouchEventType.ended then
                   print("=== onSpriteBtnTouch ended")
                   self:showSysMessage("=== onSpriteBtnTouch ended")
               end
            end
            
            local plist = TextureManager:getUIPlist(url)
            cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
            
            local button = ccui.Button:create()
            
            button:setPosition(cc.p(obj.x, obj.y))
            button:loadTextures(url, url, "", 1)
            button:addTouchEventListener(onSpriteBtnTouch)
            tmxTiledMap:addChild(button)
        end
    else
        print("当前地图没有对象 ··· ")

    end


    local scrollView = ccui.ScrollView:create()
    scrollView:setDirection(ccui.ScrollViewDir.both)
    scrollView:setContentSize(cc.size(640,960))
    scrollView:setInnerContainerSize(cc.size(width,height))
    scrollView:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)

    scrollView:addChild(tmxTiledMap)
    self.gameScene:addChild(scrollView)


    local function onScrollViewTouch(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
            print("=== onScrollViewTouch ended")
           
            local pos = sender:getTouchEndPosition()   --触摸点坐标
            pos = tmxTiledMap:convertToNodeSpace(pos)  --触摸点坐标转到地图坐标系

            -- 计算得出瓦片坐标(x,y)
            local x = pos.x/tileSize.width
            local y = (mapSize.height * tileSize.height - pos.y) / tileSize.height
            local tilePos = cc.p(math.floor(x), math.floor(y))

            print("map current tile ··· (x, y)", x, y, pos.x, pos.y)

            local layer  = tmxTiledMap:getLayer("layer")  --获取地图的指定图层
            -- local sprite = layer:getTileAt(tilePos)  --获取当前触摸点的对应瓦片
            
            -- 点击更换当前瓦片的图块素材显示
            -- local gid = layer:getTileGIDAt(tilePos)  --获取当前瓦片的GID编号
            -- if gid == 1 then
            --     gid = 2
            -- else
            --     gid = 1
            -- end

            local gid = layer:getTileGIDAt(tilePos)  --获取当前瓦片的GID编号
            local id = string.format("%03d",tilePos.x) .. '_' .. string.format("%03d",tilePos.y)  --id格式 000_000
            print("id ··· ", id)
            if conf[id] ~= nil then
                gid = conf[id].gid

                local sprite = layer:getTileAt(tilePos)  --获取当前触摸点的对应瓦片
                sprite:setColor(conf[id].color)
            end


            layer:setTileGID(gid, tilePos)  --给当前瓦片设置新的GID
            print(" 全局GID ··· ", gid)


       end
    end
    scrollView:addTouchEventListener(onScrollViewTouch)

    local function onTouchMoved(touches, event)     
       local count = table.getn(touches)   
       print("  onTouchMoved   Number of touches: ",count)
    end
    local function onTouchBegan(touches, event)
       onTouchMoved(touches, event)
    end

    scrollView:setTouchEnabled(true)

    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCHES_MOVED )

    local eventDispatcher = scrollView:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, -100)


end


function TestState:testUIComponent()
    
--    local uiLoading = UILoading.new(self.gameScene)
--    uiLoading:show("加载中")
--     local uiSkin = UISkin.new("UIPanelBg")
--     local bgImg = uiSkin:getChildByName("bgImg")
--     NodeUtils:adaptive(bgImg)
--     uiSkin:setParent(self.gameScene)
--     uiSkin:setTouchEnabled(false)
    
--     local closeBtn = uiSkin:getChildByName("titleBg/closeBtn")
--     closeBtn.srcPos = cc.p(closeBtn:getPosition())
    
--     local closeBtn2 = closeBtn:clone()
--     closeBtn:getParent():addChild(closeBtn2)
--     local x, y = closeBtn.srcPos.x - 90, closeBtn.srcPos.y
--     closeBtn2:setPosition(x, y)
--     closeBtn2.srcPos = cc.p(closeBtn2:getPosition())
    
--     local TestDrag = class("TestDrag", IDrag)
-- --    function TestDrag:getWidget()
-- --        return closeBtn
-- --    end
--     closeBtn.drag = TestDrag.new(closeBtn)
    
    
--     local TestDrag2 = class("TestDrag2", IDrag)
-- --    function TestDrag2:getWidget()
-- --        return closeBtn2
-- --    end

--     closeBtn2.drag = TestDrag2.new(closeBtn2)
    
    
--    bgImg:setTouchEnabled(true)
--    bgImg:addTouchEventListener(onTouchHandler)
    
--    UITabControl.new(self.gameScene)

    self._loadSkin = UISkin.new("UILoading")
    self._loadSkin:setParent(self.gameScene)
    
    self._contentTxt = self._loadSkin:getChildByName("mainPanel/contentTxt")
    self._bgImg = self._loadSkin:getChildByName("mainPanel/Image_2")
    local Image_17 = self._loadSkin:getChildByName("mainPanel/Image_17")
    
    --self._contentTxt:setVisible(false)
    self._loadSkin:setVisible(false)
    Image_17:setVisible(false)
    self._contentTxt:setLocalZOrder(10)
    self._bgImg:setVisible(false)

    content = content or ""
    self._loadSkin:setVisible(true)
    self._contentTxt:setString(content)

    local mainPanel = self._loadSkin:getChildByName("mainPanel")
    local size = mainPanel:getContentSize()
    
    if self._zhuanpan == nil then
        local imageView = TextureManager:createSprite("images/common/zhuanpan.png")
        self._zhuanpan = imageView
        mainPanel:addChild(imageView)
        imageView:setPosition(size.width / 2 + 5, size.height / 2 - 6)
    end
    
    -- self._rpg_spoon = UIMovieClip.new("rpg-spoon")
    -- self._rpg_spoon:setParent(mainPanel)
    -- self._rpg_spoon:play(true)
    -- self._rpg_spoon:setPosition(size.width / 2, size.height / 2)

    self._rpg_acompass = UIMovieClip.new("rpg-Acompass")
    self._rpg_acompass:setParent(mainPanel)
    self._rpg_acompass:play(true)
    self._rpg_acompass:setPosition(size.width / 2, size.height / 2)

end

function TestState:testCountDown()
    CountDownManager:add(10, self.onTick, self)
end

function TestState:onTick(remainTime)
    print("===========TestState:onTick========", remainTime)
end

function TestState:testSocket()
    GameConfig.server = "127.0.0.1"
    GameConfig.port = 8080
    local link      = "ws://" .. GameConfig.server .. ":" .. GameConfig.port
    self.socket     = cc.WebSocket:create(link)
end

function TestState:testFullName()
    local name = framework.utils.StringUtils:getFullName("s999.我的名字")
    print(name)
end

function TestState:testOrbitCamera()
    local duration = 3
    local orbitFront = cc.OrbitCamera:create(duration*0.5,1,0,90,-90,0,0)
    local orbitBack = cc.OrbitCamera:create(duration*0.5,1,0,0,-90,0,0)
    
    local front = cc.Sprite:create("2.png")  --正面
    local back = cc.Sprite:create("1.png") --背面
    
    front:setPosition(420,320) 
    self.gameScene:addChild(front)
    back:setPosition(420,320)
    self.gameScene:addChild(back)
    
    front:setVisible(false)
    
    local function f2bcallback()
        print("==============f2bcallback=================")
        front:setVisible(false)
        --背面转正面
        local b2fAction = cc.Sequence:create(cc.Show:create(), orbitBack, 
            cc.Hide:create(), cc.TargetedAction:create(front,
                cc.Sequence:create(cc.Show:create(), orbitFront)), cc.CallFunc:create(self.b2fcallback))
        back:runAction(b2fAction)
    end
    
    local function b2fcallback()
        back:setVisible(false)
        --正面转背面
        local f2bAction = cc.Sequence:create(cc.Show:create(), orbitBack, 
            cc.Hide:create(), cc.TargetedAction:create(back,
                cc.Sequence:create(cc.Show:create(), orbitFront)), cc.CallFunc:create(self.f2bcallback))
        front:runAction(f2bAction)
        print("==============callback=================")
    end
    
    self.b2fcallback = b2fcallback
    self.f2bcallback = f2bcallback
    
    --背面转正面
    local b2fAction = cc.Sequence:create(cc.Show:create(), orbitBack, 
        cc.Hide:create(), cc.TargetedAction:create(front,
            cc.Sequence:create(cc.Show:create(), orbitFront)), cc.CallFunc:create(self.b2fcallback))
    back:runAction(b2fAction)
         
    
    
end

function TestState:testPlist()
--    local url = "ui/dungeon0.plist"
--    cc.SpriteFrameCache:getInstance():addSpriteFrames(url)
    
    local sprite = game.texture.TextureManager:createSprite("images/model/1.png")
    sprite:setPosition(420,320)
    self.gameScene:addChild(sprite)
end

local EdgeNode = class("EdgeNode") --边结构
function EdgeNode:ctor(x, y, next)
    self.x = x
    self.y = y
    self.next = next
end

local VertexNode = class("VertexNode") --顶点数据结构  包括一个EgeoNode链表，来处理邻接点
function VertexNode:ctor(type)
    self.type = type
    self.data = nil
    self.firstEdge = nil
    self.relationNodes = {}
end

function VertexNode:insertEdgeNode(vertexNode)
--    if self.firstEdge == nil then
--        self.firstEdge = edgeNode
--    else
--        local curNode = self.firstEdge
--        while curNode.next ~= nil do
--            curNode = curNode.next
--        end
--        curNode.next = edgeNode
--    end
    table.insert(self.relationNodes, vertexNode)
end

function VertexNode:getRelationNode(i)
    return self.relationNodes[i]
end

function VertexNode:traversal(fun)
--    local edgeNode = self.firstEdge
--    while edgeNode ~= nil do
--        fun(edgeNode.x, edgeNode.y)
--        edgeNode = edgeNode.next
--    end
end

local TILED_WIDTH = 32
local TILED_HEIGHT = 32
local MAP_HEIGHT = 45

local GraphMap = class("GraphMap")
function GraphMap:ctor()
    self.vertexNodeMap = {}
    
    self._stack = framework.structure.Stack.new() --临时保存路径节点的栈 
end

function GraphMap:build(tmxTiledMap)

    local mapStr = "<map>\n"
    for nodeType=0, 4 do
        local group = tmxTiledMap:getObjectGroup("node" .. nodeType)
        mapStr = mapStr .. string.format("<objectgroup name='%s'>\n","node" .. nodeType)
        local objects = group:getObjects()
        for _, object in pairs(objects) do
            if object["gid"] ~= nil then
                local type = tonumber(object["type"])
                local ntilex, ntiley = self:nodeTilePos(object.x,object.y)
                local vertexNode = VertexNode.new(nodeType)
                self.vertexNodeMap[ntilex .. "-" .. ntiley] = vertexNode
                
                mapStr = mapStr .. string.format("\t<object x='%d' y='%d' id='%d'/>\n", ntilex, ntiley, type)
            end
        end
        
        mapStr = mapStr .. "</objectgroup>\n"
    end
    
    mapStr = mapStr .. string.format("<objectgroup name='%s'>\n","edge")
    
    local group = tmxTiledMap:getObjectGroup("edge")
    local objects = group:getObjects()
    for _, object in pairs(objects) do
        if object["polylinePoints"] ~= nil then --直线连通处理
            local polylinepoints = object["polylinePoints"]
            local e1x = polylinepoints[1].x + object.x
            local e1y = object.y - polylinepoints[1].y
            local e2x = polylinepoints[2].x + object.x
            local e2y = object.y - polylinepoints[2].y

            local etx1 = self:xPos2Tile(e1x)
            local ety1 = self:yPos2Tile(e1y)
            local etx2 = self:xPos2Tile(e2x)
            local ety2 = self:yPos2Tile(e2y)
            
            logger:info("####   %d   %d",etx1, ety1)
            local vertexNode1 = self:getVertexNodeByPos(etx1, ety1)
            if vertexNode1 == nil then
                print("")
            end
            
            local vertexNode2 = self:getVertexNodeByPos(etx2, ety2)
--            local edgeNode1 = EdgeNode.new(etx2, ety2)
--            local edgeNode2 = EdgeNode.new(etx1, ety1)
            
            vertexNode1:insertEdgeNode(vertexNode2)
            vertexNode2:insertEdgeNode(vertexNode1)
            
            mapStr = mapStr .. string.format("\t<object x1='%d' y1='%d' x2='%d' y2='%d'/>\n", etx1, ety1, etx2, ety2)
        end
    end
    
    mapStr = mapStr .. "</objectgroup>\n</map>"
    
    self:exportMapXml(mapStr)
end

function GraphMap:exportMapXml(mapStr)
    local file = io.open("map.xml", "w")
    file:write(mapStr)
    file:close()
end

function GraphMap:traversal(x, y, fun)
    local vertexNode = self:getVertexNodeByPos(x,y)
    if vertexNode == nil then
        print("")
    end
    vertexNode:traversal(fun)
end

--寻找路径的方法
--cNode: 当前的起始节点currentNode 
--pNode: 当前起始节点的上一节点previousNode 
--sNode: 最初的起始节点startNode 
--eNode: 终点endNode 
function GraphMap:getPaths(cNode, pNode, sNode, eNode)
    local nNode = nil
    if cNode ~= nil and pNode ~= nil and cNode == pNode then
        return false
    end
    if cNode ~= nil then
        local i = 1
        self._stack:push(cNode)
        if cNode == eNode then
            --找到路径了
            return true
        else
            nNode = cNode:getRelationNode(i)
            while nNode ~= nil do
                if pNode ~= nil and (nNode == sNode or nNode == pNode or self._stack:isInState(nNode)) then
                    i = i + 1
                    nNode = cNode:getRelationNode(i)
                else
                -- 以nNode为新的起始节点，当前起始节点cNode为上一节点，递归调用寻路方法
                    if(self:getPaths(nNode, cNode, sNode, eNode)) then
                        self._stack:pop()
                    end
                    i = i + 1 --继续在与cNode有连接关系的节点集中测试nNode
                    nNode = cNode:getRelationNode(i)
                end
            end
            
            self._stack.pop()
            return false  
        end
    else
        return false
    end
end

--判断两个点是否 通过confunc判断连通
function GraphMap:isConnected(node1, node2, confunc)
    local x1 = node1.x
    local y1 = node1.y
    
    
end

function GraphMap:getVertexNodeByPos(x, y)
    return self.vertexNodeMap[x .. "-" .. y]
end

function GraphMap:xPos2Tile(xpos)
    return math.floor(xpos / TILED_WIDTH)
end

function GraphMap:yPos2Tile(ypos)
    return math.floor( (MAP_HEIGHT * TILED_HEIGHT - ypos) / TILED_HEIGHT )
end

--返回点的tile左边，Node的描点是0 0 
function GraphMap:nodeTilePos(x, y)
    local x = x + TILED_WIDTH / 2
    local y = y + TILED_HEIGHT / 2
    local tilex = self:xPos2Tile(x)
    local tiley = self:yPos2Tile(y)
    return tilex, tiley
end


function TestState:testWarMap()
    
    
	local tmxTiledMap = ccexp.TMXTiledMap:create("map/war.tmx")
	
    local sc = ccui.ScrollView:create()
    sc:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    sc:setDirection(ccui.ScrollViewDir.both)
    sc:setContentSize(cc.size(640,960))
    sc:setInnerContainerSize(cc.size(1280,1920))
    
    self.gameScene:addChild(sc)
    
    sc:addChild(tmxTiledMap)
    self._miningScale = 1
    
    local graphMap = GraphMap.new()
    graphMap:build(tmxTiledMap)
    
    local function adjacentPointFunc(x, y)
        print(x , y)
    end
    
--    graphMap:traversal(16, 17, adjacentPointFunc)
    
--    local group = tmxTiledMap:getObjectGroup("node4")
--    local objects = group:getObjects()
--    for _, object in pairs(objects) do
--        if object["gid"] ~= nil then --node
--            local ntilex, ntiley = self:nodeTilePos(object.x,object.y) --获取到的坐标是实际坐标
--            print(ntilex, ntiley)
--        elseif object["polylinePoints"] ~= nil then --直线连通处理
--            local polylinepoints = object["polylinePoints"]
--            local e1x = polylinepoints[1].x + object.x
--            local e1y = object.y - polylinepoints[1].y
--            local e2x = polylinepoints[2].x + object.x
--            local e2y = object.y - polylinepoints[2].y
--            
--            local etx1 = self:xPos2Tile(e1x)
--            local ety1 = self:yPos2Tile(e1y)
--            local etx2 = self:xPos2Tile(e2x)
--            local ety2 = self:yPos2Tile(e2y)
--            print(etx1, ety1, etx2,ety2)
--        end
--    end
end

function TestState:xPos2Tile(xpos)
    return math.floor(xpos / TILED_WIDTH)
end

function TestState:yPos2Tile(ypos)
    return math.floor( (MAP_HEIGHT * TILED_HEIGHT - ypos) / TILED_HEIGHT )
end

--返回点的tile左边，Node的描点是0 0 
function TestState:nodeTilePos(x, y)
    local x = x + TILED_WIDTH / 2
    local y = y + TILED_HEIGHT / 2
    local tilex = self:xPos2Tile(x)
    local tiley = self:yPos2Tile(y)
    return tilex, tiley
end


function TestState:testListView()
    self.root  = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/equipment_1.ExportJson")
    self.gameScene:addChild(self.root)
    
    local Panel_EquipInfo = self.root:getChildByName("Panel_EquipInfo")
    Panel_EquipInfo:setVisible(false)
    
    local Panel_choose = self.root:getChildByName("Panel_choose")
    local Panel_down = Panel_choose:getChildByName("Panel_down")
    
    local ListView_equip = Panel_down:getChildByName("ListView_equip")
    local Panel_item = Panel_down:getChildByName("Panel_item")
    
    Panel_choose:setVisible(true)
    
    ListView_equip:setItemModel(Panel_item)
    
    for index=1, 5 do
        ListView_equip:pushBackDefaultItem()
    end
    
    local items = ListView_equip:getItems()
    for _, item in pairs(items) do
    	item:setVisible(true)
    end
    
    local item0 = ListView_equip:getItem(0)
    local Panel_330 = item0:getChildByName("Panel_330")
    Panel_330:setVisible(false)
    self:listItemAdaptive(item0,60, "Image_238")
    
--    item0:setContentSize(cc.size(566,100))
--    local Image_238 = item0:getChildByName("Image_238")
--    Image_238:setContentSize(562, 200)
    
end

function TestState:listItemAdaptive(item, dy, bgKey)
    local bgImg = item:getChildByName(bgKey)
    local size = item:getContentSize()
    item:setContentSize(size.width, size.height - dy)
    
    size= bgImg:getContentSize()
    bgImg:setContentSize(size.width, size.height - dy)
    
    local children = item:getChildren()
    for _, child in pairs(children) do
    	local x, y = child:getPosition()
    	local name = child:getName()
    	if name ~= bgKey then
            child:setPosition(x, y - dy)
        else
            child:setPosition(x, y - dy / 2)
    	end
    end
end

function TestState:testTimerManger()
--    game.manager.TimerManager:init()
--    
--    local function delay(target, num)
--        print(num)
--    end
--    game.manager.TimerManager:add(1000, delay, self, 10, 1)
--    
--    local function delay(num)
--        print(num)
--    end
--    game.manager.TimerManager:addOnce(500, delay, self, 2)

    local frameQueue1 = framework.structure.FrameQueue.new()
    local frameQueue2 = framework.structure.FrameQueue.new()
    
    local map = {}
    map[frameQueue1.pop] = 1
    map[frameQueue2.pop] = 1
    
    print(tostring(frameQueue1), tostring(frameQueue2))
end


function TestState:testutf8strlen()
    local str = "我在x这儿"
    local len = framework.utils.StringUtils:utfstrlen(str)
    print(len)
end

function TestState:testArgs()
    require ("pack")
    local function callback(...)
        local args = string.pack(...)
        for key, var in pairs(args) do
            if var == nil then
                print("nil")
            end
        	print(key, var)
        end
    end
    
    callback("1", "3", nil, "", 1)
end

function TestState:testShaders()
    local sprite = game.texture.TextureManager:createSprite("images/battleServer/1.jpg")
    sprite:setPosition(300,300)
    
    local program = cc.GLProgram:create("shaders/example_ColorBars.vsh", "shaders/example_ColorBars.fsh")
    program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
    program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
    program:link()
    program:updateUniforms()
    
    sprite:setGLProgram( program )
    
    
    self.gameScene:addChild(sprite)
end

function TestState:testExpandPageView()
    self.root  = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/soldier_1.ExportJson")
    self.gameScene:addChild(self.root)
    
    local action = ccs.ActionManagerEx:getInstance():getActionByName("soldier_1.ExportJson", "zhuangbei")
    action:play()
    
--    local panel240 = self.root:getChildByName("Panel240")
--    panel240:setVisible(true)
--    local pageView = panel240:getChildByName("Panel40"):getChildByName("PageView1")    
--    local item = panel240:getChildByName("Panel40"):getChildByName("item")    
--    
--    local data = {}
--    for index=1, 10 do
--    	table.insert(data,1)
--    end
--    
--    for index=1, 4 do
--        local itemClone = item:clone()
--        itemClone.index = index
--        local indexTxt = itemClone:getChildByName("indexTxt")
--        indexTxt:setText(index .. "")
--        itemClone:setVisible(true)
--        pageView:addPage(itemClone)
--    end
    
    local function updatePageCallback(leftPageIndex, rightPageIndex)
        print(leftPageIndex, rightPageIndex)
--        local rightPage = pageView:getPage(rightPageIndex)
----        if rightPage == nil then
--            local itemClone = item:clone()
--            itemClone:setVisible(true)
----            pageView:addPage(itemClone)
--            pageView:insertPage(itemClone, 0)
--        end
    end
    
--    component.ExpandPageView.new(pageView, data, updatePageCallback)
    
end

function TestState:testExpandScrollView()

    self.root  = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/soldier_1.ExportJson")
    self.gameScene:addChild(self.root)

    local panel10 = self.root:getChildByName("Panel10")
    local listView = panel10:getChildByName("listView")
    
    local list = {}
    local index = 0
    while index < 30 do
        table.insert(list,{})
        index = index + 1
    end
    
    local function updateData(x, y)
        if list[y + 1] == nil then
            return
        end
        print("===========updateData====index=================", y)
        local item = listView:getItem(y)
        if item == nil then
            listView:pushBackDefaultItem()
            item = listView:getItem(y)
        end
        if item ~= nil then
            item:setVisible(true)
        end
    end
    
    listView.updateData = updateData
    local item = panel10:getChildByName("item")
    listView:setItemModel(item)
    
    local expandListView = component.ExpandListView.new(listView, 630, 154)
    
    expandListView:initListViewData(list)
    
end

function TestState:testRadian()
    local centerPoint = cc.p(0, 0)
    local indexPoint = cc.p(1, 1)
    local r = framework.math.MathHelper:calculateRotateRadian(centerPoint.x,centerPoint.y,indexPoint.x,indexPoint.y)
    local deg = math.deg(r)
    print(r, deg)
end

function TestState:updateInnerContainerSize()
    self._scInnerW = self._mapW * self._miningScale
    self._scInnerH = self._mapH * self._miningScale + self._headSizeH

    self._minMoveX = self._scw - self._scInnerW
    self._maxMoveX = 0
    self._minMoveY = self._sch - self._scInnerH
    self._maxMoveY = 0

    local x, _ = self._headBg:getPosition()
    self._headBg:setPosition(x, self._mapH * self._miningScale)

    self._miningScrollView:setInnerContainerSize(cc.size(self._scInnerW, self._scInnerH))
end

function TestState:testTouch()
    self._miningScale = 1
    local MAP_WIDTH = 255
    local MAP_HEIGHT = 255
    local TILED_WIDTH = 101
    local TILED_HEIGHT = 101
    
    self._scw = 613
    self._sch = 570
    
    self._mapW = MAP_WIDTH * TILED_WIDTH
    self._mapH = MAP_HEIGHT * TILED_HEIGHT
    
    self.root  = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/mining_1.ExportJson")
    self.gameScene:addChild(self.root)
    
    self.bgPanel = tolua.cast(self.root:getChildByName("bgPanel"), "ccui.Layout")
    self.miningPanel = tolua.cast(self.bgPanel:getChildByName("miningPanel"), "ccui.Layout")
    
--    local panel = ccui.Layout:create()
--    panel:setContentSize(cc.size(self._scw,self._sch))
    
    local sc = ccui.ScrollView:create()
    sc:setBackGroundColor(cc.c3b(0,255,0))
    sc:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    sc:setDirection(ccui.ScrollViewDir.both)
    sc:setContentSize(cc.size(self._scw,self._sch))
    self._miningScrollView = sc
    self.miningPanel:addChild(sc)
    
    local headBg = game.texture.TextureManager:createSprite("images/mining/headBg.png")
    headBg:setName("headImg")
    headBg:setAnchorPoint(cc.p(0,0))
    headBg:setPosition(0, self._mapH)
    local headSize = headBg:getContentSize()
    sc:addChild(headBg)
    
    self._headBg = headBg
    self._headSizeH = headSize.height
    
    self:updateInnerContainerSize()
    
--    local sc = cc.ScrollView:create()
--    sc:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH )
--    sc:setViewSize(cc.size(self._scw,self._sch))
--    sc:ignoreAnchorPointForPosition(true)
--    sc:setClippingToBounds(true)
--    sc:setBounceable(true)
--    sc:setDelegate()
    
    local function addTmxMap()

        local tmxTiledMap = ccexp.TMXTiledMap:create("mining/map.tmx")
        local mapSize = tmxTiledMap:getMapSize()
        local tileSie = tmxTiledMap:getTileSize()
        local width = mapSize.width * tileSie.width
        local height = mapSize.height * tileSie.height

        self._tmxTiledMapLayer = cc.Layer:create()
        
--        local sprite = game.texture.TextureManager:createSprite("images/common/bg_1.jpg")
--        self._miningScrollView:setContainer(sprite)
--        self._miningScrollView:updateInset()

        self._miningScrollView:addChild(tmxTiledMap)
        self._miningScrollView:addChild(self._tmxTiledMapLayer)
        
--        local sprite = game.texture.TextureManager:createSprite("images/mining/t" .. 2401 .. ".png")
--        self._miningScrollView:addChild(sprite)

        self._tmxTiledMap = tmxTiledMap

        local layer  = self._tmxTiledMap:getLayer("backgroud")
        self._tmxLayer = layer
        
        local sprite = self._tmxLayer:getTileAt(cc.p(1, 1))
        game.texture.TextureManager:updateSprite(sprite,"images/mining/t" .. 2401 .. ".png")
    end
   
   addTmxMap()
    
    local function onScrollViewTouch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("===")
        end
    end
    sc:addTouchEventListener(onScrollViewTouch)

    local function onTouchMoved(touches, event)     
        local count = table.getn(touches)   
        print("Number of touches: ",count)
    end
    local function onTouchBegan(touches, event)
        onTouchMoved(touches, event)
    end
    
    sc:setTouchEnabled(true)

    local listener = cc.EventListenerTouchAllAtOnce:create()
    
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCHES_MOVED )

    local eventDispatcher = sc:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, -100)
--    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._tmxTiledMapLayer)

    local function scrollViewEvent(sender, evenType)
    end
    self._miningScrollView:addEventListener(scrollViewEvent)
    
end

function TestState:testGsub()
    local src = "我尔萨等待"
    local res = string.gsub(src, "我", "")
    print(res)
end

function TestState:testVector2()
    local v1 = framework.physics.Vector2.new(10, 20)
    local v2 = framework.physics.Vector2.new(10, 30)
    local v3 = v1 + v2
    print(v3.x, v3.y)
    local v4 = v3 / 3
    print(v4.x, v4.y)
end

function TestState:testEffect()
    require("component.MovieClip")
    local mc = component.MovieClip.new("knifelight")
    local function callback()
    end
    mc:play(false, callback)
    mc:setParent(self.gameScene)
    mc:setPosition(300, 600)
end

function TestState:testModel()
    require("battle.renderer.C2dFSModel")
    local startModel = 1
    local endModel = 1
--    for id=startModel, endModel do
    self:createModel(20310)
--    end
    
--    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/model_ui_resouce_big_0.plist")
--    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName("images/model/20310.png")
--    local rect = spriteFrame:getRect()
--    local offset = spriteFrame:getOffset()
--    local textue = spriteFrame:getTexture()
--    local size = textue:getContentSize()
    print("")
--    
--    local id = 1
--    local texture, rect = game.texture.TextureManager:getUITexture("images/model/" .. id .. ".png")
--    
--    local width = rect.width
--    local height = rect.height
--
--    self._maxRow = 4
--    self._maxColumn = 3
--    local perWidth = width / self._maxColumn
--    local perHeight = height / self._maxRow
--    
--    local sprite = cc.Sprite:createWithTexture(texture,cc.rect(perWidth * 1, perHeight * 3, perWidth, perHeight - 1))
--
--    sprite:setScale(2.2)
--    sprite:setPosition(math.random(100,630),math.random(100,630))
--    self.gameScene:addChild(sprite)
--    
--    local sprite = cc.Sprite:createWithTexture(texture,cc.rect(perWidth * 1, perHeight * 2, perWidth, perHeight - 1))
--
--    sprite:setScale(2.2)
--    sprite:setPosition(math.random(100,630),math.random(100,630))
--    self.gameScene:addChild(sprite)
    
end

function TestState:createModel(id)
    local model = battle.renderer.C2dFSModel.new(id)
    model:playAnimation(1, true)

    model:setParent(self.gameScene)
    model:setPosition(math.random(100,630),math.random(100,630))

--    framework.coro.CoroutineManager:startCoroutine(self.delayChangeAction, self, model)

end

function TestState:delayChangeAction(model)
    while true do
    	coroutine.yield(60)
        local list = {1,2,3,4,5}
        local modelList = {1002,1003,1004}
        local action = math.random(2, #list)
        model:changeModel(modelList[math.random(1, #modelList)])
        model:playAnimation(action, true)
    end
end

function TestState:testScene()
    
    self._sceneWidth = 2048

    local layer = cc.LayerColor:create(cc.c4b(238,11,187,222))
    
    local clip = cc.ClippingNode:create()
    local mask = cc.DrawNode:create()
    local points = {cc.p(10, 0), cc.p(10, 900), cc.p(630, 900), cc.p(630, 0)}
    mask:drawPolygon(points, table.getn(points), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))
    clip:setStencil(mask)
    clip:addChild(layer)
 
--    self.layer2_1 = cc.Sprite:create("map/3032-1.png")
--    self.layer2_1:setAnchorPoint(cc.p(0,0))
--    self.layer2_1:setPosition(0,300)
    
    self.layer3 = cc.Sprite:create("map/3003.png")
    self.layer3:setAnchorPoint(cc.p(0,0))
    self.layer3:setPosition(0,0)
    
    self.layer4_1 = cc.Sprite:create("map/3004-1.png")
    self.lyaer4_2 = cc.Sprite:create("map/3004-2.png")
    self.layer4_1:setAnchorPoint(cc.p(0,0))
    self.lyaer4_2:setAnchorPoint(cc.p(0,0))
    self.layer4_1:setPosition(0,0)
    self.lyaer4_2:setPosition(290,0)
    
--    layer:addChild(self.layer2_1)
    layer:addChild(self.layer3)
    layer:addChild(self.layer4_1)
    layer:addChild(self.lyaer4_2)
    
    clip:setPosition(0, 10)
    self.gameScene:addChild(clip)
    
    self._scroll_1 = 0
    self._scroll_2 = 0
    self._scroll_3 = 0
    self._scroll_4 = 0
end

function TestState:countDown()
    while true do
        coroutine.yield(1)
        
    end
end

function TestState:update()
    
--    self._scroll_2 = self.layer2_2 + 1
    --if self._scroll_2 >=
end


function TestState:testPartic()
    -- local plist = TextureManager:getUIPlist(url)
    -- local filename = "Particles/" .. name .. ".plist"
    -- emitter = cc.ParticleSystemQuad:create(filename)
    -- self.gameScene:addChild(emitter, 10)


    local particle = cc.ParticleSystemQuad:create("particle/lines.plist")

    --particle:setEmitterMode(cc.PARTICLE_MODE_RADIUS)  --半径模式

    --particle:setStartRadius(150)   

    --particle:setEndRadius(150)

    particle:setAngle(0)   --设置角度

    particle:setAngleVar(360)  --设置角度变化率

    particle:setEmissionRate(20)  --设置每秒产生的粒子数

    particle:setLife(2)   --设置粒子存在时间

    particle:setLifeVar(1)--设置粒子存在时间变化率

    particle:setSpeed(500)  --设置运动速度

    particle:setSpeedVar(100)  --运动速度变化率

    particle:setStartSize(100)  --设置粒子开始时候大小(像素值)

    particle:setStartSizeVar(80)  --粒子开始时大小变化率

    particle:setEndSize(400)   --设置粒子结束时候大小(像素值)
    
    particle:setEndSizeVar(300)
    
    particle:setStartColor(cc.c4f(255.0, 255.0, 255.0, 0.0))
    
    particle:setStartColorVar(cc.c4f(0.0, 0.0, 0.0, 0))
    
    particle:setEndColor(cc.c4f(255.0, 255.0, 255.0, 1.0))
    
    particle:setEndColorVar(cc.c4f(0, 0, 0, 0.5))

    --particle:setEndSizeVar(8.0) --粒子结束时大小变化率

    --particle:setPosVar(cc.p(200,200))  --粒子位置变化率

    --particle:setBlendAdditive(true)  -- 设置加亮模式

    particle:setLocalZOrder(50)
    self.gameScene:addChild(particle)
    particle:setPosition(320,480)
end

function TestState:testPlist11()
    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames("ui/chat_ui_resouce_big_0.plist")
   -- TextureManager:loadPlistFrameByUrl("chat")

    --local sprite = cache:getSpriteFrameByName("images/chat/10703.png")
    local sprite = cc.Sprite:createWithSpriteFrameName("images/chat/10703.png")
    sprite:setPosition(320,480)
    self.gameScene:addChild(sprite)
end
local function onParticleSystemTestClicked()
    -- cclog("CCBParticleSystemTest");
    -- local scene  = cc.Scene:create()
    local  proxy = cc.CCBProxy:create()
    local  node  = CCBReaderLoad("ccb/ccb/MainScene.ccbi",proxy,nil)
    local  layer = node

    return layer
    -- if nil ~= HelloCocosBuilderLayer["mTestTitleLabelTTF"] then
    --     local ccLabelTTF = HelloCocosBuilderLayer["mTestTitleLabelTTF"]
    --     if nil ~= ccLabelTTF then
    --         ccLabelTTF:setString("ccb/ccb/TestParticleSystems.ccbi")
    --     end
    -- end
    -- if nil ~= scene then
    --     scene:addChild(layer)
    --     cc.Director:getInstance():pushScene(cc.TransitionFade:create(0.5, scene, cc.c3b(0,0,0))); 
    -- end 

    -- return scene
end

HelloCocosBuilderLayer = HelloCocosBuilderLayer or {}
HelloCocosBuilderLayer["onMenuTestClicked"] = function() end
HelloCocosBuilderLayer["onSpriteTestClicked"] = function() end
HelloCocosBuilderLayer["onButtonTestClicked"] = function() end
HelloCocosBuilderLayer["onAnimationsTestClicked"] = function() end
HelloCocosBuilderLayer["onParticleSystemTestClicked"] = function() end
HelloCocosBuilderLayer["onScrollViewTestClicked"] = function() end
HelloCocosBuilderLayer["onTimelineCallbackSoundClicked"] = function() end



local function HelloCCBTestMainLayer()
    print(type(cc.Scene))
    local  proxy = cc.CCBProxy:create()
    local  node  = CCBReaderLoad("cocosbuilderRes/ccb/HelloCocosBuilder.ccbi",proxy,HelloCocosBuilderLayer)
    local  layer = node
    return layer
end

function TestState:testNewCallCCBI()

    local function complete()
        print("!!!!!!!!!!!!!!!complete!!!!!!!!!!!!!!")
    end

    local function start()
        print("!!!!!!!!!!!!!!!start!!!!!!!!!!!!!!")
    end

    local owner = {}
    owner["complete"] = complete
    owner["start"] = start
    local ccbLayer = UICCBLayer.new("MainScene", self.gameScene)
    ccbLayer:setBlendAdditive(false)

--    local children = ccbLayer:getChildren()
--    for _, child in pairs(children) do
--        local particleSystemQuad = tolua.cast(child, "cc.ParticleSystem")
--        if particleSystemQuad ~= nil then
--             particleSystemQuad:setBlendAdditive(false)
--             print("~~~~~~~~~~~~~~~~~~~~~")
--        end
--    end
    

    do
        return
    end
    require "CCBReaderLoad"
    do
        ccb["MainScene"] = {}
        ccb["MainScene"]["complete"] = complete

        local  proxy = cc.CCBProxy:create()
        local  layer  = CCBReaderLoad("ccb/ccb/MainScene.ccbi", proxy, ccb["MainScene"])
        self.gameScene:addChild(layer)
        return
    end

    local  proxy = cc.CCBProxy:create()
    local ccbReader = proxy:createCCBReader()
    local node = ccbReader:load("ccb/ccb/MainScene.ccbi")

    local animationManagers = ccbReader:getAnimationManagersForNodes()
    local nodes = ccbReader:getOwnerCallbackNodes()

    --print("!!!!!", ccbReader:isJSControlled())

    

    for _, animationManager in pairs(animationManagers) do
--        
       local keyframeCallbacks = animationManager:getKeyframeCallbacks()
       for _, callbackCombine in pairs(keyframeCallbacks) do
           local beignIndex,endIndex = string.find(callbackCombine,":")
           local callbackType	= tonumber(string.sub(callbackCombine,1,beignIndex - 1))
           local callbackName	= string.sub(callbackCombine,endIndex + 1, -1)

           local documentControllerName = animationManager:getDocumentControllerName()

           local callfunc = cc.CallFunc:create(complete)
           animationManager:setCallFuncForLuaCallbackNamed(callfunc, callbackCombine)
           print("~~~~~~~~~~~~name~~~~~~~~~~~~~~~~", callbackCombine, documentControllerName)
       end
    end

    self.gameScene:addChild(node)
    
end

function TestState:testTiledSprite()

    local sprite = TextureManager:createSprite("images/gui/Btn_-green_small.png")

    local width = 400
    local height = 400

    sprite:setTextureRect(cc.rect(0, 0, width, height))
    local t, textureContentSize = TextureManager:getUITexture("images/gui/Btn_-green_small.png")
    t:setAliasTexParameters() 

    local vertDefaultSource = "\n".."\n" ..
        "attribute vec4 a_position;\n" ..
        "attribute vec2 a_texCoord;\n" ..
        "attribute vec4 a_color;\n\n" ..
        "\n#ifdef GL_ES\n" .. 
        "varying lowp vec4 v_fragmentColor;\n" ..
        "varying mediump vec2 v_texCoord;\n" ..
        "\n#else\n" ..
        "varying vec4 v_fragmentColor;" ..
        "varying vec2 v_texCoord;" ..
        "\n#endif\n" ..
        "void main()\n" ..
        "{\n" .. 
        "   gl_Position = CC_MVPMatrix * a_position;\n"..
        "   v_fragmentColor = a_color;\n"..
        "   v_texCoord = a_texCoord;\n" ..
        "} \n"

    local fileUtiles = cc.FileUtils:getInstance()
    local fragSource = fileUtiles:getStringFromFile("shaders/tiled_sprite.fsh")
    local glProgam = cc.GLProgram:createWithByteArrays(vertDefaultSource,fragSource)
    glProgam:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)  
    glProgam:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)  
    glProgam:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)  
    glProgam:link()                                       
    glProgam:use()   
    glProgam:updateUniforms()  
    local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(glProgam)

    glprogramstate:setUniformVec2(glProgam:getUniform("size").location,cc.Vertex3F(width,height,0))    
    glprogramstate:setUniformVec2(glProgam:getUniform("sizeTiled").location,{x = textureContentSize.width*3.0,y = textureContentSize.height*3.0})  
    glprogramstate:setUniformVec2(glProgam:getUniform("realTiled").location,{x = textureContentSize.width*1.0,y = textureContentSize.height*1.0})

    local name = t:getName()  
    glprogramstate:setUniformTexture("tiled",name)  

    sprite:setGLProgramState(glprogramstate)   

    sprite:setPosition(480 / 2, 800 / 2)
    self.gameScene:addChild(sprite)

end

function TestState:testRunText()
    local text = ccui.Text:create()
     text:setPosition(640 / 2, 960 / 2)
     text:setAnchorPoint(cc.p(0, 1))
    self.gameScene:addChild(text)

    local word = "公元189年公元189年\n公元189年年年年年年年\n公元189年年年年年年年元189年元189年"

    local wordAry = StringUtils:splitUtf8String(word, "")

    local function complete()
        print("~~~~~~~~~~~~~~complete~~~~~~~~~~~~~~")
    end

    local newWordAry = {}
    local function renderWord(obj, word)
        table.insert(newWordAry, word)
        local content = table.concat(newWordAry, "")
        text:setString(content)

        if #newWordAry == #wordAry then
            complete()
        end
    end
    local index = 1
    for _, word in pairs(wordAry) do
        TimerManager:addOnce(100 * index, renderWord, {}, word)
        index = index + 1
    end
    

end


function TestState:testCocosBuilder()

--    local clip = UIMovieClip.new("shijie-bingguai", 0.1)
--    clip:setParent(self.gameScene)
--    clip:setPosition(440 / 2, 960 / 2)
--    clip:play(true)

    local url = "images/newGui1/BtnMiniGreed1.png"
    local plist = TextureManager:getUIPlist(url)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)

    local button2 = ccui.Button:create()
    button2:setPosition(cc.p(150, 200))
    button2:loadTextures(url, url, "", 1)
    self.gameScene:addChild(button2)

    local layer = ccui.Layout:create()
    self.gameScene:addChild(layer)
    layer:setPosition(640 / 2, 960 / 2)
    --inputPanel, maxLength, placeHolder, returnCallback, isFilterWorld, bgurl
    local editBox = ComponentUtils:addEditeBox(button2, 3, "输入特效名称", nil , false)
    editBox:setText("rgb-fighting")
    local function onSpriteBtnTouch(sender, eventType)
       if eventType == ccui.TouchEventType.ended then

--       local node = cc.Node:create()
--    local system = tolua.cast(node, "CCParticleSystem")
--    if system ~= nil then
--        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~", system:getDescription())
--        return
--    end

           NodeUtils:removeAllChild(layer)
           local text = editBox:getText()
           local ccb = UICCBLayer.new(text, layer)
           ccb:setScale(1 / NodeUtils:getAdaptiveScale())

           

           local function delay()
               ccb:finalize()
               print("~~~~~finalize~~~~~~~~~~~~")
           end
            TimerManager:addOnce(2000, delay, self)

--           layer:setOpacity(0)

--           local action = cc.FadeTo:create(1, 10)
--           layer:runAction(action)

--           local lizi = layer:getChild("lizi")
--           print(lizi:getName())
--           layer:setPositionType(0)
--           layer:pause()

--           local i = 0
--           local function delay()
--               layer:resume()
--               i = i + 50
--               layer:setPosition(i, i)
--               TimerManager:addOnce(100, delay, self)
--           end
--           TimerManager:addOnce(100, delay, self)
       end
    end
    
    
    local button = ccui.Button:create()
    button:setPosition(cc.p(420, 200))
    button:loadTextures(url, url, "", 1)
    button:setTitleText("播放")
    button:addTouchEventListener(onSpriteBtnTouch)
    self.gameScene:addChild(button)

    local function onSpriteBtnTouch(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
           TextureManager:removeTextureForKey("ccb/lizi_y.png")
           TextureManager:removeTextureForKey("ccb/fansheguang.png")
       end
    end
    local button = ccui.Button:create()
    button:setPosition(cc.p(520, 200))
    button:loadTextures(url, url, "", 1)
    button:setTitleText("释放")
    button:addTouchEventListener(onSpriteBtnTouch)
    self.gameScene:addChild(button)


    do
        -- self:testNewCallCCBI()
        return
    end

    require "CCBReaderLoad"

    local layer = cc.Layer:create()
    local builder = {}
    ccb["builder"] = builder
    local ccbLayer = UICCBLayer.new("rgb-piantou", layer, builder)
    ccbLayer:setPosition(480 / 2, 800 / 2)

    self.gameScene:addChild(layer)

    -- local ccbLayer = UICCBLayer.new("rgb-feixu", layer)
    -- ccbLayer:setPosition(640 / 2, 960 / 2)

    local index = 1
    local function finalize()
        -- ccbLayer:pause()
        layer:setPosition(index, index)
        index = index + 10
-- --        ccbLayer:finalize()

--         ccbLayer = UICCBLayer.new("rgp-finally-win", self.gameScene)
--         ccbLayer:setPosition(200, 200)

        TimerManager:addOnce(50, finalize, self)
    end

    -- TimerManager:addOnce(50, finalize, self)

    -- self.gameScene:addChild(onParticleSystemTestClicked())

    -- local scene = onParticleSystemTestClicked()
    -- cc.Director:getInstance():replaceScene(scene)
    -- local HelloCocosBuilderLayer = HelloCocosBuilderLayer or {}
    -- ccb["HelloCocosBuilderLayer"] = HelloCocosBuilderLayer

    -- TestParticleSystemsLayer = TestParticleSystemsLayer or {}
    -- ccb["TestParticleSystemsLayer"] = TestParticleSystemsLayer

    -- local  proxy = cc.CCBProxy:create()
    -- local  node  = CCBReaderLoad("ccb/ccb/TestParticleSystems.ccbi",proxy, HelloCocosBuilderLayer)

    -- self.gameScene:addChild(node)
    -- node:setPosition(320,480)
end


function TestState:testCCBI( )
    -- body
    local layer = cc.Layer:create()
    self.gameScene:addChild(layer)
    
    -- local builder = {}
    -- ccb["builder"] = builder
    local ccbLayer = UICCBLayer.new("rgb-guochangyun2", layer)
    ccbLayer:setPosition(480 / 2, 800 / 2)


    local function pauseCallback(  )
        -- body
        print("暂停特效啦啦啦 pauseCallback")
        ccbLayer:pause()

        local function pauseCallback(  )
            -- body
            print("继续播放特效啦啦啦 pauseCallback")
            ccbLayer:resume()
            
        end
        TimerManager:addOnce(400,pauseCallback,self)

    end
    TimerManager:addOnce(400,pauseCallback,self)

end


function TestState:testTextAction( ... )
    -- body
    print("测试富文本动画")

    if self.layer == nil then
        self.layer = cc.Layer:create()
        self.gameScene:addChild(self.layer)
        self.sprite = cc.Sprite:create()
        self.layer:addChild(self.sprite)
    end

    local index = 1
    
    if self.SpriteTab == nil then
        self.SpriteTab = {}
    end

    local function createSprite(  )
        if rawget(self.SpriteTab,"sp"..index) == nil then
            print("创建新的sprite ",index)
            local sprite = cc.Sprite:create()
            self.layer:addChild(sprite)
            self.SpriteTab["sp"..index] = sprite
        end
        self.SpriteTab["sp"..index]:setPositionY(100)
        self:createOrUpdateRichLabel( self.SpriteTab["sp"..index], index )
        self:playAcion(self.SpriteTab["sp"..index].rickLabel)

        if index < 12 then
            index = index + 1
            TimerManager:addOnce(300,createSprite,self)
        else            
            TimerManager:addOnce(6000,self.testTextAction,self)
        end
    end

    TimerManager:addOnce(300,createSprite,self)


end

-- 创建OR刷新富文本显示信息
function TestState:createOrUpdateRichLabel( parent, index, string )
    -- body
    local rickLabel = parent.rickLabel
    if rickLabel == nil then
        rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        rickLabel:setPosition(200,100)
        parent:addChild(rickLabel)
        parent.rickLabel = rickLabel
    end

    local info1 = {{{"大量经验、",18,"#eed600"},{"战法秘籍、",18,"#ff06aa"},{"声望",18,"#00f00f"},{index,18,"#00f00f"}}}
    rickLabel:setString(info1)

end

-- 滚动屏幕动画
function TestState:playAcion( rickLabel )
    -- body
    if rickLabel then
        rickLabel:stopAllActions()
        -- 遍历富文本所有子节点播放动画
        local children = rickLabel:getChildren()
        for k,child in pairs(children) do
            local x,y = child:getPosition()

            -- 动画分两段：进场/离场
            local fadeIn = cc.FadeIn:create(1)
            local fadeOut = cc.FadeOut:create(1)
            local move = cc.MoveTo:create(3,cc.p(x, 300))
            local move2 = cc.MoveTo:create(3,cc.p(x, 600))
            local Spawn = cc.Spawn:create(move,fadeIn)
            local Spawn2 = cc.Spawn:create(move2,fadeOut)
            local action = cc.Sequence:create(Spawn,Spawn2)

            child:setOpacity(0)
            child:stopAllActions()
            child:runAction(action)
        end
    end
end


-- 
function TestState:testAliasTexParameters()
    local url = "images/gui/Frame_tip_middle.png"

    local texture = TextureManager:getUITexture(url)
    texture:setAliasTexParameters()

    local sprite = TextureManager:createImageView(url)
    self.gameScene:addChild(sprite)
    sprite:setPosition(320,300)
    self._frameMiddle = sprite


    self._tileWidget = UITileWidget.new(self._frameMiddle)

    self._tileWidget:setContentHeight(500)


end



