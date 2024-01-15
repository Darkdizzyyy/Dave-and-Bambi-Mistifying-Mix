package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class FreeplaySelectState extends MusicBeatState 
{
    public static var freeplayCats:Array<String> = ['main', 'extras'];
    public static var curCategory:Int = 0;

    public var NameAlpha:Alphabet;

    var grpCategoryIcons:FlxTypedGroup<MenuItemAltFreeplay>;
    var curSelected:Int = 0;
    var BG:FlxSprite;
    var categoryIcon:MenuItemAltFreeplay;
    var num:Int = 0;

    override function create()
    {
        BG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        BG.updateHitbox();
        BG.screenCenter();
        BG.color = 0xFF4965FF;
        add(BG);

        grpCategoryIcons = new FlxTypedGroup<MenuItemAltFreeplay>();
		add(grpCategoryIcons);

        for (i in 0...freeplayCats.length)
		{
            categoryIcon = new MenuItemAltFreeplay(0, 0, freeplayCats[i]);
            categoryIcon.targetX = num;
            categoryIcon.screenCenter();
            grpCategoryIcons.add(categoryIcon);
            num++;
        }

        NameAlpha = new Alphabet(10,(FlxG.height / 2) - 282,freeplayCats[curSelected],true);
        NameAlpha.screenCenter(X);
        Highscore.load();

        add(NameAlpha);

        changeSelection();

        super.create();
    }

    override public function update(elapsed:Float) {
        if (controls.UI_LEFT_P)
            changeSelection(-1);
        if (controls.UI_RIGHT_P)
            changeSelection(1);

        var shiftMult:Int = 1;
        if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

        if(FlxG.mouse.wheel != 0)
		{
			changeSelection(-shiftMult * FlxG.mouse.wheel);
		}

        if (controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

        if (controls.ACCEPT){
            MusicBeatState.switchState(new FreeplayState());
        }

        curCategory = curSelected;

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;

        if (curSelected < 0)
            curSelected = freeplayCats.length - 1;
        if (curSelected >= freeplayCats.length)
            curSelected = 0;
        
        var bullShit:Int = 0;
        for (item in grpCategoryIcons.members)
		{
			item.targetX = bullShit - curSelected;
			bullShit++;
		}
        
        NameAlpha.destroy();
        NameAlpha = new Alphabet(10,(FlxG.height / 2) - 282,freeplayCats[curSelected],true);
        NameAlpha.screenCenter(X);
        add(NameAlpha);

        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}