
<!-- README.md is generated from README.Rmd. Please edit that file -->

# refstudio <a href='https://gipso.github.io/refstudio'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

![CRAN status](https://www.r-pkg.org/badges/version/refstudio)
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/gipso/refstudio/workflows/R-CMD-check/badge.svg)](https://github.com/gipso/refstudio/actions)
[![Codecov test
coverage](https://codecov.io/gh/gipso/refstudio/branch/main/graph/badge.svg)](https://codecov.io/gh/gipso/refstudio?branch=main)
[![License:
MIT](https://img.shields.io/badge/license-MIT-green)](https://choosealicense.com/licenses/mit/)
[![Contributor
Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](https://gipso.github.io/refstudio/CODE_OF_CONDUCT.html)
[![Buy Me A Coffee donate
button](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg)](https://ko-fi.com/danielvartan)
<!-- badges: end -->

`refstudio` is an R package that provides a complete and consistent
toolkit to deal with the extraction and processing tasks of
bibliographical references. The aim of `refstudio` is to facilitate the
evidence synthesis work while also helping with research
reproducibility.

> Please note that this package is currently on the development stage
> and have not yet been [peer
> reviewed](https://devguide.ropensci.org/softwarereviewintro.html).

## Prerequisites

You only need to have some familiarity with the [R programming
language](https://www.r-project.org/) to use `refstudio` main functions.

In case you don’t feel comfortable with R, we strongly recommend
checking Hadley Wickham and Garrett Grolemund’s free and online book [R
for data Science](https://r4ds.had.co.nz/) and the Coursera course from
John Hopkins University [Data Science: Foundations using
R](https://www.coursera.org/specializations/data-science-foundations-r)
(free for audit students).

## Installation

`refstudio` is still at the
[experimental](https://lifecycle.r-lib.org/articles/stages.html#experimental)
stage of development. That means people can use the package and provide
feedback, but it comes with no promises for long term stability.

You can install `refstudio` from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("gipso/refstudio")
```

## Citation

If you use `refstudio` in your research, please consider citing it. We
put a lot of work to build and maintain a free and open-source R
package. You can find the `refstudio` citation below.

``` r
citation("refstudio")
#> 
#> To cite {refstudio} in publications use:
#> 
#>   Vartanian, D., Pedrazzoli, M. (2021). {refstudio}: an R package for
#>   extracting and processing bibliographical references.
#>   https://gipso.github.io/refstudio/.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Unpublished{,
#>     title = {{refstudio}: an R package for extracting and processing bibliographical references},
#>     author = {Daniel Vartanian and Mario Pedrazzoli},
#>     year = {2021},
#>     url = {https://gipso.github.io/refstudio/},
#>     note = {Lifecycle: experimental},
#>   }
```

## Contributing

`refstudio` is a community project, everyone is welcome to contribute.
Take a moment to review our [Guidelines for
Contributing](https://gipso.github.io/refstudio/CONTRIBUTING.html).

Please note that `refstudio` is released with a [Contributor Code of
Conduct](https://gipso.github.io/refstudio/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

## Support `refstudio`

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/danielvartan)

Working with science in Brazil is a daily challenge. There are few
funding opportunities available and their value is not enough to live
on. Added to this, every day Brazilian science suffers from deep cuts in
funding, which requires researchers to always look for other sources of
income.

If this package helps you in any way or you simply want to support the
author’s work, please consider donating or even creating a membership
subscription (if you can!). Your support will help with the author’s
scientific pursuit and with the package maintenance.

To make a donation click on the [Ko-fi](https://ko-fi.com/danielvartan)
button above. Please indicate the `refstudio` package in your donation
message.

Thank you!
