;;;; iv-debugger.asd

(asdf:defsystem #:iv-debugger
  :description "Debugger to hack the planet"
  :author "Maximilian Ivan Filipov maximilian.filipov@proton.me"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on ("str"
               "cffi"
	       "capstone"
	       "bit-smasher"
               "slynk"
               "bordeaux-threads")
  :components ((:file "package")
               (:file "general-utilities")
               (:file "process")
               (:file "syscall-bindings")
               (:file "syscall-wrapper")
               (:file "memory-utilities")
               (:file "shared-libs/bindings")
               (:file "shared-libs/wrapper")
               (:file "register")
	       (:file "memory")
	       (:file "instruction")
               (:file "commands")
               (:file "iv-debugger")))

