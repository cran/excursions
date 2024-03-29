## interface.mc.R
##
##   Copyright (C) 2015 David Bolin
##
##   This program is free software: you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation, either version 3 of the License, or
##   (at your option) any later version.
##
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##
##   You should have received a copy of the GNU General Public License
##   along with this program.  If not, see <http://www.gnu.org/licenses/>.

#' Contour maps and contour map quality measures using Monte Carlo samples
#'
#' \code{contourmap.mc} is used for calculating contour maps and quality measures for contour maps based on Monte Carlo samples of a model.
#'
#' @param samples Matrix with model Monte Carlo samples. Each column contains a sample of the model.
#' @param n.levels Number of levels in contour map.
#' @param ind Indices of the nodes that should be analyzed (optional).
#' @param levels Levels to use in contour map.
#' @param type Type of contour map. One of:
#' \describe{
#'      \item{'standard' }{Equidistant levels between smallest and largest value of the posterior mean (default).}
#'      \item{'pretty' }{Equally spaced 'round' values which cover the range of the values in the posterior mean.}
#'      \item{'equalarea' }{Levels such that different spatial regions are approximately equal in size.}
#'      \item{'P0-optimal' }{Levels chosen to maximize the P0 measure.}
#'      \item{'P1-optimal' }{Levels chosen to maximize the P1 measure.}
#'      \item{'P2-optimal' }{Levels chosen to maximize the P2 measure.}
#' }
#' @param compute A list with quality indices to compute
#' \describe{
#'      \item{'F': }{TRUE/FALSE indicating whether the contour map function should be computed (default TRUE).}
#'      \item{'measures': }{A list with the quality measures to compute ("P0", "P1", "P2") or corresponding bounds based only on the marginal probabilities ("P0-bound", "P1-bound", "P2-bound").}
#'      }
#' @param alpha Maximal error probability in contour map function (default=0.1).
#' @param verbose Set to TRUE for verbose mode (optional).
#'
#' @return \code{contourmap} returns an object of class "excurobj" with the following elements
#'     \item{u }{Contour levels used in the contour map.}
#'     \item{n.levels }{The number of contours used.}
#'     \item{u.e }{The values associated with the level sets G_k.}
#'     \item{G }{A vector which shows which of the level sets G_k each node belongs to.}
#'     \item{map }{Representation of the contour map with map[i]=u.e[k] if i is in G_k.}
#'     \item{F }{The contour map function (if computed).}
#'     \item{M }{Contour avoiding sets (if \code{F} is computed). \eqn{M=-1} for all non-significant nodes and  \eqn{M=k} for nodes that belong to \eqn{M_k}.}
#'     \item{P0/P1/P2 }{Calculated quality measures (if computed).}
#'     \item{P0bound/P1bound/P2bound }{Calculated upper bounds quality measures (if computed).}
#'     \item{meta }{A list containing various information about the calculation.}
#' @author David Bolin \email{davidbolin@@gmail.com}
#' @details The contour map is computed for the empirical mean of the samples.
#' See \code{\link{contourmap}} and \code{\link{contourmap.inla}} for further details.
#' @references Bolin, D. and Lindgren, F. (2017) \emph{Quantifying the uncertainty of contour maps}, Journal of Computational and Graphical Statistics, 26:3, 513-524.
#'
#' Bolin, D. and Lindgren, F. (2018), \emph{Calculating Probabilistic Excursion Sets and Related Quantities Using excursions}, Journal of Statistical Software, 86(5), 1--20.
#' @seealso \code{\link{contourmap}}, \code{\link{contourmap.inla}}, \code{\link{contourmap.colors}}

#' @export
#'
#' @examples
#' n <- 100
#' Q <- Matrix(toeplitz(c(1, -0.5, rep(0, n - 2))))
#' mu <- seq(-5, 5, length = n)
#' ## Sample the model 100 times (increase for better estimate)
#' X <- mu + solve(chol(Q), matrix(rnorm(n = n * 100), nrow = n, ncol = 100))
#'
#' lp <- contourmap.mc(X, n.levels = 2, compute = list(F = FALSE, measures = c("P1", "P2")))
#'
#' # plot contourmap
#' plot(lp$map)
#' # display quality measures
#' c(lp$P1, lp$P2)
contourmap.mc <- function(samples,
                          n.levels,
                          ind,
                          levels,
                          type = c(
                            "standard",
                            "equalarea",
                            "P0-optimal",
                            "P1-optimal",
                            "P2-optimal"
                          ),
                          compute = list(F = TRUE, measures = NULL),
                          alpha,
                          verbose = FALSE) {
  if (missing(samples)) {
    stop("Must supply samples.")
  } else {
    samples <- as(samples, "matrix")
  }
  if (!missing(ind)) {
    ind <- private.as.vector(ind)
  }

  mu <- rowMeans(samples)
  type <- match.arg(type)

  if (missing(alpha) || is.null(alpha)) {
    alpha <- 0.1
  }

  measure <- NULL
  if (!is.null(compute$measures)) {
    measure <- match.arg(compute$measures,
      c("P0", "P1", "P2"),
      several.ok = TRUE
    )
  }

  if (type == "standard") {
    if (verbose) cat("Creating contour map\n")
    lp <- excursions.levelplot(
      mu = mu, n.levels = n.levels, ind = ind,
      levels = levels, equal.area = FALSE
    )
  } else if (type == "equalarea") {
    if (verbose) cat("Creating equal area contour map\n")
    lp <- excursions.levelplot(
      mu = mu, n.levels = n.levels, ind = ind,
      levels = levels, equal.area = TRUE
    )
  } else if (type == "P0-optimal" || type == "P1-optimal" || type == "P2-optimal") {
    warning("Pk-optimal contour maps not implemented, using standard.\n")
    lp <- excursions.levelplot(
      mu = mu, n.levels = n.levels, ind = ind,
      levels = levels, equal.area = FALSE
    )
  }

  F.calculated <- FALSE
  if (!is.null(measure)) {
    for (i in seq_along(measure)) {
      if (measure[i] == "P1") {
        if (verbose) cat("Calculating P1-measure\n")
        lp$P1 <- Pmeasure.mc(lp = lp, mu = mu, X = samples, ind = ind, type = 1)
      } else if (measure[i] == "P2") {
        if (verbose) cat("Calculating P2-measure\n")
        lp$P2 <- Pmeasure.mc(lp = lp, mu = mu, X = samples, ind = ind, type = 2)
      } else if (measure[i] == "P0") {
        if (verbose) cat("Calculating P0-measure and contour map function\n")

        p <- contourfunction.mc(
          lp = lp, mu = mu, X = samples, ind = ind,
          alpha = alpha, verbose = verbose
        )
        F.calculated <- TRUE
      }
    }
  }
  if (!F.calculated) {
    if (is.null(compute$F) || compute$F) {
      if (verbose) cat("Calculating contour map function\n")
      p <- contourfunction.mc(
        lp = lp, mu = mu, X = samples, ind = ind,
        alpha = alpha, verbose = verbose
      )
      F.calculated <- TRUE
    }
  }

  if (missing(ind) || is.null(ind)) {
    ind <- seq_len(length(mu))
  } else if (is.logical(ind)) {
    ind <- which(ind)
  }

  if (F.calculated) {
    lp$P0 <- mean(p$F[ind])
    lp$F <- p$F
    lp$E <- p$E
    lp$M <- p$M
    lp$rho <- p$rho
  } else {
    lp$E <- NULL
  }

  lp$meta <- list(
    calculation = "contourmap",
    F.limit = 0,
    alpha = alpha,
    levels = lp$u,
    type = "!=",
    n.iter = dim(samples)[2],
    mu.range = range(mu[ind]),
    ind = ind
  )
  class(lp) <- "excurobj"
  return(lp)
}


#' Simultaneous confidence regions using Monte Carlo samples
#'
#' \code{simconf.mc} is used for calculating simultaneous confidence regions based
#' on Monte Carlo samples. The function returns upper and lower bounds \eqn{a} and
#' \eqn{b} such that \eqn{P(a<x<b) = 1-\alpha}.
#'
#' @param samples Matrix with model Monte Carlo samples. Each column contains a sample of the model.
#' @param alpha Error probability for the region.
#' @param ind Indices of the nodes that should be analyzed (optional).
#' @param verbose Set to TRUE for verbose mode (optional).
#'
#' @return An object of class "excurobj" with elements
#' \item{a }{The lower bound.}
#' \item{b }{The upper bound.}
#' \item{a.marginal }{The lower bound for pointwise confidence bands.}
#' \item{b.marginal }{The upper bound for pointwise confidence bands.}
#' @export
#' @details See \code{\link{simconf}} for details.
#' @author David Bolin \email{davidbolin@@gmail.com}
#' @seealso \code{\link{simconf}}, \code{\link{simconf.inla}}
#'
#' @examples
#' ## Create mean and a tridiagonal precision matrix
#' n <- 11
#' mu.x <- seq(-5, 5, length = n)
#' Q.x <- Matrix(toeplitz(c(1, -0.1, rep(0, n - 2))))
#' ## Sample the model 100 times (increase for better estimate)
#' X <- mu.x + solve(chol(Q.x), matrix(rnorm(n = n * 100), nrow = n, ncol = 100))
#' ## calculate the confidence region
#' conf <- simconf.mc(X, 0.2)
#' ## Plot the region
#' plot(mu.x,
#'   type = "l", ylim = c(-10, 10),
#'   main = "Mean (black) and confidence region (red)"
#' )
#' lines(conf$a, col = 2)
#' lines(conf$b, col = 2)
simconf.mc <- function(samples,
                       alpha,
                       ind,
                       verbose = FALSE) {
  if (missing(samples)) {
    stop("Must provide matrix with samples")
  }

  if (missing(alpha)) {
    stop("Must provide significance level alpha")
  }

  if (missing(ind)) {
    ind <- seq_len(dim(samples)[1])
  }

  a.marg <- apply(samples, 1, quantile, 1, probs = c(alpha / 2))
  b.marg <- apply(samples, 1, quantile, 1, probs = c(1 - alpha / 2))

  # Simple golden section search
  lb <- 0
  ub <- alpha
  gr <- 2 / (sqrt(5) + 1)
  x1 <- ub - gr * (ub - lb)
  x2 <- lb + gr * (ub - lb)


  f1 <- fsamp.opt(x1, samples = samples[ind, ], verbose = verbose)
  f2 <- fsamp.opt(x2, samples = samples[ind, ], verbose = verbose)

  while (abs(ub - lb) > 1e-4) {
    if (f2 < 1 - alpha) {
      # optimum is to the left of x2
      ub <- x2
      x2 <- x1
      f2 <- f1
      x1 <- ub - gr * (ub - lb)
      f1 <- fsamp.opt(x1, samples = samples[ind, ], verbose = verbose)
    } else {
      lb <- x1
      x1 <- x2
      f1 <- f2
      x2 <- lb + gr * (ub - lb)
      f2 <- fsamp.opt(x2, samples = samples[ind, ], verbose = verbose)
    }
  }

  rho <- (lb + ub) / 2
  cat(rho)
  a <- apply(samples, 1, quantile, 1, probs = c(rho / 2))
  b <- apply(samples, 1, quantile, 1, probs = c(1 - rho / 2))

  return(list(
    a = a[ind],
    b = b[ind],
    a.marginal = a.marg[ind],
    b.marginal = b.marg[ind]
  ))
}



#' Excursion sets and contour credible regions using Monte Carlo samples
#'
#' \code{excursions.mc} is used for calculating excursion sets, contour credible
#' regions, and contour avoiding sets based on Monte Carlo samples of models.
#'
#' @param samples Matrix with model Monte Carlo samples. Each column contains a
#' sample of the model.
#' @param alpha Error probability for the excursion set.
#' @param u Excursion or contour level.
#' @param type Type of region:
#'  \describe{
#'      \item{'>' }{positive excursions}
#'      \item{'<' }{negative excursions}
#'      \item{'!=' }{contour avoiding function}
#'      \item{'=' }{contour credibility function}}
#' @param rho Marginal excursion probabilities (optional). For contour regions,
#' provide \eqn{P(X>u)}.
#' @param reo Reordering (optional).
#' @param ind Indices of the nodes that should be analysed (optional).
#' @param max.size Maximum number of nodes to include in the set of interest (optional).
#' @param verbose Set to TRUE for verbose mode (optional).
#'
#' @return \code{excursions.mc} returns an object of class "excurobj" with the 
#' following elements
#' \item{E }{Excursion set, contour credible region, or contour avoiding set.}
#' \item{G }{ Contour map set. \eqn{G=1} for all nodes where the \eqn{mu > u}.}
#' \item{M }{ Contour avoiding set. \eqn{M=-1} for all non-significant nodes.
#' \eqn{M=0} for nodes where the process is significantly below \code{u} and
#' \eqn{M=1} for all nodes where the field is significantly above \code{u}.
#' Which values that should be present depends on what type of set that is calculated.}
#' \item{F }{The excursion function corresponding to the set \code{E} calculated
#' for values up to \code{F.limit}}
#' \item{rho }{Marginal excursion probabilities}
#' \item{mean }{The mean \code{mu}.}
#' \item{vars }{Marginal variances.}
#' \item{meta }{A list containing various information about the calculation.}
#' @export
#' @author David Bolin \email{davidbolin@@gmail.com} and Finn Lindgren
#' \email{finn.lindgren@@gmail.com}
#' @references Bolin, D. and Lindgren, F. (2015) \emph{Excursion and contour
#' uncertainty regions for latent Gaussian models}, JRSS-series B, vol 77, no 1,
#' pp 85-106.
#'
#' Bolin, D. and Lindgren, F. (2018), \emph{Calculating Probabilistic Excursion Sets and Related Quantities Using excursions}, Journal of Statistical Software, vol 86, no 1, pp 1-20.
#' @seealso \code{\link{excursions}}, \code{\link{excursions.inla}}
#' @examples
#' ## Create mean and a tridiagonal precision matrix
#' n <- 101
#' mu.x <- seq(-5, 5, length = n)
#' Q.x <- Matrix(toeplitz(c(1, -0.1, rep(0, n - 2))))
#' ## Sample the model 100 times (increase for better estimate)
#' X <- mu.x + solve(chol(Q.x), matrix(rnorm(n = n * 1000), nrow = n, ncol = 1000))
#' ## calculate the positive excursion function
#' res.x <- excursions.mc(X, alpha = 0.05, type = ">", u = 0)
#' ## Plot the excursion function and the marginal excursion probabilities
#' plot(res.x$F,
#'   type = "l",
#'   main = "Excursion function (black) and marginal probabilites (red)"
#' )
#' lines(res.x$rho, col = 2)
excursions.mc <- function(samples,
                          alpha,
                          u,
                          type,
                          rho,
                          reo,
                          ind,
                          max.size,
                          verbose = FALSE) {
  if (missing(alpha)) {
    stop("Must specify error probability")
  }

  if (missing(u)) {
    stop("Must specify level")
  }

  mu <- rowMeans(samples)

  if (missing(type)) {
    stop("Must specify type of excursion set")
  }

  if (!missing(ind) && !missing(reo)) {
    stop("Either provide a reordering using the reo argument or provied a set of nodes using the ind argument, both cannot be provided")
  }


  F.limit <- 1

  if (verbose) {
    cat("Calculate marginals\n")
  }
  marg <- excursions.marginals.mc(
    X = samples, type = type, rho = rho,
    mu = mu, u = u
  )

  if (missing(max.size)) {
    m.size <- length(mu)
  } else {
    m.size <- max.size
  }
  if (!missing(ind)) {
    if (is.logical(ind)) {
      indices <- ind
      if (missing(max.size)) {
        m.size <- sum(ind)
      } else {
        m.size <- min(sum(ind), m.size)
      }
    } else {
      indices <- rep(FALSE, length(mu))
      indices[ind] <- TRUE
      if (missing(max.size)) {
        m.size <- length(ind)
      } else {
        m.size <- min(length(ind), m.size)
      }
    }
  } else {
    indices <- rep(TRUE, length(mu))
  }

  if (verbose) {
    cat("Calculate permutation\n")
  }
  if (missing(reo)) {
    reo <- excursions.permutation(marg$rho, indices, use.camd = FALSE)
  }

  if (verbose) {
    cat("Calculate limits\n")
  }
  limits <- excursions.setlimits(
    marg = marg, type = type, u = u,
    mu = rep(0, length(mu)), QC = FALSE
  )


  res <- mcint(X = samples[reo, ], a = limits$a[reo], b = limits$b[reo])

  n <- length(mu)
  ii <- which(res$Pv[1:n] > 0)
  if (length(ii) == 0) i <- n + 1 else i <- min(ii)

  F <- Fe <- E <- G <- rep(0, n)
  F[reo] <- res$Pv
  Fe[reo] <- res$Ev
  ireo <- NULL
  ireo[reo] <- 1:n

  ind.lowF <- F < 1 - F.limit
  E[F > 1 - alpha] <- 1

  if (type == "=") {
    F <- 1 - F
  }

  if (type == "<") {
    G[mu > u] <- 1
  } else {
    G[mu >= u] <- 1
  }

  F[ind.lowF] <- Fe[ind.lowF] <- NA

  M <- rep(-1, n)
  if (type == "<") {
    M[E == 1] <- 0
  } else if (type == ">") {
    M[E == 1] <- 1
  } else if (type == "!=" || type == "=") {
    M[E == 1 & mu > u] <- 1
    M[E == 1 & mu < u] <- 0
  }

  if (missing(ind) || is.null(ind)) {
    ind <- seq_len(n)
  } else if (is.logical(ind)) {
    ind <- which(ind)
  }
  vars <- rowSums((samples - rowMeans(samples))^2) / (dim(samples)[2] - 1)
  output <- list(
    F = F,
    G = G,
    M = M,
    E = E,
    mean = mu,
    vars = vars,
    rho = marg$rho,
    meta = (list(
      calculation = "excursions",
      type = type,
      level = u,
      F.limit = F.limit,
      alpha = alpha,
      n.iter = dim(samples)[2],
      method = "MC",
      ind = ind,
      reo = reo,
      ireo = ireo,
      Fe = Fe
    ))
  )
  class(output) <- "excurobj"
  output
}
