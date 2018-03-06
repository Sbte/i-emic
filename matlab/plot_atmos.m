function [state,pars,add] = plot_atmos(fname, opts)

    if nargin < 2
        opts = [];
    end

    
    
    if nargin < 1
        fname = 'atmos_output.h5';
    end
    
    if nargin < 2
        readE = true;
        readP = true;      
        
        opts.readE = readE;
        opts.readP = readP;
    end
    
    if isfield(opts, 'readE')
        readE = opts.readE;
    else
        readE = false;
        opts.readE = readE;
    end

    if isfield(opts, 'readP')
        readP = opts.readP;
    else
        readP = false;
        opts.readP = readP;
    end

    if isfield(opts, 'invert')
        invert = opts.invert;
    else
        invert = false;
        opts.invert = invert;
    end

    [n m l la nun xmin xmax ymin ymax hdim x y z xu yv zw landm] = readfort44('fort.44');
    surfm      = landm(2:n+1,2:m+1,l+1);    % Only interior surface points
    landm_int  = landm(2:n+1,2:m+1,2:l+1);
    summask = sum(landm_int,3);

    srf = [];
    greyness = .85;
    srf(:,:,1) = (1-greyness*(surfm'));
    srf(:,:,2) = (1-greyness*(surfm'));
    srf(:,:,3) = (1-greyness*(surfm'));

    atmos_nun = 2;
    atmos_l = 1;
    
    [state,pars,add] = readhdf5(fname, atmos_nun, n, m, atmos_l,opts);
    
    if readE
        E = reshape(add.E,n,m);
    end
    
    if readP
        P = reshape(add.P,n,m);
    end
    
    T0  = 15.0;   %//! reference temperature
    q0  = 8e-3;
    %q0  = 0;
    RtD = 180/pi;    
    
    tdim = 1;
    qdim = 1e-3;
    %qdim = 1;
    
    Ta  = T0 + tdim * squeeze(state(1,:,:,:));
    qa  = q0 + qdim * squeeze(state(2,:,:,:));
    Tz  = mean(Ta,1); % zonal mean
    qz  = mean(qa,1); % zonal mean

    figure(9)

    img = Ta';
    contourf(RtD*x,RtD*(y),img,20,'Visible','off'); hold on;
    image(RtD*x,RtD*(y),srf,'AlphaData',.2);
    c = contour(RtD*x,RtD*(y),img,20,'Visible', 'on','linewidth',1.5);
    colorbar
    cmap = my_colmap(caxis);
    colormap(cmap)
    colorbar

    hold off
    
    title('Atmospheric temperature')
    xlabel('Longitude')
    ylabel('Latitude')
    exportfig('atmosTemp.eps',10,[14,10],invert)

    figure(10)
    img = (Ta-repmat(Tz,n,1))';
    contourf(RtD*x,RtD*(y),img,20,'Visible','off'); hold on;
    image(RtD*x,RtD*(y),srf,'AlphaData',.2);
    c = contour(RtD*x,RtD*(y),img,20,'Visible', ...
                'on','linewidth', 1.5);

    cmap = my_colmap(caxis);
    colormap(cmap)
    colorbar

    hold off
    title('Ta anomaly')
    xlabel('Longitude')
    ylabel('Latitude')

    figure(11)
    img = (qa-repmat(qz,n,1))';

    imagesc(RtD*x,RtD*(y),img); hold on

    %img(img == 0) = NaN;
    %c = contour(RtD*x,RtD*(y),img,20,'k','Visible', 'on', ...
    %            'linewidth',.5);
    
    set(gca,'ydir','normal')
    
    %contourf(RtD*x,RtD*(y),img,20,'Visible','off'); hold on;
    %image(RtD*x,RtD*(y),srf,'AlphaData',.2);
    %c = contour(RtD*x,RtD*(y),img,20,'Visible', 'on','linewidth',1.5);

    hold off
    cmap = my_colmap(caxis);
    colormap(cmap)
    colorbar
   
    title('qa anomaly')
    xlabel('Longitude')
    ylabel('Latitude')
    exportfig('atmosqanom.eps',10,[14,10],invert)
    
    figure(12)
    img = qa';

    c = imagesc(RtD*x,RtD*(y),img); hold on
    image(RtD*x,RtD*(y),srf,'AlphaData',.8);
    set(gca,'ydir','normal')
    hold on
    c = contour(RtD*x,RtD*(y),img,12,'Visible', 'on', ...
                 'linewidth',1.5);
    hold off
    
    colorbar
    cmap = my_colmap(caxis);
    colormap(cmap)

    drawnow
    title('Humidity (kg / kg)')
    xlabel('Longitude')
    ylabel('Latitude')
    exportfig('atmosq.eps',10,[14,10],invert)
    
    if readE && readP

        figure(13) 
        EmP = qdim*(E-P)*3600*24*365;

        img = EmP';

        %contourf(RtD*x,RtD*(y),img,10,'Visible','off'); hold on;
        %image(RtD*x,RtD*(y),srf,'AlphaData',.2);
        
        imagesc(RtD*x,RtD*(y),img); hold on
        img(img == 0) = NaN;
        c = contour(RtD*x,RtD*(y),img,20,'k','Visible', 'on', ...
                    'linewidth',.5);
        hold off
        set(gca,'ydir','normal')
        cmap = my_colmap(caxis);
        colormap(cmap)
        colorbar

        hold off
        
        
        
        title('E-P (m/y)')
        xlabel('Longitude')
        ylabel('Latitude')
        
        exportfig('atmosEmP.eps',10,[14,10],invert)
    end
    
end