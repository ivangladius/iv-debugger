


(cffi:defcstruct user-regs-struct
  (r15 :uint64)
  (r14 :uint64)
  (r13 :uint64)
  (r12 :uint64)
  (rbp :uint64)
  (rbx :uint64)
  (r11 :uint64)
  (r10 :uint64)
  (r9 :uint64)
  (r8 :uint64)
  (rax :uint64)
  (rcx :uint64)
  (rdx :uint64)
  (rsi :uint64)
  (rdi :uint64)
  (orig_rax :uint64)
  (rip :uint64)
  (cs :uint64)
  (eflags :uint64)
  (rsp :uint64)
  (ss :uint64)
  (fs_base :uint64)
  (gs_base :uint64)
  (ds :uint64)
  (es :uint64)
  (fs :uint64)
  (gs :uint64))

(defstruct user-regs
  r15
  r14
  r13
  r12
  rbp
  rbx
  r11
  r10
  r9
  r8
  rax
  rcx
  rdx
  rsi
  rdi
  orig-rax
  rip
  cs
  eflags
  rsp
  ss
  fs-base
  gs-base
  ds
  es
  fs
  gs)

(defun convert-to-user-regs (foreign-regs)
  "Convert a foreign user-regs-struct to a Common Lisp user-regs struct."
  (make-user-regs
   :r15 (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'r15)
   :r14 (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'r14)
   :r13 (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'r13)
   :r12 (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'r12)
   :rbp (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rbp)
   :rbx (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rbx)
   :r11 (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'r11)
   :r10 (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'r10)
   :r9 (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'r9)
   :r8 (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'r8)
   :rax (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rax)
   :rcx (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rcx)
   :rdx (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rdx)
   :rsi (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rsi)
   :rdi (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rdi)
   :orig-rax (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'orig_rax)
   :rip (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rip)
   :cs (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'cs)
   :eflags (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'eflags)
   :rsp (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'rsp)
   :ss (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'ss)
   :fs-base (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'fs_base)
   :gs-base (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'gs_base)
   :ds (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'ds)
   :es (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'es)
   :fs (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'fs)
   :gs (cffi:foreign-slot-value foreign-regs 'user-regs-struct 'gs)))
