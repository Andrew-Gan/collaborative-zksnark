proof:
	cargo build --release --bin proof

run:
	sbatch -n 8 -N 1 --gpus-per-node=1 --constraint=K -A standby job.sh 