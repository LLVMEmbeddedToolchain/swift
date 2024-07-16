#ifndef TEST_INTEROP_CXX_STDLIB_INPUTS_STD_SPAN_H
#define TEST_INTEROP_CXX_STDLIB_INPUTS_STD_SPAN_H

#include <cstddef>
#include <string>
#include <span>

using ConstSpan = std::span<const int>;
using Span = std::span<int>;
using ConstSpanOfString = std::span<const std::string>;
using SpanOfString = std::span<std::string>;

// TODO remove this code
class CppApi {
public:
  ConstSpan getConstSpan();
  Span getSpan();
};

ConstSpan CppApi::getConstSpan() {
  ConstSpan sp{new int[2], 2};
  return sp;
}

Span CppApi::getSpan() {
  Span sp{new int[2], 2};
  return sp;
}

static int icarray[]{1, 2, 3};
static int iarray[]{1, 2, 3};
static std::string sarray[]{"", "ab", "abc"};
static ConstSpan icspan = {icarray};
static Span ispan = {iarray};
static SpanOfString sspan = {sarray};

inline ConstSpan initConstSpan() {
  const int a[]{1, 2, 3};
  return ConstSpan(a);
}

inline Span initSpan() {
  int a[]{1, 2, 3};
  return Span(a);
}

#endif // TEST_INTEROP_CXX_STDLIB_INPUTS_STD_SPAN_H
