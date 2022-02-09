function [] = readcggtts(infile,outfile)
%this version is in the main directory.
fprintf ('this is readcggtts infile=%s outfile=%s\n',infile,outfile)
% THIS NEEDS TO BE REVISED FOR NON-GPS INPUTS
% this just reads a cggtts file and outputs the eqiuvalent in the following column-spaced format:
% it also creates an outfile for each satellite
%to do common view, run diffdata on each satellite
%fprintf (fidout,'%f %f %s %d %f %f %f\n',utc(np),refgps(np),line(1:1),nsat(np),elev,azim,rsv);
fid = fopen(infile,'r');
if (outfile=='x'|outfile=='data')outfile=['data/',infile];disp(['outfile now=',outfile]);end;
fidout = fopen(outfile,'w');
nread=0;
nwrite=0;
idiag=1;
ppp='n';
np=0;
while ~feof(fid)
  line=fgets(fid);
  nread=nread+1;
  %fprintf('nread=%d\n',nread);
  if (ischar(line))
    %fprintf('np=%f read line %s at nread=%f\n',np,line,nread);
    nbad=0;
    nbad1=0;
    [msat,nbad1,why]=makenum(line,'2','3');
    if (nbad1>0)nbad=1;if(idiag>0);fprintf('bad msat. nread=%d why=%s\n',nread,why);end;end;
    if (msat==99)ppp='y';msat=1;end;
    [mjd,nbad1,why]=makenum(line,'8','12');
    if (nbad1>0)nbad=2;if(idiag>0);fprintf('bad mjd. nread=%d why=%s\n',nread,why);end;end;

    %fprintf('nread=%d %s nbad=%d mjd=%f why=%s\n',nread,line,nbad1,mjd,why)
    %if (length(line)>11)fprintf('line 8-12=%s\n',line(8:12));end;
    if  (nread>17 && nbad1==0 &&(mjd<50000|| mjd>70000))nbad=3;end;
    [hh,nbad1,why]=makenum(line,'14','15');
    if (nbad1>0)nbad=4;if(idiag>0);fprintf('bad yy. nread=%d why=%s\n',nread,why);end;end;
    [mm,nbad1,why]=makenum(line,'16','17');
    if (nbad1>0)nbad=5;if(idiag>0);fprintf('bad mm. nread=%d why=%s\n',nread,why);end;end;
    [ss,nbad1,why]=makenum(line,'18','19');
    if (nbad1>0)nbad=6;if(idiag>0);fprintf('bad ss. nread=%d why=%s\n',nread,why);end;end;
    if (ppp=='n')
      [telev,nbad1,why]=makenum(line,'26','28');
      if (nbad1>0)nbad=7;if(idiag>0);fprintf('bad telev. why=%s\n',why);end;end;
      [tazim,nbad1,why]=makenum(line,'30','33');
      if (nbad1>0)nbad=8;if(idiag>0);fprintf('bad tazim. why=%s\n',why);end;end;
     else
       telev=0;
       tazim=0;
    end;
    [rsv,nbad1,why]=makenum(line,'35','45');
    if (nbad1>0&ppp=='n')nbad=9;if(idiag>0);fprintf('bad rsv. why=%s\n',why);end;end;
    [rgps,nbad1,why]=makenum(line,'54','64');
    if (nbad1>0&ppp=='n')nbad=10;if(idiag>0);fprintf('bad rgps. why=%s\n',why);end;end;
    if (nbad==0) 
      %disp(['nread=',num2str(nread)])
      np=np+1;
      %fprintf('size of msat=%d %d\n',size(msat));
      nsat(np)=msat;
      utc(np)=mjd+hh/24 +mm/1440 +ss/86400;
      refgps(np)=rgps/10;
      rsv=rsv/10;
      elev=telev/10;
      azim=tazim/10;
      if (line(1:1)==' ')line(1:1)='X';end  % OP has nothing where PTB has a G
      if (nwrite==0& ppp=='n')
        for n=1:9
         fidsat(n)=fopen(strcat(outfile,'.G0',num2str(n)),'w');
         fidsath(n)=fopen(strcat(outfile,'.G0',num2str(n),'.highel'),'w');
         nsats(n)=0;
        end;
        for n=10:32
         fidsat(n)=fopen(strcat(outfile,'.G',num2str(n)),'w');
         fidsath(n)=fopen(strcat(outfile,'.G',num2str(n),'.highel'),'w');
         nsats(n)=0;
        end;
      end;  % end nwrite==0 test for non-ppp data
      if (msat>9)
        fprintf (fidout,'%f %f %s %d %f %f %f\n',utc(np),refgps(np),line(1:1),nsat(np),elev,azim,rsv);
        if(ppp=='n')fprintf (fidsat(msat),'%f %f %s %d %f %f %f\n',utc(np),refgps(np),line(1:1),nsat(np),elev,azim,rsv);end;
        if(ppp=='n'&elev>25)fprintf (fidsath(msat),'%f %f %s %d %f %f %f\n',utc(np),refgps(np),line(1:1),nsat(np),elev,azim,rsv);end;
      else
        %disp(['outfile=',outfile]);
        fprintf (fidout,'%f %f %s 0%d %f %f %f\n',utc(np),refgps(np),line(1:1),nsat(np),elev,azim,rsv);
        if (ppp=='n')fprintf (fidsat(msat),'%f %f %s 0%d %f %f %f\n',utc(np),refgps(np),line(1:1),nsat(np),elev,azim,rsv);end;
        if (ppp=='n'&elev>25)fprintf (fidsath(msat),'%f %f %s 0%d %f %f %f\n',utc(np),refgps(np),line(1:1),nsat(np),elev,azim,rsv);end;
      end;
      if (ppp=='n')nsats(msat)=nsats(msat)+1;end;
      nwrite=nwrite+1;
    else
      fprintf('nread=%d is bad line. nbad=%d msat=%d lastwhy=%s lline=%d %d\n',nread,nbad,msat,why,size(line));
      fprintf('line=%s\n',line);
      fprintf ('mjd=%f hhmmss=%d %d %d rgps=%f 10*elev=%f 10*azim=%f\n',mjd,hh,mm,ss,rgps,telev,tazim);
    end;
   else
     disp(['possible end of file at nread=',num2str(nread),' ',why])
  end;
end;
fprintf('readccttf  done. nread=%d nwrite=%d count of each satellite prn follows\n',nread,nwrite);
if (ppp=='n')fprintf(' %d',nsats);end;
fprintf('\n');
fprintf('thats all folks. infile=%s\n',infile);
fclose('all');
