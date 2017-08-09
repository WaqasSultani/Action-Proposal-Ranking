function save_Video_proposal_BBX_IM_Neg(Videos_frame_Path,Video_Motion_Path,Video_Proposal_Path,Neg_Video_Images_CNN)
% This function is to save low optical flow proposals BBX to fine tune.




if ~exist(Neg_Video_Images_CNN,'dir')
   mkdir(Neg_Video_Images_CNN)
end

 
% For UCF Sports we took negative from files before Walk_Front_005 for no
% reason

All_Files=dir(Videos_frame_Path);
All_Files=All_Files(3:end);
    ww=0;
for ifile=1:nfiles
    %length(All_Files)
    %Video_ID
        FilePath_BBX=[Video_Proposal_Path,'/',All_Files(ifile).name];
        FilePath_Mask=[Video_Motion_Path,'/',All_Files(ifile).name];
        FilePath_Result=[Neg_Video_Images_CNN ];
        FramePath=[Videos_frame_Path,'/',All_Files(ifile).name];
          
 
        
         All_images=dir([FramePath,'/*.jpg']);
         if length(All_images)==0
         
              All_images=dir([FramePath,'/*.png']);
         end
  
         if length(All_images)==0
         
              All_images=dir([FramePath,'/*.ppm']);
         end
        nFr=length(All_images);
        Image_Path=[FramePath,'/',All_images(10).name];
        I=imread(Image_Path);
       
        col_factor=size(I,2)/320;
        row_factor=size(I,1)/240;
        

        load(FilePath_BBX)
        BBX_Array=zeros(nFr,4,length(BBX));
        
        for ibbx=1:length(BBX)
           
            A1=round(BBX{ibbx})';
            A1=A1+1;
            
            BBX_Frames=A1(:,1)';
            
         for ii=1:nFr
                 
                      In_w=find(A1(:,1)==ii);
                     A=A1(In_w,2:end);
                    
                     if length(A)==0
                        continue; 
                     end
                     
                     A=[A(1) A(2) A(3)-A(1)+1,A(4)-A(2)+1];
                     A(1)=A(1)/col_factor;
                     A(2)=A(2)/row_factor;
                     A(3)=A(3)/col_factor;
                     A(4)=A(4)/row_factor;
                     A=round(A);
            
                     BBX_Array(ii,:,ibbx)=zero2one(A);
        
        end
        end
        
        load(FilePath_Mask);
        Score=zeros(size(BBX_Array,3),1);
       
        for ibbx=1:size(BBX_Array,3)
          
            B=BBX_Array(:,:,ibbx);
            C=find(B(:,1));
            mm=C';
            Average_of_Mask=zeros(1,length(mm));
            cc=0;
            
        for kk= mm
              cc=cc+1;
              D=round(B(kk,:));
              final_frame=min(kk,size(SM_Mask,3));

              x1=D(1);
              x2=min(D(1)+D(3),320);
              y1=D(2);
              y2=min(D(2)+D(4),240);

              MM=SM_Mask(y1:y2,x1:x2,final_frame);
           
              Area_xy=length(y1:y2)*length(x1:x2);
              Average_of_Mask(cc)=sum(sum(MM))/Area_xy; 
        end
        
         Score(ibbx,1)=sum(Average_of_Mask);
        end
        
        
        [Sc, Sc_Idx] = sort(Score(:,1),'descend');
         
        num=length(Sc_Idx)-round(length(Sc_Idx)*.01);
        
        Top_BBX=BBX_Array(:,:,Sc_Idx);
        Top_Sc=Score(Sc_Idx);
        
        Top_BBX=Top_BBX(:,:,num:end);
        Top_Sc=Top_Sc(num:end);
   
        
        for ibbx=1:2:size(Top_BBX,3)
            
            BBX_p=Top_BBX(:,:,1);
            
            frame_vec=find(BBX_p(:,1));
            frame_vec=frame_vec(1:8:end)';
            
            for v=frame_vec
                
                bbx=BBX_p(v,:);
                
                 x1=bbx(1);
                 x2=min(bbx(1)+bbx(3),320);
                 y1=bbx(2);
                 y2=min(bbx(2)+bbx(4),240);
                
                 
                Image_Path=[FramePath,'/',All_images(v).name];
                I=imread(Image_Path);
                
                sub_img=I(y1:y2,x1:x2,:);
                sub_img=imresize(sub_img,[256 256]);
                
                ww=ww+1;
                Results_ImagePath=[FilePath_Result,'/',sprintf('%.5d.jpg',ww)];
                fprintf('Saving negative image= %.4d\n', ww);
                imwrite(sub_img,Results_ImagePath);
                 
            end
             
            
            
        end
        
         
end
        
    