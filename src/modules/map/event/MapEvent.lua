
MapEvent = {}

MapEvent.HIDE_SELF_EVENT = "hide_self_event"
MapEvent.SHOW_OTHER_EVENT = "show_other_event"


MapEvent.WORLD_TILE_INFOS_REQ = "world_tile_infos_req" --查看坐标周围的格子信息
MapEvent.WORLD_TILE_SPY_PRICE_REQ = "world_tile_spy_price_req" --侦查加个请求
MapEvent.WORLD_TILE_MOVE_REQ = "world_tile_move_req" --迁徙基地请求

MapEvent.WORLD_NEAR_SEARCH_REQ = "world_near_search_req" --附近搜索
MapEvent.BUY_ENERGY_REQ = "world_buy_energy_req" --购买体力

MapEvent.GET_RESINFO_REQ = "get_resinfo_req" --请求单个矿点的信息

MapEvent.ATTCK_REBELS_REQ = "attck_rebels_req"  --请求攻击叛军 
MapEvent.MARCH_TIME_REQ = "march_time_req"  --请求行军时间