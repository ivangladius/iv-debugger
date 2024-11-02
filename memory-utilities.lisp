
(in-package #:iv-debugger)

(defun make-argv (args)
  "Creates a C array of strings (NULL-terminated) for execv."
  (and args
       (let ((c-args (cffi:foreign-alloc :pointer :count (1+ (length args)))))
         (loop for i from 0 below (length args)
               for arg in args do
                 (setf (cffi:mem-aref c-args :pointer i) (cffi:foreign-string-alloc arg)))
         ;; Null-terminate the array
         (setf (cffi:mem-aref c-args :pointer (length args)) (cffi:null-pointer))
         c-args)))

(defun free-argv (argv n)
  (dotimes (i n)
    (cffi:foreign-free (cffi:mem-aref argv :pointer i)))
  (cffi:foreign-free argv))

