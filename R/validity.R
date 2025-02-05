.sce_validity <- function(object) {
    msg <- NULL

    if (nrow(int_elementMetadata(object))!=nrow(object)) {
        msg <- c(msg, "'nrow' of 'int_elementMetadata' not equal to 'nrow(object)'")
    }
    if (nrow(int_colData(object))!=ncol(object)) {
        msg <- c(msg, "'nrow' of 'int_colData' not equal to 'ncol(object)'")
    }

    if (objectVersion(object) >= "1.7.1") {
        if (!.red_key %in% colnames(int_colData(object))) {
            msg <- c(msg, "no 'reducedDims' field in 'int_colData'")
        }
        if (!.alt_key %in% colnames(int_colData(object))) {
            msg <- c(msg, "no 'altExps' field in 'int_colData'")
        }
    }

    # Checking spike-in names are present and accounted for.
    spike.fields <- .get_spike_field(suppressWarnings(spikeNames(object)), check=FALSE)
    lost.spikes <- ! spike.fields %in% colnames(int_elementMetadata(object))
    if (any(lost.spikes)) {
        was.lost <- suppressWarnings(spikeNames(object)[lost.spikes][1])
        msg <- c(msg, sprintf("no field specifying rows belonging to spike-in set '%s'", was.lost))
    }

    # Checking the size factor names as well.
    sf.fields <- vapply(suppressWarnings(sizeFactorNames(object)), .get_sf_field, FUN.VALUE="")
    lost.sfs <- ! sf.fields %in% colnames(int_colData(object))
    if (any(lost.sfs)) {
        was.lost <- suppressWarnings(sizeFactorNames(object)[lost.sfs][1])
        msg <- c(msg, sprintf("no field specifying size factors for set '%s'", was.lost))
    }

    if (length(msg)) { return(msg) }
    return(TRUE)
}

#' @importFrom S4Vectors setValidity2
setValidity2("SingleCellExperiment", .sce_validity)
