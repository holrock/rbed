#include "ruby.h"
#include <stdio.h>
#include <string.h>
#include <errno.h>

static VALUE cBed = Qnil;

enum {
  NUM_BIT_PER_INDIV = 2,
  INDIV_PER_BYTE    = 4,
  BYTE_LEN          = 8
};

typedef struct Bed {
  long num_indiv;
  long num_snps;
  long bytes_per_snp;
  size_t nbytes;
  unsigned char* genotypes;
} Bed;

static
void bed_free(Bed* bed)
{
  if (bed) {
    if (bed->genotypes) {
      ruby_xfree(bed->genotypes);
    }
    ruby_xfree(bed);
  }
}

static
VALUE bed_alloc(VALUE cls)
{
  Bed* bed = NULL;
  return Data_Make_Struct(cls, Bed, 0, bed_free, bed);
}

static
VALUE bed_init(VALUE self, VALUE num_snps, VALUE num_indiv)
{
  Bed* bed = NULL;
  Data_Get_Struct(self, Bed, bed);
  bed->genotypes = NULL;
  bed->num_snps = NUM2LONG(num_snps);
  bed->num_indiv = NUM2LONG(num_indiv);
  bed->nbytes = 0;

  long nbits = bed->num_indiv * NUM_BIT_PER_INDIV;
  bed->bytes_per_snp = nbits / BYTE_LEN;
  if (nbits % BYTE_LEN) {
    bed->bytes_per_snp += 1;
  }
  return Qnil;
}

static
VALUE bed_get_num_snps(VALUE self)
{
  Bed* bed = NULL;
  Data_Get_Struct(self, Bed, bed);
  return LONG2NUM(bed->num_snps);
}

static
VALUE bed_get_num_indiv(VALUE self)
{
  Bed* bed = NULL;
  Data_Get_Struct(self, Bed, bed);
  return LONG2NUM(bed->num_indiv);
}

static
int is_magic_bytes(char* bytes)
{
  return bytes[0] == 0x6c && bytes[1] == 0x1b;
}

struct load_bed_file_arg{
  Bed* bed;
  FILE* fp;
  size_t fsize;
};

static
VALUE load_bed_file(VALUE data)
{
  struct load_bed_file_arg* arg = (struct load_bed_file_arg*)data;
  Bed* bed = arg->bed;
  FILE* fp = arg->fp;
  size_t fsize = arg->fsize;

  if (bed->genotypes) {
    ruby_xfree(bed->genotypes);
    bed->genotypes = NULL;
    bed->nbytes = 0;
  }

  const char* errmsg = NULL;
  VALUE exception;

  char magic[3];
  size_t nread = fread(magic, sizeof(unsigned char), 3, fp);
  if (nread != 3) {
    errmsg = "can't load file";
    exception = rb_eIOError;
    goto FAIL;
  }

  if (!is_magic_bytes(magic)) {
    errmsg = "not BED file";
    exception = rb_eRuntimeError;
    goto FAIL;
  }
  if (magic[2] != 0x1) {
    errmsg = "Unspport major mode";
    exception = rb_eRuntimeError;
    goto FAIL;
  }

  fsize -= 3;
  bed->genotypes = ruby_xmalloc(sizeof(unsigned char) * fsize);
  nread = fread(bed->genotypes, sizeof(unsigned char), fsize, fp);
  if (nread != fsize) {
    errmsg = "can't load file";
    exception = rb_eIOError;
    goto FAIL;
  }
  bed->nbytes = nread;

FAIL:
  if (errmsg) {
    ruby_xfree(bed->genotypes);
    bed->genotypes = NULL;
    rb_raise(exception, "%s", errmsg);
  }
  return Qnil;
}

static
VALUE ensure_load_bed_file(VALUE data2)
{
  struct load_bed_file_arg* arg = (struct load_bed_file_arg*)data2;
  if (arg->fp)
    fclose(arg->fp);
  return Qnil;
}

static
VALUE bed_load(VALUE self, VALUE arg)
{
  Check_Type(arg, T_STRING);
  VALUE vsize = rb_funcall(rb_cFile, rb_intern("size"), 1, arg);
  size_t fsize = NUM2SIZET(vsize);

  char* fname = RSTRING_PTR(arg);
  FILE* fp = fopen(fname, "rb");
  if (!fp) {
    VALUE e = INT2FIX(errno);
    rb_exc_raise(rb_class_new_instance(1, &e, rb_eSystemCallError));
  }
  Bed* bed = NULL;
  Data_Get_Struct(self, Bed, bed);

  struct load_bed_file_arg data1;
  data1.bed = bed;
  data1.fp = fp;
  data1.fsize = fsize;
  rb_ensure(load_bed_file, (VALUE)&data1, ensure_load_bed_file, (VALUE)&data1);

  return Qnil;
}

static
long get_byte_index(Bed* bed, long snp_index, long indiv_index)
{
  if (snp_index < 0 || snp_index >= bed->num_snps) {
    rb_raise(rb_eIndexError, "snp_index out of range");
  }
  if (indiv_index < 0 || indiv_index >= bed->num_indiv) {
    rb_raise(rb_eIndexError, "indiv_index out of range");
  }

  long i = snp_index * bed->bytes_per_snp;
  if (indiv_index >= INDIV_PER_BYTE)
    i += 1;
  return i;
}

static
VALUE bed_genotype(VALUE self, VALUE snp_index, VALUE indiv_index)
{
  Bed* bed = NULL;
  Data_Get_Struct(self, Bed, bed);

  long snp_i = NUM2LONG(snp_index);
  long indiv_i = NUM2LONG(indiv_index);
  long index = get_byte_index(bed, snp_i, indiv_i); 
  unsigned char c = bed->genotypes[index];

  if (indiv_i >= INDIV_PER_BYTE)
    indiv_i -= INDIV_PER_BYTE;

  int g = c >> (indiv_i << 1) & 0x03;
  if (g < 0 || g > 3) {
    rb_raise(rb_eIndexError, "genotype out of range");
  }
  return INT2FIX(g);
}

static
VALUE bed_c_ext(void)
{
  return Qtrue;
}

static
VALUE bed_each(VALUE self)
{
  Bed* bed = NULL;
  Data_Get_Struct(self, Bed, bed);

  for (size_t i = 0; i < bed->nbytes; i += bed->bytes_per_snp) {
    size_t num_indiv = bed->num_indiv;
    VALUE ary = rb_ary_new2(num_indiv);
    size_t total_indiv = 0;

    for (size_t j = 0; j < bed->bytes_per_snp; ++j) {
      unsigned char c = bed->genotypes[i  + j];

      for (size_t indiv = 0; indiv < INDIV_PER_BYTE; ++indiv) {
        int g = c >> (indiv << 1) & 0x03;
        rb_ary_push(ary, INT2FIX(g));
        ++total_indiv;
        if (total_indiv >= bed->num_indiv)
          break;
      }

    }
    rb_yield(ary);
  }
  return Qnil;
}

void Init_bed(void)
{
  VALUE modBR = rb_const_get(rb_cObject, rb_intern("Rbed"));
  cBed = rb_define_class_under(modBR, "Bed", rb_cObject);
  rb_include_module(cBed, rb_const_get(rb_cObject, rb_intern("Enumerable")));

  rb_define_alloc_func(cBed, bed_alloc);

  rb_define_method(cBed, "initialize", bed_init, 2);
  rb_define_method(cBed, "num_snps", bed_get_num_snps, 0);
  rb_define_method(cBed, "num_individuals", bed_get_num_indiv, 0);
  rb_define_method(cBed, "load", bed_load, 1);
  rb_define_method(cBed, "genotype", bed_genotype, 2);
  rb_define_method(cBed, "c_ext?", bed_c_ext, 0);
  rb_define_method(cBed, "each", bed_each, 0);

  rb_define_const(cBed, "Homo1", INT2FIX(0));
  rb_define_const(cBed, "Hetero", INT2FIX(2));
  rb_define_const(cBed, "Homo2", INT2FIX(3));
  rb_define_const(cBed, "Missing", INT2FIX(1));
}
