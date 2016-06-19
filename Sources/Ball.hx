import kha.Color;
import kha.graphics2.Graphics;
using kha.graphics2.GraphicsExtension;
import kha.math.Vector2;

enum Side {
    Left;
    Right;
}

class Ball {
    public static inline var RADIUS = 10;

    public var position(default,null):Vector2;
    public var velocity(default,null):Vector2;
    public var out(default,null):Null<Side>;
    public var speed:Float;

    public function new(x, y, speed) {
        this.speed = speed;
        reset();
    }

    public function reset() {
        this.position = new Vector2(Main.SCENE_WIDTH / 2, Main.SCENE_HEIGHT / 2);
        var direction = if (Math.random() > 0.5) 1 else -1;
        var angle = (Math.random() * Math.PI / 2) - (Math.PI / 4);
        var dirX = direction * Math.cos(angle) * speed;
        var dirY = Math.sin(angle) * speed;
        this.velocity = new Vector2(dirX, dirY);
        out = null;
    }

    public function update() {
        position.x += velocity.x;
        position.y += velocity.y;
        if (position.y < Main.MARGIN || position.y > Main.SCENE_HEIGHT - Main.MARGIN)
            velocity.y = -velocity.y;

        if (position.x < Main.MARGIN)
            out = Left;
        else if (position.x > Main.SCENE_WIDTH - Main.MARGIN)
            out = Right;
    }

    public function draw(g:Graphics) {
        g.color = Color.White;
        g.fillCircle(position.x, position.y, RADIUS);
    }

    public function bounce() {
        var direction = if (velocity.x > 0) -1 else 1;
        var angle = (Math.random() * Math.PI / 2) - (Math.PI / 4);
        velocity.x = direction * Math.cos(angle) * speed;
        velocity.y = Math.sin(angle) * speed;
    }
}
