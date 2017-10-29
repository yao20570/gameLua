
Motion = class("Motion")

function Motion:ctor(owner, startPos, desPos, speed, callback)
    self._owner = owner
    self._callback = callback
    self._startPos = startPos
    self._desPos = desPos
    self._speed = speed
end

function Motion:finalize()
    
--    CoroutineManager:stopCoroutine(self._task)
    
    self._owner = nil
    self._callback = nil
    self._startPos = nil
    self._desPos = nil
    self._task = nil
    self._isRuning = false
end

function Motion:start()
    self._isRuning = true
--    self._task = CoroutineManager:startCoroutine(self.startMotion,self) --TODO 协程执行顺序问题，协程开始后，还未赋值task
    self:startMotion()
end

function Motion:stop()
--    self._task:stop()
end

function Motion:startMotion()

    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()
    local preDis2 = -1
    local startPos = self._startPos
    local desPos = self._desPos
    local owner = self._owner
    local speed = self._speed * timeScale
    
    local dir = {x = desPos.x - startPos.x, y = desPos.y - startPos.y} --矢量，可做成工具类 TODO
    local dirlen = math.sqrt(dir.x * dir.x + dir.y * dir.y)
    dir["x"] = dir["x"] / dirlen
    dir["y"] = dir["y"] / dirlen

    -- if dir["x"] > 0 then
    --     self._owner:setDir(Direction.Right)
    -- else
    --     self._owner:setDir(Direction.Left)
    -- end
    
    local function completeMotion()
        self:endMotion()
    end
    
    local function updateMotion()
        if self._isRuning ~= true then
            game.manager.TimerManager:remove(updateMotion, self)
            completeMotion()
            return
        end
        local curPos = owner:getPosition()

        local nextPosX = curPos.x + dir["x"] * speed / 30
        local nextPosY = curPos.y + dir["y"]  * speed / 30
        owner:setPosition(nextPosX, nextPosY)


        local dis2 = (nextPosX - desPos.x) * (nextPosX - desPos.x) 
            + (nextPosY - desPos.y) * (nextPosY - desPos.y)

        if dis2 < 5 then  ---TODO
            TimerManager:remove(updateMotion, self)
            completeMotion()
            return
        end
        
        if preDis2 > 0 and preDis2 < dis2 then ---TODO
            TimerManager:remove(updateMotion, self)
            completeMotion()
            return
        end

        preDis2 = dis2
    end
    
    TimerManager:add(0, updateMotion, self, -1)
    

--    while true and  self._isRuning == true do
--        coroutine.yield(1)
--        local curPos = owner:getPosition()
--
--        local nextPosX = curPos.x + dir["x"] * speed / 30
--        local nextPosY = curPos.y + dir["y"]  * speed / 30
--        owner:setPosition(nextPosX, nextPosY)
--
--
--        local dis2 = (nextPosX - desPos.x) * (nextPosX - desPos.x) 
--            + (nextPosY - desPos.y) * (nextPosY - desPos.y)
--
--        if dis2 < 5 then  ---TODO
--            break
--        end
--
--        if preDis2 > 0 and preDis2 < dis2 then ---TODO
--            break
--        end
--
--        preDis2 = dis2
--    end
--    
--    self:endMotion()
end

function Motion:endMotion()
    if self._callback ~= nil then
        local func = self._callback["func"]
        local obj = self._callback["obj"]
        func(obj)
    end
end