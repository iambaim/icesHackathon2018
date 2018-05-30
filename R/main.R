#' Run the packaged shiny app
#'
#' @export
#'
#' @import readr
#' @import stringi
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#' @import scales
#' @import magrittr
#'
#' @examples
#' \dontrun{
#'   launch_application()
#' }
launch_application <- function()
{
  shiny::runApp(appDir = system.file("app", package = "icesHackathon2018G3"))
}
