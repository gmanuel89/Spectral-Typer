spectral_typer <- function() {
  #################### SPECTRAL TYPER ####################
  
  
  ### Program version (Specified by the program writer!!!!)
  R_script_version <- "2017.12.21.1"
  ### Force update (in case something goes wrong after an update, when checking for updates and reading the variable force_update, the script can automatically download the latest working version, even if the rest of the script is corrupted, because it is the first thing that reads)
  force_update <- FALSE
  ### GitHub URL where the R file is
  github_R_url <- "https://raw.githubusercontent.com/gmanuel89/Spectral-Typer/master/SPECTRAL%20TYPER.R"
  ### GitHub URL of the program's WIKI
  github_wiki_url <- "https://github.com/gmanuel89/Spectral-Typer/wiki"
  ### Name of the file when downloaded
  script_file_name <- "SPECTRAL TYPER"
  # Change log
  change_log <- "1. Auto adjust the intensity tolerance percentage value according to the spectral variability\n2. Variability estimation (mean signal CV)\n3. Peak enveloping\n4. More types of spectra files can be imported!\n4. Added the RMS normalization\n5. Parallel now in foreach!\n6. Allow to set tolerance in ppm\n7. Conditional formatting in Excel\n7. New names\n8. Now works with TXT replicates!\n9. Cropping spectra to a common range after alignment"
  
  
  
  
  
  ############## INSTALL AND LOAD THE REQUIRED PACKAGES
  install_and_load_required_packages(c("tcltk", "ggplot2", "ggdendro", "XML", "MALDIquant", "MALDIquantForeign", "weights", "stats", "foreach", "parallel", "corrplot", "weights"), repository = NULL, update_packages = FALSE, print_messages = TRUE)
  if (Sys.info()[1] == "Windows") {
    install_and_load_required_packages("doParallel")
  } else {
    install_and_load_required_packages("doMC")
  }
  
  
  
  
  
  
  
  
  ###################################### Initialize the variables (default values)
  filepath_reference <- NULL
  filepath_test <- NULL
  output_folder <- getwd()
  average_replicates_in_reference <- FALSE
  average_replicates_in_test <- FALSE
  low_intensity_peak_removal_threshold_method <- "element-wise"
  tof_mode <- "linear"
  spectra_format <- "fid"
  peak_picking_algorithm <- "SuperSmoother"
  similarity_criteria <- "correlation"
  correlation_method <- "pearson"
  correlation_mode <- "common signals"
  hierarchical_distance_method <- "euclidean"
  signal_intensity_evaluation <- "peak-wise adjusted percentage"
  file_type_export <- "csv"
  spectra_reference <- NULL
  spectra_test <- NULL
  peaks_reference <- NULL
  peaks_test <- NULL
  reference_folder_list <- character()
  test_folder_list <- character()
  reference_files <- character()
  test_files <- character()
  allow_parallelization <- FALSE
  transform_data_algorithm <- NULL
  smoothing_algorithm <- "SavitzkyGolay"
  smoothing_strength <- "medium"
  baseline_subtraction_algorithm <- "SNIP"
  baseline_subtraction_algorithm_parameter <- 200
  normalization_algorithm <- "TIC"
  normalization_mass_range <- NULL
  preprocess_spectra_in_packages_of <- 0
  mass_range <- c(3000,15000)
  spectral_alignment_algorithm <- NULL
  spectral_alignment_reference <- NULL
  tolerance_ppm <- 1000
  estimated_intensity_tolerance_percent <- NULL
  test_spectral_variability_list <- NULL
  reference_spectral_variability_list <- NULL
  peak_deisotoping <- FALSE
  peak_enveloping <- FALSE
  preprocessing_parameters <- list(mass_range = mass_range, transformation_algorithm = transform_data_algorithm, smoothing_algorithm = smoothing_algorithm, smoothing_strength = smoothing_strength, baseline_subtraction_algorithm = baseline_subtraction_algorithm, baseline_subtraction_algorithm_parameter = baseline_subtraction_algorithm_parameter, normalization_algorithm = normalization_algorithm, normalization_mass_range = normalization_mass_range, preprocess_spectra_in_packages_of = preprocess_spectra_in_packages_of, spectral_alignment_algorithm = spectral_alignment_algorithm, spectral_alignment_reference = spectral_alignment_reference)
  
  
  
  
  
  
  ################## Values of the variables (for displaying and dumping purposes)
  tof_mode_value <- "Linear"
  mass_range_value <- as.character(paste(mass_range[1], ",", mass_range[2]))
  average_replicates_in_reference_value <- "NO"
  average_replicates_in_test_value <- "NO"
  peak_picking_algorithm_value <- "Super Smoother"
  similarity_criteria_value <- "Pearson's correlation"
  correlation_method_value <- "Pearson"
  hierarchical_distance_method_value <- "Euclidean"
  low_intensity_peak_removal_threshold_method_value <- "element-wise"
  spectra_format_value <- "Xmass"
  allow_parallelization_value <- "NO"
  transform_data_value <- "None"
  smoothing_value <- paste0("YES", "\n( ", "SavitzkyGolay", ",\n" , "medium", " )")
  baseline_subtraction_value <- paste0("YES", "\n( ", "SNIP", ",\nIterations: ", "200", " )")
  normalization_value <- paste0("YES", "\n( ", "TIC", " )")
  spectral_alignment_value <- "None"
  spectral_alignment_algorithm_value <- ""
  spectral_alignment_reference_value <- ""
  preprocess_spectra_in_packages_of_value <- "0"
  tolerance_ppm_value <- as.character(tolerance_ppm)
  intensity_tolerance_percent_value <- "80"
  estimated_intensity_tolerance_percent_value <- ""
  peak_deisotoping_enveloping_value <- "None"
  intensity_correction_coefficient_value <- "1"
  
  
  
  
  
  
  ##################################################### DEFINE WHAT THE BUTTONS DO
  
  ##### Check for updates (from my GitHub page) (it just updates the label telling the user if there are updates) (it updates the check for updates value that is called by the label). The function will read also if an update should be forced.
  check_for_updates_function <- function() {
    ### Initialize the version number
    online_version_number <- NULL
    ### Initialize the force update
    online_force_update <- FALSE
    ### Initialize the variable that says if there are updates
    update_available <- FALSE
    ### Initialize the change log
    online_change_log <- "Bug fixes"
    # Check if there is internet connection by pinging a website
    there_is_internet <- check_internet_connection(method = "getURL", website_to_ping = "www.google.it")
    # Check for updates only in case of working internet connection
    if (there_is_internet == TRUE) {
      try({
        ### Read the file from the web (first 10 lines)
        online_file <- readLines(con = github_R_url)
        ### Retrieve the version number
        for (l in online_file) {
          if (length(grep("R_script_version <-", l, fixed = TRUE)) > 0) {
            # Isolate the "variable" value
            online_version_number <- unlist(strsplit(l, "R_script_version <- ", fixed = TRUE))[2]
            # Remove the quotes
            online_version_number <- unlist(strsplit(online_version_number, "\""))[2]
            break
          }
        }
        ### Retrieve the force update
        for (l in online_file) {
          if (length(grep("force_update <-", l, fixed = TRUE)) > 0) {
            # Isolate the "variable" value
            online_force_update <- as.logical(unlist(strsplit(l, "force_update <- ", fixed = TRUE))[2])
            break
          }
          if (is.null(online_force_update)) {
            online_force_update <- FALSE
          }
        }
        ### Retrieve the change log
        for (l in online_file) {
          if (length(grep("change_log <-", l, fixed = TRUE)) > 0) {
            # Isolate the "variable" value
            online_change_log <- unlist(strsplit(l, "change_log <- ", fixed = TRUE))[2]
            # Remove the quotes
            online_change_log_split <- unlist(strsplit(online_change_log, "\""))[2]
            # Split at the \n
            online_change_log_split <- unlist(strsplit(online_change_log_split, "\\\\n"))
            # Put it back to the character
            online_change_log <- ""
            for (o in online_change_log_split) {
              online_change_log <- paste(online_change_log, o, sep = "\n")
            }
            break
          }
        }
        ### Split the version number in YYYY.MM.DD
        online_version_YYYYMMDDVV <- unlist(strsplit(online_version_number, ".", fixed = TRUE))
        ### Compare with the local version
        local_version_YYYYMMDDVV = unlist(strsplit(R_script_version, ".", fixed = TRUE))
        ### Check the versions (from the Year to the Day)
        # Check the year
        if (as.numeric(local_version_YYYYMMDDVV[1]) < as.numeric(online_version_YYYYMMDDVV[1])) {
          update_available <- TRUE
        }
        # If the year is the same (update is FALSE), check the month
        if (update_available == FALSE) {
          if ((as.numeric(local_version_YYYYMMDDVV[1]) == as.numeric(online_version_YYYYMMDDVV[1])) && (as.numeric(local_version_YYYYMMDDVV[2]) < as.numeric(online_version_YYYYMMDDVV[2]))) {
            update_available <- TRUE
          }
        }
        # If the month and the year are the same (update is FALSE), check the day
        if (update_available == FALSE) {
          if ((as.numeric(local_version_YYYYMMDDVV[1]) == as.numeric(online_version_YYYYMMDDVV[1])) && (as.numeric(local_version_YYYYMMDDVV[2]) == as.numeric(online_version_YYYYMMDDVV[2])) && (as.numeric(local_version_YYYYMMDDVV[3]) < as.numeric(online_version_YYYYMMDDVV[3]))) {
            update_available <- TRUE
          }
        }
        # If the day and the month and the year are the same (update is FALSE), check the daily version
        if (update_available == FALSE) {
          if ((as.numeric(local_version_YYYYMMDDVV[1]) == as.numeric(online_version_YYYYMMDDVV[1])) && (as.numeric(local_version_YYYYMMDDVV[2]) == as.numeric(online_version_YYYYMMDDVV[2])) && (as.numeric(local_version_YYYYMMDDVV[3]) == as.numeric(online_version_YYYYMMDDVV[3])) && (as.numeric(local_version_YYYYMMDDVV[4]) < as.numeric(online_version_YYYYMMDDVV[4]))) {
            update_available <- TRUE
          }
        }
        ### Return messages
        if (is.null(online_version_number)) {
          # The version number could not be ckecked due to internet problems
          # Update the label
          check_for_updates_value <- paste("Version: ", R_script_version, "\nUpdates not checked:\nconnection problems", sep = "")
        } else {
          if (update_available == TRUE) {
            # Update the label
            check_for_updates_value <- paste("Version: ", R_script_version, "\nUpdate available:\n", online_version_number, sep = "")
          } else {
            # Update the label
            check_for_updates_value <- paste("Version: ", R_script_version, "\nNo updates available", sep = "")
          }
        }
      }, silent = TRUE)
    }
    ### Something went wrong: library not installed, retrieving failed, errors in parsing the version number
    if (is.null(online_version_number)) {
      # Update the label
      check_for_updates_value <- paste("Version: ", R_script_version, "\nUpdates not checked:\nconnection problems", sep = "")
    }
    # Escape the function
    update_available <<- update_available
    online_change_log <<- online_change_log
    check_for_updates_value <<- check_for_updates_value
    online_version_number <<- online_version_number
    online_force_update <<- online_force_update
  }
  
  ##### Download the updated file (from my GitHub page)
  download_updates_function <- function() {
    # Download updates only if there are updates available
    if (update_available == TRUE || online_force_update == TRUE) {
      # Changelog
      tkmessageBox(title = "Changelog", message = paste0("The updated script contains the following changes:\n", online_change_log), icon = "info")
      # Initialize the variable which says if the file has been downloaded successfully
      file_downloaded <- FALSE
      # Choose where to save the updated script
      tkmessageBox(title = "Download folder", message = "Select where to save the updated script file", icon = "info")
      download_folder <- tclvalue(tkchooseDirectory())
      # Download the file only if a download folder is specified, otherwise don't
      if (download_folder != "") {
        # Go to the working directory
        setwd(download_folder)
        tkmessageBox(message = paste0("The updated script file will be downloaded in:\n\n", download_folder))
        # Download the file
        try({
          download.file(url = github_R_url, destfile = paste0(script_file_name, ".R"), method = "auto")
          file_downloaded <- TRUE
        }, silent = TRUE)
        if (file_downloaded == TRUE) {
          tkmessageBox(title = "Updated file downloaded!", message = paste0("The updated script, named:\n\n", paste0(script_file_name, ".R"), "\n\nhas been downloaded to:\n\n", download_folder, "\n\nThe current window will now close and the new updated script will be loaded!"), icon = "info")
          # Destroy the window
          try(tkdestroy(window), silent = TRUE)
          # Relaunch the script
          try(source(paste0(script_file_name, ".R")), silent = TRUE)
        } else {
          tkmessageBox(title = "Connection problem", message = paste("The updated script file could not be downloaded due to internet connection problems!\n\nManually download the updated script file at:\n\n", github_R_url, sep = ""), icon = "warning")
        }
      } else {
        # No download folder specified!
        tkmessageBox(message = "The updated script file will not be downloaded!")
      }
    } else {
      tkmessageBox(title = "No update available", message = "NO UPDATES AVAILABLE!\n\nThe latest version is running!", icon = "info")
    }
    # Raise the focus on the main window (if there is)
    try(tkraise(window), silent = TRUE)
  }
  
  ### Downloading forced updates
  check_for_updates_function()
  if (online_force_update == TRUE) {
    download_updates_function()
  }
  
  ### Force check for updates
  force_check_for_updates_function <- function() {
    # Check for updates
    check_for_updates_function()
    # Display a message
    if (update_available == TRUE) {
      # Message
      tkmessageBox(title = "Update available", message = paste0("Update available!\n", online_version_number, "\n\nPress the 'DOWNLOAD UPDATE...' button to retrieve the updated script!"), icon = "info")
    } else {
      # Message
      tkmessageBox(title = "No update available", message = "No update available!", icon = "info")
    }
  }
  
  ##### Preprocessing window
  preprocessing_window_function <- function() {
    ##### Functions
    # Transform the data
    transform_data_choice <- function() {
      # Ask for the algorithm
      transform_data_algorithm_input <- select.list(c("Square root", "Natural logarithm", "Decimal logarithm", "Binary Logarithm", "None"), title = "Data transformation", multiple = FALSE, preselect = "None")
      # Raise the focus on the preproc window
      tkraise(window)
      tkraise(preproc_window)
      # Default and fix
      if (transform_data_algorithm_input == "Square root") {
        transform_data_algorithm <- "sqrt"
      } else if (transform_data_algorithm_input == "Natural logarithm") {
        transform_data_algorithm <- "log"
      } else if (transform_data_algorithm_input == "Binary Logarithm") {
        transform_data_algorithm <- "log2"
      } else if (transform_data_algorithm_input == "Decimal logarithm") {
        transform_data_algorithm <- "log10"
      } else if (transform_data_algorithm_input == "" || transform_data_algorithm_input == "None") {
        transform_data_algorithm <- NULL
      }
      # Set the value of the displaying label
      if (!is.null(transform_data_algorithm)) {
        transform_data_value <- paste0("YES", "\n( ", transform_data_algorithm_input, " )")
      } else {
        transform_data_value <- "None"
      }
      transform_data_value_label <- tklabel(preproc_window, text = transform_data_value, font = label_font, bg = "white", width = 20, height = 2)
      tkgrid(transform_data_value_label, row = 3, column = 2, padx = c(5, 5), pady = c(5, 5))
      # Escape the function
      transform_data_algorithm <<- transform_data_algorithm
      transform_data_value <<- transform_data_value
    }
    # Smoothing
    smoothing_choice <- function() {
      # Ask for the algorithm
      smoothing_algorithm_input <- select.list(c("Savitzky-Golay","Moving Average", "None"), title = "Smoothing algorithm", multiple = FALSE, preselect = "SavitzkyGolay")
      # Raise the focus on the preproc window
      tkraise(window)
      tkraise(preproc_window)
      # Default and fix
      if (smoothing_algorithm_input == "" || smoothing_algorithm_input == "Savitzky-Golay") {
        smoothing_algorithm <- "SavitzkyGolay"
      } else if (smoothing_algorithm_input == "Moving Average") {
        smoothing_algorithm <- "MovingAverage"
      } else if (smoothing_algorithm_input == "None") {
        smoothing_algorithm <- NULL
      }
      # Strength
      if (!is.null(smoothing_algorithm)) {
        smoothing_strength <- select.list(c("small", "medium", "strong", "stronger"), title = "Smoothing strength", multiple = FALSE, preselect = "medium")
        # Raise the focus on the preproc window
        tkraise(window)
        tkraise(preproc_window)
        if (smoothing_strength == "") {
          smoothing_strength <- "medium"
        }
      }
      # Set the value of the displaying label
      if (!is.null(smoothing_algorithm)) {
        smoothing_value <- paste0("YES", "\n( ", smoothing_algorithm_input, ",\n" , smoothing_strength, " )")
      } else {
        smoothing_value <- "None"
      }
      smoothing_value_label <- tklabel(preproc_window, text = smoothing_value, font = label_font, bg = "white", width = 20, height = 3)
      tkgrid(smoothing_value_label, row = 4, column = 2, padx = c(5, 5), pady = c(5, 5))
      # Escape the function
      smoothing_strength <<- smoothing_strength
      smoothing_algorithm <<- smoothing_algorithm
      smoothing_value <<- smoothing_value
    }
    # Baseline subtraction
    baseline_subtraction_choice <- function() {
      # Ask for the algorithm
      baseline_subtraction_algorithm <- select.list(c("SNIP", "TopHat", "ConvexHull", "median", "None"), title = "Baseline subtraction algorithm", multiple = FALSE, preselect = "SNIP")
      # Raise the focus on the preproc window
      tkraise(window)
      tkraise(preproc_window)
      # Default
      if (baseline_subtraction_algorithm == "") {
        baseline_subtraction_algorithm <- "SNIP"
        baseline_subtraction_algorithm_parameter <- 200
      }
      if (baseline_subtraction_algorithm == "None") {
        baseline_subtraction_algorithm <- NULL
      }
      # SNIP
      if (!is.null(baseline_subtraction_algorithm) && baseline_subtraction_algorithm == "SNIP") {
        baseline_subtraction_algorithm_parameter <- tclvalue(baseline_subtraction_algorithm_parameter2)
        baseline_subtraction_algorithm_parameter_value <- as.character(baseline_subtraction_algorithm_parameter)
        baseline_subtraction_algorithm_parameter <- as.integer(baseline_subtraction_algorithm_parameter)
      } else if (!is.null(baseline_subtraction_algorithm) && baseline_subtraction_algorithm == "TopHat") {
        baseline_subtraction_algorithm_parameter <- tclvalue(baseline_subtraction_algorithm_parameter2)
        baseline_subtraction_algorithm_parameter_value <- as.character(baseline_subtraction_algorithm_parameter)
        baseline_subtraction_algorithm_parameter <- as.integer(baseline_subtraction_algorithm_parameter)
      } else if (!is.null(baseline_subtraction_algorithm) && baseline_subtraction_algorithm == "median") {
        baseline_subtraction_algorithm_parameter <- tclvalue(baseline_subtraction_algorithm_parameter2)
        baseline_subtraction_algorithm_parameter_value <- as.character(baseline_subtraction_algorithm_parameter)
        baseline_subtraction_algorithm_parameter <- as.integer(baseline_subtraction_algorithm_parameter)
      }
      # Set the value of the displaying label
      if (!is.null(baseline_subtraction_algorithm) && baseline_subtraction_algorithm == "SNIP") {
        baseline_subtraction_value <- paste0("YES", "\n( ", baseline_subtraction_algorithm, ",\nIterations: ", baseline_subtraction_algorithm_parameter, " )")
      } else if (!is.null(baseline_subtraction_algorithm) && baseline_subtraction_algorithm == "TopHat") {
        baseline_subtraction_value <- paste0("YES", "\n( ", baseline_subtraction_algorithm, ",\nHalf window size: ", baseline_subtraction_algorithm_parameter, " )")
      } else if (!is.null(baseline_subtraction_algorithm) && baseline_subtraction_algorithm == "median") {
        baseline_subtraction_value <- paste0("YES", "\n( ", baseline_subtraction_algorithm, ",\nHalf window size: ", baseline_subtraction_algorithm_parameter, " )")
      } else if (!is.null(baseline_subtraction_algorithm) && baseline_subtraction_algorithm == "ConvexHull") {
        baseline_subtraction_value <- paste0("YES", "\n( ", baseline_subtraction_algorithm, ")")
      } else {
        baseline_subtraction_value <- "None"
      }
      baseline_subtraction_value_label <- tklabel(preproc_window, text = baseline_subtraction_value, font = label_font, bg = "white", width = 20, height = 3)
      tkgrid(baseline_subtraction_value_label, row = 5, column = 3, padx = c(5, 5), pady = c(5, 5))
      # Escape the function
      baseline_subtraction_algorithm_parameter <<- baseline_subtraction_algorithm_parameter
      baseline_subtraction_algorithm <<- baseline_subtraction_algorithm
      baseline_subtraction_value <<- baseline_subtraction_value
    }
    # Normalization
    normalization_choice <- function() {
      # Ask for the algorithm
      normalization_algorithm <- select.list(c("TIC", "RMS", "PQN", "median", "None"), title = "Normalization algorithm", multiple = FALSE, preselect = "TIC")
      # Raise the focus on the preproc window
      tkraise(window)
      tkraise(preproc_window)
      if (normalization_algorithm == "") {
        normalization_algorithm <- "TIC"
      }
      if (normalization_algorithm == "None") {
        normalization_algorithm <- NULL
      }
      # TIC
      if (!is.null(normalization_algorithm) && normalization_algorithm == "TIC") {
        normalization_mass_range <- tclvalue(normalization_mass_range2)
        normalization_mass_range_value <- as.character(normalization_mass_range)
        if (normalization_mass_range != 0 && normalization_mass_range != "") {
          normalization_mass_range <- unlist(strsplit(normalization_mass_range, ","))
          normalization_mass_range <- as.numeric(normalization_mass_range)
        } else if (normalization_mass_range == 0 || normalization_mass_range == "") {
          normalization_mass_range <- NULL
        }
      }
      # Set the value of the displaying label
      if (!is.null(normalization_algorithm) && normalization_algorithm != "TIC") {
        normalization_value <- paste0("YES", "\n( ", normalization_algorithm, " )\n")
      } else if (!is.null(normalization_algorithm) && normalization_algorithm == "TIC") {
        if (!is.null(normalization_mass_range)) {
          normalization_value <- paste0("YES", "\n( ", normalization_algorithm, ",\nrange:\n", normalization_mass_range_value, " )")
        } else {
          normalization_value <- paste0("YES", "\n( ", normalization_algorithm, " )")
        }
      } else {
        normalization_value <- "None"
      }
      normalization_value_label <- tklabel(preproc_window, text = normalization_value, font = label_font, bg = "white", width = 20, height = 4)
      tkgrid(normalization_value_label, row = 7, column = 3, padx = c(5, 5), pady = c(5, 5))
      # Escape the function
      normalization_mass_range <<- normalization_mass_range
      normalization_algorithm <<- normalization_algorithm
      normalization_value <<- normalization_value
    }
    # Spectral alignment
    spectral_alignment_choice <- function() {
      # Ask for the algorithm
      spectral_alignment_algorithm <- select.list(c("cubic", "quadratic", "linear", "lowess", "None"), title = "Spectral alignment algorithm", multiple = FALSE, preselect = "cubic")
      # Raise the focus on the preproc window
      tkraise(window)
      tkraise(preproc_window)
      # Default
      if (spectral_alignment_algorithm == "") {
        spectral_alignment_algorithm <- "None"
      }
      if (spectral_alignment_algorithm == "None") {
        spectral_alignment_algorithm <- NULL
      }
      ## Ask for the reference peaklist
      if (!is.null(spectral_alignment_algorithm)) {
        spectral_alignment_reference <- select.list(c("auto","average spectrum", "skyline spectrum"), title = "Spectral alignment reference", multiple = FALSE, preselect = "average spectrum")
        # Raise the focus on the preproc window
        tkraise(window)
        tkraise(preproc_window)
        if (spectral_alignment_reference == "") {
          spectral_alignment_reference <- "average spectrum"
        }
      } else {
        spectral_alignment_reference <- NULL
      }
      # Set the value of the displaying label
      if (!is.null(spectral_alignment_algorithm)) {
        spectral_alignment_value <- paste0("YES", "\n( ", spectral_alignment_algorithm, ",\n", spectral_alignment_reference, " )")
      } else {
        spectral_alignment_value <- "None"
      }
      spectral_alignment_value_label <- tklabel(preproc_window, text = spectral_alignment_value, font = label_font, bg = "white", width = 20, height = 3)
      tkgrid(spectral_alignment_value_label, row = 8, column = 2, padx = c(5, 5), pady = c(5, 5))
      # Escape the function
      spectral_alignment_algorithm <<- spectral_alignment_algorithm
      spectral_alignment_reference <<- spectral_alignment_reference
      spectral_alignment_value <<- spectral_alignment_value
    }
    # TOF mode
    tof_mode_choice <- function() {
      # Catch the value from the menu
      tof_mode <- select.list(c("Linear", "Reflectron"), title = "TOF mode")
      # Raise the focus on the preproc window
      tkraise(window)
      tkraise(preproc_window)
      # Default
      if (tof_mode == "" || tof_mode == "Linear") {
        tof_mode <- "linear"
      }
      if (tof_mode == "Reflectron") {
        tof_mode <- "reflectron"
      }
      # Set the value of the displaying label
      if (tof_mode == "linear") {
        tof_mode_value <- "Linear"
      } else if (tof_mode == "reflectron") {
        tof_mode_value <- "Reflectron"
      }
      tof_mode_value_label <- tklabel(preproc_window, text = tof_mode_value, font = label_font, bg = "white", width = 20)
      tkgrid(tof_mode_value_label, row = 2, column = 3, padx = c(5, 5), pady = c(5, 5))
      # Escape the function
      tof_mode <<- tof_mode
      tof_mode_value <<- tof_mode_value
    }
    # Commit preprocessing
    commit_preprocessing_function <- function() {
      # Get the values (they are filled with the default anyway)
      # Mass range
      mass_range <- tclvalue(mass_range2)
      mass_range <- as.numeric(unlist(strsplit(mass_range, ",")))
      mass_range_value <- as.character(paste(mass_range[1], ",", mass_range[2]))
      # Preprocessing
      preprocess_spectra_in_packages_of <- tclvalue(preprocess_spectra_in_packages_of2)
      preprocess_spectra_in_packages_of <- as.integer(preprocess_spectra_in_packages_of)
      preprocess_spectra_in_packages_of_value <- as.character(preprocess_spectra_in_packages_of)
      # Preprocessing
      tolerance_ppm <- tclvalue(tolerance_ppm2)
      if (tolerance_ppm == "") {
        tolerance_ppm <- NULL
        tolerance_ppm_value <- ""
      } else {
        tolerance_ppm <- as.numeric(tolerance_ppm)
        tolerance_ppm_value <- as.character(tolerance_ppm)
      }
      # Escape the function
      mass_range <<- mass_range
      mass_range_value <<- mass_range_value
      preprocess_spectra_in_packages_of <<- preprocess_spectra_in_packages_of
      preprocess_spectra_in_packages_of_value <<- preprocess_spectra_in_packages_of_value
      tolerance_ppm <<- tolerance_ppm
      tolerance_ppm_value <<- tolerance_ppm_value
      preprocessing_parameters <<- list(mass_range = mass_range, transformation_algorithm = transform_data_algorithm, smoothing_algorithm = smoothing_algorithm, smoothing_strength = smoothing_strength, baseline_subtraction_algorithm = baseline_subtraction_algorithm, baseline_subtraction_algorithm_parameter = baseline_subtraction_algorithm_parameter, normalization_algorithm = normalization_algorithm, normalization_mass_range = normalization_mass_range, preprocess_spectra_in_packages_of = preprocess_spectra_in_packages_of, spectral_alignment_algorithm = spectral_alignment_algorithm, spectral_alignment_reference = spectral_alignment_reference)
      # Destroy the window upon committing
      tkdestroy(preproc_window)
      # Raise the focus on the preproc window
      tkraise(window)
    }
    ##### List of variables, whose values are taken from the entries in the GUI (create new variables for the sub window, that will replace the ones in the global environment, only if the default are changed)
    mass_range2 <- tclVar("")
    preprocess_spectra_in_packages_of2 <- tclVar("")
    tolerance_ppm2 <- tclVar("")
    baseline_subtraction_algorithm_parameter2 <- tclVar("")
    normalization_mass_range2 <- tclVar("")
    ##### Window
    preproc_window <- tktoplevel(bg = "white")
    tkwm.resizable(preproc_window, FALSE, FALSE)
    tktitle(preproc_window) <- "Spectral preprocessing parameters"
    #tkpack.propagate(preproc_window, FALSE)
    # Mass range
    mass_range_label <- tklabel(preproc_window, text = "Mass range", font = label_font, bg = "white", width = 20)
    mass_range_entry <- tkentry(preproc_window, textvariable = mass_range2, font = entry_font, bg = "white", width = 20, justify = "center")
    tkinsert(mass_range_entry, "end", as.character(paste(mass_range[1],",",mass_range[2])))
    # Preprocessing (in packages of)
    preprocess_spectra_in_packages_of_label <- tklabel(preproc_window, text="Preprocess spectra\nin packages of", font = label_font, bg = "white", width = 20)
    preprocess_spectra_in_packages_of_entry <- tkentry(preproc_window, textvariable = preprocess_spectra_in_packages_of2, font = entry_font, bg = "white", width = 10, justify = "center")
    tkinsert(preprocess_spectra_in_packages_of_entry, "end", as.character(preprocess_spectra_in_packages_of))
    # Tof mode
    tof_mode_label <- tklabel(preproc_window, text="Select the TOF mode", font = label_font, bg = "white", width = 20)
    tof_mode_entry <- tkbutton(preproc_window, text="Choose the TOF mode", command = tof_mode_choice, font = button_font, bg = "white", width = 20)
    # Tolerance in ppm
    tolerance_ppm_label <- tklabel(preproc_window, text="Tolerance (in ppm)", font = label_font, bg = "white", width = 20)
    tolerance_ppm_entry <- tkentry(preproc_window, textvariable = tolerance_ppm2, font = entry_font, bg = "white", width = 10, justify = "center")
    tkinsert(tolerance_ppm_entry, "end", as.character(tolerance_ppm))
    # Transform the data
    transform_data_button <- tkbutton(preproc_window, text="Data transformation", command = transform_data_choice, font = button_font, bg = "white", width = 20)
    # Smoothing
    smoothing_button <- tkbutton(preproc_window, text="Smoothing", command = smoothing_choice, font = button_font, bg = "white", width = 20)
    # Baseline subtraction
    baseline_subtraction_button <- tkbutton(preproc_window, text="Baseline subtraction", command = baseline_subtraction_choice, font = button_font, bg = "white", width = 20)
    baseline_subtraction_algorithm_parameter_entry <- tkentry(preproc_window, textvariable = baseline_subtraction_algorithm_parameter2, font = entry_font, bg = "white", width = 10, justify = "center")
    tkinsert(baseline_subtraction_algorithm_parameter_entry, "end", as.character(baseline_subtraction_algorithm_parameter))
    # Normalization
    normalization_button <- tkbutton(preproc_window, text="Normalization", command = normalization_choice, font = button_font, bg = "white", width = 20)
    normalization_mass_range_entry <- tkentry(preproc_window, textvariable = normalization_mass_range2, font = entry_font, bg = "white", width = 20, justify = "center")
    tkinsert(normalization_mass_range_entry, "end", as.character(normalization_mass_range))
    # Spectral alignment
    spectral_alignment_button <- tkbutton(preproc_window, text="Align spectra", command = spectral_alignment_choice, font = button_font, bg = "white", width = 20)
    # Commit preprocessing
    commit_preprocessing_button <- tkbutton(preproc_window, text="Commit preprocessing", command = commit_preprocessing_function, font = button_font, bg = "white", width = 20)
    ##### Displaying labels
    tof_mode_value_label <- tklabel(preproc_window, text = tof_mode_value, font = label_font, bg = "white", width = 20)
    transform_data_value_label <- tklabel(preproc_window, text = transform_data_value, font = label_font, bg = "white", width = 20, height = 2)
    smoothing_value_label <- tklabel(preproc_window, text = smoothing_value, font = label_font, bg = "white", width = 20, height = 3)
    baseline_subtraction_value_label <- tklabel(preproc_window, text = baseline_subtraction_value, font = label_font, bg = "white", width = 20, height = 3)
    normalization_value_label <- tklabel(preproc_window, text = normalization_value, font = label_font, bg = "white", width = 20, height = 4)
    spectral_alignment_value_label <- tklabel(preproc_window, text = spectral_alignment_value, font = label_font, bg = "white", width = 20, height = 3)
    #### Geometry manager
    tkgrid(mass_range_label, row = 1, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(mass_range_entry, row = 1, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(tof_mode_label, row = 2, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(tof_mode_entry, row = 2, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(tof_mode_value_label, row = 2, column = 3, padx = c(5, 5), pady = c(5, 5))
    tkgrid(transform_data_button, row = 3, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(transform_data_value_label, row = 3, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(smoothing_button, row = 4, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(smoothing_value_label, row = 4, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(baseline_subtraction_button, row = 5, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(baseline_subtraction_algorithm_parameter_entry, row = 5, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(baseline_subtraction_value_label, row = 5, column = 3, padx = c(5, 5), pady = c(5, 5))
    tkgrid(normalization_button, row = 7, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(normalization_mass_range_entry, row = 7, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(normalization_value_label, row = 7, column = 3, padx = c(5, 5), pady = c(5, 5))
    tkgrid(spectral_alignment_button, row = 8, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(spectral_alignment_value_label, row = 8, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(preprocess_spectra_in_packages_of_label, row = 9, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(preprocess_spectra_in_packages_of_entry, row = 9, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(tolerance_ppm_label, row = 10, column = 1, padx = c(5, 5), pady = c(5, 5))
    tkgrid(tolerance_ppm_entry, row = 10, column = 2, padx = c(5, 5), pady = c(5, 5))
    tkgrid(commit_preprocessing_button, row = 11, column = 1, columnspan = 3, padx = c(5, 5), pady = c(5, 5))
  }
  
  ##### File type (export)
  file_type_export_choice <- function() {
    # Catch the value from the menu
    file_type_export <- select.list(c("csv","xlsx","xls"), title="Choose output file format", multiple = FALSE, preselect = "csv")
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (file_type_export == "") {
      file_type_export <- "csv"
    }
    # Install the packages
    if (file_type_export == "xls" || file_type_export == "xlsx") {
      # Try to install the XLConnect (it will fail if Java is not installed)
      Java_is_installed <- FALSE
      try({
        install_and_load_required_packages("XLConnect")
        Java_is_installed <- TRUE
      }, silent = TRUE)
      # If it didn't install successfully, set to CSV
      if (Java_is_installed == FALSE) {
        tkmessageBox(title = "Java not installed", message = "Java is not installed, therefore the package XLConnect cannot be installed and loaded.\nThe output format is switched back to CSV", icon = "warning")
        file_type_export <- "csv"
      }
    }
    # Escape the function
    file_type_export <<- file_type_export
    # Set the value of the displaying label
    file_type_export_value_label <- tklabel(window, text = file_type_export, font = label_font, bg = "white", width = 20)
    tkgrid(file_type_export_value_label, row = 3, column = 4, padx = c(5, 5), pady = c(5, 5))
  }
  
  ##### File name (export)
  set_file_name <- function() {
    # Retrieve the peaklist file name from the entry...
    filename <- tclvalue(file_name)
    # Add the date and time to the filename
    current_date <- unlist(strsplit(as.character(Sys.time()), " "))[1]
    current_date_split <- unlist(strsplit(current_date, "-"))
    current_time <- unlist(strsplit(as.character(Sys.time()), " "))[2]
    current_time_split <- unlist(strsplit(current_time, ":"))
    final_date <- ""
    for (x in 1:length(current_date_split)) {
      final_date <- paste0(final_date, current_date_split[x])
    }
    final_time <- ""
    for (x in 1:length(current_time_split)) {
      final_time <- paste0(final_time, current_time_split[x])
    }
    final_date_time <- paste(final_date, final_time, sep = "_")
    filename <- paste0(filename, " (", final_date_time, ")")
    # Create a copy for the subfolder name (for the spectral files)
    filename_subfolder <- filename
    # Add the extension if it is not present in the filename
    if (file_type_export == "csv") {
      if (length(grep(".csv", filename, fixed = TRUE)) == 1) {
        filename <- filename
      }  else {filename <- paste0(filename, ".csv")}
    }
    if (file_type_export == "xlsx") {
      if (length(grep(".xlsx", filename, fixed = TRUE)) == 1) {
        filename <- filename
      }  else {filename <- paste0(filename, ".xlsx")}
    }
    if (file_type_export == "xls") {
      if (length(grep(".xls", filename, fixed = TRUE)) == 1) {
        filename <- filename
      }  else {filename <- paste0(filename, ".xls")}
    }
    # Set the value for displaying purposes
    filename_value <- filename
    #### Exit the function and put the variable into the R workspace
    filename <<- filename
    filename_subfolder <<- filename_subfolder
  }
  
  ##### Library
  select_reference_function <- function() {
    ########## Prompt if a folder has to be selected or a single file
    # Catch the value from the popping out menu
    spectra_input_type <- select.list(c("Database file","Folder"), title="Folder or DB file?", preselect = "Folder", multiple = FALSE)
    # Raise the focus on the preproc window
    tkraise(window)
    if (spectra_input_type == "") {
      spectra_input_type <- "Folder"
    }
    if (spectra_input_type == "Folder") {
      filepath_reference_select <- tkmessageBox(title = "Library", message = "Select the folder for the spectra to be taken as reference.\n\n\nThe reference folder should be structured like this:\n\nClass-Entry folders/Treatment folders/Replicate spectral files (imzML, TXT, CSV, MSD files or folder containing Bruker's Xmass spectrum data)\n\nor\n\nClass-Entry folders/Replicate spectral files (imzML, TXT, CSV, MSD files or folder containing Bruker's Xmass spectrum data)\n\nor\n\nSpectral files (imzML, TXT, CSV, MSD files or folder containing Bruker's Xmass spectrum data)", icon = "info")
      filepath_reference <- tclvalue(tkchooseDirectory())
      if (!nchar(filepath_reference)) {
        tkmessageBox(message = "No folder selected")
      }  else {
        tkmessageBox(message = paste("The directory selected for the reference is", filepath_reference))
      }
    } else if (spectra_input_type == "Database file") {
      filepath_reference_select <- tkmessageBox(title = "Library", message = "Select a previously dumped database RData file", icon = "info")
      filepath_reference <- tclvalue(tkgetOpenFile(filetypes="{{RData database files} {.RData}}"))
      if (!nchar(filepath_reference)) {
        tkmessageBox(message = "No file selected")
      } else {
        tkmessageBox(message = paste("The spectra for the reference will be read from:", filepath_reference))
      }
    }
    # Set the value for displaying purposes
    filepath_reference_value <- filepath_reference
    # Exit the function and put the variable into the R workspace
    filepath_reference <<- filepath_reference
    filepath_reference_value <<- filepath_reference_value
  }
  
  ##### Samples
  select_samples_function <-function() {
    filepath_test_select <- tkmessageBox(title = "Browse Samples", message = "Select the folder for the spectra to be tested.\n\n\nThe sample folder should be organized like this:\n\nSample folders/Treatment folders/Replicate spectral files (imzML, TXT, CSV, MSD files or folder containing Bruker's Xmass spectrum data)\n\nor\n\nSpectral files (imzML, TXT, CSV, MSD files or folder containing Bruker's Xmass spectrum data)", icon = "info")
    filepath_test <- tclvalue(tkchooseDirectory())
    if (!nchar(filepath_test)) {
      tkmessageBox(message = "No folder selected")
    }  else {
      tkmessageBox(message = paste("The sample spectra will be read from:", filepath_test))
    }
    # Set the value for displaying purposes
    filepath_test_value <- filepath_test
    # Exit the function and put the variable into the R workspace
    filepath_test <<- filepath_test
    filepath_test_value <<- filepath_test_value
  }
  
  ##### Output
  browse_output_function <- function() {
    output_folder <- tclvalue(tkchooseDirectory())
    if (!nchar(output_folder)) {
      # Get the output folder from the default working directory
      output_folder <- getwd()
    }
    tkmessageBox(message = paste("Every file will be saved in:\n\n", output_folder))
    setwd(output_folder)
    tkmessageBox(message = "A sub-directory named 'SCORE X' will be created for each run!")
    # Exit the function and put the variable into the R workspace
    output_folder <<- output_folder
    # Raise the focus on the preproc window
    tkraise(window)
  }
  
  ##### Close
  quit_function <- function() {
    tkdestroy(window)
  }
  
  ##### Exit
  end_session_function <- function() {
    q(save="no")
  }
  
  ##### Peaks deisotoping or enveloping
  peak_deisotoping_enveloping_choice <- function() {
    # Catch the value from the menu
    peak_deisotoping_enveloping <- select.list(c("Peak Deisotoping","Peak Enveloping", "None"), title = "Peak Deisotoping/Enveloping", multiple = FALSE, preselect = "Peak Deisotoping")
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (peak_deisotoping_enveloping == "") {
      peak_deisotoping_enveloping <- "Peak Deisotoping"
    }
    if (peak_deisotoping_enveloping == "Peak Deisotoping") {
      peak_deisotoping <- TRUE
      peak_enveloping <- FALSE
    } else if (peak_deisotoping_enveloping == "Peak Enveloping") {
      peak_deisotoping <- FALSE
      peak_enveloping <- TRUE
    } else if (peak_deisotoping_enveloping == "None") {
      peak_deisotoping <- FALSE
      peak_enveloping <- FALSE
    }
    # Set the value of the displaying label
    peak_deisotoping_enveloping_value <- peak_deisotoping_enveloping
    peak_deisotoping_enveloping_value_label <- tklabel(window, text = peak_deisotoping_enveloping_value, font = label_font, bg = "white", width = 20)
    tkgrid(peak_deisotoping_enveloping_value_label, row = 4, column = 4, padx = c(10, 10), pady = c(10, 10))
    # Escape the function
    peak_deisotoping <<- peak_deisotoping
    peak_enveloping <<- peak_enveloping
    peak_deisotoping_enveloping_value <<- peak_deisotoping_enveloping_value
  }
  
  ##### Similarity criteria
  similarity_criteria_choice <- function() {
    # Catch the value from the menu
    similarity_criteria <- select.list(c("correlation","hca","signal intensity","similarity index"), title="Similarity criteria", multiple = TRUE, preselect = "correlation")
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (length(similarity_criteria) == 1 && similarity_criteria == "") {
      similarity_criteria <- "correlation"
    } else {
      # Correlation method
      if ("correlation" %in% similarity_criteria) {
        correlation_method <- select.list(c("Pearson","Spearman"), title="Correlation method", multiple = FALSE, preselect = "Pearson")
        # Raise the focus on the preproc window
        tkraise(window)
        correlation_mode <- select.list(c("common signals", "all signals"), title = "Correlation mode", multiple = FALSE, preselect = "common signals")
        # Raise the focus on the preproc window
        tkraise(window)
        if (correlation_method == "Pearson" || correlation_method == "") {
          correlation_method <- "pearson"
          correlation_method_value <- "Pearson"
        } else if (correlation_method == "Spearman") {
          correlation_method <- "spearman"
          correlation_method_value <- "Spearman"
        }
        if (correlation_mode == "") {
          correlation_mode <- "common signals"
        }
        # Fix the similarity_criteria value for correlation
        similarity_criteria_value_correlation <- paste0(correlation_method_value, "'s correlation")
        # Escape the function
        correlation_method <<- correlation_method
        correlation_mode <<- correlation_mode
        correlation_method_value <<- correlation_method_value
        similarity_criteria_value_correlation <<- similarity_criteria_value_correlation
      }
      # Hierarchical clustering distance method
      if ("hca" %in% similarity_criteria) {
        hierarchical_distance_method <- select.list(c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski"), title = "Hierarchical clustering distance", multiple = FALSE, preselect = "euclidean")
        # Raise the focus on the preproc window
        tkraise(window)
        if (hierarchical_distance_method == "") {
          hierarchical_distance_method <- "euclidean"
        }
        hierarchical_distance_method_value <- hierarchical_distance_method
        # Fix the similarity_criteria value for hierarchical clustering
        similarity_criteria_value_hierarchical_distance <- paste0("hca (", hierarchical_distance_method_value, ")")
        # Escape the function
        hierarchical_distance_method <<- hierarchical_distance_method
        hierarchical_distance_method_value <<- hierarchical_distance_method_value
        similarity_criteria_value_hierarchical_distance <<- similarity_criteria_value_hierarchical_distance
      }
      # Signal intensity
      if ("signal intensity" %in% similarity_criteria) {
        # Catch the value from the menu
        signal_intensity_evaluation <- select.list(c("fixed percentage", "peak-wise adjusted percentage", "average coefficient of variation"), title = "Signal intensity evaluation", preselect = "peak-wise adjusted percentage")
        # Raise the focus on the preproc window
        tkraise(window)
        # Default
        if (signal_intensity_evaluation == "") {
          signal_intensity_evaluation <- "peak-wise adjusted percentage"
        }
        # Fix the method value
        signal_intensity_evaluation_method_value <- signal_intensity_evaluation
        if (signal_intensity_evaluation_method_value == "fixed percentage") {
          signal_intensity_evaluation_method_value <- "fixed %"
        } else if (signal_intensity_evaluation_method_value == "peak-wise adjusted percentage") {
          signal_intensity_evaluation_method_value <- "peak-wise %"
        } else if (signal_intensity_evaluation_method_value == "average coefficient of variation") {
          signal_intensity_evaluation_method_value <- "mean CV"
        }
        # Fix the similarity_criteria value for signal intensity
        similarity_criteria_value_signal_intensity <- paste0("signal intensity (", signal_intensity_evaluation_method_value, ")")
        # Escape the function
        signal_intensity_evaluation <<- signal_intensity_evaluation
        similarity_criteria_value_signal_intensity <<- similarity_criteria_value_signal_intensity
      }
    }
    # Displaying value
    similarity_criteria_value <- NULL
    for (s in 1:length(similarity_criteria)) {
      if (is.null(similarity_criteria_value)) {
        if (similarity_criteria[s] == "correlation") {
          similarity_criteria_value <- similarity_criteria_value_correlation
        } else if (similarity_criteria[s] == "hca") {
          similarity_criteria_value <- similarity_criteria_value_hierarchical_distance
        } else if (similarity_criteria[s] == "signal intensity") {
          similarity_criteria_value <- similarity_criteria_value_signal_intensity
        } else {
          similarity_criteria_value <- as.character(similarity_criteria[s])
        }
      } else {
        if (similarity_criteria[s] == "correlation") {
          similarity_criteria_value <- as.character(paste0(similarity_criteria_value, "\n", similarity_criteria_value_correlation))
        } else if (similarity_criteria[s] == "hca") {
          similarity_criteria_value <- as.character(paste0(similarity_criteria_value, "\n", similarity_criteria_value_hierarchical_distance))
        } else if (similarity_criteria[s] == "signal intensity") {
          similarity_criteria_value <- as.character(paste0(similarity_criteria_value, "\n", similarity_criteria_value_signal_intensity))
        } else {
          similarity_criteria_value <- as.character(paste0(similarity_criteria_value, "\n", similarity_criteria[s]))
        }
      }
    }
    # Set the value of the displaying label
    similarity_criteria_value_label <- tklabel(window, text = similarity_criteria_value, font = label_font, bg = "white", width = 30, height = 4)
    tkgrid(similarity_criteria_value_label, row = 7, column = 2, padx = c(5, 5), pady = c(5, 5))
    # Escape the function
    similarity_criteria <<- similarity_criteria
    similarity_criteria_value <<- similarity_criteria_value
  }
  
  ##### Peak picking algorithm
  peak_picking_algorithm_choice <- function() {
    # Catch the value from the menu
    peak_picking_algorithm <- select.list(c("MAD","SuperSmoother"), title="Peak picking algorithm", preselect = "SuperSmoother", multiple = FALSE)
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (peak_picking_algorithm == "") {
      peak_picking_algorithm <- "SuperSmoother"
    }
    # Set the value of the displaying label
    peak_picking_algorithm_value <- peak_picking_algorithm
    if (peak_picking_algorithm_value == "SuperSmoother") {
      peak_picking_algorithm_value <- "Super Smoother"
    } else if (peak_picking_algorithm_value == "MAD") {
      peak_picking_algorithm_value <- "Median\nAbsolute Deviation"
    }
    peak_picking_algorithm_value_label <- tklabel(window, text = peak_picking_algorithm_value, font = label_font, bg = "white", width = 20)
    tkgrid(peak_picking_algorithm_value_label, row = 4, column = 2, padx = c(5, 5), pady = c(5, 5))
    # Escape the function
    peak_picking_algorithm <<- peak_picking_algorithm
    peak_picking_algorithm_value <<- peak_picking_algorithm_value
  }
  
  ##### Low intensity peaks removal Method
  low_intensity_peak_removal_threshold_method_choice <- function() {
    # Catch the value from the menu
    low_intensity_peak_removal_threshold_method <- select.list(c("whole","element-wise"), title="Choose", preselect = "element-wise")
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (low_intensity_peak_removal_threshold_method == "") {
      low_intensity_peak_removal_threshold_method <- "element-wise"
    }
    # Set the value of the displaying label
    low_intensity_peak_removal_threshold_method_value <- low_intensity_peak_removal_threshold_method
    low_intensity_peak_removal_threshold_method_value_label <- tklabel(window, text = low_intensity_peak_removal_threshold_method_value, font = label_font, bg = "white", width = 20)
    tkgrid(low_intensity_peak_removal_threshold_method_value_label, row = 6, column = 4, padx = c(5, 5), pady = c(5, 5))
    # Escape the function
    low_intensity_peak_removal_threshold_method <<- low_intensity_peak_removal_threshold_method
    low_intensity_peak_removal_threshold_method_value <<- low_intensity_peak_removal_threshold_method_value
  }
  
  ##### Multicore processing
  allow_parallelization_choice <- function() {
    ##### Messagebox
    tkmessageBox(title = "Parallel processing is resource hungry", message = "Parallel processing is resource hungry.\nBy activating it, the computation becomes faster, but the program will eat a lot of RAM, possibly causing your computer to freeze. If you want to play safe, do not enable it", icon = "warning")
    # Catch the value from the menu
    allow_parallelization <- select.list(c("YES","NO"), title = "Parallelization", multiple = FALSE, preselect = "NO")
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (allow_parallelization == "YES") {
      if (Sys.info()[1] == "Windows") {
        allow_parallelization <- "foreach"
      } else {
        allow_parallelization <- "lapply"
      }
    }
    if (allow_parallelization == "NO" || allow_parallelization == "") {
      allow_parallelization <- FALSE
    }
    # Set the value of the displaying label
    if (allow_parallelization == "foreach" || allow_parallelization == "lapply") {
      allow_parallelization_value <- "YES"
    } else {
      allow_parallelization_value <- "  NO  "
    }
    allow_parallelization_value_label <- tklabel(window, text = allow_parallelization_value, font = label_font, bg = "white", width = 20)
    tkgrid(allow_parallelization_value_label, row = 7, column = 6)
    # Escape the function
    allow_parallelization <<- allow_parallelization
    allow_parallelization_value <<- allow_parallelization_value
    # Raise the focus on the main window
    tkraise(window)
  }
  
  
  ##### Average replicates in reference
  average_replicates_in_reference_choice <- function() {
    # Catch the value from the menu
    average_replicates_in_reference <- select.list(c("YES","NO"), title="Choose", preselect = "YES")
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (average_replicates_in_reference == "" || average_replicates_in_reference == "NO") {
      average_replicates_in_reference <- FALSE
    }
    if (average_replicates_in_reference == "YES") {
      average_replicates_in_reference <- TRUE
    }
    # Set the value of the displaying label
    if (average_replicates_in_reference == TRUE) {
      average_replicates_in_reference_value <- "YES"
    } else {
      average_replicates_in_reference_value <- "NO"
    }
    average_replicates_in_reference_value_label <- tklabel(window, text = average_replicates_in_reference_value, font = label_font, bg = "white", width = 20)
    tkgrid(average_replicates_in_reference_value_label, row = 2, column = 4, padx = c(5, 5), pady = c(5, 5))
    # Escape the function
    average_replicates_in_reference <<- average_replicates_in_reference
    average_replicates_in_reference_value <<- average_replicates_in_reference_value
  }
  
  ##### Average replicates in test
  average_replicates_in_test_choice <- function() {
    # Catch the value from the menu
    average_replicates_in_test <- select.list(c("YES","NO"), title="Choose", preselect = "YES")
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (average_replicates_in_test == "" || average_replicates_in_test == "NO") {
      average_replicates_in_test <- FALSE
    }
    if (average_replicates_in_test == "YES") {
      average_replicates_in_test <- TRUE
    }
    # Set the value of the displaying label
    if (average_replicates_in_test == TRUE) {
      average_replicates_in_test_value <- "YES"
    } else {
      average_replicates_in_test_value <- "NO"
    }
    average_replicates_in_test_value_label <- tklabel(window, text = average_replicates_in_test_value, font = label_font, bg = "white", width = 20)
    tkgrid(average_replicates_in_test_value_label, row = 2, column = 6, padx = c(5, 5), pady = c(5, 5))
    # Escape the function
    average_replicates_in_test <<- average_replicates_in_test
    average_replicates_in_test_value <<- average_replicates_in_test_value
  }
  
  ##### File format
  spectra_format_choice <- function() {
    # Catch the value from the menu
    spectra_format <- select.list(c("imzML", "Xmass", "TXT", "CSV", "MSD"), title = "Spectra format", preselect = "Xmass")
    # Raise the focus on the preproc window
    tkraise(window)
    # Default
    if (spectra_format == "" || spectra_format == "Xmass") {
      spectra_format <- "fid"
      spectra_format_value <- "Xmass"
    } else if (spectra_format == "imzML") {
      spectra_format <- "imzML"
      spectra_format_value <- "imzML"
    } else if (spectra_format == "TXT") {
      spectra_format <- "txt"
      spectra_format_value <- "TXT"
    } else if (spectra_format == "CSV") {
      spectra_format <- "csv"
      spectra_format_value <- "CSV"
    } else if (spectra_format == "MSD") {
      spectra_format <- "msd"
      spectra_format_value <- "MSD"
    }
    # Advisory messages
    if (spectra_format == "txt") {
      tkmessageBox(title = "TXT format", message = "The TXT file should have two columns: the m/z values and the intensity values, separated by a tab and without any header", icon = "info")
    } else if (spectra_format == "csv") {
      tkmessageBox(title = "CSV format", message = "The CSV file should have two columns: the m/z values and the intensity values, separated by a comma and with a header", icon = "info")
    }
    # Escape the function
    spectra_format <<- spectra_format
    spectra_format_value <<- spectra_format_value
    # Set the value of the displaying label
    spectra_format_value_label <- tklabel(window, text = spectra_format_value, font = label_font, bg = "white", width = 20)
    tkgrid(spectra_format_value_label, row = 2, column = 2, padx = c(5, 5), pady = c(5, 5))
  }
  
  ##### Import the spectra
  import_spectra_function <- function() {
    if (!is.null(filepath_reference) && !is.null(filepath_test)) {
      # Initialization
      spectra_reference <- NULL
      spetra_test <- NULL
      ### Put all the import block under the try() statement, so that if there are blocking errors (such as no files), the spectra variable remains NULL.
      try({
        # Progress bar
        import_progress_bar <- tkProgressBar(title = "", label = "", min = 0, max = 1, initial = 0, width = 400)
        setTkProgressBar(import_progress_bar, value = 0, title = NULL, label = "Loading packages...")
        # Generate the list of spectra (library and test)
        ### Load the spectra
        # Progress bar
        setTkProgressBar(import_progress_bar, value = 0.15, title = NULL, label = "Importing reference spectra...")
        if (length(grep(".RData", filepath_reference, fixed = TRUE)) > 0) {
          ## LOAD THE R WORKSPACE (FOR DATABASE)
          # Create a temporary environment
          temporary_environment <- new.env()
          # Load the workspace
          load(filepath_reference, envir = temporary_environment)
          # Get the spectra for the database from the workspace
          spectra_reference <- get("spectra_reference", pos = temporary_environment)
          # Get the database folder list for the database from the workspace
          reference_folder_list <- get("reference_folder_list", pos = temporary_environment)
          # Get the database variability list for the database from the workspace
          reference_spectral_variability_list <- get("reference_spectral_variability_list", pos = temporary_environment)
        } else {
          spectra_reference <- import_spectra(filepath_reference, spectra_format = spectra_format, mass_range = mass_range, allow_parallelization = allow_parallelization, spectral_names = "name", replace_sample_name_field = FALSE, remove_empty_spectra = TRUE)
          # Read the folder list (database class list)
          reference_folder_list <- list.dirs(path = filepath_reference, full.names = FALSE, recursive = FALSE)
          # List the files, with the extension removed
          reference_files <- list.files(path = filepath_reference, pattern = ifelse(spectra_format == "fid", spectra_format, paste0(".", spectra_format)), all.files = FALSE, full.names = FALSE, recursive = TRUE, ignore.case = FALSE, include.dirs = FALSE)
          for (f in 1:length(reference_files)) {
            reference_files[f] <- unlist(strsplit(reference_files[f], paste0(".", spectra_format)))[1]
          }
          # Write the path inside the list
          for (x in 1:length(spectra_reference)) {
            spectra_reference[[x]]@metaData$path <- filepath_reference
          }
        }
        # Progress bar
        setTkProgressBar(import_progress_bar, value = 0.30, title = NULL, label = "Importing sample spectra...")
        spectra_test <- import_spectra(filepath_test, spectra_format = spectra_format, mass_range = mass_range, allow_parallelization = allow_parallelization, spectral_names = "name", replace_sample_name_field = FALSE, remove_empty_spectra = TRUE)
        # Read the sample folders
        test_folder_list <- list.dirs(path = filepath_test, full.names = FALSE, recursive = FALSE)
        # List the files, with the extension removed
        test_files <- list.files(path = filepath_test, pattern = ifelse(spectra_format == "fid", spectra_format, paste0(".", spectra_format)), all.files = FALSE, full.names = FALSE, recursive = TRUE, ignore.case = FALSE, include.dirs = FALSE)
        for (f in 1:length(test_files)) {
          test_files[f] <- unlist(strsplit(test_files[f], paste0(".", spectra_format)))[1]
        }
        # Read the sample folders (with treatment subfolder)
        test_folder_list_with_subfolders <- list.dirs(path = filepath_test, full.names = FALSE, recursive = TRUE)
        test_folder_list_with_treatment <- character()
        for (t in 1:length(test_folder_list)) {
          sample_folder_temp <- character()
          for (s in 1:length(test_folder_list_with_subfolders)) {
            if (length(grep(paste0(test_folder_list[t], "/"), test_folder_list_with_subfolders[s], fixed = TRUE)) > 0) {
              test_folder_list_with_subfolders_splitted <- unlist(strsplit(test_folder_list_with_subfolders[s], "/"))
              if (length(test_folder_list_with_subfolders_splitted) == 2) {
                sample_folder_temp <- append(sample_folder_temp, test_folder_list_with_subfolders[s])
              }
            }
          }
          test_folder_list_with_treatment <- append(test_folder_list_with_treatment, sample_folder_temp)
        }
        # Write the path inside the list
        for (x in 1:length(spectra_test)) {
          spectra_test[[x]]@metaData$path <- filepath_test
        }
        ### Preprocessing
        # Progress bar
        setTkProgressBar(import_progress_bar, value = 0.45, title = NULL, label = "Preprocessing reference spectra...")
        if (length(grep(".RData", filepath_reference, fixed = TRUE)) > 0) {
          spectra_reference <- spectra_reference
        } else {
          spectra_reference <- preprocess_spectra(spectra_reference, tof_mode = tof_mode, preprocessing_parameters = list(mass_range = mass_range, transformation_algorithm = transform_data_algorithm, smoothing_algorithm = smoothing_algorithm, smoothing_strength = smoothing_strength, baseline_subtraction_algorithm = baseline_subtraction_algorithm, baseline_subtraction_algorithm_parameter = baseline_subtraction_algorithm_parameter, normalization_algorithm = normalization_algorithm, normalization_mass_range = normalization_mass_range, preprocess_spectra_in_packages_of = preprocess_spectra_in_packages_of, spectral_alignment_algorithm = NULL, spectral_alignment_reference = NULL), allow_parallelization = allow_parallelization, tolerance_ppm = tolerance_ppm)
        }
        # Progress bar
        setTkProgressBar(import_progress_bar, value = 0.60, title = NULL, label = "Preprocessing sample spectra...")
        spectra_test <- preprocess_spectra(spectra_test, tof_mode = tof_mode, preprocessing_parameters = list(mass_range = mass_range, transformation_algorithm = transform_data_algorithm, smoothing_algorithm = smoothing_algorithm, smoothing_strength = smoothing_strength, baseline_subtraction_algorithm = baseline_subtraction_algorithm, baseline_subtraction_algorithm_parameter = baseline_subtraction_algorithm_parameter, normalization_algorithm = normalization_algorithm, normalization_mass_range = normalization_mass_range, preprocess_spectra_in_packages_of = preprocess_spectra_in_packages_of, spectral_alignment_algorithm = NULL, spectral_alignment_reference = NULL), allow_parallelization = allow_parallelization, tolerance_ppm = tolerance_ppm)
        # Progress bar
        setTkProgressBar(import_progress_bar, value = 0.70, title = NULL, label = "Estimating spectral variability...")
        ### Estimate variability in the spectra before averaging the replicates
        # Get the values from the entry
        SNR <- tclvalue(SNR)
        SNR <- as.numeric(SNR)
        SNR_value <- as.character(SNR)
        signals_to_take <- tclvalue(signals_to_take)
        signals_to_take <- as.integer(signals_to_take)
        signals_to_take_value <- as.character(signals_to_take)
        # Run the functions for variability estimation
        if (length(grep(".RData", filepath_reference, fixed = TRUE)) == 0 && !is.null(reference_folder_list) && length(reference_folder_list) > 0) {
          try({
            reference_spectral_variability_list <- spectral_variability_estimation(spectra = spectra_reference, folder_list = reference_folder_list, peak_picking_SNR = SNR, peak_picking_algorithm = peak_picking_algorithm, spectra_format = spectra_format, signals_to_take = signals_to_take, tof_mode = tof_mode, peak_deisotoping = peak_deisotoping, allow_parallelization = allow_parallelization)
          }, silent = TRUE)
        } else {
          if (spectra_format == "imzML") {
            spectral_files <- read_spectra_files(filepath_reference, spectra_format = spectra_format, full_path = TRUE)
            try({
              reference_spectral_variability_list <- spectral_variability_estimation(spectra = spectra_reference, folder_list = spectral_files, peak_picking_SNR = SNR, peak_picking_algorithm = peak_picking_algorithm, spectra_format = spectra_format, signals_to_take = signals_to_take, tof_mode = tof_mode, peak_deisotoping = peak_deisotoping, allow_parallelization = allow_parallelization)
            }, silent = TRUE)
          } else {
            reference_spectral_variability_list <- NULL
          }
        }
        if (!is.null(test_folder_list_with_treatment) && length(test_folder_list_with_treatment) > 0) {
          try({
            test_spectral_variability_list <- spectral_variability_estimation(spectra = spectra_test, folder_list = test_folder_list_with_treatment, peak_picking_SNR = SNR, peak_picking_algorithm = peak_picking_algorithm, spectra_format = spectra_format, signals_to_take = signals_to_take, tof_mode = tof_mode, peak_deisotoping = peak_deisotoping, allow_parallelization = allow_parallelization)
          }, silent = TRUE)
        } else {
          if (spectra_format == "imzML") {
            spectral_files <- read_spectra_files(filepath_test, spectra_format = spectra_format, full_path = TRUE)
            try({
              test_spectral_variability_list <- spectral_variability_estimation(spectra = spectra_test, folder_list = spectral_files, peak_picking_SNR = SNR, peak_picking_algorithm = peak_picking_algorithm, spectra_format = spectra_format, signals_to_take = signals_to_take, tof_mode = tof_mode, peak_deisotoping = peak_deisotoping, allow_parallelization = allow_parallelization)
            }, silent = TRUE)
          } else {
            test_spectral_variability_list <- NULL
          }
        }
        ### Average the replicates
        # Progress bar
        setTkProgressBar(import_progress_bar, value = 0.80, title = NULL, label = "Averaging replicates...")
        if (average_replicates_in_reference == TRUE && isMassSpectrumList(spectra_reference)) {
          ### If the database is a RData file, the spectra_reference are just there
          if (length(grep(".RData", filepath_reference, fixed = TRUE)) > 0) {
            spectra_reference <- spectra_reference
          } else {
            if (length(reference_folder_list) > 0 && spectra_format != "imzML") {
              spectra_reference <- average_replicates_by_folder(spectra = spectra_reference, folder = filepath_reference, spectra_format = spectra_format)
              # The preprocessing of the average will be done after group_spectra_class, otherwise there might be too much preprocessing
              #spectra_reference <- preprocess_spectra(spectra_reference, tof_mode = tof_mode, preprocessing_parameters = preprocessing_parameters, allow_parallelization = allow_parallelization, tolerance_ppm = tolerance_ppm)
            } else if (spectra_format == "imzML") {
              filepath_vector_for_averaging <- character()
              for (s in 1:length(spectra_reference)) {
                filepath_vector_for_averaging <- append(filepath_vector_for_averaging, spectra_reference[[s]]@metaData$file[1])
              }
              spectra_reference <- averageMassSpectra(spectra_reference, labels = filepath_vector_for_averaging, method = "mean")
              spectra_reference <- replace_sample_name_list(spectra_reference, spectra_format = spectra_format, type = "name", replace_sample_name_field = FALSE, force_renaming = TRUE)
              #spectra_reference <- preprocess_spectra(spectra_reference, tof_mode = tof_mode, preprocessing_parameters = list(mass_range = mass_range, transformation_algorithm = transform_data_algorithm, smoothing_algorithm = smoothing_algorithm, smoothing_strength = smoothing_strength, baseline_subtraction_algorithm = baseline_subtraction_algorithm, baseline_subtraction_algorithm_parameter = baseline_subtraction_algorithm_parameter, normalization_algorithm = normalization_algorithm, normalization_mass_range = normalization_mass_range, preprocess_spectra_in_packages_of = preprocess_spectra_in_packages_of, spectral_alignment_algorithm = NULL, spectral_alignment_reference = NULL), allow_parallelization = allow_parallelization, tolerance_ppm = tolerance_ppm)
            }
          }
        }
        if (average_replicates_in_test == TRUE && isMassSpectrumList(spectra_test)) {
          if (length(test_folder_list) > 0 && spectra_format != "imzML") {
            spectra_test <- average_replicates_by_folder(spectra = spectra_test, folder = filepath_test, spectra_format = spectra_format)
            spectra_test <- preprocess_spectra(spectra_test, tof_mode = tof_mode, preprocessing_parameters = list(mass_range = mass_range, transformation_algorithm = transform_data_algorithm, smoothing_algorithm = smoothing_algorithm, smoothing_strength = smoothing_strength, baseline_subtraction_algorithm = baseline_subtraction_algorithm, baseline_subtraction_algorithm_parameter = baseline_subtraction_algorithm_parameter, normalization_algorithm = normalization_algorithm, normalization_mass_range = normalization_mass_range, preprocess_spectra_in_packages_of = preprocess_spectra_in_packages_of, spectral_alignment_algorithm = NULL, spectral_alignment_reference = NULL), allow_parallelization = allow_parallelization, tolerance_ppm = tolerance_ppm)
          } else if (spectra_format == "imzML") {
            filepath_vector_for_averaging <- character()
            for (s in 1:length(spectra_test)) {
              filepath_vector_for_averaging <- append(filepath_vector_for_averaging, spectra_test[[s]]@metaData$file[1])
            }
            spectra_test <- averageMassSpectra(spectra_test, labels = filepath_vector_for_averaging, method = "mean")
            spectra_test <- replace_sample_name_list(spectra_test, spectra_format = spectra_format, type = "name", replace_sample_name_field = FALSE, force_renaming = TRUE)
            spectra_test <- preprocess_spectra(spectra_test, tof_mode = tof_mode, preprocessing_parameters = list(mass_range = mass_range, transformation_algorithm = transform_data_algorithm, smoothing_algorithm = smoothing_algorithm, smoothing_strength = smoothing_strength, baseline_subtraction_algorithm = baseline_subtraction_algorithm, baseline_subtraction_algorithm_parameter = baseline_subtraction_algorithm_parameter, normalization_algorithm = normalization_algorithm, normalization_mass_range = normalization_mass_range, preprocess_spectra_in_packages_of = preprocess_spectra_in_packages_of, spectral_alignment_algorithm = NULL, spectral_alignment_reference = NULL), allow_parallelization = allow_parallelization, tolerance_ppm = tolerance_ppm)
          }
        }
        ### Spectra grouping (class for database)
        # Progress bar
        setTkProgressBar(import_progress_bar, value = 0.90, title = NULL, label = "Generating entries...")
        if (length(grep(".RData", filepath_reference, fixed = TRUE)) > 0) {
          spectra_reference <- spectra_reference
        } else {
          if (length(reference_folder_list) > 0) {
            spectra_reference <- group_spectra_class(spectra_reference, class_list = reference_folder_list, spectra_format = spectra_format, grouping_method = "mean", class_in_file_path = TRUE, class_in_file_name = FALSE, tof_mode = tof_mode, preprocessing_parameters = NULL, allow_parallelization = allow_parallelization)
            spectra_reference <- preprocess_spectra(spectra_reference, tof_mode = tof_mode, preprocessing_parameters = list(mass_range = mass_range, transformation_algorithm = transform_data_algorithm, smoothing_algorithm = smoothing_algorithm, smoothing_strength = smoothing_strength, baseline_subtraction_algorithm = baseline_subtraction_algorithm, baseline_subtraction_algorithm_parameter = baseline_subtraction_algorithm_parameter, normalization_algorithm = normalization_algorithm, normalization_mass_range = normalization_mass_range, preprocess_spectra_in_packages_of = preprocess_spectra_in_packages_of, spectral_alignment_algorithm = NULL, spectral_alignment_reference = NULL), allow_parallelization = allow_parallelization, tolerance_ppm = tolerance_ppm)
          } else {
            # If there are only files, just replace the sample name field in the spectra (as if group_spectra_class had been run)
            spectra_reference <- replace_sample_name(spectra_reference, spectra_format = spectra_format, allow_parallelization = allow_parallelization)
          }
        }
        # Number of samples
        if (isMassSpectrumList(spectra_test)) {
          number_of_samples <- length(spectra_test)
        } else if (isMassSpectrum(spectra_test)) {
          number_of_samples <- 1
        }
        # Database size
        if (isMassSpectrumList(spectra_reference)) {
          reference_size <- length(spectra_reference)
        } else if (isMassSpectrum(spectra_reference)) {
          reference_size <- 1
        }
        # Exit the function and put the variable into the R workspace
        spectra_reference <<- spectra_reference
        spectra_test <<- spectra_test
        reference_folder_list <<- reference_folder_list
        reference_files <<- reference_files
        test_folder_list <<- test_folder_list
        test_files <<- test_files
        test_folder_list_with_subfolders <<- test_folder_list_with_subfolders
        number_of_samples <<- number_of_samples
        reference_spectral_variability_list <<- reference_spectral_variability_list
        test_spectral_variability_list <<- test_spectral_variability_list
        # Progress bar
        setTkProgressBar(import_progress_bar, value = 1.00, title = NULL, label = "Done!")
        close(import_progress_bar)
      }, silent = TRUE)
      if (is.null(spectra_reference) || is.null(spectra_test)) {
        try(close(import_progress_bar), silent = TRUE)
        tkmessageBox(title = "No spectral files", message = "There are no spectral files in the selected folder!\n\nTry to select another folder or another format!", icon = "warning")
      } else {
        tkmessageBox(title = "Import successful", message = "The spectra have been successfully imported and preprocessed", icon = "info")
      }
    } else if (is.null(filepath_reference) || is.null(filepath_test)) {
      ### Messagebox
      tkmessageBox(title = "Folder not set", message = "The spectra folder has not been set. Set if before importing the spectra", icon = "warning")
    }
    # Raise the focus on the preproc window
    tkraise(window)
  }
  
  ##### Dump the peaklist of the database
  database_dump_function <- function() {
    ############### If there is a peaklist to be dumped
    if (!is.null(spectra_reference)) {
      # Progress bar
      db_progress_bar <- tkProgressBar(title = "", label = "", min = 0, max = 1, initial = 0, width = 300)
      setTkProgressBar(db_progress_bar, value = 0, title = NULL, label = "Dumping database RData file...")
      ########## File name
      ##### Catch the filename from the menu
      filename_peaklist <- tclvalue(file_name)
      filename_peaklist <- as.character(filename_peaklist)
      # Get the values of SNR from the entry
      SNR <- tclvalue(SNR)
      SNR <- as.numeric(SNR)
      SNR_value <- as.character(SNR)
      signals_to_take <- tclvalue(signals_to_take)
      signals_to_take <- as.integer(signals_to_take)
      signals_to_take_value <- as.character(signals_to_take)
      # Progress bar
      setTkProgressBar(db_progress_bar, value = 0.15, title = NULL, label = "Peak picking on reference...")
      ########## Peak picking  and alignment on the database spectra
      peaks_reference <- peak_picking(spectra = spectra_reference, peak_picking_algorithm = peak_picking_algorithm, tof_mode = tof_mode, SNR = SNR, allow_parallelization = allow_parallelization, deisotope_peaklist = peak_deisotoping, envelope_peaklist = peak_enveloping, signals_to_take = signals_to_take)
      #peaks_reference <- align_and_filter_peaks(peaks = peaks_reference, peak_picking_algorithm = peak_picking_algorithm, tof_mode = tof_mode, peak_filtering_frequency_threshold_percent = 0, class_vector_for_peak_filtering = NULL, low_intensity_peak_removal_threshold_percent = 0, low_intensity_peak_removal_threshold_method = "element-wise", reference_peaklist = NULL, spectra = NULL, alignment_iterations = 5, allow_parallelization = allow_parallelization, tolerance_ppm = tolerance_ppm)
      ########## Dump the RData containing the list of the spectra and peaks in the database, along with the preprocessing parameters
      database_filename <- paste0(filename_peaklist, " - Database.RData")
      save(peaks_reference, spectra_reference, reference_folder_list, reference_spectral_variability_list, file = database_filename)
      # Progress bar
      setTkProgressBar(db_progress_bar, value = 0.60, title = NULL, label = "Determining filename...")
      ##### Generate the output filename (based upon the filename)
      filename_peaklist <- paste0(filename_peaklist, " - ", "Reference peaklist")
      ##### Add the extension if it is not present in the filename
      if (file_type_export == "csv") {
        if (length(grep(".csv", filename_peaklist, fixed = TRUE)) == 1) {
          filename_peaklist <- filename_peaklist
        }  else {filename_peaklist <- paste0(filename_peaklist, ".csv")}
      } else if (file_type_export == "xlsx") {
        if (length(grep(".xlsx", filename_peaklist, fixed = TRUE)) == 1) {
          filename_peaklist <- filename_peaklist
        }  else {filename_peaklist <- paste0(filename_peaklist, ".xlsx")}
      } else if (file_type_export == "xls") {
        if (length(grep(".xls", filename_peaklist, fixed = TRUE)) == 1) {
          filename_peaklist <- filename_peaklist
        }  else {filename_peaklist <- paste0(filename_peaklist, ".xls")}
      }
      # Progress bar
      setTkProgressBar(db_progress_bar, value = 0.65, title = NULL, label = "Generating file...")
      ##### Database size
      if (isMassPeaksList(peaks_reference)) {
        reference_size <- length(peaks_reference)
      } else if (isMassPeaks(peaks_reference)) {
        reference_size <- 1
      }
      ##### Peak vector
      peak_vector <- character()
      for (i in 1:reference_size) {
        peak_vector <- append(peak_vector, peaks_reference[[i]]@metaData$file[1])
      }
      ########## Database peaklist matrix
      ##### Find out the longest peaklist to define the final matrix boundary
      highest_peak_number <- NULL
      for (p in 1:reference_size) {
        if (is.null(highest_peak_number) || (length(peaks_reference[[p]]@mass) > highest_peak_number)) {
          highest_peak_number <- length(peaks_reference[[p]]@mass)
        }
      }
      # Progress bar
      setTkProgressBar(db_progress_bar, value = 0.80, title = NULL, label = NULL)
      ##### Generate the final matrix
      peaklist_database_matrix <- NULL
      ## Fill in the matrix (for each entry)
      for (j in 1:reference_size) {
        # Two-row matrix for the database entry (mass, intensity)
        peaklist_database_matrix_entry <- matrix("", ncol = highest_peak_number, nrow = 2)
        # Rownames
        rownames(peaklist_database_matrix_entry) <- c(paste(peak_vector[j], "m/z"), paste(peak_vector[j], "intensity"))
        # Mass
        peaklist_database_matrix_entry [1,(1:length(peaks_reference[[j]]@mass))] <- peaks_reference[[j]]@mass
        # Intensity
        peaklist_database_matrix_entry [2,(1:length(peaks_reference[[j]]@intensity))] <- peaks_reference[[j]]@intensity
        # Append it to the final matrix
        if (is.null(peaklist_database_matrix)) {
          peaklist_database_matrix <- peaklist_database_matrix_entry
        } else {
          peaklist_database_matrix <- rbind(peaklist_database_matrix, peaklist_database_matrix_entry)
        }
      }
      # Progress bar
      setTkProgressBar(db_progress_bar, value = 0.90, title = NULL, label = "Saving files...")
      ########## Dump the peaklist matrix
      if (!is.null(peaklist_database_matrix)) {
        if (file_type_export == "csv") {
          write.csv(peaklist_database_matrix, file = filename_peaklist, col.names = FALSE, row.names = TRUE)
        }
        if (file_type_export == "xls" || file_type_export == "xlsx") {
          # Convert it to a data frame
          peaklist_database_matrix <- as.data.frame(peaklist_database_matrix)
          # Generate unique row names
          unique_row_names <- make.names(rownames(peaklist_database_matrix), unique = TRUE)
          rownames(peaklist_database_matrix) <- unique_row_names
          # Export
          writeWorksheetToFile(file = filename_peaklist, data = peaklist_database_matrix, sheet = "Reference peaklist", clearSheets = TRUE, header = FALSE, rownames = rownames(peaklist_database_matrix))
        }
        ##### Message box
        tkmessageBox(title = "Peaklist dumped", message = "The reference peaklist file has been dumped.", icon = "info")
      }
      # Progress bar
      setTkProgressBar(db_progress_bar, value = 1.00, title = NULL, label = "100 %")
      close(db_progress_bar)
    } else {
      ############### If there is no peaklist and spectra to be dumped
      ##### Messagebox
      tkmessageBox(title = "Missing peaklist", message = "The spectra in the reference or the reference peaklist seem to be missing. Run the spectra import and the peak picking and try again.", icon = "warning")
    }
    # Raise the focus on the preproc window
    tkraise(window)
  }
  
  ##### Run the Spectral Typer
  run_spectral_typer_function <- function() {
    ############ Do not run if the spectra have not been imported or the peaks have not been picked
    if (!is.null(spectra_reference) && !is.null(spectra_test)) {
      setwd(output_folder)
      ##### Automatically create a subfolder with all the results
      # Add the date and time to the filename
      current_date <- unlist(strsplit(as.character(Sys.time()), " "))[1]
      current_date_split <- unlist(strsplit(current_date, "-"))
      current_time <- unlist(strsplit(as.character(Sys.time()), " "))[2]
      current_time_split <- unlist(strsplit(current_time, ":"))
      final_date <- ""
      for (x in 1:length(current_date_split)) {
        final_date <- paste0(final_date, current_date_split[x])
      }
      final_time <- ""
      for (x in 1:length(current_time_split)) {
        final_time <- paste0(final_time, current_time_split[x])
      }
      final_date_time <- paste(final_date, final_time, sep = "_")
      SCORE_subfolder <- paste0("SCORE", " (", final_date_time, ")")
      # Generate the new subfolder
      subfolder <- file.path(output_folder, SCORE_subfolder)
      # Create the subfolder
      dir.create(subfolder)
      # Go to the new working directory
      setwd(subfolder)
      set_file_name()
      # Progress bar
      st_progress_bar <- tkProgressBar(title = "Computing spectral similarities...", label = "", min = 0, max = 1, initial = 0, width = 400)
      setTkProgressBar(st_progress_bar, value = 0, title = NULL, label = NULL)
      #### Get the values
      # SNR
      SNR <- tclvalue(SNR)
      SNR <- as.numeric(SNR)
      SNR_value <- as.character(SNR)
      # Most intense signals to take
      signals_to_take <- tclvalue(signals_to_take)
      signals_to_take <- as.integer(signals_to_take)
      signals_to_take_value <- as.character(signals_to_take)
      ## Intensity correction coefficient
      #intensity_correction_coefficient <- tclvalue(intensity_correction_coefficient)
      #intensity_correction_coefficient <- as.numeric(intensity_correction_coefficient)
      #intensity_correction_coefficient_value <- as.character(intensity_correction_coefficient)
      ## Score threshold values
      score_threshold_values <- tclvalue(score_threshold_values)
      score_threshold_values_value <- as.character(score_threshold_values)
      score_threshold_values <- unlist(strsplit(score_threshold_values, ","))
      score_threshold_values <- as.numeric(score_threshold_values)
      ## Intensity tolerance percent
      intensity_tolerance_percent <- tclvalue(intensity_tolerance_percent)
      intensity_tolerance_percent <- as.numeric(intensity_tolerance_percent)
      intensity_tolerance_percent_value <- as.character(intensity_tolerance_percent)
      ## Peaks filtering threshold
      peaks_filtering_threshold_percent <- tclvalue(peaks_filtering_threshold_percent)
      peaks_filtering_threshold_percent <- as.numeric(peaks_filtering_threshold_percent)
      peaks_filtering_threshold_percent_value <- as.character(peaks_filtering_threshold_percent)
      ## Low intensity threshold
      low_intensity_peak_removal_percentage_threshold <- tclvalue(low_intensity_peak_removal_percentage_threshold)
      low_intensity_peak_removal_percentage_threshold <- as.numeric(low_intensity_peak_removal_percentage_threshold)
      low_intensity_peak_removal_percentage_threshold_value <- as.character(low_intensity_peak_removal_percentage_threshold)
      #### Run the function Spectral Typer score calculation
      score_correlation <- NULL
      score_hca <- NULL
      score_intensity <- NULL
      score_si <- NULL
      ############### CORRELATION
      # Progress bar
      setTkProgressBar(st_progress_bar, value = 0.20, title = NULL, label = "Computing correlation...")
      all_is_completed_successfully <- logical()
      if ("correlation" %in% similarity_criteria) {
        all_is_completed_successfully_correlation <- FALSE
        try({
          score_correlation <- spectral_typer_score_correlation_matrix(spectra_reference, spectra_test, filepath_reference, filepath_test, class_list_library = reference_folder_list, peaks_filtering_percentage_threshold = peaks_filtering_threshold_percent, low_intensity_percentage_threshold = low_intensity_peak_removal_percentage_threshold, low_intensity_threshold_method = low_intensity_peak_removal_threshold_method, tof_mode = tof_mode, correlation_method = correlation_method, correlation_mode = correlation_mode, intensity_correction_coefficient = intensity_correction_coefficient, spectra_format = spectra_format, allow_parallelization = allow_parallelization, score_threshold_values = score_threshold_values, tolerance_ppm = tolerance_ppm, signals_to_take = signals_to_take, peak_picking_SNR = SNR, peak_picking_algorithm = peak_picking_algorithm, peak_deisotoping = peak_deisotoping, peak_enveloping = peak_enveloping, spectral_alignment_algorithm = spectral_alignment_algorithm, spectral_alignment_reference = spectral_alignment_reference)
          if (!is.null(score_correlation)) {
            all_is_completed_successfully_correlation <- TRUE
          }
        }, silent = TRUE)
        all_is_completed_successfully <- append(all_is_completed_successfully, all_is_completed_successfully_correlation)
      }
      ############### HIERARCHICAL CLUSTERING ANALYSIS
      # Progress bar
      setTkProgressBar(st_progress_bar, value = 0.40, title = NULL, label = "Computing distance...")
      if ("hca" %in% similarity_criteria) {
        all_is_completed_successfully_hca <- FALSE
        try({
          score_hca <- spectral_typer_score_hierarchical_distance(spectra_reference, spectra_test, class_list_library = reference_folder_list, peaks_filtering_percentage_threshold = peaks_filtering_threshold_percent, low_intensity_percentage_threshold = low_intensity_peak_removal_percentage_threshold, low_intensity_threshold_method = low_intensity_peak_removal_threshold_method, tof_mode = tof_mode, spectra_format = spectra_format, hierarchical_distance_method = hierarchical_distance_method, normalize_distances = TRUE, normalization_method = "max", tolerance_ppm = tolerance_ppm, allow_parallelization = allow_parallelization, signals_to_take = signals_to_take, peak_picking_SNR = SNR, peak_picking_algorithm = peak_picking_algorithm, peak_deisotoping = peak_deisotoping, peak_enveloping = peak_enveloping, spectral_alignment_algorithm = spectral_alignment_algorithm, spectral_alignment_reference = spectral_alignment_reference)
          if (!is.null(score_hca)) {
            all_is_completed_successfully_hca <- TRUE
          }
        }, silent = TRUE)
        all_is_completed_successfully <- append(all_is_completed_successfully, all_is_completed_successfully_hca)
      }
      ############### SIMILARITY INDEX
      # Progress bar
      setTkProgressBar(st_progress_bar, value = 0.60, title = NULL, label = "Computing similarity index...")
      if ("similarity index" %in% similarity_criteria) {
        all_is_completed_successfully_si <- FALSE
        try({
          score_si <- spectral_typer_score_similarity_index(spectra_reference, spectra_test, filepath_reference, filepath_test, class_list_library = reference_folder_list, peaks_filtering_percentage_threshold = peaks_filtering_threshold_percent, low_intensity_percentage_threshold = low_intensity_peak_removal_percentage_threshold, low_intensity_threshold_method = low_intensity_peak_removal_threshold_method, tof_mode = tof_mode, spectra_format = spectra_format, allow_parallelization = allow_parallelization, score_threshold_values = score_threshold_values, tolerance_ppm = tolerance_ppm, signals_to_take = signals_to_take, peak_picking_SNR = SNR, peak_picking_algorithm = peak_picking_algorithm, peak_deisotoping = peak_deisotoping, peak_enveloping = peak_enveloping, spectral_alignment_algorithm = spectral_alignment_algorithm, spectral_alignment_reference = spectral_alignment_reference)
          if (!is.null(score_si)) {
            all_is_completed_successfully_si <- TRUE
          }
        }, silent = TRUE)
        all_is_completed_successfully <- append(all_is_completed_successfully, all_is_completed_successfully_si)
      }
      ############### INTENSITY
      # Progress bar
      setTkProgressBar(st_progress_bar, value = 0.80, title = NULL, label = "Comparing signal intensities...")
      if ("signal intensity" %in% similarity_criteria) {
        all_is_completed_successfully_intensity <- FALSE
        try({
          if (length(reference_folder_list) > 0) {
            class_list_library <- reference_folder_list
          } else {
            class_list_library <- reference_files
          }
          score_intensity <- spectral_typer_score_signal_intensity(spectra_reference, spectra_test, class_list_library = class_list_library, reference_spectral_variability_list = reference_spectral_variability_list, test_spectral_variability_list = test_spectral_variability_list, signal_intensity_evaluation = signal_intensity_evaluation, peaks_filtering_percentage_threshold = peaks_filtering_threshold_percent, low_intensity_percentage_threshold = low_intensity_peak_removal_percentage_threshold, low_intensity_threshold_method = low_intensity_peak_removal_threshold_method, tof_mode = tof_mode, intensity_tolerance_percent_threshold = intensity_tolerance_percent, spectra_format = spectra_format, allow_parallelization = allow_parallelization, score_threshold_values = score_threshold_values, tolerance_ppm = tolerance_ppm, signals_to_take = signals_to_take, peak_picking_SNR = SNR, peak_picking_algorithm = peak_picking_algorithm, peak_deisotoping = peak_deisotoping, peak_enveloping = peak_enveloping, spectral_alignment_algorithm = spectral_alignment_algorithm, spectral_alignment_reference = spectral_alignment_reference)
          if (!is.null(score_intensity)) {
            all_is_completed_successfully_intensity <- TRUE
          }
        }, silent = TRUE)
        all_is_completed_successfully <- append(all_is_completed_successfully, all_is_completed_successfully_intensity)
      }
      ### Parameters matrices
      # Progress bar
      setTkProgressBar(st_progress_bar, value = 0.90, title = NULL, label = "Finalizing...")
      # Parameters vector
      parameters_vector <- c(file_type_export, filepath_reference, filepath_test, mass_range_value, tof_mode_value, tolerance_ppm_value, spectra_format_value, preprocess_spectra_in_packages_of_value, peak_picking_algorithm_value, signals_to_take_value, intensity_tolerance_percent_value, similarity_criteria_value, intensity_correction_coefficient_value, SNR_value, peaks_filtering_threshold_percent_value, low_intensity_peak_removal_percentage_threshold_value, average_replicates_in_reference_value, average_replicates_in_test_value, score_threshold_values_value)
      names(parameters_vector) <- c("File type", "Reference folder", "Samples folder", "Mass range", "TOF mode", "Tolerance (in ppm)", "Spectra format", "Preprocess spectra in packages of", "Peak picking algorithm", "Most intense signals taken", "Intensity tolerance percent", "Similarity criteria", "Intensity correction coefficient", "Signal-to-noise ratio", "Peaks filtering threshold percentage", "Low intensity peaks removal threshold percent", "Average replicates in the reference", "Average replicates in the samples", "Score threshold values")
      parameters_matrix <- as.matrix(cbind(parameters_vector))
      colnames(parameters_matrix) <- "Parameter"
      ### Fill in the matrices (the number of columns must be the same for rbind)
      # CV matrix
      if (!is.null(reference_spectral_variability_list)) {
        reference_cv_matrix <<- reference_spectral_variability_list$cv_matrix
      } else {
        reference_cv_matrix <<- NULL
      }
      if (!is.null(test_spectral_variability_list)) {
        test_cv_matrix <<- test_spectral_variability_list$cv_matrix
      } else {
        test_cv_matrix <<- NULL
      }
      #### Exit the function and put the variable into the R workspace
      # HCA
      if (!is.null(score_hca)) {
        score_hca_matrix <<- score_hca$result_matrix
      }
      # Similarity Index
      if (!is.null(score_si)) {
        score_si_matrix <<- score_si$score_matrix_output
        score_only_si_matrix <<- score_si$score_only_matrix_output
        common_signals_si_matrix <<- score_si$common_signals_reference_samples_matrix
      }
      # Intensity
      if (!is.null(score_intensity)) {
        score_intensity_matrix <<- score_intensity$score_matrix_output
        score_only_intensity_matrix <<- score_intensity$score_only_matrix_output
        common_signals_intensity_matrix <<- score_intensity$common_signals_reference_samples_matrix
      }
      # Correlation
      if (!is.null(score_correlation)) {
        score_correlation_matrix <<- score_correlation$score_matrix_output
        score_only_correlation_matrix <<- score_correlation$score_only_matrix_output
        common_signals_correlation_matrix <<- score_correlation$common_signals_reference_samples_matrix
        most_influencing_signals_correlation_matrix <<- score_correlation$most_influencing_signals_reference_samples_matrix
      }
      # Progress bar
      setTkProgressBar(st_progress_bar, value = 0.95, title = NULL, label = "Saving files...")
      ### Save the files (CSV)
      if (file_type_export == "csv") {
        # Parameters matrix
        write.csv(parameters_matrix, file = paste0(filename_subfolder, " - Parameters.", file_type_export))
        # Intensity
        if (!is.null(score_intensity)) {
          write.csv(score_intensity_matrix, file = paste0("INTENSITY SCORE1 - ", filename))
          write.csv(score_only_intensity_matrix, file = paste0("INTENSITY SCORE2 - ", filename))
          write.csv(common_signals_intensity_matrix, file = paste0("INTENSITY COMMON - ", filename))
        }
        # HCA
        if (!is.null(score_hca)) {
          # Dump the hca plot
          #png(filename="hca.png", width = 1900, height = 1280)
          #score$score_hca$plots
          scaling_factor <- number_of_samples/25
          if (scaling_factor > 3) {
            scaling_factor <- 3
          }
          ggsave(plot = score_hca$hca_dendrogram, device = "png", filename = paste0(filename, "- hca.png"), width = 12.8, height = 7.2, units = "in", dpi = 300, scale = scaling_factor)
          #savePlot(filename="hca.png", type="png")
          #dev.print(X11, file="hca.png", width = 1900, height = 1280)
          #dev.off()
          write.csv(score_hca_matrix, file = paste0("HCA - ", filename))
        }
        # Correlation
        if (!is.null(score_correlation)) {
          write.csv(score_correlation_matrix, file = paste0("CORRELATION SCORE1 - ", filename))
          write.csv(score_only_correlation_matrix, file = paste0("CORRELATION SCORE2 - ", filename))
          write.csv(common_signals_correlation_matrix, file = paste0("CORRELATION COMMON - ", filename))
          write.csv(most_influencing_signals_correlation_matrix, file = paste0("CORRELATION INFLUENCE - ", filename))
        }
        # Similarity index
        if (!is.null(score_si)) {
          write.csv(score_si_matrix, file = paste0("SI SCORE1 - ", filename))
          write.csv(score_only_si_matrix, file = paste0("SI SCORE2 - ", filename))
          write.csv(common_signals_si_matrix, file = paste0("SI COMMON - ", filename))
        }
        # CV matrix
        if (!is.null(reference_cv_matrix)) {
          write.csv(reference_cv_matrix, file = paste0("REF-CV - ", filename))
        }
        if (!is.null(test_cv_matrix)) {
          write.csv(test_cv_matrix, file = paste0("TEST-CV - ", filename))
        }
      } else if (file_type_export == "xlsx" || file_type_export == "xls") {
        ### Save the files (Excel)
        ## Parameters matrix
        writeWorksheetToFile(file = paste0(filename_subfolder, " - Parameters.", file_type_export), data = parameters_matrix, sheet = "Parameters", clearSheets = TRUE, rownames = rownames(parameters_matrix))
        # Intensity
        if (!is.null(score_intensity)) {
          ## Common signals
          # Common signals matrix
          writeWorksheetToFile(file = paste0("INTENSITY COMMON - ", filename), data = common_signals_intensity_matrix, sheet = "Common signals", clearSheets = TRUE, rownames = rownames(common_signals_intensity_matrix))
          ## SCORE 1
          # Generate unique row names
          if (length(rownames(score_intensity_matrix)) > length(unique(rownames(score_intensity_matrix)))) {
            rownames(score_intensity_matrix) <- make.names(rownames(score_intensity_matrix), unique = TRUE)
          }
          # Load the workbook (create if there is not already)
          wb <- loadWorkbook(filename = paste0("INTENSITY SCORE1 - ", filename), create = TRUE)
          # Create the sheet
          createSheet(wb, name = "Scores - Intensity")
          # Write the data
          writeWorksheet(wb, data = score_intensity_matrix, sheet = "Scores - Intensity", header = TRUE, rownames = rownames(score_intensity_matrix))
          # Create the cell styles
          yes_cells_style <- createCellStyle(wb, name = "YES")
          ni_cells_style <- createCellStyle(wb, name = "NI")
          no_cells_style <- createCellStyle(wb, name = "NO")
          # Set the fill color
          #setFillBackgroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          #setFillBackgroundColor(ni_cells_style, color = XLC$COLOR.LIGHT_YELLOW)
          #setFillBackgroundColor(no_cells_style, color = XLC$COLOR.RED)
          setFillForegroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          setFillForegroundColor(ni_cells_style, color = XLC$COLOR.YELLOW)
          setFillForegroundColor(no_cells_style, color = XLC$COLOR.RED)
          # Set data format
          setDataFormat(yes_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(ni_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(no_cells_style, format = XLC$DATA_TYPE.STRING)
          # Set the style (fill in this case)
          setFillPattern(yes_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(ni_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(no_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          # Index cells (rows and columns) (add + 1 to the rows due to the header, and + 1 to the columns due to the rownames)
          yes_cells_rows <- numeric()
          yes_cells_columns <- numeric()
          for (rw in 1:nrow(score_intensity_matrix)) {
            for (clm in 1:ncol(score_intensity_matrix)) {
              if (length(grep("YES", score_intensity_matrix[rw, clm], fixed = TRUE)) > 0) {
                yes_cells_rows <- append(yes_cells_rows, (rw + 1))
                yes_cells_columns <- append(yes_cells_columns, (clm + 1))
              }
            }
          }
          ni_cells_rows <- numeric()
          ni_cells_columns <- numeric()
          for (rw in 1:nrow(score_intensity_matrix)) {
            for (clm in 1:ncol(score_intensity_matrix)) {
              if (length(grep("NI", score_intensity_matrix[rw, clm], fixed = TRUE)) > 0) {
                ni_cells_rows <- append(ni_cells_rows, (rw + 1))
                ni_cells_columns <- append(ni_cells_columns, (clm + 1))
              }
            }
          }
          no_cells_rows <- numeric()
          no_cells_columns <- numeric()
          for (rw in 1:nrow(score_intensity_matrix)) {
            for (clm in 1:ncol(score_intensity_matrix)) {
              if (length(grep("NO", score_intensity_matrix[rw, clm], fixed = TRUE)) > 0) {
                no_cells_rows <- append(no_cells_rows, (rw + 1))
                no_cells_columns <- append(no_cells_columns, (clm+ 1))
              }
            }
          }
          # Set the style to the indexed cells
          if (length(yes_cells_rows) > 0 && length(yes_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Intensity", row = yes_cells_rows, col = yes_cells_columns, cellstyle = yes_cells_style)
          }
          if (length(ni_cells_rows) > 0 && length(ni_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Intensity", row = ni_cells_rows, col = ni_cells_columns, cellstyle = ni_cells_style)
          }
          if (length(no_cells_rows) > 0 && length(no_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Intensity", row = no_cells_rows, col = no_cells_columns, cellstyle = no_cells_style)
          }
          # Set column width and row height
          setColumnWidth(wb, sheet = "Scores - Intensity", column = seq(1, ncol(score_intensity_matrix)), width = 1000)
          setColumnWidth(wb, sheet = "Scores - Intensity", column = (ncol(score_intensity_matrix) + 1), width = -1)
          setRowHeight(wb, sheet = "Scores - Intensity", row = seq(1, (nrow(score_intensity_matrix) + 1)), height = 30)
          # Save workbook
          saveWorkbook(wb)
          ## SCORE 2
          # Generate unique row names
          if (length(rownames(score_only_intensity_matrix)) > length(unique(rownames(score_only_intensity_matrix)))) {
            rownames(score_only_intensity_matrix) <- make.names(rownames(score_only_intensity_matrix), unique = TRUE)
          }
          # Load the workbook (create if there is not already)
          wb <- loadWorkbook(filename = paste0("INTENSITY SCORE2 - ", filename), create = TRUE)
          # Create the sheet
          createSheet(wb, name = "Scores - Intensity")
          # Write the data
          writeWorksheet(wb, data = score_only_intensity_matrix, sheet = "Scores - Intensity", header = TRUE, rownames = rownames(score_only_intensity_matrix))
          # Create the cell styles
          yes_cells_style <- createCellStyle(wb, name = "YES")
          ni_cells_style <- createCellStyle(wb, name = "NI")
          no_cells_style <- createCellStyle(wb, name = "NO")
          # Set the fill color
          #setFillBackgroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          #setFillBackgroundColor(ni_cells_style, color = XLC$COLOR.LIGHT_YELLOW)
          #setFillBackgroundColor(no_cells_style, color = XLC$COLOR.RED)
          setFillForegroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          setFillForegroundColor(ni_cells_style, color = XLC$COLOR.YELLOW)
          setFillForegroundColor(no_cells_style, color = XLC$COLOR.RED)
          # Set data format
          setDataFormat(yes_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(ni_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(no_cells_style, format = XLC$DATA_TYPE.STRING)
          # Set the style (fill in this case)
          setFillPattern(yes_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(ni_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(no_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          # Index cells (rows and columns) (add + 1 to the rows due to the header, and + 1 to the columns due to the rownames)
          yes_cells_rows <- numeric()
          yes_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_intensity_matrix)) {
            for (clm in 1:ncol(score_only_intensity_matrix)) {
              if (length(grep("YES", score_only_intensity_matrix[rw, clm], fixed = TRUE)) > 0) {
                yes_cells_rows <- append(yes_cells_rows, (rw + 1))
                yes_cells_columns <- append(yes_cells_columns, (clm + 1))
              }
            }
          }
          ni_cells_rows <- numeric()
          ni_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_intensity_matrix)) {
            for (clm in 1:ncol(score_only_intensity_matrix)) {
              if (length(grep("NI", score_only_intensity_matrix[rw, clm], fixed = TRUE)) > 0) {
                ni_cells_rows <- append(ni_cells_rows, (rw + 1))
                ni_cells_columns <- append(ni_cells_columns, (clm + 1))
              }
            }
          }
          no_cells_rows <- numeric()
          no_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_intensity_matrix)) {
            for (clm in 1:ncol(score_only_intensity_matrix)) {
              if (length(grep("NO", score_only_intensity_matrix[rw, clm], fixed = TRUE)) > 0) {
                no_cells_rows <- append(no_cells_rows, (rw + 1))
                no_cells_columns <- append(no_cells_columns, (clm+ 1))
              }
            }
          }
          # Set the style to the indexed cells
          if (length(yes_cells_rows) > 0 && length(yes_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Intensity", row = yes_cells_rows, col = yes_cells_columns, cellstyle = yes_cells_style)
          }
          if (length(ni_cells_rows) > 0 && length(ni_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Intensity", row = ni_cells_rows, col = ni_cells_columns, cellstyle = ni_cells_style)
          }
          if (length(no_cells_rows) > 0 && length(no_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Intensity", row = no_cells_rows, col = no_cells_columns, cellstyle = no_cells_style)
          }
          # Set column width and row height
          setColumnWidth(wb, sheet = "Scores - Intensity", column = seq(1, ncol(score_only_intensity_matrix)), width = 1000)
          setColumnWidth(wb, sheet = "Scores - Intensity", column = (ncol(score_only_intensity_matrix) + 1), width = -1)
          setRowHeight(wb, sheet = "Scores - Intensity", row = seq(1, (nrow(score_only_intensity_matrix) + 1)), height = 30)
          # Save workbook
          saveWorkbook(wb)
        }
        # HCA
        if (!is.null(score_hca)) {
          # Dump the hca plot
          #png(filename="hca.png", width = 1900, height = 1280)
          #score$score_hca$plots
          scaling_factor <- number_of_samples/25
          if (scaling_factor > 3) {
            scaling_factor <- 3
          }
          ggsave(plot = score_hca$hca_dendrogram, device = "png", filename = paste0(filename, " - hca.png"), width = 12.8, height = 7.2, units = "in", dpi = 300, scale = scaling_factor)
          #savePlot(filename="hca.png", type="png")
          #dev.print(X11, file="hca.png", width = 1900, height = 1280)
          #dev.off()
          # Generate unique row names
          if (length(rownames(score_hca_matrix)) > length(unique(rownames(score_hca_matrix)))) {
            rownames(score_hca_matrix) <- make.names(rownames(score_hca_matrix), unique = TRUE)
          }
          # Load the workbook (create if there is not already)
          wb <- loadWorkbook(filename = paste0("HCA - ", filename), create = TRUE)
          # Create the sheet
          createSheet(wb, name = "Scores - HCA")
          # Write the data
          writeWorksheet(wb, data = score_hca_matrix, sheet = "Scores - HCA", header = TRUE, rownames = rownames(score_hca_matrix))
          # Create the cell styles
          yes_cells_style <- createCellStyle(wb, name = "YES")
          ni_cells_style <- createCellStyle(wb, name = "NI")
          no_cells_style <- createCellStyle(wb, name = "NO")
          # Set the fill color
          #setFillBackgroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          #setFillBackgroundColor(ni_cells_style, color = XLC$COLOR.LIGHT_YELLOW)
          #setFillBackgroundColor(no_cells_style, color = XLC$COLOR.RED)
          setFillForegroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          setFillForegroundColor(ni_cells_style, color = XLC$COLOR.YELLOW)
          setFillForegroundColor(no_cells_style, color = XLC$COLOR.RED)
          # Set data format
          setDataFormat(yes_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(ni_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(no_cells_style, format = XLC$DATA_TYPE.STRING)
          # Set the style (fill in this case)
          setFillPattern(yes_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(ni_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(no_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          # Index cells (rows and columns) (add + 1 to the rows due to the header, and + 1 to the columns due to the rownames)
          yes_cells_rows <- numeric()
          yes_cells_columns <- numeric()
          for (rw in 1:nrow(score_hca_matrix)) {
            for (clm in 1:ncol(score_hca_matrix)) {
              if (length(grep("YES", score_hca_matrix[rw, clm], fixed = TRUE)) > 0) {
                yes_cells_rows <- append(yes_cells_rows, (rw + 1))
                yes_cells_columns <- append(yes_cells_columns, (clm + 1))
              }
            }
          }
          ni_cells_rows <- numeric()
          ni_cells_columns <- numeric()
          for (rw in 1:nrow(score_hca_matrix)) {
            for (clm in 1:ncol(score_hca_matrix)) {
              if (length(grep("NI", score_hca_matrix[rw, clm], fixed = TRUE)) > 0) {
                ni_cells_rows <- append(ni_cells_rows, (rw + 1))
                ni_cells_columns <- append(ni_cells_columns, (clm + 1))
              }
            }
          }
          no_cells_rows <- numeric()
          no_cells_columns <- numeric()
          for (rw in 1:nrow(score_hca_matrix)) {
            for (clm in 1:ncol(score_hca_matrix)) {
              if (length(grep("NO", score_hca_matrix[rw, clm], fixed = TRUE)) > 0) {
                no_cells_rows <- append(no_cells_rows, (rw + 1))
                no_cells_columns <- append(no_cells_columns, (clm+ 1))
              }
            }
          }
          # Set the style to the indexed cells
          if (length(yes_cells_rows) > 0 && length(yes_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - HCA", row = yes_cells_rows, col = yes_cells_columns, cellstyle = yes_cells_style)
          }
          if (length(ni_cells_rows) > 0 && length(ni_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - HCA", row = ni_cells_rows, col = ni_cells_columns, cellstyle = ni_cells_style)
          }
          if (length(no_cells_rows) > 0 && length(no_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - HCA", row = no_cells_rows, col = no_cells_columns, cellstyle = no_cells_style)
          }
          # Set column width and row height
          setColumnWidth(wb, sheet = "Scores - HCA", column = seq(1, ncol(score_hca_matrix)), width = 1000)
          setColumnWidth(wb, sheet = "Scores - HCA", column = (ncol(score_hca_matrix) + 1), width = -1)
          setRowHeight(wb, sheet = "Scores - HCA", row = seq(1, (nrow(score_hca_matrix) + 1)), height = 30)
          # Save workbook
          saveWorkbook(wb)
        }
        # Correlation
        if (!is.null(score_correlation)) {
          ## Common signals matrix
          writeWorksheetToFile(file = paste0("CORRELATION COMMON - ", filename), data = common_signals_correlation_matrix, sheet = "Common signals", clearSheets = TRUE, rownames = rownames(common_signals_correlation_matrix))
          writeWorksheetToFile(file = paste0("CORRELATION INFLUENCE - ", filename), data = most_influencing_signals_correlation_matrix, sheet = "Influencing signals", clearSheets = TRUE, rownames = rownames(most_influencing_signals_correlation_matrix))
          ## SCORE 1
          # Generate unique row names
          if (length(rownames(score_correlation_matrix)) > length(unique(rownames(score_correlation_matrix)))) {
            rownames(score_correlation_matrix) <- make.names(rownames(score_correlation_matrix), unique = TRUE)
          }
          # Load the workbook (create if there is not already)
          wb <- loadWorkbook(filename = paste0("CORRELATION SCORE1 - ", filename), create = TRUE)
          # Create the sheet
          createSheet(wb, name = "Scores - Correlation")
          # Write the data
          writeWorksheet(wb, data = score_correlation_matrix, sheet = "Scores - Correlation", header = TRUE, rownames = rownames(score_correlation_matrix))
          # Create the cell styles
          yes_cells_style <- createCellStyle(wb, name = "YES")
          ni_cells_style <- createCellStyle(wb, name = "NI")
          no_cells_style <- createCellStyle(wb, name = "NO")
          # Set the fill color
          #setFillBackgroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          #setFillBackgroundColor(ni_cells_style, color = XLC$COLOR.LIGHT_YELLOW)
          #setFillBackgroundColor(no_cells_style, color = XLC$COLOR.RED)
          setFillForegroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          setFillForegroundColor(ni_cells_style, color = XLC$COLOR.YELLOW)
          setFillForegroundColor(no_cells_style, color = XLC$COLOR.RED)
          # Set data format
          setDataFormat(yes_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(ni_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(no_cells_style, format = XLC$DATA_TYPE.STRING)
          # Set the style (fill in this case)
          setFillPattern(yes_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(ni_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(no_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          # Index cells (rows and columns) (add + 1 to the rows due to the header, and + 1 to the columns due to the rownames)
          yes_cells_rows <- numeric()
          yes_cells_columns <- numeric()
          for (rw in 1:nrow(score_correlation_matrix)) {
            for (clm in 1:ncol(score_correlation_matrix)) {
              if (length(grep("YES\n", score_correlation_matrix[rw, clm], fixed = TRUE)) > 0) {
                yes_cells_rows <- append(yes_cells_rows, (rw + 1))
                yes_cells_columns <- append(yes_cells_columns, (clm + 1))
              }
            }
          }
          ni_cells_rows <- numeric()
          ni_cells_columns <- numeric()
          for (rw in 1:nrow(score_correlation_matrix)) {
            for (clm in 1:ncol(score_correlation_matrix)) {
              if (length(grep("NI\n", score_correlation_matrix[rw, clm], fixed = TRUE)) > 0) {
                ni_cells_rows <- append(ni_cells_rows, (rw + 1))
                ni_cells_columns <- append(ni_cells_columns, (clm + 1))
              }
            }
          }
          no_cells_rows <- numeric()
          no_cells_columns <- numeric()
          for (rw in 1:nrow(score_correlation_matrix)) {
            for (clm in 1:ncol(score_correlation_matrix)) {
              if (length(grep("NO\n", score_correlation_matrix[rw, clm], fixed = TRUE)) > 0) {
                no_cells_rows <- append(no_cells_rows, (rw + 1))
                no_cells_columns <- append(no_cells_columns, (clm+ 1))
              }
            }
          }
          # Set the style to the indexed cells
          if (length(yes_cells_rows) > 0 && length(yes_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Correlation", row = yes_cells_rows, col = yes_cells_columns, cellstyle = yes_cells_style)
          }
          if (length(ni_cells_rows) > 0 && length(ni_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Correlation", row = ni_cells_rows, col = ni_cells_columns, cellstyle = ni_cells_style)
          }
          if (length(no_cells_rows) > 0 && length(no_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Correlation", row = no_cells_rows, col = no_cells_columns, cellstyle = no_cells_style)
          }
          # Set column width and row height
          setColumnWidth(wb, sheet = "Scores - Correlation", column = seq(1, ncol(score_correlation_matrix)), width = 1000)
          setColumnWidth(wb, sheet = "Scores - Correlation", column = (ncol(score_correlation_matrix) + 1), width = -1)
          setRowHeight(wb, sheet = "Scores - Correlation", row = seq(1, (nrow(score_correlation_matrix) + 1)), height = 30)
          # Save workbook
          saveWorkbook(wb)
          ## SCORE 2
          # Generate unique row names
          if (length(rownames(score_only_correlation_matrix)) > length(unique(rownames(score_only_correlation_matrix)))) {
            rownames(score_only_correlation_matrix) <- make.names(rownames(score_only_correlation_matrix), unique = TRUE)
          }
          # Load the workbook (create if there is not already)
          wb <- loadWorkbook(filename = paste0("CORRELATION SCORE2 - ", filename), create = TRUE)
          # Create the sheet
          createSheet(wb, name = "Scores - Correlation")
          # Write the data
          writeWorksheet(wb, data = score_only_correlation_matrix, sheet = "Scores - Correlation", header = TRUE, rownames = rownames(score_only_correlation_matrix))
          # Create the cell styles
          yes_cells_style <- createCellStyle(wb, name = "YES")
          ni_cells_style <- createCellStyle(wb, name = "NI")
          no_cells_style <- createCellStyle(wb, name = "NO")
          # Set the fill color
          #setFillBackgroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          #setFillBackgroundColor(ni_cells_style, color = XLC$COLOR.LIGHT_YELLOW)
          #setFillBackgroundColor(no_cells_style, color = XLC$COLOR.RED)
          setFillForegroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          setFillForegroundColor(ni_cells_style, color = XLC$COLOR.YELLOW)
          setFillForegroundColor(no_cells_style, color = XLC$COLOR.RED)
          # Set data format
          setDataFormat(yes_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(ni_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(no_cells_style, format = XLC$DATA_TYPE.STRING)
          # Set the style (fill in this case)
          setFillPattern(yes_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(ni_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(no_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          # Index cells (rows and columns) (add + 1 to the rows due to the header, and + 1 to the columns due to the rownames)
          yes_cells_rows <- numeric()
          yes_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_correlation_matrix)) {
            for (clm in 1:ncol(score_only_correlation_matrix)) {
              if (length(grep("YES\n", score_only_correlation_matrix[rw, clm], fixed = TRUE)) > 0) {
                yes_cells_rows <- append(yes_cells_rows, (rw + 1))
                yes_cells_columns <- append(yes_cells_columns, (clm + 1))
              }
            }
          }
          ni_cells_rows <- numeric()
          ni_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_correlation_matrix)) {
            for (clm in 1:ncol(score_only_correlation_matrix)) {
              if (length(grep("NI\n", score_only_correlation_matrix[rw, clm], fixed = TRUE)) > 0) {
                ni_cells_rows <- append(ni_cells_rows, (rw + 1))
                ni_cells_columns <- append(ni_cells_columns, (clm + 1))
              }
            }
          }
          no_cells_rows <- numeric()
          no_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_correlation_matrix)) {
            for (clm in 1:ncol(score_only_correlation_matrix)) {
              if (length(grep("NO\n", score_only_correlation_matrix[rw, clm], fixed = TRUE)) > 0) {
                no_cells_rows <- append(no_cells_rows, (rw + 1))
                no_cells_columns <- append(no_cells_columns, (clm+ 1))
              }
            }
          }
          # Set the style to the indexed cells
          if (length(yes_cells_rows) > 0 && length(yes_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Correlation", row = yes_cells_rows, col = yes_cells_columns, cellstyle = yes_cells_style)
          }
          if (length(ni_cells_rows) > 0 && length(ni_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Correlation", row = ni_cells_rows, col = ni_cells_columns, cellstyle = ni_cells_style)
          }
          if (length(no_cells_rows) > 0 && length(no_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - Correlation", row = no_cells_rows, col = no_cells_columns, cellstyle = no_cells_style)
          }
          # Set column width and row height
          setColumnWidth(wb, sheet = "Scores - Correlation", column = seq(1, ncol(score_only_correlation_matrix)), width = 1000)
          setColumnWidth(wb, sheet = "Scores - Correlation", column = (ncol(score_only_correlation_matrix) + 1), width = -1)
          setRowHeight(wb, sheet = "Scores - Correlation", row = seq(1, (nrow(score_only_correlation_matrix) + 1)), height = 30)
          # Save workbook
          saveWorkbook(wb)
        }
        # Similarity index
        if (!is.null(score_si)) {
          ## Common signals matrix
          writeWorksheetToFile(file = paste0("SI COMMON - ", filename), data = common_signals_si_matrix, sheet = "Common signals", clearSheets = TRUE, rownames = rownames(common_signals_si_matrix))
          ## SCORE 1
          # Generate unique row names
          if (length(rownames(score_si_matrix)) > length(unique(rownames(score_si_matrix)))) {
            rownames(score_si_matrix) <- make.names(rownames(score_si_matrix), unique = TRUE)
          }
          # Load the workbook (create if there is not already)
          wb <- loadWorkbook(filename = paste0("SI SCORE1 - ", filename), create = TRUE)
          # Create the sheet
          createSheet(wb, name = "Scores - SI")
          # Write the data
          writeWorksheet(wb, data = score_si_matrix, sheet = "Scores - SI", header = TRUE, rownames = rownames(score_si_matrix))
          # Create the cell styles
          yes_cells_style <- createCellStyle(wb, name = "YES")
          ni_cells_style <- createCellStyle(wb, name = "NI")
          no_cells_style <- createCellStyle(wb, name = "NO")
          # Set the fill color
          #setFillBackgroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          #setFillBackgroundColor(ni_cells_style, color = XLC$COLOR.LIGHT_YELLOW)
          #setFillBackgroundColor(no_cells_style, color = XLC$COLOR.RED)
          setFillForegroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          setFillForegroundColor(ni_cells_style, color = XLC$COLOR.YELLOW)
          setFillForegroundColor(no_cells_style, color = XLC$COLOR.RED)
          # Set data format
          setDataFormat(yes_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(ni_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(no_cells_style, format = XLC$DATA_TYPE.STRING)
          # Set the style (fill in this case)
          setFillPattern(yes_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(ni_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(no_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          # Index cells (rows and columns) (add + 1 to the rows due to the header, and + 1 to the columns due to the rownames)
          yes_cells_rows <- numeric()
          yes_cells_columns <- numeric()
          for (rw in 1:nrow(score_si_matrix)) {
            for (clm in 1:ncol(score_si_matrix)) {
              if (length(grep("YES", score_si_matrix[rw, clm], fixed = TRUE)) > 0) {
                yes_cells_rows <- append(yes_cells_rows, (rw + 1))
                yes_cells_columns <- append(yes_cells_columns, (clm + 1))
              }
            }
          }
          ni_cells_rows <- numeric()
          ni_cells_columns <- numeric()
          for (rw in 1:nrow(score_si_matrix)) {
            for (clm in 1:ncol(score_si_matrix)) {
              if (length(grep("NI", score_si_matrix[rw, clm], fixed = TRUE)) > 0) {
                ni_cells_rows <- append(ni_cells_rows, (rw + 1))
                ni_cells_columns <- append(ni_cells_columns, (clm + 1))
              }
            }
          }
          no_cells_rows <- numeric()
          no_cells_columns <- numeric()
          for (rw in 1:nrow(score_si_matrix)) {
            for (clm in 1:ncol(score_si_matrix)) {
              if (length(grep("NO", score_si_matrix[rw, clm], fixed = TRUE)) > 0) {
                no_cells_rows <- append(no_cells_rows, (rw + 1))
                no_cells_columns <- append(no_cells_columns, (clm+ 1))
              }
            }
          }
          # Set the style to the indexed cells
          if (length(yes_cells_rows) > 0 && length(yes_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - SI", row = yes_cells_rows, col = yes_cells_columns, cellstyle = yes_cells_style)
          }
          if (length(ni_cells_rows) > 0 && length(ni_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - SI", row = ni_cells_rows, col = ni_cells_columns, cellstyle = ni_cells_style)
          }
          if (length(no_cells_rows) > 0 && length(no_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - SI", row = no_cells_rows, col = no_cells_columns, cellstyle = no_cells_style)
          }
          # Set column width and row height
          setColumnWidth(wb, sheet = "Scores - SI", column = seq(1, ncol(score_si_matrix)), width = 1000)
          setColumnWidth(wb, sheet = "Scores - SI", column = (ncol(score_si_matrix) + 1), width = -1)
          setRowHeight(wb, sheet = "Scores - SI", row = seq(1, (nrow(score_si_matrix) + 1)), height = 30)
          # Save workbook
          saveWorkbook(wb)
          ## SCORE 2
          # Generate unique row names
          if (length(rownames(score_only_si_matrix)) > length(unique(rownames(score_only_si_matrix)))) {
            rownames(score_only_si_matrix) <- make.names(rownames(score_only_si_matrix), unique = TRUE)
          }
          # Load the workbook (create if there is not already)
          wb <- loadWorkbook(filename = paste0("SI SCORE2 - ", filename), create = TRUE)
          # Create the sheet
          createSheet(wb, name = "Scores - SI")
          # Write the data
          writeWorksheet(wb, data = score_only_si_matrix, sheet = "Scores - SI", header = TRUE, rownames = rownames(score_only_si_matrix))
          # Create the cell styles
          yes_cells_style <- createCellStyle(wb, name = "YES")
          ni_cells_style <- createCellStyle(wb, name = "NI")
          no_cells_style <- createCellStyle(wb, name = "NO")
          # Set the fill color
          #setFillBackgroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          #setFillBackgroundColor(ni_cells_style, color = XLC$COLOR.LIGHT_YELLOW)
          #setFillBackgroundColor(no_cells_style, color = XLC$COLOR.RED)
          setFillForegroundColor(yes_cells_style, color = XLC$COLOR.BRIGHT_GREEN)
          setFillForegroundColor(ni_cells_style, color = XLC$COLOR.YELLOW)
          setFillForegroundColor(no_cells_style, color = XLC$COLOR.RED)
          # Set data format
          setDataFormat(yes_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(ni_cells_style, format = XLC$DATA_TYPE.STRING)
          setDataFormat(no_cells_style, format = XLC$DATA_TYPE.STRING)
          # Set the style (fill in this case)
          setFillPattern(yes_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(ni_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          setFillPattern(no_cells_style, fill = XLC$FILL.SOLID_FOREGROUND)
          # Index cells (rows and columns) (add + 1 to the rows due to the header, and + 1 to the columns due to the rownames)
          yes_cells_rows <- numeric()
          yes_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_si_matrix)) {
            for (clm in 1:ncol(score_only_si_matrix)) {
              if (length(grep("YES", score_only_si_matrix[rw, clm], fixed = TRUE)) > 0) {
                yes_cells_rows <- append(yes_cells_rows, (rw + 1))
                yes_cells_columns <- append(yes_cells_columns, (clm + 1))
              }
            }
          }
          ni_cells_rows <- numeric()
          ni_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_si_matrix)) {
            for (clm in 1:ncol(score_only_si_matrix)) {
              if (length(grep("NI", score_only_si_matrix[rw, clm], fixed = TRUE)) > 0) {
                ni_cells_rows <- append(ni_cells_rows, (rw + 1))
                ni_cells_columns <- append(ni_cells_columns, (clm + 1))
              }
            }
          }
          no_cells_rows <- numeric()
          no_cells_columns <- numeric()
          for (rw in 1:nrow(score_only_si_matrix)) {
            for (clm in 1:ncol(score_only_si_matrix)) {
              if (length(grep("NO", score_only_si_matrix[rw, clm], fixed = TRUE)) > 0) {
                no_cells_rows <- append(no_cells_rows, (rw + 1))
                no_cells_columns <- append(no_cells_columns, (clm+ 1))
              }
            }
          }
          # Set the style to the indexed cells
          if (length(yes_cells_rows) > 0 && length(yes_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - SI", row = yes_cells_rows, col = yes_cells_columns, cellstyle = yes_cells_style)
          }
          if (length(ni_cells_rows) > 0 && length(ni_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - SI", row = ni_cells_rows, col = ni_cells_columns, cellstyle = ni_cells_style)
          }
          if (length(no_cells_rows) > 0 && length(no_cells_columns) > 0) {
            setCellStyle(wb, sheet = "Scores - SI", row = no_cells_rows, col = no_cells_columns, cellstyle = no_cells_style)
          }
          # Set column width and row height
          setColumnWidth(wb, sheet = "Scores - SI", column = seq(1, ncol(score_only_si_matrix)), width = 1000)
          setColumnWidth(wb, sheet = "Scores - SI", column = (ncol(score_only_si_matrix) + 1), width = -1)
          setRowHeight(wb, sheet = "Scores - SI", row = seq(1, (nrow(score_only_si_matrix) + 1)), height = 30)
          # Save workbook
          saveWorkbook(wb)
        }
        # CV matrix
        if (!is.null(reference_cv_matrix)) {
          # Convert it to a data frame
          reference_cv_matrix <- as.data.frame(reference_cv_matrix)
          # Generate unique row names
          unique_row_names <- make.names(rownames(reference_cv_matrix), unique = TRUE)
          rownames(reference_cv_matrix) <- unique_row_names
          # Export
          writeWorksheetToFile(file = paste0("REF-CV - ", filename), data = reference_cv_matrix, sheet = "Reference CV", clearSheets = TRUE, rownames = rownames(reference_cv_matrix))
        }
        if (!is.null(test_cv_matrix)) {
          # Convert it to a data frame
          test_cv_matrix <- as.data.frame(test_cv_matrix)
          # Generate unique row names
          unique_row_names <- make.names(rownames(test_cv_matrix), unique = TRUE)
          rownames(test_cv_matrix) <- unique_row_names
          # Export
          writeWorksheetToFile(file = paste0("TEST-CV - ", filename), data = test_cv_matrix, sheet = "Samples CV", clearSheets = TRUE, rownames = rownames(test_cv_matrix))
        }
      }
      # Progress bar
      setTkProgressBar(st_progress_bar, value = 1.00, title = NULL, label = "Done!")
      close(st_progress_bar)
      if (all(all_is_completed_successfully, na.rm = TRUE) == TRUE) {
        ### Messagebox
        tkmessageBox(title = "Done!", message = "The file(s) have been dumped\n\nLegend:\nF: Fit\nRF: Retrofit\nCorr: intensity correlation coefficient\nIntMtch: signal intensity matching\nsl: slope of the regression curve\nns: number of signals\nSI: Similarity Index\n\n\nFit = number of sample-reference matching signals / number of signals in the sample\nRetrofit = number of reference-sample matching signals / number of signals in the reference entry", icon = "info")
      } else {
        ### Messagebox
        tkmessageBox(title = "Something is wrong", message = "Some elements are needed to perform this operation or something went wrong", icon = "warning")
      }
      setwd(output_folder)
    } else if (is.null(spectra_reference) || is.null(spectra_test)) {
      ### Messagebox
      tkmessageBox(title = "Something is wrong", message = "Some elements are needed to perform this operation: make sure that the spectra have been imported correctly and no other errors happened", icon = "warning")
      setwd(output_folder)
    }
    # Raise the focus on the preproc window
    tkraise(window)
  }
  
  ##### Dump the spectral files
  dump_spectra_files_function <- function() {
    ##### Run only if there are spectra
    if (!is.null(spectra_reference) && !is.null(spectra_test)) {
      # Choose the file format
      spectra_output_format <- select.list(c("MSD", "TXT"), preselect = "MSD", multiple = FALSE, title = "Select the spectra format")
      # Raise the focus on the window
      tkraise(window)
      if (spectra_output_format == "" || spectra_output_format == "MSD") {
        spectra_output_format <- "msd"
      } else if (spectra_output_format == "TXT") {
        spectra_output_format <- "txt"
      }
      # Progress bar
      spectra_dump_progress_bar <- tkProgressBar(title = "", label = "0 %", min = 0, max = 1, initial = 0, width = 300)
      setTkProgressBar(spectra_dump_progress_bar, value = 0.05, title = "Checking for spectra/peaks...", label = "5 %")
      # Get the values of SNR from the entry
      SNR <- tclvalue(SNR)
      SNR <- as.numeric(SNR)
      SNR_value <- as.character(SNR)
      signals_to_take <- tclvalue(signals_to_take)
      signals_to_take <- as.integer(signals_to_take)
      signals_to_take_value <- as.character(signals_to_take)
      ### Peak picking and alignment only for export purposes
        peaks_reference <- peak_picking(spectra = spectra_reference, peak_picking_algorithm = peak_picking_algorithm, tof_mode = tof_mode, SNR = SNR, allow_parallelization = allow_parallelization, deisotope_peaklist = peak_deisotoping, envelope_peaklist = peak_enveloping, signals_to_take = signals_to_take)
        peaks_test <- peak_picking(spectra = spectra_test, peak_picking_algorithm = peak_picking_algorithm, tof_mode = tof_mode, SNR = SNR, allow_parallelization = allow_parallelization, deisotope_peaklist = peak_deisotoping, envelope_peaklist = peak_enveloping, signals_to_take = signals_to_take)
      if (isMassPeaksList(peaks_reference)) {
        peaks_reference_length <- length(peaks_reference)
      } else if (isMassPeaks(peaks_reference)) {
        peaks_reference_length <- 1
      }
      if (isMassPeaksList(peaks_test)) {
        peaks_test_length <- length(peaks_test)
      } else if (isMassPeaks(peaks_test)) {
        peaks_test_length <- 1
      }
      #setTkProgressBar(spectra_dump_progress_bar, value = 0.15, title = "Peak alignment...", label = "15 %")
      ##### Merge peaklists for alignment
      #peaks_all <- append(peaks_reference, peaks_test)
      #peaks_all <- align_and_filter_peaks(peaks_all, peak_picking_algorithm = peak_picking_algorithm, tof_mode = tof_mode, peak_filtering_frequency_threshold_percent = 0, low_intensity_peak_removal_threshold_percent = 0, reference_peaklist = NULL, spectra = NULL, alignment_iterations = 5, allow_parallelization = allow_parallelization)
      #peaks_reference <- peaks_all[1:peaks_reference_length]
      #peaks_test <- peaks_all[(peaks_reference_length + 1):length(peaks_all)]
      ##### Get the filename from the entry (filename_subfolder)
      set_file_name()
      setTkProgressBar(spectra_dump_progress_bar, value = 0.20, title = "Creating folders...", label = "20 %")
      ##### Go to the working directory and create a folder named 'Spectra files'
      spectra_files_subfolder <- file.path(output_folder, paste(filename_subfolder, "- Spectral files"))
      dir.create(spectra_files_subfolder)
      setwd(spectra_files_subfolder)
      ### Create the subfolder for database and for test
      spectra_reference_files_subfolder <- file.path(spectra_files_subfolder, "Reference spectra")
      spectra_test_files_subfolder <- file.path(spectra_files_subfolder, "Sample spectra")
      dir.create(spectra_reference_files_subfolder)
      dir.create(spectra_test_files_subfolder)
      ##### Get the names of the spectra and generate a vector of names
      ## Get the database names (from the spectra list)
      spectra_reference_name_vector <- names(spectra_reference)
      ## Get the database names (from the spectra list)
      spectra_test_name_vector <- names(spectra_test)
      if (average_replicates_in_test == TRUE) {
        if (spectra_format == "fid") {
          ## Split the path into individual folders (list, each element is a vector with the path splitted for that spectrum)
          spectra_test_name_vector_splitted <- list()
          for (f in 1:length(spectra_test_name_vector)) {
            spectra_test_name_vector_splitted[f] <- strsplit(spectra_test_name_vector[f], "/")
          }
          ## Re-join the names using the underscore "_"
          spectra_test_name_vector_final <- list()
          for (f in 1:length(spectra_test_name_vector_splitted)) {
            spectra_test_name_vector_final[[f]] <- spectra_test_name_vector_splitted[[f]][1]
            for (i in 2:length(spectra_test_name_vector_splitted[[f]])) {
              spectra_test_name_vector_final[[f]] <- paste(spectra_test_name_vector_final[[f]], spectra_test_name_vector_splitted[[f]][i], sep = "_")
            }
          }
          spectra_test_name_vector_final <- unlist(spectra_test_name_vector_final)
          spectra_test_name_vector <- spectra_test_name_vector_final
        }
      }
      ## If there are already unique names, leave the spectra_name_vector as it is... Otherwise, generate unique names...
      if (length(spectra_reference_name_vector) == length(unique(spectra_reference_name_vector))) {
        spectra_reference_name_vector <- spectra_reference_name_vector
      } else {
        spectra_reference_name_vector <- make.names(spectra_reference_name_vector, unique = TRUE)
      }
      if (length(spectra_test_name_vector) == length(unique(spectra_test_name_vector))) {
        spectra_test_name_vector <- spectra_test_name_vector
      } else {
        spectra_test_name_vector <- make.names(spectra_test_name_vector, unique = TRUE)
      }
      ### Dump the spectal files
      setTkProgressBar(spectra_dump_progress_bar, value = 0.50, title = "Saving spectra/peaks...", label = "50 %")
      # MSD
      if (spectra_output_format == "msd") {
        setwd(spectra_reference_files_subfolder)
        if (isMassSpectrumList(spectra_reference)) {
          if (isMassPeaksList(peaks_reference) && length(peaks_reference) == length(spectra_reference)) {
            for (s in 1:length(spectra_reference)) {
              exportMsd(spectra_reference[[s]], file = paste0(spectra_reference_name_vector[s], ".msd"), force = TRUE, peaks = peaks_reference[[s]])
            }
          } else {
            for (s in 1:length(spectra_reference)) {
              exportMsd(spectra_reference[[s]], file = paste0(spectra_reference_name_vector[s], ".msd"), force = TRUE)
            }
          }
        } else if (isMassSpectrum(spectra_reference)) {
          if (isMassPeaks(peaks_reference)) {
            exportMsd(spectra_reference, file = paste0(spectra_reference_name_vector, ".msd"), force = TRUE, peaks = peaks_reference)
          } else {
            exportMsd(spectra_reference, file = paste0(spectra_reference_name_vector, ".msd"), force = TRUE)
          }
        }
        setwd(spectra_test_files_subfolder)
        if (isMassSpectrumList(spectra_test)) {
          if (isMassPeaksList(peaks_test) && length(peaks_test) == length(spectra_test)) {
            for (s in 1:length(spectra_test)) {
              exportMsd(spectra_test[[s]], file = paste0(spectra_test_name_vector[s], ".msd"), force = TRUE, peaks = peaks_test[[s]])
            }
          } else {
            for (s in 1:length(spectra_test)) {
              exportMsd(spectra_test[[s]], file = paste0(spectra_test_name_vector[s], ".msd"), force = TRUE)
            }
          }
        } else if (isMassSpectrum(spectra_test)) {
          if (isMassPeaks(peaks_test)) {
            exportMsd(spectra_test, file = paste0(spectra_test_name_vector, ".msd"), force = TRUE, peaks = peaks_test)
          } else {
            exportMsd(spectra_test, file = paste0(spectra_test_name_vector, ".msd"), force = TRUE)
          }
        }
      } else if (spectra_output_format == "txt") {
        setwd(spectra_reference_files_subfolder)
        if (isMassSpectrumList(spectra_reference)) {
          if (isMassPeaksList(peaks_reference) && length(peaks_reference) == length(spectra_reference)) {
            for (s in 1:length(spectra_reference)) {
              spectra_txt <- matrix(0, ncol = 2, nrow = length(spectra_reference[[s]]@mass))
              peaks_txt <- matrix(0, ncol = 2, nrow = length(peaks_reference[[s]]@mass))
              spectra_txt[, 1] <- cbind(spectra_reference[[s]]@mass)
              spectra_txt[, 2] <- cbind(spectra_reference[[s]]@intensity)
              peaks_txt[, 1] <- cbind(peaks_reference[[s]]@mass)
              peaks_txt[, 2] <- cbind(peaks_reference[[s]]@intensity)
              write.table(spectra_txt, file = paste0(spectra_reference_name_vector[s], ".txt"), row.names = FALSE, col.names = FALSE)
              write.table(peaks_txt, file = paste0(spectra_reference_name_vector[s], " - Peaks.txt"), row.names = FALSE, col.names = FALSE)
            }
          } else {
            for (s in 1:length(spectra_reference)) {
              spectra_txt <- matrix(0, ncol = 2, nrow = length(spectra_reference[[s]]@mass))
              spectra_txt[, 1] <- cbind(spectra_reference[[s]]@mass)
              spectra_txt[, 2] <- cbind(spectra_reference[[s]]@intensity)
              write.table(spectra_txt, file = paste0(spectra_reference_name_vector[s], ".txt"), row.names = FALSE, col.names = FALSE)
            }
          }
        } else if (isMassSpectrum(spectra_reference)) {
          spectra_txt <- matrix(0, ncol = 2, nrow = length(spectra_reference@mass))
          peaks_txt <- matrix(0, ncol = 2, nrow = length(peaks_reference@mass))
          spectra_txt[, 1] <- cbind(spectra_reference@mass)
          spectra_txt[, 2] <- cbind(spectra_reference@intensity)
          peaks_txt[, 1] <- cbind(peaks_reference@mass)
          peaks_txt[, 2] <- cbind(peaks_reference@intensity)
          write.table(spectra_txt, file = paste0(spectra_reference_name_vector, ".txt"), row.names = FALSE, col.names = FALSE)
          write.table(peaks_txt, file = paste0(spectra_reference_name_vector, " - Peaks.txt"), row.names = FALSE, col.names = FALSE)
        }
        setwd(spectra_test_files_subfolder)
        if (isMassSpectrumList(spectra_test)) {
          if (isMassPeaksList(peaks_test) && length(peaks_test) == length(spectra_test)) {
            for (s in 1:length(spectra_test)) {
              spectra_txt <- matrix(0, ncol = 2, nrow = length(spectra_test[[s]]@mass))
              peaks_txt <- matrix(0, ncol = 2, nrow = length(peaks_test[[s]]@mass))
              spectra_txt[, 1] <- cbind(spectra_test[[s]]@mass)
              spectra_txt[, 2] <- cbind(spectra_test[[s]]@intensity)
              peaks_txt[, 1] <- cbind(peaks_test[[s]]@mass)
              peaks_txt[, 2] <- cbind(peaks_test[[s]]@intensity)
              write.table(spectra_txt, file = paste0(spectra_test_name_vector[s], ".txt"), row.names = FALSE, col.names = FALSE)
              write.table(peaks_txt, file = paste0(spectra_test_name_vector[s], " - Peaks.txt"), row.names = FALSE, col.names = FALSE)
            }
          } else {
            for (s in 1:length(spectra_test)) {
              spectra_txt <- matrix(0, ncol = 2, nrow = length(spectra_test[[s]]@mass))
              spectra_txt[, 1] <- cbind(spectra_test[[s]]@mass)
              spectra_txt[, 2] <- cbind(spectra_test[[s]]@intensity)
              write.table(spectra_txt, file = paste0(spectra_test_name_vector[s], ".txt"), row.names = FALSE, col.names = FALSE)
            }
          }
        } else if (isMassSpectrum(spectra_test)) {
          spectra_txt <- matrix(0, ncol = 2, nrow = length(spectra_test@mass))
          peaks_txt <- matrix(0, ncol = 2, nrow = length(peaks_test@mass))
          spectra_txt[, 1] <- cbind(spectra_test@mass)
          spectra_txt[, 2] <- cbind(spectra_test@intensity)
          peaks_txt[, 1] <- cbind(peaks_test@mass)
          peaks_txt[, 2] <- cbind(peaks_test@intensity)
          write.table(spectra_txt, file = paste0(spectra_test_name_vector, ".txt"), row.names = FALSE, col.names = FALSE)
          write.table(peaks_txt, file = paste0(spectra_test_name_vector, " - Peaks.txt"), row.names = FALSE, col.names = FALSE)
        }
      }
      # Go back to the output folder
      setwd(output_folder)
      setTkProgressBar(spectra_dump_progress_bar, value = 1.00, title = "Done!", label = "100 %")
      close(spectra_dump_progress_bar)
      ### Messagebox
      tkmessageBox(title = "Spectra files dumped", message = "The spectra files have been succesfully dumped!", icon = "info")
    } else {
      ### Messagebox
      tkmessageBox(title = "Spectra not loaded or Peaks not picked!", message = "No spectra have been imported yet or no peak picking has been performed!", icon = "warning")
    }
    # Raise the focus on the preproc window
    tkraise(window)
  }
  
  ##### Show info function
  show_info_function <- function() {
    if (Sys.info()[1] == "Linux") {
      system(command = paste("xdg-open", github_wiki_url), intern = FALSE)
    } else if (Sys.info()[1] == "Darwin") {
      system(command = paste("open", github_wiki_url), intern = FALSE)
    } else if (Sys.info()[1] == "Windows") {
      system(command = paste("cmd /c start", github_wiki_url), intern = FALSE)
    }
  }
  
  
  
  
  
  
  
  
  
  
  ##################################################################### WINDOW GUI
  
  ########## List of variables, whose values are taken from the entries in the GUI
  SNR <- tclVar("")
  #intensity_correction_coefficient <- tclVar("")
  intensity_correction_coefficient <- 1
  peaks_filtering_threshold_percent <- tclVar("")
  low_intensity_peak_removal_percentage_threshold <- tclVar("")
  signals_to_take <- tclVar("")
  file_name <- tclVar("")
  intensity_tolerance_percent <- tclVar("")
  score_threshold_values <- tclVar("")
  
  
  
  ######################## GUI
  
  ### Get system info (Platform - Release - Version (- Linux Distro))
  system_os = Sys.info()[1]
  os_release = Sys.info()[2]
  os_version = Sys.info()[3]
  
  ### Get the screen resolution
  try({
    # Windows
    if (system_os == "Windows") {
      # Get system info
      screen_info <- system("wmic path Win32_VideoController get VideoModeDescription", intern = TRUE)[2]
      # Get the resolution
      screen_resolution <- unlist(strsplit(screen_info, "x"))
      # Retrieve the values
      screen_height <- as.numeric(screen_resolution[2])
      screen_width <- as.numeric(screen_resolution[1])
    } else if (system_os == "Linux") {
      # Get system info
      screen_info <- system("xdpyinfo -display :0", intern = TRUE)
      # Get the resolution
      screen_resolution <- screen_info[which(screen_info == "screen #0:") + 1]
      screen_resolution <- unlist(strsplit(screen_resolution, "dimensions: ")[1])
      screen_resolution <- unlist(strsplit(screen_resolution, "pixels"))[2]
      # Retrieve the wto dimensions...
      screen_width <- as.numeric(unlist(strsplit(screen_resolution, "x"))[1])
      screen_height <- as.numeric(unlist(strsplit(screen_resolution, "x"))[2])
    }
  }, silent = TRUE)
  
  
  
  ### FONTS
  # Default sizes (determined on a 1680x1050 screen) (in order to make them adjust to the size screen, the screen resolution should be retrieved)
  title_font_size_default <- 18
  other_font_size_default <- 9
  title_font_size <- title_font_size_default
  other_font_size <- other_font_size_default
  
  # Adjust fonts size according to the pixel number
  try({
    # Windows
    if (system_os == "Windows") {
      # Determine the font size according to the resolution
      total_number_of_pixels <- screen_width * screen_height
      # Determine the scaling factor (according to a complex formula)
      scaling_factor_title_font <- as.numeric((0.03611 * total_number_of_pixels) + 9803.1254)
      scaling_factor_other_font <- as.numeric((0.07757 * total_number_of_pixels) + 23529.8386)
      title_font_size <- as.integer(round(total_number_of_pixels / scaling_factor_title_font) - 6)
      other_font_size <- as.integer(round(total_number_of_pixels / scaling_factor_other_font) - 2)
    } else if (system_os == "Linux") {
      # Linux
      # Determine the font size according to the resolution
      total_number_of_pixels <- screen_width * screen_height
      # Determine the scaling factor (according to a complex formula)
      scaling_factor_title_font <- as.numeric((0.03611 * total_number_of_pixels) + 9803.1254)
      scaling_factor_other_font <- as.numeric((0.07757 * total_number_of_pixels) + 23529.8386)
      title_font_size <- as.integer(round(total_number_of_pixels / scaling_factor_title_font))
      other_font_size <- as.integer(round(total_number_of_pixels / scaling_factor_other_font))
    } else if (system_os == "Darwin") {
      # macOS
      print("Using default font sizes...")
    }
    # Go back to defaults if there are NAs
    if (is.na(title_font_size)) {
      title_font_size <- title_font_size_default
    }
    if (is.na(other_font_size)) {
      other_font_size <- other_font_size_default
    }
  }, silent = TRUE)
  
  # Define the fonts
  # Windows
  if (system_os == "Windows") {
    garamond_title_bold = tkfont.create(family = "Garamond", size = title_font_size, weight = "bold")
    garamond_other_normal = tkfont.create(family = "Garamond", size = other_font_size, weight = "normal")
    arial_title_bold = tkfont.create(family = "Arial", size = title_font_size, weight = "bold")
    arial_other_normal = tkfont.create(family = "Arial", size = other_font_size, weight = "normal")
    trebuchet_title_bold = tkfont.create(family = "Trebuchet MS", size = title_font_size, weight = "bold")
    trebuchet_other_normal = tkfont.create(family = "Trebuchet MS", size = other_font_size, weight = "normal")
    trebuchet_other_bold = tkfont.create(family = "Trebuchet MS", size = other_font_size, weight = "bold")
	calibri_title_bold = tkfont.create(family = "Calibri", size = title_font_size, weight = "bold")
    calibri_other_normal = tkfont.create(family = "Calibri", size = other_font_size, weight = "normal")
    calibri_other_bold = tkfont.create(family = "Calibri", size = other_font_size, weight = "bold")
    # Use them in the GUI
    title_font = calibri_title_bold
    label_font = calibri_other_normal
    entry_font = calibri_other_normal
    button_font = calibri_other_bold
  } else if (system_os == "Linux") {
    #Linux
    # Ubuntu
    if (length(grep("Ubuntu", os_version, ignore.case = TRUE)) > 0) {
      # Define the fonts
      ubuntu_title_bold = tkfont.create(family = "Ubuntu", size = (title_font_size + 2), weight = "bold")
      ubuntu_other_normal = tkfont.create(family = "Ubuntu", size = (other_font_size), weight = "normal")
      ubuntu_other_bold = tkfont.create(family = "Ubuntu", size = (other_font_size), weight = "bold")
      liberation_title_bold = tkfont.create(family = "Liberation Sans", size = title_font_size, weight = "bold")
      liberation_other_normal = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "normal")
      liberation_other_bold = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "bold")
      bitstream_charter_title_bold = tkfont.create(family = "Bitstream Charter", size = title_font_size, weight = "bold")
      bitstream_charter_other_normal = tkfont.create(family = "Bitstream Charter", size = other_font_size, weight = "normal")
      bitstream_charter_other_bold = tkfont.create(family = "Bitstream Charter", size = other_font_size, weight = "bold")
      # Use them in the GUI
      title_font = ubuntu_title_bold
      label_font = ubuntu_other_normal
      entry_font = ubuntu_other_normal
      button_font = ubuntu_other_bold
    } else if (length(grep("Fedora", os_version, ignore.case = TRUE)) > 0) {
      # Fedora
      cantarell_title_bold = tkfont.create(family = "Cantarell", size = title_font_size, weight = "bold")
      cantarell_other_normal = tkfont.create(family = "Cantarell", size = other_font_size, weight = "normal")
      cantarell_other_bold = tkfont.create(family = "Cantarell", size = other_font_size, weight = "bold")
      liberation_title_bold = tkfont.create(family = "Liberation Sans", size = title_font_size, weight = "bold")
      liberation_other_normal = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "normal")
      liberation_other_bold = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "bold")
      # Use them in the GUI
      title_font = cantarell_title_bold
      label_font = cantarell_other_normal
      entry_font = cantarell_other_normal
      button_font = cantarell_other_bold
    } else {
      # Other linux distros
      liberation_title_bold = tkfont.create(family = "Liberation Sans", size = title_font_size, weight = "bold")
      liberation_other_normal = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "normal")
      liberation_other_bold = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "bold")
      # Use them in the GUI
      title_font = liberation_title_bold
      label_font = liberation_other_normal
      entry_font = liberation_other_normal
      button_font = liberation_other_bold
    }
  } else if (system_os == "Darwin") {
    # macOS
    helvetica_title_bold = tkfont.create(family = "Helvetica", size = title_font_size, weight = "bold")
    helvetica_other_normal = tkfont.create(family = "Helvetica", size = other_font_size, weight = "normal")
    helvetica_other_bold = tkfont.create(family = "Helvetica", size = other_font_size, weight = "bold")
    # Use them in the GUI
    title_font = helvetica_title_bold
    label_font = helvetica_other_normal
    entry_font = helvetica_other_normal
    button_font = helvetica_other_bold
  }
  
  
  
  # The "area" where we will put our input lines
  window <- tktoplevel(bg = "white")
  tkwm.resizable(window, FALSE, FALSE)
  tktitle(window) <- "SPECTRAL TYPER"
  # Title label
  title_label <- tkbutton(window, text = "SPECTRAL TYPER", command = show_info_function, font = title_font, bg = "white", relief = "flat")
  # Library
  select_reference_button <- tkbutton(window, text="BROWSE REFERENCE\nFOLDER...", command = select_reference_function, font = button_font, bg = "white", width = 20)
  # Samples
  select_samples_button <- tkbutton(window, text="BROWSE SAMPLES\nFOLDER...", command = select_samples_function, font = button_font, bg = "white", width = 20)
  # Output
  browse_output_button <- tkbutton(window, text="BROWSE OUTPUT\nFOLDER...", command = browse_output_function, font = button_font, bg = "white", width = 20)
  #### Entries
  # Similarity criteria
  similarity_criteria_entry <- tkbutton(window, text="Choose\nsimilarity criteria", command = similarity_criteria_choice, font = button_font, bg = "white", width = 20)
  # Intensity correction coefficient
  intensity_correction_coefficient_label <- tklabel(window, text="Intensity correction coefficient\n(0: discard the intensities,\n1: unweighted correlation)", font = label_font, bg = "white", width = 30)
  intensity_correction_coefficient_entry <- tkentry(window, textvariable = intensity_correction_coefficient, font = entry_font, bg = "white", width = 5, justify = "center")
  tkinsert(intensity_correction_coefficient_entry, "end", "1")
  # Score threshold values
  score_threshold_values_label <- tklabel(window, text = "Score threshold values --->", font = label_font, bg = "white", width = 30)
  score_threshold_values_entry <- tkentry(window, textvariable = score_threshold_values, font = entry_font, bg = "white", width = 10, justify = "center")
  tkinsert(score_threshold_values_entry, "end", "1.7, 2")
  # Intensty tolerance percent
  intensity_tolerance_percent_label <- tklabel(window, text="Intensity tolerance percent\n(if 'fixed percentage'\n'signal intensity' is selected)", font = label_font, bg = "white", width = 30)
  intensity_tolerance_percent_entry <- tkentry(window, textvariable = intensity_tolerance_percent, font = entry_font, bg = "white", width = 5, justify = "center")
  tkinsert(intensity_tolerance_percent_entry, "end", "80")
  # Peak picking algorithm
  peak_picking_algorithm_button <- tkbutton(window, text="Peak picking\nalgorithm", command = peak_picking_algorithm_choice, font = button_font, bg = "white", width = 20)
  peak_picking_algorithm_value_label <- tklabel(window, text = peak_picking_algorithm_value, font = label_font, bg = "white", width = 20)
  # Signals to take
  signals_to_take_label <- tklabel(window, text="Most intense\nsignals to take\n(0 = retain all peaks)", font = label_font, bg = "white", width = 30)
  signals_to_take_entry <- tkentry(window, textvariable = signals_to_take, font = entry_font, bg = "white", width = 5, justify = "center")
  tkinsert(signals_to_take_entry, "end", "0")
  # SNR
  SNR_label <- tklabel(window, text="Signal-to-noise\nratio", font = label_font, bg = "white", width = 20)
  SNR_entry <- tkentry(window, textvariable = SNR, font = entry_font, bg = "white", width = 5, justify = "center")
  tkinsert(SNR_entry, "end", "3")
  # Peaks filtering
  peaks_filtering_label <- tklabel(window, text="Peaks filtering", font = label_font, bg = "white", width = 20)
  # Peaks filtering threshold
  peaks_filtering_threshold_percent_label <- tklabel(window, text="Peaks filtering threshold\nfrequency percentage", font = button_font, bg = "white", width = 30)
  peaks_filtering_threshold_percent_entry <- tkentry(window, textvariable = peaks_filtering_threshold_percent, font = entry_font, bg = "white", width = 5, justify = "center")
  tkinsert(peaks_filtering_threshold_percent_entry, "end", "0")
  # Peaks deisotoping
  peak_deisotoping_entry <- tkbutton(window, text="Peak\nDeisotoping\nEnveloping", command = peak_deisotoping_enveloping_choice, font = button_font, bg = "white", width = 20)
  # Low intensity peaks removal
  low_intensity_peaks_removal_label <- tklabel(window, text="Low intensity peak\nremoval", font = label_font, bg = "white", width = 20)
  # Intensity percentage threshold
  low_intensity_peak_removal_percentage_threshold_label <- tklabel(window, text="Low-intensity peak\nremoval\npercentage threshold", font = button_font, bg = "white", width = 20)
  low_intensity_peak_removal_percentage_threshold_entry <- tkentry(window, textvariable = low_intensity_peak_removal_percentage_threshold, font = entry_font, bg = "white", width = 5, justify = "center")
  tkinsert(low_intensity_peak_removal_percentage_threshold_entry, "end", "0")
  # Intensity percentage theshold method
  low_intensity_peak_removal_threshold_method_entry <- tkbutton(window, text="Low-intensity peak\nremoval\nthreshold method", command = low_intensity_peak_removal_threshold_method_choice, font = button_font, bg = "white", width = 20)
  # Average replicates in database
  average_replicates_in_reference_label <- tklabel(window, text="Average replicates in the reference", font = label_font, bg = "white", width = 20)
  average_replicates_in_reference_entry <- tkbutton(window, text="Average replicates\nin the reference", command = average_replicates_in_reference_choice, font = button_font, bg = "white", width = 20)
  # Average replicates in samples
  average_replicates_in_test_label <- tklabel(window, text="Average replicates in the samples", font = label_font, bg = "white", width = 20)
  average_replicates_in_test_entry <- tkbutton(window, text="Average replicates\nin the samples", command = average_replicates_in_test_choice, font = button_font, bg = "white", width = 20)
  # File format
  spectra_format_entry <- tkbutton(window, text="Spectra format", command = spectra_format_choice, font = button_font, bg = "white", width = 20)
  # File type export
  file_type_export_entry <- tkbutton(window, text="Format\nof the exported file", command = file_type_export_choice, font = button_font, bg = "white", width = 20)
  # End session
  end_session_button <- tkbutton(window, text="QUIT", command = end_session_function, font = button_font, bg = "white", width = 20)
  # Multicore
  allow_parallelization_button <- tkbutton(window, text="ALLOW\nPARALLELIZATION", command = allow_parallelization_choice, font = button_font, bg = "white", width = 20)
  # Import the spectra
  import_spectra_button <- tkbutton(window, text="IMPORT AND\nPREPROCESS SPECTRA", command = import_spectra_function, font = button_font, bg = "white", width = 20)
  # Run the Spectral typer!
  run_spectral_typer_button <- tkbutton(window, text="RUN\nSPECTRAL TYPER", command = run_spectral_typer_function, font = button_font, bg = "white", width = 20)
  # Spectra preprocessing button
  spectra_preprocessing_parameters_button <- tkbutton(window, text="SPECTRA\nPREPROCESSING\nPARAMETERS...", command = preprocessing_window_function, font = button_font, bg = "white", width = 20)
  # Set the file name
  set_file_name_label <- tklabel(window, text="<--- Set the file name", font = label_font, bg = "white", width = 20)
  set_file_name_entry <- tkentry(window, textvariable = file_name, font = entry_font, bg = "white", width = 30, justify = "center")
  tkinsert(set_file_name_entry, "end", "Spectral Typer Score")
  # Dump the database peaklist
  database_peaklist_dump_button <- tkbutton(window, text="Dump the database", command = database_dump_function, font = button_font, bg = "white", width = 20)
  # Dump the spectra files
  dump_spectra_files_button <- tkbutton(window, text="DUMP SPECTRAL FILES...", command = dump_spectra_files_function, font = button_font, bg = "white", width = 20)
  # Updates
  download_updates_button <- tkbutton(window, text="DOWNLOAD UPDATE...", command = download_updates_function, font = button_font, bg = "white", width = 20)
  
  
  
  
  #### Displaying labels
  file_type_export_value_label <- tklabel(window, text = file_type_export, font = label_font, bg = "white", width = 20)
  similarity_criteria_value_label <- tklabel(window, text = similarity_criteria_value, font = label_font, bg = "white", width = 30, height = 4)
  peak_deisotoping_enveloping_value_label <- tklabel(window, text = peak_deisotoping_enveloping_value, font = label_font, bg = "white", width = 20)
  low_intensity_peak_removal_threshold_method_value_label <- tklabel(window, text = low_intensity_peak_removal_threshold_method_value, font = label_font, bg = "white", width = 20)
  average_replicates_in_reference_value_label <- tklabel(window, text = average_replicates_in_reference_value, font = label_font, bg = "white", width = 20)
  average_replicates_in_test_value_label <- tklabel(window, text = average_replicates_in_test_value, font = label_font, bg = "white", width = 20)
  spectra_format_value_label <- tklabel(window, text = spectra_format_value, font = label_font, bg = "white", width = 20)
  allow_parallelization_value_label <- tklabel(window, text = allow_parallelization_value, font = label_font, bg = "white", width = 20)
  check_for_updates_value_label <- tkbutton(window, text = check_for_updates_value, command = force_check_for_updates_function, font = label_font, bg = "white", width = 20, relief = "flat")
  
  
  
  
  #### Geometry manager
  tkgrid(title_label, row = 1, column = 1, padx = c(5, 5), pady = c(5, 5), columnspan = 4)
  tkgrid(download_updates_button, row = 1, column = 5, padx = c(5, 5), pady = c(5, 5))
  tkgrid(check_for_updates_value_label, row = 1, column = 6, padx = c(5, 5), pady = c(5, 5))
  tkgrid(spectra_format_entry, row = 2, column = 1, padx = c(5, 5), pady = c(5, 5))
  tkgrid(spectra_format_value_label, row = 2, column = 2, padx = c(5, 5), pady = c(5, 5))
  tkgrid(average_replicates_in_reference_entry, row = 2, column = 3, padx = c(5, 5), pady = c(5, 5))
  tkgrid(average_replicates_in_reference_value_label, row = 2, column = 4, padx = c(5, 5), pady = c(5, 5))
  tkgrid(average_replicates_in_test_entry, row = 2, column = 5, padx = c(5, 5), pady = c(5, 5))
  tkgrid(average_replicates_in_test_value_label, row = 2, column = 6, padx = c(5, 5), pady = c(5, 5))
  tkgrid(file_type_export_entry, row = 3, column = 3, padx = c(5, 5), pady = c(5, 5))
  tkgrid(file_type_export_value_label, row = 3, column = 4, padx = c(5, 5), pady = c(5, 5))
  tkgrid(peak_picking_algorithm_button, row = 4, column = 1, padx = c(5, 5), pady = c(5, 5))
  tkgrid(peak_picking_algorithm_value_label, row = 4, column = 2, padx = c(5, 5), pady = c(5, 5))
  tkgrid(peak_deisotoping_entry, row = 4, column = 3, padx = c(5, 5), pady = c(5, 5))
  tkgrid(peak_deisotoping_enveloping_value_label, row = 4, column = 4, padx = c(5, 5), pady = c(5, 5))
  tkgrid(SNR_label, row = 4, column = 5, padx = c(5, 5), pady = c(5, 5))
  tkgrid(SNR_entry, row = 4, column = 6, padx = c(5, 5), pady = c(5, 5))
  tkgrid(signals_to_take_label, row = 5, column = 2, padx = c(5, 5), pady = c(5, 5))
  tkgrid(signals_to_take_entry, row = 5, column = 3, padx = c(5, 5), pady = c(5, 5))
  tkgrid(peaks_filtering_threshold_percent_label, row = 5, column = 4, padx = c(5, 5), pady = c(5, 5))
  tkgrid(peaks_filtering_threshold_percent_entry, row = 5, column = 5, padx = c(5, 5), pady = c(5, 5))
  tkgrid(low_intensity_peak_removal_percentage_threshold_label, row = 6, column = 1, padx = c(5, 5), pady = c(5, 5))
  tkgrid(low_intensity_peak_removal_percentage_threshold_entry, row = 6, column = 2, padx = c(5, 5), pady = c(5, 5))
  tkgrid(low_intensity_peak_removal_threshold_method_entry, row = 6, column = 3, padx = c(5, 5), pady = c(5, 5))
  tkgrid(low_intensity_peak_removal_threshold_method_value_label, row = 6, column = 4, padx = c(5, 5), pady = c(5, 5))
  tkgrid(intensity_tolerance_percent_label, row = 6, column = 5, padx = c(5, 5), pady = c(5, 5))
  tkgrid(intensity_tolerance_percent_entry, row = 6, column = 6, padx = c(5, 5), pady = c(5, 5))
  tkgrid(similarity_criteria_entry, row = 7, column = 1, padx = c(5, 5), pady = c(5, 5))
  tkgrid(similarity_criteria_value_label, row = 7, column = 2, padx = c(5, 5), pady = c(5, 5))
  #tkgrid(intensity_correction_coefficient_label, row = 7, column = 3, padx = c(5, 5), pady = c(5, 5))
  #tkgrid(intensity_correction_coefficient_entry, row = 7, column = 4, padx = c(5, 5), pady = c(5, 5))
  tkgrid(score_threshold_values_label, row = 7, column = 3, padx = c(5, 5), pady = c(5, 5))
  tkgrid(score_threshold_values_entry, row = 7, column = 4, padx = c(5, 5), pady = c(5, 5))
  tkgrid(allow_parallelization_button, row = 7, column = 5, padx = c(5, 5), pady = c(5, 5))
  tkgrid(allow_parallelization_value_label, row = 7, column = 6, padx = c(5, 5), pady = c(5, 5))
  tkgrid(select_reference_button, row = 9, column = 1, padx = c(5, 5), pady = c(5, 5))
  tkgrid(select_samples_button, row = 9, column = 2, padx = c(5, 5), pady = c(5, 5))
  tkgrid(browse_output_button, row = 9, column = 3, padx = c(5, 5), pady = c(5, 5))
  tkgrid(spectra_preprocessing_parameters_button, row = 9, column = 4, padx = c(5, 5), pady = c(5, 5))
  tkgrid(set_file_name_label, row = 9, column = 6, padx = c(5, 5), pady = c(5, 5))
  tkgrid(set_file_name_entry, row = 9, column = 5, padx = c(5, 5), pady = c(5, 5))
  tkgrid(import_spectra_button, row = 10, column = 1, padx = c(5, 5), pady = c(5, 5), columnspan = 2)
  tkgrid(run_spectral_typer_button, row = 10, column = 2, padx = c(5, 5), pady = c(5, 5), columnspan = 2)
  tkgrid(database_peaklist_dump_button, row = 10, column = 4, padx = c(5, 5), pady = c(5, 5), columnspan = 2)
  tkgrid(dump_spectra_files_button, row = 10, column = 3, padx = c(5, 5), pady = c(5, 5), columnspan = 2)
  tkgrid(end_session_button, row = 10, column = 6, padx = c(5, 5), pady = c(5, 5))
  
  
  ################################################################################
}





### Call the functions
functions_mass_spectrometry()

### Run the function
spectral_typer()
