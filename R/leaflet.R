#' Plot CLDF Languages on an Interactive Map
#'
#' @description
#' Creates a leaflet map showing all languages in the CLDF dataset that have geographic coordinates.
#' Longitudes are standardized to a 0-360 range to ensure a continuous Pacific-centered view.
#'
#' @param x A cldf object.
#' @param color_by Character string specifying the column in `LanguageTable` to use for marker coloring.
#' Default is "ID".
#'
#' @return A leaflet map object.
#' @export
plot_languages <- function(x, color_by = "ID") {
    if (!requireNamespace("leaflet", quietly = TRUE)) {
        stop("Package 'leaflet' is required for interactive maps. Please install it.")
    }

    lt <- x$tables$LanguageTable
    lt <- lt[!is.na(lt$Latitude) & !is.na(lt$Longitude), ]
    lt$Longitude[lt$Longitude < 0] <- lt$Longitude[lt$Longitude < 0] + 360


    # Define a vibrant color palette
    pal_fn <- leaflet::colorFactor(palette = "Set1", domain = lt[[color_by]])

    leaflet::leaflet(lt, options = leaflet::leafletOptions(worldCopyJump = TRUE)) %>%
        # Use the "Positron" theme for a clean, pure-white background
        leaflet::addProviderTiles("CartoDB.Positron") %>%
        leaflet::addCircleMarkers(
            lng = ~Longitude, lat = ~Latitude,
            color = "white", weight = 1,
            fillColor = ~pal_fn(lt[[color_by]]),
            fillOpacity = 0.8,
            radius = 6,
            popup = ~paste0("<b>", Name, "</b><br>", color_by, ": ", lt[[color_by]]),
            label = ~Name
        ) %>%
        leaflet::addLegend(pal = pal_fn, values = ~lt[[color_by]], title = color_by)
}


#' Plot Distribution of a Specific Parameter
#'
#' @description
#' Filters the dataset for a specific Parameter ID and maps the values across languages.
#' This function automatically resolves whether the data is in a Form or Value table
#' and joins it with geographic data.
#'
#' @param x A cldf object.
#' @param parameter Character string. The ID of the parameter to plot (e.g., "1sg_a").
#' @param color_by Character string. The column to use for the color scale (e.g., "Value").
#'
#' @return A leaflet map object.
#' @export
plot_parameter <- function(x, parameter = "1sg_a", color_by = 'Value') {
    if (!requireNamespace("leaflet", quietly = TRUE)) {
        stop("Package 'leaflet' is required for interactive maps. Please install it.")
    }

    # does param exist?
    if (parameter %in% x$tables$ParameterTable$ID == FALSE) {
        stop("Invalid Parameter_ID")
    }
    # do we have form table or value table
    fk <- rcldf:::get_foreign_keys(x)
    fk <- fk[fk$SourceColumn == 'Parameter_ID', ]

    df <- as.cldf.wide(x, x$resources[[ fk[['SourceTable']][[1]] ]])
    df <- df[df$Parameter_ID == parameter,]

    # remove no locations and standardise
    df <- df[! is.na(df$Longitude) & ! is.na(df$Latitude), ]
    df$Longitude[df$Longitude < 0] <- df$Longitude[df$Longitude < 0] + 360

    pal_fn <- leaflet::colorFactor(palette = "Set1", domain = df[[color_by]])

    leaflet::leaflet(df, options = leaflet::leafletOptions(worldCopyJump = TRUE)) |>
        leaflet::addProviderTiles("CartoDB.Positron") |>
        leaflet::addCircleMarkers(
            lng = ~Longitude, lat = ~Latitude,
            color = "white", weight = 1,
            fillColor = ~pal_fn(df[[color_by]]),
            fillOpacity = 0.8,
            radius = 6,
            popup = ~paste0("<b>", Name.LanguageTable, "</b><br>", color_by, ": ", df[[color_by]]),
            label = ~Name.LanguageTable
        ) %>%
        leaflet::addLegend(pal = pal_fn, values = ~df[[color_by]], title = color_by)

}



#' Plot Words/Forms as Text Labels on a Map
#'
#' @description
#' Similar to \code{plot_parameter}, but instead of circles, this function renders the
#' actual phonetic forms (Value) as text labels directly on the map. Labels are
#' color-coded based on the \code{color_by} column (e.g., Cognacy).
#'
#' @param x A cldf object.
#' @param parameter Character string. The ID of the parameter (word) to plot.
#' @param color_by Character string. Column used to categorize and color the text labels.
#'
#' @return A leaflet map object.
#' @export
plot_word <- function(x, parameter = "1sg_a", color_by = 'Cognacy') {
    if (!requireNamespace("leaflet", quietly = TRUE)) {
        stop("Package 'leaflet' is required for interactive maps. Please install it.")
    }

    # does param exist?
    if (parameter %in% x$tables$ParameterTable$ID == FALSE) {
        stop("Invalid Parameter_ID")
    }
    # do we have form table or value table
    fk <- rcldf:::get_foreign_keys(x) |>
        dplyr::filter(SourceColumn == 'Parameter_ID')

    df <- as.cldf.wide(x, x$resources[[ fk[['SourceTable']][[1]] ]])
    df <- df[df$Parameter_ID == parameter,]

    # remove no locations and standardise
    df <- df[! is.na(df$Longitude) & ! is.na(df$Latitude), ]
    df$Longitude[df$Longitude < 0] <- df$Longitude[df$Longitude < 0] + 360

    # Define colors for each row
    pal_fn <- leaflet::colorFactor(palette = "Set1", domain = df[[color_by]])
    df$label_color <- pal_fn(df[[color_by]])

    # Build HTML labels with inline colors
    df$html_label <- sprintf(
        "<span style='color:%s; font-weight:bold; font-size:12px;'>%s</span>",
        df$label_color,
        htmltools::htmlEscape(df$Value)
    )

    leaflet::leaflet(df, options = leaflet::leafletOptions(worldCopyJump = TRUE)) |>
        leaflet::addProviderTiles("CartoDB.Positron") |>
        leaflet::addLabelOnlyMarkers(
            lng = ~Longitude, lat = ~Latitude,
            label = lapply(df$html_label, htmltools::HTML),
            labelOptions = leaflet::labelOptions(
                noHide = TRUE,
                direction = "top",
                textOnly = TRUE
            )
        )
}

