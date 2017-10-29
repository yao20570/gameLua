module("battleCore", package.seeall)

--克制飘字
BloodRefrainEffect = class("BloodRefrainEffect")

function BloodRefrainEffect:ctor( ... )

end

function BloodRefrainEffect:play(node, delay, callback, dir, actionTime, curCount, fCount, hurtType)
    
    local function complete()
        callback()
    end
    
    -- 数字标签动画
    local action1 = cc.ScaleTo:create(actionTime / 4, 0.9)
    local action2 = cc.ScaleTo:create(actionTime / 4 * 3, 1)
    local action = cc.Sequence:create(action1, action2, cc.CallFunc:create(complete) )
    
    local number = node:getChildByTag(hurtType)
    number:setScale(0.5)
    number:runAction(action)

    -- 文字动画：播一次
    if curCount == 2 then
        self:playTxtAction(node, number, actionTime, fCount)
    end
    
end

function BloodRefrainEffect:playTxtAction(node, number, actionTime, fCount)
    -- logger:info("BloodRefrainEffect:playTxtAction 克制txt 1111111")

    local resTab = node.resTab
    if resTab ~= nil then
        if fCount > 1 then
            actionTime = fCount * actionTime
        end

        -- actionTime : 飘字总时间

    	-- 背景
    	local spawn1 = cc.Spawn:create(cc.RotateTo:create(actionTime / 2, 180), cc.FadeTo:create(actionTime / 4, 100), cc.ScaleTo:create(actionTime / 4, 1.2))
    	local spawn2 = cc.Spawn:create(cc.FadeTo:create(actionTime / 2, 255), cc.ScaleTo:create(actionTime / 4, 1.0))
    	local action1 = cc.Sequence:create(spawn1, spawn2)

    	-- 克制
    	local delay2 = cc.DelayTime:create(actionTime / 4)
    	local spawn3 = cc.Spawn:create(cc.FadeTo:create(actionTime / 2, 150), cc.ScaleTo:create(actionTime / 4, 2.0))
    	local spawn4 = cc.Spawn:create(cc.FadeTo:create(actionTime / 2, 255), cc.ScaleTo:create(actionTime / 4, 1.0))
    	local action2 = cc.Sequence:create(delay2, spawn3, spawn4)


		local x, y = number:getPosition()          --参考坐标：数字
		local resPos = {{0,40,action1,-16.15},{0,40,action2,-8.56}}   --相对坐标：背景、克制

    	for i=1,#resTab do
		    local eff = node:getChildByName(resTab[i])

		    eff:setPosition(cc.p(x + resPos[i][1], y + resPos[i][2]))
		    -- eff:setFlippedY(resPos[i][4])
		    eff:setRotation(resPos[i][4])
		    eff:runAction(resPos[i][3])
    	end
    end

end
