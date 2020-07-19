function Korrespondenzen = punkt_korrespondenzen(I1,I2,Mpt1,Mpt2,varargin)
    % In dieser Funktion sollen die extrahierten Merkmalspunkte aus einer
    % Stereo-Aufnahme mittels NCC verglichen werden um Korrespondenzpunktpaare
    % zu ermitteln.
    
    %% 2.1 Input parser

    Im1=double(I1);
    Im2=double(I2);
    
    default_window_length=25;
    default_min_corr=0.95;
    default_do_plot=false;
    
    validationFcn_window_length=@(x) isnumeric(x) && (mod(x,2)==1) && (x>1);
    validationFcn_min_corr=@(x) isnumeric(x) && (x>0) && (x<1);
    validationFcn_do_plot=@(x) islogical(x);
    p=inputParser;
    
    addParameter(p,'window_length',default_window_length,validationFcn_window_length);
    addParameter(p,'min_corr',default_min_corr,validationFcn_min_corr);
    addParameter(p,'do_plot',default_do_plot,validationFcn_do_plot); 
    parse(p,varargin{:});
    
    window_length = p.Results.window_length;
    min_corr = p.Results.min_corr;
    do_plot = p.Results.do_plot;
%     Korrespondenzen{1}=p.Results.window_length;
%     Korrespondenzen{2}=p.Results.min_corr;
%     Korrespondenzen{3}=p.Results.do_plot;
%     Korrespondenzen{4}=Im1;
%     Korrespondenzen{5}=Im2;

    %% 2.2 Merkmalsvorbereitung
    
    
    rand=(window_length-1)/2;
    
    % for image1, find the coordinates of at the edge, convert these coordinates to 0
    [height1,width1]=size(I1);    
    Mpt1_x=Mpt1(1,:);
    Mpt1_y=Mpt1(2,:);
    for i=1:length(Mpt1_x)
        if (Mpt1_x(i)<=rand)|(Mpt1_x(i)>=width1-rand+1)
            Mpt1_x(i)=0;
            Mpt1_y(i)=0;
        end
    end  
    for i=1:length(Mpt1_y)
        if (Mpt1_y(i)<=rand)|(Mpt1_y(i)>=height1-rand+1)         
            Mpt1_y(i)=0;
            Mpt1_x(i)=0;
        end
    end

    % for image2, find the coordinates of at the edge, convert these coordinates to 0
    [height2,width2]=size(I2);
    Mpt2_x=Mpt2(1,:);
    Mpt2_y=Mpt2(2,:);
    for i=1:length(Mpt2_x)
        if (Mpt2_x(i)<=rand)|(Mpt2_x(i)>=width2-rand+1)
            Mpt2_x(i)=0;
            Mpt2_y(i)=0;
        end
    end  
    for i=1:length(Mpt2_y)
        if (Mpt2_y(i)<=rand)|(Mpt2_y(i)>=height2-rand+1)
            Mpt2_y(i)=0;
            Mpt2_x(i)=0;
        end
    end
    
    % delate the 0 coordinates
    Mpt1_x(Mpt1_x==0)=[];
    Mpt1_y(Mpt1_y==0)=[];
    Mpt2_x(Mpt2_x==0)=[];
    Mpt2_y(Mpt2_y==0)=[];
    
    no_pts1=length(Mpt1_x);
    no_pts2=length(Mpt2_x);
    
    % merge new coordinate matrix
    Mpt1=[Mpt1_x;Mpt1_y];
    Mpt2=[Mpt2_x;Mpt2_y];
       
    %Korrespondenzen={no_pts1,no_pts2,Mpt1,Mpt2};
    
    %% 2.3 Normierung
    I1=double(I1);
    I2=double(I2);
    rand=(window_length-1)/2;
    one_vector=ones(window_length,1);
    Mat_feat_1=[];
    Mat_feat_2=[];

    % dealing with Mat_feat_1
    [height,width]=size(I1);    
    for i=1:no_pts1
        corner_x=Mpt1(2,i);                 % convert x/y coordinate to matrix coordinate
        corner_y=Mpt1(1,i);
        W=I1(corner_x-rand:corner_x+rand,corner_y-rand:corner_y+rand);                     % extract W matrix from gray image according to matrix coordinate
        W_average=(1/window_length^2)*(one_vector*one_vector'*W*one_vector*one_vector');
        W_sigma=sqrt((1/(window_length^2-1))*trace((W-W_average)'*(W-W_average)));
        W_n=1/W_sigma*(W-W_average);
        column_vecotr=reshape(W_n,window_length^2,1);       % convert the normalized matrix W_n to a column vector
        Mat_feat_1=cat(2,Mat_feat_1,column_vecotr);         % add the column vector to Mat_feat_1
    end
    
    [height,width]=size(I2);    
    for i=1:no_pts2
        corner_x=Mpt2(2,i);
        corner_y=Mpt2(1,i);
        W=I2(corner_x-rand:corner_x+rand,corner_y-rand:corner_y+rand);
        W_average=(1/window_length^2)*(one_vector*one_vector'*W*one_vector*one_vector');
        W_sigma=sqrt((1/(window_length^2-1))*trace((W-W_average)'*(W-W_average)));
        W_n=1/W_sigma*(W-W_average);
        column_vecotr=reshape(W_n,window_length^2,1);
        Mat_feat_2=cat(2,Mat_feat_2,column_vecotr);
    end
    
    %Korrespondenzen = {Mat_feat_1, Mat_feat_2};

   %% 2.4 NCC Brechnung
    NCC_matrix=zeros(no_pts2,no_pts1);   
    for i=1:no_pts2
        for j=1:no_pts1
            NCC_matrix(i,j)=1/(window_length^2-1)*Mat_feat_2(:,i)'*Mat_feat_1(:,j);
        end
    end
    NCC_matrix(NCC_matrix<min_corr)=0;
    
    
    % extract the index of non-zero element in NCC_matrix
    NCC_matrix_index=find(NCC_matrix);
    for i=1:length(NCC_matrix_index)
        NCC_matrix_value(i)=NCC_matrix(NCC_matrix_index(i));       % the corresponding element of NCC_matrix according to the index
    end

    
    % sort these NCC_values in descend order
    % store the corresponding index in sorted_index
    [sorted_NCC_matrix_value new_index]=sort(NCC_matrix_value,'descend');
    sorted_index=zeros(length(NCC_matrix_index),1);
    for i=1:length(NCC_matrix_index)
        sorted_index(i)=NCC_matrix_index(new_index(i));
    end
    
    % Korrespondenzen = {NCC_matrix, sorted_index};
    
    
    %% 2.5 Korrespondenz
    Korrespondenzen = 0;

    % convert 1-dimentional index to 2-dimentional index
    [height,width]=size(NCC_matrix);
    x_sorted=zeros(length(sorted_index));
    y_sorted=zeros(length(sorted_index));
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
    
    Korrespondenzen=[];
    for i=1:length(sorted_index)
        if NCC_matrix(x_sorted(i),y_sorted(i))~=0
            NCC_matrix(:,y_sorted(i))=NCC_matrix(:,y_sorted(i)).*zeros(height,1);
            p1=Mpt1(:,y_sorted(i));
            p2=Mpt2(:,x_sorted(i));
            column_vector=[p1;p2];
            Korrespondenzen=cat(2,Korrespondenzen,column_vector);           
        end
    end
    
     %% 2.6 Zeige die Korrespondenzpunktpaare an
    if do_plot
        
        I1=uint8(I1);
        I2=uint8(I2);
        [height,width]=size(Korrespondenzen);

        imshow(I1)
        hold on
        imagesc(I2,'AlphaData',0.5)

        plot(Korrespondenzen(1,:),Korrespondenzen (2,:),'g*')
        plot(Korrespondenzen(3,:),Korrespondenzen (4,:),'r*')
        for i=1:width
            line([Korrespondenzen(1,i),Korrespondenzen(3,i)],[Korrespondenzen(2,i),Korrespondenzen(4,i)])
        end
    end

end