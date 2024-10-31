;;;; iv-debugger.asd

(asdf:defsystem #:iv-debugger
  :description "Debugger to hack the planet"
  :author "Maximilian Ivan Filipov maximilian.filipov@proton.me"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on ("str" "cffi")
  :components ((:file "package")
	       (:file "register")
	       (:file "process")
	       (:file "syscall-bindings")
	       (:file "syscall-wrapper")
	       (:file "memory-utilities")
               (:file "iv-debugger")))
