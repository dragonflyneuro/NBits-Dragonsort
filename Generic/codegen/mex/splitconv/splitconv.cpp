//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  splitconv.cpp
//
//  Code generation for function 'splitconv'
//


// Include files
#include "splitconv.h"
#include "indexShapeCheck.h"
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "splitconv_data.h"
#include "tconv.h"

// Variable Definitions
static emlrtRSInfo emlrtRSI = { 21,    // lineNo
  "splitconv",                         // fcnName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pathName
};

static emlrtRSInfo b_emlrtRSI = { 22,  // lineNo
  "splitconv",                         // fcnName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pathName
};

static emlrtRSInfo c_emlrtRSI = { 25,  // lineNo
  "splitconv",                         // fcnName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pathName
};

static emlrtBCInfo emlrtBCI = { -1,    // iFirst
  -1,                                  // iLast
  19,                                  // lineNo
  12,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo b_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  19,                                  // lineNo
  22,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo c_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  19,                                  // lineNo
  25,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo d_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  20,                                  // lineNo
  12,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo e_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  20,                                  // lineNo
  22,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo f_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  20,                                  // lineNo
  25,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo g_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  21,                                  // lineNo
  32,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo h_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  25,                                  // lineNo
  20,                                  // colNo
  "daf",                               // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo i_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  25,                                  // lineNo
  22,                                  // colNo
  "daf",                               // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo j_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  25,                                  // lineNo
  33,                                  // colNo
  "dbf",                               // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo k_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  25,                                  // lineNo
  40,                                  // colNo
  "dbf",                               // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo l_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  25,                                  // lineNo
  7,                                   // colNo
  "y",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtECInfo emlrtECI = { -1,    // nDims
  25,                                  // lineNo
  5,                                   // colNo
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pName
};

static emlrtBCInfo m_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  21,                                  // lineNo
  27,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtBCInfo n_emlrtBCI = { -1,  // iFirst
  -1,                                  // iLast
  22,                                  // lineNo
  27,                                  // colNo
  "d",                                 // aName
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m",// pName
  0                                    // checkKind
};

static emlrtRTEInfo e_emlrtRTEI = { 16,// lineNo
  1,                                   // colNo
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pName
};

static emlrtRTEInfo f_emlrtRTEI = { 19,// lineNo
  10,                                  // colNo
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pName
};

static emlrtRTEInfo g_emlrtRTEI = { 21,// lineNo
  5,                                   // colNo
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pName
};

static emlrtRTEInfo h_emlrtRTEI = { 20,// lineNo
  10,                                  // colNo
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pName
};

static emlrtRTEInfo i_emlrtRTEI = { 22,// lineNo
  5,                                   // colNo
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pName
};

static emlrtRTEInfo j_emlrtRTEI = { 25,// lineNo
  15,                                  // colNo
  "splitconv",                         // fName
  "F:\\GitHub\\Dragonsort\\Generic\\splitconv.m"// pName
};

// Function Definitions
void splitconv(const emlrtStack *sp, const coder::array<real_T, 2U> &d, const
               coder::array<real_T, 2U> &f, coder::array<real_T, 2U> &y)
{
  uint32_T unnamed_idx_0;
  uint32_T unnamed_idx_1;
  int32_T loop_ub;
  int32_T i;
  int32_T dmid;
  int32_T b_loop_ub;
  int32_T c_loop_ub;
  coder::array<real_T, 2U> c_d;
  coder::array<real_T, 2U> daf;
  coder::array<real_T, 2U> dbf;
  int32_T iv[2];
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);

  //
  //  convolution with minimized edge artifacts
  //  assumes length(d) >> length(f)
  //
  // IN: d = time series (vector)
  //     f = kernel
  //
  // OUT: y = filtered d
  //
  //  AL, janelia; 11/09
  //
  // y = splitconv(d,f)
  //
  unnamed_idx_0 = static_cast<uint32_T>(d.size(0));
  unnamed_idx_1 = static_cast<uint32_T>(d.size(1));
  y.set_size((&e_emlrtRTEI), sp, (static_cast<int32_T>(unnamed_idx_0)), (
              static_cast<int32_T>(unnamed_idx_1)));
  loop_ub = static_cast<int32_T>(unnamed_idx_0) * static_cast<int32_T>
    (unnamed_idx_1);
  for (i = 0; i < loop_ub; i++) {
    y[i] = 0.0;
  }

  i = d.size(0);
  if (0 <= i - 1) {
    dmid = static_cast<int32_T>(muDoubleScalarRound(static_cast<real_T>(d.size(0))
      / 2.0));
    b_loop_ub = d.size(1);
    c_loop_ub = d.size(1);
  }

  for (int32_T ii = 0; ii < i; ii++) {
    int32_T i1;
    real_T b_d;
    int32_T i2;
    int32_T d_loop_ub;
    int32_T i3;
    if (1 > d.size(1)) {
      emlrtDynamicBoundsCheckR2012b(1, 1, d.size(1), &c_emlrtBCI, sp);
    }

    i1 = ii + 1;
    if ((i1 < 1) || (i1 > d.size(0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, d.size(0), &emlrtBCI, sp);
    }

    i1 = ii + 1;
    if ((i1 < 1) || (i1 > d.size(0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, d.size(0), &b_emlrtBCI, sp);
    }

    i1 = ii + 1;
    if ((i1 < 1) || (i1 > d.size(0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, d.size(0), &d_emlrtBCI, sp);
    }

    i1 = ii + 1;
    if ((i1 < 1) || (i1 > d.size(0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, d.size(0), &e_emlrtBCI, sp);
    }

    if (d.size(1) < 1) {
      emlrtDynamicBoundsCheckR2012b(d.size(1), 1, d.size(1), &f_emlrtBCI, sp);
    }

    if (1 > d.size(1)) {
      emlrtDynamicBoundsCheckR2012b(1, 1, d.size(1), &g_emlrtBCI, sp);
    }

    b_d = d[ii];
    c_d.set_size((&f_emlrtRTEI), sp, 1, d.size(1));
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      c_d[i1] = d[ii + d.size(0) * i1] - b_d;
    }

    st.site = &emlrtRSI;
    tconv(&st, c_d, f, daf);
    i1 = daf.size(0) * daf.size(1);
    daf.set_size((&g_emlrtRTEI), sp, 1, daf.size(1));
    i2 = ii + 1;
    if ((i2 < 1) || (i2 > d.size(0))) {
      emlrtDynamicBoundsCheckR2012b(i2, 1, d.size(0), &m_emlrtBCI, sp);
    }

    b_d = d[i2 - 1];
    loop_ub = i1 - 1;
    for (i1 = 0; i1 <= loop_ub; i1++) {
      daf[i1] = daf[i1] + b_d;
    }

    b_d = d[ii + d.size(0) * (d.size(1) - 1)];
    c_d.set_size((&h_emlrtRTEI), sp, 1, d.size(1));
    for (i1 = 0; i1 < c_loop_ub; i1++) {
      c_d[i1] = d[ii + d.size(0) * i1] - b_d;
    }

    st.site = &b_emlrtRSI;
    tconv(&st, c_d, f, dbf);
    i1 = dbf.size(0) * dbf.size(1);
    dbf.set_size((&i_emlrtRTEI), sp, 1, dbf.size(1));
    i2 = ii + 1;
    if ((i2 < 1) || (i2 > d.size(0))) {
      emlrtDynamicBoundsCheckR2012b(i2, 1, d.size(0), &n_emlrtBCI, sp);
    }

    if (d.size(1) < 1) {
      emlrtDynamicBoundsCheckR2012b(d.size(1), 1, d.size(1), &n_emlrtBCI, sp);
    }

    b_d = d[(i2 + d.size(0) * (d.size(1) - 1)) - 1];
    loop_ub = i1 - 1;
    for (i1 = 0; i1 <= loop_ub; i1++) {
      dbf[i1] = dbf[i1] + b_d;
    }

    if (1 > dmid) {
      loop_ub = 0;
    } else {
      if (1 > daf.size(1)) {
        emlrtDynamicBoundsCheckR2012b(1, 1, daf.size(1), &h_emlrtBCI, sp);
      }

      if (dmid > daf.size(1)) {
        emlrtDynamicBoundsCheckR2012b(dmid, 1, daf.size(1), &i_emlrtBCI, sp);
      }

      loop_ub = dmid;
    }

    iv[0] = 1;
    iv[1] = loop_ub;
    st.site = &c_emlrtRSI;
    indexShapeCheck(&st, daf.size(1), iv);
    if (dmid + 1 > dbf.size(1)) {
      i1 = 0;
      i2 = 0;
    } else {
      i1 = dmid + 1;
      if ((i1 < 1) || (i1 > dbf.size(1))) {
        emlrtDynamicBoundsCheckR2012b(i1, 1, dbf.size(1), &j_emlrtBCI, sp);
      }

      i1--;
      if (dbf.size(1) < 1) {
        emlrtDynamicBoundsCheckR2012b(dbf.size(1), 1, dbf.size(1), &k_emlrtBCI,
          sp);
      }

      i2 = dbf.size(1);
    }

    iv[0] = 1;
    d_loop_ub = i2 - i1;
    iv[1] = d_loop_ub;
    st.site = &c_emlrtRSI;
    indexShapeCheck(&st, dbf.size(1), iv);
    i3 = ii + 1;
    if ((i3 < 1) || (i3 > y.size(0))) {
      emlrtDynamicBoundsCheckR2012b(i3, 1, y.size(0), &l_emlrtBCI, sp);
    }

    c_d.set_size((&j_emlrtRTEI), sp, 1, ((loop_ub + i2) - i1));
    for (i2 = 0; i2 < loop_ub; i2++) {
      c_d[i2] = daf[i2];
    }

    for (i2 = 0; i2 < d_loop_ub; i2++) {
      c_d[i2 + loop_ub] = dbf[i1 + i2];
    }

    iv[0] = 1;
    iv[1] = y.size(1);
    emlrtSubAssignSizeCheckR2012b(&iv[0], 2, c_d.size(), 2, &emlrtECI, sp);
    loop_ub = c_d.size(1);
    for (i1 = 0; i1 < loop_ub; i1++) {
      y[ii + y.size(0) * i1] = c_d[i1];
    }

    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(sp);
    }
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

// End of code generation (splitconv.cpp)
