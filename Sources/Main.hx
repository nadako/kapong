import kha.Assets;
import kha.Framebuffer;
import kha.Key;
import kha.Scheduler;
import kha.System;
import kha.input.Keyboard;

class Main {
    public static inline var BAT_SPEED = 7;
    public static inline var BALL_SPEED = 7;
    public static inline var MARGIN = 5;
    public static inline var SCENE_WIDTH = 500;
    public static inline var SCENE_HEIGHT = 500;

    var bat1:Paddle;
    var bat2:Paddle;
    var ball:Ball;

    function new() {
        Assets.loadEverything(function() {
            var batYPos = (SCENE_HEIGHT - Paddle.LENGTH - MARGIN * 2) / 2;
            bat1 = new Paddle(MARGIN, batYPos, BAT_SPEED, Assets.sounds.ping);
            bat2 = new Paddle(SCENE_WIDTH - MARGIN - Paddle.WIDTH, batYPos, BAT_SPEED, Assets.sounds.pong);
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
            if (ball.velocity.x < 0 && ball.position.x < 30 && ball.position.y >= bat1.position.y && ball.position.y <= bat1.position.y + Paddle.LENGTH) {
                ball.position.x = 30;
                kha.audio1.Audio.play(bat1.sound);
                ball.bounce();
            } else if (ball.velocity.x > 0 && ball.position.x > 470 && ball.position.y >= bat2.position.y && ball.position.y <= bat2.position.y + Paddle.LENGTH) {
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

    public static function main() {
        System.init({title: "Project", width: SCENE_WIDTH, height: SCENE_HEIGHT}, function() new Main());
    }
}
