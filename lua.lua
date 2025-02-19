    local ffi = require('ffi')
    local bit = require('bit')
    local antiaim_funcs = require('gamesense/antiaim_funcs')
    local base64 = require('gamesense/base64')
    local clipboard = require('gamesense/clipboard')
    local vector = require 'vector'

    local script_info = {
        build = "Stable",
        ver = "1.6",
        ds = "cvar1337",
    }

    --1
    local steamname = panorama.open("CSGOHud").MyPersonaAPI.GetName()

----------------------------------------------------------------
    
    --endregion

    local filesystem_find = vtable_bind("filesystem_stdio.dll", "VFileSystem017", 32, "const char* (__thiscall*)(void*, const char*, int*)")
    local exists = function(file)
        local int_ptr = ffi.new("int[1]")
        local res = filesystem_find(file, int_ptr)
        if res == ffi.NULL then
            return nil
        end

        return int_ptr, ffi.string(res)
    end

    local contain_bomb = function(ent)
    	local weapons = {}
    	for index = 0, 12 do
    		local weapon = entity.get_prop(ent, "m_hMyWeapons", index)
    		if weapon and entity.get_prop(weapon, "m_iItemDefinitionIndex") == 49 then
    			return true
    		end
    	end

    	return false
    end


    local success_img, defensive_image = pcall(renderer.load_png, image_data, 36, 36)
    local function str_to_sub(input, sep)
    	local t = {}
    	for str in string.gmatch(input, "([^"..sep.."]+)") do
    		t[#t + 1] = string.gsub(str, "\n", "")
    	end
    	return t
    end

    local function to_boolean(str)
    	if str == "true" or str == "false" then
    		return (str == "true")
    	else
    		return str
    	end
    end
    moriade = {
        table = {
            config_data = {};
            visuals = {
                image_loaded = "";
                animation_variables = {};
                new_change = true;
                to_draw_ticks = 0;
                offset_maxed2 = 0;
                indi_op = 0;
                offset_maxed = 0;
                indi_op2 = 0;
                indi_op3 = 0;
                indi_op4 = 0;
            };
        };
        reference = {};
        menu = {};
        anti_aim = {
            is_invert = false;
            tick_var = 0;
            cur_team = 0;
            tick_variables = 0;
            state_id = 0;
            is_active_inds = 0;
            pitch = "";
            pitch_value = 0;
            yaw_base = "";
            yaw = "";
            yaw_value = 0;
            yaw_jitter = "";
            yaw_jitter_value = 0;
            yaw_jitter_value_real = 0;
            body_yaw = "";
            body_yaw_value = 0;
            body_yaw_value_real = 0;
            freestanding_body_yaw = false;
            freestanding = "";
            freestanding_value = 0;
            defensive_ct = false;
            defensive_t = false;
            is_active = false;
            last_press = 0;
            aa_dir = 0;
            defensive = false;
            defensive_ticks = 0;
            ground_time = 0;
            tick_yaw = 0;
            current_preset = 0;
            aa_side = 0;
            aa_inverted = 0;
        };
    }
    
    moriade.reference = {
        anti_aim = {
            master                                            = ui.reference("AA", "Anti-aimbot angles", "Enabled");
            yaw_base                                          = ui.reference("AA", "Anti-aimbot angles", "Yaw base");
            pitch                                             = {ui.reference("AA", "Anti-aimbot angles", "Pitch")};
            yaw                     = {ui.reference("AA", "Anti-aimbot angles", "Yaw")};
            yaw_jitter       = {ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")};
            body_yaw           = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")};
            freestanding_body_yaw                             = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw");
            edge_yaw                                          = ui.reference("AA", "Anti-aimbot angles", "Edge yaw");
            freestanding      = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")};
            roll_offset                                       = ui.reference("AA", "Anti-aimbot angles", "Roll");
        };
        other = {
            double_tap = {ui.reference("RAGE", "Aimbot", "Double tap")};
            clantag = {ui.reference("MISC", "Miscellaneous", "Clan tag spammer")};
            hide_shots      = {ui.reference("AA", "Other", "On shot anti-aim")};
            fakeducking                                     = ui.reference("RAGE", "Other", "Duck peek assist");
            legs                                            = ui.reference("AA", "Other", "Leg movement");
            slow_motion    = {ui.reference("AA", "Other", "Slow motion")};
            bunny_hop = ui.reference("Misc", "Movement", "Bunny hop");
            enable_fakelag        = {ui.reference("AA", "Fake lag", "Enabled")};
            fakelag_limit        = ui.reference("AA", "Fake lag", "Limit");
            auto_peek = {ui.reference("rage", "other", "quick peek assist")};
        }
    }

    setup_skeet_element = function (types, element, value, type_of)
        if types == "vis" then
            for table, values in pairs(moriade.reference.anti_aim) do
                if type(values) == "table" then
                    for table_, values_ in pairs(values) do
                        if type_of == "load" then
                            ui.set_visible(values_, false)
                        else
                            ui.set_visible(values_, true)
                        end
                    end
                else
                    if type_of == "load" then
                        ui.set_visible(values, false)
                    else
                        ui.set_visible(values, true)
                    end
                end
            end
        elseif types == "vis_elem" then
            ui.set_visible(element, value)
        elseif types == "elem" then
            ui.set(element, value)
        end
    end;

    -- outside
    state3, ground_time = 'nil', 0
    alpha_pulse = 0
    offset_move = 0
    alpha_fade = 0
    offset_dt = 0
    offset_qp = 0
    offset_center = 0
    offset_state = 0
    offset_quickpeek = 0
    offset_rapid = 0
    offset_center2 = 0
    dtopa = 0
    qpopa = 0
    dtopa2 = 0
    dtopa3 = 0 
    dtopa4 = 0
    dtopa5 = 0
    dtopa6 = 0
    offset_rapid2 = 0
    offset_rapid3 = 0
    offset_quickpeek2 = 0
    dtopa7 = 0
    offset_quickpeek3 = 0
    local ground_ticks = 0
    local end_time = 0
    local step = 0
    dtopa8 = 0

    -- script helpers function

    local script = {}

    script.helpers = {
        defensive = 0,
        checker = 0,

        easeInOut = function(self, t)
            return (t > 0.5) and 4*((t-1)^3)+1 or 4*t^3;
        end,

        clamp = function(self, val, lower, upper)
            assert(val and lower and upper, "not very useful error message here")
            if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
            return math.max(lower, math.min(upper, val))
        end,

        split = function(self, inputstr, sep)
            if sep == nil then
                    sep = "%s"
            end
            local t={}
            for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                    table.insert(t, str)
            end
            return t
        end,

        rgba_to_hex = function(self, r, g, b, a)
          return bit.tohex(
            (math.floor(r + 0.5) * 16777216) + 
            (math.floor(g + 0.5) * 65536) + 
            (math.floor(b + 0.5) * 256) + 
            (math.floor(a + 0.5))
          )
        end,

        hex_to_rgba = function(self, hex)
        local color = tonumber(hex, 16)

        return 
        math.floor(color / 16777216) % 256, 
        math.floor(color / 65536) % 256, 
        math.floor(color / 256) % 256, 
        color % 256
        end,

        color_text = function(self, string, r, g, b, a)
            local accent = "\a" .. self:rgba_to_hex(r, g, b, a)
            local white = "\a" .. self:rgba_to_hex(255, 255, 255, a)

            local str = ""
            for i, s in ipairs(self:split(string, "$")) do
                str = str .. (i % 2 ==( string:sub(1, 1) == "$" and 0 or 1) and white or accent) .. s
            end

            return str
        end,

        animate_text = function(self, time, string, r, g, b, a)
            local t_out, t_out_iter = { }, 1

            local l = string:len( ) - 1

            local r_add = (255 - r)
            local g_add = (255 - g)
            local b_add = (255 - b)
            local a_add = (155 - a)

            for i = 1, #string do
                local iter = (i - 1)/(#string - 1) + time
                t_out[t_out_iter] = "\a" .. script.helpers:rgba_to_hex( r + r_add * math.abs(math.cos( iter )), g + g_add * math.abs(math.cos( iter )), b + b_add * math.abs(math.cos( iter )), a + a_add * math.abs(math.cos( iter )) )

                t_out[t_out_iter + 1] = string:sub( i, i )

                t_out_iter = t_out_iter + 2
            end

            return t_out
        end,

        get_time = function(self, h12)
            local hours, minutes, seconds = client.system_time()

            if h12 then
                    local hrs = hours % 12

                    if hrs == 0 then
                            hrs = 12
                    else
                            hrs = hrs < 10 and hrs or ('%02d'):format(hrs)
                    end

                    return ('%s:%02d %s'):format(
                            hrs,
                            minutes,
                            hours >= 12 and 'pm' or 'am'
                    )
            end

            return ('%02d:%02d:%02d'):format(
                    hours,
                    minutes,
                    seconds
            )
    end,
    }

    -- script renderer function

    script.renderer = {
       rec = function(self, x, y, w, h, radius, color)
            radius = math.min(x/2, y/2, radius)
            local r, g, b, a = unpack(color)
            renderer.rectangle(x, y + radius, w, h - radius*2, r, g, b, a)
            renderer.rectangle(x + radius, y, w - radius*2, radius, r, g, b, a)
            renderer.rectangle(x + radius, y + h - radius, w - radius*2, radius, r, g, b, a)
            renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
            renderer.circle(x - radius + w, y + radius, r, g, b, a, radius, 90, 0.25)
            renderer.circle(x - radius + w, y - radius + h, r, g, b, a, radius, 0, 0.25)
            renderer.circle(x + radius, y - radius + h, r, g, b, a, radius, -90, 0.25)
        end,

        rec_outline = function(self, x, y, w, h, radius, thickness, color)
            radius = math.min(w/2, h/2, radius)
            local r, g, b, a = unpack(color)
            if radius == 1 then
                renderer.rectangle(x, y, w, thickness, r, g, b, a)
                renderer.rectangle(x, y + h - thickness, w , thickness, r, g, b, a)
            else
                renderer.rectangle(x + radius, y, w - radius*2, thickness, r, g, b, a)
                renderer.rectangle(x + radius, y + h - thickness, w - radius*2, thickness, r, g, b, a)
                renderer.rectangle(x, y + radius, thickness, h - radius*2, r, g, b, a)
                renderer.rectangle(x + w - thickness, y + radius, thickness, h - radius*2, r, g, b, a)
                renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, thickness)
                renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius, 90, 0.25, thickness)
                renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, -90, 0.25, thickness)
                renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25, thickness)
            end
        end,

        glow_module = function(self, x, y, w, h, width, rounding, accent, accent_inner)
            local thickness = 1
            local offset = 1
            local r, g, b, a = unpack(accent)
            if accent_inner then
                self:rec(x , y, w, h + 1, rounding, accent_inner)
            end
            for k = 0, width do
                if a * (k/width)^(1) > 5 then
                    local accent = {r, g, b, a * (k/width)^(2)}
                    self:rec_outline(x + (k - width - offset)*thickness, y + (k - width - offset) * thickness, w - (k - width - offset)*thickness*2, h + 1 - (k - width - offset)*thickness*2, rounding + thickness * (width - k + offset), thickness, accent)
                end
            end
        end
    }


    -- contains function
    local function contains(tbl, val)
        for i=1,#tbl do
            if tbl[i] == val then
                return true
            end
        end
        return false
    end

    -- other functions
    function rounded_rectangle(x, y, r, g, b, a, width, height, radius)
        renderer.rectangle(x + radius, y + radius, width - (radius * 2), height - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y, width - (radius * 2), radius, r, g, b, a)
        renderer.rectangle(x + radius, y + height - radius, width - (radius * 2), radius, r, g, b, a)
        renderer.rectangle(x, y + radius, radius, height - (radius * 2), r, g, b, a)
        renderer.rectangle(x + (width - radius), y + radius, radius, height - (radius * 2), r, g, b, a)

        renderer.circle(x + radius, y + radius, r, g, b,a, radius, 145, radius * 0.1)
        renderer.circle(x + width - radius, y + radius, r, g, b, a, radius, 90, radius * 0.1)
        renderer.circle(x + radius, y + height - radius, r, g, b, a, radius, 180, radius * 0.1)
        renderer.circle(x + width - radius, y + height - radius, r, g, b, a, radius, 0, radius * 0.1)
    end

    rgba_to_hex = function(b,c,d,e)
        return string.format('%02x%02x%02x%02x',b,c,d,e)
    end

    text_fade_animation = function(speed, r, g, b, a, text)
        local final_text = ''
        local curtime = globals.curtime()
        for i=0, #text do
            local color = rgba_to_hex(r, g, b, a*math.abs(1*math.cos(2*speed*curtime/4+i*5/30)))
            final_text = final_text..'\a'..color..text:sub(i, i)
        end
        return final_text
    end

    local function roundedRectangle(b, c, d, e, f, g, h, i, j, k)
        renderer.rectangle(b, c, d, e, f, g, h, i)
        renderer.circle(b, c, f, g, h, i, k, -180, 0.25)
        renderer.circle(b + d, c, f, g, h, i, k, 90, 0.25)
        renderer.rectangle(b, c - k, d, k, f, g, h, i)
        renderer.circle(b + d, c + e, f, g, h, i, k, 0, 0.25)
        renderer.circle(b, c + e, f, g, h, i, k, -90, 0.25)
        renderer.rectangle(b, c + e, d, k, f, g, h, i)
        renderer.rectangle(b - k, c, k, e, f, g, h, i)
        renderer.rectangle(b + d, c, k, e, f, g, h, i)
    end

    -- animation variables function
    function moriade.table.visuals.animation_variables.lerp(a,b,t)
        return a + (b - a) * t
    end

    function moriade.table.visuals.animation_variables.pulsate(alpha,min,max,speed)

        if alpha >= max - 2 then
            moriade.table.visuals.new_change = false
        elseif alpha <= min  + 2 then
            moriade.table.visuals.new_change = true
        end

        if moriade.table.visuals.new_change == true then
            alpha = moriade.table.visuals.animation_variables.lerp(alpha,max,globals.frametime() * speed)
        else
            alpha = moriade.table.visuals.animation_variables.lerp(alpha,min,globals.frametime() * speed)
        end

        return alpha 
    end

    function moriade.table.visuals.animation_variables.movement(offset,when,original,new_place,speed)

        if when == true then
            offset = moriade.table.visuals.animation_variables.lerp(offset,new_place,globals.frametime() * speed)
        else
            offset = moriade.table.visuals.animation_variables.lerp(offset,original,globals.frametime() * speed)
        end

        return offset 
    end

    function moriade.table.visuals.animation_variables.fade(alpha,fade_bool,f_in,f_away,speed) 

        if fade_bool == true then 
            alpha = moriade.table.visuals.animation_variables.lerp(alpha,f_in,globals.frametime() * speed)
        else
            alpha = moriade.table.visuals.animation_variables.lerp(alpha,f_away,globals.frametime() * speed)
        end

        return alpha
    end

    -- menu elements

    moriade.menu.antiaim_elements = {}
    moriade.menu.antiaim_elements_t = {}
    moriade.menu.tab_label = ui.new_label("AA", "Anti-aimbot angles", " ");
    moriade.menu.color_picker = ui.new_color_picker("AA", "Anti-aimbot angles", " ", 175 ,175, 195, 255);
    moriade.menu.tab_selector = ui.new_combobox("AA", "Anti-aimbot angles", "\nselection", {"info", "anti-aim", "rage", "misc", "visuals"});
    moriade.menu.antiaim_enable_addons = ui.new_checkbox("AA", "Fake lag", "\aFFFFFFFFKeybinds");
    moriade.menu.tab2_label1 = ui.new_label("AA", "Anti-aimbot angles", "\aAFAFC3FF•------------------------------------------------•");
    moriade.menu.tab2_label7 = ui.new_label("AA", "Anti-aimbot angles", "\aAFAFC3FF• User: ez dumped by solyX" --[[.. steamname]]);
    moriade.menu.tab2_label2 = ui.new_label("AA", "Anti-aimbot angles", "\aAFAFC3FF• Version:  " .. script_info.ver);
    moriade.menu.tab2_label3 = ui.new_label("AA", "Anti-aimbot angles", "\aAFAFC3FF• Build:  " .. script_info.build);
    moriade.menu.tab2_label4 = ui.new_label("AA", "Anti-aimbot angles", "\aAFAFC3FF• Author Discord:  " .. script_info.ds);
    moriade.menu.discord = ui.new_button("AA", "Anti-aimbot angles", "Discord" , function()
        panorama.loadstring("SteamOverlayAPI.OpenExternalBrowserURL('https://discord.gg/zPzDtxgDFX');")()
    end);
    moriade.menu.antiaim_manual_left = ui.new_hotkey("AA", "Fake lag", "\aFFFFFFFF• Yaw Left");
    moriade.menu.antiaim_manual_right = ui.new_hotkey("AA", "Fake lag", "\aFFFFFFFF• Yaw Right");
    moriade.menu.antiaim_manual_forward = ui.new_hotkey("AA", "Fake lag", "\aFFFFFFFF• Yaw Forward");
    moriade.menu.antiaim_freestanding = ui.new_hotkey("AA", "Fake lag", "\aFFFFFFFF• Yaw Freestand");
    moriade.menu.antiaim_flickfs = ui.new_checkbox("AA", "Fake lag", "\aFFFFFFFF• FS breacker");
    moriade.menu.fpsboost = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFFps boost");
    moriade.menu.misclabel = ui.new_label("AA", "Anti-aimbot angles", "\aAFAFC3FF•------------------------------------------------•");
    moriade.menu.antiaim_anti_knife = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFAnti Backstab");
    moriade.menu.antiaim_legit_aa = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFLegit AA");
    moriade.menu.ragelabel = ui.new_label("AA", "Anti-aimbot angles", "\aAFAFC3FF•------------------------------------------------•");
    moriade.menu.breaklc = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFAuto teleport")
    moriade.menu.breaklckey = ui.new_hotkey("AA", "Anti-aimbot angles", "\aFFFFFFFFAuto teleport", true)
    moriade.menu.consolefilter = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFConsole filter");
    moriade.menu.log_render = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFAim logs");
    moriade.menu.killsay = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFTrash talk");
    moriade.menu.clantag = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFClan tag");
    moriade.menu.airstop = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFAir stop")
    moriade.menu.airstopkey = ui.new_hotkey("AA", "Anti-aimbot angles", "\aFFFFFFFFFFAir stop", true)
    moriade.menu.antiaim_bomb_site_unuse = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFBomb E fix");
    moriade.menu.antiaim_quickpeek = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFPeek Options");
    moriade.menu.antiaim_quickpeek_addons = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFFBody", "Static", "Jitter", "Opposite");
    moriade.menu.antiaim_safeknife = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFSafe Head");
    moriade.menu.antiaim_safeknife_options = ui.new_multiselect("AA", "Anti-aimbot angles", "\aFFFFFFFFTrigger", "Knife", "Taser");
    moriade.menu.indicators = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFFDefensive Indicator");
    moriade.menu.watermark = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFFWatermark", "Bottom", "Side");
    moriade.menu.indicators5 = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFFIndicator", "-", "Modern", "v2");
    moriade.menu.animbreak = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFFAnim breaks", "-", "Earthquake", "Kangaroo");
    moriade.menu.indicator_main_color_label = ui.new_label("AA", "Anti-aimbot angles", "\aFFFFFFFFMain color");
    moriade.menu.indicator_main_color = ui.new_color_picker("AA", "Anti-aimbot angles", "Main Color\nClr", 0, 255, 255, 255);
    moriade.menu.indicator_main_os_color_label = ui.new_label("AA", "Anti-aimbot angles", "\aFFFFFFFFMain(OS) color");
    moriade.menu.indicator_main_os_color = ui.new_color_picker("AA", "Anti-aimbot angles", "Main(Os) Color\nClr", 0, 255, 0, 255);
    moriade.menu.indicator_main_dt_color_label = ui.new_label("AA", "Anti-aimbot angles", "\aFFFFFFFFMain(DT) color");
    moriade.menu.indicator_main_dt_color = ui.new_color_picker("AA", "Anti-aimbot angles", "Main(DT) Color\nClr", 255, 0, 0, 255);
    moriade.menu.indicator_accent_color_label = ui.new_label("AA", "Anti-aimbot angles", "\aFFFFFFFFAccent color");
    moriade.menu.indicator_accent_color = ui.new_color_picker("AA", "Anti-aimbot angles", "Accent Color\nClr", 215, 145, 175, 255);

    moriade.menu.builder_state = {'Global', 'Stand', 'Run', 'Slow', 'Air', 'Air Crouch', 'Crouch Move', 'Crouch', 'Fakelag', 'Freestand', 'Manual right', 'Manual left'}
    moriade.menu.state_to_num = { 
        ['Global'] = 1, 
        ['Stand'] = 2, 
        ['Run'] = 3, 
        ['Slow'] = 4, --export
        ['Air'] = 5,
        ['Air Crouch'] = 6,
        ['Crouch Move'] = 7,
        ['Crouch'] = 8,
        ['Fakelag'] = 9,
        ['Freestand'] = 10,
        ['Manual right'] = 11,
        ['Manual left'] = 12,
    };
    moriade.menu.aalabel = ui.new_label("AA", "Anti-aimbot angles", "\aAFAFC3FF•------------------------------------------------•");
    moriade.menu.aabuilder_state = ui.new_combobox("AA", "Anti-aimbot angles", "\aAFAFC3FFState \aFFFFFFFFSelect:", moriade.menu.builder_state)

    -- anti_aim elements
    for k, v in pairs(moriade.menu.builder_state) do
        moriade.menu.antiaim_elements[k] = {  
            enable = ui.new_checkbox("AA", "Anti-aimbot angles", "\aAFAFC3FFEnable: "..moriade.menu.builder_state[k].."");
            antiaim_pitch = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Pitch Type", {"L&R", "Jitter", "Delayed"});
            antiaim_pitch_slider_speed = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Pitch Speed  ", 1, 40, 0, true, "t");
            antiaim_pitch_slider_first = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." First Pitch ", -89, 89, 0, true, "°");
            antiaim_pitch_slider_second = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Second Pitch ", -89, 89, 0, true, "°");
            antiaim_yaw = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Yaw ", {"180", "Spin", "Static"});
            antiaim_yaw_advanced = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Yaw Type ", {"L&R", "Jitter", "Delayed"});
            antiaim_yaw_slider_speed = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Yaw Speed  ", 1, 40, 0, true, "t");
            antiaim_yaw_slider_left = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Left Yaw  ", -180, 180, 0, true, "°");
            antiaim_yaw_slider_right = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Right Yaw  ", -180, 180, 0, true, "°");
            antiaim_body_yaw_correction = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Body Yaw Correction");
            antiaim_yaw_jitter = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Jitter Type ", {"Center", "Offset", "Skitter", "Random"});
            antiaim_yaw_jitter_type = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Jitter Method", {"L&R", "Jitter", "Delayed"});
            antiaim_yaw_jitter_slider_speed = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Jitter Speed  ", 1, 40, 0, true, "t");
            antiaim_yaw_jitter_slider_l = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Left Jitter ", -180, 180, 0, true, "°");
            antiaim_yaw_jitter_slider_r = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Right Jitter ", -180, 180, 0, true, "°");
            antiaim_body_yaw = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Body Type ", {"Static", "Jitter", "Off"});
            antiaim_body_yaw_type = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Body Method", {"L&R", "Jitter", "Delayed"});
            antiaim_body_yaw_speed = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Body Speed  ", 1, 40, 0, true, "t");
            antiaim_body_yaw_slider_l = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Left Body", -180, 180, 0, true, "°");
            antiaim_body_yaw_slider_r = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Right Body", -180, 180, 0, true, "°");
            antiaim_defensive = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive breacker", {"On peak", "GameSense", "NeverLose", "Moriade"});
            antiaim_defensive_slider =  ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Ticks", 0, 11, 0, true, "t", 1, {[0] = "Always on"});
            antiaim_defensive_enable = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive");
            antiaim_defensive_pitch = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Pitch Type", {"L&R", "Jitter", "Delayed"});
            antiaim_defensive_pitch_slider_speed = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Pitch Speed  ", 1, 40, 0, true, "t");
            antiaim_defensive_pitch_slider_first = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive First Pitch ", -89, 89, 0, true, "°");
            antiaim_defensive_pitch_slider_second = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Second Pitch ", -89, 89, 0, true, "°");
            antiaim_defensive_yaw = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Yaw ", {"180", "Spin", "Static"});
            antiaim_defensive_yaw_advanced = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Yaw Type ", {"L&R", "Jitter", "Delayed"});
            antiaim_defensive_yaw_slider_speed = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Yaw Speed  ", 1, 40, 0, true, "t");
            antiaim_defensive_yaw_slider_left = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Left Yaw  ", -180, 180, 0, true, "°");
            antiaim_defensive_yaw_slider_right = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Right Yaw  ", -180, 180, 0, true, "°");
            antiaim_defensive_body_yaw_correction = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Body Yaw Correction");
            antiaim_defensive_yaw_jitter = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Jitter Type ", {"Center", "Offset", "Skitter", "Random"});
            antiaim_defensive_yaw_jitter_type = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Jitter Method", {"L&R", "Jitter", "Delayed"});
            antiaim_defensive_yaw_jitter_slider_speed = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Jitter Speed  ", 1, 40, 0, true, "t");
            antiaim_defensive_yaw_jitter_slider_l = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Left Jitter ", -180, 180, 0, true, "°");
            antiaim_defensive_yaw_jitter_slider_r = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Right Jitter ", -180, 180, 0, true, "°");
            antiaim_defensive_body_yaw = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Body Type ", {"Static", "Jitter", "Off"});
            antiaim_defensive_body_yaw_type = ui.new_combobox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Body Method", {"L&R", "Jitter", "Delayed"});
            antiaim_defensive_body_yaw_speed = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Jitter Speed  ", 1, 40, 0, true, "t");
            antiaim_defensive_body_yaw_slider_l = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Left Body", -180, 180, 0, true, "°");
            antiaim_defensive_body_yaw_slider_r = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Defensive Right Body", -180, 180, 0, true, "°");
            antiaim_height_asvantage = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Height advantage");
            antiaim_height_asvantage_slider = ui.new_slider("AA", "Anti-aimbot angles", "\aFFFFFFFF"..moriade.menu.builder_state[k].." Height advantage offset", 0, 300, 0, true);
        }
    end

    -- config data

    moriade.table.config_data.cfg_data = {
        anti_aim = {
            moriade.menu.antiaim_elements[1].antiaim_pitch;
            moriade.menu.antiaim_elements[1].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[1].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[1].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[1].antiaim_yaw;
            moriade.menu.antiaim_elements[1].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[1].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[1].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[1].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[1].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[1].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[1].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[1].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[1].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[1].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[1].antiaim_body_yaw;
            moriade.menu.antiaim_elements[1].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[1].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[1].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[1].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[1].antiaim_defensive;
            moriade.menu.antiaim_elements[1].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[1].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[1].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[1].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[1].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[1].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[1].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[1].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[1].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[1].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[1].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[1].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[1].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[1].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[1].antiaim_height_asvantage_slider;
            
            moriade.menu.antiaim_elements[2].enable;
            moriade.menu.antiaim_elements[2].antiaim_pitch;
            moriade.menu.antiaim_elements[2].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[2].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[2].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[2].antiaim_yaw;
            moriade.menu.antiaim_elements[2].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[2].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[2].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[2].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[2].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[2].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[2].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[2].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[2].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[2].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[2].antiaim_body_yaw;
            moriade.menu.antiaim_elements[2].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[2].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[2].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[2].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[2].antiaim_defensive;
            moriade.menu.antiaim_elements[2].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[2].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[2].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[2].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[2].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[2].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[2].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[2].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[2].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[2].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[2].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[2].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[2].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[2].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[2].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[3].enable;
            moriade.menu.antiaim_elements[3].antiaim_pitch;
            moriade.menu.antiaim_elements[3].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[3].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[3].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[3].antiaim_yaw;
            moriade.menu.antiaim_elements[3].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[3].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[3].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[3].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[3].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[3].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[3].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[3].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[3].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[3].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[3].antiaim_body_yaw;
            moriade.menu.antiaim_elements[3].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[3].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[3].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[3].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[3].antiaim_defensive;
            moriade.menu.antiaim_elements[3].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[3].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[3].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[3].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[3].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[3].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[3].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[3].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[3].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[3].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[3].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[3].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[3].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[3].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[3].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[4].enable;
            moriade.menu.antiaim_elements[4].antiaim_pitch;
            moriade.menu.antiaim_elements[4].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[4].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[4].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[4].antiaim_yaw;
            moriade.menu.antiaim_elements[4].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[4].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[4].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[4].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[4].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[4].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[4].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[4].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[4].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[4].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[4].antiaim_body_yaw;
            moriade.menu.antiaim_elements[4].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[4].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[4].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[4].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[4].antiaim_defensive;
            moriade.menu.antiaim_elements[4].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[4].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[4].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[4].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[4].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[4].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[4].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[4].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[4].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[4].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[4].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[4].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[4].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[4].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[4].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[5].enable;
            moriade.menu.antiaim_elements[5].antiaim_pitch;
            moriade.menu.antiaim_elements[5].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[5].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[5].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[5].antiaim_yaw;
            moriade.menu.antiaim_elements[5].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[5].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[5].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[5].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[5].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[5].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[5].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[5].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[5].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[5].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[5].antiaim_body_yaw;
            moriade.menu.antiaim_elements[5].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[5].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[5].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[5].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[5].antiaim_defensive;
            moriade.menu.antiaim_elements[5].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[5].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[5].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[5].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[5].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[5].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[5].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[5].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[5].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[5].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[5].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[5].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[5].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[5].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[5].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[6].enable;
            moriade.menu.antiaim_elements[6].antiaim_pitch;
            moriade.menu.antiaim_elements[6].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[6].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[6].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[6].antiaim_yaw;
            moriade.menu.antiaim_elements[6].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[6].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[6].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[6].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[6].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[6].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[6].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[6].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[6].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[6].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[6].antiaim_body_yaw;
            moriade.menu.antiaim_elements[6].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[6].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[6].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[6].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[6].antiaim_defensive;
            moriade.menu.antiaim_elements[6].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[6].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[6].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[6].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[6].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[6].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[6].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[6].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[6].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[6].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[6].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[6].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[6].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[6].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[6].antiaim_height_asvantage_slider;
            
            moriade.menu.antiaim_elements[7].enable;
            moriade.menu.antiaim_elements[7].antiaim_pitch;
            moriade.menu.antiaim_elements[7].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[7].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[7].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[7].antiaim_yaw;
            moriade.menu.antiaim_elements[7].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[7].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[7].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[7].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[7].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[7].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[7].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[7].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[7].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[7].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[7].antiaim_body_yaw;
            moriade.menu.antiaim_elements[7].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[7].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[7].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[7].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[7].antiaim_defensive;
            moriade.menu.antiaim_elements[7].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[7].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[7].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[7].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[7].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[7].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[7].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[7].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[7].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[7].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[7].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[7].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[7].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[7].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[7].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[8].enable;
            moriade.menu.antiaim_elements[8].antiaim_pitch;
            moriade.menu.antiaim_elements[8].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[8].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[8].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[8].antiaim_yaw;
            moriade.menu.antiaim_elements[8].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[8].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[8].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[8].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[8].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[8].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[8].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[8].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[8].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[8].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[8].antiaim_body_yaw;
            moriade.menu.antiaim_elements[8].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[8].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[8].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[8].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[8].antiaim_defensive;
            moriade.menu.antiaim_elements[8].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[8].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[8].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[8].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[8].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[8].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[8].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[8].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[8].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[8].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[8].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[8].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[8].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[8].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[8].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[9].enable;
            moriade.menu.antiaim_elements[9].antiaim_pitch;
            moriade.menu.antiaim_elements[9].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[9].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[9].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[9].antiaim_yaw;
            moriade.menu.antiaim_elements[9].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[9].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[9].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[9].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[9].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[9].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[9].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[9].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[9].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[9].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[9].antiaim_body_yaw;
            moriade.menu.antiaim_elements[9].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[9].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[9].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[9].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[9].antiaim_defensive;
            moriade.menu.antiaim_elements[9].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[9].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[9].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[9].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[9].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[9].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[9].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[9].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[9].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[9].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[9].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[9].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[9].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[9].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[9].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[10].enable;
            moriade.menu.antiaim_elements[10].antiaim_pitch;
            moriade.menu.antiaim_elements[10].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[10].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[10].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[10].antiaim_yaw;
            moriade.menu.antiaim_elements[10].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[10].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[10].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[10].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[10].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[10].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[10].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[10].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[10].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[10].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[10].antiaim_body_yaw;
            moriade.menu.antiaim_elements[10].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[10].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[10].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[10].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[10].antiaim_defensive;
            moriade.menu.antiaim_elements[10].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[10].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[10].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[10].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[10].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[10].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[10].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[10].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[10].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[10].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[10].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[10].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[10].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[10].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[10].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[11].enable;
            moriade.menu.antiaim_elements[11].antiaim_pitch;
            moriade.menu.antiaim_elements[11].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[11].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[11].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[11].antiaim_yaw;
            moriade.menu.antiaim_elements[11].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[11].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[11].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[11].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[11].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[11].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[11].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[11].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[11].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[11].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[11].antiaim_body_yaw;
            moriade.menu.antiaim_elements[11].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[11].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[11].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[11].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[11].antiaim_defensive;
            moriade.menu.antiaim_elements[11].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[11].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[11].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[11].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[11].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[11].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[11].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[11].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[11].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[11].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[11].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[11].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[11].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[11].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[11].antiaim_height_asvantage_slider;

            moriade.menu.antiaim_elements[12].enable;
            moriade.menu.antiaim_elements[12].antiaim_pitch;
            moriade.menu.antiaim_elements[12].antiaim_pitch_slider_speed;
            moriade.menu.antiaim_elements[12].antiaim_pitch_slider_first;
            moriade.menu.antiaim_elements[12].antiaim_pitch_slider_second;
            moriade.menu.antiaim_elements[12].antiaim_yaw;
            moriade.menu.antiaim_elements[12].antiaim_yaw_advanced;
            moriade.menu.antiaim_elements[12].antiaim_yaw_slider_speed;
            moriade.menu.antiaim_elements[12].antiaim_yaw_slider_left;
            moriade.menu.antiaim_elements[12].antiaim_yaw_slider_right;
            moriade.menu.antiaim_elements[12].antiaim_body_yaw_correction;
            moriade.menu.antiaim_elements[12].antiaim_yaw_jitter;
            moriade.menu.antiaim_elements[12].antiaim_yaw_jitter_type;
            moriade.menu.antiaim_elements[12].antiaim_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[12].antiaim_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[12].antiaim_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[12].antiaim_body_yaw;
            moriade.menu.antiaim_elements[12].antiaim_body_yaw_type;
            moriade.menu.antiaim_elements[12].antiaim_body_yaw_speed;
            moriade.menu.antiaim_elements[12].antiaim_body_yaw_slider_l;
            moriade.menu.antiaim_elements[12].antiaim_body_yaw_slider_r;
            moriade.menu.antiaim_elements[12].antiaim_defensive;
            moriade.menu.antiaim_elements[12].antiaim_defensive_slider;
            moriade.menu.antiaim_elements[12].antiaim_defensive_enable;
            moriade.menu.antiaim_elements[12].antiaim_defensive_pitch;
            moriade.menu.antiaim_elements[12].antiaim_defensive_pitch_slider_speed;
            moriade.menu.antiaim_elements[12].antiaim_defensive_pitch_slider_first;
            moriade.menu.antiaim_elements[12].antiaim_defensive_pitch_slider_second;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_advanced;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_slider_speed;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_slider_left;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_slider_right;
            moriade.menu.antiaim_elements[12].antiaim_defensive_body_yaw_correction;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_jitter;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_jitter_type;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_jitter_slider_speed;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_jitter_slider_l;
            moriade.menu.antiaim_elements[12].antiaim_defensive_yaw_jitter_slider_r;
            moriade.menu.antiaim_elements[12].antiaim_defensive_body_yaw;
            moriade.menu.antiaim_elements[12].antiaim_defensive_body_yaw_type;
            moriade.menu.antiaim_elements[12].antiaim_defensive_body_yaw_speed;
            moriade.menu.antiaim_elements[12].antiaim_defensive_body_yaw_slider_l;
            moriade.menu.antiaim_elements[12].antiaim_defensive_body_yaw_slider_r;
            moriade.menu.antiaim_elements[12].antiaim_height_asvantage;
            moriade.menu.antiaim_elements[12].antiaim_height_asvantage_slider;
        };

        keybindsandothertable = {};
        other_aa = {};
    }

    --#region configs

    local export_config = ui.new_button("AA", "Other", "\aAFAFC3FFExport anti-aims", function ()
        local Code = {{}, {}, {}};

        for _, main in pairs(moriade.table.config_data.cfg_data.anti_aim) do
            if ui.get(main) ~= nil then
                table.insert(Code[1], tostring(ui.get(main)))
            end
        end

        for _, main in pairs(moriade.table.config_data.cfg_data.keybindsandothertable) do
            if ui.get(main) ~= nil then
                table.insert(Code[2], tostring(framework.library["=>"].func.arr_to_string(main)))
            end
        end

        for _, main in pairs(moriade.table.config_data.cfg_data.other_aa) do
            if ui.get(main) ~= nil then
                table.insert(Code[3], tostring(ui.get(main)))
            end
        end

        clipboard.set(base64.encode(json.stringify(Code)))
    end);

    local import_config = ui.new_button("AA", "Other", "\aAFAFC3FFImport anti-aims", function ()
        local protected = function() 
            for k, v in pairs(json.parse(base64.decode(clipboard.get()))) do
                
                k = ({[1] = "anti_aim", [2] = "keybindsandothertable", [3] = "other_aa"})[k]

                for k2, v2 in pairs(v) do
                    if (k == "anti_aim") then
                        if v2 == "true" then
                            ui.set(moriade.table.config_data.cfg_data[k][k2], true)
                        elseif v2 == "false" then
                            ui.set(moriade.table.config_data.cfg_data[k][k2], false)
                        else
                            ui.set(moriade.table.config_data.cfg_data[k][k2], v2)
                        end
                    end
                    if (k == "keybindsandothertable") then
                        ui.set(moriade.table.config_data.cfg_data[k][k2], framework.library["=>"].func.str_to_sub(v2, ","))
                    end
                    if (k == "other_aa") then
                        if v2 == "true" then
                            ui.set(moriade.table.config_data.cfg_data[k][k2], true)
                        elseif v2 == "false" then
                            ui.set(moriade.table.config_data.cfg_data[k][k2], false)
                        else
                            ui.set(moriade.table.config_data.cfg_data[k][k2], v2)
                        end
                    end
                end
            end
        end
        local status, message = pcall(protected)
        if not status then
            error("error cfg")
            return
        end
    end);

    --#endregion configs

    --#region visible

    client.set_event_callback( "paint_ui", function(  )
        setup_skeet_element("vis", nil, nil, "load")
        setup_skeet_element("vis_elem", export_config, ui.get(moriade.menu.tab_selector) == "anti-aim", nil)
        setup_skeet_element("vis_elem", import_config, ui.get(moriade.menu.tab_selector) == "anti-aim", nil)
        local r,g,b = ui.get(moriade.menu.color_picker)
        if ui.is_menu_open() then
            ui.set(moriade.menu.tab_label, text_fade_animation(8, r,g,b, 255, "moriade.lua ~ [stable]"))
        end
        local info_tab = ui.get(moriade.menu.tab_selector) == "info"
        local anti_aim_tab = ui.get(moriade.menu.tab_selector) == "anti-aim"
        local rage_tab = ui.get(moriade.menu.tab_selector) == "rage"
        local misc_tab = ui.get(moriade.menu.tab_selector) == "misc"
        local visuals_tab = ui.get(moriade.menu.tab_selector) == "visuals"
        local yaw_addons_enabled = ui.get(moriade.menu.antiaim_enable_addons)
        for i = 1,#moriade.menu.builder_state do
            -- anti_aim elements
            local selecte = ui.get(moriade.menu.aabuilder_state)
            local conditions_enabled_ct = ui.get(moriade.menu.antiaim_elements[i].enable)
            local show_ct = anti_aim_tab and selecte == moriade.menu.builder_state[i] and conditions_enabled_ct 
           
            -- counter
            ui.set_visible(moriade.menu.antiaim_elements[i].enable, anti_aim_tab and selecte == moriade.menu.builder_state[i] and i > 1)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_pitch, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_pitch_slider_speed, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_pitch) == "Delayed")
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_pitch_slider_first, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_pitch_slider_second, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_advanced, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_slider_speed, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_yaw_advanced) == "Delayed")
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_slider_left, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_slider_right, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_body_yaw_correction, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_jitter, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_jitter_type, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_jitter_slider_speed, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_yaw_jitter_type) == "Delayed")
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_jitter_slider_r, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_yaw_jitter_slider_l, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_body_yaw, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_body_yaw_type, show_ct and not ui.get(moriade.menu.antiaim_elements[i].antiaim_body_yaw_correction))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_body_yaw_speed, show_ct and not ui.get(moriade.menu.antiaim_elements[i].antiaim_body_yaw_correction) and ui.get(moriade.menu.antiaim_elements[i].antiaim_body_yaw_type) == "Delayed")
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_body_yaw_slider_l, show_ct and not ui.get(moriade.menu.antiaim_elements[i].antiaim_body_yaw_correction))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_body_yaw_slider_r, show_ct and not ui.get(moriade.menu.antiaim_elements[i].antiaim_body_yaw_correction))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive, show_ct and selecte ~= 'Fakelag')
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_slider, show_ct and selecte ~= 'Fakelag')
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_enable, show_ct and selecte ~= 'Fakelag')
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_pitch, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_pitch_slider_speed, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable) and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_pitch) == "Delayed")
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_pitch_slider_first, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_pitch_slider_second, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_advanced, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_slider_speed, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable) and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_advanced) == "Delayed")
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_slider_left, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_slider_right, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_correction, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_jitter, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_jitter_type, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_jitter_slider_speed, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable) and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_jitter_type) == "Delayed")
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_jitter_slider_r, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_yaw_jitter_slider_l, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_type, show_ct and not ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_correction) and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_speed, show_ct and not ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_correction) and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable) and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_type) == "Delayed")
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_slider_l, show_ct and not ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_correction) and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_slider_r, show_ct and not ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_body_yaw_correction) and ui.get(moriade.menu.antiaim_elements[i].antiaim_defensive_enable))
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_height_asvantage, show_ct)
            ui.set_visible(moriade.menu.antiaim_elements[i].antiaim_height_asvantage_slider, show_ct and ui.get(moriade.menu.antiaim_elements[i].antiaim_height_asvantage))
        end

        -- other elements
        ui.set_visible(moriade.menu.antiaim_anti_knife, misc_tab)
        ui.set_visible(moriade.menu.fpsboost, visuals_tab)
        ui.set_visible(moriade.menu.antiaim_legit_aa, misc_tab)
        ui.set_visible(moriade.menu.killsay, rage_tab)
        ui.set_visible(moriade.menu.consolefilter, misc_tab)
        ui.set_visible(moriade.menu.log_render, rage_tab)
        ui.set_visible(moriade.menu.clantag, misc_tab)
        ui.set_visible(moriade.menu.breaklc, rage_tab)
        ui.set_visible(moriade.menu.airstop, rage_tab)
        ui.set_visible(moriade.menu.airstopkey, rage_tab)
        ui.set_visible(moriade.menu.tab2_label1, info_tab)
        ui.set_visible(moriade.menu.tab2_label7, info_tab)
        ui.set_visible(moriade.menu.tab2_label2, info_tab)
        ui.set_visible(moriade.menu.tab2_label3, info_tab)
        ui.set_visible(moriade.menu.tab2_label4, info_tab)
        ui.set_visible(moriade.menu.discord, info_tab)
        ui.set_visible(moriade.menu.EnableResolver, rage_tab)
        ui.set_visible(moriade.menu.breaklckey, rage_tab)
        ui.set_visible(moriade.menu.antiaim_bomb_site_unuse, misc_tab)
        ui.set_visible(moriade.menu.antiaim_quickpeek, misc_tab)
        ui.set_visible(moriade.menu.antiaim_quickpeek_addons, misc_tab and ui.get(moriade.menu.antiaim_quickpeek))
        ui.set_visible(moriade.menu.aalabel, anti_aim_tab)
        ui.set_visible(moriade.menu.ragelabel, rage_tab)
        ui.set_visible(moriade.menu.misclabel, misc_tab)
        ui.set_visible(moriade.menu.aabuilder_state, anti_aim_tab)
        ui.set_visible(moriade.menu.antiaim_enable_addons, anti_aim_tab)
        ui.set_visible(moriade.menu.antiaim_manual_left, anti_aim_tab and yaw_addons_enabled)
        ui.set_visible(moriade.menu.antiaim_manual_right, anti_aim_tab and yaw_addons_enabled)
        ui.set_visible(moriade.menu.antiaim_manual_forward, anti_aim_tab and yaw_addons_enabled)
        ui.set_visible(moriade.menu.antiaim_freestanding, anti_aim_tab and yaw_addons_enabled)
        ui.set_visible(moriade.menu.antiaim_flickfs, anti_aim_tab)
        ui.set_visible(moriade.menu.antiaim_safeknife, misc_tab)
        ui.set_visible(moriade.menu.antiaim_safeknife_options, misc_tab and ui.get(moriade.menu.antiaim_safeknife))
        ui.set_visible(moriade.menu.indicators5, visuals_tab)
        ui.set_visible(moriade.menu.indicators, visuals_tab)
        ui.set_visible(moriade.menu.indicator_main_color_label, visuals_tab and ui.get(moriade.menu.indicators5) == "v2")
        ui.set_visible(moriade.menu.indicator_main_color, visuals_tab and ui.get(moriade.menu.indicators5) == "v2")
        ui.set_visible(moriade.menu.indicator_main_os_color_label, visuals_tab and ui.get(moriade.menu.indicators5) == "v2")
        ui.set_visible(moriade.menu.indicator_main_os_color, visuals_tab and ui.get(moriade.menu.indicators5) == "v2")
        ui.set_visible(moriade.menu.indicator_main_dt_color_label, visuals_tab and ui.get(moriade.menu.indicators5) == "v2")
        ui.set_visible(moriade.menu.indicator_main_dt_color, visuals_tab and ui.get(moriade.menu.indicators5) == "v2")
        ui.set_visible(moriade.menu.indicator_accent_color_label, visuals_tab and ui.get(moriade.menu.indicators5) == "v2")
        ui.set_visible(moriade.menu.indicator_accent_color, visuals_tab and ui.get(moriade.menu.indicators5) == "v2")
        ui.set_visible(moriade.menu.watermark, visuals_tab)
        ui.set_visible(moriade.menu.animbreak, visuals_tab)
    end)

    setup_skeet_element("elem", moriade.reference.anti_aim.master, true, nil)
    setup_skeet_element("elem", moriade.menu.antiaim_elements[1].enable, true, nil)
    setup_skeet_element("vis_elem", moriade.menu.antiaim_elements[1].enable, false, nil)

    --#endregion visible

    --#region events

    local function is_vulnerable()
        for _, v in ipairs(entity.get_players(true)) do
            local flags = (entity.get_esp_data(v)).flags
    
            if bit.band(flags, bit.lshift(1, 11)) ~= 0 then
                return true
            end
        end
    
        return false
    end

    -- custom anti_aims
    manipulation_break = function(a, b, time)
        return (time / 2 <= (globals.tickcount() % time)) and a or b --print
    end;

    get_body_yaw = function(player)
    	return entity.get_prop(player, "m_flPoseParameter", 11) * 120 - 60
    end

    -- state functions

    get_anti_aimbuilder_state = function ()
        local state = ""
        local lp = entity.get_local_player()
        local vel1, vel2, vel3 = entity.get_prop(lp, 'm_vecVelocity')
        local velocity = math.floor(math.sqrt(vel1 * vel1 + vel2 * vel2))
        local on_ground = bit.band(entity.get_prop(lp, "m_fFlags"), 1) == 1
        local not_moving = velocity < 2
        local slowwalk_key = ui.get(moriade.reference.other.slow_motion[2])
        local teamnum = entity.get_prop(lp, 'm_iTeamNum')
        local vec_velocity = { entity.get_prop(lp, 'm_vecVelocity') }
        local teamnum = entity.get_prop(lp, 'm_iTeamNum') 
        local duck_amount = entity.get_prop(lp, 'm_flDuckAmount')
        local velocity = math.floor(math.sqrt(vec_velocity[1] ^ 2 + vec_velocity[2] ^ 2) + 0.5)
        local air = bit.band(entity.get_prop(lp, 'm_fFlags'), 1) == 0
        if air == false then
            moriade.anti_aim.ground_time = moriade.anti_aim.ground_time + 1
        else
            moriade.anti_aim.ground_time = 0
        end
        if not ui.get(moriade.reference.other.bunny_hop) then
            on_ground = bit.band(entity.get_prop(lp, "m_fFlags"), 1) == 1
        end


        if not ui.get(moriade.reference.other.double_tap[2]) and not ui.get(moriade.reference.other.hide_shots[2]) then
            state = 'Fakelag'
        elseif moriade.anti_aim.ground_time < 8 and duck_amount > 0 then
            state = 'Air Crouch'
        elseif moriade.anti_aim.ground_time < 8 then
            state = 'Air'
        elseif duck_amount > 0 and velocity <= 2 then
            state = 'Crouch'
        elseif duck_amount > 0 and velocity >= 2 then
            state = 'Crouch Move'
        elseif ui.get(moriade.reference.other.fakeducking)then 
            state = 'Crouch'
        elseif ui.get(moriade.menu.antiaim_freestanding)then 
            state = 'Freestand'
        elseif ui.get(moriade.menu.antiaim_manual_right)then 
            state = 'Manual right'
        elseif ui.get(moriade.menu.antiaim_manual_left)then 
            state = 'Manual left'
        elseif not_moving then   
            state = 'Stand'
        elseif not not_moving then
            if slowwalk_key then
            state = 'Slow'
        else
            state = 'Run'
            end
        end
        return state

    end

    --end

    --airstop

    local function airstop(cmd)
        local lp = entity.get_local_player()
        if not lp then return end
        
        if ui.get(moriade.menu.airstop) then
            if ui.get(moriade.menu.airstopkey) then
                if cmd.quick_stop then
                    if (globals.tickcount() - ticks) > 3 then
                        cmd.in_speed = 1
                    end
                else
                    ticks = globals.tickcount()
                end
            end
        end
    
    end

    client.set_event_callback("setup_command", function(cmd)
        if ui.get(moriade.menu.airstop) then
            airstop(cmd)
        end
    end
)
    --end

    --airstop ind

    client.set_event_callback("paint", function()
        if ui.get(moriade.menu.airstop) and ui.get(moriade.menu.airstopkey) then
            renderer.indicator(215,211,213,255, "AIR-QUICK STOP")
        end
    end)
    --das
    client.set_event_callback("paint", function()
    if ui.get(moriade.menu.breaklc) and ui.get(moriade.menu.breaklckey) then
        renderer.indicator(215,211,213,255, "LC")
    end
end
)
    --dalbayeb

    local function get_table_length(data)
        if type(data) ~= 'table' then
            return 0
        end
        local count = 0
        for _ in pairs(data) do
            count = count + 1
        end
        return count
    end


    -- defensive check

    local native_GetClientEntity = vtable_bind("client.dll", "VClientEntityList003", 3, "uintptr_t(__thiscall*)(void*, int)");

    do_defensive = function ()
        local player = entity.get_local_player( )

        if player == nil then
            return
        end

        local ptr = native_GetClientEntity(player);

        local m_flSimulationTime = entity.get_prop(player, "m_flSimulationTime");
        local m_flOldSimulationTime = ffi.cast("float*", ptr + 0x26C)[0];

        if (m_flSimulationTime - m_flOldSimulationTime < 0) then
            moriade.anti_aim.defensive_ticks = globals.tickcount() + toticks(.200);
        end
    end

    client.set_event_callback( "net_update_start", function(  )
        do_defensive()
    end)

    local lerp = function(a, b, t)
        if type(a) == 'table' then
            local result = {}
            for k, v in pairs(a) do
                result[k] = a[k] + (b[k] - a[k]) * t
            end
            return result
        elseif type(a) == 'cdata' then
            return vector(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t)
        else
            return a + (b - a) * t
        end
    end

    local last_this_status = "DEF"
    local bombsite_unuse = function(e)
    	local self = entity.get_local_player()
    	if not entity.is_alive(self) then
    		return false
    	end

    	local resource = entity.get_player_resource()
    	local site = {
    		vector(entity.get_prop(resource, "m_bombsiteCenterA")),
    		vector(entity.get_prop(resource, "m_bombsiteCenterB"))
    	}

    	local has_bomb = contain_bomb(self)
    	local origin = vector(entity.get_origin(self))
    	for _, pos in pairs(site) do
    		local distance = pos:dist(origin)
    		if has_bomb and distance < 200 and e.in_use == 1 then
    			e.in_use = 0
    			return true
    		end
    	end

    	return false
    end

    client.set_event_callback( "setup_command", function( arg )
        if entity.is_alive(entity.get_local_player()) then 

        if globals.tickcount() - moriade.anti_aim.tick_var > 0 and arg.chokedcommands == 1 then
            moriade.anti_aim.is_invert = not moriade.anti_aim.is_invert
            moriade.anti_aim.tick_var = globals.tickcount()
        elseif globals.tickcount() - moriade.anti_aim.tick_var < -1 then
            moriade.anti_aim.tick_var = globals.tickcount()
        end

        if arg.chokedcommands == 1 then
            moriade.anti_aim.tick_variables = moriade.anti_aim.tick_variables + 1
        end

        if moriade.anti_aim.tick_variables > 6 then
            moriade.anti_aim.tick_variables = 0
        end

        local body_yaw = entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) * 120 - 60
        
        moriade.anti_aim.aa_inverted = body_yaw > 0
        moriade.anti_aim.aa_side = moriade.anti_aim.aa_inverted and 1 or -1
        local m_flSimulationTime = entity.get_prop(player, "m_flSimulationTime");
        moriade.anti_aim.cur_team = entity.get_prop(entity.get_local_player(), "m_iTeamNum") 
        local build_number = get_anti_aimbuilder_state()
        last_this_status = build_number
        moriade.anti_aim.state_id = ui.get(moriade.menu.antiaim_elements[moriade.menu.state_to_num[build_number] ].enable) and moriade.menu.state_to_num[build_number] or moriade.menu.state_to_num['Global'];


        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch) == "L&R" then
            moriade.anti_aim.pitch_value = moriade.anti_aim.aa_side ~= 1 and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch_slider_first) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch_slider_second)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch) == "Jitter" then
            moriade.anti_aim.pitch_value = moriade.anti_aim.is_invert and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch_slider_first) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch_slider_second)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch) == "Delayed" then
            moriade.anti_aim.pitch_value = manipulation_break(ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch_slider_first), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch_slider_second), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_pitch_slider_speed))
        end

        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_advanced) == "L&R" then
            moriade.anti_aim.yaw_value = moriade.anti_aim.aa_side ~= 1 and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_slider_left) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_slider_right)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_advanced) == "Jitter" then
            moriade.anti_aim.yaw_value = moriade.anti_aim.is_invert and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_slider_left) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_slider_right)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_advanced) == "Delayed" then
            moriade.anti_aim.yaw_value = manipulation_break(ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_slider_left), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_slider_right), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_slider_speed))
        end
        
        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_type) == "L&R" then
            moriade.anti_aim.yaw_jitter_value = moriade.anti_aim.aa_side ~= 1 and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_slider_l) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_slider_r)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_type) == "Jitter" then
            moriade.anti_aim.yaw_jitter_value = moriade.anti_aim.is_invert and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_slider_l) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_slider_r)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_type) == "Delayed" then
            moriade.anti_aim.yaw_jitter_value = manipulation_break(ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_slider_l), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_slider_r), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter_slider_speed))
        end

        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_type) == "L&R" then
            moriade.anti_aim.body_yaw_value = moriade.anti_aim.aa_side ~= 1 and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_slider_l) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_slider_r)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_type) == "Jitter" then
            moriade.anti_aim.body_yaw_value = moriade.anti_aim.is_invert and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_slider_l) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_slider_r)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_type) == "Delayed" then
            moriade.anti_aim.body_yaw_value = manipulation_break(ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_slider_l), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_slider_r), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_speed))
        end
        
        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw_correction) then
        moriade.anti_aim.body_yaw_value_real = moriade.anti_aim.is_invert and -1 or 1
        else 
        moriade.anti_aim.body_yaw_value_real = moriade.anti_aim.body_yaw_value 
        end

        moriade.anti_aim.yaw = ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw)
        moriade.anti_aim.yaw_jitter = ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_yaw_jitter)
        moriade.anti_aim.body_yaw = ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_body_yaw)

        moriade.anti_aim.defensive = moriade.anti_aim.defensive_ticks - ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_slider) > globals.tickcount()
        if moriade.anti_aim.defensive then
            moriade.anti_aim.is_active = true
        else
            moriade.anti_aim.is_active = false
        end

        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_enable) and moriade.anti_aim.defensive and ui.get(moriade.reference.other.double_tap[2])then
        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch) == "L&R" then
            moriade.anti_aim.pitch_value = moriade.anti_aim.aa_side ~= 1 and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch_slider_first) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch_slider_second)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch) == "Jitter" then
            moriade.anti_aim.pitch_value = moriade.anti_aim.is_invert and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch_slider_first) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch_slider_second)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch) == "Delayed" then
            moriade.anti_aim.pitch_value = manipulation_break(ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch_slider_first), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch_slider_second), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_pitch_slider_speed))
        end
        
        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_advanced) == "L&R" then
            moriade.anti_aim.yaw_value = moriade.anti_aim.aa_side ~= 1 and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_slider_left) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_slider_right)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_advanced) == "Jitter" then
            moriade.anti_aim.yaw_value = moriade.anti_aim.is_invert and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_slider_left) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_slider_right)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_advanced) == "Delayed" then
            moriade.anti_aim.yaw_value = manipulation_break(ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_slider_left), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_slider_right), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_slider_speed))
        end
        
        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_type) == "L&R" then
            moriade.anti_aim.yaw_jitter_value = moriade.anti_aim.aa_side ~= 1 and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_slider_l) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_slider_r)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_type) == "Jitter" then
            moriade.anti_aim.yaw_jitter_value = moriade.anti_aim.is_invert and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_slider_l) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_slider_r)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_type) == "Delayed" then
            moriade.anti_aim.yaw_jitter_value = manipulation_break(ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_slider_l), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_slider_r), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter_slider_speed))
        end
        
        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_type) == "L&R" then
            moriade.anti_aim.body_yaw_value = moriade.anti_aim.aa_side ~= 1 and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_slider_l) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_slider_r)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_type) == "Jitter" then
            moriade.anti_aim.body_yaw_value = moriade.anti_aim.is_invert and ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_slider_l) or ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_slider_r)
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_type) == "Delayed" then
            moriade.anti_aim.body_yaw_value = manipulation_break(ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_slider_l), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_slider_r), ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_speed))
        end
        
        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw_correction) then
        moriade.anti_aim.body_yaw_value_real = moriade.anti_aim.is_invert and -1 or 1
        else 
        moriade.anti_aim.body_yaw_value_real = moriade.anti_aim.body_yaw_value 
        end
        
        moriade.anti_aim.yaw = ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw)
        moriade.anti_aim.yaw_jitter = ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_yaw_jitter)
        moriade.anti_aim.body_yaw = ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive_body_yaw)
        end



        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive) == "GameSense" then
            moriade.anti_aim.defensive_ct = true
            moriade.anti_aim.is_active_inds = true
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive) == "NeverLose" then
            moriade.anti_aim.is_active_inds = true
            if globals.tickcount() % 2 == 1 then
                moriade.anti_aim.defensive_ct = true
            else
                moriade.anti_aim.defensive_ct = false
            end
        elseif ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_defensive) == "Moriade" then
            moriade.anti_aim.is_active_inds = true
            if globals.tickcount() % 3 == 1 then
                moriade.anti_aim.defensive_ct = true
            else
                moriade.anti_aim.defensive_ct = false
            end
        else
            moriade.anti_aim.defensive_ct = false
            moriade.anti_aim.is_active_inds = false
        end
            arg.force_defensive = moriade.anti_aim.defensive_ct;
        end

        
        moriade.anti_aim.pitch = "Custom"
        moriade.anti_aim.yaw_base = "At Targets"


        if ui.get(moriade.reference.other.auto_peek[2]) and ui.get(moriade.menu.antiaim_quickpeek) then
            moriade.anti_aim.yaw_value = 0
            moriade.anti_aim.yaw_base = "At Targets"
            moriade.anti_aim.yaw_jitter = "Off"
            moriade.anti_aim.yaw_jitter_value_real = 0
            moriade.anti_aim.body_yaw = ui.get(moriade.menu.antiaim_quickpeek_addons)
            moriade.anti_aim.body_yaw_value_real = 0
            moriade.anti_aim.is_active_inds = true
            quick_peek_addons = true
        else quick_peek_addons = false
        end

        ui.set(moriade.menu.antiaim_manual_left, "Toggle")
    	ui.set(moriade.menu.antiaim_manual_right, "Toggle")
        ui.set(moriade.menu.antiaim_manual_forward, "On hotkey")
        local on_ground = bit.band(entity.get_prop(entity.get_local_player(), "m_fFlags"),1) == 1 and not client.key_state(0x20)
    	local p_key = client.key_state(69)

    	
           if ui.get(moriade.menu.antiaim_manual_right) and moriade.anti_aim.last_press + 5 < globals.curtime() then
            moriade.anti_aim.aa_dir = moriade.anti_aim.aa_dir == 2
    			moriade.anti_aim.last_press = globals.curtime()
    		elseif ui.get(moriade.menu.antiaim_manual_left) and moriade.anti_aim.last_press + 5 < globals.curtime() then
    			moriade.anti_aim.aa_dir = moriade.anti_aim.aa_dir == 1
    			moriade.anti_aim.last_press = globals.curtime()
    		elseif ui.get(moriade.menu.antiaim_manual_forward) and moriade.anti_aim.last_press + 0.2 < globals.curtime() then
    			moriade.anti_aim.aa_dir = moriade.anti_aim.aa_dir == 3 and 0 or 3
    			moriade.anti_aim.last_press = globals.curtime()
    		elseif moriade.anti_aim.last_press > globals.curtime() then
    			moriade.anti_aim.last_press = globals.curtime()
            end

    	if moriade.anti_aim.aa_dir == 1 or moriade.anti_aim.aa_dir == 2 or moriade.anti_aim.aa_dir == 3 then
    		if moriade.anti_aim.aa_dir == 1 then
                moriade.anti_aim.yaw_value = -90
                moriade.anti_aim.yaw = "180"
                moriade.anti_aim.yaw_base = "Local View"
                moriade.anti_aim.yaw_jitter = "Off"
                moriade.anti_aim.yaw_jitter_value_real = 0
                moriade.anti_aim.body_yaw = "Static"
                moriade.anti_aim.body_yaw_value_real = 0
    		elseif moriade.anti_aim.aa_dir == 2 then
    			moriade.anti_aim.yaw_value = 90
                moriade.anti_aim.yaw = "180"
                moriade.anti_aim.yaw_base = "Local View"
                moriade.anti_aim.yaw_jitter = "Off"
                moriade.anti_aim.yaw_jitter_value_real = 0
                moriade.anti_aim.body_yaw = "Static"
                moriade.anti_aim.body_yaw_value_real = 0
    		elseif moriade.anti_aim.aa_dir == 3 then
    			moriade.anti_aim.yaw_value = 180
                moriade.anti_aim.yaw = "180"
                moriade.anti_aim.yaw_base = "Local View"
                moriade.anti_aim.yaw_jitter = "Off"
                moriade.anti_aim.yaw_jitter_value_real = 0
                moriade.anti_aim.body_yaw = "Static"
                moriade.anti_aim.body_yaw_value_real = 0
    		end
        end

    	local should_legit = true
    	local origin = vector(entity.get_origin(entity.get_local_player()))
    	local bombs = entity.get_all("CPlantedC4")
    	for _, ptr in pairs(bombs) do
    		local bomb_origin = vector(entity.get_origin(ptr))
    		if bomb_origin:dist(origin) < 150 then
    			should_legit = false
    			break
    		end
    	end

        local is_bomb_site = false
        if ui.get(moriade.menu.antiaim_bomb_site_unuse) then
    	is_bomb_site = bombsite_unuse(arg)
        end
        
        if ui.get(moriade.menu.antiaim_safeknife) then
            local lp = entity.get_local_player()
            local weapon = entity.get_player_weapon(lp)
            if contains(ui.get(moriade.menu.antiaim_safeknife_options), "Knife") and get_anti_aimbuilder_state() == "Air Crouch" then
            if entity.get_classname(weapon) == "CKnife" then
                moriade.anti_aim.yaw_value = 4
                moriade.anti_aim.pitch = "Custom"
                moriade.anti_aim.yaw = "180"
                moriade.anti_aim.pitch_value = 89
                moriade.anti_aim.yaw_jitter = "Offset"
                moriade.anti_aim.yaw_jitter_value_real = 3
                moriade.anti_aim.body_yaw = "Static"
                moriade.anti_aim.body_yaw_value_real = 0
            end
            end
            if contains(ui.get(moriade.menu.antiaim_safeknife_options), "Taser") and get_anti_aimbuilder_state() == "Air Crouch" then
            if entity.get_classname(weapon) == "CWeaponTaser" then
                moriade.anti_aim.yaw_value = 4
                moriade.anti_aim.pitch = "Custom"
                moriade.anti_aim.yaw = "180"
                moriade.anti_aim.pitch_value = 89
                moriade.anti_aim.yaw_jitter = "Offset"
                moriade.anti_aim.yaw_jitter_value_real = 3
                moriade.anti_aim.body_yaw = "Static"
                moriade.anti_aim.body_yaw_value_real = 0
            end
            end
        end

        if ui.get(moriade.menu.antiaim_anti_knife) then
            local players = entity.get_players(true)
            local lx, ly, lz = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
            if players == nil then return end
            for i=1, #players do
                local x, y, z = entity.get_prop(players[i], "m_vecOrigin")
                local distance = (math.sqrt((x - lx)^2 + (y - ly)^2 + (z - lz)^2))
                local weapon = entity.get_player_weapon(players[i])
                if entity.get_classname(weapon) == "CKnife" and distance <= 180 then
                    moriade.anti_aim.yaw_value = 180
                    moriade.anti_aim.pitch = "Up"
                    moriade.anti_aim.yaw_base = "At targets"
                end
            end
        end

        if ui.get(moriade.menu.fpsboost) then
            cvar.cl_disablefreezecam:set_float(1)
        cvar.cl_disablehtmlmotd:set_float(1)
        cvar.r_dynamic:set_float(0)
        cvar.r_3dsky:set_float(0)
        cvar.r_shadows:set_float(0)
        cvar.cl_csm_static_prop_shadows:set_float(0)
        cvar.cl_csm_world_shadows:set_float(0)
        cvar.cl_foot_contact_shadows:set_float(0)
        cvar.cl_csm_viewmodel_shadows:set_float(0)
        cvar.cl_csm_rope_shadows:set_float(0)
        cvar.cl_csm_sprite_shadows:set_float(0)
        cvar.cl_freezecampanel_position_dynamic:set_float(0)
        cvar.cl_freezecameffects_showholiday:set_float(0)
        cvar.cl_showhelp:set_float(0)
        cvar.cl_autohelp:set_float(0)
        cvar.mat_postprocess_enable:set_float(0)
        cvar.fog_enable_water_fog:set_float(0)
        cvar.gameinstructor_enable:set_float(0)
        cvar.cl_csm_world_shadows_in_viewmodelcascade:set_float(0)
        cvar.cl_disable_ragdolls:set_float(0)	
        end

        local last_origin = vector(0, 0, 0)
        local origin = vector(entity.get_origin(entity.get_local_player()))
        local threat = client.current_threat()
        local height_to_threat = 0

        if arg.chokedcommands == 0 then
            last_origin = origin
        end

        if threat then
            local threat_origin = vector(entity.get_origin(threat))
            height_to_threat = origin.z-threat_origin.z
        end

        local freestanding_bodyyaw = false
        if ui.get(moriade.menu.antiaim_legit_aa) and should_legit and not is_bomb_site then
            if weaponn ~= nil and entity.get_classname(weaponn) == "CC4" then
                if arg.in_attack == 1 then
                    arg.in_attack = 0 
                    arg.in_use = 1
                end
            else
                if arg.chokedcommands == 0 then
                    arg.in_use = 0
                end
            end

        elseif is_bomb_site and ui.get(moriade.menu.antiaim_legit_aa) then
    	freestanding_bodyyaw = true
    	moriade.anti_aim.yaw = "Off"
    	moriade.anti_aim.pitch = "Off"
    	moriade.anti_aim.yaw_value = 0
    	moriade.anti_aim.yaw_jitter = "Center"
    	moriade.anti_aim.body_yaw = "Static"
    	moriade.anti_aim.yaw_base = "Local view"
    	moriade.anti_aim.body_yaw_value_real = - 60
        end

       
        if ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_height_asvantage) and threat and height_to_threat > ui.get(moriade.menu.antiaim_elements[moriade.anti_aim.state_id].antiaim_height_asvantage_slider) and moriade.anti_aim.aa_dir == 0 then
            ui.set(moriade.reference.anti_aim.pitch[1], "Custom");
            ui.set(moriade.reference.anti_aim.pitch[2], 89);
            ui.set(moriade.reference.anti_aim.yaw_base, "At targets");
            ui.set(moriade.reference.anti_aim.yaw[1], "180");
            ui.set(moriade.reference.anti_aim.yaw[2], 0);
            ui.set(moriade.reference.anti_aim.yaw_jitter[1], "Off");
            ui.set(moriade.reference.anti_aim.yaw_jitter[2], 0);
            ui.set(moriade.reference.anti_aim.body_yaw[1], "Static");
            ui.set(moriade.reference.anti_aim.body_yaw[2], 0);
            ui.set(moriade.reference.anti_aim.freestanding_body_yaw, false);
            ui.set(moriade.reference.anti_aim.freestanding[2], ui.get(moriade.menu.antiaim_freestanding) and "Always On" or "On hotkey");
            ui.set(moriade.reference.anti_aim.freestanding[1], ui.get(moriade.menu.antiaim_freestanding) and true);
            ui.set(moriade.reference.anti_aim.roll_offset, 0);
        else
            ui.set(moriade.reference.anti_aim.pitch[1], moriade.anti_aim.pitch);
            ui.set(moriade.reference.anti_aim.pitch[2], moriade.anti_aim.pitch_value);
            ui.set(moriade.reference.anti_aim.yaw_base, moriade.anti_aim.yaw_base);
            ui.set(moriade.reference.anti_aim.yaw[1], moriade.anti_aim.yaw);
            ui.set(moriade.reference.anti_aim.yaw[2], moriade.anti_aim.yaw_value);
            ui.set(moriade.reference.anti_aim.yaw_jitter[1], moriade.anti_aim.yaw_jitter);
            ui.set(moriade.reference.anti_aim.yaw_jitter[2], moriade.anti_aim.yaw_jitter_value_real);
            ui.set(moriade.reference.anti_aim.body_yaw[1], moriade.anti_aim.body_yaw);
            ui.set(moriade.reference.anti_aim.body_yaw[2], moriade.anti_aim.body_yaw_value_real);
            ui.set(moriade.reference.anti_aim.freestanding_body_yaw, freestanding_bodyyaw);
            ui.set(moriade.reference.anti_aim.freestanding[2], ui.get(moriade.menu.antiaim_freestanding) and "Always On" or "On hotkey");
            ui.set(moriade.reference.anti_aim.freestanding[1], ui.get(moriade.menu.antiaim_freestanding) and true);
            ui.set(moriade.reference.anti_aim.roll_offset, 0);
        end
    end)
    client.set_event_callback("shutdown", function ()
        setup_skeet_element("vis", nil, nil, "unload")
    end)
    defensive_opa = 0
    defensive_opa2 = 0
    defensive_opa3 = 0
    defensive_indicator = function()
            if not ui.get(moriade.menu.indicators) then
                return
            end
            X,Y = screen[1], screen[2]
            value2 = 0
            draw_art = moriade.table.visuals.to_draw_ticks * 50/90 
            if is_active then
                value2 = 0.4
            else value2 = 5 
            end
            
            is_active = moriade.anti_aim.is_active_inds == true and ui.get(moriade.reference.other.double_tap[2]) and ui.get(moriade.reference.other.hide_shots[2])
            if is_active then
                defensive_opa = script.helpers:clamp(defensive_opa + globals.frametime()/0.4, 0, 1)
                defensive_opa2 = script.helpers:clamp(defensive_opa2 + globals.frametime()/0.15, 0, 1)
                defensive_opa3 =  script.helpers:clamp(defensive_opa2 + globals.frametime()/0.15, 0, 1)
            else
                defensive_opa = script.helpers:clamp(defensive_opa - globals.frametime()/0.25, 0, 1)
                defensive_opa2 = script.helpers:clamp(defensive_opa2 - globals.frametime()/0.25, 0, 1)
                defensive_opa3 = script.helpers:clamp(defensive_opa2 - globals.frametime()/0.25, 0, 1)
            end
           
            if 50 < defensive_opa * 110 then
                maxed = "yes"
            else 
                maxed = "no"
            end

            local maxed_true = maxed == "yes"
            local r, g, b = ui.get(moriade.menu.color_picker)
            local jedi_icon = '<svg t="1650815150236" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1757" width="1000" height="1000"><path d="M398.5 373.6c95.9-122.1 17.2-233.1 17.2-233.1 45.4 85.8-41.4 170.5-41.4 170.5 105-171.5-60.5-271.5-60.5-271.5 96.9 72.7-10.1 190.7-10.1 190.7 85.8 158.4-68.6 230.1-68.6 230.1s-.4-16.9-2.2-85.7c4.3 4.5 34.5 36.2 34.5 36.2l-24.2-47.4 62.6-9.1-62.6-9.1 20.2-55.5-31.4 45.9c-2.2-87.7-7.8-305.1-7.9-306.9v-2.4 1-1 2.4c0 1-5.6 219-7.9 306.9l-31.4-45.9 20.2 55.5-62.6 9.1 62.6 9.1-24.2 47.4 34.5-36.2c-1.8 68.8-2.2 85.7-2.2 85.7s-154.4-71.7-68.6-230.1c0 0-107-118.1-10.1-190.7 0 0-165.5 99.9-60.5 271.5 0 0-86.8-84.8-41.4-170.5 0 0-78.7 111 17.2 233.1 0 0-26.2-16.1-49.4-77.7 0 0 16.9 183.3 222 185.7h4.1c205-2.4 222-185.7 222-185.7-23.6 61.5-49.9 77.7-49.9 77.7z" p-id="1758" fill="#ffffff"></path></svg>'
            local jedi_icon2 = renderer.load_svg(jedi_icon,50,50)
            script.renderer:glow_module(X / 2 - 55, Y / 2 - 220, defensive_opa * 110, 0, 10, 0, {r, g, b, defensive_opa * 100}, {r, g, b, defensive_opa * 100})
            rounded_rectangle(X / 2 - 55, Y / 2 - 220, r, g, b, defensive_opa * 140, defensive_opa * 110, 2, 1)
        
            renderer.texture(defensive_image, (X / 2) - 18, Y / 2 - 268, 36, 36, 255, 255, 255, defensive_opa2 * 255, "f")
            

            charged_mes = renderer.measure_text("-", "DEFENSIVE ") + renderer.measure_text(" ", " ")
            exploit_mes = renderer.measure_text("-", "DEFENSIVE ") 
            local ret = script.helpers:animate_text(globals.curtime(), " ", r, g, b, defensive_opa2 * 255)
            renderer.text(X / 2.068, Y / 2 - 230,255, 255, 255, defensive_opa2 * 255, "-",  defensive_opa2 * charged_mes + 1, "DEFENSIVE ", unpack(ret))
            moriade.table.visuals.to_draw_ticks = moriade.table.visuals.to_draw_ticks + 1
            if moriade.table.visuals.to_draw_ticks == 200 then
                moriade.table.visuals.to_draw_ticks = 0
            end
        end

        --kill
    local kill_say_text = {
            "1";
            "equality has been killed by cvar1337";
            "vaperr";
            "𝐝𝐚𝐬𝐟𝐡𝐰𝐞";
            "ᴅᴀꜱꜰʜᴡᴇ ᴄᴏᴅᴇᴅ ʙᴇꜱᴛ ʀᴇꜱᴏʟᴠᴇʀ ꜰᴏʀ ᴍᴏʀɪᴀᴅᴇ";
            "#1",
            ">~<";
            "#1337";
            "000";
            "1337 SWAG";
            "?";
            "русский чит всегда был хуевый";
            "gamesense reworked my life";
            "NL is no longer the best cheat";
            "#1337";
            "#1797";
            "ш-общи,    че бля, я ебанат что ли по твоему?"
        }
        
        client.set_event_callback("player_death", function(e)
        
            if not ui.get(moriade.menu.killsay) then return end
        
            if client.userid_to_entindex(e.target) == entity.get_local_player() then return end
        
            if client.userid_to_entindex(e.attacker) == entity.get_local_player() then
                local random_number = math.random(1,#kill_say_text)
                client.exec("say " .. kill_say_text[random_number])
            end
           
        end)

    --#region misc

    local info_panel = function()
        screen = {client.screen_size()}
        x_offset, y_offset = screen[1], screen[2]
        x, y = x_offset/2, y_offset/2
        r,g,b = ui.get(moriade.menu.color_picker)
        if ui.get(moriade.menu.watermark) == "Bottom" then
        script.renderer:glow_module(x - 60, y_offset - 40, 120, 20, 20, 3, {r, g, b, 150}, {255, 255, 255,0})
        --roundedRectangle(x - renderer.measure_text("1", "d")/1 - 0, y_offset - 730, renderer.measure_text("cvar1337", "cvar1337".. steamname) + 3, 10, 255,255,255,50," ", 4)
        renderer.text(x, y_offset - 30, 255,255,255, 255, 'c', nil, "Moriade.lua " .. text_fade_animation(8, r,g,b, 255, "[stable]  "))
        --renderer.gradient(x, y_offset - 43, renderer.measure_text("321", "Moriade")/2 + 5, 2, r, g, b, 150, r, g, b, 10, true)
        --renderer.gradient(x, y_offset - 73, -renderer.measure_text("321", "Moriade")/2 - 5, 2, r, g, b, 150, r, g, b, 10, true)
        end
        
        if ui.get(moriade.menu.watermark) == "Side" then
        renderer.text(10, y - 15, 100,100,100, 255, '', nil, "M O R I A D E")
        renderer.text(10, y - 15, 255,255,255, 255, '', nil, text_fade_animation(8, r,g,b, 255, "M O R I A D E . L U A") .. "\aFFFFFFFF  [STABLE]")
        renderer.text(10, y - 5, 255,255,255, 255, '', nil, text_fade_animation(8, r,g,b, 255, "U S E R ") .. "\aFFFFFFFF :" .. steamname)
        end
    end

    client.set_event_callback("paint", function()
        info_panel()
        defensive_indicator()
    end)

    --#region indicators
    mleft = 0
    mright = 0
    mfor = 0
    offset_hs = 0

    local vector = require "vector"
    local indicator_data = {
    	anims = {},
    	text_anims = {},
    	last_velocity = 0,
    	last_reset_time = 0,
    	chokeds = {0, 0, 0, 0, 0}
    }

    local container = function(x, y, w, h, r, g, b, a, text)
    	renderer.rectangle(x, y, w, 1, r, g, b, a)
    	renderer.gradient(x, y, 1, h, r, g, b, a, r, g, b, 0, false)
    	renderer.gradient(x + w, y, 1, h, r, g, b, a, r, g, b, 0, false)
    	renderer.text(x + ((w / 2) * (a / 255)), y + (h / 2), 255, 255, 255, a, "c", 0, text)
    end

    local function lerp(a, b, t)
    	if type(a) == "table" then
    		return {
    			a[1] + (b[1] - a[1]) * t,
    			a[2] + (b[2] - a[2]) * t,
    			a[3] + (b[3] - a[3]) * t,
    			a[4] + (b[4] - a[4]) * t
    		}
    	end

    	return a + (b - a) * t
    end

    local anim_new = function(name, value, fraction)
    	if not indicator_data.anims[name] then
    		indicator_data.anims[name] = value
    	end

    	indicator_data.anims[name] = lerp(indicator_data.anims[name], value, globals.frametime() * (fraction / 10))
    	return indicator_data.anims[name]
    end

    local text_animation = function(name, text, fraction)
    	if not indicator_data.text_anims[name] then
    		indicator_data.text_anims[name] = {
    			text = "",
    			fraction = 0
    		}
    	end

    	if indicator_data.text_anims[name].text ~= text then
    		indicator_data.text_anims[name].text = text
    		indicator_data.text_anims[name].fraction = 0
    	end

    	indicator_data.text_anims[name].fraction = lerp(indicator_data.text_anims[name].fraction, 1, globals.frametime() * (fraction / 10))
    	return indicator_data.text_anims[name].fraction
    end

    local rgbatohex = function(r, g, b, a)
    	return ("%02x%02x%02x%02x"):format(r, g, b, a)
    end

    local rgbatohextext = function(r, g, b, a, text)
    	return ("\a%s%s"):format(rgbatohex(r, g, b, a), text)
    end

    local gradienttext = function(text, r1, g1, b1, a1, r2, g2, b2, a2)
    	local output = ""
    	local len = #text - 1
    	local rinc = (r2 - r1) / len
    	local ainc = (a2 - a1) / len
    	local ginc = (g2 - g1) / len
    	local binc = (b2 - b1) / len
    	for i = 1, len + 1 do 
    		output = output .. ("\a%s%s"):format(rgbatohex(r1, g1, b1, a1), text:sub(i, i))
    		r1 = r1 + rinc
    		a1 = a1 + ainc
    		b1 = b1 + binc
    		g1 = g1 + ginc
    	end

    	return output
    end

    local colors = {
    	{255, 255, 255, 255},
    	{0, 255, 255, 255},
    	{255, 0, 0, 255}
    }

    local velocity = function(player)
    	if not player or not entity.is_alive(player) or entity.is_dormant(player) then
    		return 0
    	end

    	return vector(entity.get_prop(player, "m_vecVelocity")):length2d()
    end

    local onshot = {ui.reference("AA", "Other", "On shot anti-aim")}
    local doubletap = {ui.reference("RAGE", "Aimbot", "Double tap")}


    local text_animation = function(name, text, fraction)
    	if not indicator_data.text_anims[name] then
    		indicator_data.text_anims[name] = {
    			text = "",
    			fraction = 0
    		}
    	end

    	if indicator_data.text_anims[name].text ~= text then
    		indicator_data.text_anims[name].text = text
    		indicator_data.text_anims[name].fraction = 0
    	end

    	indicator_data.text_anims[name].fraction = lerp(indicator_data.text_anims[name].fraction, 1, globals.frametime() * (fraction / 10))
    	return indicator_data.text_anims[name].fraction
    end

    local rgbatohex = function(r, g, b, a)
    	return ("%02x%02x%02x%02x"):format(r, g, b, a)
    end

    local rgbatohextext = function(r, g, b, a, text)
    	return ("\a%s%s"):format(rgbatohex(r, g, b, a), text)
    end

    local gradienttext = function(text, r1, g1, b1, a1, r2, g2, b2, a2)
    	local output = ""
    	local len = #text - 1
    	local rinc = (r2 - r1) / len
    	local ainc = (a2 - a1) / len
    	local ginc = (g2 - g1) / len
    	local binc = (b2 - b1) / len
    	for i = 1, len + 1 do 
    		output = output .. ("\a%s%s"):format(rgbatohex(r1, g1, b1, a1), text:sub(i, i))
    		r1 = r1 + rinc
    		a1 = a1 + ainc
    		b1 = b1 + binc
    		g1 = g1 + ginc
    	end

    	return output
    end

    local velocity = function(player)
    	if not player or not entity.is_alive(player) or entity.is_dormant(player) then
    		return 0
    	end

    	return vector(entity.get_prop(player, "m_vecVelocity")):length2d()
    end

    local onshot = {ui.reference("AA", "Other", "On shot anti-aim")}
    local doubletap = {ui.reference("RAGE", "Aimbot", "Double tap")}
    local renderable = function()
    	local local_player = entity.get_local_player()
    	if not local_player or not entity.is_alive(local_player) then
    		return
    	end

    	local colors = {
    		{ui.get(moriade.menu.indicator_main_color)},
    		{ui.get(moriade.menu.indicator_main_os_color)},
    		{ui.get(moriade.menu.indicator_main_dt_color)}
    	}

    	local curtime = globals.curtime()
    	local accent_color = {ui.get(moriade.menu.indicator_accent_color)}
    	local center = vector(client.screen_size()) / 2
    	local os = ui.get(onshot[1]) and ui.get(onshot[2])
    	local dt = ui.get(doubletap[1]) and ui.get(doubletap[2])
    	local wpn = entity.get_player_weapon(local_player)
    	local scope = entity.get_prop(local_player, "m_bIsScoped") == 1 or (wpn and contains({
    		"CSnowball",
    		"CFlashbang",
    		"CHEGrenade",
    		"CDecoyGrenade",
    		"CSensorGrenade",
    		"CSmokeGrenade",
    		"CMolotovGrenade",
    		"CIncendiaryGrenade"
    	},  entity.get_classname(wpn)))
    	if math.abs(curtime - indicator_data.last_reset_time) > 0.25 then
    		indicator_data.last_velocity = velocity(local_player)
    		indicator_data.last_reset_time = curtime
    	end

    	local currentchoke = globals.chokedcommands()
    	local rect_fraction = (dt or os) and math.min(0.5 + (indicator_data.last_velocity / 330), 1) or math.min(currentchoke / 14, 1)
    	local accent_main_color = colors[dt and 3 or os and 2 or 1]
    	local main_color = anim_new("Main Colors", accent_main_color, 70)
    	local rect_size = vector(60, 15)
    	local exploit_anim = anim_new("Exploits", (dt or os) and 1 or 0, 70)
    	local current_state = dt and "DT" or os and "OS" or "Def"
    	local text_modified = text_animation("Global Clr", current_state, 70)
    	local scope_anim = anim_new("Scope Animation", scope and 1 or 0, 70)
    	local extra_offset = scope_anim * 50
    	if indicator_data.chokeds[5] > currentchoke then
    		indicator_data.chokeds[1] = indicator_data.chokeds[2]
    		indicator_data.chokeds[2] = indicator_data.chokeds[3]
    		indicator_data.chokeds[3] = indicator_data.chokeds[4]
    		indicator_data.chokeds[4] = indicator_data.chokeds[5]
    	end

    	local current_status_text = last_this_status:upper()
    	local status_text_modified = text_animation("Global Status", current_status_text, 50)
    	indicator_data.chokeds[5] = currentchoke
    	local scopesize = vector(40, 6)
    	renderer.text(center.x + extra_offset, center.y + 25, main_color[1], main_color[2], main_color[3], main_color[4], "cb", 0, "moriade")
    	renderer.rectangle(center.x - (scopesize.x / 2) + extra_offset, center.y + 35 - (scopesize.y / 2), scopesize.x, scopesize.y, 0, 0, 0, 255 * scope_anim)
    	renderer.gradient(center.x - (scopesize.x / 2) + 1 + extra_offset, center.y + 35 - (scopesize.y / 2) + 1, (scopesize.x - 2) * rect_fraction, scopesize.y - 2, main_color[1], main_color[2], main_color[3], main_color[4] * scope_anim, accent_color[1], accent_color[2], accent_color[3], accent_color[4] * scope_anim, 0, false)
    	local rect_text = (dt or os) and gradienttext(("%iKM/R"):format(velocity(local_player)), accent_color[1], accent_color[2], accent_color[3], accent_color[4] * scope_anim, main_color[1], main_color[2], main_color[3], main_color[4] * scope_anim) or rgbatohextext(main_color[1], main_color[2], main_color[3], main_color[4] * scope_anim, ("%i-%i-%i-%i"):format(indicator_data.chokeds[4], indicator_data.chokeds[3], indicator_data.chokeds[2], indicator_data.chokeds[1]))
    	renderer.text(center.x + scopesize.x - 16 + extra_offset, center.y + 29, main_color[1], main_color[2], main_color[3], main_color[4] * scope_anim, "-", 0, rect_text)
    	renderer.text(center.x + extra_offset, center.y + 35, main_color[1], main_color[2], main_color[3], main_color[4] * (1 - scope_anim) * status_text_modified, "c-", 0, current_status_text)
    	if exploit_anim > 0.001 then
    		container(center.x - (rect_size.x / 2) + extra_offset, center.y + 42, rect_size.x, rect_size.y, main_color[1], main_color[2], main_color[3], main_color[4] * exploit_anim, rgbatohextext(main_color[1], main_color[2], main_color[3], main_color[4] * text_modified * exploit_anim, dt and "double tap" or "os-aa"))
    	end
    end

    local offset_center = 0
    animated = function()
        r, g, b = ui.get(moriade.menu.color_picker)
        screen = {client.screen_size()}
        center = {screen[1] / 2, screen[2] / 2}
        if moriade.anti_aim.aa_dir == 1 then
            mleft = script.helpers:clamp(mleft + globals.frametime() / 0.15, 0, 1)
            mright = script.helpers:clamp(mright - globals.frametime() / 0.15, 0, 1)
            mfor = script.helpers:clamp(mfor - globals.frametime() / 0.15, 0, 1)
        elseif moriade.anti_aim.aa_dir == 2 then
            mleft = script.helpers:clamp(mleft - globals.frametime() / 0.15, 0, 1)
            mright = script.helpers:clamp(mright + globals.frametime() / 0.15, 0, 1)
            mfor = script.helpers:clamp(mfor - globals.frametime() / 0.15, 0, 1)
        else
            mleft = script.helpers:clamp(mleft - globals.frametime() / 0.15, 0, 1)
            mright = script.helpers:clamp(mright - globals.frametime() / 0.15, 0, 1)
            mfor = script.helpers:clamp(mfor - globals.frametime() / 0.15, 0, 1)
        end

        --manual inds remove it if you need
        renderer.text(center[1] - 60, center[2], r, g, b, mleft * 255, "+", nil, "‹")
        renderer.text(center[1] + 60, center[2], r, g, b, mright * 255, "+", nil, "›")

        if ui.get(moriade.menu.indicators5) == "Modern" then
            local scoped = entity.get_prop(entity.get_local_player(), "m_bIsScoped") == 1
            dted = ui.get(moriade.reference.other.double_tap[2]) == true
            hsed = ui.get(moriade.reference.other.hide_shots[2]) == true
            qped = ui.get(moriade.reference.other.auto_peek[2]) == true  
            dtopa = moriade.table.visuals.animation_variables.movement(dtopa,dted,0,255,12)
            
            
            if dted and hsed then 
            location = 73
            elseif dted or hsed then
            location = 62
            else
            location = 51
            end
            
            if dted then
            location2 = 62
            else 
            location2 = 51
            end
            
            if dted then
            dtopa2 = script.helpers:clamp(dtopa2 + globals.frametime()/0.2, 0, 1)
            else
            dtopa2 = script.helpers:clamp(dtopa2 - globals.frametime()/0.2, 0, 1)
            end
            
            if hsed then
            dtopa4 = script.helpers:clamp(dtopa4 + globals.frametime()/0.2, 0, 1)
            else
            dtopa4 = script.helpers:clamp(dtopa4 - globals.frametime()/0.2, 0, 1)
            end
                
            
            if qped then
            dtopa3 = script.helpers:clamp(dtopa3 + globals.frametime()/0.2, 0, 1)
            else
            dtopa3 = script.helpers:clamp(dtopa3 - globals.frametime()/0.2, 0, 1)
            end
            qpopa = moriade.table.visuals.animation_variables.movement(qpopa,qped,0,255,12)
            rapid_mes = renderer.measure_text("", "dt")/2 + 6
            rapid_mes2 = renderer.measure_text("-", "  DT CHARGING")/2 - 1
            rapid_mes3 = renderer.measure_text("-", "  DT DEFENSIVE")/2 - 1
            local_player = entity.get_local_player()
            if not entity.is_alive(local_player) then return end
            blink = math.sin(math.abs(-math.pi + (globals.realtime() * (1 / 0.5)) % (math.pi * 1))) * 255
            blink2 = math.sin(math.abs(-math.pi + (globals.realtime() * (1 / 0.5)) % (math.pi * 1))) * 120
            cen_meas = renderer.measure_text("c", "moriade")/2  + 5
            cen_meas3 = renderer.measure_text("c", "moriade")/2  
            cen_meas2 = renderer.measure_text("c", "moriade")
            build_meas = renderer.measure_text("", "sync")
            state_mes = renderer.measure_text("", "sync")/2 + 6
            qp_mes = renderer.measure_text("", "qp")/2 + 5.5
            qp_mes2 = renderer.measure_text("-", "IDEALTICK CHARGING")/2 + 2
            qp_mes3 = renderer.measure_text("-", "IDEALTICK DEFENSIVE")/2 + 1
            hs_mes = renderer.measure_text("", "os")/2 + 5.5
            offset_qp = moriade.table.visuals.animation_variables.movement(offset_qp,qped,51,location,15)
            offset_hs = moriade.table.visuals.animation_variables.movement(offset_hs,hsed,51,location2,15)
            offset_center = moriade.table.visuals.animation_variables.movement(offset_center,scoped,1,cen_meas,10)
            offset_state = moriade.table.visuals.animation_variables.movement(offset_state,scoped,0,state_mes,8)
            offset_quickpeek = moriade.table.visuals.animation_variables.movement(offset_quickpeek,scoped,0,qp_mes,8)
            offset_quickpeek2 = moriade.table.visuals.animation_variables.movement(offset_quickpeek2,scoped,0,qp_mes2,8)
            offset_quickpeek3 = moriade.table.visuals.animation_variables.movement(offset_quickpeek3,scoped,0,qp_mes3,8)
            offset_rapid = moriade.table.visuals.animation_variables.movement(offset_rapid,scoped,0,rapid_mes,8)
            offset_rapid2 = moriade.table.visuals.animation_variables.movement(offset_rapid2,scoped,0,hs_mes,8)
            offset_rapid3 = moriade.table.visuals.animation_variables.movement(offset_rapid3,scoped,0,rapid_mes3,8)
            dtcolor = 0
            dt_mes = renderer.measure_text("", "dt ")
            hs_mes = renderer.measure_text("", "os ")
            p_mes = renderer.measure_text("", "qp ")
            h_mes = renderer.measure_text("-", "HIDESHOT ")
            if antiaim_funcs.get_double_tap() == false then
            dtcolor = 190
            else dtcolor = 255
            end
            charging_size = renderer.measure_text("-", "READY ")
            charging_size2 = renderer.measure_text("-", "CHARGING ")
            charging_size3 = renderer.measure_text("-", "DEFENSIVE ")
            charging_size4 = renderer.measure_text("-", "READY ")
            charging_size5 = renderer.measure_text("-", "CHARGING ")
            local ret2 = script.helpers:animate_text(globals.curtime(), "CHARGING", 255, 30, 30, 255)
            local ret5 = script.helpers:animate_text(globals.curtime(), "CHARGING", 255, 30, 30, 255)
            renderer.text(center[1] + offset_center, center[2] + 29- 10, 255, 255, 255, 255, "c", nil, "moriade")
            renderer.text(center[1] + offset_state, center[2] + 40 - 10, r, g, b, blink, "c" , nil, "sync")
            renderer.text(center[1] + offset_rapid , center[2] + 51 - 10, 255, 255, 255, dtopa2 * 255, "c" , dtopa2 * dt_mes + 1, "dt")
            renderer.text(center[1] + offset_rapid2 , center[2] + offset_hs - 10, 155, 255, 155, dtopa4 * 255, "c" , dtopa4 * hs_mes + 1, "os")
            renderer.text(center[1] + offset_quickpeek, center[2] + offset_qp - 10, 255, 255, 255, dtopa3 * 255, "c" , dtopa3 * p_mes + 1, "qp")
        elseif ui.get(moriade.menu.indicators5) == "v2" then
    	renderable()
        end
    end


    local function on_setup_command(cmd)
    local lp = entity.get_local_player()
    if not lp or not entity.is_alive(lp) then
    return
    end
    local vec_velocity = { entity.get_prop(lp, 'm_vecVelocity') }
    local flags = entity.get_prop(lp, 'm_fFlags')
                  
    if not vec_velocity[1] or not flags then
    return
    end
                  
    local duck_amount = entity.get_prop(lp, 'm_flDuckAmount')
    local velocity = math.floor(math.sqrt(vec_velocity[1] ^ 2 + vec_velocity[2] ^ 2) + 0.5)
    local air = bit.band(flags, 1) == 0         
    if air == false then
    ground_time = ground_time + 1
    else
    ground_time = 0
    end
                
    if ground_time < 8 and duck_amount > 0 then
    state3 = '- air crouch -'
    elseif ground_time < 8 then
    state3 = '- in air -'
    elseif duck_amount > 0 and velocity <= 2 then
    state3 = '- crouch -'
    elseif duck_amount > 0 and velocity >= 2 then
    state3 = '- move crouch -'
    elseif velocity < 3.1 then
    state3 = '- stand -'
    elseif velocity < 100 and ui.get(moriade.reference.other.slow_motion[2]) then
    state3 = '- walking -'
    else
    state3 = '- run -'
    end
    end      
    client.set_event_callback('setup_command', on_setup_command) 
    client.set_event_callback("paint", animated)

    --#logs

    local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}

    client.set_event_callback("aim_hit", function(e)
        if not ui.get(moriade.menu.log_render) then return end

        local who = entity.get_player_name(e.target)
        local group = hitgroup_names[e.hitgroup + 1] or "?"
        local dmg = e.damage
        local health = entity.get_prop(e.target, "m_iHealth")
        local bt = globals.tickcount() - e.tick
        local hc = math.floor(e.hit_chance)
        local log = ""

        if health ~= 0 then
            log = string.lower(string.format("hurt %s in the %s for %d damage (%d hp remaining) [bt: %d, hc: %d.].",
            who, group, dmg, health, bt, hc))

        else 
            log = string.lower(string.format("killed %s in the %s [bt: %d, hc: %d.].",
            who, group, bt, hc))
        end

        print("Moriade » "..log)
    end)

    client.set_event_callback("aim_miss", function(e)
        if not ui.get(moriade.menu.log_render) then return end

        local who = entity.get_player_name(e.target)
        local group = hitgroup_names[e.hitgroup + 1] or "?"
        local reason = e.reason
        local bt = globals.tickcount() - e.tick
        local hc = math.floor(e.hit_chance)
        local log = string.lower(string.format(
            "missed in %s %s due to %s [bt:%s hc:%s.]",
            who, group, reason, bt, hc
        ))
        
        print("Moriade » "..log)
    end)

    -- console filter
    ui.set_callback(moriade.menu.consolefilter, function()
        cvar.con_filter_text:set_string("cool text")
        cvar.con_filter_enable:set_int(1)
    end)

    --#regionend

    --PIZDEC
    client.set_event_callback("setup_command", function(cmd)
        if ui.get(moriade.menu.breaklc) and ui.get(moriade.menu.breaklckey) then
            if is_vulnerable() and cmd.in_jump == 1 then
                cmd.force_defensive = true
                cmd.discharge_pending = true
            end
        end
    end)

    --#region clan tag

    local skeetclantag = ui.reference('MISC', 'MISCELLANEOUS', 'Clan tag spammer')

    local duration = 25
    local clantags = {

    ' ',
    'm',
    'mo',
    'mor',
    'mori',
    'mor1a',
    'moriad',
    'moriad3',
    'moriade.',
    'moriade.l',
    'moriade.lu',
    'moriade.lua',
    '-oriade.lua',
    'm-riade.lua',
    'mo-iade.lua',
    'mor-ade.lua',
    'mori-de.lua',
    'moria-e.lua',
    'moriad-.lua',
    'moriade-lua',
    'moriade.-ua',
    'moriade.l-a',
    'moriade.lu-',
    'moriade.l',
    'moriade.',
    'moriade',
    'moriad',
    'moria',
    'mori',
    'mor',
    'mo',
    'm',
    ' ',
    }

    local empty = {''}
    local clantag_prev
    client.set_event_callback('net_update_end', function()
        if ui.get(skeetclantag) then 
            return 
        end

        local cur = math.floor(globals.tickcount() / duration) % #clantags
        local clantag = clantags[cur+1]

        if ui.get(moriade.menu.clantag) then
            if clantag ~= clantag_prev then
                clantag_prev = clantag
                client.set_clan_tag(clantag)
            end
        end
    end)
    ui.set_callback(moriade.menu.clantag, function() client.set_clan_tag('\0') end)

    --resolver

    local ffi = require("ffi")
    local vector = require("vector")
    function Clamp(value, min, max) return math.min(math.max(value, min), max) end
    local function AngleModifier(a) return (360 / 65536) * bit.band(math.floor(a * (65536 / 360)), 65535) end
    local function Approach(target, value, speed)
    	target = AngleModifier(target)
    	value = AngleModifier(value)
    	local delta = target - value
    	if speed < 0 then speed = -speed end
    	if delta < -180 then delta = delta + 360
    	elseif delta > 180 then delta = delta - 360 end
    	if delta > speed then value = value + speed
    	elseif delta < -speed then value = value - speed
        else value = target
    	end
    	return value
    end
    local function NormalizeAngle(angle)
        if angle == nil then return 0 end
    	while angle > 180 do angle = angle - 360 end
    	while angle < -180 do angle = angle + 360 end
    	return angle
    end
    local function AngleDifference(dest_angle, src_angle)
    	local delta = math.fmod(dest_angle - src_angle, 360)
    	if dest_angle > src_angle then
    		if delta >= 180 then delta = delta - 360 end
    	else
    		if delta <= -180 then delta = delta + 360 end
    	end
    	return delta
    end
    local function AngleVector(pitch, yaw)
        if pitch ~= nil and yaw ~= nil then 
            local p, y = math.rad(pitch), math.rad(yaw)
            local sp, cp, sy, cy = math.sin(p), math.cos(p), math.sin(y), math.cos(y)
            return cp*cy, cp*sy, -sp
        end
        return 0,0,0
    end
    local function CalcAngle(localplayerxpos, localplayerypos, enemyxpos, enemyypos)
        local relativeyaw = math.atan( (localplayerypos - enemyypos) / (localplayerxpos - enemyxpos) )
        return relativeyaw * 180 / math.pi
    end
    local function AngleFromVectors(a, b)
        local angles = {}
        local delta = a - b
        local hyp = delta:length2d()
        angles.y = math.atan(delta.y / delta.x) * 57.2957795131
        angles.x = math.atan(delta.z / hyp) * 57.2957795131
        angles.z = 0.0
        if delta.x >= 0.0 then angles.y = angles.y + 180.0 end
        return angles
    end
    local function DegToRad(Deg) return Deg * (math.pi / 180) end
    local function RadToDeg(Rad) return Rad * (180 / math.pi) end
    local Lerp = function(a, b, t) return a + (b - a) * t end

    local VTable = {
        Entry = function(instance, index, type) return ffi.cast(type, (ffi.cast("void***", instance)[0])[index]) end,
        Bind = function(self, module, interface, index, typestring)
            local instance = client.create_interface(module, interface)
            local fnptr = self.Entry(instance, index, ffi.typeof(typestring))
            return function(...) return fnptr(instance, ...) end
        end
    }

    local animstate_t = ffi.typeof 'struct { char pad0[0x18]; float anim_update_timer; char pad1[0xC]; float started_moving_time; float last_move_time; char pad2[0x10]; float last_lby_time; char pad3[0x8]; float run_amount; char pad4[0x10]; void* entity; void* active_weapon; void* last_active_weapon; float last_client_side_animation_update_time; int	 last_client_side_animation_update_framecount; float eye_timer; float eye_angles_y; float eye_angles_x; float goal_feet_yaw; float current_feet_yaw; float torso_yaw; float last_move_yaw; float lean_amount; char pad5[0x4]; float feet_cycle; float feet_yaw_rate; char pad6[0x4]; float duck_amount; float landing_duck_amount; char pad7[0x4]; float current_origin[3]; float last_origin[3]; float velocity_x; float velocity_y; char pad8[0x4]; float unknown_float1; char pad9[0x8]; float unknown_float2; float unknown_float3; float unknown; float m_velocity; float jump_fall_velocity; float clamped_velocity; float feet_speed_forwards_or_sideways; float feet_speed_unknown_forwards_or_sideways; float last_time_started_moving; float last_time_stopped_moving; bool on_ground; bool hit_in_ground_animation; char pad10[0x4]; float time_since_in_air; float last_origin_z; float head_from_ground_distance_standing; float stop_to_full_running_fraction; char pad11[0x4]; float magic_fraction; char pad12[0x3C]; float world_force; char pad13[0x1CA]; float min_yaw; float max_yaw; } **'
    local animlayer_t = ffi.typeof 'struct { char pad_0x0000[0x18]; uint32_t sequence; float prev_cycle; float weight; float weight_delta_rate; float playback_rate; float cycle; void *entity;char pad_0x0038[0x4]; } **'
    local NativeGetClientEntity = VTable:Bind("client.dll", "VClientEntityList003", 3, "void*(__thiscall*)(void*, int)")

    local NullPtr, CharPtr, ClassPtr = ffi.new "void*", ffi.typeof "char*", ffi.typeof "void***"

    moriade.menu.EnableResolver = ui.new_checkbox("AA", "Anti-aimbot angles", "• \aFFFFFFFFCustom resolver")

    local GetAnimState = function(ent)
        if not ent then return false end
        local Address = type(ent) == "cdata" and ent or NativeGetClientEntity(ent)
        if not Address or Address == ffi.NULL then return false end
        local AddressVtable = ffi.cast("void***", Address)
        return ffi.cast(animstate_t, ffi.cast("char*", AddressVtable) + 0x9960)[0]
    end

    local GetSimulationTime = function(ent)
        local pointer = NativeGetClientEntity(ent)
        if pointer then return entity.get_prop(ent, "m_flSimulationTime"), ffi.cast("float*", ffi.cast("uintptr_t", pointer) + 0x26C)[0] else return 0 end
    end

    local GetAnimlayers = function (ent, layer)
        local pointer = NativeGetClientEntity(ent)
        if pointer then return ffi.cast(animlayer_t, ffi.cast('char*', ffi.cast("void***", pointer)) + 0x3914)[0][layer or 0] end
    end

    local IsPlayerValid = function(player)
        if not player then return false end
        if not entity.is_alive(player) then return false end
        return true
    end

    local GetMaxDesync = function(player)
        local Animstate = GetAnimState(player)
        if not Animstate then return 0 end
        local speedfactor = Clamp(Animstate.feet_speed_forwards_or_sideways, 0, 1)
        local avg_speedfactor = (Animstate.stop_to_full_running_fraction * -0.3 - 0.2) * speedfactor + 1
        local duck_amount = Animstate.duck_amount
        if duck_amount > 0 then avg_speedfactor = avg_speedfactor + ((duck_amount * speedfactor) * (0.5 - avg_speedfactor)) end
        return Clamp(avg_speedfactor, .5, 1)
    end

    local IsPlayerAnimating = function(player)
        local CurrentSimulationTime, RecordSimulationTime = GetSimulationTime(player)
        CurrentSimulationTime, RecordSimulationTime = toticks(CurrentSimulationTime), toticks(RecordSimulationTime)
        return toticks(CurrentSimulationTime) ~= nil and toticks(RecordSimulationTime) ~= nil
    end

    local GetChokedPackets = function(player)
        if not IsPlayerAnimating(player) then return 0 end
        local CurrentSimulationTime, PreviousSimulationTime = GetSimulationTime(player)
        local SimulationTimeDifference = globals.curtime() - CurrentSimulationTime
        local ChokedCommands = Clamp(toticks(math.max(0.0, SimulationTimeDifference - client.latency())), 0, cvar.sv_maxusrcmdprocessticks:get_string() - 2)
        return ChokedCommands
    end

    function RebuildServerYaw(player)
        local Animstate = GetAnimState(player)
        if not Animstate then return 0 end
        
        local m_flGoalFeetYaw = Animstate.goal_feet_yaw
        local eye_feet_delta = AngleDifference(Animstate.eye_angles_y, Animstate.goal_feet_yaw)
        local flRunningSpeed = Clamp(Animstate.feet_speed_forwards_or_sideways, 0.0, 1.0)
        
        local flYawModifier = (((Animstate.stop_to_full_running_fraction * -0.3) - 0.2) * flRunningSpeed) + 1.0
        if Animstate.duck_amount > 0.0 then
            local flDuckingSpeed = Clamp(Animstate.feet_speed_forwards_or_sideways, 0.0, 1.0)
            flYawModifier = flYawModifier + ((Animstate.duck_amount * flDuckingSpeed) * (0.6 - flYawModifier))
        end
       
        local flMaxYawModifier = flYawModifier * Animstate.max_yaw
        local flMinYawModifier = flYawModifier * Animstate.min_yaw
       
        if eye_feet_delta <= flMaxYawModifier then
            if flMinYawModifier > eye_feet_delta then
                m_flGoalFeetYaw = math.abs(flMinYawModifier) + Animstate.eye_angles_y
            end
        else
            m_flGoalFeetYaw = Animstate.eye_angles_y - math.abs(flMaxYawModifier)
        end

    	return NormalizeAngle(m_flGoalFeetYaw)
    end

    local Cache = {}

    local JitterBuffer = 6
    local Resolver = { 
        Jitter = { Jittering = false, JitterTicks = 0, StaticTicks = 0, YawCache = {}, JitterCache = 0, Difference = 0 },
        Main = { Mode = 0, Side = 0, Angles = 0 }
    }

    local Cache = {}

    local CDetectJitter = function(player)
        local Data = Resolver.Jitter
        local EyeAnglesX, EyeAnglesY, EyeAnglesZ = entity.get_prop(player, "m_angEyeAngles")
        Data.YawCache[Data.JitterCache % JitterBuffer] = EyeAnglesY
        if Data.JitterCache >= JitterBuffer + 1 then
            Data.JitterCache = 0
        else
            Data.JitterCache = Data.JitterCache + 1
        end
        for i = 0, JitterBuffer, 1 do
            if i < JitterBuffer then
                local Difference = (Data.YawCache[i - Data.JitterCache % JitterBuffer] ~= nil and Data.YawCache[Data.JitterCache % JitterBuffer] ~= nil) and math.abs(Data.YawCache[i - Data.JitterCache % JitterBuffer] - Data.YawCache[Data.JitterCache % JitterBuffer]) or 0
                if Difference ~= nil and Difference ~= 0.0 then
                    NormalizeAngle(Difference)
                    Data.Jittering = Difference >= (45.0 * GetMaxDesync(player)) and true or false
                    Data.Difference = Difference
                end
            end
        end
    end

    local CProcessImpact = function(player) return Resolver.Jitter.Jittering and 1 or 0 end

    local CGetPointDirection = function(player)
        local fw = vector()
        local LocalOriginX, LocalOriginY, LocalOriginZ = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
        local LocalOrigin = vector(LocalOriginX, LocalOriginY)
        local PlayerOriginX, PlayerOriginY, PlayerOriginZ = entity.get_prop(player, "m_vecOrigin")
        local PlayerOrigin = vector(PlayerOriginX, PlayerOriginY)
        local AtTarget = AngleFromVectors(LocalOrigin, PlayerOrigin).y
        AngleVector(AtTargetX, AtTargetY)
        return fw
    end

    local CDetectDesyncSide = function(player)
        local Animstate = GetAnimState(player)
        if not Animstate then return 0 end
        local EyeAnglesX, EyeAnglesY, EyeAnglesZ = entity.get_prop(player, "m_angEyeAngles")
        local InverseSide = function(player)
            local VecOriginX, VecOriginY, VecOriginZ = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
            local AbsOriginX, AbsOriginY, AbsOriginZ = entity.get_prop(entity.get_local_player(), "m_vecAbsOrigin")
            local EyeAnglesX, EyeAnglesY, EyeAnglesZ = entity.get_prop(player, "m_angEyeAngles")
            
            local VecOrigin = vector(VecOriginX, VecOriginY, VecOriginZ)
            local AbsOrigin = vector(AbsOriginX, AbsOriginY, AbsOriginZ)
            local EyeAngles = vector(EyeAnglesX, EyeAnglesY, EyeAnglesZ)
            
            local AtTarget = NormalizeAngle(AngleFromVectors(VecOrigin, AbsOrigin).y)
            local Angle = NormalizeAngle(EyeAngles.y)
            local SidewaysLeft = math.abs(NormalizeAngle(Angle - NormalizeAngle(AtTarget - 90.0))) < 45.0
            local SidewaysRight = math.abs(NormalizeAngle(Angle - NormalizeAngle(AtTarget + 90.0))) < 45.0
            local Forward = math.abs(NormalizeAngle(Angle - NormalizeAngle(AtTarget + 180.0))) < 45.0
            return Forward and not (SidewaysLeft or SidewaysRight)
        end

        if Resolver.Jitter.Jittering and GetChokedPackets(player) < 3 then
            Cache.FirstNormalizedAngle = NormalizeAngle(Resolver.Jitter.YawCache[JitterBuffer - 1])
            Cache.SecondNormalizedAngle = NormalizeAngle(Resolver.Jitter.YawCache[JitterBuffer - 2])

            Cache.FirstSinAngle = math.sin(DegToRad(Cache.FirstNormalizedAngle))
            Cache.SecondSinAngle = math.sin(DegToRad(Cache.SecondNormalizedAngle))

            Cache.FirstCosAngle = math.cos(DegToRad(Cache.FirstNormalizedAngle))
            Cache.SecondCosAngle = math.cos(DegToRad(Cache.SecondNormalizedAngle))

            Cache.AVGYaw = NormalizeAngle(RadToDeg(math.atan2((Cache.FirstSinAngle + Cache.SecondSinAngle) / 2.0, (Cache.FirstCosAngle + Cache.SecondCosAngle) / 2.0)))
            Cache.Difference = NormalizeAngle(Animstate.eye_angles_y - Cache.AVGYaw)
            if Cache.Difference ~= 0.0 then Resolver.Main.Side = Cache.Difference > 0.0 and 1 or -1 else Resolver.Main.Side = 0 end
        end

        return Resolver.Main.Side
    end

    local CResolverInstance = function(player)
        local Animstate = GetAnimState(player)
        if not Animstate then return end

        CProcessImpact(player)
        CDetectJitter(player)
        CDetectDesyncSide(player)

        local ChokedPackets = GetChokedPackets(player)
        local SimulationTime, PreviousSimulationTime = GetSimulationTime(player)
        for i = 0, ChokedPackets, 1 do
            local NotSentTick = i == ChokedPackets - 1
            local BackupSimulationTime = SimulationTime
            if IsPlayerAnimating(player) then BackupSimulationTime = SimulationTime - totime(ChokedPackets - i - 1) end
            if Resolver.Jitter.Jittering and not NotSentTick then
                Resolver.Main.Angles = Cache.Difference ~= nil and (Cache.Difference * GetMaxDesync(player)) * Resolver.Main.Side or (45.0 * GetMaxDesync(player)) * Resolver.Main.Side
                Resolver.Main.Mode = 1
            else
                Resolver.Main.Angles = 0
                Resolver.Main.Mode = 0
            end
        end
    end

    client.set_event_callback("net_update_end", function()
        if not entity.get_local_player() then return end
        if not entity.is_alive(entity.get_local_player()) then Resolver.Main.Mode = 0 return end
        local Players = entity.get_players() client.update_player_list()
        for i = 1, #Players do
            local idx = Players[i]
            if entity.is_enemy(idx) and IsPlayerAnimating(idx) and ui.get(moriade.menu.EnableResolver) then
                CResolverInstance(idx)
                plist.set(idx, "Force body yaw value", Resolver.Main.Mode ~= 0 and Resolver.Main.Angles or 0)
                plist.set(idx, "Force body yaw", Resolver.Main.Mode ~= 0)
            else
                plist.set(idx, "Force body yaw", false)
            end
        end
    end)

    client.register_esp_flag("RESOLVED", 200, 200, 200, function(e) return (entity.is_enemy(e) and ui.get(moriade.menu.EnableResolver) and Resolver.Main.Mode == 1) and true or false end)

    --#hueta
    clamper = function(yyyy)
        if yyyy > 180 then
            return -180 + yyyy - 180
        elseif yyyy < -180 then
            return 180 - (-180 - yyyy)
        end
    end;
    --re
    if ui.get(moriade.menu.antiaim_freestanding) then
        if ui.get(moriade.menu.antiaim_flickfs) then
            cmd.force_defensive = 1
        end;
        if ui.get(moriade.menu.antiaim_flickfs) then
            moriade.reference.anti_aim.yaw = abstoflick + 180 + math.random(-10, 10)
            cmd.pitch = 1080 + math.random(-25, 10)
            cmd.force_defensive = 1;
            ui.set(moriade.reference.anti_aim.pitch[1], "Custom")
            ui.set(moriade.reference.anti_aim.pitch[2], 0)
            ui.set(moriade.reference.anti_aim.yaw_base, "Local view")
            ui.set(moriade.reference.anti_aim.yaw[1], "180")
            ui.set(moriade.reference.anti_aim.yaw[2], clamper(abstoflick))
            ui.set(moriade.reference.anti_aim.jitter[1], "Offset")
            ui.set(moriade.reference.anti_aim.jitter[2], 0)
            ui.set(moriade.reference.anti_aim.body_yaw[1], "Static")
            ui.set(moriade.reference.anti_aim.body_yaw[2], 0)
            ui.set(moriade.reference.anti_aim.fs_body_yaw, false)
        else
            abstoflick = antiaim_funcs.get_abs_yaw()
            ui.set(moriade.reference.anti_aim.antiaim.pitch[1], "Minimal")
            ui.set(moriade.reference.anti_aim.antiaim.yaw_base, "At targets")
            ui.set(moriade.reference.anti_aim.antiaim.yaw[1], "180")
            ui.set(moriade.reference.anti_aim.antiaim.yaw[2], 0)
            ui.set(moriade.reference.anti_aim.antiaim.jitter[1], "Offset")
            ui.set(moriade.reference.anti_aim.antiaim.jitter[2], 0)
            ui.set(moriade.reference.anti_aim.antiaim.body_yaw[1], "Static")
            ui.set(moriade.reference.anti_aim.antiaim.body_yaw[2], 0)
            ui.set(moriade.reference.anti_aim.antiaim.fs_body_yaw, true)
        end
    end;

    --- #region: prepare helpers
    local function table_contains(source, target)
        local source_element = ui.get(source)
        for _, name in pairs(source_element) do
            if name == target then
                return true
            end
        end
        return false
    end

    local c_entity = require("gamesense/entity")
    local E_POSE_PARAMETERS = {
        STRAFE_YAW = 0,
        STAND = 1,
        LEAN_YAW = 2,
        SPEED = 3,
        LADDER_YAW = 4,
        LADDER_SPEED = 5,
        JUMP_FALL = 6,
        MOVE_YAW = 7,
        MOVE_BLEND_CROUCH = 8,
        MOVE_BLEND_WALK = 9,
        MOVE_BLEND_RUN = 10,
        BODY_YAW = 11,
        BODY_PITCH = 12,
        AIM_BLEND_STAND_IDLE = 13,
        AIM_BLEND_STAND_WALK = 14,
        AIM_BLEND_STAND_RUN = 15,
        AIM_BLEND_CROUCH_IDLE = 16,
        AIM_BLEND_CROUCH_WALK = 17,
        DEATH_YAW = 18
    }
    --- #endregion

    --- #region: prepare menu elements
    
    --- #endregion

    --- #region: process main work
    local function jitter_value()
        local current_time = globals.tickcount() / 10
        local jitter_frequency = 7
        local jitter_factor = 0.5 + 0.5 * math.sin(current_time * jitter_frequency)
        return jitter_factor * 100
    end

    client.set_event_callback("pre_render", function()
        local self = entity.get_local_player()
        if not self or not entity.is_alive(self) then return end

        local self_index = c_entity.new(self)
        local self_anim_state = self_index:get_anim_state()
        if not self_anim_state then return end

        if ui.get(moriade.menu.animbreak) == "Kangaroo" then
            entity.set_prop(entity.get_local_player(), "m_flPoseParameter", math.random(0, 10)/10, 3)
            entity.set_prop(entity.get_local_player(), "m_flPoseParameter", math.random(0, 10)/10, 7)
            entity.set_prop(entity.get_local_player(), "m_flPoseParameter", math.random(0, 10)/10, 6)
        end

        if ui.get(moriade.menu.animbreak) == "Earthquake" then
            local self_anim_overlay = self_index:get_anim_overlay(12)
            if not self_anim_overlay then return end

            if globals.tickcount() % 90 > 1 then
                self_anim_overlay.weight = jitter_value() / 100
            end
        end
    end)
