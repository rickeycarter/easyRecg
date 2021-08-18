
<!-- README.md is generated from README.Rmd. Please edit that file -->

# easyRecg

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

## Retrieving ECG Meta Data

By default, `read_muse_xml_meta` returns the meta data related to Muse
versions, patient and test demographics, resting ECG measurements, and
original resting ECG measurements. The returned object is a named list
of data frames (or tibbles). The function can take a file path or a
collection of file paths. If more than one file path is present, the
results are appended together.

``` r
meta1 <- read_muse_xml_meta(file1, ids = 1)
meta1
#> $muse
#> # A tibble: 1 × 2
#>      id muse_version
#>   <dbl> <chr>       
#> 1     1 9.0.9.18167 
#> 
#> $patient_demo
#> # A tibble: 1 × 6
#>      id patient_id patient_age age_units gender patient_last_name
#>   <dbl> <chr>      <chr>       <chr>     <chr>  <chr>            
#> 1     1 JAX01234   60          YEARS     MALE   TEST 05          
#> 
#> $test_demo
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
#> $resting_ecg
#> # A tibble: 1 × 19
#>      id ventricular_rate atrial_rate pr_interval qrs_duration qt_interval
#>   <dbl> <chr>            <chr>       <chr>       <chr>        <chr>      
#> 1     1 60               60          158         78           364        
#> # … with 13 more variables: qt_corrected <chr>, p_axis <chr>, r_axis <chr>,
#> #   t_axis <chr>, qrs_count <chr>, q_onset <chr>, q_offset <chr>,
#> #   p_onset <chr>, p_offset <chr>, t_offset <chr>, ecg_sample_base <chr>,
#> #   ecg_sample_exponent <chr>, q_tc_frederica <chr>
#> 
#> $original_resting_ecg
#> # A tibble: 1 × 19
#>      id ventricular_rate atrial_rate pr_interval qrs_duration qt_interval
#>   <dbl> <chr>            <chr>       <chr>       <chr>        <chr>      
#> 1     1 60               60          158         78           364        
#> # … with 13 more variables: qt_corrected <chr>, p_axis <chr>, r_axis <chr>,
#> #   t_axis <chr>, qrs_count <chr>, q_onset <chr>, q_offset <chr>,
#> #   p_onset <chr>, p_offset <chr>, t_offset <chr>, ecg_sample_base <chr>,
#> #   ecg_sample_exponent <chr>, q_tc_frederica <chr>
```

### Customizing Output Results

In some cases, you may not want all data returned (e.g. to avoid sharing
PHI). To do so, you can take a whitelisting, blacklisting, or mixed
approach.

#### Whitelisting

To include only certain data sets or columns, you can specify a named
list of dataframes and columns. If a named element is `NA`, all
variables from that dataset are returned.

Here, we will return only muse data, patient id and age, and test date.

``` r
include <- list(
  muse = NA,
  patient_demo = c("patient_id", "patient_age", "age_units"),
  test_demo = "acquisition_date"
)

read_muse_xml_meta(file1, include = include)
#> $muse
#> # A tibble: 1 × 2
#>   id                                                                muse_version
#>   <chr>                                                             <chr>       
#> 1 /people/m208076/packages/easyRecg/inst/extdata/muse/muse_ecg1.xml 9.0.9.18167 
#> 
#> $patient_demo
#> # A tibble: 1 × 3
#>   patient_id patient_age age_units
#>   <chr>      <chr>       <chr>    
#> 1 JAX01234   60          YEARS    
#> 
#> $test_demo
#> # A tibble: 1 × 1
#>   acquisition_date
#>   <chr>           
#> 1 05-10-2021
```

#### Blacklisting

Similar to whitelisting, you can specifiy specific data sets or elements
to exclude. Here, if a named element is `NA`, the entire dataset is
removed.

Let’s remove all resting ecg data along with patient names:

``` r
exclude <- list(
  resting_ecg = NA,
  original_resting_ecg = NA,
  patient_demo = c("patient_last_name")
)

read_muse_xml_meta(file1, exclude = exclude, ids = 1)
#> $muse
#> # A tibble: 1 × 2
#>      id muse_version
#>   <dbl> <chr>       
#> 1     1 9.0.9.18167 
#> 
#> $patient_demo
#> # A tibble: 1 × 5
#>      id patient_id patient_age age_units gender
#>   <dbl> <chr>      <chr>       <chr>     <chr> 
#> 1     1 JAX01234   60          YEARS     MALE  
#> 
#> $test_demo
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
```

#### Mixed filtering

If you want more flexibility but don’t want to type out all
names/variables, you can use both `include` and `exclude`. The same
logic above applies here, however the `include` is always executed
first.

Here, we will return all patient demographics except name:

``` r
# Only consider the patient demographics
include <- list(patient_demo = NA)

# Remove patient name
exclude <- list(patient_demo = c("patient_last_name"))

read_muse_xml_meta(file1, include = include, exclude = exclude, ids = 1)
#> $patient_demo
#> # A tibble: 1 × 5
#>      id patient_id patient_age age_units gender
#>   <dbl> <chr>      <chr>       <chr>     <chr> 
#> 1     1 JAX01234   60          YEARS     MALE
```

## Data Sources

ECG XML files included in this package are simulated and do not
represent actual patient evaluations.
