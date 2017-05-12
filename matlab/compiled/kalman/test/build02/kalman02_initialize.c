/*
 * Student License - for use by students to meet course requirements and
 * perform academic research at degree granting institutions only.  Not
 * for government, commercial, or other organizational use.
 *
 * kalman02_initialize.c
 *
 * Code generation for function 'kalman02_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "kalman02.h"
#include "kalman02_initialize.h"

/* Function Definitions */
void kalman02_initialize(void)
{
  rt_InitInfAndNaN(8U);
  kalman02_init();
}

/* End of code generation (kalman02_initialize.c) */
