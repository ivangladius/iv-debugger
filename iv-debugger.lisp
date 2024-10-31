;; iv-debugger.lisp

(in-package #:iv-debugger)

(cffi:defctype pid-t :int)
(cffi:defctype size-t :unsigned-long)
(cffi:defctype ssize-t :long)


(defconstant +ptrace-traceme+ 0)
(defconstant +wnohang+ 1)

(defvar *pipefds* nil)

(defun child-process (exe args read-end write-end)
  (format t "from child-process -> pid: ~a~%" (sys-getpid))
  (format t "from child-process -> ppid: ~a~%" (sys-getppid))
  ;; (ptrace-traceme)
  
  ;; (print "child")
  ;; (print read-end)
  ;; (print write-end)
  
  ;; (sys-close read-end)
  ;; (sys-dup2 write-end 1)
  ;; (sys-close write-end)
  ;; (execv exe args))
  )

(defun parent-process (read-end write-end)
  (format t "from parent-process -> pid: ~a~%" (sys-getpid))
  (format t "from parent-process -> ppid: ~a~%" (sys-getppid))
  ;; (print read-end)
  ;; (print write-end)
  ;; (sys-close write-end)
  ;; (let* ((len 8000)
  ;; 	 (buf (cffi:foreign-alloc :char :count len))
  ;; 	 (n   (sys-read read-end buf len)))
  ;;   (format t "child process send[~a]: ~%~a~%"
  ;; 	    n
  ;; 	    (cffi:foreign-string-to-lisp buf :count n :encoding :ascii))
  ;;   (sys-waitpid -1 (cffi:null-pointer) 0)
  ;;   (cffi:foreign-free buf)))
  )
  
(defun debug-exe (exe args)
  (with-unnamed-unix-pipe (read-end write-end)
    (let ((pid (sys-fork)))
      (cond
	((= pid 0) (let ((*pid* pid))
		     (child-process exe args read-end write-end))) ;; child-process
	((> pid 0) (let ((*ppid* pid))
		     (parent-process read-end write-end)))      ;; parent-process
	(t (format t "error happened: pid = ~a~%" pid))))))


