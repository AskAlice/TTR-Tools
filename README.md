Toontown Rewritten Tools
=======
TTR-Tools is a Toontown Rewritten AutoHotKey helper. Currently has Anti-AFK and Toonfest Trampoline bot that maxes every time and can repeat hands-free (~3200 tokens/hr)
[Download the latest release.](https://github.com/thezoid/TTR-Tools/releases)
<p align="center"><img src="http://i.imgur.com/HpzGcPy.png" alt="TTRT Icon"/>  <img src="https://i.imgur.com/B0wyZoV.png" alt="TTR Tools Snapshot"/></p>
<p align="center">
<p align="center"><a href="https://www.youtube.com/watch?v=nyd5mGpnBXA">Watch Overview Video</a></p><p align="center"><a href="https://www.youtube.com/watch?v=nyd5mGpnBXA"><img src="https://img.youtube.com/vi/nyd5mGpnBXA/0.jpg" alt="TTR-Tools Overview Video"/></a></p>
</p>

[Official Facebook Page](https://www.facebook.com/ttrtools/)

Features
-------
 - **Anti-AFK:** Enable/disable by CTRL+ALT+SHIFT+1. The Anti AFK will run even when TTR isn't focused. So you can continue to use your computer. As the AFK is on, the lower graph will show you how often it is ticking the Anti AFK. Every 6 seconds the graph will update, and when the AFK ticks it will spike up for one plot. The Anti-AFK can not be enabled while the trampoline is on. Use the 'Repeat' option to leave the bot on (more info below).
	 - **Settings:**

	 - AFK Time (mins): You can also set the minutes between each Anti-AFK tick. (ie: 2 mins never sleeping) The toon will log out after 12 minutes (2 mins to sleep, 10 mins to log out once sleeping) so the max AFK tick time is 11 minutes. 

 - **Trampoline Bot:** Enable by CTRL+ALT+SHIFT+2, Disable by CTRL+ALT+SHIFT+3. This is really the main feature of the program so far. I had a prototype working in a few hours, but kept developing the bot to be shiny because it's fun. It will graph the duration of each jump, to see how smoothly the bot is running. Make sure you keep TTR focused (don't tab out) while this bot is running or it won't find the pixels needed (limitation of AutoHotKey).
	 - **Settings:**

	 - Repeat Trampoline: This will let you leave the bot open and walk away as the bot racks up roughly 3200 tokens per hour. It will click away the window that pops up at the end of the trampoline game, walk backwards into the trampoline, then attempt to click the play button (given ping allows, if not then no big deal just wait for it to count down).

Upcoming features
-------
I will probably be motivated to expand upon this after ToonFest. I've already got a couple ideas, but I'll keep them to myself for now.
	
Bugs
-------
If you are having issues getting this working well or would like to report any issues please refer to the [issue tracker on github.](https://github.com/thezoid/TTR-Tools/issues)

Compiling
-------
Requires AutoHotKey, pandoc to convert readme.md to html (see line 11 of Gui.ahk). To compile with the icon, use the "Convert .ahk to .exe" utility in the AutoHotKey installation. For debugging I like to use [SciTE4AutoHotkey](http://fincs.ahk4.net/scite4ahk/)

Disclaimer
-------
You may get banned for using this. Although somewhat harmless, some may consider that it gives an 'unfair advantage'. Read the [TTR Guidelines to Being Toontastically Toon Enough](https://www.toontownrewritten.com/terms). I bet TTR could try and detect if a tool like this is running. I've not gotten banned but if this tool becomes popular then TTR's security team will probably look into this.