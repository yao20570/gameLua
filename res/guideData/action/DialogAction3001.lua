local DialogAction3001 = class( "DialogAction3001", DialogAction)
function DialogAction3001:ctor()
    DialogAction3001.super.ctor(self)

    self._infos = {}

    local info = {}          
          info.head = "images/guide/guide_rw.png"
          info.name = "孙尚香"
          info.memo = "{ {txt = '主公，', color = cc.c3b(0xAA,0x11,0xCC) , fontSize = 30}"
          				..",{txt = '获得更多军械，就挑战战役, 就挑战战役-鲜卑远征吧！', color = cc.c3b(0x93,0xC8,0xFB) , fontSize = 30} }"
    table.insert(self._infos, info)

    local info = {}          
          info.head = "images/guide/guide_rw.png"
          info.name = "孙尚香"
          info.memo = "{ {txt = '老人家，何事惊慌？', color = cc.c3b(0x93,0xC8,0xFB) , fontSize = 30} }"		  
    table.insert(self._infos, info)


end

function DialogAction3001:onEnter(guide)
    DialogAction3001.super.onEnter(self, guide)

    --guide:hideModule(ModuleName.PartsWarehouseModule)
end

return DialogAction3001