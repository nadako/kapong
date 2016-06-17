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
	public static inline var WIDTH = 100;
	
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
		if (position.y < 5) position.y = 5;
		if (position.y > 395) position.y = 395;
	}
	
	public function draw(g:Graphics) {
		g.color = Color.White;
		g.fillRect(position.x, position.y, 15, WIDTH);
	}
}

class Ball {
	public var position(default,null):Vector2;
	public var velocity(default,null):Vector2;
	public var out(default,null):Null<Side>;
	public var speed:Float;

	public function new(x, y, speed) {
		this.speed = speed;
		reset();
	}
	
	public function reset() {
		this.position = new Vector2(250, 250);
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
		if (position.y < 5 || position.y > 495)
			velocity.y = -velocity.y;

		if (position.x < 5)
			out = Left;
		else if (position.x > 495)
			out = Right;
	}

	public function draw(g:Graphics) {
		g.color = Color.White;
		g.fillCircle(position.x, position.y, 10);
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
	var bat1:Bat;
	var bat2:Bat;
	var ball:Ball;
	
	public function new() {
		Assets.loadEverything(function() {
			bat1 = new Bat(5, 200, 7, Assets.sounds.ping);
			bat2 = new Bat(480, 200, 7, Assets.sounds.pong);
			ball = new Ball(250, 250, 7);
			
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
			if (ball.velocity.x < 0 && ball.position.x < 30 && ball.position.y >= bat1.position.y && ball.position.y <= bat1.position.y + Bat.WIDTH) {
				ball.position.x = 30;
				kha.audio1.Audio.play(bat1.sound);
				ball.bounce();
			} else if (ball.velocity.x > 0 && ball.position.x > 470 && ball.position.y >= bat2.position.y && ball.position.y <= bat2.position.y + Bat.WIDTH) {
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
		g.end();		
	}
}
