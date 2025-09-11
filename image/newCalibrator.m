function newCalibrator

%NEWCALIBRATOR   - Psychophysical estimation of the monitor's GAMMA.
%

filename=input('Please type in the name for the output file:\n\n', 's');
fid=fopen(filename,'a');

whichScreen=str2num(input('Which Screen Are You Going to Calibrate (0, 1, 2)?\n','s'));
rect=CenterRect([0 0 192-1 192-1], SCREEN(whichScreen, 'Rect'));		%frame size is 192*192
%rect=CenterRect([0 0 192 192], SCREEN(whichScreen, 'Rect'));		%frame size is 192*192

nframes=2;				%movie runs for 4*nframes, without repeats
pixelSizes=SCREEN(whichScreen,'PixelSizes');
if max(pixelSizes)<16
	fprintf('Sorry, I need a screen that supports 16- or 32-bit pixelSize.\n');
	return;
end
[window,screenRect]=SCREEN(whichScreen,'OpenWindow',0,[],max(pixelSizes));
 oldBoolean=SCREEN(whichScreen,'Preference','MaxPriorityForBlankingInterrupt');

SCREEN(window,'FillRect', 127);
repeats=1;		%repeat
m=ones(192, 192);
win=zeros(nframes,1);
frameRect=[0 0 size(m)-1];

lum=ones(192,192)*127;
normalClut=SCREEN(window,'GetClut');

ans=input('Do you know the B/R ratio? Type "y" for yes or "n" for no.\n\n','s');
if  (ans=='y')
	BRratio=input('Please enter the B/R ratio:\n\n');
else
	fprintf('Let us find it out!\n');
	
	for j=1:192
		if (rem(fix(j/10),2) == 0)		%Making horizontal alternating stripes
			lum(j,:)=1;
		else
			lum(j,:)=2;
		end
	end
	win(1)=SCREEN(window, 'OpenOffscreenWindow', 0, frameRect);
	SCREEN(win(1), 'PutImage', lum);
	
	%Determine BRratio by matching [rrr 0 195] with [0 0 200].
	rrr=input('Please enter the initial red value:\n\n');
	while (1)
		if ( rrr > 255 )
			rrr = 255;
		elseif ( rrr < 0 )
			rrr = 0;			
		end
		normalClut(2,:)=[0 0 200];
		normalClut(3,:)=[rrr 0 195];
		SCREEN(window,'SetClut',normalClut);	
				
		fprintf('rrr=%d\n',rrr);
		SCREEN('CopyWindow', win(1), window, frameRect, rect);
		ans=input('Enter "j" or "k" to remove the grating, press "c" to change the red value,\npress "q" when you are done.\n\n','s');
		if ( ans== 'j')
			rrr=rrr+1;
		elseif ( ans == 'k')
			rrr=rrr-1;
		elseif (ans == 'c')
			rrr=input('Please enter the new red value:\n\n');
		elseif (ans == 'q')
			break;
		else
			rrr=rrr;
		end		%end if
	end		%end while
		BRratio = rrr/5.0;	
end		% end if

fprintf(fid,'BRratio=%f\n', BRratio);
fprintf('BRratio=%f\n', BRratio);


for j = 1:2
	for k=1:192
		if ((k>=64) & (k<=128))
			lum(k,:)=4;
		elseif (rem(k,2) == 0)
			lum(k,:)=4+j;
		else
			lum(k,:)=7-j;
		end
	end
	win(j)=SCREEN(window, 'OpenOffscreenWindow', 0, frameRect);
	lum=uint8(lum);
	SCREEN(win(j), 'PutImage', lum);
end		%end for


rgbH=zeros(3);
rgbL=zeros(3);
M=zeros(15,3);
	
keyboard;
%Fine luminance calibration:
	
for i=1:15
	i
	switch i
		case 1
			rgbH(1)=0; rgbH(2)=0; rgbH(3)=255;
			rgbL(1)=0; rgbL(2)=0; rgbL(3)=0; 
		case 2
			rgbH(1)=0; rgbH(2)=0; rgbH(3)=255;
			rgbL(1) = M(1,1); rgbL(2)=M(1,2); rgbL(3)=M(1,3); 
		case 3
		 	rgbH(1) = M(1,1); rgbH(2)=M(1,2); rgbH(3)=M(1,3);
			rgbL(1)=0; rgbL(2)=0; rgbL(3)=0; 
		 case 4
			rgbH(1)=0; rgbH(2)=0; rgbH(3)=255;
		   	rgbL(1) = M(2,1); rgbL(2)=M(2,2); rgbL(3)=M(2,3); 
		 case 5
			rgbH(1) = M(2,1); rgbH(2)=M(2,2); rgbH(3)=M(2,3);
		    rgbL(1) = M(1,1); rgbL(2)=M(1,2); rgbL(3)=M(1,3); 
		case 6
			rgbH(1) = M(1,1); rgbH(2)=M(1,2); rgbH(3)=M(1,3);
		    rgbL(1)= M(3,1); rgbL(2)=M(3,2); rgbL(3)=M(3,3); 
		case 7
			rgbH(1) = M(3,1); rgbH(2)=M(3,2); rgbH(3)=M(3,3);
			rgbL(1)=0; rgbL(2)=0; rgbL(3)=0;
		case 8
			rgbH(1)=0; rgbH(2)=0; rgbH(3)=255;
		   	rgbL(1) = M(4,1); rgbL(2)=M(4,2); rgbL(3)=M(4,3); 
		case 9
			rgbH(1) = M(4,1); rgbH(2)=M(4,2); rgbH(3)=M(4,3);
		    rgbL(1) = M(2,1); rgbL(2)=M(2,2); rgbL(3)=M(2,3); 
		case 10
			rgbH(1)= M(2,1); rgbH(2)=M(2,2); rgbH(3)=M(2,3);
		    rgbL(1) = M(5,1); rgbL(2)=M(5,2); rgbL(3)=M(5,3);
		case 11
			rgbH(1) = M(5,1); rgbH(2)=M(5,2); rgbH(3)=M(5,3);
		    rgbL(1) = M(1,1); rgbL(2)=M(1,2); rgbL(3)=M(1,3);
		case 12
			rgbH(1) = M(1,1); rgbH(2)=M(1,2); rgbH(3)=M(1,3);
		    rgbL(1) = M(6,1); rgbL(2)=M(6,2); rgbL(3)=M(6,3);
		case 13
			rgbH(1)= M(6,1); rgbH(2)=M(6,2); rgbH(3)=M(6,3);
		    rgbL(1) = M(3,1); rgbL(2)=M(3,2); rgbL(3)=M(3,3); 
		case 14
			rgbH(1) = M(3,1); rgbH(2)=M(3,2); rgbH(3)=M(3,3);
		    rgbL(2) = M(7,1); rgbL(2)=M(7,2); rgbL(3)=M(7,3); 
		case 15
			rgbH(1) = M(7,1); rgbH(2)=M(7,2); rgbH(3)=M(7,3);
		    rgbL(1)=0; rgbL(2)=0; rgbL(3)=0; 
		end		%end switch
	
	if ( BRratio < 1.0)
		rgbH(1)=rgbH(3);
		rgbH(2)=rgbH(3);
		rgbL(1)=rgbL(3);
		rgbL(2)=rgbL(3);
	end
	
	fprintf('Matching-%d: %4.1f %4.1f %4.1f & %4.1f %4.1f %4.1f\n',...
		i, rgbH(1), rgbH(2), rgbH(3), rgbL(1), rgbL(2), rgbL(3)); 
	M(i,1)=(rgbH(1)+rgbL(1))/2;
	M(i,2)=(rgbH(2)+rgbL(2))/2;
	M(i,3)=(rgbH(3)+rgbL(3))/2;
		
	M(i,3)= input('Please type your initial guess for blue\n\n');
	if (BRratio < 1.0 )
		M(i, 1) = M(i, 3);
		M(i, 2) = M(i, 3);
	end
		
	while (1)
		fprintf('%4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f\n',...
			rgbH(1), rgbH(2), rgbH(3), rgbL(1), rgbL(2), rgbL(3), M(i,1), M(i,2), M(i,3));
		
		
		normalClut(5,:)=[M(i,1) M(i,2) M(i,3)];
		normalClut(6,:)=[rgbH(1) rgbH(2) rgbH(3)];
		normalClut(7,:)=[rgbL(1) rgbL(2) rgbL(3)];
		SCREEN(window,'SetClut',normalClut);

		priorityLevel = MaxPriority(whichScreen ,'WaitBlanking');
		%priorityLevel = 1;
		string = [];
		string = [string 'for n = 0:120;'];
		string = [string 'SCREEN(''CopyWindow'', win(1+rem(n,2)), window, frameRect, rect);'];
		string = [string 'SCREEN(window, ''WaitBlanking'',repeats);'];
		string = [string 'end;'];
		 
		HideCursor;
		Rush(string,priorityLevel);
		ShowCursor;

% 		HideCursor;
% 		for n=0:120
% 			SCREEN('CopyWindow', win(1+rem(n,2)), window, frameRect, rect);
% 			SCREEN(window, 'WaitBlanking',repeats);
% 		end
% 		ShowCursor;
		
		ans=input('Please enter "U" or "D" to remove the grating, enter "j" or "k" to fine tune,\nenter "c" for a new blue value, enter "q" when you are done.\n\n','s');
		if ( BRratio < 1.0 )
			if (( ans == 'j') | (ans == 'U'))
				M(i,3)=M(i,3)+1; 
			elseif (( ans == 'k') | (ans == 'D'))
				M(i,3)=M(i,3)-1;
			elseif (ans == 'q')
				break;
			elseif (ans == 'c')
				M(i,3)=input('Please enter new blue value:\n');
			end
			M(i, 1) = M(i, 3);
			M(i, 2) = M(i, 3);
		else
			if ( ans == 'j')
				M(i,1)=M(i,1)+1;
			elseif (ans == 'U')
			 	M(i,3)=M(i,3)+1;
			elseif (ans == 'k')
				M(i,1)=M(i,1)-1;
			elseif (ans == 'D')
				M(i,3)=M(i,3)-1;
			elseif (ans == 'q')
				break;
			elseif (ans == 'c')
				M(i,3)=input('Please enter new blue value:\n');
			end
		end	%end if
		
		fprintf(fid,'%4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f %4.1f\n', rgbH(1), rgbH(2), rgbH(3), rgbL(1), rgbL(2), rgbL(3), M(i,1), M(i,2), M(i,3));
		
	end		%end while.
keyboard;
end		%end for i= 1 to 15.


if ( BRratio < 1.0)
	data=[0 0;
		  0.0625 M(15, 3);
		  0.1250 M(7, 3);
		  0.1875 M(14, 3);
		  0.2500 M(3, 3);
		  0.3125 M(13, 3);
		  0.3750 M(6, 3);
		  0.4375 M(12, 3);
		  0.50 M(1, 3);
		  0.5625 M(11, 3);
		  0.6250 M(5, 3);
		  0.6875 M(10, 3);
		  0.7500 M(2, 3);
		  0.8125 M(9, 3);
		  0.8750 M(4, 3);
		  0.9375 M(8, 3);
		  1.0 255];
else
	data=[0 0;
		  0.0625 M(15, 3)+M(15, 1)/BRratio;
		  0.1250 M(7, 3)+M(7, 1)/BRratio;
		  0.1875 M(14, 3)+M(14, 1)/BRratio;
		  0.2500 M(3, 3)+M(3, 1)/BRratio;
		  0.3125 M(13, 3)+M(13, 1)/BRratio;
		  0.3750 M(6, 3)+M(6, 1)/BRratio;
		  0.4375 M(12, 3)+M(12, 1)/BRratio;
		  0.50 M(1, 3)+M(1, 1)/BRratio;
		  0.5625 M(11, 3)+M(11, 1)/BRratio;
		  0.6250 M(5, 3)+M(5, 1)/BRratio;
		  0.6875 M(10, 3)+M(10, 1)/BRratio;
		  0.7500 M(2, 3)+M(2, 1)/BRratio;
		  0.8125 M(9, 3)+M(9, 1)/BRratio;
		  0.8750 M(4, 3)+M(4, 1)/BRratio;
		  0.9375 M(8, 3)+M(8, 1)/BRratio;
		  1.0 255];
end 

guess= [1.5];
nparameter=1;

opt(1) = 0;
opt(2) = 1.e-13;
opt(3) = 1.e-13;
opt(14) = 10000;
Gamma=guess;
output = fmins('Macost_funct0', guess, opt, [], data)
x=data(:,1);
y1=data(:, 2);
y2=[];

Gamma=output(1);
C=0;
Beta=255;

for i=1:17
	y2=[y2 C+Beta*x(i).^(1/Gamma)];
end


figure;
plot(x, y1, 'xg', x, y2, '-y');

y2=y2-sum(y2)/17;
y1=y1-sum(y1)/17;
cor1 = y2*y1/sqrt(y1'*y1)/sqrt(y2*y2')

fprintf(fid, 'Gamma=%f, correlation=%f\n', Gamma, cor1);

fprintf('\nNow The Calibration Is Done!\n');
fclose(fid);
SCREEN('CloseAll');

%%%%% End of file NEWCALIBRATOR.M
