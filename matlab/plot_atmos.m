function [state,pars,add] = plot_atmos(fname)

    if nargin < 1
        fname = 'atmos_output.h5';
    end

    [n m l la nun xmin xmax ymin ymax hdim x y z xu yv zw landm] = readfort44('fort.44');
    surfm      = landm(2:n+1,2:m+1,l+1);    % Only interior surface points
    landm_int  = landm(2:n+1,2:m+1,2:l+1);

    srf = [];
    greyness = .85;
    srf(:,:,1) = (1-greyness*(surfm'));
    srf(:,:,2) = (1-greyness*(surfm'));
    srf(:,:,3) = (1-greyness*(surfm'));

    atmos_nun = 2;
    atmos_l = 1;
    opts.readE = true;
    opts.readP = true;
    [state,pars,add] = readhdf5(fname, atmos_nun, n, m, atmos_l,opts);
    
    E = reshape(add.E,n,m);
    P = reshape(add.P,n,m);
    
    T0  = 15.0;   %//! reference temperature
    q0  = 0.0015;
    RtD = 180/pi;    
    
    Ta  = T0 + squeeze(state(1,:,:,:));
    qa  = q0 + squeeze(state(2,:,:,:));
    Tz  = mean(Ta,1); % zonal mean

    figure(10)

    img = Ta';
    contourf(RtD*x,RtD*(y),img,20,'Visible','off'); hold on;
    image(RtD*x,RtD*(y),srf,'AlphaData',.2);
    c = contour(RtD*x,RtD*(y),img,15,'Visible', 'on','linewidth',1);
    colorbar
    caxis([min(min(Ta)),max(max(Ta))])
    hold off
    drawnow
    title('Atmospheric temperature')
    xlabel('Longitude')
    ylabel('Latitude')
    exportfig('atmosTemp.eps')

    figure(11)

    img = (Ta-repmat(Tz,n,1))';
    contourf(RtD*x,RtD*(y),img,20,'Visible','off'); hold on;
    image(RtD*x,RtD*(y),srf,'AlphaData',.2);
    c = contour(RtD*x,RtD*(y),img,15,'Visible', 'on','linewidth',1);
    colorbar
    caxis([min(min(img)),max(max(img))])
    hold off
    drawnow
    title('Atmospheric temperature anomaly')
    xlabel('Longitude')
    ylabel('Latitude')
    exportfig('atmosTemp.eps')
    
    figure(12)

    img = qa';
    contourf(RtD*x,RtD*(y),img,20,'Visible','off'); hold on;
    image(RtD*x,RtD*(y),srf,'AlphaData',.2);
    c = contour(RtD*x,RtD*(y),img,5,'Visible', 'on','linewidth',1);
    colorbar
    caxis([min(min(qa)),max(max(qa))])
    hold off
    drawnow
    title('Atmospheric humidity (g / kg)')
    xlabel('Longitude')
    ylabel('Latitude')
    exportfig('atmosq.eps')

    figure(13)
    surf(qa')
    
    figure(14) 
    E(E==0)=NaN;
    img = E';
    contourf(RtD*x,RtD*(y),img,10,'Visible','off'); hold on;
    image(RtD*x,RtD*(y),srf,'AlphaData',.2);
    c = contour(RtD*x,RtD*(y),img,15,'Visible', 'on','linewidth',1);
    colorbar

    hold off
    drawnow
    title('Evaporation')
    xlabel('Longitude')
    ylabel('Latitude')
    
    
    

    

end