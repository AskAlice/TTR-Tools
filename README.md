This is no longer maintained. Feel free to fork and update. It's fairly out of date.

Toontown Rewritten Tools
=======

Made by Alice Knag/AskAlice. I changed my github username, then someone registered an account with that username, so it may look like I did not author this, but I did.

TTR-Tools is a Toontown Rewritten AutoHotKey helper. Currently has Anti-AFK, Garden Bot, Teleport macros (no hack), and Toonfest/party Trampoline bot that maxes every time and can repeat hands-free (~3200 tokens/hr)
[Download the latest release.](https://github.com/thezoid/TTR-Tools/releases)
<p align="center"><img src="http://i.imgur.com/HpzGcPy.png" alt="TTRT Icon"/> <br/><img src="http://i.imgur.com/OkXosgP.png" alt="TTR Tools Snapshot"/><br/>
Old GUI Eventually to be phased out:<br/>
<img src="https://i.imgur.com/YHKErJt.png" alt="Old GUI"/></p>
<p align="center">
<p align="center"><a href="https://www.youtube.com/watch?v=nyd5mGpnBXA">Watch Overview Video</a></p><p align="center"><a href="https://www.youtube.com/watch?v=nyd5mGpnBXA"><img src="https://img.youtube.com/vi/nyd5mGpnBXA/0.jpg" alt="TTR-Tools Overview Video"/></a></p>
</p>

[Official Facebook Page](https://www.facebook.com/ttrtools/)

Features
-------

**The GUI is powered by [joedf's Webapp.ahk](https://github.com/joedf/Webapp.ahk). It lets an HTML page to act as the GUI, to make the bot much prettier. There may be some bugs when using it. YMMV please report any bugs in the issues section of this repo.**

There is a config file installed to %appdata%\TTR-Tools\config.ini which will store your settings, but will overwrite itself each update. You can even change the name of the window now with the windowName property. With this it TTR-Tools will unofficially be capable of running on most TTO source games.


 - **Anti-AFK:** Enable/disable by ALT+SHIFT+1. The Anti AFK will run even when TTR isn't focused. So you can continue to use your computer. As the AFK is on, the lower graph will show you how often it is ticking the Anti AFK. Every 6 seconds the graph will update, and when the AFK ticks it will spike up for one plot. The Anti-AFK can not be enabled while the trampoline is on. Use the 'Repeat' option to leave the bot on (more info below).
	 - **Settings:**

	  - *AFK Time (mins)*: You can also set the minutes between each Anti-AFK tick. (ie: 2 mins never sleeping) The toon will log out after 12 minutes (2 mins to sleep, 10 mins to log out once sleeping) so the max AFK tick time is 11 minutes.

 - **Gardening Bot:** This feature is a work in progress (initial features released in v1.0.4, first full auto prototype in 1.1.0) There are multiple features in this gardening helper suite. Firstly, there is auto-garden which will garden all of your plants, replanting if specified and watering a specified amount of time. Alternately, there is the macro-garden which will garden a specific flower on numpad press (1-5). All modes will use the max amount of beans you can plant with except the final mode, the watering can trainer, which uses one jellybean to water, replant, then repeat. Please help me out by reporting any bugs you see into the issue section on this github repository.  
	 - **Modes:**
		 -  *Auto-Garden*:
			 - Controls: CTRL+ALT+4 to start, CTRL+ALT+5 to stop. PAUSE/Break to pause/unpause
			 - Description: Only start this at the spawn point for the estate (teleport to estate, don't move, and press the hotkey). It should work most times, if it fails beyond repair, stop it and use macro gardening to finish.
		 - *Macro-Garden*:
			 - Controls: (Enable numlock) NUMPAD 1 through 5. PAUSE/Break to pause/unpause
			 - Description: If the auto-garden isn't working out for you, or you just want to plant a specific flower, you can do the movement manually and select which flower you'd like to plant (1-5) with numpad number keys. Using numpad will ALWAYS pick a plant if there's something already in the pot. and the bot will select the beans and click plant if it is sure that it has selected the right amount of beans (mostly always this works).
		 - *Watering Can Trainer*:
			 - Controls: Numpad DOT (This is a period " . " key. Usually in between zero / enter on the numpad) to enable. PAUSE/Break to pause/unpause CTRL+SHIFT+5 to disable.
			 - Description:  This mode will train your watering can by repeatedly and indefinitely planting a one-jellybean dummy plant and then water the plant the number of times set in the "Times to Water (0-5)" setting. This will drain your jellybeans if you leave it running too long.

  	 - **Settings:**

    	- *Pick+Replant*: This option, when enabled, will authenticate the bot to pick plants. There is no reliable way to tell if the plants are grown or not, so just tick this option when the flowers are grown. Otherwise, you can uncheck it and it will just water plants that are already in a pot.
	  - *Times to Water*: Based on your water bucket skill, this is useful to either save time or get the most skill out of watering.
 - **Fast Teleport:** A simple little input will appear when you press F5. As long as you have teleport access and can open your schticker book (it doesn't matter if it's already open, either), you won't have to take your hands off the keyboard to teleport anywhere you are able to. Hit F5, the program should be able to identify which area you are trying to go to. For example, "ddl, dream, dreamland, and Donald's Dreamland" would all teleport you to to Donald's Dreamland. Please make an issue on github if you find any flaws or issues with this small addition.
  	 - **Settings:**

   	  - Currently no settings you can change, but feel free to change anything in Teleport.ahk, then compile TTRTools.ahk

 - **Trampoline Bot:** Currently disabled due to no trampolines being in TTR. You can enable it in %appdata%\TTR-Tools\config.ini. Once enabled You can run it with ALT+SHIFT+2, and stop by ALT+SHIFT+3. This is really the main feature of the program so far. I had a prototype working in a few hours, but kept developing the bot to be shiny because it's fun. It will graph the duration of each jump, to see how smoothly the bot is running. Make sure you keep TTR focused (don't tab out) while this bot is running or it won't find the pixels needed (limitation of AutoHotKey).
  	 - **Settings:**

  	  - *Repeat Trampoline*: This will let you leave the bot open and walk away as the bot racks up roughly 3200 tokens per hour. It will click away the window that pops up at the end of the trampoline game, walk backwards into the trampoline, then attempt to click the play button (given ping allows, if not then no big deal just wait for it to count down).

Upcoming features
-------
- **Gardening Bot:** I plan on making it more reliable.

- **(Potential) Gag queue:** I had an idea for ease of use in cog battles. While waiting to pick a gag, you could tell the bot which gag you're going to pick, before the gag screen pops up. The bot would wait, select the gag and cog, and you can lay back or get some snacks or something.

- **(Potential)Fast gag restock:** It may be possible to have a hotkey to buy all the gags you would like in a specific priority. This could automatically buy gags that you intend to hold the max amount of, I see no good way to restock to a specific number besides the max without some elaborate pixel searching which would probably prove to be fairly unreliable. But It's an idea I could work on if I ever feel like it.

Bugs
-------
- **Known**

	- (minor) - Sometimes the garden skill level detection gets the max beans you can plant wrong, and you end up losing skill. Only have witnessed this 4 times.

If you are having issues getting this working well or would like to report any issues please refer to the [issue tracker on github.](https://github.com/thezoid/TTR-Tools/issues)

Compiling
-------
Requires AutoHotKey, pandoc to convert readme.md to html (see line 11 of Gui.ahk). To compile with the icon, use the "Convert .ahk to .exe" utility in the AutoHotKey installation. For debugging I like to use [SciTE4AutoHotkey](http://fincs.ahk4.net/scite4ahk/)

Disclaimer
-------
You may get banned for using this. Although somewhat harmless, some may consider that it gives an 'unfair advantage'. Read the [TTR Guidelines to Being Toontastically Toon Enough](https://www.toontownrewritten.com/terms). I bet TTR could try and detect if a tool like this is running. I've not gotten banned but if this tool becomes popular then TTR's security team will probably look into this.
