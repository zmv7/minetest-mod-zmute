local s = core.get_mod_storage()
local S = core.get_translator("zmute")
core.register_on_priv_revoke(function(name,revoker,priv)
	if priv == "shout" then
		s:set_string(name,"shout priv revoked")
	end
end)
core.register_on_priv_grant(function(name,granter,priv)
	if priv == "shout" then
		s:set_string(name,"")
	end
end)
if core.get_modpath("privlockdown") then
	core.register_on_joinplayer(function(player)
		local name = player:get_player_name()
		if not name then return end
		local ismuted = s:get_string(name)
		if ismuted and ismuted ~= "" then
			local privs = core.get_player_privs(name)
			privs["shout"] = nil
			core.after(0.1,function()
				core.set_player_privs(name,privs)
				core.chat_send_player(name,core.colorize("#F00",S("You have been muted")))
			end)
		end
	end)
end
core.register_privilege("mute","Allows to mute and unmute players")
core.register_chatcommand("mute",{
  description = "Mute a player",
  privs = {mute=true},
  params = "<name> <reason>",
  func = function(name,param)
	local pname, reason = param:match("^(%S+) (.+)$")
	if not (pname and reason) then
		return false, "Invalid params"
	end
	if not core.player_exists(pname) then
		return false, "Player doesnt exists"
	end
	s:set_string(pname,reason)
	local privs = core.get_player_privs(pname)
	if type(privs) == "table" then
		privs["shout"] = nil
		core.set_player_privs(pname,privs)
	end
	if core.get_player_by_name(pname) then
		core.chat_send_player(pname,core.colorize("#F00",S("You have been muted")))
	end
	return true, "Muted "..pname.." for reason '"..reason.."'"
end})
core.register_chatcommand("unmute",{
  description = "Unmute a player",
  privs = {mute=true},
  params = "<name>",
  func = function(name,param)
	local pname = param:match("^%S+")
	if not pname then
		return false, "Invalid params"
	end
	if not core.player_exists(pname) then
		return false, "Player doesnt exists"
	end
	s:set_string(pname,"")
	local privs = core.get_player_privs(pname)
	if type(privs) == "table" then
		privs["shout"] = true
		core.set_player_privs(pname,privs)
	end
	if core.get_player_by_name(pname) then
		core.chat_send_player(pname,core.colorize("#0F0",S("You have been unmuted")))
	end
	return true, "Unmuted "..pname
end})
core.register_chatcommand("muted",{
  description = "Show list of muted players",
  privs = {mute=true},
  params = "[purge]",
  func = function(name,param)
		local out = {}
		local tabl = s:to_table().fields
		for nick,reason in pairs(tabl) do
			if param == "purge" then
				s:set_string(nick,"")
				local privs = core.get_player_privs(nick)
				if type(privs) == "table" then
					privs["shout"] = true
					core.set_player_privs(nick,privs)
				end
			else
				table.insert(out,nick.."("..reason..")")
			end
		end
		if param == "purge" then
			return true, "Mutelist purged"
		else
			return true, "Muted: "..table.concat(out,", ")
		end
end})
