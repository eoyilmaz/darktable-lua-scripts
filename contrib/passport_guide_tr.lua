--[[
  Passport cropping guide for darktable

  copyright (c) 2023 Erkan Ozgur Yilmaz
  
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
PASSPORT CROPPING GUIDE (Turkey Version)
This is based on the original passport guide from Kåre Hampf.

Guides for cropping passport photos based on documents from the Turkish Home Office.

INSTALLATION
* copy this file in $CONFIGDIR/lua/ where CONFIGDIR is your darktable configuration directory
* add the following line in the file $CONFIGDIR/luarc
  require "passport_guide_tr"
* (optional) add the line:
  "plugins/darkroom/clipping/extra_aspect_ratios/passport_TR 50x60mm=60:50"
  to $CONFIGDIR/darktablerc

USAGE
* when using the cropping tool, select "passport_TR" as guide and if you added the line in yout rc
  select "passport 50x60mm" as aspect
]]

local dt = require "darktable"
local du = require "lib/dtutils"
local gettext = dt.gettext

du.check_min_api_version("2.0.0", "passport_guide") 

-- Tell gettext where to find the .mo file translating messages for a particular domain
gettext.bindtextdomain("passport_guide_tr", dt.configuration.config_dir.."/lua/locale/")

local function _(msgid)
  return gettext.dgettext("passport_guide_tr", msgid)
end

dt.guides.register_guide("passport_tr",
-- draw
function(cairo, x, y, width, height, zoom_scale)
  local _width, _height

  -- get the max 50x60 rectangle
  local aspect_ratio = 60 / 50
  if width * aspect_ratio > height then
    _width = height / aspect_ratio
    _height = height
  else
    _width = width
    _height = width * aspect_ratio
  end

  cairo:save()

  cairo:translate(x + (width - _width) / 2, y + (height - _height) / 2)
  cairo:scale(_width / 50, _height / 60)

  -- outer rectangle
  cairo:rectangle( 0, 0, 50, 60)

  -- inner rectangle of 35x45
  cairo:rectangle(7.5, 6, 35, 45)

  -- inner rectangle for face
  -- hair line
  cairo:draw_line(10, 10.5, 40, 10.5) -- man
  cairo:draw_line(10, 12.5, 40, 12.5) -- woman
  -- chin line
  cairo:draw_line(10, 44, 40, 44) -- woman
  cairo:draw_line(10, 46, 40, 46) -- man

  -- centre bar
  cairo:draw_line(25, 12, 25, 48)

  -- eye range lines
  cairo:draw_line(10, 22, 40, 22)
  cairo:draw_line(10, 29.5, 40, 29.5)

  cairo:restore()
end,
-- gui
function()
  return dt.new_widget("label"){label = _("passport_tr"), halign = "start"}
end
)

-- kate: tab-indents: off; indent-width 2; replace-tabs on; remove-trailing-space on; hl Lua;
-- vim: shiftwidth=2 expandtab tabstop=2 cindent syntax=lua
