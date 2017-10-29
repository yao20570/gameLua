require "modules.chat.rich.ComRich"
RichTextMgr = class("RichTextMgr")

local instance = nil

function RichTextMgr:getInstance()
	if not instance then
		instance = RichTextMgr.new()
	end
	return instance
end

--[[
	创建富文本，返回富文本和真实宽度

	--imageview loadtexture模式默认读plist或者textureCache。
	--imageview loadtexture模式默认读plist或者textureCache。
	--imageview loadtexture模式默认读plist或者textureCache。

	参数：params嵌套的table   txt字段用于创建label fontSize字段用于设置lable尺寸 color字段用于设置label的颜色 
	pos字段用于下划线和当前控件的位置偏差，一般传cc.p(0,0)
	isUnderLine字段指定为1和pos字段存在才能划线
	img字段用于创建imageview  
	data字段用于回调函数的参数
	所有控件统一回调函数，但是在回调函数里面可以根据参数不同做不同的操作。如果需要回调函数，必须要传data字段，不传默认不回调
	
	maxwidth:设置最大宽度，用于自动换行
	color:全局颜色参数，但是以每个table中的color为优先
	callback:回调函数，不置空必须要传data字段

	例子：
	local p1 = {}
 	p1.txt = "11dddddddd"
 	p1.data = "11撒旦是大事!@#$%^&*())__+''|:}{~!1**卧槽**11"
	p1.color = cc.c3b(200, 120, 0)
	p1.isUnderLine = 1
 	p1.pos = cc.p(0,0)
 	local p2 = {}
 	p2.img = "1-40.png"
 	p2.data = "1-40.png"

 	local p3 = {}
 	p3.txt = "11撒旦是大事!@#$%^&*())__+''|:}{~!1**卧槽**11"
 	p3.data = "11撒旦是大事!@#$%^&*())__+''|:}{~!1**卧槽**11"
	p3.color = cc.c3b(200, 120, 155)

	local params = {}
	params[1] = p1
	params[2] = p2
	params[3] = p3
	

	getRich(params, 300, cc.c3b(200, 120, 155), nil, nil)

	--imageview loadtexture模式默认读plist或者textureCache。
	--imageview loadtexture模式默认读plist或者textureCache。
	--imageview loadtexture模式默认读plist或者textureCache。
]]

--[[
	eg:
	local args = {}
    args[1] = {txt = TextWords:getTextWord(540110), color = "9C724C", fontSize = 22}
    if self.richText_des then
        self.richText_des:setData(args, 400)
    else
        self.richText_des = RichTextMgr:getInstance():getRich(args, 400)
        self.windowBg:addChild(self.richText_des)
    end
    self.richText_des:setAnchorPoint(0, 1)
    self.richText_des:setPosition(desLab:getPosition())
]]

function RichTextMgr:getRich(params, maxwidth, color, callback, lineSize, centerType)
	local rich = RichLabel:create()
    rich:setName("RichLabel")
    if centerType ~= nil then
    	rich:setCenterType(centerType)
    end
	rich:setData(params, maxwidth, color, lineSize)
	if callback then
		rich:setOnClickHandle(callback)
	end
	
	

	return rich
    
end


function RichTextMgr:getNoticeParams(data, isString)
	local params = loadstring("return "..data)()
	if isString then
		local result = ""
		if type(params) ~= "table" then
			logger:error("无法解析这个公告-->%s",data)
			return data
		end
		for k,v in pairs(params) do
			result = result..v.txt
		end
		return result
	else
		return params or {}
	end
end