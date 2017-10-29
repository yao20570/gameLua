-----控件基类！！
---UI控件的基类，方便管理
BasicComponent = class("BasicComponent")

function BasicComponent:ctor()
	self._listViewMap = {}
end

function BasicComponent:finalize()
	for _, listView in pairs(self._listViewMap) do
        ComponentUtils:finalizeExpandListView(listView)
    end

    for key,_ in pairs(self) do
        self[key] = nil
    end
end

function BasicComponent:renderListView(listView, infos, obj, rendercall, isFrame, isInitAll, cusMargin)
    self._listViewMap[listView] = listView
    ComponentUtils:renderListView(listView, infos, obj, rendercall, isFrame, isInitAll, cusMargin)
end