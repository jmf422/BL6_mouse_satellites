#!/usr/bin/env Rscript

# run this script with:
# Rscript --vanilla mouse_makebed_1Mb.R
# this script makes a bed file with 1 Mb windows, to be used in mouse_simprep_density scripts
# it requires an input of the chromosomes/contigs and their length (tab separated)

contig.summary <- read.delim("mouse39.lengths.txt", header=F)
colnames(contig.summary) <- c("contigname", "length")

options(scipen=999)

make_bed <- function (contig_df, window_size) {
  bed_df <- data.frame(chr="contig0", begin=0, end=0 )
  
  for (i in 1:nrow(contig_df)) { # for each contig
    # calculate number of windows for each contig
    nwindows <- round(contig_df[i,2]/window_size)
    start <- 0
    for (j in 1:nwindows) { # for each window, make a bed file
      
      if (j < nwindows ) { # if not the last window, last window will be larger
        newrow <- data.frame(chr=contig_df[i,1], begin=start, end=start+window_size) # contig name, start position, end position
        bed_df <- rbind(bed_df, newrow)
        start <- start + window_size
      } else {
        newrow <- data.frame (chr=contig_df[i,1], begin=start, end=(contig_df[i,2]-1))
        bed_df <- rbind(bed_df, newrow)
      }
    }
  }
  return(bed_df)
}

mouse39.1Mb.bed <- make_bed(contig.summary, 1000000)

write.table(mouse39.1Mb.bed, file = "mouse39.1Mb.bed", row.names = F, col.names=F, quote=F, sep="\t")
