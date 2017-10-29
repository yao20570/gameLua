--
-- Author: zlf
-- Date: 2016年9月19日 23:16:55
-- 类似老虎机的滚动节点

UIMoveNode = class("UIMoveNode")

--[[
	@param:imgPathInfo  图片的地址   为了按顺序显示，传list过来吧。map恕不接待
	这个值定了之后不能变
	@param:percentY     间隔距离   其实是用在下面  size.height * (i-0.5) * percentY + startY  是一个系数
	@param:startY       y坐标偏移量  size.height * (i-0.5) * percentY + startY
	@param:callBack     转动停止回调函数
	@param:posX    		子控件的x坐标，默认0
]] 
function UIMoveNode:ctor(imgPathInfo, parent, posX, callBack, percentY, startY)

	self._parent = parent

	percentY = percentY or 1

	startY = startY or 0

	self._startY = startY

	-- self._percentY = percentY

	posX = posX or 0

	self.lenght = #imgPathInfo
	self.allChild = {}

	self._callback = callBack

	self._rootNode = cc.Node:create()
	parent:addChild(self._rootNode)

	self.parentPosY = 0

	for i=1,#imgPathInfo do
		local v = imgPathInfo[i]
		local imageView = TextureManager:createImageView(v)
		imageView.index = i
		imageView:setName(i)
		local size = imageView:getContentSize()

		self.globalSize = size
		local y = size.height * (i-0.5) * percentY + startY
		if y > self.parentPosY then
			self.parentPosY = y
		end
		imageView:setPosition(posX, y)
		self._rootNode:addChild(imageView)
		self.allChild[i] = imageView
	end

	self._percentY = self.allChild[2]:getPositionY() - self.allChild[1]:getPositionY() - self.globalSize.height

end

--初始化后手动调用startMove
--[[
	@param:centerPos    第几个位置显示目标图片
	@param:targetPos    要将第几张图片（在数组中的位置）显示在centerPos
	@param:circle       转几圈
	@param:time         开始到停下来的时间
	@param:dir			运动的方向 要不就1，要不就-1  默认-1
]]
function UIMoveNode:startMove(centerPos, targetPos, circle, time, dir)
	if self.moveIng then
		return
	end
	dir = dir or -1

	self.moveIng = true

	self.oldTargetPos = targetPos

	targetPos = self.allChild[targetPos].index or targetPos

	local nodeHeight = self.globalSize.height + self._percentY

	--[[
		计算从当前点移动到目标点的长度（先一圈） 再加上圈数*总长度。计算出这次运动的路程   这里面有个间隔需要注意
		每个控件通过快到慢的动作移动到目标点
		有个定时器检测位置越界，通过加减（根据移动方向）总长度来还原位置，使用加减的原因是容纳位置的细微偏差。
		动作停止，需要重新设置Index  因为理论上targetpos上面的控件现在是停在了centerpos上面   所以index属性要进行修改
	]]
	local distance = 0
	if dir < 0 then
		dir = -1
		distance = ((self.lenght + targetPos - centerPos) * nodeHeight + self.lenght * nodeHeight * circle) * dir
	else
		dir = 1
		distance = (self.lenght - targetPos + centerPos) * nodeHeight + self.lenght * nodeHeight * circle
	end

	self.direction = dir

	for i=1, #self.allChild do
		local target = cc.p(0, distance)
		local move = cc.MoveBy:create(time, target)
		local action = cc.EaseSineInOut:create(move)
		--最后一个控件要做回调，运动完刷新
		if i == #self.allChild then
			local func = cc.CallFunc:create(function()
				local count = 1
				local curIndex = self.oldTargetPos
				local curCenterPos = centerPos
				while count <= self.lenght do
					if curCenterPos > self.lenght then
						curCenterPos = 1
					end
					if curIndex > self.lenght then
						curIndex = 1
					end
					self.allChild[curIndex].index = curCenterPos
					curCenterPos = curCenterPos + 1
					curIndex = curIndex + 1
					count = count + 1
				end
				TimerManager:remove(self.update, self)
				self.moveIng = nil

				if type(self._callback) == "function" then
					self._callback()
				end

			end)
			local Seq = cc.Sequence:create(action, func)
			self.allChild[i]:runAction(Seq)
		else
			self.allChild[i]:runAction(action)
		end
	end

	TimerManager:add(1, self.update, self)
end

function UIMoveNode:update()
	local dir = self.direction
	local height = self.globalSize.height
	for i=1, #self.allChild do
		local y = self.allChild[i]:getPositionY()
		if dir == 1 then
			if y >= self.parentPosY + self.globalSize.height * 0.5 + self._percentY then
				y = y + (self.lenght*height + (self._percentY * self.lenght)) *dir*-1
			end
		else
			if y <= 0 + self._startY then
				y = y + (self.lenght*height + (self._percentY * self.lenght)) *dir*-1
			end
		end
		self.allChild[i]:setPositionY(y)
	end
end

function UIMoveNode:finalize()
	TimerManager:remove(self.update, self)
	for k,v in pairs(self.allChild) do
		self.allChild[k]:removeAllChildren()
	end
	if self._rootNode ~= nil then
		self._rootNode:removeAllChildren()
		self._rootNode:removeFromParent()
	end
	for k,v in pairs(self) do
		self[k] = nil
	end
end

function UIMoveNode:getAllChild()
	return self.allChild
end