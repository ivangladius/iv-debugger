;;;; iv-debugger.asd

(asdf:defsystem #:iv-debugger
  :description "Debugger to hack the planet"
  :author "Your Name maximilian.filipov@proton.me"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on ("str")
  :components ((:file "package")
               (:file "iv-debugger")))
