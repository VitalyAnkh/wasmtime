;;! target = "x86_64"
;;! test = "winch"

(module
  (memory 1 1 shared)
  (func (export "_start") (result i32)
        (i32.atomic.rmw.and (i32.const 0) (i32.const 42))))
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r11
;;       movq    0x10(%r11), %r11
;;       addq    $0x14, %r11
;;       cmpq    %rsp, %r11
;;       ja      0x87
;;   1c: movq    %rdi, %r14
;;       subq    $0x10, %rsp
;;       movq    %rdi, 8(%rsp)
;;       movq    %rsi, (%rsp)
;;       movl    $0x2a, %eax
;;       movl    $0, %ecx
;;       andl    $3, %ecx
;;       cmpl    $0, %ecx
;;       jne     0x89
;;   48: movl    $0, %ecx
;;       movq    0x30(%r14), %r11
;;       movq    (%r11), %rdx
;;       addq    %rcx, %rdx
;;       subq    $4, %rsp
;;       movl    %eax, (%rsp)
;;       movl    (%rsp), %ecx
;;       addq    $4, %rsp
;;       movl    (%rdx), %eax
;;       movq    %rax, %r11
;;       andq    %rcx, %r11
;;       lock cmpxchgl %r11d, (%rdx)
;;       jne     0x6d
;;   7e: addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;   87: ud2
;;   89: ud2
