module Game
  # Items are picked up by the player.
  class Item < PhysicsObject
    SPRITE_WIDTH = 32

    class << self
      def sprites
        @sprites ||= SpriteSheet["item.png", SPRITE_WIDTH, SPRITE_WIDTH, 8]
      end
    end

    def short_name; "#{self.class}#{id_string}" end
    def needs_sync?; false end

    def initialize(options)
      options = {
          zorder: ZOrder::ITEM,
          collision_type: :item,
          angle: rand(4) * 90,
          speed: 0,
      }.merge! options

      super options

      Messages::CreateItem.broadcast(self) if parent.server?

      debug { "Created #{short_name} at #{position}" }
    end

    def draw
      @image.draw_rot x, y, zorder, angle, 0.5, 0.5
    end
  end
end