#' Combine raw PK tables into one standard table
#'
#' Takes the raw dose, drug level, and covariate tables and returns one
#' table with one row per event (dose or level), sorted by patient and time.
#' It adds TIME (hours since the patient's first dose) and TAD (hours since
#' the most recent dose, for level rows).
#'
#' Times must be numbers: hours since midnight on the patient's first
#' dosing day (for example, 8 = 8:00 AM on day 1, 31.5 = 7:30 AM on day 2).
#'
#' @param doses A data frame with columns ID, DOSE_TIME_HR, AMT_MG, INF_DUR_HR.
#' @param levels A data frame with columns ID, DRAW_TIME_HR, CONC_MGL.
#' @param covariates A data frame with columns ID, AGE, SEX, WT_KG, SCR_MGDL.
#'
#' @return A data frame with columns ID, TIME, EVENT, AMT, DUR, CONC, TAD,
#'   AGE, SEX, WT_KG, SCR_MGDL.
#'
#' @examples
#' standardize_pk_data(pk_doses, pk_levels, pk_covariates)
#'
#' @export
standardize_pk_data <- function(doses, levels, covariates) {

  # Step 1: stop if the times aren't numbers
  if (!is.numeric(doses$DOSE_TIME_HR) | !is.numeric(levels$DRAW_TIME_HR)) {
    stop("DOSE_TIME_HR and DRAW_TIME_HR must be numbers (hours).")
  }

  # Step 2: give doses and levels the same columns
  # CLOCK = the raw hour from the dataset (temporary column)
  doses2 <- dplyr::mutate(doses, CLOCK = DOSE_TIME_HR, EVENT = "dose",
                          AMT = AMT_MG, DUR = INF_DUR_HR, CONC = NA)
  levels2 <- dplyr::mutate(levels, CLOCK = DRAW_TIME_HR, EVENT = "level",
                           AMT = NA, DUR = NA, CONC = CONC_MGL)
  keep <- c("ID", "CLOCK", "EVENT", "AMT", "DUR", "CONC")
  doses2 <- doses2[, keep]
  levels2 <- levels2[, keep]

  # Step 3: stack into one table
  all_rows <- rbind(doses2, levels2)

  # Step 4: sort by patient, then by time
  all_rows <- dplyr::arrange(all_rows, ID, CLOCK)

  # Step 5: TIME = hours since this patient's first dose
  all_rows <- dplyr::group_by(all_rows, ID)
  all_rows <- dplyr::mutate(all_rows, TIME = CLOCK - min(CLOCK[EVENT == "dose"]))
  all_rows <- dplyr::ungroup(all_rows)

  # Step 6: TAD = level TIME minus the most recent dose's TIME
  all_rows$TAD <- NA
  last_dose <- NA
  for (i in 1:nrow(all_rows)) {
    # new patient: forget the previous patient's dose
    if (i == 1 || all_rows$ID[i] != all_rows$ID[i - 1]) {
      last_dose <- NA
    }
    if (all_rows$EVENT[i] == "dose") {
      last_dose <- all_rows$TIME[i]   # remember this dose's time
    } else {
      all_rows$TAD[i] <- all_rows$TIME[i] - last_dose
    }
  }

  # Step 7: add covariates by matching ID
  all_rows <- dplyr::left_join(all_rows, covariates, by = "ID")

  # Step 8: keep only the standard columns, in order
  all_rows <- dplyr::select(all_rows, ID, TIME, EVENT, AMT, DUR, CONC, TAD,
                            AGE, SEX, WT_KG, SCR_MGDL)
  as.data.frame(all_rows)
}
