#include "Rmath.h"
#include <complex.h>

double complex erfz(double complex z);
double complex erfi(double complex z);


double complex erfz(double complex z)
/*******************************************************************************
  
  Evalutaes the error function for a complex argument. Based on the Fortran
  subroutine CERROR.

  Licensing:

    The original Fortran routine CERROR is copyrighted by Shanjie Zhang and
    Jianming Jin.  However, they give permission to incorporate this routine
    into a user program provided that the copyright is acknowledged.

  Modified:
  
    26 July 2017

  Author:
  
    Kjell P. Konis

  Authors of original Fortran subroutine:

    Shanjie Zhang and Jianming Jin

  Reference:

    Shanjie Zhang and Jianming Jin,
    Computation of Special Functions,
    Wiley, 1996,
    ISBN: 0-471-11963-6,
    LC: QA351.C45.

*******************************************************************************/
{
  double a0 = 0.0;
  double complex c0 = 0.0 + 0.0*I,
                 cer = 0.0 + 0.0*I,
                 cl = 0.0 + 0.0*I,
                 cr = 0.0 + 0.0*I,
                 cs = 0.0 + 0.0*I,
                 z1 = 0.0 + 0.0*I;
  int k = -1;

  a0 = cabs(z);
  c0 = cexp(-z*z);
  z1 = z;

  if(creal(z) < 0.0 )
    z1 = -z;

  if(a0 <= 5.8) {

    cs = z1;
    cr = z1;
    for(k = 1; k <= 120; k++) {
      cr = cr * z1 * z1 / (0.5 + k);
      cs = cs + cr;
      if(cabs(cr/cs) < 1.0e-15)
        break;
    }

    cer = c0 * cs * M_2_SQRTPI;
    
  } else {

    cl = 1.0 / z1;
    cr = cl;
    for(k = 1; k <= 13; k++) {
      cr = -cr * (k - 0.5) / (z1*z1);
      cl = cl + cr;
      if(cabs(cr/cl) < 1.0e-15)
        break;
    }

    cer = 1.0 - c0 * cl / M_SQRT_PI;

  }

  if(creal(z) < 0.0)
    cer = -cer;

  return(cer);
}


double complex erfi(double complex z)
{
  return(-I*erfz(I*z));
}




