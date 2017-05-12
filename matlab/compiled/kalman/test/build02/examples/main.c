/*
 * Student License - for use by students to meet course requirements and
 * perform academic research at degree granting institutions only.  Not
 * for government, commercial, or other organizational use.
 *
 * main.c
 *
 * Code generation for function 'main'
 *
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/
/* Include files */
#include "rt_nonfinite.h"
#include "kalman02.h"
#include "main.h"
#include "kalman02_terminate.h"
#include "kalman02_initialize.h"

/* Function Declarations */
static void argInit_2x1_real_T(double result[2]);
static double argInit_real_T(void);
static void main_kalman02(void);

/* Function Definitions */
static void argInit_2x1_real_T(double result[2])
{
  int idx0;

  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 2; idx0++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx0] = argInit_real_T();
  }
}

static double argInit_real_T(void)
{
  return 0.0;
}

static void main_kalman02(void)
{
  double dv0[2];
  double y[2];

  /* Initialize function 'kalman02' input arguments. */
  /* Initialize function input argument 'z'. */
  /* Call the entry-point 'kalman02'. */
  argInit_2x1_real_T(dv0);
  kalman02(dv0, y);
}

int main(int argc, const char * const argv[])
{
  (void)argc;
  (void)argv;

  /* Initialize the application.
     You do not need to do this more than one time. */
  kalman02_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_kalman02();

  /* Terminate the application.
     You do not need to do this more than one time. */
  kalman02_terminate();
  return 0;
}

/* End of code generation (main.c) */
