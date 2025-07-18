;;! component_model_async = true
;;! component_model_async_builtins = true

;; future.new
(component
  (core module $m
    (import "" "future.new" (func $future-new (result i64)))
  )
  (type $future-type (future u8))
  (core func $future-new (canon future.new $future-type))
  (core instance $i (instantiate $m (with "" (instance (export "future.new" (func $future-new))))))
)

;; future.read
(component
  (core module $libc (memory (export "memory") 1))
  (core instance $libc (instantiate $libc))
  (core module $m
    (import "" "future.read" (func $future-read (param i32 i32) (result i32)))
  )
  (type $future-type (future u8))
  (core func $future-read (canon future.read $future-type async (memory $libc "memory")))
  (core instance $i (instantiate $m (with "" (instance (export "future.read" (func $future-read))))))
)

;; future.read; with realloc
(component
  (core module $libc
    (func (export "realloc") (param i32 i32 i32 i32) (result i32) unreachable)
    (memory (export "memory") 1)
  )
  (core instance $libc (instantiate $libc))
  (core module $m
    (import "" "future.read" (func $future-read (param i32 i32) (result i32)))
  )
  (type $future-type (future string))
  (core func $future-read (canon future.read $future-type async (memory $libc "memory") (realloc (func $libc "realloc"))))
  (core instance $i (instantiate $m (with "" (instance (export "future.read" (func $future-read))))))
)

;; future.write
(component
  (core module $libc (memory (export "memory") 1))
  (core instance $libc (instantiate $libc))
  (core module $m
    (import "" "future.write" (func $future-write (param i32 i32) (result i32)))
  )
  (type $future-type (future u8))
  (core func $future-write (canon future.write $future-type async (memory $libc "memory")))
  (core instance $i (instantiate $m (with "" (instance (export "future.write" (func $future-write))))))
)

;; future.cancel-read
(component
  (core module $m
    (import "" "future.cancel-read" (func $future-cancel-read (param i32) (result i32)))
  )
  (type $future-type (future u8))
  (core func $future-cancel-read (canon future.cancel-read $future-type async))
  (core instance $i (instantiate $m (with "" (instance (export "future.cancel-read" (func $future-cancel-read))))))
)

;; future.cancel-write
(component
  (core module $m
    (import "" "future.cancel-write" (func $future-cancel-write (param i32) (result i32)))
  )
  (type $future-type (future u8))
  (core func $future-cancel-write (canon future.cancel-write $future-type async))
  (core instance $i (instantiate $m (with "" (instance (export "future.cancel-write" (func $future-cancel-write))))))
)

;; future.drop-readable
(component
  (core module $m
    (import "" "future.drop-readable" (func $future-drop-readable (param i32)))
  )
  (type $future-type (future u8))
  (core func $future-drop-readable (canon future.drop-readable $future-type))
  (core instance $i (instantiate $m (with "" (instance (export "future.drop-readable" (func $future-drop-readable))))))
)

;; future.drop-writable
(component
  (core module $m
    (import "" "future.drop-writable" (func $future-drop-writable (param i32)))
  )
  (type $future-type (future u8))
  (core func $future-drop-writable (canon future.drop-writable $future-type))
  (core instance $i (instantiate $m (with "" (instance (export "future.drop-writable" (func $future-drop-writable))))))
)
