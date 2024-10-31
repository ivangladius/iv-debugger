;;;; iv-debugger.asd

(asdf:defsystem #:iv-debugger
  :description "Debugger to hack the planet"
  :author "Maximilian Ivan Filipov maximilian.filipov@proton.me"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on ("str")
  :components ((:file "package")
               (:file "iv-debugger")
	       (:file "register")
	       (:file "syscall-wrapper")
	       (:file "syscall-bindings")
	       (:file "memory-utilities")))
