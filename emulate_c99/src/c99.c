// emulate some C99 functions that are missing in MSVC

#define _CRTIMP
#include <math.h>

typedef struct { float re, im; }  fcomplex;
typedef struct { double re, im; } dcomplex;

#ifdef TESTING
# define NAME(n) n##_  // change function name so that we can compare with their real C99 counterparts
#include <complex.h>
typedef double complex native_complex;
#else
# define NAME(n) n
typedef struct _complex native_complex;
#endif

double NAME(asinh)( double t )
{
     return log(t + sqrt(t * t + 1.0));
}

double NAME(trunc)( double t )
{
     return t >= 0.0
                ? floor(t + 0.5)
                : ceil(t - 0.5);
}

long NAME(lround)( double t )
{
     return t >= 0.0
                ? (long)floor(t + 0.5)
                : (long)ceil(t - 0.5);
}

long NAME(lroundf)( float t )
{
     return t >= 0.0
                ? (long)floor(t + 0.5)
                : (long)ceil(t - 0.5);
}

float NAME(cabsf)(fcomplex x)
{
    double absa = fabs(x.re);
    double absb = fabs(x.im);
    if (absa > absb) 
    {
        double s = absb/absa;
        return (float)(absa * sqrt(1.0 + s*s)); 
    }
    else if (absb == 0.0)
    {
        return 0.0f;
    }
    else
    {
        double s = absa/absb;
        return (float)(absb * sqrt(1.0 + s*s)); 
    }
}

double NAME(cabs)(native_complex x)
{
#ifdef TESTING
    double absa = fabs(creal(x));
    double absb = fabs(cimag(x));
#else
    double absa = fabs(x.x);
    double absb = fabs(x.y);
#endif
    if (absa > absb) 
    {
        double s = absb/absa;
        return absa * sqrt(1.0 + s*s); 
    }
    else if (absb == 0.0)
    {
        return 0.0;
    }
    else
    {
        double s = absa/absb;
        return absb * sqrt(1.0 + s*s); 
    }
}

fcomplex NAME(csqrtf)(fcomplex x)
{
    fcomplex r;

    if (x.re == 0.0f)
    {
        r.re = (float)sqrt(0.5 * fabs(x.im));
        r.im = x.im < 0.0f ? -r.re : r.re;
    }
    else
    {
        float __t = (float)sqrt(2.0 * (NAME(cabsf)(x) + fabs(x.re)));
        float __u = 0.5f * __t;
        if (x.re > 0.0f)
        {
            r.re = __u;
            r.im = x.im / __t;
        }
        else
        {
            r.re = (float)fabs(x.im) / __t;
            r.im = x.im < 0.0f ? -__u : __u;
        }
    }
    return r;
}

dcomplex NAME(csqrt)(dcomplex x)
{
    dcomplex r;

    if (x.re == 0.0)
    {
        r.re = sqrt(0.5 * fabs(x.im));
        r.im = x.im < 0.0 ? -r.re : r.re;
    }
    else
    {
        double __t = sqrt(2.0 * (_cabs(*(native_complex *)&x) + fabs(x.re)));
        double __u = 0.5 * __t;
        if (x.re > 0.0)
        {
            r.re = __u;
            r.im = x.im / __t;
        }
        else
        {
            r.re = fabs(x.im) / __t;
            r.im = x.im < 0.0 ? -__u : __u;
        }
    }
    return r;
}

dcomplex NAME(cexp)(dcomplex x)
{
    double c = exp(x.re);
    dcomplex r;
    r.re = c*cos(x.im);
    r.im = c*sin(x.im);
    return r;
}

dcomplex NAME(clog)(dcomplex x)
{
    dcomplex r;
    r.re = log(_cabs(*(native_complex *)&x));
    r.im = atan2(x.im, x.re);
    return r;
}

dcomplex NAME(ccos)(dcomplex x)
{
    dcomplex r;
    r.re = cos(x.re)*cosh(x.im);
    r.im = -sin(x.re)*sinh(x.im);
    return r;
}

dcomplex NAME(csin)(dcomplex x)
{
    dcomplex r;
    r.re = sin(x.re)*cosh(x.im);
    r.im = cos(x.re)*sinh(x.im);
    return r;
}

dcomplex NAME(cpow)(dcomplex x, dcomplex y)
{
    dcomplex r;
    if(x.re == 0.0 && x.im == 0.0)
        return x;
    x = NAME(clog)(x);
    r.re = x.re*y.re - x.im*y.im;
    r.im = x.re*y.im + x.im*y.re;
    return NAME(cexp)(r);
}
