;;! target = "x86_64"
;;! test = "winch"

(module
    (func (result i64)
	(i64.const 0)
	(i64.const 0)
	(i64.div_s)
    )
)
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r11
;;       movq    0x10(%r11), %r11
;;       addq    $0x10, %r11
;;       cmpq    %rsp, %r11
;;       ja      0x51
;;   1c: movq    %rdi, %r14
;;       subq    $0x10, %rsp
;;       movq    %rdi, 8(%rsp)
;;       movq    %rsi, (%rsp)
;;       movl    $0, %ecx
;;       movl    $0, %eax
;;       cmpq    $0, %rcx
;;       je      0x53
;;   43: cqto
;;       idivq   %rcx
;;       addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;   51: ud2
;;   53: ud2
