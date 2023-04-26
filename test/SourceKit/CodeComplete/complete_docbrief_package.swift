// RUN: %empty-directory(%t)
// RUN: %empty-directory(%t/Modules)
// RUN: split-file %s %t

// RUN: %target-swift-frontend \
// RUN:     -emit-module \
// RUN:     -module-name DocBriefTest \
// RUN:     -package-name DocPackage \
// RUN:     -emit-module-path %t/Modules/DocBriefTest.swiftmodule \
// RUN:     -emit-module-source-info-path %t/Modules/DocBriefTest.swiftsourceinfo \
// RUN:     %t/Module.swift

//--- Module.swift
package protocol P {
  /// This is a doc comment of P.foo
  ///
  /// Do whatever.
  func foo()
}

package struct S: P {
  public init() {}
  public func foo() {}
}

//--- User.swift
package import DocBriefTest

func test() {
  S().foo()
}

// RUN: %sourcekitd-test -req=complete -pos=4:7 %t/User.swift -- %t/User.swift -I %t/Modules -target %target-triple -module-name DocBriefUser -package-name DocPackage -enable-experimental-feature AccessLevelOnImport | %FileCheck %s -check-prefix=CHECK

// CHECK: {
// CHECK:   key.results: [
// CHECK-NEXT:     {
// CHECK-NEXT:       key.kind: source.lang.swift.decl.function.method.instance,
// CHECK-NEXT:       key.name: "foo()",
// CHECK-NEXT:       key.sourcetext: "foo()",
// CHECK-NEXT:       key.description: "foo()",
// CHECK-NEXT:       key.typename: "Void",
// CHECK-NEXT:       key.doc.brief: "This is a doc comment of P.foo",
// CHECK:          }

