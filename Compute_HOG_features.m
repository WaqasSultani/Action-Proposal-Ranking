function  Compute_HOG_features 

% This HOG code is taken from 'http://www.di.ens.fr/willow/research/objectdiscovery
 ActionPath_Frames='../Data/DatasetName/Dataset_frames';
 ActionPath_HOG='../Data/DatasetName/Video_BBX_HOG_HMDB';
 BBX50MS_Path='../Data/DatasetName/BBX_MotionSalient';
  
 
 if ~exist(ActionPath_HOG,'dir')
     mkdir(ActionPath_HOG)
 end
  
 % compute HOG features
    szCell = 8;
    nX=8; nY=8;
    nDim = nX*nY*31;
    
    pixels = double([nY nX] * szCell);
    cropsize = ([nY nX]+2) * szCell;
    
    file_lda_bg_hog = 'bg11.mat';
%     hsfilter = fspecial3('gaussian', [5 5 5]);
    
        % HOG template
    hog_spec.ny = 8;
    hog_spec.nx = 8;
    hog_spec.nf = 31;
    ndim_hog = hog_spec.nx * hog_spec.ny * hog_spec.nf;

    % background HOG statistics
    load(file_lda_bg_hog); % variable "bg"
    [R, mu_bg] = whiten(bg, hog_spec.nx, hog_spec.ny);
    hog_spec.R = R; 
    hog_spec.mu_bg = mu_bg;

    
  AllFiles=dir(ActionPath_Frames);
  AllFiles=AllFiles(3:end);
 
  
 for ifile=1:150

     
           FramesFilePath=[ActionPath_Frames,'/', AllFiles(ifile).name];
           BBX50filePath=[BBX50MS_Path,'/', AllFiles(ifile).name];
           ResultFilePath=[ActionPath_HOG,'/', AllFiles(ifile).name];
   
           if exist( [ResultFilePath,'.mat'],'file')
               disp('FileExist')
               continue;
           else
              waqas=1;
             save( ResultFilePath,'waqas');  
           end
           
           
          load(BBX50filePath)
          nBBX=length(Top_Sc);
        
          % Load Video
        
        AllFrames=dir(FramesFilePath);
        AllFrames=AllFrames(3:end);
        
        Video=zeros(240,320,3,length(AllFrames));
        
        for iv=1:length(AllFrames)
            
           Video(:,:,:,iv)=imread([FramesFilePath,'/',AllFrames(iv).name]);
            
        end
        
        
        Proposal=struct;
      
        for ibbx=1:nBBX
               % tic 
             ibbx
           
            A1=Top_BBX(:,:,ibbx);
            BBX1=A1;
            frame_vec=find(A1(:,1))';
            frame_vec=frame_vec(1:1:end);
            nfr=length(frame_vec);
            hist_temp = zeros(nfr, nDim);
            
            gg=0;
            for ii=frame_vec
%size(BBX1,1)    
               
                col1=max(1,A1(ii,1));
                col1=min(col1,320);
                col2=min(320,A1(ii,1)+A1(ii,3));
                row1=max(1,A1(ii,2));
                row1=min(row1,240);                
                row2=min(240,A1(ii,2)+A1(ii,4));
                  
                padx = szCell * A1(ii,3)/ pixels(2);
                pady = szCell * A1(ii,4) / pixels(1);
                img=Video(:,:,:,ii);
%                 imshow(uint8(img));
%                 rectangle('Position',[col1, row1,A1(ii,3), A1(ii,4)])
%                 
              %  window = subarray(img, y1, y2, x1, x2, 1);
                window = subarray(img, row1, row2, col1, col2, 1);
                img_patch = imresize(window, cropsize, 'bilinear');
                
                hog = features(double(img_patch), szCell);
                hog_ = hog(:,:,1:end-1);
                gg=gg+1;
                hist_temp(gg,:) = hog_(:)';
                 hist_temp(gg,:)=cast( hist_temp(gg,:), 'single');
                clear hog;
                clear hog_;
  
            end
            
               hist_temp=hist_temp';
            
                desc_wht =  hist_temp - repmat(hog_spec.mu_bg, 1, size( hist_temp, 2));
                desc_wht = hog_spec.R \ (hog_spec.R' \ desc_wht);
                desc_wht = [desc_wht; (-desc_wht' * hog_spec.mu_bg)'];
                desc_wht =desc_wht';
               hog_feat=zeros(length(AllFrames), nDim+1);           
             
               gg=0;
               
               for ii=frame_vec
            
                   gg=gg+1;
                   hog_feat(ii,:)=desc_wht(gg,:);
                
               end
                
               
           Proposal(ibbx).HOG=single(hog_feat);
           Proposal(ibbx).BBX=BBX1;
          clear hog_feat BBX1
             
        end
        save( ResultFilePath,'Proposal','-v7.3');
        clear Proposal Top_BBX Top_Sc   desc_wht
        
 end
 
function B = subarray(A, i1, i2, j1, j2, pad)

% B = subarray(A, i1, i2, j1, j2, pad)
% Extract subarray from array
% pad with boundary values if pad = 1
% pad with zeros if pad = 0

dim = size(A);
%i1
%i2
is = i1:i2;
js = j1:j2;

if pad,
  is = max(is,1);
  js = max(js,1);
  is = min(is,dim(1));
  js = min(js,dim(2));
  B  = A(is,js,:);
else
  % todo
end
