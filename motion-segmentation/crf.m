function [  ] = crf( INPUT_IMAGE_FILE, INPUT_SEG_MAT_FILE, OUTPUT_MAT_FILE, path)

    % python apply_crf_image.py -i INPUT_IMAGE_FILE -s INPUT_SEG_MAT_FILE -o OUTPUT_MAT_FILE

    lastDir = pwd;
    cd(path);
    
    INPUT_IMAGE_FILE = strcat('../.', INPUT_IMAGE_FILE);
    INPUT_SEG_MAT_FILE = strcat('../.', INPUT_SEG_MAT_FILE);
    OUTPUT_MAT_FILE = strcat('../.', OUTPUT_MAT_FILE);

    command = strcat('python apply_crf_image.py -i ', INPUT_IMAGE_FILE, ' -s ', INPUT_SEG_MAT_FILE, ' -o ', OUTPUT_MAT_FILE);%, ' -cbw 15 -cbx 40 -cbc 5');
    system(command);

    cd(lastDir);

end