
// RUN: rm -rf %t
// RUN: split-file %s %t
// RUN: %target-swift-frontend -typecheck -verify -I %swift_src_root/lib/ClangImporter/SwiftBridging -Xcc -std=c++20 -I %t/Inputs  %t/test.swift -enable-experimental-feature AllowUnsafeAttribute -enable-experimental-feature WarnUnsafe  -enable-experimental-feature SafeInterop -enable-experimental-feature LifetimeDependence -cxx-interoperability-mode=default -diagnostic-style llvm 2>&1

// REQUIRES: objc_interop
// REQUIRES: swift_feature_AllowUnsafeAttribute
// REQUIRES: swift_feature_SafeInterop
// REQUIRES: swift_feature_WarnUnsafe
// REQUIRES: swift_feature_LifetimeDependence

//--- Inputs/module.modulemap
module Test {
    header "nonescapable.h"
    requires cplusplus
}

//--- Inputs/nonescapable.h
#include "swift/bridging"
#include <span>

struct SWIFT_NONESCAPABLE View {
    __attribute__((swift_attr("@lifetime(immortal)")))
    View() : member(nullptr) {}
    __attribute__((swift_attr("@lifetime(p)")))
    View(const int *p [[clang::lifetimebound]]) : member(p) {}
    View(const View&) = default;
private:
    const int *member;
};

struct SWIFT_ESCAPABLE Owner {};

struct Unannotated {
    Unannotated();
};

struct SWIFT_UNSAFE_REFERENCE UnsafeReference {};

struct SafeEscapableAggregate {
    int a;
    float b[5];
};

struct UnknownEscapabilityAggregate {
    SafeEscapableAggregate agg;
    Unannotated unann;
};

struct MyContainer {
    int begin() const { return 0; }
    int end() const { return -1; }
};

using SpanOfInt = Unannotated;
using SpanOfIntAlias = SpanOfInt;

//--- test.swift

import Test
import CoreFoundation

// expected-note@+1{{make global function 'useUnsafeParam' @unsafe to indicate that its use is not memory-safe}}{{1-1=@unsafe }}
func useUnsafeParam(x: Unannotated) { // expected-warning{{reference to unsafe struct 'Unannotated'}}
}

// expected-note@+2{{make global function 'useUnsafeParam2' @unsafe to indicate that its use is not memory-safe}}{{10:1-1=@unsafe }}
@available(SwiftStdlib 5.8, *)
func useUnsafeParam2(x: UnsafeReference) { // expected-warning{{reference to unsafe class 'UnsafeReference'}}
}

// expected-note@+1{{make global function 'useUnsafeParam3' @unsafe to indicate that its use is not memory-safe}}{{1-1=@unsafe }}
func useUnsafeParam3(x: UnknownEscapabilityAggregate) { // expected-warning{{reference to unsafe struct 'UnknownEscapabilityAggregate'}}
}

// expected-note@+1{{make global function 'useSafeParams' @safe(unchecked) to allow it to use unsafe constructs in its definition}}{{1-1=@safe(unchecked) }}
func useSafeParams(x: Owner, y: View, z: SafeEscapableAggregate, c: MyContainer) {
    let _ = c.__beginUnsafe() // expected-warning{{call to unsafe instance method '__beginUnsafe'}}
}

func useCfType(x: CFArray) {
}

// expected-note@+1{{make global function 'useCppSpan' @unsafe to indicate that its use is not memory-safe}}
func useCppSpan(x: SpanOfInt) { // expected-warning{{reference to unsafe type alias 'SpanOfInt'}}
}

// expected-note@+1{{make global function 'useCppSpan2' @unsafe to indicate that its use is not memory-safe}}
func useCppSpan2(x: SpanOfIntAlias) { // expected-warning{{reference to unsafe type alias 'SpanOfIntAlias'}}
}
