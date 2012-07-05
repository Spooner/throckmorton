module Game
  # Items are picked up by the player.
  class Item < PhysicsObject
    SPRITE_WIDTH = 16

    class << self
      def sprites
        @sprites ||= SpriteSheet["item.png", SPRITE_WIDTH, SPRITE_WIDTH, 8].map do |sprite|
          sprite.thin_outlined
        end
      end
    end

    def short_name; "#{self.class}#{id_string}" end
    def needs_sync?; false end

    def initialize(options)
      options = {
          zorder: ZOrder::ITEM,
          collision_type: :item,
      }.merge! options

      super options

      @shape.sensor = true

      Messages::CreateItem.broadcast(self) if parent.server?

      info { "Created #{short_name} at #{tile.grid_position}" }
    end

    def draw
      tile = self.tile
      if tile && tile.seen?
        @image.draw_rot x, y, zorder, angle, 0.5, 0.5
      end
    end
  end
end