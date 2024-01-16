//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  tconv.cpp
//
//  Code generation for function 'tconv'
//


// Include files
#include "tconv.h"
#include "anyNonFinite.h"
#include "blas.h"
#include "eml_int_forloop_overflow_check.h"
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "splitconv.h"
#include "splitconv_data.h"

// Variable Definitions
static emlrtRSInfo d_emlrtRSI = { 23,  // lineNo
  "tconv",                             // fcnName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m"// pathName
};

static emlrtRSInfo e_emlrtRSI = { 25,  // lineNo
  "tconv",                             // fcnName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m"// pathName
};

static emlrtRSInfo f_emlrtRSI = { 57,  // lineNo
  "conv",                              // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pathName 
};

static emlrtRSInfo g_emlrtRSI = { 48,  // lineNo
  "conv",                              // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pathName 
};

static emlrtRSInfo h_emlrtRSI = { 45,  // lineNo
  "conv",                              // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pathName 
};

static emlrtRSInfo i_emlrtRSI = { 44,  // lineNo
  "conv",                              // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pathName 
};

static emlrtRSInfo n_emlrtRSI = { 109, // lineNo
  "convFull",                          // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pathName 
};

static emlrtRSInfo o_emlrtRSI = { 113, // lineNo
  "convFull",                          // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pathName 
};

static emlrtRSInfo p_emlrtRSI = { 110, // lineNo
  "convFull",                          // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pathName 
};

static emlrtRSInfo q_emlrtRSI = { 114, // lineNo
  "convFull",                          // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pathName 
};

static emlrtRSInfo r_emlrtRSI = { 61,  // lineNo
  "xaxpy",                             // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xaxpy.m"// pathName 
};

static emlrtRSInfo s_emlrtRSI = { 60,  // lineNo
  "xaxpy",                             // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xaxpy.m"// pathName 
};

static emlrtRSInfo t_emlrtRSI = { 14,  // lineNo
  "max",                               // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\max.m"// pathName 
};

static emlrtRSInfo u_emlrtRSI = { 44,  // lineNo
  "minOrMax",                          // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"// pathName 
};

static emlrtRSInfo v_emlrtRSI = { 79,  // lineNo
  "maximum",                           // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"// pathName 
};

static emlrtRSInfo w_emlrtRSI = { 145, // lineNo
  "unaryMinOrMax",                     // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"// pathName 
};

static emlrtRSInfo x_emlrtRSI = { 1019,// lineNo
  "maxRealVectorOmitNaN",              // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"// pathName 
};

static emlrtRSInfo y_emlrtRSI = { 932, // lineNo
  "minOrMaxRealVector",                // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"// pathName 
};

static emlrtRSInfo ab_emlrtRSI = { 924,// lineNo
  "minOrMaxRealVector",                // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"// pathName 
};

static emlrtRSInfo bb_emlrtRSI = { 975,// lineNo
  "findFirst",                         // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"// pathName 
};

static emlrtRSInfo cb_emlrtRSI = { 992,// lineNo
  "minOrMaxRealVectorKernel",          // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"// pathName 
};

static emlrtRSInfo db_emlrtRSI = { 41, // lineNo
  "find",                              // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\elmat\\find.m"// pathName 
};

static emlrtRSInfo eb_emlrtRSI = { 153,// lineNo
  "eml_find",                          // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\elmat\\find.m"// pathName 
};

static emlrtRSInfo fb_emlrtRSI = { 377,// lineNo
  "find_first_indices",                // fcnName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\elmat\\find.m"// pathName 
};

static emlrtDCInfo emlrtDCI = { 99,    // lineNo
  17,                                  // colNo
  "convFull",                          // fName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m",// pName 
  4                                    // checkKind
};

static emlrtBCInfo o_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  26,                                  // lineNo
  17,                                  // colNo
  "fmax",                              // aName
  "tconv",                             // fName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo p_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  30,                                  // lineNo
  13,                                  // colNo
  "dnew",                              // aName
  "tconv",                             // fName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo q_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  30,                                  // lineNo
  18,                                  // colNo
  "dnew",                              // aName
  "tconv",                             // fName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m",// pName
  0                                    // checkKind
};

static emlrtRTEInfo emlrtRTEI = { 95,  // lineNo
  27,                                  // colNo
  "unaryMinOrMax",                     // fName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"// pName 
};

static emlrtRTEInfo b_emlrtRTEI = { 79,// lineNo
  1,                                   // colNo
  "convFull",                          // fName
  "C:\\Program Files\\MATLAB\\R2020a\\toolbox\\eml\\lib\\matlab\\datafun\\conv.m"// pName 
};

static emlrtRTEInfo k_emlrtRTEI = { 23,// lineNo
  1,                                   // colNo
  "tconv",                             // fName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m"// pName
};

static emlrtRTEInfo l_emlrtRTEI = { 25,// lineNo
  17,                                  // colNo
  "tconv",                             // fName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m"// pName
};

static emlrtRTEInfo m_emlrtRTEI = { 30,// lineNo
  8,                                   // colNo
  "tconv",                             // fName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m"// pName
};

static emlrtRTEInfo n_emlrtRTEI = { 30,// lineNo
  1,                                   // colNo
  "tconv",                             // fName
  "F:\\GitHub\\Dragonsort\\Generic\\tconv.m"// pName
};

// Function Definitions
void tconv(const emlrtStack *sp, const coder::array<real_T, 2U> &data, const
           coder::array<real_T, 2U> &kernel, coder::array<real_T, 2U> &dnew)
{
  int32_T nA;
  int32_T nApnB;
  int32_T nC;
  int32_T k;
  ptrdiff_t n_t;
  ptrdiff_t incx_t;
  ptrdiff_t incy_t;
  real_T ex;
  boolean_T exitg1;
  coder::array<boolean_T, 2U> x;
  int32_T ii_data[1];
  uint32_T fmax_data[1];
  uint32_T u;
  coder::array<real_T, 2U> b_dnew;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
  emlrtStack j_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &st;
  c_st.tls = st.tls;
  d_st.prev = &b_st;
  d_st.tls = b_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  i_st.prev = &h_st;
  i_st.tls = h_st.tls;
  j_st.prev = &i_st;
  j_st.tls = i_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);

  //
  //  conv data with kernel and compensate for time-shift
  //  induced by convolution
  //
  //  length(dnew) = length(data)
  //
  //  assume kernel center is at max unless cmid=1
  //
  // IN: data = time series to be convolved
  //    kernel = convolution kernel
  //    cmid = assume middle of kernel is center (ie for derivative)
  //           use cmid = 0 for standard spectral filtering
  //
  // OUT: dnew = convolved, time-shifted data
  //      fmax = center of kernel
  //
  //  AL, Caltech, 8/00
  //
  //  [dnew,fmax] = tconv(data,kernel,cmid)
  //
  st.site = &d_emlrtRSI;
  b_st.site = &i_emlrtRSI;
  c_st.site = &h_emlrtRSI;
  if (anyNonFinite(&b_st, data) || anyNonFinite(&c_st, kernel)) {
    int32_T nB;
    b_st.site = &g_emlrtRSI;
    nA = data.size(1) - 1;
    nB = kernel.size(1) - 1;
    nApnB = data.size(1) + kernel.size(1);
    if ((data.size(1) == 0) || (kernel.size(1) == 0)) {
      nC = nApnB;
    } else {
      nC = nApnB - 1;
    }

    if (nC > nApnB) {
      emlrtErrorWithMessageIdR2018a(&b_st, &b_emlrtRTEI,
        "Coder:builtins:AssertionFailed", "Coder:builtins:AssertionFailed", 0);
    }

    dnew.set_size((&k_emlrtRTEI), (&b_st), 1, dnew.size(1));
    if (nC < 0) {
      emlrtNonNegativeCheckR2012b(static_cast<real_T>(nC), &emlrtDCI, &b_st);
    }

    dnew.set_size((&k_emlrtRTEI), (&b_st), dnew.size(0), nC);
    for (k = 0; k < nC; k++) {
      dnew[k] = 0.0;
    }

    if ((data.size(1) > 0) && (kernel.size(1) > 0)) {
      if (kernel.size(1) > data.size(1)) {
        d_st.site = &n_emlrtRSI;
        for (k = 0; k <= nA; k++) {
          for (nC = 0; nC <= nB; nC++) {
            nApnB = k + nC;
            dnew[nApnB] = dnew[nApnB] + data[k] * kernel[nC];
          }
        }
      } else {
        d_st.site = &o_emlrtRSI;
        if (kernel.size(1) > 2147483646) {
          e_st.site = &m_emlrtRSI;
          check_forloop_overflow_error(&e_st);
        }

        for (k = 0; k <= nB; k++) {
          for (nC = 0; nC <= nA; nC++) {
            nApnB = k + nC;
            dnew[nApnB] = dnew[nApnB] + kernel[k] * data[nC];
          }
        }
      }
    }
  } else {
    int32_T nB;
    b_st.site = &f_emlrtRSI;
    nA = data.size(1);
    nB = kernel.size(1);
    nApnB = data.size(1) + kernel.size(1);
    if ((data.size(1) == 0) || (kernel.size(1) == 0)) {
      nC = nApnB;
    } else {
      nC = nApnB - 1;
    }

    if (nC > nApnB) {
      emlrtErrorWithMessageIdR2018a(&b_st, &b_emlrtRTEI,
        "Coder:builtins:AssertionFailed", "Coder:builtins:AssertionFailed", 0);
    }

    dnew.set_size((&k_emlrtRTEI), (&b_st), 1, dnew.size(1));
    if (nC < 0) {
      emlrtNonNegativeCheckR2012b(static_cast<real_T>(nC), &emlrtDCI, &b_st);
    }

    dnew.set_size((&k_emlrtRTEI), (&b_st), dnew.size(0), nC);
    for (k = 0; k < nC; k++) {
      dnew[k] = 0.0;
    }

    if ((data.size(1) > 0) && (kernel.size(1) > 0)) {
      if (kernel.size(1) > data.size(1)) {
        d_st.site = &n_emlrtRSI;
        for (k = 0; k < nA; k++) {
          d_st.site = &p_emlrtRSI;
          e_st.site = &s_emlrtRSI;
          e_st.site = &r_emlrtRSI;
          n_t = (ptrdiff_t)nB;
          incx_t = (ptrdiff_t)1;
          incy_t = (ptrdiff_t)1;
          daxpy(&n_t, &data[k], &kernel[0], &incx_t, &dnew[k], &incy_t);
        }
      } else {
        d_st.site = &o_emlrtRSI;
        if (kernel.size(1) > 2147483646) {
          e_st.site = &m_emlrtRSI;
          check_forloop_overflow_error(&e_st);
        }

        for (k = 0; k < nB; k++) {
          d_st.site = &q_emlrtRSI;
          e_st.site = &s_emlrtRSI;
          e_st.site = &r_emlrtRSI;
          n_t = (ptrdiff_t)nA;
          incx_t = (ptrdiff_t)1;
          incy_t = (ptrdiff_t)1;
          daxpy(&n_t, &kernel[k], &data[0], &incx_t, &dnew[k], &incy_t);
        }
      }
    }
  }

  st.site = &e_emlrtRSI;
  b_st.site = &t_emlrtRSI;
  d_st.site = &u_emlrtRSI;
  e_st.site = &v_emlrtRSI;
  if (kernel.size(1) < 1) {
    emlrtErrorWithMessageIdR2018a(&e_st, &emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  f_st.site = &w_emlrtRSI;
  g_st.site = &x_emlrtRSI;
  nC = kernel.size(1);
  if (kernel.size(1) <= 2) {
    if (kernel.size(1) == 1) {
      ex = kernel[0];
    } else if ((kernel[0] < kernel[1]) || (muDoubleScalarIsNaN(kernel[0]) &&
                (!muDoubleScalarIsNaN(kernel[1])))) {
      ex = kernel[1];
    } else {
      ex = kernel[0];
    }
  } else {
    h_st.site = &ab_emlrtRSI;
    if (!muDoubleScalarIsNaN(kernel[0])) {
      nA = 1;
    } else {
      nA = 0;
      i_st.site = &bb_emlrtRSI;
      if (kernel.size(1) > 2147483646) {
        j_st.site = &m_emlrtRSI;
        check_forloop_overflow_error(&j_st);
      }

      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= kernel.size(1))) {
        if (!muDoubleScalarIsNaN(kernel[k - 1])) {
          nA = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }

    if (nA == 0) {
      ex = kernel[0];
    } else {
      h_st.site = &y_emlrtRSI;
      ex = kernel[nA - 1];
      nApnB = nA + 1;
      i_st.site = &cb_emlrtRSI;
      if ((nA + 1 <= kernel.size(1)) && (kernel.size(1) > 2147483646)) {
        j_st.site = &m_emlrtRSI;
        check_forloop_overflow_error(&j_st);
      }

      for (k = nApnB; k <= nC; k++) {
        real_T d;
        d = kernel[k - 1];
        if (ex < d) {
          ex = d;
        }
      }
    }
  }

  st.site = &e_emlrtRSI;
  x.set_size((&l_emlrtRTEI), (&st), 1, kernel.size(1));
  nApnB = kernel.size(0) * kernel.size(1);
  for (k = 0; k < nApnB; k++) {
    x[k] = (kernel[k] == ex);
  }

  b_st.site = &db_emlrtRSI;
  d_st.site = &eb_emlrtRSI;
  nA = 0;
  nApnB = 1;
  e_st.site = &fb_emlrtRSI;
  if (x.size(1) > 2147483646) {
    f_st.site = &m_emlrtRSI;
    check_forloop_overflow_error(&f_st);
  }

  nC = 0;
  exitg1 = false;
  while ((!exitg1) && (nC <= x.size(1) - 1)) {
    if (x[nC]) {
      nA = 1;
      ii_data[0] = nC + 1;
      exitg1 = true;
    } else {
      nC++;
    }
  }

  if (nA == 0) {
    nApnB = 0;
  }

  if (0 <= nApnB - 1) {
    fmax_data[0] = static_cast<uint32_T>(ii_data[0]);
  }

  if (1 > nApnB) {
    emlrtDynamicBoundsCheckR2012b(1, 1, 0, &o_emlrtBCI, sp);
  }

  u = (fmax_data[0] + data.size(1)) - 1U;
  if (fmax_data[0] > u) {
    k = 0;
    nC = 0;
  } else {
    if ((static_cast<int32_T>(fmax_data[0]) < 1) || (static_cast<int32_T>
         (fmax_data[0]) > dnew.size(1))) {
      emlrtDynamicBoundsCheckR2012b(static_cast<int32_T>(fmax_data[0]), 1,
        dnew.size(1), &p_emlrtBCI, sp);
    }

    k = static_cast<int32_T>(fmax_data[0]) - 1;
    if ((static_cast<int32_T>(u) < 1) || (static_cast<int32_T>(u) > dnew.size(1)))
    {
      emlrtDynamicBoundsCheckR2012b(static_cast<int32_T>(u), 1, dnew.size(1),
        &q_emlrtBCI, sp);
    }

    nC = static_cast<int32_T>(u);
  }

  nApnB = nC - k;
  b_dnew.set_size((&m_emlrtRTEI), sp, 1, nApnB);
  for (nC = 0; nC < nApnB; nC++) {
    b_dnew[nC] = dnew[k + nC];
  }

  dnew.set_size((&n_emlrtRTEI), sp, 1, b_dnew.size(1));
  nApnB = b_dnew.size(0) * b_dnew.size(1);
  for (k = 0; k < nApnB; k++) {
    dnew[k] = b_dnew[k];
  }

  //  recenter even-length (non-symmetric) filter with cmid centering)
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

// End of code generation (tconv.cpp)
