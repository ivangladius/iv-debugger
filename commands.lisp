
(in-package #:iv-debugger)

(defun step-instruction ()
  (let ((ptrace-retval (ptrace-singlestep (process-info-child *process*))))
    (if (= ptrace-retval -1)
        (error "step-instruction: could not singlestep.")
        (progn
          (registers-push *foreign-registers*)))))

