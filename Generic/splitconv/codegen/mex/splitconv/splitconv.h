//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  splitconv.h
//
//  Code generation for function 'splitconv'
//


#pragma once

// Include files
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "splitconv_types.h"

// Function Declarations
CODEGEN_EXPORT_SYM void splitconv(const emlrtStack *sp, const coder::array<
  real_T, 2U> &d, const coder::array<real_T, 2U> &f, coder::array<real_T, 2U> &y);

// End of code generation (splitconv.h)
