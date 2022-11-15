%use with plot_rose_n.m
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
