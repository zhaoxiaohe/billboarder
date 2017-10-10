#' Map variables on the chart
#'
#' @param bb A \code{billboard} \code{htmlwidget} object.
#' @param x Name of the variable to map on the x-axis
#' @param y Name of the variable to map on the y-axis
#' @param group Name of the grouping variable.
#'
#' @return A \code{billboard} \code{htmlwidget} object.
#' @export
#' 
#' @note \code{bb_aes} is intended to use in a "piping" way. 
#' \code{bbaes} is the equivalent to use inside a helper function such as \code{bb_barchart}, \code{bb_scatterplot}...
#' 
#' @name billboard-aes
#'
#' @examples
#' \dontrun{
#' dat <- as.data.frame(table(sample(letters[1:5], 100, TRUE)))
#' 
#' billboarder(data = dat) %>% 
#'   bb_aes(x = Var1, y = Freq) %>% 
#'   bb_barchart()
#' 
#' 
#' tab <- table(sample(letters[1:5], 100, TRUE), sample(LETTERS[1:5], 100, TRUE))
#' dat_group <- as.data.frame(tab)
#' 
#' billboarder(data = dat_group) %>% 
#'   bb_aes(x = Var1, y = Freq, group = "Var2") %>% 
#'   bb_barchart()
#' }
# bbaes <- function(bb, x, y, group = NULL) {
#   x <- deparse(substitute(x))
#   y <- deparse(substitute(y))
#   group <- deparse(substitute(group))
#   if (identical(group, "NULL"))
#     group <- NULL
#   bb$x$aes <- list(x = x, y = y, group = group)
#   bb
# }
bb_aes <- function(bb, x, y, group = NULL) {
  aes <- structure(as.list(match.call()[-1]), class = "uneval")
  aes$bb <- NULL
  bb$x$mapping <- aes
  bb
}

#' @rdname billboard-aes
#' @export
bbaes <- function(x, y, group = NULL) {
  aes <- structure(as.list(match.call()[-1]), class = "uneval")
  aes
}


bbmapping <- function(data, mapping) {
  
  if (is.null(data))
    return(list())
  
  if (is.null(mapping$group)) {
    json <- lapply(
      X = mapping,
      FUN = function(paraes) {
        eval(paraes, envir = data, enclos = parent.frame())
      }
    )
    names(json) <- as.character(unlist(mapping))
    x <- as.character(mapping$x)
    if (anyDuplicated(json[[x]])) {
      y <- as.character(mapping$y)
      json[[y]] <- tapply(X = json[[y]], INDEX = json[[x]], FUN = sum, na.rm = TRUE)
      json[[x]] <- names(json[[y]])
      json[[y]] <- unname(json[[y]])
      message("Non unique values in '", x, "' : calculating sum of '", y, "'")
    }
  } else {
    grouping <- eval(mapping$group, envir = data, enclos = parent.frame())
    mapping$group <- NULL
    x_un <- eval(mapping$x, envir = data, enclos = parent.frame())
    x_un <- unique(x_un)
    data_split <- split(x = data, f = grouping)
    n_ <- names(data_split)
    json <- lapply(
      X = stats::setNames(n_, n_),
      FUN = function(iii) {
        y_ <- eval(mapping$y, envir = data_split[[iii]], enclos = parent.frame())
        x_ <- eval(mapping$x, envir = data_split[[iii]], enclos = parent.frame())
        idx <- match(x = x_un, table = x_, nomatch = nrow(data_split[[iii]])+1)
        y_[idx]
      }
    )
    x <- as.character(mapping$x)
    json[[x]] <- x_un
  }
  
  return(json)
  
}




