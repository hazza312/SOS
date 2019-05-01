#include <stddef.h>

#define PAGE_SIZE 4096
#define KERN_PAGES 0 // Number of pages required for kernel, change if necessary
typedef unsigned long ptr_t;


// debug printers
extern void put_str(char* string);
extern void x86_vm_dump_pages(void);

// Map npages of (consecutive) pages and return virtual mapped address of the first page
// Returns NULL on failure
ptr_t *page_alloc(size_t npages);

// Free the page mapped at virtual address ptr
void page_free(ptr_t *ptr);
static size_t memsize;


void assert(int b)
{
    if (b)
      return;
    
    // TODO: print error message
    put_str(".. test failed");
    /* Cause a breakpoint exception. */
    while (1)
        asm volatile("int3");
}

void assert_page_contents(char *p, char c)
{
  for (int i = 0; i < PAGE_SIZE; i++) {
    assert(p[i] == c);
  }
}

void *memset(void *s, int c, size_t n)
{
    unsigned char* p=s;
    while(n--)
        *p++ = (unsigned char)c;
    return s;
}



// Init memory subsystem with sz bytes of memory
void init_mem(size_t sz)
{
  memsize = sz;
  // Do other init stuff
}



void test_alloc_easy()
{
  size_t npages = memsize / PAGE_SIZE;
  size_t nsample = npages - 1 < PAGE_SIZE / sizeof(void *) ? npages - 1 : PAGE_SIZE / sizeof(void *);

  // Keep track of allocated pages
  ptr_t **p = (ptr_t **)page_alloc(1);

  // Allocate a bunch of pages
  for (int i = 0; i < nsample / 3; i++) {
    p[i] = page_alloc(1);
    assert(p[i] != NULL);
  }

  // Free pages
  for (int i = 0; i < nsample / 3; i++) {
    page_free(p[i]);
  }

  page_free((ptr_t*)p);
}

void test_alloc_advanced()
{
  size_t npages = memsize / PAGE_SIZE;

  assert(npages > 0);

  // Keep track of allocated pages
  ptr_t **p = (ptr_t **)page_alloc(1);

  size_t nsample = npages - 1 < PAGE_SIZE / sizeof(void *) ? npages - 1 : PAGE_SIZE / sizeof(void *);

  // Allocate one page worth of pointers
  for (int i = 0; i < nsample; i++) {
    p[i] = page_alloc(1);
    assert(p[i] != NULL);
  }

  // Write to pages
  for (int i = 0; i < nsample; i++) {
    char *ptr = (char *)p[i];
    char v = 0x42 + i % 256;
    memset(ptr, v, PAGE_SIZE);
  }

  // Free even pages
  for (int i = 0; i < nsample; i += 2) {
    char v = 0x42 + i % 256;
    assert_page_contents((char *)p[i], v);
    page_free(p[i]);
  }

  // Free odd pages
  for (int i = 1; i < nsample; i += 2) {
    char v = 0x42 + i % 256;
    assert_page_contents((char *)p[i], v);
    page_free(p[i]);
  }

  page_free((ptr_t*)p);

}


void test_alloc_oom()
{
  size_t npages = memsize / PAGE_SIZE;
  size_t nsample = npages - KERN_PAGES;

  // Keep track of allocated pages
  ptr_t **p = (ptr_t **)page_alloc((npages  * sizeof(ptr_t) + PAGE_SIZE -1) / PAGE_SIZE);

  // Allocate all the pages
  int allocated = 0;
  for (int i = 0; i < nsample; i++) {
    p[i] = page_alloc(1);
    if (p[i]) {
      memset(p[i], 0x42, PAGE_SIZE);
      allocated++;
    }
  }

  // print: allocated `allocated` pages
  //assert(allocated >= npages - KERN_PAGES);

  // Free all allocated pages
  for (int i = 0; i < nsample; i++) {
    if (p[i])
      page_free(p[i]);

    //if (i != 0 && (i % PAGE_SIZE == 0))
    //  page_free((ptr_t*) &p[i]);
  }

}


void test_all()
{
  //Memory alloc
  put_str("[TC] Attempting easy test........");
  test_alloc_easy();
  put_str(".. passed\n");

  put_str("[TC] Attempting advanced test....");
  test_alloc_advanced();
  put_str(".. passed\n");

  put_str("[TC] Attempting OOM test.........");
  test_alloc_oom();
  put_str(".. passed\n");
}
