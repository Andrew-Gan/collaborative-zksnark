proof:
	cargo build --release --bin proof

run:
	sbatch -n 8 -N 1 --gpus-per-node=1 -A standby job.sh
