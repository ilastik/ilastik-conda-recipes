#include <math.h>
#include <complex.h>
#include <stdio.h>

double trunc_( double t );
long lround_( double t );
float cabsf_(float complex x);
float complex csqrtf_(float complex x);
double complex csqrt_(double complex x);
double complex cexp_(double complex x);
double complex clog_(double complex x);
double complex ccos_(double complex x);
double complex csin_(double complex x);
double complex cpow_(double complex x, double complex y);

int main()
{
    float  complex fc = 3.0 + 4.0i;
    double complex dc = 3.0 - 4.0i, dcr1, dcr2, de = 0.5;
    
    printf("%f %f\n", trunc_(-1.23), trunc(-1.23));
    printf("%d %d\n", lround_(-1.23), lround(-1.23));
    printf("%f %f\n", cabsf_(fc), cabsf(fc));
    
    dcr1 = csqrt_(dc);
    dcr2 = csqrt(dc);
    printf("%f + %fi,  %f + %fi\n", creal(dcr1), cimag(dcr1), creal(dcr2), cimag(dcr2));
    
    dcr1 = clog_(dc);
    dcr2 = clog(dc);
    printf("%f + %fi,  %f + %fi\n", creal(dcr1), cimag(dcr1), creal(dcr2), cimag(dcr2));
    
    dcr1 = cexp_(dc);
    dcr2 = cexp(dc);
    printf("%f + %fi,  %f + %fi\n", creal(dcr1), cimag(dcr1), creal(dcr2), cimag(dcr2));
    
    dcr1 = ccos_(dc);
    dcr2 = ccos(dc);
    printf("%f + %fi,  %f + %fi\n", creal(dcr1), cimag(dcr1), creal(dcr2), cimag(dcr2));
    
    dcr1 = csin_(dc);
    dcr2 = csin(dc);
    printf("%f + %fi,  %f + %fi\n", creal(dcr1), cimag(dcr1), creal(dcr2), cimag(dcr2));
    
    dcr1 = cpow_(dc, de);
    dcr2 = cpow(dc, de);
    printf("%f + %fi,  %f + %fi\n", creal(dcr1), cimag(dcr1), creal(dcr2), cimag(dcr2));
}