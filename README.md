# The Best of Both Worlds: Combining CNNs and Geometric Constraints for Hierarchical Motion Segmentation
This is the implementation of the paper [The Best of Both Worlds: Combining CNNs andGeometric Constraints for Hierarchical Motion Segmentation (CVPR 2018)](http://vis-www.cs.umass.edu/motionSegmentation/website_CVPR18/cvpr18-bideau.pdf). The code generates motion segmentation masks segmenting multiple independently moving objects. In addition an approach to estimate the camera's motion in presence of moving objects is provided and can be used in combination with the provided code or alone.

VIDEO

The code is documented and designed to be extended. If you use it in your research, please consider citing this paper (bibtex below).

## Requirements
* [VLFeat](https://www.vlfeat.org/) (the code was tested using vlfeat-0.9.20)
* miniconda
* [sharpmask](https://github.com/facebookresearch/deepmask)
* [fully conneted CRF](https://papers.nips.cc/paper/4296-efficient-inference-in-fully-connected-crfs-with-gaussian-edge-potentials.pdf). The implementation used in this work can be downloaded [here](https://github.com/AruniRC/crf-motion-seg/archive/master.zip).

## Getting Started

1) install miniconda (from your home directory on swarm2):
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
bash Miniconda2-latest-Linux-x86_64.sh

2) setup the conda environment:
conda create --prefix ~/dense-crf-conda python=2.7
source activate /home/arunirc/dense-crf-conda
pip install pydensecrf     [this takes a long time ... without any output messages!]
conda install numpy
conda install scipy
conda install scikit-image

3) then testing:
wget https://github.com/AruniRC/crf-motion-seg/archive/master.zip
unzip master.zip
cd crf-motion-seg-master/

## Moving Object Segmentation

## Camera Motion Estimation

## Differences from the Official paper
Commit abcdef follows the implementation of the hierarchical-motion-segmentation paper. Later on further improvments have been made mostly for camera motion estimation. Deviations from the main paper are the following:
* **Improved rotation compensation in 3D:**
* **More robust (but slower) optimization procedure:**


## Citation
Use this bibtex to cite this repository:
```
@InProceedings{Bideau_2018_CVPR,
author = {Bideau, Pia and RoyChowdhury, Aruni and Menon, Rakesh R. and Learned-Miller, Erik},
title = {The Best of Both Worlds: Combining CNNs and Geometric Constraints for Hierarchical Motion Segmentation},
booktitle = {The IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
month = {June},
year = {2018}
} 
```

## Projects using this Code
