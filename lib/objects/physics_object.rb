module Game
  class PhysicsObject < Chingu::GameObject
    extend Forwardable

    def_delegators :"@body.pos", :x, :y, :x=, :y=
    def_delegators :"@body", :reset_forces

    MARGIN = 2

    class << self
      attr_accessor :next_id
      def reset_ids; @next_id = 0 end
    end

    attr_reader :speed, :id, :body, :shape
    attr_accessor :velocity_x, :velocity_y

    def needs_sync?; true; end
    def time; parent.time; end
    def frame_time; parent.frame_time; end
    def exists?; !destroyed? end
    def destroyed?; !@shape.object end
    def position; "#{x.to_i}, #{y.to_i}" end
    def id_string; id ? "##{id}" : "" end

    def initialize(options = {})
      options = {
          rotation_center: :center_center,
      }.merge! options

      @velocity_x, @velocity_y = 0, 0 # TODO: Use these!

      @speed = options[:speed] / 10.0

      @id = PhysicsObject.next_id
      PhysicsObject.next_id += 1

      @body = CP::Body.new Float::INFINITY, Float::INFINITY

      super options

      init_physics options
    end

    def init_physics(options)
      # rectangular
      #vertices = [CP::Vec2.new(-width / 2 - MARGIN, -height / 2 - MARGIN),
      #            CP::Vec2.new(-width / 2 - MARGIN, height / 2 + MARGIN),
      #            CP::Vec2.new(width / 2 + MARGIN, height / 2 + MARGIN),
      #            CP::Vec2.new(width / 2 + MARGIN, -height / 2 - MARGIN)]
      #@shape = CP::Shape::Poly.new(@body, vertices, CP::Vec2.new(0, 0))

      @shape = CP::Shape::Circle.new(@body,
                                     scale * options[:width] + MARGIN,
                                     CP::Vec2.new(0, 0))

      @shape.collision_type = options[:collision_type]
      @shape.group = options[:group] if options.has_key? :group
      @shape.object = self
      @shape.sensor = true # No collisions, just detection.

      parent.space.add_body @body
      parent.space.add_shape @shape
    end

    def on_collision_with_wall
      # Do nothing.
    end

    def move(angle)
      move_x = offset_x angle, speed * frame_time
      move_y = offset_y angle, speed * frame_time

      dest_x, dest_y = x + move_x, y + move_y

      radius = @shape.radius

      clear_at_destination = parent.map.sample_distance dest_x, dest_y
      if clear_at_destination >= radius
        # Plenty of room to move.
        self.x, self.y = dest_x, dest_y
      else
        # Can't move the full distance, so move as far as we can.
        clear_at_start = parent.map.sample_distance x, y
        distance_to_move = (clear_at_start - radius).to_f

        #lerp = distance_to_move / (clear_at_start - clear_at_destination)
        lerp = 0.0
        #self.x = x + move_x * lerp
        #self.y = y + move_y * lerp

        on_collision_with_wall

        # Now do a bit of a slide along the surface we've collided with.
        normal_x, normal_y = parent.map.sample_normal x, y
        plane_x, plane_y = -normal_y, normal_x
        dot_product = move_x * plane_x + move_y * plane_y

        dest_x = x + dot_product * plane_x * (1.0 - lerp)
        dest_y = y + dot_product * plane_y * (1.0 - lerp)

        if parent.map.sample_distance(dest_x, dest_y) >= radius
          self.x, self.y = dest_x, dest_y
        end
      end
    end

    def distance_to(other)
      distance(x, y, other.x, other.y)
    end

    def move_towards(other)
      move Gosu::angle(x, y, other.x, other.y)
    end

    def move_away_from(other)
      move Gosu::angle(other.x, other.y, x, y)
    end

    def draw
      image.draw_rot x, y, zorder, angle, 0.5, 0.5
    end

    def destroy
      parent.map.remove_object self

      parent.space.remove_body @body
      parent.space.remove_shape @shape

      @shape.object = nil

      super

      Messages::Destroy.broadcast(self) if parent.server?

      debug { "Destroyed #{short_name} at #{position}" }
    end

    def draw_physics
      width, height = shape.bb.r - shape.bb.l, shape.bb.t - shape.bb.b

      case shape
        when CP::Shape::Circle
          $window.physics_circle.draw_rot x, y, ZOrder::PHYSICS, 0, 0.5, 0.5,
                                          width / 32.0, height / 32.0
        when CP::Shape::Poly
          $window.physics_rect.draw_rot x, y, ZOrder::PHYSICS, 0, 0.5, 0.5,
                                        width / 32.0, height / 32.0
      end
    end

    def draw_name
      Font[6].draw_rel short_name[/[^:]+$/], x, y,
                       ZOrder::PHYSICS, 0.5, 0.5
    end
  end
end