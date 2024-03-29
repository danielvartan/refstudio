#' Read references/citations from files
#'
#' @description
#'
#' `r lifecycle::badge("experimental")`
#'
#' `read_ref()` read references/citations from files. When more than one file is
#' used, the function binds the references from each file.
#'
#' At the moment, `read_ref()` works only with PubMed and RIS (Research
#' Information Systems) formats.
#'
#' @details
#'
#' ## `sep` argument
#'
#' The `sep` argument is only used if the reference/citation files have
#' duplicated tags. In those cases, `read_ref()` will join all the same tag
#' values using the `sep` value.
#'
#' Example:
#'
#' ```
#' read_ref(file, sep = " | ")
#'
#' AU  - Stoykova B
#' AU  - Slota C
#' AU  - Doward L
#'
#' Joined tags: AU - Stoykova B | Slota C | Doward L
#' ```
#'
#' ## `lookup` argument
#'
#' `read_ref()` allows you to rename and rearrange the tags/variables from
#' reference files. You can create your own settings for that task or
#' use the settings provided by the `refstudio` package. Use `lookup = NULL`
#' (default) to preserve the original tag names.
#'
#' To use the settings from the `refstudio` package, choose and assign one of
#' the following values to the `lookup` argument, accordingly to the database
#' provider from which the reference file was exported. You can see the
#' `refstudio` package settings in `refstudio::ris_tags` or at
#' <https://bit.ly/3efSgHr>.
#'
#' * `"general"`: A general lookup table for RIS files.
#' * `"apa"`: for [APA](https://help.psycnet.org/) (American Psychology
#' Association).
#' * `"ebsco"`: for [EBSCO](http://support.ebsco.com/help/) (Elton Bryson
#' Stephens Company).
#' * `"embase"`: for [Embase](https://bit.ly/399d14T) (Excerpta Medica
#' dataBASE)
#' * `"pubmed"`: for [PubMed](https://pubmed.ncbi.nlm.nih.gov/help/).
#' * `"scopus"`: for [Scopus](https://bit.ly/2QAylcS).
#' * `"wos"`: for [Web of Science](https://bit.ly/3sj8nsz).
#'
#' To use you own settings, you will need to assign a `data.frame` object to
#' the `lookup` argument. This `data.frame` need to have the 3 columns
#' below:
#'
#' * `tag`: a `character` column indicating the tag/variable.
#' * `order`: an `integer` column, with greater than 0 values, indicating the
#' columns order.
#' * `name`: a `character` column indicating the name to replace the
#' tag/variable indicated in the `tag` column.
#'
#' Note that `read_ref()` will perform a cleaning process to the `lookup`
#' data frame. This process involves:
#'
#' * Removing rows with `NA` values found in the `tag`, `order` and/or `name`
#' columns.
#' * Removing any duplicated `tag` values, considering the last values after
#' arranging the table by the `order` column.
#'
#' Also, if one or more `tag` values have the same `name` value, `read_ref()`
#' will combine them with the separator assigned in the `sep` argument.
#'
#' ## Reading ZIP files
#'
#' `read_ref()` also allows you to read ZIP compacted files. Just assign
#' the ZIP file in the `file` argument.
#'
#' @param file (optional) a `character` object indicating PubMed, RIS or ZIP
#'   file names. If not assigned, a dialog window will be open enabling the user
#'   to search and select a file (only for interactive sessions).
#' @param lookup (optional) a string indicating the database provider from which
#'   the reference/citation file was exported, or a `data.frame` object
#'   containing instructions on how to rename and rearrange the tags/variables.
#'   See the Details section to learn more (default: `NULL`).
#' @param sep (optional) a string indicating the separator to be used when
#'   combining values with the same tag/variable (default: `" | "`).
#'
#' @return A `data.frame` object with the citations/references found in the
#'   `file` argument.
#'
#' @family reference/citation functions
#' @export
#'
#' @examples
#' \dontrun{
#' if (require_namespace("utils", quietly = TRUE)) {
#'     file <- raw_data()[grep("_pubmed_", raw_data())]
#'     file <- raw_data(file)
#'
#'     View(read_ref(file, "pubmed"))}}
read_ref <- function(file = file.choose(), lookup = NULL, sep = " | ") {
    checkmate::assert_character(file, min.len = 1, any.missing = FALSE,
                                all.missing = FALSE)
    checkmate::assert_file_exists(file)
    checkmate::assert_multi_class(lookup, c("character", "data.frame"),
                                  null.ok = TRUE)
    checkmate::assert_string(sep)

    if (inherits(lookup, "character")) {
        choices <- c("general", "apa", "ebsco", "embase", "pubmed", "scopus",
                     "wos")

        checkmate::assert_choice(lookup, choices)
    } else if (inherits(lookup, "data.frame")) {
        choices <- c("tag", "order", "name")

        checkmate::assert_data_frame(lookup, min.rows = 1, min.cols = 3)
        checkmate::assert_names(names(lookup), must.include = choices)
    }

    if (length(file) > 1 ||
        any(stringr::str_detect(file, "(?i).zip$"), na.rm = TRUE)) {
        if (any(stringr::str_detect(file, ".zip$"), na.rm = TRUE)) {
            rutils:::require_pkg("utils")
        }

        out <- dplyr::tibble()

        cli::cat_line()
        cli::cli_alert_info(paste0(
            "{.strong This may take a while. Please be patient.} \U00023F3"
        ))
        cli::cat_line()

        for (i in file) {
            if (stringr::str_detect(i, "(?i).zip$")) {
                i <- utils::unzip(i, exdir = tempdir())
            }

            data <- read_ref(i, sep = sep, lookup = lookup)
            out <- dplyr::bind_rows(out, data)
        }

        return(out)
    }

    data <- guess_ref(file, return_data = TRUE)

    if (is.null(data)) {
        cli::cli_abort(paste0(
            "No reference/citation was identified in ",
            "{cli::col_red(file)}."
        ))
    } else if (data$count > 100) {
        cli::cat_line()
        cli::cli_alert_info(paste0(
            "{.strong This may take a while. Please be patient.} \U00023F3"
        ))
        cli::cat_line()
    }

    out <- chopp_ref(data) %>%
        remove_ref_header() %>%
        lapply(join_ref_solo_lines) %>%
        lapply(stringr::str_squish) %>%
        lapply(join_ref_tag_values, sep = sep) %>%
        convert_ref_to_tibble() %>%
        rename_ref(lookup, file, sep)

    invisible(out)
}

chopp_ref <- function(data) {
    checkmate::assert_list(data)

    out <- rutils::cutter(data$data, data$index, between = data$between) %>%
        lapply(function(x) x[!stringr::str_detect(x, "^\\s*$")]) %>%
        lapply(function(x) x[!stringr::str_detect(x, "^ER$|^ER |^ER-")])

    out <- out[!lengths(out) == 0]

    invisible(out)
}

remove_ref_header <- function(x) {
    checkmate::assert_list(x, min.len = 1)

    if (stringr::str_detect(x[[1]][1], "^[^A-Z]") &&
        stringr::str_detect(x[[1]][1],
                            "^.*[A-Z][A-Z0-9]+(?=(-\\s+|\\s+-\\s+))")) {
        x[[1]][1] <- stringr::str_remove(x[[1]][1], "^[^A-Z]+(?=[A-Z])")
    }

    pattern_tag <- "^[A-Z][A-Z0-9]+(?=(-\\s+|\\s+-\\s+))"
    first_tag <- which(stringr::str_detect(x[[1]], pattern_tag) == TRUE)[1]

    if (!first_tag == 1) {
        x[[1]] <- unlist(rutils::cutter(x[[1]], first_tag, between = "left",
                                rm_start = TRUE))
    }

    invisible(x)
}

join_ref_solo_lines <- function(x) {
    checkmate::assert_character(x, min.len = 1)

    pattern_tag <- "^[A-Z][A-Z0-9]+(?=(-\\s+|\\s+-\\s+))"
    tag_detect <- stringr::str_detect(x, pattern_tag)
    tagged_elements <- which(tag_detect == TRUE)

    if (any(!tag_detect)) {
        x <- x %>%
            rutils::cutter(index = tagged_elements, between = "left") %>%
            lapply(function(i) paste(trimws(i), collapse = " ")) %>%
            unlist()
    }

    x
}

join_ref_tag_values <- function(x, sep) {
    checkmate::assert_character(x, min.len = 1)
    checkmate::assert_string(sep)

    pattern_tag <- "^[A-Z][A-Z0-9]+(?=(-\\s+|\\s+-\\s+))"
    pattern_data <- "(?<=-).*"
    tags <- stringr::str_extract(x, pattern_tag)

    if (any(duplicated(rutils:::rm_na(tags)), na.rm = TRUE)) {
        duplicated_tags <- unique(tags[duplicated(tags)]) %>% rutils:::rm_na()

        for (i in duplicated_tags) {
            pattern <- paste0("^", i, "\\s", "|", "^", i, "-")
            index <- which(stringr::str_detect(x, pattern))
            values <- x[index]

            tag <- paste0(i, paste(rep(" ", 4 - nchar(i)), collapse = ""),
                          "- ")
            data <- paste0(trimws(stringr::str_extract(values, pattern_data)),
                           collapse = sep)

            x[index[1]] <- paste0(tag, data)
            x <- x[-index[-1]]
        }
    }

    x
}

convert_ref_to_tibble <- function(x) {
    checkmate::assert_list(x, min.len = 1)

    out <- dplyr::tibble()
    envir <- environment()

    invisible(lapply(x, bind_ref, envir = envir))

    invisible(out)
}

bind_ref <- function(x, envir) {
    checkmate::assert_character(x, min.len = 1)
    checkmate::assert_environment(envir)

    pattern_tag <- "^[A-Z][A-Z0-9]+(?=(-\\s+|\\s+-\\s+))"
    pattern_data <- "(?<=-).*"

    col <- stringr::str_extract(x, pattern_tag)
    row <- trimws(stringr::str_extract(x, pattern_data))

    if (any(stringr::str_detect(col, "^ER$"), na.rm = TRUE)) {
        index <- which(stringr::str_detect(col, "^ER$"))
        col <- col[-index]
        row <- row[-index]
    }

    if (length(col) != length(row)) {
        stop("The number of RIS tags doesn't match the number of values ",
             "in at least one record.", call. = FALSE)
    }

    if (any(is.na(col))) {
        index <- which(is.na(col))
        col <- col[-index]
        row <- row[-index]
    }

    x <- data.frame(as.list(row))
    names(x) <- col

    assign("out", dplyr::bind_rows(get("out", envir = envir), x), envir = envir)

    invisible(NULL)
}

rename_ref <- function(x, lookup, file, sep) {
    checkmate::assert_data_frame(x)
    checkmate::assert_multi_class(lookup, c("character", "data.frame"),
                                  null.ok = TRUE)
    checkmate::assert_string(file)
    checkmate::assert_string(sep)

    if (inherits(lookup, "character")) {
        choices <- c("general", "apa", "ebsco", "embase", "pubmed", "scopus",
                     "wos")

        checkmate::assert_choice(lookup, choices)

        code_lookup <- list(general = "General", apa = "APA", ebsco = "EBSCO",
                            embase = "Embase", pubmed = "PubMed",
                            scopus = "Scopus", wos = "Web of Science")

        if (!lookup == "general") provider <- code_lookup[[lookup]]
        lookup <- refstudio::ris_tags[[lookup]]
    } else if (inherits(lookup, "data.frame")) {
        choices <- c("tag", "order", "name")

        checkmate::assert_data_frame(lookup, min.rows = 1, min.cols = 3)
        checkmate::assert_names(names(lookup), must.include = choices)
    } else {
        x <- x %>% dplyr::mutate(file = basename(file))

        return(x)
    }

    lookup <- lookup %>% dplyr::arrange(order)
    lookup <- clean_lookup_table(lookup)
    x <- join_ref_col_values(x, lookup, sep)
    replacement_index <- which(lookup$tag %in% names(x))

    if (!length(replacement_index) == 0) {
        replacement_tag <- lookup$tag[replacement_index]
        replacement_name <- lookup$name[replacement_index]

        match <- unlist(lapply(replacement_tag, match, table = names(x)))
        no_match <- which(!names(x) %in% lookup$tag)
        order <- append(match, no_match)

        x <- x[order] %>%
            dplyr::rename_with(function(x) replacement_name,
                               dplyr::all_of(replacement_tag))
    }

    if ("provider" %in% ls()) {
        if (!"provider" %in% names(x)) {
            x <- x %>% dplyr::mutate(provider = provider,
                                     file = basename(file))
        } else {
            x <- x %>%
                dplyr::relocate("provider", .after = dplyr::last(names(x))) %>%
                dplyr::mutate(file = basename(file))
        }
    } else {
        x <- x %>% dplyr::mutate(file = basename(file))
    }

    invisible(x)
}

clean_lookup_table <- function(lookup) {
    choices <- c("tag", "order", "name")

    checkmate::assert_data_frame(lookup, min.rows = 1, min.cols = 3)
    checkmate::assert_names(names(lookup), must.include = choices)

    for (i in c("tag", "order", "name")) {
        if (any(is.na(lookup[[i]]))) {
            cli::cli_alert_info(paste0(
                "The lookup table has {.strong {cli::col_red('NA')}} ",
                "values in the {.strong {cli::col_blue(i)}} column ",
                "{cli::qty(length(which(is.na(lookup[[i]]))))}(row{?s} ",
                "{as.character(which(is.na(lookup[[i]])))}). ",
                "{?This/These} row{?s} were removed."
            ))

            lookup <- lookup[-which(is.na(lookup[[i]])), ]
        }
    }

    if (nrow(lookup) == 0) {
        cli::cli_abort(paste0(
            "No rows remained in the lookup table after the cleaning ",
            "process. Check the function documentation to learn more."
        ))
    }

    lookup <- lookup[!duplicated(lookup$tag), ]

    invisible(lookup)
}

join_ref_col_values <- function(x, lookup, sep) {
    choices <- c("tag", "order", "name")

    checkmate::assert_data_frame(x)
    checkmate::assert_data_frame(lookup, min.rows = 1, min.cols = 3)
    checkmate::assert_names(names(lookup), must.include = choices)
    checkmate::assert_string(sep)

    if (any(duplicated(lookup$name), na.rm = TRUE)) {
        duplicate_names <- unique(lookup$name[duplicated(lookup$name)]) %>%
            rutils:::rm_na()

        for (i in duplicate_names) {
            tags <- lookup$tag[which(lookup$name == i)]

            if (any(tags %in% names(x), na.rm = TRUE)) {
                cols <- tags[tags %in% names(x)]

                x <- x %>%
                    tidyr::unite(!!as.symbol(cols[1]), dplyr::all_of(cols),
                                 sep = " | ", na.rm = TRUE)
            }
        }

        invisible(x)
    } else {
        invisible(x)
    }
}
