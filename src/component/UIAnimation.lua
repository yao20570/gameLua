--ccs编辑的动画特效

UIAnimation = class("UIAnimation")

function UIAnimation:ctor(parent, name, isLoop, callback)
    self._callback = callback
    self._name = name
    self._isLoop = isLoop
    self._parent = parent
    
    self._armature = nil
end

function UIAnimation:finalize()

end

function UIAnimation:setCompleteCallback(callback)
    self._callback = callback
end

function UIAnimation:play(animationName, isAdaptive)
    animationName = animationName or "Animation1"
    self._isAdaptive = isAdaptive
    if self._isAdaptive == nil then
        self._isAdaptive = true
    end
    self:loadAnimation(self._parent, self._name, self._isLoop,animationName)
end

function UIAnimation:loadAnimation(parent, name, isLoop, animationName)
    local function dataLoaded(percent)
        if percent >= 1 then
            local armature = ccs.Armature:create(name)
            armature:getAnimation():play(animationName)
            armature:setLocalZOrder(3000)
            parent:addChild(armature)
            
            self._armature = armature
            
            if self._isAdaptive == true then
                self:adaptiveArmature(armature)
            end

            local function animationEvent(armatureBack,movementType,movementID)
--                if movementType == ccs.MovementEventType.complete then
                    if isLoop ~= true then
                        parent:removeChild(armature)
                        if self._callback ~= nil then
                            self._callback()
                        end
                    end
--                else
--                    if isLoop ~= true then
--                        parent:removeChild(armature)
--                    end
--                end
            end
            armature:getAnimation():setMovementEventCallFunc(animationEvent)
        end
    end
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(
        "effect/" .. name .. ".ExportJson", dataLoaded)
end

function UIAnimation:pause()
    if self._armature == nil then
        return
    end
    self._armature:pause()
end

function UIAnimation:resume()
    if self._armature == nil then
        return
    end
    self._armature:resume()
end

--将全屏的特效自适应处理，让x轴对齐
function UIAnimation:adaptiveArmature(armature)
    NodeUtils:adaptiveXCenter(armature)
end








