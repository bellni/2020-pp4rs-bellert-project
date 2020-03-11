# # --- Figures --- #
# #FIGS = ["earnings_by_cohort", "education_by_cohort"]
FIGS = glob_wildcards("src/figures/{iFile}.R").iFile
# FIXED_EFFECTS = ["fixed_effects", "no_fixed_effects"]
# INSTRUMENT_SPEC = glob_wildcards("src/model-specs/instrument_{iInst}.json").iInst

# # --- Everything --- #
rule all:
    input:
        paper = "out/paper/paper.pdf",
        table = "out/tables/regression_table.tex",
        figs = expand("out/figures/{iFigure}.pdf",
                        iFigure = FIGS)

# # --- SLIDES --- #
# # rule slides:
# #     input:
# #         rmarkdown = "src/slides/slides.Rmd",
# #         script = "src/lib/knit_rmd.R",
# #         figures = expand(out/figures/{iFigure}.pdf",
# #                         iFigure = FIGS),
# #         table       = "out/tables/regression_table.tex",
# #     output:
# #         pdf = "out/paper/paper.pdf",
# #     shell:
# #         "Rscript {input.script} {input.rmarkdown} {output.pdf}"

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
# rule run_models:
#     input:
#         ols = expand("out/analysis/ols_{iFixedEffect}.Rds",
#                         iFixedEffect = FIXED_EFFECTS),
#         iv = expand("out/analysis/iv_{iInstrument}.Rds",
#                         iInstrument = INSTRUMENT_SPEC)

# rule iv:
#     input:
#         script = "src/analysis/estimate_iv.R",
#         data =  "out/data/angrist_krueger.csv",
#         equation = "src/model-specs/estimating_equation.json",
#         fixedEffects = "src/model-specs/{iFixedEffect}.json",
#         inst    = "src/model-specs/instrument_{iInstrument}.json"
#     output:
#         model = "out/analysis/iv_{iInstrument}.{iFixedEffect}.Rds"
#     shell:
#         "Rscript {input.script} \
#             --data {input.data} \
#             --model {input.equation} \
#             --fixedEffects {input.fixedEffects} \
#             --instruments {input.inst} \
#             --out {output.model}"

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
# rule cohort_summary:
#     input:
#         script = "src/data-management/cohort_summary.R",
#         data = "out/data/angrist_krueger.csv"
#     output:
#         csv = "out/data/cohort_summary.csv"
#     shell:
#         "Rscript {input.script} \
#             --data {input.data}  \
#             --out {output.csv}"

# rule gen_reg_vars:
#     input:
#         script = "src/data-management/gen_reg_vars.R",
#         data = "out/data/angrist_krueger_1991.zip"
#     output:
#         csv = "out/data/angrist_krueger.csv"
#     shell:
#         "Rscript {input.script} \
#             --data {input.data} \
#             --out {output.csv}"

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