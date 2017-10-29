-- Author: zlf
-- Date: 2016年5月9日17:05:37
-- 简易富文本

RichText = class("RichText", function()
	return ccui.Layout:create()
end)

--自适应最大宽度，自动换行
RichText.auto = 1
--系统公告，无限宽
RichText.gmnotice = 2

local cache = cc.SpriteFrameCache:getInstance()

--[[
	@param data 富文本参数（table）
	data示例：{{txt="12呵呵asdasad###3", color="#FF9966", isUnLine = 1, data = "函数回调参数"}, {img = "Star.png", data = "函数回调参数"}}

	使用方式：
	local richLabel = RichText:create()
	setDrawType可用可不用，但是create之后一定要手动调用init函数
	richLabel:setDrawType(1)
	richLabel:init(param, 300)
	richLabel:setPos(300, 320)
	self:addChild(richLabel) 

	data里面元素作用详解：
	txt代表要创建的控件是ccui.Text，img则代表ccui.ImageView， color设置ccui.Text的字体颜色，但是以全局颜色优先
	isUnLine用来表示ccui.Text是否需要下划线，nil或者false代表不画， data作为控件回调函数的参数
	fontSize用来设置ccui.Text的字体大小，但是以全局字体大小参数优先

	@param maxWidth 富文本的最大宽度，设置了最大宽度，可以自动换行

	@param globalCallBack 全局回调函数，当这个参数存在时，所有的控件回调都调用这个函数

	@param globalFontSize 全局字体大小，当这个参数存在时，所有的ccui.Text的字体大小都设置为这个参数

	@param this 类指针，callback(this, callParam)这个作用，语法糖


]]
function RichText:create()
	local ret = RichText.new()
	return ret
end

function RichText:init(param, maxWidth, globalCallBack, globalColor, globalFontSize, this)
	if type(param) ~= "table" then
		return
	end
	--先删除所有的子节点，用于update富文本
    self:removeAllChildren() 
    --保存统一的回调函数和字体大小
    self.globalCallBack = globalCallBack
    self.globalFontSize = globalFontSize
    --初始化总行数和实际渲染的宽度
	self.renderWidth = 0
	self.renderLine = 0
	--默认最大宽度为400
	maxWidth = maxWidth or 400
	--记录每一行的实时宽度，用于换行
	local curWidth = 0
	--记录实时行数
	local row = 0
	--每一行的所有控件都用一个Table存着，curIndex是这个table的key
	local curIndex = 1
	local allWidget = {}
	--调整参数
	self:adjustParam(param)
	for i=1,#param do
		local x, y = 0
		if param[i].txt and param[i].txt ~= "" then
			--参数的txt字段调整过后，还要再次调整，醉了啊啊啊  尼玛
			local textTb = self:getNeedString(Utils.separate(param[i].txt), curWidth, maxWidth, globalFontSize or param[i].fontSize)
			for j=1,#textTb do

				--就只需要注释一个控件的就好了。所有控件的位置原理都一样

				local color = self:getNeedColor(globalColor, param[i].color)
				--创建控件的函数，不解释
				local widget = self:getLabel(textTb[j], color, globalCallBack, param[i].data, globalFontSize or param[i].fontSize, this)
				--保存当前控件的划线属性，后面调整控件的位置顺便可以划线
				widget.isUnLine = param[i].isUnLine
				local size = widget:getContentSize()
				--x, y其实只有x才有用，设置控件的横坐标(设置x轴的锚点为0，posX直接设置为当前宽度就好，比较方便)
				x, y = curWidth, size.height * row
				--实际宽度还是用contentSize的width比较靠谱
				local width = size.width
				--到了要换行的时候了，把当前控件放在下一行，所以curWidth要设置为这个控件的width
				--但是因为这个控件是所在行的第一个控件，所以x设置为0
				--换行curIndex要+1，最后就是把控件存到表，设置坐标啊。。加到layer上面等等
				if curWidth + width > maxWidth then
					curWidth = width
					row = row - 1
					curIndex = curIndex + 1
					x, y = 0, size.height * row
				else
					curWidth = curWidth + width
				end
				if not allWidget[curIndex] then
					allWidget[curIndex] = {}
				end
				table.insert(allWidget[curIndex], widget)
				widget:setPosition(x, y)
				widget:setAnchorPoint(cc.p(0, 0.5))
				self:addChild(widget)
			end
		elseif param[i].img then
			local widget = self:getImage(param[i].img, globalCallBack, globalParam or param[i].data, this)
			local size = widget:getContentSize()
			x, y = curWidth, size.height * row
			if curWidth + size.width > maxWidth then
				curWidth = size.width
				row = row - 1
				curIndex = curIndex + 1
				x, y = 0, size.height * row
			else
				curWidth = curWidth + size.width
			end
			if not allWidget[curIndex] then
				allWidget[curIndex] = {}
			end
			table.insert(allWidget[curIndex], widget)
			widget:setAnchorPoint(cc.p(0, 0.5))
			widget:setPosition(x, y)
			self:addChild(widget)
		elseif param[i].anim then
			local anim, size, name = self:getAnim(param[i])
			local sprite = nil
			if param[i].type == 1 then
				sprite = cc.Sprite:createWithSpriteFrameName(name)
			else
				sprite = cc.Sprite:create(name)
			end
			sprite:runAction(anim)
			x, y = curWidth, size.height * row
			if curWidth + size.width > maxWidth then
				curWidth = size.width
				row = row - 1
				curIndex = curIndex + 1
				x, y = 0, size.height * row
			else
				curWidth = curWidth + size.width
			end
			if not allWidget[curIndex] then
				allWidget[curIndex] = {}
			end
			sprite.isAnim = true
			sprite.size = size
			table.insert(allWidget[curIndex], sprite)
			sprite:setAnchorPoint(cc.p(0, 0.5))
			sprite:setPosition(x, y)
			self:addChild(sprite)
		end
	end
	--渲染的宽度要看有没有换行过
	self.renderWidth = curIndex > 1 and maxWidth or curWidth
	self.renderLine = curIndex	
	self:adjust(allWidget)
end

--世界公告（无限宽）还是普通（自动换行）
function RichText:setDrawType(type)
	self.DrawType = type
end

--设置行距
function RichText:setRowSpace(space)
	self.rowSpace = space
end

--设置控件的Y坐标、下划线。。等等
--顺便记录渲染的高度
function RichText:adjust(allWidget)
	self.DrawType = self.DrawType or self.auto
	self.renderHeight = 0
	if self.DrawType == self.auto then
		self.rowSpace = self.rowSpace or 0
		local _max = {}
		for i=1,#allWidget do
			--调整Y坐标的思路就是，找出每一行所有控件中，高度最大的一个
			--再累加上一行的最大高度*2（如果存在上一行的话），设置为这行所有控件的Y坐标
			--为什么*2？因为y轴的锚点是0.5，获取的最大高度都打了五折
			local maxHeight = 0
			for k,v in pairs(allWidget[i]) do
				local size
				if v.isAnim then
					size = v.size
				else
					size = v:getContentSize()
				end
				if size.height * 0.5 > maxHeight then
					maxHeight = size.height * 0.5 + self.rowSpace
				end
			end
			self.renderHeight = self.renderHeight + maxHeight
			if i == 1 then
				--因为y轴的锚点是0.5，所以要减去偏移量。偏移量就是所在行的最大高度减去行距
				self.posX = maxHeight - self.rowSpace
			end
			--_max这个表就是记录每一行控件的y坐标，下面有个累加的过程，呃~~因为是向下摆放的，所以应该是累减~~
			if maxHeight > 0 then
				if _max[i-1] then
					_max[i] = maxHeight*2 + _max[i-1]
				else
					_max[i] = maxHeight
				end
			
				for k,v in pairs(allWidget[i]) do
					local height = 0 
					if _max[i-1] then
						height = -maxHeight - _max[i-1]
					else
						height = 0
					end
					v:setPositionY(height)
					--是否划下划线~~~
					if v.isUnLine then
						self:drawUnLine(self, v)
					end
				end
			end
		end
		self:setContentSize(cc.size(self.renderWidth, self.renderHeight))
	else
		--这个调整就更简单，直接简单粗暴，找出所有控件中最大高度作为Y坐标就可以了
		local all = {}
		local allWidth = {}
		local maxHeight = -100
		for k,v in pairs(allWidget) do
			for key,value in pairs(v) do
				local size
				if value.isAnim then
					size = value.size
				else
					size = value:getContentSize()
				end
				if size.height * 0.5 > maxHeight then
					maxHeight = size.height * 0.5
				end
				table.insert(all, value)
				table.insert(allWidth, value:getContentSize().width)
			end
			if k == 1 then
				self.posX = maxHeight
			end
		end
		self.renderHeight = maxHeight
		local curWidth = 0
		for i=1,#all do
			all[i]:setPosition(curWidth, 0)
			curWidth = curWidth + allWidth[i]
			self.renderWidth = curWidth
			if all[i].isUnLine then
				self:drawUnLine(self, all[i])
			end
		end
		self.renderLine = 1
	end
	self:setContentSize(cc.size(self.renderWidth, 0))
end

function RichText:getRenderWidth()
	return self.renderWidth
end

function RichText:getRenderLine()
	return self.renderLine
end

function RichText:getRenderHeight()
	return self.renderHeight
end

function RichText:drawUnLine(parent, widget)
	local color4F = cc.convertColor(widget:getColor(), "4f")
	color4F.a = 1
	local pos = cc.p(widget:getPosition())
	self:getDrawNode(parent):drawLine(cc.p(pos.x, pos.y - widget:getContentSize().height/2), cc.p(pos.x + widget:getContentSize().width, pos.y - widget:getContentSize().height/2), color4F)
end

function RichText:getDrawNode(parent)
	if not self.drawNode then
		self.drawNode = cc.DrawNode:create()
		parent:addChild(self.drawNode)
	end
	return self.drawNode
end

function RichText:getLabel(param, color, callback, funcParam, fontSize, this)
	local text = ccui.Text:create()
	text:setFontName(GlobalConfig.fontName)
	text:setFontSize(fontSize or 22)
	text:setString(param)
	if color then
		text:setColor(color)
	end
	if funcParam then
		text:setTouchEnabled(true)
		if type(callback) == "function" then
			text:addTouchEventListener(function(sender, event)
				if event == ccui.TouchEventType.ended then
					if this then
						callback(this, funcParam)
					else
						callback(funcParam)
					end
				end
			end)
		end
	end
	text:enableShadow(cc.c4b(0,0,0,255), cc.size(1,-1))
	return text
end

function RichText:getImage(param, callback, callParam, this)
	local img = ccui.ImageView:create()
	if not cache:getSpriteFrame(param) then
		img:loadTexture(param)
	else
		img:loadTexture(param, ccui.TextureResType.plistType)
	end
	if callParam then
		img:setTouchEnabled(true)
		if type(callback) == "function" then
			img:addTouchEventListener(function(sender, event)
				if event == ccui.TouchEventType.ended then
					if this then
						callback(this, callParam)
					else
						callback(callParam)
					end
				end
			end)
		end
	end
	return img
end

function RichText:getNeedColor(p1, p2)
	local result
	if p1 then
		result = p1
	elseif p2 then
		result = p2
	else
		result = cc.c3b(255,255,255)
	end
	if type(result) == "string" then
		result = Utils.str2Color(result)
	end
	return result
end

--保证在不换行的情况下最大限度的增加创建txt的文本字数
function RichText:getNeedString(txt, curWidth, maxWidth, fontSize)
	local data = {}
	if not self.testLabel then
		self.testLabel = ccui.Text:create()
        self.testLabel:setFontName(GlobalConfig.fontName)
		self.testLabel:retain()
	end
	--用一个text来记录长度
	local result = ""
	for i=1,#txt do
		self.testLabel:setString(txt[i])
		self.testLabel:setFontSize(fontSize or 22)
		local addLen = self.testLabel:getContentSize().width
		--如果到了要换行的情况，插入result，再把result置为""
		if addLen + curWidth >= maxWidth then
			table.insert(data, result)
			result = ""
			curWidth = 0
			result = result .. txt[i]
			curWidth = curWidth + addLen
		else
			--不需要换行就继续连接result
			result = result .. txt[i]
			curWidth = curWidth + addLen
			--补充最后的文字
			if i == #txt then
				table.insert(data, result)
				result = ""
				curWidth = 0
			end
		end
	end
	self.testLabel:release()
	self.testLabel = nil
	return data
end

--返回最大尺寸，动画和贴图的名字
function RichText:getAnim(args)
	--maxWidth、maxHeight记录所有图片中最大的宽度和高度
	local maxWidth = 0
	local maxHeight = 0
	--保存第一张图片的名字作为精灵的贴图
	local spriteName = ""
	--使用local的图片模式，碎图(不是读取cache里面)
	if args.type == 0 then
		local animation = cc.Animation:create()
		local idx = args.index
		local spr = cc.Sprite:create()
		spr:retain()
		while true do			
			local name = string.format(args.anim, idx)
			local isHas = CommonResMgr:getInstance():getFilePath(name)
			if not isHas then
				break
			end
			spr:setTexture(name)
			local size = spr:getContentSize()
			maxWidth = (size.width >= maxWidth) and size.width or maxWidth
			maxHeight = (size.height >= maxHeight) and size.height or maxHeight
			animation:addSpriteFrameWithFile(name)
			idx = idx + 1
			if spriteName == "" then
				spriteName = name
			end
		end
		spr:release()
    	animation:setDelayPerUnit(args.time)
		animation:setLoops(-1)
    	return cc.Animate:create(animation), cc.size(maxWidth, maxHeight), spriteName
	else
		local animFrames = {}
		local idx = args.index
		while true do
			local name = string.format(args.anim, idx)
			local frameSprite = cache:createWithSpriteFrameName(name)
			if not frameSprite then
				break
			end
			local size = frameSprite:getContentSize()
			maxWidth = size.width >= maxWidth and size.width or maxWidth
			maxHeight = size.height >= maxHeight and size.height or maxHeight
			table.insert(animFrames, frameSprite)
			idx = idx + 1
			if spriteName == "" then
				spriteName = name
			end
		end
		local animation = cc.Animation:createWithSpriteFrames(animFrames)
		animation:setDelayPerUnit(args.time)
		animation:setLoops(-1)
		return cc.Animate:create(animation), cc.size(maxWidth, maxHeight), spriteName
	end
end

--调整参数，写得有点绕，连我自己都有点晕 2016年6月12日13:54:36
function RichText:adjustParam(t)
	--判断两个参数能不能合并在一起，只有txt的时候才需要处理
	local function isSameParam(p1, p2)
		--颜色、字体大小等参数防止空，后面判断相等
		p1.color = p1.color or cc.c3b(255, 255, 255)
		p2.color = p2.color or cc.c3b(255, 255, 255)
		p1.fontSize = p1.fontSize or 22
		p2.fontSize = p2.fontSize or 22
		local isSameCall = false
		--如果没data字段，默认是不开启触摸的，所以有一个空，data字段就断为相等
		if (not p1.data) or (not p2.data) then
			isSameCall = true
		elseif type(p1.data) == "table" and type(p2.data) == "table" then
			--如果两个data都是table，序列化之后判断字符串是否相等
			local s1 = Utils.serialize(p1.data)
			local s2 = Utils.serialize(p2.data)
			isSameCall = s1 == s2
		else
			--如果两个data不同类型，肯定不相等，相同类型(非table，判断相等（忽略function和userData吧！！）)
			if type(p1.data) ~= type(p2.data) then
				isSameCall = false
			else
				isSameCall = p1.data == p2.data
			end
		end
		if not self.globalCallBack then
			--没设置回调函数？？那其他说破天也没用
			isSameCall = true
		end
		--isSameCall主要是判断除了color和fontSize这些基本数据之外其他的数据是否相等的标识
		local isSame = Utils.isSameColor(p1.color, p2.color) and p1.isUnLine == p2.isUnLine and p1.fontSize == p2.fontSize and isSameCall
		
		return isSame
	end

	local rs = {}
	local str = ""
	--保留一份引用
	local result = {}
	for k,v in pairs(t) do
		result[k] = v
	end
	for i=1,#t do
		--设置好fontSize参数
		if t[i].txt then
			t[i].fontSize = self.globalFontSize or t[i].fontSize
		end
		--如果有连续两个txt字段，则要判断是否能连接起来了connect是用来判断txt是不是已经连接过
		--str是用来拿去一段连接完毕的字符串，放到表里面
		if t[i].txt and t[i+1] and t[i+1].txt then
			--if not t[i].connect then这个判断之后马上连接起来？？因为如果t[i]没有连接过，证明上一个一定是断了连接，此时的str肯定是""
			--所以连接起来
			if not t[i].connect then
				str = str .. t[i].txt
				t[i].connect = true
			end
			--如果下一个没连接过，而且拥有一样的参数(color, fontsize, data等等)则可以连接起来
			--连接之后的txt要设置为""，后面可以通过这个判断来设置str的位置，例如：
			--{{txt="123"},{txt="123"},{txt="123"},{txt="123"},{img="hehe.png"},{txt="123"},{txt="123"}}
			--调整会变成{{txt=""},{txt=""},{txt=""},{txt="123"},{img="hehe.png"},{txt=""},{txt="123"}}
			--然后rs = {"123123123", "123123"}
			--最后遍历result看到有个txt不是""，就是123123123替换原本的123，因为有个index在计数，计数+1
			--下次遇到txt不是""，就把rs[index]替换txt
			if not t[i+1].connect and isSameParam(t[i], t[i + 1]) then
				str = str .. t[i+1].txt
				t[i+1].connect = true
				t[i+1].txt = ""
			--不一样的参数，连接要断开，插入str后把str置为""
			elseif not isSameParam(t[i], t[i + 1]) then
				table.insert(rs, str)
				t[i].connect = true
				str = ""
			end
		--下一个不是txt字段，因为如果t[i]没有连接过，证明上一个一定是断了连接，此时的str肯定是""
		--但是因为下一个不是txt，所以要把str插入后置为""
		elseif t[i].txt and t[i+1] and not t[i+1].txt then
			if not t[i].connect then
				str = str .. t[i].txt
				t[i].connect = true
			end
			table.insert(rs, str)
			str = ""
		--最后一个参数是txt
		--因为如果t[i]没有连接过，证明上一个一定是断了连接，此时的str肯定是""
		--所有if not t[i].connect then  这个判断  都是同上原因
		elseif t[i].txt and not t[i+1] then
			if not t[i].connect then
				str = str .. t[i].txt
				t[i].connect = true
			end
			table.insert(rs, str)
			str = ""
		end
	end
	local index = 1
	--{{txt="123"},{txt="123"},{txt="123"},{txt="123"},{img="hehe.png"},{txt="123"},{txt="123"}}
	--调整会变成{{txt=""},{txt=""},{txt=""},{txt="123"},{img="hehe.png"},{txt=""},{txt="123"}}
	--然后rs = {"123123123", "123123"}
	--最后遍历result看到有个txt不是""，就是123123123替换原本的123，因为有个index在计数，计数+1
	--下次遇到txt不是""，就把rs[index]替换txt
	--至于rs[index]这个为空，应该不会出现，防止出现而已
	for i=1,#result do
		if result[i].txt and result[i].txt ~= "" then
			if rs[index] then
				result[i].txt = rs[index]
			else
				result[i].txt = ""
			end
			index = index + 1
		end
	end
end

function RichText:setPos(x, y)
	self.posX = self.posX or 0
	if type(x) == "table" then
		x.y = x.y - self.posX
		self:setPosition(x)
	else
		y = y - self.posX
		self:setPosition(x, y)
	end
end

function RichText:destory()
	if self.testLabel ~= nil then
		self.testLabel:removeFromParent()
		self.testLabel:release()
		self.testLabel = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end