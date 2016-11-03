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
\::
  Suspend Permit
  Pause Toggle
  Return
  
checkWindow(byref active_id){
width := 816
height := 639
WinGet id, ID, Toontown Rewritten [BETA]
active_id := id
IfWinExist, Toontown Rewritten [BETA]
	{
		WinActivate ; use the window found above
		WinGetPos,winX,winY,curWidth,curHeight
		if(curWidth != width || curHeight != height)
			WinMove, Toontown Rewritten [BETA], , ,  , width, height
		return true
	}
	else{
		TrayTip TTR Tools, "Toontown Application not open", 1, 1
		GuiControl,,txt, Toontown not open
		global gardening := false
		gardening := false
		gosub setStatus
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
	}
		makeFlower(beanCount,iteration){
			flower := getBeanData(beanCount,iteration)
			loop, % flower.MaxIndex()
				clickBean(flower[A_Index])
		}
		
plant(iteration){
	if(!checkWindow(active_id))
		return
	;Looks for a pixel that is present when the bean picker is open
	PixelGetColor,boxOpen,400,250, RGB
	boxOpenDist := RGB_Euclidian_Distance(boxOpen,0xFFFFBF)
		OutputDebug Plant Box: %boxOpenDist%
	if(boxOpenDist < 20)
	{
		;Bean Picker found, no need to click the shovel button
		OutputDebug Already in window!
	}else
	{
		if(!checkWindow(active_id))
		return
	;Try and click the shovel button, but don't remove a plant if it's already ther
	;Search for the water bucket button
		PixelGetColor,hasGardenSidebar,70,145, RGB
		sidebarDist := RGB_Euclidian_Distance(hasGardenSidebar,0xFFFF8F)
		OutputDebug Sidebar: %sidebarDist%
		if(sidebarDist < 20)
		{
		PixelGetColor,hasBucket,40,214, RGB
		bucketDist := RGB_Euclidian_Distance(hasBucket,0x56C9D0)
		OutputDebug Bucket: %bucketDist%
			if(bucketDist > 20)
			{
			;Water bucket not found, look for shovel tool
			PixelGetColor,hasShovel,50,159, RGB
			shovelDist := RGB_Euclidian_Distance(hasShovel,0x495251)
				OutputDebug Shovel: %shovelDist%
				if(shovelDist < 20)
				{
					safeClick(45,170)
					sleep, 75
				}else
				{
					TrayTip TTR Tools, "Garden bot error! Couldn't find Shovel button but could find Garden Sidebar! Make a bug report!!", 1, 1
					GuiControl,,txt, Found sidebar but couldn't find shovel button! Error!!
					return 0
				}
			}else
			{
				safeClick(40,214)
				return 2
			}
		}else
		{
			TrayTip TTR Tools, "Garden bot error! Couldn't find Garden Sidebar buttons", 1, 1
			GuiControl,,txt, Couldn't find planter window or the garden sidebar buttons! Error!!
			return 0
		}
	}
	boxN = 7
	beanCount = 0
	loop, 8
	{
		getBoxCoords(boxN,boxX,boxY)
		PixelGetColor,box,boxX,boxY, RGB
		boxDist := RGB_Euclidian_Distance(box,0x7F7F7F)
		if(boxDist < 20 || (boxN == 0 && RGB_Euclidian_Distance(box,0xFFFFFF) < 20))
		{
			if((beanCount +1)< (boxN + 1))
			beanCount := boxN + 1
		}
	boxN--
	}
	OutputDebug Bean Count: %beanCount%
	if(beanCount == 0){
			TrayTip TTR Tools, "Couldn't figure out the max amount of beans you can plant. If you're in the planting window and beans are not selected already then file a bug report!", 10, 1
			GuiControl,,txt, Couldn't calculate max # of JBs. Already in planter?
	 return 3
	}
	GuiControl,,txt, Making %beanCount%-bean flower #%iteration%
	makeFlower(beanCount,iteration)
	GuiControl,,txt, Made %beanCount%-bean flower #%iteration%
	boxN := 7
		scanBeanCount := 0
		loop, 8
	{
		getBoxCoords(boxN,boxX,boxY)
		PixelGetColor,box,boxX,boxY, RGB
		boxDist := RGB_Euclidian_Distance(box,0x7F7F7F)
		OutputDebug Count %boxN% Dist %boxDist%
		if(boxDist < 20 || RGB_Euclidian_Distance(box,0xFFFFFF) < 10)
		{
			if((scanBeanCount +1)< (boxN + 1))
			scanBeanCount := boxN + 1
		}
	boxN--
	}
	if(scanBeanCount == 0)
	{
		safeClick(495,435)
		return 1
	}
	else
	{
		TrayTip TTR Tools, "I messed up so I won't click plant.", 10, 1
		GuiControl,,txt, I think I didn't select the max amount of beans to the planter, so I won't click plant.
		return 4
	}
}
movement(iter){
	if(!checkWindow(active_id))
		return
if(iter == 0)
	{
		ControlSend,, {Left DOWN},ahk_id %active_id%
		Sleep 170
		ControlSend,, {Left UP},ahk_id %active_id%
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 600
		ControlSend,, {Up UP},ahk_id %active_id%
		OutputDebug moved!
		return true
	}else if(iter == 1)
	{
		ControlSend,, {Left DOWN},ahk_id %active_id%
		Sleep 70
		ControlSend,, {Left UP},ahk_id %active_id%
		ControlSend,, {Up DOWN},ahk_id %active_id%
		Sleep 300
		ControlSend,, {Up UP},ahk_id %active_id%
		OutputDebug moved!
		return true
	}else
	{
		return false
	}
}

/*
!+5:: 
gardening := false
gosub setStatus
return

!+4::
gardening := true
gosub setStatus
OutputDebug Debugging Garden bot
width := 816
height := 639
SendMode Input
checkWindow(active_id)
flower := 1
flowersComplete := 0
readyToPlant := false
moveIter := 0
Loop
{
	global gardening
	if(!gardening)
		break
	if(!readyToPlant)
	{
		if(movement(moveIter))
			{
			readyToPlant := true
			moveIter+=1
			}
			else
			{
			OutputDebug %moveIter%
			}
	}
	else
	{
		if(flowersComplete <= 10)
		{
			result := plant(flower)
			if(result == 1)
			{
				flowersComplete++
				flower++
				readyToPlant := false
			}else if(result == 0)
			{
			;fatal error
			Pause
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
				;click reset
				;redo loop
			}
		}else
		{
		break
		}
	}
}
global gardening := false
gosub setStatus
return
*/
NUMPAD1:: plant(1)
NUMPAD2:: plant(2)
NUMPAD3:: plant(3)
NUMPAD4:: plant(4)
NUMPAD5:: plant(5)