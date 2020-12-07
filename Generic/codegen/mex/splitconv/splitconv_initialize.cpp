//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  splitconv_initialize.cpp
//
//  Code generation for function 'splitconv_initialize'
//


// Include files
#include "splitconv_initialize.h"
#include "_coder_splitconv_mex.h"
#include "rt_nonfinite.h"
#include "splitconv.h"
#include "splitconv_data.h"

// Function Definitions
void splitconv_initialize()
{
  emlrtStack st = { NULL,              // site
    NULL,                              // tls
    NULL                               // prev
  };

  mex_InitInfAndNan();
  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

// End of code generation (splitconv_initialize.cpp)
