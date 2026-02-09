et -euo pipefail

# 用法:
#   bash run_all_splash4.sh            # 默认 8 核
#   P=16 bash run_all_splash4.sh       # 指定核数
#   TIMEOUT=30m P=8 bash run_all_splash4.sh

P="${P:-8}"
TIMEOUT="${TIMEOUT:-20m}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${ROOT}/run_all_p${P}.log"

echo "ROOT=${ROOT}"
echo "P=${P}"
echo "TIMEOUT=${TIMEOUT}"
echo "LOG=${LOG}"

# 编译
make -C "${ROOT}" -j"$(nproc)"

run() {
	  local dir="$1"
	    local cmd="$2"

	      echo "=== ${dir} ===" | tee -a "${LOG}"
	        if (cd "${ROOT}/Splash-4/${dir}" && timeout "${TIMEOUT}" bash -lc "${cmd}") >>"${LOG}" 2>&1; then
			    echo "[OK] ${dir}" | tee -a "${LOG}"
			      else
				          rc=$?
					      echo "[FAIL:${rc}] ${dir}" | tee -a "${LOG}"
					        fi
						  echo | tee -a "${LOG}"
					  }

				  : > "${LOG}"

				  run barnes "./BARNES < inputs/n16384-p${P}"
				  run cholesky "./CHOLESKY -p${P} < inputs/tk15.O"
				  run fft "./FFT -p${P} -m16"
				  run fmm "./FMM < inputs/input.${P}.16384"
				  run lu-contiguous_blocks "./LU-CONT -p${P} -n512"
				  run lu-non_contiguous_blocks "./LU-NOCONT -p${P} -n512"
				  run ocean-contiguous_partitions "./OCEAN-CONT -p${P} -n258"
				  run ocean-non_contiguous_partitions "./OCEAN-NOCONT -p${P} -n258"
				  run radiosity "./RADIOSITY -p ${P} -ae 5000 -bf 0.1 -en 0.05 -room -batch"
				  run radix "./RADIX -p${P} -n1048576"
				  run raytrace "./RAYTRACE -p${P} -m64 inputs/car.env"
				  run volrend "./VOLREND ${P} inputs/head 8"
				  run volrend-no_print_lock "./VOLREND-NPL ${P} inputs/head 8"
				  run water-nsquared "./WATER-NSQUARED < inputs/n512-p${P}"
				  run water-spatial "./WATER-SPATIAL < inputs/n512-p${P}"

				  echo "==== SUMMARY ====" | tee -a "${LOG}"
				  grep -E "^\[OK\]|^\[FAIL" "${LOG}" | tee -a "${LOG}"

				  echo "Done. Log: ${LOG}"

