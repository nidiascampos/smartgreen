/*
 * Student License - for use by students to meet course requirements and
 * perform academic research at degree granting institutions only.  Not
 * for government, commercial, or other organizational use.
 *
 * _coder_kalman02_api.h
 *
 * Code generation for function '_coder_kalman02_api'
 *
 */

#ifndef _CODER_KALMAN02_API_H
#define _CODER_KALMAN02_API_H

/* Include files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_kalman02_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void kalman02(real_T z[2], real_T y[2]);
extern void kalman02_api(const mxArray * const prhs[1], const mxArray *plhs[1]);
extern void kalman02_atexit(void);
extern void kalman02_initialize(void);
extern void kalman02_terminate(void);
extern void kalman02_xil_terminate(void);

#endif

/* End of code generation (_coder_kalman02_api.h) */
