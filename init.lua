local s = core.get_mod_storage()
core.register_on_priv_revoke(function(name,revoker,priv)
    if priv == "shout" then
        s:set_string(name,"true")
    end
end)
core.register_on_priv_grant(function(name,granter,priv)
    if priv == "shout" then
        s:set_string(name,"")
    end
end)
core.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if not name then return end
    local ismuted = s:get_string(name)
    if ismuted == "true" then
        local privs = core.get_player_privs(name)
        privs["shout"] = nil
        core.after(0.1,function()
            core.set_player_privs(name,privs)
            core.chat_send_player(name,core.colorize("#F00","You have been muted. Вы заглушены."))
        end)
    end
end)
core.register_chatcommand("mute",{
    description = "Mute a player",
    privs = {basic_privs=true},
    params = "<name>",
    func = function(name,param)
        if param == "" then param = name end
        s:set_string(param,"true")
        local player = core.get_player_by_name(param)
        if player then
            local pname = player:get_player_name()
            if pname then
                local privs = core.get_player_privs(pname)
                privs["shout"] = nil
                core.set_player_privs(pname,privs)
                core.chat_send_player(pname,core.colorize("#F00","You have been muted. Вы заглушены."))
            end
        end
        return true, "Muted "..param
end})
core.register_chatcommand("unmute",{
    description = "Unmute a player",
    privs = {basic_privs=true},
    params = "<name>",
    func = function(name,param)
        if param == "" then param = name end
        s:set_string(param,"")
        local player = core.get_player_by_name(param)
        if player then
            local pname = player:get_player_name()
            if pname then
                local privs = core.get_player_privs(pname)
                privs["shout"] = true
                core.set_player_privs(pname,privs)
                core.chat_send_player(pname,core.colorize("#0F0","You have been unmuted. Вы разглушены."))
            end
        end
        return true, "Unmuted "..param
end})
core.register_chatcommand("muted",{
    description = "Show list of muted players",
    privs = {basic_privs=true},
    func = function(name,param)
        local out = {}
        local tabl = s:to_table().fields
        for nick,val in pairs(tabl) do
            table.insert(out,nick)
        end
        return true, "Muted: "..table.concat(out,", ")
end})
