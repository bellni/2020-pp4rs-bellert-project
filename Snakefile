# # --- Figures --- #
FIGS = glob_wildcards("src/figures/{iFile}.R").iFile

# # --- Everything --- #
rule all:
    input:
        paper = "out/paper/paper.pdf",
        table = "out/tables/regression_table.tex",
        figs = expand("out/figures/{iFigure}.pdf",
                        iFigure = FIGS)


# # --- Paper --- #
rule paper:
    input:
        rmarkdown   = "src/paper/paper.Rmd",
        script      = "src/lib/knit_rmd.R",
        figures     = expand("out/figures/{iFigure}.pdf",
                        iFigure = FIGS),
        table       = "out/tables/regression_table.tex",
    output:
        pdf = "out/paper/paper.pdf",
    shell:
        "Rscript {input.script} {input.rmarkdown} {output.pdf}"

# # --- TABLE --- #
rule make_table:
    input:
        script = "src/tables/regression_table.R",
        ols_res = "out/analysis/ols.Rds",
    output:
        table = "out/tables/regression_table.tex"
    params:
        directory = "out/analysis"
    shell:
        "Rscript {input.script} \
            --filepath {params.directory} \
            --out {output.table}"

# # --- MODELS --- #

rule ols:
    input:
        script = "src/analysis/estimate_ols.R",
        data =  "out/data/cartel_data.csv",
        equation = "src/model-specs/estimating_equation.json",
    output:
        model = "out/analysis/ols.Rds",
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --model {input.equation} \
            --out {output.model}"

rule make_figs:
    input:
        figs = expand("out/figures/{iFigure}.pdf",
                        iFigure = FIGS)

rule figs:
    input:
        script = "src/figures/{iFigure}.R",
        data = "out/data/cartel_data.csv",
    output:
        pdf = "out/figures/{iFigure}.pdf",
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.pdf}"

# --- Data Management --- #

rule prepare_data:
    input:
        script = "src/data-management/prepare_data.R",
        data = "input/data/20190305_duration_struc_all.csv"
    output:
        csv = "out/data/cartel_data.csv"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.csv}"

rule clean:
    shell:
        "rm -r out/*"

rule filegraph:
    input:
        "Snakefile"
    output:
        "filegraph.pdf"
    shell:
        "snakemake --filegraph | dot -Tpdf > {output}"

rule rulegraph:
    input:
        "Snakefile"
    output:
        "rulegraph.pdf"
    shell:
        "snakemake --rulegraph | dot -Tpdf > {output}"

# most advanced steps are at top