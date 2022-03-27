#!/bin/bash
#SBATCH -o /home/%u/slogs/sl_%A.out
#SBATCH -e /home/%u/slogs/sl_%A.out
#SBATCH -N 1	  # nodes requested
#SBATCH -n 1	  # tasks requested
#SBATCH --gres=gpu:1  # use 1 GPU
#SBATCH --mem=20000  # memory in Mb
#SBATCH --partition=PGR-Standard
#SBATCH -t 80:00:00  # time requested in hour:minute:seconds
#SBATCH --cpus-per-task=8  # number of cpus to use - there are 32 on each node.

set -e # fail fast

dt=$(date '+%d_%m_%y_%H_%M');
echo "I am job ${SLURM_JOB_ID}"
echo "I'm running on ${SLURM_JOB_NODELIST}"
echo "Job started at ${dt}"

export CUDA_VISIBLE_DEVICES=0

export CUDA_HOME=/opt/cuda-10.2.89_440_33/
export CUDNN_HOME=/opt/cuDNN-7.6.0.64_10.0/

export LD_LIBRARY_PATH=${CUDNN_HOME}/lib64:${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
export LIBRARY_PATH=${CUDNN_HOME}/lib64:$LIBRARY_PATH
export CPATH=${CUDNN_HOME}/include:$CPATH
export PATH=${CUDA_HOME}/bin:${PATH}
export PYTHON_PATH=$PATH
# ====================
# Activate Anaconda environment
# ====================
source /home/${USER}/miniconda3/bin/activate paddle_env

# ====================
# RSYNC data from /home/ to /disk/scratch/
# ====================
export SCRATCH_HOME=/disk/scratch/${USER}
# export DATA_HOME=${PWD}/data/tusimpleNew
# export DATA_SCRATCH=${SCRATCH_HOME}/lanenet/data
#mkdir -p ${SCRATCH_HOME}/lanenet/data
#rsync --archive --update --compress --progress ${DATA_HOME}/ ${DATA_SCRATCH}

# ====================
# Run training. Here we use src/gpu.py
# ====================
echo "Creating directory to save model weights"
export OUTPUT_DIR=${SCRATCH_HOME}/result/bisenetv2/cityscapes100_1024x512
mkdir -p ${OUTPUT_DIR}

echo "Executing train.py"


python train.py \
       --config configs/bisenet/bisenet_cityscapes_1024x512_160k.yml \
       --do_eval \
       --use_vdl \
       --save_interval 10000 \
       --save_dir ${OUTPUT_DIR}


## This script does not actually do very much. But it does demonstrate the principles of training
#python src/gpu.py \
#	--data_path=${DATA_SCRATCH}/train.txt \
#	--output_dir=${OUTPUT_DIR}
#
## ====================
## Run prediction. We will save outputs and weights to the same location but this is not necessary
## ====================
#python src/gpu_predict.py \
#	--data_path=${DATA_SCRATCH}/pred.txt \
#	--model_dir=${OUTPUT_DIR}

# ====================
# RSYNC data from /disk/scratch/ to /home/. This moves everything we want back onto the distributed file system
# ====================
echo "Training ends, start to transfer data back."
OUTPUT_HOME=${PWD}/output/bisenetv2/cityscapes100_1024x512
mkdir -p ${OUTPUT_HOME}
rsync --archive --update --compress --progress ${OUTPUT_DIR} ${OUTPUT_HOME}

# ====================
# Finally we cleanup after ourselves by deleting what we created on /disk/scratch/
# ====================
#rm -rf ${OUTPUT_DIR}
echo "Job ${SLURM_JOB_ID} is done!"
