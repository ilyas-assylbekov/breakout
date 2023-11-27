VictoryState = Class{ __includes = BaseState }

function VictoryState:enter( params )
    self.level = params.level
    self.score = params.score
    self.paddle = params.paddle
    self.health = params.health
    self.balls = params.balls
    self.highScores = params.highScores
    self.recoverPoints = params.recoverPoints
end

function VictoryState:update( dt )
    self.paddle:update( dt )

    for key, ball in pairs( self.balls ) do
        ball.x = self.paddle.x + ( self.paddle.width / 2 ) - 4
        ball.y = self.paddle.y - 8 
    end

    if love.keyboard.wasPressed( "enter" ) or love.keyboard.wasPressed( "return" ) then
        gStateMachine:change( "serve" , {
            level = self.level + 1,
            bricks = LevelMaker.createMap( self.level + 1 ),
            paddle = self.paddle,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            recoverPoints = self.recoverPoints
        })
    end

end

function VictoryState:render()
    self.paddle:render()
    for key, ball in pairs( self.balls ) do
        ball:render() 
    end

    renderHealth( self.health )
    renderScore( self.score )

    love.graphics.setFont( gFonts[ "large" ] )
    love.graphics.printf( "Level " .. tostring( self.level ) .. " complete!", 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, "center" )

    love.graphics.setFont( gFonts[ "medium" ] )
    love.graphics.printf( "Press Enter to serve!", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, "center" )
end