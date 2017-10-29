
local scene = cc.Scene:create()
if cc.Director:getInstance():getRunningScene() then
    cc.Director:getInstance():replaceScene(scene)
else
    cc.Director:getInstance():runWithScene(scene)
end

local director = cc.Director:getInstance()
director:getOpenGLView():setDesignResolutionSize(640, 960, cc.ResolutionPolicy.FIXED_WIDTH)

cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/guide_ui_resouce_big_0.plist")

local time = os.clock()
require("framework.__init")
require("game.__init")
print(os.clock() - time)

function Test()
    
    
    
    local time = os.clock()
    local root  = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/help_1.ExportJson")
    scene:addChild(root)
    
    print(os.clock() - time)
    
end

function TestUILua()
--    local scene = cc.Scene:create()
--    if cc.Director:getInstance():getRunningScene() then
--        cc.Director:getInstance():replaceScene(scene)
--    else
--        cc.Director:getInstance():runWithScene(scene)
--    end
    
    local time = os.clock()

--    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/UI16.plist")
--
--    print(os.clock() - time)
--    
--    
--    local time = os.clock()
    
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/guide_ui_resouce_big_0.plist")
    
--    print(os.clock() - time)
    
    local root = ccui.Layout:create()
    root:setContentSize(cc.size(640,960))
    root:ignoreContentAdaptWithSize(false)
    root:setLayoutType(ccui.LayoutType.RELATIVE)
    root:setPosition(0, 0)
    
    local Panel_1 = ccui.Layout:create()
    Panel_1:setContentSize(cc.size(640,960))
    Panel_1:ignoreContentAdaptWithSize(false)
    Panel_1:setLayoutType(ccui.LayoutType.RELATIVE)
    local layoutparameter = ccui.RelativeLayoutParameter:create()
    layoutparameter:setRelativeName("Panel_1")
    layoutparameter:setRelativeToWidgetName("Panel_82")
    layoutparameter:setAlign(ccui.RelativeAlign.centerInParent)
--    layoutparameter:setMargin({left = 0})
    Panel_1:setLayoutParameter(layoutparameter)
    root:addChild(Panel_1)
    
    local Panel_2 = ccui.Layout:create()
    Panel_2:setContentSize(cc.size(640,950))
    Panel_2:ignoreContentAdaptWithSize(false)
--    Panel_2:setBackGroundColorType(ccui.LayoutBackGroundColorType.gradient)
--    Panel_2:setBackGroundColor(cc.c3b(200,200,200))
    local layoutparameter = ccui.RelativeLayoutParameter:create()
    layoutparameter:setRelativeName("Panel_2")
    layoutparameter:setRelativeToWidgetName("Panel_1")
    layoutparameter:setAlign(ccui.RelativeAlign.centerInParent)
--    layoutparameter:setMargin({left = 0})
    Panel_2:setLayoutParameter(layoutparameter)
    Panel_1:addChild(Panel_2)
    
    local Image_3 = ccui.ImageView:create()
    Image_3:loadTexture("images/guide/3.png", ccui.TextureResType.plistType)
    Image_3:setPosition(286, 499)
    Image_3:setScale9Enabled(true)
    Image_3:setContentSize(cc.size(499,304))
    Image_3:setCapInsets(cc.rect(100,30,200,1))
    Panel_2:addChild(Image_3)
    
    local Image_4 = ccui.ImageView:create()
    Image_4:loadTexture("images/guide/2.png", ccui.TextureResType.plistType)
    Image_4:setPosition(553, 436)
    Panel_2:addChild(Image_4)
    
    local content = ccui.Text:create()
    content:setString("Text Label")
    content:setPosition(284, 508)
--    content:setTextAreaSize(24)
    content:setFontSize(24)
    Panel_2:addChild(content)

    scene:addChild(root)
    
    print(os.clock() - time)
end

Test()

--TestUILua()

