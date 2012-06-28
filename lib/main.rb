Config = RbConfig if defined? RbConfig unless defined? RSpec # Hack for deprecation warning.

require 'forwardable'
require 'fileutils'

APP_NAME = "Game_of_Scones"

USER_DATA_PATH = if ENV['APPDATA']
                   pretty_name = APP_NAME.split("_").map(&:capitalize).join(" ").gsub(/ (?:And|Or|Of) /, &:downcase)
                   File.join ENV['APPDATA'].gsub("\\", "/"), pretty_name
                 else
                   File.expand_path "~/.#{APP_NAME}"
                 end

FileUtils.mkdir_p USER_DATA_PATH

t = Time.now

require 'bundler/setup'
Bundler.require :default

require_relative 'standard_ext/object' # Set up logging

info { "Loaded gems in #{Time.now - t}s" }

include Gosu
include Chingu

module ZOrder
  TILES, PROJECTILES, ITEM, ENEMY, PLAYER, LIGHT, GUI, CURSOR = *(0..100)
end

t = Time.now



require_relative "standard_ext/class"
require_relative "chipmunk_ext/space"
require_relative "chingu_ext/game_object"

require_relative "game"
require_relative "version"
require_relative "window"

require_relative "states/play"

require_relative "map/map"
require_relative "map/tile"

require_relative "mixins/line_of_sight"

require_relative "objects/physics_object"
require_relative "objects/item"

require_relative "objects/entity"
require_relative "objects/player"
require_relative "objects/health_path"
require_relative "objects/energy_pack"
require_relative "objects/enemy"
require_relative "objects/projectile"
require_relative "objects/treasure"

info { "Loaded scripts in #{Time.now - t}s" }