import kha.Color;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.Sound;

class Paddle {
    public static inline var LENGTH = 100;
    public static inline var WIDTH = 15;

    public var speed:Float;
    public var position(default,null):Vector2;
    public var controls(default,null):Controls;
    public var sound(default,null):Sound;

    public function new(x, y, speed, sound) {
        this.speed = speed;
        this.sound = sound;
        position = new Vector2(x, y);
        controls = new Controls();
    }

    public function update() {
        if (controls.up)
            position.y -= speed;
        else if (controls.down)
            position.y += speed;
        if (position.y < Main.MARGIN) position.y = Main.MARGIN;
        if (position.y > Main.SCENE_HEIGHT - LENGTH - Main.MARGIN) position.y = Main.SCENE_HEIGHT - LENGTH - Main.MARGIN;
    }

    public function draw(g:Graphics) {
        g.color = Color.White;
        g.fillRect(position.x, position.y, WIDTH, LENGTH);
    }
}

class Controls {
    public var up = false;
    public var down = false;
    public function new() {}
}
