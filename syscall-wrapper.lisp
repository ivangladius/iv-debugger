

(defun ptrace-traceme ()
  (sys-ptrace +ptrace-traceme+ 0 (cffi:null-pointer) (cffi:null-pointer)))

(defmacro with-unnamed-unix-pipe ((read-end write-end) &body body)
  ;; int pipe(int pipefd[2]);
  (let ((pipes (gensym)))
    `(let* ((,pipes (cffi:foreign-alloc :int :count 2))
	    (pipes-status (sys-pipe ,pipes)))
       (declare (ignore pipes-status)) ;; TODO: implement error handlign
       (let ((,read-end (cffi:mem-aref ,pipes :int 0))
	     (,write-end (cffi:mem-aref ,pipes :int 1)))
	 (progn
	   ,@body)))))

(defun execv (exe args)
  (let ((argv (make-argv args)))
    (unwind-protect
	     (sys-execv exe argv)
      (free-argv argv (length args)))))

