package;

import flixel.addons.transition.Transition;
import flixel.addons.transition.FlxTransitionableState;
import sys.io.File;
import lime.app.Application;
import haxe.Exception;
import Controls.Control;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
#if windows
import lime.app.Application;
import sys.FileSystem;
#end

/**
	hey you fun commiting people, 
	i don't know about the rest of the mod but since this is basically 99% my code
	i do not give you guys permission to grab this specific code and re-use it in your own mods without asking me first.
	the secondary dev, ben
 */
class CharacterInSelect
{
	public var name:String;
	public var noteMs:Array<Float>;
	public var forms:Array<CharacterForm>;

	public function new(name:String, noteMs:Array<Float>, forms:Array<CharacterForm>)
	{
		this.name = name;
		this.noteMs = noteMs;
		this.forms = forms;
	}
}

class CharacterForm
{
	public var name:String;
	public var polishedName:String;
	public var noteType:String;
	public var noteMs:Array<Float>;

	public function new(name:String, polishedName:String, noteMs:Array<Float>, noteType:String = 'normal')
	{
		this.name = name;
		this.polishedName = polishedName;
		this.noteType = noteType;
		this.noteMs = noteMs;
	}
}

class CharacterSelectState extends MusicBeatState
{
	public var char:Boyfriend;
	public var current:Int = 0;
	public var curForm:Int = 0;
	public var notemodtext:FlxText;
	public var characterText:FlxText;
	public var wasInFullscreen:Bool;

	public var funnyIconMan:HealthIcon;

	var strummies:FlxTypedGroup<FlxSprite>;

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;

	var selectedCharacter:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camTransition:FlxCamera;

	var currentSelectedCharacter:CharacterInSelect;

	var noteMsTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	var arrows:Array<FlxSprite> = [];
	var basePosition:FlxPoint;

	public static var characters:Array<CharacterInSelect> = [
		new CharacterInSelect('bf', [1, 1, 1, 1], [
			new CharacterForm('bf', 'Boyfriend', [1, 1, 1, 1]),
			new CharacterForm('bf-christmas', 'Boyfriend (Christmas)', [1, 1, 1, 1]),
			new CharacterForm('bf-car', 'Boyfriend (Car)', [1, 1, 1, 1]),
			//you can add more forms if you want, it just has to follow the format like: new CharacterForm('bf', 'Boyfriend', [1, 1, 1, 1]),
		])
	];

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		Conductor.changeBPM(110);

		camGame = new FlxCamera();
		camTransition = new FlxCamera();
		camTransition.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camTransition);
		@:privateAccess
		FlxCamera._defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camTransition;

		FlxG.camera.zoom = 1.2;
		camHUD.zoom = 0.75;

		currentSelectedCharacter = characters[current];

		FlxG.sound.playMusic(Paths.music("good-ending"), 1, true);

		// create BG

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/sky_night'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.75, 0.75);
		bg.active = false;
		add(bg);

		var hills:BGSprite = new BGSprite('charSelect/hills', -133, 52, 1, 1);
		add(hills);

		var house:BGSprite = new BGSprite('charSelect/house', 385, 78, 1, 1);
		add(house);

		var behindGrass:BGSprite = new BGSprite('charSelect/behindGrass', -33, 468, 1, 1);
		add(behindGrass);

		var gateLeft:BGSprite = new BGSprite('charSelect/gateLeft', -38, 464, 1, 1);
		add(gateLeft);

		var gateRight:BGSprite = new BGSprite('charSelect/gateRight', 1014, 464, 1, 1);
		add(gateRight);
		
		var grass:BGSprite = new BGSprite('charSelect/grass', -80, 385, 1, 1);
		add(grass);
		
		var frontGrass:BGSprite = new BGSprite('charSelect/frontGrass', -185, 382, 1, 1);
		add(frontGrass);
		
		var varientColor = 0xFF878787;
		
		frontGrass.color = varientColor;
		hills.color = varientColor;
		house.color = varientColor;
		behindGrass.color = varientColor;
		gateLeft.color = varientColor;
		gateRight.color = varientColor;
		grass.color = varientColor;

		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, 'bf');
		char.cameras = [camHUD];
		char.screenCenter();
		add(char);

		basePosition = char.getPosition();

		strummies = new FlxTypedGroup<FlxSprite>();
		strummies.cameras = [camHUD];

		add(strummies);
		generateStaticArrows(false);

		notemodtext = new FlxText((FlxG.width / 3.5) + 80, FlxG.height, 0, "1.00x       1.00x        1.00x       1.00x", 30);
		notemodtext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		notemodtext.scrollFactor.set();
		notemodtext.alpha = 0;
		notemodtext.y -= 10;
		FlxTween.tween(notemodtext, {y: notemodtext.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * 0)});
		notemodtext.cameras = [camHUD];
		add(notemodtext);

		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - 225, "Boyfriend");
		characterText.font = 'Comic Sans MS Bold';
		characterText.setFormat(Paths.font("vcr.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterText.autoSize = false;
		characterText.fieldWidth = 1080;
		characterText.borderSize = 5;
		characterText.screenCenter(X);
		characterText.cameras = [camHUD];
		characterText.antialiasing = true;
		characterText.y = FlxG.height - 180;
		add(characterText);

		var resetText = new FlxText(FlxG.width, FlxG.height, "Press R to Reset");
		resetText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetText.autoSize = false;
		resetText.fieldWidth = FlxG.height;
		resetText.x -= resetText.textField.textWidth;
		resetText.y -= resetText.textField.textHeight - 100;
		resetText.borderSize = 3;
		resetText.cameras = [camHUD];
		resetText.antialiasing = true;
		add(resetText);

		funnyIconMan = new HealthIcon('bf', true);
		funnyIconMan.cameras = [camHUD];
		funnyIconMan.visible = false;
		funnyIconMan.antialiasing = true;
		updateIconPosition();
		add(funnyIconMan);

		var tutorialThing:FlxSprite = new FlxSprite(-110, -30).loadGraphic(Paths.image('charSelectGuide'));
		tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.5));
		tutorialThing.antialiasing = true;
		tutorialThing.cameras = [camHUD];
		add(tutorialThing);

		var arrowLeft:FlxSprite = new FlxSprite(10, 0).loadGraphic(Paths.image("ArrowLeft_Idle", "preload"));
		arrowLeft.screenCenter(Y);
		arrowLeft.antialiasing = true;
		arrowLeft.scrollFactor.set();
		arrowLeft.cameras = [camHUD];
		arrows[0] = arrowLeft;
		add(arrowLeft);

		var arrowRight:FlxSprite = new FlxSprite(-5, 0).loadGraphic(Paths.image("ArrowRight_Idle", "preload"));
		arrowRight.screenCenter(Y);
		arrowRight.antialiasing = true;
		arrowRight.x = 1280 - arrowRight.width - 5;
		arrowRight.scrollFactor.set();
		arrowRight.cameras = [camHUD];
		arrows[1] = arrowRight;
		add(arrowRight);

		super.create();

		CustomFadeTransition.nextCamera = camTransition;
	}

	private function generateStaticArrows(noteType:String = 'normal', regenerated:Bool):Void
	{
		if (regenerated)
		{
			if (strummies.length > 0)
			{
				strummies.forEach(function(babyArrow:FlxSprite)
				{
					remove(babyArrow);
					strummies.remove(babyArrow);
				});
			}
		}
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, FlxG.height - 40);

			var noteAsset:String = 'NOTE_assets';
			switch (noteType)
			{
				case '3D':
					noteAsset = 'NOTE_assets_3D';
			}

			babyArrow.frames = Paths.getSparrowAtlas(noteAsset);
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.x += Note.swagWidth * i;
			switch (Math.abs(i))
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.ID = i;

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 3.5));
			babyArrow.y -= 10;
			babyArrow.alpha = 0;

			var baseDelay:Float = regenerated ? 0 : 0.5;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: baseDelay + (0.2 * i)});
			babyArrow.cameras = [camHUD];
			strummies.add(babyArrow);
		}
	}

	override public function update(elapsed:Float):Void
	{
		Conductor.songPosition = FlxG.sound.music.time;

		var controlSet:Array<Bool> = [controls.UI_LEFT_P, controls.UI_DOWN_P, controls.UI_UP_P, controls.UI_RIGHT_P];

		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (wasInFullscreen)
			{
				FlxG.fullscreen = true;
			}
			LoadingState.loadAndSwitchState(new FreeplayState());
		}

		for (i in 0...controlSet.length)
		{
			if (controlSet[i] && !PressedTheFunny)
			{
				switch (i)
				{
					case 0:
						char.playAnim(char.nativelyPlayable ? 'singLEFT' : 'singRIGHT', true);
					case 1:
						char.playAnim('singDOWN', true);
					case 2:
						char.playAnim('singUP', true);
					case 3:
						char.playAnim(char.nativelyPlayable ? 'singRIGHT' : 'singLEFT', true);
				}
			}
		}
		if (controls.ACCEPT)
		{
			if (PressedTheFunny)
			{
				return;
			}
			else
			{
				PressedTheFunny = true;
			}
			selectedCharacter = true;
			var heyAnimation:Bool = char.animation.getByName("hey") != null;
			char.playAnim(heyAnimation ? 'hey' : 'singUP', true);
			FlxG.sound.music.fadeOut(1.9, 0);
			FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));
			new FlxTimer().start(1.9, endIt);
		}
		if (FlxG.keys.justPressed.LEFT && !selectedCharacter)
		{
			curForm = 0;
			current--;
			if (current < 0)
			{
				current = characters.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			arrows[0].loadGraphic(Paths.image("ui/ArrowLeft_Pressed", "preload"));
		}

		if (FlxG.keys.justPressed.RIGHT && !selectedCharacter)
		{
			curForm = 0;
			current++;
			if (current > characters.length - 1)
			{
				current = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			arrows[1].loadGraphic(Paths.image("ArrowRight_Pressed", "preload"));
		}

		if (FlxG.keys.justReleased.LEFT)
			arrows[0].loadGraphic(Paths.image("ArrowLeft_Idle", "preload"));
		if (FlxG.keys.justReleased.RIGHT)
			arrows[1].loadGraphic(Paths.image("ArrowRight_Idle", "preload"));

		if (FlxG.keys.justPressed.DOWN && !selectedCharacter)
		{
			curForm--;
			if (curForm < 0)
			{
				curForm = characters[current].forms.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (FlxG.keys.justPressed.UP && !selectedCharacter)
		{
			curForm++;
			if (curForm > characters[current].forms.length - 1)
			{
				curForm = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (FlxG.keys.justPressed.R && !selectedCharacter)
		{
			reset();
			FlxG.resetState();
		}
	}

	public static function unlockCharacter(character:String)
	{
		if (!FlxG.save.data.charactersUnlocked.contains(character))
		{
			FlxG.save.data.charactersUnlocked.push(character);
			FlxG.save.flush();
		}
	}

	public static function reset()
	{
		FlxG.save.data.charactersUnlocked = new Array<String>();
		for (character in characters)
		{
			for (form in character.forms)
			{
				unlockCharacter(form.name); // unlock everyone
			}
		}
		FlxG.save.flush();
	}

	public function UpdateBF()
	{
		var newSelectedCharacter = characters[current];
		if (currentSelectedCharacter.forms[curForm].noteType != newSelectedCharacter.forms[curForm].noteType)
		{
			generateStaticArrows(newSelectedCharacter.forms[curForm].noteType, true);
		}

		currentSelectedCharacter = newSelectedCharacter;
		characterText.text = currentSelectedCharacter.forms[curForm].polishedName;
		char.destroy();
		char = new Boyfriend(basePosition.x, basePosition.y, currentSelectedCharacter.forms[curForm].name);
		char.cameras = [camHUD];

		insert(members.indexOf(strummies), char);
		funnyIconMan.changeIcon(char.curCharacter);
		funnyIconMan.color = FlxColor.WHITE;
		characterText.screenCenter(X);
		updateIconPosition();
		notemodtext.text = FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[0])
			+ "x       "
			+ FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[3])
			+ "x        "
			+ FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[2])
			+ "x       "
			+ FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[1])
			+ "x";
	}

	override function beatHit()
	{
		super.beatHit();
		if (char != null && !selectedCharacter && curBeat % 2 == 0)
		{
			char.playAnim('idle', true);
		}
	}

	function updateIconPosition()
	{
		// var xValues = CoolUtil.getMinAndMax(funnyIconMan.width, characterText.width);
		var yValues = CoolUtil.getMinAndMax(funnyIconMan.height, characterText.height);

		funnyIconMan.x = characterText.x + characterText.width / 2;
		funnyIconMan.y = characterText.y + ((yValues[0] - yValues[1]) / 2);
	}

	public function endIt(e:FlxTimer = null)
	{
		PlayState.characteroverride = currentSelectedCharacter.name;
		PlayState.formoverride = currentSelectedCharacter.forms[curForm].name;
		PlayState.curmult = currentSelectedCharacter.forms[curForm].noteMs;

		PlayState.SONG.player1 = currentSelectedCharacter.forms[curForm].name;
		PlayState.SONG.player1 = currentSelectedCharacter.name;

		if (FlxTransitionableState.skipNextTransIn)
		{
			CustomFadeTransition.nextCamera = null;
		}
		FlxG.sound.music.stop();
		LoadingState.loadAndSwitchState(new PlayState());
	}
}
