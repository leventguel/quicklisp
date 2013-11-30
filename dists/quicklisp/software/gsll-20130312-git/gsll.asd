;; Definition of GSLL system 
;; Liam Healy
;; Time-stamp: <2012-02-05 16:50:51EST gsll.asd>
;;
;; Copyright 2006, 2007, 2008, 2009, 2010, 2011 Liam M. Healy
;; Distributed under the terms of the GNU General Public License
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(eval-when (:compile-toplevel :load-toplevel :execute)
  (asdf:oos 'asdf:load-op :cffi-libffi)) ; loads cff-grovel too, needed here

(asdf:defsystem #:gsll
  :name "GSLL"
  :description "GNU Scientific Library for Lisp."
  :version "0"
  :author "Liam M. Healy"
  :licence "GPL v3"
  :defsystem-depends-on (#:cffi-grovel #:asdf-system-connections)
  :depends-on (#:antik
	       #:cffi-grovel
	       #:trivial-garbage
	       #:alexandria
	       #:metabang-bind
	       #:osicat)
  :components
  ((:module init
	    :components
	    ((:file "init")
	     (cffi-grovel:grovel-file
	      "libgsl" :pathname #+unix "libgsl-unix" #-unix "nothing-here"
	      :depends-on ("init"))
	     (:file "utility" :depends-on ("init"))
	     (:file "forms" :depends-on ("init"))
	     (:file "conditions" :depends-on ("init" "libgsl"))
	     (:file "callback-compile-defs" :depends-on ("init"))
	     (:file "mobject" :depends-on ("init" "callback-compile-defs"))
	     (:file "callback-included" :depends-on ("mobject"))
	     (:file "callback"
		    :depends-on
		    ("init" "utility" "forms"
			    "callback-included"))
	     (:file "types" :depends-on ("init" "libgsl"))
	     (cffi-grovel:grovel-file "callback-struct"
				      :depends-on ("types" "libgsl"))
	     (:file "funcallable" :depends-on ("init" "utility"))
	     (:file "interface"
		    :depends-on ("init" "conditions"))
	     (:file "defmfun" :depends-on ("init" "forms" "interface"))
	     (:file "defmfun-array"
		    :depends-on ("init" "defmfun" "callback-included"))
	     (:file "defmfun-single"
		    :depends-on ("init" "defmfun" "mobject" "callback"))
	     (:file "body-expand" :depends-on ("init" "defmfun" "mobject" "callback"))
	     (:file "generate-examples" :depends-on ("init"))))
   (:module floating-point
	    :depends-on (init)
	    :components
	    ((:file "ieee-modes")
	     (:file "floating-point")))
   (:module mathematical
	    :depends-on (init)
	    :components
	    ((:file "mathematical")
	     #+fsbv
	     (:file "complex")))
   (:module data
	    :depends-on (init)
	    :components
	    ((cffi-grovel:grovel-file "array-structs")
	     (:file "foreign-array" :depends-on ("array-structs"))
	     (:file "vector" :depends-on ("foreign-array" "array-structs"))
	     (:file "matrix" :depends-on ("foreign-array" "vector" "array-structs"))
	     (:file "both" :depends-on ("foreign-array" "vector" "matrix"))
	     (:file "array-tests" :depends-on ("both"))
	     (:file "permutation" :depends-on ("foreign-array" "array-structs"))
	     (:file "combination" :depends-on ("foreign-array" "array-structs"))))
   (:file "polynomial" :depends-on (init data))
   (:module special-functions
	    :depends-on (init mathematical)
	    :components
	    ((cffi-grovel:grovel-file "sf-result")
	     (:file "return-structures" :depends-on ("sf-result"))
	     (:file "airy" :depends-on ("return-structures"))
	     (:file "bessel" :depends-on ("return-structures"))
	     (:file "clausen" :depends-on ("return-structures"))
	     (:file "coulomb" :depends-on ("return-structures"))
	     (:file "coupling" :depends-on ("return-structures"))
	     (:file "dawson" :depends-on ("return-structures"))
	     (:file "debye" :depends-on ("return-structures"))
	     (:file "dilogarithm" :depends-on ("return-structures"))
	     (:file "elementary" :depends-on ("return-structures"))
	     (:file "elliptic-integrals" :depends-on ("return-structures"))
	     (:file "elliptic-functions" :depends-on ("return-structures"))
	     (:file "error-functions" :depends-on ("return-structures"))
	     (:file "exponential-functions" :depends-on ("return-structures"))
	     (:file "exponential-integrals" :depends-on ("return-structures"))
	     (:file "fermi-dirac" :depends-on ("return-structures"))
	     (:file "gamma" :depends-on ("return-structures"))
	     (:file "gegenbauer" :depends-on ("return-structures"))
	     (:file "hypergeometric" :depends-on ("return-structures"))
	     (:file "laguerre" :depends-on ("return-structures"))
	     (:file "lambert" :depends-on ("return-structures"))
	     (:file "legendre" :depends-on ("return-structures"))
	     (:file "logarithm" :depends-on ("return-structures"))
	     (:file "mathieu" :depends-on ("return-structures"))
	     (:file "power" :depends-on ("return-structures"))
	     (:file "psi" :depends-on ("return-structures"))
	     (:file "synchrotron" :depends-on ("return-structures"))
	     (:file "transport" :depends-on ("return-structures"))
	     (:file "trigonometry" :depends-on ("return-structures"))
	     (:file "zeta" :depends-on ("return-structures"))))
   (:file "sorting" :depends-on (init data))
   (:module linear-algebra
	    :depends-on (init data special-functions)
	    :components
	    ((:file "blas1")
	     (:file "blas2")
	     (:file "blas3" :depends-on ("blas2"))
	     (:file "matrix-generation")
	     (:file "exponential")
	     (:file "lu")
	     (:file "qr")
	     (:file "qrpt")
	     (:file "svd")
	     (:file "cholesky")
	     (:file "diagonal")
	     (:file "householder")))
   (:module eigensystems
	    :depends-on (init data)
	    :components
	    ((:file "symmetric-hermitian")
	     (cffi-grovel:grovel-file "eigen-struct")
	     (:file "nonsymmetric" :depends-on ("eigen-struct"))
	     (:file "generalized")
	     (:file "nonsymmetric-generalized")))
   (:module fast-fourier-transforms
            :depends-on (init data)
            :components
            ((:file "wavetable-workspace")
	     (:file "forward")
             (:file "backward")
             (:file "inverse")
             (:file "select-direction")
             (:file "unpack")
             (:file "discrete")
             (:file "extras")
	     (:file "example")))
   (:module random
	    :depends-on (init data)
	    :components
	    ((:file "rng-types")
	     (:file "generators" :depends-on ("rng-types"))
	     (:file "quasi" :depends-on ("rng-types" "generators"))
	     (:file "tests" :depends-on ("rng-types"))
	     (:file "gaussian" :depends-on ("rng-types"))
	     (:file "gaussian-tail" :depends-on ("rng-types"))
	     (:file "gaussian-bivariate" :depends-on ("rng-types"))
	     (:file "exponential" :depends-on ("rng-types"))
	     (:file "laplace" :depends-on ("rng-types"))
	     (:file "exponential-power" :depends-on ("rng-types"))
	     (:file "cauchy" :depends-on ("rng-types"))
	     (:file "rayleigh" :depends-on ("rng-types"))
	     (:file "rayleigh-tail" :depends-on ("rng-types"))
	     (:file "landau" :depends-on ("rng-types"))
	     (:file "levy" :depends-on ("rng-types"))
	     (:file "gamma" :depends-on ("rng-types"))
	     (:file "flat" :depends-on ("rng-types"))
	     (:file "lognormal" :depends-on ("rng-types"))
	     (:file "chi-squared" :depends-on ("rng-types"))
	     (:file "fdist" :depends-on ("rng-types"))
	     (:file "tdist" :depends-on ("rng-types"))
	     (:file "beta" :depends-on ("rng-types"))
	     (:file "logistic" :depends-on ("rng-types"))
	     (:file "pareto" :depends-on ("rng-types"))
	     (:file "spherical-vector" :depends-on ("rng-types"))
	     (:file "weibull" :depends-on ("rng-types"))
	     (:file "gumbel1" :depends-on ("rng-types"))
	     (:file "gumbel2" :depends-on ("rng-types"))
	     (:file "dirichlet" :depends-on ("rng-types"))
	     (:file "discrete" :depends-on ("rng-types"))
	     (:file "poisson" :depends-on ("rng-types"))
	     (:file "bernoulli" :depends-on ("rng-types"))
	     (:file "binomial" :depends-on ("rng-types"))
	     (:file "multinomial" :depends-on ("rng-types"))
	     (:file "negative-binomial" :depends-on ("rng-types"))
	     (:file "geometric" :depends-on ("rng-types"))
	     (:file "hypergeometric" :depends-on ("rng-types"))
	     (:file "logarithmic" :depends-on ("rng-types"))
	     (:file "shuffling-sampling" :depends-on ("rng-types"))))
   (:module statistics
	    :depends-on (init data)
	    :components
	    ((:file "mean-variance")
	     (:file "absolute-deviation")
	     (:file "higher-moments")
	     (:file "autocorrelation")
	     (:file "covariance")
	     ;; minimum and maximum values provided in vector.lisp
	     (:file "median-percentile")))
   (:module histogram
	    :depends-on (init linear-algebra random)
	    :components
	    ((:file "histogram")
	     (:file "updating-accessing" :depends-on ("histogram"))
	     (:file "statistics" :depends-on ("histogram"))
	     (:file "operations" :depends-on ("histogram"))
	     (:file "probability-distribution" :depends-on ("histogram"))
	     (:file "ntuple")))
   (:module calculus
	    :depends-on (init mathematical data random)
	    :components
	    ((:file "numerical-integration")
	     (:file "numerical-integration-with-tables"
		    :depends-on ("numerical-integration"))
	     (cffi-grovel:grovel-file "monte-carlo-structs")
	     (:file "monte-carlo")
	     (:file "numerical-differentiation")))
   (:module ordinary-differential-equations
	    :depends-on (init)
	    :components
	    ((:file "ode-system")
	     (cffi-grovel:grovel-file "ode-struct")
	     (:file "stepping" :depends-on ("ode-struct"))
	     (:file "control")
	     (:file "evolution")
	     (:file "ode-example" :depends-on ("ode-system" "stepping"))))
   (:module interpolation
	    :depends-on (init mathematical)
	    :components
	    ((:file "interpolation")
	     (:file "types" :depends-on ("interpolation"))
	     (:file "lookup")
	     (:file "evaluation")
	     (:file "spline-example" :depends-on ("types"))))
   (:file "chebyshev" :depends-on (init))
   (cffi-grovel:grovel-file "series-struct")
   (:file "series-acceleration" :depends-on (init mathematical "series-struct"))
   (:file "wavelet" :depends-on (init data))
   (:file "hankel" :depends-on (init data))
   (:module solve-minimize-fit
	    :depends-on (init mathematical data random)
	    :components
	    ((:file "generic")
	     (cffi-grovel:grovel-file "solver-struct")
	     (:file "roots-one" :depends-on ("generic"))
	     (:file "minimization-one" :depends-on ("generic"))
	     (:file "roots-multi" :depends-on ("roots-one" "generic" "solver-struct"))
	     (:file "minimization-multi" :depends-on ("generic"))
	     (:file "linear-least-squares")
	     (:file "nonlinear-least-squares"
		    :depends-on ("generic" "solver-struct"))
	     #+fsbv
	     (:file "simulated-annealing")))
   (:file "basis-splines" :depends-on (init data random))
   (:module physical-constants
	    :depends-on (init)
	    :components
	    ((cffi-grovel:grovel-file "mksa")
	     (cffi-grovel:grovel-file "cgsm")
	     (cffi-grovel:grovel-file "num")
	     (:file export)))))

(asdf:defsystem-connection GSLL-tests
  :name "GSLL-tests"
  :description "Regression (unit) tests for GNU Scientific Library for Lisp."
  :version "0"
  :author "Liam M. Healy"
  :licence "GPL v3"
  :requires (gsll lisp-unit)
  :components
  ((:module test-unit
	    :components
	    ((cffi-grovel:grovel-file "machine")
	     (:file "augment" :depends-on ("machine"))))
   (:module tests
	    :depends-on (test-unit)
	    :components
	    ((:file "absolute-deviation")
	     (:file "absolute-sum")
	     (:file "airy")
	     (:file "autocorrelation")
	     (:file "axpy")
	     (:file "basis-spline")
	     (:file "bernoulli")
	     (:file "bessel")
	     (:file "beta")
	     (:file "binomial")
	     (:file "blas-copy")
	     (:file "blas-swap")
	     (:file "cauchy")
	     (:file "cdot")
	     (:file "chebyshev")
	     (:file "chi-squared")
	     (:file "cholesky")
	     (:file "clausen")
	     (:file "column")
	     (:file "combination")
	     (:file "coulomb")
	     (:file "coupling")
	     (:file "correlation")
	     (:file "covariance")
	     (:file "dawson")
	     (:file "debye")
	     (:file "dilogarithm")
	     (:file "dirichlet")
	     (:file "discrete")
	     (:file "dot")
	     (:file "eigensystems")
	     (:file "elementary")
	     (:file "elliptic-functions")
	     (:file "elliptic-integrals")
	     (:file "error-functions")
	     (:file "euclidean-norm")
	     (:file "exponential-functions")
	     (:file "exponential-integrals")
	     (:file "exponential")
	     (:file "exponential-power")
	     (:file "fast-fourier-transform")
	     (:file "fdist")
	     (:file "fermi-dirac")
	     (:file "flat")
	     (:file "gamma")
	     (:file "gamma-randist")
	     (:file "gaussian-bivariate")
	     (:file "gaussian")
	     (:file "gaussian-tail")
	     (:file "gegenbauer")
	     (:file "geometric")
	     (:file "givens")
	     (:file "gumbel1")
	     (:file "gumbel2")
	     (:file "hankel")
	     (:file "higher-moments")
	     (:file "histogram")
	     (:file "householder")
	     (:file "hypergeometric")
	     (:file "hypergeometric-randist")
	     (:file "index-max")
	     (:file "interpolation")
	     (:file "inverse-matrix-product")
	     (:file "laguerre")
	     (:file "lambert")
	     (:file "landau")
	     (:file "laplace")
	     (:file "legendre")
	     (:file "levy")
	     (:file "linear-least-squares")
	     (:file "logarithmic")
	     (:file "logarithm")
	     (:file "logistic")
	     (:file "lognormal")
	     (:file "lu")
	     (:file "mathematical")
	     (:file "mathieu")
	     (:file "matrix-div")
	     (:file "matrix-max-index")
	     (:file "matrix-max")
	     (:file "matrix-mean")
	     (:file "matrix-min")
	     (:file "matrix-min-index")
	     (:file "matrix-minmax-index")
	     (:file "matrix-minmax")
	     (:file "matrix-sub")
	     (:file "matrix-add")
	     (:file "matrix-mult")
	     #+fsbv (:file "matrix-product-hermitian")
	     (:file "matrix-product")
	     (:file "matrix-product-nonsquare")
	     (:file "matrix-product-symmetric")
	     (:file "matrix-product-triangular")
	     (:file "matrix-set-all")
	     (:file "matrix-set-zero")
	     (:file "matrix-standard-deviation")
	     (:file "matrix-standard-deviation-with-fixed-mean")
	     (:file "matrix-standard-deviation-with-mean")
	     (:file "matrix-swap")
	     (:file "matrix-transpose-copy")
	     (:file "matrix-transpose")
	     (:file "matrix-variance")
	     (:file "matrix-variance-with-fixed-mean")
	     (:file "matrix-variance-with-mean")
	     (:file "median-percentile")
	     (:file "minimization-one")
	     (:file "minimization-multi")
	     (:file "monte-carlo")
	     (:file "multinomial")
	     (:file "negative-binomial")
	     (:file "nonlinear-least-squares")
	     (:file "ntuple")
	     (:file "numerical-differentiation")
	     (:file "numerical-integration")
	     (:file "ode")
	     (:file "pareto")
	     (:file "permutation")
	     (:file "poisson")
	     (:file "polynomial")
	     (:file "power")
	     (:file "psi")
	     (:file "qr")
	     (:file "qrpt")
	     (:file "quasi-random-number-generators")
	     (:file "random-number-generators")
	     (:file "rank-1-update")
	     (:file "rayleigh")
	     (:file "rayleigh-tail")
	     (:file "roots-multi")
	     (:file "roots-one")
	     (:file "row")
	     (:file "scale")
	     (:file "series-acceleration")
	     (:file "set-basis")
	     (:file "setf-column")
	     (:file "setf-row")
	     (:file "set-identity")
	     (:file "shuffling-sampling")
	     (:file "sort-matrix-largest")
	     (:file "sort-matrix")
	     (:file "sort-matrix-smallest")
	     (:file "sort-vector-index")
	     (:file "sort-vector-largest-index")
	     (:file "sort-vector-largest")
	     (:file "sort-vector")
	     (:file "sort-vector-smallest-index")
	     (:file "sort-vector-smallest")
	     (:file "spherical-vector")
	     (:file "svd")
	     (:file "swap-columns")
	     (:file "swap-elements")
	     (:file "swap-row-column")
	     (:file "swap-rows")
	     (:file "synchrotron")
	     (:file "tdist")
	     (:file "transport")
	     (:file "trigonometry")
	     (:file "vector-div")
	     (:file "vector-max-index")
	     (:file "vector-max")
	     (:file "vector-mean")
	     (:file "vector-min")
	     (:file "vector-min-index")
	     (:file "vector-minmax-index")
	     (:file "vector-minmax")
	     (:file "vector-sub")
	     (:file "vector-add")
	     (:file "vector-mult")
	     (:file "vector-reverse")
	     (:file "vector-set-all")
	     (:file "vector-set-zero")
	     (:file "vector-standard-deviation")
	     (:file "vector-standard-deviation-with-fixed-mean")
	     (:file "vector-standard-deviation-with-mean")
	     (:file "vector-swap")
	     (:file "vector-variance")
	     (:file "vector-variance-with-fixed-mean")
	     (:file "vector-variance-with-mean")
	     (:file "weibull")
	     (:file "zeta")))))