function [SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis2(im,gridax,sigpos,box)
%IMERRORANALYSIS Error analysis of an image to be used in analysis of SRP image

% im - SRP image
% gridax - the gridpoints used to index the SRP image
% sigpos - the xyz coordinate matrix of source positions
% box - size of the box used to delineate noise and source signal

%%%% Get Grid point nearest sigpos
% delta = (gridax{1}(2)-gridax{1}(1));
% AA = gridax{1} > (sigpos(1)+delta);
% BB = gridax{1} < (sigpos(1)-delta);
% CCx = find(AA == BB);

% delta = (gridax{2}(2)-gridax{2}(1));
% AA = gridax{2} > (sigpos(2)+delta);
% BB = gridax{2} < (sigpos(2)-delta);
% CCy = find(AA == BB);
%%%%

% BOX METHOD
% gridsize = box; % size of region around peak
% % range
% regx = CCx-gridsize:CCx+gridsize;
% regy = CCy-gridsize:CCy+gridsize;
% % doesn't catch boundary problems if max peak is near edge.
%%%%

% %%%% THRESHOLD METHOD
% peakVal = max(im(:));
% thresh = 0.50*peakVal;
% [regx,regy] = find(im>thresh);
% %%%%

peakVal = max(im(:));
decent = (1-1/sqrt(2))*peakVal;
thresh = peakVal-decent;
[regy,regx] = find(im>thresh);
points = [regx,regy];
outline = [1 1];

adjx = 1;
adjy = 1;
for aa = min(points(:,1)):max(points(:,1))% iterate through x coordinate
    idx = find(points(:,1) == aa);
    if ~isempty(idx)
%         for bb = 1:length(idx) % iterate through x coordinate
            [m l] = max(points(idx,2));
            outline = [outline; points(idx(l),:)];
            [m l] = min(points(idx,2));
            outline = [outline; points(idx(l),:)];
%         end
    end
end

outline = outline(2:end,:);

scatter3(gridax{1}(outline(:,1)),gridax{2}(outline(:,2)),...
    ones(1,size(outline,1))*0.5,'pk','LineWidth',1)

% [py px] = find(im == peakVal); 
% xory = [1 1 2 2];
% plusminus = [-1 +1 -1 +1];
% outline = [px py];
% lobe = [px py];
% scanpts = [px py];
% direction = 1;
% a = 1; b = -1;
% idx = 1;
% for ii = 1:100
%     if ii > size(scanpts,1)
%         direction = mod(direction + 1,4)+1;
%         a = xory(direction);
%         b = plusminus(direction);
%     else
%         idx = ii;
%     end
%     [XY, mainlobe, scanptsout] = outlineRUN(...
%         lobe,scanpts,idx,im,peakVal-decent,xory,plusminus,a,b );
%     lobe = mainlobe;
%     scanpts = scanptsout;
% %     outline = [outline; XY(2:end,:)];
% scatter3(gridax{1}(lobe(:,1)),gridax{2}(lobe(:,2)),...
%     ones(1,size(lobe,1))*0.5,'+k','LineWidth',3)
% end

% scatter3(gridax{1}(lobe(:,1)),gridax{2}(lobe(:,2)),...
%     ones(1,size(lobe,1))*0.5,'+k','LineWidth',3)


%%%% BOX METHOD
% imsourcewindow = zeros(gridsize*2+1);
% for ll = 1:gridsize*2+1
%     for kk = 1:gridsize*2+1
%         imsourcewindow(kk,ll) = im(kk+regx(1)-1,ll+regy(1)-1);
%     end
% end
%%%%

% PLOT ABOVE THRESHOLD
% pause;
% surf(gridax{1},gridax{2},im.*(im>thresh));
% xlabel('Xaxis meters'); ylabel('Yaxis meters');
% title(['Image above threshold of ', num2str(thresh)]);
% pause;

srpmax = max(im(im>thresh));
srpmean = mean(im(im>thresh));
% [ymax xmax] = find(im == srpmax); % get index of max peak
% locxmax = gridax{1}(xmax); % get coordinate of max peak
% locymax = gridax{2}(ymax);

% peakloc = [ locxmax locymax ];

% if show_plots == 1
%    plot3(locxmax, locymax, max(im(:)) ,'ok', 'MarkerSize', 18,'LineWidth', 2);
% end

% gridsize = box; % size of region around peak
% % range
% regx = xmax-gridsize/2:xmax+gridsize/2;
% regy = ymax-gridsize/2:ymax+gridsize/2;
% doesn't catch boundary problems if max peak is near edge.

xN = length(gridax{1});
yN = length(gridax{2});
imnoise = zeros(xN,yN);
nn = 1;
for ll = 1:xN
    cond1 = length(find(regx ~= ll)) ~= length(regx);
    for kk = 1:yN
        cond2 = length(find(regy ~= kk)) ~= length(regy);
        if ~(cond1 && cond2) % true when ll is in both regions     
            imnoise(kk,ll) = im(kk,ll);
            noisevalues(nn) = im(kk,ll);
            nn = nn + 1;
        end
    end
end

noisevalues(noisevalues<0) = 0; % zero negative noise values
avgnoise = mean(noisevalues);
peakSourcePower = srpmax;
thresholdMeanPower = srpmean;
SNRdB = db(srpmean/avgnoise);
% SNRdB = db(max(im(:))/std(im(:))); % quick estimate
end