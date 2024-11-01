
(in-package #:iv-debugger)

;; transform c struct after ptrace-getregs to the common lisp struct user-regs
;;
;; ----------------------------------
;;
(defvar *register-symbols*
  '(r15 r14 r13 r12 rbp rbx r11 r10 r9 r8 rax rcx rdx rsi rdi
    orig-rax rip cs eflags rsp ss fs-base gs-base ds es fs gs))

;; generate cffi user-regs-struct definiton
;; ---------------------------------

(defmacro generate-cffi-user-regs-struct (name register-size)
  `(cffi:defcstruct ,name
     ,@(loop :for reg :in *register-symbols* :collect
             `(,reg ,register-size))))

(generate-cffi-user-regs-struct user-regs-struct  :uint64)

;; generate Common Lisp user-regs definition to convert
;; cffi user-regs-struct to Common Lisp struct for convinience
;; so we can later access them with (register-rax *register*) ...
;; -----------------------------------------

(defmacro generate-registers (name)
  `(defstruct ,name
     ,@(loop :for reg :in *register-symbols* :collect reg)))

(generate-registers register)

(defvar *register* (make-user-regs))


;; -------------------------------------

(defun update-registers (foreign-registers)
  (dolist (reg *register-symbols*)
    (let ((accessor (intern (format nil "REGISTER-~a" reg) :iv-debugger)))
      (setf (funcall accessor *register*)
            (cffi:foreign-slot-value foreign-registers 'user-regs-struct reg)))))





;;  (update-registers (foreign user))


(dolist (reg *register-symbols*)
  (print (intern (format nil "REGISTER-~a" reg) :iv-debugger)))
