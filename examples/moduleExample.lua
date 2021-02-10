--[[
    This file is part of darktable,
    copyright (c) 2016 Tobias Jakobs

    darktable is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    darktable is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with darktable.  If not, see <http://www.gnu.org/licenses/>.
]]
--[[

USAGE
* require this script from your luarc file
  To do this add this line to the file .config/darktable/luarc: 
require "examples/moduleExample"

* it creates a new example lighttable module

More informations about building user interface elements:
https://www.darktable.org/usermanual/ch09.html.php#lua_gui_example
And about new_widget here:
https://www.darktable.org/lua-api/index.html.php#darktable_new_widget
]]

local dt = require "darktable"
local du = require "lib/dtutils"
           require "lib/darktable_transition"

du.check_min_api_version("3.0.0", "moduleExample") 
local CURR_API_STRING = dt.configuration.api_version_string

-- translation

-- https://www.darktable.org/lua-api/index.html#darktable_gettext
local gettext = dt.gettext

gettext.bindtextdomain("moduleExample", dt.configuration.config_dir .. "/lua/locale/")

local function _(msgid)
    return gettext.dgettext("moduleExample", msgid)
end

-- declare a local namespace and a couple of variables we'll need to install the module
local mE = {}
mE.widgets = {}
mE.event_registered = false  -- keep track of whether we've added an event callback or not
mE.module_installed = false  -- keep track of whether the module is module_installed

--[[ We have to create the module in one of two ways depending on which view darktable starts
     in.  In orker to not repeat code, we wrap the darktable.register_lib in a local function.
  ]]

local function install_module()
  if not mE.module_installed then
    -- https://www.darktable.org/lua-api/index.html#darktable_register_lib
    dt.register_lib(
      "exampleModule",     -- Module name
      "exampleModule",     -- name
      true,                -- expandable
      false,               -- resetable
      {[dt.gui.views.lighttable] = {"DT_UI_CONTAINER_PANEL_RIGHT_CENTER", 100}},   -- containers
      -- https://www.darktable.org/lua-api/types_lua_box.html
      dt.new_widget("box") -- widget
      {
        orientation = "vertical",
        dt.new_widget("button")
        {
          label = _("MyButton"),
          clicked_callback = function (_)
            dt.print(_("Button clicked"))
          end
        },
        table.unpack(mE.widgets),
      },
      nil,-- view_enter
      nil -- view_leave
    )
    mE.module_installed = true
  end
end

-- https://www.darktable.org/lua-api/types_lua_check_button.html
local check_button = dt.new_widget("check_button"){label = _("MyCheck_button"), value = true}

-- https://www.darktable.org/lua-api/types_lua_combobox.html
local combobox = dt.new_widget("combobox"){label = _("MyCombobox"), value = 2, "8", "16", "32"}

-- https://www.darktable.org/lua-api/types_lua_entry.html
local entry = dt.new_widget("entry")
{
    text = "test", 
    placeholder = _("placeholder"),
    is_password = false,
    editable = true,
    tooltip = _("Tooltip Text"),
    reset_callback = function(self) self.text = "text" end
}

-- https://www.darktable.org/lua-api/types_lua_file_chooser_button.html
local file_chooser_button = dt.new_widget("file_chooser_button")
{
    title = _("MyFile_chooser_button"),  -- The title of the window when choosing a file
    value = "",                       -- The currently selected file
    is_directory = false              -- True if the file chooser button only allows directories to be selecte
}

-- https://www.darktable.org/lua-api/types_lua_label.html
local label = dt.new_widget("label")
label.label = _("MyLabel") -- This is an alternative way to the "{}" syntax to set a property 

-- https://www.darktable.org/lua-api/types_lua_separator.html
local separator = dt.new_widget("separator"){}

-- https://www.darktable.org/lua-api/types_lua_slider.html
local slider = dt.new_widget("slider")
{
  label = _("MySlider"), 
  soft_min = 10,      -- The soft minimum value for the slider, the slider can't go beyond this point
  soft_max = 100,     -- The soft maximum value for the slider, the slider can't go beyond this point
  hard_min = 0,       -- The hard minimum value for the slider, the user can't manually enter a value beyond this point
  hard_max = 1000,    -- The hard maximum value for the slider, the user can't manually enter a value beyond this point
  value = 52          -- The current value of the slider
}

-- pack the widgets in a table for loading in the module

table.insert(mE.widgets, check_button)
table.insert(mE.widgets, combobox)
table.insert(mE.widgets, entry)
table.insert(mE.widgets, file_chooser_button)
table.insert(mE.widgets, label)
table.insert(mE.widgets, separator)
table.insert(mE.widgets, slider)

-- ... and tell dt about it all


if dt.gui.current_view().id == "lighttable" then -- make sure we are in lighttable view
  install_module()  -- register the lib
else
  if not mE.event_registered then -- if we are not in lighttable view then register an event to signal when we might be
    -- https://www.darktable.org/lua-api/index.html#darktable_register_event
    dt.register_event(
      "mdouleExample", "view-changed",  -- we want to be informed when the view changes
      function(event, old_view, new_view)
        if new_view.name == "lighttable" and old_view.name == "darkroom" then  -- if the view changes from darkroom to lighttable
          install_module()  -- register the lib
         end
      end
    )
    mE.event_registered = true  --  keep track of whether we have an event handler installed
  end
end

-- vim: shiftwidth=2 expandtab tabstop=2 cindent syntax=lua
-- kate: hl Lua;
