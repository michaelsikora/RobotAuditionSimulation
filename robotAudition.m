
clear;
run declare2
%%%% EDIT THESE VALUES
vars.label = {'Mics per Platform','Number of Platforms',...
    'Distance Between Cluster Centers','Platform Pitch Angle',...
    'Distance Between Adjacent Cluster Mics',...
    'Platform Yaw Angle','Source Type',...
    'Source Locations','Platform Locations'};
vars.value = {'3','2','0.5','1','17','1','WHITE NOISE',...
    'Choose Location','Choose Locations'};

% XYZ Points of center of clusters
vars.clusterCenters = [1.4597 1.2727 1.5;...
                  1.4947 0.2733 1.5];
              
vars.sigpos = [-1.6993 0.0076 1.5]';
              
vars.independent = 'Platform Angle';
vars.ii = [4 6];
vars.N = 4;
vars.value{4} = rand(1,vars.N).*90;
% vars.value{4} = zeros(1,vars.N);
vars.value{6} = (rand(1,vars.N).*180)-90;
% vars.value{6} = linspace(-90,90,vars.N);
    snrdbarray = zeros(1,vars.N);
%     angleArray = zeros(1,vars.N);
%     angleArray = ones(1,vars.N).*pi/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%% Get variable values for simulation
% Numerical variables
varCoeffs = [1 1 1 (pi/180) 1 (pi/180)]; % values to scale input variables
N_numVars = length(varCoeffs);
for vv = 1:N_numVars % load numerical variables from user data
    if ischar(vars.value{vv})
        localvars.value{vv} = str2double(vars.value{vv}).*varCoeffs(vv);
    else
        localvars.value{vv} = vars.value{vv}.*varCoeffs(vv);
    end
end

% Independent variable array
if strcmp(vars.independent,'None') %
    vars.ii = 1;
end
localvars.indvalues = zeros(length(vars.ii),vars.N);
for vv = 1:length(vars.ii)
    localvars.indvalues(vv,:) = localvars.value{vars.ii(vv)};
    localvars.value{vars.ii(vv)} = localvars.indvalues(vv,1);
end

% Static variables
cameraAngle = 2;

im{1} = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



waitDialog = waitbar(0,'Running Simulation');
%%%% independent variable loop
for aa = 1:vars.N
    
    for vv = 1:length(vars.ii)
        localvars.value{vars.ii(vv)} = localvars.indvalues(vv,aa);
    end
    micnum = localvars.value{2}*localvars.value{1};  %  Number of mics in array to be tested
    mjs_radius = localvars.value{5}/(200*sin(pi/localvars.value{1}));

    distBetween = sqrt(sum((vars.clusterCenters(2,:)-vars.clusterCenters(1,:)).^2));
    scale = distBetween/localvars.value{3};
    vars.clusterCenters(2,:) = vars.clusterCenters(1,:)...
        + (vars.clusterCenters(2,:)-vars.clusterCenters(1,:))/scale;

    % Precompute half angles for quaternion rotation
    mjs_cos2 = cos(localvars.value{4}/2); mjs_sin2 = sin(localvars.value{4}/2);
    % Define Platforms
    for pp = 1:localvars.value{2} % loop for identical platforms
        mjs_platform(pp) = Platform(vars.clusterCenters(pp,:),...
            localvars.value{1},localvars.value{5}/100);
        % vector from each mic center to source location
        mjs_pl2src(pp,:) = vars.sigpos-vars.clusterCenters(pp,:)';
        mjs_pltheta(pp) = atan2(mjs_pl2src(pp,2),mjs_pl2src(pp,1))+localvars.value{6};
        % tangential planar vector for rotation
        mjs_pltan2src(pp,:) = cross(mjs_pl2src(pp,:),[0 0 1]);
        % z axis rotations to orient endfire to source;
%         mjs_platform(pp).eulOrient(mjs_pltheta(pp),0); 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Orientation: Pitch %02.f degrees, Yaw %02.f degrees : ', localvars.value{4}/pi*180, localvars.value{6}/pi*180);
    for pp = 1:localvars.value{2}
        mjs_platform(pp).eulOrient(mjs_pltheta(pp),localvars.value{4}); 
    end

% Add microphone coordinates to mic position matrix
    for pp = 1:localvars.value{2}
        [mjs_X, mjs_Y, mjs_Z] = mjs_platform(pp).getMics();
        vars.mposplat{aa}(:,(pp-1)*localvars.value{1}+(1:localvars.value{1})) = [mjs_X, mjs_Y, mjs_Z]'; % Set mic coordinates
    end

%         vars.mposplat{aa} = zeros(3,micnum);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find max distance (delay) over all mic pairs; this represents an upper bound
        % on all required relative delays when scanning over the FOV
        [rm, nm] = size(vars.mposplat{aa});
        prs = mposanaly(vars.mposplat{aa},2);

        % Maximum delay in seconds needed to synchronize in Delay and Sum beamforming
        maxmicd = max(prs(:,3));
        % Extra delay time for padding window of data
        textra = ceil(vars.fs*maxmicd(1)/vars.prop.c); 
        % Windowing function to taper edge effects in the whitening process
        tapwin = flattap(vars.winlen+textra,20);
        winrec = tapwin*ones(1,micnum);

        waitbar(0.25,waitDialog,'Simulating Source');
        %%%% SOURCE
        % Generate target waveform
%         [b,a] = butter(5,[200 (vars.fs)-200]./vars.fs);
%         target = randn(vars.fs*5,1);
%         target = 10^(-3/20)*(target./max(target));
%         target = filtfilt(b,a,target);
        
        [target,fso] = audioread('./wav/mozart-1.wav');
        target = target(1:max(length(target),fso*5));
        target = resample(target,vars.fs,fso);  % Resample to fs
%                 target = filtfilt(target,a,y); % high pass filter the signal
        target = target*ones(1,vars.sigtot);
        
        % Compute array signals from target
        [sigoutper, taxper] = simarraysigim(target, vars.fs, vars.sigpos, vars.mposplat{aa}, vars.froom, vars.bs, vars.prop);
        % Random generation of coherent noise source positions on wall 
%         for knn=1:numnos
%             randv = ceil(rand(1,1)*4);
        % Noise source positions
%             sigposn(:,knn) = vn(:,randv) + rand(1)*(vn(:,mod(randv,4)+1)-vn(:,randv));
%         end
        sigposn = [-2.6204 3.500; 4.000 -3.6285; 1.5000 1.5000];
        % Create coherent white noise source with sample lengths as target signal
        [rt,ct] = size(target);
        % generate white noise 
        onos = randn(rt,vars.numnos);
        % place white noise target randomly on wall
%         [nosoutper, taxnosper] = simarraysigim(onos,vars.fs, sigposn, mposperim, froom, bs, vars.prop);
        [nosoutper, taxnosper] = simarraysigim(onos,vars.fs, sigposn, vars.mposplat{aa}, vars.froom, vars.bs, vars.prop);

        %%%% ENVELOPE SOURCE
        [mxp,cp] = max(max(abs(sigoutper)));  % Max point over all channels
        envper = abs(hilbert(sigoutper(:,cp(1))));  % Compute envelope of strongest channel
        % Compute maximum envelope point for reference in SNRs
        % Also location of max point will be used to ensure time window processed includes
        % the target
        [perpkpr, rpper] = max(envper);
        % Trim room signals to same length
        [siglenper, mc] = size(sigoutper);
        [noslenper, mc] = size(nosoutper);
        siglen = min([siglenper, noslenper]);
        sigoutper = sigoutper(1:siglen,:);
        nosoutper = nosoutper(1:siglen,:);
   
        %%%% SRP Window
        % Random window in 1 second
%             rpper = vars.winlen+round((length(target)-2*vars.winlen)*rand(1));
        % iterative time windows
        rpper = vars.winlen+round((length(target)-2*vars.winlen)*0.1)+2000*(aa-1);
        % Normalize noise power
        nosoutper = nosoutper/sqrt(mean(mean(nosoutper.^2)));
        % Add coherent noise to target signals
        nos = randn(siglen,mc);
        asnr = 10^((vars.cnsnr/20));
        nosamp = asnr*perpkpr;
        sigoutpera = sigoutper + nosamp*nosoutper + nos*vars.sclnos*perpkpr;
        % Initialize signal window index to beginning index, offset to ensure it includes target
        % signal
        sst = 1+rpper(1)-fix(.9*vars.winlen); 
        sed = sst+min([vars.winlen+textra, siglen]);   %  and end window end
        % create tapering window
%             fprintf(' Window starts at %d seconds \n', sst/vars.fs);
        tapwin = flattap(sed-sst+1,20);  %  One dimensional
        wintap = tapwin*ones(1,micnum);  %  Extend to matrix covering all channels
        % Whiten signal (apply PHAT, with beta factor given at the begining)
        sigout = whiten(sigoutpera(sst:sed,:).*wintap, vars.batar);
        % Create SRP Image from processed perimeter array signals
        waitbar(.50,waitDialog,'Running SRP image');
        im{aa} = srpframenn(sigout, vars.gridax, vars.mposplat{aa}, vars.fs, vars.prop.c, vars.trez);
        waitbar(.75,waitDialog,'Plotting SRP image');

        %%%% IMAGE ANALYSIS
        [SNRdB,avgnoise,peakSourcePower,thresholdMeanPower] = imErrorAnalysis(im{aa},vars.gridax,vars.sigpos,8);
        table(SNRdB,avgnoise,peakSourcePower,thresholdMeanPower)
        snrdbarray(aa) = SNRdB;
         
end % END of aa loop
close(waitDialog);

save('testdata.mat','localvars','vars','im','mjs_platform');
clear;