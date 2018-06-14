
% Plots the average, minimum and maximum images for the stored series.

clear;    
load('testdata.mat');

%%%% Average of image points
imavg = im{1};
for aa = 2:vars.N
    imavg = imavg + im{aa};
end
imavg = imavg./vars.N;

%%%% Minimum of image points
immin = im{1};
for aa = 2:vars.N
    immin = min(immin,im{aa});
end

%%%% Maximum of image points
immax = im{1};
for aa = 2:vars.N
    immax = max(immax,im{aa});
end
    
% Set common scale for plots
maximums(1) = max(imavg(:));
maximums(2) = max(immin(:));
maximums(3) = max(immax(:));
zmax = max(maximums);

minimums(1) = min(imavg(:));
minimums(2) = min(immin(:));
minimums(3) = min(immax(:));
zmin = min(minimums);

%%%% Plot
figure(2);
h = surf(vars.gridax{1},vars.gridax{2}, imavg);
peakVal = max(max(im{aa})); % Used to test convergence
colormap(jet); colorbar; axis('xy');
axis([vars.froom(1,1)-.25, vars.froom(1,2)+.25, vars.froom(2,1)-.25, vars.froom(2,2)+.25]);
hold on;
%  Mark coherenet noise positions
%       plot(sigposn(1,:),sigposn(2,:),'xb','MarkerSize', 18,'LineWidth', 2);  %  Coherent noise
%  Mark actual target positions  
sourceplot = plot3(vars.sigpos(1,:),vars.sigpos(2,:),ones(vars.sigtot)*1.5,'ok', 'MarkerSize', 18,'LineWidth', 2);
axis('tight');

for iii = 1:localvars.value{2} % Label Platform numbers
    vars.platcenters{aa}(iii,:) = mjs_platform(iii).getCenter();
    platlabs{aa}(iii) = plot3(vars.platcenters{aa}(iii,1),vars.platcenters{aa}(iii,2),vars.platcenters{aa}(iii,3),'sr','MarkerSize', 12,'LineWidth',2);
end

    % Draw Room walls
plot([vars.vn(1,:), vars.vn(1,1)],[vars.vn(2,:), vars.vn(2,1)],'k--')
% Label Plot
xlabel('Xaxis Meters')
ylabel('Yaxis Meters')
title({['SRP Average image (Clusters centered at squares,'],[' Target in circle)']} )
limits = axis;
caxis([zmin zmax]);
axis([limits(1:4),zmin, 1.8]);
view(2);

%%%% IMAGE ANALYSIS
[SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis2(imavg,vars.gridax,vars.sigpos,8);
table(SNRdB,avgnoise,peakSourcePower,thresholdMeanPower)
hold off

%%%% Plot
% figure(3);
% h = surf(vars.gridax{1},vars.gridax{2}, immin);
% peakVal = max(max(im{aa})); % Used to test convergence
% colormap(jet); colorbar; axis('xy');
% axis([vars.froom(1,1)-.25, vars.froom(1,2)+.25, vars.froom(2,1)-.25, vars.froom(2,2)+.25]);
% hold on;
% %  Mark actual target positions  
% sourceplot = plot3(vars.sigpos(1,:),vars.sigpos(2,:),ones(vars.sigtot)*1.5,'ok', 'MarkerSize', 18,'LineWidth', 2);
% axis('tight');
% 
% for iii = 1:localvars.value{2} % Label Platform numbers
%     vars.platcenters{aa}(iii,:) = mjs_platform(iii).getCenter();
%     platlabs{aa}(iii) = plot3(vars.platcenters{aa}(iii,1),vars.platcenters{aa}(iii,2),vars.platcenters{aa}(iii,3),'sr','MarkerSize', 12,'LineWidth',2);
% end
% 
%     % Draw Room walls
% plot([vars.vn(1,:), vars.vn(1,1)],[vars.vn(2,:), vars.vn(2,1)],'k--')
% % Label Plot
% xlabel('Xaxis Meters')
% ylabel('Yaxis Meters')
% title({['SRP Minimum image (Clusters centered at squares,'],[' Target in circle)']} )
% limits = axis;
% caxis([zmin zmax]);
% axis([limits(1:4),zmin, 1.8]);
% view(2);
% 
% %%%% IMAGE ANALYSIS
% [SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis2(immin,vars.gridax,vars.sigpos,8);
% table(SNRdB,avgnoise,peakSourcePower,thresholdMeanPower)
% hold off
% 
% %%%% Plot
% figure(4);
% h = surf(vars.gridax{1},vars.gridax{2}, immax);
% colormap(jet); colorbar; axis('xy');
% axis([vars.froom(1,1)-.25, vars.froom(1,2)+.25, vars.froom(2,1)-.25, vars.froom(2,2)+.25]);
% hold on;
% %  Mark actual target positions  
% sourceplot = plot3(vars.sigpos(1,:),vars.sigpos(2,:),ones(vars.sigtot)*1.5,'ok', 'MarkerSize', 18,'LineWidth', 2);
% axis('tight');
% 
% for iii = 1:localvars.value{2} % Label Platform numbers
%     vars.platcenters{aa}(iii,:) = mjs_platform(iii).getCenter();
%     platlabs{aa}(iii) = plot3(vars.platcenters{aa}(iii,1),vars.platcenters{aa}(iii,2),vars.platcenters{aa}(iii,3),'sr','MarkerSize', 12,'LineWidth',2);
% end
% 
%     % Draw Room walls
% plot([vars.vn(1,:), vars.vn(1,1)],[vars.vn(2,:), vars.vn(2,1)],'k--')
% % Label Plot
% xlabel('Xaxis Meters')
% ylabel('Yaxis Meters')
% title({['SRP Maximum image (Clusters centered at squares,'],[' Target in circle)']} ) 
% limits = axis;
% caxis([zmin zmax]);
% axis([limits(1:4),zmin, 1.8]);
% view(2);
% 
% %%%% IMAGE ANALYSIS
% [SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis2(immax,vars.gridax,vars.sigpos,8);
% table(SNRdB,avgnoise,peakSourcePower,thresholdMeanPower)
% hold off