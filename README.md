# Action-Proposal-Ranking
CVIU 2017
This folder contains demo code for our CVIU Paper, “Unsupervised Action Proposal Ranking through Proposal Recombination".

Since our code has several components, we have included separate files for each component; some of them can be run in parallel.
Please follow the following steps to run code files

1. Compute Action proposal in each video using any of the following code:
. https://github.com/jvgemert/apt 
. http://lear.inrialpes.fr/~oneata/3Dproposals/
. http://isis-data.science.uva.nl/cgmsnoek/pub/jain-tubelets-cvpr2014.pdf

2. Use "Calculate_opticalflow_flowMask.m"  to compute optical flow Mask in each frame of the video.
3. Use "Calculate_Motion_Score.m" to do Non_Maximal Suppression. 
4. To compute Motioness:
 4.1  After computing optical flow (as shown in "Calculate_opticalflow_flowMask or Calculate_opticalflow.m"), use edgeBoxesDemo_w in ../edge-master 
 
 4.2  Compute_Motioness.m

5. To train actioness classifier:

  5.1 Download the images provided at "http://crcv.ucf.edu/projects/videolocalization_images//#Code".

5.2 Use the code at "http://crcv.ucf.edu/projects/videolocalization_images//#Code" find action patches.  Once patches are found, use "save_Image_proposal_BBX_IM" to save top 3 patches from each image. After that, compute CNN features again on these patches using "Compute_CNN_Images" and remove noisy patches using "RandomWalk_NoisyImages".  Note that Compute_CNN_Images" and "RandomWalk_NoisyImages" are used twice; once for images and second for patches.

  5.3 Use "save_Video_proposal_BBX_IM_Neg.m" to save patches from low optical flow derivatives tubes in UCF-Sports dataset. These patches are used as negative examples to train actionness classifier. 

6.  Fine tune AlexNet using above positive and negative action images. Please see  "http://caffe.berkeleyvision.org/gathered/examples/finetune_flickr_style.html", to see the example code for Fine-Tuning.

7. After fine tunning AlexNet for actionness, use "Compute_Actioness_Caffe.m" to compute actionness of each patch of action proposal.
8. Use "Compute_HOG_features.m" to compute HOG features within each patch of action proposal. 
9. Use "Compute_ProposalPath_Recombination.m" to find final new proposals.

"We are still updating the code".

 
In case, you find some bug, could not understand any part of the code, or for other any comments, please drop me an email at waqas5163@gmail.com.


If you find this code useful in your research, please cite the following paper:

@article{SULTANI2017,
title = "Unsupervised action proposal ranking through proposal recombination",
journal = "Computer Vision and Image Understanding",
volume = "",
number = "",
pages = "",
year = "2017",
note = "",
issn = "1077-3142",
doi = "http://dx.doi.org/10.1016/j.cviu.2017.06.001",
url = "http://www.sciencedirect.com/science/article/pii/S1077314217301133",
author = "Waqas Sultani and Dong Zhang and Mubarak Shah",
keywords = "Action proposal ranking",
keywords = "Action recognition",
keywords = "Unsupervised method"
}

Thank you!
