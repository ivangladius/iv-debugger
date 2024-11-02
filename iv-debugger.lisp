;; iv-debugger.lisp
;;
;; (main-start-or-restart #'run-hackme)
;;
(in-package #:iv-debugger)


(declaim (optimize (speed 0) (space 0) (debug 3)))

(defvar *process* nil)
(defvar +error-sys-execv+ 69)


;; glibc (https://github.com/bminor/glibc)
;; #define	__WEXITSTATUS(status)	(((status) & 0xff00) >> 8)
;; #define	__WTERMSIG(status)	((status) & 0x7f)
;;
(defun child-process (exe args read-end write-end)
  (declare (ignore read-end))
  (declare (ignore write-end))
  ;; (sys-close read-end)
  ;; (sys-dup2 write-end 1)

  ;; dont use execvp, somehow the process doesn't get stopped in the parent
  (ptrace-traceme)
  (execv exe args)

  (force-format t "could not execv process ~a ~a" exe args)
  (sys-exit +error-sys-execv+)

  ;; (print "child")
  ;; (print read-end)
  ;; (print write-end)

  ;; (sys-close read-end)
  ;; (sys-dup2 write-end 1)
  ;; (sys-close write-end)
  ;; (execv exe args))
  )

(defun initialize-further-process-info (child-pid)
  (setf (process-info-child *process*) child-pid)
  (setf (process-info-running *process*) t))

(defun debugger-logic (pid status-obj regs)
  (declare (ignore status-obj))
  (sleep 1)
  (let ((ptrace-retval (ptrace-getregs pid regs)))
    (update-registers regs)
    (force-format t "~%ptrace-getregs~%[errno, retval, rip, rax, parent, child] : ~a ~a ~a ~a ~a ~a~%"
                  (get-errno)
                  ptrace-retval
                  (format nil "0x~X" (rip))
                  (format nil "0x~X" (rax))
                  (sys-getpid)
                  (process-info-child *process*)))

  (ptrace-singlestep pid)

  (when (= (waitpid status-obj :pid pid) -1)
    (error-format "could not singlestep at [rip] : 0x~X" (rip)))

  )

(defun parent-process (child-pid read-end write-end)
  (declare (ignore read-end))
  (declare (ignore write-end))
  (initialize-further-process-info
   child-pid)
  ;; (sys-close write-end)
  ;; (let* ((len 8000)
  ;;        (buf (cffi:foreign-alloc :char :count len))
  ;;        (n   (sys-read read-end buf len)))
  ;;   (force-format t "child process send[~a]: ~%~a~%"
  ;;                 n
  ;;                 (cffi:foreign-string-to-lisp buf :count n :encoding :ascii))
  ;;   (cffi:foreign-free buf))
  ;; (force-format t "waiting....")
  ;;
  ;; (slynk:create-server :port 4005)
  (cffi:with-foreign-objects ((status-obj :int)
                              (regs '(:struct user-regs-struct)))

    ;; when child executes execv* , sigtrap gets signaled to the
    ;; parent process, we wait for that, else execv* wasn't successful
    (wait-for-execv*-sigterm-from-child-with-waitpid status-obj
                                                     :child-pid child-pid)

    ;; execute debugger logic here
    (loop :do (progn
                (debugger-logic child-pid status-obj regs)
                ))

    ;; child has stopped

    ))




;; (loop :while (not (wifexited (waitpid status-obj))
;;                   :do (progn
;;                         (update-registers regs)
;;                         (force-print *register*)
;;                         (sleep 0.5)
;;                         ))
;;              (force-print "after loop")))


;; (let ((exit-code (child-exited-p (waitpid status-obj))))
;;   (if (/= exit-code 0)
;;       (force-format t "[-] : child process exited with code: ~a~%"
;;                     exit-code)
;;       (force-format t "[+] : child process successfully started!")))))
(defun debug-exe (exe args)
  "Spawn child process trough fork(), then pass over the pipes for communication
  and then let the child process execv. The pipes are needed to transfer the child process
  stdout to our process pipe with dup2(...) "

  (unless (probe-file exe)
    (error-format "~a executable not found." exe))

  (setf *process* (make-process-info
                   :name exe
                   :args args
                   :parent (sys-getpid)
                   :parent-parent (sys-getppid)))
  (println *process*)
  (with-unnamed-unix-pipe (read-end write-end)
    (let ((pid (sys-fork)))
      (cond
        ((= pid 0) (child-process exe args read-end write-end))
        ((> pid 0) (parent-process pid read-end write-end))
        (t (error-format "error happened: pid = ~a~%" pid))))))

(defvar *main-thread* nil)

(defun main (test-function)
  (setf *main-thread*
        (bt:make-thread #'(lambda () (funcall test-function))))
  (ignore-errors
   (bt:join-thread *main-thread*)))     ;

(defun kill-main-thread ()
  (and *main-thread* (bt:thread-alive-p *main-thread*)
       (bt:destroy-thread *main-thread*)))


(defun main-start-or-restart (test-function)
  (kill-main-thread)
  (main test-function))

(defun run-hackme ()
  (debug-exe "hackme" '("1234")))

(defun run-chromium ()                  ;
  (debug-exe "chromium" '("--new-window")))
