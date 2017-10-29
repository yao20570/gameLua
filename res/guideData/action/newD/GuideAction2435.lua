local GuideAction2435 = class( "GuideAction2435", PlotAction) -- 417

function GuideAction2435:ctor()
    GuideAction2435.super.ctor(self)

    self.moduleName = ModuleName.MapModule

    self._plotData = {}


    local info = {}
		  info.direction = 2
		  info.head = 3
		  info.name = "百姓"
		  info.faceIcon = 2
		  info.memo = "多谢主公，为百姓造福！相信贼寇今后听闻大人威名后不敢再来犯恶！"
    table.insert(self._plotData, info)
    
	local info= {}
		  info.direction = 1
		  info.head = 10
		  info.name = "玩家名"
		  info.faceIcon = 3
		  info.memo = "各位请放心，今后我誓必剿灭流匪，保百姓安宁。"
		  info.flip = 1 
          info.diffPos = { -30, 0}
    table.insert(self._plotData, info)
        
	local info = {}
		  info.direction = 2
		  info.head = 3
		  info.name = "百姓"
		  info.faceIcon = 2
		  info.memo = "主公，这是我们一份心意，望你笑纳。"
    table.insert(self._plotData, info)
end

function GuideAction2435:getPlotData()
    return self._plotData
end

function GuideAction2435:isNextAction()
    self._isNextAction = true
    return self._isNextAction
end


return GuideAction2435