;;! target = "x86_64"
;;! test = "winch"

(module
  (memory 1 1 shared)
  (func (export "_start") (result i64)
        (i64.atomic.rmw16.and_u (i32.const 0) (i64.const 42))))
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r11
;;       movq    0x10(%r11), %r11
;;       addq    $0x18, %r11
;;       cmpq    %rsp, %r11
;;       ja      0x7c
;;   1c: movq    %rdi, %r14
;;       subq    $0x10, %rsp
;;       movq    %rdi, 8(%rsp)
;;       movq    %rsi, (%rsp)
;;       movl    $0x2a, %eax
;;       movl    $0, %ecx
;;       andw    $1, %cx
;;       cmpw    $0, %cx
;;       jne     0x7e
;;   48: movl    $0, %ecx
;;       movq    0x30(%r14), %r11
;;       movq    (%r11), %rdx
;;       addq    %rcx, %rdx
;;       pushq   %rax
;;       popq    %rcx
;;       movzwq  (%rdx), %rax
;;       movq    %rax, %r11
;;       andq    %rcx, %r11
;;       lock cmpxchgw %r11w, (%rdx)
;;       jne     0x5d
;;   6f: movzwq  %ax, %rax
;;       addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;   7c: ud2
;;   7e: ud2
