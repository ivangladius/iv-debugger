;;;; iv-debugger.lisp

(in-package #:iv-debugger)

(cffi:defctype pid-t :int)
(cffi:defctype size-t :unsigned-long)
(cffi:defctype ssize-t :long)

(cffi:defcfun ("ptrace" sys-ptrace) :long
  (request :int)
  (pid pid-t)
  (addr :pointer)
  (data :pointer))

(defconstant +ptrace-traceme+ 0)
(defconstant +wnohang+ 1)

(defun ptrace-traceme ()
  (sys-ptrace +ptrace-traceme+ 0 (cffi:null-pointer) (cffi:null-pointer)))

(cffi:defcfun ("fork" sys-fork) pid-t)
(cffi:defcfun ("pipe" sys-pipe) :int (pipefd :pointer))
(cffi:defcfun ("dup2" sys-dup2) :int (oldfd :int) (newfd :int))
(cffi:defcfun ("close" sys-close) :int (fd :int))
(cffi:defcfun ("read" sys-read) ssize-t (fd :int) (buf :pointer) (count size-t))
(cffi:defcfun ("execv" sys-execv) :int (pathname :string) (argv :pointer))
(cffi:defcfun ("waitpid" sys-waitpid) pid-t (pid pid-t) (status :pointer) (option :int))

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

(defmacro with-unnamed-unix-pipe ((read-end write-end) &body body)
  ;; int pipe(int pipefd[2]);
  (let ((pipes (gensym)))
    `(let* ((,pipes (cffi:foreign-alloc :int :count 2))
	   (pipes-status (sys-pipe ,pipes)))
       (let ((,read-end (cffi:mem-aref ,pipes :int 0))
	     (,write-end (cffi:mem-aref ,pipes :int 1)))
	 (progn
	   ,@body)))))

(defun execv (exe args)
  (let ((argv (make-argv args)))
    (unwind-protect
	     (sys-execv exe argv)
      (free-argv argv (length args)))))

(defun child-process (exe args read-end write-end)
  (format t "[+] attaching to executable ~a with args ~a~%" exe args)
  (ptrace-traceme)
  
  (print "child")
  (print read-end)
  (print write-end)
  
  (sys-close read-end)
  (sys-dup2 write-end 1)
  (sys-close write-end)
  (execv exe args))

(defun parent-process (read-end write-end)
  (print "parent")
  (print read-end)
  (print write-end)
  (sys-close write-end)
  (let* ((len 8000)
	 (buf (cffi:foreign-alloc :char :count len))
	 (n   (sys-read read-end buf len)))
    (format t "child process send[~a]: ~%~a~%"
	    n
	    (cffi:foreign-string-to-lisp buf :count n :encoding :ascii))
    (sys-waitpid -1 (cffi:null-pointer) 0)
    (cffi:foreign-free buf)))
  
(defun debug-exe (exe args)
  (with-unnamed-unix-pipe (read-end write-end)
    (let ((pid (sys-fork)))
      (cond
	((= pid 0) (child-process exe args read-end write-end)) ;; child-process
	((> pid 0) (parent-process read-end write-end))      ;; parent-process
	(t (format t "error happened: pid = ~a~%" pid))))))


