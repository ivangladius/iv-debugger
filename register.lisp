
(in-package #:iv-debugger)

;;
;; ;; create list of registers and push new ones, so we can compare
;; if registers have changed and also time travel, like rr
(defvar *registers-history* '())
(defvar cffi-registers-struct-name 'cffi-registers)
(defvar registers-struct-name 'registers)

;;
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *register-symbols*
    '(r15 r14 r13 r12 rbp rbx r11 r10 r9 r8 rax rcx rdx rsi rdi
      orig-rax rip cs eflags rsp ss fs-base gs-base ds es fs gs)))

;; generate cffi user-regs-struct definiton
;; ---------------------------------

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro generate-cffi-user-regs-struct (name register-size)
    `(cffi:defcstruct ,(symbol-value name)
       ,@(loop :for reg :in *register-symbols* :collect
               `(,reg ,register-size)))))

(generate-cffi-user-regs-struct
 cffi-registers-struct-name  :uint64)

;; generate Common Lisp user-regs definition to convert
;; cffi user-regs-struct to Common Lisp struct for convinience
;; so we can later access them with (register-rax *register*) ...
;; -----------------------------------------

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro generate-registers (name)
    `(defstruct ,(symbol-value name)
       ,@(loop :for reg :in *register-symbols* :collect reg))))

(generate-registers registers-struct-name)




;; -------------------------------------

;; (defun update-registers (foreign-registers)
;;   (dolist (reg *register-symbols*)
;;     (let ((accessor (intern (format nil "REGISTER-~a" reg) :iv-debugger)))
;;       (eval
;;        `(setf (,accessor *register*)
;;               (cffi:foreign-slot-value ,foreign-registers 'user-regs-struct ,reg))))))




;; generate functions to get rax not only from (car *registers-history*) but any register object
;;
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro generate-register-getter-and-setter ()
    `(progn
       ,@(loop :for reg :in *register-symbols*
               :collect
               (let ((accessor (intern (format nil "~a-~a" registers-struct-name reg) :iv-debugger)))
                 `(defun ,reg (&key value (registers (car *registers-history*) registers-supplied-p))
                    (if (and registers-supplied-p (null registers))
                        nil
                        (if value
                            (setf (,accessor registers) value)
                            (,accessor registers)))))))))

(generate-register-getter-and-setter)

;;(rax)


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro update-registers (foreign-registers)
    `(progn
       ,@(loop :for register-symbol-as-accessor :in *register-symbols*
               :collect
               `(,register-symbol-as-accessor
                 (cffi:foreign-slot-value ,foreign-registers '(:struct ,cffi-registers-struct-name) ',register-symbol-as-accessor))))))



(defun push-registers-to-history (registers)
  (unless (typep registers 'registers)
    (error "parameter register must be of type register"))
  (pushnew registers *registers-history*))

(defun pop-registers-from-history ()
  (pop *registers-history*))



;; ---------------------------------------------------
;;;; convinient for the user repl which I will later implement
;; to get a register value, just use:
;; (rax) => 7
;; to set a regster, just use:
;; (rbx 69) => 69
;; which sets the slot rbx in *register* to 69
;; by using (setf (register-rbx *register*) 69) internally
                                        ;

;;;; some testing

;; (setf *registers-history* nil)

;; (push-registers-to-history
;;  (make-registers
;;   :rax 69))

;; (rax)

;; (push-registers-to-history
;;  (make-registers
;;   :rax 420))

;; (rax)

;; (rax :registers (cadr *registers-history*))

;; (let ((last-registers (pop-registers-from-history)))
;;   (rax :registers last-registers))
