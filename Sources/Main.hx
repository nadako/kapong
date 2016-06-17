import kha.System;

class Main {
    public static function main() {
        System.init({title: "Project", width: Project.SCENE_WIDTH, height: Project.SCENE_HEIGHT}, function() new Project());
    }
}
