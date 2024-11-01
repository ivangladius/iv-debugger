
(in-package #:iv-debugger)

;; long ptrace(enum __ptrace_request op, pid_t pid,
;;                void *addr, void *data);
(defun ptrace-traceme ()
  (sys-ptrace +ptrace-traceme+ 0 (cffi:null-pointer) (cffi:null-pointer)))

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

;; pid_t waitpid(pid_t pid, int *_Nullable wstatus, int options);
(defun waitpid (status-obj &key (pid -1) (options 0))
  "TODO: import headers where options are defined there must
   be some libraries which can import c headers for sure"
  (unless (cffi:pointerp status-obj)
    (error "waitpid (status): status must be a foreign pointer to a int"))
  (sys-waitpid pid status-obj options)
  status-obj)
