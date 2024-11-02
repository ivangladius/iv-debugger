;; iv-debugger.lisp

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
  (setf (process-info-child *process*) (sys-getpid))
  ;; (sys-close read-end)
  ;; (sys-dup2 write-end 1)

  (ptrace-traceme)
  (execvp exe args)

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


(defun set-rax (value)
  (setf (register-rax *register*) value))


(defun rax (&optional val)
  (if val
      (setf (register-rax *register*) val)
      (register-rax *register*)))

                                        ;

(defun hello-msg ()
  (sleep 0.5)
  (format nil "[~a, ~a, ~a, ~a] = ~a ~a ~a ~a"
          "rax" "rbx" "rcx" "rdx"
          (rax) (rbx) (rcx) (rdx)))

(defun parent-process (child-pid read-end write-end)
  (declare (ignore read-end))
  (declare (ignore write-end))
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
  (slynk:create-server :port 9998 :dont-close nil)
  (cffi:with-foreign-objects ((status-obj :int)
                              (regs '(:struct user-regs-struct)))
    (wait-for-execv*-sigterm-from-child-with-waitpid
     status-obj
     :child-pid child-pid)
    (let ((msg "hello world"))
      (loop :do (progn
                  (sleep 0.1)
                  (format t "~a~%" (hello-msg))
                  (force-output)
                  )))

    ;; child has stopped

    ))

(defun hello-msg ()
  (format nil "hello nein nein nein"))

(defun parent-process (child-pid read-end write-end)
  (declare (ignore read-end))
  (declare (ignore write-end))
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
  (slynk:create-server :port 4005)
  (cffi:with-foreign-objects ((status-obj :int)
                              (regs '(:struct user-regs-struct)))
    (wait-for-execv*-sigterm-from-child-with-waitpid
     status-obj
     :child-pid child-pid)
    (let ((msg "hello world"))
      (loop :do (progn
                  (sleep 0.1)
                  (format t "~a~%" (hello-msg))
                  (force-output)
                  )))

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
          ((> pid 0) (parent-process pid read-end write-end))
          (t (format t "error happened: pid = ~a~%" pid)))))))

;; (defvar *running-threads* nil)

;; (defun main (test-function)
;;   (push (bt:make-thread #'(lambda () (funcall test-function))) *running-threads*)
;;   (mapc #'bt:join-thread *running-threads*))

;; (defun kill-threads (threads)
;;   (loop :for thread = (pop *running-threads*)
;;         :while thread
;;         :do (progn
;;               (force-format t "killing thread: ")
;;               (print thread)
;;               (bt:destroy-thread thread))))


;; (kill-threads *running-threads*)

(defun run-hackme ()
  (debug-exe "hackme" '("1234")))

(defun run-chromium ()                  ;
  (debug-exe "chromium" '("--new-window")))
