;; iv-debugger.lisp

(in-package #:iv-debugger)


(defvar *process* nil)
(defvar +error-sys-execv+ 69)

;; glibc (https://github.com/bminor/glibc)
;; #define	__WEXITSTATUS(status)	(((status) & 0xff00) >> 8)
;; #define	__WTERMSIG(status)	((status) & 0x7f)
;;
(defun child-process (exe args read-end write-end)
  (setf (process-info-child *process*) (sys-getpid))
  (sys-close read-end)
  (sys-dup2 write-end 1)
  ;; (when (=
  (execv exe args)
  (sys-exit +error-sys-execv+)
  ;;      -1)
  ;; (error (format nil "could not execv ~a ~a" exe args)))

  ;; execv failed
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
  (sys-close write-end)
  (let* ((len 8000)
         (buf (cffi:foreign-alloc :char :count len))
         (n   (sys-read read-end buf len)))
    (force-format t "child process send[~a]: ~%~a~%"
                  n
                  (cffi:foreign-string-to-lisp buf :count n :encoding :ascii))
    (cffi:foreign-free buf))
  (force-format t "waiting....")

  (cffi:with-foreign-object (status-obj :int)
    (sys-waitpid -1 status-obj 0)
    (let ((status (cffi:mem-ref status-obj :int)))
      (if (wifexited status)
          (progn
            (force-format t "[-] : child process exited with code: ~a~%"
                          (wexitstatus status))
            (force-format t "[-] : child process exited with code: ~a~%"
                          (wexitstatus status)
                          ))))))




(defun debug-exe (exe args)
  "Spawn child process trough fork(), then pass over the pipes for communication
  and then let the child process execv. The pipes are needed to transfer the child process
  stdout to our process pipe with dup2(...) "
  (let* ((*process* (make-process-info
                     :name exe
                     :args args
                     :parent (sys-getpid)
                     :parent-parent (sys-getppid))))
    (println *process*)
    (with-unnamed-unix-pipe (read-end write-end)
      (let ((pid (sys-fork)))
        (cond
          ((= pid 0) (child-process exe args read-end write-end))
          ((> pid 0) (parent-process read-end write-end))
          (t (format t "error happened: pid = ~a~%" pid)))))))

(defun run-hackme ()
  (debug-exe "/home/asdf/quicklisp/local-projects/debugger/hackme" '("1234")))
