
(in-package #:iv-debugger)

;; transform c struct after ptrace-getregs to the common lisp struct user-regs
;;
(eval-when (:compile-toplevel :load-toplevel :execute)
(defparameter *register-symbols*
  '(r15 r14 r13 r12 rbp rbx r11 r10 r9 r8 rax rcx rdx rsi rdi
    orig-rax rip cs eflags rsp ss fs-base gs-base ds es fs gs)))

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

(defvar *register* (make-register))


;; -------------------------------------

;; (defun update-registers (foreign-registers)
;;   (dolist (reg *register-symbols*)
;;     (let ((accessor (intern (format nil "REGISTER-~a" reg) :iv-debugger)))
;;       (eval
;;        `(setf (,accessor *register*)
;;               (cffi:foreign-slot-value ,foreign-registers 'user-regs-struct ,reg))))))


(eval-when (:compile-toplevel :load-toplevel :execute)
(defmacro generate-register-getter-and-setter ()
  `(progn
     ,@(loop :for reg :in *register-symbols*
             :collect
             (let ((accessor
                     `(,(intern (format nil "REGISTER-~a" reg) :iv-debugger) *register*)))
               `(defun ,reg (&optional value)
                  (if value
                      (setf ,accessor value)
                      ,accessor)))))))

(generate-register-getter-and-setter)

(defmacro update-registers (foreign-registers)
  `(progn
     ,@(loop :for reg :in *register-symbols*
             :collect
             `(,reg (cffi:foreign-slot-value ,foreign-registers '(:struct user-regs-struct) ',reg)))))


;; ---------------------------------------------------
;;;; convinient for the user repl which I will later implement
;; to get a register value, just use:
;; (rax) => 7
;; to set a regster, just use:
;; (rbx 69) => 69
;; which sets the slot rbx in *register* to 69
;; by using (setf (register-rbx *register*) 69) internally
                                        ;
