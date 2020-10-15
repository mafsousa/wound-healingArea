//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// FRETratiometrics //////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////Author: Mafalda Sousa, mafsousa@ibmc.up.pt ////////////////////////////////////////
/////////////////////////// ALM - I3S ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

/* Title: Wound healing 
* v1.0
* 
* Short description: Identify wound-healing area along time or for one frame
	* * Preprocessing steps: Remove background, gaussian blur 
	* * Apply automatic threshold
	* * Post-processing: Fill holes and define ROI minimum area
	* * Measure area of each Roi;
	
* Input 2D/3D grey-scaled images 

* Output: plot and results table with wound area for each time frame 
*  
* This macro should NOT be redistributed without author's permission. 
* Explicit acknowledgement to the ALM facility should be done in case of published articles 
* (approved in C.E. 7/17/2017):     
* 
* "The authors acknowledge the support of i3S Scientific Platform Advanced Light Microscopy, 
* member of the national infrastructure PPBI-Portuguese Platform of BioImaging 
* (supported by POCI-01-0145-FEDER-022122)."
* 
* Date: October/2020
* Author: Mafalda Sousa, mafsousa@ibmc.up.pt
* Advanced Ligth Microscopy, I3S 
* PPBI-Portuguese Platform of BioImaging
*/



roiManager("reset");

//check if there's images opened
list = getList("image.titles");
Array.print(list);
if (list.length == 0) {
   	input_dir = getDirectory("image");
   	open(input_dir);
}
else{
	image_title = getTitle();
	dotIndex = lastIndexOf(image_title, ".");
   	title = substring(image_title, 0, dotIndex); 
   	//check correct input: at least 2 channels
   	getDimensions(width, height, channels, slices, frames);
   	input_dir = getDirectory("image");
}
//define output directory
output_dir = input_dir+File.separator+"Result";
if(!File.exists(output_dir)){
	File.makeDirectory(output_dir);
}

//Reduce image size for better computer performance
getDimensions(width, height, channels, slices, frames);
if(frames == 1 && slices > 1){
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=1 frames=" + slices + " display=Color");
	frames = slices;
}
w = getWidth();	
h = getHeight();
resetMinAndMax;
run("8-bit");
run("Scale...", "x=0.5 y=0.5 z=1.0 width=" + w +" height="+ h +" depth="+ frames + " interpolation=Bilinear average process create");

//scaled dimensions
getDimensions(width, height, channels, slices, frames);
getPixelSize(unit, pixelWidth, pixelHeight);
Stack.getUnits(X, Y, Z, Time, Value);


//calculate the minimum wound area
min_area = (width * pixelWidth * height *  pixelHeight)/10;
print("Minimum wound area", min_area);


img = getTitle();		//original image	
Satisfied = false;
while (Satisfied==false){ 
	Dialog.create("Algorithm parameters");
	Dialog.addMessage("Select algorithm parameters");
	Dialog.addNumber("Gaussian sigma", 3);
	Dialog.addNumber("Backgroung radius", 10);
	items = newArray("Minimum","Otsu","Li","MaxEntropy","Default");
	Dialog.addChoice("Threshold algorithm", items);
	Dialog.show();
	sigma = Dialog.getNumber();
	radius = Dialog.getNumber();
	thres = Dialog.getChoice();
	selectWindow(img);
	run("Duplicate...", "duplicate");
		
	//Remove background and gaussian blur for segmentation
	run("Subtract Background...", "rolling="+ radius + " light stack");
	run("Gaussian Blur...", "sigma=" + sigma +" stack");
	rename("Processed");
	
	//Segmentation
	setAutoThreshold("Minimum dark");
	run("Convert to Mask", "method=" + thres + " background=Dark");
	
	//Post-processing
	run("Fill Holes", "stack");	
	
	//Find wound countours
	run("Set Measurements...", "area stack redirect=None decimal=3");

	//adjust minimim size for your particular case
	run("Analyze Particles...", "size="+ min_area + "-Infinity show=Masks display clear include add stack");
	for (i = 0; i < nResults(); i++) {
		setResult("Units", i, unit + "^2");
	}
	updateResults();
	rename("Mask");

	///Satisfied?
	waitForUser("Check wound detection", "Check the quality of wound detection\nThen click OK.");
	Dialog.create("Satisfied with wound detection?");
	Dialog.addMessage("If you are not satisfied, do not tick the box and just click Ok.\nThis will take you back to the previous step for the selection of the parametrer.\nOtherwise tick the box and click OK to proceed to the next step.");
	Dialog.addCheckbox("Satisfied?", false);
	Dialog.show();
	Satisfied = Dialog.getCheckbox();
	wait(1000);
	
	if (Satisfied == false){
		selectWindow(img);
		close("\\Others");
	}
}

if(frames > 1 ){
	//PLot results
	xValues = newArray(nResults);
	yValues = newArray(nResults);
	if(Stack.getFrameInterval()==0){
		Dialog.create("Frame interval");
    	Dialog.addMessage("Specify the frame interval!");
    	Dialog.addNumber("Frame interval", 10);
    	Dialog.addChoice("Units", newArray("sec","min","hours"),"hours");
    	Dialog.show();
    	rate = Dialog.getNumber();
    	Time = Dialog.getChoice();
	}else {
		rate = Stack.getFrameInterval();
	}
	for (i = 0; i < nResults; i++) {
		xValues[i] = (i+1)*rate;
		yValues[i] = getResult("Area", i);
	}
	
	
	Plot.create("Wound-healing", "Time "+ Time , "Area " + unit +"^2", xValues, yValues);
}

//Save Results
name = substring(img, 0,indexOf(img, "."));
roiManager("deselect");
roiManager("Save", output_dir + File.separator + name + "_Roi.roi");
selectWindow("Results");
saveAs("Results", output_dir + File.separator + name + ".xls");
selectWindow("Processed");
close();
selectWindow(img);
//saveAs("tif", output_dir + File.separator + name + ".tif");
roiManager("select", 0); //to preview


