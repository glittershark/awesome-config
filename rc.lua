-- vim: set expandtab tabstop=4 foldmethod=marker:
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Weather Widget
local yawn = require("yawn")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
scriptdir = confdir .. "/scripts/"
themes = confdir .. "/themes"
active_theme = themes .. "/glittershark"
--beautiful.init("/usr/local/share/awesome/themes/zenburn/theme.lua")
--beautiful.init("/home/smith/code/awesome-config/themes/glittershark/theme.lua")
beautiful.init(active_theme .. "/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "gnome-terminal"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
default = layouts[2]
tags = {
    {
        --names  = { "term"     , "editor"   , "www"      , "personal" , "misc" },
       names = { "Ƅ", "ƈ", "ƀ", "Ɗ", "ƙ" },
        layout = { layouts[8] , default    , default    , default    , default }
    },
    {
        --names  = { "term"     , "work-web" , "monitor"  , "personal" , "misc" },
       names = { "Ƅ", "ƀ", "Ɗ", "ƈ", "ƙ" },
        layout = { layouts[9] , layouts[3] , layouts[3] , layouts[8] , layouts[2] }
    }  
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags[s].names, s, tags[s].layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Colours
coldef  = "</span>"
white  = "<span color='#d7d7d7'>"
gray = "<span color='#9e9c9a'>"

-- Create a textclock widget
mytextclock = awful.widget.textclock(" %a, %b %d | %l:%M %p ")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}

-- Taglist {{{
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
-- }}}

-- Tasklist {{{
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
-- }}}

-- Register yawn
yawn.register(2391279, '#D7D7D7', 'f')

-- Gmail widget {{{
mygmail = wibox.widget.textbox()
gmail_t = awful.tooltip({ objects = { mygmail },})
notify_shown = false
mailcount = 0
vicious.register(mygmail, vicious.widgets.gmail,
 function (widget, args)
  gmail_t:set_text(args["{subject}"])
  gmail_t:add_to_object(mygmail)
  notify_title = ""
  notify_text = ""
  mailcount = args["{count}"]
  if (args["{count}"] > 0 ) then
    if (notify_shown == false) then
      -- Italian localization
      -- can be a stub for your own localization
      if (args["{count}"] == 1) then
          notify_title = "You got a new mail"
          notify_text = '"' .. args["{subject}"] .. '"'
      else
          notify_title = "You got " .. args["{count}"] .. " new emails"
          notify_text = 'Last one: "' .. args["{subject}"] .. '"'
      end
      naughty.notify({
          title = notify_title,
          text = notify_text,
          timeout = 7,
          position = "top_left",
          icon = beautiful.widget_mail_notify,
          fg = beautiful.taglist_fg_focus,
          bg = "#060606"
      })
      notify_shown = true
    end
    if yawn.icon == yawn.sky_na then return gray .. " Mail " .. coldef .. white .. args["{count}"]  .. " " .. coldef
    else return gray .. " Mail " .. coldef .. white .. args["{count}"] .. coldef .. " <span font='Tamsyn 5'> </span><span font='Tamsyn 3'> </span>"
    end
  else
    notify_shown = false
    return ''
  end
end, 60)

mygmail:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(mail, false) end)))
-- }}}

-- Mpd widget {{{
mpdwidget = wibox.widget.textbox()
mpdwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
curr_track = nil
vicious.register(mpdwidget, vicious.widgets.mpd,
function(widget, args)
	if args["{state}"] == "Play" then
    if args["{Title}"] ~= curr_track
     then
        curr_track = args["{Title}"]
        os.execute(scriptdir .. "mpdinfo")
        old_id = naughty.notify({
            title = "Now playing",
            text = args["{Artist}"] .. " (" .. args["{Album}"] .. ")\n" .. args["{Title}"],
            icon = "/tmp/mpdnotify_cover.png",
            bg = "#060606",
            timeout = 5,
            replaces_id = old_id
        }).id
    end
   if yawn.icon == yawn.sky_na then return gray .. args["{Artist}"] .. coldef .. white .. " " .. args["{Title}"] .. " " .. coldef
    elseif mailcount == 0 then return gray .. args["{Artist}"] .. coldef .. white .. " " .. args["{Title}"] .. "<span font='Tamsyn 8'>  <span font ='Tamsyn 2'> </span></span>" .. coldef
    else return gray .. args["{Artist}"] .. coldef .. white .. " " .. args["{Title}"] .. coldef .. "<span font='Tamsyn 8'> <span font='Tamsyn 2'> </span></span>" 
    end
	 elseif args["{state}"] == "Pause" then
    if mailcount == 0 then return gray .. "mpd: " .. coldef .. white .. "paused<span font='Tamsyn 6'> </span> " .. coldef
    else return gray .. "mpd: " .. coldef .. white .. "paused " .. coldef
    end
	else
    curr_track = nil
		return ''
	end
end, 1)
-- }}}

-- Battery widget {{{
---[[
batwidget = wibox.widget.textbox()
function batstate()

  local file = io.open("/sys/class/power_supply/BAT0/status", "r")

  if (file == nil) then
    return "Cable plugged"
  end

  local batstate = file:read("*line")
  file:close()

  if (batstate == 'Discharging' or batstate == 'Charging') then
    return batstate
  else
    return "Fully charged"
  end
end
vicious.register(batwidget, vicious.widgets.bat,
function (widget, args)
  -- plugged
  if (batstate() == 'Cable plugged') then
    return ''
    -- critical
  elseif (args[2] <= 5 and batstate() == 'Discharging') then
    naughty.notify{
      text = "sto per spegnermi...",
      title = "Carica quasi esaurita!",
      position = "top_right",
      timeout = 0,
      fg="#000000",
      bg="#ffffff",
      screen = 1,
      ontop = true,
    }
    -- low
  elseif (args[2] <= 10 and batstate() == 'Discharging') then
    naughty.notify({
      text = "attacca il cavo!",
      title = "Carica bassa",
      position = "top_right",
      timeout = 0,
      fg="#ffffff",
      bg="#262729",
      screen = 1,
      ontop = true,
    })
  end
  return gray .. "Bat " .. coldef .. white .. args[2] .. "% " .. coldef
end, 1, 'BAT0')
--]]
-- }}}

-- Volume widget {{{
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume,
function (widget, args)
  if (args[2] ~= "♩" ) then
     return gray .. "Vol " .. coldef .. white .. args[1] .. "% " .. coldef
  else
     return gray .. "Vol " .. coldef .. white .. "X " .. coldef
  end
end, 1, "Master")
-- }}}

-- Separators {{{
spr = wibox.widget.textbox(' ')
first = wibox.widget.textbox('<span font="Droid Sans Mono 8"> </span>')
--arrl_pre = wibox.widget.imagebox()
--arrl_pre:set_image(beautiful.arrl_lr_pre)
--arrl_post = wibox.widget.imagebox()
--arrl_post:set_image(beautiful.arrl_lr_post)
-- }}}

-- Initialize wibox {{{
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    --left_layout:add(mylauncher)
    left_layout:add(first)
    left_layout:add(mytaglist[s])
    --left_layout:add(arrl_pre)
    left_layout:add(mypromptbox[s])
    --left_layout:add(arrl_post)
    left_layout:add(mylayoutbox[s])
    left_layout:add(first)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(first)
    if s == 1 then right_layout:add(mpdwidget) end
    right_layout:add(mygmail)
    right_layout:add(yawn.icon)
    right_layout:add(yawn.widget)
    right_layout:add(volumewidget)
    right_layout:add(spr)
    right_layout:add(batwidget)
    right_layout:add(spr)
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    
    awful.key({ modkey,           }, "]",    
        function () 
            screen_no = client.focus.screen + 1 % (screen.count() + 1)
            awful.screen.focus(screen_no)
        end),
    awful.key({ modkey,           }, "[",
        function () 
            screen_no = client.focus.screen - 1
            if screen_no < 1 then 
              screen_no = screen.count() 
            end
            awful.screen.focus(screen_no)
        end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "x",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "s",      function (c) awful.client.movetoscreen()      end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
