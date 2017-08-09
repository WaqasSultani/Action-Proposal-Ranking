function Calculate_opticalflow(Video_ID)
Video_ID=1;

 %Video_ID=str2num(Video_ID)

All_Videos_Path='../Data/DatasetName/Dataset_frames';
All_Optical_Path='../Data/DatasetName/Dataset/Opticalflow';

if ~exist(All_Optical_Path,'dir')

	mkdir(All_Optical_Path);
end

All_Videos_files=dir(All_Videos_Path);
All_Videos_files=All_Videos_files(3:end);


for ivideo=Video_ID
%1:ength(All_Videos_files)
     ivideo
    file_path=[All_Videos_Path,'/',All_Videos_files(ivideo).name]
    Op_file_Path=[All_Optical_Path,'/',All_Videos_files(ivideo).name];
    
%     if exist(Op_file_Path)
%        
%         continue
%     else
%        
%         mkdir(Op_file_Path)
%         
%     end
%   
    
        All_images=dir([file_path,'/*.jpg']);
        if length(All_images)==0
           
          
        All_images=dir([file_path,'/*.ppm']);
          
            
        end
%     All_images=dir([file_path);
    All_images=All_images(3:end);
    U_Mask=zeros(240,320,length(All_images)-1);
    V_Mask=zeros(240,320,length(All_images)-1);
    
    for Im=1:length(All_images)-1
        Im
        I1=imread([file_path,'/',All_images(Im).name]);
        I2=imread([file_path,'/',All_images(Im+1).name]);
        
        im1 = double(imresize(I1,[240,320]));
        im2 = double(imresize(I2,[240,320]));
        tic
        flow = mex_LDOF(im1,im2);
        u=flow(:,:,1);
        v=flow(:,:,2);
        U_Mask(:,:,Im)=u;
        V_Mask(:,:,Im)=v;
   
    end
        
        V_Mask=single(V_Mask);
        U_Mask=single(U_Mask);
        %ResultName=[Op_file_Path,'/',a];
        save(Op_file_Path,'U_Mask','V_Mask');
       % save(ResultName,'u','v');
      clear flow u v  U_Mask V_Mask
    end
    
    
    
  
end
