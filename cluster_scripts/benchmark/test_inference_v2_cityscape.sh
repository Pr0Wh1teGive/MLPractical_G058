#!/bin/bash
#SBATCH -o /home/%u/slogs/sl_%A.out
#SBATCH -e /home/%u/slogs/sl_%A.out
#SBATCH -N 1	  # nodes requested
#SBATCH -n 1	  # tasks requested
#SBATCH --gres=gpu:1  # use 1 GPU
#SBATCH --mem=20000  # memory in Mb
#SBATCH --partition=PGR-Standard
#SBATCH -t 1:00:00  # time requested in hour:minute:seconds
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



config_path="./configs/bisenet/bisenet_cityscapes_1024x512_160k.yml"
pretrained_path="./pretrained_model/bisenet/model.pdparams"

echo -e "\n Analyze model"
# python tools/analyze_model.py \
#     --config configs/bisenet/bisenet_cityscapes_1024x1024_160k.yml

# python tools/analyze_model.py \
#     --config configs/bisenet/bisenet_cityscapes_1024x512_160k.yml

 python tools/analyze_model.py \
     --config ${config_path}

echo -e "\n Export inference model"
export_path="./inference_model/bisenetv2"
if [ -d ${export_path} ]; then
    rm -rf ${export_path}
fi
python ./export.py \
    --config ${config_path}\
    --model_path ${pretrained_path} \
    --save_dir ${export_path}

dataset_type="Cityscapes"
dataset_path="./data/cityscapes"

resize_width=0  # 0 means not use resize
resize_height=0

echo -e "\n Test BiseNetV2 GPU Naive fp32"
python deploy/python/infer_dataset.py \
    --dataset_type ${dataset_type} \
    --dataset_path ${dataset_path} \
    --device gpu \
    --use_trt False \
    --precision fp32 \
    --resize_width ${resize_width} \
    --resize_height ${resize_height} \
    --config ${export_path}/deploy.yaml


echo "Job ${SLURM_JOB_ID} is done!"

