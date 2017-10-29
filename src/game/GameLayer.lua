GameLayer = class("GameLayer")

--GameLayer.mapLayer = "mapLayer"
--GameLayer.bottomLayer = "bottomLayer"
--GameLayer.modelLayer = "modelLayer"
--GameLayer.maskLayer = "maskLayer"
--GameLayer.model2Layer = "model2Layer"
--GameLayer.effectLayer = "effectLayer"
GameLayer.uiLayer = "uiLayer"  --一般层
GameLayer.ui2Layer = "ui2Layer" --第二层ui层 引导之类的
GameLayer.ui3Layer = "ui3Layer" --第三层 加载模块之类
GameLayer.uiTopLayer = "uiTopLayer" --UI最高层次
GameLayer.popLayer = "popLayer" --弹出层
GameLayer.topLayer = "topLayer" --module切换特效层
GameLayer.warnLayer = "warnLayer" --全屏警告动画层
GameLayer.touchLayer = "touchLayer" --module切换特效层
--GameLayer.touchLayer = "touchLayer" --全局触摸层

function GameLayer:ctor(parent)
--    if self._parent ~= nil then
--        self:removeLayer()
--    end
    self._parent = parent
    self._layers = {}
    self:initLayer()
end

function GameLayer:finalize()
    self:removeLayer()
end

function GameLayer:initLayer()
    local layer = nil
----    layer = cc.LayerColor:create(cc.c4b(64, 46, 36, 255))
--    layer = cc.Layer:create()
--    self._parent:addChild(layer)
--    self._layers[GameLayer.mapLayer] = layer

    layer = cc.Layer:create()
    self._parent:addChild(layer)
    self._layers[GameLayer.uiLayer] = layer
    
    layer = cc.Layer:create()
    self._parent:addChild(layer)
    self._layers[GameLayer.ui2Layer] = layer
    
    layer = cc.Layer:create()
    self._parent:addChild(layer)
    self._layers[GameLayer.ui3Layer] = layer
    
    layer = cc.Layer:create()
    self._parent:addChild(layer)
    self._layers[GameLayer.uiTopLayer] = layer
    
    layer = cc.Layer:create()
    self._parent:addChild(layer)
    self._layers[GameLayer.popLayer] = layer    
    
    layer = cc.Layer:create()
    self._parent:addChild(layer)
    self._layers[GameLayer.topLayer] = layer

    layer = cc.Layer:create()
    self._parent:addChild(layer)
    self._layers[GameLayer.warnLayer] = layer  --全屏警告动画层

    self._mask = ccui.Layout:create()
    self._mask:setLocalZOrder(99999)
    self._mask:setContentSize(640, 960)
--    self._mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    self._mask:setTouchEnabled(true)
    self._parent:addChild(self._mask)
    self._mask:setVisible(false)
    
   -- layer = cc.Layer:create()
   -- self._parent:addChild(layer)
   -- self._layers[GameLayer.touchLayer] = layer

--    local mc = component.MovieClip.new("dianji")
--    mc:setParent(layer)
--    self._clickMc = mc
    
   self:addTouchEvent(GameLayer.topLayer)
   -- self:addTouchEvent(GameLayer.touchLayer)
end

--设置一个最高曾佳的蒙版
function GameLayer:setMask(visible)
    self._mask:setVisible(visible)
end

function GameLayer:isMask()
    return self._mask:isVisible()
end

function GameLayer:addTouchEvent(name)
--    local touchLayer = self._layers[GameLayer.touchLayer]
    local touchLayer = self._layers[name]

    local function complete()
        self._isPlayClickEffect = false
    end
    
    local function onTouchBegan(touch, event)
        self._msg:sendNotification("unlock_begin","unlock_begin_event",{})                 --全局触摸事件开始
        if self._isPlayClickEffect == true then
            return true
        end
        local pos = touch:getLocation()
        local effect = UICCBLayer.new("rgb-dianji", touchLayer, nil, complete, true)
        effect:setLocalZOrder(100)
        effect:setPosition(pos.x, pos.y)
        self._isPlayClickEffect = true
        return true
    end
    
    local function onTouchEnd(touch, event)
        --print("--------onTouchEnd---------", touch, name)
        -- AudioManager:playButtonEffect()
        --self:dispatchEvent(MainSceneEvent.HIDE_MAIN_BTN,true)
        self._msg:sendNotification("unlock","unlock_event",{})                              --挂机事件启动

    end
    
    local eventDispatcher = touchLayer:getEventDispatcher()
    local touchOneByOneListener = cc.EventListenerTouchOneByOne:create()
    touchOneByOneListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    touchOneByOneListener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED )
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchOneByOneListener, touchLayer)
    
--    local function onTouchBegan(touches, event)
--        self._touchDistance = nil
--        component.SysMessage:show("--------onTouchBegan---------")
--        onTouchMoved(touches, event)
--        return true
--    end
--    
--    local function onTouchCancelled(touches, event)
--        self._touchDistance = nil
--    end
--    
--    local listener = cc.EventListenerTouchAllAtOnce:create()
--    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
--    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCHES_MOVED )
--    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCHES_CANCELLED )
--    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchLayer)
--    eventDispatcher:addEventListenerWithFixedPriority(listener, -200)
end

function GameLayer:getLayer(layerName)
    return self._layers[layerName]
end

function GameLayer:removeLayer()
--    self._clickMc:destory()
    for key, layer in pairs(self._layers) do
    	self._parent:removeChild(layer)
    	self._layers[key] = nil
    end

    self._parent:removeChild(self._mask)
end

--除了2个层次,其他全部隐藏
function GameLayer:hideAllLayerExcept(layerName,layerName2)
    for name, layer in pairs(self._layers) do
    	if layerName ~= name and layerName2 ~= name then
    	    layer:setVisible(false)
    	end
    end
end

--将所有的视图还原
function GameLayer:resetLayers()
    for name, layer in pairs(self._layers) do
        layer:setVisible(true)
    end
end

function GameLayer:setMsgCenter(msg)
    self._msg = msg
end

