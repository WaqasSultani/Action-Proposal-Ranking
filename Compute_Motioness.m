function  Compute_Motioness 
 
Ref_Path='../Data/DatasetName/BBX_MotionSalient';
AllBBX50MS_Path='../Data/DatasetName/BBX_MotionSalient';
EdgeBoxPath='../Data/DatasetName/EdgeBoxesFramewise';
Result_Path='../Data/DatasetName/Motionness';
 

if ~exist(Result_Path,'dir')
     mkdir(Result_Path);
 end

 AllFiles=dir(Ref_Path);
 AllFiles=AllFiles(3:end);

 for ifile= 1:length(AllFiles)
 
         BBX50MS_Path=[AllBBX50MS_Path,'/', AllFiles(ifile).name];
         Result_Video=[Result_Path,'/', AllFiles(ifile).name];
         EdgeBoxFile=[EdgeBoxPath,'/', AllFiles(ifile).name];
        
         if exist(Result_Video,'dir')
               continue;
         else
             
         end
         
         load(BBX50MS_Path)
         load(EdgeBoxFile)
        
         nProp=size(Top_BBX,3); 
         Motion_Score=zeros(size(Top_BBX,1),nProp);
       
         for p=1:nProp  
               p 
                P_BBX=Top_BBX(:,:,p);
                P_BBX=zero2one(P_BBX);
                frame_vec=find(P_BBX(:,1))';
                id=find(frame_vec==size(P_BBX,1));
                frame_vec(id)=[];   
                scores=zeros(size(P_BBX,1),1);

             for im=frame_vec
                    bbxs=Boxes{im};
                    if bbxs==0
                         scores(im)=0;
                    else
                        Sc=bbxs(:,end);
                        bbx=bbxs(:,1:4);
                        M =bboxOverlapRatio_w(P_BBX(im,:),bbx);
                        [ov,idx]=max(M);

                     if ov>0.5
                         scores(im)= Sc(idx(1));   
                     else
                        scores(im)=0;
                     end
                    end
             end
             
            Motion_Score(:,p)=scores;
          
            clear scores
          end

        save(Result_Video,'Motion_Score');
       clear Top_BBX Top_Sc P_BBX Motion_Score Boxes
 end