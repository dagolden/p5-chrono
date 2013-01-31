#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define NEED_sv_2pv_flags
#include "ppport.h"
#include "chrono.h"

typedef int64_t I64V;

#if IVSIZE >= 8
# define SvI64V(sv)         (I64V)SvIV(sv)
# define newSVi64v(i64)     newSViv((IV)i64)
# define XSRETURN_I64V(i64) XSRETURN_IV((IV)i64)
#else
# define SvI64V(sv)         (I64V)SvNV(sv)
# define newSVi64v(i64)     newSVnv((NV)i64)
# define XSRETURN_I64V(i64) XSRETURN_NV((NV)i64)
#endif

#ifndef STR_WITH_LEN
#define STR_WITH_LEN(s)  ("" s ""), (sizeof(s)-1)
#endif

#ifndef gv_stashpvs
#define gv_stashpvs(s, flags) gv_stashpvn(STR_WITH_LEN(s), flags)
#endif

#ifndef XSRETURN_BOOL
#define XSRETURN_BOOL(v) STMT_START { ST(0) = boolSV(v); XSRETURN(1); } STMT_END
#endif

#define MY_CXT_KEY "Chrono::_guts" XS_VERSION
typedef struct {
    HV *stash_date;
    HV *stash_time;
    HV *stash_datetime;
    HV *stash_duration;
} my_cxt_t;

START_MY_CXT

static void
setup_my_cxt(pTHX_ pMY_CXT) {
    MY_CXT.stash_date     = gv_stashpvs("Chrono::Date", GV_ADD);
    MY_CXT.stash_time     = gv_stashpvs("Chrono::Time", GV_ADD);
    MY_CXT.stash_datetime = gv_stashpvs("Chrono::DateTime", GV_ADD);
    MY_CXT.stash_duration = gv_stashpvs("Chrono::Duration", GV_ADD);
}

static SV *
THX_newSVchrono_date(pTHX_ const chrono_date_t *d, HV *stash) {
    SV *pv = newSVpvn((const char *)d, sizeof(chrono_date_t));
    SV *sv = newRV_noinc(pv);
    sv_bless(sv, stash);
    SvREADONLY_on(pv);
    return sv;
}

static SV *
THX_newSVchrono_time(pTHX_ const chrono_time_t *t, HV *stash) {
    SV *pv = newSVpvn((const char *)t, sizeof(chrono_time_t));
    SV *sv = newRV_noinc(pv);
    sv_bless(sv, stash);
    SvREADONLY_on(pv);
    return sv;
}

static SV *
THX_newSVchrono_datetime(pTHX_ const chrono_datetime_t *dt, HV *stash) {
    SV *pv = newSVpvn((const char *)dt, sizeof(chrono_datetime_t));
    SV *sv = newRV_noinc(pv);
    sv_bless(sv, stash);
    SvREADONLY_on(pv);
    return sv;
}

static SV *
THX_newSVchrono_duration(pTHX_ const chrono_duration_t *d, HV *stash) {
    SV *pv = newSVpvn((const char *)d, sizeof(chrono_duration_t));
    SV *sv = newRV_noinc(pv);
    sv_bless(sv, stash);
    SvREADONLY_on(pv);
    return sv;
}

static bool
THX_sv_isa_chrono(pTHX_ SV *sv, const char *klass, HV *stash) {
    SV *rv;

    SvGETMAGIC(sv);
    if (!SvROK(sv))
        return FALSE;
    rv = SvRV(sv);
    if (!(SvOBJECT(rv) && SvSTASH(rv) && SvPOKp(rv)))
        return FALSE;
    if (!(SvSTASH(rv) == stash || sv_derived_from(sv, klass)))
        return FALSE;
    return TRUE;
}

static bool
THX_sv_isa_chrono_date(pTHX_ SV *sv) {
    dMY_CXT;
    return THX_sv_isa_chrono(aTHX_ sv, "Chrono::Date", MY_CXT.stash_date);
}

static bool
THX_sv_isa_chrono_time(pTHX_ SV *sv) {
    dMY_CXT;
    return THX_sv_isa_chrono(aTHX_ sv, "Chrono::Time", MY_CXT.stash_time);
}

static bool
THX_sv_isa_chrono_datetime(pTHX_ SV *sv) {
    dMY_CXT;
    return THX_sv_isa_chrono(aTHX_ sv, "Chrono::DateTime", MY_CXT.stash_datetime);
}

static bool
THX_sv_isa_chrono_duration(pTHX_ SV *sv) {
    dMY_CXT;
    return THX_sv_isa_chrono(aTHX_ sv, "Chrono::Duration", MY_CXT.stash_duration);
}

static chrono_date_t
THX_sv_2chrono_date(pTHX_ SV *sv, const char *name) {
    if (!THX_sv_isa_chrono_date(aTHX_ sv))
        croak("%s is not an instance of Chrono::Date", name);
    return *(const chrono_date_t *)SvPVX(SvRV(sv));
}

static chrono_time_t
THX_sv_2chrono_time(pTHX_ SV *sv, const char *name) {
    if (!THX_sv_isa_chrono_time(aTHX_ sv))
        croak("%s is not an instance of Chrono::Time", name);
    return *(const chrono_time_t *)SvPVX(SvRV(sv));
}

static chrono_datetime_t
THX_sv_2chrono_datetime(pTHX_ SV *sv, const char *name) {
    if (!THX_sv_isa_chrono_datetime(aTHX_ sv))
        croak("%s is not an instance of Chrono::DateTime", name);
    return *(const chrono_datetime_t *)SvPVX(SvRV(sv));
}

static chrono_duration_t
THX_sv_2chrono_duration(pTHX_ SV *sv, const char *name) {
    if (!THX_sv_isa_chrono_duration(aTHX_ sv))
        croak("%s is not an instance of Chrono::Duration", name);
    return *(const chrono_duration_t *)SvPVX(SvRV(sv));
}

static HV *
THX_stash_constructor(pTHX_ SV *sv, const char *name, STRLEN namelen, HV *stash) {
    const char *pv;
    STRLEN len;

    SvGETMAGIC(sv);
    if (SvROK(sv)) {
        SV * const rv = SvRV(sv);
        if (SvOBJECT(rv) && SvSTASH(rv))
            return SvSTASH(rv);
    }
    pv = SvPV_nomg_const(sv, len);
    if (len == namelen && memEQ(pv, name, namelen))
        return stash;
    return gv_stashpvn(pv, len, GV_ADD);
}

#define dSTASH_CONSTRUCTOR(sv, name, dstash) \
    HV * const stash = THX_stash_constructor(aTHX_ sv, STR_WITH_LEN(name), dstash)

#define dSTASH_CONSTRUCTOR_DATE(sv) \
    dMY_CXT; \
    dSTASH_CONSTRUCTOR(sv, "Chrono::Date", MY_CXT.stash_date)

#define dSTASH_CONSTRUCTOR_TIME(sv) \
    dMY_CXT; \
    dSTASH_CONSTRUCTOR(sv, "Chrono::Time", MY_CXT.stash_time)

#define dSTASH_CONSTRUCTOR_DATETIME(sv) \
    dMY_CXT; \
    dSTASH_CONSTRUCTOR(sv, "Chrono::DateTime", MY_CXT.stash_datetime)

#define dSTASH_CONSTRUCTOR_DURATION(sv) \
    dMY_CXT; \
    dSTASH_CONSTRUCTOR(sv, "Chrono::Duration", MY_CXT.stash_duration)

#define dSTASH_INVOCANT \
    HV * const stash = SvSTASH(SvRV(ST(0)))

#define dSTASH_DATE \
    dMY_CXT; \
    HV * const stash = MY_CXT.stash_date

#define dSTASH_TIME \
    dMY_CXT; \
    HV * const stash = MY_CXT.stash_time

#define dSTASH_DATETIME \
    dMY_CXT; \
    HV * const stash = MY_CXT.stash_datetime

#define dSTASH_DURATION \
    dMY_CXT; \
    HV * const stash = MY_CXT.stash_duration

#define newSVchrono_date(d, stash) \
    THX_newSVchrono_date(aTHX_ d, stash)

#define newSVchrono_time(t, stash) \
    THX_newSVchrono_time(aTHX_ t, stash)

#define newSVchrono_datetime(d, stash) \
    THX_newSVchrono_datetime(aTHX_ d, stash)

#define newSVchrono_duration(d, stash) \
    THX_newSVchrono_duration(aTHX_ d, stash)

#define sv_isa_chrono_date(sv) \
    THX_sv_isa_chrono_date(aTHX_ sv)

#define sv_isa_chrono_time(sv) \
    THX_sv_isa_chrono_time(aTHX_ sv)

#define sv_isa_chrono_datetime(sv) \
    THX_sv_isa_chrono_datetime(aTHX_ sv)

#define sv_isa_chrono_duration(sv) \
    THX_sv_isa_chrono_duration(aTHX_ sv)

#define sv_2chrono_date(sv, name) \
    THX_sv_2chrono_date(aTHX_ sv, name)

#define sv_2chrono_time(sv, name) \
    THX_sv_2chrono_time(aTHX_ sv, name)

#define sv_2chrono_datetime(sv, name) \
    THX_sv_2chrono_datetime(aTHX_ sv, name)

#define sv_2chrono_duration(sv, name) \
    THX_sv_2chrono_duration(aTHX_ sv, name)

XS(XS_Chrono_nil) {
    dXSARGS;
    PERL_UNUSED_VAR(items);
    XSRETURN_EMPTY;
}

XS(XS_Chrono_Date_stringify) {
    dXSARGS;
    if (items < 1)
        croak("Wrong number of arguments to Chrono::Date::(\"\"");
    ST(0) = chrono_date_to_string(sv_2chrono_date(ST(0), "self"));
    XSRETURN(1);
}

XS(XS_Chrono_Time_stringify) {
    dXSARGS;
    if (items < 1)
        croak("Wrong number of arguments to Chrono::Time::(\"\"");
    ST(0) = chrono_time_to_string(sv_2chrono_time(ST(0), "self"), 6);
    XSRETURN(1);
}

XS(XS_Chrono_DateTime_stringify) {
    dXSARGS;
    if (items < 1)
        croak("Wrong number of arguments to Chrono::DateTime::(\"\"");
    ST(0) = chrono_datetime_to_string(sv_2chrono_datetime(ST(0), "self"), 6);
    XSRETURN(1);
}

XS(XS_Chrono_Date_cmp) {
    dXSARGS;
    chrono_date_t lhs, rhs;
    IV res;
    if (items < 3)
        croak("Wrong number of arguments to Chrono::Date::(<=>");
    lhs = sv_2chrono_date(ST(0), "self");
    if (cBOOL(SvTRUE(ST(2)))) {
        rhs = sv_2chrono_date(ST(1), "left-hand side");
        res = chrono_date_compare(rhs, lhs);
    }
    else {
        rhs = sv_2chrono_date(ST(1), "right-hand side");
        res = chrono_date_compare(lhs, rhs);
    }
    XSRETURN_IV(res);
}

XS(XS_Chrono_Time_cmp) {
    dXSARGS;
    chrono_time_t lhs, rhs;
    IV res;
    if (items < 3)
        croak("Wrong number of arguments to Chrono::Time::(<=>");
    lhs = sv_2chrono_time(ST(0), "self");
    if (cBOOL(SvTRUE(ST(2)))) {
        rhs = sv_2chrono_time(ST(1), "left-hand side");
        res = chrono_time_compare(rhs, lhs);
    }
    else {
        rhs = sv_2chrono_time(ST(1), "right-hand side");
        res = chrono_time_compare(lhs, rhs);
    }
    XSRETURN_IV(res);
}

XS(XS_Chrono_DateTime_cmp) {
    dXSARGS;
    chrono_datetime_t lhs, rhs;
    IV res;
    if (items < 3)
        croak("Wrong number of arguments to Chrono::DateTime::(<=>");
    lhs = sv_2chrono_datetime(ST(0), "self");
    if (cBOOL(SvTRUE(ST(2)))) {
        rhs = sv_2chrono_datetime(ST(1), "left-hand side");
        res = chrono_datetime_compare(rhs, lhs);
    }
    else {
        rhs = sv_2chrono_datetime(ST(1), "right-hand side");
        res = chrono_datetime_compare(lhs, rhs);
    }
    XSRETURN_IV(res);
}

MODULE = Chrono   PACKAGE = Chrono

PROTOTYPES: DISABLE

BOOT:
{
    MY_CXT_INIT;
    setup_my_cxt(aTHX_ aMY_CXT);
#if (PERL_REVISION == 5 && PERL_VERSION < 9)
    PL_amagic_generation++;
#endif
    sv_setsv(get_sv("Chrono::Date::()", GV_ADD), &PL_sv_yes);
    sv_setsv(get_sv("Chrono::Time::()", GV_ADD), &PL_sv_yes);
    sv_setsv(get_sv("Chrono::DateTime::()", GV_ADD), &PL_sv_yes);
    newXS("Chrono::Date::()", XS_Chrono_nil, file);
    newXS("Chrono::Date::(\"\"", XS_Chrono_Date_stringify, file);
    newXS("Chrono::Date::(<=>", XS_Chrono_Date_cmp, file);
    newXS("Chrono::Time::()", XS_Chrono_nil, file);
    newXS("Chrono::Time::(\"\"", XS_Chrono_Time_stringify, file);
    newXS("Chrono::Time::(<=>", XS_Chrono_Time_cmp, file);
    newXS("Chrono::DateTime::()", XS_Chrono_nil, file);
    newXS("Chrono::DateTime::(\"\"", XS_Chrono_DateTime_stringify, file);
    newXS("Chrono::DateTime::(<=>", XS_Chrono_DateTime_cmp, file);
}

#ifdef USE_ITHREADS

void
CLONE(...)
CODE:
{
    MY_CXT_CLONE;
    setup_my_cxt(aTHX_ aMY_CXT);
    PERL_UNUSED_VAR(items);
}

#endif

INCLUDE: Date.xsh
INCLUDE: Time.xsh
INCLUDE: DateTime.xsh
INCLUDE: Duration.xsh
