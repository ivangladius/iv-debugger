
(in-package #:iv-debugger)

;;
;; ;; create list of registers and push new ones, so we can compare
;; if registers have changed and also time travel, like rr
;;
;; let A, B, C .... G be registers struct object
;; '(A C D)   D   '(E F G)
;; prev  ->  curr -> next
;; we can travel backward by pushing curr into next and popping prev into curr
;; the same way forward by pushing curr into prev and poppinng next into curr
;;
;;
(defvar *foreign-registers* nil
  "the registers after ptrace-getregs, its just a temporary holder for registers for global access.")

(defvar *current-registers* '()
  "holds a cl registers struct of type (symbol-value 'register-struct-name)")

(defvar *previous-registers* '()
  "holds a list of previous registers struct of type (symbol-value 'register-struct-name")

(defvar *next-registers* '()
  "holds a list of next registers struct of type (symbol-value 'register-struct-name")



(defvar cffi-registers-struct-name 'cffi-registers)
(defvar registers-struct-name 'registers)

;;
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *registers-symbols*
    '(r15 r14 r13 r12 rbp rbx r11 r10 r9 r8 rax rcx rdx rsi rdi
      orig-rax rip cs eflags rsp ss fs-base gs-base ds es fs gs)))

;; generate cffi user-regs-struct definiton
;; ---------------------------------

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro generate-cffi-user-regs-struct (name register-size)
    `(cffi:defcstruct ,(symbol-value name)
       ,@(loop :for reg :in *registers-symbols* :collect
               `(,reg ,register-size)))))


(eval-when (:compile-toplevel :load-toplevel :execute)
  (generate-cffi-user-regs-struct
   cffi-registers-struct-name  :uint64))

;; generate Common Lisp user-regs-struct definition to convert
;; cffi user-regs-struct to Common Lisp struct for convinience
;; so we can later access them with (register-rax *register*) ...
;; -----------------------------------------

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro generate-registers (name)
    `(defstruct ,(symbol-value name)
       ,@(loop :for reg :in *registers-symbols* :collect reg))))


(eval-when (:compile-toplevel :load-toplevel :execute)
  (generate-registers registers-struct-name))



;; generate accessor functions like (registers-rax) (registers-rip) ....
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro generate-struct-accessor-functions ()
    `(defvar *registers-accessors*
       ',(loop :for reg :in *registers-symbols*
               :collect
               (intern (format nil "~a-~a" registers-struct-name reg) :iv-debugger)))))


(eval-when (:compile-toplevel :load-toplevel :execute)
  (generate-struct-accessor-functions))



;; generate convinient functions like (rax) or (rdx :value 7)
;; which eithers gets or sets with the help of the above generated functions like (registers-rax) ...
;; or (setf (registers-rip) 111111)
;;
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro generate-register-getter-and-setter ()
    `(progn
       ,@(loop :for reg :in *registers-symbols*
               :for accessor :in *registers-accessors*

               :collect
               `(defun ,reg (&key value (registers (car *current-registers*) registers-supplied-p))
                  (if (and registers-supplied-p (null registers))
                      nil
                      (if value
                          (setf (,accessor registers) value)
                          (,accessor registers))))))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (generate-register-getter-and-setter))


;; copy foreign-object of user_regs_struct to our cl registers struct
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro copy-foreign-regs-to-cl (foreign-registers cl-registers)
    `(progn
       ,@(loop :for registers-symbol-as-accessor :in *registers-symbols*
               :collect
               `(,registers-symbol-as-accessor
                 :value (cffi:foreign-slot-value
                         ,foreign-registers
                         '(:struct ,cffi-registers-struct-name)
                         ',registers-symbol-as-accessor)
                 :registers ,cl-registers)))))

;;(defun registers-intersection (A B))


;; returns
(defun registers-changed (A B)
  (let ((changed-alist '()))
    (loop :for accessor :in *registers-accessors*
          :for register-symbol :in *registers-symbols*
          :do (progn
                (if (= (funcall accessor A) (funcall accessor B))
                    (push (cons register-symbol (funcall accessor A)) changed-alist))))
    changed-alist))



(defun registers-all-rax ()
  (terpri)
  (let ((x 0))
    (format t "[~a] : " (length *previous-registers*))
    (dolist (r *previous-registers*)
      (format t "~a " (registers-rax r)))
    (terpri)
    (format t "~a~%" (registers-rax (car *current-registers*)))
    (format t "[~a] : " (length *next-registers*))
    (dolist (r *next-registers*)
      (format t "~a " (registers-rax r)))
    (terpri))))

(defun registers-current ()
  (car *current-registers*))

(defun registers-next ()
  (push (pop *current-registers*) *previous-registers*)
  (push (pop *next-registers*) *current-registers*))

(defun registers-previous ()
  (push (pop *current-registers*) *next-registers*)
  (push (pop *previous-registers*) *current-registers*))

(defun registers-push (foreign-registers)
  (let ((temporary-registers (make-registers)))
    (copy-foreign-regs-to-cl foreign-registers temporary-registers)
    (if (null *current-registers*)
        (push temporary-registers *current-registers* )
        (progn
          (push (pop *current-registers*) *previous-registers*)
          (push temporary-registers *current-registers* )))))


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
