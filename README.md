
<!-- README.md is generated from README.Rmd. Please edit that file -->

# easyRecg

`easyRecg` is designed to host simple tools to facilitate reading and
writing digital ECG files.

<!-- badges: start -->
<!-- badges: end -->

## Installation

You can install the development version of `easyRecg` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("rickeycarter/easyRecg")
```

``` r
library(easyRecg)
library(tibble)
```

## Retrieving 12-lead data

A matrix with data for 12-leads can be generated using the function
`read_muse_xml_ecg`:

``` r
# Get sample file
file1 <- ecg_example("muse/muse_ecg1.xml")

# Read xml file - return a 2d matrix
ecg1_2d <- read_muse_xml_ecg(file1, numpyformat = F)

dim(ecg1_2d)
#> [1] 5000   12

head(ecg1_2d)
#>        I  II III  aVR aVL aVF V1  V2  V3  V4  V5  V6
#> [1,] 156 214  58 -185  48 136 68 204 390 312 165 126
#> [2,] 156 214  58 -185  48 136 68 204 390 312 165 126
#> [3,] 156 214  58 -185  48 136 68 204 390 312 165 126
#> [4,] 156 214  58 -185  48 136 68 204 390 312 165 126
#> [5,] 165 219  53 -192  56 136 68 219 400 322 175 131
#> [6,] 165 224  58 -195  53 141 68 224 409 331 185 136

# Instead, return a 4d array formatted for AI inputs
ecg1_4d <- read_muse_xml_ecg(file1, numpyformat = T)

dim(ecg1_4d)
#> [1]    1 5000   12    1
```

A directory of ecg files can be read and returned as an array using the
`read_muse_xml_directory` function:

``` r
# Sample directory of muse files
muse_dir <- system.file("extdata", path = "muse", package = "easyRecg")

# Check number of files 
length(dir(muse_dir))
#> [1] 3

# Read xml files
all_muse <- read_muse_xml_directory(muse_dir)
#> A total of  3  ecgs were located.  Preparing to read.
#> ECGs successfully read.  Returned object includes numeric array and listing of files in the order of the array.

names(all_muse)
#> [1] "ecg_array"   "array_order"
dim(all_muse$ecg_array)
#> [1]    3 5000   12    1
```

## Retrieving Meta Data

For more information on how to filter the provided meta data, please see
the “Filtering Meta Data” vignette.

``` r
meta1 <- read_muse_xml_meta(file1, ids = 1)
meta1
#> $muse_info
#> # A tibble: 1 × 2
#>      id muse_version
#>   <dbl> <chr>       
#> 1     1 9.0.9.18167 
#> 
#> $patient_demographics
#> # A tibble: 1 × 6
#>      id patient_id patient_age age_units gender patient_last_name
#>   <dbl> <chr>      <chr>       <chr>     <chr>  <chr>            
#> 1     1 JAX01234   60          YEARS     MALE   TEST 05          
#> 
#> $test_demographics
#> # A tibble: 1 × 24
#>      id data_type site  site_name acquisition_device status    edit_list_status
#>   <dbl> <chr>     <chr> <chr>     <chr>              <chr>     <chr>           
#> 1     1 RESTING   11    Research  MAC55              CONFIRMED Confirmed       
#> # … with 17 more variables: priority <chr>, location <chr>,
#> #   location_name <chr>, acquisition_time <chr>, acquisition_date <chr>,
#> #   cart_number <chr>, acquisition_software_version <chr>,
#> #   analysis_software_version <chr>, edit_time <chr>, edit_date <chr>,
#> #   overreader_id <chr>, editor_id <chr>, overreader_last_name <chr>,
#> #   overreader_first_name <chr>, editor_last_name <chr>,
#> #   editor_first_name <chr>, his_status <chr>
#> 
#> $resting_ecg_measurements
#> # A tibble: 1 × 19
#>      id ventricular_rate atrial_rate pr_interval qrs_duration qt_interval
#>   <dbl> <chr>            <chr>       <chr>       <chr>        <chr>      
#> 1     1 60               60          158         78           364        
#> # … with 13 more variables: qt_corrected <chr>, p_axis <chr>, r_axis <chr>,
#> #   t_axis <chr>, qrs_count <chr>, q_onset <chr>, q_offset <chr>,
#> #   p_onset <chr>, p_offset <chr>, t_offset <chr>, ecg_sample_base <chr>,
#> #   ecg_sample_exponent <chr>, q_tc_frederica <chr>
#> 
#> $original_resting_ecg_measurements
#> # A tibble: 1 × 19
#>      id ventricular_rate atrial_rate pr_interval qrs_duration qt_interval
#>   <dbl> <chr>            <chr>       <chr>       <chr>        <chr>      
#> 1     1 60               60          158         78           364        
#> # … with 13 more variables: qt_corrected <chr>, p_axis <chr>, r_axis <chr>,
#> #   t_axis <chr>, qrs_count <chr>, q_onset <chr>, q_offset <chr>,
#> #   p_onset <chr>, p_offset <chr>, t_offset <chr>, ecg_sample_base <chr>,
#> #   ecg_sample_exponent <chr>, q_tc_frederica <chr>
#> 
#> $diagnosis
#> # A tibble: 1 × 8
#>      id modality diagnosis_statement_stmt_flag diagnosis_state… diagnosis_state…
#>   <dbl> <chr>    <chr>                         <chr>            <chr>           
#> 1     1 RESTING  ENDSLINE                      Statement Text(… ENDSLINE        
#> # … with 3 more variables: diagnosis_statement_stmt_text_2 <chr>,
#> #   diagnosis_statement_stmt_flag_3 <chr>,
#> #   diagnosis_statement_stmt_text_3 <chr>
#> 
#> $original_diagnosis
#> # A tibble: 1 × 8
#>      id modality diagnosis_statement_stmt_flag diagnosis_state… diagnosis_state…
#>   <dbl> <chr>    <chr>                         <chr>            <chr>           
#> 1     1 RESTING  ENDSLINE                      Statement Text(… ENDSLINE        
#> # … with 3 more variables: diagnosis_statement_stmt_text_2 <chr>,
#> #   diagnosis_statement_stmt_flag_3 <chr>,
#> #   diagnosis_statement_stmt_text_3 <chr>
#> 
#> $qrs_times_types
#> # A tibble: 1 × 33
#>      id qrs_number qrs_type qrs_time qrs_number_2 qrs_type_2 qrs_time_2
#>   <dbl> <chr>      <chr>    <chr>    <chr>        <chr>      <chr>     
#> 1     1 1          0        808      2            0          1810      
#> # … with 26 more variables: qrs_number_3 <chr>, qrs_type_3 <chr>,
#> #   qrs_time_3 <chr>, qrs_number_4 <chr>, qrs_type_4 <chr>, qrs_time_4 <chr>,
#> #   qrs_number_5 <chr>, qrs_type_5 <chr>, qrs_time_5 <chr>, qrs_number_6 <chr>,
#> #   qrs_type_6 <chr>, qrs_time_6 <chr>, qrs_number_7 <chr>, qrs_type_7 <chr>,
#> #   qrs_time_7 <chr>, qrs_number_8 <chr>, qrs_type_8 <chr>, qrs_time_8 <chr>,
#> #   qrs_number_9 <chr>, qrs_type_9 <chr>, qrs_time_9 <chr>,
#> #   qrs_number_10 <chr>, qrs_type_10 <chr>, qrs_time_10 <chr>, …
#> 
#> $pharma_data
#> # A tibble: 1 × 5
#>      id pharma_r_rinterval pharma_unique_ecgid   pharma_p_pinter… pharma_cart_id
#>   <dbl> <chr>              <chr>                 <chr>            <chr>         
#> 1     1 1000               SCD06526477PA1005202… 1000             SCD06526477PA
```

## Data Sources

ECG XML files included in this package are simulated and do not
represent actual patient evaluations.
