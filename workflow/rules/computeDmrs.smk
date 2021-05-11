rule compute:
	input:
		unpack(get_CX_reports)
	output:
		CG="results/comparisons/{id}/{id}-CG.bed",
		CHG="results/comparisons/{id}/{id}-CHG.bed",
		CHH="results/comparisons/{id}/{id}-CHH.bed",
	log:
		"results/comparisons/{id}/{id}_log.out"
	conda:
		"../envs/dmrcaller.yaml"
	threads: 4
	script:
		"../scripts/compute.R"
