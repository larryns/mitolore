
process EXTENDREF {
    tag "$meta"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'file://Apptainer/mttools.sif':
        'biocontainers/YOUR-TOOL-HERE' }"

    input:
    tuple val(meta), path(fasta)    // Input fasta reference to extend
    val(extlen)                     // Amount to extend the reference

    output:
    tuple val(meta), path("*.fa.gz"), emit: fasta
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}_ext"

    """
    samtools faidx ${fasta} ${args} | \\
        extend_ref --ext ${extlen} --header ${args}_ext | \\
        gzip -c > ${prefix}.fa.gz \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        extendref: \$(extend_ref --version |cut -d' ' -f2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fa.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        extendref: \$(extend_ref --version |& cut -d' ' -f2)
    END_VERSIONS
    """
}
