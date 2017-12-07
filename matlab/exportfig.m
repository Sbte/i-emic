function [] = exportfig(string,fs,dims,invert)
    if nargin < 4
        invert = false;
    end
    if nargin < 3
        dims = [14,10];
    end
    if nargin < 2
        fs = 10;
    end

    width = dims(1); height = dims(2);
    set(gca,'fontsize',fs)

    set(gcf,'paperunits','centimeters')
    set(gcf,'paperposition',[1,1,width,height])
    set(gcf,'papersize',[width,height])

    if invert
        set(gca,'color','k');
        set(gca,'xcolor','w');
        set(gca,'ycolor','w');
        set(gca,'gridcolormode','manual');
        set(gca,'minorgridcolormode','manual');
        set(gca,'gridcolor',[.15,.15,.15]);
        set(gca,'minorgridcolor',[.15,.15,.15]);
        set(gca,'gridalpha',1);
        set(gca,'minorgridalpha',1);
        
        set(gcf,'color','k');
        set(legend,'color','k');
        set(legend,'edgecolor',[.5,.5,.5]);
        set(legend,'textcolor','w');        

        title = get(gca,'title');
        title.Color=[1,1,1];
        
        %set(colorbar, 'color', 'w');
        
    end
    
    set(gcf,'inverthardcopy','off')
    fprintf('saving to %s...\n', string);
    print(string, '-depsc2', '-painters', '-opengl');
    %print(string, '-depsc2', '-painters');
    %print(string, '-depsc2');
    %print(string)
    %saveas(gcf,string);
end

