;;! target = "aarch64"
;;! test = "compile"
;;! flags = " -C cranelift-enable-heap-access-spectre-mitigation -O static-memory-maximum-size=0 -O static-memory-guard-size=4294967295 -O dynamic-memory-guard-size=4294967295"

;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;; !!! GENERATED BY 'make-load-store-tests.sh' DO NOT EDIT !!!
;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

(module
  (memory i32 1)

  (func (export "do_store") (param i32 i32)
    local.get 0
    local.get 1
    i32.store offset=0)

  (func (export "do_load") (param i32) (result i32)
    local.get 0
    i32.load offset=0))

;; wasm[0]::function[0]:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldr     x9, [x2, #0x40]
;;       ldr     x10, [x2, #0x38]
;;       mov     w11, w4
;;       mov     x12, #0
;;       add     x10, x10, w4, uxtw
;;       cmp     x11, x9
;;       csel    x10, x12, x10, hi
;;       csdb
;;       str     w5, [x10]
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;
;; wasm[0]::function[1]:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       ldr     x9, [x2, #0x40]
;;       ldr     x10, [x2, #0x38]
;;       mov     w11, w4
;;       mov     x12, #0
;;       add     x10, x10, w4, uxtw
;;       cmp     x11, x9
;;       csel    x10, x12, x10, hi
;;       csdb
;;       ldr     w2, [x10]
;;       ldp     x29, x30, [sp], #0x10
;;       ret
