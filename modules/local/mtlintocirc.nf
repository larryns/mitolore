process MTLINTOCIRC {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'file://Apptainer/mttools.sif':
        'biocontainers/YOUR-TOOL-HERE' }"

    input:
    tuple val(meta), path(bam)  // The input alignment file to fix.

    output:
    tuple val(meta), path("*.bam"), emit: bam
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def refName = task.ext.args ?: 'chrM'
    def reflen = task.ext.args2 ?: '16569'
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mt_lintocirc \\
        --ref "${refName}_ext" \\
        --reflen ${reflen} \\
        --targetref ${refName} \\
         ${bam} | samtools addreplacerg -r 'ID:${meta.id}' -r 'SM:${meta.id}' -o ${prefix}.lin.bam -

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mtlintocirc: \$(mt_lintocirc --version |& cut -d' ' -f2)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mtlintocirc: \$(mtlintocirc --version |& cut -d' ' -f2)
    END_VERSIONS
    """
}
