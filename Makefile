RSCRIPT = Rscript --no-init-file
FILE_TARGET := "${FILE}"
DEPS := $(shell ${RSCRIPT} -e 'invisible(lapply(c("glue", "cli"), require, character.only = TRUE, quiet = TRUE))' -e 'deps = renv::dependencies(quiet = TRUE)' -e 'uniq_pkgs = sort(unique(deps$$Package))' -e 'uniq_pkgs = uniq_pkgs[!grepl("^proofr$$|^rcromwell$$", uniq_pkgs)]' -e 'cat(c("getwilds/proofr@v0.2", "getwilds/rcromwell@v3.2.0", uniq_pkgs), file="deps.txt", sep="\n")')

run:
	${RSCRIPT} -e "options(shiny.autoreload = TRUE)" \
		-e "shiny::runApp(\"app\", launch.browser = TRUE)"

run_docker:
	@echo "NOTE: CTRL+C doesn't work to kill the container - use separate terminal window or Docker Desktop\n\n"
	docker build --platform linux/amd64 -t shiny-cromwell:app .
	docker run -p 3838:3838 shiny-cromwell:app

# use: `make style_file FILE=stuff.R`
# accepts 1 file only
style_file:
	${RSCRIPT} -e 'styler::style_file(${FILE_TARGET})'

pkg_deps_cmd:
	@${RSCRIPT} -e 'invisible(lapply(c("glue", "cli"), require, character.only = TRUE, quiet = TRUE))' \
	-e 'uniq_pkgs = readLines("deps.txt")' \
	-e 'cli_alert_info("Found {length(uniq_pkgs)} packages")' \
	-e 'cli_alert_info("Here are the installation instructions:")' \
	-e "cli_code(glue('pak::pak(c({glue_collapse(double_quote(uniq_pkgs), sep = \", \")}))'))"

pkg_deps_install:
	@${RSCRIPT} -e 'invisible(lapply(c("glue", "cli"), require, character.only = TRUE, quiet = TRUE))' \
	-e 'uniq_pkgs = readLines("deps.txt")' \
	-e 'cli_alert_info("Found {length(uniq_pkgs)} packages")' \
	-e 'cli_alert_info(glue("{glue_collapse(uniq_pkgs, sep = \", \")}"))' \
	-e 'cli_alert_info("Installing them using pak:")' \
	-e "pak::pak(eval(parse(text = glue('c({glue_collapse(double_quote(uniq_pkgs), sep = \", \")})'))))"
