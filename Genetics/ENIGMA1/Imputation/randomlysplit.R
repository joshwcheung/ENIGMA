# Code to randomly select 300 subjects from a study population
#	and output a formatted list to be used with plink
#
# Written by Derrek Hibar (dhibar@ucla.edu) for the ENIGMA Consortium

all = read.table("4selectsubset.raw", header=T, sep=' ');
suball = all[,1:2];

if (nrow(suball) < 500){
	cat("You have fewer than 500 subjects. Outputting a formatted list with all subjects present.\n");
	write.table(suball, file="referenceIDs.list", row.names=F, col.names=F, sep='\t');
} else if (length(unique(suball[,1])) > 300){
	N = sample(unique(suball[,1]), 300);
	collection = rep(as.character(NA), 300);
	cat("Doing quality control check...\n");
	for (x in 1:length(N)){
		lastsub = NULL;
		for (i in 1:nrow(suball)){
			if(suball[i,1] == N[x]){
				lastsub = paste(suball[i,1], "\t", suball[i,2], sep='');
			}
		}
		collection[x] = lastsub;
	}
	if(length(collection) != 300){
		stop("There was an error. The file outputted does not contain 300 subjects.\n");
	}
	write(collection, file="referenceIDs.list", sep="\n");
} else {
	cat("You're sample contains related individuals. When randomly selecting unrelated subjects, they total fewer than 300. Therefore, the outputted list will contain 300 randomly selected individuals which may contain some amount of relatedness.\n");
	N = sample(suball[,2], 300);
	collection = rep(as.character(NA), 300);
	cat("Doing quality control check...\n");
	for (x in 1:length(N)){
		lastsub = NULL;	
		for (i in 1:nrow(suball)){
			if(suball[i,2] == N[x]){
				lastsub = paste(suball[i,1], "\t", suball[i,2], sep='');
			}

		}
		collection[x] = lastsub;
	}
	
	if(length(collection) != 300){
		stop("There was an error. The file outputted does not contain 300 subjects.\n");
	}
	write(collection, file="referenceIDs.list", sep="\n");
}