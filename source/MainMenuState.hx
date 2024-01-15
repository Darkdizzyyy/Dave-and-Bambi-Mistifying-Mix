package;

import flixel.addons.ui.FlxInputText;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import sys.FileSystem;
import flixel.util.FlxSave;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;
import editors.MasterEditorMenu;
#if desktop
import Discord.DiscordClient;
#end
import flixel.system.FlxSound;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'credits', 'ost', 'options', 'discord'];

	var languagesOptions:Array<String> = [
		'Story Mode',
		'Freeplay',
		'Credits',
		'OST',
		'Options',
		'Discord'
	];

	var languagesDescriptions:Array<String> = [
		'Play the story mode to unlock new characters, and understand the story!',
		'Play any song as you wish and get new scores!',
		'Look at the people who have worked for or contributed to the mod!',
		'Listen to songs of the mod.',
		'Adjust game settings and keybinds.',
		'Join the official DNB: Misifying Mix discord server!',
	];

	public static var firstStart:Bool = true;

	public static var finishedFunnyMove:Bool = false;

	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC

	public static var canInteract:Bool = true;

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var selectUi:FlxSprite;
	var bigIcons:FlxSprite;
	var camFollow:FlxObject;
	var debugKeys:Array<FlxKey>; 

	var curOptText:FlxText;
	var curOptDesc:FlxText;

	override function create()
	{
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		persistentUpdate = persistentDraw = true;

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
        bg.scrollFactor.set(0, yScroll);
        bg.setGraphicSize(Std.int(bg.width * 1.175));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
        magenta.scrollFactor.set(0, yScroll);
        magenta.setGraphicSize(Std.int(magenta.width * 1.175));
        magenta.updateHitbox();
        magenta.screenCenter();
        magenta.visible = false;
        magenta.antialiasing = ClientPrefs.globalAntialiasing;
        magenta.color = 0xFFfd719b;
        add(magenta);

		selectUi = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/Select_Thing', 'preload'));
		selectUi.scrollFactor.set(0, 0);
		selectUi.antialiasing = true;
		selectUi.updateHitbox();
		add(selectUi);

		bigIcons = new FlxSprite(0, 0);
		bigIcons.frames = Paths.getSparrowAtlas('menu_big_icons');
		for (i in 0...optionShit.length)
		{
			bigIcons.animation.addByPrefix(optionShit[i], optionShit[i] == 'freeplay' ? 'freeplay0' : optionShit[i], 24);
		}
		bigIcons.scrollFactor.set(0, 0);
		bigIcons.antialiasing = true;
		bigIcons.updateHitbox();
		bigIcons.animation.play(optionShit[0]);
		bigIcons.screenCenter(X);
		add(bigIcons);

		curOptText = new FlxText(0, 0, FlxG.width, languagesOptions[curSelected], 32);
		curOptText.setFormat("Comic Sans MS Bold", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curOptText.scrollFactor.set(0, 0);
		curOptText.borderSize = 2.5;
		curOptText.antialiasing = true;
		curOptText.screenCenter(X);
		curOptText.y = FlxG.height / 2 + 28;
		add(curOptText);

		curOptDesc = new FlxText(0, 0, FlxG.width, languagesDescriptions[curSelected], 32);
		curOptDesc.setFormat("Comic Sans MS Bold", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curOptDesc.scrollFactor.set(0, 0);
		curOptDesc.borderSize = 2;
		curOptDesc.antialiasing = true;
		curOptDesc.screenCenter(X);
		curOptDesc.y = FlxG.height - 58;
		add(curOptDesc);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('main_menu_icons');

		// camFollow = new FlxObject(0, 0, 1, 1);
		// add(camFollow);

		// FlxG.camera.follow(camFollow, null, 0.06);

		// camFollow.setPosition(640, 150.5);

		for (i in 0...optionShit.length)
		{
			var currentOptionShit = optionShit[i];
			var menuItem:FlxSprite = new FlxSprite(FlxG.width * 1.6, 0);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', (currentOptionShit == 'freeplay glitch' ? 'freeplay' : currentOptionShit) + " basic", 24);
			menuItem.animation.addByPrefix('selected', (currentOptionShit == 'freeplay glitch' ? 'freeplay' : currentOptionShit) + " white", 24);
			menuItem.animation.play('idle');
			menuItem.antialiasing = false;
			menuItem.setGraphicSize(128, 128);
			menuItem.ID = i;
			menuItem.updateHitbox();
			// menuItem.screenCenter(Y);
			// menuItem.alpha = 0; //TESTING
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 1);
			if (firstStart)
			{
				FlxTween.tween(menuItem, {x: FlxG.width / 2 - 450 + (i * 160)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						// menuItem.screenCenter(Y);
						changeItem();
					}
				});
			}
			else
			{
				// menuItem.screenCenter(Y);
				menuItem.x = FlxG.width / 2 - 450 + (i * 160);
				changeItem();
			}
		}

		firstStart = false;

		/*
		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "VDAB: Misifying Mix 1.0", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Modified Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		*/
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Dave Engine v3.0", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.y = FlxG.height / 2 + 130;
		});

		// NG.core.calls.event.logEvent('swag').send();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (leftP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (rightP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'discord')
				{
					CoolUtil.browserLoad('https://discord.gg/z8JEjkAK2Z');
				}
				else if (optionShit[curSelected] == 'credits')
				{
					CoolUtil.browserLoad('https://docs.google.com/document/d/1-BhmfMggh4OUTpj2UD6QsOeAsjNRBS4yrrNN7J5hHQw/edit?usp=sharing');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];
								switch (daChoice)
								{
									case 'story mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplaySelectState());
									case 'options':
										MusicBeatState.switchState(new options.OptionsState());
									case 'ost':
										MusicBeatState.switchState(new MusicPlayerState());
								}
							});
						}
					});
				}
			}
		#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}


	override function beatHit()
	{
		super.beatHit();
	}

	function changeItem(huh:Int = 0)
	{	
		if (canInteract)
			{
				curSelected += huh;

				if (curSelected >= menuItems.length)
					curSelected = 0;
				if (curSelected < 0)
					curSelected = menuItems.length - 1;
			}

			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');

				if (spr.ID == curSelected && canInteract)
				{
					spr.animation.play('selected');
					// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				}
				// spr.screenCenter(Y);
				spr.updateHitbox();
			});

			bigIcons.animation.play(optionShit[curSelected]);
			curOptText.text = languagesOptions[curSelected];
			curOptDesc.text = languagesDescriptions[curSelected];
	}
}