// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// betampt
List betampt(int M, arma::mat H, arma::mat a, arma::mat b, arma::vec c, arma::vec map, arma::vec shape, arma::vec rate);
RcppExport SEXP TreeBUGS_betampt(SEXP MSEXP, SEXP HSEXP, SEXP aSEXP, SEXP bSEXP, SEXP cSEXP, SEXP mapSEXP, SEXP shapeSEXP, SEXP rateSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type M(MSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type H(HSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type a(aSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type b(bSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type c(cSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type map(mapSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type shape(shapeSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type rate(rateSEXP);
    rcpp_result_gen = Rcpp::wrap(betampt(M, H, a, b, c, map, shape, rate));
    return rcpp_result_gen;
END_RCPP
}
// simplempt
List simplempt(int M, arma::mat H, arma::mat a, arma::mat b, arma::vec c, arma::vec map, arma::vec alpha, arma::vec beta);
RcppExport SEXP TreeBUGS_simplempt(SEXP MSEXP, SEXP HSEXP, SEXP aSEXP, SEXP bSEXP, SEXP cSEXP, SEXP mapSEXP, SEXP alphaSEXP, SEXP betaSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type M(MSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type H(HSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type a(aSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type b(bSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type c(cSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type map(mapSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type alpha(alphaSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type beta(betaSEXP);
    rcpp_result_gen = Rcpp::wrap(simplempt(M, H, a, b, c, map, alpha, beta));
    return rcpp_result_gen;
END_RCPP
}
// loglikMPT
arma::vec loglikMPT(arma::mat theta, arma::vec h, arma::mat a, arma::mat b, arma::vec c, arma::vec map);
RcppExport SEXP TreeBUGS_loglikMPT(SEXP thetaSEXP, SEXP hSEXP, SEXP aSEXP, SEXP bSEXP, SEXP cSEXP, SEXP mapSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::mat >::type theta(thetaSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type h(hSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type a(aSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type b(bSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type c(cSEXP);
    Rcpp::traits::input_parameter< arma::vec >::type map(mapSEXP);
    rcpp_result_gen = Rcpp::wrap(loglikMPT(theta, h, a, b, c, map));
    return rcpp_result_gen;
END_RCPP
}
