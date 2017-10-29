--ui粒子特效

UIParticle = class("UIParticle")

function UIParticle:ctor(parent, name)
    self:play(parent, name)
end

function UIParticle:finalize()
    self._particle:removeFromParent()
end

function UIParticle:play(parent, name)
    local particle = cc.ParticleSystemQuad:create("particle/" .. name .. ".plist")
    particle:setLocalZOrder(50)
    parent:addChild(particle)
    
    self._particle = particle

    if name == "lines" then
    	self:setLines()
    end
end

function UIParticle:setPosition(x, y)
    self._particle:setPosition(x,y)
end

function UIParticle:getRootNode()
    return self._particle
end

function UIParticle:setLines()
	self._particle:setAngle(0)   --设置角度
    self._particle:setAngleVar(360)  --设置角度变化率
    self._particle:setEmissionRate(20)  --设置每秒产生的粒子数
    self._particle:setLife(2)   --设置粒子存在时间
    self._particle:setLifeVar(1)--设置粒子存在时间变化率
    self._particle:setSpeed(500)  --设置运动速度
    self._particle:setSpeedVar(100)  --运动速度变化率
    self._particle:setStartSize(100)  --设置粒子开始时候大小(像素值)
    self._particle:setStartSizeVar(80)  --粒子开始时大小变化率
    self._particle:setEndSize(400)   --设置粒子结束时候大小(像素值)
    self._particle:setEndSizeVar(300) --设置粒子结束时候编号率
    self._particle:setStartColor(cc.c4f(255, 255, 255, 0.0)) --设置粒子开始时候颜色（0-1）之间
    self._particle:setStartColorVar(cc.c4f(0.0, 0.0, 0.0, 0.0)) --设置粒子开始时候颜色变化率
    self._particle:setEndColor(cc.c4f(255, 255, 255, 1.0)) --设置粒子结束时候颜色
    self._particle:setEndColorVar(cc.c4f(0, 0, 0,0.5 )) --设置粒子结束时候颜色变化率
    --self._particle:setBlendFunc(GL_SRC_COLOR , GL_ONE) --设置粒子混合模式
end