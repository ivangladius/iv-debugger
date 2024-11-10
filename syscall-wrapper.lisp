
(in-package #:iv-debugger)

;; long ptrace(enum __ptrace_request op, pid_t pid,
;;                void *addr, void *data);
(defun ptrace-traceme ()
  (sys-ptrace +ptrace-traceme+ 0 (cffi:null-pointer) (cffi:null-pointer)))


(defun ptrace-getregs (pid regs)
  (unless (cffi:pointerp regs)
    (error "regs must be a cffi pointer to a user-regs-struct"))
  (sys-ptrace +ptrace-getregs+ pid (cffi:null-pointer) regs))

(defun ptrace-peekdata (pid address)
  (unless (integerp pid) (error "pid must be integer"))
  (unless (integerp address)
    (error "addresss must be a integer"))
  (let ((address-pointer (cffi:make-pointer address)))
    (sys-ptrace +ptrace-peekdata+ pid address-pointer (cffi:null-pointer))))
    
    
(defun get-errno ()
  (cffi:mem-ref (cffi:foreign-symbol-pointer "errno") :int))

(defun ptrace-singlestep (pid)
  (unless (integerp pid)
    (error "pid must be a integer"))
  (sys-ptrace +ptrace-singlestep+ pid (cffi:null-pointer) (cffi:null-pointer)))

;; stolen from https://github.com/k-stz/cl-ptrace/blob/master/cl-ptrace/cl-ptrace.lisp
(defun ptrace-successful? (ptrace-return-value &optional (print-errno-description? t))
  "Return T if last ptrace call was successful. Optionally print human readable errno description."
  (declare ((unsigned-byte 64) ptrace-return-value))
  (if (and (= ptrace-return-value #xffffffffffffffff) (/= *errno* 0))
      (progn
	(when print-errno-description?
	  (format t "~a~%" (strerror)))
	(values nil ptrace-return-value))
      t))

;; int pipe(int pipefd[2]);
(defmacro with-unnamed-unix-pipe ((read-end write-end) &body body)
  (let ((pipe-fd (gensym)))
    `(let* ((,pipe-fd (cffi:foreign-alloc :int :count 2))
            (pipe-fd-status (sys-pipe ,pipe-fd)))
       (declare (ignore pipe-fd-status)) ;; TODO: implement error handlign
       (let ((,read-end (cffi:mem-aref ,pipe-fd :int 0))
             (,write-end (cffi:mem-aref ,pipe-fd :int 1)))
         (progn
           ,@body)))))

;; int execv(const char *path, char *const argv[]);
(defun execv (exe args)
  (let ((argv (make-argv args)))
    (unwind-protect
         (sys-execv exe argv)
      (free-argv argv (length args)))))

;; int execvp(const char *path, char *const argv[]);
(defun execvp (exe args)
  (let ((argv (make-argv args)))
    (unwind-protect
         (sys-execvp exe argv)
      (free-argv argv (length args)))))

;; pid_t waitpid(pid_t pid, int *_Nullable wstatus, int options);
(defun waitpid (status-obj &key (pid -1) (options 0))
  "TODO: import headers where options are defined there must
   be some libraries which can import c headers for sure"
  (unless (cffi:pointerp status-obj)
    (error "waitpid (status): status must be a foreign pointer to a int"))
  (sys-waitpid pid status-obj options)
  (cffi:mem-ref status-obj :int))

(defun child-exited-p (status)
  (unless (cffi:pointerp status)
    (error "child-exited-p (status): status must be a foreign pointer to a int"))
  (let ((status-val (cffi:mem-ref status :int)))
    (wifexited status-val)))

(defun wait-for-execv*-sigterm-from-child-with-waitpid (status-obj &key (child-pid -1) (options 0))
  (let ((status-val (waitpid status-obj :pid child-pid)))
    (if (and (wifstopped status-val) (= (wstopsig status-val) +sigtrap+))
        (force-format t "child process stopped! Happy Hacking!~%")
        (error-format "parent-process: Could not stop child process [~a]." child-pid))))
