require 'pong_sounds'

Shoes.app :width => 640, :height => 480, :resizable => false do  
  paddle_size = 75
  half_paddle = paddle_size / 2
  
  ball_size = 10
  half_ball = ball_size / 2
  
  start_speed_x, start_speed_y = 4, 2
  vx, vy = start_speed_x, start_speed_y
  
  comp_speed = app.width / 80
  bounce = 1.2
  paddle_width = 4
  
  winning_score = 7
  
  # set up the playing board
  nostroke and background black
  center_line = rect app.width / 2, 0, 4, app.height, :fill => white
  
  @ball = rect 0, 0, ball_size, ball_size, :fill => white
  @you, @comp = [app.width - paddle_width, 0].map {|x| rect x, 0, paddle_width, paddle_size, :curve => 2, :fill => white}
  
  @my_score, @comp_score = 0, 0
  @my_score_txt   = title @my_score, :top => 25, :left => 500, :stroke => white, :font => 'Network'
  @comp_score_txt = title @comp_score, :top => 25, :left => 100, :stroke => white, :font => 'Network'
  
  paused_text = title "PAUSED", :size => 32, :top => 140, :align => 'center', :stroke => white, :hidden => true
  
  # animates at 40 frames per second
  @animation = animate 40 do
    keypress do |key|      
      # allow user to pause by pressing spacebar
      if key == " "
        @animation.toggle
        paused_text.toggle
      end
    end
    
    # check for a score
    if @ball.left + ball_size < 0 || @ball.left > app.width
      PongSounds.play :score
      
      if @ball.left + ball_size < 0
        @my_score_txt.replace(@my_score += 1)
        @ball.move app.width, 0
        vx, vy = -start_speed_x, -start_speed_y
      else
        @comp_score_txt.replace(@comp_score += 1)
        @ball.move 0, 0
        vx, vy = start_speed_x, start_speed_y
      end
      
      # check for game over
      if @my_score > winning_score || @comp_score > winning_score
        para strong("GAME OVER", :size => 32), "\n",
          (@my_score > @comp_score ? "You win!" : "Computer wins"), 
          :top => 140, :align => 'center', :stroke => white
        @ball.hide and center_line.hide and @animation.stop
      
      # sleep for 1 second then resume play
      else
        sleep 1
      end
    end
    
    # move the @you paddle, following the mouse
    @you.top = (mouse[2] - half_paddle).to_i
    
    # determine new x/y coordinates based on old position + velocity
    nx, ny = (@ball.left + vx).to_i, (@ball.top + vy).to_i
    
    # move the @comp paddle, speed based on 'comp_speed' variable    
    @comp.top += 
      if ny + half_ball > @comp.top + paddle_size
        # ball is above us, move up towards it
        comp_speed
      elsif ny < @comp.top
        # ball is below us, move down towards it
        -comp_speed
      else
        0
      end
    
    # if the @you paddle hits the ball
    if nx + ball_size > app.width and vx > 0 and (0..paddle_size).include?(ny + half_ball - @you.top)
      vy = (ny - @you.top - half_paddle) * 0.25
      vx = -vx * bounce
      nx = app.width - ball_size
      
      PongSounds.play :hit
    # if the @comp paddle hits the ball
    elsif nx < 0 and vx < 0 and (0..paddle_size).include?(ny + half_ball - @comp.top)
      vy = (ny - @comp.top - half_paddle) * 0.25
      vx = -vx * bounce
      nx = 0
      
      PongSounds.play :hit
    # ball hits top/bottom of screen
    elsif ny + ball_size > app.height or ny < 0
      vy = -vy
      
      PongSounds.play :bounce
    end
    
    @ball.move nx, ny
  end
end