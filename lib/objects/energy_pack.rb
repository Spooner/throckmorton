module Game
  class EnergyPack < Item
    WIDTH = 9
    HEAL_VALUE = 25

    def initialize(x, y)
      image = TexPlay.create_image $window, WIDTH, WIDTH, color: :cyan

      super x: x, y: y, image: image
    end

    def activated_by(player)
      unless player.energy == player.max_energy
        player.energy += HEAL_VALUE
        self.destroy
      end
    end

    def draw_mini
      tile = self.tile
      if tile and tile.seen?
        parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(0, 255, 255)
      end
    end
  end
end