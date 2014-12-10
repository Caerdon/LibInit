local MAJOR_VERSION = "LibInit"
local MINOR_VERSION = 1
--- A minimal Crayon like implementation
-- C.Azure.c returns a string "rrggbb"
-- tostring(C.Azure) returns a string "rrggbb"
-- "aa" .. C.Azure can be done and returns "aarrggbb"
-- C.Azure() returns r,g,b as float list
-- C.Azure.r returns r as float
-- C("testo","azure") returns "|cff" .. >color code for azure> .. "test" .. "|r"
--
-- @usage local C=LibStub("LibInit"):GetColorTable()
-- For a list of available color check Colors
-- Each color became the name of a metod
-- @name C.Azure()
-- @return r,g,b
--
-- @name C.Azure.r
-- @return red value
-- @name C.Azure.g
-- @return green value
-- @name C.Azure.b
-- @return blue value
-- @name C.Azure.c
-- @return hex string "rrggbb"
-- @name tostring(C.Azure(
-- @return hex string "rrggbb"
-- @name C(testo,colore)
-- @return "|cff" .. >color code for azure> .. "test" .. "|r"
--


-- Color system related function
local C
local lib=LibStub:NewLibrary("LibInit-Colorize",1)
if (not lib) then return end
local setmetatable=setmetatable
local tonumber=tonumber
local tostring=tostring
local rawget=rawget
local rawset=rawset
local pairs=pairs
local format=format
local strlower=strlower
local type=type
local unpack=unpack
local _G=_G
local UIERRORS_HOLD_TIME=UIERRORS_HOLD_TIME or 1
local UIErrorsFrame=UIErrorsFrame
local ChatTypeInfo=ChatTypeInfo
--- Available colors
-- @class table
-- @name Colors
lib.colors={
azure                   ="0c92dc"
,black                  ="000000"
,blue                   ="0000ff"
,brightgrey             ="d0d0d0"
,connection_color       ="33ff66"
,copper                 ="cc9900"
,debug_color            ="00ff00"
,gold                   ="ffff66"
,gray                   ="808080"
,green                  ="20ff20"
,green2                 ="00c000"
,grey                   ="909090"
,guildchat              ="269926"
,highlight_color_code   ="ffffff"
,lightblue              ="515179"
,lightyellow            ="ffff9a"
,lightgrey              ="d0d0d0"
,money_color            ="ffcc33"
,orange                 ="ff9900"
,partychat              ="515179"
,purple                 ="800080"
,raidchat               ="66331a"
,red                    ="ff2020"
,red2                   ="f41400"
,silver                 ="c0c0c0"
,status_color           ="0066ff"
,white                  ="ffffff"
,yellow                 ="ffd200"
,yellow2                ="ffed1a"
,druid  			    ="ff7d0a"
,hunter					="abd473"
,mage        			="69ccf0"
,deathknight			="ff0000"
,paladin     			="f58cba"
,priest     			="ffffff"
,rogue       			="fff569"
,shaman      			="0000FF"
,warlock     			="9482ca"
,warrior     			="c79c6e"
,default				="ffd200"
}
if (_G.RAID_CLASS_COLORS) then
	for class,c in pairs (_G.RAID_CLASS_COLORS) do
		local color=format("%02X%02X%02X", 255*c.r, 255*c.g, 255*c.b)
		lib.colors[strlower(class)]=color
	end
end

local ChatTypeInfo=ChatTypeInfo or {}
local format=format
setmetatable(lib.colors,
{__index=
	function(table,key)
		local color
		local okey=key
		if (key=='horde' or key== "chat_msg_bg_system_horde") then
			color = ChatTypeInfo["BG_SYSTEM_HORDE"]
			if type(color) == "table" and color.r and color.g and color.b then
				local r, g, b = color.r, color.g, color.b
				color=format("%02X%02X%02X", 255*r, 255*g, 255*b)
			else
				key='azure'
			end
		end
		if (key=='alliance' or key=='ally' or key== "chat_msg_bg_system_alliance") then
			color = ChatTypeInfo["BG_SYSTEM_ALLIANCE"]
			if type(color) == "table" and color.r and color.g and color.b then
				local r, g, b = color.r, color.g, color.b
				color=format("%02X%02X%02X", 255*r, 255*g, 255*b)
			else
				key='red'
			end
		end
		if (key=='neutral' or key== "chat_msg_bg_system_neutral") then
			color = ChatTypeInfo["BG_SYSTEM_NEUTRAL"]
			if type(color) == "table" and color.r and color.g and color.b then
				local r, g, b = color.r, color.g, color.b
				color=format("%02X%02X%02X", 255*r, 255*g, 255*b)
			else
				key='yellow'
			end
		end
		if (not color) then color=rawget(table,key) or table.default end
		rawset(table,okey,color)
		return color
	end
}
)

do
	local function colorize(stringa,colore,dummy)
			-- Crayon compatibility
			if (type(stringa)=="table") then
					stringa=dummy
			end
			if (colore:match("^%x+$")) then
					return "|cff" .. colore .. tostring(stringa) .. "|r"
			else
					return "|cff" .. C[colore] .. tostring(stringa) .. "|r"
			end
	end
	local colors=lib.colors
	local map={r=1,g=2,b=3,c=4}
	local mt={
			__index=function(table,key)
					return rawget(table,map[key])
			end,
			__tostring=function(table)
					return rawget(table,4)
			end,
			__concat=function(t1,t2)
					return tostring(t1) .. tostring(t2)
			end,
			__call=function(table,...)
					return unpack(table)
			end

	}
	C=setmetatable({},{
			__index=function(table,key)
				key=strlower(tostring(key))
					local c=colors[key]
					local r,g,b=tonumber(c:sub(1,2),16)/255,tonumber(c:sub(3,4),16)/255,tonumber(c:sub(5,6),16)/255
					rawset(table,key,setmetatable({r,g,b,c},mt))
					return  rawget(table,key)
			end,
			__call = function(table,...)
							return colorize(...)
			end
	}
	)
end
function lib:OnScreen(color,msg,hold)
	color=color or "Yellow"
	msg=msg or "Test message"
	local r,g,b=C[color]()
	hold=hold or 4
	UIErrorsFrame:AddMessage(tostring(msg), r,g,b, 1.0, UIERRORS_HOLD_TIME * hold);
end
setmetatable(lib,{
	__call=function(table,...) return C end
	}
)
