/*
 * Student License - for use by students to meet course requirements and
 * perform academic research at degree granting institutions only.  Not
 * for government, commercial, or other organizational use.
 *
 * _coder_kalman02_api.c
 *
 * Code generation for function '_coder_kalman02_api'
 *
 */

/* Include files */
#include "tmwtypes.h"
#include "_coder_kalman02_api.h"
#include "_coder_kalman02_mex.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;
emlrtContext emlrtContextGlobal = { true,/* bFirstTime */
  false,                               /* bInitialized */
  131450U,                             /* fVersionInfo */
  NULL,                                /* fErrorFunction */
  "kalman02",                          /* fFunctionName */
  NULL,                                /* fRTCallStack */
  false,                               /* bDebugMode */
  { 2045744189U, 2170104910U, 2743257031U, 4284093946U },/* fSigWrd */
  NULL                                 /* fSigMem */
};

/* Function Declarations */
static real_T (*b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId))[2];
static real_T (*c_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *
  msgId))[2];
static real_T (*emlrt_marshallIn(const mxArray *z, const char_T *identifier))[2];
static const mxArray *emlrt_marshallOut(const real_T u[2]);

/* Function Definitions */
static real_T (*b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId))[2]
{
  real_T (*y)[2];
  y = c_emlrt_marshallIn(emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}
  static real_T (*c_emlrt_marshallIn(const mxArray *src, const
  emlrtMsgIdentifier *msgId))[2]
{
  real_T (*ret)[2];
  static const int32_T dims[1] = { 2 };

  emlrtCheckBuiltInR2012b(emlrtRootTLSGlobal, msgId, src, "double", false, 1U,
    dims);
  ret = (real_T (*)[2])mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real_T (*emlrt_marshallIn(const mxArray *z, const char_T *identifier))[2]
{
  real_T (*y)[2];
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(emlrtAlias(z), &thisId);
  emlrtDestroyArray(&z);
  return y;
}
  static const mxArray *emlrt_marshallOut(const real_T u[2])
{
  const mxArray *y;
  const mxArray *m0;
  static const int32_T iv0[1] = { 0 };

  static const int32_T iv1[1] = { 2 };

  y = NULL;
  m0 = emlrtCreateNumericArray(1, iv0, mxDOUBLE_CLASS, mxREAL);
  mxSetData((mxArray *)m0, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m0, iv1, 1);
  emlrtAssign(&y, m0);
  return y;
}

void kalman02_api(const mxArray * const prhs[1], const mxArray *plhs[1])
{
  real_T (*y)[2];
  real_T (*z)[2];
  y = (real_T (*)[2])mxMalloc(sizeof(real_T [2]));

  /* Marshall function inputs */
  z = emlrt_marshallIn(emlrtAlias(prhs[0]), "z");

  /* Invoke the target function */
  kalman02(*z, *y);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(*y);
}

void kalman02_atexit(void)
{
  mexFunctionCreateRootTLS();
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtLeaveRtStackR2012b(emlrtRootTLSGlobal);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  kalman02_xil_terminate();
}

void kalman02_initialize(void)
{
  mexFunctionCreateRootTLS();
  emlrtClearAllocCountR2012b(emlrtRootTLSGlobal, false, 0U, 0);
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

void kalman02_terminate(void)
{
  emlrtLeaveRtStackR2012b(emlrtRootTLSGlobal);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (_coder_kalman02_api.c) */
