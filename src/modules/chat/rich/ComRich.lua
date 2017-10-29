


-- 字符size映射表
FontSizeMap = FontSizeMap or {}
function FontSizeMap:init()
    if self._isInit == true then
        return
    end

    self._isInit = true
    self._map = {}
    self._mesureLable = ccui.Text:create()
    self._mesureLable:setFontName(GlobalConfig.fontName)
    self._mesureLable:setFontSize(22)
    self._mesureLable:retain()

    self:initCharSizeMap()
end

function FontSizeMap:dispose()
    self._mesureLable:release()
    self._isInit = false
end

function FontSizeMap:getCharSize(char, fontSize)
    self:init()

    fontSize = fontSize or 22

    if self._map[fontSize] == nil then
        self._map[fontSize] = { }
    end

    local tempChar = nil
    if self:isChineseFont(char) then
        -- 中文字体用这个标记来统一大小
        tempChar = "ChineseFontSize"
    end

    local size = self._map[fontSize][tempChar or char]
    if size == nil then        
        self._mesureLable:setFontSize(fontSize)
        self._mesureLable:setString(char)

        size = self._mesureLable:getContentSize()

        self:setCharSize(tempChar or char, fontSize, size.width, size.height)

    end

    return size
end

function FontSizeMap:setCharSize(char, fontSize, w, h)
    self:init()

    if self._map[fontSize] == nil then
        self._map[fontSize] = { }
    end
    self._map[fontSize][char] = { width = w, height = h }
end

-- 是否中文
function FontSizeMap:isChineseFont(c)
    return c:byte() > 128
end

-- 默认记录了22号通用字符大小（如果有遗漏，getCharSize(char, fontSize)会补回来，当然不介意手动在下面添加）
function FontSizeMap:initCharSizeMap()
    if self._map[22] ~= nil then
        return
    end

    self._map[22] = { }
    local charSizeMap = self._map[22]

    -- 中文字体()
    charSizeMap["ChineseFontSize"] = { width = 22, height = 29 }

--    -- 通用字符
    charSizeMap["`"] = { width = 12, height = 29 }
    charSizeMap["1"] = { width = 12, height = 29 }
    charSizeMap["2"] = { width = 12, height = 29 }
    charSizeMap["3"] = { width = 12, height = 29 }
    charSizeMap["4"] = { width = 12, height = 29 }
    charSizeMap["5"] = { width = 12, height = 29 }
    charSizeMap["6"] = { width = 12, height = 29 }
    charSizeMap["7"] = { width = 12, height = 29 }
    charSizeMap["8"] = { width = 12, height = 29 }
    charSizeMap["9"] = { width = 12, height = 29 }
    charSizeMap["0"] = { width = 12, height = 29 }
    charSizeMap["-"] = { width = 7, height = 29 }
    charSizeMap["="] = { width = 12, height = 29 }
    charSizeMap["q"] = { width = 13, height = 29 }
    charSizeMap["w"] = { width = 17, height = 29 }
    charSizeMap["e"] = { width = 11, height = 29 }
    charSizeMap["r"] = { width = 9, height = 29 }
    charSizeMap["t"] = { width = 9, height = 29 }
    charSizeMap["y"] = { width = 12, height = 29 }
    charSizeMap["u"] = { width = 13, height = 29 }
    charSizeMap["i"] = { width = 6, height = 29 }
    charSizeMap["o"] = { width = 12, height = 29 }
    charSizeMap["p"] = { width = 13, height = 29 }
    charSizeMap["["] = { width = 7, height = 29 }
    charSizeMap["]"] = { width = 7, height = 29 }
    charSizeMap["a"] = { width = 12, height = 29 }
    charSizeMap["s"] = { width = 10, height = 29 }
    charSizeMap["d"] = { width = 13, height = 29 }
    charSizeMap["f"] = { width = 9, height = 29 }
    charSizeMap["g"] = { width = 13, height = 29 }
    charSizeMap["h"] = { width = 13, height = 29 }
    charSizeMap["j"] = { width = 6, height = 29 }
    charSizeMap["k"] = { width = 11, height = 29 }
    charSizeMap["l"] = { width = 6, height = 29 }
    charSizeMap[";"] = { width = 6, height = 29 }
    charSizeMap["'"] = { width = 5, height = 29 }
    charSizeMap["z"] = { width = 10, height = 29 }
    charSizeMap["x"] = { width = 11, height = 29 }
    charSizeMap["c"] = { width = 10, height = 29 }
    charSizeMap["v"] = { width = 11, height = 29 }
    charSizeMap["b"] = { width = 13, height = 29 }
    charSizeMap["n"] = { width = 13, height = 29 }
    charSizeMap["m"] = { width = 20, height = 29 }
    charSizeMap[","] = { width = 6, height = 29 }
    charSizeMap["."] = { width = 6, height = 29 }
    charSizeMap["/"] = { width = 8, height = 29 }
    charSizeMap["~"] = { width = 12, height = 29 }
    charSizeMap["!"] = { width = 6, height = 29 }
    charSizeMap["@"] = { width = 19, height = 29 }
    charSizeMap["#"] = { width = 15, height = 29 }
    charSizeMap["$"] = { width = 12, height = 29 }
    charSizeMap["%"] = { width = 18, height = 29 }
    charSizeMap["^"] = { width = 12, height = 29 }
    charSizeMap["&"] = { width = 15, height = 29 }
    charSizeMap["*"] = { width = 12, height = 29 }
    charSizeMap["("] = { width = 7, height = 29 }
    charSizeMap[")"] = { width = 7, height = 29 }
    charSizeMap["_"] = { width = 9, height = 29 }
    charSizeMap["+"] = { width = 12, height = 29 }
    charSizeMap["{"] = { width = 8, height = 29 }
    charSizeMap["}"] = { width = 8, height = 29 }
    charSizeMap[":"] = { width = 6, height = 29 }
    charSizeMap["|"] = { width = 12, height = 29 }
    charSizeMap["<"] = { width = 12, height = 29 }
    charSizeMap[">"] = { width = 12, height = 29 }
    charSizeMap["?"] = { width = 10, height = 29 }
end

function FontSizeMap:pinrtAllCharInfo()    
--    for fontSize, fontInfos in pairs(self._map) do        
--        for k, v in pairs(fontInfos) do            
--            print(string.format("charSizeMap[%s] = { width = %d, height = %d }", k, v.width, v.height))
--        end
--    end
end



local RichUtils = RichUtils or {}
RichUtils.getTblLen = function(tableValue)
  local tableLength = 0
  
  for k, v in pairs(tableValue) do
    tableLength = tableLength + 1
  end
  
  return tableLength
end

--字符转颜色 00ff00 转 cc.c3b
function RichUtils:str2Color(str)
  str = string.gsub(str,"#","")
  return cc.c3b(tonumber(string.sub(str,1,2),16),
                 tonumber(string.sub(str,3,4),16),
                 tonumber(string.sub(str,5,6),16))
end

-- 是否中文字
function RichUtils:isCn(c)
   return c:byte() > 128
end

function RichUtils:isSameColor(color1,color2)
    return color1.r == color2.r and 
           color1.g == color2.g and
           color1.b == color2.b
end

--function RichUtils:separate(str)

--    local function SubUTF8String(s, n)
--        local dropping = string.byte(s, n + 1)
--        if not dropping then return s end
--        if dropping >= 128 and dropping < 192 then
--            return SubUTF8String(s, n - 1)
--        end
--        return string.sub(s, 1, n)
--    end

--    local i = 1
--    local lastStr = ""
--    local curStr = ""
--    local ret = { }
--    while i <= #str do

--        curStr = SubUTF8String(str, i)
--        if lastStr ~= curStr then
--            table.insert(ret, string.sub(curStr, string.len(lastStr) + 1))
--            lastStr = curStr
--        end
--        i = i + 1
--    end
--    return ret
--end
function RichUtils:separate(str)
    local byteCount = 3
    local ret = {}
    local len = #str
    local i = 1
    while i <= len do
        local b = string.byte(str, i)
        if b > 128 then
            byteCount = 3
        else
            byteCount = 1
        end

        local e = i + byteCount - 1
        local char = string.sub(str, i, e)
        table.insert(ret, char)

        i = e + 1
    end
    return ret
end
----字典
--local RichDic = class("RichDic")
--function RichDic:ctor()
--	self.list = {}
--    self.count = 0
--end
--function RichDic:size()
--    return self.count
--end
--function RichDic:setObject(obj,key)
--	if obj then
--		self.list[key] = obj
--		self.list[key]:retain()
--        self.count = self.count + 1
--	end
--end

--function RichDic:objectForKey(key)
--	return self.list[key]
--end

--function RichDic:clean(func)
--	for _,v in pairs(self.list) do
--		if type(func) == "function" then
--			func(v)
--		end
--		v:release()
--		v = nil
--	end
--	self.list = {}
--    self.count = 0
--end

--function RichDic:forEach(func)
--	for k,v in pairs(self.list) do
--		func(v,k)
--	end
--end

--function RichDic:removeWithKey(key)
--	for k,v in pairs(self.list) do
--		if string.find(k,key) then
--			v:release()
--			self.list[k] = nil
--            self.count = self.count + 1
--		end
--	end
--end

local function isFloatColor(c)
    return (c.r <= 1 and c.g <= 1 and c.b <= 1) and (math.ceil(c.r) ~= c.r or math.ceil(c.g) ~= c.g or math.ceil(c.b) ~= c.b)
end

local function convertColor(input, typ)
    -- assert(type(input) == "table" and input.r and input.g and input.b, "cc.convertColor() - invalid input color")
    if type(input) ~= "table" or type(input.r) ~= "number" or type(input.g) ~= "number" or type(input.b) ~= "number" then
    	logger:error("颜色有问题 type(color) ~= table or type(color.r) ~= number or type(color.g) ~= number or type(color.b) ~= number")
    	return cc.c3b(255,255,255,255)
    end
    local ret
    if typ == "3b" then
        if isFloatColor(input) then
            ret = {r = math.ceil(input.r * 255), g = math.ceil(input.g * 255), b = math.ceil(input.b * 255)}
        else
            ret = {r = input.r, g = input.g, b = input.b}
        end
    elseif typ == "4b" then
        if isFloatColor(input) then
            ret = {r = math.ceil(input.r * 255), g = math.ceil(input.g * 255), b = math.ceil(input.b * 255)}
        else
            ret = {r = input.r, g = input.g, b = input.b}
        end
        if input.a then
            if math.ceil(input.a) ~= input.a or input.a >= 1 then
                ret.a = input.a * 255
            else
                ret.a = input.a
            end
        else
            ret.a = 255
        end
    elseif typ == "4f" then
        if isFloatColor(input) then
            ret = {r = input.r, g = input.g, b = input.b}
        else
            ret = {r = input.r / 255, g = input.g / 255, b = input.b / 255}
        end
        if input.a then
            if math.ceil(input.a) ~= input.a or input.a >= 1 then
                ret.a = input.a
            else
                ret.a = input.a / 255
            end
        else
            ret.a = 255
        end
    else
        error(string.format("cc.convertColor() - invalid type %s", typ), 0)
    end
    return ret
end

-------------------------------------------------------
RichLabelAlign = {}
RichLabelAlign.design_center = 1
RichLabelAlign.real_center = 2
RichLabelAlign.left_top = 3
RichLabelAlign.limit_center = 4
-------------------------------------------------------
--富文本 
local ccDirector = cc.Director:getInstance()
local ccTextureCache = ccDirector:getTextureCache()
RichLabel = class("RichLabel",function()    
	return ccui.Layout:create()    
end)

function RichLabel:create()
	local ret = RichLabel.new()
	ret:init()
	return ret
end

function RichLabel:init()
	-- require "RichDic"
	self._lineNum = 1
	self.dic_lab = {} --RichDic:new()
	self.dic_img = {} --RichDic:new()
	self.dic_sprite = {} --RichDic:new()
	self._centerType = RichLabelAlign.design_center
	self._verticalSpace = 0
    self._nodeAutoIndex = 0   
end

function RichLabel:getLines()
	return self._lineNum
end

function RichLabel:getContainer()
	return self
end

function RichLabel:setData(tbl, lineWidth, defaultColor, lineSize)
    --ProfileUtils:PrintTime(61)
	self:clean()
	self._elemRenderMap = {}
	self.lineMap = {}
	self.lineSize = lineSize
    if tbl == nil then
        return
    end
    --ProfileUtils:PrintTime(2000)
	for _,elem in ipairs(tbl) do
		if elem.txt and elem.txt ~= "" then -- 文本
			if type(elem.color) == "nil" then
				if defaultColor then
					if type(defaultColor) == "string" then
						elem.color = RichUtils:str2Color(defaultColor)
					else
						elem.color = defaultColor
					end
				else
					elem.color = cc.c3b(255,255,255)
				end
            elseif type(elem.color) == "string" then
                elem.color = RichUtils:str2Color(elem.color)
            end

            --print("==>1",elem.txt)
            --local lab = self:getMesureLabel()
            local chars = RichUtils:separate(elem.txt)
			for _,char in ipairs(chars) do
				--local size = self:makeLabelSize(lab,elem,char)
                local size = FontSizeMap:getCharSize(char, elem.fontSize)
--                if size.width == 0 then     
--                    char = "■" 
--                    chars[_] = char
--                    size = FontSizeMap:getCharSize(char, elem.fontSize)
--                end
                table.insert(self._elemRenderMap,{char=char,
												  width=size.width,
												  height=size.height,
												  isOutLine=1,
												  isUnderLine=elem.isUnderLine,
												  fontSize=elem.fontSize,
												  color=elem.color or cc.c3b(0x93,0xC8,0xFB),
												  data=elem.data})
			end

--            elem.txt = table.concat(chars)

		elseif elem.img and elem.img ~= "" then -- 图片             
            local imgContentSize = TextureManager:getTextureRect(elem.img)
            if imgContentSize then
                table.insert(self._elemRenderMap,{img = elem.img, 
                                                  width = imgContentSize.width * elem.scale, 
                                                  height = imgContentSize.height * elem.scale, 
                                                  data = elem.data, 
                                                  scale = elem.scale})
            end
		elseif elem.anim and elem.anim ~= "" then -- 动画
            local imgInfo = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("%s%d.png", elem.anim, 1)) 
			if imgInfo then
                local rect = imgInfo:getRect()
				table.insert(self._elemRenderMap,{anim = elem.anim,
                                                  dt = elem.dt,
                                                  width = rect.width * elem.scale,
                                                  height = rect.height * elem.scale,
                                                  data = elem.data})
			end
		elseif elem.newline == 1 then -- 换行
			table.insert(self._elemRenderMap,{newline=1})
		end
	end
    --FontSizeMap:pinrtAllCharInfo()
    

	local charWidth = 0
	local oneLine = 0
	local lines = 1

	if self._centerType == RichLabelAlign.real_center then
		self._lineWidth = 640 * 2 --无限宽
	else
		if lineWidth ~= nil then
			self._lineWidth = lineWidth
		else
			self._lineWidth = self._lineWidth or 600
		end
	end

	for i, elem in ipairs(self._elemRenderMap) do

		if elem.newline == 1 then --换行符

			oneLine = 0
            lines = lines +1
            self._lineNum = self._lineNum + 1
            elem.width = 0
            elem.height = 29
           	elem.posX = oneLine
            elem.posY = -lines * 29

		else --其他元素

	        if oneLine + elem.width > self._lineWidth then
	        	
	        	if elem.char then --文字 

		        	if RichUtils:isCn(elem.char) or elem.char == " " then --中文字 或者空格 直接换行
			            
			            oneLine = 0
			            lines = lines +1
			            self._lineNum = self._lineNum + 1
			            elem.posX = oneLine
                        elem.posY = -lines * 29
			            oneLine = elem.width

			        else --英文字或数字
			        	local spaceIdx = 0
			        	local idx = i
			        	while idx > 0 do 
			        		idx = idx - 1

			        		if self._elemRenderMap[idx] and 
			        		   self._elemRenderMap[idx].char == " " and
			        		   self._elemRenderMap[idx].posY == self._elemRenderMap[i-1].posY then --仅检测同一行
			        			spaceIdx = idx
			        			break
			        		end
			        	end
			        	-- 找不到空格 直接换行
			        	if spaceIdx == 0 then
			        	
			        		oneLine = 0
			        		lines = lines +1
			        		self._lineNum = self._lineNum + 1
			           		elem.posX = oneLine
			           		elem.posY = -lines * 29

			           		oneLine = elem.width
			           	else --有空格 可换行(要移位)

			           		oneLine = 0
			           		lines = lines +1
			           		self._lineNum = self._lineNum + 1
			           		for _i=spaceIdx+1,i do
			           			
			           			local _elem = self._elemRenderMap[_i]
			           			_elem.posX = oneLine
			           			_elem.posY = -lines * 29
		        				oneLine = oneLine + _elem.width
			           		end
			        	end
		        	end
		        elseif (elem.img ~= nil) or (elem.anim ~= nil) then --图片
	        		lines = lines +1
	        		self._lineNum = self._lineNum + 1
	           		elem.posX = 0
	           		elem.posY = -lines * 29
	           		oneLine = elem.width
	        	end
	        else
	        	elem.posX = oneLine
	        	elem.posY = -lines * 29
	       		oneLine = oneLine + elem.width
	        end
	    end
    end
    --ProfileUtils:PrintTime(2001)
----------------排序 分行----------------------------------------------
    local tmp = {}
   	for i,v in ipairs(self._elemRenderMap) do
   		if v.posY then
	   		tmp[ v.posY ] = tmp[ v.posY ] or {}
	   		table.insert(tmp[ v.posY ], v )
   		end
   	end	
   	local tmpLineYKey = {}
   	for lineY,v in pairs(tmp) do
   		table.insert(tmpLineYKey,lineY)
   	end
   	table.sort( tmpLineYKey, function(a,b) return a > b end )
--------------------------------------------------------------
    --ProfileUtils:PrintTime(2001)
   	for _,lineY in ipairs(tmpLineYKey) do

   		local oneLine = ""
   		local _lastEleme = tmp[lineY][1]
   		local _lastDiffStarEleme = tmp[lineY][1]
   		if #tmp[lineY] > 0 then
   			local _arr = {}
	   		for _,elem in ipairs(tmp[lineY]) do
	   			if _lastEleme.char and elem.char then
		   			if RichUtils:isSameColor(_lastEleme.color,elem.color) and _lastEleme.isUnderLine == elem.isUnderLine then
		   				oneLine = oneLine .. elem.char
		   			else --颜色不同
		   				if _lastDiffStarEleme.char then
		   					local _newElem = clone(_lastDiffStarEleme)
	   						_newElem.str = oneLine
	   						-- _newElem.isUnderLine = elem.isUnderLine
		   					table.insert(_arr,_newElem) 
			   				_lastDiffStarEleme = elem
			   				oneLine = elem.char
			   			end
		   			end
		   		elseif elem.img then

		   			if _lastDiffStarEleme.char then
	   					local _newElem = clone(_lastDiffStarEleme)
	   					_newElem.str = oneLine
	   					oneLine = ""
		   				table.insert(_arr,_newElem) 
		   			end

		   			table.insert(_arr,elem)
		   		elseif elem.anim then

		   			if _lastDiffStarEleme.char then
	   					local _newElem = clone(_lastDiffStarEleme)
	   					_newElem.str = oneLine
	   					oneLine = ""
		   				table.insert(_arr,_newElem) 
		   			end

		   			table.insert(_arr,elem)

		   		elseif elem.newline then

		   			if _lastDiffStarEleme.char then
	   					local _newElem = clone(_lastDiffStarEleme)
	   					_newElem.str = oneLine
	   					oneLine = ""
		   				table.insert(_arr,_newElem) 
		   			end

		   			table.insert(_arr,elem)
		   		elseif _lastEleme.char == nil then
		   			_lastDiffStarEleme = elem

		   			if elem.char then
		   				oneLine = elem.char
		   			end
	   			end
	   			_lastEleme = elem
	   		end
	   		if _lastEleme.char then
		   		local _newElem = clone(_lastDiffStarEleme)
				_newElem.str = oneLine
				-- _newElem.isUnderLine = _lastEleme.isUnderLine
				table.insert(_arr,_newElem)
			end
   			table.insert(self.lineMap,_arr)
   		end
   	end
    --ProfileUtils:PrintTime(2003)
	-- 偏移坐标
	local _obj = nil
	local _offsetLineY = 0
	self.realLineHeight = 0
	for i, lines in ipairs(self.lineMap) do
		local _lineHeight = 0
    	for _,elem in ipairs(lines) do
    		_lineHeight = math.max(_lineHeight, elem.height)
    	end

    	if i > 1 then --偶数行
    		self.realLineHeight = self.realLineHeight + _lineHeight + self._verticalSpace
    		_offsetLineY = _offsetLineY + (_lineHeight - 29) + self._verticalSpace
    	else
    		self.realLineHeight = self.realLineHeight + _lineHeight
    		_offsetLineY = _offsetLineY + (_lineHeight - 29)
    	end

    	for _,elem in ipairs(lines) do
    		elem.posY = elem.posY - _offsetLineY
    		self.realLineHeight = math.max( self.realLineHeight, math.abs(elem.posY) )
    	end
    end
    --ProfileUtils:PrintTime(2004)
    -- 放置元素坐标
    self.realLineWidth = 0
    for _,lines in ipairs(self.lineMap) do
    	local _lineWidth = 0
    	for _,elem in ipairs(lines) do
    		if not elem.newline then
		    	if elem.img then
		    		_obj = self:getSprite()
		    		self:makeImage(_obj,elem)
		    		_lineWidth = _lineWidth + _obj.width-- _obj:getContentSize().width
		    	elseif elem.anim then
		    		_obj = self:getSprite()
		    		self:makeAnim(_obj,elem)
		    		_lineWidth = _lineWidth + elem.width
		    	elseif elem.str then                 
		    		_obj = self:getLabel()                    
		    		self:makeLabel(_obj,elem,elem.str)                    
		    		_lineWidth = _lineWidth + _obj:getContentSize().width                    
		    	end

                _obj:setVisible(true)
    			_obj:setPosition(elem.posX, elem.posY + self.realLineHeight)
    		end
    	end 	
    	self.realLineWidth = math.max(_lineWidth, self.realLineWidth)
    end
    --ProfileUtils:PrintTime(2005)
    self:_onCenter()
    --ProfileUtils:PrintTime(2006)
end

function RichLabel:setCenterType(t)
	self._centerType = t
end

function RichLabel:_onCenter()
	if self._centerType == RichLabelAlign.design_center then
		self:setContentSize(cc.size(self:getDesignWidth(),self:getRealHeight()))
		self:setAnchorPoint(0.5,0.5)

	elseif self._centerType == RichLabelAlign.real_center or
			self._centerType == RichLabelAlign.limit_center then		
		self:setContentSize(cc.size(self:getRealWidth(),self:getRealHeight()))
		self:setAnchorPoint(0.5,0.5)

	elseif self._centerType == RichLabelAlign.left_top then
		self:setContentSize(cc.size(self:getRealWidth(),self:getRealHeight()))
		self:setAnchorPoint(0,1)
	end
end

function RichLabel:getRealHeight()
	return self.realLineHeight
end

function RichLabel:getRealWidth()
	return self.realLineWidth
end

function RichLabel:getDesignWidth()
	return self._lineWidth
end

function RichLabel:setVerticalSpace(s)
	self._verticalSpace = s
end

function RichLabel:getDrawNode()
	if self._drawNode == nil then
		self._drawNode = cc.DrawNode:create()
		self:addChild(self._drawNode)
	end
	return self._drawNode
end

--[[
function RichLabel:getMesureLabel()
	if self._mesureLable == nil then
		self._mesureLable = ccui.Text:create()
        self._mesureLable:setFontName(GlobalConfig.fontName)
		self._mesureLable:retain()
	end
	return self._mesureLable
end
--]]

function RichLabel:getMesureImageContentSize(path,type)
	if self._mesureImage == nil then
		self._mesureImage = ccui.ImageView:create()
		self._mesureImage:retain()
	end
	-- if type then
	-- 	self._mesureImage:loadTexture(path)
	-- else
		-- self._mesureImage:loadTexture(path, ccui.TextureResType.plistType)
		TextureManager:updateImageView(self._mesureImage, path)
	-- end
	return self._mesureImage:getContentSize()
end

function RichLabel:setOnClickHandle(func)
	self._func = func
end

--function RichLabel:getNodeAutoKey()
--    self._nodeAutoIndex = self._nodeAutoIndex + 1
--    return self._nodeAutoIndex
--end

function RichLabel:getLabel()
    for _, lab in pairs(self.dic_lab) do
        if lab.isUse == 0 then
            return lab
        end
    end

    local lab = ccui.Text:create()

    lab:setFontName(GlobalConfig.fontName)

    lab:setAnchorPoint(0, 0)
--    lab:addTouchEventListener( function(sender, eventType)
--        if eventType == 2 then
--            if self._func then
--                self._func(sender.data)
--            end
--        end
--    end )    
    table.insert(self.dic_lab, lab)
    self:addChild(lab)
--    local key = self:getNodeAutoKey()
--    self.dic_lab:setObject(lab, key)
    return lab
end

function RichLabel:getImage()

    for _, img in pairs(self.dic_img) do
        if img.isUse == 0 then
            return img
        end
    end

    local img = ccui.ImageView:create()
    img:setAnchorPoint(0, 0)
--    img:addTouchEventListener( function(sender, eventType)
--        if eventType == 2 then
--            if self._func then
--                self._func(sender.data)
--            end
--        end
--    end )
--    local key = self:getNodeAutoKey()
--    self.dic_img:setObject(img, key)
    table.insert(self.dic_img, img)
    self:addChild(img)
    return img

end

function RichLabel:getSprite()

    for _, spr in pairs(self.dic_sprite) do
        if spr.isUse == 0 then
            return spr
        end
    end

    local spr = cc.Sprite:create()
    spr:setAnchorPoint(0, 0)
--    local key = self:getNodeAutoKey()
--    self.dic_sprite:setObject(spr, key)
    table.insert(self.dic_sprite, spr)
    self:addChild(spr)
    return spr

end

function RichLabel:makeImage(img,elem)
	img:stopAllActions()
	-- if not cc.SpriteFrameCache:getInstance():getSpriteFrame(elem.img) then
	-- 	img:loadTexture(elem.img)
	-- else
	TextureManager:updateSprite(img, elem.img)
	img:setScale(elem.scale or 1)
	-- img:setContentSize(cc.size(elem.width, elem.height))
		-- img:loadTexture(elem.img, ccui.TextureResType.plistType)
	-- end
	img.isUse = 1
	-- img.scale = elem.scale
	img.width = elem.width
	img.data = elem.data 

--	if elem.data then
--		img:setTouchEnabled(true)
--   	else
--   		img:setTouchEnabled(false)
--	end

end

function RichLabel:makeAnim(spr,elem)
	spr:stopAllActions()

	local pCache = cc.SpriteFrameCache:getInstance();
	local pFrame;
	local index = 1
	local pAnim = cc.Animation:create()
	local animName = ""
	while true do
		animName = string.format("%s%d.png",elem.anim,index)
		pFrame = pCache:getSpriteFrame(animName);
		if pFrame == nil then
			break
		end
		pAnim:addSpriteFrame(pFrame);
		index = index + 1
	end

	pAnim:setLoops(999);
	--pAnim:setRestoreOriginalFrame(true);
	pAnim:setDelayPerUnit(elem.dt or 0.1);
	spr:runAction(cc.Animate:create(pAnim))
	spr.isUse = 1

end

--[[
function RichLabel:makeLabelSize(lab,elem,char)
    local fontSize = elem.fontSize or 24

    local size = FontSizeMap:getCharSize(char, fontSize)
    if size == nil then
        --self:makeLabel(lab,elem,char)
        lab:setFontSize(elem.fontSize or 22)
        lab:setString(char)
        size = lab:getContentSize()
        --FontSizeMap:setCharSize(char, fontSize, size.width, size.height)
    end

    return size
end
--]]


function RichLabel:makeLabel(lab,elem,char)
    --print("=======>", char)
    
    --ProfileUtils:PrintTime(1)
	lab:disableEffect()
	elem.color.a = 255
	if elem.isOutLine == 1 then
		lab:setColor(elem.color)
		-- lab:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
	else
		lab:setColor(elem.color)
	end
	lab:setFontSize(elem.fontSize or 22)
    --ProfileUtils:PrintTime(2)
	lab:setString(char)
    --ProfileUtils:PrintTime(3)
	lab.isUse = 1
	elem.posX = elem.posX or 0
	elem.posY = elem.posY or 0
	if elem.isUnderLine == 1 and self.realLineHeight then
		local color4F = convertColor(elem.color, "4f")
		color4F.a = 1--drawSegment
		-- print(self.lineSize or 1)
		self:getDrawNode():drawSegment(
			cc.p(elem.posX,elem.posY + self.realLineHeight),
			cc.p(elem.posX +lab:getContentSize().width,elem.posY + self.realLineHeight ),
            (self.lineSize or 1),
			color4F)
	end
--	if elem.data then
--		lab:setTouchEnabled(true)
--   	else
--   		lab:setTouchEnabled(false)
--	end
	lab.data = elem.data 
end

function RichLabel:clean()
	if self._drawNode then
		self._drawNode:clear()
	end

    for k,v in pairs(self.dic_lab) do
		v.isUse = 0
        v:setVisible(false)
	end

    for k,v in pairs(self.dic_img) do
		v.isUse = 0
        v:setVisible(false)
	end

    for k,v in pairs(self.dic_sprite) do
		v.isUse = 0
        v:setVisible(false)
	end

--	self.dic_lab:forEach(function(lab)
--		lab.isUse = 0
--        lab:setVisible(false)
--		--lab:removeFromParent()
--	end)
--	self.dic_img:forEach(function(img)
--		img.isUse = 0
--        img:setVisible(false)
--		--img:removeFromParent()
--	end)
--	self.dic_sprite:forEach(function(spr)
--		spr.isUse = 0
--        spr:setVisible(false)
--		--spr:removeFromParent()
--	end)
end

function RichLabel:dispose()    
    
--    -- 继承了Layout， removeFromParent()全都不存在了
--	self:clean()
--	self.dic_lab:clean()
--	self.dic_img:clean()
--	self.dic_sprite:clean()
--	if self._mesureLable then
--		self._mesureLable:removeFromParent()
--		self._mesureLable:release()
--		self._mesureLable = nil
--	end
--	if self._mesureImage then
--		self._mesureImage:removeFromParent()
--		self._mesureImage:release()
--		self._mesureImage = nil
--	end
    
	self:removeFromParent()
end