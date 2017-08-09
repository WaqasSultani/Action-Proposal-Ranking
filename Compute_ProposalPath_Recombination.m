 function  Compute_ProposalPath_Recombination
 %% This file is to compute final new proposals.
 
 All_HOG_Features_s='../Data/DatasetName/Video_BBX_HOG';
 Motion_Salient_Proposals_s='../Data/DatasetName/BBX_MotionSalient';
 Motioness_path_s='../Data/DatasetName/Motionness';
 Actionness_Path_s='../Data/DatasetName/Actionness_BBX';
 AllResultPath='../Data/DatasetName/ProposalPath_Recombination';
  
for it=4

AllBBX50MS_Path=Motion_Salient_Proposals_s;
Result_Path=[AllResultPath,'/',sprintf('Sub_%.3d',it)];
All_HOG_Features=All_HOG_Features_s;
ActionessPath=  Actionness_Path_s;
MotionessPath=Motioness_path_s;

if ~exist(Result_Path,'dir')
   
    mkdir(Result_Path);
    
end

 
 AllFiles=dir(ActionessPath);
 AllFiles=AllFiles(3:end);
sim=[];
 for ifile=1:length(AllFiles)
     
        BBX50MS_Path=[AllBBX50MS_Path,'/', AllFiles(ifile).name];
        Video_HOG=[All_HOG_Features,'/', AllFiles(ifile).name];
        Result_Video=[Result_Path,'/', AllFiles(ifile).name];
        Actioness_file=[ActionessPath,'/', AllFiles(ifile).name];
        Motioness_file=[MotionessPath,'/', AllFiles(ifile).name];
        
          if exist(Result_Video,'file')
               continue    
          else
              
          end
        clear Proposal Top_BBX Top_Sc Alex_scores Motion_Score
   
        load(Video_HOG)
        load(BBX50MS_Path)
        load(Actioness_file)
        load(Motioness_file)
        
        nProp_O=length(Proposal);
 
        Vi_Div =it;
        
        Video_length=size(Top_BBX,1);
        vec=round(linspace(1, Video_length,Vi_Div+1));
       
        Input_Proposal_Num=nProp_O;
       % rand_idx=randperm(nProp_O,Input_Proposal_Num);
       % rand_idx=sort(rand_idx);
        nProp=nProp_O;
       % Motion 
        Motion_Score= Motion_Score;%(:,rand_idx)';
       % Action
        Action_Score= Alex_scores;%(rand_idx,:);
 
       U_M=zeros(size(Motion_Score,1),Vi_Div);
       A_M=zeros(size(Motion_Score,1),Vi_Div);
    
       % Unary weights
         gg=0;
        for ii=1:length(vec)-1
              aa=vec(ii);
              bb=vec(ii+1)-1;
            
             if ii==length(vec)-1
                 bb=vec(ii+1);
             end
            gg=gg+1; 
            Sub_Alex=Action_Score(:,aa:bb);
            temp1=sum(Sub_Alex,2)/length(aa:bb);
            temp1=(temp1-min(temp1))/(max(temp1)-min(temp1));
            if all(isnan(temp1))==1
                 temp1=zeros(nProp,1);
             end
            U_M(:,gg)=temp1;
            Sub_Mot=Motion_Score(:,aa:bb);
            temp2=sum(Sub_Mot,2)/length(aa:bb);
            temp2=(temp2-min(temp2))/(max(temp2)-min(temp2));
            
            if all(isnan(temp2))==1
                
                temp2=zeros(nProp,1);
                
            end
            A_M(:,gg)=temp2;
        end
        
        Unary_weights=U_M+A_M;
       % Overlaps
       
        Overlape_Mat=zeros(nProp_O,nProp_O,Vi_Div-1);
        gg=0;
        for ii=2:length(vec)-1
              
              aa=vec(ii);
              Sub_BBX_temp=[Proposal.BBX]';
              Sub_BBX_temp=Sub_BBX_temp(:,aa);
              Sub_BBX_temp1=reshape(Sub_BBX_temp,[4,nProp_O])';
              Sub_BBX_temp1=zero2one(Sub_BBX_temp1);
               
              
              bb=vec(ii)+1;
              Sub_BBX_temp=[Proposal.BBX]';
              Sub_BBX_temp=Sub_BBX_temp(:,bb);
              Sub_BBX_temp2=reshape(Sub_BBX_temp,[4,nProp_O])';
              Sub_BBX_temp2=zero2one(Sub_BBX_temp2);
               
              
              gg=gg+1;
              Overlape_Mat(:,:,gg) =bboxOverlapRatio( Sub_BBX_temp1,Sub_BBX_temp2);
        end 
             
         Overlape_Mat(Overlape_Mat<.2)=-Inf;
         Overlape_Mat(Overlape_Mat>-Inf)=1;
         
        % HOG Distance Matrices
        HOG_Mat=zeros(nProp_O,1985,Vi_Div);
        gg=0;
        
        
         Sub_HOG_temp=[Proposal.HOG]';
        for ii=1:length(vec)-1
        
              aa=vec(ii);
              bb=vec(ii+1)-1;
            
             if ii==length(vec)-1
                 bb=vec(ii+1);
             end
            
           
             Sub_HOG_temp1=Sub_HOG_temp(:,aa:bb);
             m_row=size(Proposal(1).HOG(aa:bb,:),2);
             n_matrices=nProp_O;
             ll=length(aa:bb);
             p_column=ll;
             
             Sub_HOG=reshape(permute(reshape(Sub_HOG_temp1',p_column,m_row,n_matrices),[2  1 3]),m_row,n_matrices*p_column);
             Sub_HOG_mat=zeros(nProp_O,1985);
             
             for ip=1:nProp_O
            
                   cc=(ip-1)*ll+1;
                   dd=ip*ll;
                   temp1=Sub_HOG(:,cc:dd);
                   temp1=mean(temp1,2);  
                   Sub_HOG_mat(ip,:)= temp1';

             end
             
              gg=gg+1;
              
               
               Sub_HOG_mat = Sub_HOG_mat ./ (repmat(sqrt(sum(Sub_HOG_mat.^2,2)), 1, size(Sub_HOG_mat,2)) + eps);
               HOG_Mat(:,:,gg)=Sub_HOG_mat;
        
        end
        

        HOG_Dist=zeros(nProp_O,nProp_O,gg-1);
         
        for jj=1:gg-1
            
            dist=distance(HOG_Mat(:,:,jj)',HOG_Mat(:,:,jj+1)');   
            dist=exp(-dist);
            HOG_Dist(:,:,jj)=dist;
        
        end
        
        Binary_Weights=Overlape_Mat.*HOG_Dist;
        Binary_Weights_Samp=zeros(nProp,nProp,gg-1);
         
        
         for jj=1:gg-1
            
            Binary_Weights_Samp(:,:,jj)=Binary_Weights(:,:,jj);
         end 
        
         
        TotalPath_num=min(10,nProp);
    
   
   [nodes_selected path_weight] = DP_branch_MultiPaths_Dong(Unary_weights,Binary_Weights, TotalPath_num);

    
    for ip=1:TotalPath_num
       
        Results_BBX=[];
         gg=0;
        for ii=1:length(vec)-1
        
              aa=vec(ii);
              bb=vec(ii+1)-1;
        
              gg=gg+1;
              Idx_p=nodes_selected(ip,gg);
             %Idx_p=rand_idx(Idx_p);
              dummy=Proposal(Idx_p).BBX(aa:bb,:);
              dumm1=sum(dummy,2);
          
            if dumm1(end)==0
                
               dummy(end,:)=dummy(end-1,:); 
            end
        
        Results_BBX(aa:bb,:)=dummy;
       end
       Mul_BBX(ip).BBX= Results_BBX;
         
    end
    
    kk=0;
    for ii=1:nProp
    
    kk=kk+1;
             dummy=Proposal(ii).BBX;
             dumm1=sum(dummy,2);
          
            if dumm1(end)==0
               dummy(end,:)=dummy(end-1,:); 
            end
         Mul_BBX(kk).Prop=dummy;
        
    end
    
    save(Result_Video,'Mul_BBX')
    
    clear Mul_BBX Alex_scores Motion_Score Proposal Top_BBX  Top_Sc nodes_selected path_weight Unary_weights Binary_Weights  TotalPath_num
    clear Sub_HOG_temp1 Sub_HOG_temp2 Sub_BBX_temp1 Sub_BBX_temp2
    
 end
  
end    
        
       
