import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Key;
import kha.input.Keyboard;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.Assets;
import kha.Sound;
using kha.graphics2.GraphicsExtension;

enum Side {
    Left;
    Right;
}

class Bat {
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
        if (position.y < Project.MARGIN) position.y = Project.MARGIN;
        if (position.y > Project.SCENE_HEIGHT - LENGTH - Project.MARGIN) position.y = Project.SCENE_HEIGHT - LENGTH - Project.MARGIN;
    }

    public function draw(g:Graphics) {
        g.color = Color.White;
        g.fillRect(position.x, position.y, WIDTH, LENGTH);
    }
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
        this.position = new Vector2(Project.SCENE_WIDTH / 2, Project.SCENE_HEIGHT / 2);
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
        if (position.y < Project.MARGIN || position.y > Project.SCENE_HEIGHT - Project.MARGIN)
            velocity.y = -velocity.y;

        if (position.x < Project.MARGIN)
            out = Left;
        else if (position.x > Project.SCENE_WIDTH - Project.MARGIN)
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

class Controls {
    public var up = false;
    public var down = false;
    public function new() {}
}

class Project {
    public static inline var BAT_SPEED = 7;
    public static inline var BALL_SPEED = 7;
    public static inline var MARGIN = 5;
    public static inline var SCENE_WIDTH = 500;
    public static inline var SCENE_HEIGHT = 500;

    var bat1:Bat;
    var bat2:Bat;
    var ball:Ball;

    public function new() {
        Assets.loadEverything(function() {
            var batYPos = (SCENE_HEIGHT - Bat.LENGTH - MARGIN * 2) / 2;
            bat1 = new Bat(MARGIN, batYPos, BAT_SPEED, Assets.sounds.ping);
            bat2 = new Bat(SCENE_WIDTH - MARGIN - Bat.WIDTH, batYPos, BAT_SPEED, Assets.sounds.pong);
            ball = new Ball(SCENE_WIDTH / 2, SCENE_HEIGHT / 2, BALL_SPEED);

            System.notifyOnRender(render);
            Scheduler.addTimeTask(update, 0, 1 / 60);
            Keyboard.get().notify(onKeyDown, onKeyUp);
        });
    }

    function onKeyUp(key:Key, char:String) {
        switch (key) {
            case Key.UP:
                bat1.controls.up = false;
            case Key.DOWN:
                bat1.controls.down = false;
            default:
        }
    }

    function onKeyDown(key:Key, char:String) {
        switch (key) {
            case Key.UP:
                bat1.controls.up = true;
            case Key.DOWN:
                bat1.controls.down = true;
            default:
        }
    }

    function ai() {
        bat2.controls.down = (ball.position.x > 300 && ball.position.y > bat2.position.y + 70);
        bat2.controls.up = (ball.position.x > 300 && ball.position.y < bat2.position.y + 30);
    }

    function update(): Void {
        ai();
        bat1.update();
        bat2.update();
        ball.update();
        if (ball.out != null) {
            ball.reset();
            kha.audio1.Audio.play(kha.Assets.sounds.lose);
        } else {
            if (ball.velocity.x < 0 && ball.position.x < 30 && ball.position.y >= bat1.position.y && ball.position.y <= bat1.position.y + Bat.LENGTH) {
                ball.position.x = 30;
                kha.audio1.Audio.play(bat1.sound);
                ball.bounce();
            } else if (ball.velocity.x > 0 && ball.position.x > 470 && ball.position.y >= bat2.position.y && ball.position.y <= bat2.position.y + Bat.LENGTH) {
                ball.position.x = 470;
                kha.audio1.Audio.play(bat2.sound);
                ball.bounce();
            }
        }
    }

    function render(framebuffer: Framebuffer): Void {
        var g = framebuffer.g2;
        g.begin();
        bat1.draw(g);
        bat2.draw(g);
        ball.draw(g);
        g.drawRect(MARGIN, MARGIN, SCENE_WIDTH - MARGIN * 2, SCENE_HEIGHT - MARGIN * 2);
        g.end();
    }
}
