Powerup = Class{}

function Powerup:init( skin )
    self.width = 16
    self.height = 16
    self.x = math.random( 0, VIRTUAL_WIDTH - self.width )
    self.y = -self.height
    self.dy = 25
    self.skin = skin
end

function Powerup:collides( target )
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end

function Powerup:update( dt )
    self.y = self.y + self.dy * dt
end

function Powerup:render()
    love.graphics.draw( gTextures[ "main" ], gFrames[ "powerups" ][ self.skin ], self.x, self.y )
end