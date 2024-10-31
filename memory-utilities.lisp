
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


(defmacro with-heap-memory ((name &key
				   (type :uint8)
				   (count 1))
				   &body body)
  `(let ((,name (cffi:foreign-alloc ,type :count ,count)))
     (unwind-protect
	  (progn
	    ,@body)
       (cffi:foreign-free ,name))))

(defmacro with-heap-memory (
			    &body body)
  `(progn
     (mapcar #'(lambda (name)
		 (setf name (cffi:foreign-alloc ,type :count ,count)))
	     ,name-or-names)
     (progn
       ,@body)
     (mapcar #'(lambda (name)
		 (cffi:foreign-free name))
	     ,name-or-names)))




(defun with-heap-memory-test
    (with-heap-memory ((name :type :char :count 32))
      (dotimes (i 32)
	(setf (cffi:mem-aref name :char i) (char-code #\A)))
      (format t "string: ~a~%" (cffi:foreign-string-to-lisp name))
      (setf (cffi:mem-aref name :char 0) (char-code #\B))
      (format t "string: ~a~%" (cffi:foreign-string-to-lisp name))))


(defmacro des-test (name-type-count)
  (let ((obj (gensym)))
    `(progn
       (mapcar #'(lambda (,obj)
		   (destructuring-bind (name &key type count) name-type-count
		     (format t "name: ~a~%type: ~a~%count: ~a~%~%"
			     name type count)))
	      ',names-and-options))))

(progn
 (mapcar #'(lambda (#:g366) (print obj))
         '((one :char :count 256) (two :int :count 2))))



(defun hello (args)
  (destructuring-bind (a &key name age) args
    (format t "[~a] = aaa: ~a~%bbb: ~a~%" a name age)))





 
