function [ borderpoints insidepoints scanptsout] = outlineRUN(...
        lobe,scanpts,idx,im,thresh,xory,plusminus,a,b )
%OUTLINE
borderpoints = ones(1,2);
px = scanpts(idx,1);
py = scanpts(idx,2);
s = size(im);
scanptsout = scanpts;
insidepoints = lobe;
err = 0;
for dd = 1:4
    XY = [px py];
    coord = xory(dd);
    iter = plusminus(dd);
    continuing = 1;
    if im(XY(2),XY(1)) > (thresh)
    while continuing % looking in one direction
        XY(coord) = XY(coord) + iter;
        if insidepoints((insidepoints(:,1)== XY(1)),2) == XY(2) % point already in mainlobe
            continuing = 0;
            err = err + 2;
        else
            % if outof bounds, stop
            if (XY(coord) > s(coord)) || (XY(coord) < 1)
                continuing = 0;
                err = err + 1;
            elseif im(XY(2),XY(1)) < (thresh) % if lower than threshold
                borderpoints = [borderpoints; XY];
                continuing = 0;
            end
            if ~(XY(1)==0 || XY(2)==0)
                insidepoints = [insidepoints; XY];
                if (coord == a) && (iter == b)
                    scanptsout = [scanptsout; XY];
                end
            end
        end
    end  
    end
%     borderpoints = [borderpoints; XY];
end
end

