Toontown Rewritten Tools
=======
<img src="http://i.imgur.com/HpzGcPy.png" alt="TTRT Icon"/>
TTR-Tools is a Toontown Rewritten AutoHotKey helper. Currently has Anti-AFK and Toonfest Trampoline bot that maxes every time and can repeat hands-free (~6500 tokens/hr)
[Download the latest release.](https://github.com/thezoid/TTR-Tools/releases)
<p align="center"> <img src="http://i.imgur.com/RC0feE1.png" alt="TTR Tools Snapshot"/> </p>

Features
-------
 - **Anti-AFK:** Enable/disable by CTRL+ALT+SHIFT+1. The Anti AFK will run even when TTR isn't focused. So you can continue to use your computer. As the AFK is on, the lower graph will show you how often it is ticking the Anti AFK. Every 6 seconds the graph will update, and when the AFK ticks it will spike up for one plot. The Anti-AFK can not be enabled while the trampoline is on. Use the 'Repeat' option to leave the bot on (more info below).
	 - **Settings:**

	 - AFK Time (mins): You can also set the minutes between each Anti-AFK tick. (ie: 2 mins never sleeping) The toon will log out after 12 minutes (2 mins to sleep, 10 mins to log out once sleeping) so the max AFK tick time is 11 minutes. 

 - **Trampoline Bot:** Enable by CTRL+ALT+SHIFT+2, Disable by CTRL+ALT+SHIFT+3. This is really the main feature of the program so far. I had a prototype working in a few hours, but kept developing the bot to be shiny because it's fun. It will graph the jump strength as the bot jumps on the trampoline. Make sure you keep TTR focused (don't tab out) while this bot is running or it won't find the pixels needed (limitation of AutoHotKey).
	 - **Settings:**

	 - Repeat: This will let you leave the bot open and walk away as the bot racks up roughly 6500 tokens per hour. It will click away the window that pops up at the end of the trampoline game, walk backwards into the trampoline, then attempt to click the play button (given ping allows, if not then no big deal just wait for it to count down).

	 - Lagfix (>40): If the 'lag' variable shown above the graph during each jump is more often than not above 40, use this as lag above 40 will make the jumps too late. When the bot is working fine lag is usually around 31, but if for some reason the system is taking longer than usual to search, this option will get rid of some methods that search pixels each time a jump is made to a) see the variation in the color (integrity) and b) verify that the bot is in the trampoline game by looking for the purple pixels at the bottom of the jump bar. This prevents unwanted jumps when bot is enabled but not in trampoline. Stop the bot when walking around to mitigate this. It is recommended that you don't use lagfix if possible. To improve your performance (lower the lag number) close other 3d applications, applications of high impact (ie: chrome), and make sure only one TTR-Tools application is running (check taskbar).

Upcoming features
-------
I will probably be motivated to expand upon this after ToonFest. I've already got a couple ideas, but I'll keep them to myself for now.
	
Bugs
-------
If you are having issues getting this working well or would like to report any issues please refer to the [issue tracker on github.](https://github.com/thezoid/TTR-Tools/issues)

Compiling
-------
Requires AutoHotKey, pandoc to convert readme.md to html (see line 31 of TTR-Tools.ahk). To compile with the icon, use the "Convert .ahk to .exe" utility in the AutoHotKey installation. For debugging I like to use [SciTE4AutoHotkey](http://fincs.ahk4.net/scite4ahk/)

Disclaimer
-------
You may get banned for using this. Although somewhat harmless, some may consider that it gives an 'unfair advantage'. Read the [TTR Guidelines to Being Toontastically Toon Enough](https://www.toontownrewritten.com/terms). I bet TTR could try and detect if a tool like this is running. I've not gotten banned but if this tool becomes popular then TTR's security team will probably look into this.