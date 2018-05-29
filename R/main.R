#' Run the packaged shiny app
#'
#' @export
#' @examples
#' \dontrun{
#'   launch_application()
#' }
launch_application <- function()
{
  shiny::runApp(appDir = system.file("app", package = "icesHackathon2018G3"))
}
