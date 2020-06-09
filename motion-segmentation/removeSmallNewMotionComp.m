function [ ind_first ] = removeSmallNewMotionComp(ind_all, minNumPixels)

    % -------------------------------------------------------------------------
    % remove small new motion Components that were created
    % -------------------------------------------------------------------------

    ind_second = ind_all(:,:,end-1);
    ind_first = ind_all(:,:,end);
    
    newMotion = ind_first==1;

    CC = bwconncomp(newMotion);
    numNewMotion = CC.NumObjects;
    num = max(max(ind_second-1));


    for k=1:numNewMotion               
         PixelList = CC.PixelIdxList{k};

          if length(PixelList) > minNumPixels 
             % keep new motion component
             isBg = ind_second(PixelList)-1;
             isBg = sum(isBg==num);
             % if new motion component was belonging to a previously
             % detected motion component. simply just keep previous motion
             % Component (remove new motion component)
             if (isBg == 0)
                ind_first(PixelList) = ind_second(PixelList);
             end
          else
              ind_first(PixelList) =  ind_second(PixelList);
          end  


    end


end

