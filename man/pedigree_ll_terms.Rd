% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{pedigree_ll_terms}
\alias{pedigree_ll_terms}
\alias{pedigree_ll_terms_loadings}
\title{Get a C++ Object for Log Marginal Likelihood Approximations}
\usage{
pedigree_ll_terms(data, max_threads = 1L, n_sequences = 8L)

pedigree_ll_terms_loadings(data, max_threads = 1L, n_sequences = 8L)
}
\arguments{
\item{data}{\code{\link{list}} where each element is a list for a cluster
with an:
\itemize{
  \item{\code{"X"}}{ element with the design matrix for the fixed effect,}
  \item{\code{"Z"}}{ element with the design matrix for the loadings of the effects (only needed for \code{pedigree_ll_terms_loadings}),}
  \item{\code{"y"}}{ element with the zero-one outcomes, and}
  \item{\code{"scale_mats"}}{ element with a list where each element is a
scale/correlation matrix for a particular type of effect.}
}}

\item{max_threads}{maximum number of threads to use.}

\item{n_sequences}{number of randomized quasi-Monte Carlo sequences to use.
More samples yields a better estimate of the error but a worse
approximation. Eight is used in the original Fortran code. If one is
used then the error will be set to zero because it cannot be estimated.}
}
\description{
Constructs an object needed for \code{\link{eval_pedigree_ll}} and
\code{\link{eval_pedigree_grad}}.
}
\details{
An intercept column is not added to the \code{X} matrices
like what \code{\link{lm.fit}} and \code{\link{glm.fit}} do.
Thus, it is often important that the user adds an intercept column
to these matrices as it is hardly ever justified to not include the
intercept (the exceptions being e.g. when splines are used which include
the intercept and with certain dummy designs). This equally holds for
the \code{Z} matrices with \code{pedigree_ll_terms_loadings}.

\code{pedigree_ll_terms_loadings} relax the assumption that the scale
parameter is the same for all individuals. \code{pedigree_ll_terms_loadings}
and \code{pedigree_ll_terms} yield the same model if \code{"Z"} is an
intercept column for all families but with a different parameterization.
In this case, \code{pedigree_ll_terms} will be
faster. See \code{vignette("pedmod", "pedmod")} for examples of using
\code{pedigree_ll_terms_loadings}.
}
\examples{
# three families as an example
fam_dat <- list(
  list(
    y = c(FALSE, TRUE, FALSE, FALSE),
    X = structure(c(
      1, 1, 1, 1, 1.2922654151273, 0.358134905909256, -0.734963997107464,
      0.855235473516044, -1.16189500386223, -0.387298334620742,
      0.387298334620742, 1.16189500386223),
      .Dim = 4:3, .Dimnames = list( NULL, c("(Intercept)", "X1", ""))),
    rel_mat = structure(c(
      1, 0.5, 0.5, 0.125, 0.5, 1, 0.5, 0.125, 0.5, 0.5,
      1, 0.125, 0.125, 0.125, 0.125, 1), .Dim = c(4L, 4L)),
    met_mat = structure(c(1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1),
                        .Dim = c(4L, 4L))),
  list(
    y = c(FALSE, FALSE, FALSE),
    X = structure(c(
      1, 1, 1, -0.0388728997202442, -0.0913782435233639,
      -0.0801619722392612, -1, 0, 1), .Dim = c(3L, 3L)),
    rel_mat = structure(c(
      1, 0.5, 0.125, 0.5, 1, 0.125, 0.125, 0.125, 1), .Dim = c(3L, 3L)),
    met_mat = structure(c(
      1, 1, 0, 1, 1, 0, 0, 0, 1), .Dim = c(3L, 3L))),
  list(
    y = c(TRUE, FALSE),
    X = structure(c(
      1, 1, 0.305275750370738, -1.49482995913648,  -0.707106781186547,
      0.707106781186547),
      .Dim = 2:3, .Dimnames = list( NULL, c("(Intercept)", "X1", ""))),
    rel_mat = structure(c(1, 0.5,  0.5, 1), .Dim = c(2L, 2L)),
    met_mat = structure(c(1, 1, 1, 1), .Dim = c(2L,  2L))))

# get the data into the format needed for the package
dat_arg <- lapply(fam_dat, function(x){
  # we need the following for each family:
  #   y: the zero-one outcomes.
  #   X: the design matrix for the fixed effects.
  #   scale_mats: list with the scale matrices for each type of effect.
  list(y = as.numeric(x$y), X = x$X,
       scale_mats = list(x$rel_mat, x$met_mat))
})

# get a pointer to the C++ object
ptr <- pedigree_ll_terms(dat_arg, max_threads = 1L)

# get the argument for a the version with loadings
dat_arg_loadings <- lapply(fam_dat, function(x){
  list(y = as.numeric(x$y), X = x$X, Z = x$X[, 1:2],
       scale_mats = list(x$rel_mat, x$met_mat))
})

ptr <- pedigree_ll_terms_loadings(dat_arg_loadings, max_threads = 1L)

}
