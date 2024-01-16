//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  _coder_splitconv_mex.cpp
//
//  Code generation for function '_coder_splitconv_mex'
//


// Include files
#include "_coder_splitconv_mex.h"
#include "_coder_splitconv_api.h"
#include "splitconv.h"
#include "splitconv_data.h"
#include "splitconv_initialize.h"
#include "splitconv_terminate.h"

// Function Declarations
MEXFUNCTION_LINKAGE void splitconv_mexFunction(int32_T nlhs, mxArray *plhs[1],
  int32_T nrhs, const mxArray *prhs[2]);

// Function Definitions
void splitconv_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs, const
  mxArray *prhs[2])
{
  const mxArray *outputs[1];
  emlrtStack st = { NULL,              // site
    NULL,                              // tls
    NULL                               // prev
  };

  st.tls = emlrtRootTLSGlobal;

  // Check for proper number of arguments.
  if (nrhs != 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 2, 4, 9,
                        "splitconv");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 9,
                        "splitconv");
  }

  // Call the function.
  splitconv_api(prhs, nlhs, outputs);

  // Copy over outputs to the caller.
  emlrtReturnArrays(1, plhs, &outputs[0]);
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(&splitconv_atexit);

  // Module initialization.
  splitconv_initialize();

  // Dispatch the entry-point.
  splitconv_mexFunction(nlhs, plhs, nrhs, prhs);

  // Module termination.
  splitconv_terminate();
}

emlrtCTX mexFunctionCreateRootTLS()
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

// End of code generation (_coder_splitconv_mex.cpp)
