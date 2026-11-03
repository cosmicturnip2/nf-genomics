# nf-science-genomics

Per-sample variant calling with Nextflow, Samtools and GATK
HaplotypeCaller, written while working through Part 2 of Seqera's
[Nextflow for Genomics](https://training.nextflow.io/latest/nf4_science/genomics/)
course.

> **Warning: the data files are empty.**
> The files in `data/bam/` and `data/ref/` exist so that every path in the
> code and configuration stays as written, but each file is empty. The
> original files are available through the course at
> <https://training.nextflow.io/latest/nf4_science/genomics/02_per_sample_variant_calling/>.
> The course keeps them in its GitHub repository,
> [nextflow-io/training](https://github.com/nextflow-io/training), in the
> folder `nf4-science/genomics/data/`.

## What the workflow does

1. Builds a channel of BAM files from one of two inputs:
   - `bam_from_file`: a parameter for a text file that contains BAM paths. 
      In this repo, this will retrieve a csv file. The workflow reads it with
     `splitCsv(header: true)` and takes the path in the `reads_bam` column
      of each row.
   - `bam_from_folder`: a parameter for a folder that contains BAM paths.
      In this repo, this will retrieve `data/bam/*.bam`.

   If both are set, `bam_from_file` is used. If neither is set, the run
   stops with an error.
2. Indexes each BAM file with `samtools index` (process `SAMTOOLS_INDEX`).
   The process emits each BAM file and its index together as a tuple, so
   every sample keeps its own index.
3. Calls variants on each indexed BAM file with `gatk HaplotypeCaller`
   (process `GATK_HAPLOTYPECALLER`), limited to the regions in the
   intervals file.
4. Publishes the BAM files with their indexes to `results/bam/` and the VCF
   files with their indexes to `results/vcf/`.

Nextflow processes the samples in parallel where it can.

## Repository contents

| Path | Contents |
|---|---|
| `genomics.nf` | Workflow: parameters, input channel, process calls, published outputs |
| `nextflow.config` | Turns on Docker; profiles `tutorial` and `turnip` with the default inputs |
| `modules/samtools_index.nf` | Process `SAMTOOLS_INDEX` |
| `modules/gatk_haplotypecaller.nf` | Process `GATK_HAPLOTYPECALLER` |
| `data/samplesheet.csv` | The course's original samplesheet (columns `sample_id`, `reads_bam`) |
| `data/bam/` | Empty files named after the three course BAM files |
| `data/ref/` | Empty files named after the reference FASTA, its index and dictionary, and the intervals file |

## Inputs

| Parameter | Type | Description | `tutorial` profile | `turnip` profile |
|---|---|---|---|---|
| `bam_from_file` | `String` | Samplesheet (CSV) whose `reads_bam` column lists the BAM files | `data/samplesheet.csv` | not set |
| `bam_from_folder` | `String` | Glob pattern that matches the BAM files | not set | `data/bam/*.bam` |
| `reference` | `Path` | Reference genome FASTA | `data/ref/ref.fasta` | `data/ref/ref.fasta` |
| `reference_index` | `Path` | FASTA index | `data/ref/ref.fasta.fai` | `data/ref/ref.fasta.fai` |
| `reference_dict` | `Path` | Sequence dictionary | `data/ref/ref.dict` | `data/ref/ref.dict` |
| `intervals` | `Path` | Regions to call variants in | `data/ref/intervals.bed` | `data/ref/intervals.bed` |

`nextflow.config` builds each profile path from `${projectDir}`, the folder
that holds `genomics.nf`. `bam_from_file` and `bam_from_folder` default to
an empty string, which means "not set". The four accessory files have no
default and must be given.

The paths inside `data/samplesheet.csv` are the course's originals. They
point to the course's GitHub Codespaces environment
(`/workspaces/training/nf4-science/genomics/data/bam/`).

## Outputs

```
results/
├── bam/   reads_<sample>.bam and reads_<sample>.bam.bai for each sample
└── vcf/   reads_<sample>.bam.vcf and reads_<sample>.bam.vcf.idx for each sample
```

By default, Nextflow publishes these files as symbolic links into its
`work/` directory.

## Running the workflow

Requirements: Nextflow 25.10.2 or later with the v2 syntax parser (the
default from Nextflow 26.04), and Docker.

1. Replace the empty files in `data/ref/` with the course originals.
2. Provide the BAM files for the chosen profile:
   - `tutorial`: make the paths in `data/samplesheet.csv` point to the
     original BAM files.
   - `turnip`: replace the empty files in `data/bam/` with the original BAM
     files.
3. From the root of the repository, run one of:

```bash
# BAM files listed in data/samplesheet.csv
nextflow run genomics.nf -profile tutorial

# Every BAM file in data/bam/
nextflow run genomics.nf -profile turnip
```

Containers:

- Samtools 1.20:
  `community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464`
- GATK 4.5.0.0:
  `community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867`

## Credits and licence

This repository is based on the
[Nextflow for Genomics](https://training.nextflow.io/latest/nf4_science/genomics/)
training course, Part 2:
[Per-sample variant calling](https://training.nextflow.io/latest/nf4_science/genomics/02_per_sample_variant_calling/),
by [Seqera](https://seqera.io). Course material: Copyright © 2020-2025,
Seqera, licensed under
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

Changes from the course material:

- `genomics.nf`, `nextflow.config` and the files in `modules/` were written
  by [cosmicturnip2](https://github.com/cosmicturnip2) while following the
  course.
- The course's single `input` parameter is replaced by two:
  `bam_from_file`, which keeps the course's samplesheet input, and
  `bam_from_folder`, an added input that takes a glob pattern of BAM files.
- The course's `test` profile is replaced by the `tutorial` and `turnip`
  profiles, and the published BAM output is named `bam_n_bai` instead of
  the course's `indexed_bam`.
- The files in `data/bam/` and `data/ref/` were replaced with empty files of
  the same names.
- `data/samplesheet.csv` is unchanged.

This repository is licensed under CC BY-NC-SA 4.0; the full text is in
[LICENSE](LICENSE). It is not affiliated with or endorsed by Seqera.
