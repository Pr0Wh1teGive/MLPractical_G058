### Cluster_Scripts
- train: cluster scripts for submitting jobs
- benchmark: cluster scripts for model benchmark (Flops/Params/FPS)

### Common Commands
- Submit jobs by: sbatch xxx.sh
- View status of submitted job: squeue -u ${USER}
- View logs: watch -n 0.5 tail -n 30 sl_xxxxxx.out
