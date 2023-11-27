PlayState = Class{ __includes = BaseState }

local timer = 0

function PlayState:enter( params )
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.balls = params.balls
    self.level = params.level
    self.highScores = params.highScores
    
    self.recoverPoints = params.recoverPoints
    self.brickHits = params.brickHits
    self.growPoints = params.growPoints
    self.powerups = {}
    self.keyPowerup = params.keyPowerup

    for key, ball in pairs( self.balls ) do
        ball.dx = math.random( -200, 200 )
        ball.dy = math.random( -50, -60 ) 
    end

end

function PlayState:update( dt )

    timer = timer + 1

    if self.paused then
        if love.keyboard.wasPressed( "space" ) then
            self.paused = false
            gSounds[ "pause" ]:play()
        else
            return
        end
    elseif love.keyboard.wasPressed( "space" ) then
        self.paused = true
        timer = timer - 1
        gSounds[ "pause" ]:play()
        return
    end

    if ( timer / 144 ) > 30 then
        powerup = Powerup( 10 )
        powerup.isKey = true
        table.insert( self.powerups, powerup )
        timer = 0
    end

    for key, powerup in pairs( self.powerups ) do
        powerup:update( dt )
    end

    for key, powerup in pairs( self.powerups ) do
        if powerup:collides( self.paddle ) then
            if powerup.isKey then
                self.keyPowerup = true
            end
            table.remove( self.powerups, key )
            ball2 = Ball( math.random( 7 ) )
            ball2.x = self.paddle.x + ( self.paddle.width / 2 )
            ball2.y = self.paddle.y - 8 
            ball2.dx = math.random( -200, 200 )
            ball2.dy = math.random( -50, -60 ) 
            ball3 = Ball( math.random( 7 ) )
            ball3.x = self.paddle.x + ( self.paddle.width / 2 )
            ball3.y = self.paddle.y - 8
            ball3.dx = math.random( -200, 200 )
            ball3.dy = math.random( -50, -60 )
            table.insert( self.balls, ball2 )
            table.insert( self.balls, ball3 )
            gSounds[ "powerup" ]:play()
        end
    end

    self.paddle:update( dt )
    for key, ball in pairs( self.balls ) do
        ball:update( dt ) 
    end

    for key, ball in pairs( self.balls ) do
        if ball:collides( self.paddle ) then
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy
    
            if ball.x < self.paddle.x + ( self.paddle.width / 2 ) and self.paddle.dx < 0 then
                ball.dx = -50 + -( 8 * ( self.paddle.x + self.paddle.width / 2 - ball.x ) )
            elseif ball.x > self.paddle.x + ( self.paddle.width / 2 ) and self.paddle.dx > 0 then
                ball.dx = 50 + ( 8 * math.abs( self.paddle.x + self.paddle.width / 2 - ball.x ) )
            end
    
            gSounds[ "paddle-hit" ]:play()
        end 
    end

    for key, brick in pairs( self.bricks ) do

        for k, ball in pairs( self.balls ) do

            if brick.inPlay and ball:collides( brick ) then
    
                if brick.isKeyBrick then
                    if self.keyPowerup then
                        brick:hit()
                        self.brickHits = self.brickHits + 1
                        self.keyPowerup = false
                    end
                else
                    self.score = self.score + ( brick.tier * 200 + brick.color * 25 )
                    brick:hit()
                    self.brickHits = self.brickHits + 1
                end
    
                if self.score > self.recoverPoints then
                    self.health = math.min( 3, self.health + 1 )
                    self.recoverPoints = math.min( 100000, self.recoverPoints * 2 )
                    gSounds[ "recover" ]:play()
                end

                if self.score > self.growPoints then
                    self.paddle.size = math.min( 4, self.paddle.size + 1 )
                    if self.paddle.size == 2 then
                        self.paddle.width = 64
                    elseif self.paddle.size == 3 then
                        self.paddle.width = 96
                    elseif self.paddle.size == 4 then
                        self.paddle.width = 128
                    end
                    self.growPoints = math.min( 100000, self.growPoints * 2 )
                    gSounds[ "paddle-grow" ]:play()
                end

                if self.brickHits > 10 then
                    powerup = Powerup( math.random(9) )
                    powerup.isKey = false
                    table.insert( self.powerups, powerup )
                    self.brickHits = 0
                end
    
                if self:checkVictory() then
                    gSounds[ "victory" ]:play()
    
                    gStateMachine:change( "victory", {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        balls = self.balls,
                        highScores = self.highScores,
                        recoverPoints = self.recoverPoints,
                        growPoints = self.growPoints,
                        brickHits = self.brickHits,
                    } )
                end
    
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                elseif ball.y < brick.y then 
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                else
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end
    
                ball.dy = ball.dy * 1.02
                break
    
            end 
        end

    end

    for key, powerup in pairs( self.powerups ) do
        if powerup.y > VIRTUAL_HEIGHT then
            table.remove( self.powerups, key )
        end
    end

    for key, ball in pairs( self.balls ) do
        if ball.y >= VIRTUAL_HEIGHT then
            table.remove( self.balls, key )

            if #self.balls == 0 then
                self.health = self.health - 1
                self.paddle.size = math.max( 1, self.paddle.size - 1 )
                if self.paddle.size == 1 then
                    self.paddle.width = 32
                elseif self.paddle.size == 2 then
                    self.paddle.width = 64
                elseif self.paddle.size == 3 then
                    self.paddle.width = 96
                end
            end
            gSounds[ "hurt" ]:play()
    
            if self.health == 0 then
                gStateMachine:change( "game-over", {
                    score = self.score,
                    highScores = self.highScores
                } )
            elseif #self.balls == 0 then
                gStateMachine:change( "serve", {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints,
                    growPoints = self.growPoints,
                    brickHits = self.brickHits,
                    keyPowerup = self.keyPowerup
                } )
            end
        end 
    end

    for key, brick in pairs( self.bricks ) do
        brick:update( dt )
    end

    if love.keyboard.wasPressed( "escape" ) then
        love.event.quit()
    end
end

function PlayState:render()

    for key, brick in pairs( self.bricks ) do
        brick:render()
    end

    for key, brick in pairs( self.bricks ) do
        brick:renderParticles()
    end

    for key, powerup in pairs( self.powerups ) do
        powerup:render()
    end

    self.paddle:render()
    for key, ball in pairs( self.balls ) do
        ball:render() 
    end

    renderScore( self.score )
    renderHealth( self.health )

    if self.paused then
        love.graphics.setFont( gFonts[ "large" ] )
        love.graphics.printf( "PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, "center" )
    end
end

function PlayState:checkVictory()
    for key, brick in pairs( self.bricks ) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end