#!/bin/bash

set -euo pipefail

PROJECT_DIR="$( cd "$( dirname "$( dirname "$(readlink -f "${BASH_SOURCE[0]}" )" )" )" && pwd )"
source "$PROJECT_DIR/config.config"

export PATH="$bedtools_path:$PATH"

mkdir -p "$data_dir/sites/genes/"

if ! [[ -e "$data_dir/sites/genes/genes.lexicographic.bed" ]]; then

    if ! [[ -e "$data_dir/sites/genes/gencode.gtf.gz" ]]; then
        # Link from <http://www.gencodegenes.org/releases/19.html>
        wget -O "$data_dir/sites/genes/gencode.gtf.gz" "ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz"
    fi

    # TODO: these mostly have `gene_type` of `protein_coding`, `pseudogene`, `lincRNA`, `antisense`, or `miRNA`.  Should I filter on that category?
    gzip -cd "$data_dir/sites/genes/gencode.gtf.gz" |
    # Remove `chr` from the beginning of the lines and print out `chr startpos endpos genename`.
    perl -F'\t' -nale '$F[0] =~ s{chr}{}; print "$F[0]\t$F[3]\t$F[4]\t", m{gene_name "(.*?)";} if $F[2] eq "gene"' \
    > "$data_dir/sites/genes/genes.bed"

    # Bedtools expects chromosomes to be in lexicographic order.
    cat "$data_dir/sites/genes/genes.bed" |
    bedtools sort -i \
    > "$data_dir/sites/genes/genes.lexicographic.bed"
fi

echo done!
