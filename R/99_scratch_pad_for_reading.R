library(tidyverse)
library(xml2)
library(base64enc)

### Resources 
## Info on FDA XML format
#  https://www.amps-llc.com/Services/ecg-file-format-conversion


# Python example that works
#http://sourceforge.net/projects/musexmlexport/

## Data on the GE Format
# http://ace.ucv.ro/analele/2011_vol2/08_Popa_Teodoru.pdf


##### Attempt 1 ##################


outdata <- read_muse_xml_ecg("data/muse_xml/1_MUSE_ecg.xml")
outdata2 <- read_muse_xml_ecg("data/muse_xml/MUSE_20210427_083733_92000.xml")

dim(outdata)

ecgs <- read_muse_xml_directory("data/muse_xml/")
ecg_data <- ecgs$ecg_array
write_numpy(ecg_data, "ecg_data.npy")
indata <- read_numpy("ecg_data.npy")
table(indata == ecg_data)



## check the reading...
## The 1_MUSE file
outdata[1, 230:250, 2, 1]== ecg_data[1, 230:250, 2, 1]

outdata2[1, 530:550, 10, 1] == ecg_data[2, 530:550, 10, 1]

## trying the write to numpy function

#filename <- "data/1_MUSE_ecg.xml"
filename <- "data/MUSE_20210427_083733_92000.xml"
doc <- read_xml(filename,encoding = "ISO-8859-1")
doc_list <- as_list(doc)



### Function from https://rdrr.io/github/dloewenstein/dukeR/src/R/dr_read_ecgxml.R

xml_file <- xml2::read_xml(filename)

acquisition_time <- xml_file %>%
  xml2::xml_find_first("/RestingECG/TestDemographics/AcquisitionTime") %>%
  xml2::xml_contents() %>%
  xml2::xml_text()

acquisition_date <- xml_file %>%
  xml2::xml_find_first("/RestingECG/TestDemographics/AcquisitionDate") %>%
  xml2::xml_contents() %>%
  xml2::xml_text()

# We want date in one column and formatted as POSIXct

acquisition_date_time <- as.POSIXct(paste(acquisition_date,
                                          acquisition_time,
                                          sep = " "),
                                    format = "%m-%d-%Y %H:%M:%S")

demographics <- xml_file %>%
  xml2::xml_find_all("/RestingECG/PatientDemographics") %>%
  xml2::xml_contents()

ecg_measurements <- xml_file %>%
  xml2::xml_find_all("/RestingECG/RestingECGMeasurements") %>%
  xml2::xml_contents()


wave1_bin <- xml_file %>%
  xml2::xml_find_first("/RestingECG/Waveform/LeadData/WaveFormData") %>%
  xml2::xml_contents()


wave1_bin_list <- as_list(wave1_bin)
wave1_bin_list[[1]][1]

