Introduction
============

This markdown processes salmon Age, Sex, Length (ASL) data from the
Prince William Sound and Copper River areas. These files are fixed width
with a varying fixed-width structure within the file. Longer, 52
character width lines contain sample event information including the
sample date, location, gear, project type. Shorter, 26 character width
lines contain sample information, including the sex, length, and age.

This file structure arises from the way these data are collected. To
gather age/sex/length samples, scales are taken from fish out of a
representative sample caught at an ASL sampling project. These projects
can be from escapement enumeration projects, commercial fishing
operations, or hatchery operations. Scales from fish taken during a
sampling event are placed on "scale cards," along with other information
about both the sampling event (such as the date and location) and the
fish itself (such as length and sex). For Prince William Sound/Copper
River salmon, all chinook and coho have a maximum of 10 fish sampled per
scale card, whereas sockeye and chum salmon have a maximum of 40 fish
sampled per card (pink salmon too, but they are rarely sampled). This is
because Chinook and coho lose scales easily and therefore a larger
portion of the sampled scales are “regenerated” and are not useable. To
get around this, up to 4 scales need to be pulled from each Chinook or
coho in the hope of finding a single scale that can be successfully
aged. The PWS scale cards have 4 rows and 10 columns: for sockeye and
chum, each of the 40 positions get a scale from a single fish; for
Chinook and coho, each column gets 3-4 scales from a single fish.

The sample event information lines (52 character) in these files,
therefore, are information that are recorded at the top of each sample
card about the sampling event, and the sample lines (26 character) are
information derived from the scale samples and associated information.
Together, these represent the information from an entire card. In this
dataset, each file contains information from anywhere between 2 and 30+
cards.

Below is a view of data from 3 cards within the same file:

![](images/PWS_structure.jpg)

The positions of information within the fixed-width format is explained
in more detail here:

![](images/AscIIHeaderinfo.jpg)

In addition to the information within the file, in the form of the
sample event information and the sample information, some duplicate
information is contained within the filenames themselves. This
information is derived from what is in the file. However, it does not
always agree exactly with the information contained within the file,
causing problems that will be dealt with later in this analysis. Despite
the occasional contradiction, the filename information is occasionally
helpful, especially given that some aspects of the sample event
information have unknown provenance. Although the provenance chain is
lost on these pieces of information, the filename information can
sometimes be used to intuit their meaning.

Below is a description of the file format and codes contained within the
filenames.

![](images/filanameinfo.jpg)

Data Extraction
===============

First, all of the data from the files is extracted into a large list of
character lines.

    library(stringi)
    library(dplyr)
    library(lubridate)
    library(kableExtra)
    library(knitr)
    library(data.table)
    path <- '/home/sjclark/ASL/Originals/PWS_CopperRiver/As Aged/'
    files <- dir(path, recursive = T)
    #remove header info file
    i <- grep("*HEADER",files)
    files <- files[-i]

    lines <- lapply(file.path(path,files),scan, what = 'character', sep = '\n', quiet = T)

Sample Event Extraction
-----------------------

Now the sample event lines and the sample lines need to be separated,
since they have to be parsed differently. First the filenames are pasted
onto the ends of the text lines that correspond to them in order to
track which row came from which file. The data are then unlisted.

    lines2 <- c()
    for (i in 1:length(files)){
        lines2[[i]] <- paste(lines[[i]], files[i], sep = ',')
    }
    #unlist all the data
    lines2 <- unlist(lines2)

### QA Step: Removing supurious header text

Before going further, since every valid data line should start with a
number, lines that start with characters are searched for and removed.

    i <- grep('^[A-Z]', lines2, ignore.case = T)
    lines2 <- lines2[-i]

Now a quick check to make sure that every line has a data file attached
to it, and removing the filenames into their own vector (which is the
same length as the total number of lines).

    test <- as.data.frame(stri_split_fixed(lines2, ',', simplify = T))
    filenames <- test$V2
    lines <- as.character(test$V1)
    rm(test, lines2)

The sample event information lines need to be extracted from the sample
lines. Luckily, all of the sample event lines start with '00', so they
can be found by searching for '00' at the beginning of the line. They
are then extracted into a dataframe with columns based on the parsing
information shown in the introduction. Filenames are also added into the
dataframe to be able to track which file the data came from.

    #rm(test)
    #find lines starting with "00" (indicating sample event information)
     is <-grep("^00", lines, fixed = F)
     
     
     #extract sample event information
     infolines <- lines[is]
     info <- c()
     info$LocationCode <- substr(infolines, 13,26)
     info$SpeciesID <- substr(infolines, 11,11)
     info$District <- as.numeric(substr(infolines, 13,15))
     info$Sub.District <- as.numeric(substr(infolines, 17,18))
     info$sampleDate <- substr(infolines,31,38)
     info$period <- as.numeric(substr(infolines, 40,41))
     info$gearID <- as.numeric(substr(infolines, 42,43))
     info$Mesh.Size <- as.numeric(substr(infolines, 44,45))
     info$lengthtypeID <- as.numeric(substr(infolines, 46, 46))
     info$cardNo <- as.numeric(substr(infolines, 50,52))
     
     info <- data.frame(info, stringsAsFactors = F)
     info$filename <- filenames[is]

### QA Step: Checking species and dates

Species and date information is checked to ensure parsing was done
correctly. The species code should be 1, 2, 3, 4, or 5.

    i <- which(info$SpeciesID != '1' & info$SpeciesID != '2'&info$SpeciesID != '3'&info$SpeciesID != '4'&info$SpeciesID != '5')
    print(paste(infolines[i], info$filename[i], sep = ';'))

    ##  [1] "00000000000 212-00-000-800  1 08/20/80 1103  2     3;1980/3C80CDMX.ALL" 
    ##  [2] "00000000000 212-00-000-800  1 08/20/80 1103  2     4;1980/3C80CDMX.ALL" 
    ##  [3] "00000000000 212-00-000-800  1 08/22/80 1103  2     5;1980/3C80CDMX.ALL" 
    ##  [4] "00000000000 212-00-000-800  1 08/22/80 1103  2     6;1980/3C80CDMX.ALL" 
    ##  [5] "00000000000 212-00-000-800  1 08/22/80 1103  2     7;1980/3C80CDMX.ALL" 
    ##  [6] "00000000000 212-30-000-800  1 08/29/80 1203  2     8;1980/3C80CDMX.ALL" 
    ##  [7] "00000000000 212-30-000-800  1 09/03/80 1303  2     9;1980/3C80CDMX.ALL" 
    ##  [8] "00000000000 212-30-000-800  1 09/05/80 1303  2    10;1980/3C80CDMX.ALL" 
    ##  [9] "00000000000 212-10-000-800  1 09/20/80 1503  2    11;1980/3C80CDMX.ALL" 
    ## [10] "00000000 404221-20-035-000  4 08/11/80   00  0    01;1980/5p80e_ea.all" 
    ## [11] "00000000000 212-10-000-800  1 08/25/82 2703  2     6;1982/3C82CDMX.ALL" 
    ## [12] "00000000000 212-30-000-800  1 08/27/82 2703  2     7;1982/3C82CDMX.ALL" 
    ## [13] "00050675 4  225-21-503-000  8 07/11/86   12  2   010;1986/5P86BXMB.ALL" 
    ## [14] "00050675 4  225-21-503-000  8 07/11/86   12  2   010;1986/5P86BXMB.ALL" 
    ## [15] "00050675 4  225-21-503-000  8 07/11/86   12  2   010;1986/5P86BXMB.ALL" 
    ## [16] "00050675 4  225-21-503-000  8 07/11/86   12  2   010;1986/5P86BXMB.ALL" 
    ## [17] "00086973 4  225-21-000-800  1 07/20/89   01  2    24;1989/5P89HPMB.ALL" 
    ## [18] "0000000045 221-00-000-800  1 07/18/91 0501  2   001;1991/5P91CPMX.ALL"  
    ## [19] "00000000040 212-30-925-340  4  8/26/93   02  2     2;1993/2C93EBLM.ALL" 
    ## [20] "00000000040 212-30-925-340  4  8/26/93   02  2     3;1993/2C93EBLM.ALL" 
    ## [21] "00000000040 212-30-925-340  4  8/26/93   02  2     4;1993/2C93EBLM.ALL" 
    ## [22] "00000000040 212-30-925-340  4  8/26/93   02  2     5;1993/2C93EBLM.ALL" 
    ## [23] "00000000040 212-30-925-340  4  8/26/93   02  2     6;1993/2C93EBLM.ALL" 
    ## [24] "00000000040 212-30-925-340  4  8/26/93   02  2     7;1993/2C93EBLM.ALL" 
    ## [25] "00000000040 212-30-925-340  4  8/26/93   02  2     8;1993/2C93EBLM.ALL" 
    ## [26] "00000000040 212-30-925-340  4  8/26/93   02  2     9;1993/2C93EBLM.ALL" 
    ## [27] "00000000040 212-30-925-340  4  8/26/93   02  2    10;1993/2C93EBLM.ALL" 
    ## [28] "00000000040 212-30-925-340  4  8/26/93   02  2    11;1993/2C93EBLM.ALL" 
    ## [29] "00000000040 212-30-925-340  4  8/26/93   02  2    12;1993/2C93EBLM.ALL" 
    ## [30] "00000000040 212-30-925-340  4  8/26/93   02  2    13;1993/2C93EBLM.ALL" 
    ## [31] "00000000040 212-30-925-340  4  8/26/93   02  2    14;1993/2C93EBLM.ALL" 
    ## [32] "0000000004  212-10-022-211  4  8/06/93   02  2   028;1993/2C93EXSB.ALL" 
    ## [33] "00000000040 222-00-000-000  1 08/04/94 1401  2     1;1994/5P94CPNO.ALL" 
    ## [34] "00000000040 222-00-000-000  1 08/04/94 1401  2     2;1994/5P94CPNO.ALL" 
    ## [35] "00000000040 222-00-000-000  1 08/04/94 1401  2     3;1994/5P94CPNO.ALL" 
    ## [36] "00000000040 222-00-000-000  1 08/04/94 1401  2     4;1994/5P94CPNO.ALL" 
    ## [37] "00000000040 222-00-000-000  1 08/04/94 1401  2     5;1994/5P94CPNO.ALL" 
    ## [38] "00000000040 222-00-000-000  1 08/04/94 1401  2     6;1994/5P94CPNO.ALL" 
    ## [39] "00000000040 222-00-000-000  1 08/04/94 1401  2     7;1994/5P94CPNO.ALL" 
    ## [40] "00000000040 222-00-000-000  1 08/04/94 1401  2     8;1994/5P94CPNO.ALL" 
    ## [41] "00000000040 222-00-000-000  1 08/04/94 1401  2     9;1994/5P94CPNO.ALL" 
    ## [42] "00000000040 222-00-000-000  1 08/04/94 1401  2    10;1994/5P94CPNO.ALL" 
    ## [43] "000000000402221-60-000-000  1 09/01/94   12  2     3;1994/5P94XXSG.ALL" 
    ## [44] "00000      1 212-20-100-700  9 06/18/95   13  7   019;1995/1C95PNCH.ALL"
    ## [45] "00000      1 212-20-100-700  9 06/22/95   13  7   020;1995/1C95PNCH.ALL"
    ## [46] "000000000402216-10-022-211  4 07/18/03 0002  2  0007;2003/2C03EBSB.ALL" 
    ## [47] "00000000450323-00-000-000  1 06/18/08 0403  2  0027;2008/5P08CDCO.ALL"

These sample event information lines appear to either have no species
info at all, or it is in the wrong place in the line. These problem
files are saved in a dataframe to be examined in more detail later.

    problems <- data.frame(file = unique(info$filename[i]), problem = 'event info - species')

The dates need to be reformatted and checked as well.

    info$sampleDate <- as.Date(info$sampleDate, format = '%m/%d/%y')
    i <- which(year(info$sampleDate) > 2016)
    info$sampleDate[i] <- info$sampleDate[i] - 100*365.25
    i <- which(is.na(info$sampleDate) == T)
    print(paste(infolines[i], info$filename[i], sep = ';'))

    ##  [1] "00051917 43 212-00-000-800  1 19/19/85   03  2    50;1985/3C85CDMX.ALL"    
    ##  [2] "00147305 42 212-30-917-391  4 07/09/     02  2    12;1990/2C90EBTN.ALL"    
    ##  [3] "00147203042 212-20-100-700  9   /  /90 0513  2    29;1990/2C90PNUC.NSX"    
    ##  [4] "00047975 45 225-00-000-800  1 06/28/   0104  2    25;1990/5P90CGES.ALL"    
    ##  [5] "00147580 45 229-00-000-800  1   /  /         2     3;1990/5P90CPNO.ALL"    
    ##  [6] "00000000045 225-00-000-800  1 16/25/91  314  2    33;1991/5P91CGES.ALL"    
    ##  [7] "00000000041 212-20-100-700  9   /  /93   13  2     6;1993/1C93PNCH.ALL"    
    ##  [8] "00000000041 212-20-100-700  9   /  /93   13  2     8;1993/1C93PNCH.ALL"    
    ##  [9] "00000000041 212-20-100-700  9   /  /93   13  2    12;1993/1C93PNCH.ALL"    
    ## [10] "00000000 42 225-21-000-000-000  1 07/11/93   01  2   021;1993/2P93HPMB.ALL"
    ## [11] "00000000 42 225-21-000-000-000  1 07/11/93   01  2   022;1993/2P93HPMB.ALL"

There are clearly some mistakes and missing information in these lines.
This is added to the dataframe with a description of the problem.

    problems2 <- data.frame(file = unique(info$filename[i]), problem = 'event info - dates')
    problems <- rbind(problems, problems2)
    rm(problems2)

To figure out what is going on exactly with these files, the original
text files must be opened and examined. Here is more detailed
information on these problems after examining each file individually,
with a description of the solution.

    problems <- read.csv('/home/sjclark/ASL/PWS_processing_corrections/PWS_problems_SpeciesDates_cards.csv', stringsAsFactors = F)
    kable(problems, row.names = F, format = 'html') %>% 
            kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) #%>%

<table class="table table-striped table-hover table-condensed table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
file
</th>
<th style="text-align:left;">
problem
</th>
<th style="text-align:left;">
problem\_detailed
</th>
<th style="text-align:left;">
solution\_description
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
1980/3C80CDMX.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1980/5p80e\_ea.all
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1982/3C82CDMX.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1985/3C85CDMX.ALL
</td>
<td style="text-align:left;">
event info - dates
</td>
<td style="text-align:left;">
typo reads "19/19/85" based on other data should read "09/09/85"
</td>
<td style="text-align:left;">
find and replace "19/19/85" with "09/19/85"
</td>
</tr>
<tr>
<td style="text-align:left;">
1986/5P86BXMB.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1989/5P89HPMB.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1990/2C90EBTN.ALL
</td>
<td style="text-align:left;">
event info - dates
</td>
<td style="text-align:left;">
typo reads "07/09/ " based on other data should read "07/09/90"
</td>
<td style="text-align:left;">
find and replace "07/09/ " with "07/09/90"
</td>
</tr>
<tr>
<td style="text-align:left;">
1990/2C90PNUC.NSX
</td>
<td style="text-align:left;">
event info - dates
</td>
<td style="text-align:left;">
no date information available for one card: reads " / /90"
</td>
<td style="text-align:left;">
find and replace " / /90" with "01/01/90"
</td>
</tr>
<tr>
<td style="text-align:left;">
1990/5P90CGES.ALL
</td>
<td style="text-align:left;">
event info - dates
</td>
<td style="text-align:left;">
typeo reads "06/28/ " should read "06/28/90"
</td>
<td style="text-align:left;">
find and replace "06/28/ " with "06/28/90"
</td>
</tr>
<tr>
<td style="text-align:left;">
1990/5P90CPNO.ALL
</td>
<td style="text-align:left;">
event info - dates
</td>
<td style="text-align:left;">
no date information available for one card: reads " / / "
</td>
<td style="text-align:left;">
find and replace " / / " with "01/01/90"
</td>
</tr>
<tr>
<td style="text-align:left;">
1991/5P91CGES.ALL
</td>
<td style="text-align:left;">
event info - dates
</td>
<td style="text-align:left;">
typeo reads "16/25/91" should read "06/25/91"
</td>
<td style="text-align:left;">
find and replace "16/25/91" with "06/25/91"
</td>
</tr>
<tr>
<td style="text-align:left;">
1991/5P91CPMX.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
card 1: information line is off by one digit
</td>
<td style="text-align:left;">
gsub '0000000045 221-00-000-800' for '00000000045 221-00-000-800'
</td>
</tr>
<tr>
<td style="text-align:left;">
1993/1C93PNCH.ALL
</td>
<td style="text-align:left;">
event info - dates
</td>
<td style="text-align:left;">
no date information available for three cards: reads " / /93"
</td>
<td style="text-align:left;">
find and replace " / /93" with "01/01/93"
</td>
</tr>
<tr>
<td style="text-align:left;">
1993/2C93EBLM.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1993/2C93EXSB.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1993/2P93HPMB.ALL
</td>
<td style="text-align:left;">
event info - dates
</td>
<td style="text-align:left;">
location code has trailing '-000' that needs to be removed in cards 021
and 022
</td>
<td style="text-align:left;">
gsub '225-21-000-000-000' for '225-21-000-000'
</td>
</tr>
<tr>
<td style="text-align:left;">
1994/5P94CPNO.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1994/5P94XXSG.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1995/1C95PNCH.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
2003/2C03EBSB.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
no species info in some sample event lines
</td>
<td style="text-align:left;">
use species from file name since other sample info lines agree with
filename
</td>
</tr>
<tr>
<td style="text-align:left;">
2008/5P08CDCO.ALL
</td>
<td style="text-align:left;">
event info - species
</td>
<td style="text-align:left;">
card 27: information line is off by one digit
</td>
<td style="text-align:left;">
gsub '00000000450323-00-000-000' for '00000000045 223-00-000-000'
</td>
</tr>
</tbody>
</table>
To fix these problems, the original info lines with problems must be
found and several bad date and species/location strings replaced. To
make this easier, `gsub` is used on all of the bad portions of the file
info lines, and the sample event information lines are reprocessed from
scratch exactly like what was done above.

    infolines <- gsub('19/19/85', '09/19/85', infolines)
    infolines <- gsub('07/09/  ', '07/09/90', infolines)
    infolines <- gsub('  /  /90', '01/01/90', infolines)
    infolines <- gsub('16/25/91', '06/25/91', infolines)
    infolines <- gsub('  /  /93', '01/01/93', infolines)
    infolines <- gsub('0000000045 221-00-000-800  1 07/18/91 0501  2   001', '0000000045 221-00-000-800  1 07/18/91 0501  2   001', infolines)
    infolines <- gsub('225-21-000-000-000', '225-21-000-000', infolines)
    infolines <- gsub('00000000450323-00-000-000', '00000000045 223-00-000-000', infolines)

     info$LocationCode <- substr(infolines, 13,26)
     info$SpeciesID <- substr(infolines, 11,11)
     info$District <- as.numeric(substr(infolines, 13,15))
     info$Sub.District <- as.numeric(substr(infolines, 17,18))
     info$projectcodeID <- substr(infolines, 28,29)
     info$sampleDate <- substr(infolines,31,38)
     info$period <- as.numeric(substr(infolines, 40,41))
     info$gearID <- as.numeric(substr(infolines, 42,43))
     info$Mesh.Size <- as.numeric(substr(infolines, 44,45))
     info$lengthtypeID <- as.numeric(substr(infolines, 46, 46))
     info$cardNo <- as.numeric(substr(infolines, 50,52))
     info <- data.frame(info, stringsAsFactors = F)
     info$filename <- filenames[is]

Next, the solution to replace missing/nonsensical species information
with species information from the filename is applied. This is done for
all of the files that have that problem. Note that it is acceptable to
replace ALL of the data from each file's sample event information,
whether there was a problem or not, with the species info from the
filename, since it was determined that all of the sample event lines
agree with the filename in these files.

    i <- which(problems$solution_description == 'use species from file name since other sample info lines agree with filename')
    files_speciesreplace <- problems$file[i]
    i2 <- c()
    for (z in 1:length(files_speciesreplace)){
     i2[[z]] <- which(info$filename == files_speciesreplace[z])   
    }
    i2 <- unlist(i2)
    info$filename <- as.character(info$filename)
    info$SpeciesID[i2] <- as.numeric(substr(info$filename[i2], 6,6))

Individual Sample Extraction
----------------------------

Now the individual sample (scale information) is extracted from the
short lines in a similar way to how the sample event information was
extracted. This is all according to the parsing document shown in the
introduction.

    #extract sample information
    data_t <- lines[-is]
    data <- c()
    data$fishNum <- as.numeric(substr(data_t, 1,2))
    data$sexID <- as.numeric(substr(data_t, 4,4))
    data$Length <- as.numeric(substr(data_t, 6,9))
    data$Fresh.Water.Age <- as.numeric(substr(data_t, 11,11))
    data$Salt.Water.Age <- as.numeric(substr(data_t, 12,12))
    data$ageerrorID <- as.numeric(substr(data_t, 15,15))
    data <- as.data.frame(data)

Of course, the individual sample information data frame is much longer
than the sample event information data frame, but it is necessary to
populate all of the sample event information alongside each individual
sample. This is done by repeating the sample event information according
to how many individual samples there are per sample event. The saved
index vector `is` is used here - note that this comes from the search
for rows from the original data starting with '00', which are the sample
event lines.

Once the expanded sample event information is created, it is bound to
the individual sample information, creating a single dataframe.

    is2 <- c(is, length(lines)+1) #indices of info rows + last row
    r <- diff(is2) #find number of rows each info row represents

    info <- info[rep(seq_len(nrow(info)), times = r-1), ] #repeat info according to rep scheme defined by the number of rows each info row represents
    info <- data.frame(info, stringsAsFactors = F) #create expanded info data frame

    data <- cbind(data,info) #bind the two

### Code Translation

To make this dataset more human readble, the numerous codes outlined in
the parsing documents shown in the introduction need to be converted
into their more descriptive words. This is done by creating a number of
lookup dataframes for each coded field and using a left join to join
these lookup tables to the main data frame.

    sex_code <- data.frame(sexID = c(1,2,3,0,5), Sex = c('male', 'female', 'unknown','unknown', 'unknown'))
    gear_code <- data.frame(gearID = c(19, 0:14, 16:18, 31, 43),
                            Gear = c('weir', 'trap', 'seine', 'seine', 'gillnet', 'gillnet', 'troll', 'longline', 'trawl', 'fishwheel', 'pots', 'sport hook and line', 'seine',
                                     'handpicked or carcass', 'dip net', 'weir', 'electrofishing', 'trawl', 'handpicked or carcass', 'gillnet and seine', 'gillnet'))
    length_code <- data.frame(lengthtypeID = c(1:7), Length.Measurement.Type = c('tip of snout to fork of tail', 'mid-eye to fork of tail', 'post-orbit to fork of tail', 'mid-eye to hypural plate',
                                                      'post orbit to hypural plate', 'mid-eye to posterior insertion of anal fin', 'mid-eye to fork of tail'))
    age_error_code <- data.frame(ageerrorID = c(1:9), Age.Error = c('otolith', 'inverted', 'regenerated', 'illegible', 'missing', 'resorbed', 'wrong species', 'not preferred scale', 'vertebrae'))

    species_code <- data.frame(SpeciesID = c('1','2','3','4','5'), Species = c('chinook', 'sockeye', 'coho', 'pink', 'chum'))
    #project names are modified slightly from original definitions to reflect overall SASAP project code vocabulary
    project_code <- data.frame(projectcodeID = c('1','2','3','4','5','6','7','8','9','10'), ASLProjectType = c('commercial catch', 'subsistence catch', 'escapement', 'escapement', 'test fishing', 'sport catch', 'sport catch', 'brood stock recovery', 'personal use', 'hatchery cost recovery'))

    data <- left_join(data, sex_code)
    data <- left_join(data, gear_code)
    data <- left_join(data, length_code)
    data <- left_join(data, age_error_code)
    data <- left_join(data, species_code)
    data <- left_join(data, project_code)

Filename Info Extraction
------------------------

The last bit of data that needs to be extracted are the data that come
from the filenames themselves. These are parsed according to the parsing
document shown in the introduction.

    filenames_original <- filenames
    filenames <- filenames[-is]; filenames <- as.character(filenames)

    fileinfo <-  c()
    fileinfo$Area_filename <- substr(filenames, 7,7); fileinfo$Area_filename <- tolower(fileinfo$Area_filename)
    fileinfo$Gear_filename <- substr(filenames, 11,11);fileinfo$Gear_filename <- tolower(fileinfo$Gear_filename)
    fileinfo$Species_filename <- substr(filenames, 6,6)
    fileinfo$Location_filename <- paste(substr(filenames, 10,10),substr(filenames, 12,13), sep = '')
    fileinfo$ASLProjectType_filename <- tolower(substr(filenames, 10,10))

Again, lookup tables are created to translate codes to more
human-readable text.

    gear_codef <- data.frame(Gear_filename = c('p', 'd', 's', 'g', 'n', 'f', 'b', 'w', 'c', 'x', 'r'),
                            GearF = c('purse seine', 'drift gillnet','set gillnet', 'gillnet','dipnet', 'fish wheel', 'beach seine', 'weir', 'carcass', 'handpicked, mixed, unknown', 'rod and reel'))
    species_codef <- data.frame(Species_filename = c('1','2','3','4','5'), SpeciesF = c('chinook', 'sockeye', 'coho', 'pink', 'chum'))
    area_codef <- data.frame(Area_filename = c('c','b','y','p'), AreaF = c('Copper River', 'Bering River', 'Yakutat', 'Prince William Sound'))
    project_codef <- data.frame(ASLProjectType_filename = c('c','s','p','h','t','r','e','b','x','d'), ASLProjectTypeF = c('commercial catch','subsistence catch','personal use','hatchery cost recovery','test fish','sport fish','escapement','brood stock','brood excess', 'unknown'))
    location_codef <- read.csv('/home/sjclark/ASL/PWS_processing_corrections/PWS_filenameLocationCodes_original.csv', stringsAsFactors = F)
    location_codef$Location_filename <- tolower(location_codef$Location_filename)

These lookup tables are joined to the file information data table, and
the old code columns are removed.

    fileinfo <- data.frame(fileinfo, stringsAsFactors = F)

    data <- cbind(data,fileinfo)

    data <- left_join(data, gear_codef)
    data <- left_join(data, species_codef)
    data <- left_join(data, area_codef)
    data <- left_join(data, project_codef)
    data$Location_filename <- tolower(data$Location_filename); data <- left_join(data, location_codef)

    data$Area_filename <- NULL; data$Gear_filename <- NULL; data$Species_filename <- NULL; data$ASLProjectType_filename <- NULL; data$Location_filename <- NULL
    #convert factors to characters
    i <- sapply(data, is.factor)
    data[i] <- lapply(data[i], as.character)

### QA Step: Checking filename information joins

Here, we check to see what information may have been missing from our
lookup tables. Information didn't join to a code above should be
examined, so first NA values in the Area, Gear, Species, and
ASLProjectType columns are found, and the original filenames written to
a dataframe.

    i <- which(is.na(data$AreaF) == T |  is.na(data$GearF) == T |  is.na(data$SpeciesF) == T | is.na(data$ASLProjectTypeF) == T)

    problems <- data.frame(file = unique(data$filename[i]), problem = 'filename')

After looking at the files individually, another solutions data frame is
created, and shown below.

    problems <- read.csv('/home/sjclark/ASL/PWS_processing_corrections/FileNameProblems.csv', stringsAsFactors = F)
    problems <- data.table(problems)
    #summarize these for display since so many are the same
    problems_sum <- problems[, .(files = paste(unique(file), collapse = ';')), by = .(problem, problem_detailed, solution_description, solution_code)]
    kable(problems_sum, row.names = F, format = 'html') %>% 
            kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) #%>%

<table class="table table-striped table-hover table-condensed table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
problem
</th>
<th style="text-align:left;">
problem\_detailed
</th>
<th style="text-align:left;">
solution\_description
</th>
<th style="text-align:right;">
solution\_code
</th>
<th style="text-align:left;">
files
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
filename
</td>
<td style="text-align:left;">
gear information blank
</td>
<td style="text-align:left;">
use gear information from sample information
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
1962/5p62e\_ea.all;1964/5p64e\_co.all;1964/5p64e\_ea.all;1964/5p64e\_mo.all;1964/5p64e\_no.all;1964/5p64e\_nw.all;1964/5p64e\_se.all;1965/5p65e\_co.all;1965/5p65e\_ea.all;1965/5p65e\_mo.all;1965/5p65e\_nw.all;1965/5p65e\_se.all;1966/5p66e\_co.all;1966/5p66e\_ea.all;1966/5p66e\_mo.all;1966/5p66e\_no.all;1966/5p66e\_nw.all;1966/5p66e\_se.all;1969/5p69e\_co.all;1969/5p69e\_ea.all;1969/5p69e\_no.all;1969/5p69e\_se.all;1970/5p70e\_co.all;1970/5p70e\_ea.all;1970/5p70e\_mo.all;1970/5p70e\_no.all;1970/5p70e\_nw.all;1970/5p70e\_se.all;1971/5p71e\_co.all;1971/5p71e\_ea.all;1971/5p71e\_mo.all;1971/5p71e\_no.all;1971/5p71e\_nw.all;1971/5p71e\_se.all;1972/5p72e\_co.all;1972/5p72e\_ea.all;1972/5p72e\_mo.all;1972/5p72e\_no.all;1972/5p72e\_nw.all;1972/5p72e\_se.all;1972/5p72e\_sw.all;1973/5p73e\_ea.all;1973/5p73e\_mo.all;1973/5p73e\_no.all;1973/5p73e\_nw.all;1973/5p73e\_se.all;1973/5p73e\_sw.all;1974/5p74e\_co.all;1974/5p74e\_ea.all;1974/5p74e\_no.all;1974/5p74e\_nw.all;1974/5p74e\_se.all;1975/5p75e\_ea.all;1975/5p75e\_no.all;1975/5p75e\_se.all;1977/5p77e\_ea.all;1977/5p77e\_no.all;1978/5p78e\_co.all;1978/5p78e\_ea.all;1978/5p78e\_no.all;1978/5p78e\_nw.all;1980/5p80e\_ea.all;1980/5p80e\_no.all;1981/5p81e\_wr.all;1983/5p83e\_wr.all
</td>
</tr>
<tr>
<td style="text-align:left;">
filename
</td>
<td style="text-align:left;">
region information blank
</td>
<td style="text-align:left;">
add Region == 'Bering River', since location information in sample
information indicates this is the region
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
1973/3\_73CDMX.ALL
</td>
</tr>
<tr>
<td style="text-align:left;">
filename
</td>
<td style="text-align:left;">
unknown file naming system
</td>
<td style="text-align:left;">
replace all filename information with NA
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
1990/PKTMP000.ALL;1992/ESHTST12.ALL;1992/ESHTST34.ALL;1992/ESHTST56.ALL;1992/ESTST910.ALL;2015/2C15ETL.ALL
</td>
</tr>
</tbody>
</table>
First the issue with missing gear information is fixed. The lines in the
main data frame that correspond to these files are found, then the
information in the GearF (gear derived from filename) column is replaced
with information from the Gear (gear derived from file) column.

    i <- which(problems$solution_code == 1)
    files_gearreplace <- problems$file[i]
    i2 <- c()
    for (z in 1:length(files_gearreplace)){
     i2[[z]] <- which(data$filename == files_gearreplace[z])   
    }
    i2 <- unlist(i2)
    data$filename <- as.character(data$filename)
    data$GearF[i2] <- data$Gear[i2]

For problem 2, the file with no Area information, based on the district
information within the file, the Area is clearly "Bering River."

    i <- which(problems$solution_code == 2)
    files_replace <- problems$file[i]
    i2 <- which(data$filename == files_replace)   

    data$AreaF[i2] <- 'Bering River'

Finally, problem 3, the files with unknown filename conventions. For
these, the gear, species, and project information must be taken from the
file itself. The values in these filename columns are replaced with
those from the file derived data.

    i <- which(problems$solution_code == 3)
    files_replace <- problems$file[i]
    i2 <- c()
    for (z in 1:length(files_replace)){
     i2[[z]] <- which(data$filename == files_replace[z])   
    }
    i2 <- unlist(i2)

    data$GearF[i2] <- data$Gear[i2]
    data$SpeciesF[i2] <- data$Species[i2]
    data$ASLProjectTypeF[i2] <- data$ASLProjectType[i2]

Unfortunately, Area only comes from the filename, so the above solution
cannot be used for those files, but the district information can be used
to determine the area. Here, rows with no Area information are found,
and the unique districts are shown.

    i2 <- which(is.na(data$AreaF) == T)
    print(unique(data$District[i2]))

    ## [1] 212 225 223

District 212 is Copper River, while 225 and 223 are Prince William
Sound. The areas are assigned accordingly.

    data$AreaF[which(is.na(data$AreaF) == T & data$District == 212)] <- "Copper River"
    data$AreaF[which(is.na(data$AreaF) == T & data$District == 225)] <- "Prince William Sound"
    data$AreaF[which(is.na(data$AreaF) == T & data$District == 223)] <- "Prince William Sound"

### QA Step: Do two species sources agree?

As another quality assurance step, the two sources of species
information are compared. Unfortunately they don't always agree. These
rows where they disagree are examined and issues resolved. First a
problems data frame is written.

    i <- which(data$Species != data$SpeciesF)
    problems <- data.frame(file = unique(data$filename[i]), problem = 'species disagreement')

The original text files with species disagreement were examined
individually. Some of the more confusing files were examined by Rich
Brenner, an expert in the field, to determine which species designation
is correct. What follows is a description of these errors and their
solution.

    problems <- read.csv('/home/sjclark/ASL/PWS_processing_corrections/species_disagreement.csv', stringsAsFactors = F)
    problems <- data.table(problems)
    kable(problems, row.names = F, format = 'html') %>% 
            kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) #%>%

<table class="table table-striped table-hover table-condensed table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
file
</th>
<th style="text-align:left;">
problem
</th>
<th style="text-align:left;">
problem\_description
</th>
<th style="text-align:left;">
solution
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
1983/1C83CDMX.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
species transpose to '14' in one line
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1988/3B88CDMX.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
The filename suggest Bering River coho and all the lengths and ages look
like coho. Coho generally spend a single year at sea, thus, most marine
ages = 1. Within the scale card data I do see a '42' on line 288 and
perhaps another line. This is incorrect as the ages are still only 1
ocean.
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1989/1C89CDMX.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
File name and most asci header info indicating this is a Chinook sample.
I do see a '42' for the scale card data on lines 2035 and 2046 but these
are incorrect as the lengths and number of scales collected (10) are
clearly for Chinook
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
<tr>
<td style="text-align:left;">
1990/3C90CDMX.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
File name and most asci header info suggests coho. But line 217 has '45'
for species suggests chum salmon instead of '43' for coho, which is
incorrect as the ages are clearly for coho
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
<tr>
<td style="text-align:left;">
2002/1C02SXCG.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
File name and some asci header info suggests Chinook but some scale care
info (lines 37, 48, 95, etc.) suggest sockeye. These are incorrect as
the number of scales (10) and lengths are clearly for Chinook.
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
<tr>
<td style="text-align:left;">
2002/2C02EBSB.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
The file name suggests sockeye but line 523 of the asci header info
suggests Chinook, which is incorrect as the number of scales (40) and
lengths match sockeye
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
<tr>
<td style="text-align:left;">
2009/2C09EBMS.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
The file name suggest sockeye (species =2) but the header info suggests
chum salmon '45'. The ages suggest these are sockeye salmon as chum
salmon do not spend a year in freshwater.
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
<tr>
<td style="text-align:left;">
2010/2C10EBEM.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
The file name suggest sockeye (species =2) but the asci header info on
lines 478 and 519 suggest Chinook (species = 41), which is incorrect as
the lengths and number of scales (40) clearly indicate sockeye.
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
<tr>
<td style="text-align:left;">
2014/2B14EBBL.ALL
</td>
<td style="text-align:left;">
species disagreement
</td>
<td style="text-align:left;">
one card has species "41" based on number of samples on the card this
should be '42'
</td>
<td style="text-align:left;">
use species from filename
</td>
</tr>
</tbody>
</table>
Although the explanations and rationale behind the problems are complex,
the solutions for all of them are simple - default to the species given
by the filename in all of the files.

    i <- c()
    for (z in 1:length(files_gearreplace)){
     i[[z]] <- which(data$filename == problems$file[z])   
    }
    i <- unlist(i)
    data$Species[i] <- data$SpeciesF[i]

Finally, many of these columns can be cleaned up, including the ones
with IDs that were transformed into more clear words, and all of the
columns for species, gear, and project type that come from the sample
event information in the file itself as opposed to the filename.
Overall, the information in the sample event information is much more
subject to error than the filename, since all of these data were hand
entered. Therefore, the Gear, Species, and ASLProjectType columns are
removed, defaulting to the filename derived GearF, SpeciesF, and
ASLProjectTypeF columns. These columns are renamed to remove the F
designator.

    #removing ID columns
    data$sexID <- NULL; data$gearID <- NULL; data$lengthtypeID <- NULL; data$projectcodeID <- NULL; data$ageerrorID <- NULL; data$SpeciesID <- NULL
    #removing duplicate columns derived from sample event info
    data$Gear <- NULL; data$Species <- NULL; data$ASLProjectType <- NULL

    colnames(data)[16] <- 'Gear'
    colnames(data)[17] <- 'Species'
    colnames(data)[18] <- 'Area'
    colnames(data)[19] <- 'ASLProjectType'

Location Information
--------------------

Location information is stored in two places in the files, the filename
and the sample event information within the file. Although the location
information within the file is more subject to typeographical error, it
does have a higher spatial resolution than the filename information,
which in many cases indicates only "mixed." Therefore, unlike the Gear,
Species, and ASLProjectType columns, these data are preferred over
filename information and must be dealt with.

The location codes within the file are specific to the local department,
and follow the general format: DDD-SS-RRR-NNN, where DDD is the
commercial fishing district, SS the sub-district, RRR the local
department stream/system identifier, and NNN an additional sub-system
identifier. The district and sub-district information is easy to parse
and assign a location name, as it is used consistently throughout the
state and is well documented. For information and clarification on these
fields we reference these two maps for the [Copper/Bering
Rivers](http://www.adfg.alaska.gov/static/fishing/PDFs/commercial/pwsstatmaps/212-200_Copper_Bering_Districts_ReportingAreas_2012.pdf)
and [Prince William
Sound.](http://www.adfg.alaska.gov/static/fishing/PDFs/commercial/pwsstatmaps/2017_pws_statistical_area_map.pdf)
The stream identifier is more challenging, as this is the portion of the
identifier that is specific to local offices.

The stream identifiers for Prince William Sound are based on Stream \#
columns from this file (aspws.xls):

![](images/PWS_streamcodes.jpg)

In the location identifier used in the sample event information lines,
the streamcodes are padded with 0s, so Sheep River, for example, is
designated as 221-20-036-000.

The stream identifiers for the Copper/Bering River area are based on the
CF Index number from this file (CBRStrmCodes.xls). Frequently the
numbers in the dataset match not the number exactly, but instead the
first two or three digits of the number, padded with a 0 if necessary.
Here is a look at the header for this file:

![](images/CR_streamcodes.jpg)

Power Creek, then, would have a location code of 212-10-026-000 in these
data.

Unfortunately, many of these locations share the same CF Index code, for
example the various locations within Eyak Lake. The data itself seems to
suggest that there is a way to distinguish between the sub-locations
with Eyak Lake, with unique location values of 212-10-022-211,
212-10-022-212, 212-10-022-215. Although, to my knowledge, there is no
documentation giving the codes to the last 3 digits of the location ID,
we can reincorporate the filename information alongside the location
code to see if it helps decode them at all.

To decode the location information and assign a location name, we find
unique combinations of the LocationCode and LocationF columns, location
information derived from the sample event information and the filename,
respectively, along with the number of samples for each of these
combinations.

    data <- data.table(data)
    data_loc_summary <- data[, .(n = length(Length)), by = .(LocationCode, LocationF)]
    kable(data_loc_summary[1:10,], row.names = F, format = 'html') %>% 
            kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"))

From this information, along with the information from the two files
described above, we will attempt to assign each unique location code as
precise and accurate of a location name as possible. After assigning
each unique location code a location name, this will be used as a lookup
table to join the location names to the entire dataset. Improved
district and subdistrict information will also be included in the lookup
table since there are several typeos in these fields.

In cases where the last three digits of a location code can be intuited
from the location information in the filename, the location information
from the filename will be used to inform the location name If there are
multiple filename derived locations for a location code, but one is used
for a very large portion of the data relative to the others, the
location name is derived from the most ubiquitously used filename
location. In rare cases, there is no apparent stream identifier match
from the department files but there is information from the filename
that is more prescise than district level information. In these cases,
the information from the filename is used. In general, however, there
has be a compelling reason to use the filename information over the
information in the file.

The finest resolution location name will be determined by using the
entire location code if possible, and moving backwards through the
levels as they are able to be identified. For example, for code
225-21-503-000, since 503 is not listed in the Prince William Sound
streamcode file, the finest resolution can confidently assign this
location is the subdistrict level, or "Main Bay" in this case.

Here are the results from this location decoding.

    locs <- read.csv('/home/sjclark/ASL/PWS_processing_corrections/PWS_location_lookup.csv', stringsAsFactors = F)
    kable(locs, row.names = F, format = 'html') %>% 
            kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) #%>%

<table class="table table-striped table-hover table-condensed table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
LocationCode
</th>
<th style="text-align:left;">
Location
</th>
<th style="text-align:right;">
DistrictID
</th>
<th style="text-align:right;">
SubDistrictID
</th>
<th style="text-align:left;">
LocationF
</th>
<th style="text-align:right;">
n
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
212-20-056-295
</td>
<td style="text-align:left;">
27-Mile Slough
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Twenty-Seven Mile
</td>
<td style="text-align:right;">
10445
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-917-391
</td>
<td style="text-align:left;">
39-Mile Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Thirty-Nine Mile
</td>
<td style="text-align:right;">
9516
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-000-391
</td>
<td style="text-align:left;">
39-Mile Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Thirty-Nine Mile
</td>
<td style="text-align:right;">
829
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-917-391
</td>
<td style="text-align:left;">
39-Mile Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Thirty-Nine Mile
</td>
<td style="text-align:right;">
8212
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-917-391
</td>
<td style="text-align:left;">
39-Mile Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Unakwik Subdist.
</td>
<td style="text-align:right;">
41
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-919-391
</td>
<td style="text-align:left;">
39-Mile Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Thirty-Nine Mile
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
222-30-283-000
</td>
<td style="text-align:left;">
Bad Creek
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
110
</td>
</tr>
<tr>
<td style="text-align:left;">
221-30-048-000
</td>
<td style="text-align:left;">
Beartrap
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
801
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-962-000
</td>
<td style="text-align:left;">
Bering Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Bering Lk-mixed
</td>
<td style="text-align:right;">
1469
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-962-000
</td>
<td style="text-align:left;">
Bering Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Bering Lk-Dick Cr
</td>
<td style="text-align:right;">
859
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-962-200
</td>
<td style="text-align:left;">
Bering Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Bering Lk-mixed
</td>
<td style="text-align:right;">
1229
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-962-000
</td>
<td style="text-align:left;">
Bering Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Bering Lk-mixed
</td>
<td style="text-align:right;">
668
</td>
</tr>
<tr>
<td style="text-align:left;">
200-00-000-000
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
15066
</td>
</tr>
<tr>
<td style="text-align:left;">
200-00-000-000
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Controller Bay
</td>
<td style="text-align:right;">
1352
</td>
</tr>
<tr>
<td style="text-align:left;">
200-00-000-212
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
344
</td>
</tr>
<tr>
<td style="text-align:left;">
200-00-000-800
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
9089
</td>
</tr>
<tr>
<td style="text-align:left;">
200-00-000-800
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Controller Bay
</td>
<td style="text-align:right;">
626
</td>
</tr>
<tr>
<td style="text-align:left;">
200-00-000-800
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
450
</td>
</tr>
<tr>
<td style="text-align:left;">
200-00-000-850
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Controller Bay
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
200-00-000-860
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Controller Bay
</td>
<td style="text-align:right;">
560
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-000-962
</td>
<td style="text-align:left;">
Bering River
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Controller Bay
</td>
<td style="text-align:right;">
600
</td>
</tr>
<tr>
<td style="text-align:left;">
222-10-218-000
</td>
<td style="text-align:left;">
Billy's Hole
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Billys Hole
</td>
<td style="text-align:right;">
234
</td>
</tr>
<tr>
<td style="text-align:left;">
222-10-218-000
</td>
<td style="text-align:left;">
Billy's Hole
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
234
</td>
</tr>
<tr>
<td style="text-align:left;">
222-30-276-000
</td>
<td style="text-align:left;">
Black Bear Creek
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
804
</td>
</tr>
<tr>
<td style="text-align:left;">
228-30-850-000
</td>
<td style="text-align:left;">
Canoe Creek
</td>
<td style="text-align:right;">
228
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
60
</td>
</tr>
<tr>
<td style="text-align:left;">
222-20-229-000
</td>
<td style="text-align:left;">
Cedar Creek
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
670
</td>
</tr>
<tr>
<td style="text-align:left;">
227-20-741-000
</td>
<td style="text-align:left;">
Chalmers River
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
360
</td>
</tr>
<tr>
<td style="text-align:left;">
224-40-495-000
</td>
<td style="text-align:left;">
Chimevisky Creek
</td>
<td style="text-align:right;">
224
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
120
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-974-000
</td>
<td style="text-align:left;">
Clear Creek
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
102
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-974-000
</td>
<td style="text-align:left;">
Clear Creek
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Clear Cr
</td>
<td style="text-align:right;">
105
</td>
</tr>
<tr>
<td style="text-align:left;">
-00-000-800
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
223-00-000-000
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
61137
</td>
</tr>
<tr>
<td style="text-align:left;">
223-00-000-000
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Esther Subdist.
</td>
<td style="text-align:right;">
400
</td>
</tr>
<tr>
<td style="text-align:left;">
223-00-000-000
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
400
</td>
</tr>
<tr>
<td style="text-align:left;">
223-00-000-800
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
15846
</td>
</tr>
<tr>
<td style="text-align:left;">
223-00-000-800
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
25
</td>
</tr>
<tr>
<td style="text-align:left;">
223-00-000-800
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
417
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-000-000
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
695
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-000-012
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
426
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-000-100
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Point
</td>
<td style="text-align:right;">
1141
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-000-800
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
840
</td>
</tr>
<tr>
<td style="text-align:left;">
230-00-000-800
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
27
</td>
</tr>
<tr>
<td style="text-align:left;">
222-30-322-100
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Coghill Weir
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-221-100
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Weir
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-000
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
326
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-014
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Lake
</td>
<td style="text-align:right;">
19
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-048
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Lake
</td>
<td style="text-align:right;">
222
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-050
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Lake
</td>
<td style="text-align:right;">
132
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-100
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
175
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-100
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Weir
</td>
<td style="text-align:right;">
58282
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-100
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Lake
</td>
<td style="text-align:right;">
169
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-800
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Weir
</td>
<td style="text-align:right;">
67
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-322-800
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Wells River
</td>
<td style="text-align:right;">
67
</td>
</tr>
<tr>
<td style="text-align:left;">
233-30-322-100
</td>
<td style="text-align:left;">
Coghill River
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Coghill Weir
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
228-60-815-000
</td>
<td style="text-align:left;">
Constantine Creek
</td>
<td style="text-align:right;">
228
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
828
</td>
</tr>
<tr>
<td style="text-align:left;">
221-30-052-000
</td>
<td style="text-align:left;">
Control Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
244
</td>
</tr>
<tr>
<td style="text-align:left;">
228-40-828-000
</td>
<td style="text-align:left;">
Cook Creek
</td>
<td style="text-align:right;">
228
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
101
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-100-70
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
13
</td>
</tr>
<tr>
<td style="text-align:left;">
2 2-00-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
21-00-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
211-00-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
212-00-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
192207
</td>
</tr>
<tr>
<td style="text-align:left;">
212-00-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
5023
</td>
</tr>
<tr>
<td style="text-align:left;">
212-00-000-003
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
140
</td>
</tr>
<tr>
<td style="text-align:left;">
212-00-000-600
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
10
</td>
</tr>
<tr>
<td style="text-align:left;">
212-00-000-700
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
12
</td>
</tr>
<tr>
<td style="text-align:left;">
212-00-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
61884
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
885
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-000-700
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
111
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
1522
</td>
</tr>
<tr>
<td style="text-align:left;">
212-11-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
381
</td>
</tr>
<tr>
<td style="text-align:left;">
212-15-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
15
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
200
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
570
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
334
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Crosswind Lake
</td>
<td style="text-align:right;">
150
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
240
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-100-228
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
167
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-100-700
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
28380
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-100-700
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Gulkana R
</td>
<td style="text-align:right;">
2
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-100-7l0
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
6
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-700-100
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
80
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
1625
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-000-800
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
1170
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-000-951
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
62
</td>
</tr>
<tr>
<td style="text-align:left;">
212300-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
10
</td>
</tr>
<tr>
<td style="text-align:left;">
213-00-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
10
</td>
</tr>
<tr>
<td style="text-align:left;">
213-20-000-000
</td>
<td style="text-align:left;">
Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
10
</td>
</tr>
<tr>
<td style="text-align:left;">
225-10-000-000
</td>
<td style="text-align:left;">
Crafton Island Subdistrict
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Crafton Island Subd.
</td>
<td style="text-align:right;">
707
</td>
</tr>
<tr>
<td style="text-align:left;">
225-10-000-000
</td>
<td style="text-align:left;">
Crafton Island Subdistrict
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
60
</td>
</tr>
<tr>
<td style="text-align:left;">
225-10-000-007
</td>
<td style="text-align:left;">
Crafton Island Subdistrict
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
845
</td>
</tr>
<tr>
<td style="text-align:left;">
225-10-000-008
</td>
<td style="text-align:left;">
Crafton Island Subdistrict
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
520
</td>
</tr>
<tr>
<td style="text-align:left;">
225-10-000-800
</td>
<td style="text-align:left;">
Crafton Island Subdistrict
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Crafton Island Subd.
</td>
<td style="text-align:right;">
80
</td>
</tr>
<tr>
<td style="text-align:left;">
224-30-479-000
</td>
<td style="text-align:left;">
Culross Creek
</td>
<td style="text-align:right;">
224
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
78
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-963-000
</td>
<td style="text-align:left;">
Dick Creek
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Bering Lk-Dick Cr
</td>
<td style="text-align:right;">
3933
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-963-041
</td>
<td style="text-align:left;">
Dick Creek
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Bering Lk-mixed
</td>
<td style="text-align:right;">
400
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-963-411
</td>
<td style="text-align:left;">
Dick Creek
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Bering Lk-Dick Cr
</td>
<td style="text-align:right;">
4485
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-963-411
</td>
<td style="text-align:left;">
Dick Creek
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
713
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-963-411
</td>
<td style="text-align:left;">
Dick Creek
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Bering Lk-mixed
</td>
<td style="text-align:right;">
5019
</td>
</tr>
<tr>
<td style="text-align:left;">
228-60-806-000
</td>
<td style="text-align:left;">
Dog Salmon Creek
</td>
<td style="text-align:right;">
228
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
228-40-831-000
</td>
<td style="text-align:left;">
Double Creek
</td>
<td style="text-align:right;">
228
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
54
</td>
</tr>
<tr>
<td style="text-align:left;">
221-50-116-000
</td>
<td style="text-align:left;">
Duck River
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
718
</td>
</tr>
<tr>
<td style="text-align:left;">
222-30-281-000
</td>
<td style="text-align:left;">
Eaglek Bay
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
221-00-000-000
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
5333
</td>
</tr>
<tr>
<td style="text-align:left;">
221-00-000-800
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
1265
</td>
</tr>
<tr>
<td style="text-align:left;">
221-00-000-800
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
64
</td>
</tr>
<tr>
<td style="text-align:left;">
221-20-000-000
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
226
</td>
</tr>
<tr>
<td style="text-align:left;">
221-40-000-000
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
188
</td>
</tr>
<tr>
<td style="text-align:left;">
221-62-000-000
</td>
<td style="text-align:left;">
Eastern District
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
678
</td>
</tr>
<tr>
<td style="text-align:left;">
222-10-221-000
</td>
<td style="text-align:left;">
Eickelberg Creek
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
80
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-000
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
1170
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-000
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Crafton Island Subd.
</td>
<td style="text-align:right;">
335
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-001
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1878
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-002
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1233
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-003
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
340
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-004
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
230
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-005
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
606
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-006
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
608
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-007
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
129
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-008
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
148
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-009
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
276
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-010
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
86
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-800
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Crafton Island Subd.
</td>
<td style="text-align:right;">
80
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-000-800
</td>
<td style="text-align:left;">
Eshamy Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
80
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-000
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
30554
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-000
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
343
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-000
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Crafton Island Subd.
</td>
<td style="text-align:right;">
998
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-000
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
450
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-800
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
14477
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-800
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Unakwik Subdist.
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-800
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
2906
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-800
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Crafton Island Subd.
</td>
<td style="text-align:right;">
662
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-800
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Main Bay Hatch. & Subdist.
</td>
<td style="text-align:right;">
624
</td>
</tr>
<tr>
<td style="text-align:left;">
225-00-000-900
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
625-00-000-800
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-511-000
</td>
<td style="text-align:left;">
Eshamy River
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Eshamy Weir
</td>
<td style="text-align:right;">
5490
</td>
</tr>
<tr>
<td style="text-align:left;">
225-30-511-100
</td>
<td style="text-align:left;">
Eshamy River
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Eshamy Weir
</td>
<td style="text-align:right;">
30058
</td>
</tr>
<tr>
<td style="text-align:left;">
255-30-511-000
</td>
<td style="text-align:left;">
Eshamy River
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Eshamy Weir
</td>
<td style="text-align:right;">
36
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-00 0
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
119
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-00
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
440
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-000
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
4722
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-000
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
46217
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-000
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
Esther Subdist.
</td>
<td style="text-align:right;">
9249
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-001
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
14
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-002
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-003
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-004
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-005
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-006
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
2
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-007
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
2
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-009
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
592
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-010
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
427
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-011
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
157
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-800
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
Coghill District
</td>
<td style="text-align:right;">
3948
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-800
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1786
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-800
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
269
</td>
</tr>
<tr>
<td style="text-align:left;">
223-40-000-800
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
Esther Subdist.
</td>
<td style="text-align:right;">
1282
</td>
</tr>
<tr>
<td style="text-align:left;">
23-40-000-000
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
233-40-000-000
</td>
<td style="text-align:left;">
Esther Island
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-000
</td>
<td style="text-align:left;">
Eyak Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
635
</td>
</tr>
<tr>
<td style="text-align:left;">
225-20-000-000
</td>
<td style="text-align:left;">
Falls Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Crafton Island Subd.
</td>
<td style="text-align:right;">
900
</td>
</tr>
<tr>
<td style="text-align:left;">
225-20-000-000
</td>
<td style="text-align:left;">
Falls Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
266
</td>
</tr>
<tr>
<td style="text-align:left;">
225-20-000-003
</td>
<td style="text-align:left;">
Falls Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1678
</td>
</tr>
<tr>
<td style="text-align:left;">
225-20-000-004
</td>
<td style="text-align:left;">
Falls Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
593
</td>
</tr>
<tr>
<td style="text-align:left;">
225-20-000-800
</td>
<td style="text-align:left;">
Falls Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
555
</td>
</tr>
<tr>
<td style="text-align:left;">
225-20-000-800
</td>
<td style="text-align:left;">
Falls Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Crafton Island Subd.
</td>
<td style="text-align:right;">
182
</td>
</tr>
<tr>
<td style="text-align:left;">
221-40-089-000
</td>
<td style="text-align:left;">
Fish Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
178
</td>
</tr>
<tr>
<td style="text-align:left;">
223-30-311-000
</td>
<td style="text-align:left;">
Golden Lagoon
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Golden Lagoon
</td>
<td style="text-align:right;">
295
</td>
</tr>
<tr>
<td style="text-align:left;">
222-30-282-000
</td>
<td style="text-align:left;">
Good Creek
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
92
</td>
</tr>
<tr>
<td style="text-align:left;">
221-50-123-000
</td>
<td style="text-align:left;">
Gregorieoff Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
223-10-414-000
</td>
<td style="text-align:left;">
Harrison Creek
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
120
</td>
</tr>
<tr>
<td style="text-align:left;">
221-10-002-000
</td>
<td style="text-align:left;">
Hartney Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
33
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-215
</td>
<td style="text-align:left;">
Hatchery Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-Hatchery Cr
</td>
<td style="text-align:right;">
11432
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-215
</td>
<td style="text-align:left;">
Hatchery Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-Middle Arm
</td>
<td style="text-align:right;">
11
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-022-215
</td>
<td style="text-align:left;">
Hatchery Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-Hatchery Cr
</td>
<td style="text-align:right;">
251
</td>
</tr>
<tr>
<td style="text-align:left;">
221-50-117-000
</td>
<td style="text-align:left;">
Indian Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1035
</td>
</tr>
<tr>
<td style="text-align:left;">
226-20-508-800
</td>
<td style="text-align:left;">
Jackpot Creek
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Jackpot Weir
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
226-20-608-100
</td>
<td style="text-align:left;">
Jackpot Creek
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Jackpot Weir
</td>
<td style="text-align:right;">
464
</td>
</tr>
<tr>
<td style="text-align:left;">
226-20-608-100
</td>
<td style="text-align:left;">
Jackpot Creek
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1682
</td>
</tr>
<tr>
<td style="text-align:left;">
226-20-608-800
</td>
<td style="text-align:left;">
Jackpot Creek
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Jackpot Weir
</td>
<td style="text-align:right;">
600
</td>
</tr>
<tr>
<td style="text-align:left;">
222-20-259-000
</td>
<td style="text-align:left;">
Jonah Creek
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
120
</td>
</tr>
<tr>
<td style="text-align:left;">
192-41-000-000
</td>
<td style="text-align:left;">
Kaliakh River
</td>
<td style="text-align:right;">
192
</td>
<td style="text-align:right;">
41
</td>
<td style="text-align:left;">
Kaliakh River
</td>
<td style="text-align:right;">
65
</td>
</tr>
<tr>
<td style="text-align:left;">
200-30-000-890
</td>
<td style="text-align:left;">
Kayak Island
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Kayak Island
</td>
<td style="text-align:right;">
400
</td>
</tr>
<tr>
<td style="text-align:left;">
221-40-083-000
</td>
<td style="text-align:left;">
Keta Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
278
</td>
</tr>
<tr>
<td style="text-align:left;">
228-40-829-000
</td>
<td style="text-align:left;">
King Creek
</td>
<td style="text-align:right;">
228
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
221-20-035-000
</td>
<td style="text-align:left;">
Koppen Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1396
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-972-420
</td>
<td style="text-align:left;">
Kushtaka Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Kushtaka Lk
</td>
<td style="text-align:right;">
11788
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-972-420
</td>
<td style="text-align:left;">
Kushtaka Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1222
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-972-430
</td>
<td style="text-align:left;">
Kushtaka Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Kushtaka Lk
</td>
<td style="text-align:right;">
4291
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-972-420
</td>
<td style="text-align:left;">
Kushtaka Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Kushtaka Lk
</td>
<td style="text-align:right;">
719
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-972-430
</td>
<td style="text-align:left;">
Kushtaka Lake
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Kushtaka Lk
</td>
<td style="text-align:right;">
640
</td>
</tr>
<tr>
<td style="text-align:left;">
221-40-099-000
</td>
<td style="text-align:left;">
Lagoon Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
147
</td>
</tr>
<tr>
<td style="text-align:left;">
221-50-121-000
</td>
<td style="text-align:left;">
Levshakoff Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
60
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-925-340
</td>
<td style="text-align:left;">
Little Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Little Martin Lk
</td>
<td style="text-align:right;">
7631
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-925-340
</td>
<td style="text-align:left;">
Little Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Pleasant Cr
</td>
<td style="text-align:right;">
270
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-736-101
</td>
<td style="text-align:left;">
Long Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Long Lk
</td>
<td style="text-align:right;">
7382
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000- 00
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000-000
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
Main Bay Hatch. & Subdist.
</td>
<td style="text-align:right;">
6529
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000-000
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
7750
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000-000
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
2197
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000-005
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
2062
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000-006
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1410
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000-013
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
173
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000-800
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1637
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-000-800
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
Eshamy District
</td>
<td style="text-align:right;">
800
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-503-000
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
10300
</td>
</tr>
<tr>
<td style="text-align:left;">
225-21-503-800
</td>
<td style="text-align:left;">
Main Bay
</td>
<td style="text-align:right;">
225
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
7687
</td>
</tr>
<tr>
<td style="text-align:left;">
21 -30-926-320
</td>
<td style="text-align:left;">
Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin Lk-mixed
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-926-000
</td>
<td style="text-align:left;">
Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin Lk-mixed
</td>
<td style="text-align:right;">
632
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-926-230
</td>
<td style="text-align:left;">
Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin Lk-mixed
</td>
<td style="text-align:right;">
781
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-926-320
</td>
<td style="text-align:left;">
Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin Lk-mixed
</td>
<td style="text-align:right;">
12524
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-926-320
</td>
<td style="text-align:left;">
Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin Lk-West Side
</td>
<td style="text-align:right;">
741
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-926-321
</td>
<td style="text-align:left;">
Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin Lk-West Side
</td>
<td style="text-align:right;">
1852
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-926-322
</td>
<td style="text-align:left;">
Martin Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin Lk-mixed
</td>
<td style="text-align:right;">
65
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-294-381
</td>
<td style="text-align:left;">
Martin River Slough
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin R. Slough
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-940-381
</td>
<td style="text-align:left;">
Martin River Slough
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Martin R. Slough
</td>
<td style="text-align:right;">
11701
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-053-230
</td>
<td style="text-align:left;">
McKinley Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
McKinley Lk
</td>
<td style="text-align:right;">
16616
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-053-233
</td>
<td style="text-align:left;">
McKinley Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
McKinley Lk
</td>
<td style="text-align:right;">
666
</td>
</tr>
<tr>
<td style="text-align:left;">
223-10-430-000
</td>
<td style="text-align:left;">
Meacham Creek
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-212
</td>
<td style="text-align:left;">
Middle Arm
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-Middle Arm
</td>
<td style="text-align:right;">
25707
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-212
</td>
<td style="text-align:left;">
Middle Arm
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
567
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-212
</td>
<td style="text-align:left;">
Middle Arm
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-South Beaches
</td>
<td style="text-align:right;">
1322
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-022-212
</td>
<td style="text-align:left;">
MIddle Arm
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-Middle Arm
</td>
<td style="text-align:right;">
1146
</td>
</tr>
<tr>
<td style="text-align:left;">
223-10-421-000
</td>
<td style="text-align:left;">
Mill Creek
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
315
</td>
</tr>
<tr>
<td style="text-align:left;">
227-00-000-000
</td>
<td style="text-align:left;">
Montague District
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Port Chalmers, Montague District
</td>
<td style="text-align:right;">
6109
</td>
</tr>
<tr>
<td style="text-align:left;">
226-40-000-000
</td>
<td style="text-align:left;">
Mummy Bay
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
Southwestern District
</td>
<td style="text-align:right;">
183
</td>
</tr>
<tr>
<td style="text-align:left;">
221-50-127-000
</td>
<td style="text-align:left;">
Naomoff River
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
81
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-022-213
</td>
<td style="text-align:left;">
North Beaches
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-North Beaches
</td>
<td style="text-align:right;">
469
</td>
</tr>
<tr>
<td style="text-align:left;">
222-10-000-000
</td>
<td style="text-align:left;">
North Glacier Island
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Billys Hole
</td>
<td style="text-align:right;">
8
</td>
</tr>
<tr>
<td style="text-align:left;">
222-10-121-080
</td>
<td style="text-align:left;">
North Glacier Island
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Billys Hole
</td>
<td style="text-align:right;">
127
</td>
</tr>
<tr>
<td style="text-align:left;">
222-10-121-800
</td>
<td style="text-align:left;">
North Glacier Island
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Billys Hole
</td>
<td style="text-align:right;">
37
</td>
</tr>
<tr>
<td style="text-align:left;">
222-00-000-000
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
1220
</td>
</tr>
<tr>
<td style="text-align:left;">
222-00-000-800
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
801
</td>
</tr>
<tr>
<td style="text-align:left;">
222-50-000-000
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Miners Lake
</td>
<td style="text-align:right;">
447
</td>
</tr>
<tr>
<td style="text-align:left;">
222-50-000-244
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Miners Lake
</td>
<td style="text-align:right;">
512
</td>
</tr>
<tr>
<td style="text-align:left;">
222-50-000-244
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
512
</td>
</tr>
<tr>
<td style="text-align:left;">
224-30-473-000
</td>
<td style="text-align:left;">
Northwest District
</td>
<td style="text-align:right;">
224
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
20
</td>
</tr>
<tr>
<td style="text-align:left;">
228-60-812-000
</td>
<td style="text-align:left;">
Nuchek Creek
</td>
<td style="text-align:right;">
228
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
14
</td>
</tr>
<tr>
<td style="text-align:left;">
221-30-051-000
</td>
<td style="text-align:left;">
Olsen Bay Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
939
</td>
</tr>
<tr>
<td style="text-align:left;">
221-30-051-000
</td>
<td style="text-align:left;">
Olsen Bay Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Olsen Creek
</td>
<td style="text-align:right;">
42
</td>
</tr>
<tr>
<td style="text-align:left;">
221-30-105-170
</td>
<td style="text-align:left;">
Olsen Bay Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Olsen Creek
</td>
<td style="text-align:right;">
1178
</td>
</tr>
<tr>
<td style="text-align:left;">
224-10-458-000
</td>
<td style="text-align:left;">
Parks Creek
</td>
<td style="text-align:right;">
224
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
13
</td>
</tr>
<tr>
<td style="text-align:left;">
224-10-455-000
</td>
<td style="text-align:left;">
Paulson Creek
</td>
<td style="text-align:right;">
224
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
180
</td>
</tr>
<tr>
<td style="text-align:left;">
227-20-775-000
</td>
<td style="text-align:left;">
Pautzke Creek
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
32
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-201-360
</td>
<td style="text-align:left;">
Pleasant Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Pleasant Cr
</td>
<td style="text-align:right;">
518
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-212-010
</td>
<td style="text-align:left;">
Pothole Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Pothole Lake
</td>
<td style="text-align:right;">
537
</td>
</tr>
<tr>
<td style="text-align:left;">
220-00-000-000
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
100
</td>
</tr>
<tr>
<td style="text-align:left;">
220-00-000-000
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
General Districts
</td>
<td style="text-align:right;">
6426
</td>
</tr>
<tr>
<td style="text-align:left;">
220-00-000-800
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
General Districts
</td>
<td style="text-align:right;">
941
</td>
</tr>
<tr>
<td style="text-align:left;">
220-00-000-800
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
516
</td>
</tr>
<tr>
<td style="text-align:left;">
221-00 222-00
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
289
</td>
</tr>
<tr>
<td style="text-align:left;">
221-00 223-00
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
440
</td>
</tr>
<tr>
<td style="text-align:left;">
223-00 229-00
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
224
</td>
</tr>
<tr>
<td style="text-align:left;">
223-00-229-00
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
80
</td>
</tr>
<tr>
<td style="text-align:left;">
520-00-000-800
</td>
<td style="text-align:left;">
Prince William Sound General
</td>
<td style="text-align:right;">
220
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-930-310
</td>
<td style="text-align:left;">
Ragged Point Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Ragged Point Lk
</td>
<td style="text-align:right;">
295
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-931-310
</td>
<td style="text-align:left;">
Ragged Point Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Ragged Point Lk
</td>
<td style="text-align:right;">
2878
</td>
</tr>
<tr>
<td style="text-align:left;">
221-61-137-000
</td>
<td style="text-align:left;">
Robe Lake
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
Robe Lake
</td>
<td style="text-align:right;">
63
</td>
</tr>
<tr>
<td style="text-align:left;">
221-61-137-000
</td>
<td style="text-align:left;">
Robe Lake
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
59
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-054-000
</td>
<td style="text-align:left;">
Salmon Creek - Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
McKinley Lk
</td>
<td style="text-align:right;">
1632
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-054-230
</td>
<td style="text-align:left;">
Salmon Creek - Copper River
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
McKinley Lk
</td>
<td style="text-align:right;">
716
</td>
</tr>
<tr>
<td style="text-align:left;">
226-60-000-000
</td>
<td style="text-align:left;">
Sawmill Bay
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
Southwestern District
</td>
<td style="text-align:right;">
649
</td>
</tr>
<tr>
<td style="text-align:left;">
226-60-000-800
</td>
<td style="text-align:left;">
Sawmill Bay
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
General Districts
</td>
<td style="text-align:right;">
216
</td>
</tr>
<tr>
<td style="text-align:left;">
221-60-133-000
</td>
<td style="text-align:left;">
Sawmill Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
10
</td>
</tr>
<tr>
<td style="text-align:left;">
227-20-746-000
</td>
<td style="text-align:left;">
Schuman Creek
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
120
</td>
</tr>
<tr>
<td style="text-align:left;">
221-20-036-000
</td>
<td style="text-align:left;">
Sheep River
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
200
</td>
</tr>
<tr>
<td style="text-align:left;">
200-20-964-430
</td>
<td style="text-align:left;">
Shepherd Creek
</td>
<td style="text-align:right;">
200
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Shepherd Cr
</td>
<td style="text-align:right;">
2276
</td>
</tr>
<tr>
<td style="text-align:left;">
224-30-476-000
</td>
<td style="text-align:left;">
Shrode Creek
</td>
<td style="text-align:right;">
224
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
222-20-264-000
</td>
<td style="text-align:left;">
Siwash Creek
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
185
</td>
</tr>
<tr>
<td style="text-align:left;">
226-20-613-000
</td>
<td style="text-align:left;">
Siwash Creek
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Siwash Creek
</td>
<td style="text-align:right;">
120
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-211
</td>
<td style="text-align:left;">
South Beaches
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-South Beaches
</td>
<td style="text-align:right;">
16917
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-211
</td>
<td style="text-align:left;">
South Beaches
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
212-10-022-211
</td>
<td style="text-align:left;">
South Beaches
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
McKinley Lk
</td>
<td style="text-align:right;">
595
</td>
</tr>
<tr>
<td style="text-align:left;">
216-10-022-211
</td>
<td style="text-align:left;">
South Beaches
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
Eyak-South Beaches
</td>
<td style="text-align:right;">
120
</td>
</tr>
<tr>
<td style="text-align:left;">
226-00-000-000
</td>
<td style="text-align:left;">
Southwestern District
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Southwestern District
</td>
<td style="text-align:right;">
16292
</td>
</tr>
<tr>
<td style="text-align:left;">
226-00-000-800
</td>
<td style="text-align:left;">
Southwestern District
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Southwestern District
</td>
<td style="text-align:right;">
923
</td>
</tr>
<tr>
<td style="text-align:left;">
226-00-000-800
</td>
<td style="text-align:left;">
Southwestern District
</td>
<td style="text-align:right;">
226
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Mixed Loc's
</td>
<td style="text-align:right;">
181
</td>
</tr>
<tr>
<td style="text-align:left;">
221-20-020-000
</td>
<td style="text-align:left;">
Spring Creek - Eastern District
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
222-10-217-000
</td>
<td style="text-align:left;">
Spring Creek - Northern District
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
80
</td>
</tr>
<tr>
<td style="text-align:left;">
221-30-056-000
</td>
<td style="text-align:left;">
St Matthews Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
20
</td>
</tr>
<tr>
<td style="text-align:left;">
221-50-153-000
</td>
<td style="text-align:left;">
Stellar Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
524
</td>
</tr>
<tr>
<td style="text-align:left;">
221-40-087-000
</td>
<td style="text-align:left;">
Sunny River
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
412
</td>
</tr>
<tr>
<td style="text-align:left;">
227-20-739-000
</td>
<td style="text-align:left;">
Swamp Creek
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
223-10-432-000
</td>
<td style="text-align:left;">
Swanson Creek
</td>
<td style="text-align:right;">
223
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
141
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-008-100
</td>
<td style="text-align:left;">
Tanada Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Tanada Creek
</td>
<td style="text-align:right;">
4799
</td>
</tr>
<tr>
<td style="text-align:left;">
212-20-008-100
</td>
<td style="text-align:left;">
Tanada Creek
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
50
</td>
</tr>
<tr>
<td style="text-align:left;">
224-10-450-000
</td>
<td style="text-align:left;">
Tebenkof Creek
</td>
<td style="text-align:right;">
224
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
100
</td>
</tr>
<tr>
<td style="text-align:left;">
200-30-924-350
</td>
<td style="text-align:left;">
Tokun Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Tokun Lk
</td>
<td style="text-align:right;">
502
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-924-350
</td>
<td style="text-align:left;">
Tokun Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Tokun Lk
</td>
<td style="text-align:right;">
15395
</td>
</tr>
<tr>
<td style="text-align:left;">
212-30-924-850
</td>
<td style="text-align:left;">
Tokun Lake
</td>
<td style="text-align:right;">
212
</td>
<td style="text-align:right;">
30
</td>
<td style="text-align:left;">
Tokun Lk
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
221-50-152-000
</td>
<td style="text-align:left;">
Twin Falls Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
123
</td>
</tr>
<tr>
<td style="text-align:left;">
229-00-000-000
</td>
<td style="text-align:left;">
Unakwik District
</td>
<td style="text-align:right;">
229
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Unakwik Subdist.
</td>
<td style="text-align:right;">
3023
</td>
</tr>
<tr>
<td style="text-align:left;">
229-00-000-000
</td>
<td style="text-align:left;">
Unakwik District
</td>
<td style="text-align:right;">
229
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
225
</td>
</tr>
<tr>
<td style="text-align:left;">
229-00-000-800
</td>
<td style="text-align:left;">
Unakwik District
</td>
<td style="text-align:right;">
229
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Northern District
</td>
<td style="text-align:right;">
354
</td>
</tr>
<tr>
<td style="text-align:left;">
229-00-000-800
</td>
<td style="text-align:left;">
Unakwik District
</td>
<td style="text-align:right;">
229
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Unakwik Subdist.
</td>
<td style="text-align:right;">
342
</td>
</tr>
<tr>
<td style="text-align:left;">
229-50-000-000
</td>
<td style="text-align:left;">
Unakwik District
</td>
<td style="text-align:right;">
229
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Unakwik Subdist.
</td>
<td style="text-align:right;">
4028
</td>
</tr>
<tr>
<td style="text-align:left;">
229-50-000-800
</td>
<td style="text-align:left;">
Unakwik District
</td>
<td style="text-align:right;">
229
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
Unakwik Subdist.
</td>
<td style="text-align:right;">
1954
</td>
</tr>
<tr>
<td style="text-align:left;">
221-60-000-000
</td>
<td style="text-align:left;">
Valdez Narrows
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
911
</td>
</tr>
<tr>
<td style="text-align:left;">
222-10-216-000
</td>
<td style="text-align:left;">
Vanishing Creek
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
148
</td>
</tr>
<tr>
<td style="text-align:left;">
221-50-129-000
</td>
<td style="text-align:left;">
Vlasoff Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
50
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
135
</td>
</tr>
<tr>
<td style="text-align:left;">
222-20-234- 00
</td>
<td style="text-align:left;">
Wells River
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
222-20-234-000
</td>
<td style="text-align:left;">
Wells River
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
1434
</td>
</tr>
<tr>
<td style="text-align:left;">
222-20-234-000
</td>
<td style="text-align:left;">
Wells River
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Wells River
</td>
<td style="text-align:right;">
413
</td>
</tr>
<tr>
<td style="text-align:left;">
222-20-234-800
</td>
<td style="text-align:left;">
Wells River
</td>
<td style="text-align:right;">
222
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Wells River
</td>
<td style="text-align:right;">
171
</td>
</tr>
<tr>
<td style="text-align:left;">
221-40-080-000
</td>
<td style="text-align:left;">
Whalen Creek
</td>
<td style="text-align:right;">
221
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
227-20-744-745
</td>
<td style="text-align:left;">
Wilby Creek
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
227-20-745-000
</td>
<td style="text-align:left;">
Wild Creek
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
40
</td>
</tr>
<tr>
<td style="text-align:left;">
227-20-000-000
</td>
<td style="text-align:left;">
Zaikof Bay
</td>
<td style="text-align:right;">
227
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:left;">
Port Chalmers, Montague District
</td>
<td style="text-align:right;">
3880
</td>
</tr>
</tbody>
</table>
Now joining this to the main data frame - removing the filename location
column and the number of samples column, and duplicate rows, first.

    locs$LocationF <- NULL; locs$n <- NULL
    i <- which(duplicated(locs) == TRUE)
    locs <- locs[-i, ]
    data <- left_join(data, locs)

Now we just need to clean up columns - dropping the old location code,
district, and subdistrict columns, and renaming the new ones so they are
consistent with the rest of the SASAP datasets.

    data$LocationCode <- NULL; data$LocationF <- NULL; data$District <- NULL; data$Sub.District <- NULL; 
    data$filename <- NULL; data$period <- NULL

Create a SASAP region column consistent with the rest of the SASAP data
and drop the Area column.

    data$SASAP.Region <- NA
    data$SASAP.Region[which(data$Area == 'Yakutat')] <- 'Southeast'
    data$SASAP.Region[which(data$Area == 'Bering River')] <- 'Copper River'
    data$SASAP.Region[which(data$Area == 'Prince William Sound')] <- 'Prince William Sound'
    data$SASAP.Region[which(data$Area == 'Copper River')] <- 'Copper River'
    data$Area <- NULL

Fix the dates

    data$sampleDate <- as.Date(data$sampleDate, format = '%m/%d/%y')
    i <- which(year(data$sampleDate) > 2016)
    data$sampleDate[i] <- data$sampleDate[i] - 100*365.25

Fix subdistrict information so '0' is '00'

    data$SubDistrictID <- as.character(data$SubDistrictID)
    data$SubDistrictID[which(data$SubDistrictID == '0')] <- '00'

Rename a couple of columns

    colnames(data)[15] <- 'District'
    colnames(data)[16] <- 'Sub.District'
    data$Source <- 'PWS LengthFreq Textfiles'

Finally, write the file!

    write.csv(data, '/home/sjclark/ASL/ASL_data_formatted/PWS_CopperRiver.csv', row.names = F)
