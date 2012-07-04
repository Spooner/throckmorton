module Game
  class WorldMaker
    MARGIN = 4

    # Generate a new map (2d array of tile types).
    def generate_tile_data(width, height)
      height.times.map do |y|
        width.times.map do |x|

          if x < MARGIN || y < MARGIN || x >= width - MARGIN || y >= height - MARGIN
            type = :cavern_wall
          elsif distance(x, y, width / 2, height / 2) < 5
            type = ([:cavern_floor] * 10 + [:water]).sample
          else
            type = ([:cavern_floor] * 40 + [:water] * 2 + [:rocks] * 1 + [:lava] * 1 + [:cavern_wall] * 16).sample
          end

          type
        end
      end
    end

    def start_position(tiles)
      [tiles.size / 2, tiles[0].size / 2]
    end

    def generate_object_data(tiles)
      player_position = start_position tiles

      valid_tiles = tiles.flatten.select {|t| t.spawn_object? && distance(t.x, t.y, *player_position) > 20 }
      valid_tiles.map.with_object([]) do |tile, data|
        case rand(100)
          when 0..10
            @@possibilities ||= Enemy.config.map {|k, v| [k] * v[:frequency] }.flatten
            data << [Enemy.name[/[^:]+$/], tile.x, tile.y, @@possibilities.sample]

          when 15..17
            data << [HealthPack.name[/[^:]+$/], tile.x, tile.y]
          when 18
            data <<[EnergyPack.name[/[^:]+$/], tile.x, tile.y]
          when 20..26
            data <<[Treasure.name[/[^:]+$/], tile.x, tile.y]
        end
      end
    end
  end
end