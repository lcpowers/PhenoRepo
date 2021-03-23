


>## Descriptions of the data available from NEON
> #### _Images_: images containing RGB (red, green, blue) color channel pixel values were captured at various study sites. The pixel values are 8-bit digital numbers (DN). Images were taken about every 15 minutes between roughly 6am and 5pm local time. Color channel information was recorded and statistics were calculated for a particular region of interest (ROI) at each site, typically an area of a specific vegetation type (e.g. an area of evergreen broadleaf trees within a larger forest).
> ### **Main target statistics:** 
> **GCC** - _green chromatic coordinate_
> * the ratio of the green digital number to the sum of the green, red and blue digital numbers 
> * this metric is used to limit the effects of internal processing and external environmental factors that can affect the illumination of the image (better isolates the true phenological signal)
>
>**RCC** - _red chromatic coordinate_
> * same as GCC, but for the red digital number
> 
> ### **Data provided in the daily site csv files:**
> **date** - date of observation
>
> **year** - year of observation
>
> **doy** - day of the year (e.g. 32 means February 1st of the given year)
>
> **image_count** - the number of images that passed the selection criteria and were included in the data
>
> **midday_filename** - the name of the image file that was taken nearest to noon on the observation day
>
> **midday_r** - mean of the red channel pixel value (8-bit digital number) for the midday image over the ROI
>
> **midday_g** - mean of the green channel pixel value (8-bit digital number) for the midday image over the ROI
>
> **midday_b** - mean of the blue channel pixel value (8-bit digital number) for the midday image over the ROI
>
> **midday_gcc** - the mean GCC for the midday image over the ROI
>
> **midday_rcc** - the mean RCC for the midday image over the ROI
>
> **r_mean** - the mean of the red channel pixel values over the ROI for all images passing the selection criteria  (really a mean of all the means for each image)
>
> **r_std** - standard deviation of the r_mean value
>
> **g_mean** - the mean of the green channel pixel values over the ROI for all images passing the selection criteria  (really a mean of all the means for each image)
>
> **g_std** - standard deviation of the g_mean value
>
> **b_mean** - the mean of the blue channel pixel values over the ROI for all images passing the selection criteria  (really a mean of all the means for each image)
>
> **b_std** - standard deviation of the b_mean value
>
> **gcc_mean** - the mean of the GCC values over the ROI for all images passing the selection criteria  (really a mean of all the means for each image)
>
> **gcc_std** - standard deviation of the gcc_mean value
>
> **gcc_50** - the 50th quantile of the mean GCC over the ROI
>
> **gcc_75** - the 75th quantile of the mean GCC over the ROI
>
> **gcc_90** - the 90th quantile of the mean GCC over the ROI
>
> **rcc_mean** - the mean of the RCC values over the ROI for all images passing the selection criteria  (really a mean of all the means for each image)
>
> **rcc_std** - standard deviation of the rcc_mean value
>
> **rcc_50** - the 50th quantile of the mean RCC over the ROI
>
> **rcc_75** - the 75th quantile of the mean RCC over the ROI
>
> **rcc_90** - the 90th quantile of the mean RCC over the ROI
>
> **max_solar_elev** - the maximum solar elevation angle that was reached out of all the images passing the selection criteria
>
> **snowflag** - indicates if snow is covering the vegetation: NA=not evaluated; 1=bad or obscured image; 2=no snow in image; 3=snow (used for non-tree sites); 4=snow on ground only (used for treed sites); 5=snow on trees (and ground, used for treed sites)
>
> **outlierflag_gcc_mean** - a value of 0 indicates that the data for the gcc_mean is good, a value of 1 indicates that the data for the gcc_mean is an outlier
>
> **outlierflag_gcc_50** - a value of 0 indicates that the data for the gcc_50 is good, a value of 1 indicates that the data for the gcc_50 is an outlier
>
> **outlierflag_gcc_75** - a value of 0 indicates that the data for the gcc_75 is good, a value of 1 indicates that the data for the gcc_75 is an outlier
>
> **outlierflag_gcc_90** - a value of 0 indicates that the data for the gcc_90 is good, a value of 1 indicates that the data for the gcc_90 is an outlier
>
>**rg_cor** - correlation coefficient between the red channel and green channel
>
>**gb_cor** - correlation coefficient between the green channel and blue channel
>
>**br_cor** - correlation coefficient between the blue channel and red channel
