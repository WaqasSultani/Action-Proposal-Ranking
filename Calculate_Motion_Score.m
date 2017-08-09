function Calculate_Motion_Score(Video_ID)

%% 2. We perform Non-Maximal Suppression using optical flow derivatives to remove highly overlapped proposals
 
Videos_frame_Path='../Data/DatasetName/Dataset_frames';
Video_Proposal_Path='/Data/DatsetName/Dataset_Proposals';
Video_Motion_Path='../Data/DatasetName/Motion_Mask';
 
Motion_Salient_Proposals='../Data/DatasetName/BBX_MotionSalient';


if ~exist(Motion_Salient_Proposals,'dir')
   mkdir(Motion_Salient_Proposals)
end

 


All_Files=dir(Videos_frame_Path);
All_Files=All_Files(3:end);
    
for ifile=1:length(All_Files)
    
        FilePath_BBX=[Video_Proposal_Path,'/',All_Files(ifile).name];
        FilePath_Mask=[Video_Motion_Path,'/',All_Files(ifile).name];
        FilePath_Result=[Motion_Salient_Proposals,'/',All_Files(ifile).name];
        FramePath=[Videos_frame_Path,'/',All_Files(ifile).name];
          
          if exist([FilePath_Result,'.mat'],'file')
              disp('Motion Score FileExist....')
              
                continue
          else
              
                waqas=1;
              save(FilePath_Result,'waqas');
          
          end
         
        
        
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
            ibbx
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
            ibbx
            B=BBX_Array(:,:,ibbx);
            C=find(B(:,1));
            mm=C';
            Average_of_Mask=zeros(1,length(mm));
            cc=0;
            
        for kk= mm
              cc=cc+1;
              D=round(B(kk,:));
              final_frame=min(kk,size(SM_Mask,3));

              x1=min(D(1),320);
              x2=min(D(1)+D(3),320);
              y1=min(D(2),240);
              y2=min(D(2)+D(4),240);

              MM=SM_Mask(y1:y2,x1:x2,final_frame);
              Area_xy=length(y1:y2)*length(x1:x2);
              Average_of_Mask(cc)=sum(sum(MM))/Area_xy;
        end
        
         Score(ibbx,1)=sum(Average_of_Mask);
         
         if isnan(Score(ibbx,1))
         
         error('???')
         end
 
        end

        [Sc, Sc_Idx] = sort(Score(:,1),'descend');
        num=length(Sc_Idx)-round(length(Sc_Idx)*.05);
     
        % Remove very small optical flow score tubes as they might not
        % contain any action.
        
        Top_BBX=BBX_Array(:,:,Sc_Idx);
        Top_Sc=Score(Sc_Idx);
        
        Top_BBX=Top_BBX(:,:,1:num);
        Top_Sc=Top_Sc(1:num);
        
      
        
        
         B=Top_BBX;
                    Pairwise_BBX = zeros(size(B,3));
                    C=permute(B,[1 3 2]);
                    C=reshape(C,[],size(B,2),1);
                    sz=size(B(:,:,1),1);

                    C=zero2one(C);
                    B=zero2one(B);

                        for i = 1:size(B,3)
                        i
                            M =bboxOverlapRatio_w(zero2one(B(:,:,i)),C);
                            ti=1;
                           for j=1:1:size(B,3)

                                Pairwise_BBX(i,j)=sum(diag(M(:,ti:ti+sz-1)))/sz;
                                ti=ti+sz;
                           end
                        end
        
                        
         %After Non-maximal suppression Keep maximum of 60% (randomly selected) original proposals 
         Max_Proposals=length(Top_Sc)-round(length(Top_Sc)*.40);
         
               
   %%  Non-maximal suppression     
       
        ov_th=0.85;
        TT=0;
        num=0;
        while (num<Max_Proposals)
            
            TT=TT+1;
            if TT>1
                 break;
            end
            num = 0;
            dets=zeros(length(Top_Sc),2);
            for i = 1:length(Top_Sc)
                i
                if i==1
                    num = num + 1;
                    dets(num,1) = i;
                    dets(num,2)=Top_Sc(i);

                else
                    flag = 0;
                    for j = 1:num
                        try
                        overlap = Pairwise_BBX(j,i);
                        catch
                           keyboard 
                        end

                        if overlap >ov_th(TT)
                            flag = 1;
                            break;
                        end
                    end
                    if flag == 0
                        num = num + 1;
                        dets(num,1) = i;
                        dets(num,2)=Top_Sc(i);

                        if num>Max_Proposals
                            break;
                        end
                    end
                end
            end
        
        
        end
         
          
        if num<Max_Proposals
            
            Final_idx1=dets(1:num,1);
            Final_Score1=dets(1:num,2);  
        else
            Final_idx1=dets(1:Max_Proposals,1);
            Final_Score1=dets(1:Max_Proposals,2);
        end
        
        
        Top_BBX=Top_BBX(:,: ,Final_idx1);
        Top_Sc=Final_Score1;
        save(FilePath_Result,'Top_BBX','Top_Sc');
        clear Top_BBX Top_Sc
        
    end

        
        
    
