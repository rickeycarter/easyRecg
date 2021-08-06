library(tidyverse)
library(xml2)
library(base64enc)
library(jasonlite)
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
print(ecgs$array_order)
dim(ecg_data)

## check the reading...
## The 1_MUSE file
outdata[1, 230:250, 2, 1]== ecg_data[1, 230:250, 2, 1]

outdata2[1, 530:550, 10, 1] == ecg_data[2, 530:550, 10, 1]



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



wave1_bin_list_raw<-base64decode(wave1_bin_list[[1]][1] )

wave1_bin_list_raw %>% 
  setdiff('00') %>%
  rawToChar
str(wave1_bin_list_raw)
rawToChar(wave1_bin_list_raw)
str(wave1_bin_list_raw)
count_nul <- length(wave1_bin_list_raw[wave1_bin_list_raw==00])

wave1_data<-readBin(con=wave1_bin_list_raw, what="raw", n = count_nul)
wave1_ascii <- readBin(wave1_bin, what="raw")


?readBin
# Read the leaf names to use for column names later on.

demographics_column_names <- xml2::xml_name(demographics)
ecg_column_names          <- xml2::xml_name(ecg_measurements)

demographics <- demographics %>%
  xml2::xml_text() %>%
  unlist() %>%
  t() %>%
  data.frame(stringsAsFactors = FALSE)

colnames(demographics) <- demographics_column_names

ecg_measurements <- ecg_measurements %>%
  xml2::xml_text() %>%
  unlist() %>%
  t() %>%
  data.frame(stringsAsFactors = FALSE)

colnames(ecg_measurements) <- ecg_column_names

clean_dx_statement <- function(data) {
  
  # Function to clean the diagnosis statements.
  
  #Args:
  #x: Diagnosis statment node
  
  data <-  data %>%
    xml2::xml_text() %>% # Get the text from the node.
    stringr::str_replace_all(.,stringr::regex(("(userinsert)"), ignore_case = TRUE), "") %>%
    stringr::str_split("ENDSLINE") %>% # Split text into vectors.
    unlist() %>%
    stringr::word(1, sep = "\\.") %>%
    stringr::str_split(",") %>%
    unlist() %>%
    subset(stringr::str_detect(.,stringr::regex(("(absent|\\bno\\b|\\bsuggests?\\b|\\bprobabl(e|y)\\b|\\bpossible\\b|\\brecommend\\b|\\bconsider\\b|\\bindicated\\b|resting)"),
                                                ignore_case = TRUE)) == FALSE) %>%
    stringr::str_c(collapse = ", ") %>%
    tolower()
  
  return(data)
  
}

diagnosis <- xml_file %>%
  xml2::xml_find_all("/RestingECG/Diagnosis")%>%
  clean_dx_statement()

original_diagnosis <- xml_file %>%
  xml2::xml_find_all("/RestingECG/OriginalDiagnosis") %>%
  clean_dx_statement()



patient_ecg <- cbind(demographics,
                     acquisition_date_time,
                     ecg_measurements,
                     diagnosis,
                     original_diagnosis,
                     as.data.frame(filename, stringsAsFactors = FALSE),
                     stringsAsFactors = FALSE)


