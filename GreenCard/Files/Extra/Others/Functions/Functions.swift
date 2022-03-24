import Foundation

func replace(_ method: Selector, with anotherMethod: Selector, for clаss: AnyClass) {
  let original = class_getInstanceMethod(clаss, method)
  let swizzled = class_getInstanceMethod(clаss, anotherMethod)
  switch class_addMethod(clаss, method, method_getImplementation(swizzled!), method_getTypeEncoding(swizzled!)) {
  case true:
    class_replaceMethod(clаss, anotherMethod, method_getImplementation(original!), method_getTypeEncoding(original!))
  case false:
    method_exchangeImplementations(original!, swizzled!)
  }
}
