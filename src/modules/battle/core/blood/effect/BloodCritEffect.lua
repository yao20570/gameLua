module("battleCore", package.seeall)

--暴击飘字
BloodCritEffect = class("BloodCritEffect")

function BloodCritEffect:ctor( ... )

end

function BloodCritEffect:play(node, delay, callback, dir, actionTime, curCount, fCount, hurtType)
    -- logger:info("BloodCritEffect:play暴击")
    
    local function complete()
        callback()
    end
    
    local action1 = cc.ScaleTo:create(actionTime / 4, 0.9)
    local action2 = cc.ScaleTo:create(actionTime / 4 * 3, 1)
    local action = cc.Sequence:create(action1, action2, cc.CallFunc:create(complete) )
    
    local number = node:getChildByTag(hurtType)
    number:setScale(0.5)
    number:runAction(action)
	
    if curCount == 2 then
        self:playTxtAction(node, number, actionTime, fCount)
    end
    
end


function BloodCritEffect:playTxtAction(node, number, actionTime, fCount)
    -- logger:info("BloodCritEffect:playTxtAction 暴击txt 1111111 actionTime=%d", actionTime)

    local resTab = node.resTab
    if resTab ~= nil then
        if fCount > 1 then
            actionTime = fCount * actionTime
            -- print(" 暴击 play ··· fCount, actionTime", fCount, actionTime)
        end

        -- actionTime : 飘字总时间

    	-- 背景
    	local spawn1 = cc.Spawn:create(cc.FadeTo:create(actionTime / 4, 100), cc.ScaleTo:create(actionTime / 6, 1.2))
    	local spawn2 = cc.Spawn:create(cc.FadeTo:create(actionTime / 4, 255), cc.ScaleTo:create(actionTime / 6, 1.0))
    	local action1 = cc.Sequence:create(spawn1, spawn2)

    	-- 暴
    	local delay2 = cc.DelayTime:create(actionTime / 2)
    	local spawn3 = cc.Spawn:create(cc.FadeTo:create(actionTime / 3, 150), cc.ScaleTo:create(actionTime / 4, 2.0))
    	local spawn4 = cc.Spawn:create(cc.FadeTo:create(actionTime / 3, 255), cc.ScaleTo:create(actionTime / 4, 1.0))
    	local action2 = cc.Sequence:create(delay2, spawn3, spawn4)

    	-- 击
    	local delay3 = cc.DelayTime:create(actionTime * 1 / 1.5)
    	local spawn5 = cc.Spawn:create(cc.FadeTo:create(actionTime / 3, 150), cc.ScaleTo:create(actionTime / 4, 2.0))
    	local spawn6 = cc.Spawn:create(cc.FadeTo:create(actionTime / 3, 255), cc.ScaleTo:create(actionTime / 4, 1.0))
    	local action3 = cc.Sequence:create(delay3, spawn5, spawn6)


		local x, y = number:getPosition()          --参考坐标：数字
		local resPos = {{0,40,action1},{-12,40,action2},{12,44,action3}}   --相对坐标：背景、暴、击

    	for i=1,#resTab do
		    local eff = node:getChildByName(resTab[i])
		    eff:setPosition(cc.p(x + resPos[i][1], y + resPos[i][2]))
		    eff:runAction(resPos[i][3])
    	end
    end

end