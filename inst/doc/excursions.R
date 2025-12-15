## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  dev = "png",
  dev.args = list(type = "cairo-png")
)
library(excursions)
library(fields)
library(RColorBrewer)
library(sp)
library(fmesher)
library(excursions)
seed <- 1
exc.seed <- 123
set.seed(seed)

## ----inla_link, include = FALSE-----------------------------------------------
inla_link <- function() {
  sprintf("[%s](%s)", "`R-INLA`", "https://www.r-inla.org")
}

## -----------------------------------------------------------------------------
x <- seq(from = 0, to = 10, length.out = 20)
mesh <- fm_rcdt_2d_inla(
  lattice = fm_lattice_2d(x = x, y = x),
  extend = FALSE, refine = FALSE
)
Q <- fm_matern_precision(mesh, alpha = 2, rho = 3, sigma = 1)
x <- fm_sample(n = 1, Q = Q)
obs.loc <- 10 * cbind(runif(100), runif(100))

## -----------------------------------------------------------------------------
A <- fm_basis(mesh, loc = obs.loc)
sigma2.e <- 0.01
Y <- as.vector(A %*% x + rnorm(100) * sqrt(sigma2.e))
Q.post <- (Q + (t(A) %*% A) / sigma2.e)
mu.post <- as.vector(solve(Q.post, (t(A) %*% Y) / sigma2.e))

## ----fig.width=7, fig.height=4, fig.align = "center"--------------------------
proj <- fm_evaluator(mesh, dims = c(100, 100))
cmap <- colorRampPalette(brewer.pal(9, "YlGnBu"))(100)

sd.post <- excursions.variances(Q = Q.post, max.threads = 2)^0.5
cmap.sd <- colorRampPalette(brewer.pal(9, "Reds"))(100)

par(mfrow = c(1, 2))
image.plot(proj$x, proj$y, fm_evaluate(proj, field = mu.post),
  col = cmap, axes = FALSE,
  xlab = "", ylab = "", asp = 1
)
points(obs.loc[, 1], obs.loc[, 2], pch = 20)
image.plot(proj$x, proj$y, fm_evaluate(proj, field = sd.post),
  col = cmap.sd, axes = FALSE,
  xlab = "", ylab = "", asp = 1
)
points(obs.loc[, 1], obs.loc[, 2], pch = 20)

## -----------------------------------------------------------------------------
res.exc <- excursions(
  mu = mu.post, Q = Q.post, alpha = 0.1, type = ">",
  u = 0, F.limit = 1
)

## ----eval=FALSE---------------------------------------------------------------
# excursions.mc(X, u, type)

## -----------------------------------------------------------------------------
res.con <- contourmap(
  mu = mu.post, Q = Q.post,
  n.levels = 4, alpha = 0.1,
  compute = list(F = TRUE, measures = c("P0"))
)

## -----------------------------------------------------------------------------
sets.exc <- continuous(ex = res.exc, geometry = mesh, alpha = 0.1)

## ----eval=FALSE---------------------------------------------------------------
# simconf(alpha, mu, Q)

## ----eval=FALSE---------------------------------------------------------------
# gaussint(mu, Q, a, b)

## ----fig.width=5, fig.height=4, fig.align = "center"--------------------------
set.sc <- tricontourmap(mesh,
  z = mu.post,
  levels = res.con$u
)
plot(set.sc$map, col = contourmap.colors(res.con, col = cmap))

## ----fig.width=5, fig.height=4, fig.align = "center"--------------------------
plot(sets.exc$M["1"],
  col = "red",
  xlim = range(mesh$loc[, 1]),
  ylim = range(mesh$loc[, 2])
)
plot(mesh,
  vertex.color = rgb(0.5, 0.5, 0.5),
  draw.segments = FALSE,
  edge.color = rgb(0.5, 0.5, 0.5),
  add = TRUE
)

## ----fig.width=5, fig.height=4, fig.align = "center"--------------------------
cmap.F <- colorRampPalette(brewer.pal(9, "Greens"))(100)
proj <- fm_evaluator(sets.exc$F.geometry, dims = c(200, 200))
image(proj$x, proj$y, fm_evaluate(proj, field = sets.exc$F),
  col = cmap.F, axes = FALSE, xlab = "", ylab = "", asp = 1
)
con <- tricontourmap(mesh, z = mu.post, levels = 0)
plot(con$map, add = TRUE)

