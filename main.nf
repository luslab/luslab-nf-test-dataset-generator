#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

// Check for mode
if(params.mode == "single") {
    Channel
        .fromPath(params.input, checkIfExists: true)
        .map {row -> [ [id : row.simpleName], row ]}
        .set { ch_input }
}

else if (params.mode == "paired") {
    Channel
        .fromFilePairs(params.input, checkIfExists: true)
        .map {row -> [ [id : row[0]], row[1] ]}
        .set { ch_input }
}
else {
    
}
//ch_input | view

// Don't overwrite global params.modules, create a copy instead and use that within the main script.
def modules = params.modules.clone()

def seqtk_options = modules['seqtk_subsample']
seqtk_options.count = params.subset_count
seqtk_options.seed = '-s' + params.seed

include { SEQTK_SUBSAMPLE } from './modules/seqtk_subsample/main' addParams( options: seqtk_options )

workflow {
    SEQTK_SUBSAMPLE( ch_input )
    //SEQTK_SUBSAMPLE.out.fastq | view
}