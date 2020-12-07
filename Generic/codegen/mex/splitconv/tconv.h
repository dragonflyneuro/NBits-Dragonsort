//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  tconv.h
//
//  Code generation for function 'tconv'
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
void tconv(const emlrtStack *sp, const coder::array<real_T, 2U> &data, const
           coder::array<real_T, 2U> &kernel, coder::array<real_T, 2U> &dnew);

// End of code generation (tconv.h)
