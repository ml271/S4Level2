########################################################################################################################
.setUp <- function() {
    basic_deltaT_data <- c('"DELTA-T LOGGER"',
        '"FVA_ES08"',
        '"19/09 09:10:07"',
        '"08/01 15:09:12"',
        '"TIMED"',
        '"Channel number   ",11," ",         1',
        '"Sensor code      ",11," ","     TM1"',
        '"Label            ",11," "," Logtemp"',
        '"Unit             ",11," ","   deg C"',
        '"Minimum value    ",11," ",     -3.66',
        '"Maximum value    ",11," ",     23.94',
        '"11/12 14:00:00   ",11," ",      3.11')
    writeLines(basic_deltaT_data, file.path(tempdir(), "test_2018_file.dat"))
}

.tearDown <- function() {
    unlink(dir(tempdir(), full.names = TRUE), recursive = TRUE)
}

.initializeL2Object <- function(.URI, path) {
    if (dir.exists(file.path(path, "internal_structure"))) {
        resetDataLocation(path)
    } else {
        stop("Before using these tests again make sure the path in data/output is not overwritten completely!")
        initializeDataLocation(path)
    }
    Level2 <- loadL2Object(path)

    if (getURI_Depth(.URI) >= 1) {
        plot_name <- getPlotName(.URI)
        Level2 <- createAndAddPlot(Level2, plot_name = plot_name, corrected.aggregate.path = path)
    }

    if (getURI_Depth(.URI) >= 2) {
        sub_plot_name <- getSubPlotName(.URI)
        Level2 <- createAndAddSubPlot(Level2, sub_plot_name = sub_plot_name, .URI = .URI)
    }

    if (getURI_Depth(.URI) >= 3) {
        logger_type <- getDataStructureName(.URI)
        Level2 <- createAndAddLogger(
            .Object = Level2,
            logger_type = logger_type,
            source_paths = path,
            .URI = .URI)
    }
    return(Level2)
}


########################################################################################################################
testGetLocalDirectory <- function() {
    .Level2 <- Level2(local_directory = tempdir())
    RUnit::checkEquals(tempdir(), getLocalDirectory(.Level2))
}

testCreateDirectoryStructure <- function() {
    .Logger_URI <- Level2URI("")
    test_directory <- file.path(tempdir(), "CreateTestDir")
    .Level2 <- .initializeL2Object(.Logger_URI, test_directory)
    saveL2Object(.Level2)

    RUnit::checkTrue(dir.exists(test_directory))
}

testGetPlot <- function() {
    plot_name <- "TestPlot"
    .URI <- Level2URI(plot_name)

    .Level2 <- Level2(local_directory = tempdir())
    .TestPlot <- Plot(name = plot_name,
                      local_directory = file.path(tempdir(), plot_name),
                      corrected.aggregate.path = tempdir())

    .Level2 <- addPlot(.Level2, .TestPlot)
    RUnit::checkEquals(.TestPlot, getObjectByURI(.Level2, .URI))
}

testGetSubPlot <- function() {
    plot_name <- "TestPlot"
    .Plot_URI <- Level2URI(plot_name)
    .Level2 <- .initializeL2Object(.Plot_URI, tempdir())

    sub_plot_name <- "TestSubPlot"
    .SubPlot_URI <- Level2URI(file.path(plot_name, sub_plot_name))
    .TestSubPlot <- SubPlot(
        name = sub_plot_name,
        uri = .SubPlot_URI,
        local_directory = file.path(tempdir(), "internal_structure", plot_name, sub_plot_name))

    .Level2 <- addSubPlot(.Level2, .TestSubPlot, .SubPlot_URI)
    RUnit::checkEquals(.TestSubPlot, getObjectByURI(.Level2, .SubPlot_URI))
}

testGetDataStructure <- function() {
    plot_name = "TestPlot"
    sub_plot_name = "TestSubPlot"
    .SubPlot_URI = Level2URI(file.path(plot_name, sub_plot_name))
    .Level2 <- .initializeL2Object(.SubPlot_URI, tempdir())

    data_structure_type = "Envilog"
    .DataStructure_URI <- Level2URI(file.path(plot_name, sub_plot_name, data_structure_type))

    target_local_directory <- file.path(tempdir(), "internal_structure", plot_name, sub_plot_name, data_structure_type)
    .TestDataStructure <- new(data_structure_type,
        uri = Level2URI(""),
        local_directory = target_local_directory,
        paths = tempdir())
    .Level2 <- addDataStructure(
        .Object = .Level2,
        .DataStructure = .TestDataStructure,
        .URI =.DataStructure_URI)

	RUnit::checkEquals(.TestDataStructure, getObjectByURI(.Level2, .DataStructure_URI))
}

testAddPlot <- function() {
	.URI <- Level2URI("")
    .Level2 <- .initializeL2Object(.URI, tempdir())

    plot_name <- "TestPlot"
    local_directory_once_added_to_level2 <-  file.path(tempdir(), "internal_structure", plot_name)
    .Plot_URI <- Level2URI(plot_name)
    .Plot <- Plot(name = plot_name,
                  local_directory = local_directory_once_added_to_level2,
                  corrected.aggregate.path = tempdir())

    .Level2 <- addPlot(.Level2, .Plot)
    RUnit::checkEquals(.Plot, getObjectByURI(.Level2, .Plot_URI))
}

testAddSubPlot <- function() {
    plot_name = "TestPlot"
    sub_plot_name = "TestSubPlot"

    .PlotURI <- Level2URI(plot_name)
    .Level2 <- .initializeL2Object(.PlotURI, tempdir())

    on_adding_local_directory_is_set_to <- file.path(tempdir(), "internal_structure", plot_name, sub_plot_name)
    .SubPlot_URI = Level2URI(file.path(plot_name, sub_plot_name))
    .SubPlot <- SubPlot(
        name = sub_plot_name,
        uri = .SubPlot_URI,
        local_directory = on_adding_local_directory_is_set_to)
    .Level2 <- addSubPlot(.Level2, .SubPlot, .PlotURI)

    RUnit::checkEquals(.SubPlot, getObjectByURI(.Level2, .SubPlot_URI))
}

testAddDataStructure <- function() {
    plot_name = "TestPlot"
    sub_plot_name = "TestSubPlot"
    data_structure_name = "TestDataStructure"

    .SubPlot_URI <- Level2URI(file.path(plot_name, sub_plot_name))
    .Level2 <- .initializeL2Object(.SubPlot_URI, tempdir())

    on_adding_local_directory_is_set_to <- file.path(tempdir(), "internal_structure", plot_name, sub_plot_name, data_structure_name)
    .DataStructure_URI <- Level2URI(file.path(plot_name, sub_plot_name, data_structure_name))
    .TestDataStructure <- DataStructure(
        unique_name = data_structure_name,
        uri = .DataStructure_URI,
        local_directory = on_adding_local_directory_is_set_to,
        paths = tempdir())
    .Level2 <- addDataStructure(
        .Object = .Level2,
        .DataStructure = .TestDataStructure,
        .URI = .DataStructure_URI)

    RUnit::checkEquals(.TestDataStructure, getObjectByURI(.Level2, .DataStructure_URI))
}

testAddAndApplySensorMapping <- function() {
    .URI <- Level2URI("TestPlot/TestSubPlot/DeltaT")
    .Level2 <- .initializeL2Object(.URI, tempdir())

    example_pattern <- "Logtemp"
    example_replacement <- "Logger_Temperature"
    .Level2 <- addSensorMapping(
        .Object = .Level2,
        pattern = example_pattern,
        replacement = example_replacement,
        .URI = .URI)

    .DataStructure <- getObjectByURI(.Level2, .URI)
    sensor_mappings <- getSensorMappings(.DataStructure)
    RUnit::checkEquals(1, nrow(sensor_mappings))
    RUnit::checkEquals(3, ncol(sensor_mappings))

    current_patterns <- unlist(sensor_mappings[1, "patterns"])
    attr(current_patterns, "names") <- NULL
    RUnit::checkEquals(example_pattern, current_patterns)

    current_replacements <- unlist(sensor_mappings[1, "replacements"])
    attr(current_replacements, "names") <- NULL
    RUnit::checkEquals(example_replacement, current_replacements)

    .Level2 <- updateFilePaths(.Level2)
    saveL2Object(.Level2)
    .Level2 <- updateData(.Level2)
    changed_variable_data <- getLoggerData(.Level2)
    current_variable <- unlist(changed_variable_data[1, "variable"])
    attr(current_variable, "names") <- NULL
	RUnit::checkEquals(as.factor(example_replacement), current_variable)
}

testReplaceListObject <- function() {
    plot_name <- "TestPlot"
    .Plot_URI <- Level2URI(plot_name)
    .Level2 <- .initializeL2Object(.Plot_URI, path = tempdir())

    .Replacement_Plot <- Plot(name = plot_name,
                              local_directory = tempdir(),
                              corrected.aggregate.path = tempdir())
    .Level2 <- replaceListObject(.Level2, .Replacement_Plot)

    RUnit::checkEquals(.Replacement_Plot, getPlotList(.Level2)[[plot_name]])
}

testReplaceObjectByURIWithItselfError <- function() {
    RUnit::DEACTIVATED("'testReplaceObjectByURIWithItselfError' is not implemented yet")
}

testReplacePlotByURI <- function() {
    plot_name = "TestPlot"
    .URI <- Level2URI(plot_name)
    .Level2 <- .initializeL2Object(.URI, tempdir())

    .ReplacementPlot <- Plot(name = plot_name,
                             local_directory = tempdir(),
                             corrected.aggregate.path = tempdir())
    .Level2 <- replaceObjectByURI(.Level2, .ReplacementObject = .ReplacementPlot)

    plot_list <- getPlotList(.Level2)
    RUnit::checkEquals(1, length(plot_list))

    .ReplacedPlot <- getObjectByURI(.Level2, .URI)
	RUnit::checkEquals(.ReplacementPlot, .ReplacedPlot)
}

testReplaceSubPlotByURI <- function() {
	RUnit::DEACTIVATED("'testReplaceSubPlotByURI' is not implemented yet")
}

testUpdateFilePaths <- function() {
    .Logger_URI <- Level2URI("TestPlot/TestSubPlot/DeltaT")
    .Level2 <- .initializeL2Object(.Logger_URI, path = tempdir())
    .Level2 <- updateFilePaths(.Level2)
    .TestLogger <- getObjectByURI(.Level2, .Logger_URI)
    test_source_file <- getSourceFileTable(.TestLogger)

    RUnit::checkTrue(nrow(test_source_file) == 1)
    RUnit::checkEquals("test_2018_file.dat", test_source_file[, "file"])
}

testUpdateData <- function() {
    .Logger_URI <- Level2URI("TestPlot/TestSubPlot/DeltaT")
    Level2 <- .initializeL2Object(.Logger_URI, tempdir())
    saveL2Object(Level2)
    Level2 <- updateFilePaths(Level2)
    Level2 <- updateData(Level2)

    imported_data <- getLoggerData(Level2)
    RUnit::checkEquals(1, nrow(imported_data))
    RUnit::checkEquals(6, ncol(imported_data))
    current_value <- unlist(imported_data[1, "value"])
    RUnit::checkEqualsNumeric(3.11, current_value)
}

testResetPlot <- function() {
    .Logger_URI <- Level2URI("TestPlot/TestSubPlot/DeltaT")
    .Level2 <- .initializeL2Object(.Logger_URI, tempdir())
    .Level2 <- updateFilePaths(.Level2)
    .Level2 <- resetToInitialization(.Level2)

    .TestLogger <- getObjectByURI(.Level2, .Logger_URI)
    test_source_file <- getSourceFileTable(.TestLogger)
    RUnit::checkEquals(0, nrow(test_source_file))
}


