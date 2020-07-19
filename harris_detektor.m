 function merkmale = harris_detektor(input_image, varargin)
    %% Input parser
    %HA1.3+HA1.7
    default_segment_length=15;
    default_k=0.05;
    default_tau=10^6;
    default_do_plot=false;
    default_min_dist=20;
    default_tile_size=[200,200];
    default_N=5;
    
    validationFcn_segment_length=@(x) isnumeric(x) && (mod(x,2)==1) && (x > 1);
    validationFcn_k=@(x) isnumeric(x) && (x>=0) && (x<= 1);
    validationFcn_tau=@(x) isnumeric(x) && (x>0);
    validationFcn_do_plot=@(x) islogical(x);
    validationFcn_min_dist=@(x) isnumeric(x) && x>=1;
    validationFcn_tile_size=@(x) isnumeric(x);  
    validationFcn_N=@(x) isnumeric(x) && x>=1;
    
    p = inputParser;
    
    addParameter(p,'segment_length',default_segment_length,validationFcn_segment_length);
    addParameter(p,'k',default_k,validationFcn_k);
    addParameter(p,'tau',default_tau,validationFcn_tau);
    addParameter(p,'do_plot',default_do_plot,validationFcn_do_plot);
    addParameter(p,'min_dist',default_min_dist,validationFcn_min_dist);
    addParameter(p,'tile_size',default_tile_size,validationFcn_tile_size);
    addParameter(p,'N',default_N,validationFcn_N);
    
    parse(p,varargin{:});
    segment_length=p.Results.segment_length;
    k=p.Results.k;
    tau=p.Results.tau;
    do_plot=p.Results.do_plot;
    min_dist=p.Results.min_dist;
    if length(p.Results.tile_size)==2
        tile_size=p.Results.tile_size;
    else tile_size=[p.Results.tile_size,p.Results.tile_size];
    end
    N=p.Results.N;
    
    
    %% Vorbereitung zur Feature Detektion
    %HA1.4
   
    % Pruefe ob es sich um ein Grauwertbild handelt   
    if numel(size(input_image))~=2
        error('Image format has to be NxMx1');
    end

    % Approximation des Bildgradienten
    [Ix, Iy] = sobel_xy(double(input_image));
    
    % Gewichtung
%     w=fspecial('gaussian',[segment_length 1],segment_length/5);
%     W=w*w';

    W = guassian_filter(segment_length, segment_length/5);


    % Harris Matrix G
    Ix2 = Ix.^2;
    Iy2 = Iy.^2;
    IxIy = Ix.*Iy;
    
    G11=filter2(W,Ix2);
    G22=filter2(W,Iy2);
    G12=filter2(W,IxIy);
    
    %% Merkmalsextraktion ueber die Harrismessung
    % HA1.5

    merkmale = {0, 0, 0};
    [height,width]=size(input_image);
    corners=zeros(height,width);
    
    % obtain the Harris matrix by calculating the Harris value of each pixel
    for i=1:height
        for j=1:width
            M=[G11(i,j) G12(i,j);G12(i,j) G22(i,j)];
            H(i,j)=det(M)-k*(trace(M))^2;
        end
    end
    corners=H;
    
    % dealing with the edge of the corner matrix
    % eliminate all pixels which are at the edge
    rand=ceil(segment_length/2);
    corners(1:rand,:)=0;
    corners(height-rand+1:height,:)=0;
    corners(:,1:rand)=0;
    corners(:,width-rand+1:width)=0;
    
    % eliminate the pixels whose vaule is smaller than threshold 'tau'
    corners(corners<tau)=0;
    
    % extract the index of the corner pixel, convert them into x/y coordinate form
    [y1,x1]=find(corners);
    

    %% Merkmalsvorbereitung
    % HA1.9
    
    [height,width]=size(corners);
    
    %add zero edge to corner matrix
    left=zeros(height,min_dist);
    right=zeros(height,min_dist);
    top=zeros(min_dist,width+min_dist*2);
    bottom=zeros(min_dist,width+min_dist*2);
    b=[left corners right];
    c=[top;b;bottom];
    corners=c;
    
    % extract the index of non-zero pixel    
    index=find(corners);
    for i=1:length(index)
        intensity(i)=corners(index(i));
    end
    
    % sort these pixels in descend order according to the intensity
    % store the corresponding index in sorted_index
    [sorted_intensity new_index]=sort(intensity,'descend');
    sorted_index=zeros(length(index),1);
    for i=1:length(index)
        sorted_index(i)=index(new_index(i));
    end
    
    %% Akkumulatorfeld
    % HA1.10
    [height,width]=size(H);
    tile_height=tile_size(1);
    tile_width=tile_size(2);
    akku_num1=ceil(height/tile_height);
    akku_num2=ceil(width/tile_width);
    AKKA=zeros(akku_num1,akku_num2);
    
   %% Merkmalsbestimmung mit Mindestabstand und Maximalzahl pro Kachel   
   % HA1.11
    [num1,num2]=size(AKKA);
    Cake=cake(min_dist);
    
    % the center pixel of Cake matrix should be 1 
    Cake(min_dist+1,min_dist+1)=1;
    
    [height width]=size(corners);
    
    % recall that the index of the strongest pixels are stored in sorted_index in order
    % convert 1-dimentional index to 2-dimensional index(the coordinate of the matrix)
    for i=1:length(sorted_index)
        y=floor(sorted_index(i)/height);
        x=mod(sorted_index(i),height);
        if x==0
            x_sorted(i)=height;
            y_sorted(i)=y;
        else x_sorted(i)=x;
             y_sorted(i)=y+1;
        end
    end
    
    % use Cake matirx to deal with the sorted pixels one by one, so there will be only one strongest pixel in a certain region
    for i=1:length(sorted_index)
        if corners(x_sorted(i),y_sorted(i))~=0
            corners(x_sorted(i)-min_dist:x_sorted(i)+min_dist,y_sorted(i)-min_dist:y_sorted(i)+min_dist)=corners(x_sorted(i)-min_dist:x_sorted(i)+min_dist,y_sorted(i)-min_dist:y_sorted(i)+min_dist).*Cake;
        end
    end
    
    
    % elinimate the 0-edge, convert the corner matrix to the orginal size,
    % in order to cut the corner matrix into several tiles
    corners_small=corners(min_dist+1:height-min_dist,min_dist+1:width-min_dist);
    [height width]=size(corners_small);
    
    
    
    % use mat2cell function to cut the image into several tiles
    tile_model_x=zeros(1,num1);
    tile_model_y=zeros(1,num2);
    for i=1:num1
            tile_model_x(i)=tile_size(1);
    end
    
    % there can be also tiles, whcih has different size with the others
    % because they are at the edge of the image
    if mod(height,tile_size(1))~=0
        remainder=mod(height,tile_size(1));
        tile_model_x(end)=remainder;
    end  
    for i=1:num2
            tile_model_y(i)=tile_size(2);
    end
    if mod(width,tile_size(2))~=0
        remainder=mod(width,tile_size(2));
        tile_model_y(end)=remainder;
    end  
    corners_small_cell=mat2cell(corners_small,tile_model_x,tile_model_y);
    
    % the maximal number in each tile is N, so remian the strongest N corners
    for i=1:num1
        for j=1:num2
            tile=corners_small_cell{i,j};       % there are total num1*num2 tiles
            tile_index=find(tile);              % extract the index of the pixel in the tile
            % initialize the intensity vector, preparing for the sorting
            % very important becaues the number of corners in each tiles can be different
            intensity=zeros(1,length(tile_index));  
            % sort the corners, eliminate the corners after N
            if length(tile_index)>0
                for q=1:length(tile_index)
                    intensity(q)=tile(tile_index(q));
                end
                [sorted_intensity new_tile_index]=sort(intensity,'descend');
                sorted_tile_index=zeros(length(tile_index),1);
                for q=1:length(tile_index)
                    sorted_tile_index(q)=tile_index(new_tile_index(q));
                end
    
                 if length(sorted_tile_index)>N
                     tile(sorted_tile_index(N+1:end))=0;
                 end
            end
    
            corners_small_cell{i,j}=tile;
    
        end
    end
    
    % use cell2mat function to convert the tiles back to matrix form(without white edge)
    corners_small=cell2mat(corners_small_cell);
    
    % extract the index of corners in x/y coordinate form(for the plotting)
    [y,x]=find(corners_small);
    merkmale=[x,y]'; 
    
    %% Plot
    %HA1.6
    if do_plot       
        imshow(input_image)
        hold on
        plot(x,y, 'gx')
        hold off
    end
    
end