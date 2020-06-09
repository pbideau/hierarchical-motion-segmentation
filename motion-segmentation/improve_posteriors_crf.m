function [ posterior_object ] = improve_posteriors_crf( INPUT_IMAGE_FILE, INPUT_PROB_MAT_FILE, OUTPUT_PROB_MAT_FILE, objectProb, path )

    % -------------------------------------------------------------------------
    % getting posterior_object in correct object order for postprocessing
    % with CRF
    % -------------------------------------------------------------------------
    %[posterior_object] = changePosteriorOrder(posterior_object, ind_objects(:,:,end), objectSegmentation);
    save(INPUT_PROB_MAT_FILE, 'objectProb', '-v6');
    crf( INPUT_IMAGE_FILE, INPUT_PROB_MAT_FILE, OUTPUT_PROB_MAT_FILE, path);
    posterior_object = load(OUTPUT_PROB_MAT_FILE);
    posterior_object = posterior_object.objectProb;

end

