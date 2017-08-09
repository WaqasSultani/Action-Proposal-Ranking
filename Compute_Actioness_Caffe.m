function Compute_Actioness_Caffe
 
Videos_frame_Path='../Data/DatasetName/Dataset_frames';
Actionness_Path_s='../Data/DatasetName/Actionness_BBX';
Motion_Salient_Proposals_s='../Data/DatasetName/BBX_MotionSalient';

AllBBX50MS_Path=Motion_Salient_Proposals_s;
Result_Path=Actionness_Path_s;
if ~exist(Result_Path,'dir')
   
    mkdir(Result_Path);
    
end
  
d = load('/home/student/Downloads/caffe-master/matlab/+caffe/imagenet/ilsvrc_2012_mean.mat');
addpath(genpath('/home/student/Downloads/caffe-master/matlab/'));
addpath(genpath('/usr/local/cuda-7.5/lib64'))
addpath(genpath('/usr/local/cuda-7.5/bin'))

% caffe.set_mode_cpu();
caffe.set_mode_gpu();
% gpu_id = 1;  % we will use the first gpu in this demo
% caffe.set_device(gpu_id);
% Initialize the network using BVLC CaffeNet for image classification
% Weights (parameter) file needs to be downloaded from Model Zoo.
model_dir = '/home/student/Downloads/caffe-master/models/Actioness_r/';
net_model = [model_dir 'deploy.prototxt'];
net_weights = [model_dir 'Actioness_iter_40000.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please download CaffeNet from Model Zoo before you run this demo');
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);
mean_data = d.mean_data;
IMAGE_DIM = 256;
CROPPED_DIM = 227;
 AllFiles=dir(AllBBX50MS_Path);
 AllFiles=AllFiles(3:end);

nfiles=length(AllFiles);

 for  ifile= nfiles:-1:1
  
     
        BBX50MS_Path=[AllBBX50MS_Path,'/', AllFiles(ifile).name];
        FramePath=[Videos_frame_Path,'/',AllFiles(ifile).name(1:end-4)];
        Result_Video=[Result_Path,'/', AllFiles(ifile).name];
 
       if exist(Result_Video,'file')
            
           continue;
        else
            
           waqas=1;
             save(Result_Video,'waqas');
       end
       
       
       All_images=dir([FramePath,'/*.jpg']);
        nFr=length(All_images);
        
        if nFr==0

            All_images=dir([FramePath,'/*.ppm']);
            nFr=length(All_images);
        
        end     
        
        if nFr==0
            
            All_images=dir([FramePath,'/*.png']);
            nFr=length(All_images);
        
        end     
        

Videos_frames=zeros(240,320,3,nFr);

for iv=1:nFr
    
    I=imread([FramePath,'/',All_images(iv).name]);
    Videos_frames(:,:,:,iv)=imresize(I,[240 320]);
    
end

        load(BBX50MS_Path)
        nProp=size(Top_BBX,3);
        Alex_scores=zeros(nProp,nFr);     
       

        for ip=1:nProp
            ip
  
                 BBX=Top_BBX(:,:,ip);
                 frame_vec=find(BBX(:,1))';
                 crops_data = zeros(CROPPED_DIM, CROPPED_DIM, 3, length(frame_vec), 'single');
                 gg=0;
 
                 for ibbx=frame_vec
 
                  c1=max(BBX(ibbx,1),1);  
                  c1=min(c1,320);
                  r1=max(1,BBX(ibbx,2));
                  r1=min(r1,240);
                  c2=min(BBX(ibbx,1)+BBX(ibbx,3)+1,320);
                  r2=min(BBX(ibbx,2)+BBX(ibbx,4)+1,240);
                  
                  sub_im=Videos_frames(r1:r2,c1:c2,:,ibbx);
%                   figure(1)
                  gg=gg+1;
%                   subplot(3,5,gg); imshow(uint8(sub_im))
                  
                  
                  im_data = sub_im(:, :, [3, 2, 1]);
%   % flip width and height to make width the fastest dimension
                  im_data = permute(im_data, [2, 1, 3]);
%   % convert from uint8 to single
                  im_data = single(im_data);
%   % reshape to a fixed size (e.g., 227x227).
                  im_data = imresize(im_data, [IMAGE_DIM IMAGE_DIM], 'bilinear');
%   % subtract mean_data (already in W x H x C with BGR channels)
              

                  im_data = im_data - mean_data;  
                  
                  indices = [0 IMAGE_DIM-CROPPED_DIM] + 1;
                  center = floor(indices(2) / 2) + 1;

                  crops_data(:,:,:,gg) = im_data(center:center+CROPPED_DIM-1,center:center+CROPPED_DIM-1,:);

                end




% if nargin < 1
%   % For demo purposes we will use the cat image
%   fprintf('using caffe/examples/images/cat.jpg as input image\n');
%   im = imread('../../examples/images/cat.jpg');
% end

% prepare oversampled input
% input_data is Height x Width x Channel x Num
 
input_data = {crops_data};
 

% do forward pass to get scores
% scores are now Channels x Num, where Channels == 1000

% The net forward function. It takes in a cell array of N-D arrays
% (where N == 4 here) containing data of input blob(s) and outputs a cell
% array containing data from output blob(s)
net.blobs('data').reshape([227 227 3 gg]); % reshape blob 'data'
net.reshape()

scores = net.forward(input_data);

% pool5_feat = net.blobs('pool5').get_data();
scores = scores{1};
Temp_score=scores(2,:);

 Temp_score=Temp_score(1:length(frame_vec));    
             
 gg=0;
               
  for ii=frame_vec
 
      gg=gg+1;
      Alex_scores(ip,ii)=Temp_score(gg);
                
  end
       
  clear scores Temp_score input_data crops_data
 
        end
        
     save(Result_Video,'Alex_scores');  
     clear Top_BBX  input_data crops_data BBX  Alex_scores nProp
  end
 

% 
% % ------------------------------------------------------------------------
% function crops_data = prepare_image(im)
% % ------------------------------------------------------------------------
% % caffe/matlab/+caffe/imagenet/ilsvrc_2012_mean.mat contains mean_data that
% % is already in W x H x C with BGR channels
% d = load('../+caffe/imagenet/ilsvrc_2012_mean.mat');
% mean_data = d.mean_data;
% IMAGE_DIM = 256;
% CROPPED_DIM = 227;
% 
% % Convert an image returned by Matlab's imread to im_data in caffe's data
% % format: W x H x C with BGR channels
% im_data = im(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
% im_data = permute(im_data, [2, 1, 3]);  % flip width and height
% im_data = single(im_data);  % convert from uint8 to single
% im_data = imresize(im_data, [IMAGE_DIM IMAGE_DIM], 'bilinear');  % resize im_data
% im_data = im_data - mean_data;  % subtract mean_data (already in W x H x C, BGR)
% 
% % oversample (4 corners, center, and their x-axis flips)
% crops_data = zeros(CROPPED_DIM, CROPPED_DIM, 3, 10, 'single');
% indices = [0 IMAGE_DIM-CROPPED_DIM] + 1;
% n = 1;
% for i = indices
%   for j = indices
%     crops_data(:, :, :, n) = im_data(i:i+CROPPED_DIM-1, j:j+CROPPED_DIM-1, :);
%     crops_data(:, :, :, n+5) = crops_data(end:-1:1, :, :, n);
%     n = n + 1;
%   end
% end
% center = floor(indices(2) / 2) + 1;
% crops_data(:,:,:,5) = ...
%   im_data(center:center+CROPPED_DIM-1,center:center+CROPPED_DIM-1,:);
% crops_data(:,:,:,10) = crops_data(end:-1:1, :, :, 5);
