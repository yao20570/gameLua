module("battleCore", package.seeall)

Bullet = class("Bullet")

--子弹类
function Bullet:ctor(attr)
    self._startPos = attr.startPos
    self._endPos = attr.endPos
    self._callback = attr.callback
    self._typeId = attr.typeId or 1
    self._parent = attr.parent
    self._target = attr.target
    self._atkDir = attr.atkDir
    self._info = attr.info 
    
    self._bulletType = self._info[2]
    self._bulletImg = self._info[3]
    self._speed = tonumber(self._info[4])  --* 10
    
    self._rootNode = cc.Node:create()
    self._parent:addChild(self._rootNode)
    
    self:launch()
end

function Bullet:finalize()
    self._rootNode:removeFromParent()
    self._rootNode = nil
end

function Bullet:launch()
    
    local bullet = nil
    if self._bulletType == "spine" then
        bullet = SpineEffect.new(self._bulletImg, self._rootNode, true)
        bullet:setDirection(self._atkDir)
    else
        local url = string.format("bg/bullet/%s.png", self._bulletImg)
        bullet = cc.Sprite:create(url)
        bullet.finalize = function() end
        self._rootNode:addChild(bullet)
    end
    
    bullet:setPosition(self._startPos.x, self._startPos.y)
    self._rootNode:setLocalZOrder(1000)
    
    local function callback()
        self._callback(self._target)
        bullet:finalize()
        self:finalize()
    end
    
    local dx = self._endPos.x - self._startPos.x
    local dy = self._endPos.y - self._startPos.y
    local s = math.sqrt( dx * dx + dy * dy)
    local time = s / self._speed
    
    local deg = math.deg(math.atan(dy / dx))
    bullet:setRotation(deg * self._atkDir * -1)
    
    local moveTo = cc.MoveTo:create(time, cc.p(dx, dy))
--    local move_ease_out = cc.EaseOut:create(moveTo,2.5)
    local move_ease_out = moveTo --cc.EaseSineOut:create(moveTo)先注释掉缓动
    --备用Action EaseExponentialOut EaseBounceOut EaseBounceInOut 
    --EaseElasticOut EaseBackOut EaseBackInOut 由快到慢缓冲
    local action = cc.Sequence:create(move_ease_out, cc.CallFunc:create(callback))
    self._rootNode:runAction(action)
end








