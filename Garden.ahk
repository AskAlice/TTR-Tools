enableFeatureGarden = true
#Include Gui.ahk
#Include json.ahk
getBeanData(beanCount, flower){
beans = 
(
{
  "1": [
    [1],
    [2],
    [5],
    [6],
    [7]
  ],
  "2": [
    [1,7],
    [2,7],
    [5,6],
    [6,0],
    [7,1]
  ],
  "3": [
    [6,0,1],
    [2,0,0],
    [0,0,0],
    [5,0,0],
    [7,0,0]
  ],
  "4": [
    [6,0,7,2],
    [7,2,2,5],
    [1,5,6,6],
    [2,6,6,0],
    [0,6,2,6]
  ],
  "5": [
    [6,0,2,2,2],
    [7,0,0,0,0],
    [3,0,4,3,3],
    [5,0,1,4,0],
    [1,5,4,5,5]
  ],
  "6": [
    [7,0,3,3,3,3],
    [3,0,0,0,3,3],
    [6,4,7,3,4,4],
    [0,5,2,0,2,5],
    [2,5,5,2,4,5]
  ],
  "7": [
    [0,7,2,5,3,7,7],
    [7,3,7,4,7,4,4],
    [6,1,0,2,1,1,1],
    [4,3,4,3,7,4,4],
    [5,1,1,1,1,6,1]
  ],
  "8": [
    [0,4,3,3,4,4,5,4],
    [4,5,5,4,0,2,6,6],
    [7,4,6,6,7,4,6,6],
    [6,4,3,7,3,0,2,3],
    [3,6,6,3,6,2,3,6]
  ]
}
)
global pBeans := JSON.Load(beans)
currentFlower := pBeans[beanCount][flower]
return currentFlower
}

;DEBUG
Pause::
Suspend Permit
global gardening
if(gardening)
{
	guiText("txt", "Gardening paused with the PAUSE button")
	Pause, Toggle, 1
    Suspend, Toggle
}else{
	Pause, Off
	Suspend, Off
}
return

  Return
/*
Numpad7::
	checkWindow(active_id)
	OutputDebug, RUNNING DEBUGGER
	Suspend Permit
  Pause Toggle
return
Numpad8::
	isRec := false
loop{
	isup := GetKeyState("Up", "P")
	isdown := GetKeyState("Down", "P")
	isleft := GetKeyState("Left", "P")
	isright :=  GetKeyState("Right", "P")
		if (isup || isdown || isleft || isright)
	{
		isRec := true
		wuu := isup
		wdu := isdown
		wlu := isleft
		wru := isright
	elapsedtime := A_TickCount - _starttime
	}else{
		if(isRec){
			OutputDebug, Time %elapsedtime% Up %wuu% Down %wdu% Left %wlu% Right %wru%
			wuu := false
			wdu := false
			wlu := false
			wru := false
			isRec := false
		}
		_starttime := A_TickCount 
	}
	}
return

Numpad9::
	checkWindow(active_id)

		return
		*/
; END DEBUG
checkWindow(byref active_id){
width := 816
height := 639
outputDebug, windowName %windowName%
WinGet id, ID, %windowName%
active_id := id
IfWinExist %windowName%
	{
		WinActivate ; use the window found above
		WinGetPos,winX,winY,curWidth,curHeight
		if(curWidth != width || curHeight != height)
			WinMove, %windowName%, , ,  , width, height
		return true
	}
	else{
		TrayTip TTR Tools, "Toontown Application not open", 1, 1
		guiText("txt", "Toontown not open")
		exitGardening()
		return false
	}
}
getBeanCoords(bean, byref X, byref Y){
X = 285
X += bean*30
Y = 300
}
getBoxCoords(box, byref X, byref Y){
X = 300
X += box*30
Y = 375
}
safeClick(x,y){
	checkWindow(active_id)
	MouseGetPos, mouseX, mouseY
	if((mouseX >= 0 && mouseX <= 816) && (mouseY >= 0 && mouseY <= 639))
	MouseMove, x, y
	sleep,25
	ControlClick,X%x% Y%y%,ahk_id %active_id%,,,1, NA
	ControlSend,, {Ctrl},ahk_id %active_id%
}
	clickBean(bean){
	getBeanCoords(bean,x,y)
	safeClick(x,y)
	sleep, 50
	}
		makeFlower(beanCount,iteration){
			flower := getBeanData(beanCount,iteration)
			loop, % flower.MaxIndex()
				clickBean(flower[A_Index])
		}
	


/* THE PLANT FUNCTION 
 This clicks the shovel icon, scans the number of beans you can plant, then plants the plant of index `iteration` with the most beans possible.
This function will return:
0 - Replant not enabled so the plant should be watered.
1 - Completed Successfully
3 - Couldn't calculate max jbs
4 -  Didn't select max amount of beans, so reset
5 - Code error, iteration exceeds 5, the flower number should never exceet 5, as there are only 5 flowers for each tier of beans
6 - Replant enabled and the plant should be replaced.
*/
plant(iteration){
	guiText("txt", "Attempting to plant flower #" . iteration)
	if(iteration > 5 && iteration <= 10)
		iteration := 6-(iteration-5)
	if(iteration > 10)
		iteration := iteration - 10
		guiText("txt", "Real flower # is:" . iteration)
	if(iteration > 5)
		return 5
	if(!checkWindow(active_id))
		return 99
	;Looks for a pixel that is present when the bean picker is open
	guiText("txt", "Scanning for gardening sidebar.")
	PixelGetColor,boxOpen,400,250, RGB
	boxOpenDist := RGB_Euclidian_Distance(boxOpen,0xFFFFBF)
		OutputDebug Plant Box: %boxOpenDist%
	if(boxOpenDist < 20)
	{
		;Bean Picker found, no need to click the shovel button
		OutputDebug Already in window!
		guiText("txt", "Plant window already open... moving on")
	}else
	{
	;BEGIN SIDEBAR CHECKING
		if(!checkWindow(active_id))
		return
	;Try and click the shovel button, but don't remove a plant if it's already ther
	;Search for the water bucket button
		PixelGetColor,hasGardenSidebar,70,145, RGB
		sidebarDist := RGB_Euclidian_Distance(hasGardenSidebar,0xFFFF8F)
		;OutputDebug Sidebar: %sidebarDist%
		if(sidebarDist < 20)
		{
		PixelGetColor,hasBucket,40,214, RGB
		bucketDist := RGB_Euclidian_Distance(hasBucket,0x56C9D0)
		;OutputDebug Bucket: %bucketDist%
			if(bucketDist > 20)
			{
			;Water bucket not found, look for shovel tool
			PixelGetColor,hasShovel,50,159, RGB
			shovelDist := RGB_Euclidian_Distance(hasShovel,0x495251)
				;OutputDebug Shovel: %shovelDist%
				if(shovelDist < 20)
				{
					guiText("txt", "Pot is empty, so opening planting window.")
					safeClick(45,170)
					sleep, 75
				}else
				{
					guiText("txt","Found sidebar, but not shovel. House name in the way?")
					safeClick(45,170)
					sleep, 75
					;return 0
				}
			}else
			{
				;safeClick(40,214)
				global replant
				if(!replant)
				{
				guiText("txt","Plant already found for flower " . iteration . ", watering...")
				return 0
				}else{
					guiText("txt", "Replanting...")
				OutputDebug Replanting...
					Return 6
				}
			}
		}else
		{
			TrayTip TTR Tools, "Garden bot error! Couldn't find Garden Sidebar buttons. Move your toon to a pot.", 1, 1
			guiText("txt","Couldn't find flower pot. Move your toon to a pot.")
			sleep, 500
			return 9
		}
	;END SIDEBAR CHECKING
	}
	boxN = 7
	global beanCount = 0
	guiText("txt", "Scanning max number of beans.")
	loop, 8
	{
		getBoxCoords(boxN,boxX,boxY)
		PixelGetColor,box,boxX,boxY, RGB
		boxDist := RGB_Euclidian_Distance(box,0x7F7F7F)
		firstBoxDist := RGB_Euclidian_Distance(box,0xFFFFFF)
		test :=  (boxN == 0 && firstBoxDist < 20)
		if(boxDist < 20 || (boxN == 0 && firstBoxDist < 20))
		{
			if(beanCount == 0)
			beanCount := boxN + 1
		}
	boxN--
	}
	guiText("txt", "Number of Beans: " . beanCount . "Verifying...")
	OutputDebug Bean Count: %beanCount%
	if(beanCount == 0){
			TrayTip TTR Tools, "Couldn't figure out the max amount of beans you can plant. If you're in the planting window and beans are not selected already then file a bug report! ", 10, 1
			guiText("txt","Couldn't calculate max # of JBs. Already in planter?")
	 return 3
	}
	guiText("txt","Making " . beanCount . "-bean flower #" . iteration)
	makeFlower(beanCount,iteration)
	guiText("txt", "Made " . beanCount . "-bean flower #" . iteration)
	boxN = 7
	global scanBeanCount = 0
	loop, 8
	{
		getBoxCoords(boxN,boxX,boxY)
		PixelGetColor,box,boxX,boxY, RGB
		boxDist := RGB_Euclidian_Distance(box,0x7F7F7F)
		firstBoxDist := RGB_Euclidian_Distance(box,0xFFFFFF)
		test :=  (boxN == 0 && firstBoxDist < 20)
		if(boxDist < 20 || (boxN == 0 && firstBoxDist < 20))
		{
			if(scanBeanCount == 0)
			{
				scanBeanCount := boxN + 1
			}
		}
	boxN--
	}
	if(scanBeanCount == 0)
	{
		guiText("txt", "Verified! Planting now!")
		safeClick(495,435)
		return 1
	}
	else
	{
		TrayTip TTR Tools, "I messed up so I won't click plant.", 10, 1
		guiText("txt","I think I didn't select the max amount of beans to the planter, so I'll reset.")
		safeClick(405,435)
		sleep, 100
		safeClick(405,435)
		safeClick(405,435)
		safeClick(405,435)
		return 4
	}
}
checkForSidebar(mode = 0, silent = true)
{
	/* MODES:
	0 - Looking for status codes, which are:
		0 = sidebar not found, 1 =  Pot Empty, 2 = Pot Full, 3 = Scan Error
	1 - Looking to plant, making sure there's not a plant already, will click
	2 - looking to water, will click
	3 - Scan Error
	
	*/
	;BEGIN SIDEBAR CHECKING
	if(!checkWindow(active_id))
	return
;Try and click the shovel button, but don't remove a plant if it's already ther
;Search for the water bucket button
	PixelGetColor,hasGardenSidebar,70,145, RGB
	sidebarDist := RGB_Euclidian_Distance(hasGardenSidebar,0xFFFF8F)
	if(!silent) 
		OutputDebug Sidebar: %sidebarDist%
	if(sidebarDist < 20)
	{
	PixelGetColor,hasBucket,40,214, RGB
	bucketDist := RGB_Euclidian_Distance(hasBucket,0x56C9D0)
	if(!silent)
		OutputDebug Bucket: %bucketDist%
		if(bucketDist > 20)
		{
		;Water bucket not found, look for shovel tool
		PixelGetColor,hasShovel,50,159, RGB
		shovelDist := RGB_Euclidian_Distance(hasShovel,0x495251)
			if(!silent)
				OutputDebug Shovel: %shovelDist%
			if(shovelDist < 20)
			{
				if(mode != 0)
					{
						safeClick(45,170)
						sleep, 75
					}
				returnCode := 1
			}else
			{
				if(!silent)
				{

				}
				returnCode := 1 ; should be 3, but debugging
			}
		}else
		{
			if(mode != 0)
			{
				guiText("txt", "Clicking water button.")
				safeClick(40,214)
			}
			returnCode := 2
		}
	}else
	{
		if(!silent)
		{
			TrayTip TTR Tools, "Garden bot error! Couldn't find Garden Sidebar buttons", 1, 1
			guiText("txt","Couldn't find planter window or the garden sidebar buttons! Error!!")
		}
		returnCode := 9
	}
;END SIDEBAR CHECKING
	if(mode != 0)
	{
		return (returnCode == mode)
	}
	else
	{
		return returnCode
	}
}
movement(iter){
	if(!checkWindow(active_id))
		return
guiText("txt", "Running movement code #" . iter)
if(iter == 0)
	{
		ControlSend,, {Left DOWN},ahk_id %active_id%
		Sleep 281
		ControlSend,, {Left UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 400
		ControlSend,, {Up UP},ahk_id %active_id%
		
		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 430
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 90
		ControlSend,, {Up UP},ahk_id %active_id%
		
		OutputDebug moved!
		guiText("txt", "Finished movement code #" . iter)
		return true
	}
	else if(iter == 1)
	{
/*		ControlSend,, {Left DOWN},ahk_id %active_id%
		Sleep 500
		ControlSend,, {Left UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 453
		ControlSend,, {Up UP},ahk_id %active_id%
		
		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 625
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 170
		ControlSend,, {Up UP},ahk_id %active_id%

		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 710
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 157
		ControlSend,, {Up UP},ahk_id %active_id%
		*/
		ControlSend,, {Down DOWN},ahk_id %active_id%
		Sleep 125
		ControlSend,, {Down UP},ahk_id %active_id%

		ControlSend,, {Left DOWN},ahk_id %active_id%
		Sleep 469
		ControlSend,, {Left UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 469
		ControlSend,, {Up UP},ahk_id %active_id%
		
		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 719
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 300
		ControlSend,, {Up UP},ahk_id %active_id%
		
		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 906
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 90
		ControlSend,, {Up UP},ahk_id %active_id%
		OutputDebug moved!
		guiText("txt", "Finished movement code" . iter)
		return true
	}
	
	else if(iter ==2 || iter==3 || iter == 5 || iter ==7 || iter == 8)
	{
/*		ControlSend,, {Left DOWN},ahk_id %active_id%
			Sleep 200
		ControlSend,, {Left UP},ahk_id %active_id%
		ControlSend,, {Up DOWN},ahk_id %active_id%
		if(iter == 7)
			Sleep 420
		else if(iter == 5)
			Sleep 330
		else if(iter == 2)
			Sleep 380
		else
			Sleep 410
		ControlSend,, {Up UP},ahk_id %active_id%
		*/
		ControlSend,, {Left DOWN},ahk_id %active_id%
		if(iter != 5)
			Sleep 825
		else
			Sleep 800
		ControlSend,, {Left UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		if(iter == 2 || iter == 3)
			Sleep 141
		else if iter !=5)
			Sleep 140
		else
			Sleep 155
		ControlSend,, {Up UP},ahk_id %active_id%
		OutputDebug moved!
		guiText("txt", "Finished movement code" . iter)
		return true
	}
	
	else if(iter ==4)
	{
		ControlSend,, {Down DOWN},ahk_id %active_id%
		Sleep 312
		ControlSend,, {Down UP},ahk_id %active_id%
		ControlSend,, {Left DOWN},ahk_id %active_id%
		Sleep 422
		ControlSend,, {Left UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 765
		ControlSend,, {Up UP},ahk_id %active_id%
		
		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 1000
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 150
		ControlSend,, {Up UP},ahk_id %active_id%
		OutputDebug moved!
		guiText("txt", "Finished movement code" . iter)
		return true
	}
	else if(iter ==6)
	{
		ControlSend,, {Down DOWN},ahk_id %active_id%
		Sleep 94
		ControlSend,, {Down UP},ahk_id %active_id%
		
		ControlSend,, {Left DOWN},ahk_id %active_id%
		Sleep 672
		ControlSend,, {Left UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 594
		ControlSend,, {Up UP},ahk_id %active_id%
		
		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 656
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 294
		ControlSend,, {Up UP},ahk_id %active_id%
		
		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 830
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 135
		ControlSend,, {Up UP},ahk_id %active_id%
		OutputDebug moved!
		guiText("txt", "Finished movement code" . iter)
		return true
	} else if(iter == 9)
	{
	ControlSend,, {Down DOWN},ahk_id %active_id%
		Sleep 62
		ControlSend,, {Down UP},ahk_id %active_id%
		ControlSend,, {Left DOWN},ahk_id %active_id%
		Sleep 688
		ControlSend,, {Left UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 297
		ControlSend,, {Up UP},ahk_id %active_id%
		
		ControlSend,, {Right DOWN},ahk_id %active_id%
		Sleep 500
		ControlSend,, {Right UP},ahk_id %active_id%
		
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 100
		ControlSend,, {Up UP},ahk_id %active_id%
		return true
	}
	else
	{
		return false
	}
}
getColorDist(byref thisDistance, thisPixelX, thisPixelY, thisRgbColor){
	PixelGetColor,thisPixelColor,thisPixelX,thisPixelY, RGB
	thisDistance := RGB_Euclidian_Distance(thisPixelColor, thisRgbColor)
}
plantFinishOK(){
	getColorDist(dialogColor, 400, 370, 0xFFFFBF)	
	if(dialogColor < 20)
	{
		safeClick(405,405)
		return true
	}else
	{
		return false
	}
}
return
exitGardening(){
global gardening := false
gosub setStatus
}

exitGardening:
	exitGardening()
return

!+5:: 
Suspend Permit
if(gardening)
{
if(A_IsSuspended || A_IsPaused)
{
	Pause, Toggle, 1
    Suspend, Toggle
	guiText("txt", "Unpausing, Stopping Gardening...")
}
else
	guiText("txt", "Stopping Gardening...")
global gardening := false
}
return

!+4::
global shouldMacroPlant := false
gosub, runGarden
return

startGarden(){
gosub, runGarden
}
runGarden:
if(toggle)
{
TrayTip,TTR-Tools, Can't garden while anti-afk is running.
return
}
if(trampRunning)
{
TrayTip,TTR-Tools, Can't garden while trampoline is running.
return
}
global gardening := true
gosub setStatus
global shouldMacroPlant
global singlePlantNumber
OutputDebug Debugging Garden bot
width := 816
height := 639
SendMode Input
checkWindow(active_id)
flower := shouldMacroPlant ? singlePlantNumber : 1
flowersComplete := 0
readyToPlant := shouldMacroPlant ? true : false
readyToMove := shouldMacroPlant ? false : true
searchingForOK := false
moveIter := 0
sidebarCheckCount := 0
waterCount := 0
guiText("txt", "Starting Auto-Gardening\r\n------------------ \r\n")
GuiControl, TTRTools:, txt, Started Auto-Gardening
Loop
{
	global gardening
	if(!gardening)
		break
	if(!readyToPlant)
	{
		if(readyToMove)
		{
			if(shouldMacroPlant)
			{
				GuiText("txt", "loop broken by movement tick")
				break
			}
			if(movement(moveIter))
				{
				readyToPlant := true
				readyToMove := false
				moveIter+=1
				OutputDebug Move ran, next is %moveIter%
				}
				else
				{
				OutputDebug Break at moveIter %moveIter%
				guiText("txt","Gardening Finished!")
				break
				}
		}else
		{
			if(readyToWater)
			{
				if(checkForSidebar(0) == 2)
				{
					guiText("txt", "Preparing to water plants.." )
					sidebarCheckCount := 0
					
					if((waterCount >= timesToWater) || (replanting && timesToWater == 1))
					{
						waterCount := 0
						global replanting
						if(replanting)
						{
							guiText("txt", "Clicking okay on remove plant buttons.")
							safeClick(45,170)
							sleep, 125
							safeClick(369,414)
							safeClick(369,424)
							safeClick(369,435)
							safeClick(369,445)
							sleep,100
						}else{
							readyToWater := false
							readyToMove := true
						}
					}else{
						guiText("txt", "Attempting to water...")
						checkForSidebar(2)  ; waters plant
						sleep, 50
						if(checkForSidebar(0) != 2)
						{
							waterCount++
							guiText("txt", "Watered #" . waterCount . ")")
							OutputDebug watered %waterCount%
						}
					}
				}else{
					if(checkForSidebar(0) == 1){
						if(replanting)
						{
							guiText("txt", "Done Removing Plant. Planting new...")
							OutputDebug Done Replanting.
							replanting := false
							readyToPlant := true
							readyToWater := false
						}
					}else{
					sidebarCheckCount++
					if(Mod(sidebarCheckCount, 5) == 0 || sidebarCheckCount < 2)
						guiText("txt", "Looking for planting sidebar. (Attempt #" . sidebarCheckCount . " Code:" . checkForSidebar(0) . ")")
					if(sidebarCheckCount > 600)
					{
						
						guiText("txt", "Timed out looking for planting sidebar.")
						;Something went horribly wrong. Stop the bot
						exitGardening()
						TrayTip TTR Tools, "Gardening bot error. Searched for water bucket for too long", 1, 1
					}
				}}
				Sleep, 50
			}else
			{
				if(!searchingForOK)
				{
					guiText("txt", "Looking for the OK button after plant is planted")
					searchingForOK := true
				}
				if(plantFinishOK())
					{		
					guiText("txt", "Clicked OK button. Moving on...")
						searchingForOK := false
						readyToWater := true
					}
			}
		}
	}
	else
	{
		if(flowersComplete <= 10)
		{
			result := plant(flower)
			if(result == 1)
			{
				flower++
				flowersComplete++
				readyToPlant := false
			}else if(result == 0)
			{
				flower++
				flowersComplete++
				readyToPlant := false
				readyToWater := true
			}
			else if(result == 2)
			{
				
			; watered plants
			; move on to next one
			}
			else if(result == 3){
			;shit. um...
			}
			else if(result == 4)
			{
				safeClick(405,435)
				sleep, 50
				safeClick(405,435)
				;click reset
				;redo loop
			}
			else if(result == 5)
			{
				;code error, iteration exceeds 5, the flower number should never exceet 5, as there are only 5 flowers for each tier of beans
				OutputDebug, CODE ERROR! RESULT 5
				break
			}
			else if(result == 6)
			{
				global replanting  := true
				guiText("txt", "Detected a plant, and replant setting is on, so replanting")
				readyToPlant := false
				readyToWater := true
			}
			else if(result == 9){
			;sidebar not found, wait
			sleep, 500
			;keep looping
			}
			else if(result == 99){
				break
			}
		}else
		{
		OutputDebug, Unknown plant return code
		break
		}
	}
}
OutputDebug Stopping Gardening
gardening := true
guiText("txt", "\r\n------------------ \r\nStopped Auto-Gardening" ,,false)
GuiControl, TTRTools:, txt, Stopped Auto-Gardening
gardening := false
exitGardening()
return

qplant(flower){
	if(toggle)
	{
	TrayTip,TTR-Tools, Can't garden while anti-afk is running.
	return
	}
	if(trampRunning)
	{
	TrayTip,TTR-Tools, Can't garden while trampoline is running.
	return
	}
	if(garden)
	{
	TrayTip,TTR-Tools, Can't quick plant while auto-garden is running.
	return
	}
	gardening := true
	gosub setStatus
	sleep, 250
	guiText("txt", "Started Macro-Gardening\r\n------------------ \r\n")
	GuiControl, TTRTools:, txt, Started Macro-Gardening
	sleep, 150
	global singlePlantNumber := flower
	global shouldMacroPlant := true
	gosub, runGarden
	global shouldMacroPlant := false
	gardening := true
	guiText("txt", "\r\n------------------ \r\nStopped Macro-Gardening" ,, false)
	GuiControl, TTRTools:, txt, Stopped Macro-Gardening
	gardening := false
	gosub setStatus
}
NUMPAD1:: qplant(1)
NUMPAD2:: qplant(2)
NUMPAD3:: qplant(3)
NUMPAD4:: qplant(4)
NUMPAD5:: qplant(5)
NUMPADDot::
if(!gardening)
{
	gosub trainCan
}
else
{
	exitGardening()
	gosub, setStatus
	return
}
return

trainCan:
gardening := true
gosub setStatus
TrayTip TTR Tools, "Starting Watering Can Trainer", 1, 1
guiText("txt", "Training Watering Can\r\n------------------ \r\n")
GuiControl, TTRTools:, txt, Training water can...
sleep, 150
timesWatered := 0
canTrainerTimeout := 0
while(gardening){
curstatus := checkForSidebar(0)
OutputDebug Status %curstatus% Watered %timesWatered% Time %canTrainerTimeout%
if(curstatus == 1){
	safeClick(45,170)
	sleep, 75
	guiText("txt", "Making a 1-bean flower...")
	makeFlower(1,1)
	safeClick(495,435)
}
if((curstatus == 2))
{
	if(timesWatered < timesToWater)
	{
		guiText("txt", "Trying to Water...")
		result := checkForSidebar(2)
		timesWatered++
	}
	else{
			safeClick(45,170)
			sleep, 75
			safeClick(369,414)
			sleep, 30
			safeClick(369,424)
			sleep, 30
			safeClick(369,435)
			sleep, 30
			safeClick(369,445)
			sleep,100

	}
}
if(curstatus == 4)
	{
	safeClick(405,435)
	sleep, 50
	safeClick(405,435)
	}
if(curstatus == 9)
	{
		if(plantFinishOK())
			{
				guiText("txt", "Finished making plant.")
				timesWatered := 0
				canTrainerTimeout := 0
			}
			PixelGetColor,boxOpen,400,250, RGB
			boxOpenDist := RGB_Euclidian_Distance(boxOpen,0xFFFFBF)
			if(boxOpenDist < 20)
			{
				;Bean Picker found, no need to click the shovel button
				safeClick(405,435)
				sleep, 50
				safeClick(405,435)
				sleep, 75
				guiText("txt", "Making a 1-bean flower...")
				makeFlower(1,1)
				safeClick(495,435)
			}
		canTrainerTimeout++
		if(Mod(canTrainerTimeout, 10) == 0 || canTrainerTimeout < 2)
						guiText("txt", "Looking for planting sidebar. (Attempt #" . canTrainerTimeout . ")")
		if(canTrainerTimeout > 300)
		{
			gardening := false
			guiText("txt", "Watering can trainer timed out...")
		}
	}
if(curstatus != 9)
	canTrainerTimeout := 0
}
gardening := true
guiText("txt", "\r\n------------------ \r\nStopping watering can trainer...",, false)
GuiControl, TTRTools:, txt, Stopping watering can trainer...
gardening := false
gosub setStatus
return