KeyBrick = Class{ __includes = Brick }

function KeyBrick:init( x, y )
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16

    self.isKeyBrick = true
    self.inPlay = true

    self.psystem = love.graphics.newParticleSystem( gTextures[ "particle" ], 64 )
    self.psystem:setParticleLifetime( 0.5, 1 )
    self.psystem:setLinearAcceleration( -15, 0, 15, 80 )
    self.psystem:setEmissionArea( "normal", 10, 10 )
end

function KeyBrick:hit()
    self.psystem:setColors(
        255 / 255,
        215 / 255,
        0 / 255,
        255 / 255,
        0 / 255,
        0 / 255,
        0 / 255,
        0
    )
    self.psystem:emit(64)

    gSounds[ "brick-hit-2" ]:stop()
    gSounds[ "brick-hit-2" ]:play()

    self.inPlay = false

    if not self.inPlay then
        gSounds[ "brick-hit-1" ]:stop()
        gSounds[ "brick-hit-1" ]:play()
    end
end

function KeyBrick:render()
    if self.inPlay then
        love.graphics.draw( gTextures[ "main" ], gFrames[ "key-brick" ], self.x, self.y )
    end
end