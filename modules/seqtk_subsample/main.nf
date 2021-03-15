// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

// Random subsample of FASTQ file
process SEQTK_SUBSAMPLE {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    //if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
    //    container 'https://depot.galaxyproject.org/singularity/seqtk:1.2--1'
    //} else {
    container 'quay.io/biocontainers/seqtk:1.3--hed695b0_2'
    //}
    
    input:
      tuple val(meta), path(reads)

    output:
      tuple val(meta), path("*.fastq.gz"), emit: fastq
        
    script:
        def software = getSoftwareName(task.process)
        def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
        def seed = options.seed ? options.seed : "-s100"
        def count = options.count ? options.count : 10000

        //Calculate the number of reads
        readList = reads.collect{it.toString()}
        if(readList.size == 1){
            """
            seqtk sample $seed ${reads[0]} $count $options.args > ${prefix}.fastq
            gzip ${prefix}.fastq
            """
        }
        else {
            """
            seqtk sample $seed ${reads[0]} $count $options.args | gzip > ${prefix}.r1.fastq.gz
            seqtk sample $seed ${reads[1]} $count $options.args | gzip > ${prefix}.r2.fastq.gz
            """
        }
}
