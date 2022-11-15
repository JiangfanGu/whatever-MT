%batch plot rose
%%code for special need to plot some rose strike
%define parameters
%%modified by GuJiangfan@CUGB
pref_strike = 90*pi/180;
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
%%%%%%%%%%%%%%%%%%
%%%%plot_data
%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%strike
parplot=squeeze(pdata.parplot(1,:,:));
pclims=[0,90];
pylabel='degrees';
cmap=jet(32);
%%%%%%%%%%%rose
%%%read ipers first and change your parameter everytime
%%parameter is the first location of every period, and do not forget to input the last 
parameter=[1 14 27 41 54 67 79 92];%%change
band=length(parameter)-1;
name={'0.001-0.01','0.01-0.1','0.1-1','1-10','10-100','100-1000','1000-10000'};%change
%%%%%%%you can chose the data you want to draw with
isites=[1:92];
for i=1:1:band
    parplot_n=parplot(:,parameter(i):parameter(i+1)-1);
    
    
%{
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
    parplot=parplot(:,str2num(ipers));
   
% specify site range
prompt = {'choose site range'};
stitle  = 'Choose site range';
def = {['1:',num2str(pdata.nsite)]};
isites = char(inputdlg(prompt,stitle,1,def)); 
    parplot = parplot(str2num(isites),:)*pi/180;
    %}
    parplot_n=parplot_n(isites,:)*pi/180;
%plot
figure;
parplot_n(size(parplot_n,1)+1:2*size(parplot_n,1),:)=parplot_n+pi;
parplot_n=reshape(parplot_n,1,[]);
size(parplot_n)
rose(parplot_n+pi/2,pdata.nsect);
set(gca,'view',[-90,90]);
set(findobj(gca,'Type','line'),'Color','r');
 hold on
rose(parplot_n,pdata.nsect);
%title(char(menu2{choice2}));

set(gca,'ydir','reverse');
print('-depsc',[name{1,i},'-rose.eps']);
close(gcf)
end


