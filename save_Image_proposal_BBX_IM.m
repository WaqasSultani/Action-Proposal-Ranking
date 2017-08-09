function save_Image_proposal_BBX_IM(Image_Dataset_Path,Coloc_Result_Path,Coloc_Data_Path,Pos_Images_CNN)

% save_Image_proposal_BBX_IM is to save Original images fine Tune CNN 
% Please see "http://crcv.ucf.edu/projects/videolocalization_images//#Code"
% for complete code.

addpath(genpath('../Code/UODL_v1_modified'));

if ~exist(Pos_Images_CNN,'dir')
    mkdir(Pos_Images_CNN)
end

All_Actions=dir(Coloc_Result_Path);
All_Actions=All_Actions(3:end);
cc=0;
for iAction=11: length(All_Actions)
    
    Coloc_Res=[Coloc_Result_Path,'/',All_Actions(iAction).name];
    Data_Path=[Coloc_Data_Path,'/',All_Actions(iAction).name];
    Coloc_BBX=[Pos_Images_CNN,'/',All_Actions(iAction).name];
    Action_Image_Path=[Image_Dataset_Path,'/',All_Actions(iAction).name];
    Allimages=dir([Action_Image_Path,'/*.png']);
    
    
    if ~exist([Coloc_BBX],'file')
          mkdir([Coloc_BBX])
     end
    
    
    gists=dir([Data_Path,'/*_gist.mat']);

 
    nimage=length(gists);

for im = 1:nimage
  
	fprintf('Images: %d / %d\n', im, nimage);
  
    ImagePath=[Action_Image_Path,'/',Allimages(im).name];
    I=imread(ImagePath);
    
    
    conf.postfix_feat='_seg';
    conf.postfix_gist='_gist';
	idata   = loadView_seg([Data_Path,'/',gists(im).name(1:end-5)], 'conf', conf);
	boxes  = frame2box(idata.frame)';
	
    load(fullfile( Coloc_Res,  sprintf('sai_%03s_i%02d.mat',gists(im).name(1:end-9),5)))
    [ ranki, saliv ] = select_kbestbox(boxes', saliency, 5);
    
    for i=1:min(3,length(saliv))
     
          A1 = boxes(ranki(i), :);
          xmin=A1(1);
          xmax=A1(3);
          ymin=A1(2);
          ymax=A1(4);
          
          sub_img=I(ymin:ymax,xmin:xmax,:);
          cc=cc+1;
          Results_ImagePath=[Coloc_BBX,'/',sprintf('%.5d.jpg',cc)];
          
          imwrite(sub_img,Results_ImagePath);
          
          % Misu Draw box = [xmin, ymin, xmax, ymax]
         % imshow(sub_img)
        % bbox(i,:)=[A1(1), A1(2), A1(3)-A1(1),A1(4)-A1(2)];
    end
    

end


end





