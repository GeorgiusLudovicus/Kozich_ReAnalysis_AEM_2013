#!/usr/bin/env bash

# Obtained the raw `fastq.gz` files from https://www.mothur.org/MiSeqDevelopmentData.html
# *Downloaded htps://https://www.mothur.org/MiSeqDevelopmentData/StabilityWMetaG.tar
# *Ran the following from the project's root directory

# wget --no-check-certificate https://www.mothur.org/MiSeqDevelopmentData/StabilityWMetaG.tar
# comand fail to get tar files, use browser to download the data in local machine 
# https://mothur.org/MiSeqDevelopmentData/StabilityWMetaG.tar/
# then use FileZilla to transfered into EC2

tar xvf StabilityWMetaG.tar -C data/raw/
rm StabilityWMetaG.tar


# Obtained the silva reference alignment from the mothur website:

wget https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.seed_v123.tgz
tar xvzf silva.seed_v123.tgz silva.seed_v123.align silva.seed_v123.tax
../../code/mothur/mothur "#get.lineage(fasta=silva.seed_v123.align, taxonomy=silva.seed_v123.tax, taxon=Bacteria);degap.seqs(fasta=silva.seed_v123.pick.align, processors=8)"
mv silva.seed_v123.pick.align silva.seed.align
rm silva.seed_v123.tgz | rm silva.seed_v123.*
rm mothur.*.logfile

# Obtained the RDP reference taxonomy from the mothur website:

wget -N https://mothur.s3.us-east-2.amazonaws.com/wiki/trainset14_032015.pds.tgz
tar xvzf trainset14_032015.pds.tgz
mv trainset14_032015.pds/trainset* .
rm -rf trainset14_032015.pds
rm trainset14_032015.pds.tgz

# Generate a customized version of the SILVA v4 reference dataset
code/mothur/mothur "#pcr.seqs(fasta=data/references/silva.seed.align, start=11894, end=25319, keepdots=F, processors=8)"
mv data/references/silva.seed.pcr.align data/references/silva.v4.align

#Run mothur through the data curation steps
code/mothur/mothur code/get_good_seqs.batch

#Run mock community data through seq.error to sequencing error rate
code/mothur/mothur code/get_error.batch

#Run processed data through clustering and making a shared file
code/mothur/mothur code/get_shared_otus.batch

#Run data to plot NMDS ordination
code/mothur/mothur code/get_nmds_data.batch

#Calculkate the number of OTUS per sample when rarefying to 3000 sequences per sample
code/mothur/mothur code/get_sobs_data.batch


#Construct NMDS png file
R -e "source('code/plot_nmds.R'); plot_nmds('data/mothur/stability.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.unique_list.thetayc.0.03.lt.ave.nmds.axes')"

