ServeState = Class{ __includes = BaseState }

function ServeState:enter( params )
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.level = params.level
    self.highScores = params.highScores

    self.recoverPoints = params.recoverPoints
    self.brickHits = params.brickHits
    self.growPoints = params.growPoints

    self.balls = {}
    ball1 = Ball( math.random( 7 ) )
    table.insert( self.balls, ball1 )
end

function ServeState:update( dt )
    
    self.paddle:update( dt )
    for key, ball in pairs( self.balls ) do
        ball.x = self.paddle.x + ( self.paddle.width / 2 )
        ball.y = self.paddle.y - 8 
    end

    if love.keyboard.wasPressed( "enter" ) or love.keyboard.wasPressed( "return" ) then
        
        gStateMachine:change( "play", {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            balls = self.balls,
            level = self.level,
            highScores = self.highScores,
            recoverPoints = self.recoverPoints,
            growPoints = self.growPoints,
            brickHits = self.brickHits
        } )

    end

    if love.keyboard.wasPressed( "escape" ) then
        love.event.quit()
    end

end

function ServeState:render()
    self.paddle:render()
    for key, ball in pairs( self.balls ) do
        ball:render() 
    end

    for key, brick in pairs( self.bricks ) do
        brick:render()
    end

    renderScore( self.score )
    renderHealth( self.health )

    love.graphics.setFont( gFonts[ "medium" ] )
    love.graphics.printf( "Press Enter to serve!", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, "center" )
end