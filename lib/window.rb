module Game
 class Window < Chingu::Window
   attr_reader :potential_fps

    def initialize
      super 800, 600, false
      
      enable_undocumented_retrofication
      
      push_game_state Play
      
      init_fps

      self.caption = "Game of Scones (by Spooner) --- WASD or Arrows to move; Mouse to aim and fire; Hold TAB to view map"
    end  
    

    def update
      start_at = Time.now
            
      super
      
      @used_time += (Time.now - start_at).to_f
      recalculate_fps

    rescue => ex
      fatal { "#{ex.class}: #{ex}\n#{ex.backtrace.join("\n")}" }
      exit
    end
    
    def draw
      start_at = Time.now
      
      super
      
      @used_time += (Time.now - start_at).to_f

    rescue => ex
      fatal { "#{ex.class}: #{ex}\n#{ex.backtrace.join("\n")}" }
      exit
    end
    
    def init_fps
      @fps_next_calculated_at = Time.now.to_f + 1
      @fps = @potential_fps = 0
      @num_frames = 0
      @used_time = 0
    end

    def recalculate_fps
      @num_frames += 1

      if Time.now.to_f >= @fps_next_calculated_at
        elapsed_time = @fps_next_calculated_at - Time.now.to_f + 1
        @fps = @num_frames / elapsed_time
        @potential_fps = @num_frames / [@used_time, 0.0001].max

        @num_frames = 0
        @fps_next_calculated_at = Time.now.to_f + 1
        @used_time = 0
      end
    end
  end
end