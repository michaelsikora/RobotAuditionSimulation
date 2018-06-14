% Michael Sikora <m.sikora@uky.edu>
% 2018.06.14

% Plots the series of images

clear;    
load('testdata.mat');

% Set common scale for plots
for aa = 1:vars.N
    maximums(aa) = max(im{aa}(:));
    minimums(aa) = min(im{aa}(:));
end
zmax = max(maximums);
zmin = min(minimums);

aa = 1; % for single image
for aa = 1:vars.N
%%%% Plot
figure(1);
h = surf(vars.gridax{1},vars.gridax{2}, im{aa});
peakVal = max(max(im{aa})); % Used to test convergence
colormap(jet); colorbar; axis('xy');
axis([vars.froom(1,1)-.25, vars.froom(1,2)+.25, vars.froom(2,1)-.25, vars.froom(2,2)+.25]);
hold on;
%  Mark actual target positions  
sourceplot = plot3(vars.sigpos(1,:),vars.sigpos(2,:),ones(vars.sigtot)*1.5,'ok', 'MarkerSize', 18,'LineWidth', 2);
%  Mark microphone positions
micplot = plot3(vars.mposplat{aa}(1,:),vars.mposplat{aa}(2,:),vars.mposplat{aa}(3,:),'sr','MarkerSize', 12);
axis('tight');

for iii = 1:localvars.value{2} % Label Platform numbers
    vars.platcenters{aa}(iii,:) = mjs_platform(iii).getCenter();
    platlabs{aa}(iii) = text(vars.platcenters{aa}(iii,1),vars.platcenters{aa}(iii,2)+0.5,vars.platcenters{aa}(iii,3), ['Pl', int2str(iii)], 'HorizontalAlignment', 'center');
end
for kn=1:length(vars.mposplat{aa}(1,:)) % Label microphones
    miclabs{kn} = text(vars.mposplat{aa}(1,kn),vars.mposplat{aa}(2,kn),vars.mposplat{aa}(3,kn), int2str(kn), 'HorizontalAlignment', 'center');
end

    % Draw Room walls
plot([vars.vn(1,:), vars.vn(1,1)],[vars.vn(2,:), vars.vn(2,1)],'k--')
% Label Plot
xlabel('Xaxis Meters')
ylabel('Yaxis Meters')
title({['SRP image (Mics at squares,'],[' Target in circle']} )   

vars.currentImageIndex = aa;
limits = axis;
caxis([zmin zmax]);
axis([limits(1:4),zmin, 1.8]);
view(2);

%%%% IMAGE ANALYSIS : PLOTS THE MAIN LOBE OUTLINE
[SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis2(im{aa},vars.gridax,vars.sigpos,8);
table(SNRdB,avgnoise,peakSourcePower,thresholdMeanPower)
hold off

pause(1);
end