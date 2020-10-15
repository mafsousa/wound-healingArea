# wound-healingArea

## Description
healingArea is an ImageJ macro for image analysis, that measures wound-healing areas, capable of illustrating the evolution of the healing along time. This tool was specifically developed to measure wound area on images acquired in widefield inverted microscopes or inCell assays. It includes simple user interface to select main parameters of background subtraction, filters and threshold segmentation .

Wound-healing assay example:

![picture alt](https://github.com/mafsousa/wound-healingArea/blob/main/example.png)

## How it works
This macro works on opened images or ask for opening. A preprocessing step consists in removing background and apllying a Gaussian fiter, where the user can specify radius and sigma valures, respectively. Wound area is segmented by automatic threshold using user selection algorithm. Finally, the waound area is calculated for each frame. Some user-friendly dialogs are available to perform multiple options during the workflow execution. The output result combines the results table and the plot result along time; Complementary, the ROIs are saved for quality control. Note that while wound-healingArea is easy to use and semi-automatized, it only works efficiently in images with normalized intensities along time.
	
## Input:
  2D/3D grey-scaled images 

## Output: 
  plot and results table with wound area for each time frame 
  
## License 
This macro should NOT be redistributed without author's permission. 
Explicit acknowledgement to the ALM facility should be done in case of published articles 
(approved in C.E. 7/17/2017):     
 
"The authors acknowledge the support of i3S Scientific Platform Advanced Light Microscopy, 
member of the national infrastructure PPBI-Portuguese Platform of BioImaging 
(supported by POCI-01-0145-FEDER-022122)."
 
Date: October/2020
Author: Mafalda Sousa, mafsousa@ibmc.up.pt
Advanced Ligth Microscopy, I3S 
PPBI-Portuguese Platform of BioImaging
