function plot_strike
%%Coded by Ye Gaofeng,
%   China university of Geosciences,
%   Beijing, P.R.China
%   2011-3-25
%   Usage: plotting *.dcmp file from Alan Jones'
%   strike analysis codes.
%   Do NOT destribute it without permission


%define parameters
pref_strike = 170*pi/180;
azimuth = 0;  nsect=72;  %nsect controls the rose thickness
esper=100;
[cname,cdir]=uigetfile({'*.dcmp'},'Choose files','multiselect','on');
if ~iscell(cname)% is not a cell array
    if cname==0 %select none,
        return;
    else   %select one
        cname={cname};
        nsite=1;
    end
else %is a cell array
    nsite=length(cname);
end
data=read_dcmp(cdir,cname,nsite);
%IMPORTANT: here we asume that these sites
%have same frequencies,furthermore the highest 
%freq is the same
pdata.pref_strike=pref_strike;
pdata.nsite=nsite;
pdata.pref_strike=pref_strike;
pdata.azimuth=azimuth;
pdata.nsect=nsect;
pdata.nfmax=max([data(1:nsite).nfreq]);
pdata.dcmpname={data(1:nsite).dcmpname};
pdata.ediname={data(1:nsite).ediname};
for i=1:nsite
    if data(i).nfreq==pdata.nfmax
        pdata.freq=data(i).freq;  %get longest freqs table
        break;
    end
end
pdata.parplot=zeros(6,nsite,pdata.nfmax);
pdata.parplot(:,:,:)=nan;
for i=1:nsite
    pdata.parplot(1,i,1:data(i).nfreq)=rem(rem(data(i).azimuth,360)+360,90);
    pdata.parplot(2,i,1:data(i).nfreq)=data(i).shear;
    pdata.parplot(3,i,1:data(i).nfreq)=rem(rem(data(i).channel,360)+360,90);
    pdata.parplot(4,i,1:data(i).nfreq)=data(i).twist;
    pdata.parplot(5,i,1:data(i).nfreq)=data(i).rms;
    pdata.parplot(6,i,1:data(i).nfreq)=tan(data(i).skew*pi/180);
    pdata.parplot(7,i,1:data(i).nfreq)=data(i).rhoa;
    pdata.parplot(8,i,1:data(i).nfreq)=data(i).phsa;
    pdata.parplot(9,i,1:data(i).nfreq)=data(i).rhob;
    pdata.parplot(10,i,1:data(i).nfreq)=data(i).phsb;
end
plot_data(pdata,data);
return;

%function read_dcmp
function data=read_dcmp(cdir,cname,ns)
for i=1:ns
    data(i).dcmpname=cname(i);
    cfile=[cdir,char(cname(i))];
    nband=0;
    fid=fopen(cfile,'r');
    for j=1:10000
        if ~feof(fid)
            line=fgetl(fid);
            if findstr(line,'Per-min')
                while 1
                    line=fgetl(fid);
                    if ~strcmp(line,'#')
                        nband=nband+1;
                        band(nband,1:5)=str2num(line(2:length(line)));
                    else
                        break;
                    end
                end
                data(i).band=band;
            elseif findstr(line,'# input file >')
                data(i).ediname=strrep(line,'# input file >','');
            elseif findstr(line,'>LATITUDE')
                temp=zeros(1,4);
                for k=1:4
                    for kk=length(line):-1:1
                        if line(kk:kk)==' '
                            ns=kk-1;
                            ne=length(line);
                            break;
                        end
                    end
                    temp(k)=str2double(line(ns:ne));        
                    line=fgetl(fid);
                end
                data(i).loc=temp([2,1,3,4]);
            elseif findstr(line,'regional azimuth')
                ne=findstr(line,'regional')-1;
                nfreq=str2num(line(1:ne));
                temp=fscanf(fid,'%f',[4,nfreq]);
                temp=temp';
                data(i).nfreq=nfreq;
                data(i).freq=temp(:,1);
                data(i).azimuth=temp(:,2);
                data(i).azimuth(find(data(i).azimuth==0))=nan;
            elseif findstr(line,'shear angle')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).shear=temp(:,2);
            elseif findstr(line,'channelling angle')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).channel=temp(:,2);
            elseif findstr(line,'twist angle')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).twist=temp(:,2);
            elseif findstr(line,'skew')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).skew=temp(:,2);
            elseif findstr(line,'anis')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).anis=temp(:,2);
            elseif findstr(line,'phadif')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).phadif=temp(:,2);
            elseif findstr(line,'app rho a')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).rhoa=temp(:,2);
            elseif findstr(line,'app rho b')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).rhob=temp(:,2);
            elseif findstr(line,'imped phase a')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).phsa=temp(:,2);
            elseif findstr(line,'imped phase b')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).phsb=temp(:,2);
            elseif findstr(line,'av. rms error')
                temp=fscanf(fid,'%f',[4,data(i).nfreq]);
                temp=temp';
                data(i).rms=temp(:,2);                
            end
        end
    end
    fclose(fid);
end           
return;

%function plot_data
function plot_data(pdata,data)
loc=zeros(pdata.nsite,4);
for i=1:pdata.nsite
    loc(i,1:4)=data(i).loc;
end
cen_long=(max(loc(:,1))+min(loc(:,1)))/2;
cen_lat=(max(loc(:,2))+min(loc(:,2)))/2;
long=loc(:,1);
lat=loc(:,2);
% Convert degrees to km N-S and E-W
x = 111.7*cos(cen_lat*pi/180)*(long-cen_long); 
y = 111.7*(lat-cen_lat);
% project stations on line of preferred strike (sp)
beta = atan2(y,x); 
r = sqrt(x.^2 + y.^2);

xdist = y;
per = pdata.freq(1:pdata.nfmax);
param = pdata.parplot(:,:,1:pdata.nfmax);

sparam = {'regional','shear','channelling','twist','rms','skew'};

npers=pdata.nfmax;
esper=npers;
% npers = size(parplots,2);
% if npers<fF
%     esper=esper+1;
% elseif npers>fF
%     esper=esper-1;
% elseif npers==fF
%     break
% end
menu1 = {'pcolor','profile','map','rose','exit'};
menu2 = {'strike','shear','channelling','twist','misfit','skew','exit'};
while 1
    choice1=menu('kind of plot:',menu1);
    if choice1~=5
        choice2=menu('parameters:',menu2);
        switch choice2
        case 1  % strike
            parplot=squeeze(pdata.parplot(1,:,:));
            pclims=[0,90];
            pylabel='degrees';
            cmap=jet(32);
        case 2 % shear
            parplot=squeeze(pdata.parplot(2,:,:));
            pclims=[-45;45];
            pylabel='degrees';
            cmap=jet(32);
        case 3 %channelling
            parplot=squeeze(pdata.parplot(3,:,:));
            pclims=[0,90];
            pylabel='degrees';
            cmap=jet(32)
        case 4 % twist
            parplot=squeeze(pdata.parplot(4,:,:));
            pclims=[-60,60];
            pylabel='degrees';
            cmap=jet(32);
        case 5 % misfit
            parplot=squeeze(pdata.parplot(5,:,:));
            pclims=[0,5];
            pylabel=' ';
            cmap=jet(32);
        case 6 % skew
            parplot=squeeze(pdata.parplot(6,:,:));
            pclims=[0,0.5];
            pylabel=' ';
            cmap=jet(32);                
        end
        switch choice1
        case 1                                   
            % =================> PCOLOR
            figure;
            set(gcf,'Name',[pwd,' - pcolor']);            
            % adjust blocks such that sites are in their middle:
            % if spacing doesn't seem to be appropriate, check
            % dx for negative entries and reorder sitefile.
            tx=xdist; dx=diff(xdist);
            % shift everything half dx to the left
            tx(1)=xdist(1)-dx(1)/2;
            tx(2:pdata.nsite)=xdist(1:pdata.nsite-1)+dx/2;
            tx(pdata.nsite+1)=xdist(pdata.nsite)+dx(2);
            % extend arrays
            parplot(pdata.nsite+1,:)=parplot(pdata.nsite,:);
            parplot(:,pdata.nfmax+1)=parplot(:,pdata.nfmax);
            per(pdata.nfmax+1)=per(pdata.nfmax);
            pcolor(tx,log10(per)*1.07,parplot');
            disp('Average value')
            mean(mean(parplot))
            hold on
            plot(xdist',log10(per(1))*ones(pdata.nsite,1),'kv');
            set(gca,'YDir','reverse');
            shading flat
            colormap(cmap)
            caxis(pclims);
            colorbar('vert')
            xlabel('km'); ylabel('log period'); 
            title(['profile ',char(menu2(choice2))]);
            set(gcf, 'paperPositionMode', 'auto'); 
            print('-dpsc',[char(menu2(choice2)),'-pcolor.ps']);
        case {2,3,4} % all others
	 	    prompt = {'choose period'};
            titles  = 'Choose period (range)';
            def = {['1:',num2str(pdata.nfmax)]};
            ipers = char(inputdlg(prompt,titles,1,def));
            if findstr(ipers,':')
                tper=str2num(strrep(ipers,':',' '));
                per_min=per(tper(1));per_max=per(tper(2));
            else
                tper=str2num(ipers);
                per_min=per(tper);permax=per(tper);
            end
            if (choice1==2)                   
                % =================> PROFILE
                parplot=squeeze(mean(parplot(:,str2num(ipers)),2));
                figure
                plot(xdist,parplot,'+');
                xlabel(['km along preferred strike: ',num2str(pdata.pref_strike*180/pi)]);
                ylabel(pylabel);
                title(['profile;',...
                       ' period band: ',num2str(per_min),'s-',num2str(per_max),'s;',...
                       ' ',char(sparam(choice1))]);
                set(gca,'XLim',[min(xdist)-10;max(xdist)+10],'YLim',pclims);
                print('-dpsc',[char(menu2(choice2)),'-profile.ps']);
            elseif (choice1==3 & choice2==1)         
                % =================> MAP
                parplot=squeeze(mean(parplot(:,str2num(ipers)),2)); 
                %figure
                parplot=parplot*pi/180;
                plot(x,y,'.')
                hold on
                % scale by misfit
                misfit = squeeze(mean(param(5,:,str2num(ipers)),3));
                strike_scale = 20-3*misfit;
                % rotate to align strikes to a preferred direction
                strike=parplot;
                nstop=1;
                while nstop~=0;
                    nchange=0;
                    aindex=find(strike-pdata.pref_strike >= pi/4);
                    bindex=find(strike-pdata.pref_strike < -pi/4);
                    if (sum(aindex)>0) strike(aindex)=strike(aindex)-pi/2; nchange=1; end
                    if (sum(bindex)>0) strike(bindex)=strike(bindex)+pi/2; nchange=1; end
                    nstop=nchange;
                end
                % create and plot bars
                x_strike=strike_scale.*cos(strike'); 
                y_strike=strike_scale.*sin(strike');
                xs = [x'-x_strike; x'+x_strike]; 
                ys = [y'+y_strike; y'-y_strike];
                xs_pi2 = [x'-y_strike; x'+y_strike]; 
                ys_pi2 = [y'-x_strike; y'+x_strike];
                plot(xs,ys,'b-')
                plot(xs_pi2,ys_pi2,'r-')   
                axis('equal')
                axis([min(x)-30,max(x)+30,min(y)-30,max(y)+30])
                xlabel('km'); ylabel('km');
                hold on
                title(['profile - regional strike;',...
                       ' period band: ',num2str(per(1)),'s-',num2str(per(length(per))),'s;',...
                       ' preferred strike: ',num2str(pdata.pref_strike*180/pi),' deg']);
                print('-dpsc',[char(menu2(choice2)),'-map.ps']);
            elseif (choice1==4 & (choice2==1|choice2==3)) 
                % =================> ROSE
                parplot=parplot(:,str2num(ipers));
                % specify site range
	 	        prompt = {'choose site range'};
                stitle  = 'Choose site range';
                def = {['1:',num2str(pdata.nsite)]};
                isites = char(inputdlg(prompt,stitle,1,def));
                parplot = parplot(str2num(isites),:)*pi/180;
                %plot
                figure;
                parplot(size(parplot,1)+1:2*size(parplot,1),:)=parplot+pi;
                parplot=reshape(parplot,1,[]);
                size(parplot)
                rose(parplot+pi/2,pdata.nsect);
                set(gca,'view',[-90,90]);
                set(findobj(gca,'Type','line'),'Color','r');
                hold on
                rose(parplot,pdata.nsect);
                title(char(menu2{choice2}));
                set(gca,'ydir','reverse');
                print('-depsc',[char(menu2(choice2)),'-rose.eps']);
            end
        end     
    else
        break;
    end
end
return
